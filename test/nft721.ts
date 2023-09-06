import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('MyNFT Contract', function () {
  let owner;
  let addr1;
  let addr2;
  let myNFT;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the ERC721 contract
    const MyNFT = await ethers.getContractFactory('MyNFT');
    myNFT = await MyNFT.deploy();
    await myNFT.deployed();

    // Mint some tokens for testing
    await myNFT.mintToken(owner.address);
    await myNFT.mintToken(addr1.address);
  });

  it('Should return correct name and symbol', async function () {
    expect(await myNFT.name()).to.equal('MyNFT');
    expect(await myNFT.symbol()).to.equal('MNFT');
  });

  it('Should mint tokens and check owner balance', async function () {
    expect(await myNFT.balanceOf(owner.address)).to.equal(1);
    expect(await myNFT.balanceOf(addr1.address)).to.equal(1);
    expect(await myNFT.balanceOf(addr2.address)).to.equal(0);
  });

  it('Should transfer tokens', async function () {
    const tokenId = 0; // Assuming the first token was minted to the owner

    // Transfer token from owner to addr2
    await myNFT.connect(owner).transferFrom(owner.address, addr2.address, tokenId);

    expect(await myNFT.ownerOf(tokenId)).to.equal(addr2.address);
  });

  it('Should approve and transfer tokens', async function () {
    const tokenId = 0; // Assuming the first token was minted to the owner

    // Approve addr1 to transfer token on behalf of owner
    await myNFT.connect(owner).approve(addr1.address, tokenId);

    // Transfer token from owner to addr2 using addr1 as the intermediary
    await myNFT.connect(addr1).transferFrom(owner.address, addr2.address, tokenId);

    expect(await myNFT.ownerOf(tokenId)).to.equal(addr2.address);
  });
});
