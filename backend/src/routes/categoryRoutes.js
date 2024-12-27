import express from 'express';
import { addCategory, getCategories, updateCategory, deleteCategory } from '../controllers/category/categoryController.js';
import { authenticateToken } from '../middleware/auth.js'; 

const router = express.Router();

// Thêm danh mục
router.post('/add', authenticateToken, addCategory);

// Lấy danh sách danh mục
router.get('/list', authenticateToken, getCategories);

// Cập nhật danh mục
router.put('/update/:id', authenticateToken, updateCategory);

// Xóa danh mục
router.delete('/delete/:id', authenticateToken, deleteCategory);

export default router;
