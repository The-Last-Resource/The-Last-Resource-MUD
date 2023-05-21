// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {MapConfig, Obstruction, Position, Collectible} from "../src/codegen/Tables.sol";
import {TerrainType} from "../src/codegen/Types.sol";
import {positionToEntityKey} from "../src/positionToEntityKey.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        console.log("Deployed world: ", worldAddress);
        IWorld world = IWorld(worldAddress);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TerrainType O = TerrainType.None;
        TerrainType T = TerrainType.Tree;
        TerrainType B = TerrainType.Rock;
        TerrainType W = TerrainType.Water;

        TerrainType[20][20] memory map = [
            [O, O, O, O, O, O, T, O, O, O, O, O, O, O, O, O, O, O, O, O],
            [O, O, T, O, O, O, O, O, T, O, O, O, O, B, O, O, O, O, O, O],
            [O, T, T, T, T, O, O, O, O, O, O, O, O, O, O, T, T, O, O, O],
            [O, O, T, T, T, T, O, O, O, O, B, O, O, O, O, O, T, O, O, O],
            [O, O, O, O, T, T, O, O, O, O, O, O, O, O, O, O, O, T, O, O],
            [O, O, O, B, B, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O],
            [O, T, O, O, O, B, B, O, O, O, O, T, O, O, O, O, O, B, O, O],
            [O, O, T, T, O, O, O, O, O, T, O, B, O, O, T, O, B, O, O, O],
            [O, O, T, O, O, O, O, T, T, T, O, B, B, O, W, W, W, O, O, O],
            [O, O, O, O, O, O, O, T, T, T, O, B, T, O, W, W, W, O, O, O],
            [O, B, O, O, O, B, O, O, T, T, O, B, O, O, W, W, O, O, O, O],
            [O, O, W, W, O, O, T, O, T, T, O, O, B, T, T, T, O, O, O, O],
            [O, O, W, W, W, O, O, O, T, O, O, O, B, O, T, O, O, O, O, O],
            [O, O, O, W, W, O, O, O, O, O, O, O, O, B, O, T, O, O, O, O],
            [O, O, O, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O],
            [O, O, O, O, O, O, O, O, O, O, B, B, O, O, T, O, O, O, O, O],
            [O, O, O, O, T, O, O, O, T, B, O, O, O, T, T, O, B, O, O, O],
            [O, O, O, T, O, T, T, T, O, O, O, O, O, T, O, O, O, O, O, O],
            [O, O, O, T, T, T, T, O, O, O, O, T, O, O, O, T, O, O, O, O],
            [O, O, O, O, O, T, O, O, O, O, O, O, O, O, O, O, O, O, O, O]
        ];

        uint32 height = uint32(map.length);
        uint32 width = uint32(map[0].length);
        bytes memory terrain = new bytes(width * height);

        for (uint32 y = 0; y < height; y++) {
            for (uint32 x = 0; x < width; x++) {
                TerrainType terrainType = map[y][x];
                if (terrainType == TerrainType.None) continue;

                terrain[(y * width) + x] = bytes1(uint8(terrainType));

                bytes32 entity = positionToEntityKey(x, y);
                Position.set(world, entity, x, y);
                Obstruction.set(world, entity, true);
                Collectible.set(world, entity, true);
            }
        }

        MapConfig.set(world, width, height, terrain);

        vm.stopBroadcast();
    }
}
