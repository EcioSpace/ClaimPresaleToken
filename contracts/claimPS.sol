// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @author ECIO Engineering Team
/// @title Claimtoken Smart Contract

interface BalancesChecker {
    function accountBalances(address _address) external view returns (uint);
}



contract Claimtoken is Ownable, ReentrancyGuard {

  //BUSD token address.
  address public busdTokenAddress;

  //ECIO token address.
  address public ecioTokenAddress;


  function setBUSDTokenAddress(address _address) public onlyOwner{
      busdTokenAddress = _address;
  }

  function setECIOTokenAddress(address _address) public onlyOwner{
      ecioTokenAddress = _address;
  }

  function checkPresale(address presales, address _customerAddress) external view returns (uint256) {
        return BalancesChecker(presales).accountBalances(_customerAddress);
   }



}
