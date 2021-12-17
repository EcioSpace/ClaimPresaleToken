// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vesting is ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public token;

    uint256 public totalMultiple;
    VestingParams[] public vestingParams;
    mapping(address => VestingInfo) private _userToVesting;

    struct VestingParams {
        uint256 multiple;
        uint256 duration;
    }

    struct VestingInfo {
        uint256 amount;
        uint256 claimed;
        uint256 startBlock;
        bool exist;
    }

    event AddVesting(
      address _user,
      uint256 _amount,
      uint256 _startBlock
    );

    event ClaimVesting(
      address _user,
      uint256 _amount
    );



    constructor(
        address _token,
        uint256[] memory _duration,
        uint256[] memory _multiple
    ) public {
        require(_token != address(0), "Vesting: Invalid token address");
        token = IERC20(_token);

        require(
            _duration.length == _multiple.length,
            "Vesting: Duration and multiple are not match"
        );

        for (uint256 i = 0; i < _duration.length; i++) {
            totalMultiple = totalMultiple + _multiple[i];
            vestingParams.push(VestingParams(_multiple[i], _duration[i]));
        }

    }

    function addVesting(address _user, uint256 _amount) external  {
        require(_amount > 0, "Vesting: invalid amount");
        require(_userToVesting[_user].exist == false, "Vesting: already exist");

        token.safeTransferFrom(msg.sender, address(this), _amount);

        VestingInfo memory info = VestingInfo(_amount, 0, block.number, true);
        _userToVesting[_user] = info;

        emit AddVesting(_user, _amount, block.number);
    }

    function claimVesting() external nonReentrant {
        uint256 claimableAmount = _getVestingClaimableAmount(msg.sender);
        require(claimableAmount > 0, "Vesting: Nothing to claim");

        _userToVesting[msg.sender].claimed = _userToVesting[msg.sender].claimed + claimableAmount;

        token.safeTransfer(msg.sender, claimableAmount);

        emit ClaimVesting(msg.sender, claimableAmount);
    }

    function _getVestingClaimableAmount(address _user)
        internal
        view
        returns (uint256 claimableAmount)
    {
        VestingInfo memory info = _userToVesting[_user];

        uint256 passBlocks = block.number - info.startBlock;

        uint256 totalUnlock = 0;

        for (uint256 i = 0; i < vestingParams.length; i++) {
            if (passBlocks > vestingParams[i].duration) {
                passBlocks = passBlocks - vestingParams[i].duration;
                totalUnlock = totalUnlock + info.amount * vestingParams[i].multiple;
            }
        }

        totalUnlock = totalUnlock / totalMultiple;

        return totalUnlock - info.claimed;
    }

    function getVestingClaimableAmount(address _user) external view returns (uint256) {
        return _getVestingClaimableAmount(_user);
    }

    function getVestingInfo(address _user) external view returns (VestingInfo memory) {
        VestingInfo memory info = _userToVesting[_user];
        return info;
    }

    function getVestingParams() public view returns (VestingParams[] memory) {
        return vestingParams;
    }
}
