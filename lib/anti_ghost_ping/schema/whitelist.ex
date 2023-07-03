defmodule AntiGhostPing.Schema.Whitelist do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  @primary_key false
  schema "whitelist" do
    field :guild_id, :integer, primary_key: true
    field :user_id, :integer, primary_key: true
  end

  def whitelisted?(guild_id, user_id) do
    AntiGhostPing.Repo.exists?(from u in __MODULE__, where: u.guild_id == ^guild_id and u.user_id == ^user_id)
  end

  def add_user(guild_id, user_id) do
    AntiGhostPing.Repo.insert(%__MODULE__{guild_id: guild_id, user_id: user_id})
  end

  def remove_user(guild_id, user_id) do
    AntiGhostPing.Repo.delete(%__MODULE__{guild_id: guild_id, user_id: user_id})
  end

  def list(guild_id) do
    AntiGhostPing.Repo.all(from u in __MODULE__, where: u.guild_id == ^guild_id, select: u.user_id)
  end
end
