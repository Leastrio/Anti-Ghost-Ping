defmodule AntiGhostPing.Commands.Mention do
  def description, do: "Toggle for alerts to only contain mentions and no message content"
  def options, do: [%{
    name: "enable",
    description: "The option to enable or disable this setting",
    required: true,
    type: 5
  }]
  def permissions, do: [:manage_channels]

  def slash_command(interaction, [%{value: choice}]) do
    res = case AntiGhostPing.Schema.Guilds.upsert_mention(interaction.guild_id, choice) do
      {:ok, _} -> case choice do
        true -> "Ghost ping alerts will now only contain mentions."
        false -> "Ghost ping alerts will now contain full message content."
      end
      {:error, _} -> "An error occurred, please try again."
    end

    {:content, res}
  end
end
