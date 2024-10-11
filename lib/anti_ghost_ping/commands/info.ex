defmodule AntiGhostPing.Commands.Info do
  import Nostrum.Struct.Embed

  def description, do: "View info about the bot"
  def options, do: []
  def permissions, do: :everyone

  def slash_command(_, _) do
    embed = %Nostrum.Struct.Embed{}
    |> put_description("""
      **Sorry for losing your configuration! [Explanation here](https://gist.github.com/Leastrio/59f4c4c2d283e2caf51055ee767ae9fc)**

      - You can invite Anti Ghost Ping to your own server by clicking **[here](https://discord.com/api/oauth2/authorize?client_id=699522828147490826&permissions=274878187648&scope=bot)**
      - Join the support server for help **[here](https://discord.gg/aVvCdEDkSy)**
      - Vote **[here](https://top.gg/bot/699522828147490826/vote)** to show your support!
      - **[Source Code](https://github.com/Leastrio/Anti-Ghost-Ping)**
      """)
    |> put_color(16711712)

    {:embed, embed}
  end
end
