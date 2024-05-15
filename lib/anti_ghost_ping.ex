defmodule AntiGhostPing do
  @app :anti_ghost_ping

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  def profile() do
    :fprof.start()
    :fprof.apply(:agp_guild_qlc, :apply, [5])
    :fprof.profile()
    :fprof.analyse(totals: false, dest: 'prof.analysis')
    :fprof.stop()
  end
end
