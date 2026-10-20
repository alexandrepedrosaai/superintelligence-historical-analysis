const fs = require('fs');

test('timeline.js exists', () => {
  expect(fs.existsSync('timeline.js')).toBe(true);
});
