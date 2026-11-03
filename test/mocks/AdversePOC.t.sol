// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.35;
import "forge-std/Test.sol";
enum Side { LONG, SHORT }
contract AdverseInversionPOC is Test {
    function buggy(Side s,bool c,uint p,uint conf) internal pure returns(uint){
        uint sh=(conf*2000)/10000;
        bool up=s==Side.SHORT?!c:c;
        return up?p+sh:p-sh;
    }
    function fixed(Side s,bool c,uint p,uint conf) internal pure returns(uint){
        uint sh=(conf*2000)/10000;
        bool up=s==Side.LONG?!c:c;
        return up?p+sh:p-sh;
    }
    function test_bug() public {
        uint price=100e8; uint conf=0.1e8;
        uint bOpen=buggy(Side.LONG,false,price,conf);
        uint fOpen=fixed(Side.LONG,false,price,conf);
        emit log_named_uint("Buggy LONG open (should be <100)", bOpen);
        emit log_named_uint("Fixed LONG open (should be >100)", fOpen);
        assertLt(bOpen, price);
        assertGt(fOpen, price);
    }
}