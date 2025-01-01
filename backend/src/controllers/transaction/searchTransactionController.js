import Transaction from "../../models/transaction.js";
import Category from "../../models/category.js";
import RecurringTransaction from "../../models/recurringTransaction.js";
import { Op } from 'sequelize';

export const searchTransactions = async (req, res) => {
    const { keyword, startDate, endDate, categoryId, minAmount, maxAmount, sort, page, pageSize } = req.query;
  
    try {
      const filters = {};
  
      // Lọc theo từ khóa
      if (keyword) {
        filters[Op.or] = [
          { note: { [Op.iLike]: `%${keyword}%` } },
          { '$category.name$': { [Op.iLike]: `%${keyword}%` } },
        ];
      }
  
      // Lọc theo khoảng thời gian
      if (startDate || endDate) {
        filters.date = {};
        if (startDate) filters.date[Op.gte] = new Date(startDate);
        if (endDate) filters.date[Op.lte] = new Date(endDate);
      }
  
      // Lọc theo danh mục
      if (categoryId) {
        filters.categoryId = categoryId;
      }
  
      // Lọc theo số tiền
      if (minAmount || maxAmount) {
        filters.amount = {};
        if (minAmount) filters.amount[Op.gte] = parseFloat(minAmount);
        if (maxAmount) filters.amount[Op.lte] = parseFloat(maxAmount);
      }
  
      // Xử lý sắp xếp
      const order = [];
      if (sort) {
        const [field, direction] = sort.split(':');
        if (['date', 'amount'].includes(field) && ['asc', 'desc'].includes(direction)) {
          order.push([field, direction.toUpperCase()]);
        }
      } else {
        // Mặc định sắp xếp theo ngày giảm dần
        order.push(['date', 'DESC']);
      }
  
      // Phân trang
      const pageNum = parseInt(page, 10) || 1;
      const itemsPerPage = parseInt(pageSize, 10) || 10;
      const offset = (pageNum - 1) * itemsPerPage;
      const limit = itemsPerPage;
  
      // Truy vấn giao dịch với phân trang
      const transactions = await Transaction.findAndCountAll({
        where: filters,
        include: [
          { model: Category, as: 'category' }, // Thêm bảng Category vào truy vấn
        ],
        order,
        limit,
        offset,
      });
  
      res.status(200).json({
        total: transactions.count,
        transactions: transactions.rows,
        currentPage: pageNum,
        totalPages: Math.ceil(transactions.count / itemsPerPage),
      });
    } catch (error) {
      res.status(500).json({ error: 'Lỗi khi tìm kiếm giao dịch', details: error.message });
    }
};

export const searchRecurringTransactions = async (req, res) => {
  const { keyword, categoryId, frequency } = req.query;

  try {
    const filters = { userId: req.user.id };

    // Tìm theo từ khóa trong ghi chú
    if (keyword) {
      filters.note = { [Op.iLike]: `%${keyword}%` };
    }

    // Lọc theo danh mục
    if (categoryId) {
      filters.categoryId = categoryId;
    }

    // Lọc theo tần suất
    if (frequency) {
      filters.frequency = frequency;
    }

    const recurringTransactions = await RecurringTransaction.findAll({
      where: filters,
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name'] },
      ],
    });

    res.status(200).json(recurringTransactions);
  } catch (error) {
    console.error('Error while searching recurring transactions:', error);
    res.status(500).json({ error: error.message });
  }
};
