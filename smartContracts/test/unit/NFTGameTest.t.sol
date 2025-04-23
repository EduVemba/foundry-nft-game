// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFTGame} from "../../src/NFTGame.sol";
import {MyERC721} from "../../src/MyERC721.sol";
import {NFTReceiverMock} from "./mock/NFTReceiverMock.sol";

contract NFTGameTest is Test {
    NFTGame public game;
    MyERC721 public nft;
    // NFTReceiverMock public creatorMock;

    address public player1 = address(2);
    address public automation = address(3);
    uint64 public subId = 1;

    function setUp() public {
        nft = new MyERC721();
        //creatorMock = new NFTReceiverMock();
        game = new NFTGame(automation, subId, address(nft));
    }

    // TODO: Only the mockContract can receive an NFT
    function testCreateGame() public {
        
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);

        
        NFTGame.Game memory createdGame = game.getGame(1);
        assertEq(createdGame.creator, address(this));
        assertEq(createdGame.imageURI, imageURI); 

        
        uint256 tokenId = createdGame.tokenId;
        assertEq(nft.ownerOf(tokenId), address(game)); 
    }
}
