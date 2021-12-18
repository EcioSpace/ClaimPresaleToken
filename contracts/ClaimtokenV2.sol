// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//    ########    #####     ##     #####
//    ##         ##    ##   ##   ##     ##
//    ##        ##          ##  ##       ##
//    ########  ##          ##  ##  ^_^  ##
//    ##        ##          ##  ##       ##
//    ##         ##    ##   ##   ##     ##
//    ########    #####     ##     #####

/// @author ECIO Engineering Team
/// @title Claimtoken Smart Contract

interface BalancesChecker {
    function accountBalances(address _address) external view returns (uint);
}

contract ClaimtokenV2 is Ownable {

  //ECIO token address.
  address public ecioTokenAddress;

  //Presales Address
  address public presalesAddress;

  uint256 public constant ECIO_PRESALE_PRICE  = 2000000000000000;

  mapping(uint8 => uint8) periodPercentages;
  mapping(uint8 => uint256) periodReleaseTime;

  uint8 public constant PERIOD_1ST  = 1;
  uint8 public constant PERIOD_2ND  = 2;
  uint8 public constant PERIOD_3RD  = 3;
  uint8 public constant PERIOD_4TH  = 4;
  uint8 public constant PERIOD_5TH  = 5;
  uint8 public constant PERIOD_6TH  = 6;

  mapping(address => mapping(uint8 => bool)) claimRecords;

  constructor() {

      //Initial percentage and release time of each periods.
      periodPercentages[PERIOD_1ST] = 20;
      periodPercentages[PERIOD_2ND] = 16;
      periodPercentages[PERIOD_3RD] = 16;
      periodPercentages[PERIOD_4TH] = 16;
      periodPercentages[PERIOD_5TH] = 16;
      periodPercentages[PERIOD_6TH] = 16;

      periodReleaseTime[PERIOD_1ST] = 1640008800;
      periodReleaseTime[PERIOD_2ND] = 1642687200;
      periodReleaseTime[PERIOD_3RD] = 1645365600;
      periodReleaseTime[PERIOD_4TH] = 1647784800;
      periodReleaseTime[PERIOD_5TH] = 1650463200;
      periodReleaseTime[PERIOD_6TH] = 1653055200;

  }

   modifier hasPresaleAuthority(address _address) {
      uint256 balance = BalancesChecker(presalesAddress).accountBalances(_address);
      require(balance > 0);
      _;
   }

  function setPeriodReleaseTime(uint8 _periodId, uint256 _releaseTime) public onlyOwner{
      periodReleaseTime[_periodId] = _releaseTime;
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

  function ecioAmountByPeriod(address _address, uint8 _periodId) public view returns (uint256)  {

       //Get BUSD amount which user use to buy presale.
       uint256 customerBalance = BalancesChecker(presalesAddress).accountBalances(_address);
       require( customerBalance > 0, "This address can not claimToken");


       //If user is claimed this func will return 0
       if(claimRecords[_address][_periodId]){
           return 0;
       }

      //Calculate amount of ECIO by calculateECIOPerPeriod function
      return calculateECIOPerPeriod(_address, _periodId);

  }

  function calculateECIOPerPeriod(address _address, uint8 _periodId) internal view returns (uint256) {

      //Get BUSD amount which user bought at presale.
      uint256 customerBalance = BalancesChecker(presalesAddress).accountBalances(_address);

      //Calculate BUSD token from percentage of the period
      uint256 busdAmountPerPeriod = (customerBalance * periodPercentages[_periodId]) / 100;

     //Calculate ECIO token from using BUSD amount of this period devided by ECIO presale price.
      return (busdAmountPerPeriod / ECIO_PRESALE_PRICE) * 10**18;

  }


  function claimECIOToken(uint8 _periodId) public hasPresaleAuthority(msg.sender) {
      // compare now with periodReleaseTime[_periodId]
      require( block.timestamp >= periodReleaseTime[_periodId], "Your time has not come" );

    //Verify
    require(!claimRecords[msg.sender][_periodId], "This period is claimed.");


     //Calculate ECIO token for this period
      uint256 ecioAmount = calculateECIOPerPeriod(msg.sender, _periodId);

      //Transfer ECIO Token in this contract to sender
      IERC20(ecioTokenAddress).transfer(msg.sender, ecioAmount);

      //Set flag that this user is claimed
      claimRecords[msg.sender][_periodId] = true;
  }

  function checkIsAvailable(uint8 _periodId) public view returns (bool) {
        if( block.timestamp >= periodReleaseTime[_periodId] ) {
          return true;
        } else {
          return false;
        }
    }

}
