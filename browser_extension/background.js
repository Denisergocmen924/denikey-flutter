const PORT = 27653;
const BASE_URL = `http://localhost:${PORT}`;

// Token'ı storage'dan al veya DeniKey ile握手 yap
async function getToken() {
  const result = await chrome.storage.local.get('denikey_token');
  return result.denikey_token || null;
}

async function setToken(token) {
  await chrome.storage.local.set({ denikey_token: token });
}

// DeniKey durumunu kontrol et
async function checkStatus(token) {
  try {
    const res = await fetch(`${BASE_URL}/status`, {
      headers: { 'X-DeniKey-Token': token },
    });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

// Domain için eşleşen kayıtları getir
async function fetchMatches(domain, token) {
  try {
    const res = await fetch(`${BASE_URL}/autofill`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-DeniKey-Token': token,
      },
      body: JSON.stringify({ domain }),
    });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

// Content script'ten gelen mesajları işle
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === 'GET_MATCHES') {
    (async () => {
      const token = await getToken();
      if (!token) {
        sendResponse({ error: 'no_token' });
        return;
      }
      const data = await fetchMatches(msg.domain, token);
      if (!data) {
        sendResponse({ error: 'denikey_offline' });
        return;
      }
      sendResponse(data);
    })();
    return true; // async response
  }

  if (msg.type === 'SAVE_TOKEN') {
    setToken(msg.token).then(() => sendResponse({ ok: true }));
    return true;
  }

  if (msg.type === 'CHECK_STATUS') {
    (async () => {
      const token = await getToken();
      if (!token) { sendResponse({ connected: false }); return; }
      const status = await checkStatus(token);
      sendResponse({ connected: !!status, locked: status?.locked ?? true });
    })();
    return true;
  }
});
