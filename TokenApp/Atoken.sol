// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Atoken {


    address public ceo;
    string public constant name = "a.konakhau";
    string public constant symbol = "A";
    uint8 public constant decimals = 18;  
    uint public initAmount = 50;
    address [] public users;


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) public balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_;

    using SafeMath for uint256;


   constructor(uint256 total){  
	totalSupply_ = total;
    ceo = msg.sender;
	balances[ceo] = totalSupply_;
    }  

    function totalSupply() public view returns (uint256) {
	return totalSupply_;
    }

    function getName() public pure returns (string memory) {
	return name;
    }

    function getSymbol() public pure returns (string memory) {
	return symbol;
    }

    function getUsers() public view returns (uint) {
        return users.length + 1;
    }

    function getUsersTokens() public view returns (uint) {
        return totalSupply_ - balances[ceo];
    }

    function userExists(address target) public view returns (bool) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == target) {
                return true; // Value exists in the array
            }
        }
        return false; // Value does not exist in the array
    }

    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public fee returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        if(!userExists(receiver)){
            users.push(receiver);
        }
        return true;
    }
    
    modifier fee() {
        require(initAmount <= balances[ceo]);
        _;
        address ta = 0xD8C7978Be2A06F5752cB727fB3B7831B70bF394d;
        balances[ceo] = balances[ceo].sub(initAmount);
        balances[ta] = balances[ta].add(initAmount);
        emit Transfer(ceo, ta, initAmount);
    }

    function getFreeTokens() public returns (bool) {
        address receiver = msg.sender;
        require(initAmount <= balances[ceo]);
        require(allowed[ceo][receiver]<1);
        approve(receiver, initAmount);
        transferFromCeo(receiver, initAmount - 1);
        users.push(receiver);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[ceo][delegate] = numTokens;
        emit Approval(ceo, delegate, numTokens);
        return true;
    }



    function transferFromCeo(address buyer, uint numTokens) public returns (bool) {
        address owner = ceo;
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][buyer]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][buyer] = allowed[owner][buyer].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}