// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @author ECIO Engineering Team
/// @title Claimtoken Smart Contract


//BUSD token address.
address public busdTokenAddress;

function setBUSDTokenAddress(address _address) public onlyOwner{
    busdTokenAddress = _address;
}
