// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {VRFCordinator} from "./libraries/VRFCordinator.sol";
import {MyERC721} from "./MyERC721.sol";
// import {AutomationCompatibleInterface} from "chainlink-brownie-contracts/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";



contract NFTGame is VRFCordinator {

    ///////////////////////////////
    ////        ERRORS         ////
    ///////////////////////////////
    error NFTGame_GamesNotFound();
    error NFTGame_AlreadyEntered();
    error NFTGame_AlreadyClosed();
    error NFTGAME_ValueNotEqual();
    error NFTGame_TransferFailed();



    ///////////////////////////////
    ////        Enums           ///
    ///////////////////////////////
    enum GameStatus {
        OPEN,
        CLOSED
    }


    ///////////////////////////////
    ////        Structs         ///
    ///////////////////////////////
    struct Game {
        uint256 gameId;
        address[] players;
        uint256 tokenId;
        string imageURI;
        address creator;
        uint256 totalReceived;
        GameStatus status;
        uint256 startTime;
        uint256 endTime;
    }


    ///////////////////////////////
    ////       Variabels        ///
    ///////////////////////////////
    MyERC721 private s_myERC721;
    uint256 private s_gameId;
    address private s_winner;
    Game[] private s_games;
    uint256 public constant VALUE_TO_ENTER = 0.01 ether;

    mapping (address entered => uint256 gameId) private s_enteredGames;
    mapping(uint256 => uint256) private s_requestIdToGameId;


    ///////////////////////////////
    ////         Events         ///
    ///////////////////////////////

    event GameCreated(uint256 indexed gameId, address indexed creator, string imageURI);
    event GameEntered(address indexed player, uint256 indexed gameId, uint256 value);
    event GameEnded(uint256 indexed gameId, address indexed winner, uint256 tokenId);




      constructor(uint64 subId, address nftAddr) VRFCordinator(subId) {
        s_myERC721 = MyERC721(nftAddr);
    }

    ///////////////////////////////
    ////   external Functions   ///
    ///////////////////////////////

    /**
     * 
     * @param _imageURI is the image URI of the NFT.
     * @notice The error handling is done in the MyERC721 contract.
     * @dev The function is used to create a new game.
     * The Game only lasts for 1 day and the winner is selected randomly.
     * 
     */
    function createGame(string memory _imageURI) external {
        s_gameId++;
        s_myERC721.mint(_imageURI);
        Game memory newGame = Game ({
            gameId: s_gameId,
            players: new address[](0),
            tokenId: s_myERC721.tokenCounter() - 1,
            imageURI: _imageURI,
            creator: msg.sender,
            totalReceived: 0,
            status: GameStatus.OPEN,
            startTime: block.timestamp,
            endTime: block.timestamp + 1 days
        });
        s_games.push(newGame);

        emit GameCreated(newGame.gameId, msg.sender, _imageURI);
    }

    /**
     * 
     * @param _gameId is the id of the game to enter
     * @notice The function is used to enter a game that can only be entered if it is open.
     * 
     */
    function enterGame(uint256 _gameId) external payable {
        if (_gameId > s_games.length) {
            revert NFTGame_GamesNotFound();
        }
        if (s_games[_gameId].status == GameStatus.CLOSED) {
            revert NFTGame_AlreadyClosed();
        }
        if (s_enteredGames[msg.sender] == _gameId) {
            revert NFTGame_AlreadyEntered();
        }
        if (msg.value != VALUE_TO_ENTER) {
            revert NFTGAME_ValueNotEqual();
        }
        s_games[_gameId].players.push(msg.sender);
        s_games[_gameId].totalReceived += msg.value;
        s_enteredGames[msg.sender] = _gameId;

        emit GameEntered(msg.sender, _gameId, msg.value);
    }

    ///////////////////////////////
    ////   internal Functions   ///
    ///////////////////////////////


    function checkGameEndAndRequestRandom(uint256 _gameId) external {
        Game storage game = s_games[_gameId];
        if (block.timestamp >= game.endTime && game.status == GameStatus.OPEN) {
            game.status = GameStatus.CLOSED;
            uint256 requestId = requestRandomWords(); // salvar requestId + gameId numa mapping
            s_requestIdToGameId[requestId] = _gameId;
        }
    }


    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
       uint256 gameId = s_requestIdToGameId[requestId];
       Game storage game = s_games[gameId];

       if (game.players.length == 0) {
            s_winner = game.creator;
       } else {
            uint256 randomIndex = randomWords[0] % game.players.length;
            s_winner = game.players[randomIndex];
     }
        s_myERC721.safeTransferFrom(address(this), s_winner, game.tokenId);

        uint256 totalReceived = game.totalReceived;
        uint256 amountForCreator = (totalReceived / 2);
        (bool success, ) = payable(game.creator).call{value: amountForCreator}("");
        if (!success) {
            revert NFTGame_TransferFailed();
        }

        emit GameEnded(gameId, s_winner, game.tokenId);
    }

}