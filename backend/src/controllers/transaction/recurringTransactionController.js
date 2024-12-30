import RecurringTransaction from '../../models/recurringTransaction.js';
import Notification from '../../models/notification.js';
import dayjs from "dayjs";

export const addRecurringTransaction = async (req, res) => {
  const { categoryId, amount, note, frequency } = req.body;

  try {
    // Tính toán nextDate dựa trên frequency
    const today = dayjs();
    let nextDate;

    switch (frequency) {
      case "daily":
        nextDate = today.add(1, "day").format("YYYY-MM-DD");
        break;
      case "weekly":
        nextDate = today.add(1, "week").format("YYYY-MM-DD");
        break;
      case "monthly":
        nextDate = today.add(1, "month").format("YYYY-MM-DD");
        break;
      default:
        return res.status(400).json({ error: "Invalid frequency value" });
    }

    // Tạo giao dịch định kỳ
    const recurringTransaction = await RecurringTransaction.create({
      userId: req.user.id,
      categoryId,
      amount,
      note,
      frequency,
      nextDate,
    });

    // Gửi thông báo cho người dùng
    await Notification.create({
      userId: req.user.id,
      type: "success",
      message: `Giao dịch định kỳ của bạn (${amount} - ${note}) với tần suất ${frequency} đã được tạo thành công.`,
    });

    res.status(201).json(recurringTransaction);
  } catch (error) {
    console.error("Error while adding recurring transaction:", error);
    res.status(500).json({ error: error.message });
  }
};

export const getRecurringTransactions = async (req, res) => {
    try {
      const recurringTransactions = await RecurringTransaction.findAll({
        where: { userId: req.user.id },
      });
  
      res.status(200).json(recurringTransactions);
    } catch (error) {
      console.error('Error while fetching recurring transactions:', error);
      res.status(500).json({ error: error.message });
    }
};

export const getRecurringTransactionById = async (req, res) => {
  const { id } = req.params;

  try {
    const recurringTransaction = await RecurringTransaction.findOne({
      where: {
        id,
        userId: req.user.id, // Đảm bảo giao dịch thuộc về người dùng hiện tại
      },
    });

    if (!recurringTransaction) {
      return res.status(404).json({ error: 'Giao dịch định kỳ không tồn tại!' });
    }

    res.status(200).json(recurringTransaction);
  } catch (error) {
    console.error('Error while fetching recurring transaction:', error);
    res.status(500).json({ error: error.message });
  }
};

export const updateRecurringTransaction = async (req, res) => {
  const { id } = req.params;
  const { categoryId, amount, note, frequency } = req.body; // Loại bỏ `nextDate` khỏi body

  try {
    // Tìm giao dịch định kỳ theo ID và userId
    const recurringTransaction = await RecurringTransaction.findOne({
      where: {
        id,
        userId: req.user.id, // Đảm bảo giao dịch thuộc về người dùng hiện tại
      },
    });

    if (!recurringTransaction) {
      return res.status(404).json({ error: "Giao dịch định kỳ không tồn tại!" });
    }

    // Cập nhật các trường 
    if (categoryId !== undefined) recurringTransaction.categoryId = categoryId;
    if (amount !== undefined) recurringTransaction.amount = amount;
    if (note !== undefined) recurringTransaction.note = note;
    if (frequency !== undefined) recurringTransaction.frequency = frequency;

    await recurringTransaction.save();

    // Gửi thông báo cho người dùng
    await Notification.create({
      userId: req.user.id,
      type: "success",
      message: `Giao dịch định kỳ của bạn (${recurringTransaction.amount} - ${recurringTransaction.note}) đã được cập nhật thành công.`,
    });

    res.status(200).json(recurringTransaction);
  } catch (error) {
    console.error("Error while updating recurring transaction:", error);
    res.status(500).json({ error: error.message });
  }
};

export const deleteRecurringTransaction = async (req, res) => {
  const { id } = req.params;

  try {
    const recurringTransaction = await RecurringTransaction.findOne({
      where: {
        id,
        userId: req.user.id, // Đảm bảo giao dịch thuộc về người dùng hiện tại
      },
    });

    if (!recurringTransaction) {
      return res.status(404).json({ error: 'Giao dịch định kỳ không tồn tại!' });
    }

    await recurringTransaction.destroy();

    res.status(200).json({ message: 'Giao dịch định kỳ đã được xóa thành công!' });
  } catch (error) {
    console.error('Error while deleting recurring transaction:', error);
    res.status(500).json({ error: error.message });
  }
};
