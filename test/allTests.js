const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Tpay DEX Full Stack Test", function () {
  let deployer, team, marketing, user;
  let token, farm, factory, router, lp;
  let TpayToken, TpayFarm, TpayFactory, TpayPair, TpayRouter;
  let token0, token1, pairAddress;

  before(async () => {
    [deployer, team, marketing, user] = await ethers.getSigners();

    // Deploy TPAY token
    TpayToken = await ethers.getContractFactory("TpayToken");
    token = await TpayToken.deploy(team.address, marketing.address);
    await token.deployed();

    // Deploy farming contract
    const currentBlock = await ethers.provider.getBlockNumber();
    TpayFarm = await ethers.getContractFactory("TpayFarm");
    farm = await TpayFarm.deploy(token.address, ethers.utils.parseEther("1"), currentBlock + 10);
    await farm.deployed();

    // Give farm tokens for rewards
    await token.transfer(farm.address, ethers.utils.parseEther("100000"));

    // Deploy DEX core: factory and router
    TpayFactory = await ethers.getContractFactory("TpayFactory");
    factory = await TpayFactory.deploy(deployer.address);
    await factory.deployed();

    TpayRouter = await ethers.getContractFactory("TpayRouter");
    router = await TpayRouter.deploy(factory.address);
    await router.deployed();

    // Deploy two mock ERC20 tokens to simulate trading pairs
    const MockToken = await ethers.getContractFactory("TpayToken");
    token0 = await MockToken.deploy(deployer.address, marketing.address);
    token1 = await MockToken.deploy(deployer.address, marketing.address);
    await token0.deployed();
    await token1.deployed();

    // Give user test tokens
    await token0.transfer(user.address, ethers.utils.parseEther("1000"));
    await token1.transfer(user.address, ethers.utils.parseEther("1000"));
  });

  it("should correctly initialize TPAY token and vesting", async () => {
    const total = await token.totalSupply();
    expect(await token.balanceOf(marketing.address)).to.equal(total.mul(20).div(100));
    expect(await token.vestedAmount(team.address)).to.equal(total.mul(20).div(100));
  });

  it("should reject early vesting claim", async () => {
    await expect(token.connect(team).claimVested()).to.be.revertedWith("Vesting not ended");
  });

  it("should allow creating a new trading pair via factory", async () => {
    await factory.createPair(token0.address, token1.address);
    pairAddress = await factory.getPair(token0.address, token1.address);
    expect(pairAddress).to.not.equal(ethers.constants.AddressZero);
  });

  it("should allow adding liquidity via router", async () => {
    await token0.connect(user).approve(router.address, ethers.utils.parseEther("100"));
    await token1.connect(user).approve(router.address, ethers.utils.parseEther("100"));

    await router.connect(user).addLiquidity(
      token0.address,
      token1.address,
      ethers.utils.parseEther("50"),
      ethers.utils.parseEther("50")
    );

    const pairAddr = await factory.getPair(token0.address, token1.address);
    const TpayPair = await ethers.getContractFactory("TpayPair");
    const pair = await TpayPair.attach(pairAddr);

    expect(await pair.balanceOf(user.address)).to.be.gt(0);
  });

  it("should allow token swap via router", async () => {
    const amountOut = ethers.utils.parseEther("5");

    await token0.connect(user).approve(router.address, ethers.utils.parseEther("50"));

    await router.connect(user).swap(
      token0.address,
      token1.address,
      amountOut
    );

    const bal = await token1.balanceOf(user.address);
    expect(bal).to.be.gt(0);
  });

  it("should allow staking LP tokens in farm and earn TPAY", async () => {
    const pairAddr = await factory.getPair(token0.address, token1.address);
    const TpayPair = await ethers.getContractFactory("TpayPair");
    const pair = await TpayPair.attach(pairAddr);

    await farm.addPool(100, pair.address);

    const lpAmount = await pair.balanceOf(user.address);
    await pair.connect(user).approve(farm.address, lpAmount);

    await farm.connect(user).deposit(0, lpAmount);
    await ethers.provider.send("evm_mine"); // simulate block

    await farm.connect(user).withdraw(0, lpAmount);
    const tpayBalance = await token.balanceOf(user.address);
    expect(tpayBalance).to.be.gt(0);
  });
});
