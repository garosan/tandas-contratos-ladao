// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

import "./SavingGroupsCore.sol";

contract SavingGroupsAdmin {
    SavingGroupsCore public core;
    address public admin;
    address public devFund;
    uint256 public adminFee;
    uint256 public groupSize;
    uint256 public payTime;

    // Constantes
    uint256 public constant MAX_GROUP_SIZE = 12;
    uint256 public constant MIN_AMOUNT = 5 * 10**18;
    uint256 public constant MAX_ADMIN_FEE = 100;

    event EndRound(address indexed roundAddress, uint256 indexed startAt, uint256 indexed endAt);
    event EmergencyWithdraw(address indexed roundAddress, uint256 indexed funds);

    constructor(
        address _core,
        address _admin,
        address _devFund,
        uint256 _adminFee,
        uint256 _groupSize,
        uint256 _payTime
    ) {
        core = SavingGroupsCore(_core);
        admin = _admin;
        devFund = _devFund;
        adminFee = _adminFee;
        groupSize = _groupSize;
        payTime = _payTime * 86400;
    }

    function startRound() external {
        // ... (mover lógica de inicio aquí)
    }

    function endRound() external {
        // ... (mover lógica de finalización aquí)
    }

    function emergencyWithdraw() external {
        // ... (mover lógica de emergencia aquí)
    }
} 