import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

const NFtCollection = buildModule("nftCollectionModule", (module) => {
    const ana = '0x1eB50333B53515189Fab1f70D69E2D40D8f5a2CA'
    const john = '0xB36Ce604EF05648f8d4C249B6BC2bD3b6EeB00ba'
    const peter = '0x1BB1c5ca4ca4363a6cfb4d18D7e1bBF4adaE1eAc'
    const buyerList = [ana, john]
    const uri = "https://ipfs.io/ipfs/QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/"

    const nftCollection = module.contract('NFtCollection', [uri, buyerList]);

    return { nftCollection }
})

export default NFtCollection;