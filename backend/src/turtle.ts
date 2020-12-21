import WebSocket from "ws";
import { EventEmitter } from "events";
import { move, dig, tunnel } from "./turtle_actions";

export class Turtle extends EventEmitter {
  ws: WebSocket;
  fuelLevel = 0;
  label: string;
  x = 0;
  y = 0;
  z = 0;
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
        console.log(items[1]);
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
}
