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

contract InventorySystem is System {
    function getAxe() public view returns (uint256) {
        bytes32 player = addressToEntityKey(_msgSender());
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Axe));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }

    function getAxe(bytes32 player) public view returns (uint256) {
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Axe));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }

    function getPickaxe() public view returns (uint256) {
        bytes32 player = addressToEntityKey(_msgSender());
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Pickaxe));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }

    function getPickaxe(bytes32 player) public view returns (uint256) {
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Pickaxe));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }

    function getBucket() public view returns (uint256) {
        bytes32 player = addressToEntityKey(_msgSender());
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Bucket));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }

    function getBucket(bytes32 player) public view returns (uint256) {
        QueryFragment[] memory fragments = new QueryFragment[](2);

        fragments[0] = QueryFragment(QueryType.HasValue, ItemTableId, Item.encode(ItemType.Bucket));
        fragments[1] = QueryFragment(QueryType.HasValue, OwnedByTableId, OwnedBy.encode(player));

        bytes32[][] memory keyTuples = query(fragments);
        return keyTuples.length;
    }
}
