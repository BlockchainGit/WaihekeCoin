pragma solidity ^0.4.23;

/**
 * The Locality Coin
 * 
 * Created by Warwick Allen, May 2018
 * Licenced under GPL3.0
 * Some code portions borrowed from https://www.ethereum.org/token.
 * 
 */

/**
 * Overflow-Proof Arithmetic
 * 
 * Safegaurd against overflow errors.
 */
library OverflowProofArithmetic192 {
    function add(uint192 a, uint192 b) internal pure returns (uint192 c) {
        c = a + b;
        assert(c >= a && c >= b, "Overflow detected in addition");
    }
    function sub(uint192 a, uint192 b) internal pure returns (uint192 c) {
        require(b <= a, "Subtraction will result in a negative value");
        c = a - b;
        assert(c <= a, "Overflow detected in subtraction");
    }
    function mul(uint192 a, uint192 b) internal pure returns (uint192 c) {
        c = a * b;
        assert(c >= a && c >= b, "Overflow detected in multiplication");
    }
    function div(uint192 a, uint192 b) internal pure returns (uint192 c) {
        require(b > 0, "Divide by zero error");
        c = a / b;
        assert(c <= a, "Overflow detected in division");
    }
}

/**
 * ERC Token Standard #20 Interface
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Token {
    uint public constant totalSupply;

    function balanceOf(address tokenOwner) public constant
        returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant
        returns (uint remaining);
    function transfer(address to, uint tokens) public
        returns (bool success);
    function approve(address spender, uint tokens) public
        returns (bool success);
    function transferFrom(address from, address to, uint tokens) public
        returns (bool success);

    event Transfer(
        address indexed from,
        address indexed to,
        uint value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint value
    );
}

contract Owned {
    address public owner;
    address public ownerChangeRequest = 0x0;

    modifier onlyOwner() {
    require(
            msg.sender == owner,
            "Only the owner can run this function"
        );
        _;
    }

    function requestOwnerChange(address _newOwner)
    onlyOwner
    public
    returns (bool success) {
        ownerChangeRequest = _newOwner;
        return true;
    }

    function acceptOwnerChange()
    public
    returns (bool success) {
        require(
            ownerChangeRequest != 0x0,
            "Cannot change the owner to 0x0"
        );
        require(
            msg.sender == ownerChangeRequest,
            "This address has not been nominated to be the new owner"
        );
        owner = ownerChangeRequest;
        ownerChangeRequest = 0x0;
        return true;
    }
}

contract Suspendable is Owned {
    /**
     * Modify functions to be "onlyWhenActive" to prevent them from being
     * executed when the contract has been suspended.
     */
    bool public suspended = false;

    modifier onlyWhenActive() {
        // The owner can still run functions when the token is suspended.
        require(
            !suspended || msg.sender == owner,
            "This token is currently disabled"
        );
        _;
    }

    /**
     * Suspend the contract if there is some problem.
     */
    function suspend()
    onlyOwner
    public
    {
        suspended = true;
    }

    /**
     * Re-enable the contract if it has been suspended.
     */
    function enable()
    onlyOwner
    public
    {
        suspended = false;
    }
}

contract Attributable is Owned {
    mapping (string => string) public attributes;

    /**
     * Attribute getter function
     * 
     * Get the value of the `_attrName` attribute.
     * 
     * @param _attrName The name of the attribute
     */
    function getAttribute(string _attrName)
    view
    public
    returns (string attrValue) {
        return attributes[_attrName];
    }

    /**
     * Attribute setter function
     * 
     * Set the value of the `_attrName` attribute to `_attrValue`.  This can only
     * by done by the contract owner.
     * 
     * @param _attrName The name of the attribute
     * @param _attrValue The value of the attribute
     */
    function setAttribute(string _attrName, string _attrValue)
    onlyOwner
    public
    returns (bool success) {
        attributes[_attrName] = _attrValue;
        return true;
    }
}

interface localityCoinRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    ) external;
}

