defmodule AntiGhostPing.Repo do
  use Ecto.Repo,
    otp_app: :anti_ghost_ping,
    adapter: Ecto.Adapters.Postgres
end
