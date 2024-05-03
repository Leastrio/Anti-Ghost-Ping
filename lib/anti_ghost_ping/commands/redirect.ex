defmodule AntiGhostPing.Commands.Redirect do
  alias AntiGhostPing.Schema.Guilds

  def description, do: "Set a channel for all ghost ping messages to get redirected to"
  def options, do: [%{
    name: "channel",
    description: "The channel for alerts to redirect to (Emit this option to reset)",
    required: false,
    type: 7,
    channel_types: [0, 5]
  }]
  def permissions, do: [:manage_channels]

  def slash_command(interaction, nil) do
    resp = case Guilds.upsert_redirect(interaction.guild_id, nil) do
      {:ok, _} -> "Removed default ghost ping output channel."
      {:error, _} -> "An error occurred, please try again."
    end

    {:content, resp}
  end

  def slash_command(interaction, [%{value: channel_id}]) do
    resp = case Guilds.upsert_redirect(interaction.guild_id, channel_id) do
      {:ok, _} -> "Set default ghost ping alert channel to: <##{channel_id}>"
      {:error, _} -> "An error occurred, please try again."
    end
    
    {:content, resp}
  end
end
