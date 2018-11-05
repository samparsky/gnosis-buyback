pragma solidity ^0.4.21;

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
        address indexed sellToken,
        address indexed buyToken,
        uint balance,
        uint auctionIndex
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
        address burnAddress,
        uint amount
    );
    
    event DeleteAuction(
        uint auctionIndex,
        uint amount
    );
       
    /**
     * @notice Buyback
     * @param _buyToken Address of the security token
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param _auctionIndexes Auction index the to participate 
     * @param _auctionAmounts Auction amount to fill in auction index
     */
    function BuyBack(address _dx, address _buyToken, address _sellToken, bool _burn, uint[] _auctionIndexes, uint[] _auctionAmounts) public {
        require(_auctionIndexes.length == _auctionAmounts.length);

        dx = DutchExchange(_dx);
        sellToken = _sellToken;
        buyToken = _buyToken;
        shouldBurnToken = _burn;
        auctionIndexes = _auctionIndexes;
        
        // map the auction ids to the auction amount
        for(uint i = 0; i < _auctionIndexes.length; i++ ){
            auction[_auctionIndexes[i]] = _auctionAmounts[i];
        }
    }
    
    /**
     * @notice modifyAuctionsMulti modify the amount for multiple auction index
     * @param _auctionIndexes Auction index the to participate 
     * @param _auctionAmounts Auction amount to fill in auction index
     */
    function modifyAuctionsMulti(uint[] _auctionIndexes, uint[] _auctionAmounts) external onlyOwner  {
        require(_auctionIndexes.length == _auctionAmounts.length);
        for(uint i = 0; i < _auctionIndexes.length; i++){
            modifyAuction(_auctionIndexes[i], _auctionAmounts[i]);
        }
    }
    
    /**
     * @notice modifyAuctions modify the amount for an auction index
     * @param _auctionIndex Auction index the to participate 
     * @param _auctionAmount Auction amount to fill in auction index
     */
    function modifyAuction(uint _auctionIndex, uint _auctionAmount) public onlyOwner {
        // require(_auctionInd)
        auction[_auctionIndex] = _auctionAmount;
        emit ModifyAuction(_auctionIndex, _auctionAmount);
    }
    
    /**
     * @notice deleteAuction modify the amount for an auction index
     * @param _auctionIndex Auction index the to participate 
     */
    function deleteAuction(uint _auctionIndex) public onlyOwner {
        require(auction[_auctionIndex] > 0);
        uint[] newAuctionIndexes;
        for(uint i = 0; i < auctionIndexes.length; i++){
            if(auctionIndexes[i] == _auctionIndex){
                continue;
            }
            newAuctionIndexes[i] = auctionIndexes[i];
        }
        auctionIndexes = newAuctionIndexes;
        uint auctionAmount = auction[_auctionIndex];
        delete auction[_auctionIndex];
        emit DeleteAuction(_auctionIndex, auctionAmount);
    }
    
    
    /**
     * @notice deleteAuctions delete an Auction
     * @param _auctionIndexes Auction index the to participate 
     */
    function deleteAuctions(uint[] _auctionIndexes) public onlyOwner {
        require(_auctionIndexes.length > 0);
        for(uint i = 0; i < _auctionIndexes.length; i++) {
            deleteAuction(_auctionIndexes[i]); 
        }
    }
    
    /**
     * @notice modifyBurn should burn the bought tokens
     * @param _burn to either burn or not burn i.e. True or false
     */
    function modifyBurn(bool _burn) external {
        shouldBurnToken = _burn;
    }
    
    /**
     * @notice modifyBurnAddress modify address burnt tokens should be sent to
     * @param _burnAddress burn address
     */
    function modifyBurnAddress(address _burnAddress) public {
        burnAddress = _burnAddress;
        emit ModifyBurnAddress(_burnAddress);
    }

    function updateDutchExchange(DutchExchange _dx) external onlyOwner {
        dx = _dx;
    }

    /**
     * @notice deposit
     * @param _token Address of the deposited token 
     * @param _amount Amount of tokens deposited 10^18
     */
    function deposit(address _token, uint _amount) public onlyOwner returns (uint) {
        require(_amount > 0);
        require(_token == sellToken);
        require(Token(_token).transferFrom(msg.sender, this, _amount));
        
        balances[_token] += _amount;
        emit Deposit(_token, _amount);

        return _amount;
    }

    /**
     * @notice approve trading
     */
    function approve() public {
        // approve the dx proxy contract to trade on my behalf
        // _sellToken
        for( uint i = 0; i < auctionIndexes.length; i++ ) {
            dx.postSellOrder(sellToken, buyToken, auctionIndexes[i], auction[auctionIndexes[i]]);
        }
    }

    /**
     * @notice approve trading

     */
    function claim() public {
        uint balance;
        for(uint i = 0; i < auctionIndexes.length; i++) {
            (balance, ) = dx.claimSellerFunds(sellToken, buyToken, this, auctionIndexes[i]);
            if(shouldBurnToken == true){
                if( burnAddress != address(0) ){
                    burnTokensWithAddress(buyToken, burnAddress, balance);
                }
                burnTokens(buyToken, balance);
            }
            emit Withdraw(sellToken, buyToken, balance, auctionIndexes[i]);
        }
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
            address(0),
            _amount
        );
    }

    /**
     * @notice burnTokensWithAddress
     * @param _token Address of the  token
     * @param _burnAddress Address to send burn tokens
     * @param _amount Amount of tokens to burn
     */
    function burnTokensWithAddress(address _token, address _burnAddress, uint _amount) public {
        // transfer the tokens to address(0)
        require(_amount > 0);
        require(Token(_token).transferFrom(this, _burnAddress, _amount));
        emit Burn(
            _token,
            _burnAddress,
            _amount
        );
    }
}