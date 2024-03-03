# Test comment
# First stage: install necessary packages and build dependencies
FROM node:18 AS builder

WORKDIR /usr/src/app

COPY package.json ./
COPY yarn.lock ./

RUN yarn

COPY . .

RUN apt-get update && \
    apt-get install -y wget postgresql-client && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
         --output-document ./prisma/root.crt && \
    chmod 0600 ./prisma/root.crt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN yarn prisma migrate deploy
RUN yarn build

# Second stage: get only specific files from first stage and install packages
FROM node:18

WORKDIR /usr/src/app

ENV DATABASE_URL $DATABASE_URL

COPY --from=builder /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]