import { Server } from "ws";
import { Turtle } from "./turtle";
import { dig, move } from "./turtle_actions";
import readline from "readline";
import Queue from "p-queue";

const port = 5000;

const wss = new Server({ port: port });

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// const turtleQueue = new Queue({ concurrency: 1 });

wss.on("connection", (ws) => {
  console.log("turtle connected");

  let turtle = new Turtle(ws, "default");
  ws.on("message", (message: string) => {
    if (message.split(" ")[0] == "label") {
      let label = message.split(" ")[1];
      turtle.setLabel(label);
    }
  });
});
