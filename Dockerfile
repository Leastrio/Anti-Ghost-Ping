FROM elixir:1.15.4 as builder

ENV MIX_ENV="prod"

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
copy rel rel
COPY .git .git

RUN mix release

FROM elixir:1.15.4-slim

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/anti_ghost_ping ./

CMD ["sh", "-c", "/app/bin/anti_ghost_ping eval \"AntiGhostPing.migrate\" && /app/bin/anti_ghost_ping start"]

