defmodule AntiGhostPing.Commands.Whitelist do
  import Nostrum.Struct.Embed

  def description, do: "Whitelist users to allow them to ghost ping"
  def options, do: [
    %{
      type: 1,
      name: "add",
      description: "Add a member to the whitelist",
      options: [%{
        type: 6,
        name: "member",
        description: "Member to add",
        required: true
      }]
    },
    %{
      type: 1,
      name: "remove",
      description: "Remove a member from the whitelist",
      options: [%{
        type: 6,
        name: "member",
        description: "member to remove",
        required: true
      }]
    },
    %{
      type: 1,
      name: "list",
      description: "Show all whitelisted users"
    }
  ]
  def permissions, do: [:manage_channels]

  def slash_command(interaction, [%{name: "list"}]), do: {:embed, gen_list_embed(interaction.guild_id)}

  def slash_command(interaction, [%{name: "add", options: [%{name: "member", value: id}]}]) do
    whitelist = AntiGhostPing.Schema.Whitelist.list(interaction.guild_id)
    resp = case Enum.any?(whitelist, fn whitelist_user -> whitelist_user == id end) do
      true -> "Member already whitelisted, no changes happened."
      false ->
        if Enum.count(whitelist) + 1 > 15 do
          "This guild has hit the 15 member whitelist max!"
        else
          AntiGhostPing.Schema.Whitelist.add_user(interaction.guild_id, id)
          "Member added to whitelist."
        end
    end
    
    {:content, resp}
  end

  def slash_command(interaction, [%{name: "remove", options: [%{name: "member", value: id}]}]) do
    resp = case AntiGhostPing.Schema.Whitelist.whitelisted?(interaction.guild_id, id) do
      false -> "Member not in whitelist, no changed happened."
      true ->
        AntiGhostPing.Schema.Whitelist.remove_user(interaction.guild_id, id)
        "Member removed from whitelist."
    end

    {:content, resp}
  end

  defp gen_list_embed(guild_id) do
    %Nostrum.Struct.Embed{}
      |> put_title("Whitelist")
      |> put_description(
        Enum.chunk_every(AntiGhostPing.Schema.Whitelist.list(guild_id), 2)
        |> Enum.map(&format_mention/1)
        |> Enum.join("\n")
        )
  end

  defp format_mention([user_1, user_2]), do: "<@#{user_1}> <@#{user_2}>"
  defp format_mention([user]), do: "<@#{user}>"
end
