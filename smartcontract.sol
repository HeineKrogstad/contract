// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    address public creator;
    string public companyName;
    uint public goalAmount;
    uint public deadline;
    uint public totalAmount;
    mapping(address => uint) public contributions;
    address public doublingContract;

    event ContributionMade(address contributor, uint amount);
    event FundsReleased();

    constructor(uint _goalAmount, uint _durationMinutes, string memory _companyName) {
        creator = msg.sender;
        companyName = _companyName;
        goalAmount = _goalAmount * 1 ether;
        deadline = block.timestamp + (_durationMinutes * 1 minutes);
    }

    function setDoublingContractAddress(address _doublingContract) public {
        doublingContract = _doublingContract;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "The fundraising period has expired");
        require(totalAmount + msg.value <= goalAmount, "The target amount has been exceeded");
        
        contributions[msg.sender] += msg.value;
        totalAmount += msg.value;
        
        emit ContributionMade(msg.sender, msg.value);
    }

    function timeRemaining() public view returns (uint) {
        require(block.timestamp < deadline, "Contract has already ended");
        return deadline - block.timestamp;
    }

    function releaseFunds() public {
        require(block.timestamp >= deadline, "The fundraising has not been completed yet");
        require(totalAmount >= goalAmount, "The target amount has not been reached");

        payable(creator).transfer(totalAmount);
        
        emit FundsReleased();

        if (doublingContract != address(0)) {
            DoublingContract(doublingContract).doubleContribution(creator, totalAmount);
        }
    }

    function refund() public {
        require(block.timestamp >= deadline, "The fundraising has not been completed yet");
        require(totalAmount < goalAmount, "The target amount has been reached");

        uint amountToRefund = contributions[msg.sender];
        require(amountToRefund > 0, "You have not deposited any funds");

        payable(msg.sender).transfer(amountToRefund);

        contributions[msg.sender] = 0;
    }

    function getCompanyName() public view returns (string memory) {
        return companyName;
    }
}
