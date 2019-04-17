以最简单投票作为示例，不添加委托投票功能，相当于官方示例Ballot合约的简化，本项目中官方示例合约Ballot重命名为BallotDelegate，简化后的投票合约命名为Ballot。

###　投票流程

根据生活经验，投票流程大致如下

提出提案—＞提案公布—＞拥有投票权的人进行投票—＞统计各提案票数—＞公布获胜提案名

### 分析

提案的提出和公布无须由智能合约完成，只需要合约发起者将提案列表写入智能合约，然后由拥有投票权的人（合约调用者）进行投票即可。为了控制投票权，须由合约发起者对符合条件的投票者授予投票权。故合约发起者称为“chairperson”。投票结束后，调用合约相关函数进行票数统计，并公布获胜提案名。涉及的实体和关系描述如下：

- 合约发起者chairperson
  - 利用构造器constructor初始化提案列表
  - 授予相关合约调用者投票权(giveRightToVoter)
- 合约调用者Voter
  - 投票(vote)
- 合约本身
  - 统计各提案票数(winningProposal)
  - 返回获胜提案名(winnerName)

### 数据结构

投票者的数据结构

```js
struct Voter {
    bool weight;  //是否有投票权
    bool voted;  //是否投过票
    uint proposalNum;  //要投的提案编号
}
```

提案的数据结构

```js
struct Proposal {
    bytes32 name;  //提案名
    uint voteCount;  //当前票数
}
```

需要定义地址类型chairperson来存放合约发起人地址，进行访问控制

```js
address public chairperson;
```

需要定义一个映射将投票者状态（数据结构Voter）与传入的投票者地址对应

```js
mapping (address => Voter) public voters;
```

以及需要定义Proposal类型的数组来存放提案状态

```js
Proposal[] public proposals;
```

<br>

由以上思路进行[Ballot](../contract/ballot.sol)合约的编写。

