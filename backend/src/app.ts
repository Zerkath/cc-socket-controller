import { Server } from "ws";
import { connect } from "ngrok";
import readline from "readline";

const port = 5000;

const wss = new Server({ port: port });

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

interface Turtle {}

wss.on("connection", (ws) => {
  console.log("Something connected to socket");
  ws.on("message", (message: string) => {
    console.log("Turtle: " + message);
    if (message == "waiting") {
      rl.question("Next: ", (answer: string) => {
        ws.send(answer);
      });
    }
  });
});

async () => {
  const url = await connect(5000);
  console.log(url);
};
