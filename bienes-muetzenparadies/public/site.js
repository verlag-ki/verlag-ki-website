(() => {
  const WHATSAPP = '4915734487082';
  const dialog = document.getElementById('contact-dialog');
  const choices = document.getElementById('contact-choices');
  const form = document.getElementById('contact-form');
  const feedback = document.getElementById('form-feedback');
  const success = document.getElementById('form-success');
  const summary = document.getElementById('form-summary');
  const whatsapp = document.getElementById('whatsapp-link');
  const preview = document.getElementById('whatsapp-preview');
  const toggle = document.querySelector('.menu-toggle');
  const mobile = document.getElementById('mobile-nav');
  const state = {pattern: '', head_cm: '', wishes: '', wishesLabel: 'Besondere Wünsche'};

  // Ohne Angaben entspricht die Nachricht genau dem festgelegten Begrüßungstext.
  const message = () => {
    const lines = ['Hallo Biene! 😊', ''];
    if (state.pattern) lines.push('Ich habe dein Mützenparadies entdeckt und interessiere mich für folgende Mütze:', '', `Muster: ${state.pattern}`);
    else lines.push('Ich habe dein Mützenparadies entdeckt und würde gerne eine Mütze anfragen.');
    if (state.head_cm) lines.push(...(state.pattern ? [] : ['']), `Kopfumfang: ${state.head_cm} cm`);
    if (state.wishes) lines.push('', `${state.wishesLabel}:`, state.wishes);
    lines.push('', state.pattern ? 'Kannst du mir sagen, ob das möglich ist und was die Mütze kosten würde?' : 'Kannst du mir sagen, ob mein Wunsch möglich ist?', '', 'Liebe Grüße');
    return lines.join('\n');
  };

  // Überträgt die Auswahl in WhatsApp-Link, Vorschau und Formular.
  const update = () => {
    const text = message();
    whatsapp.href = `https://wa.me/${WHATSAPP}?text=${encodeURIComponent(text)}`;
    preview.textContent = text;
    for (const key of ['pattern', 'head_cm', 'wishes']) form.elements.namedItem(key).value = state[key];
    const parts = [state.pattern && `Muster: ${state.pattern}`, state.head_cm && `Kopfumfang: ${state.head_cm} cm`, state.wishes && `${state.wishesLabel}: ${state.wishes}`].filter(Boolean);
    summary.hidden = !parts.length;
    summary.textContent = parts.length ? 'Wird mitgeschickt – ' + parts.join(' · ') : '';
  };

  const showChoices = () => { choices.hidden = false; form.hidden = true; success.hidden = true; };

  function openDialog() {
    update(); showChoices();
    feedback.textContent = ''; feedback.classList.remove('is-error');
    closeMenu();
    if (!dialog.open) dialog.showModal();
  }

  document.querySelectorAll('[data-contact]').forEach(el => el.addEventListener('click', () => {
    Object.assign(state, {pattern: '', head_cm: '', wishes: '', wishesLabel: 'Besondere Wünsche'});
    openDialog();
  }));

  document.querySelectorAll('#pattern-form').forEach(el => el.addEventListener('submit', event => {
    event.preventDefault();
    const data = new FormData(el);
    state.pattern = el.dataset.pattern || '';
    state.wishesLabel = el.dataset.wishesLabel || 'Besondere Wünsche';
    state.head_cm = String(data.get('head_cm') || '').trim().replace('.', ',');
    state.wishes = String(data.get('wishes') || '').trim();
    openDialog();
  }));

  document.querySelector('[data-close]').addEventListener('click', () => dialog.close());
  dialog.addEventListener('click', event => { if (event.target === dialog) dialog.close(); });

  document.getElementById('show-form').addEventListener('click', () => {
    choices.hidden = true; form.hidden = false; update();
    form.elements.namedItem('name').focus();
  });
  document.getElementById('form-back').addEventListener('click', () => { showChoices(); whatsapp.focus(); });

  const fail = (text, field) => {
    feedback.textContent = text; feedback.classList.add('is-error');
    if (field) { field.setAttribute('aria-invalid', 'true'); field.focus(); }
  };

  form.addEventListener('submit', async event => {
    event.preventDefault();
    form.querySelectorAll('[aria-invalid]').forEach(el => el.removeAttribute('aria-invalid'));
    feedback.classList.remove('is-error');
    const el = name => form.elements.namedItem(name);
    const contact = el('contact').value.trim();
    if (!el('name').value.trim()) return fail('Bitte gib deinen Namen an.', el('name'));
    if (!contact.includes('@') && contact.replace(/\D/g, '').length < 6) return fail('Bitte gib eine Telefonnummer oder E-Mail-Adresse an, damit Biene dir antworten kann.', el('contact'));
    if (!el('message').value.trim()) return fail('Bitte schreib uns kurz, was du dir wünschst.', el('message'));

    feedback.textContent = 'Wird gesendet …';
    const button = form.querySelector('button[type="submit"]');
    button.disabled = true;
    try {
      const res = await fetch('/api/nachricht', {method: 'POST', body: new URLSearchParams(new FormData(form))});
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.ok) throw Error(data.error || 'Die Nachricht konnte nicht gesendet werden. Bitte versuche es später erneut oder schreib per WhatsApp.');
      form.hidden = true; feedback.textContent = '';
      success.hidden = false; success.focus();
      el('name').value = ''; el('contact').value = ''; el('message').value = '';
    } catch (err) {
      fail(err.message);
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

  // Bildergalerie der Musterseite
  const mainImage = document.getElementById('main-image');
  document.querySelectorAll('.thumbs button').forEach(btn => btn.addEventListener('click', () => {
    mainImage.src = btn.dataset.src; mainImage.alt = btn.dataset.alt;
    document.querySelectorAll('.thumbs button').forEach(b => b.removeAttribute('aria-current'));
    btn.setAttribute('aria-current', 'true');
  }));
})();
