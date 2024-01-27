defmodule AntiGhostPing.Commands do
  alias AntiGhostPing.Commands

  @commands %{
    "info" => Commands.Info,
    "etoggle" => Commands.Etoggle,
    "redirect" => Commands.Redirect,
    "mentions" => Commands.Mention,
    "color" => Commands.Color,
    "whitelist" => Commands.Whitelist
  }

  def get_commands() do
    Enum.map(@commands, fn {name, module} ->
      %{
        name: name,
        description: apply(module, :description, []),
        options: apply(module, :options, []),
        dm_permission: false,
        default_member_permissions: apply(module, :permissions, [])
      }
    end)
  end

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "info"}} = interaction),
    do: Commands.Info.slash_command(interaction)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "etoggle", options: [%{name: "enable", value: choice}]}} = interaction),
    do: Commands.Etoggle.slash_command(interaction, choice)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "redirect", options: options}} = interaction),
    do: Commands.Redirect.slash_command(interaction, options)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "mentions", options: [%{name: "enable", value: choice}]}} = interaction),
    do: Commands.Mention.slash_command(interaction, choice)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "color", options: [%{name: "color", value: color}]}} = interaction),
    do: Commands.Color.slash_command(interaction, color)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "whitelist", options: options}} = interaction),
    do: Commands.Whitelist.slash_command(interaction, options)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "debug", options: [%{name: "id", value: id}]}} = interaction),
    do: Commands.Debug.slash_command(interaction, id)

  def handle_slash_command(interaction) do
    Nostrum.Api.create_interaction_response!(interaction, %{
      type: 4,
      data: %{
        content: "Unhandled command. This is an error, please join the support server and report it."
      }
    })
  end
end
