// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { PositionData, Position, PositionTableId } from "../codegen/Tables.sol";
import { addressToEntityKey } from "../addressToEntityKey.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Direction } from "../codegen/Types.sol";

contract PlayerSystem is System {
  function spawn(int32 x, int32 y) public {
    require(x != 0 || y != 0, "cannot spawn at 0 coord");
    bytes32 player = addressToEntityKey(_msgSender());
    PositionData memory existingPosition = Position.get(player);

    require(existingPosition.x == 0 && existingPosition.y == 0, "Coord set");

    bytes32[] memory playerAtPosition = getKeysWithValue(PositionTableId, Position.encode(x, y));
    require(playerAtPosition.length == 0, "Spawn location has player");

	  Position.set(player, x, y);
  }

  function move(Direction direction) public {
    require(direction != Direction.Unknown, "Unknown direction");

    bytes32 player = addressToEntityKey(_msgSender());
    PositionData memory existingPosition = Position.get(player);

    require(existingPosition.x != 0 && existingPosition.y != 0, "Not spawn");

    int32 x = existingPosition.x;
    int32 y = existingPosition.y;

    if (direction == Direction.Up) {
      y -= 1;
    } else if (direction == Direction.Down) {
        y += 1;
    } else if (direction == Direction.Left) {
        x -= 1;
    } else if (direction == Direction.Right) {
        x += 1;
    }

    bytes32[] memory playerAtPosition = getKeysWithValue(PositionTableId, Position.encode(x, y));
    require(playerAtPosition.length == 0, "Spawn location has player");
    Position.set(player, x, y);
  }
}
