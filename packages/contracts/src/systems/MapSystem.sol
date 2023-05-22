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
    CollectionAttempt,
    Inventory,
    Item,
    ItemTableId,
    OwnedBy,
    OwnedByTableId
} from "../codegen/Tables.sol";
import {ResourceType, TerrainType, ItemType} from "../codegen/Types.sol";
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
        Player.set(player, true);
        Position.set(player, x, y);
        Movable.set(player, true);
    }

    function move(uint32 x, uint32 y) public {
        bytes32 player = addressToEntityKey(_msgSender());
        require(Movable.get(player), "cannot move");

        (uint32 fromX, uint32 fromY) = Position.get(player);
        require(distance(fromX, fromY, x, y) == 1, "can only move to adjacent spaces");

        bytes32 position = positionToEntityKey(x, y);
        require(!Obstruction.get(position), "this space is obstructed");

        // Constrain position to map size, wrapping around if necessary
        (uint32 width, uint32 height,) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        // Check if its a resource we can collect
        if (IWorld(_world()).collectResource(position, player)) {
            removeTerrain(x, y);
        }

        Position.set(player, x, y);
    }

    function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
        uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
        uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
        return deltaX + deltaY;
    }
}
