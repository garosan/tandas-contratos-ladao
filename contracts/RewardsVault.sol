// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";
/**
 * @title RewardsVault
 * @notice This vault accepts deposits of any ERC20 token (e.g. $OP, WETH, or in our case $XOC)
 * and allows an authorized caller (the vault admin) to distribute all tokens held in the vault
 * to a list of participants. Distribution is based on a weight that increases with the participant’s
 * position in the payout order.
 */
contract RewardsVault {
    using SafeERC20 for IERC20;

    // Mapping to track the total tokens held in the vault per token address.
    mapping(address => uint256) public vaultBalances;
    
    // The admin address that is allowed to trigger distribution.
    // In our use case, the SavingsGroupWithRewards contract becomes the vault admin.
    address public admin;

    event Deposited(address indexed token, address indexed from, uint256 amount);
    event RewardsDistributed(address indexed token, uint256 totalReward);

    /**
     * @notice Constructor sets the vault admin to the contract that deploys this vault.
     */
    constructor() {
        console.log("RewardsVault constructor", msg.sender);
        console.log("RewardsVault Contract", address(this));
        admin = msg.sender;
    }
    
    /**
     * @notice Deposit tokens into the vault.
     * @param token The ERC20 token address.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        vaultBalances[token] += amount;
        emit Deposited(token, msg.sender, amount);
    }
    
    /**
     * @notice Distribute all tokens held in the vault for a given token to participants.
     * Each participant’s weight is their 1-indexed position in the array (so later positions earn more).
     * @param token The ERC20 token address for rewards.
     * @param participants An array of participant addresses in the order they received their payout.
     */
    function distributeRewards(address token, address[] calldata participants) external {
        require(msg.sender == admin, "Only admin can distribute rewards");
        uint256 totalReward = vaultBalances[token];
        require(totalReward > 0, "No rewards available for this token");
        require(participants.length > 0, "No participants provided");

        // Calculate the total weight (sum of 1, 2, ... n).
        uint256 totalWeight = 0;
        uint256 len = participants.length;
        for (uint256 i = 0; i < len; i++) {
            totalWeight += (i + 1);
        }
        
        // Distribute rewards proportionally based on each participant's weight.
        for (uint256 i = 0; i < len; i++) {
            uint256 weight = i + 1;
            uint256 share = (totalReward * weight) / totalWeight;
            IERC20(token).safeTransfer(participants[i], share);
        }
        
        // Reset the vault balance for this token.
        vaultBalances[token] = 0;
        emit RewardsDistributed(token, totalReward);
    }
}
