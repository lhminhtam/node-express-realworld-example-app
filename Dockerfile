# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
# Thay đổi dòng này cho đúng với vị trí thực tế của thư mục prisma
COPY src/prisma ./src/prisma/ 

RUN npm install

COPY . .

# Chỉ định rõ đường dẫn file schema khi generate
RUN npx prisma generate --schema ./src/prisma/schema.prisma

RUN npx nx build --prod

# Stage 2: Runtime
FROM node:18-alpine
WORKDIR /app

COPY --from=builder /app/dist/api ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
# Copy cả thư mục prisma sang để chạy ở môi trường production nếu cần
COPY --from=builder /app/src/prisma ./src/prisma 

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["node", "dist/main.js"]