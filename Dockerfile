# Stage 1: Build stage
FROM node:20-alpine as builder

# Install additional build dependencies
RUN apk add --no-cache git python3 make g++

# Set working directory
WORKDIR /app

# Copy package files first to leverage cache
COPY package.json yarn.lock ./

# Install dependencies including admin
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY . ./

# Build the admin panel explicitly using medusa-admin build
RUN yarn add @medusajs/admin-ui
RUN yarn medusa-admin build --deployment
RUN echo "--- [BUILDER STAGE] Listing /app after admin build ---" && ls -Al /app
RUN echo "--- [BUILDER STAGE] Listing /app/build after admin build (if it exists) ---" && (ls -Al /app/build || echo "/app/build does not exist or is empty")
RUN echo "--- [BUILDER STAGE] Finding index.html in /app after admin build ---" && (find /app -name index.html -ls || echo "index.html not found in /app")


# Build the Medusa backend
RUN yarn build

# Stage 2: Production stage
FROM node:20-alpine

ENV NODE_ENV=production \
    DISABLE_MEDUSA_ADMIN=false \
    DB_HOST=postgres \
    DB_PORT=5432

WORKDIR /app

# Copy necessary files from builder
COPY --from=builder /app/dist/ ./dist/
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/node_modules/ ./node_modules/
# Copy the admin build files to the correct location
COPY --from=builder /app/build/ ./build/
RUN echo "--- [PRODUCTION STAGE] Listing /app/build after copy ---" && (ls -A /app/build || echo "/app/build does not exist or is empty")
RUN echo "--- [PRODUCTION STAGE] Finding index.html in /app after copy ---" && (find /app -name index.html -ls || echo "index.html not found in /app")

# Expose the default Medusa port
EXPOSE 9000

# Run migrations and start the server
CMD ["/bin/sh", "-c", "yarn medusa migrations run && yarn medusa start"]