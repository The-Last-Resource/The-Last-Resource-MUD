import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { GameMap } from "./GameMap";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { hexToArray } from "@latticexyz/utils";
import { ItemType, TerrainType, terrainTypes } from "./types";
import { Has, HasValue, getComponentValueStrict } from "@latticexyz/recs";
import { ethers } from "ethers";
import { defaultAbiCoder } from "ethers/lib/utils";

export const GameBoard = () => {
  useKeyboardMovement();

  const {
    components: { Player, Position, MapConfig, Item, OwnedBy },
    network: { playerEntity, singletonEntity },
    systemCalls: { spawn },
  } = useMUD();

  const val = useEntityQuery([Has(Item), Has(OwnedBy)])
    .filter((entity) => {
      const ownerData = getComponentValueStrict(OwnedBy, entity);
      const address = defaultAbiCoder.decode(["address"], ownerData.value)[0];

      return (
        ethers.utils.getAddress(address) ===
        ethers.utils.getAddress(playerEntity as any)
      );
    })
    .map((itemKey) => {
      const itemData = getComponentValueStrict(Item, itemKey).value;

      return Object.values(ItemType)[itemData];
    });

  console.log(val);

  const canSpawn = useComponentValue(Player, playerEntity)?.value !== true;

  const players = useEntityQuery([Has(Player), Has(Position)]).map((entity) => {
    const position = getComponentValueStrict(Position, entity);
    return {
      entity,
      x: position.x,
      y: position.y,
      emoji: entity === playerEntity ? "🤠" : "🥸",
    };
  });

  const mapConfig = useComponentValue(MapConfig, singletonEntity);
  if (mapConfig == null) {
    throw new Error(
      "map config not set or not ready, only use this hook after loading state === LIVE"
    );
  }

  const { width, height, terrain: terrainData } = mapConfig;
  const terrain =
    terrainData && width
      ? Array.from(hexToArray(terrainData.toString())).map((value, index) => {
          const { emoji } =
            value in TerrainType
              ? terrainTypes[value as TerrainType]
              : { emoji: "" };
          return {
            x: index % Number(width),
            y: Math.floor(index / Number(width)),
            emoji,
          };
        })
      : undefined;

  // const encounter = useComponentValue(Encounter, playerEntity);
  // const monsterType = useComponentValue(
  //   Monster,
  //   encounter ? (encounter.monster as Entity) : undefined
  // )?.value;
  // const monster =
  //   monsterType != null && monsterType.toString() in MonsterType
  //     ? monsterTypes[monsterType as MonsterType]
  //     : null;

  return (
    <GameMap
      width={20}
      height={20}
      terrain={terrain}
      onTileClick={canSpawn ? spawn : undefined}
      players={players}
    />
  );
};
