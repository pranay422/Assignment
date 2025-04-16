# Stage 1: Node.js Scraper
FROM node:18-slim as scraper

# Install Chromium and dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Set workdir and copy project
WORKDIR /app
COPY package.json ./
RUN npm install
COPY scrape.js ./

# Accept SCRAPE_URL as build argument
ARG SCRAPE_URL=https://example.com
ENV SCRAPE_URL=${SCRAPE_URL}

# Run scraping
RUN node scrape.js

# Stage 2: Python Flask Server
FROM python:3.10-slim

WORKDIR /app

# Copy scraped data only
COPY --from=scraper /app/scraped_data.json ./
COPY server.py ./
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]
