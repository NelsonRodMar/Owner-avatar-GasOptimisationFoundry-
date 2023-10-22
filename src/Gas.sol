// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract GasContract {
    uint256 whiteListAmount;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        balances[msg.sender] = 1000000000;
        administrators[0] = address(0x3243Ed9fdCDE2345890DDEAf6b083CA4cF0F68f2);
        administrators[1] = address(0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46);
        administrators[2] = address(0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf);
        administrators[3] = address(0xeadb3d065f8d15cc05e92594523516aD36d1c834);
        administrators[4] = msg.sender;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        require(msg.sender == address(0x1234));
        require(_tier < 255);
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function balanceOf(address _user) public pure returns (uint256) {
        return 10;
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) public returns (bool) {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        return true;
    }

    function whiteTransfer(address _recipient, uint256 _amount) public 
    {
        whiteListAmount = _amount;
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount; 
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {        
        return (true, whiteListAmount);
    }
}