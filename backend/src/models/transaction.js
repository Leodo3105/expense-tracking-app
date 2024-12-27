import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';
import Category from './category.js';

const Transaction = sequelize.define(
    'Transaction',
    {
      amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
      },
      date: {
        type: DataTypes.DATE,
        allowNull: false,
      },
      categoryId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      note: {
        type: DataTypes.STRING, // Ghi chú cho giao dịch
        allowNull: true, // Tùy chọn, không bắt buộc
      },
    },
    {
      tableName: 'transactions',
      timestamps: false,
    }
);


export default Transaction;
  