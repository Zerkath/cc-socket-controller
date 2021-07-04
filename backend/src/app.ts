import { Server } from "ws";
import { Turtle } from "./turtle";
// import { TurtleController } from "./turtleController";
import { dig, move, tunnel } from "./turtleAttributes";

const port = 5000;

const wss = new Server({ port: port });

const turtles: Turtle[] = [];
// let tc: TurtleController;

wss.on("connection", (ws, request) => {
  const label = request.url?.slice(1);
  console.log(label + " connected");
  if (label !== "controller") {
    turtles.push(new Turtle(ws, String(label)));
    // if (tc !== undefined) tc.updateTurtles(turtles);
  } else {
    // tc = new TurtleController(ws, turtles);
  }
});
