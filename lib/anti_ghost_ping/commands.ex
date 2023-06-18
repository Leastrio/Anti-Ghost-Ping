defmodule AntiGhostPing.Commands do
  alias AntiGhostPing.Commands

  @commands %{
    "info" => Commands.Info,
    "etoggle" => Commands.Etoggle,
    "redirect" => Commands.Redirect,
    "mentions" => Commands.Mention,
    "color" => Commands.Color
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

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "mention", options: [%{name: "enable", value: choice}]}} = interaction),
    do: Commands.Etoggle.slash_command(interaction, choice)

  def handle_slash_command(%Nostrum.Struct.Interaction{data: %{name: "color", options: [%{name: "color", value: color}]}} = interaction),
    do: Commands.Color.slash_command(interaction, color)
end
