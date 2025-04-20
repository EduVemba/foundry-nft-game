// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;


import {VRFConsumerBaseV2} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";


abstract contract VRFCordinator is VRFConsumerBaseV2  {

     VRFCoordinatorV2Interface COORDINATOR;


    uint64 private immutable subId;
    address private constant vrfCordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 private constant keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint16 private constant requestConfirmations = 3;
    uint32 private constant callbackGasLimit = 100000;
    uint32 private constant numWords = 1;

    uint256 private lastRandomWord;


    constructor(uint64 _subId) VRFConsumerBaseV2(vrfCordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCordinator);
        subId = _subId;
    }



    function requestRandomWords() public returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    /**
     * @dev This function will be used on the NFTgame contract.
     * @notice VRFCordinator fulfillRandomWords function.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual override {
        lastRandomWord = randomWords[0];
    }

}