import { google } from 'googleapis';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method !== 'POST') {
    return res.status(400).json({ error: 'POST gerekli' });
  }

  const { months } = req.body;
  const authToken = req.headers.authorization?.split(' ')[1];

  if (!authToken) {
    return res.status(401).json({ error: 'Gmail bağlı değil' });
  }

  try {
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET
    );
    
    const tokens = JSON.parse(Buffer.from(authToken, 'base64').toString());
    oauth2Client.setCredentials(tokens);

    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });
    const labels = await gmail.users.labels.list({ userId: 'me' });
    
    let fileCount = 0;
    const files = [];

    for (const month of months) {
      const label = labels.data.labels.find(l => 
        l.name.toLowerCase().includes(month.toLowerCase())
      );
      
      if (!label) continue;

      const messages = await gmail.users.messages.list({
        userId: 'me',
        q: `label:${label.id} filename:(csv OR xlsx)`,
        maxResults: 50
      });

      if (messages.data.messages) {
        files.push({
          month: month,
          count: messages.data.messages.length
        });
        fileCount += messages.data.messages.length;
      }
    }

    res.json({
      success: true,
      count: fileCount,
      files: files
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
