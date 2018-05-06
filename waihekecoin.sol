pragma solidity ^0.4.23;

/**
 * The Locality Coin
 * 
 * Created by Warwick Allen, April 2018
 * Licenced under GPL3.0
 * Some code portions borrowed from https://www.ethereum.org/token.
 * 
 */

interface localityCoinRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    ) external;
}

contract LocalityCoin {
    string constant public purpose =
        "To promote provences, cities, towns and villages.";
    string constant public localityCoinCreator =
        "Warwick Allen <warwick.allen@bchain.expert>";
    uint8 constant public decimals = 18;        // Minimum divisible unit.
    uint96 constant public totalSupply = -1;    // ~79 billion whole coins.

    /**
     * Octave generator code for the price table:
     *   N = 2^96 - 1;
     *   x = linspace(0, N, 2^8).';
     *   y = 2^(60 + 16/17) .* 2.^(-N./((N - x) + N/16));
     *   ydash = round(y);
     *   plot(x, ydash);
     *   printf('%19d\n', ydash.')
     */
    uint64[256] priceTable = [
       uint64(1152921504606844288),
       1150138535701106944,
       1147341663492382336,
       1144530791883885184,
       1141705824023610368,
       1138866662299742848,
       1136013208336123392,
       1133145362987769472,
       1130263026336457856,
       1127366097686372864,
       1124454475559825664,
       1121528057693048576,
       1118586741032071680,
       1115630421728684160,
       1112658995136486656,
       1109672355807046144,
       1106670397486148608,
       1103653013110167168,
       1100620094802543872,
       1097571533870398080,
       1094507220801264000,
       1091427045259968640,
       1088330896085655680,
       1085218661288963968,
       1082090228049370240,
       1078945482712703232,
       1075784310788839808,
       1072606596949592576,
       1069412225026797056,
       1066201078010613504,
       1062973038048047232,
       1059727986441705728,
       1056465803648800640,
       1053186369280406528,
       1049889562100991744,
       1046575260028231296,
       1043243340133119616,
       1039893678640392704,
       1036526150929280512,
       1033140631534599168,
       1029736994148203136,
       1026315111620813568,
       1022874855964239104,
       1019416098354008704,
       1015938709132436096,
       1012442557812132480,
       1008927513079991808,
       1005393442801668864,
       1001840214026571392,
        998267692993391104,
        994675745136196096,
        991064235091110912,
        987433026703611904,
        983781983036461312,
        980110966378311296,
        976419838253008512,
        972708459429625728,
        968976689933257344,
        965224389056607488,
        961451415372410112,
        957657626746712832,
        953842880353064704,
        950007032687645952,
        946149939585381248,
        942271456237076992,
        938371437207628288,
        934449736455342336,
        930506207352422016,
        926540702706664576,
        922553074784423424,
        918543175334887296,
        914510855615734784,
        910455966420220672,
        906378358105755392,
        902277880624041344,
        898154383552830336,
        894007716129373952,
        889837727285633280,
        885644265685327104,
        881427179762892288,
        877186317764439808,
        872921527790788480,
        868632657842662656,
        864319555868148736,
        859982069812499072,
        855620047670389888,
        851233337540727168,
        846821787684114560,
        842385246583088384,
        837923563005243008,
        833436586069358848,
        828924165314666240,
        824386150773370752,
        819822393046580224,
        815232743383770624,
        810617053765945728,
        805975176992636928,
        801306966772908544,
        796612277820535552,
        791890965953523456,
        787142888198158336,
        782367902897768192,
        777565869826398976,
        772736650307605760,
        767880107338573184,
        762996105719787904,
        758084512190495104,
        753145195570176256,
        748178026906304512,
        743182879628633728,
        738159629710295424,
        733108155835988352,
        728028339577552896,
        722920065577238272,
        717783221738983168,
        712617699428042240,
        707423393679304320,
        702200203414664320,
        696948031669822592,
        691666785830904832,
        686356377881307392,
        681016724659192192,
        675647748126070272,
        670249375646935936,
        664821540282422144,
        659364181093477888,
        653877243459080832,
        648360679407521280,
        642814447961814400,
        637238515499821696,
        631632856129679232,
        625997452081162112,
        620332294113632256,
        614637381941242368,
        608912724676099200,
        603158341290107264,
        597374261096250496,
        591560524250090624,
        585717182272291072,
        579844298593006336,
        573941949119003968,
        568010222824419072,
        562049222366068608,
        556059064724289664,
        550039881870292480,
        543991821461054336,
        537915047562809728,
        531809741404230656,
        525676102160415232,
        519514347768842432,
        513324715778477120,
        507107464233245632,
        500862872591127104,
        494591242680142208,
        488292899692540416,
        481968193218521664,
        475617498320844608,
        469241216651701952,
        462839777613254016,
        456413639563234368,
        449963291067044800,
        443489252197764800,
        436992075885500544,
        430472349317487296,
        423930695390347200,
        417367774215876864,
        410784284681706496,
        404180966068120512,
        397558599722277056,
        390918010790979648,
        384260070013067904,
        377585695572377856,
        370895855012089408,
        364191567211120896,
        357473904423038528,
        350743994377737408,
        344003022445890752,
        337252233865874688,
        330492936032537984,
        323726500846799104,
        316954367124614528,
        310178043063354560,
        303399108763059968,
        296619218799395328,
        289840104844394048,
        283063578330256608,
        276291533150537824,
        269525948392012832,
        262768891089334432,
        256022518993288768,
        249289083341970720,
        242570931622574048,
        235870510309642464,
        229190367563596448,
        222533155871074848,
        215901634606110048,
        209298672488359040,
        202727249911518848,
        196190461111633376,
        189691516141225184,
        183233742611034336,
        176820587156577888,
        170455616581740064,
        164142518626129952,
        157885102296968032,
        151687297699771808,
        145553155295062400,
        139486844500715968,
        133492651551396608,
        127574976517758800,
        121738329378790224,
        115987325030820272,
        110326677106399904,
        104761190465536992,
         99295752210782544,
         93935321066550912,
         88684914952068608,
         83549596566744944,
         78534456796942752,
         73644595744573296,
         68885101171252328,
         64261024147701488,
         59777351697594472,
         55438976229297816,
         51250661559327624,
         47217005349543312,
         43342397808134680,
         39630976544713608,
         36086577525076720,
         32712682144661780,
         29512360535004276,
         26488211338635800,
         23642298339212616,
         20976084519746048,
         18490364347119316,
         16185195349654530,
         14059830369380464,
         12112652233061956,
         10341112994228328,
          8741680346117628,
          7309794279806259,
          6039837540880125,
          4925123887603701,
          3957908523587366,
          3129425298732973,
          2429955251071177,
          1848930681518283,
          1375078072863408,
           996601627234053,
           701406849071102,
           477360325106243,
           312577620538119,
           195726161849381,
           116324522710094,
            65014462566029,
            33778639852949
    ];

    // Declare the public variables of the token.
    string public locality;
    string public country;
    string public name;
    string public symbol;
    string public blurb;
    string public creator;
    address public owner;
    bool public suspended = false;    // Give the option to suspend the token.
    address public ownerChangeRequest = 0x0;

    // This creates an array with all balances.
    mapping (address => uint96) public balanceOf;
    mapping (address => mapping (address => uint96)) public allowance;

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
    constructor(
        string _provence,
        string _country,
        string _name,
        string _symbol,
        string _creator
    )
    internal
    {
        locality = _locality;
        country = _country;
        name = _name;
        symbol = _symbol;
        blurb = "To promote ${_locality}, ${_country}";
        creator = _creator;
        owner = msg.sender;
        balanceOf[this] = totalSupply;
    }

    /*
    function wholeCoinToSmallestUnit(uint240 amountInWholeCoins)
    pure
    returns (uint96 amountInSmallestUnits) {
        amountInSmallestUnits = uint96(amountInWholeCoins) * 10**uint96(decimals);
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow detected");
    }
    */

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

    /**
     * Get cost of localitycoin in ether.
     *
     * Returns the amount of wei needed to much _volume of whole localitycoins.
     * 
     * The cost is based on the formula:
     *     y = 2^(60 + 16/17) .* 2.^(-N./((N - x) + N/16));
     * where
     *     N is the total supply of localitycoin
     *     x is the amount of localitycoin currently owned by the contract
     *     y is the amount of wei needed to buy 1 whole localitycoin
     */
    function getBuyPrice()
    view
    public
    returns (uint64 buyPrice) {
        uint96 index = balanceOf[this] >> 88;
        assert(index > 255, "Invalid index to the price table: ${index} > 255")
        return priceTable[index];
    }

    function setBlurb(string _blurb)
    onlyOwner
    public
    returns (string blurb) {
        return blurb = _blurb;
    }

    function setSymbol(string _symbol)
    onlyOwner
    public
    returns (string symbol) {
        return symbol = _symbol;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value)
    internal
    {
        require(_to != 0x0, "Cannot transfer to 0x0");
        require(balanceOf[_from] >= _value, "The sender's balance is too low");
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
        localityCoinRecipient spender = localityCoinRecipient(_spender);
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

contract WaihekeCoin is LocalityCoin(
 "Waiheke Island",
 "New Zealand",
 "Waiheke Coin",
 "₩",
 "Warwick Allen <warwick.allen@blockchain.expert>"
) {
 constructor() { }
}

contract AucklandCoin is LocalityCoin(
 "Auckland",
 "New Zealand",
 "Auckland Coin",
 "ACK",
 "Warwick Allen <warwick.allen@blockchain.expert>"
) {
 constructor() { }
}

contract MatakanaCoin is LocalityCoin(
 "Matakana",
 "New Zealand",
 "Matakana Coin",
 "MATA",
 "Warwick Allen <warwick.allen@blockchain.expert>"
) {
 constructor() { }
}

contract BarrierCoin is LocalityCoin(
 "Great Barrier Island",
 "New Zealand",
 "Barrier Coin",
 "GBC",
 "Warwick Allen <warwick.allen@blockchain.expert>"
) {
 constructor() { }
}
