import WebSocket from "ws";
import { EventEmitter } from "events";
import { move, dig, tunnel, InventoryCell } from "./turtle_attributes";

export class Turtle extends EventEmitter {
  ws: WebSocket;
  fuelLevel = 0;
  label: string;
  position = {
    x: 0,
    y: 0,
    z: 0,
    heading: 2,
  };
  inventory: InventoryCell[] = [];

  constructor(ws: WebSocket, label: string) {
    super();
    this.ws = ws;
    this.label = label;
    this.turtleListener();
  }

  private turtleListener(): void {
    this.ws.on("message", (data: string) => {
      const items = data.split(" ");
      if (items[0] === "fuel") {
        this.fuelLevel = parseInt(items[1]);
        console.log(this.fuelLevel);
      } else if (items[0] === "items") {
        this.inventory = JSON.parse(items[1]);
        console.log(this.inventory);
      } else if (items[0] === "position") {
        const { x, y, z, heading } = JSON.parse(items[1]);
        this.position = { x, y, z, heading };
        console.log(this.position);
      }
    });
  }

  public do(action: move | dig | tunnel, actionCount?: number): void {
    if (actionCount === undefined) {
      actionCount = 1;
    }
    this.ws.send(action + actionCount);
  }

  public setLabel(label: string): void {
    this.label = label;
  }

  public getFuelLevel(): void {
    this.ws.send("fuel");
  }

  public getItems(): void {
    this.ws.send("items");
  }

  /**
   * This method excavates a 4x4 area then goes down by one
   */
  public excavate(): void {
    const data = [
      tunnel.forward + " 3",
      move.right,
      tunnel.forward + " 3",
      move.right,
      tunnel.forward,
      move.right,
      tunnel.forward + " 2",
      move.left,
      tunnel.forward,
      move.left,
      tunnel.forward + " 2",
      move.right,
      tunnel.forward,
      move.right,
      tunnel.forward + " 3",
      tunnel.down,
      move.right,
    ];
    this.ws.send("instructions " + JSON.stringify(data));
  }
}
