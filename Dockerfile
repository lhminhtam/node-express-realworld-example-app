# Stage 1: Build the application
FROM node:18-alpine as builder

WORKDIR /app

COPY package*.json ./
COPY src/prisma ./src/prisma

RUN npm install

COPY . .

RUN npx prisma generate --schema ./src/prisma/schema.prisma
RUN npx run build

# Stage 2: Run the application
FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app/dist/api ./dist/api
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src/prisma ./src/prisma

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["node", "dist/main.js"]
