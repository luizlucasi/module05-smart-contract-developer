import { ethers, ignition } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

async function deployNFtCollectionFixture() {
    const [owner, ana, john, carlos, ...accounts] = await ethers.getSigners()
    const uri = 'https://example.com/image/'
    const name = "NFT Collection"
    const symbol = "NFTC"
    const buyerList = [ana.address, john.address, carlos.address]
    const NFtCollection = await ethers.getContractFactory('NFtCollection');

    const nftCollection = await NFtCollection.deploy(uri, buyerList)
    await nftCollection.waitForDeployment()

    return {
        nftCollection,
        name,
        symbol,
        owner,
        ana,
        john,
        carlos,
        ...accounts
    }
}

describe("Contrato NFtCollection", () => {
    describe("Implantação", function () {
        it("Deve definir o nome e símbolo corretos", async function () {
            const { nftCollection } = await loadFixture(deployNFtCollectionFixture);

            expect(await nftCollection.name()).to.equal("NFT Collection");
            expect(await nftCollection.symbol()).to.equal("NFTC");
        });

        it("Deve definir o limite correto de supply total", async function () {
            const { nftCollection } = await loadFixture(deployNFtCollectionFixture);

            expect(await nftCollection.TOTAL_SUPPLY()).to.equal(10);
        });

        it("Deve definir o preço correto para os NFTs", async function () {
            const { nftCollection } = await loadFixture(deployNFtCollectionFixture);

            expect(await nftCollection.NFT_PRICE()).to.equal(ethers.parseEther("0.05"));
        });
    });

    describe("Mintando NFTs", function () {
        it.only("Deve mintar NFT quando o preço correto é pago", async function () {
            const { nftCollection, ana } = await loadFixture(deployNFtCollectionFixture);

            const price = ethers.parseEther("0.05");

            await expect(nftCollection.connect(ana).mint({ value: price }))
                .to.emit(nftCollection, "Transfer")
                .withArgs(ethers.ZeroAddress, ana.address, 0);
            const contractBalance = await ethers.provider.getBalance(nftCollection.target);
            expect(contractBalance).to.equal(price)
            console.log(await nftCollection.tokenIds());

            // await nftCollection.ownerOf(ana.address)
        });

        it("Deve mintar NFT quando o preço correto é pago", async function () {
            const { nftCollection, ana } = await loadFixture(deployNFtCollectionFixture);
            const price = ethers.parseEther("0.2");
            await expect(nftCollection.connect(ana).mint({ value: price }))
                .to.revertedWithCustomError(nftCollection, "NotEnoughPrice")
                .withArgs(price);
        });

        it("Deve reverter se o limite de supply for excedido", async function () {
            const { nftCollection, ana, john } = await loadFixture(deployNFtCollectionFixture);
            const price = ethers.parseEther("0.05");
            for (let i = 0; i < 5; i++) {
                await nftCollection.connect(ana).mint({ value: price });
                await nftCollection.connect(john).mint({ value: price });
            }

            await nftCollection.connect(john).mint({ value: price })
        });

        it("Deve reverter se um endereço tentar mintar mais de 2 NFTs", async function () {
            const { nftCollection, ana } = await loadFixture(deployNFtCollectionFixture);

            expect.fail("O aluno deve implementar este teste")
        });

        it("Deve devolver o excesso de ether enviado", async function () {
            const { nftCollection, john } = await loadFixture(deployNFtCollectionFixture);
            expect.fail("O aluno deve implementar este teste")
        });
    });

    describe("Segurança e Validação", function () {
        it("Deve permitir apenas ao proprietário sacar o saldo", async function () {
            const { nftCollection, owner, ana } = await loadFixture(deployNFtCollectionFixture);
            await expect(nftCollection.connect(ana).withdraw()).to.be.revertedWithCustomError(nftCollection, "OwnableUnauthorizedAccount")

            await nftCollection.connect(owner).withdraw();
            expect(await ethers.provider.getBalance(nftCollection.target)).to.equal(0);
        });

        it("Deve prevenir ataque de reentrância no saque", async function () {
            const { nftCollection, owner } = await loadFixture(deployNFtCollectionFixture);
            expect.fail("O aluno deve implementar este teste")
        });
    });
})