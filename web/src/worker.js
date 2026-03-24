import { EmailMessage } from 'cloudflare:email';
import { createMimeMessage } from 'mimetext';

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      return handleContact(request, env);
    }

    return env.ASSETS.fetch(request);
  },
};

async function handleContact(request, env) {
  const headers = { 'Content-Type': 'application/json' };

  try {
    const body = await request.json();
    const { name, email, subject, message } = body;

    if (!name || !email || !subject || !message) {
      return new Response(JSON.stringify({ error: 'All fields are required' }), {
        status: 400,
        headers,
      });
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return new Response(JSON.stringify({ error: 'Invalid email' }), {
        status: 400,
        headers,
      });
    }

    const msg = createMimeMessage();
    msg.setSender({ name: 'AISight', addr: 'noreply@private-search-intelligence.app' });
    msg.setRecipient('jesus@perezpaz.es');
    msg.setSubject(`[AISight] ${subject}: from ${name} (${email})`);
    msg.addMessage({
      contentType: 'text/plain',
      data: [
        'New contact form submission from AISight website:',
        '',
        `Name: ${name}`,
        `Email: ${email}`,
        `Subject: ${subject}`,
        '',
        'Message:',
        message,
      ].join('\n'),
    });

    const emailMessage = new EmailMessage(
      'noreply@private-search-intelligence.app',
      'jesus@perezpaz.es',
      msg.asRaw(),
    );

    await env.EMAIL.send(emailMessage);

    return new Response(JSON.stringify({ success: true }), { status: 200, headers });
  } catch (err) {
    console.error('Contact form error:', err);
    return new Response(JSON.stringify({ error: 'Server error' }), {
      status: 500,
      headers,
    });
  }
}
