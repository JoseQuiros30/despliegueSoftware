import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

test('El modelo original guarda publicados y oculta borradores', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'strapi-a5-'));
  process.env.DATABASE_CLIENT = 'sqlite';
  process.env.DATABASE_FILENAME = join(dir, 'test.db');
  process.env.NODE_ENV = 'test';
  process.env.HOST = '127.0.0.1';
  process.env.PORT = '0';
  process.env.APP_KEYS = 'test-key-one,test-key-two,test-key-three,test-key-four';
  process.env.API_TOKEN_SALT = 'test-api-token-salt';
  process.env.ADMIN_JWT_SECRET = 'test-admin-jwt-secret';
  process.env.TRANSFER_TOKEN_SALT = 'test-transfer-token-salt';
  process.env.JWT_SECRET = 'test-users-permissions-secret';
  process.env.ENCRYPTION_KEY = 'test-encryption-key';
  const { createStrapi } = require('@strapi/strapi');
  const app = createStrapi({ distDir: 'dist' });
  try {
    await app.load();
    const articles = app.documents('api::articulo.articulo');
    const content = [{ type: 'paragraph', children: [{ type: 'text', text: 'Prueba' }] }];
    const published = await articles.create({ data: { titulo: 'Publicado', slug: 'publicado', resumen: 'Resumen publicado', contenido: content, categoria: 'noticias' } });
    await articles.publish({ documentId: published.documentId });
    await articles.create({ data: { titulo: 'Borrador', slug: 'borrador', resumen: 'Resumen borrador', contenido: content, categoria: 'tutoriales' } });
    const visible = await articles.findMany({ status: 'published' });
    assert.deepEqual(visible.map((item) => item.titulo), ['Publicado']);
    assert.equal(visible[0].categoria, 'noticias');
    assert.equal(visible[0].resumen, 'Resumen publicado');
    await app.start();
    const base = `http://127.0.0.1:${app.server.httpServer.address().port}`;
    const health = await fetch(`${base}/api/health`);
    assert.equal(health.status, 200);
    assert.equal((await health.json()).status, 'ok');
    const publicList = await fetch(`${base}/api/articulos?status=draft`);
    assert.equal(publicList.status, 200);
    assert.deepEqual((await publicList.json()).data.map((item) => item.titulo), ['Publicado']);
    const publicOne = await fetch(`${base}/api/articulos/${published.documentId}?status=draft`);
    assert.equal(publicOne.status, 200);
    assert.equal((await publicOne.json()).data.titulo, 'Publicado');
    const write = await fetch(`${base}/api/articulos`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{}' });
    assert.equal(write.status, 403);
  } finally {
    await app.destroy();
    rmSync(dir, { recursive: true, force: true });
  }
});
