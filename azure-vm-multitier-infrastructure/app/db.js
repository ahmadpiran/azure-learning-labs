// Database connection module
// Handles PostgreSQL connection pooling

const { Pool } = require('pg');
require('dotenv').config();


// Database configuration from environment variables
const pool = new Pool({
  host: process.env.DB_HOST || '10.0.3.4',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'taskdb',
  user: process.env.DB_USER || 'taskuser',
  password: process.env.DB_PASSWORD,
  // Connection pool settings
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection not available
});

// Test database connection on startup
pool.on('connect', () => {
  console.log('✓ Database connection established');
});

pool.on('error', (err) => {
  console.error('✗ Unexpected database error:', err);
  process.exit(-1);
});

// Export query function
module.exports = {
  query: (text, params) => pool.query(text, params),
  pool: pool
};