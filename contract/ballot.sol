pragma solidity >=0.4.0 <0.7.0;

// 投票
contract Ballot {
    //投票者
    struct Voter {
        bool right;  //是否拥有投票权
        bool voted;  //是否已投过票
        uint proposalNum; // 提案编号
    }
    //提案
    struct Proposal {
        bytes32 name;  //提案名
        uint voteCount;  //提案当前票数 
    }

    address public chairperson;  //主持人（合约发起者）地址
    mapping (address => Voter) public voters;  //关联投票者地址和投票者状态
    Proposal[] public proposals;  //提案列表

    // 初始化提案列表
    constructor (bytes32[] memory proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].right = true;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // 主持人授予投票者投票权
    function giveRightToVoter (address voter) public {
        require (
            msg.sender == chairperson,
            "only chairperson can give right to vote."
        );
        require (
            !voters[voter].voted,
            "The voter has already voted."
        );
        require (!voters[voter].right);
        voters[voter].right = true;
    }

    // 投票者根据公布的提案列表进行投票
    function vote (uint proposalNums) public {
        Voter storage sender = voters[msg.sender];
        require (
            !sender.voted,
            "already voted."
        );
        require (
            sender.right,
            "has no right to vote."
        );
        sender.voted = true;
        sender.proposalNum = proposalNums;
        proposals[proposalNums].voteCount += 1;
    }

    // 统计各提案票数并最终返回获胜提案编号
    function winningProposal() public view 
        returns (uint winningProposal_)
    {
        uint winningProposalCount = 0;
        for (uint j = 0; j < proposals.length; j++) {
            if (winningProposalCount < proposals[j].voteCount) {
                winningProposalCount = proposals[j].voteCount;
                winningProposal_ = j;
            }
        }
    }

    // 获取票数最多的提案名
    function winnerName () public view
        returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}