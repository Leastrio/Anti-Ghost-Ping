defmodule AntiGhostPing.Commands.Etoggle do
  def description, do: "Toggle detection for `@everyone` and `@here` ghost pings"
  def options, do: [%{
    name: "enable",
    description: "The option to enable or disable this setting",
    required: true,
    type: 5
  }]
  def permissions, do: [:manage_channels]

  def slash_command(interaction, [%{value: choice}]) do
    res = case AntiGhostPing.Schema.Guilds.upsert_etoggle(interaction.guild_id, choice) do
      {:ok, _} -> case choice do
        true -> "Enabled everyone and here ghost ping detection."
        false -> "Disabled everyone and here ghost ping detection."
      end
      {:error, _} -> "An error occurred, please try again."
    end

    {:content, res}
  end
end
