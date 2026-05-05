import express from 'express';
import cors from 'cors';

import { analyzeImageRouter } from './routes/analyzeImage';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: '10mb' }));

  app.get('/health', (_req, res) => {
    res.status(200).json({ ok: true });
  });

  app.use(analyzeImageRouter);

  return app;
}

