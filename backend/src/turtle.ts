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
  }
  public move(move: move): void {
    this.ws.send(move);
  }
  public dig(dig: dig): void {
    this.ws.send(dig);
  }
  public tunnel(tunnel: tunnel): void {
    this.ws.send(tunnel);
  }
  public setLabel(label: string): void {
    this.label = label;
  }

  public getFuelLevel(): void {
    this.ws.send("fuel");
    this.ws.on("message", (data: string) => {
      if (data.split(" ")[0] == "fuel") {
        this.fuelLevel = parseInt(data.split(" ")[1]);
        console.log(this.fuelLevel);
      }
    });
  }
}
