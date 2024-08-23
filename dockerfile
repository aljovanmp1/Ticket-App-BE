FROM elixir:alpine

RUN apk update && apk add inotify-tools
RUN apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile
COPY . .

EXPOSE 4000
CMD ["mix", "phx.server"]