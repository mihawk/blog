-compile({parse_transform, lager_transform}).
-module(ad_filter).
-export([before_filter/2]).

before_filter(Cfg, ReqCtx) ->
  %% get the current SessionId
  Sid = proplists:get_value(session_id, ReqCtx),

  %% get the user id
  User = boss_session:get_session_data(Sid, user),

  %% get the http request method
  Method = proplists:get_value(method, ReqCtx),

  %% get the current controller
  Ctrl = proplists:get_value(controller_module, ReqCtx),

  %% get the current action
  Action = proplists:get_value(action, ReqCtx),

  check_access(ReqCtx, User, Sid, Method, Ctrl, Action).


%% pattern match for access page.
%% if user is not authentified and want to access the index page, we redirect to the login page
check_access(_, undefined, Sid, 'GET', ad_index_controller, "index") -> 
    boss_session:set_session_data(Sid, redirect_after_login_success, )
    {redirect, "/auth/login"};

%% if user is identified and want to access index page, the user can acces it.
check_access(ReqCtx, User, Sid, 'GET', ad_index_controller, "index") -> {ok, [{user, User}|ReqCtx]};

%% anonymous user or identified user can access other page
check_access(ReqCtx, undefined, Sid, _M, _Ctrl, _Action) -> {ok, [{user, "anonymous"}|ReqCtx]};
check_access(ReqCtx,      User, Sid, _M, _Ctrl, _Action) -> {ok, [{user, User}|ReqCtx]}.

    
