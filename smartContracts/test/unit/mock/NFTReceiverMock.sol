// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;



import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTReceiverMock is IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
