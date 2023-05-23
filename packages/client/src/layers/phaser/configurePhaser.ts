import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
  Asset,
} from "@latticexyz/phaserx";
import worldTileset from "../../../public/assets/tilesets/world.png";
import { TileAnimations, Tileset } from "../../artTypes/world";
import {
  Sprites,
  Assets,
  Maps,
  Scenes,
  TILE_HEIGHT,
  TILE_WIDTH,
  Animations,
} from "./constants";
import { PhaserEngineConfig } from "@latticexyz/phaserx/src/types";
import { SceneConfig } from "@latticexyz/phaserx/src/types";
import { Sprite } from "@latticexyz/phaserx/src/types";
import { Animation } from "@latticexyz/phaserx/src/types";

const ANIMATION_INTERVAL = 200;

const mainMap = defineMapConfig({
  chunkSize: TILE_WIDTH * 64, // tile size * tile amount
  tileWidth: TILE_WIDTH,
  tileHeight: TILE_HEIGHT,
  backgroundTile: [Tileset.Grass],
  animationInterval: ANIMATION_INTERVAL,
  tileAnimations: TileAnimations,
  layers: {
    layers: {
      Background: { tilesets: ["Default"] },
      Foreground: { tilesets: ["Default"] },
    },
    defaultLayer: "Background",
  },
});

export const phaserConfig = {
  sceneConfig: {
    [Scenes.Main]: defineSceneConfig({
      assets: {
        [Assets.Tileset]: {
          type: AssetType.Image,
          key: Assets.Tileset,
          path: worldTileset,
        },
        [Assets.MainAtlas]: {
          type: AssetType.MultiAtlas,
          key: Assets.MainAtlas,
          // Add a timestamp to the end of the path to prevent caching
          path: `/assets/atlases/atlas.json?timestamp=${Date.now()}`,
          options: {
            imagePath: "/assets/atlases/",
          },
        },
      },
      maps: {
        [Maps.Main]: mainMap,
      },
      sprites: {
        [Sprites.MainCharacter]: {
          assetKey: Assets.MainAtlas,
          frame: "sprites/main-character/base.png",
        },
        [Sprites.Soldier]: {
          assetKey: Assets.MainAtlas,
          frame: "sprites/soldier/idle/0.png",
        },
      },
      animations: [
        {
          key: Animations.MainCharacterIdle,
          assetKey: Assets.MainAtlas,
          startFrame: 0,
          endFrame: 3,
          frameRate: 6,
          repeat: -1,
          prefix: "sprites/main-character/idle/",
          suffix: ".png",
        },
        {
          key: Animations.MainCharacterWalk,
          assetKey: Assets.MainAtlas,
          startFrame: 0,
          endFrame: 7,
          frameRate: 6,
          repeat: -1,
          prefix: "sprites/main-character/walk/",
          suffix: ".png",
        },
        {
          key: Animations.MainCharacterAttack,
          assetKey: Assets.MainAtlas,
          startFrame: 0,
          endFrame: 7,
          frameRate: 6,
          repeat: -1,
          prefix: "sprites/main-character/attack/",
          suffix: ".png",
        },
        {
          key: Animations.MainCharacterDeath,
          assetKey: Assets.MainAtlas,
          startFrame: 0,
          endFrame: 7,
          frameRate: 6,
          repeat: -1,
          prefix: "sprites/main-character/death/",
          suffix: ".png",
        },
        {
          key: Animations.SwordsmanIdle,
          assetKey: Assets.MainAtlas,
          startFrame: 0,
          endFrame: 3,
          frameRate: 6,
          repeat: -1,
          prefix: "sprites/soldier/idle/",
          suffix: ".png",
        },
      ],
      tilesets: {
        Default: {
          assetKey: Assets.Tileset,
          tileWidth: TILE_WIDTH,
          tileHeight: TILE_HEIGHT,
        },
      },
    }),
  },
  scale: defineScaleConfig({
    parent: "phaser-game",
    zoom: 1,
    mode: Phaser.Scale.NONE,
  }),
  cameraConfig: defineCameraConfig({
    pinchSpeed: 1,
    wheelSpeed: 1,
    maxZoom: 3,
    minZoom: 1,
  }),
  cullingChunkSize: TILE_HEIGHT * 16,
  physics: {
    default: "arcade",
  },
};
