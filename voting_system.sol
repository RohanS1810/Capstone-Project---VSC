//This sets the Solidity version pragma and declares the start of the Voting contract.
pragma solidity >=0.7.0 <0.9.0;
contract Voting {

//This defines two struct types: Voter and Proposal. Voter represents a voter and contains information about whether they have voted or not.
Proposal represents a proposal and contains the name of the proposal and the number of votes it has received.
   struct Voter {
        bool hasVoted;
        uint votedProposalIndex;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }
//This declares three state variables: chairperson, voters, and proposals.

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    
    enum State { Created, Voting, Ended }
    State public state;

//This defines two custom modifiers: onlyChairperson and inState. The onlyChairperson modifier checks whether the caller of a function is 
the chairperson address. The inState modifier checks whether the current state of the contract matches the state that was said as an argument.
    
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only the chairperson can perform this action");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        state = State.Created;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal(proposalNames[i], 0));
        }
    }

//This function can be called by the chairperson to start the voting process.

    function startVote() public onlyChairperson inState(State.Created) {
        state = State.Voting;
    }

//This function does the opposite and can end the voting process.

    function endVote() public onlyChairperson inState(State.Voting) {
        state = State.Ended;
    }

//This allows a registered voter to cast their vote for a specific proposal indicated by its proposalIndex. 
It ensures that the voter has not already voted and that the proposalIndex is valid. It basically safe proofs the voting process and it
won't allow someone to vote twice.

    function vote(uint proposalIndex) public inState(State.Voting) {
        Voter storage voter = voters[msg.sender];
        require(!voter.hasVoted, "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal index");

        voter.hasVoted = true;
        voter.votedProposalIndex = proposalIndex;

        proposals[proposalIndex].voteCount++;
    }

//This basically concludes the voting process. It determines the proposal with the highest vote count and returns its name.

    function winningProposal() public view inState(State.Ended) returns (string memory winnerName_) {
        uint winningVoteCount = 0;
        uint winningProposalIndex = 0;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }

        winnerName_ = proposals[winningProposalIndex].name;
    }
}
