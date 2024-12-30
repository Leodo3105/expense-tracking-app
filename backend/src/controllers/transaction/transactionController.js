import Transaction from "../../models/transaction.js";
import Category from "../../models/category.js";
import Notification from '../../models/notification.js';
import User from '../../models/user.js';
import { Op } from 'sequelize';

export const addTransaction = async (req, res) => {
  const { amount, date, categoryId, categoryName, note } = req.body;

  try {
    let category;

    // Kiểm tra nếu `categoryId` được gửi
    if (categoryId) {
      category = await Category.findOne({
        where: { id: categoryId, userId: req.user.id },
      });

      if (!category) {
        return res.status(404).json({ error: 'Danh mục không tồn tại!' });
      }
    } else if (categoryName) {
      // Kiểm tra xem danh mục có trùng lặp không
      category = await Category.findOne({
        where: { name: categoryName, userId: req.user.id },
      });

      // Nếu không tồn tại, tạo danh mục mới
      if (!category) {
        category = await Category.create({
          name: categoryName,
          type: "expense", // Loại mặc định là `expense`
          userId: req.user.id,
        });
      }
    } else {
      return res.status(400).json({ error: 'Cần chọn danh mục hoặc cung cấp thông tin danh mục mới!' });
    }

    // Tạo giao dịch
    const transaction = await Transaction.create({
      amount,
      type: category.type, // Loại giao dịch từ danh mục
      date,
      categoryId: category.id, // Liên kết danh mục
      userId: req.user.id,
      note,
    });

    // Gửi thông báo cho người dùng
    await Notification.create({
      userId: req.user.id,
      type: 'success',
      message: `Giao dịch của bạn (${amount} - ${note}) đã được tạo thành công.`,
    });

    // Kiểm tra hạn mức chi tiêu
    const user = await User.findByPk(req.user.id);

    if (user && user.spendingLimit) {
      const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1); // Đầu tháng hiện tại
      const totalSpending = await Transaction.sum('amount', {
        where: {
          userId: req.user.id,
          type: 'expense', // Chỉ tính chi tiêu
          date: { [Op.gte]: startOfMonth }, // Các giao dịch từ đầu tháng
        },
      });

      // Nếu tổng chi tiêu vượt hạn mức, gửi thông báo cảnh báo
      if (totalSpending > user.spendingLimit) {
        await Notification.create({
          userId: req.user.id,
          type: 'alert',
          message: `Cảnh báo: Bạn đã vượt hạn mức chi tiêu của tháng này. Hạn mức: ${user.spendingLimit}, tổng chi tiêu hiện tại: ${totalSpending}.`,
        });
      }
    }

    // Bao gồm thông tin danh mục trong phản hồi
    const response = {
      ...transaction.dataValues,
      category: {
        name: category.name,
        type: category.type,
      },
    };

    res.status(201).json(response);
  } catch (error) {
    console.error('Error while adding transaction:', error);
    res.status(500).json({ error: error.message });
  }
};
  
export const updateTransaction = async (req, res) => {
  const { id } = req.params;
  const { amount, date, categoryId, note } = req.body;

  try {
    // Tìm giao dịch thuộc người dùng hiện tại
    const transaction = await Transaction.findOne({
      where: { id, userId: req.user.id },
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Giao dịch không tồn tại!' });
    }

    // Nếu có categoryId, kiểm tra danh mục
    if (categoryId) {
      const category = await Category.findOne({
        where: { id: categoryId, userId: req.user.id },
      });

      if (!category) {
        return res.status(404).json({ error: 'Danh mục không tồn tại!' });
      }

      transaction.categoryId = category.id;
      transaction.type = category.type; // Cập nhật loại giao dịch theo danh mục
    }

    // Cập nhật các thông tin khác
    transaction.amount = amount || transaction.amount;
    transaction.date = date || transaction.date;
    transaction.note = note || transaction.note;

    await transaction.save();

    // Gửi thông báo cho người dùng
    await Notification.create({
      userId: req.user.id,
      type: 'success',
      message: `Giao dịch của bạn (${transaction.amount} - ${transaction.note}) đã được cập nhật thành công.`,
    });

    res.status(200).json(transaction);
  } catch (error) {
    console.error('Error while updating transaction:', error);
    res.status(500).json({ error: error.message });
  }
};
  
export const getTransactions = async (req, res) => {
  try {
    // Lấy tất cả giao dịch của người dùng
    const transactions = await Transaction.findAll({
      where: { userId: req.user.id }, // Chỉ lấy giao dịch của người dùng hiện tại
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['name', 'type'],
        },
      ],
    });

    res.status(200).json(transactions);
  } catch (error) {
    console.error('Error while fetching transactions:', error);
    res.status(500).json({ error: error.message });
  }
};


export const getTransactionById = async (req, res) => {
  const { id } = req.params;

  try {
    // Truy vấn giao dịch theo ID, bao gồm thông tin danh mục
    const transaction = await Transaction.findOne({
      where: { id },
      include: [{ model: Category, as: 'category' }],
    });

    // Nếu không tìm thấy, trả về lỗi
    if (!transaction) {
      return res.status(404).json({ error: 'Giao dịch không tồn tại' });
    }

    res.status(200).json(transaction);
  } catch (error) {
    res.status(500).json({ error: 'Lỗi khi lấy chi tiết giao dịch', details: error.message });
  }
};

export const deleteTransaction = async (req, res) => {
    const { id } = req.params;
  
    try {
      const transaction = await Transaction.findOne({
        where: { id, userId: req.user.id },
      });
  
      if (!transaction) {
        return res.status(404).json({ error: 'Giao dịch không tồn tại!' });
      }
  
      // Lưu thông tin giao dịch trước khi xóa (cho log hoặc phản hồi)
      const deletedTransaction = { ...transaction.dataValues };
  
      await transaction.destroy();
  
      res.status(200).json({
        message: 'Giao dịch đã được xóa thành công!',
        transaction: deletedTransaction,
      });
    } catch (error) {
      console.error('Error while deleting transaction:', error);
      res.status(500).json({ error: error.message });
    }
};

