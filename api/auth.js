import { google } from 'googleapis';

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  'https://battal-panel.vercel.app/api/callback'
);

export default async function handler(req, res) {
  if (req.method === 'GET' && req.query.action === 'url') {
    const authUrl = oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: ['https://www.googleapis.com/auth/gmail.readonly']
    });
    return res.json({ authUrl });
  }

  if (req.method === 'GET' && req.query.code) {
    try {
      const { tokens } = await oauth2Client.getToken(req.query.code);
      res.setHeader('Set-Cookie', `auth_token=${JSON.stringify(tokens)}; Path=/; HttpOnly`);
      return res.json({ success: true, message: 'Gmail bağlandı!' });
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  res.status(400).json({ error: 'Invalid request' });
}
