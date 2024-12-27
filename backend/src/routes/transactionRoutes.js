import express from 'express';
import { addTransaction, updateTransaction, getTransactions, deleteTransaction } from '../controllers/transaction/transactionController.js';
import { authenticateToken } from '../middleware/auth.js'; 

const router = express.Router();

// Thêm danh mục
router.post('/add', authenticateToken, addTransaction);

// Lấy danh sách danh mục
router.get('/list', authenticateToken, getTransactions);

// Cập nhật danh mục
router.put('/update/:id', authenticateToken, updateTransaction);

// Xóa danh mục
router.delete('/delete/:id', authenticateToken, deleteTransaction);

export default router;
