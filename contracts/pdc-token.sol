// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Payda Classic Token (PDC)
 * @dev BEP-20 Token with additional features: fee delegation, owner transfer, and fee payer management.
 * Built for the Binance Smart Chain (BSC).
 */
contract PaydaClassicToken {
    string public name = "PAYDA CLASSIC";
    string public symbol = "PDC";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;
    address public feePayer;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FeePayerChanged(address indexed previousFeePayer, address indexed newFeePayer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyFeePayer() {
        require(msg.sender == feePayer, "Not the fee payer");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        feePayer = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Cannot approve zero address");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    // Internal transfer function
    function _transfer(address _from, address _to, uint256 _value) internal {
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    // Change token owner
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    // Change fee payer address
    function setFeePayer(address _newFeePayer) public onlyOwner {
        require(_newFeePayer != address(0), "New fee payer is zero address");
        emit FeePayerChanged(feePayer, _newFeePayer);
        feePayer = _newFeePayer;
    }

    // Fee delegated transfer
    function delegatedTransfer(address _from, address _to, uint256 _value) public onlyFeePayer returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        _transfer(_from, _to, _value);
        return true;
    }
}
