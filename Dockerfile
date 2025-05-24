FROM node:20-alpine

# Nastavení pracovního adresáře
WORKDIR /app

# Kopírování package manager souborů pro backend
COPY package.json yarn.lock ./

# Instalace závislostí backendu
RUN yarn install

# Kopírování celého projektu
COPY . .

# Vstup do admin složky a build admin rozhraní
RUN cd admin && yarn install && yarn build

# Build backendu (např. Typescript)
RUN yarn build

# Nastavení prostředí
ENV NODE_ENV=production

# Exponuj port
EXPOSE 9000

# Spuštění aplikace s migracemi a serverem
CMD ["/bin/sh", "-c", "echo 'Running DB migrations...' && yarn predeploy && echo 'Starting Medusa server...' && yarn start"]
