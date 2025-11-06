const app = require('./index');

console.log('Running tests...');

// Test 1: greet function
const greeting = app.greet('World');
if (greeting === 'Hello, World!') {
  console.log('✓ greet() test passed');
} else {
  console.error('✗ greet() test failed');
  process.exit(1);
}

// Test 2: add function
const sum = app.add(2, 3);
if (sum === 5) {
  console.log('✓ add() test passed');
} else {
  console.error('✗ add() test failed');
  process.exit(1);
}

console.log('\nAll tests passed! ✓');
