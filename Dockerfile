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
ENV NODE_ENV=production
ENV DISABLE_MEDUSA_ADMIN=false

# Build aplikace včetně admin dashboardu
RUN yarn build

# Kontrola, zda byl admin dashboard sestaven
RUN if [ -d ".medusa/admin" ]; then \
      echo "Admin dashboard built successfully"; \
    else \
      echo "Admin dashboard build failed"; \
      exit 1; \
    fi

# Expose port
EXPOSE 9000

# Spuštění aplikace s migracemi
CMD ["/bin/sh", "-c", "echo 'Running database migrations...' && yarn predeploy && echo 'Starting Medusa server...' && yarn start"]