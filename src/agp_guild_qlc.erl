-module(agp_guild_qlc).
-export([top/1]).

-include_lib("stdlib/include/qlc.hrl").
-define(CACHE, 'Elixir.Nostrum.Cache.GuildCache').

top(Count) ->
  Q = qlc:q([{Member_count, Guild} || {_Id, #{member_count := Member_count} = Guild} <- ?CACHE:query_handle()]),
  Q2 = qlc:keysort(1, Q, [{order, descending}]),
  ?CACHE:wrap_qlc(fun () ->
    C = qlc:cursor(Q2),
    R = qlc:next_answers(C, Count),
    ok = qlc:delete_cursor(C),
    R
  end).
