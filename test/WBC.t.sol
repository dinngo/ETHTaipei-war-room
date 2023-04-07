// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "src/WBC/WBC.sol";
import "src/WBC/Ans.sol";

contract WBCTest is Test {
    WBC public wbc;
    Ans public ans;

    uint256 count;

    function setUp() external {
        wbc = new WBC();
        ans = new Ans{salt: bytes32(uint256(87))}(address(wbc));
    }

    function testSalt() external {
        uint256 salt;

        for (uint256 i = 0; i < 1000; ++i) {
            try new Ans{salt: bytes32(i)}(address(wbc)) returns (Ans) {
                salt = i;
                break;
            } catch {}
        }
        console2.log(salt);
    }

    function testSetup() external {
        assertTrue(true);
    }

    function testWin() external {
        ans.win();
    }

    function testCannotHomeRunEasily() external {
        vm.expectRevert("try again");
        wbc.homerun();
    }

    // function testDecode() external {
    //     bytes32 input = 0x0000000000000000000000000000000000000000000009486974416e6452756e;
    //     string memory result = wbc.decode(input);
    //     console2.log(result);
    //     assertTrue(true);
    // }
}
