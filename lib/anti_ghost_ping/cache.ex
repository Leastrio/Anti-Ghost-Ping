defmodule AntiGhostPing.Cache do
  use Nebulex.Cache,
    otp_app: :anti_ghost_ping,
    adapter: Nebulex.Adapters.Local
end
