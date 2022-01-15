const { ethers } = require("hardhat");
const { expect } = require("chai");

let al721;

let deployer;
let user1;
let user2;
let user3;

before(async () => {
  const AL = await ethers.getContractFactory("AddressLimiter721");
  al721 = await AL.deploy(10, 3, "bcral token", "BCRAL");
  await al721.deployed();

  [deployer, user1, user2, user3] = await ethers.getSigners();
});

describe("AddressLimiter721", function () {

  it("Should test that AddressLimiter721 has been deployed", async function () {
    expect(await al721.name()).to.equal("bcral token");
  });

  it("Should allow any address to mint to any address for free", async function () {
    await al721.mint(user1.address);
    
    expect(await al721.balanceOf(user1.address)).to.equal(1);
  });

  it("Should mint to users 1, 2, and 3.", async function () {
    await al721.mint(user1.address);
    await al721.mint(user2.address);
    await al721.mint(user3.address);
    
    expect(await al721.balanceOf(user1.address)).to.equal(2);
    expect(await al721.balanceOf(user2.address)).to.equal(1);
    expect(await al721.balanceOf(user3.address)).to.equal(1);
  });

  it("Should mint to user1, making user1 own the max allowed.", async function () {
    await al721.mint(user1.address);
    
    expect(await al721.balanceOf(user1.address)).to.equal(3);
    expect(al721.mint(user1.address)).to.be.revertedWith('This address is not allowed to own any more of this asset.');
  });

  it("Should transfer from user1 to user2.", async function () {
    await al721.connect(user1).transferFrom(user1.address, user2.address, 1);
    
    expect(await al721.balanceOf(user1.address)).to.equal(2);
    expect(await al721.balanceOf(user2.address)).to.equal(2);
  });

  it("Should transfer from user3 to user2.", async function () {
    let owner = await al721.ownerOf(3);

    expect(owner).to.equal(user3.address);

    await al721.connect(user3).transferFrom(user3.address, user2.address, 3);
    
    expect(await al721.balanceOf(user3.address)).to.equal(0);
    expect(await al721.balanceOf(user2.address)).to.equal(3);
  });

  it("Should transfer from user1 to user2 and fail because 2 is maxed out.", async function () {
    
    expect(al721.connect(user1).transferFrom(user1.address, user2.address, 0)).to.be.revertedWith('This address is not allowed to own any more of this asset.');
    expect(await al721.balanceOf(user1.address)).to.equal(2);
    expect(await al721.balanceOf(user2.address)).to.equal(3);
  });
});
