import Category from './category.js';
import Transaction from './transaction.js';
import User from './user.js';

const associateModels = () => {
  // Category -> Transaction
  Category.hasMany(Transaction, { foreignKey: 'categoryId', as: 'transactions' });
  Transaction.belongsTo(Category, { foreignKey: 'categoryId', as: 'category' });

  // User -> Category
  User.hasMany(Category, { foreignKey: 'userId', as: 'categories' });
  Category.belongsTo(User, { foreignKey: 'userId', as: 'user' });

  // User -> Transaction
  User.hasMany(Transaction, { foreignKey: 'userId', as: 'transactions' });
  Transaction.belongsTo(User, { foreignKey: 'userId', as: 'user' });
};

export default associateModels;
