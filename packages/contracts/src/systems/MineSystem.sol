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
    Collected,
    Inventory,
    Item,
    ItemTableId,
    OwnedBy,
    OwnedByTableId,
    Stats
} from "../codegen/Tables.sol";
import {ResourceType, TerrainType, ItemType} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {IWorld} from "../codegen/world/IWorld.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import {query, QueryFragment, QueryType} from "@latticexyz/world/src/modules/keysintable/query.sol";

contract MineSystem is System {
    function mine(uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(_msgSender());
        require(Movable.get(player), "cannot move");

        (uint32 fromX, uint32 fromY) = Position.get(player);
        require(distance(fromX, fromY, x, y) == 1, "can only mine adjacent spaces");

        bytes32 position = positionToEntityKey(x, y);
        require(Mineable.get(position), "not a mineable obstruction");

        // Constrain position to map size, wrapping around if necessary
        (uint32 width, uint32 height, bytes memory terrain) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        // Mine the resource in that position
        bytes32 entity = positionToEntityKey(x, y);

        // Remove the obstruction and ability to mine that resource
        Obstruction.deleteRecord(entity);
        Mineable.deleteRecord(entity);

        // When you mine an obstruction, it turns into a resource
        // We instantly add it to your inventory
        if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Tree))) {
            collectResource(ResourceType.Wood, player);
        } else if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Rock))) {
            collectResource(ResourceType.Stone, player);
        } else if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Sea))) {
            collectResource(ResourceType.Water, player);
        }

        IWorld(_world()).removeTerrain(x, y);
    }

    function collectResource(ResourceType resource, bytes32 player) public returns (bool) {
        uint32 multiplier = 0;
        if (resource == ResourceType.Wood) {
            if (IWorld(_world()).getAxe(player) > 0) {
                multiplier = 1;
            }
            Inventory.setWood(player, Inventory.getWood(player) + 1 + multiplier);
        }
        if (resource == ResourceType.Stone) {
            if (IWorld(_world()).getPickaxe(player) > 0) {
                multiplier = 1;
            }
            Inventory.setStone(player, Inventory.getStone(player) + 1 + multiplier);
        }
        // For food and water, we add time rather than save in inventory
        if (resource == ResourceType.Water) {
            if (IWorld(_world()).getBucket(player) > 0) {
                multiplier = 2;
            }
            Stats.setThirst(player, Stats.getThirst(player) + 30 * multiplier);
        }
        if (resource == ResourceType.Food) {
            if (IWorld(_world()).getBucket(player) > 0) {
                multiplier = 2;
            }
            Stats.setHunger(player, Stats.getHunger(player) + 30 * multiplier);
        }

        Collected.emitEphemeral(player, resource);
        return true;
    }

    function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
        uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
        uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
        return deltaX + deltaY;
    }
}
