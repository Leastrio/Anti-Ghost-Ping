defmodule AntiGhostPing.Commands.Debug do
  import Nostrum.Struct.Embed
  import Bitwise

  @view_channel 1 <<< 10
  @send_messages 1 <<< 11
  @embed_links 1 <<< 14

  def description, do: "Debug a server"
  def options, do: [
    %{
      type: 3,
      name: "id",
      description: "the server id you want to debug",
      required: true
    }
  ]
  def permissions, do: :everyone

  def slash_command(interaction, [%{value: server_id}]) do
    Nostrum.Api.create_interaction_response!(interaction, %{type: 5})

    resp = case Integer.parse(server_id) do
      {guild_id, _} ->
        case Nostrum.Cache.GuildCache.get(guild_id) do
          {:ok, guild} -> gen_resp(guild)
          _ -> {:content, "Guild not found!"}
        end
      _ -> {:content, "Invalid server id!"}
    end

    {:edit, resp}
  end

  def gen_resp(guild) do
    channels = calc_channel_perms(guild)
    if channels == :all do
      {:content, "I have administrator permissions in this server!"}
    else
      desc = channels 
      |> Enum.sort(fn {first, _, _}, {second, _, _} -> first.position <= second.position end)
      |> Enum.map(fn {channel, read, send} ->
        "  #{emoji(read)}   | #{emoji(send)} - #{channel.name}\n"
      end)

      start_embed = %Nostrum.Struct.Embed{}
      |> put_title("Debug")
      |> put_description("Read | Send Permission\n")

      embeds = Enum.chunk_while(desc, {24, start_embed}, fn curr_channel, {char_count, current_embed} -> 
        channel_length = String.length(curr_channel)
        if channel_length + char_count > 4096 do
          {:cont, current_embed, {24 + channel_length, %Nostrum.Struct.Embed{} |> put_description("Read | Send Permission\n#{curr_channel}")}}
        else
          {:cont, {char_count + channel_length, current_embed |> put_description(current_embed.description <> curr_channel)}}
        end
      end,
      fn {_char_count, current_embed} -> 
        {:cont, current_embed, []}
      end)

      case embeds do
        [embed] -> {:embed, embed}
        _ -> {:debug_embeds, embeds}
      end
    end
  end

  def emoji(has_permission) do
    if has_permission == true do
      "<:DTCloseEmoji:723972002334900276>"
    else
      "<:nodenied:717542786454388776>"
    end
  end

  def calc_base_perms(guild, member) do
    permissions = Enum.reduce(member.roles, guild.roles[guild.id].permissions, fn role_id, acc ->
      role = guild.roles[role_id]
      acc ||| role.permissions
    end)

    if (permissions &&& 8) == 8 do
      :all
    else
      permissions
    end
  end

  def calc_overwrites(base, guild, member, channel) do
    {allow, deny} = Enum.reduce([guild.id | member.roles], {0, 0}, fn role_id, {allow, deny} ->
      case Enum.find(channel.permission_overwrites, nil, fn overwrite -> overwrite.id == role_id end) do
        nil -> {allow, deny}
        %{allow: allow_o, deny: deny_o} -> {allow ||| allow_o, deny ||| deny_o}
      end
    end)

    permissions = (base &&& bnot(deny)) ||| allow

    case Enum.find(channel.permission_overwrites, nil, fn overwrite -> overwrite.id == member.user_id end) do
      nil -> permissions
      %{allow: allow_o, deny: deny_o} -> (permissions &&& bnot(deny_o)) ||| allow_o
    end
  end

  def check_permission(perms) do
    read = (perms &&& @view_channel) == @view_channel 
    send = ((perms &&& @send_messages) == @send_messages) and ((perms &&& @embed_links) == @embed_links)
    {read, send}
  end

  def calc_channel_perms(guild) do
    member = Nostrum.Api.get_guild_member!(guild.id, Nostrum.Cache.Me.get().id)
    base_perms = calc_base_perms(guild, member)
    if base_perms != :all do
      Enum.reduce(guild.channels, [], fn {_, channel}, acc -> 
        case channel.type do
          0 ->
            perms = calc_overwrites(base_perms, guild, member, channel)
            {read, send} = check_permission(perms)
            [{channel, read, send} | acc]
          _ -> acc
        end
      end)
    else
      :all
    end
  end
end

