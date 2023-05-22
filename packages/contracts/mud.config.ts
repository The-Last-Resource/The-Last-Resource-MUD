import { mudConfig, resolveTableId } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    ResourceType: ["None", "Wood", "Stone", "Water"],
    ItemType: ["Axe", "Pickaxe", "Bucket"],
    TerrainType: ["None", "Tree", "Rock", "Sea", "Wood", "Stone", "Water"],
    MonsterType: ["None", "Deer", "Gorilla"],
  },
  tables: {
    Monster: {
      schema: {
        monster: "MonsterType",
        health: "uint32",
        damage: "uint32",
      },
    },
    Encounter: {
      dataStruct: false,
      keySchema: {
        player: "bytes32",
      },
      schema: {
        monster: "bytes32",
      },
    },
    EncounterTrigger: "bool",
    Resource: "ResourceType",
    Item: "ItemType",
    MapConfig: {
      keySchema: {},
      dataStruct: false,
      schema: {
        width: "uint32",
        height: "uint32",
        terrain: "bytes",
      },
    },
    CollectionAttempt: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        resource: "bytes32",
      },
      schema: {
        result: "ResourceType",
      },
    },
    Obstruction: "bool",
    Mineable: "bool", // If a user can mine this
    OwnedBy: "bytes32",
    Player: "bool",
    Position: {
      dataStruct: false,
      schema: {
        x: "uint32",
        y: "uint32",
      },
    },
    Movable: "bool",
    Stats: {
      schema: {
        health: "uint32",
        damage: "uint32",
        thirst: "uint32",
        hunger: "uint32",
      },
    },
    Inventory: {
      schema: {
        wood: "uint32",
        stone: "uint32",
        water: "uint32",
      },
    },
  },
  modules: [
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("Item")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Item")],
    },
  ],
});
