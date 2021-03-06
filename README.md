# 区块链基础

[中文文档](https://solidity-cn.readthedocs.io/zh/develop/index.html)

[英文文档](https://solidity.readthedocs.io/en/v0.6.6/solidity-by-example.html#possible-improvements)



## 交易/事物

​		区块链是全球共享的事务性数据库，这意味着每个人都可加入网络来阅读数据库中的记录。如果你想改变数据库中的某些东西，你必须创建一个被所有其他人所接受的事务。

​		此外，交易总是由**发送人**（创建者）签名。

​		这样，就可非常简单地为数据库的特定修改增加访问保护机制。在电子货币的例子中，一个简单的检查可以确保只有持有账户密钥的人才能从中转账。

## 区块

​		在比特币中，要解决的一个主要难题，被称为“双花攻击 (double-spend attack)”：如果网络存在两笔交易，都想花光同一个账户的钱时（即所谓的冲突）会发生什么情况？交易互相冲突？

​		简单的回答是你不必在乎此问题。网络会为你自动选择一条交易序列，并打包到所谓的“区块”中，然后它们将在所有参与节点中执行和分发。如果两笔交易互相矛盾，那么最终被确认为后发生的交易将被拒绝，不会被包含到区块中。

​		作为“顺序选择机制”（也就是所谓的“挖矿”）的一部分，可能有时会发生块（blocks）被回滚的情况，但仅在链的“末端”。末端增加的块越多，其发生回滚的概率越小。因此你的交易被回滚甚至从区块链中抹除，这是可能的，但等待的时间越长，这种情况发生的概率就越小。

# 以太坊虚拟机

​		以太坊虚拟机 EVM 是智能合约的运行环境。它不仅是沙盒封装的，而且是完全隔离的，也就是说在 EVM 中运行代码是无法访问网络、文件系统和其他进程的。甚至智能合约之间的访问也是受限的。

## 账户

​		以太坊中有两类账户（它们共用同一个地址空间）： **外部账户** 由公钥-私钥对（也就是人）控制； **合约账户** 由和账户一起存储的代码控制。

​		外部账户的地址是由**公钥**决定的，而合约账户的地址是在**创建该合约时**确定的（这个地址通过合约创建者的地址和从该地址发出过的交易数量计算得到的，也就是所谓的“nonce”）。

​		每个账户都有一个键值对形式的持久化存储。其中 key 和 value 的长度都是256位，我们称之为 **存储** 。

​		此外，每个账户有一个以太币余额（ **balance** ）（单位是“Wei”），余额会因为发送包含以太币的交易而改变。

## 交易

​		交易可以看作是从一个帐户发送到另一个帐户的消息。它能包含一个二进制数据（合约负载）和以太币。

​		如果目标账户含有代码，此代码会被执行，并以 payload 作为入参。

​		如果目标账户是 **零账户（账户地址为 `0` )**，此交易将创建一个 **新合约** 。 如前文所述，合约的地址不是零地址，而是通过合约创建者的地址和从该地址发出过的交易数量计算得到的（所谓的“nonce”）。 这个用来创建合约的交易的 payload 会被转换为 EVM 字节码并执行。**执行的输出** 将作为 **合约代码** 被永久存储。这意味着，为创建一个合约，你不需要发送实际的合约代码，而是发送能够产生合约代码的代码。

> 在合约创建的过程中，它的代码还是空的。所以直到构造函数执行结束，你都不应该在其中调用合约自己函数。



## Gas

​		一经创建，每笔交易都收取一定数量的 **gas** ，目的是限制执行交易所需要的工作量和为交易支付手续费。EVM 执行交易时，gas 将按特定规则逐渐耗尽。

​		**gas price** 是交易发送者设置的一个值，发送者账户需要预付的手续费= `gas_price * gas` 。如果交易执行后还有剩余， gas 会原路返还。

​		无论执行到什么位置，一旦 gas 被耗尽（比如降为负值），将会触发一个 out-of-gas 异常。当前调用帧（call frame）所做的所有状态修改都将被回滚。



## 存储，内存和栈

​		每个账户有一块持久化内存区称为 **存储** 。 存储是将256位字映射到256位字的键值存储区。 在合约中枚举存储是不可能的，且读存储的相对开销很高，修改存储的开销甚至更高。合约只能读写存储区内属于自己的部分。

​		第二个内存区称为 **内存** ，合约会试图为每一次消息调用获取一块被重新擦拭干净的内存实例。 内存是线性的，可按字节级寻址，但读的长度被限制为256位，而写的长度可以是8位或256位。当访问（无论是读还是写）之前从未访问过的内存字（word）时（无论是偏移到该字内的任何位置），内存将按字进行扩展（每个字是256位）。扩容也将消耗一定的gas。 随着内存使用量的增长，其费用也会增高（以平方级别）。

​		EVM 不是基于寄存器的，而是基于栈的，因此所有的计算都在一个被称为 **栈（stack）** 的区域执行。 栈最大有1024个元素，每个元素长度是一个字（256位）。对栈的访问只限于其顶端，限制方式为：允许拷贝最顶端的16个元素中的一个到栈顶，或者是交换栈顶元素和下面16个元素中的一个。所有其他操作都只能取最顶的两个（或一个，或更多，取决于具体的操作）元素，运算后，把结果压入栈顶。当然可以把栈上的元素放到存储或内存中。但是无法只访问栈上指定深度的那个元素，除非先从栈顶移除其他元素。

## 指令集

​		EVM的指令集量应尽量少，以最大限度地避免可能导致共识问题的错误实现。所有的指令都是针对"256位的字（word）"这个基本的数据类型来进行操作。具备常用的算术、位、逻辑和比较操作。也可以做到有条件和无条件跳转。此外，合约可以访问当前区块的相关属性，比如它的编号和时间戳。

## 消息调用

​		合约可以通过消息调用的方式来调用其它合约或者发送以太币到非合约账户。消息调用和交易非常类似，它们都有一个源、目标、数据、以太币、gas和返回数据。事实上每个交易都由一个顶层消息调用组成，这个消息调用又可创建更多的消息调用。

​		合约可以决定在其内部的消息调用中，对于剩余的 **gas** ，应发送和保留多少。如果在内部消息调用时发生了out-of-gas异常（或其他任何异常），这将由一个被压入栈顶的错误值所指明。此时，只有与该内部消息调用一起发送的gas会被消耗掉。并且，Solidity中，发起调用的合约默认会触发一个手工的异常，以便异常可以从调用栈里“冒泡出来”。 如前文所述，被调用的合约（可以和调用者是同一个合约）会获得一块刚刚清空过的内存，并可以访问调用的payload——由被称为 calldata 的独立区域所提供的数据。调用执行结束后，返回数据将被存放在调用方预先分配好的一块内存中。 调用深度被 **限制** 为 1024 ，因此对于更加复杂的操作，我们应使用循环而不是递归。

## 委托调用/代码调用和库

​		有一种特殊类型的消息调用，被称为 **委托调用(delegatecall)** 。它和一般的消息调用的区别在于，目标地址的代码将在发起调用的合约的上下文中执行，并且 `msg.sender` 和 `msg.value` 不变。 这意味着一个合约可以在运行时从另外一个地址动态加载代码。存储、当前地址和余额都指向发起调用的合约，只有代码是从被调用地址获取的。 这使得 Solidity 可以实现”库“能力：可复用的代码库可以放在一个合约的存储上，如用来实现复杂的数据结构的库。

## 日志

​		有一种特殊的可索引的数据结构，其存储的数据可以一路映射直到区块层级。这个特性被称为 **日志(logs)** ，Solidity用它来实现 **事件(events)** 。合约创建之后就无法访问日志数据，但是这些数据可以从区块链外高效的访问。因为部分日志数据被存储在 [布隆过滤器（Bloom filter)](https://en.wikipedia.org/wiki/Bloom_filter) 中，我们可以高效并且加密安全地搜索日志，所以那些没有下载整个区块链的网络节点（轻客户端）也可以找到这些日志。

## 创建

​		合约甚至可以通过一个特殊的指令来创建其他合约（不是简单的调用零地址）。创建合约的调用 **create calls** 和普通消息调用的唯一区别在于，负载会被执行，执行的结果被存储为合约代码，调用者/创建者在栈上得到新合约的地址。

## 自毁

​		合约代码从区块链上移除的唯一方式是合约在合约地址上的执行自毁操作 `selfdestruct` 。合约账户上剩余的以太币会发送给指定的目标，然后其存储和代码从状态中被移除。

> 尽管一个合约的代码中没有显式地调用 `selfdestruct` ，它仍然有可能通过 `delegatecall` 或 `callcode` 执行自毁操作。

# solidity 语法

## 成员变量

### 类型

- `uint` :（256位无符号整数）

- `enum`:  枚举

   ```javascript
   enum State {Created, Locked, Inactive}
   ```

   

- `address` :（一个160位的值，且不允许任何算数操作，这种类型适合存储合约地址或外部人员的密钥对。）

   ```javascript
   // address(0)  是对象 ？
   while (voters[to].delegate != address(0)) {
     to = voters[to].delegate;
   
     // 不允许闭环委托
     require(to != msg.sender, "Found loop in delegation.");
   }
   ```

   

- `mapping (address => uint) public balances`:  Mappings 可以看作是一个 [哈希表](https://en.wikipedia.org/wiki/Hash_table) 它会执行虚拟初始化，以使所有可能存在的键都映射到一个字节表示为全零的值。

   ```javascript
   
   // 这声明了一个状态变量，为每个可能的地址存储一个 `Voter`。 类似一个 hash 表，key 是 address ，value 是 Voter
   mapping(address => Voter) public voters;
   ......
   Voter storage sender = voters[msg.sender];
   ......
   ```

   

- `event Sent(address from, address to, uint amount);` : 行声明了一个所谓的“事件（event）”.

  - 它会在 `send` 函数 ` emit Sent(msg.sender, receiver, amount);` 被发出。

    ```javascript
    function send(address receiver, uint amount) public {
      if (balances[msg.sender] < amount) return;
      balances[msg.sender] -= amount;
      balances[receiver] += amount;
      emit Sent(msg.sender, receiver, amount);
    }
    ```

  -  为了监听这个事件，你可以使用如下代码：

  - ```javascript
    Coin.Sent().watch({}, '', function(error, result) {
        if (!error) {
            console.log("Coin transfer: " + result.args.amount +
                " coins were sent from " + result.args.from +
                " to " + result.args.to + ".");
            console.log("Balances now:\n" +
                "Sender: " + Coin.balances.call(result.args.from) +
                "Receiver: " + Coin.balances.call(result.args.to));
        }
    })
    ```

- `struct`  : 结构体 

   ```javascript
    struct Voter {
      uint weight; // 计票的权重
      bool voted;  // 若为真，代表该人已投票
      address delegate; // 被委托人
      uint vote;   // 投票提案的索引
    }
   ```

- `Proposal[] public proposals;` : 数组类型

  ```javascript
  proposals.push(Proposal({
    name: proposalNames[i],
    voteCount: 0
  }));
  ```



### 修饰 关键字

- `public` （关键字“public”让这些变量可以从外部读取。关键字 public 自动生成一个函数，允许你在这个合约之外访问这个状态变量的当前值。如果没有这个关键字，其他的合约没有办法访问这个变量。）
- 



## 方法

### 修饰符

- `constructor`:  构造函数。

  ```javascript
  constructor(uint256 _biddingTime, address _beneficiary) public {
    chairperson = msg.sender;
    beneficiary = _beneficiary;
    auctionEnd = now + _biddingTime;
  }
  ```

- `function` : 定义方法。

  ```javascript
  function mint(address receiver, uint amount) public {
    if (msg.sender != minter) return;
    balances[receiver] += amount;
  }
  ```

- `public` :  可以被外部调用。

- `view`:  view的作用和constant一模一样，可以读取状态变量但是不能改。

  - 在Solidity中`constant`、`view`、`pure`三个函数修饰词的作用是告诉编译器，函数不改变/不读取状态变量，这样函数执行就可以不消耗gas了（是完全不消耗！），因为不需要矿工来验证。所以用好这几个关键词很重要，不言而喻，省gas就是省钱！

- `pure`: pure则更为严格，pure修饰的函数不能改也不能读状态变量，否则编译通不过。

  ```javascript
  pragma solidity ^0.4.21;
  contract constantViewPure{
    string name;
    uint public age;
  
    function constantViewPure() public{
      name = "liushiming";
      age = 29;
    }
  
    function getAgeByConstant() public constant returns(uint){
      age += 1;  //声明为constant，在函数体中又试图去改变状态变量的值，编译会报warning, 但是可以通过
      return age;  // return 30, 但是！状态变量age的值不会改变，仍然为29！
    } 
  
    function getAgeByView() public view returns(uint){
      age += 1; //view和constant效果一致，编译会报warning，但是可以通过
      return age; // return 30，但是！状态变量age的值不会改变，仍然为29！
    }
  
    function getAgeByPure() public pure returns(uint){
      return age; //编译报错！pure比constant和view都要严格，pure完全禁止读写状态变量！
      return 1;
    }
  }
  ```

  

- `returns (uint256 winningProposal_)`  : 定义合约返回类型

- `payable`: 。如果在调用合约的function call的时候发送一些以太币，那么这些以太币就会被added 到合约的总balance上，就像刚刚开始创建合约的时候会发送一些以太币也会作为合约的balance一样。但这样发送给合约balance的要求就是这个被调用的function必须要有payable标识，不然就会抛exception啦

  ```javascript
  function bid() public payable {
    // 参数不是必要的。因为所有的信息已经包含在了交易中。
    // 对于能接收以太币的函数，关键字 payable 是必须的。
  
    // 如果拍卖已结束，撤销函数的调用。
    require(now <= auctionEnd, "Auction already ended.");
  
    // 如果出价不够高，返还你的钱
    require(msg.value > highestBid, "There already is a higher bid.");
  
    if (highestBid != 0) {
      // 返还出价时，简单地直接调用 highestBidder.send(highestBid) 函数，
      // 是有安全风险的，因为它有可能执行一个非信任合约。
      // 更为安全的做法是让接收方自己提取金钱。
      pendingReturns[highestBidder] += highestBid;
    }
    highestBidder = msg.sender;
    highestBid = msg.value;
    emit HighestBidIncreased(msg.sender, msg.value);
  }
  ```

- `internal`: 这是一个 "internal" 函数， 意味着它只能在本合约（或继承合约）内被调用.

- `modifier`: 使用 `modifier` 可以更便捷的校验函数的入参。 `onlyBefore` 会被用于后面的 `bid` 函数：新的函数体是由 `modifier` 本身的函数体，并用原函数体替换 `_;` 语句来组成的。

  ```javascript
  modifier onlyBefore(uint256 _time) {
    require(now < _time);
    // bid 方法的逻辑会在这里插入
    _;
  }
  
  modifier onlyAfter(uint256 _time) {
    require(now > _time);
    // auctionEnd 的逻辑会在这里插入
    _;
  }
  
  function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd) {
    bids[msg.sender].push(
      Bid({blindedBid: _blindedBid, deposit: msg.value})
    );
  }
  
  function auctionEnd() public onlyAfter(revealEnd) {
    require(!ended);
    emit AuctionEnded(highestBidder, highestBid);
    ended = true;
    beneficiary.transfer(highestBid);
  }
  ```

  







### 入参修饰符



- `memory` :   `Memory` 变量则是临时的，当外部函数对某合约调用完成时，内存型变量即被移除。
  - 状态变量（在函数之外声明的变量）默认为“**storage**”形式，并永久写入区块链；而在函数内部声明的变量默认是“**memory**”型的，它们函数调用结束后消失。
- 



### 方法中对象 修饰符

- `storage`:  定义了变量的存储位置。而对于`storage`的变量，数据将永远存在于区块链上。

  ```javascript
  // 传引用
  Voter storage sender = voters[msg.sender];
  require(!sender.voted, "You already voted.");
  ```

  



## 语法

### 循环

- `for` : 
- 



### 特殊用户关键字

- `require` : 类似于 java 中的 `assert.notnull` 。 

  ```javascript
  // 若 `require` 的第一个参数的计算结果为 `false`，
  // 则终止执行，撤销所有对状态和以太币余额的改动。
  // 在旧版的 EVM 中这曾经会消耗所有 gas，但现在不会了。
  // 使用 require 来检查函数是否被正确地调用，是一个好习惯。
  // 你也可以在 require 的第二个参数中提供一个对错误情况的解释。
  require(
    msg.sender == chairperson,
    "Only chairperson can give right to vote."
  );
  ```

- `assembly`:  内嵌汇编。内联编译在当编译器没办法得到有效率的代码时非常有用

  ```javascript
  assembly {
    // retrieve the size of the code, this needs assembly
    let size := extcodesize(_addr)
    // allocate output byte array - this could also be done without assembly
    // by using o_code = new bytes(size)
    o_code := mload(0x40)
    // new "memory end" including padding
    mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
    // store length in memory
    mstore(o_code, size)
    // actually retrieve the code, this needs assembly
    extcodecopy(_addr, add(o_code, 0x20), 0, size)
  }
  ```

  





## 特殊功能函数
### 时间

- `now` :  [详见（需要翻墙）](https://zoom-blc.com/solidity-time-logic)
- 



## 特殊对象

### msg

- `msg.sender`
- `msg.value` 



### abi

- `abi.encodePacked(...) returns (bytes)` : 对给定参数执行 [紧打包编码](https://solidity-cn.readthedocs.io/zh/develop/abi-spec.html#abi-packed-mode) 
- `abi.soliditySHA3`:
- 



### web3







## 内置方法



- `keccak256(value, fake, secret)`：  keccak256加密

  ```javascript
  keccak256(abi.encodePacked(msg.sender, amount, nonce, this))
  ```

  

- `add`: 

- `mload`: 

- `ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)`:   `ecrecover`的思想是，可以计算对应于用于创建`ECDSA`签名的私钥的公钥，这两个额外的字节通常是由签名提供的。签名本身是椭圆曲线点R和S的两个（编码），而V是恢复公钥所需的两个附加位。

  它返回对应于恢复的公钥（即其sha3/keccak的哈希）的地址。这意味着要实际验证签名，检查返回的地址是否等于相应的私钥应该已经签署哈希的那个地址。

- `selfdestruct(msg.sender)` : 销毁合约 ， 回收剩余资金

- 