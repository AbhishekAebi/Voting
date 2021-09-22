pragma solidity ^0.5.9;

contract Ballot{
    struct Voter{
        bool voted;
        uint weight;
        uint8 vote;
    }
    
    struct Proposal {
        uint voteCount;
    }
    
    enum Stage {Init, Reg, Vote, Done}
    Stage public stage = Stage.Init;
    
    address chairPerson;
    mapping (address => Voter) voters;
    Proposal[] proposals;
    
    uint startTime;
    
    event votingCompleted();
    
    modifier validStage(Stage reqCheck){
        require(stage == reqCheck);
        _;
    }
    
    constructor (uint _numProposals) public{
        chairPerson = msg.sender;
        voters[chairPerson].weight = 2;
        proposals.length = _numProposals;
        stage = Stage.Reg;
        startTime = now;
    }
    
    function register (address toVoter) public validStage(Stage.Reg){
        // if(stage != Stage.Reg) {return;}
        if(msg.sender != chairPerson || voters[toVoter].voted) return;
        voters[toVoter].weight = 1;
        voters[toVoter].voted = false;
        if(now > (startTime + 30 seconds)) {stage = Stage.Vote;}
    }
    
    function vote (uint8 toProposal) public validStage(Stage.Vote){
        // if(stage != Stage.Vote) {return;}
        Voter storage sender = voters[msg.sender];
        if(sender.voted || toProposal > proposals.length) return;
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
        if(now > (startTime + 60 seconds)) {stage = Stage.Done; emit votingCompleted();}
    }
    
    function winningProposal() public validStage(Stage.Done) view returns (uint8 _winningProposal) {
        // if(stage != Stage.Done) {return;}
        uint winningVoteCount = 0;
        for(uint8 prop =0 ; prop <proposals.length ; prop++){
            if(proposals[prop].voteCount > winningVoteCount){
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
        }
    }
}