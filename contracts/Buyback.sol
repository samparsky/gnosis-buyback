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
    address public burnAddress;

    // mapping of the sell token to 
    mapping (address => uint) public balances;
    // mapping (address => uint) public 

    // This is a mapping of auction id to amount
    uint[] auctionIndexes;
    mapping(uint => uint) public auction;

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

    event Deposit(
        address indexed tokenAddress,
        uint amount
    );

    event ModifyAuction(
        uint auctionIndex,
        uint amount
    );

    event ModifyBurnAddress(
        address burnAddress
    );

    event Burn (
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
    constructor(address _buyToken, address _sellToken, bool _burn, uint[] _auctionIndexs, uint[] _auctionAmounts) public {
        sellToken = _sellToken;
        buyToken = _buyToken;
        shouldBurnToken = _burn;

        require(_auctionIndexs.length == _auctionAmounts.length, "Invalid auction amount and index");
        
        // map the auction ids to the auction amount
        for(i=0; i < _auctionIndexs.length; i++ ){
            auction[_auctionIndexs[i]] = _auctionAmounts[i];
        }

        // (pricetNum, priceDen) = dx.getPriceOfTokenInLastAuction(token);
    }

    function modifyAuctionsMulti(uint[] _auctionIndexs, uint[] _auctionAmounts) external onlyOwner  {
        require(_auctionIndexs.length == _auctionAmounts.length, "Invalid auction amount and index");
        for(i = 0; i < _auctionIndexs.length; i++){
            modifyAuction(_auctionIndexs[i], _auctionAmounts[i]);
        }
    }

    function modifyAuction(uint _auctionIndex, uint _auctionAmount) public onlyOwner {
        // require(_auctionInd)
        auction[_auctionIndex] = _auctionAmount;
        emit ModifyAuction(_auctionIndex, _auctionAmount);
    }

    function modifyBurn(bool _burn) external {
        shouldBurnToken = _burn;
    }

    function modifyBurnAddress(address _burnAddress) public {
        burnAdress = _burnAddress;
        emit ModifyBurnAddress(_burnAddress);
    }

    function updateDutchExchange(DutchExchange _dx) external onlyOwner {
        dx = _dx;
    }

    /**
     * @notice deposit
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function deposit(address _token, uint _amount) public onlyOwner returns (uint) {
        require(amount > 0);
        require(_token == sellToken, "Only alloweds");
        require(Token(token).transferFrom(msg.sender, this, amount));
        
        balances[token] += amount;
        emit Deposit(token, amount);

        return amount;
    }

     /**
     * @notice approve trading
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */

    function approve() public {
        // approve the dx proxy contract to trade on my behalf

        // _sellToken
        for( i = 0; i < auctionIndexes.length; i++ ) {
            dx.postSellOrder(sellToken, buyToken, auctionIndexes[i], auction[auctionIndexex[i]]);
        }
    }

    /**
     * @notice approve trading
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function claim() public {
        for(i = 0; i < auctionIndexes.length; i++) {
            (balance, frtsIssued) = dx.claimSellerFunds(sellToken, buyToken, this, auctionIndexes[i]);
            if(shouldBurnToken == true){
                
                if( burnAddress != address(0) ){
                    burnTokensWithAddress(buyToken, burnAddress, balance);
                }

                burnTokens(buyToken, balance);
            }
        }
    }

    /**
     * @notice approve trading
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function claimAndBurn() public {

        for(i = 0; i < auctionIndexes.length; i++) {
            dx.claimSellerFunds( sellToken, buyToken, this, auctionIndexes[i]);
        }

    }
    function transfer() public {
        // deposit would allow sell orders
        // with token pair to the 
    }

    /**
     * @notice burnTokens
     * @param _token Address of the  token
     * @param _amount Amount of tokens to burn
     */
    function burnTokens(address _token, uint _amount) public {
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
    function burnTokensWithAddress(address _token, address _burnAddress, uint _amount) public {
        // transfer the tokens to address(0)
        require(amount > 0);
        require(Token(token).transferFrom(this, _burnAddress, amount));
        emit Burn(
            _token,
            _amount
        );
    }



}