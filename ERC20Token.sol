// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

abstract contract ERC20_token {

    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);

    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownership {

    address public contractOwner;
    address public newOwner;

    constructor () {
        contractOwner = msg.sender;
    }

    event TransferOwner(address indexed _from, address indexed _to);

    function changeOwner(address _to) public {
        require(msg.sender == contractOwner,"Only owner can give ownership");
        newOwner = _to;
    }

    function approveOwner () public {
        require(newOwner == msg.sender,"Only new owner can call this function");
        emit TransferOwner(contractOwner,newOwner);
        contractOwner = newOwner;
        newOwner = address(0);
    }
}


contract MyERC20 is Ownership, ERC20_token {

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) totalBalance;
    mapping( address => mapping(address => uint256)) allowed;

    address public _minter;

    constructor (address minter_) {
        _name = "Rocky coin";
        _symbol = "ROC";
        _totalSupply = 1000000;
        _minter = minter_;

        totalBalance[_minter] = _totalSupply;
    }

    function name() public view override returns (string memory){
        return _name;
    }
    function symbol() public view override returns (string memory){
        return _symbol;
    }
    function decimals() public view override returns (uint8){
        return _decimals;
    }
    function totalSupply() public view override returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view override returns (uint256 balance){
        return totalBalance[_owner];
    }


    function transfer(address _to, uint256 _value) public override returns (bool success){

        require(totalBalance[msg.sender] >= _value, "Insufficient Balance");
        totalBalance[msg.sender] -= _value;
        totalBalance[_to] += _value;
        emit Transfer(msg.sender , _to , _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        uint256 allowedvalue = allowed[_from][msg.sender];
        require(allowedvalue >= _value, "Insufficient Balance");
        totalBalance[_from] -= _value;
        totalBalance[_to] += _value;

        emit Transfer( _from, _to, _value);
        return true;
    }
 

    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(totalBalance[msg.sender] >= _value,"Insufficient balance");
        allowed[msg.sender][_spender] = _value;
        emit Approval( msg.sender ,_spender,_value);
        return true;
    }


    function allowance(address _owner, address _spender) public view override returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
}