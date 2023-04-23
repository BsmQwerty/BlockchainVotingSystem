pragma solidity ^0.8.4;

contract Voting {
    // Struct representing a candidate
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // Variable storing the list of candidates
    mapping(uint => Candidate) public candidates;
    // Variable storing the number of candidates
    uint public candidatesCount;

    // Variable storing the list of addresses that have already voted
    mapping(address => bool) public voters;

    // Array of arrays representing the rankings of each voter
    uint[][] public rankings;

    // Array storing the list of candidate IDs in order of elimination
    uint[] public eliminatedCandidates;

    // Event emitted after voting
    event votedEvent (
        uint indexed _candidateId
    );

    // Function adding a new candidate
    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    // Constructor, adding some candidates
    constructor() {
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
        addCandidate("Candidate 3");
    }

    // Function allowing to vote for a specific candidate
    function vote(uint[] memory _ranking) public {
        // Checking if the address has already voted
        require(!voters[msg.sender], "This address has already voted!");

        // Recording the address to prevent voting again
        voters[msg.sender] = true;

        // Adding the ranking to the list of rankings
        rankings.push(_ranking);

        // Incrementing the vote count for the first choice candidate
        candidates[_ranking[0]].voteCount++;

        // Emitting an event informing about the vote
        emit votedEvent(_ranking[0]);
    }

    // Function to get the winning candidate(s)
    function getWinner() public view returns (uint[] memory) {
        // Array storing the current vote counts for each candidate
        uint[] memory voteCounts = new uint[](candidatesCount);

        // Initializing the vote counts to zero
        for (uint i = 1; i <= candidatesCount; i++) {
            voteCounts[i - 1] = candidates[i].voteCount;
        }

        // Looping through the rankings and redistributing votes
        for (uint round = 1; round <= candidatesCount; round++) {
            uint[] memory newVoteCounts = new uint[](candidatesCount);

            // Looping through the rankings and redistributing votes
            for (uint i = 0; i < rankings.length; i++) {
                uint highestRank = candidatesCount + 1;
                uint highestRankCandidate = 0;

                // Looping through the voter's rankings to find the highest-ranked candidate that hasn't been eliminated
                for (uint j = 0; j < rankings[i].length; j++) {
                    uint candidateId = rankings[i][j];

                    if (voteCounts[candidateId - 1] != 0 && j < highestRank) {
                        highestRank = j;
                        highestRankCandidate = candidateId;
                    }
                }

                // Incrementing the vote count for the highest-ranked candidate that hasn't been eliminated
                if (highestRankCandidate != 0) {
                    newVoteCounts[highestRankCandidate - 1]++;
                }
            }

            // Finding the candidate(s) with the lowest vote count and eliminating them
            uint minVoteCount = candidatesCount + 1;

            for (uint i = 0; i < candidatesCount; i++) {
                if (newVoteCounts[i] < minVote            Count) {
                minVoteCount = newVoteCounts[i];
            }
        }

        for (uint i = 0; i < candidatesCount; i++) {
            if (newVoteCounts[i] == minVoteCount && !hasBeenEliminated(i + 1)) {
                eliminatedCandidates.push(i + 1);
                voteCounts[i] = 0;
            }
        }

        // Updating the vote counts for the remaining candidates
        for (uint i = 0; i < candidatesCount; i++) {
            if (!hasBeenEliminated(i + 1)) {
                voteCounts[i] = newVoteCounts[i];
            }
        }
    }

    // Finding the candidate(s) with the highest vote count
    uint[] memory winners = new uint[](candidatesCount);
    uint maxVoteCount = 0;
    uint numWinners = 0;

    for (uint i = 0; i < candidatesCount; i++) {
        if (voteCounts[i] > maxVoteCount) {
            maxVoteCount = voteCounts[i];
            winners[0] = i + 1;
            numWinners = 1;
        } else if (voteCounts[i] == maxVoteCount) {
            numWinners++;
            winners[numWinners - 1] = i + 1;
        }
    }

    // Returning the winning candidate(s)
    uint[] memory result = new uint[](numWinners);

    for (uint i = 0; i < numWinners; i++) {
        result[i] = winners[i];
    }

    return result;
}

// Function to check if a candidate has been eliminated
function hasBeenEliminated(uint candidateId) public view returns (bool) {
    for (uint i = 0; i < eliminatedCandidates.length; i++) {
        if (eliminatedCandidates[i] == candidateId) {
            return true;
        }
    }

    return false;
}
}

