import { createPhaserEngine } from "@latticexyz/phaserx";
import { useComponentValue } from "@latticexyz/react";
import { namespaceWorld, getComponentValueStrict } from "@latticexyz/recs";
import { NetworkLayer } from "../network/createNetworkLayer";
import { registerSystems } from "./systems";
import { TILE_HEIGHT, TILE_WIDTH } from "./constants";

export type PhaserLayer = Awaited<ReturnType<typeof createPhaserLayer>>;
type PhaserEngineConfig = Parameters<typeof createPhaserEngine>[0];

export const createPhaserLayer = async (
  networkLayer: NetworkLayer,
  phaserConfig: PhaserEngineConfig
) => {
  const world = namespaceWorld(networkLayer.world, "phaser");

  const {
    game,
    scenes,
    dispose: disposePhaser,
  } = await createPhaserEngine(phaserConfig);
  world.registerDisposer(disposePhaser);

  const mapConfig = getComponentValueStrict(
    networkLayer.components.MapConfig,
    networkLayer.singletonEntity
  );

  const { camera } = scenes.Main;

  const width = mapConfig.width;
  const height = mapConfig.height;

  console.log(0, 0, width * TILE_WIDTH, height * TILE_HEIGHT, "help");
  camera.phaserCamera.setBounds(0, 0, width * TILE_WIDTH, height * TILE_HEIGHT);
  camera.phaserCamera.centerOn(
    (width / 2) * TILE_WIDTH,
    (height / 2) * TILE_HEIGHT
  );

  const components = {};

  const layer = {
    networkLayer,
    world,
    game,
    scenes,
    components,
    mapConfig,
  };

  registerSystems(layer);

  return layer;
};
