// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
// import {console} from "forge-std/console.sol";
import {
    MapConfig,
    Movable,
    Obstruction,
    Player,
    Position,
    Resource,
    Mineable,
    Inventory,
    Stats,
    Item,
    ItemTableId,
    OwnedBy,
    OwnedByTableId,
    Hungry,
    Thirsty,
    Stats,
    Died
} from "../codegen/Tables.sol";
import {ResourceType, TerrainType, ItemType, Direction} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {IWorld} from "../codegen/world/IWorld.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import {query, QueryFragment, QueryType} from "@latticexyz/world/src/modules/keysintable/query.sol";

contract MapSystem is System {
    function setTerrain(uint32 x, uint32 y, TerrainType terrainType) public {
        (uint32 width, uint32 height, bytes memory terrain) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        terrain[(y * width) + x] = bytes1(uint8(terrainType));
        MapConfig.set(width, height, terrain);
    }

    function removeTerrain(uint32 x, uint32 y) public {
        (uint32 width, uint32 height, bytes memory terrain) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        terrain[(y * width) + x] = bytes1(uint8(TerrainType.None));
        MapConfig.set(width, height, terrain);
    }

    function spawn(uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(address(_msgSender()));
        require(!Player.get(player), "already spawned");

        // Constrain position to map size, wrapping around if necessary
        (uint32 width, uint32 height,) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        bytes32 position = positionToEntityKey(x, y);
        require(!Obstruction.get(position), "this space is obstructed");

        // Before spawning the player, we will initialize their stats
        Stats.set(player, 5, 1, block.number + 30, block.number + 30);

        Player.set(player, true);
        Position.set(player, x, y);
        Movable.set(player, true);
    }

    function moveTo(uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(_msgSender());
        require(Movable.get(player), "cannot move");

        (uint32 fromX, uint32 fromY) = Position.get(player);
        require(distance(fromX, fromY, x, y) == 1, "can only move to adjacent spaces");

        bytes32 position = positionToEntityKey(x, y);
        require(!Obstruction.get(position), "this space is obstructed");

        require(Stats.getHealth(player) > 0, "Player has died");

        // Constrain position to map size, wrapping around if necessary
        (uint32 width, uint32 height,) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        // Check if its a resource we can collect
        if (IWorld(_world()).collectResource(position, player)) {
            removeTerrain(x, y);
        }

        // Also check hunger & thirst
        if (IWorld(_world()).timeTillThirsty(player) == 0) {
            uint256 thirstySince = IWorld(_world()).thirstySince(player);
            if (thirstySince == 0) {
                Thirsty.emitEphemeral(player, true);
            } else if (thirstySince % 3 == 0) {
                // Change the number to change how many steps till minus health
                uint32 currHealth = Stats.getHealth(player);
                if (currHealth > 0) {
                    Stats.setHealth(player, Stats.getHealth(player) - 1);
                }
            }
        }

        if (IWorld(_world()).timeTillHungry(player) == 0 && IWorld(_world()).hungrySince(player) == 0) {
            uint256 hungrySince = IWorld(_world()).hungrySince(player);
            if (hungrySince == 0) {
                Hungry.emitEphemeral(player, true);
            } else if (hungrySince % 5 == 0) {
                // Change the number to change how many steps till minus health
                uint32 currHealth = Stats.getHealth(player);
                if (currHealth > 0) {
                    Stats.setHealth(player, Stats.getHealth(player) - 1);
                }
            }
            Hungry.emitEphemeral(player, true);
        }

        if (Stats.getHealth(player) == 0) Died.emitEphemeral(player, true);
        Position.set(player, x, y);
    }

    function move(Direction direction) public {
        require(direction != Direction.Unknown, "Unknown direction");

        bytes32 player = addressToEntityKey(_msgSender());
        (uint32 x, uint32 y) = Position.get(player);

        if (direction == Direction.Up) {
            y -= 1;
        } else if (direction == Direction.Down) {
            y += 1;
        } else if (direction == Direction.Left) {
            x -= 1;
        } else if (direction == Direction.Right) {
            x += 1;
        }

        moveTo(x, y);
    }

    function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
        uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
        uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
        return deltaX + deltaY;
    }
}
