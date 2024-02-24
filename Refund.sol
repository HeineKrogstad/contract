// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DoublingContract {
    address public crowdfundingContract;

    event FundsDoubled(address recipient, uint originalAmount, uint doubledAmount);

    function setCrowdfundingContractAddress(address _crowdfundingContract) external {
        crowdfundingContract = _crowdfundingContract;
    }

    function doubleContribution(address recipient, uint amount) public {
        require(crowdfundingContract != address(0), "Crowdfunding contract address not set");
        
        // Получаем информацию о взносе из контракта Crowdfunding
        uint originalAmount = Crowdfunding(crowdfundingContract).getContributionInfoFromDoublingContract(msg.sender);
        
        // Проверка наличия средств в контракте
        require(address(this).balance >= originalAmount * 2, "Insufficient funds in the contract");
        
        // Удваиваем взнос
        payable(recipient).transfer(originalAmount * 2);

        // Вызываем событие для отслеживания удвоения средств
        emit FundsDoubled(recipient, originalAmount, originalAmount * 2);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}


