pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

contract Ballot {
    struct Voter {
        bool hasVoted;
        uint votedProposalIndex;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    enum State { Created, Voting, Ended }
    State public state;

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only the chairperson can perform this action");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    constructor() {
        chairperson = msg.sender;
        state = State.Created;
    }

    function initializeProposals(string[] memory proposalNames)
        public
        onlyChairperson
        inState(State.Created)
    {
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal(proposalNames[i], 0));
        }
    }

    function addProposals(string[] memory proposalNames)
        public
        onlyChairperson
        inState(State.Ended)
    {
        state = State.Created;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal(proposalNames[i], 0));
        }
    }

    function startVote()
        public
        onlyChairperson
        inState(State.Created)
    {
        state = State.Voting;
    }

    function endVote()
        public
        onlyChairperson
        inState(State.Voting)
    {
        state = State.Ended;
    }

    function giveRightToVote(address voter)
        public
        onlyChairperson
        inState(State.Created)
    {
        require(!voters[voter].hasVoted, "The voter has already voted.");
        voters[voter] = Voter(false, 0);
    }

    function vote(uint proposalIndex)
        public
        inState(State.Voting)
    {
        Voter storage voter = voters[msg.sender];
        require(!voter.hasVoted, "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal index");

        voter.hasVoted = true;
        voter.votedProposalIndex = proposalIndex;

        proposals[proposalIndex].voteCount += 1;
    }

    function winningProposal()
        public
        view
        inState(State.Ended)
        returns (string memory winnerName_)
    {
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winnerName_ = proposals[i].name;
            }
        }
    }
}