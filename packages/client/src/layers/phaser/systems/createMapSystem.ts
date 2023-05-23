import {
  Entity,
  Has,
  defineSystem,
  getComponentValueStrict,
} from "@latticexyz/recs";
import { Tileset } from "../../../artTypes/RPGNatureTileset";
import { TerrainType } from "../../../mud/types";
import { type PhaserLayer } from "../createPhaserLayer";
import { hexToArray } from "@latticexyz/utils";
import { TILE_WIDTH, TILE_HEIGHT } from "../constants";
import { convertToMatrix } from "../utils";

export async function createMapSystem(layer: PhaserLayer) {
  const {
    scenes: {
      Main: {
        maps: {
          Main: { putTileAt },
        },
        camera: { phaserCamera },
      },
    },
    networkLayer: {
      components: { MapConfig },
      singletonEntity,
    },
    world,
  } = layer;

  defineSystem(world, [Has(MapConfig)], ({ entity }) => {
    const mapConfig = getComponentValueStrict(MapConfig, singletonEntity);

    const { width, height, terrain } = mapConfig;

    phaserCamera.setBounds(0, 0, width * TILE_WIDTH, height * TILE_HEIGHT);
    phaserCamera.centerOn((width / 2) * TILE_WIDTH, (height / 2) * TILE_HEIGHT);

    const convertToMatrix = (
      arr: number[],
      rows: number,
      cols: number
    ): number[][] => {
      const matrix: number[][] = [];

      for (let i = 0; i < rows; i++) {
        const row: number[] = arr.slice(i * cols, (i + 1) * cols);
        matrix.push(row);
      }

      return matrix;
    };

    const map =
      terrain && width
        ? convertToMatrix(
            Array.from(hexToArray(terrain.toString())),
            height,
            width
          )
        : undefined;

    if (map) {
      for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
          const coord = { x, y };

          if (map[y][x] === 1) putTileAt(coord, Tileset.Forest, "Foreground");
          else if (map[y][x] === 2)
            putTileAt(coord, Tileset.Stone, "Foreground");
          else if (map[y][x] === 3)
            putTileAt(coord, Tileset.WaterMid, "Foreground");
          else if (map[y][x] === 5)
            putTileAt(coord, Tileset.Sign, "Foreground");
          else if (map[y][x] === 10)
            putTileAt(coord, Tileset.WaterUpLeft, "Foreground");
          else if (map[y][x] === 11)
            putTileAt(coord, Tileset.WaterUp, "Foreground");
          else if (map[y][x] === 12)
            putTileAt(coord, Tileset.WaterUpRight, "Foreground");
          else if (map[y][x] === 13)
            putTileAt(coord, Tileset.WaterMidLeft, "Foreground");
          else if (map[y][x] === 14)
            putTileAt(coord, Tileset.WaterMid, "Foreground");
          else if (map[y][x] === 15)
            putTileAt(coord, Tileset.WaterMidRight, "Foreground");
          else if (map[y][x] === 16)
            putTileAt(coord, Tileset.WaterDownLeft, "Foreground");
          else if (map[y][x] === 17)
            putTileAt(coord, Tileset.WaterDown, "Foreground");
          else if (map[y][x] === 18)
            putTileAt(coord, Tileset.WaterDownRight, "Foreground");
        }
      }
    }
  });
}
