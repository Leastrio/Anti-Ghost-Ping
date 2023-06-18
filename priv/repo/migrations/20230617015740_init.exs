defmodule AntiGhostPing.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:guilds, primary_key: false) do
      add :guild_id, :bigint, primary_key: true
      add :channel_id, :bigint
      add :everyone, :boolean
      add :mention_only, :boolean
      add :color, :integer
    end
  end
end
