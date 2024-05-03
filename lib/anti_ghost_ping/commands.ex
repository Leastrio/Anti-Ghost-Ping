defmodule AntiGhostPing.Commands do
  alias AntiGhostPing.Commands

  @commands %{
    "info" => Commands.Info,
    "etoggle" => Commands.Etoggle,
    "redirect" => Commands.Redirect,
    "mentions" => Commands.Mention,
    "color" => Commands.Color,
    "whitelist" => Commands.Whitelist,

    # Support server only
    "debug" => Commands.Debug
  }

  def get_commands() do
    @commands
    |> Enum.filter(fn {name, _} -> name != "debug" end)
    |> Enum.map(fn {name, module} ->
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
      perms -> to_string(Nostrum.Permission.to_bitset(perms))
    end
  end

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: cmd, options: opts}} = interaction) do
    resp =
      case Enum.find(@commands, :error, fn {name, _} -> cmd == name end) do
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
