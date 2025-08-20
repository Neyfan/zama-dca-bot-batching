// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PrivateDCA {
    struct Order {
        address user;
        uint256 amount;
    }

    mapping(address => Order[]) public orders;

    event OrderStored(address indexed user, uint256 amount);

    /// @notice Сохраняет новый ордер для пользователя
    function storeOrder(address user, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        orders[user].push(Order(user, amount));
        emit OrderStored(user, amount);
    }

    /// @notice Возвращает ордер по индексу для конкретного пользователя
    function getOrder(address user, uint256 index) external view returns (Order memory) {
        require(index < orders[user].length, "Invalid order index");
        return orders[user][index];
    }

    /// @notice Возвращает количество ордеров пользователя
    function getOrderCount(address user) external view returns (uint256) {
        return orders[user].length;
    }
}
