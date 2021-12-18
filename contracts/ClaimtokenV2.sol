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
  address public presalesAddressV1;
  address public presalesAddressV2;

  uint256 public constant ECIO_PRESALE_PRICE  = 2000000000000000;

  mapping(uint8 => uint16)  public periodPercentages;
  mapping(uint8 => uint256) public periodReleaseTime;

  uint8 public constant PERIOD_1ST  = 1;
  uint8 public constant PERIOD_2ND  = 2;
  uint8 public constant PERIOD_3RD  = 3;
  uint8 public constant PERIOD_4TH  = 4;
  uint8 public constant PERIOD_5TH  = 5;
  uint8 public constant PERIOD_6TH  = 6;

  mapping(address => mapping(uint8 => bool)) public claimRecords;

  constructor() {

      //Initial percentage and release time of each periods.
      periodPercentages[PERIOD_1ST] = 2000;
      periodPercentages[PERIOD_2ND] = 1600;
      periodPercentages[PERIOD_3RD] = 1600;
      periodPercentages[PERIOD_4TH] = 1600;
      periodPercentages[PERIOD_5TH] = 1600;
      periodPercentages[PERIOD_6TH] = 1600;

      periodReleaseTime[PERIOD_1ST] = 1640008800;
      periodReleaseTime[PERIOD_2ND] = 1642687200;
      periodReleaseTime[PERIOD_3RD] = 1645365600;
      periodReleaseTime[PERIOD_4TH] = 1647784800;
      periodReleaseTime[PERIOD_5TH] = 1650463200;
      periodReleaseTime[PERIOD_6TH] = 1653055200;

  }

  event ClaimECIOToken(address indexed user, uint8 indexed period , uint256 amount , uint256 timestamp);

   modifier hasPresaleAuthority(address _address) {
      uint256 balance1 = BalancesChecker(presalesAddressV1).accountBalances(_address);
      uint256 balance2 = BalancesChecker(presalesAddressV2).accountBalances(_address);
      require((balance1+balance2) > 0);
      _;
   }

  function setPeriodReleaseTime(uint8 _periodId, uint256 _releaseTime) public onlyOwner{
      periodReleaseTime[_periodId] = _releaseTime;
  }

  function setECIOTokenAddress(address _address) public onlyOwner{
      ecioTokenAddress = _address;
  }

  function setPresaleAddressV1(address _address) public onlyOwner{
      presalesAddressV1 = _address;
  }

  function setPresaleAddressV2(address _address) public onlyOwner{
      presalesAddressV2 = _address;
  }

  function checkPresale(address presalesAddr, address _customerAddress) external view returns (uint256) {
        return BalancesChecker(presalesAddr).accountBalances(_customerAddress);
  }

  function ecioAmountByPeriod(address _address, uint8 _periodId) public view returns (uint256)  {

       //Get BUSD amount which user use to buy presale.
       uint256 balance1 = BalancesChecker(presalesAddressV1).accountBalances(_address);
       uint256 balance2 = BalancesChecker(presalesAddressV2).accountBalances(_address);
       require( (balance1 + balance2) > 0, "This address can not claimToken");


       //If user is claimed this func will return 0
       if(claimRecords[_address][_periodId]){
           return 0;
       }

      //Calculate amount of ECIO by calculateECIOPerPeriod function
      return calculateECIOPerPeriod(_address, _periodId);

  }

  function calculateECIOPerPeriod(address _address, uint8 _periodId) internal view returns (uint256) {

      //Get BUSD amount which user bought at presale.
     uint256 balance1 = BalancesChecker(presalesAddressV1).accountBalances(_address);
     uint256 balance2 = BalancesChecker(presalesAddressV2).accountBalances(_address);

      //Calculate BUSD token from percentage of the period
      uint256 busdAmountPerPeriod = ((balance1 + balance2) * periodPercentages[_periodId]) / 10000;

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


      emit ClaimECIOToken(msg.sender, _periodId, ecioAmount, block.timestamp);
  }

  function checkIsAvailable(uint8 _periodId) public view returns (bool) {
        if( block.timestamp >= periodReleaseTime[_periodId] ) {
          return true;
        } else {
          return false;
        }
    }

   /**
    * @dev Transfer is function to transfer token from contract to other account.
   */
   function transfer(address _contractAddress, address  _to, uint _amount) public onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
   }

}
