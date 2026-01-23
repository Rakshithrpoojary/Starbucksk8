FROM node:alpine as builder

WORKDIR /app

COPY /package.*.json .

RUN npm install

COPY . .
RUN npm run build

FROM node:alpine
WORKDIR /app
COPY --from=builder /app/build ./build

EXPOSE 3000
CMD ["serve","-s","build","-l","3000"]