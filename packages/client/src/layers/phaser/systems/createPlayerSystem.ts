import {
  Has,
  defineEnterSystem,
  defineSystem,
  getComponentValueStrict,
} from "@latticexyz/recs";
import type { PhaserLayer } from "../createPhaserLayer";
import { Animations, TILE_HEIGHT, TILE_WIDTH, Direction } from "../constants";
import {
  pixelCoordToTileCoord,
  tileCoordToPixelCoord,
} from "@latticexyz/phaserx";

export function createPlayerSystem(layer: PhaserLayer) {
  const {
    networkLayer: {
      systemCalls: { spawn, move, mine, craftAxe, craftBucket, craftPickaxe },
      components: { Position, Player },
    },
    world,
    scenes: {
      Main: {
        objectPool,
        input,
        maps: {
          Main: { putTileAt },
        },
      },
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

  input.onKeyPress(
    (keys) => keys.has("W"),
    () => {
      move(Direction.Up);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("S"),
    () => {
      move(Direction.Down);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("A"),
    () => {
      move(Direction.Left);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("D"),
    () => {
      move(Direction.Right);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("UP"),
    () => {
      mine(Direction.Up, putTileAt);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("DOWN"),
    () => {
      mine(Direction.Down, putTileAt);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("LEFT"),
    () => {
      mine(Direction.Left, putTileAt);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("RIGHT"),
    () => {
      mine(Direction.Right, putTileAt);
    }
  );

  input.onKeyPress(
    (keys) => keys.has("ONE"),
    () => {
      craftAxe();
    }
  );

  input.onKeyPress(
    (keys) => keys.has("TWO"),
    () => {
      craftPickaxe();
    }
  );

  input.onKeyPress(
    (keys) => keys.has("THREE"),
    () => {
      craftBucket();
    }
  );

  defineEnterSystem(world, [Has(Position), Has(Player)], ({ entity }) => {
    const playerObj = objectPool.get(entity, "Sprite");
    playerObj.setComponent({
      id: "playerAnimation",
      once: (sprite) => {
        sprite.play(Animations.MainCharacterIdle);
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
