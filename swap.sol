pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{function transferFrom(address,address,uint)external;}
contract Swap{
    uint public fee=9999;
    address private _owner;
    mapping(address=>mapping(address=>uint[2]))public pairs;
    constructor(){
        _owner=msg.sender;
    }
    modifier OnlyOwner(){
        require(_owner==msg.sender);_;
    }
    function addLiqudity(address conAddr1,address conAddr2,uint amount1,uint amount2)external payable OnlyOwner{unchecked{
        IERC20(conAddr1).transferFrom(msg.sender,address(this),amount1);
        IERC20(conAddr2).transferFrom(msg.sender,address(this),amount2);
        (pairs[conAddr1][conAddr2][0]+=amount1,pairs[conAddr1][conAddr2][1]+=amount2,
        pairs[conAddr2][conAddr1][0]+=amount2,pairs[conAddr2][conAddr1][1]+=amount1);
    }}
    function RemoveLiqudity(address conAddr1,address conAddr2,uint amount1,uint amount2)external payable OnlyOwner{unchecked{
        require(_owner==msg.sender);
        IERC20(conAddr1).transferFrom(address(this),msg.sender,amount1);
        IERC20(conAddr2).transferFrom(address(this),msg.sender,amount2);
        (pairs[conAddr1][conAddr2][0]-=amount1,pairs[conAddr1][conAddr2][1]-=amount2,
        pairs[conAddr2][conAddr1][0]-=amount2,pairs[conAddr2][conAddr1][1]-=amount1);
    }}
    function setFee(uint percent)external OnlyOwner{
        fee=percent;
    }
    function exchange(address conAddr1,address conAddr2,uint amount1)external payable{unchecked{
        uint amount2=getPrice(conAddr1,conAddr2,amount1);
        require(amount2>0);
        require(amount2<=pairs[conAddr1][conAddr2][1]);
        IERC20(conAddr1).transferFrom(msg.sender,address(this),amount1);
        IERC20(conAddr2).transferFrom(address(this),msg.sender,amount2);
        (pairs[conAddr1][conAddr2][0]+=amount1,pairs[conAddr1][conAddr2][1]-=amount2,
        pairs[conAddr2][conAddr1][0]-=amount2,pairs[conAddr2][conAddr1][1]+=amount1);
    }}
    function getPrice(address conAddr1,address conAddr2,uint amount)public view returns(uint){{
        return pairs[conAddr1][conAddr2][1]*amount/pairs[conAddr1][conAddr2][0]*fee/10000;
    }}
}
