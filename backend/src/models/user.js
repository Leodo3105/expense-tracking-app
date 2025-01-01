import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js'; 

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
      unique: true, 
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    spendingLimit: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
      defaultValue: null,
    },
  },
  {
    tableName: 'users', 
    timestamps: false,  
  }
);

export default User;
