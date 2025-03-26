// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/ISavingGroupsCore.sol";
import "./Modifiers.sol";
import "./SavingGroupsPayments.sol";
import "./SavingGroupsAdmin.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SavingGroupsCore is ISavingGroupsCore, Initializable {
    enum Stages {
        Setup,
        Save,
        Finished,
        Emergency
    }

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

    mapping(address => User) public users;
    uint256 public usersCounter;
    uint8 public turn;
    uint256 public startTime;
    address[] public addressOrderList;
    Stages public stage;
    bool public outOfFunds = false;

    SavingGroupsPayments public payments;
    SavingGroupsAdmin public admin;

    event RoundCreated(uint256 indexed saveAmount, uint256 indexed groupSize);
    event RegisterUser(address indexed user, uint8 indexed turn);
    event RemoveUser(address indexed removedBy, address indexed user, uint8 indexed turn);

    function initialize(
        address _paymentsContract,
        address _adminContract
    ) public initializer {
        usersCounter = 0;
        turn = 1;
        stage = Stages.Setup;
        payments = SavingGroupsPayments(_paymentsContract);
        admin = SavingGroupsAdmin(_adminContract);
    }

    // Core functions for user management and state
    function registerUser(uint8 _userTurn) external atStage(Stages.Setup) {
        // ... (mantener lógica de registro)
    }

    function removeUser(uint8 _userTurn) external atStage(Stages.Setup) {
        // ... (mantener lógica de eliminación)
    }

    // ... otros getters y funciones de estado
} 