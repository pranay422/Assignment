# Stage 1: Scraper
FROM node:18-slim as scraper

# Install Chromium and required tools
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app

COPY package.json ./
RUN npm install

COPY scrape.js ./

# Set SCRAPE_URL to example.com by default
ARG SCRAPE_URL=https://example.com
ENV SCRAPE_URL=${SCRAPE_URL}

RUN node scrape.js

# Stage 2: Python Flask server
FROM python:3.10-slim

WORKDIR /app

COPY --from=scraper /app/scraped_data.json ./scraped_data.json
COPY server.py ./
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]
