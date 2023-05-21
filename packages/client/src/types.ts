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
    emoji: "🪨",
  },
  [TerrainType.Water]: {
    emoji: "🟦",
  },
};
