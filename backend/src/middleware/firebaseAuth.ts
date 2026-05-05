import type { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';

let initialized = false;

function ensureFirebaseAdmin() {
  if (initialized) return;
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
  initialized = true;
}

function extractBearerToken(req: Request): string | null {
  const h = req.header('authorization');
  if (!h) return null;
  const m = /^Bearer\s+(.+)$/i.exec(h.trim());
  return m?.[1]?.trim() ?? null;
}

export async function firebaseAuth(req: Request, res: Response, next: NextFunction) {
  try {
    const token = extractBearerToken(req);
    if (!token) {
      return res.status(401).json({
        error: { code: 'UNAUTHORIZED', message: 'Missing Authorization Bearer token.' },
      });
    }

    ensureFirebaseAdmin();
    const decoded = await admin.auth().verifyIdToken(token);

    // Attach decoded token for downstream handlers.
    (req as Request & { user?: admin.auth.DecodedIdToken }).user = decoded;

    return next();
  } catch {
    return res.status(401).json({
      error: { code: 'UNAUTHORIZED', message: 'Invalid or expired Firebase token.' },
    });
  }
}

