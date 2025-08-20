FROM node:20-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml* package-lock.json* yarn.lock* ./
RUN npm i -g pnpm || true && (pnpm i || npm i)
COPY . .
EXPOSE 8787
CMD ["npm","run","api"]
