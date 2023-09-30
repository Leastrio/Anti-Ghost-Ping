FROM elixir:1.15.4 as build

COPY config config
COPY lib lib
COPY priv priv
COPY mix.exs mix.exs
COPY mix.lock mix.lock
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

RUN mix deps.get && mix release

RUN mkdir /export && \
    cp -r _build/prod/rel/anti_ghost_ping/ /export

FROM elixir:1.15.4

RUN mkdir -p /opt/app
COPY --from=build /export/ /opt/app

CMD ["sh", "-c", "anti_ghost_ping/bin/anti_ghost_ping eval \"AntiGhostPing.migrate\" && anti_ghost_ping/bin/anti_ghost_ping start"]
