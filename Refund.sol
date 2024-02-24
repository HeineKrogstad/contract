// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Импортируем интерфейс Crowdfunding
interface Crowdfunding {
    function getContributionInfo(address contributor) external view returns (uint);
}

contract DoublingContract {
    address public crowdfundingContract;

    event FundsDoubled(address recipient, uint originalAmount, uint doubledAmount);
    event FundsDeposited(address depositor, uint amount);

    // Функция для установки адреса контракта Crowdfunding
    function setCrowdfundingContract(address _crowdfundingContract) public {
        crowdfundingContract = _crowdfundingContract;
    }

    // Функция для удвоения взноса
    function doubleContribution(address recipient) public {
        // Проверяем, что адрес контракта Crowdfunding установлен
        require(crowdfundingContract != address(0), "Crowdfunding contract address not set");

        // Получаем информацию о взносе из контракта Crowdfunding
        uint originalAmount = Crowdfunding(crowdfundingContract).getContributionInfo(recipient);

        // Проверка наличия средств в контракте
        require(address(this).balance >= originalAmount * 2, "Insufficient funds in the contract");

        // Удваиваем взнос
        payable(recipient).transfer(originalAmount * 2);

        // Вызываем событие для отслеживания удвоения средств
        emit FundsDoubled(recipient, originalAmount, originalAmount * 2);
    }

    // Функция для внесения средств в контракт
    function depositFunds() public payable {
        // Вызываем событие для отслеживания внесения средств
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Функция для получения баланса контракта
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}


