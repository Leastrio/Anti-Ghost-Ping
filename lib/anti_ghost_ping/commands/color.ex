defmodule AntiGhostPing.Commands.Color do
  import Nostrum.Struct.Embed
  alias AntiGhostPing.GhostPing

  def description, do: "Set a color for the ghost ping alert"
  def options, do: [%{
    name: "color",
    description: "Color to set the alert",
    required: true,
    type: 3,
    autocomplete: true
  }]
  def permissions, do: [:manage_channels]

  def slash_command(interaction, [%{value: color}]) do
    try do
      hex = parse_color(color)
      AntiGhostPing.Schema.Guilds.upsert_color(interaction.guild_id, hex)
      embed = %Nostrum.Struct.Embed{}
      |> put_title("Example Ghost Ping Alert")
      |> put_color(if(hex == -1, do: GhostPing.rand_color, else: hex))
      |> put_thumbnail("https://ghostping.xyz/static/assets/bot_logo.png")
      [content: "Color successfully set! Below is a preview of the color", embed: embed]
    rescue
      _ -> {:content, "Invalid Hex code. Ex. `#FFFFFF`"}
    end
  end

  def parse_color(color) do
    case color do
      "random" -> -1
      "teal" -> 1752220
      "green" -> 3066993
      "blue" -> 3447003
      "purple" -> 10181046
      "magenta" -> 15277667
      "gold" -> 15844367
      "orange" -> 15105570
      "red" -> 16711712
      "yellow" -> 16705372
      "og blurple" -> 7506394
      "blurple" -> 5793266
      "dark theme" -> 3553599
      _ -> parse_hex(color)
    end
  end

  def parse_hex(hex) do
    hex = hex |> String.trim() |> String.trim_leading("#")
    if String.length(hex) != 6 || not String.match?(hex, ~r/^[[:xdigit:]]+$/) do
      raise ArgumentError
    else
      String.to_integer(hex, 16)
    end
  end

  def handle_autocomplete(interaction) do
    if interaction.data.name == "color" do
      resp = %{
        type: 8,
        data: %{
          choices: [
            %{name: "random", value: "random"},
            %{name: "teal", value: "teal"},
            %{name: "green", value: "green"},
            %{name: "blue", value: "blue"},
            %{name: "purple", value: "purple"},
            %{name: "magenta", value: "magenta"},
            %{name: "gold", value: "gold"},
            %{name: "orange", value: "orange"},
            %{name: "red", value: "red"},
            %{name: "yellow", value: "yellow"},
            %{name: "og blurple", value: "og blurple"},
            %{name: "blurple", value: "blurple"},
            %{name: "dark theme", value: "dark theme"},
          ]
        }
      }
      Nostrum.Api.create_interaction_response!(interaction, resp)
    end
  end
end
