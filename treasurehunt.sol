// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract TreasureHunt {
    address public owner;
    address public winner;
    uint public prizeAmount;
    string public treasureLocation;
    string[] public clues;
    mapping(address => bool) public hasClaimed;

    event ClueReleased(string clue);
    event TreasureFound(address winner, uint prize);

    constructor() {
        owner = msg.sender;
        prizeAmount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot participate");
        _;
    }

    function depositPrize() external payable onlyOwner {
        prizeAmount += msg.value;
    }

    function addClue(string memory clue) external onlyOwner {
        clues.push(clue);
        emit ClueReleased(clue);
    }

    function getClue() external view returns (string memory) {
        require(currentClueIndex() < clues.length, "No more clues available");
        return clues[currentClueIndex()];
    }

    function submitSolution(string memory solution) external notOwner {
        require(!hasClaimed[msg.sender], "Participant has already claimed");
        require(keccak256(abi.encodePacked(solution)) == keccak256(abi.encodePacked(treasureLocation)), "Incorrect solution");

        winner = msg.sender;
        hasClaimed[msg.sender] = true;
        emit TreasureFound(winner, prizeAmount);

        // Reset the contract for a new round
        resetContract();
    }

    function currentClueIndex() internal view returns (uint) {
        uint index = prizeAmount / 1 ether; // Each ether deposit releases one more clue
        if (index >= clues.length) {
            return clues.length - 1;
        }
        return index;
    }

    function resetContract() internal {
        prizeAmount = 0;
        delete clues;
        delete treasureLocation;
        winner = address(0);
    }
}
