const { ethers } = require("hardhat");
const { expect } = require("chai");

let al1155;

let deployer;
let user1;
let user2;
let user3;

before(async () => {
  const AL = await ethers.getContractFactory("AddressLimiter1155");
  al1155 = await AL.deploy("myURI");
  await al1155.deployed();

  [deployer, user1, user2, user3] = await ethers.getSigners();
});

describe("AddressLimiter1155", function () {

  it("Should test that AddressLimiter1155 has been deployed", async function () {
    expect(await al1155.uri(0)).to.equal("myURI");
  });

  it("Should try to mint and fail because limits are not set for this(or any) id yet", async function () {
    expect(al1155.mint(user1.address, 0, 1)).to.be.reverted;
  });

  it("Should set address limit for index 0 to 3, and supply limit to 5", async function () {
    await al1155.setAddressMaxForId(0, 3);
    await al1155.setMaxSupplyForId(0, 5);

    expect(await al1155.getAddressMaxForId(0)).to.equal(3);
    expect(await al1155.getMaxSupplyForId(0)).to.equal(5);
  });

  it("Should mint id 0, amount 1 to user1", async function () {
    await al1155.mint(user1.address, 0, 1);

    expect(await al1155.balanceOf(user1.address, 0)).to.equal(1);
  });

  it("Should mint id 0, amount 3 to user2", async function () {
    await al1155.mint(user2.address, 0, 3);

    expect(await al1155.balanceOf(user2.address, 0)).to.equal(3);
  });

  it("Should try to mint id 0, amount 5 to user3, but should fail", async function () {

    expect(al1155.mint(user3.address, 0, 5)).to.be.reverted;
  });

  it("Should mint id 0, amount 1 to user1, and fail minting amount 1 to user2", async function () {
    await al1155.mint(user1.address, 0, 1);

    expect(al1155.mint(user2.address, 0, 1)).to.be.reverted;
  });

  it("Should mint id 1, amount 5, 8, and 5 to users 1, 2, and 3", async function () {
    await al1155.setAddressMaxForId(1, 10);
    await al1155.setMaxSupplyForId(1, 100);
    await al1155.mint(user1.address, 1, 5);
    await al1155.mint(user2.address, 1, 8);
    await al1155.mint(user3.address, 1, 5);

    expect(await al1155.balanceOf(user1.address, 1)).to.equal(5);
    expect(await al1155.balanceOf(user2.address, 1)).to.equal(8);
    expect(await al1155.balanceOf(user3.address, 1)).to.equal(5);
  });

  it("Should transfer id 1, amount 1 from user1  to user2.", async function () {
    await al1155.connect(user1).transferFrom(user1.address, user2.address, 1, 1);

    expect(await al1155.balanceOf(user1.address, 1)).to.equal(4);
    expect(await al1155.balanceOf(user2.address, 1)).to.equal(9);
  });

  it("Should try to transfer id 1, amount 2 from user3  to user2, and fail.", async function () {
    expect(al1155.connect(user3).transferFrom(user3.address, user2.address, 1, 2)).to.be.reverted;
  });

  it("Should burn id 1, amount 2 from user2 and allow user2 to receive again.", async function () {
    await al1155.connect(user2).burn(1, user2.address, 2);
    expect(await al1155.balanceOf(user2.address, 1)).to.equal(7);
    // max out user2 id 1 balance
    await al1155.mint(user2.address, 1, 3);
    expect(await al1155.balanceOf(user2.address, 1)).to.equal(10);
  });

  it("Should batch mint id 0 and id 1, amount 2 each, to user3", async function () {
    // burn from id 0 so there is room to mint
    await al1155.connect(user1).burn(0, user1.address, 2);
    await al1155.connect(user3).mintBatch(user3.address, [0, 1], [2, 2]);
    
    expect(await al1155.balanceOf(user3.address, 0)).to.equal(2);
    expect(await al1155.balanceOf(user3.address, 1)).to.equal(7);
  });

});
