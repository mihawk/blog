-module(ad_auth_controller,[Req,Sid]).
-export([login/2]).
-default_action(login).

login('GET', []) ->
  {ok, []};

login('POST', []) ->

  %% extract value return by the login form
  Params = Req:post_params(),

  %% extract login and password
  Login = proplists:get_value("login", Params),
  Password = proplists:get_value("password", Params),

  %% check against active directory
  lager:info("Login: ~p, Password: ~p",[Login, Password]),
  case eldap_api:check_password(default, list_to_binary(Login), list_to_binary(Password)) of
       true -> 
               %%if user is authentified, link is current session
               boss_session:set_session_data(Sid, user, Login),
               %%Redirect = boss_session:get_session_data(Sid, redirect_after_login_if_success),
               lager:info("success login ~p....",[Login]),
               {ok, [{success_msg, "You are authetified"}]};
       false ->
               lager:info("fail login ~p....",[Login]),
               {ok, [{error_msg, "Not Authorized"}]}
  end.
