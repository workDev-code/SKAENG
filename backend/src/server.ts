import 'dotenv/config';

import { createApp } from './app';

const port = process.env.PORT ? Number(process.env.PORT) : 8080;
if (!Number.isFinite(port)) {
  throw new Error('Invalid PORT');
}

const app = createApp();
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend listening on http://localhost:${port}`);
});

