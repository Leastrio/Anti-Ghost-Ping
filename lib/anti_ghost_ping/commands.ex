defmodule AntiGhostPing.Commands do
  alias AntiGhostPing.Commands

  @commands %{
    "info" => Commands.Info,
    "etoggle" => Commands.Etoggle,
    "redirect" => Commands.Redirect,
    "mentions" => Commands.Mention,
    "color" => Commands.Color,
    "whitelist" => Commands.Whitelist,
  }

  @support_commands %{
    "debug" => Commands.Debug,
    "stats" => Commands.Stats
  }

  @all_commands Map.merge(@commands, @support_commands)

  def commands(), do: get_commands(@commands)
  def support_commands(), do: get_commands(@support_commands)
  defp get_commands(commands) do
    Enum.map(commands, fn {name, module} ->
      %{
        name: name,
        description: apply(module, :description, []),
        options: apply(module, :options, []),
        dm_permission: false,
        default_member_permissions: to_bitset(apply(module, :permissions, []))
      }
    end)
  end

  def to_bitset(permissions) do
    case permissions do
      :everyone -> nil
      :noone -> "0"
      perms -> to_string(Nostrum.Permission.to_bitset(perms))
    end
  end

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: cmd, options: opts}} = interaction) do
    resp =
      case Enum.find(@all_commands, :error, fn {name, _} -> cmd == name end) do
        {_, module} -> apply(module, :slash_command, [interaction, opts])
        :error -> {:content, "Unknown command"}
      end

    case resp do
      {:edit, data} ->
        Nostrum.Api.edit_interaction_response(interaction, build_interaction_reply(data))

      data when is_list(data) ->
        Nostrum.Api.create_interaction_response(interaction, %{
          type: 4,
          data: build_interaction_reply(data)
        })

      data when is_tuple(data) ->
        Nostrum.Api.create_interaction_response(interaction, %{
          type: 4,
          data: build_interaction_reply(data)
        })

      _ ->
        :noop
    end
  end

  def build_interaction_reply(list) when is_list(list), do: build_interaction_reply(list, %{})

  def build_interaction_reply(tuple) when is_tuple(tuple),
    do: build_interaction_reply([tuple], %{})

  def build_interaction_reply([{:content, msg} | tail], reply),
    do: build_interaction_reply(tail, Map.put(reply, :content, msg))

  def build_interaction_reply([{:embed, embed} | tail], reply),
    do: build_interaction_reply(tail, Map.put(reply, :embeds, [embed]))

  def build_interaction_reply([{:file, {name, content}} | tail], reply),
    do: build_interaction_reply(tail, Map.put(reply, :file, %{name: name, body: content}))

  def build_interaction_reply([:ephemeral | tail], reply),
    do: build_interaction_reply(tail, Map.put(reply, :flags, 64))

  def build_interaction_reply([], reply), do: reply
end
