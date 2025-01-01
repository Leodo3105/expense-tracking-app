import express from 'express';
import { addNotification, getNotifications, getNotificationById } from '../controllers/notification/notificationController.js';
import { authenticateToken }from '../middleware/auth.js';

const router = express.Router();

router.post('/add', addNotification);

router.get('/list', authenticateToken, getNotifications);

router.get('/detail/:id', authenticateToken, getNotificationById);

export default router;
