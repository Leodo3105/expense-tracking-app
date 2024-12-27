import express from 'express';
import dotenv from 'dotenv';
import sequelize, { sync } from './config/db.js';

// Import models để các model được định nghĩa
import './models/category.js';
import './models/transaction.js';
import './models/user.js';
import associateModels from './models/association.js';

// Import routes
import authRoutes from './routes/authRoutes.js';
import categoryRoutes from './routes/categoryRoutes.js';
import transactionRoutes from './routes/transactionRoutes.js';

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

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);

  sync ()
    .then(() => console.log('Database synced successfully'))
    .catch((err) => console.error('Error syncing database:', err));
});
