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

# Build the admin panel explicitly using medusa develop
RUN yarn add @medusajs/admin
RUN yarn medusa-admin build --deployment

# Build the Medusa backend
RUN yarn build

# Stage 2: Production stage
FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /app

# Copy necessary files from builder
COPY --from=builder /app/dist/ ./dist/
COPY --from=builder /app/package.json ./
COPY --from=builder /app/yarn.lock ./
COPY --from=builder /app/node_modules/ ./node_modules/
# Copy the admin build files to the correct location
COPY --from=builder /app/build/ ./build/

# Expose the default Medusa port
EXPOSE 9000

# Run migrations and start the server
CMD ["/bin/sh", "-c", "yarn medusa migrations run && yarn medusa start"]