// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

import "./SavingsGroupsWithRewards.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Main {

    address public immutable devFund;
    uint256 public fee = 5;
    
    event RoundCreated(SavingsGroupsWithRewards childRound);

    constructor(address _devFund) public {
        require(_devFund != address(0), "Invalid dev fund address");
        devFund = _devFund;
    }

    function createRound(   
        uint256 _warranty,
        uint256 _saving,
        uint256 _groupSize,
        uint256 _adminFee,
        uint256 _payTime,
        ERC20 _token
    ) external payable returns(address) {
        SavingsGroupsWithRewards newRound = new SavingsGroupsWithRewards(   
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

    function setDevFundAddress (address _devFund) public {
        require(msg.sender == devFund, "Only the dev fund can set the address");
        devFund = _devFund;
    }

    function setFee (uint256 _fee) public {
        require(msg.sender == devFund, "Only the dev fund can set the fee");
        fee = _fee;
    }

}