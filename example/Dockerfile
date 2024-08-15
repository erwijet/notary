FROM node:lts
WORKDIR /app

RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml /app
RUN pnpm install --frozen-lockfile

COPY index.html vite.config.ts tsconfig* /app
COPY src/ /app/src
RUN pnpm build

CMD ["npx", "serve", "dist"]
