// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {System} from "@latticexyz/world/src/System.sol";
import {console} from "forge-std/console.sol";
import {MapConfig, Movable, Obstruction, Player, Position, Resource, Collectible} from "../codegen/Tables.sol";
import {ResourceType, TerrainType} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";

contract MapSystem is System {
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
        require(Collectible.get(position), "not a collectible");

        // Constrain position to map size, wrapping around if necessary
        (uint32 width, uint32 height, bytes memory terrain) = MapConfig.get();
        x = (x + width) % width;
        y = (y + height) % height;

        // Mine the resource in that position
        bytes32 entity = positionToEntityKey(x, y);
        Obstruction.deleteRecord(entity);

        terrain[(y * width) + x] = bytes1(uint8(TerrainType.None));
        MapConfig.set(width, height, terrain);
    }
}
