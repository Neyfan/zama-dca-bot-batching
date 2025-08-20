import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();

const { RPC_URL, PRIVATE_KEY, CONTRACT_ADDRESS } = process.env;

if (!RPC_URL || !PRIVATE_KEY || !CONTRACT_ADDRESS) {
  throw new Error("Missing RPC_URL, PRIVATE_KEY or CONTRACT_ADDRESS in .env");
}

export interface Order {
  asset: string;        // теперь поле asset есть
  recipient: string;
  amount: string;
  interval: number;
}

// Очередь заказов
export const queue: Order[] = [];

// Провайдер и кошелек
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

// Контракт (ABI нужно подставить свой)
const contractAbi = [
  "function storeOrder(address recipient, uint256 amount) external"
];
const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi, wallet);

console.log("Batcher bot started...");

// Добавление заказа в очередь
export const enqueueOrder = async (order: Order) => {
  console.log(`Enqueue order: asset=${order.asset}, recipient=${order.recipient}, amount=${order.amount}`);
  queue.push(order);
};

// Обработка очереди каждые n секунд
const processQueue = async () => {
  if (queue.length === 0) return;

  const order = queue.shift();
  if (!order) return;

  try {
    console.log(`Processing order for ${order.recipient}, amount: ${order.amount}`);
    const tx = await contract.storeOrder(
      order.recipient,
      ethers.parseUnits(order.amount, 18)
    );
    await tx.wait();
    console.log(`Order processed: ${order.recipient}, txHash=${tx.hash}`);
  } catch (error) {
    console.error("Error processing order:", error);
  }
};

// Интервал обработки (каждые 5 секунд)
setInterval(processQueue, 5000);
