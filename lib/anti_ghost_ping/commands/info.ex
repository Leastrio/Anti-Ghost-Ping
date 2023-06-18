defmodule AntiGhostPing.Commands.Info do
  import Nostrum.Struct.Embed

  def description, do: "View info about the bot"
  def options, do: []
  def permissions, do: 2147483648

  def slash_command(interaction) do
    embed = %Nostrum.Struct.Embed{}
    |> put_description("""
      - You can invite Anti Ghost Ping to your own server by clicking **[here](https://ghostping.xyz/invite)**
      - Join the support server for help **[here](https://ghostping.xyz/discord)**
      """)
    |> put_color(16711712)

    Nostrum.Api.create_interaction_response!(interaction, %{
      type: 4,
      data: %{
        embeds: [embed]
      }
    })
  end
end
