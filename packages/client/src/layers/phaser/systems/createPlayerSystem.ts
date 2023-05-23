import {
  Has,
  defineEnterSystem,
  defineSystem,
  getComponentValueStrict,
} from "@latticexyz/recs";
import type { PhaserLayer } from "../createPhaserLayer";
import { Animations, TILE_HEIGHT, TILE_WIDTH } from "../constants";
import {
  pixelCoordToTileCoord,
  tileCoordToPixelCoord,
} from "@latticexyz/phaserx";

export function createPlayerSystem(layer: PhaserLayer) {
  const {
    networkLayer: {
      systemCalls: { spawn, moveBy },
      components: { Position, Player },
    },
    world,
    scenes: {
      Main: { objectPool, input },
    },
  } = layer;

  input.click$.subscribe((event) => {
    const x = event.worldX;
    const y = event.worldY;
    console.log(x, y);

    const position = pixelCoordToTileCoord({ x, y }, TILE_WIDTH, TILE_HEIGHT);
    if (position.x === 0 || position.y === 0) {
      return;
    }
    spawn(position.x, position.y);
  });

  defineEnterSystem(world, [Has(Position), Has(Player)], ({ entity }) => {
    const playerObj = objectPool.get(entity, "Sprite");
    playerObj.setComponent({
      id: "playerAnimation",
      once: (sprite) => {
        sprite.play(Animations.MainCharacterDeath);
      },
    });
  });

  defineSystem(world, [Has(Position), Has(Player)], ({ entity }) => {
    const position = getComponentValueStrict(Position, entity);
    const pixelPosition = tileCoordToPixelCoord(
      position,
      TILE_WIDTH,
      TILE_HEIGHT
    );

    const playerObj = objectPool.get(entity, "Sprite");

    playerObj.setComponent({
      id: "position",
      once: (sprite) => {
        sprite.setPosition(pixelPosition.x, pixelPosition.y);
      },
    });
  });
}
