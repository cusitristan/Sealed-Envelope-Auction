
pragma solidity 0.8.7;

contract BlindAuction{
    //amount of wei equal to one eth
    uint256 weiMul = 1000000000000000000;

    //struct to contain bidding data
    struct bidData{
        bytes32 hash;
        uint nonce;
        uint256 bid;
    }
    //list of bidder ids mapped to their bids 
    mapping(address => bidData) public bidList;
    //list of bidder ids
    address[] addresses;
    //auction phases
    enum Phases{STANDBY, BIDDING, REVEALING, OPENING}
    //current phase
    Phases curPhase;
    //address of the admin account
    address payable public admin;
    //contract constructor
    constructor() public{
        admin = payable(msg.sender);
        curPhase = Phases.STANDBY;
    }

    //modifier that ensures sender is admin
    modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
    }

    //start the bidding process, allow bidders to give their bids
    function startBidding()
    public onlyAdmin{
        curPhase = Phases.BIDDING;
    }

    //create hash for bidders bid
    function createBidHash(uint bidValue, uint nonce) public pure returns( bytes32 bidHash){
        return keccak256(abi.encode(bidValue, nonce));
    }

    //accept bid hashes from bidder 
    function bidCommit(bytes32 _bid) public{
        require (curPhase == Phases.BIDDING);
        bidList[msg.sender] = bidData(_bid,0,0);
        addresses.push(msg.sender);
    }

    //end bidding process, no longer allow bids
    function endBidding()
    public onlyAdmin{
        curPhase = Phases.REVEALING;
    }
    
    //bidders transfer their ETH and reveal their bids and nonces 
    function revealBid( uint256 _bid, uint _nonce) payable public{
        require (curPhase == Phases.REVEALING);
        bidList[msg.sender].nonce = _nonce;
        bidList[msg.sender].bid = _bid;
        uint256 value = msg.value / weiMul;
        require(value == _bid, "claimed bid did not match transfer");
    }

    //end revealing phase, start opening phase
    function endRevealing()
    public onlyAdmin{
        curPhase = Phases.OPENING;
    }

    //store winners data here to view
    bidData public  winner;
    
    //open bids, verify bids and announce winner
    function openBids() payable public onlyAdmin{
        require (curPhase == Phases.OPENING);
        address highestBidder;
        uint256 highestBid = 0;
        //iterating over list of bidders, verifying their commitments and looking for winner
        for(uint i=0; i<addresses.length; i++){
            //verify hash
            address bidderAddress = addresses[i];
            uint256 bid = bidList[bidderAddress].bid;
            uint nonce = bidList[bidderAddress].nonce;
            bytes32 hash = bidList[bidderAddress].hash;
            require (hash == createBidHash(bid, nonce));
            //keep track of highest bidder
            if(bid > highestBid){
                highestBid = bid;
                highestBidder = bidderAddress;
            }
        }
        //store winner
        winner = bidList[highestBidder];

        //iterating over bidders, transfering back the eth to all non-winners
        for(uint i=0; i<addresses.length; i++){
            address payable bidderAddress = payable(addresses[i]);
            uint256 bid = bidList[bidderAddress].bid;
            uint256 bidEth = bid*weiMul;
            if(bidderAddress != highestBidder){
                bool status = bidderAddress.send(bidEth);
                require(status, "did not work :(");
            }
        }
        //transfer highest bid to admin
        uint256 highestBidETH = highestBid*weiMul;
        bool status = admin.send(highestBidETH);
        require(status, "did not work :(");
    }
}
