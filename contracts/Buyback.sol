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

    function burnTokens() {


    }

}