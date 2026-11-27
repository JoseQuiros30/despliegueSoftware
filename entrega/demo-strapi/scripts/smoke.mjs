const base = process.env.SERVICE_URL || 'http://localhost:1337';
const expected = process.env.EXPECTED_REVISION;
const response = await fetch(`${base}/api/health`, { signal: AbortSignal.timeout(15000) });
const body = await response.json();
if (!response.ok || body.status !== 'ok' || (expected && body.revision !== expected)) {
  throw new Error(`Smoke failed: HTTP ${response.status} ${JSON.stringify(body)}`);
}
console.log(`Smoke OK: ${base}/api/health (${body.revision})`);
