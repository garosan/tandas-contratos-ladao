const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Main Contract", function () {
  let Main, main;
  let Token, token;
  let owner, devFund, user;

  beforeEach(async () => {
    [owner, devFund, user] = await ethers.getSigners();

    // Deploy a fake ERC20 token
    Token = await ethers.getContractFactory("MockFakeToken");
    token = await Token.deploy("MockFakeToken", "MFT");
    await token.waitForDeployment();

    // Deploy Main
    Main = await ethers.getContractFactory("Main");
    main = await Main.deploy(devFund.address);
    await main.waitForDeployment();
  });

  it("should deploy Main, create a SavingGroup, and register a user", async () => {
    // 1. Create a round
    const tx = await main.createRound(
      5,
      5,
      3,
      5,
      1,
      token.target // .target for ethers v6
    );
    await tx.wait();

    // 2. Get new SavingGroups instance
    const logs = await main.queryFilter(main.filters.RoundCreated());
    const newRoundAddress = logs[0].args.childRound;

    const SavingGroups = await ethers.getContractFactory("SavingGroups");
    const round = await SavingGroups.attach(newRoundAddress);

    // 3. Mint and approve tokens for user
    const amount = ethers.parseEther("1000");
    await token.mint(user.address, amount);
    await token.connect(user).approve(round.target, amount); // .target instead of .address

    // 4. Register user at position 1
    await round.connect(user).registerUser(1);

    // 5. Assert user is active
    const isActive = await round.getUserIsActive(1);
    expect(isActive).to.be.true;
  });
});
