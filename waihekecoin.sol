pragma solidity ^0.4.23;

/**
 * The Waiheke Coin
 * 
 * Created by Warwick Allen, April 2018
 * Licenced under GPL3.0
 * Some code portions borrowed from https://www.ethereum.org/token.
 * 
 */

interface waihekeCoinRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    ) external;
}

contract WaihekeCoin {
    string constant public name = "Waiheke Coin";
    string constant public symbol = "₩";
    string constant public purpose = "To promote Waiheke Island, New Zealand";
    string constant public creator =
        "Warwick Allen <warwick.allen@bchain.expert>";
    uint8 constant public decimals = 18;       // Minimum divisible unit.
    uint32 constant public totalSupply = 92e6; // The area of Waiheke in m^2.

    // Declare the public variables of the token.
    address public owner;
    bool public suspended = false;    // Give the option to suspend the token.
    address public ownerChangeRequest = 0x0;
    uint256 public sellPrice;
    uint256 public buyPrice;

    // This creates an array with all balances.
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients.
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    // This notifies clients about the amount reverted.
    event RevertToContract(
        address indexed from,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyOwner() {
    require(
            msg.sender == owner,
            "Only the owner can run this function"
        );
        _;
    }

    modifier isActive() {
        // The owner can still run functions when the token is suspended.
        require(
            !suspended || msg.sender == owner,
            "This token is currently disabled"
        );
        _;
    }

    /**
     * Constructor
     *
     * Initialises the contract by giving all the tokens to the creator of the
     * contract (i.e., the "owner").
     */
    constructor()
    public
    {
        owner = msg.sender;
        uint256 ownerBalance = uint256(totalSupply) * 10**uint256(decimals);
        balanceOf[owner] = ownerBalance;
    }

    /**
     * Suspend the token if there is some problem.
     */
    function suspend()
    onlyOwner
    public
    {
        suspended = true;
    }

    /**
     * Re-enable the token if it has been suspended.
     */
    function enable()
    onlyOwner
    public
    {
        suspended = false;
    }

    function setBuySellPrice(uint256 _newBuyPrice, uint256 _newSellPrice)
    onlyOwner
    public
    {
        buyPrice = _newBuyPrice;
        sellPrice = _newSellPrice;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value)
    internal
    {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0, "Cannot transfer to 0x0");
        // Check if the sender has enough.
        require(balanceOf[_from] >= _value, "The sender's balance is too low");
        // Check for overflows.
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow detected");

        uint256 sumOfStartingBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;  // Subtract from the sender
        balanceOf[_to] += _value;    // Add the same to the recipient
        // Sanity check.
        assert(balanceOf[_from] + balanceOf[_to] == sumOfStartingBalances);
        emit Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens.
     *
     * Send `_value` tokens to `_to` from your account.
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value)
    isActive
    public
    returns (uint256 value) {
        _transfer(msg.sender, _to, _value);
        return _value;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value)
    isActive
    public
    returns (uint256 value) {
        require(
            _value <= allowance[_from][msg.sender],
            "The allowance is insufficient for this transfer"
        );
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return _value;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf.
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value)
    isActive
    public
    returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify.
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf,
     * and then pings the contract about it.
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    isActive
    public
    returns (bool success) {
        waihekeCoinRecipient spender = waihekeCoinRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Send tokens to the contract from another account.
     *
     * Send `_value` tokens on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to revert
     */
    function revertToContractFrom(address _from, uint256 _value)
    isActive
    public
    returns (bool success) {
        _transfer(_from, this, _value);
        emit RevertToContract(_from, _value);
        return true;
    }

    /**
     * Send tokens to the contract.
     *
     * Returns `_value` tokens to the contract.
     *
     * @param _value the amount of money to revert
     */
    function revertToContract(uint256 _value)
    isActive
    public
    returns (bool success) {
        return revertToContractFrom(msg.sender, _value);
    }

    function balanceOfContract()
    view
    public
    returns (uint256) {
        return balanceOf[this];
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

    function balance()
    view
    public
    returns (uint256) {
        return balanceOf[msg.sender];
    }
    
    /**
     * Buy tokens
     * 
     * Exchange ether for tokens.
     */
    function buy()
    payable
    public
    returns (uint256 amount){
        amount = msg.value/buyPrice;         // calculate the amount
        _transfer(this, msg.sender, amount); // from contract to seller
        return amount;
    }

    /**
     * Sell tokens
     * 
     * Redeem tokens for ether.
     */
    function sell(uint256 _amount)
    public
    returns (uint revenue){
        _transfer(msg.sender, this, _amount); // from seller to contract
        revenue = _amount*sellPrice;
        // Send ether to the seller.  It's important to do this last to prevent
        // recursion attacks.
        msg.sender.transfer(revenue);       
        return revenue;
    }

    /**
     * Fall-back function to receive ether.
     */
    function()
    public
    payable
    { }
}
