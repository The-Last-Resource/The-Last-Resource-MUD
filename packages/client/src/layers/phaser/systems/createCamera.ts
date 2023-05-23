import { getComponentValue } from "@latticexyz/recs";
import { TILE_WIDTH, TILE_HEIGHT } from "../constants";
import { PhaserLayer } from "../createPhaserLayer";

export const createCamera = (layer: PhaserLayer) => {
  const {
    scenes: {
      Main: {
        camera: { phaserCamera },
      },
    },
    networkLayer: {
      components: { MapConfig },
      singletonEntity,
    },
  } = layer;

  const mapConfig = getComponentValue(MapConfig, singletonEntity);

  if (mapConfig) {
    const width = mapConfig.width;
    const height = mapConfig.height;

    phaserCamera.setBounds(0, 0, width * TILE_WIDTH, height * TILE_HEIGHT);
    phaserCamera.centerOn((width / 2) * TILE_WIDTH, (height / 2) * TILE_HEIGHT);
  }
};
