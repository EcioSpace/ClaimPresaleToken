// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @author ECIO Engineering Team
/// @title Pre-Sale Smart Contract
contract PresaleMockup is Ownable {


//maximum BUSD per account.
uint256 private constant MAXIMUM_BUSD_PER_ACCOUNT  = 200000000000000000000;

mapping(address => uint) public accountBalances;

function setMockupBalance(address _address, uint _balance) public  {

    require (_balance <= MAXIMUM_BUSD_PER_ACCOUNT, 'Token: Maximum is 200 BUSD');
    accountBalances[_address] = _balance;

 }

 function tokenAvailableForBuying(address _account) private view returns(uint) {
     return MAXIMUM_BUSD_PER_ACCOUNT - accountBalances[_account];
 }



}
