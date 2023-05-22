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
    OwnedByTableId,
    Stats
} from "../codegen/Tables.sol";
import {ResourceType, TerrainType, ItemType} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import {query, QueryFragment, QueryType} from "@latticexyz/world/src/modules/keysintable/query.sol";

contract StatsSystem is System {
    function getHungerTimestamp() public view returns (uint256) {
        bytes32 player = addressToEntityKey(_msgSender());

        return Stats.getHunger(player);
    }

    function getThirstTimestamp() public view returns (uint256) {
        bytes32 player = addressToEntityKey(_msgSender());

        return Stats.getThirst(player);
    }

    function getHungerTimestamp(bytes32 player) public view returns (uint256) {
        return Stats.getHunger(player);
    }

    function getThirstTimestamp(bytes32 player) public view returns (uint256) {
        return Stats.getThirst(player);
    }

    function timeTillHungry() public view returns (uint256) {
        uint256 hungerTime = getHungerTimestamp();
        if (hungerTime > block.number) {
            return hungerTime - block.number;
        }
        return 0;
    }

    function timeTillThirsty() public view returns (uint256) {
        uint256 thirstTime = getThirstTimestamp();
        if (thirstTime > block.number) {
            return thirstTime - block.number;
        }
        return 0;
    }

    function hungrySince(bytes32 player) public view returns (uint256) {
        uint256 hungerSince = getHungerTimestamp(player);

        if (block.number > hungerSince) {
            return block.number - hungerSince;
        }
        return 0;
    }

    function thirstySince(bytes32 player) public view returns (uint256) {
        uint256 thirstSince = getThirstTimestamp(player);

        if (block.number > thirstSince) {
            return block.number - thirstSince;
        }
        return 0;
    }

    function getDamage() public view returns (uint32) {
        bytes32 player = addressToEntityKey(_msgSender());

        return Stats.getDamage(player);
    }

    function getHealth() public view returns (uint32) {
        bytes32 player = addressToEntityKey(_msgSender());

        return Stats.getHealth(player);
    }
}
