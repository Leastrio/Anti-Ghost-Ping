defmodule AntiGhostPing.Consumer do
  use Nostrum.Consumer
  require Logger
  alias AntiGhostPing.Schema.Guilds
  alias AntiGhostPing.GhostPing

  def handle_event({:READY, %{shard: {shard, num_shards}}, ws_state}) do
    if shard == 0 do
      case Nostrum.Api.bulk_overwrite_global_application_commands(AntiGhostPing.Commands.get_commands()) do
        {:error, err} -> Logger.error("An Error occurred bulk registering commands:\n#{err}")
        {:ok, _} -> Logger.info("Successfully bulk registered commands")
      end
    end
    Nostrum.Api.update_shard_status(ws_state.conn_pid, :online, "/ | https://ghostping.xyz")
    Logger.info("Shard #{shard + 1}/#{num_shards} connected")
  end

  def handle_event({:MESSAGE_CREATE, %Nostrum.Struct.Message{} = msg, _ws_state}) when is_nil(msg.author.bot) and not is_nil(msg.guild_id) do
    if msg.mention_everyone or msg.mention_roles != [] or msg.mentions != [] do
      AntiGhostPing.Cache.put(msg.id, msg, ttl: :timer.minutes(10))
    end
  end

  def handle_event({:MESSAGE_DELETE, %Nostrum.Struct.Event.MessageDelete{} = msg_del, _ws_state}) when not is_nil(msg_del.guild_id) do
    case AntiGhostPing.Cache.get(msg_del.id) do
      nil -> :ok
      msg ->
        guild_conf = Guilds.get_guild(msg.guild_id)
        if msg.mention_everyone && guild_conf.everyone do
          GhostPing.handle_everyone(guild_conf, msg)
        else unless (msg.mentions == [] && msg.mention_roles == []) do
          GhostPing.handle_mention(guild_conf, msg)
        end
      end
    end
  end

  def handle_event({:MESSAGE_UPDATE, %Nostrum.Struct.Message{} = msg_upd, _ws_state}) when is_nil(msg_upd.author.bot) and not is_nil(msg_upd.guild_id) do
    case AntiGhostPing.Cache.get(msg_upd.id) do
      nil -> :ok
      msg ->
        guild_conf = Guilds.get_guild(msg.guild_id)
        if msg.mention_everyone && not msg_upd.mention_everyone && guild_conf.everyone do
          GhostPing.handle_everyone(guild_conf, msg)
        else if !(Enum.all?(msg.mentions, &Enum.member?(msg_upd.mentions, &1)) && Enum.all?(msg.mention_roles, &Enum.member?(msg_upd.mention_roles, &1))) do
          GhostPing.handle_mention(guild_conf, msg)
        end
        AntiGhostPing.Cache.put(msg_upd.id, msg_upd, ttl: :timer.minutes(10))
      end
    end
  end

  # def handle_event({:GUILD_DELETE, {%Nostrum.Struct.Guild{id: id}, false}, _ws_state}) do
  #   AntiGhostPing.Repo.delete(id)
  # end

  def handle_event({:INTERACTION_CREATE, %Nostrum.Struct.Interaction{type: type} = interaction, _ws_state}) do
    case type do
      2 -> AntiGhostPing.Commands.handle_slash_command(interaction)
      4 -> AntiGhostPing.Commands.Color.handle_autocomplete(interaction)
    end
  end

  def handle_event(_) do
    :noop
  end
end
