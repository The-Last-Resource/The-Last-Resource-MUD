import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    ResourceType: ["None", "Wood", "Stone", "Water"],
    ItemType: ["Axe", "Pickaxe", "Bucket"],
    TerrainType: ["None", "Tree", "Rock", "Sea", "Wood", "Stone", "Water"],
  },
  tables: {
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
    Inventory: {
      schema: {
        wood: "uint32",
        stone: "uint32",
        water: "uint32",
      },
    },
  },
});
