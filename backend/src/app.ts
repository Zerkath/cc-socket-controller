import { Server } from "ws";
import { Turtle } from "./turtle";
import { dig, move, tunnel } from "./turtle_attributes";
import readline from "readline";
// import Queue from "p-queue";

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
        turtle.label + " is waiting for action (dig, tunnel, move, items): ",
        (action) => {
          action = action.toLowerCase();
          let direction = "";
          if (action === "dig" || action === "tunnel") {
            rl.question("direction (forward, up, down): ", (dir) => {
              direction = dir.toLowerCase();
              turtleAction(action, direction, turtle);
            });
          } else if (action === "move") {
            rl.question(
              "direction (forward, back, up, down, left, right): ",
              (dir) => {
                direction = dir.toLowerCase();
                turtleAction(action, direction, turtle);
              }
            );
          } else {
            turtle.getItems();
          }
        }
      );
    }
  });
});

const turtleAction = (action: string, direction: string, turtle: Turtle) => {
  let nextAction: move | dig | tunnel;
  const actionPicked =
    action === "move" || action === "dig" || action === "tunnel";
  if (action === "move") {
    if (direction === "forward") {
      nextAction = move.forward;
    } else if (direction === "up") {
      nextAction = move.up;
    } else if (direction === "down") {
      nextAction = move.down;
    } else if (direction === "back") {
      nextAction = move.back;
    } else if (direction === "left") {
      nextAction = move.left;
    } else if (direction === "right") {
      nextAction = move.right;
    } else {
      turtle.getFuelLevel();
    }
  } else if (action === "dig" || action === "tunnel") {
    if (direction === "forward") {
      nextAction = action === "dig" ? dig.forward : tunnel.forward;
    } else if (direction === "up") {
      nextAction = action === "dig" ? dig.up : tunnel.up;
    } else if (direction === "down") {
      nextAction = action === "dig" ? dig.down : tunnel.down;
    } else {
      turtle.getFuelLevel();
    }
  } else {
    turtle.getFuelLevel();
  }
  if (actionPicked) {
    rl.question("How many times?", (answer: string) => {
      turtle.do(nextAction, Number(answer));
    });
  }
};
