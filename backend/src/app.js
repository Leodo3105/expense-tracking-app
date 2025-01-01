import express from 'express';
import dotenv from 'dotenv';
import sequelize, { sync } from './config/db.js';
import { initializeCronJobs } from './config/cronJob.js';

// Import models để các model được định nghĩa
import './models/category.js';
import './models/transaction.js';
import './models/user.js';
import './models/recurringTransaction.js';
import './models/notification.js';
import associateModels from './models/association.js';

// Import routes
import authRoutes from './routes/authRoutes.js';
import categoryRoutes from './routes/categoryRoutes.js';
import transactionRoutes from './routes/transactionRoutes.js';
import recurringTransactionRoutes from './routes/recurringTransactionRoutes.js';
import userRoutes from './routes/userRoutes.js';
import notificationRoutes from './routes/notificationRoutes.js';
import statisticRoutes from './routes/statisticRoutes.js';

// Load environment variables
dotenv.config();
associateModels();
const app = express();

// Middleware
app.use(express.json());

// Basic route
app.use('/api/auth', authRoutes);
app.use('/api/category', categoryRoutes);
app.use('/api/transaction', transactionRoutes);
app.use('/api/recurring-transaction', recurringTransactionRoutes);
app.use('/api/user', userRoutes);
app.use('/api/notification', notificationRoutes);
app.use('/api/statistic', statisticRoutes);

// Khởi chạy Cron Jobs
initializeCronJobs();

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);

  sync ()
    .then(() => console.log('Database synced successfully'))
    .catch((err) => console.error('Error syncing database:', err));
});
