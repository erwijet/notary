FROM node:lts
WORKDIR /app

ARG VITE_HOST
ARG VITE_NOTARY_KEY

ENV VITE_HOST=$VITE_HOST
ENV VITE_NOTARY_HOST=$VITE_NOTARY_HOST

RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml /app
RUN pnpm install --frozen-lockfile

COPY index.html vite.config.ts tsconfig* /app
COPY src/ /app/src
RUN pnpm build

CMD ["npx", "serve", "dist"]
