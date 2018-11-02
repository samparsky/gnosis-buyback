pragma solidity ^0.4.24;

import "@gnosis.pm/util-contracts/contracts/Token.sol";
import "@gnosis.pm/dx-contracts/contracts/DutchExchange.sol";
import "@gnosis.pm/dx-contracts/contracts/Oracle/PriceOracleInterface.sol";

/**
* Set maximum an address can buy
* approve and allow
*/

contract BuyBack {

    address public owner;

    // SellToken the token that is sold
    address public sellToken;
    address public buyToken;

    // mapping of the sell token to 
    mapping (address => uint) public balances;
    mapping (address => uint) public 

    uint256[] auctionIDs;


    bool shouldBurnToken;

    // BuyToken the token that is bought
    DutchExchange public dx;

    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }

    event Withdraw(
         address indexed token,
         uint amount
    );

    event Deposit (
        address indexed tokenAddress,
        uint amount
    );

    event Burn (
        address indexed tokenAddress,
        uint amount
    )

    event BuyBack (
        address indexed from,
        address indexed to,
        uint amount,
        uint token
    );
       
    /**
     * @notice Constructor
     * @param _buyToken Address of the security token
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    constructor(address _buyToken, address _sellToken, bool _burn, uint256 _amount) public {
        sellToken = _sellToken;
        buyToken = _buyToken;
        amount = _amount;
        shouldBurnToken = _burn;
        (pricetNum, priceDen) = dx.getPriceOfTokenInLastAuction(token);
    }

    function updateDutchExchange (DutchExchange _dx) external onlyOwner {
        dx = _dx;
    }

    /**
     * @notice deposit
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function deposit (address token, uint amount) public onlyOwner returns (uint) {
        require(amount > 0);
        require(Token(token).transferFrom(msg.sender, this, amount));
        
        balances[token] += amount;
        emit Deposit(token, amount);

        return amount;
    }

    function _approve() {
        _sellToken
    }

    function transfer() {
        // deposit would allow sell orders
        // with token pair to the 
        dx.addTokenPair()


    }

    /**
     * @notice burnTokens
     * @param token Address of the  token
     * @param amount Amount of tokens to burn
     */
    function burnTokens(address _token, uint _amount) {
        // transfer the tokens to address(0)
        require(_amount > 0);
        require(Token(_token).transferFrom(this, address(0), _amount));
        emit Burn(
            _token,
            _amount
        );
    }

    /**
     * @notice burnTokensWithAddress
     * @param _token Address of the  token
     * @param _amount Amount of tokens to burn
     * @param _burnAddress Address to send burn tokens
     */
    function burnTokensWithAddress(address _token, address _burnAddress, uint _amount,) {
        // transfer the tokens to address(0)
        require(amount > 0);
        require(Token(token).transferFrom(this, _burnAddress, amount));
        emit Burn(
            token,
            amount
        );
    }



}