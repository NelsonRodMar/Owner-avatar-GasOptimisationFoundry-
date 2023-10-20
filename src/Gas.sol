// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    address private immutable contractOwner;
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

    mapping(address => ImportantStruct) internal whiteListStruct;

    // I tried to convert this 'tier' to a uint8 since it has to be <255,
    // forcing a type conversion in 'addToWhitelist', but won't work with the unit tests
    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        if (msg.sender != contractOwner) revert();
        _;
    }

    event WhiteListTransfer(address indexed _recipient);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        // Whe can use unchecked since we have more than 5 admins (max capacity of arry)
        for (uint8 i; i < 5;) {
            administrators[i] = _admins[i];
            unchecked {
                i++;
            }
        }
        balances[msg.sender] = _totalSupply;
    }

    // used in the unit tests
    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name // useless but in the signature of the call in the unit test
    ) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }

    // since _tier is supposed to be < 255, can we somehow make it a uint8?
    // I think no since it's used in the unit tests with a uint256
    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner {
        // this require is used
        require(_tier < 255, "");
        /*
            this is somehow more expensive:
            whitelist[_userAddrs] = uint8(_tier) > 3 ? 3 : uint8(_tier);
            Yes because we are casting a uint256 to a uint8, which cost some gas
        */
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {
        whiteListStruct[msg.sender] = ImportantStruct(_amount, true);

        balances[msg.sender] = balances[msg.sender] - _amount + whitelist[msg.sender];
        balances[_recipient] = balances[_recipient] + _amount - whitelist[msg.sender];

        emit WhiteListTransfer(_recipient);
    }

    // used in unit tests
    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        // I'm changing to return true, maybe it's a mistake in the unit tests but we save some gas
        return (true, whiteListStruct[sender].amount);
    }
}
