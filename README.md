# Floxyswap Smart Contract

# Overview

The Floxyswap Smart Contract facilitates decentralized token swapping between Ethereum (ETH), 
Matic (Polygon), and other ERC20 tokens. The contract utilizes the OpenZeppelin library 
for ERC20 interactions and is designed to provide a flexible and secure mechanism for users to 
exchange various tokens on supported networks.

# Features

1. Token Swapping: Users can swap ERC20 tokens, ETH, or Matic for other specified tokens with predefined 
conversion rates.

2. Native Token Swapping: Users can exchange native tokens (ETH or Matic) for specified target tokens, 
considering the chain on which the contract is deployed.

3. USDC to Token Swapping: Users can swap USDC tokens for other specified tokens based on predefined 
conversion rates.

4. Conversion Rates: The contract allows the administrator to set and update conversion rates for ETH, Matic, 
and other ERC20 tokens.

5. Withdrawal Functions:

* Withdraw Matic: The administrator can withdraw Matic from the contract.
* Withdraw ETH: The administrator can withdraw ETH from the contract.
* Withdraw ERC20 Tokens: Users can withdraw ERC20 tokens from the contract.

6. Admin Transfer: The contract allows for the transfer of administrative privileges to a new address.

# Contract Initialization
The contract is initialized with the following parameters:

1. admin: Address of the contract administrator.
2. token: Address of the main ERC20 token.
3. token2: Address of the secondary ERC20 token.
4. usdcToken: Address of the USDC token.
5. matictoken: Address of the Matic token.
6. conversionRates: Array of conversion rates for ETH, Matic, and other ERC20 tokens.

# Usage

# Token Swapping:

Use the swapTokens function to exchange ERC20 tokens for a specified target token.

# Native Token Swapping:

Utilize swapnativeToToken to swap native tokens (ETH or Matic) for the specified target token.

# USDC to Token Swapping:

Use swapUsdcToToken to swap USDC tokens for the specified target token.

# Setting Conversion Rates:

The administrator can update conversion rates using the setConversionRates function.

# Withdrawal:ONLY admin call this function

1. Withdraw Matic using withdrawmatic.
2. Withdraw ETH using withdraweth.
3. Withdraw ERC20 tokens using withdrawToken.

# Admin Transfer:

The administrator can transfer administrative privileges to a new address using transferAdmin.