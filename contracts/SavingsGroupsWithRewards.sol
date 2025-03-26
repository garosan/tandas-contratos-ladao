// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SavingsGroup.sol"; // The base contract (which includes all saving logic)
import "./RewardsVault.sol"; // The vault contract for rewards distribution
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title SavingsGroupsWithRewards
 * @notice Extends the base SavingsGroup contract and integrates an automatically deployed
 * RewardsVault instance. This vault holds reward tokens (in this case $XOC) and, when the round
 * ends, distributes its entire balance among participants according to their payout order.
 *
 * Note: Since we no longer use the BLX token, we pass a dummy value for that parameter in the base constructor.
 */
contract SavingsGroupsWithRewards is SavingGroups {
    RewardsVault public rewardsVault;
    // The token used in the group (in this case, $XOC) is also the reward token.
    address public rewardToken;

    /**
     * @notice Constructor.
     * @param _cashIn Amount required to join the group.
     * @param _saveAmount Payment per round.
     * @param _groupSize Total number of participants.
     * @param _admin Admin address.
     * @param _adminFee Fee charged by the admin (in percentage).
     * @param _payTime Payment period in days.
     * @param _token The ERC20 token used in the group (here, $XOC).
     * @param _devFund Address for the developer fund.
     * @param _fee Additional fee value.
     */
    constructor(
        uint256 _cashIn,
        uint256 _saveAmount,
        uint256 _groupSize,
        address _admin,
        uint256 _adminFee,
        uint256 _payTime,
        IERC20Metadata _token,
        address _devFund,
        uint256 _fee
    )
        SavingGroups(
            _cashIn,
            _saveAmount,
            _groupSize,
            _admin,
            _adminFee,
            _payTime,
            _token,
            _devFund,
            _fee
        )
    {
        rewardToken = address(_token);
        // Deploy a new vault for this group.
        rewardsVault = new RewardsVault();
    }
    
    /**
     * @notice Override endRound to finalize the round without BLX rewards and automatically trigger
     * reward distribution from the group's dedicated vault.
     */
    function endRound() public override atStage(Stages.Save) {
        require(getRealTurn() > groupSize, "Round not yet completed");
        
        // Finalize the round by advancing remaining turns.
        for (uint8 turno = turn; turno <= groupSize; turno++) {
            _completeSavingsAndAdvanceTurn(turno);
        }
        
        uint256 sumAvailableCashIn = 0;
        for (uint8 i = 0; i < groupSize; i++) {
            address userAddr = addressOrderList[i];
            if (users[userAddr].availableSavings >= users[userAddr].owedTotalCashIn) {
                payLateFromSavings(userAddr);
            }
            sumAvailableCashIn += users[userAddr].availableCashIn;
        }
        
        if (!outOfFunds) {
            uint256 totalAdminFee = 0;
            for (uint8 i = 0; i < groupSize; i++) {
                address userAddr = addressOrderList[i];
                uint256 cashInReturn = (users[userAddr].availableCashIn * totalCashIn) / sumAvailableCashIn;
                // Reset available cash and mark user as inactive.
                users[userAddr].availableCashIn = 0;
                users[userAddr].isActive = false;
                uint256 amountTempAdmin = (cashInReturn * adminFee) / 100;
                totalAdminFee += amountTempAdmin;
                // Calculate what the user receives.
                uint256 amountTempUsr = cashInReturn - amountTempAdmin + users[userAddr].availableSavings;
                users[userAddr].availableSavings = 0;
                transferTo(userAddr, amountTempUsr);
                emit EndRound(address(this), startTime, block.timestamp);
            }
            transferTo(admin, totalAdminFee);
            stage = Stages.Finished;
        } else {
            for (uint8 i = 0; i < groupSize; i++) {
                address userAddr = addressOrderList[i];
                uint256 amountTemp = users[userAddr].availableSavings + ((users[userAddr].availableCashIn * totalCashIn) / sumAvailableCashIn);
                users[userAddr].availableSavings = 0;
                users[userAddr].availableCashIn = 0;
                users[userAddr].isActive = false;
                amountTemp = 0;
            }
            stage = Stages.Emergency;
        }
        
        // Once the round is properly finished, trigger reward distribution from this group's vault.
        if (stage == Stages.Finished) {
            // The vault will distribute all tokens (of type rewardToken, i.e. $XOC) it holds among participants.
            rewardsVault.distributeRewards(rewardToken, addressOrderList);
        }
    }

}