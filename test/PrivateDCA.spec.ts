import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("PrivateDCA", function () {
  let privateDCA: Contract;
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const PrivateDCA = await ethers.getContractFactory("PrivateDCA");
    privateDCA = await PrivateDCA.deploy(); // deploy сразу возвращает контракт
  });

  it("stores orders and emits events", async function () {
    const amount = 1000;

    await expect(privateDCA.connect(user1).storeOrder(await user1.getAddress(), amount))
      .to.emit(privateDCA, "OrderStored")
      .withArgs(await user1.getAddress(), amount);

    const order = await privateDCA.getOrder(await user1.getAddress(), 0);
    expect(order.user).to.equal(await user1.getAddress());
    expect(order.amount).to.equal(amount);
  });

  it("handles multiple orders for one user", async function () {
    const amounts = [500, 1500, 2500];

    for (const amount of amounts) {
      await privateDCA.connect(user1).storeOrder(await user1.getAddress(), amount);
    }

    const count = await privateDCA.getOrderCount(await user1.getAddress());
    expect(count).to.equal(amounts.length);

    for (let i = 0; i < amounts.length; i++) {
      const order = await privateDCA.getOrder(await user1.getAddress(), i);
      expect(order.amount).to.equal(amounts[i]);
    }
  });

  it("stores orders for different users independently", async function () {
    const amount1 = 1000;
    const amount2 = 2000;

    await privateDCA.connect(user1).storeOrder(await user1.getAddress(), amount1);
    await privateDCA.connect(user2).storeOrder(await user2.getAddress(), amount2);

    const order1 = await privateDCA.getOrder(await user1.getAddress(), 0);
    const order2 = await privateDCA.getOrder(await user2.getAddress(), 0);

    expect(order1.amount).to.equal(amount1);
    expect(order2.amount).to.equal(amount2);
  });
});
