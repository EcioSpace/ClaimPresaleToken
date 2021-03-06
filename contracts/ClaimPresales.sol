// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @author ECIO Engineering Team
/// @title Claimtoken Smart Contract

interface BalancesChecker {
    function accountBalances(address _address) external view returns (uint);
}

interface VestingInterface {
    function addVesting(address _user, uint256 _amount) external view returns (uint);
    function claimVesting() external nonReentrant{};
    function getVestingClaimableAmount(address _user) external view returns (uint256);
}

contract Claimtoken is Ownable, ReentrancyGuard {

  //BUSD token address.
  address public busdTokenAddress;

  //ECIO token address.
  address public ecioTokenAddress;

  //Presales Address
  address public presalesAddress;

  //customerBalance from Presales
  uint256 customerBalance;

  uint256 private ecioPrice = 0.0020;


  function setBUSDTokenAddress(address _address) public onlyOwner{
      busdTokenAddress = _address;
  }

  function setECIOTokenAddress(address _address) public onlyOwner{
      ecioTokenAddress = _address;
  }

  function setPresaleAddress(address _address) public onlyOwner{
      presalesAddress = _address;
  }

  function checkPresale(address presalesAddr, address _customerAddress) external view returns (uint256) {
        return BalancesChecker(presalesAddr).accountBalances(_customerAddress);
  }

  function amountCaculate(address _customerAddress) public nonReentrant {
      //update Presales Balance
      customerBalance = BalancesChecker(presalesAddress).accountBalances(_customerAddress);

      require( customerBalance > 0, "This address can not claimToken");
      uint256 amount = (customerBalance * 1e18) / ecioPrice;

      IERC20(ecioTokenAddress).transfer(_customerAddress, amount);
  }



}
