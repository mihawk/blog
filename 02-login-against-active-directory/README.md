# Authentification against Active Directory, Boss Filter for authentification and authorization.

* earlier this year, i had to connect an authenticate user against Active Directory from erlang,
  [erlang/OTP](http://erlang.org) have ldap client include since R15,
  i tryed to connect to an Active Directory but without success :(, MS, MS, again MS ...
  back to my favorite search engine, after googling some time,  
  i find out that [ejabberd](https://www.ejabberd.im/node/639) from [preocess-one](https://www.process-one.net/en/), 
   can connect and authenticate user against ActiveDirectory, WOW :), and it is open-source,
  i decided to extract the code and package it. 

  in this post, you will find out how to use [ChicagoBoss](http://www.chicagoboss.org) with an external dep, 
   boss filter for authentification and authorization.
  

# let's start.

 i assume you have an Active Directory Server ready somewhere in your network, 
 and installed ChicagoBoss, mostly you can copy paste to your shell when you see shell code, 
 this tuto was made against last version of CB, 17 september 2015

```bash
cd ChicagoBoss
make
make app PROJECT=ad
cd ../ad
```

 edit your rebar.config file and add eldap repo in the deps section.

```erlang
{deps, [
  {boss, ".*", {git, "git://github.com/ChicagoBoss/ChicagoBoss.git", {tag, "v0.8.15"}}},
  {eldap, ".*", {git, "git://github.com/mihawk/ldap.git", {tag, "master"}}}
]}.
{deps_dir, ["./deps"]}.
{plugin_dir, ["priv/rebar"]}.
{plugins, [boss_plugin]}.
{eunit_compile_opts, [{src_dirs, ["src/test"]}]}.
{lib_dirs, ["../ChicagoBoss/deps/elixir/lib"]}.
```

 * fetch and compile our new deps.

```bash
cd ad
make all
```

 i had this error during compilation process.

```bash
==> lager (compile)
ERROR: /home/mihawk/workspace/ad/deps/lager/.rebar/erlcinfo file version is incompatible. expected: 1 got: 2
ERROR: compile failed while processing /home/mihawk/workspace/ad/deps/lager: rebar_abort
```

 i do this:

```bash
find . -name .rebar -type d | xargs rm -fr
make compile
```


#let's start and try to connect to our ActiveDirectory

```bash
./init-dev.sh

```

oups forget to configure our eldap.
edit boss.config and add the config for eldap.
just like follow, update your config according to your env.

```erlang
[
{eldap, [
         {default, [         
                    {ldap_servers, ["ldap.MyDomain.com"]},
                    {ldap_encrypt, none},
                    {ldap_port, 389},
                    {ldap_uids, [{"sAMAccountName", "%u"}]},
                    {ldap_base, "CN=Users,DC=MyDomain,DC=com"},
                    {ldap_rootdn, "CN=Administrator,CN=Users,DC=MyDomain,DC=com"},
                    {ldap_password, "MyPassword"},
                    {ldap_filter, "(memberOf=*)"}
                   ]
         }
        ]
 },
{boss, [
    {path, "./deps/boss"},
    {applications, [ad]},
    {assume_locale, "en"},
...
```

let s try again

```bash
./init-dev.sh
(ad@xyz)1> 
(ad@xyz)1>application:start(eldap).
ok
(ad@xyz)2>eldap_api:start().
00:55:36.645 [info] LDAP connection on xxx.xx.xx.xx:389
00:55:36.646 [info] LDAP connection on xxx.xx.xx.xx:389
{ok,<0.86.0>}
```

test user credential:

```bash
(ad@xyz)4> eldap_api:check_password(default, <<"administrator">>, <<"mypass1">>).
true
(ad@xyz)5> eldap_api:check_password(default, <<"administrator">>, <<"mypass2">>).
false
```

#start eldap each time we start our app.

in CB, we have init folder where you can perform some task at the boot time of your CB app.
let's write what we did previously in the shell into a module.

```erlang
cat <<EOF > priv/init/ad_02_eldap.erl
-module(ad_02_eldap).
-compile(export_all).

init() ->
    {ok, Pid} = case application:start(eldap) of
                    ok -> 
                        lager:info("starting eldap interface..."),
                        eldap_api:start();
                    Err -> 
                        lager:error("starting eldap interface fail ~p", [Err])
                end,
    {ok, []}.

stop(_) ->
  application:stop(eldap),
  ok.
EOF
./init-dev.sh
```

if you lunch your app, you application crash miserably, what happen here,
the culprit is lager :(, it's a parse transform, 
a parse transform is a hook into the compilation chaine 
where the code is transformed before compilation. 
the easiest way to fix this, is to add this magic line:

 **-compile({parse_transform, lager_transform}).**


```erlang
-compile({parse_transform, lager_transform}).
-module(ad_02_eldap).
-compile(export_all).
...
```

now your app should start properly.

```erlang
./init-dev.sh
...
13:14:19.947 [info] starting eldap interface...
13:14:19.978 [info] LDAP connection on xxx.xx.xxx.xx:389
13:14:19.978 [info] LDAP connection on xxx.xx.xxx.xx:389
(ad@xyz)1> eldap_api:check_password(default, <<"administrator">>, <<"mypass1">>). 
true
(ad@xyz)2>
```

 cool we can call eldap_api:check_password/3 from our controller :)

#boss filter for authentification.

  i assume you have read the [README_FILTERS.md](https://github.com/ChicagoBoss/ChicagoBoss/blob/master/READMEs/README_FILTERS.md) from the boss repo.
  from the doc we have:

```erlang
    -module(my_before_filter).
    -export([before_filter/2]).

    before_filter(_Config, RequestContext) ->
        IsAdmin = is_admin(RequestContext),
        {ok, [{is_admin, IsAdmin}|RequestContext]}.
```

let's write our own module, which does nothing but just log some information.


```erlang
cat <<EOF > src/lib/ad_filter.erl
-compile({parse_transform, lager_transform}).
-module(ad_filter).
-export([before_filter/2]).

before_filter(_Cfg, ReqCtx) ->
  lager:info("Cfg:~p",[Cfg]),
  lager:info("ReqCtx:~p",[ReqCtx]),
  {ok, ReqCtx}.

EOF
```

we need a basic page

basic controller:

```erlang
cat <<EOF > src/controller/ad_index_controller.erl
-module(ad_index_controller,[Req,Sid]).
-export([index/3]).
-default_action(index).

index('GET', [], _ReqCtx) ->
  {ok, [{msg, "Hello World!!"}]}.
EOF
```

basic view:
```
mkdir -p src/view/index
cat <<EOF > src/view/index/index.html
<html>
<head></head>
<body>
  {{msg}}
</body>
</html>
EOF
```

activate your filter, edit your boss.config like below:

```erlang
%% controller_filter_config - Specify defaults for controller filters
%%   Sub-key 'lang' can be set to the atom 'auto' to autodetermine language
%%     universally, or can be set to a specific language by setting a string (e.g.
%%     "en" or "de")

{controller_filter_modules, [ad_filter]},

%    {controller_filter_config, [
%        {lang, auto}
%    ]},
```

open an other shell an fetch the page with curl:
```bash
curl -XGET http://localhost:8001/index
...
```

here the corresponding log from the REPL.

```erlang
13:45:16.444 [info] Cfg:undefined
13:45:16.444 [info] ReqCtx:[{controller_module,ad_index_controller},{request,....},{session_id,"219ec9e933d968b595c2c85e6721a6dab98699ec"},{method,'GET'},{action,"index"},{tokens,[]}]
13:45:16.462 [warning] GET /index [ad] 404 49ms
```
we see that ReqCtx contain:
- controller_module
- request
- session_id
- method 
- action
- token

let's add a login page, and redirect all user who want to access /index/index to the login page.

auth controller:
```erlang
cat <<EOF > src/controller/ad_auth_controller.erl
-module(ad_auth_controller,[Req,Sid]).
-export([login/3]).
-default_action(login).

login('GET', [], _ReqCtx) ->
  {ok, []};

login('POST', [], _ReqCtx) ->  
  {ok, []}.

EOF
```

login view:
```
mkdir -p src/view/auth
cat <<EOF > src/view/auth/login.html
<html>
<head>
<style> center{padding-top:100px;} </style>
</head>
<body>
  <center>
  <form method="post" action="/auth/login">
  <table>
  <tr>
  <td>login:</td>
  <td><input type=text name="login"></td>
  </tr>
  <tr>
  <td>password:</td>
  <td><input type=password name="password"></td>  
  </tr>
  <tr>
  <td>  
   <input type="submit" value="OK">
  </td><td></td>  
  </tr>
  </table>
  </form>
  </center>
</body>
</html>
EOF
```

let s try our new login page.
open your webrowser an go to the url http://localhost:8001/auth/login, 
you should see our login form
or you can get the page using curl like below:

```bash
curl -X GET http://localhost:8001/auth/login
<html>
<head>
<style> center{padding-top:100px;} </style>
</head>
<body>
  <center>
  <form method="post" action="/auth/login">
  <table>
  <tr>
  <td>login:</td>
  <td><input type=text name="login"></td>
  </tr>
  <tr>
  <td>password:</td>
  <td><input type=password name="password"></td>  
  </tr>
  <tr>
  <td>  
   <input type="submit" value="OK"> 
  </td><td></td>  
  </tr>
  </table>
  </form>
  </center>
</body>
</html>
```
we got the page. nice
now let's authenticate our user against Active Directory, 
edit the auth controller like follow:

```erlang

login('POST', [], _ReqCtx) ->

  %% extract value return by the login form
  Params = Req:post_params(),

  %% extract login and password
  Login = list_to_binary(proplists:get_value("login", Params)),
  Password = list_to_binary(proplists:get_value("login", Params)),

  %% check against active directory
  case eldap_api:check_password(default, Login, Password) of
       true -> 
               %%if user is authentified, link is current session
               boss_session:set_session_data(Sid, user, Login);
               {ok, [{success_msg, "You are authentified"}]};
       false ->
               %%if user is authentified, link is current session
               {ok, [{error_msg, "Not Authorized"}]}
  end.
```

edit your view and add the error message.

```html
<html>
<head>
<style> center{padding-top:100px;} </style>
</head>
<body>
  <center>
  {% if success_msg %}<p><span style="color:green;">{{success_msg}}</span></p>{% endif %}  
  {% if error_msg %}<p><span style="color:red;">{{error_msg}}</span></p>{% endif %}  
  <form method="post" action="/auth/login">
  <table>
  <tr>
...
```

let's test with curl

```bash
curl -X POST -d "login=admin&password=123123" http://localhost:8001/auth/login
<html>
<head>
<style> center{padding-top:100px;} </style>
</head>
<body>
  <center>  
   
 <p><span style="color:red;">Not Authorized</span></p>  
  <form method="post" action="/auth/login">
  <table>
  <tr>
  <td>login:</td>
  <td><input type="text" name="login"></td>
  </tr>
  <tr>
  <td>password:</td>
  <td><input type="password" name="password"></td>  
  </tr>
  <tr>
  <td>  
   <input type="submit" value="OK">
  </td> 
  </tr>
  </table>
  </form>
  </center>
</body>
</html>
```

we got the error message "Not Autorized".
let s try with a correct user.

```bash
curl -X POST -d "login=administrator&password=mypass1" http://localhost:8001/auth/login
<html>
<head>
<style> center{padding-top:100px;} </style>
</head>
<body>
  <center>  
 <p><span style="color:green;">You are authetified</span></p>  
   
  <form method="post" action="/auth/login">
  <table>
  <tr>
  <td>login:</td>
  <td><input type="text" name="login"></td>
  </tr>
  <tr>
  <td>password:</td>
  <td><input type="password" name="password"></td>  
  </tr>
  <tr>
  <td>  
   <input type="submit" value="OK">
  </td> 
  </tr>
  </table>
  </form>
  </center>
</body>
</html>
```

we got the success message "You are authentified".
let s go back to our ad_filter module and add the logic 
if the user want to see the page index/index he need to be authentified

```erlang
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

  check(ReqCtx, User, Sid, Method, Ctrl, Action).


%% pattern match for access page.

%% if user is not authentified and want to access the index page, we redirect to the login page
check(_, undefined, Sid, 'GET', ad_index_controller, "index") -> {redirect, "/auth/login"};

%% if user is identified and want to access index page, the user can acces it.
check(ReqCtx, User, Sid, 'GET', ad_index_controller, "index") -> {ok, [{user, User}|ReqCtx]};

%% anonymous user or identified user can access other page
check(ReqCtx, undefined, Sid, _Method, _Ctrl, _Action) -> {ok, [{user, "anonymous"}|ReqCtx]}.

```

let's edit our index/index page to see which type of user.

```erlang
-module(ad_index_controller,[Req,Sid]).
-export([index/3]).
-default_action(index).

index('GET', [], ReqCtx) ->
  User = proplists:get_value(user, ReqCtx, "anonymous"),
  {ok, [{msg, "Hello World!!" ++ User}]}.
```

there is a small glitch here, how to redirect the user after the login page.
i let you image what to do, you have all the information.

thank for reading this long post, 
hope you find it interesting.
you can find the code for this post [here](https://github.com/mihawk/blog/tree/master/02-login-against-active-directory/ad) 

mihawk.









 






