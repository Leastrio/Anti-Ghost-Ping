defmodule AntiGhostPing.Schema.Guilds do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  @primary_key false
  schema "guilds" do
    field :guild_id, :integer, primary_key: true
    field :channel_id, :integer
    field :everyone, :boolean
    field :mention_only, :boolean
    field :color, :integer
  end

  def get_guild(guild_id) do
    query =
      from g in __MODULE__,
      where: g.guild_id == ^guild_id

    case AntiGhostPing.Repo.one(query) do
      nil -> %__MODULE__{guild_id: guild_id, channel_id: nil, everyone: false, mention_only: false, color: nil}
      config -> config
    end
  end

  def upsert_etoggle(guild_id, choice) do
    AntiGhostPing.Repo.insert(
      %__MODULE__{guild_id: guild_id, everyone: choice},
      on_conflict: [set: [everyone: choice]],
      conflict_target: :guild_id
    )
  end

  def upsert_redirect(guild_id, channel_id) do
    AntiGhostPing.Repo.insert(
      %__MODULE__{guild_id: guild_id, channel_id: channel_id},
      on_conflict: [set: [channel_id: channel_id]],
      conflict_target: :guild_id
    )
  end

  def upsert_mention(guild_id, choice) do
    AntiGhostPing.Repo.insert(
      %__MODULE__{guild_id: guild_id, mention_only: choice},
      on_conflict: [set: [mention_only: choice]],
      conflict_target: :guild_id
    )
  end

  def upsert_color(guild_id, color) do
    AntiGhostPing.Repo.insert!(
      %__MODULE__{guild_id: guild_id, color: color},
      on_conflict: [set: [color: color]],
      conflict_target: :guild_id
    )
  end
end
