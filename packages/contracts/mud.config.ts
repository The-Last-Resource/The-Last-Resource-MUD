import { mudConfig, resolveTableId } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    ResourceType: ["None", "Wood", "Stone", "Water", "Food"],
    ItemType: ["Axe", "Pickaxe", "Bucket"],
    TerrainType: ["None", "Tree", "Rock", "Sea", "Wood", "Stone", "Water", "Food"],
    MonsterType: ["None", "Deer", "Chicken"],
    Direction: ["Unknown", "Up", "Down", "Left", "Right"],
  },
  tables: {
    Collected: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        resource: "bytes32",
      },
      schema: {
        result: "ResourceType",
      },
    },
    Crafted: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        item: "bytes32",
      },
      schema: {
        result: "ItemType",
      },
    },
    Thirsty: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        player: "bytes32",
      },
      schema: {
        result: "bool",
      },
    },
    Hungry: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        player: "bytes32",
      },
      schema: {
        result: "bool",
      },
    },
    Died: {
      ephemeral: true,
      dataStruct: false,
      keySchema: {
        player: "bytes32",
      },
      schema: {
        result: "bool",
      },
    },
    Monster: {
      dataStruct: false,
      schema: {
        monster: "MonsterType",
        health: "uint32",
        damage: "uint32",
      },
    },
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
        thirst: "uint256",
        hunger: "uint256",
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
