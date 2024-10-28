# Auction House Smart Contract

## Overview
The Auction House smart contract enables users to create and participate in decentralized auctions on the Stacks blockchain. The contract manages auction lifecycles, including creating auctions, placing bids, ending auctions, and handling settlements. It supports basic auction functions and includes error handling for seamless interactions.

## Features
- **Auction Creation**: Users can create new auctions by specifying a token ID, duration, and reserve price.
- **Bidding System**: Users place bids on active auctions. Only bids higher than the current bid and the reserve price are accepted.
- **Auction Management**: Functions to check auction status, retrieve bid information, end auctions, and cancel auctions.
- **Settlement**: Once an auction is complete, the winning bid amount is transferred to the auction owner, and the auction is marked as `ended`.

## Data Structures
- **`auctions` Map**: Stores auction details, such as the owner, token ID, start and end block, reserve price, current bid, highest bidder, and auction status.
- **`user-bids` Map**: Tracks user-specific bids for each auction.
- **`next-auction-id` Variable**: Stores the ID for the next auction to be created.

## Error Codes
- **`ERR-EXPIRED` (100)**: Auction duration must be positive.
- **`ERR-NOT-EXPIRED` (101)**: Auction is still active and cannot be ended.
- **`ERR-LOW-BID` (102)**: Bid is below the current or reserve price.
- **`ERR-NO-AUCTION` (103)**: No auction found for the provided ID.
- **`ERR-ALREADY-EXISTS` (104)**: Auction already exists.
- **`ERR-NOT-OWNER` (105)**: Only the auction owner can perform this action.
- **`ERR-AUCTION-ACTIVE` (106)**: Auction has active bids and cannot be canceled.
- **`ERR-NOT-ACTIVE` (107)**: Auction is not active.

## Functions

### Read-Only Functions
- **`get-auction`**: Retrieves the details of a specified auction.
- **`get-user-bid`**: Gets the bid placed by a specific user on a given auction.
- **`is-auction-active`**: Checks if an auction is currently active by comparing block height and auction status.

### Public Functions
- **`create-auction`**: Allows users to create a new auction with a specified token ID, duration, and reserve price.
- **`place-bid`**: Enables users to place a bid on an active auction. It verifies that the bid is higher than the current bid and transfers the bid amount to the contract.
- **`end-auction`**: Ends an auction after its expiration. Transfers the winning bid to the auction owner, finalizes the auction, and updates its status.
- **`cancel-auction`**: Cancels an auction if no bids are present and only by the owner.

## Example Usage
1. **Creating an Auction**: Call `create-auction` with `token-id`, `duration`, and `reserve-price` parameters.
2. **Placing a Bid**: Call `place-bid` with `auction-id` and `bid-amount`.
3. **Ending an Auction**: Use `end-auction` to finalize an auction after it expires. If successful, the winning bid is transferred to the auction owner.
4. **Cancelling an Auction**: Call `cancel-auction` to cancel an auction without active bids.

## Notes
- **NFT Transfer Assumption**: The contract includes a placeholder for transferring NFTs. Integration with an external NFT contract or transfer function is required.
- **Error Handling**: The contract uses custom error codes for streamlined error reporting.

## License
This contract is open-source and available under the MIT License.
