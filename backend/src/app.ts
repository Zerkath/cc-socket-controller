import { Server } from "ws";
import { Turtle } from "./turtle";
import { dig, move, tunnel } from "./turtle_actions";
import readline from "readline";
import Queue from "p-queue";

const port = 5000;

const wss = new Server({ port: port });

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

wss.on("connection", (ws, request) => {
  const label = request.url?.slice(1);
  console.log(label + " connected");
  const turtle = new Turtle(ws, String(label));
  ws.on("message", (message: string) => {
    if (message === "waiting") {
      rl.question(
        turtle.label + " is waiting for action (dig, tunnel, move): ",
        (action) => {
          console.log("action: " + action);
          action = action.toLowerCase();
          let direction = "";
          if (action === "dig" || action === "tunnel") {
            rl.question("direction (forward, up, down): ", (dir) => {
              direction = dir.toLowerCase();
              turtleAction(action, direction, turtle);
            });
          } else {
            rl.question(
              "direction (forward, back, up, down, left, right): ",
              (dir) => {
                direction = dir.toLowerCase();
                turtleAction(action, direction, turtle);
              }
            );
          }
        }
      );
    }
  });
});

const turtleAction = (action: string, direction: string, turtle: Turtle) => {
  if (action === "move") {
    if (direction === "forward") {
      turtle.do(move.forward);
    } else if (direction === "up") {
      turtle.do(move.up);
    } else if (direction === "down") {
      turtle.do(move.down);
    } else if (direction === "back") {
      turtle.do(move.back);
    } else if (direction === "left") {
      turtle.do(move.left);
    } else if (direction === "right") {
      turtle.do(move.right);
    } else {
      turtle.getFuelLevel;
    }
  } else if (action === "dig" || action === "tunnel") {
    if (direction === "forward") {
      action === "dig" ? turtle.do(dig.forward) : turtle.do(tunnel.forward);
    } else if (direction === "up") {
      action === "dig" ? turtle.do(dig.up) : turtle.do(tunnel.up);
    } else if (direction === "down") {
      action === "dig" ? turtle.do(dig.down) : turtle.do(tunnel.down);
    } else {
      turtle.getFuelLevel;
    }
  } else {
    turtle.getFuelLevel();
  }
};
