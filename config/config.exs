import Config

config :anti_ghost_ping, AntiGhostPing.Cache,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 20_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :anti_ghost_ping, AntiGhostPing.Repo,
  database: "agp",
  username: "agp",
  password: "password",
  hostname: "127.0.0.1"

config :nostrum,
  num_shards: :auto,
  gateway_intents: [
    :message_content,
    :guilds,
    :guild_messages
  ],
  caches: %{
    presences: Nostrum.Cache.PresenceCache.NoOp,
    guilds: Nostrum.Cache.GuildCache.Mnesia,
    members: Nostrum.Cache.MemberCache.NoOp,
    users: Nostrum.Cache.UserCache.NoOp,
    channel_guild_mapping: Nostrum.Cache.ChannelGuildMapping.NoOp
  }

config :anti_ghost_ping,
  ecto_repos: [AntiGhostPing.Repo]

config :logger,
  level: :info,
  compile_time_purge_matching: [
    [module: Nostrum.Shard.Event, level_lower_than: :error],
    [module: Nostrum.Shard.Dispatch]
  ]

if config_env() == :prod do
  config :anti_ghost_ping,
    support_server_id: 713504281260458066
else
  config :anti_ghost_ping,
    support_server_id: 700419839092850698
end
