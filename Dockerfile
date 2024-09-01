FROM node:18-alpine

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем package.json и yarn.lock в контейнер
COPY package.json yarn.lock ./

# Устанавливаем зависимости
RUN yarn

RUN apk update && \
    apk add --no-cache wget postgresql-client && \
    mkdir -p ./prisma && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
         --output-document ./prisma/root.crt && \
    chmod 0600 ./prisma/root.crt && \
    rm -rf /var/cache/apk/*
    
RUN yarn prisma generate

# Копируем остальные файлы в контейнер
COPY . .

RUN yarn prisma migrate deploy
# Собирать проект
RUN yarn build

# Определяем команду для запуска вашего приложения
CMD ["yarn", "start:prod"]