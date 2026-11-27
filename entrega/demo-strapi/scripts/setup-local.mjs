import { existsSync, writeFileSync } from 'node:fs';
import { randomBytes } from 'node:crypto';

if (existsSync('.env')) {
  console.log('.env ya existe; no se sobrescribió');
  process.exit(0);
}
const secret = () => randomBytes(32).toString('base64url');
const values = {
  HOST: '0.0.0.0',
  PORT: '1337',
  DATABASE_CLIENT: 'sqlite',
  DATABASE_FILENAME: '.tmp/data.db',
  APP_KEYS: [secret(), secret(), secret(), secret()].join(','),
  API_TOKEN_SALT: secret(),
  ADMIN_JWT_SECRET: secret(),
  TRANSFER_TOKEN_SALT: secret(),
  JWT_SECRET: secret(),
  ENCRYPTION_KEY: secret(),
};
writeFileSync('.env', Object.entries(values).map(([key, value]) => `${key}=${value}`).join('\n') + '\n', { mode: 0o600 });
console.log('.env local creado con secretos aleatorios (ignorado por Git)');
