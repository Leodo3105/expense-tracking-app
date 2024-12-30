import Transaction from '../../models/transaction.js';
import Category from '../../models/category.js';
import RecurringTransaction from '../../models/recurringTransaction.js';
import Sequelize, { Op } from 'sequelize';

export const getMonthlyOverview = async (req, res) => {
  const { month, year } = req.query;

  try {
    const startDate = new Date(year, month - 1, 1); // Ngày đầu tháng
    const endDate = new Date(year, month, 0); // Ngày cuối tháng

    // Lấy tổng thu nhập và chi tiêu từ giao dịch thông thường
    const transactions = await Transaction.findAll({
      attributes: [
        [Sequelize.fn('SUM', Sequelize.col('amount')), 'totalAmount'],
        'categoryId',
      ],
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['type'],
        },
      ],
      where: {
        userId: req.user.id,
        date: { [Op.between]: [startDate, endDate] },
      },
      group: ['Transaction.categoryId', 'category.id', 'category.type'],
    });

    let totalIncome = 0;
    let totalExpense = 0;

    transactions.forEach((transaction) => {
      const categoryType = transaction.category?.type;
      const amount = parseFloat(transaction.dataValues.totalAmount || 0);
      if (categoryType === 'income') {
        totalIncome += amount;
      } else if (categoryType === 'expense') {
        totalExpense += amount;
      }
    });

    // Lấy tổng thu nhập và chi tiêu từ giao dịch định kỳ
    const recurringTransactions = await RecurringTransaction.findAll({
      where: {
        userId: req.user.id,
        nextDate: { [Op.between]: [startDate, endDate] },
      },
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['type'],
        },
      ],
    });
    
    recurringTransactions.forEach((recurring) => {
      const categoryType = recurring.category?.type;
      const amount = parseFloat(recurring.amount || 0);
      if (categoryType === 'income') {
        totalIncome += amount;
      } else if (categoryType === 'expense') {
        totalExpense += amount;
      }
    });
    

    res.status(200).json({
      month,
      year,
      totalIncome,
      totalExpense,
      balance: totalIncome - totalExpense,
    });
  } catch (error) {
    console.error('Error while fetching monthly overview:', error);
    res.status(500).json({ error: error.message });
  }
};








// export const getStatisticsByCategory = async (req, res) => {
//     const { month, year } = req.query;
  
//     try {
//       const startDate = new Date(year, month - 1, 1);
//       const endDate = new Date(year, month, 0);
  
//       const stats = await Transaction.findAll({
//         attributes: [
//           'categoryId',
//           [sequelize.fn('SUM', sequelize.col('amount')), 'totalAmount'],
//         ],
//         where: {
//           userId: req.user.id,
//           date: { [Op.between]: [startDate, endDate] },
//         },
//         group: ['categoryId'],
//         include: [
//           {
//             model: Category,
//             as: 'category',
//             attributes: ['name', 'type'],
//           },
//         ],
//       });
  
//       res.status(200).json(stats);
//     } catch (error) {
//       console.error('Error while fetching statistics by category:', error);
//       res.status(500).json({ error: error.message });
//     }
// };

// export const getStatisticsByTime = async (req, res) => {
//     const { startDate, endDate } = req.query;
  
//     try {
//       const stats = await Transaction.findAll({
//         attributes: [
//           [sequelize.fn('DATE', sequelize.col('date')), 'date'],
//           [sequelize.fn('SUM', sequelize.col('amount')), 'totalAmount'],
//         ],
//         where: {
//           userId: req.user.id,
//           date: { [Op.between]: [startDate, endDate] },
//         },
//         group: ['date'],
//         order: [[sequelize.literal('date'), 'ASC']],
//       });
  
//       res.status(200).json(stats);
//     } catch (error) {
//       console.error('Error while fetching statistics by time:', error);
//       res.status(500).json({ error: error.message });
//     }
// };

export const getCategorySpendingRatio = async (req, res) => {
  const { month, year, type } = req.query;

  try {
    // Xác định khoảng thời gian
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    // Kiểm tra và xác định loại giao dịch (income/expense)
    if (!['income', 'expense'].includes(type)) {
      return res.status(400).json({ error: "Type must be 'income' or 'expense'." });
    }

    // Tổng số tiền giao dịch theo loại
    const totalTransaction = await Transaction.sum('amount', {
      include: [
        {
          model: Category,
          as: 'category',
          where: { type }, // Lọc theo cột `type` trong bảng `Category`
        },
      ],
      where: {
        userId: req.user.id,
        date: { [Op.between]: [startDate, endDate] },
      },
    });
    const categoryStats = await Transaction.findAll({
      attributes: [
        'categoryId', // Thuộc Transaction
        [sequelize.fn('SUM', sequelize.col('amount')), 'categoryTotal'], // SUM amount
      ],
      where: {
        userId: req.user.id,
        date: { [Op.between]: [startDate, endDate] },
      },
      include: [
        {
          model: Category,
          as: 'category', // Alias phải khớp với định nghĩa trong belongsTo
          attributes: ['id', 'name'], // Các cột cần lấy từ Category
        },
      ],
      group: ['Transaction.categoryId', 'category.id', 'category.name'], // Đảm bảo GROUP BY đầy đủ
    });
    
    // Tính toán tỷ lệ phần trăm
    const statsWithRatio = categoryStats.map((stat) => ({
      category: stat.category.name,
      total: parseFloat(stat.dataValues.categoryTotal),
      percentage: ((stat.dataValues.categoryTotal / totalTransaction) * 100).toFixed(2),
    }));

    res.status(200).json(statsWithRatio);
  } catch (error) {
    console.error('Error while fetching category spending ratio:', error);
    res.status(500).json({ error: error.message });
  }
};

  
  

  