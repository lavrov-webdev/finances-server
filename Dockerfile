# First stage: install necessary packages and build dependencies
FROM node:18 AS builder

WORKDIR /usr/src/app

COPY package.json ./
COPY yarn.lock ./
COPY . .

RUN yarn
RUN yarn prisma migrate deploy
RUN yarn build

# Second stage: get only specific files from first stage and install packages
FROM node:18

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/dist ./dist
COPY package.json yarn.lock ./

RUN apt-get update && \
    apt-get install -y wget postgresql-client && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
         --output-document ./prisma/root.crt && \
    mkdir -p ~/.postgresql && \
    mv ./prisma/root.crt ~/.postgresql/root.crt && \
    chmod 0600 ~/.postgresql/root.crt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD [ "node", "dist/main.js" ]