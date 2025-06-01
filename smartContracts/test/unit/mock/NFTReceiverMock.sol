// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title NFTReceiverMock
 * @author Eduardo Vemba
 * @notice This is a mock contract for testing the NFTGame contract.
 */
contract NFTReceiverMock is IERC721Receiver {
    
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
    
    uint256[] public receivedTokenIds;
    mapping(uint256 => bool) public hasReceived;
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        receivedTokenIds.push(tokenId);
        hasReceived[tokenId] = true;
        
        emit NFTReceived(operator, from, tokenId, data);
        
        return IERC721Receiver.onERC721Received.selector;
    }

    function getReceivedTokenIdsCount() external view returns (uint256) {
        return receivedTokenIds.length;
    }
    
    function getReceivedTokenId(uint256 index) external view returns (uint256) {
        require(index < receivedTokenIds.length, "Index out of bounds");
        return receivedTokenIds[index];
    }
    
    function hasReceivedToken(uint256 tokenId) external view returns (bool) {
        return hasReceived[tokenId];
    }
}