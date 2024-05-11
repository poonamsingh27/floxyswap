// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Floxyswap is Initializable {
    using SafeERC20 for IERC20;

    address public admin;
    IERC20 public token;
    IERC20 public usdcToken;
     //mapping(address => uint256) public tokenInfo;
    mapping(address => mapping(address => uint256)) public conversionRates; // Maps source and target token addresses to their conversion rate
    address[] public supportedTokens; // Dynamic array to keep track of supported token addresses

    event TokensSwapped(address indexed user, uint256 amount, uint256 targetTokenAmount, address sourceToken, address targetToken);
    event MaticWithdrawn(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount, address indexed token);
    event TokensWithdrawn(address indexed user, uint256 amount, address indexed token);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the contract admin");
        _;
    }

    modifier isValidTokenPair(address sourceToken, address targetToken) {
        require(conversionRates[sourceToken][targetToken] > 0, "Conversion rate not set for the token pair");
        require(isTokenSupported(sourceToken) && isTokenSupported(targetToken), "Invalid token pair");
        _;
    }

    function isTokenSupported(address tokenAddress) internal view returns (bool) {
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == tokenAddress) {
                return true;
            }
        }
        return false;
    }

    function init(
        address _admin,
        address _token,
        address _usdcToken,
        address[] calldata _supportedTokens,
        uint256[] calldata _conversionRates
    ) external initializer {
        require(_admin != address(0), "Invalid admin address");
        require(_token != address(0), "Invalid token address");
        require(_usdcToken != address(0), "Invalid USDC token address");
        require(_supportedTokens.length == _conversionRates.length, "Array lengths do not match");

        admin = _admin;
        token = IERC20(_token);
        usdcToken = IERC20(_usdcToken);

        for (uint256 i = 0; i < _supportedTokens.length; i++) {
            require(_supportedTokens[i] != address(0), "Invalid supported token address");
            require(_conversionRates[i] > 0, "Invalid conversion rate");

            supportedTokens.push(_supportedTokens[i]);

            for (uint256 j = 0; j < _supportedTokens.length; j++) {
                if (i != j) {
                    // Avoid self-mapping
                    conversionRates[_supportedTokens[i]][_supportedTokens[j]] = _conversionRates[j];
                }
            }
        }
    }

    function setConversionRate(address sourceToken, address targetToken, uint256 rate) external onlyAdmin {
        require(sourceToken != address(0) && targetToken != address(0), "Invalid token address");
        require(rate > 0, "Invalid conversion rate");

        conversionRates[sourceToken][targetToken] = rate;
    }

    function swapTokens(uint256 amount, address sourceToken, address targetToken) external isValidTokenPair(sourceToken, targetToken) {
        require(amount > 0, "Invalid amount");

        // Transfer tokens from the user to the contract
        IERC20(sourceToken).safeTransferFrom(msg.sender, address(this), amount);

        // Calculate the target token amount based on the specified conversion rate
        uint256 targetTokenAmount = (amount * conversionRates[sourceToken][targetToken]) / 1e18;

       // Transfer the target token to the user
          transferTargetToken(targetToken, targetTokenAmount);
        emit TokensSwapped(msg.sender, amount, targetTokenAmount, sourceToken, targetToken);
    }

   
    function swapnativeToToken(uint256 amount,address sourceToken, address targetToken) external payable isValidTokenPair(sourceToken,targetToken) {
        require(amount > 0 && msg.value == amount, "Invalid amount");

        // Ensure that the target token is in the list of supported tokens
        require(isTokenSupported(targetToken), "Unsupported target token");

        // Additional check to ensure that the target token is a valid ERC20 token
        require(isValidERC20(targetToken), "Invalid ERC20 token");

        // Calculate the target token amount based on the specified conversion rate
        uint256 targetTokenAmount = (amount * conversionRates[sourceToken][targetToken]) / 1e18;

        // Transfer the target token to the user
        IERC20(targetToken).safeTransfer(msg.sender, targetTokenAmount);
        emit TokensSwapped(msg.sender, amount, targetTokenAmount, targetToken,sourceToken);
    }
     // Add similar functions for swapping tokens to MATIC, etc.
    receive() external payable {
        
    }

      // withdraw funds from contract address
    function withdrawFunds(uint256 amount, address targetToken) external onlyAdmin {
        require(amount > 0, "Invalid amount");

        if (targetToken == address(0) || targetToken == address(0x0000000000000000000000000000000000001010)) {
            // If targetToken is ETH or Matic
            payable(admin).transfer(amount);
            emit Withdrawn(admin, amount, targetToken);
        } else {
            // If targetToken is an ERC20 token other than Matic
            IERC20(targetToken).safeTransfer(admin, amount);
            emit TokensWithdrawn(admin, amount, targetToken);
        }
    }

    function transferTargetToken(address targetToken, uint256 amount) internal {
        if (targetToken == address(0) || targetToken == address(0x0000000000000000000000000000000000001010)) {
            // If targetToken is ETH or Matic
            payable(msg.sender).transfer(amount);
        } else {
            // If targetToken is an ERC20 token other than Matic
            IERC20(targetToken).safeTransfer(msg.sender, amount);
        }
    }

    // Function to check if the address is a valid ERC20 token
    function isValidERC20(address tokenAddress) internal view returns (bool) {
        try IERC20(tokenAddress).totalSupply() returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }
}
