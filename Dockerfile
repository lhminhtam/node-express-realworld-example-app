# Stage 1: Build the application
FROM node:18-alpine as builder

WORKDIR /app

# Copy các file cấu hình trước để tận dụng cache của Docker
COPY package*.json ./
# Đảm bảo đường dẫn này đúng với cấu trúc repo của bạn
COPY src/prisma ./src/prisma

RUN npm install

COPY . .

# Generate Prisma Client
RUN npx prisma generate --schema ./src/prisma/schema.prisma

# Sửa lệnh build của Nx
RUN npx nx build api --prod

# Stage 2: Run the application
FROM node:18-alpine

WORKDIR /app

# Copy các file cần thiết từ stage builder
COPY --from=builder /app/dist/api ./dist/api
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src/prisma ./src/prisma

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Sửa đường dẫn chạy file main.js cho đúng với thư mục đã copy ở trên
CMD ["node", "dist/api/main.js"]