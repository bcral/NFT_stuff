const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Practice", function () {
  it("Should test that Practice has been deployed", async function () {
    const Practice = await ethers.getContractFactory("PracticeNFT");
    const practice = await Practice.deploy();
    await practice.deployed();

    expect(await practice.greet()).to.equal("");
  });
});
