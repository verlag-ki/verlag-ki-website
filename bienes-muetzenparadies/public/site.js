(() => {
  const WHATSAPP = '4915734487082';
  const dialog = document.getElementById('contact-dialog');
  const choices = document.getElementById('contact-choices');
  const form = document.getElementById('contact-form');
  const feedback = document.getElementById('form-feedback');
  const success = document.getElementById('form-success');
  const fields = document.getElementById('form-pattern-fields');
  const whatsapp = document.getElementById('whatsapp-link');
  const toggle = document.querySelector('.menu-toggle');
  const mobile = document.getElementById('mobile-nav');
  const state = {pattern: '', size: '', head_cm: '', color: '', wishes: ''};
  const general = 'Hallo Biene! 😊\n\nIch habe dein Mützenparadies entdeckt und würde gerne eine Mütze anfragen.\n\nKannst du mir sagen, ob mein Wunsch möglich ist?\n\nLiebe Grüße';

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

  // Überträgt die Auswahl in den WhatsApp-Link und in das Formular.
  const update = () => {
    whatsapp.href = `https://wa.me/${WHATSAPP}?text=${encodeURIComponent(message())}`;
    fields.hidden = !state.pattern;
    for (const key of Object.keys(state)) {
      const input = form.elements.namedItem(key);
      if (input) {
        input.value = state[key];
        const wrap = input.closest('label');
        // Leere optionale Angaben nicht als leeres Feld anzeigen
        if (wrap && key !== 'pattern') wrap.hidden = !state[key];
      }
    }
    const subject = form.elements.namedItem('subject');
    if (!subject.dataset.touched) subject.value = state.pattern ? `Anfrage: ${state.pattern}` : 'Anfrage zu einer Häkelmütze';
  };

  const showChoices = () => { choices.hidden = false; form.hidden = true; success.hidden = true; };

  function openDialog() {
    update(); showChoices(); feedback.textContent = ''; feedback.classList.remove('is-error');
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
  form.elements.namedItem('subject').addEventListener('input', e => { e.target.dataset.touched = '1'; });

  document.getElementById('show-form').addEventListener('click', () => {
    choices.hidden = true; form.hidden = false; update();
    form.elements.namedItem('name').focus();
  });
  document.getElementById('form-back').addEventListener('click', () => {
    showChoices(); update(); whatsapp.focus();
  });

  const fail = (text, field) => {
    feedback.textContent = text; feedback.classList.add('is-error');
    if (field) { field.setAttribute('aria-invalid', 'true'); field.focus(); }
  };

  form.addEventListener('submit', async event => {
    event.preventDefault();
    form.querySelectorAll('[aria-invalid]').forEach(el => el.removeAttribute('aria-invalid'));
    feedback.classList.remove('is-error');
    const el = name => form.elements.namedItem(name);
    if (!el('name').value.trim()) return fail('Bitte gib deinen Namen an.', el('name'));
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(el('email').value.trim())) return fail('Bitte gib eine gültige E-Mail-Adresse an, damit wir dir antworten können.', el('email'));
    if (!el('subject').value.trim()) return fail('Bitte gib einen Betreff an.', el('subject'));
    if (!el('message').value.trim()) return fail('Bitte schreib uns kurz, was du dir wünschst.', el('message'));

    feedback.textContent = 'Deine Anfrage wird übermittelt …';
    const button = form.querySelector('button[type="submit"]');
    button.disabled = true;
    try {
      const res = await fetch('/api/inquiry', {method: 'POST', body: new URLSearchParams(new FormData(form))});
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.ok) throw Error(data.error || 'Die Anfrage konnte nicht übermittelt werden. Bitte versuche es später erneut oder schreib uns per WhatsApp.');
      form.hidden = true; choices.hidden = true; feedback.textContent = '';
      document.getElementById('form-success-text').textContent = data.mail_sent
        ? 'Deine Nachricht ist angekommen. Wir melden uns bei dir.'
        : 'Deine Anfrage ist bei uns gespeichert. Die E-Mail-Benachrichtigung hat gerade nicht geklappt – für eine schnelle Antwort schreib uns gern zusätzlich per WhatsApp.';
      success.hidden = false; success.focus();
      form.reset(); delete el('subject').dataset.touched;
    } catch (err) {
      fail(err.message || 'Bitte versuche es später erneut.');
    } finally {
      button.disabled = false;
    }
  });

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
