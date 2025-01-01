import cron from 'node-cron';
import RecurringTransaction from '../models/recurringTransaction.js';
import Transaction from '../models/transaction.js';
import Notification from '../models/notification.js';
import User from '../models/user.js';
import { Op } from 'sequelize';

// Hàm khởi tạo các Cron Jobs
export const initializeCronJobs = () => {
  // Cron Job chạy mỗi ngày lúc 00:00
  cron.schedule('0 0 * * *', async () => {
    console.log('Cron Job: Xử lý giao dịch định kỳ...');

    try {
      const today = new Date();

      // Lấy tất cả giao dịch định kỳ đến hạn trong ngày
      const recurringTransactions = await RecurringTransaction.findAll({
        where: {
          nextDate: { [Op.lte]: today }, // Giao dịch định kỳ có ngày <= hôm nay
        },
      });

      // Nếu không có giao dịch đến hạn
      if (!recurringTransactions.length) {
        console.log('Không có giao dịch định kỳ đến hạn.');
        return;
      }

      // Xử lý từng giao dịch định kỳ
      for (const recurring of recurringTransactions) {
        try {
          // Tạo giao dịch mới từ giao dịch định kỳ
          const transaction = await Transaction.create({
            userId: recurring.userId,
            categoryId: recurring.categoryId,
            amount: recurring.amount,
            note: recurring.note,
            date: recurring.nextDate,
          });

          // Gửi thông báo cho người dùng
          await Notification.create({
            userId: recurring.userId,
            type: 'success',
            message: `Giao dịch định kỳ (${recurring.note}) đã được tạo thành công vào ngày ${recurring.nextDate.toISOString().slice(0, 10)}.`,
          });

          // Cập nhật ngày giao dịch tiếp theo
          let nextDate = new Date(recurring.nextDate);
          switch (recurring.frequency) {
            case 'daily':
              nextDate.setDate(nextDate.getDate() + 1);
              break;
            case 'weekly':
              nextDate.setDate(nextDate.getDate() + 7);
              break;
            case 'monthly':
              nextDate.setMonth(nextDate.getMonth() + 1);
              break;
            default:
              console.warn(`Tần suất không hợp lệ: ${recurring.frequency}`);
              continue; // Bỏ qua nếu tần suất không hợp lệ
          }

          // Lưu ngày giao dịch tiếp theo
          recurring.nextDate = nextDate;
          await recurring.save();

          // Kiểm tra hạn mức chi tiêu của người dùng
          const user = await User.findByPk(recurring.userId);

          if (user && user.spendingLimit) {
            const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1); // Đầu tháng
            const totalSpending = await Transaction.sum('amount', {
              where: {
                userId: user.id,
                type: 'expense',
                date: { [Op.gte]: startOfMonth }, // Tính từ đầu tháng
              },
            });

            if (totalSpending > user.spendingLimit) {
              // Gửi thông báo cảnh báo nếu vượt hạn mức
              await Notification.create({
                userId: user.id,
                type: 'alert',
                message: `Bạn đã vượt hạn mức chi tiêu trong tháng này. Hạn mức: ${user.spendingLimit}, tổng chi tiêu hiện tại: ${totalSpending}.`,
              });
              console.warn(`User ID ${user.id} đã vượt hạn mức chi tiêu.`);
            }
          }
        } catch (transactionError) {
          console.error(
            `Lỗi khi xử lý giao dịch định kỳ ID: ${recurring.id}, chi tiết:`,
            transactionError
          );
        }
      }

      console.log('Cron Job: Hoàn thành xử lý giao dịch định kỳ!');
    } catch (error) {
      console.error('Lỗi trong quá trình xử lý Cron Job:', error);
    }
  });
};
