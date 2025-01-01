import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const RecurringTransaction = sequelize.define('RecurringTransaction', {
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  categoryId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  note: {
    type: DataTypes.TEXT,
  },
  frequency: {
    type: DataTypes.ENUM('daily', 'weekly', 'monthly'),
    allowNull: false,
  },
  nextDate: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'recurring_transactions',
  timestamps: true,
});

export default RecurringTransaction;
