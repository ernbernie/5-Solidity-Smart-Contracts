//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
 
contract Lottery{
    
    // declaring the state variables - only 2 state variables
    address payable[] public players; //dynamic array of type address - payable modifier so we can transfer the funds to the address
    address public manager; 
    
    constructor(){
        // sets the owner to the address that deploys the contract
        manager = msg.sender;
    }
    
    // declaring the receive() function that is necessary to receive ETH
    receive () payable external{
        require(msg.value == 0.1 ether); // .1 eth is an arbitrary number
        // appending the player to the players array to be available to be chosen
        players.push(payable(msg.sender));
    }
    
    // returning the contract's balance in wei
    function getBalance() public view returns(uint){
        require(msg.sender == manager); // only the manager is allowed to call it
        return address(this).balance;
    }
    
    // helper function that returns a big random integer
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    
    // selecting the winner
    function pickWinner() public{
        // only the manager can pick a winner if there are at least 5 players in the lottery
        require(msg.sender == manager);
        require (players.length >= 5);
        
        uint r = random();
        address payable winner;
        
        // computing a random index of the array to choose winner
        uint index = r % players.length; 
    
        winner = players[index]; // winner is chosen by randomizing array index position

        uint managerFee = (getBalance() * 10 ) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90 ) / 100;     // winner prize is 90%
        
        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);

        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);
        
        // resetting the lottery for the next round
        players = new address payable[](0);
    }
 
}