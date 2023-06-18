import Config

config :anti_ghost_ping, AntiGhostPing.Cache,
  # GC interval for pushing new generation: 12 hrs
  gc_interval: :timer.hours(12),
  # Max 1 million entries in cache
  max_size: 1_000_000,
  # Max 2 GB of memory
  allocated_memory: 20_000_000_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

config :anti_ghost_ping, AntiGhostPing.Repo,
  database: "agp",
  username: "agp",
  password: "password",
  hostname: "database"

config :nostrum,
  token: "",
  num_shards: :auto,
  gateway_intents: [
    :message_content,
    :guilds,
    :guild_messages
  ],
  caches: %{
    presences: Nostrum.Cache.PresenceCache.NoOp,
    guilds: Nostrum.Cache.GuildCache.NoOp,
    channels: Nostrum.Cache.ChannelCache.NoOp,
    members: Nostrum.Cache.MemberCache.NoOp,
    users: Nostrum.Cache.UserCache.Mnesia,
    channel_guild_mapping: Nostrum.Cache.ChannelGuildMapping.NoOp
  }

config :anti_ghost_ping,
  ecto_repos: [AntiGhostPing.Repo]

config :logger, level: :info
