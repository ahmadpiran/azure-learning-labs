// Database connection module
// Handles PostgreSQL conneciton pooling

const { Pool } = require('pg');

// Database configuration from environment variables
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.DB_PASSWORD,
    // Connection pool settings
    max: 20,
    idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
    connectionTimeoutMillis: 2000, // Return an error after 2 seconds if connection not available
});

// Test databse connection on startup
pool.on('connect', () => {
    console.log('✓ Database connection established');
});

pool.on('error', (err) => {
    console.error('x Unexpected database error:', err);
    process.exit(-1);
});

// Export query function
module.exports = {
    query: (text, params) => pool.query(text, params),
    pool: pool
};