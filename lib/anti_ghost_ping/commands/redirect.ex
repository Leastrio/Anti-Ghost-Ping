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
  def permissions, do: 16

  def slash_command(interaction, options) do
    res = case options do
      nil ->
        case Guilds.upsert_redirect(interaction.guild_id, nil) do
          {:ok, _} -> "Removed default ghost ping output channel."
          {:error, _} -> "An error occurred, please try again."
        end
      [%{name: "channel", value: channel_id}] ->
        case Guilds.upsert_redirect(interaction.guild_id, channel_id) do
          {:ok, _} -> "Set default ghost ping alert channel to: <##{channel_id}>"
          {:error, _} -> "An error occurred, please try again."
        end
      _ -> "An error occurred, please try again."
    end

    Nostrum.Api.create_interaction_response!(interaction, %{
      type: 4,
      data: %{
        content: res
      }
    })
  end
end
