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
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import {IWorld} from "../codegen/world/IWorld.sol";
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
        if (uint256(Resource.get(position)) > 0) {
            if (Resource.get(position) == ResourceType.Wood) {
                Inventory.setWood(player, Inventory.getWood(player) + 1);
            }
            if (Resource.get(position) == ResourceType.Stone) {
                Inventory.setStone(player, Inventory.getStone(player) + 1);
            }
            if (Resource.get(position) == ResourceType.Water) {
                Inventory.setWater(player, Inventory.getWater(player) + 1);
            }

            CollectionAttempt.emitEphemeral(player, Resource.get(position));

            Resource.deleteRecord(position);
            removeTerrain(x, y);
        }
        Position.set(player, x, y);
    }

    function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
        uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
        uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
        return deltaX + deltaY;
    }

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
        setTerrain(x, y, TerrainType.Wood);
        if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Rock))) {
            resource = ResourceType.Stone;
            setTerrain(x, y, TerrainType.Stone);
        } else if (terrain[(y * width) + x] == bytes1(uint8(TerrainType.Sea))) {
            resource = ResourceType.Water;
            setTerrain(x, y, TerrainType.Water);
        }

        Resource.set(entity, resource);
    }

    /**
     * There are a few things to note here:
     * 1. We will include the crafting amount logic here
     * 2. We will
     */
    function craftAxe() public {
        bytes32 player = addressToEntityKey(_msgSender());

        // Lets assume crafting an axe will cost 2 wood
        uint32 wood = Inventory.getWood(player);
        require(wood >= 2, "Not enough wood to craft!");

        // Subtract amount first
        Inventory.setWood(player, wood - 2);

        // If they fulfill the requirements, we will create the item and make it owned by them
        bytes32 item = keccak256(abi.encode(player, blockhash(block.number - 1), block.difficulty));
        Item.set(item, ItemType.Axe);
        OwnedBy.set(item, player);
    }

    function craftPickaxe() public {
        bytes32 player = addressToEntityKey(_msgSender());

        uint32 wood = Inventory.getWood(player);
        require(wood >= 3, "Not enough wood to craft!");

        Inventory.setWood(player, wood - 3);

        // If they fulfill the requirements, we will create the item and make it owned by them
        bytes32 item = keccak256(abi.encode(player, blockhash(block.number - 1), block.difficulty));
        Item.set(item, ItemType.Pickaxe);
        OwnedBy.set(item, player);
    }

    function craftBucket() public {
        bytes32 player = addressToEntityKey(_msgSender());

        uint32 stone = Inventory.getStone(player);
        require(stone >= 3, "Not enough stone to craft!");

        Inventory.setStone(player, stone - 3);

        // If they fulfill the requirements, we will create the item and make it owned by them
        bytes32 item = keccak256(abi.encode(player, blockhash(block.number - 1), block.difficulty));
        Item.set(item, ItemType.Bucket);
        OwnedBy.set(item, player);
    }

    // function getItems() public view returns (bytes32[] memory) {
    //     bytes32[] memory ownedBy = getKeysWithValue(OwnedByTableId, OwnedBy.encode(addressToEntityKey(_msgSender())));

    //     for (uint i = 0; i < ownedBy.length; i++) {

    //     }
    //     return ownedBy;
    // }

    // function getItems() public view returns (bytes32[][] memory) {
    //     bytes32 player = addressToEntityKey(_msgSender());
    //     QueryFragment[] memory fragments = new QueryFragment[](2);

    //     fragments[1] = QueryFragment(QueryType.Has, ItemTableId, new bytes(0));
    //     fragments[0] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

    //     bytes32[][] memory keyTuples = query(fragments);
    //     return keyTuples;
    // }

    // function hasPickaxe() public view returns (bytes32[][] memory) {
    //     bytes32 player = addressToEntityKey(_msgSender());
    //     // bytes32[] memory items =
    //     QueryFragment[] memory fragments = new QueryFragment[](2);

    //     // Specify the more restrictive filter first for performance reasons
    //     fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

    //     // The value argument is ignored in Has query fragments
    //     fragments[0] = QueryFragment(QueryType.Has, ItemTableId, new bytes(0));

    //     bytes32[][] memory keyTuples = query(fragments);
    //     return keyTuples;
    // }

    function getItems() public view returns (bytes32[][] memory) {
        bytes32 player = addressToEntityKey(_msgSender());
        // bytes32[] memory items =
        QueryFragment[] memory fragments = new QueryFragment[](3);

        // Specify the more restrictive filter first for performance reasons
        // fragments[0] = QueryFragment(QueryType.Has, ItemTableId, new bytes(0));
        fragments[0] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        fragments[1] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Pickaxe));

        // // The value argument is ignored in Has query fragments

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples;
    }
}