contract LocalityCoin is ERC20Token, Owned, Suspendable, Attributable {
    using OverflowProofArithmetic192 for uint192;

    string public constant about =
        "The Locality Coin exists to promote provences, cities, towns and villages.  It was created by Warwick Allen (warwick.allen@bchain.expert) on 7 May 2018 and is licenced under the GNU GENERAL PUBLIC LICENSE Version 3.0, which can be viewed at https://www.gnu.org/licenses/gpl-3.0.txt.";
    uint8 constant public decimals = 18;        // Minimum divisible unit.
    uint96 constant public totalSupply = -1;    // ~79 billion whole coins.

    string public name;
    string public symbol;
    mapping (address => uint96) public localityCoinBalance;
    mapping (address => mapping (address => uint96)) public allowance;

    // Notify clients of the amount reverted.
    event RevertToContract(
        address indexed from,
        uint256 value
    );

    /**
     * Constructor
     *
     * Initialises the contract by giving all the localcoin to the creator of
     * the contract (i.e., the "owner").
     */
    constructor(
        string _provence,
        string _country,
        string _name,
        string _symbol
    )
    internal
    {
        attributes['Locality'] = _locality;
        attributes['Country'] = _country;
        attributes['Name'] = name = _name;
        attributes['Symbol'] = symbol = _symbol;

        owner = msg.sender;
        localityCoinBalance[this] = totalSupply;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value)
    internal
    {
        require(_to != 0x0, "Cannot transfer to 0x0");
        require(
            localityCoinBalance[_from] >= _value,
            "The sender's localityCoin balance is too low"
        );
        require(
            localityCoinBalance[_to] + _value >= localityCoinBalance[_to],
            "Overflow detected"
        );

        uint256 sumOfStartingBalances =
            localityCoinBalance[_from] + localityCoinBalance[_to];
        localityCoinBalance[_from] -= _value;   // Subtract from the sender
        localityCoinBalance[_to] += _value;     // Add the same to the recipient
        // Sanity check.
        assert(
            localityCoinBalance[_from] + localityCoinBalance[_to] ==
                sumOfStartingBalances
        );
        emit Transfer(_from, _to, _value);
    }

    /**
     * Transfer localitycoin
     *
     * Send `_volume` localitycoin to `_to` from the caller's account.
     *
     * @param _to The address of the recipient
     * @param _volume the amount to send
     */
    function transfer(address _to, uint256 _volume)
    onlyWhenActive
    public
    returns (uint256 volume) {
        _transfer(msg.sender, _to, _volume);
        return _volume;
    }

    /**
     * Transfer localitycoin from another address
     *
     * Send `_volume` localitycoin to `_to` on behalf of `_from`.
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _volume the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _volume)
    onlyWhenActive
    public
    returns (uint192 volume) {
        require(
            _volume <= allowance[_from][msg.sender],
            "The allowance is insufficient for this transfer"
        );
        allowance[_from][msg.sender] -= _volume;
        _transfer(_from, _to, _volume);
        return _volume;
    }

    /**
     * Set allowance for another address
     *
     * Allows `_spender` to spend no more than `_volume` tokens on the caller's
     * behalf.
     *
     * @param _spender The address authorized to spend
     * @param _volume the max amount they can spend
     */
    function approve(address _spender, uint192 _volume)
    onlyWhenActive
    public
    returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_volume` minimum units of
     * localitycoin on the caller's behalf, then pings the contract about it.
     *
     * @param _spender The address authorised to spend
     * @param _volume The max amount they can spend
     * @param _extraData Some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint192 _volume, bytes _extraData)
    onlyWhenActive
    public
    returns (bool success) {
        localityCoinRecipient spender = localityCoinRecipient(_spender);
        if (approve(_spender, _volume)) {
            spender.receiveApproval(msg.sender, _volume, this, _extraData);
            return true;
        }
    }

    /**
     * Send localitycoin to the contract from another account
     *
     * Send `_volume` minimum units of localitycoin on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _volume the amount of localitycoin to revert
     */
    function revertToContractFrom(address _from, uint192 _volume)
    onlyWhenActive
    public
    returns (bool success) {
        _transfer(_from, this, _value);
        emit RevertToContract(_from, _value);
        return true;
    }

    /**
     * Send localitycoin to the contract
     *
     * Returns `_volume` minimum units of localitycoin to the contract.
     *
     * @param _volume the amount of money to revert
     */
    function revertToContract(uint192 _volume)
    onlyWhenActive
    public
    returns (bool success) {
        return revertToContractFrom(msg.sender, _volume);
    }

    /**
     * Get the caller's balance
     * 
     * Returns the number of minimum units of localitycoin owned by the caller.
     */
    function balanceOf()
    view
    public
    returns (uint256) {
        return localityCoinBalance[msg.sender];
    }

    /**
     * Get the contract's balance
     * 
     * Returns the number of minimum units of localitycoin owned by the contract.
     */
    function balanceOfContract()
    view
    public
    returns (uint192 volume) {
        return localityCoinBalance[this];
    }
    
    /**
     * Get the price of localitycoin in ether
     */
    function getPrice()
    view
    public
    returns (uint96 price) {
        return (totalSupply - localityCoinBalance[this]) >> 2;
    }

    /**
     * Get the ether value of a volume of localitycoin
     *
     * Returns the value of wei needed to buy `_volume` minimum units of
     * localitycoin.
     * 
     * @param _volume The amount of localitycoin
     */
    function getValue(uint96 _volume)
    view
    public
    returns (uint192 value) {
        return uint192(getPrice()) * _volume;
    }

    /**
     * Get the volume that can be purchased with some ether value
     *
     * Returns the volume of minimum units of localitycoin that `_value` of wei
     * will buy.
     * 
     * @param _value The amount of wei
     */
    function getBuyVolume(uint192 _value)
    view
    public
    returns (uint96 volume) {
        return _value / getPrice();
    }

    /**
     * Buy localitycoin
     * 
     * Exchange ether for localitycoin.
     */
    function buy()
    payable
    onlyWhenActive
    public
    returns (uint192 volume) {
        volume = getBuyVolume(msg.amount);
        _transfer(this, msg.sender, volume); // from contract to seller
        return volume;
    }

    /**
     * Sell localitycoin
     * 
     * Redeem localitycoin for ether.
     */
    function sell(uint192 _amount)
    onlyWhenActive
    public
    returns (uint192 value){
        _transfer(msg.sender, this, _amount); // from seller to contract
        value = getValue(_amount);
        // Send ether to the seller.  It's important to do this last to prevent
        // recursion attacks.
        msg.sender.transfer(value);
        return value;
    }

    /**
     * Fall-back function to receive ether
     */
    function()
    public
    payable
    { }
}

contract WaihekeCoin is LocalityCoin(
    "Waiheke Island",
    "New Zealand",
    "Waiheke Coin",
    "WAIHK"
) {
    constructor() {
        setAttribute('Symbol Character', '₩');
        setAttribute('Creator', 'Warwick Allen');
        setAttribute('Creator Email', '<warwick.allen@blockchain.expert>');
    }
}
