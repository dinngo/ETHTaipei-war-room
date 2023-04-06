// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import {IERC721Receiver} from "openzeppelin-contracts-07/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "openzeppelin-contracts-07/contracts/token/ERC721/IERC721.sol";

contract Pool is IERC721Receiver {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(uint256 => bool)) private _userDeposits;

    address private NFTCollateral;

    constructor(address NFTCollection_) {
        NFTCollateral = NFTCollection_;
    }

    function onERC721Received(address, address from, uint256, bytes memory) external override returns (bytes4) {
        _mint(from, 1);

        return this.onERC721Received.selector;
    }

    function deposit(uint256 tokenId) external returns (uint256 amount) {
        IERC721(NFTCollateral).transferFrom(msg.sender, address(this), tokenId);
        _userDeposits[msg.sender][tokenId] = true;
        amount = _mint(msg.sender, 1 ether);
    }

    function _mint(address account, uint256 amount) internal returns (uint256) {
        _balances[account] += amount;
        return _balances[account];
    }

    function withdraw(uint256 tokenId) external returns (uint256 amount) {
        require(_userDeposits[msg.sender][tokenId], "Should be owner.");
        require(_balances[msg.sender] > 0, "Should have balance.");

        amount = _burn(1 ether, tokenId);
        IERC721(NFTCollateral).safeTransferFrom(address(this), msg.sender, tokenId);
        delete _userDeposits[msg.sender][tokenId];
    }

    function _burn(uint256 amount, uint256 tokenId) internal returns (uint256) {
        require(_userDeposits[msg.sender][tokenId], "Should be owner.");
        _balances[msg.sender] -= amount;
        return _balances[msg.sender];
    }

    function isSolved() public view returns (bool) {
        return _balances[msg.sender] > 1000 ether;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balances[_address];
    }
}
