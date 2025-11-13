FROM node:24.7.0-alpine3.21 AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.15.1 --activate

FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm run build

FROM caddy:2.10.2-alpine AS production
COPY --from=builder --chown=caddy:caddy /app/dist /srv
EXPOSE 80 443