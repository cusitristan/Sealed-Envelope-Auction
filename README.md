# Sealed-Envelope-Auction
This is a sealed-envelope/blind auction smart contract written in Solidity for use on the Ethereum blockchain

## How it works
A blind auction is a type of auction where bidders can bid on an item without other bidders seeing the bids. This means bidders cannot up-bid others based their bids which modivates bidders to put forward their best bid. A blind auction has three phases:
1. ***Bidding Phase***
2. ***Revealing Phase***
3. ***Opening Phase***

The smart contract works as follows:
* The user/wallet that deploys the contract is considered the host and seller (named admin in contract code)
* The admin is the only one able to control the phases of the auction 
* Other users/wallets are the bidders 
* The auction starts when the admin begins the ***Bidding Phase*** where bidder may submit their blind bids (submitted as hashes of their bids)
* Once the admin is happy with the number of bids they can change the phase to ***Revealing Phase***
* In this phase bidders must submit their actual bids and have them verfied from their blind bid, this is also the time when auctual funds are deposited
* Finally, the admin can change the phase to the ***Opening Phase*** where all bids are compared to find the winner. Losers are transferred their payments back and the admin is transferred the highest bid

## How to use
This was entirely coded and tested on the Remix Online IDE so the following steps to run are within Remix. This contract should be ready to run on the Ethereum blockchain but since it wasnt tested there I cannot provide instructions.

1. Start by visiting [Remix Online IDE](https://remix.ethereum.org) and creating a new workspace or use the default one that is created on page entry
2. Copy-paste code from `Auction.sol` in this repo into one of the created files on Remix, or create a new file and paste there
3. Press `command/ctrl (mac/windows) + S` to save and compile
4. On the left hand side of the screen press the arrow looking icon named "deploy and run transactions"
5. Scroll down and press the orange "Deploy" button, should see a contract in the "Deployed Contracts" section
6. Expand that contract to reveal the API calls
7. While still using the same wallet_id press the orange "startBidding" button 
8. Next scroll back up and select a new wallet_id from the "Account" dropdown menu (you are now a bidder)
9. Enter: `<bid amount>, <random number>` (eg `4,8745`) into the blue "createBidHash" and click it. This will generate a hash of your bid. Remember or write these values for each bidder
10. Copy the hash output benieth starting with `0x` and paste it surrounded by quotation marks (eg "0xGHhdh678ns...") into the orange "commitBid" and click it
11. Do steps 8-10 for as many bidders as you'd like
12. Select the top wallet (the one used as admin) and press the orange "endBidding" button
13. Now go back to each bidder wallet and for each:
- enter the amount of the bid **in ETH** in the "value" section near the top
- then in the red "revealBid" section enter: `<bid amount>, <same random number>` and then click the button
14. Do the above for each bidder
15. Select the admin account again and press the orange "endRevealing" button
16. Then press the red "openBids" button

If you did the above steps correctly you should be able to press the blue "winner" button to see the winners bid, nonce(random number) and the hash they created. You should also see all the non-winner wallets have their Eth returned (minus gas fees) and the admin transferred the highest bid. 
