import express from 'express';
import {  getMonthlyOverview, getCategorySpendingRatio  } from '../controllers/statistic/statisticController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/monthly-overview', authenticateToken, getMonthlyOverview);

// router.get('/category', authenticateToken, getStatisticsByCategory);

// router.get('/time', authenticateToken, getStatisticsByTime);

router.get('/category-ratio', authenticateToken, getCategorySpendingRatio);

export default router;