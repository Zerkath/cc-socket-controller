import WebSocket from "ws";
import { EventEmitter } from "events";
import { Turtle } from "./turtle";

export class TurtleController extends EventEmitter {
  ws: WebSocket;
  turtles: Turtle[] = [];

  constructor(ws: WebSocket, turtles: Turtle[]) {
    super();
    this.ws = ws;
    this.turtles = turtles;
    this.controllerListener();
  }

  public updateTurtles(turtles: Turtle[]): void {
    if (turtles !== null) {
      this.turtles = turtles;
    }
  }

  private controllerListener(): void {
    this.ws.on("message", (data: string) => {
      if (data === "excavate") {
        this.turtles.forEach((turtle) => {
          turtle.excavate();
        });
      }
    });
  }
}
