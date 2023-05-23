import { Tileset } from "../../../artTypes/RPGNatureTileset";
import { type PhaserLayer } from "../createPhaserLayer";
import { createNoise2D } from "simplex-noise";

export function createMapSystem(layer: PhaserLayer) {
  const {
    scenes: {
      Main: {
        maps: {
          Main: { putTileAt },
        },
      },
    },
  } = layer;

  // const noise = createNoise2D();
  const map = [
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 2, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0],
    [0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0, 1, 0, 2, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 2, 2, 0, 0, 0, 0, 3, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 2, 1, 0, 1, 10, 13, 16, 0, 0],
    [0, 2, 0, 0, 0, 2, 0, 0, 1, 1, 0, 2, 0, 0, 1, 11, 14, 17, 0, 0],
    [0, 0, 2, 0, 0, 4, 1, 0, 1, 1, 0, 0, 2, 1, 1, 12, 15, 18, 0, 0],
    [0, 0, 2, 2, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 1, 4, 0, 0, 0, 0],
    [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 1, 2, 0, 0, 0, 1, 1, 0, 2, 0, 0, 0],
    [0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  for (let x = 0; x < map.length; x++) {
    for (let y = 0; y < map.length; y++) {
      const coord = { x, y };

      if (map[x][y] === 0) putTileAt(coord, Tileset.Grass, "Background");
      else if (map[x][y] === 1) putTileAt(coord, Tileset.Forest, "Foreground");
      else if (map[x][y] === 2) putTileAt(coord, Tileset.Stone, "Foreground");
      else if (map[x][y] === 3) putTileAt(coord, Tileset.Sign, "Foreground");
      else if (map[x][y] === 4) putTileAt(coord, Tileset.Mushrooms, "Foreground");
      else if (map[x][y] === 10) putTileAt(coord, Tileset.WaterUpLeft, "Foreground");
      else if (map[x][y] === 11) putTileAt(coord, Tileset.WaterUp, "Foreground");
      else if (map[x][y] === 12) putTileAt(coord, Tileset.WaterUpRight, "Foreground");
      else if (map[x][y] === 13) putTileAt(coord, Tileset.WaterMidLeft, "Foreground");
      else if (map[x][y] === 14) putTileAt(coord, Tileset.WaterMid, "Foreground");
      else if (map[x][y] === 15) putTileAt(coord, Tileset.WaterMidRight, "Foreground");
      else if (map[x][y] === 16) putTileAt(coord, Tileset.WaterDownLeft, "Foreground");
      else if (map[x][y] === 17) putTileAt(coord, Tileset.WaterDown, "Foreground");
      else if (map[x][y] === 18) putTileAt(coord, Tileset.WaterDownRight, "Foreground");
    }
  }
}
