# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx nx build api --prod

# Stage 2: Production
FROM node:18-alpine

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

RUN chown node:node /app

USER node

COPY --from=builder --chown=node:node /app/dist/api ./

RUN npm install --omit=dev

EXPOSE 3000
CMD ["node", "src/main.js"]