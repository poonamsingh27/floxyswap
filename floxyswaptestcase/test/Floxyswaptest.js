const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require('ethers');

describe("Floxyswap Contract", function () {
  let Floxyswap;
  let floxyswap;
  //let admin;

  let user="0xdCe867155ec431Dba1Caa9c21f8567dBbe0472d4"
  // Define your contract addresses and other necessary details
  const admin = "0xdCe867155ec431Dba1Caa9c21f8567dBbe0472d4";
  const token = "0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD";
  const token2Address = "0xF5387b28DF30aB2be8259E2e48824b6f7908938E";
  const usdcTokenAddress = "0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97";
  const maticTokenAddress = "0x0000000000000000000000000000000000001010";
  //const floxyswap = "0xcdff63a84d70f8b97ea589460e6a7173d2e32b73";
  //const user = "0xcDEEd618B32446e0dF0BD0F3a58CB41B262C13e7"
  const conversionRates = [
    BigNumber.from('10000000000000000'),
    BigNumber.from('10000000000000000'),
    BigNumber.from('1000000000000000000')
  ];


  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // Deploy the Floxyswap contract
    Floxyswap = await ethers.getContractFactory("Floxyswap");
    floxyswap = await Floxyswap.deploy();
    await floxyswap.init(
      admin,
      token,
      token2Address,
      usdcTokenAddress,
      maticTokenAddress,
      conversionRates,
    );
    await floxyswap.deployed();
  });

  it("should swap tokens correctly", async function () { 
    // Assuming you have tokens and ETH/MATIC on your testnet accounts
    const amount = BigNumber.from("1000000000000000");
    // Swap tokens
    await expect (floxyswap.connect(user).swapTokens(amount, maticTokenAddress));
  
   });

  it("should swap usdctoToken correctly", async function () {
    // Swap usdc to token
    const amount = BigNumber.from("10000000");

   await expect(floxyswap.connect(user).swapUsdcToToken(amount,token));

  });

  it("should swapnativeToToken correclty",async function() {

    //swap matic or eth  to fxytoken
     const amount = BigNumber.from(10000000000);
    //const amount = ethers.utils.parseEther("0.00000001");

    await expect(floxyswap.connect(user, { value: '10000000000'}).swapnativeToToken('10000000000',token));

  });
  it("should withdraw Matic correctly", async function () {

    // Replace 'privateKey' with the private key of the account you want to use
const adminPrivateKey = "6d926d79abc39487d6a8818da9e0afdd09865c8712dd6e7a75b30c69f90d718c";

    // Fund the admin account with Matic
    //const withdrawalAmount = BigNumber.from(10000);
   // console.log("withdrawalAmount",withdrawalAmount);
   const amountInEth = 0.0000001;
   const amountInWei = BigNumber.from(Math.floor(amountInEth * 1e18));
   console.log("amountInWei",amountInWei);
    const adminWallet = new ethers.Wallet(adminPrivateKey, ethers.provider);
    console.log("adminWallet",adminWallet.address);

    // Withdraw Matic
    await expect (floxyswap.connect(adminWallet).withdrawmatic(amountInWei,{ gasLimit: 300000 }));

  });


  it("should set conversion rates correctly", async function () {
    const newConversionRates = [
      BigNumber.from(Math.floor(0.00002 * 1e18)),  // 0.00002 Matic in Wei
      BigNumber.from(Math.floor(0.00003 * 1e18)),  // 0.00003 Matic in Wei
      BigNumber.from(Math.floor(0.00004 * 1e18))   // 0.00004 Matic in Wei
    ];
     // Replace 'privateKey' with the private key of the account you want to use
    const adminPrivateKey = "6d926d79abc39487d6a8818da9e0afdd09865c8712dd6e7a75b30c69f90d718c";

    const adminWallet = new ethers.Wallet(adminPrivateKey, ethers.provider);
   
    // Set new conversion rates
    await expect(floxyswap.connect(adminWallet).setConversionRates(newConversionRates));

});

});