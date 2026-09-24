const form = document.getElementById('fraud-form');
const resultEl = document.getElementById('result');
const statusEl = document.getElementById('status');

const API_URL = window.LAMBDA_FUNCTION_URL || '';

if (!API_URL) {
  statusEl.textContent = 'Lambda URL not configured yet. Run the deploy script after Terraform apply.';
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();

  if (!API_URL) {
    resultEl.textContent = 'Lambda URL not configured yet.';
    return;
  }

  const payload = {
    timestamp: document.getElementById('timestamp').value,
    name: document.getElementById('name').value,
    value: Number(document.getElementById('value').value),
    location: document.getElementById('location').value
  };

  statusEl.textContent = 'Sending transaction to Lambda...';
  resultEl.textContent = 'Waiting for response...';

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const raw = await response.text();
    let data = raw;

    try {
      data = JSON.parse(raw);
    } catch (error) {
      // leave raw text if not JSON
    }

    statusEl.textContent = 'Request completed successfully.';
    resultEl.textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    statusEl.textContent = 'Request failed.';
    resultEl.textContent = `Error: ${error.message}`;
    console.error(error);
  }
});
