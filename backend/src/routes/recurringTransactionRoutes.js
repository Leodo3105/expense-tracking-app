import express from 'express';
import { addRecurringTransaction , getRecurringTransactions, getRecurringTransactionById, updateRecurringTransaction, deleteRecurringTransaction } from '../controllers/transaction/recurringTransactionController.js';
import { searchRecurringTransactions } from '../controllers/transaction/searchTransactionController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Thêm giao dịch định kỳ
router.post('/add', authenticateToken, addRecurringTransaction);

// Lấy danh sách giao dịch định kỳ
router.get('/list', authenticateToken, getRecurringTransactions);

//Lấy chi tiết giao dịch định kỳ
router.get('/detail/:id', authenticateToken, getRecurringTransactionById);

// Cập nhật giao dịch định kỳ
router.put('/update/:id', authenticateToken, updateRecurringTransaction);

// Xóa giao dịch định kỳ
router.delete('/delete/:id', authenticateToken, deleteRecurringTransaction);

// Tìm kiếm giao dịch định kỳ
router.get('/search', authenticateToken, searchRecurringTransactions);

export default router;