// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

interface ISavingGroupsCore {
    enum Stages { Setup, Save, Finished, Emergency }
    
    struct User {
        address userAddr;
        uint8 userTurn;
        uint256 availableCashIn;
        uint256 availableSavings;
        uint256 assignedPayments;
        uint256 unassignedPayments;
        uint8 latePayments;
        uint256 owedTotalCashIn;
        bool isActive;
        uint256 withdrewAmount;
    }

    function registerUser(uint8 _userTurn) external;
    function removeUser(uint8 _userTurn) external;
    // ... otros métodos
} 