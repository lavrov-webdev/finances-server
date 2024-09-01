# Базовый образ для сборки порядка
FROM node:18-alpine AS builder

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем package.json и yarn.lock в контейнер
COPY package.json yarn.lock ./

# Устанавливаем зависимости
RUN yarn --frozen-lockfile

# Копируем исходные файлы и файлы Prisma в контейнер
COPY . .

# Генерация Prisma клиента
RUN yarn prisma generate

# Собирать проект
RUN yarn build

# Базовый образ для запуска
FROM node:18-alpine AS runner

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Устанавливаем runtime зависимости
RUN apk update && \
    apk add --no-cache postgresql-client && \
    mkdir -p ./prisma && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
         --output-document ./prisma/root.crt && \
    chmod 0600 ./prisma/root.crt && \
    rm -rf /var/cache/apk/*

# Копируем только необходимые файлы из builder стадии
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/dist ./dist

# Применяем миграции Prisma
RUN yarn prisma migrate deploy

# Определяем команду для запуска вашего приложения
CMD ["node", "dist/main.js"]