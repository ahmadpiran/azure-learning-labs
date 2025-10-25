// Test database connection
// Run this to verify database connectivity before starting the API

const db = require('./db');
require('dotenv').config();

async function testConnection() {
  console.log('Testing database connection...');
  console.log('Configuration:');
  console.log(`  Host: ${process.env.DB_HOST || '10.0.3.4'}`);
  console.log(`  Port: ${process.env.DB_PORT || 5432}`);
  console.log(`  Database: ${process.env.DB_NAME || 'taskdb'}`);
  console.log(`  User: ${process.env.DB_USER || 'taskuser'}`);
  console.log('');

  try {
    // Test basic connection
    const result = await db.query('SELECT NOW()');
    console.log('✓ Database connection successful');
    console.log(`  Server time: ${result.rows[0].now}`);
    
    // Test tasks table
    const countResult = await db.query('SELECT COUNT(*) FROM tasks');
    console.log(`✓ Tasks table accessible`);
    console.log(`  Total tasks: ${countResult.rows[0].count}`);
    
    // Fetch sample tasks
    const tasksResult = await db.query('SELECT * FROM tasks LIMIT 3');
    console.log('✓ Sample tasks:');
    tasksResult.rows.forEach(task => {
      console.log(`  - [${task.id}] ${task.title} (${task.completed ? 'Done' : 'Pending'})`);
    });
    
    console.log('');
    console.log('All tests passed! ✓');
    process.exit(0);
  } catch (error) {
    console.error('✗ Connection test failed:', error.message);
    process.exit(1);
  }
}

testConnection();