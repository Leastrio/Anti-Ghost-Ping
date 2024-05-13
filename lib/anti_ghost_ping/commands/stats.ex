defmodule AntiGhostPing.Commands.Stats do
  import Nostrum.Struct.Embed

  def description, do: "Bot Stats"
  def options, do: []
  def permissions, do: :noone

  def slash_command(interaction, _) do
    Nostrum.Api.create_interaction_response!(interaction, %{type: 5})
    top = :agp_guild_qlc.top(5)

    embed = %Nostrum.Struct.Embed{}
            |> put_color(16711712)
            |> fill_fields(top)

    {:edit, {:embed, embed}}
  end


  def fill_fields(embed, []), do: embed
  def fill_fields(embed, [{{count, _}, guild} | rest]) do
    embed
    |> put_field("#{count}", guild.name)
    |> fill_fields(rest)
  end
end
