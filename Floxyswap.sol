// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title Floxyswap
 * @dev This smart contract facilitates token swapping between Ethereum, Matic, and ERC20 tokens.
 * It utilizes OpenZeppelin libraries for ERC20 interactions and contract initialization.
 */

contract Floxyswap is Initializable {
    using SafeERC20 for IERC20;
    address public admin;
    IERC20 public token;
    IERC20 public token2;
    IERC20 public usdcToken;
    IERC20 public matictoken;
    address private _owner;
    uint256[] public conversionRates;

    event TokensSwapped(address indexed user, uint256 amount, uint256 targetTokenAmount);
    event MaticWithdrawn(address indexed to, uint256 amount);
    event withdrawETH(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount, address indexed token);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the contract admin");
        _;
    } 

    /**
     * @dev Initialization of the Contract
     * @param _admin Address of the contract administrator
     * @param _token Address of the main ERC20 token
     * @param _token2 Address of the secondary ERC20 token
     * @param _usdcToken Address of the USDC token
     * @param _matictoken Address of the Matic token
     * @param _conversionRates Array of conversion rates for ETH, Matic, and other ERC20 tokens
     */

    function init(
        address _admin,
        address _token,
        address _token2,
        address _usdcToken,
        address _matictoken,
       uint256[3] memory _conversionRates
    ) external initializer {
        admin = _admin;
        token = IERC20(_token);
        token2 = IERC20(_token2);
        matictoken = IERC20(_matictoken);
        usdcToken = IERC20(_usdcToken);
       conversionRates = _conversionRates;

    }

      /**
     * @dev Set new conversion rates for ETH, Matic, and other ERC20 tokens
     * @param _conversionRates Array of new conversion rates
     */

    function setConversionRates(uint256[] memory _conversionRates) external onlyAdmin {
        require(_conversionRates.length == 3, "Invalid conversion rates array length");
        conversionRates = _conversionRates;
    }


     /**
     * @dev Swap ERC20 tokens for the specified target token
     * @param amount Amount of tokens to be swapped
     * @param targetToken Address of the target token
     * matic address= 0x0000000000000000000000000000000000001010
     * eth address= 0x0000000000000000000000000000000000000000
     */

    function swapTokens(uint256 amount, address targetToken) external {
        require(amount > 0, "Invalid amount");

        // Transfer tokens from the user to the contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Determine the index of the target token in the array
        uint256 tokenIndex;
        if (targetToken == address(0)) {
            // If targetToken is ETH
            tokenIndex = 0;
        } else if (targetToken == address(0x0000000000000000000000000000000000001010)) {
            // If targetToken is Matic
            tokenIndex = 1;
        } else {
            // If targetToken is an ERC20 token other than Matic
            tokenIndex = 2;
        }

        // Calculate the target token amount based on the specified conversion rate
        uint256 targetTokenAmount = (amount * conversionRates[tokenIndex]) / 1e18;

        // Transfer the target token to the user
        if (targetToken == address(0) || targetToken == address(0x0000000000000000000000000000000000001010)) {
            // If targetToken is ETH or Matic
            payable(msg.sender).transfer(targetTokenAmount);
        } else {
            // If targetToken is an ERC20 token other than Matic
            IERC20(targetToken).safeTransfer(msg.sender, targetTokenAmount);
        }

        emit TokensSwapped(msg.sender, amount, targetTokenAmount);
     }

      /**
     * @dev Swap native tokens (ETH or Matic) for the specified target token
     * @param amount Amount of native tokens to be swapped
     * @param targetToken Address of the target token
     * targetTOken address=0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD
     */

    function swapnativeToToken(uint256 amount, address targetToken) external payable {
    require(amount > 0, "Invalid amount");
    require(msg.value == amount, "Incorrect amount sent");

    uint256 tokenIndex;

    // Identify the chain based on the source address
    if (block.chainid == 11155111) {
        // If chain ID is 1, it's Ethereum testnet
        tokenIndex = 0; // ETH
    } else if (block.chainid == 80001) {
        // If chain ID is 137, it's Matic testnet
        tokenIndex = 1; // Matic
    } else {
        // If neither Ethereum nor Matic, assume ERC20
        tokenIndex = 2;
    }

    // Calculate the target token amount based on the ratio
    uint256 targetTokenAmount;
    if (tokenIndex == 1) {
        // If Matic, use conversionRates[tokenIndex]
        targetTokenAmount = (amount * conversionRates[tokenIndex]) / 1e18;
    } else {
        // If ETH or other ERC20, use conversionRates
        targetTokenAmount = (amount * conversionRates[tokenIndex]) / 1e18;
    }

    // Transfer the target token to the user
    IERC20(targetToken).safeTransfer(msg.sender, targetTokenAmount);

    emit TokensSwapped(msg.sender, amount, targetTokenAmount);
}

   /**
     * @dev Swap USDC tokens for the specified target token
     * @param amount Amount of USDC tokens to be swapped
     * @param targetToken Address of the target token
     * token address = 0x3ADD0D140057303AeaA689C867Ca2eA3A7F844aD
     */

    function swapUsdcToToken(uint256 amount, address targetToken) external {
    require(amount > 0, "Invalid amount");

    // Determine the index of the target token in the array
        uint256 tokenIndex;
        if (targetToken == address(0)) {
            // If targetToken is ETH
            tokenIndex = 0;
        } else if (targetToken == address(0x0000000000000000000000000000000000001010)) {
            // If targetToken is Matic
            tokenIndex = 1;
        } else {
            // If targetToken is an ERC20 token other than Matic
            tokenIndex = 2;
        }

    // Transfer USDC from the user to the contract
    usdcToken.safeTransferFrom(msg.sender, address(this), amount);

    // Calculate the target token amount based on the ratio
    uint256 targetTokenAmount = (amount * conversionRates[tokenIndex]) / 1e18;

    // Transfer the target token to the user
    IERC20(targetToken).safeTransfer(msg.sender, targetTokenAmount);

    emit TokensSwapped(msg.sender, amount, targetTokenAmount);
}

 
    // Add similar functions for swapping tokens to MATIC, etc.
     receive() external payable {
        
     }

      // withdraw eth or matic from contract address
    function withdrawmatic(uint256 amount) external onlyAdmin {
         payable(admin).transfer(amount);
    }

    function withdraweth(uint256 amount) external onlyAdmin {
         payable(admin).transfer(amount);
    }

    function withdrawToken(address tokenAddress, uint256 amount) external {
    require(amount > 0, "Invalid amount");

    // Transfer tokens to the user
    IERC20(tokenAddress).safeTransfer(msg.sender, amount);

    emit TokensWithdrawn(msg.sender, amount, tokenAddress);
   
   }
  
   /**
     * @dev Transfer contract administration to a new address
     * @param newAdmin Address of the new administrator
     */

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid new admin address");
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}