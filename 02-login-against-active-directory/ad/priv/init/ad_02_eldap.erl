-compile({parse_transform, lager_transform}).
-module(ad_02_eldap).
-compile(export_all).

init() ->
    {ok, Pid} = case application:start(eldap) of
                    ok -> lager:info("starting eldap interface..."),
                          eldap_api:start();
                    Err -> 
                        lager:error("starting eldap interface fail ~p", [Err])
                end,
    {ok, []}.

stop(_) ->
  application:stop(eldap),
  ok.
