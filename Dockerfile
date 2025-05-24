FROM node:20-alpine

WORKDIR /app

# Kopírování souborů projektu
COPY package.json yarn.lock ./
COPY . .

# Instalace závislostí
RUN yarn install

# Build aplikace
RUN yarn build

# Vytvoření startup skriptu
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'set -e' >> /app/start.sh && \
    echo 'echo "Running database migrations..."' >> /app/start.sh && \
    echo 'yarn predeploy' >> /app/start.sh && \
    echo 'echo "Starting Medusa server..."' >> /app/start.sh && \
    echo 'yarn start' >> /app/start.sh && \
    chmod +x /app/start.sh

# Nastavení proměnných prostředí
ENV NODE_ENV=production

# Expose port
EXPOSE 9000

# Spuštění aplikace
CMD ["/app/start.sh"]
