import { GoogleGenerativeAI } from '@google/generative-ai';

export type GeminiWordResult = {
  englishWord: string;
  vietnameseTranslation: string;
  pronunciationGuide: string;
  exampleSentence: string;
};

const systemPrompt = `
You help Vietnamese learners of English. The user sends a photo of a real object, text label, or scene.

Identify the MAIN English word or short phrase (1–4 words) that best matches what is shown.
Respond with ONLY valid JSON (no markdown fences, no extra text) using exactly these keys:
{
  "englishWord": string,
  "vietnameseTranslation": string,
  "pronunciationGuide": string,
  "exampleSentence": string
}

Rules:
- "englishWord": the English term only.
- "vietnameseTranslation": clear Vietnamese meaning for learners.
- "pronunciationGuide": simple phonetic spelling using English letters (not IPA), e.g. "WAH-tur" for "water".
- "exampleSentence": one natural English sentence using the word (school-appropriate).
`.trim();

function extractJsonObject(raw: string): string {
  let t = raw.trim();
  const fence = /```(?:json)?\s*([\s\S]*?)```/m;
  const m = fence.exec(t);
  if (m?.[1]) t = m[1].trim();

  const start = t.indexOf('{');
  const end = t.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw new Error('No JSON object found in model output.');
  }
  return t.substring(start, end + 1);
}

function requireEnv(name: string): string {
  const v = process.env[name];
  if (!v || !v.trim()) throw new Error(`Missing ${name}`);
  return v.trim();
}

function requireString(obj: Record<string, unknown>, key: string): string {
  const v = obj[key];
  if (typeof v === 'string' && v.trim()) return v.trim();
  throw new Error(`Missing or empty "${key}" in JSON.`);
}

export async function analyzeImageWithGemini(params: {
  imageBytes: Uint8Array;
  mimeType: string;
}): Promise<GeminiWordResult> {
  const apiKey = requireEnv('GEMINI_API_KEY');
  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    systemInstruction: systemPrompt,
  });

  const response = await model.generateContent([
    {
      text: 'Return only the JSON object for what you see in this image.',
    },
    {
      inlineData: {
        data: Buffer.from(params.imageBytes).toString('base64'),
        mimeType: params.mimeType,
      },
    },
  ]);

  const text = response.response.text();
  if (!text || !text.trim()) {
    throw new Error('Empty response from Gemini.');
  }

  const jsonString = extractJsonObject(text);
  const map = JSON.parse(jsonString) as Record<string, unknown>;

  return {
    englishWord: requireString(map, 'englishWord'),
    vietnameseTranslation: requireString(map, 'vietnameseTranslation'),
    pronunciationGuide: requireString(map, 'pronunciationGuide'),
    exampleSentence: requireString(map, 'exampleSentence'),
  };
}

