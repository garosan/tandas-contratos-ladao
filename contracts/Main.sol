// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./SavingGroups.sol";

contract Main {
    // TODO: Check if devFund needs to be immutable or not
    address public devFund;
    uint256 public fee = 5;

    event RoundCreated(SavingGroups childRound);

    constructor(address _devFund) {
        require(_devFund != address(0), "Invalid dev fund address");
        devFund = _devFund;
    }

    function createRound(
        uint256 _warranty,
        uint256 _saving,
        uint256 _groupSize,
        uint256 _adminFee,
        uint256 _payTime,
        IERC20Metadata _token
    ) external payable returns (address) {
        SavingGroups newRound = new SavingGroups(
            _warranty,
            _saving,
            _groupSize,
            msg.sender,
            _adminFee,
            _payTime,
            _token,
            devFund,
            fee
        );
        emit RoundCreated(newRound);
        return address(newRound);
    }

    function setDevFundAddress(address _devFund) public {
        require(msg.sender == devFund, "Only the dev fund can set the address");
        devFund = _devFund;
    }

    function setFee(uint256 _fee) public {
        require(msg.sender == devFund, "Only the dev fund can set the fee");
        fee = _fee;
    }
}
