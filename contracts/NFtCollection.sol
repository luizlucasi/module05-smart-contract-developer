// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Coleção NFT Limitada
 * @notice Este contrato implementa uma coleção de NFTs com limite de supply e controle de minting.
 * @dev O contrato segue o padrão ERC-721, permitindo a criação e venda de NFTs com preço fixo e limitações.
 * Este contrato é apenas para estudos, nunca utiliza-lo em produção!!!
 * @author Jeftar Mascarenhas
 */
contract NFtCollection is ERC721, ERC721Burnable, Ownable, ReentrancyGuard {
    uint256 public constant TOTAL_SUPPLY = 10;
    uint256 public constant MAX_PER_ADDRESS = 2;
    uint256 public constant NFT_PRICE = 0.05 ether;
    uint256 public constant MINTERS_ALLOWED = 3;

    address[] public BUYER_LIST;

    uint256 public tokenIds;
    string public uri;

    // Mapeamento para rastrear quantos NFTs cada endereço mintou
    mapping(address => uint256) private _mintedTokensPerAddress;

    // Mapeamento para autorizar endereços a mintar
    mapping(address => bool) private _authorizedMinters;
    uint256 public authorizedMintersCount;

    // Eventos para monitoramento de adição e remoção de endereços
    event AddressMintAuthorized(address indexed account);
    event AddressMintRemoved(address indexed account);

    // Verificar o limite máximo de mint por endereço
    modifier canMint(address account) {
        require(
            _mintedTokensPerAddress[account] < MAX_PER_ADDRESS,
            "Endereco atingiu o maximo de NFT permitidos"
        );
        _;
    }

    error NotEnoughPrice(uint256 price);
    error ChangeMoneyDoesNotWork();
    error WithdrawFailure();

    constructor(
        string memory _uri,
        address[] memory _BUYER_LIST
    ) ERC721("NFT Collection", "NFTC") Ownable(msg.sender) {
        uri = _uri;
        BUYER_LIST = _BUYER_LIST;
    }

    modifier checkPrice() {
        if (msg.value < NFT_PRICE) {
            revert NotEnoughPrice(msg.value);
        }
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function _safeMint(address to) internal canMint(to) checkTotalSupply {
        validation();
        _mint(to, tokenIds); // Corrigir o uso aqui para evitar loop
        tokenIds++;
    }

    function mint() external payable checkPrice isAuthorizedMinter {
        _safeMint(msg.sender);
    }

    //proteção contra reentrância
    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) {
            revert WithdrawFailure();
        }
    }

    function validation() internal {
        if (msg.value > NFT_PRICE) {
            uint256 changeMoney = msg.value - NFT_PRICE;
            (bool success, ) = payable(msg.sender).call{value: changeMoney}("");
            /**
             * Pode usar o erro customizado no require se a versão for 0.8.27
             * require(success, ChangeMoneyDoesNotWork());
             */
            if (!success) {
                revert ChangeMoneyDoesNotWork();
            }
        }
    }

    modifier checkTotalSupply() {
        require(tokenIds < TOTAL_SUPPLY, "Total de NFTs atingiu o limite");
        _;
    }

    modifier isAuthorizedMinter() {
        require(
            _authorizedMinters[msg.sender],
            "Endereco nao autorizado a mintar"
        );
        _;
    }

    // Adicionar um endereço autorizado, limitado a 3 endereços
    function authorizeMinter(address account) external onlyOwner {
        require(account != address(0), "Endereco invalido");
        require(!_authorizedMinters[account], "Endereco ja autorizado");
        require(
            authorizedMintersCount < MINTERS_ALLOWED,
            "Limite de enderecos autorizados atingido"
        );

        _authorizedMinters[account] = true;
        authorizedMintersCount++;
        emit AddressMintAuthorized(account);
    }

    // Remover um endereço da lista de autorizados
    function removeMinter(address account) external onlyOwner {
        require(_authorizedMinters[account], "Endereco nao autorizado");

        _authorizedMinters[account] = false;
        authorizedMintersCount--;
        emit AddressMintRemoved(account);
    }
}
