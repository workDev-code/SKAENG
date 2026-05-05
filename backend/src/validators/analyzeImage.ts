import { z } from 'zod';

export const analyzeImageBodySchema = z.object({
  imageBase64: z.string().min(1),
  mimeType: z.string().min(1),
});

export type AnalyzeImageBody = z.infer<typeof analyzeImageBodySchema>;

