pragma solidity >=0.4.0 <0.7.0;

/// title 委托投票
contract Ballot{
    /// 投票者Voter数据结构
    struct Voter{
        uint weight;  //该投票所占权重
        bool voted;  //是否已经投过票
        address delegate;  //该投票者投票权的委托对象
        uint vote;  //要投的提案编号
    }
    /// 提案Proposal数据结构
    struct Proposal{
        bytes32 name;  //提案名
        uint voteCount;  //提案目前票数
    }

    /// 投票的主持人
    address public chairperson;
    /// 投票者地址和状态的对应关系
    mapping(address => Voter) public voters;
    /// 提案列表
    Proposal[] public proposals;
    
    /// 初始化合约时，给定一个提案名称列表
    constructor(bytes32[] memory proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for(uint i = 0; i < proposalNames.length; i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    /// 只有chairperson能授予投票者投票权
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /// 投票者将自己的投票机会授权给另一个地址
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    /// 投票者根据提案列表进行投票
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    /// 进行票数统计
    function winningProposal() public view 
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++){
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /// 获取票数最多的提案名
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
