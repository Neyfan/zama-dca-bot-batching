import express from "express";
import bodyParser from "body-parser";
import { enqueueOrder, Order, queue } from "../bot/batcher";

const app = express();
app.use(bodyParser.json());

// POST /orders — добавляем ордер в очередь
app.post("/orders", async (req, res) => {
  const { asset, amount, interval, recipient } = req.body;

  if (!asset || !amount || !interval || !recipient) {
    return res.status(400).send({ error: "Missing fields" });
  }

  try {
    const order: Order = { asset, amount, interval, recipient };
    await enqueueOrder(order);
    res.status(200).send({ success: true });
  } catch (err: any) {
    res.status(500).send({ error: err.message });
  }
});

// GET /orders — посмотреть текущую очередь (для отладки)
app.get("/orders", (req, res) => {
  res.status(200).send({ queue });
});

const PORT = 8787;
app.listen(PORT, () => {
  console.log(`API listening on :${PORT}`);
});
