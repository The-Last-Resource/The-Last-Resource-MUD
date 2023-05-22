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
    Crafted,
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
import {query, QueryFragment, QueryType} from "@latticexyz/world/src/modules/keysintable/query.sol";

contract CraftSystem is System {
    /**
     * There are a few things to note here:
     * 1. We will include the crafting amount logic here
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

        Crafted.emitEphemeral(player, ItemType.Axe);
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

        Crafted.emitEphemeral(player, ItemType.Pickaxe);
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

        Crafted.emitEphemeral(player, ItemType.Bucket);
    }
}
