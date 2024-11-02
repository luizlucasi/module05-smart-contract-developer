// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.27;
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

    //ERROS
    error UnauthorizedMinter(address minter);
    error TotalSupplyExceeded(uint256 maxSupply);
    error CannotMintMore();
    error NotEnoughPrice(uint256 price);
    error ChangeMoneyDoesNotWork();
    error WithdrawFailure();

    // Verificar o limite máximo de mint por endereço
    modifier canMint(address account) {
        require(
            _mintedTokensPerAddress[account] < MAX_PER_ADDRESS,
            "Endereco atingiu o maximo de NFT permitidos"
        );
        _;
    }

    constructor(
        string memory _uri,
        address[] memory _BUYER_LIST
    ) ERC721("NFT Collection", "NFTC") Ownable(msg.sender) {
        uri = _uri;
        BUYER_LIST = _BUYER_LIST;
        
        // Autorizarlista BUYER_LIST
         for (uint256 i = 0; i < BUYER_LIST.length; i++) {
            _authorizedMinters[BUYER_LIST[i]] = true;
            authorizedMintersCount++;
        }

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
    tokenIds++; //Incrementa primeiro 
    _mint(to, tokenIds); // Mint do token
    }

    function mint() external payable checkPrice nonReentrant{
     require(_mintedTokensPerAddress[msg.sender] < MAX_PER_ADDRESS, "Endereco atingiu o maximo de NFT permitidos");     
    require(tokenIds < TOTAL_SUPPLY, "Total de NFTs atingiu o limite");    
    validation(); // Valida todas as condições antes de mintar
    _safeMint(msg.sender);
    _mintedTokensPerAddress[msg.sender]++;
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
            if (!success) {
                revert ChangeMoneyDoesNotWork();
            }
        }

        if (!isAuthorizedMinter(msg.sender)) {
            revert UnauthorizedMinter(msg.sender);
        }

        if (tokenIds >= TOTAL_SUPPLY) {
            revert TotalSupplyExceeded(TOTAL_SUPPLY);
        }

        if (_mintedTokensPerAddress[msg.sender] >= MAX_PER_ADDRESS) {
            revert CannotMintMore();
        }
    }

    modifier checkTotalSupply() {
        require(tokenIds < TOTAL_SUPPLY, "Total de NFTs atingiu o limite");
        _;
    }

    function isAuthorizedMinter(address account) internal view returns (bool) {
        return _authorizedMinters[account];
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
