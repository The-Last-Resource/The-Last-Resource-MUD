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
        // We set that position to a specific resource type
        ResourceType resource = ResourceType.Wood;
        IWorld(_world()).setTerrain(x, y, TerrainType.Wood);
        if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Rock))) {
            resource = ResourceType.Stone;
            IWorld(_world()).setTerrain(x, y, TerrainType.Stone);
        } else if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Sea))) {
            resource = ResourceType.Water;
            IWorld(_world()).setTerrain(x, y, TerrainType.Water);
        }

        Resource.set(entity, resource);
    }

    /**
     * We can add additional logic where if they have a specific tool, their resource multiplies
     */
    function collectResource(bytes32 position, bytes32 player) public returns (bool) {
        if (uint256(Resource.get(position)) > 0) {
            uint32 multiplier = 0;
            if (Resource.get(position) == ResourceType.Wood) {
                if (IWorld(_world()).getAxe(player) > 0) {
                    multiplier = 1;
                }
                Inventory.setWood(player, Inventory.getWood(player) + 1 + multiplier);
            }
            if (Resource.get(position) == ResourceType.Stone) {
                if (IWorld(_world()).getPickaxe(player) > 0) {
                    multiplier = 1;
                }
                Inventory.setStone(player, Inventory.getStone(player) + 1 + multiplier);
            }
            // For food and water, we add time rather than save in inventory
            if (Resource.get(position) == ResourceType.Water) {
                if (IWorld(_world()).getBucket(player) > 0) {
                    multiplier = 2;
                }
                Stats.setThirst(player, Stats.getThirst(player) + 30 * multiplier);
            }
            if (Resource.get(position) == ResourceType.Food) {
                if (IWorld(_world()).getBucket(player) > 0) {
                    multiplier = 2;
                }
                Stats.setHunger(player, Stats.getHunger(player) + 30 * multiplier);
            }

            Collected.emitEphemeral(player, Resource.get(position));
            Resource.deleteRecord(position);
            return true;
        }
        return false;
    }

    function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
        uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
        uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
        return deltaX + deltaY;
    }
}
