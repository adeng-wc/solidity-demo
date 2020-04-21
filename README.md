# solidity 语法

## 成员变量 类型

- `uint` （256位无符号整数）

- `address` （一个160位的值，且不允许任何算数操作，这种类型适合存储合约地址或外部人员的密钥对。）

- `mapping (address => uint) public balances`  Mappings 可以看作是一个 [哈希表](https://en.wikipedia.org/wiki/Hash_table) 它会执行虚拟初始化，以使所有可能存在的键都映射到一个字节表示为全零的值。

- `event Sent(address from, address to, uint amount);`  行声明了一个所谓的“事件（event）”.

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

  - 

## 成员变量 关键字

- `public` （关键字“public”让这些变量可以从外部读取。关键字 public 自动生成一个函数，允许你在这个合约之外访问这个状态变量的当前值。如果没有这个关键字，其他的合约没有办法访问这个变量。）
- 

