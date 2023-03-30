// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Base {
    uint256 immutable private _startTime;
    uint256 immutable private _fullScore;
    uint256 immutable private _baseScore;
    uint256 immutable private _multiplier;

    uint256 private _completeTime;

    constructor (uint256 startTime, uint256 fullScore, uint256 baseScore, uint256 multiplier) {
        require(startTime >= block.timestamp);
        require(fullScore >= baseScore);
        _startTime = startTime;
        _fullScore = fullScore;
        _baseScore = baseScore;
        _multiplier = multiplier;
    }

    function setup() external virtual;

    function getCurrentScore() external view returns (uint256) {
        uint256 score = (block.timestamp - _startTime) * _multiplier;
        return _getScore(score);
    }

    function getFinalScore() external view returns (uint256) {
        require(isSolved(), "Not solved");
        uint256 score = (_completeTime - _startTime) * _multiplier;
        return _getScore(score);
    }

    function solve() external virtual {
        _completeTime = block.timestamp;
    }

    function isSolved() public view returns (bool) {
        return _completeTime != 0;
    }

    function _getScore(uint256 score) internal view returns (uint256) {
        if (_fullScore - _baseScore > score) {
            return _fullScore - score;
        } else {
            return _baseScore;
        }
    }
}