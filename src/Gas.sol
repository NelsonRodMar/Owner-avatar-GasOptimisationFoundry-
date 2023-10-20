// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;


contract GasContract {

    address public contractOwner;
    mapping(address => uint256) public balances;
    /* 
        tried to make whitelist a uint8 since the value will be <= 3
        but somehow my method is more expensive in gas...
    */
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    
    
    struct ImportantStruct {
        uint256 amount;
        bool paymentStatus;
    }
    mapping(address => ImportantStruct) public whiteListStruct;

    // I tried to convert this 'tier' to a uint8 since it has to be <255, 
    // forcing a type conversion in 'addToWhitelist', but won't work with the unit tests
    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        address senderOfTx = msg.sender;
        if (senderOfTx == contractOwner) {
            _;
        } else {
            revert(
                ""
            );
        }
    }

    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;

        for (uint8 i = 0; i < _admins.length; i++) {
            administrators[i] = _admins[i];             
        }
        balances[contractOwner] = _totalSupply;
    }

    // used in the unit tests
    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user]; 
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name // useless but in the signature of the call in the unit test
    ) public {
        address senderOfTx = msg.sender;
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
    }

    // since _tier is supposed to be < 255, can we somehow make it a uint8?
    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdminOrOwner
    {
        // this require is used
        require(
            _tier < 255,
            ""
        );
        /*
            this is somehow more expensive:
            whitelist[_userAddrs] = uint8(_tier) > 3 ? 3 : uint8(_tier);
        */
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        address senderOfTx = msg.sender;
        whiteListStruct[senderOfTx] = ImportantStruct(_amount, true);
        
        balances[senderOfTx] = balances[senderOfTx] - _amount + whitelist[senderOfTx];
        balances[_recipient] = balances[_recipient] + _amount - whitelist[senderOfTx];

        emit WhiteListTransfer(_recipient);
    }

    // used in unit tests
    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }
}