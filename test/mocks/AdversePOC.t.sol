// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;
import "forge-std/Test.sol";

enum Side { LONG, SHORT }

contract AdversePOC is Test {
    function buggy_adverse(Side side, bool isClose, uint256 price, uint256 conf) internal pure returns (uint256) {
        uint256 shift = (conf * 2000) / 10000;
        bool adverseUp = side == Side.SHORT ? !isClose : isClose;
        return adverseUp ? price + shift : price - shift;
    }

    function test_adverseInversion() public {
        uint256 price = 100e8;
        uint256 conf = 1e7; // 0.1e8
        uint256 shift = (conf * 2000) / 10000; // 2000000

        uint256 longOpenBuggy = buggy_adverse(Side.LONG, false, price, conf);
        // LONG open should be adverse UP = price+shift = 10002e6
        // Buggy gives price-shift = 9998e6
        
        emit log_named_uint("Price", price);
        emit log_named_uint("Shift", shift);
        emit log_named_uint("Buggy LONG open", longOpenBuggy);
        emit log_named_uint("Expected LONG open (adverse)", price + shift);

        assertLt(longOpenBuggy, price, "BUG CONFIRMED: LONG open favorable not adverse");
        
        uint256 longCloseBuggy = buggy_adverse(Side.LONG, true, price, conf);
        emit log_named_uint("Buggy LONG close", longCloseBuggy);
        
        int256 roundtrip = int256(longCloseBuggy) - int256(longOpenBuggy);
        emit log_named_int("Risk-free PnL per unit", roundtrip);
        assertGt(roundtrip, 0, "BUG: 4 bps risk-free profit");
    }
}