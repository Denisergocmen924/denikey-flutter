(() => {
  // Her input için sadece bir kez ikon ekle
  const injected = new WeakSet();

  function getDomain() {
    return window.location.hostname.replace(/^www\./, '');
  }

  function isLoginInput(input) {
    const type = (input.type || '').toLowerCase();
    const name = (input.name || input.id || input.autocomplete || '').toLowerCase();
    if (type === 'password') return true;
    if (type === 'email') return true;
    if (type === 'text' && /user|login|email|mail|uname|kullanici/.test(name)) return true;
    return false;
  }

  function createPopup(items, input, passwordInput) {
    // Varsa eski popup'ı kaldır
    document.getElementById('denikey-popup')?.remove();

    const popup = document.createElement('div');
    popup.id = 'denikey-popup';
    popup.style.cssText = `
      position: fixed;
      z-index: 2147483647;
      background: #1a1a2e;
      border: 1px solid #FF5900;
      border-radius: 10px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.5);
      min-width: 240px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      overflow: hidden;
    `;

    // Başlık
    const header = document.createElement('div');
    header.style.cssText = `
      padding: 10px 14px;
      background: #FF5900;
      color: white;
      font-size: 13px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 6px;
    `;
    header.innerHTML = `<span>🔑</span><span>DeniKey</span>`;
    popup.appendChild(header);

    const list = document.createElement('div');
    list.style.cssText = 'padding: 6px 0;';

    // Hesap listesi
    items.forEach(item => {
      const row = document.createElement('div');
      row.style.cssText = `
        padding: 9px 14px;
        cursor: pointer;
        color: #e0e0e0;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: background 0.15s;
      `;
      row.innerHTML = `<span>👤</span><span>${item.username || item.email || item.title}</span>`;
      row.addEventListener('mouseenter', () => row.style.background = '#2a2a4e');
      row.addEventListener('mouseleave', () => row.style.background = 'transparent');
      row.addEventListener('mousedown', (e) => {
        e.preventDefault();
        fillForm(input, passwordInput, item);
        popup.remove();
      });
      list.appendChild(row);
    });

    // Ayırıcı
    const divider = document.createElement('div');
    divider.style.cssText = 'height: 1px; background: #333355; margin: 4px 0;';
    list.appendChild(divider);

    // Yeni hesap ekle
    const addRow = document.createElement('div');
    addRow.style.cssText = `
      padding: 9px 14px;
      cursor: pointer;
      color: #FF5900;
      font-size: 13px;
      display: flex;
      align-items: center;
      gap: 8px;
    `;
    addRow.innerHTML = `<span>＋</span><span>Yeni hesap ekle</span>`;
    addRow.addEventListener('mouseenter', () => addRow.style.background = '#2a2a4e');
    addRow.addEventListener('mouseleave', () => addRow.style.background = 'transparent');
    addRow.addEventListener('mousedown', (e) => {
      e.preventDefault();
      popup.remove();
      // DeniKey'i aç — deep link ile yeni kayıt ekranına git
      window.open('denikey://new', '_blank');
    });
    list.appendChild(addRow);

    // Ayırıcı 2
    const divider2 = document.createElement('div');
    divider2.style.cssText = 'height: 1px; background: #333355; margin: 4px 0;';
    list.appendChild(divider2);

    // Kendim gireceğim
    const dismissRow = document.createElement('div');
    dismissRow.style.cssText = `
      padding: 9px 14px;
      cursor: pointer;
      color: #888;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 8px;
    `;
    dismissRow.innerHTML = `<span>✕</span><span>Kendim gireceğim</span>`;
    dismissRow.addEventListener('mouseenter', () => dismissRow.style.background = '#2a2a4e');
    dismissRow.addEventListener('mouseleave', () => dismissRow.style.background = 'transparent');
    dismissRow.addEventListener('mousedown', (e) => {
      e.preventDefault();
      popup.remove();
    });
    list.appendChild(dismissRow);

    popup.appendChild(list);

    // Konumlandır
    const rect = input.getBoundingClientRect();
    popup.style.top = `${rect.bottom + window.scrollY + 4}px`;
    popup.style.left = `${rect.left + window.scrollX}px`;

    document.body.appendChild(popup);

    // Dışarı tıklanınca kapat
    setTimeout(() => {
      document.addEventListener('mousedown', function handler(e) {
        if (!popup.contains(e.target)) {
          popup.remove();
          document.removeEventListener('mousedown', handler);
        }
      });
    }, 100);
  }

  function fillForm(usernameInput, passwordInput, item) {
    // Kullanıcı adı / email alanını doldur
    if (usernameInput) {
      nativeInputSetter(usernameInput, item.username || item.email || '');
    }
    // Şifre alanını doldur
    if (passwordInput) {
      nativeInputSetter(passwordInput, item.password || '');
    }
  }

  // React/Vue gibi framework'ler için native setter kullan
  function nativeInputSetter(el, value) {
    const nativeSetter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype, 'value'
    )?.set;
    if (nativeSetter) {
      nativeSetter.call(el, value);
      el.dispatchEvent(new Event('input', { bubbles: true }));
      el.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
      el.value = value;
    }
  }

  function findPasswordInput(usernameInput) {
    // Aynı form içindeki password input'unu bul
    const form = usernameInput.closest('form');
    if (form) return form.querySelector('input[type="password"]');
    // Form yoksa sayfadaki ilk password input'unu bul
    return document.querySelector('input[type="password"]');
  }

  async function onInputFocus(input) {
    if (injected.has(input)) return;
    injected.add(input);

    const domain = getDomain();
    const response = await chrome.runtime.sendMessage({ type: 'GET_MATCHES', domain });

    if (!response || response.error || !response.items || response.items.length === 0) return;

    const passwordInput = input.type === 'password' ? input : findPasswordInput(input);
    const usernameInput = input.type === 'password' ? null : input;

    createPopup(response.items, usernameInput, passwordInput);
  }

  function attachListeners(input) {
    input.addEventListener('focus', () => onInputFocus(input));
  }

  // Mevcut input'ları tara
  document.querySelectorAll('input').forEach(input => {
    if (isLoginInput(input)) attachListeners(input);
  });

  // Dinamik eklenen input'ları izle (SPA'lar için)
  const observer = new MutationObserver(mutations => {
    mutations.forEach(m => {
      m.addedNodes.forEach(node => {
        if (node.nodeType !== 1) return;
        const inputs = node.tagName === 'INPUT'
          ? [node]
          : Array.from(node.querySelectorAll?.('input') || []);
        inputs.forEach(input => {
          if (isLoginInput(input)) attachListeners(input);
        });
      });
    });
  });

  observer.observe(document.body, { childList: true, subtree: true });
})();
