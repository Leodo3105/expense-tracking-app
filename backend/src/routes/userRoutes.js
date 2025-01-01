import express from 'express';
import { setSpendingLimit } from '../controllers/user/userController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.put('/spending-limit', authenticateToken, setSpendingLimit);

export default router;
