FROM node:20-alpine

WORKDIR /app

# Kopírování souborů projektu
COPY package.json yarn.lock ./

# Instalace závislostí
RUN yarn install

# Kopírování zbytku souborů
COPY . .

# Build aplikace
RUN yarn build

# Nastavení proměnných prostředí
ENV NODE_ENV=production

# Expose port
EXPOSE 9000

# Spuštění aplikace s migracemi
CMD ["/bin/sh", "-c", "echo 'Running database migrations...' && yarn predeploy && echo 'Starting Medusa server...' && yarn start"]
