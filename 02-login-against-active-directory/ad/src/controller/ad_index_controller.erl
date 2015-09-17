-module(ad_index_controller,[Req,Sid]).
-export([index/3]).
-export([gift/3]).
-default_action(index).

index('GET', [], ReqCtx) ->
  User = proplists:get_value(user, ReqCtx, "anonymous"),
  {ok, [{msg, "Hello World!!" ++ User}]}.
