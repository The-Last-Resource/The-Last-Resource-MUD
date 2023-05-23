import { createPhaserEngine } from "@latticexyz/phaserx";
import { namespaceWorld, getComponentValue } from "@latticexyz/recs";
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

  await new Promise((r) => setTimeout(r, 5000));

  const mapConfig = getComponentValue(
    networkLayer.components.MapConfig,
    networkLayer.singletonEntity
  );

  const { camera } = scenes.Main;

  if (mapConfig) {
    const width = mapConfig.width;
    const height = mapConfig.height;

    camera.phaserCamera.setBounds(
      0,
      0,
      width * TILE_WIDTH,
      height * TILE_HEIGHT
    );
    camera.phaserCamera.centerOn(
      (width / 2) * TILE_WIDTH,
      (height / 2) * TILE_HEIGHT
    );
  }

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
