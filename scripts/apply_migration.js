const fs = require('fs');
const { execSync } = require('child_process');

const content = fs.readFileSync('supabase/migrations/0021_complaints.sql', 'utf8');

// Split file into top-level SQL statements
const statements = [];
let buffer = '';
let inDollarBlock = false;

const lines = content.split('\n');
for (let line of lines) {
  const trimmed = line.trim();
  if (trimmed.startsWith('--')) continue;

  // Count $$ occurrences
  const dollarMatches = (line.match(/\$\$/g) || []).length;
  if (dollarMatches % 2 !== 0) {
    inDollarBlock = !inDollarBlock;
  }

  buffer += line + '\n';

  if (!inDollarBlock && trimmed.endsWith(';')) {
    if (buffer.trim()) {
      statements.push(buffer.trim());
    }
    buffer = '';
  }
}
if (buffer.trim()) {
  statements.push(buffer.trim());
}

console.log(`Found ${statements.length} SQL statements to execute.`);

for (let i = 0; i < statements.length; i++) {
  const stmt = statements[i];
  console.log(`\nExecuting statement ${i + 1}/${statements.length}...`);
  try {
    execSync('npx supabase db query', {
      input: stmt,
      encoding: 'utf8',
      stdio: ['pipe', 'inherit', 'inherit']
    });
  } catch (e) {
    console.error(`Failed at statement ${i + 1}: ${e.message}`);
    process.exit(1);
  }
}

console.log('\nMigration 0021_complaints.sql applied successfully!');
