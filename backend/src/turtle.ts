import WebSocket from "ws";
import { EventEmitter } from "events";
import { action, move, dig } from "./turtle_actions";

export class Turtle extends EventEmitter {
  ws: WebSocket;
  fuelLevel: number = 0;
  label: string = "unnamed";
  constructor(ws: WebSocket, label: string) {
    super();
    this.ws = ws;
    this.label = label;
  }
  public move(move: move) {
    this.ws.send(move);
  }
  public dig(dig: dig) {
    this.ws.send(dig);
  }
  public setLabel(label: string) {
    this.label = label;
  }

  public getFuel() {
    this.ws.send("fuel");
    this.ws.on("message", (data: string) => {
      if (data.split(" ")[0] == "fuel") {
        this.fuelLevel = parseInt(data.split(" ")[1]);
        console.log(this.fuelLevel);
      }
    });
  }
}
