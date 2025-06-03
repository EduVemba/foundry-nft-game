// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFTGame} from "../../src/NFTGame.sol";
import {MyERC721} from "../../src/MyERC721.sol";
import {NFTReceiverMock} from "./mock/NFTReceiverMock.sol";

contract NFTGameTest is Test {
    NFTGame public game;
    MyERC721 public nft;
    NFTReceiverMock public receiverMock;

    address public player1 = address(2);
    address public automation = address(3);
    uint64 public subId = 1;

    function setUp() public {
        nft = new MyERC721();
        receiverMock = new NFTReceiverMock();
        game = new NFTGame(automation, subId, address(nft));
        vm.deal(player1, 1 ether);
    }

    function testCreateGame() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);

        NFTGame.Game memory createdGame = game.getGame(0);
        assertEq(createdGame.creator, address(this));
        assertEq(createdGame.imageURI, imageURI);

        uint256 tokenId = createdGame.tokenId;
        assertEq(nft.ownerOf(tokenId), address(game));
    }

    
    function testTransferNFTToMock() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);
        
        NFTGame.Game memory createdGame = game.getGame(0);
        uint256 tokenId = createdGame.tokenId;
        
        assertEq(nft.ownerOf(tokenId), address(game));

        vm.prank(address(game));
        nft.transferFrom(address(game), address(receiverMock), tokenId);

        assertEq(nft.ownerOf(tokenId), address(receiverMock));
    }

    // TODO: FIX
    function testEnterGame() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);
        
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        game.enterGame{value: 0.01 ether}(0);
        vm.stopPrank();
        
        NFTGame.Game memory gameAfterEntry = game.getGame(0);
        assertEq(gameAfterEntry.players.length, 1);
        assertEq(gameAfterEntry.players[0], player1);
        assertEq(gameAfterEntry.totalReceived, 0.01 ether);
    }

    function testEnterGameWithWrongValue() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);
        
        vm.deal(player1, 1 ether);
        vm.prank(player1);
        
        // TODO: INPUT THE CORRECT ERROR
        vm.expectRevert(/*NFTGame.NFTGame_AlreadyEntered.selector*/);
        game.enterGame{value: 0.02 ether}(0);
    }

    // TODO: FIX
    function testCannotEnterTwice() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);
        
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        
        game.enterGame{value: 0.01 ether}(0);
        
        vm.expectRevert(NFTGame.NFTGame_AlreadyEntered.selector);
        game.enterGame{value: 0.01 ether}(0);
        vm.stopPrank();
    }

    // TODO: FIX
    function testGameEndWithMockAsWinner() public {
        string memory imageURI = "ipfs://my-image";
        game.createGame(imageURI);
        
        NFTGame.Game memory createdGame = game.getGame(0);
        uint256 tokenId = createdGame.tokenId;
 
        vm.prank(address(game));
        nft.transferFrom(address(game), address(receiverMock), tokenId);
        
        assertEq(nft.ownerOf(tokenId), address(receiverMock));
        
        assertTrue(address(receiverMock).code.length > 0);
    }
}