defmodule AntiGhostPing.GhostPing do
  import Nostrum.Struct.Embed
  import Bitwise

  def handle_mention(config, msg) do
    if not AntiGhostPing.Schema.Whitelist.whitelisted?(msg.guild_id, msg.author.id) do
      content = cond do
        String.length(msg.content) > 2500 || config.mention_only ->
          {:mentions, Enum.join(msg.mentions, " ") <> Enum.join(msg.mention_roles, " ")}
        true -> {:message, msg.content}
      end
      send_alert(config, msg, content)
    end
  end

  def handle_everyone(config, msg) do
    if not AntiGhostPing.Schema.Whitelist.whitelisted?(msg.guild_id, msg.author.id) do
      content = cond do
        String.length(msg.content) > 2500 || config.mention_only -> {:mentions, "Message contained @everyone and/or @here ping"}
        true -> {:message, msg.content}
      end
      send_alert(config, msg, content)
    end
  end

  def send_alert(config, msg, {type, content}) do
    embed = %Nostrum.Struct.Embed{}
    |> put_title("Ghost Ping Found!")
    |> put_thumbnail("https://ghostping.xyz/static/assets/bot_logo.png")
    |> put_timestamp(DateTime.to_iso8601(msg.timestamp))
    |> put_field("Author:", "<@#{msg.author.id}>", true)
    |> put_field(String.capitalize(to_string(type)) <> ":", content, true)
    |> maybe_channel_field(config, msg)
    |> put_color(get_color(config))

    channel_id = case config.channel_id do
      nil -> msg.channel_id
      id -> id
    end
    Nostrum.Api.create_message(channel_id, embeds: [embed])
  end

  def maybe_channel_field(embed, config, msg) do
    case config.channel_id do
      nil -> embed
      _ -> embed |> put_field("Channel:", "<##{msg.channel_id}>", true)
    end
  end

  def get_color(config) do
    case config.color do
      -1 -> rand_color()
      nil -> 16711712
      color -> color
    end
  end

  def rand_color() do
    r = Enum.random(0..255)
    g = Enum.random(0..255)
    b = Enum.random(0..255)
    (r <<< 16) + (g <<< 8) + b
  end
end
