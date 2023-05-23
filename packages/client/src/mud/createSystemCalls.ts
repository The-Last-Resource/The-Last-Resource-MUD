import { Has, HasValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { uuid, awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { Direction } from "../layers/phaser/constants";
import { Tileset } from "../artTypes/RPGNatureTileset";
import { toast } from "react-toastify";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { playerEntity, singletonEntity, worldSend, txReduced$ }: SetupNetworkResult,
  { MapConfig, Obstruction, Player, Position, Mineable }: ClientComponents
) {
  const wrapPosition = (x: number, y: number) => {
    // const mapConfig = getComponentValue(MapConfig, singletonEntity);
    // if (!mapConfig) {
    //   throw new Error("mapConfig no yet loaded or initialized");
    // }
    // return [
    //   (x + mapConfig.width) % mapConfig.width,
    //   (y + mapConfig.height) % mapConfig.height,
    // ];

    return [x, y];
  };

  const isObstructed = (x: number, y: number) => {
    return runQuery([Has(Obstruction), HasValue(Position, { x, y })]).size > 0;
  };

  const isMineable = (x: number, y: number) => {
    return runQuery([Has(Mineable), HasValue(Position, { x, y })]).size > 0;
  };

  const move = async (direction: Direction) => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const playerPosition = getComponentValue(Position, playerEntity);
    if (!playerPosition) {
      console.warn("cannot moveBy without a player position, not yet spawned?");
      return;
    }

    let x = playerPosition.x;
    let y = playerPosition.y;

    if (direction == Direction.Up) {
      y -= 1;
    } else if (direction == Direction.Down) {
      y += 1;
    } else if (direction == Direction.Left) {
      x -= 1;
    } else if (direction == Direction.Right) {
      x += 1;
    }

    if (isObstructed(x, y)) {
      console.warn("cannot move to obstructed space");
      return;
    }

    const positionId = uuid();
    Position.addOverride(positionId, {
      entity: playerEntity,
      value: { x, y },
    });

    try {
      const tx = await worldSend("move", [direction]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    } finally {
      Position.removeOverride(positionId);
    }
  };

  const spawn = async (inputX: number, inputY: number) => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const canSpawn = getComponentValue(Player, playerEntity)?.value !== true;
    if (!canSpawn) {
      throw new Error("already spawned");
    }

    const [x, y] = wrapPosition(inputX, inputY);
    if (isObstructed(x, y)) {
      console.warn("cannot spawn on obstructed space");
      return;
    }

    const tx = await worldSend("spawn", [x, y]);
    await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
  };

  const mine = async (direction: Direction, putTileAt: any) => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const playerPosition = getComponentValue(Position, playerEntity);
    if (!playerPosition) {
      console.warn("cannot moveBy without a player position, not yet spawned?");
      return;
    }

    let x = playerPosition.x;
    let y = playerPosition.y;

    if (direction == Direction.Up) {
      y -= 1;
    } else if (direction == Direction.Down) {
      y += 1;
    } else if (direction == Direction.Left) {
      x -= 1;
    } else if (direction == Direction.Right) {
      x += 1;
    }

    if (!isMineable(x, y)) {
      console.warn("cannot mine non resource");
      return;
    }

    try {
      const tx = await worldSend("mine", [x, y]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
      putTileAt({ x, y }, Tileset.Grass, "Foreground");
    } finally {
      // Position.removeOverride(positionId);
    }
  };

  const craftAxe = async () => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const toastId = toast.info("Crafting...", {
      toastId: "craft",
    });
    try {
      const tx = await worldSend("craftAxe", []);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
      toast.update(toastId, {
        type: toast.TYPE.SUCCESS,
        render: "Axe crafted!",
      });
    } catch (err) {
      toast.update(toastId, {
        type: toast.TYPE.ERROR,
        render: "Not enough wood to craft axe!",
      });
    }
  };

  const craftPickaxe = async () => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const toastId = toast.info("Crafting...", {
      toastId: "craft",
    });
    try {
      const tx = await worldSend("craftPickaxe", []);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
      toast.update(toastId, {
        type: toast.TYPE.SUCCESS,
        render: "Pickaxe crafted!",
      });
    } catch (err) {
      toast.update(toastId, {
        type: toast.TYPE.ERROR,
        render: "Not enough wood to craft pickaxe!",
      });
    }
  };

  const craftBucket = async () => {
    if (!playerEntity) {
      throw new Error("no player");
    }

    const toastId = toast.info("Crafting...", {
      toastId: "craft",
    });
    try {
      const tx = await worldSend("craftBucket", []);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
      toast.update(toastId, {
        type: toast.TYPE.SUCCESS,
        render: "Bucket crafted!",
      });
    } catch (err) {
      toast.update(toastId, {
        type: toast.TYPE.ERROR,
        render: "Not enough wood to craft bucket!",
      });
    }
  };

  return {
    move,
    spawn,
    mine,
    craftAxe,
    craftPickaxe,
    craftBucket,
  };
}
