import { useEffect } from "react";
import { useMUD } from "./MUDContext";

export const useKeyboardMovement = () => {
  const {
    systemCalls: {
      moveBy,
      mine,
      craftAxe,
      craftPickaxe,
      craftBucket,
      getItems,
    },
  } = useMUD();

  useEffect(() => {
    const listener = (e: KeyboardEvent) => {
      if (e.key === "w") {
        moveBy(0, -1);
      }
      if (e.key === "s") {
        moveBy(0, 1);
      }
      if (e.key === "a") {
        moveBy(-1, 0);
      }
      if (e.key === "d") {
        moveBy(1, 0);
      }
      if (e.key === "ArrowUp") {
        mine(0, -1);
      }
      if (e.key === "ArrowDown") {
        mine(0, 1);
      }
      if (e.key === "ArrowLeft") {
        mine(-1, 0);
      }
      if (e.key === "ArrowRight") {
        mine(1, 0);
      }
      if (e.key === "1") {
        craftAxe();
      }
      if (e.key === "2") {
        craftPickaxe();
      }
      if (e.key === "3") {
        craftBucket();
      }
      if (e.key === "4") {
        console.log(getItems());
      }
    };

    window.addEventListener("keydown", listener);
    return () => window.removeEventListener("keydown", listener);
  }, [moveBy]);
};
