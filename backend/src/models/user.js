import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js'; 
import Category from './category.js'; 

const User = sequelize.define(
  'User',
  {
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true, // Đảm bảo email là duy nhất
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    tableName: 'users', 
    timestamps: false,  
  }
);

export default User;
