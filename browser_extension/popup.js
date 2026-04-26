const statusEl = document.getElementById('status');
const tokenInput = document.getElementById('tokenInput');
const saveBtn = document.getElementById('saveBtn');

async function checkAndShowStatus() {
  const response = await chrome.runtime.sendMessage({ type: 'CHECK_STATUS' });
  if (!response.connected) {
    statusEl.className = 'status offline';
    statusEl.textContent = 'DeniKey bağlı değil';
  } else if (response.locked) {
    statusEl.className = 'status locked';
    statusEl.textContent = '🔒 DeniKey kilitli — önce giriş yapın';
  } else {
    statusEl.className = 'status ok';
    statusEl.textContent = '✓ Bağlı ve hazır';
  }
}

// Mevcut token'ı göster
chrome.storage.local.get('denikey_token', (result) => {
  if (result.denikey_token) {
    tokenInput.value = result.denikey_token;
  }
  checkAndShowStatus();
});

saveBtn.addEventListener('click', async () => {
  const token = tokenInput.value.trim();
  if (!token) return;
  await chrome.runtime.sendMessage({ type: 'SAVE_TOKEN', token });
  checkAndShowStatus();
});
