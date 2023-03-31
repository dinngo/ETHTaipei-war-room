// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Arcade is ERC20("prize", "PRIZE"), Ownable {
    address public immutable YOU;

    address public currentPlayer;
    address[] public activePlayers;
    uint256 public numActivePlayers;
    uint256 public lastEarnTimestamp;
    mapping(address player => uint256 points) public scoreboard;

    event PlayerEarned(address indexed player, uint256 currentPoints);
    event PlayerChanged(address indexed oldPlayer, address indexed newPlayer);

    modifier onlyPlayer() {
        require(msg.sender == currentPlayer, "Unauthorized");
        _;
    }

    constructor(address player) {
        YOU = player;
        currentPlayer = player;
    }

    /// @notice Do YOU have 200 PRIZE?
    function pass() external view returns (bool) {
        if (balanceOf(YOU) >= 200 ether) return true;
        return false;
    }

    function getCurrentPlayerPoints() public view returns (uint256) {
        return scoreboard[currentPlayer];
    }

    function isActivePlayer(address player) public view returns (bool) {
        for (uint256 i; i < numActivePlayers; ++i) {
            if (activePlayers[i] == player) {
                return true;
            }
        }
        return false;
    }

    function setScore(address player, uint256 points) external onlyOwner {
        scoreboard[player] = points;
        if (!isActivePlayer(player)) {
            activePlayers.push(player);
            numActivePlayers++;
        }
    }

    /// @notice Earn 10 points at most once per 10 minutes
    function earn() external onlyPlayer {
        address player = msg.sender;
        require(block.timestamp >= lastEarnTimestamp + 10 minutes, "Too frequent");
        scoreboard[player] += 10 ether;
        lastEarnTimestamp = block.timestamp;
        emit PlayerEarned(player, getCurrentPlayerPoints());
    }

    /// @notice Be cautious as you might lose the ability to earn and redeem points afterward
    function changePlayer(address newPlayer) external onlyPlayer {
        address oldPlayer = currentPlayer;
        emit PlayerChanged(_redeem(oldPlayer), _setNewPlayer(newPlayer));
    }

    /// @notice Redeem points for minting PRIZE tokens at 1:1 ratio
    function redeem() external onlyPlayer {
        _redeem(msg.sender);
    }

    function _redeem(address oldPlayer) internal returns (address) {
        uint256 points = getCurrentPlayerPoints();
        _mint(oldPlayer, points);
        delete scoreboard[oldPlayer];

        return oldPlayer;
    }

    function _setNewPlayer(address newPlayer) internal returns (address) {
        currentPlayer = newPlayer;
        return newPlayer;
    }
}
