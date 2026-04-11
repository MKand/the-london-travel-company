const API_BASE_URL = window.APP_CONFIG?.API_BASE_URL || 'http://localhost:8000';
const AGENT_NAME = 'london_agent';

export const DEFAULT_USER_ID = 'u_123';

export async function createSession() {
  const response = await fetch(`${API_BASE_URL}/apps/${AGENT_NAME}/users/${DEFAULT_USER_ID}/sessions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
  if (!response.ok) throw new Error('Failed to create session');
  return response.json();
}

export async function sendMessage(sessionId, text) {
  const response = await fetch(`${API_BASE_URL}/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      appName: AGENT_NAME,
      userId: DEFAULT_USER_ID,
      sessionId: sessionId,
      newMessage: {
        role: "user",
        parts: [{
          text: text
        }]
      }
    }),
  });
  if (!response.ok) throw new Error('Failed to send message');
  return response.json();
}
