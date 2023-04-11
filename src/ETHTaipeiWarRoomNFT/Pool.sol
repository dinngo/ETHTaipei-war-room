// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import {IERC721Receiver} from "openzeppelin-contracts-07/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "openzeppelin-contracts-07/contracts/token/ERC721/IERC721.sol";
import {ERC20} from "openzeppelin-contracts-07/contracts/token/ERC20/ERC20.sol";

contract Pool is ERC20("USD Taipei", "USDT"), IERC721Receiver {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(uint256 => bool)) private _userDeposits;

    address private NFTCollateral;

    constructor(address NFTCollection_) {
        NFTCollateral = NFTCollection_;
    }

    function onERC721Received(address, address, uint256, bytes memory) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function deposit(uint256 tokenId) external {
        IERC721(NFTCollateral).transferFrom(msg.sender, address(this), tokenId);
        _userDeposits[msg.sender][tokenId] = true;
        _balances[msg.sender] += 1 ether;
    }

    function withdraw(uint256 tokenId) external {
        require(_userDeposits[msg.sender][tokenId], "Should be owner.");
        require(_balances[msg.sender] > 0, "Should have balance.");

        IERC721(NFTCollateral).safeTransferFrom(address(this), msg.sender, tokenId);
        _balances[msg.sender] -= 1 ether;
        delete _userDeposits[msg.sender][tokenId];
    }

    function isSolved() public view returns (bool) {
        return _balances[msg.sender] > 1000 ether;
    }
}
