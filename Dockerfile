FROM docker.io/node:20 AS build-portal
WORKDIR /portal
RUN npm install -g pnpm

COPY ./portal /portal

# see: https://github.com/npm/cli/issues/4828
#   npm bug requires us to delete node_modules/ and our lockfile
#   if they exist when compiling on a different platform (such is the case here)

RUN rm pnpm-lock.yaml \ 
    && rm -rf node_modules \
    && pnpm install \
    && pnpm run build

FROM docker.io/hexpm/elixir:1.15.7-erlang-24.3.4.16-ubuntu-focal-20240123
WORKDIR /app

RUN PROTOC_ZIP=protoc-3.20.3-linux-aarch_64.zip \
    && apt-get update \
    && apt-get install -y curl unzip \
    && curl -OL "https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/$PROTOC_ZIP" \
    && unzip -o "$PROTOC_ZIP" -d /usr/local bin/protoc \
    && unzip -o "$PROTOC_ZIP" -d /usr/local 'include/*' \
    && rm -f $PROTOC_ZIP

COPY mix.exs    /app
COPY mix.lock   /app
COPY ./protos   /app/protos
COPY ./lib      /app/lib
COPY ./config   /app/config
COPY ./priv /app/priv

COPY --from=build-portal /portal /app/portal

RUN mix deps.get
RUN mix escript.install hex protobuf --force
RUN PATH=~/.mix/escripts:$PATH protoc --elixir_out=plugins=grpc:./lib/ protos/notary.proto
RUN MIX_ENV=prod mix release

CMD "mix ecto.migrate && _build/prod/rel/notary/bin/notary start"