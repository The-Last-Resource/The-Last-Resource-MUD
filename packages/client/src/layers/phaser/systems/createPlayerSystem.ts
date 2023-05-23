import {
  defineEnterSystem,
  Has,
  defineSystem,
  getComponentValueStrict,
} from "@latticexyz/recs";
import { Animations, TILE_HEIGHT, TILE_WIDTH } from "../constants";
import { PhaserLayer } from "../createPhaserLayer";
import {
  pixelCoordToTileCoord,
  tileCoordToPixelCoord,
} from "@latticexyz/phaserx";

export const createPlayerSystem = (layer: PhaserLayer) => {
  const {
    world,
    networkLayer: {
      components: { Position },
      systemCalls: { spawn },
    },
    scenes: {
      Main: { objectPool, input },
    },
  } = layer;

  input.pointerdown$.subscribe((event) => {
    const x = event.pointer.worldX;
    const y = event.pointer.worldY;

    const position = pixelCoordToTileCoord({ x, y }, TILE_WIDTH, TILE_HEIGHT);

    spawn(position.x, position.y);
  });

  defineEnterSystem(world, [Has(Position)], ({ entity }) => {
    const playerObj = objectPool.get(entity, "Sprite");

    playerObj.setComponent({
      id: "animation",
      once: (sprite) => {
        sprite.play(Animations.Golem);
      },
    });
  });

  // defineSystem(world, [Has(Position)], ({ entity }) => {
  //   const position = getComponentValueStrict(Position, entity);
  //   const pixelPosition = tileCoordToPixelCoord(
  //     position,
  //     TILE_WIDTH,
  //     TILE_HEIGHT
  //   );

  //   const playerObj = objectPool.get(entity, "Sprite");

  //   playerObj.setComponent({
  //     id: "position",
  //     once: (sprite) => {
  //       sprite.setPosition(pixelPosition.x, pixelPosition.y);
  //     },
  //   });
  // });
};
