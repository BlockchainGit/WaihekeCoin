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
library OverflowProofArithmetic96 {
    function add(uint96 a, uint96 b) internal pure returns (uint96 c) {
        c = a + b;
        require(c >= a && c >= b, "Overflow detected in addition");
    }
    function subtract(uint96 a, uint96 b) internal pure returns (uint96 c) {
        require(b <= a, "Subtraction will result in a negative value");
        c = a - b;
        require(c <= a, "Overflow detected in subtraction");
    }
    function multiply(uint96 a, uint96 b) internal pure returns (uint96 c) {
        c = a * b;
        require(c >= a && c >= b, "Overflow detected in multiplication");
    }
    function divide(uint96 a, uint96 b) internal pure returns (uint96 c) {
        require(b > 0, "Divide by zero error");
        c = a / b;
        require(c <= a, "Overflow detected in division");
    }
}


/**
 * ERC Token Standard #20 Interface
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Token {
    function totalSupply() public constant
        returns (uint);
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


interface localityCoinRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    ) external;
}


contract LocalityCoin is ERC20Token, Owned, Suspendable {
    using OverflowProofArithmetic96 for uint96;

    string public constant about =
        "The Locality Coin exists to promote provences, cities, towns and villages.  It was created by Warwick Allen (warwick.allen@bchain.expert) on 7 May 2018 and is licenced under the GNU GENERAL PUBLIC LICENSE Version 3.0, which can be viewed at https://www.gnu.org/licenses/gpl-3.0.txt.";
    uint8 constant public decimals = 18;
    uint96 constant public totalWholeUnits   = 7.9228162514e28;
    uint96 constant public totalMinimumUnits = 7.9228162514e10;
    uint96 constant internal creatorFee = 514e18;

    string public locality;
    string public country;
    string public name;
    string public symbol;
    string public symbolCharacter;
    string public creator;
    string public creatorEmail;
    string public blurb;
    string public miscellaneous;

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
        string _locality,
        string _country,
        string _name,
        string _symbol,
        string _symbolCharacter,
        string _creator,
        string _creatorEmail,
        string _blurb,
        string _miscellaneous
    )
    internal
    {
        locality = _locality;
        country = _country;
        name = _name;
        symbol = _symbol;
        symbolCharacter = _symbolCharacter;
        creator = _creator;
        creatorEmail = _creatorEmail;
        blurb = _blurb;
        miscellaneous = _miscellaneous;

        owner = msg.sender;
        localityCoinBalance[owner] = creatorFee;
        localityCoinBalance[this] = totalMinimumUnits.subtract(creatorFee);
    }

    /**
     * Fall-back function to receive ether
     */
    function()
    public
    payable
    { }

    /**
     * Getter functions
     */
    function getLocality() view public returns (string) {
        return locality;
    }
    function getCountry() view public returns (string) {
        return country;
    }
    function getName() view public returns (string) {
        return name;
    }
    function getSymbol() view public returns (string) {
        return symbol;
    }
    function getSymbolCharacter() view public returns (string) {
        return symbolCharacter;
    }
    function getCreator() view public returns (string) {
        return creator;
    }
    function getCreatorEmail() view public returns (string) {
        return creatorEmail;
    }
    function getBlurb() view public returns (string) {
        return blurb;
    }
    function getMiscellaneous() view public returns (string) {
        return miscellaneous;
    }

    /**
     * Setter functions
     */
    function setLocality(string newValue) onlyOwner public returns (string) {
        return locality = newValue;
    }
    function setCountry(string newValue) onlyOwner public returns (string) {
        return country = newValue;
    }
    function setName(string newValue) onlyOwner public returns (string) {
        return name = newValue;
    }
    function setSymbol(string newValue) onlyOwner public returns (string) {
        return symbol = newValue;
    }
    function setSymbolCharacter(string newValue) onlyOwner public returns (string) {
        return symbolCharacter = newValue;
    }
    function setCreator(string newValue) onlyOwner public returns (string) {
        return creator = newValue;
    }
    function setCreatorEmail(string newValue) onlyOwner public returns (string) {
        return creatorEmail = newValue;
    }
    function setBlurb(string newValue) onlyOwner public returns (string) {
        return blurb = newValue;
    }
    function setMiscellaneous(string newValue) onlyOwner public returns (string) {
        return miscellaneous = newValue;
    }

    /**
     * Total Supply
     * 
     * The total number of whole coins.
     */
    function totalSupply()
    view
    public
    returns (uint supply) {
        return totalWholeUnits;
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
    returns (bool success) {
        _transfer(msg.sender, _to, uint96(_volume));
        return true;
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
    returns (bool success) {
        uint96 thisAllowance = allowance[_from][msg.sender];
        uint96 volume = uint96(_volume);
        require(
            volume <= thisAllowance,
            "The allowance is insufficient for this transfer"
        );
        allowance[_from][msg.sender] = thisAllowance.subtract(volume);
        _transfer(_from, _to, volume);
        return true;
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
    function approve(address _spender, uint _volume)
    onlyWhenActive
    public
    returns (bool success) {
        uint96 volume = uint96(_volume);
        allowance[msg.sender][_spender] = volume;
        emit Approval(msg.sender, _spender, volume);
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
    function approveAndCall(address _spender, uint96 _volume, bytes _extraData)
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
    function revertToContractFrom(address _from, uint96 _volume)
    onlyWhenActive
    public
    returns (bool success) {
        _transfer(_from, this, _volume);
        emit RevertToContract(_from, _volume);
        return true;
    }

    /**
     * Send localitycoin to the contract
     *
     * Returns `_volume` minimum units of localitycoin to the contract.
     *
     * @param _volume the amount of money to revert
     */
    function revertToContract(uint96 _volume)
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
    returns (uint) {
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
    returns (uint volume) {
        return localityCoinBalance[this];
    }

    /**
     * Get the price of localitycoin in ether
     */
    function getPrice()
    view
    public
    returns (uint96 price) {
        return (totalMinimumUnits.subtract(localityCoinBalance[this])) >> 2;
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
    returns (uint96 value) {
        uint96 price = getPrice();
        return price.multiply(_volume);
    }

    /**
     * Get the volume that can be purchased with some ether value
     *
     * Returns the volume of minimum units of localitycoin that `_value` of wei
     * will buy.
     * 
     * @param _value The amount of wei
     */
    function getBuyVolume(uint96 _value)
    view
    public
    returns (uint96 volume) {
        uint96 price = getPrice();
        return _value.divide(price);
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
    returns (uint96 volume) {
        uint96 value = uint96(msg.value);
        require(
            uint256(value) == msg.value,
            "Overflow detected in the amount of paid ether"
        );
        volume = getBuyVolume(value);
        _transfer(this, msg.sender, volume); // from contract to seller
        return volume;
    }

    /**
     * Sell localitycoin
     * 
     * Redeem localitycoin for ether.
     */
    function sell(uint96 _amount)
    onlyWhenActive
    public
    returns (uint96 value){
        _transfer(msg.sender, this, _amount); // from seller to contract
        value = getValue(_amount);
        // Send ether to the seller.  It's important to do this last to prevent
        // recursion attacks.
        msg.sender.transfer(value);
        return value;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint96 _value)
    internal
    {
        require(_to != 0x0, "Cannot transfer to 0x0");
        require(
            localityCoinBalance[_from] >= _value,
            "The sender's localityCoin balance is too low"
        );

        localityCoinBalance[_from] = localityCoinBalance[_from].subtract(
            _value
        );   // Subtract from the sender

        localityCoinBalance[_to] = localityCoinBalance[_to].add(
            _value
        );     // Add the same to the recipient

        emit Transfer(_from, _to, _value);
    }
}


contract WaihekeCoin is LocalityCoin(
    "Waiheke Island",
    "New Zealand",
    "Waiheke Coin",
    'WAIHK',
    '₩',
    'Warwick Allen',
    '<warwick.allen@blockchain.expert>',
    '',
    ''
) { constructor() internal { } }
