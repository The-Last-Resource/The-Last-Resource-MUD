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
    OwnedByTableId,
    PositionTableId,
    Monster,
    Stats
} from "../codegen/Tables.sol";
import {ResourceType, TerrainType, ItemType, MonsterType} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {getKeysInTable} from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import {IWorld} from "../codegen/world/IWorld.sol";
import {query, QueryFragment, QueryType} from "@latticexyz/world/src/modules/keysintable/query.sol";

contract AttackSystem is System {
    /**
     * The way attack works is:
     * 1. The player "moves" onto the enemy
     * 2. We then need to get the enemy at the coordinate
     * 3. Then minus the enemy health
     * 4. Still alive? Then attack back (minus player health)
     * 5. Dead? Drop resource
     */
    function attack(bytes32 player, uint32 x, uint32 y) public {
        // Get enemy at the coordinate
        bytes32 entity = positionToEntityKey(x, y);
        (, uint32 health, uint32 damage) = Monster.get(entity);
        require(health > 0, "Enemy is dead");

        // Minus enemy health
        Monster.setHealth(entity, health - IWorld(_world()).getDamage(player));

        // If still alive, attack back
        if (health - 1 > 0) {
            Stats.setHealth(player, Stats.getHealth(player) - damage);
        } else {
            // If dead, drop resource
            Resource.set(entity, ResourceType.Food);
            IWorld(_world()).setTerrain(x, y, TerrainType.Food);

            // Remove the monster
            Monster.deleteRecord(entity);
        }
    }
}
