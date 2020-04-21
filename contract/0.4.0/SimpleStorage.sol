pragma solidity >=0.4.16 <0.7.0;

/***
    允许任何人在合约中存储一个单独的数字，并且这个数字可以被世界上任何人访问。
 */
contract SimpleStorage {
    //uint（256位无符号整数），状态变量
    uint storedData;

    // 变更
    function set(uint x) public {
        storedData = x;
    }

    // 取值
    function get() public view returns (uint) {
        return storedData;
    }
}
