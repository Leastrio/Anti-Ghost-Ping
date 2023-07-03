defmodule AntiGhostPing.Repo.Migrations.CreateWhitelist do
  use Ecto.Migration

  def change do
    create table(:whitelist, primary_key: false) do
      add :guild_id, :bigint, primary_key: true
      add :user_id, :bigint, primary_key: true
    end
  end
end
