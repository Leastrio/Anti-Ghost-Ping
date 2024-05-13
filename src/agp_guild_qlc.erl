-module(agp_guild_qlc).
-export([top/1]).

-include_lib("stdlib/include/qlc.hrl").
-define(CACHE, 'Elixir.Nostrum.Cache.GuildCache').

top(Count) ->
  Q = qlc:q([{MemberCount, Id, Guild} || {Id, #{member_count := MemberCount} = Guild} <- ?CACHE:query_handle()]),
  ?CACHE:wrap_qlc(fun () ->
    {Tree, _, _} = qlc:fold(
      fun({MemberCount, Id, Guild}, {Tree, Smallest, Size}) ->
          if 
            (MemberCount > Smallest) and (Size >= Count) ->
              {_, _, NewTree} = gb_trees:take_smallest(Tree),
              {gb_trees:insert({MemberCount, Id}, Guild, NewTree), MemberCount, Size};
            Size < Count ->
              {gb_trees:insert({MemberCount, Id}, Guild, Tree), MemberCount, Size + 1};
            true ->
              {Tree, Smallest, Size}
          end
      end,
      {gb_trees:empty(), 0, 0}, Q),
    lists:reverse(gb_trees:to_list(Tree))
  end).
