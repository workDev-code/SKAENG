import { Router } from 'express';

import { firebaseAuth } from '../middleware/firebaseAuth';
import { analyzeImageWithGemini } from '../services/geminiVision';
import { analyzeImageBodySchema } from '../validators/analyzeImage';

export const analyzeImageRouter = Router();

analyzeImageRouter.post('/analyze-image', firebaseAuth, async (req, res) => {
  try {
    const parsed = analyzeImageBodySchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: { code: 'BAD_REQUEST', message: 'Invalid request body.' },
      });
    }

    const { imageBase64, mimeType } = parsed.data;

    let bytes: Buffer;
    try {
      bytes = Buffer.from(imageBase64, 'base64');
    } catch {
      return res.status(400).json({
        error: { code: 'BAD_REQUEST', message: 'Invalid imageBase64.' },
      });
    }

    if (!bytes.length) {
      return res.status(400).json({
        error: { code: 'BAD_REQUEST', message: 'Empty imageBase64.' },
      });
    }

    const result = await analyzeImageWithGemini({
      imageBytes: new Uint8Array(bytes),
      mimeType,
    });

    return res.status(200).json(result);
  } catch (e) {
    const msg = e instanceof Error ? e.message : 'Unexpected error.';
    return res.status(502).json({
      error: { code: 'UPSTREAM_ERROR', message: msg },
    });
  }
});

