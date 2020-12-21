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

wss.on("connection", (ws, request) => {
  const label = request.url?.slice(1);
  console.log(label + " connected");
  const turtle = new Turtle(ws, String(label));
  turtle.getFuelLevel();
  ws.on("message", (message: string) => {
    console.log(message);
  });
});
