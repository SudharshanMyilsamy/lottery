// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address payable[] public players;
    address public winner;
    bool public lotteryOpen;

    event NewPlayer(address indexed player, uint256 numberOfPlayers);
    event WinnerSelected(address indexed winner, uint256 winningAmount);

    constructor() {
        manager = msg.sender;
        lotteryOpen = true;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    modifier lotteryIsOpen() {
        require(lotteryOpen, "Lottery is not open");
        _;
    }

    function enter() public payable lotteryIsOpen {
        require(msg.value > 0, "Value sent must be greater than 0");
        players.push(payable(msg.sender));
        emit NewPlayer(msg.sender, players.length);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function closeLottery() public onlyManager lotteryIsOpen {
        require(players.length > 0, "No players in the lottery");
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length))) % players.length;
        winner = players[randomNumber];
        lotteryOpen = false;
        emit WinnerSelected(winner, address(this).balance);
        payable(winner).transfer(address(this).balance);
    }

    function cancelLottery() public onlyManager lotteryIsOpen {
        lotteryOpen = false;
        for (uint256 i = 0; i < players.length; i++) {
            payable(players[i]).transfer(address(this).balance / players.length);
        }
    }

    function withdrawFunds(uint256 amount) public onlyManager {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(manager).transfer(amount);
    }

    receive() external payable {}
}
