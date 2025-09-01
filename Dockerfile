FROM node:22-bookworm-slim AS base

ENV CHROME_BIN="/usr/bin/chromium" \
    #PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium" \
    NODE_ENV="production"

WORKDIR /usr/src/app

FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts

FROM base

# Install Chromium + necessary libs for headless chrome
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      fonts-liberation \
      libasound2 \
      libatk1.0-0 \
      libc6 \
      libcairo2 \
      libexpat1 \
      libfontconfig1 \
      libfreetype6 \
      libgbm1 \
      libglib2.0-0 \
      libgtk-3-0 \
      libnspr4 \
      libnss3 \
      libx11-6 \
      libx11-xcb1 \
      libxcomposite1 \
      libxdamage1 \
      libxrandr2 \
      libxss1 \
      libxshmfence1 \
      lsb-release \
      wget \
      gnupg \
      chromium \
      ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy node_modules produced in deps stage
COPY --from=deps /usr/src/app/node_modules ./node_modules

# Copy app
COPY . .

EXPOSE 3000
CMD ["npm", "start"]