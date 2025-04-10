// SPDX-License-Identifier: BSD 3-Clause License
pragma solidity ^0.8.28;

abstract contract Modifiers {
    error NotAdmin();
    error UserNotRegistered();

    modifier onlyAdmin(address admin) {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    modifier isRegisteredUser(bool user) {
        if (!user) revert UserNotRegistered();
        _;
    }
}
