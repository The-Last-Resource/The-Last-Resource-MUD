export enum ResourceType {
  Wood,
  Stone,
  Water,
}

export enum ItemType {
  Axe,
  Pickaxe,
  Bucket,
}

export enum TerrainType {
  Tree = 1,
  Rock,
  Sea,
  Wood,
  Stone,
  Water,
}

type TerrainConfig = {
  emoji: string;
};

export const terrainTypes: Record<TerrainType, TerrainConfig> = {
  [TerrainType.Tree]: {
    emoji: "🌳",
  },
  [TerrainType.Rock]: {
    emoji: "🗿",
  },
  [TerrainType.Sea]: {
    emoji: "🟦",
  },
  [TerrainType.Wood]: {
    emoji: "🪵",
  },
  [TerrainType.Stone]: {
    emoji: "🪨",
  },
  [TerrainType.Water]: {
    emoji: "🌊",
  },
};
