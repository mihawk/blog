# Who I am

*This blog is about Erlang/OTP and web developpement.
i had a revelation when i discover erlang/OTP in 2010, 
since, i am following ChicagoBoss project, patching and contributing to it.*


# ChicagoBoss Erlang web framework.

[ChicagoBoss](http://www.chicagoboss.org) was made by [Evan Miller](http://www.evanmiller.org), 
it is a MVC web framework like Ruby On Rail, but better.


# Install Erlang/OTP on Ubuntu.

on linux Ubuntu 14.04, i usualy remove pre installed erlang runtime and use kerl to install erlang from source.

```bash type in the console
 cd ~
 mkdir bin
 cd bin
 sudo apt-get remove erlang
 sudo apt-get build-dep erlang
 curl -O https://raw.githubusercontent.com/spawngrid/kerl/master/kerl
 chmod u+x kerl
 echo "KERL_INSTALL_MANPAGES=yes"  >> ~/.kerlrc
 ./kerl update releases
 ./kerl build 17.5 17.5
 ./kerl install 17.5 ~/bin/lang/erlang/17.5
 echo "source ~/bin/lang/erlang/17.5/activate"  ~/.profile
 echo "export PATH=$PATH:$HOME/bin:."  ~/.profile
 source ~/.profile
```

after this step, you have a working erlang runtime compiled from source.
just type `erl` in your shell and you will get the erlang REPL.

# Get ChicagoBoss
```bash type in the console
 sudo apt-get install git
 mkdir workspace
 cd workspace
 git clone http://github.com/ChicagoBoss/ChicagoBoss.git
 cd ChicagoBoss
 make
```

# First CB app.

```bash type in the console
 cd 
 cd workspace/ChicagoBoss
 make app PROJECT=first
 cd ../first
 ./init-dev.sh 
```

# Anatomy 
```bash Directory Structure
first/
     ├── boss.config
     ├── init-dev.sh
     ├── init.sh
     ├── deps
     │   ├── boss
     │   ├── boss_db
     │   └── ...
     ├── log
     ├── ebin
     ├── priv
     │   ├── first.routes
     │   ├── init
     │   ├── rebar
     │   └── static
     ├── src
     │   ├── controller
     │   ├── first.app.src
     │   ├── mail
     │   ├── view
     │   └── websocket
     └── start-server.bat  
```

| File/Dir              |                                            | 
|:--------------------- |:-------------------------------------------| 
| **boss.config**       | the config file of your application        | 
| **init-dev.sh**       | start your app in dev mode                 | 
| **init.sh**           | start your app                             | 
| **log**               | log files                                  | 
| **ebin**              | compiled source, beam files                | 
| **priv/first.routes** | route files                                | 
| **priv/init**         | your init script                           | 
| **priv/static**       | here goes your static file                 | 
| **src/controller**    | your controller                            | 
| **src/mail**          | incoming/outgoing mail controller          | 
| **src/view**          | your view                                  | 
| **src/websocket**     | your websocket controller                  | 

# Which IDE?

 Personnaly is use `emacs`, any text editor will do the job.

# CONTROLLER

For example i want to create a index controller, 
with an action call index, when the browser point to `http://localhost:8001/index/index`, 
my app should show `Hello world!!!`

a controller is named like this: 
```erlang controller naming convention
     <app_name>/src/<app_name>_<controller_name>_controller.erl
```

edit `first/src/controller/first_index_controller.erl`

```erlang first controller
  -module(first_index_controller, [Req, SessionId]).
  -export([index/3]).

  index('GET', [], _ReqCtx) ->
   {ok, [{msg, "Hello World!!!"}]}.
  
```

# VIEW

```erlang corresponding view naming convention
      <app_name>/src/view/<controller_name>/<action_name>.<tpl_extension>
```
for the action index in controller index we have the corresponding view:
     - `first/src/view/index/index.html`

```html view
  <html>
  <head><title>My First CB app</title></head>
  <body>
   {{ msg }}
  </body>
  </html>
```


```bash
 curl -X GET http://localhost:8001/index/index 
```

# ACTION

an action in CB is a function with 2 or 3 parameters in the controller module.
 - the first parameter is an atom matching the requested method:
    * `'GET', 'POST', 'PUT', 'DELETE', 'HEAD'` ...
 - the second parameter is a list of uri token matching the uri from the requested url.
 - the third parameter is optional: Request Context, CB will provide to your action
 the request context, it is a proplist of usefull value. this list can be modified
 by the  `_before` function or by some `boss_filter` function.

```erlang first controller
  -module(first_index_controller, [Req, SessionId]).
  -export([index/3]).

  index('GET', [], ReqCtx) ->
   lager:info("Request Context: ~p",[ReqCtx]),
   {ok, [{msg, "Hello World!!!"}]}.
``` 

# DEFAULT ACTION
  
 what is default action?, 
 no action cannot be guessed from the requested url, 
 if you want to provide such feature, you can use the attributes `-default_action(<action_name>)`.
 in your controller module.
 if no default action is provided, CB will throw an 404 not found.


```bash without default action.
 curl -X GET http://localhost:8001/index
```

with default action to index.

```erlang
  -module(first_index_controller, [Req, SessionId]).
  -export([index/3]).
  -default_action(index).

  index('GET', [], _ReqCtx) ->
   {ok, [{msg, "Hello World!!!"}]}.
  
```

 point the browser to http://localhost:8001/index will execute the default action index.

```bash with default action to index.
 curl -X GET http://localhost:8001/index
```




