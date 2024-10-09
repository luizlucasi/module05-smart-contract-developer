# Curso Smart Contract Developer do zero ao intermediário.
Requisitos para desenvolvimento do contrato.

## Requisitos para o Contrato de NFT (Parte Completa pelos Alunos):

- **Nome e Símbolo do Token:** O contrato deve implementar o padrão ERC-721 com nome "NFT Collection" e símbolo "NFTC".
- **Limite de Supply:** O contrato deve garantir que não sejam emitidos mais de 10 NFTs.
- **Limite de NFTs por Endereço:** Um endereço não pode possuir mais de 2 NFTs, respeitando o limite de compras.
- **Preço Fixo por NFT:** Cada NFT custa 0.5 ether. O contrato deve verificar se o comprador enviou o valor correto e, se for enviado um valor maior, devolver o troco.
- **Função de Mint:** A função `mint` permite a compra de NFTs. Cada compra minta um novo NFT para o comprador, desde que o limite de supply e de NFTs por endereço não tenha sido atingido.
- **Reembolso de Troco:** Se o comprador enviar mais ether do que o necessário, o contrato reembolsará a diferença.
- **Função de Saque:** O proprietário do contrato pode sacar o saldo acumulado com a função `withdraw`, que transfere todo o saldo do contrato para o proprietário.

## Instrutor
Jeftar Mascarenhas - Blockchain Engineer at GFT Brazil.
- [Youtube](https://www.youtube.com/@nftchoose)
- [LinkedIn](https://www.linkedin.com/in/jeftar.macarenhas)
- [Github](https://github.com/jeftarmascarenhas)
