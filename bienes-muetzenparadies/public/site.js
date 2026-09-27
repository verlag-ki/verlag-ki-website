(() => {
  const WHATSAPP = '4915734487082';
  const dialog = document.getElementById('contact-dialog');
  const whatsapp = document.getElementById('whatsapp-link');
  const preview = document.getElementById('whatsapp-preview');
  const toggle = document.querySelector('.menu-toggle');
  const mobile = document.getElementById('mobile-nav');
  const state = {pattern: '', size: '', head_cm: '', color: '', wishes: ''};
  const general = 'Hallo Biene! 😊\n\nIch habe dein Mützenparadies entdeckt und würde gerne eine Mütze anfragen.\n\nKannst du mir sagen, ob mein Wunsch möglich ist?\n\nLiebe Grüße';

  // Leere optionale Angaben erscheinen nicht in der Nachricht.
  const message = () => {
    if (!state.pattern) return general;
    const lines = ['Hallo Biene! 😊', '', 'Ich habe dein Mützenparadies entdeckt und interessiere mich für folgende Mütze:', '', `Muster: ${state.pattern}`];
    if (state.size) lines.push(`Größe: ${state.size}`);
    if (state.head_cm) lines.push(`Kopfumfang: ${state.head_cm} cm`);
    if (state.color) lines.push(`Wunschfarbe: ${state.color}`);
    if (state.wishes) lines.push('', 'Besondere Wünsche:', state.wishes);
    lines.push('', 'Kannst du mir sagen, ob das möglich ist und was die Mütze kosten würde?', '', 'Liebe Grüße');
    return lines.join('\n');
  };

  function openDialog() {
    const text = message();
    whatsapp.href = `https://wa.me/${WHATSAPP}?text=${encodeURIComponent(text)}`;
    preview.textContent = text;
    closeMenu();
    if (!dialog.open) dialog.showModal();
  }

  document.querySelectorAll('[data-contact]').forEach(el => el.addEventListener('click', () => {
    for (const key of Object.keys(state)) state[key] = '';
    openDialog();
  }));

  document.querySelectorAll('#pattern-form').forEach(el => el.addEventListener('submit', event => {
    event.preventDefault();
    const data = new FormData(el);
    state.pattern = el.dataset.pattern;
    for (const key of ['size', 'head_cm', 'color', 'wishes']) state[key] = String(data.get(key) || '').trim();
    openDialog();
  }));

  document.querySelector('[data-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', event => { if (event.target === dialog) dialog.close(); });

  // Mobile Navigation
  function closeMenu() {
    if (mobile.hidden) return;
    mobile.hidden = true;
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'Menü öffnen');
    document.body.style.overflow = '';
  }
  toggle.addEventListener('click', () => {
    if (!mobile.hidden) return closeMenu();
    mobile.hidden = false;
    toggle.setAttribute('aria-expanded', 'true');
    toggle.setAttribute('aria-label', 'Menü schließen');
    document.body.style.overflow = 'hidden';
    mobile.querySelector('a, button').focus();
  });
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && !mobile.hidden) { closeMenu(); toggle.focus(); } });
  window.matchMedia('(min-width: 1081px)').addEventListener('change', e => { if (e.matches) closeMenu(); });

  // Bildergalerie der Musterseite
  const mainImage = document.getElementById('main-image');
  document.querySelectorAll('.thumbs button').forEach(btn => btn.addEventListener('click', () => {
    mainImage.src = btn.dataset.src; mainImage.alt = btn.dataset.alt;
    document.querySelectorAll('.thumbs button').forEach(b => b.removeAttribute('aria-current'));
    btn.setAttribute('aria-current', 'true');
  }));

  // Größenhilfe
  const sizeInput = document.getElementById('head-size');
  if (sizeInput) {
    const sizes = JSON.parse(document.getElementById('sizes-json').textContent);
    sizeInput.addEventListener('input', () => {
      const n = Number(sizeInput.value.replace(',', '.'));
      const found = sizes.filter(s => Number.isFinite(n) && n >= s.min_cm && n <= s.max_cm);
      document.getElementById('size-result').textContent = !sizeInput.value
        ? 'Bitte gib deinen Kopfumfang ein.'
        : found.length === 1
          ? `Unsere Maßtabelle empfiehlt: ${found[0].name}. Bitte stimme die Passform mit uns ab.`
          : 'Keine eindeutige Größe gefunden. Frag uns bitte persönlich – wir finden eine Lösung.';
    });
  }
})();
