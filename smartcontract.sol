// SPDX-License-Identifier: MIT
// Указываем версию Solidity для компилятора
pragma solidity ^0.8.0;

// Объявляем контракт
contract Crowdfunding {

    // Переменные для хранения информации о сборе средств
    address public creator; // Адрес создателя контракта
    uint public goalAmount; // Целевая сумма для сбора
    uint public deadline; // Сроки сбора средств в timestamp
    uint public totalAmount; // Общая сумма, собранная на данный момент
    mapping(address => uint) public contributions; // Маппинг для хранения внесенных средств каждого участника

    // События для отслеживания изменений
    event ContributionMade(address contributor, uint amount);
    event FundsReleased();

    // Конструктор контракта, устанавливающий параметры сбора
    constructor(uint _goalAmount, uint _durationMinutes) {
        creator = msg.sender;
        goalAmount = _goalAmount * 1 ether; // Преобразуем сумму в wei
        deadline = block.timestamp + (_durationMinutes * 1 minutes); // Устанавливаем сроки в timestamp
    }

    // Функция для внесения средств
    function contribute() public payable {
        require(block.timestamp < deadline, "The fundraising period has expired");
        require(totalAmount + msg.value <= goalAmount, "The target amount has been exceeded");
        
        contributions[msg.sender] += msg.value;
        totalAmount += msg.value;
        
        emit ContributionMade(msg.sender, msg.value);
    }

    // Функция для проверки состояния и выпуска средств
    function releaseFunds() public {
        require(block.timestamp >= deadline, "The fundraising has not been completed yet");
        require(totalAmount >= goalAmount, "The target amount has not been reached");

        // Отправляем средства создателю контракта
        payable(creator).transfer(totalAmount);
        
        emit FundsReleased();
    }

    // Функция для возврата средств в случае не достижения целевой суммы
    function refund() public {
        require(block.timestamp >= deadline, "The fundraising has not been completed yet");
        require(totalAmount < goalAmount, "The target amount has been reached");

        uint amountToRefund = contributions[msg.sender];
        require(amountToRefund > 0, "You have not deposited any funds");

        // Возвращаем средства участнику
        payable(msg.sender).transfer(amountToRefund);

        contributions[msg.sender] = 0;
    }
}
