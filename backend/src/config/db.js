import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config()

const sequelize = new Sequelize(
  process.env.DB_DATABASE,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false,
  }
);

sequelize.authenticate()
  .then(() => console.log('Connected to PostgreSQL'))
  .catch((err) => console.error('Unable to connect to PostgreSQL:', err));

// Exporting sync method
export const sync = async () => {
  await sequelize.sync({ alert: true }); // or true for dropping and re-creating tables
};

export default sequelize;

