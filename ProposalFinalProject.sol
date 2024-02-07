// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract ProposalContract {

address owner;

uint256 private counter; 

struct Proposal {
        string description; // Description of the proposal
        string title;
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 totalVoteToEnd; // When the total votes in the proposal reaches this limit, proposal ends
        bool currentState; // This shows the current state of the proposal, meaning whether if passes of fails
        bool isActive; // This shows if others can vote to our contract
    }

mapping(uint256 => Proposal) proposal_history;

// Store votes for proposals
mapping(uint256 => mapping (address => bool)) public hasVoted;

constructor(){
    owner = msg.sender;
}

modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner of this contract can execute this");
    _;
}

modifier active(uint256 proposalId) {
    require(proposal_history[proposalId].isActive == true, "The proposal is not active");
    _;
}

modifier hasNotVotedYet(uint256 proposalId) {
    require(!hasVoted[proposalId][msg.sender], "Address has already voted on this proposal");
    _;
}

function create(string calldata _description,string calldata title , uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_description,title, 0, 0, 0, _total_vote_to_end, false, true);
}

function setOwner(address new_owner) external onlyOwner {
    owner = new_owner;
}

function terminateProposal(uint256 proposalId) external onlyOwner active(proposalId) {
    proposal_history[proposalId].isActive = false;
}

function calculateCurrentState(Proposal storage proposal) private view returns(bool) {
     uint256 adjustedPass = (proposal.pass +  1) /  2;
    return proposal.approve > proposal.reject + adjustedPass;
}


function vote(uint8 choice, uint256 proposalId) external hasNotVotedYet(proposalId) active(proposalId) {

    Proposal storage proposal = proposal_history[proposalId];

    hasVoted[proposalId][msg.sender] = true;

    // Second part
    if (choice == 1) {
        proposal.approve += 1;
        proposal.currentState = calculateCurrentState(proposal);
    } else if (choice == 2) {
        proposal.reject += 1;
        proposal.currentState = calculateCurrentState(proposal);
    } else if (choice == 0) {
        proposal.pass += 1;
        proposal.currentState = calculateCurrentState(proposal);
    }

    

    
    uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
    if ((proposal.totalVoteToEnd == total_vote)) {
        proposal.isActive = false;
    }

}

    // QUERY FUNCTIONS


function didIVote(uint256 proposalId) external view returns (bool){
    return hasVoted[proposalId][msg.sender];
}

function getLatestProposal() external view returns(Proposal memory) {
    return proposal_history[counter];
}

function getProposal(uint256 proposalId) external view returns(Proposal memory) {
    return proposal_history[proposalId];
}

function getOwner() external view returns(address){
    return owner;
}
}
