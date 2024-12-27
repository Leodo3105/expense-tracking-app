import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';
import User from './user.js';

const Category = sequelize.define(
  'Category',
  {
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    type: {
      type: DataTypes.ENUM('income', 'expense'), 
      allowNull: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false, 
    },
  },
  {
    tableName: 'categories', 
    timestamps: false, 
  }
);

export default Category;
