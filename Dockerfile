FROM node:20-alpine

# Instalace dodatečných závislostí pro build
RUN apk add --no-cache git python3 make g++ curl

# Nastavení pracovního adresáře
WORKDIR /app

# Kopírování souborů projektu
COPY package.json yarn.lock ./

# Instalace závislostí
RUN yarn install

# Kopírování zbytku souborů
COPY . .

# Nastavení proměnných prostředí pro build
ENV NODE_ENV=development
ENV DISABLE_MEDUSA_ADMIN=false

# Build aplikace včetně admin dashboardu
RUN yarn build

# Nastavení proměnných prostředí pro produkci po buildu
ENV NODE_ENV=production

# Zobrazení struktury adresářů po buildu pro diagnostiku
RUN find . -type d -name "admin" | grep -v "node_modules"
RUN find .medusa -type d | grep -v "node_modules"

# Expose port
EXPOSE 9000

# Spuštění aplikace s migracemi
CMD ["/bin/sh", "-c", "echo 'Running database migrations...' && yarn predeploy && echo 'Starting Medusa server...' && yarn start"]