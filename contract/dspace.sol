pragma solidity ^0.4.18;

contract DSpace {
    uint public x = 0;
    
    function setX(uint _x) public {
        x = _x;
    }
}
