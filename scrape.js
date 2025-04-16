const fs = require('fs');
const puppeteer = require('puppeteer');

const url = process.env.SCRAPE_URL || 'https://example.com';

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new', // Required by Puppeteer 20+
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    executablePath: '/usr/bin/chromium-browser'
  });

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'domcontentloaded' });

  const data = await page.evaluate(() => {
    return {
      title: document.title,
      heading: document.querySelector('h1')?.innerText || 'No H1 found'
    };
  });

  fs.writeFileSync('scraped_data.json', JSON.stringify(data, null, 2));
  console.log('✅ Scraping complete. Data saved to scraped_data.json');

  await browser.close();
})();
