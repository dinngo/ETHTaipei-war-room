// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Base {
    uint256 immutable private _startTime;
    uint256 immutable private _endTime;
    uint256 immutable private _fullScore;

    uint256 private _completeTime;

    constructor (uint256 startTime, uint256 endTime, uint256 fullScore) {
        require(startTime >= block.timestamp);
        require(endTime >= startTime);
        _startTime = startTime;
        _endTime = endTime;
        _fullScore = fullScore;
    }

    function setup() external virtual;

    function getCurrentScore() external view returns (uint256) {
        return _getScore(block.timestamp);
    }

    function getFinalScore() external view returns (uint256) {
        if (isSolved()) {
            return _getScore(_completeTime);
        } else {
            return 0;
        }
    }

    function solve() public virtual {
        _completeTime = block.timestamp;
    }

    function isSolved() public view returns (bool) {
        return _completeTime != 0;
    }

    function _getScore(uint256 timestamp) internal view returns (uint256) {
        if (timestamp > _startTime) {
            return _fullScore - (block.timestamp - _startTime);
        } else if (timestamp > _endTime) {
            return 0;
        } else {
            return _fullScore;
        }
    }
}