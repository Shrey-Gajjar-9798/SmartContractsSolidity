pragma solidity ^0.8.0;

///import

contract MyNft {

//here we are using the contract balance for transfering the ethers to another account.    
//1. we are storing the ethers to contract and then send to customer using transfer.
//2. the difference bet. transfer and send is in (send and calldata) fucntion it "require is required";

    address payable customer = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);

    receive() external payable {}

    function send() external {
        customer.transfer(1 ether);
    }

    function contractBalance() external  view returns(uint) {
        return address(this).balance;
    }

    function call() external {
        (bool send, bytes memory data) = customer.call{value: 1 ether}("");//we can set the gas limit in call fucntion also catch the data which it returns in bytes.
        require(send,"failed to transfer");
    }
}