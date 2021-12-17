// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @author ECIO Engineering Team
/// @title Pre-Sale Smart Contract
contract PresaleMockup is Ownable {
    
 mapping(address => uint) public accountBalances;

 function setMockupBalance(address _address, uint _balance) public  {
     accountBalances[_address] = _balance;
 }

}