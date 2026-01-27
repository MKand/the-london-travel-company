import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const API_BASE_URL = 'http://localhost:8000';
const AGENT_NAME = 'london_agent';
const DEFAULT_USER_ID = 'u_123';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    {
      name: 'api-chat-middleware',
      configureServer(server) {
        server.middlewares.use(async (req, res, next) => {
          if (req.url === '/api/chat' && req.method === 'POST') {
            let body = '';
            req.on('data', chunk => {
              body += chunk.toString();
            });
            req.on('end', async () => {
              try {
                const parsedBody = body ? JSON.parse(body) : {};
                const { message } = parsedBody;

                if (!message) {
                  res.statusCode = 400;
                  res.setHeader('Content-Type', 'application/json');
                  res.end(JSON.stringify({ error: 'Message is required' }));
                  return;
                }

                const sessionId = 's_' + Date.now();

                // 1. Create session
                const createSessionUrl = `${API_BASE_URL}/apps/${AGENT_NAME}/users/${DEFAULT_USER_ID}/sessions/${sessionId}`;
                const sessionResponse = await fetch(createSessionUrl, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({}),
                });

                if (!sessionResponse.ok) {
                  throw new Error(`Failed to create session: ${sessionResponse.statusText}`);
                }

                // 2. Send message
                const runUrl = `${API_BASE_URL}/run`;
                const runResponse = await fetch(runUrl, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({
                    appName: AGENT_NAME,
                    userId: DEFAULT_USER_ID,
                    sessionId: sessionId,
                    newMessage: {
                      role: "user",
                      parts: [{ text: message }]
                    }
                  }),
                });

                if (!runResponse.ok) {
                  throw new Error(`Failed to send message: ${runResponse.statusText}`);
                }

                const result = await runResponse.json();
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ sessionId, ...result }));
              } catch (error) {
                console.error('Error in /api/chat middleware:', error);
                res.statusCode = 500;
                res.setHeader('Content-Type', 'application/json');
                res.end(JSON.stringify({ error: error.message }));
              }
            });
          } else {
            next();
          }
        });
      }
    }
  ]
})
