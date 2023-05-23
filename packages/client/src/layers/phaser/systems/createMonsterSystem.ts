import { hexToArray } from "@latticexyz/utils";
import { Tileset } from "../../../artTypes/RPGNatureTileset";
import { type PhaserLayer } from "../createPhaserLayer";
import { convertToMatrix } from "../utils";
import {
  Has,
  HasValue,
  World,
  defineEnterSystem,
  defineSystem,
  getComponentValueStrict,
} from "@latticexyz/recs";
import { tileCoordToPixelCoord } from "@latticexyz/phaserx";
import { Animations, TILE_HEIGHT, TILE_WIDTH } from "../constants";
import { MonsterType } from "../../../mud/types";

export function createMonsterSystem(layer: PhaserLayer) {
  const {
    scenes: {
      Main: { objectPool },
    },
    networkLayer: {
      components: { Position, Monster, MapConfig },
    },
    world,
  } = layer;

  // --- Initialise chickens ---
  defineEnterSystem(
    world,
    [HasValue(Monster, { monster: MonsterType.Chicken })],
    ({ entity }) => {
      const chickenObject = objectPool.get(entity, "Sprite");
      chickenObject.setComponent({
        id: "chickenAnimation",
        once: (sprite) => {
          sprite.play(Animations.ChickenIdle);
        },
      });
    }
  );

  defineSystem(
    world,
    [HasValue(Monster, { monster: MonsterType.Chicken })],
    ({ entity }) => {
      const position = getComponentValueStrict(Position, entity);
      const pixelPosition = tileCoordToPixelCoord(
        position,
        TILE_WIDTH,
        TILE_HEIGHT
      );

      const playerObj = objectPool.get(entity, "Sprite");

      playerObj.setComponent({
        id: "chickenPosition",
        once: (sprite) => {
          sprite.setPosition(pixelPosition.x, pixelPosition.y);
        },
      });
    }
  );

  // const map =
  //   terrain && width
  //     ? convertToMatrix(
  //         Array.from(hexToArray(terrain.toString())),
  //         height,
  //         width
  //       )
  //     : undefined;

  // if (map) {
  //   for (let y = 0; y < height; y++) {
  //     for (let x = 0; x < width; x++) {
  //       const coord = { x, y };
  //       // if (map[y][x] === 4) {
  //       // }
  //     }
  //   }
  // }
}
