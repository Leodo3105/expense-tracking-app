import Transaction from "../../models/transaction.js";
import Category from "../../models/category.js";
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
  
      res.status(200).json(transaction);
    } catch (error) {
      console.error('Error while updating transaction:', error);
      res.status(500).json({ error: error.message });
    }
};
  
export const getTransactions = async (req, res) => {
    const { startDate, endDate, page = 1, limit = 10, sortBy = 'date', search } = req.query;
  
    try {
      const whereCondition = { userId: req.user.id };
  
      // Lọc theo thời gian
      if (startDate && endDate) {
        whereCondition.date = {
          [Op.between]: [startDate, endDate],
        };
      }
  
      // Tìm kiếm theo ghi chú
      if (search) {
        whereCondition.note = {
          [Op.like]: `%${search}%`,
        };
      }
  
      // Phân trang và sắp xếp
      const offset = (page - 1) * limit;
  
      const transactions = await Transaction.findAndCountAll({
        where: whereCondition,
        include: [
          {
            model: Category,
            as: 'category',
            attributes: ['name', 'type'],
          },
        ],
        order: [[sortBy, 'ASC']], // Sắp xếp theo trường được chỉ định
        limit: parseInt(limit, 10),
        offset,
      });
  
      res.status(200).json({
        total: transactions.count,
        transactions: transactions.rows,
        currentPage: parseInt(page, 10),
        totalPages: Math.ceil(transactions.count / limit),
      });
    } catch (error) {
      console.error('Error while fetching transactions:', error);
      res.status(500).json({ error: error.message });
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
  