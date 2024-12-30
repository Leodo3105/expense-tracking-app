import express from 'express';
import { addTransaction, updateTransaction, getTransactions, getTransactionById, deleteTransaction } from '../controllers/transaction/transactionController.js';
import { searchTransactions } from '../controllers/transaction/searchTransactionController.js';
import { authenticateToken } from '../middleware/auth.js'; 

const router = express.Router();

// Thêm danh mục
router.post('/add', authenticateToken, addTransaction);

// Lấy danh sách danh mục
router.get('/list', authenticateToken, getTransactions);

//Lấy chi tiết danh mục
router.get('/detail/:id', getTransactionById);

// Cập nhật danh mục
router.put('/update/:id', authenticateToken, updateTransaction);

// Xóa danh mục
router.delete('/delete/:id', authenticateToken, deleteTransaction);

// Tìm kiếm giao dịch
router.get('/search', authenticateToken, searchTransactions);

export default router;
