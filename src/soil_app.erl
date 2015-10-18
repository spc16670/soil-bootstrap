-module(soil_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  %% Cowboy dependencies
  ensure_started(crypto),
  ensure_started(cowlib),
  ensure_started(ranch),
  ensure_started(cowboy),

  %% Gun dependencies
  ensure_started(asn1),
  ensure_started(public_key),
  ensure_started(ssl),
  ensure_started(gun),
 
  %% Gproc
  ensure_started(gproc),

  %% Erlydtl dependencies
  ensure_started(syntax_tools),
  ensure_started(compiler),
  ensure_started(merl),
  ensure_started(erlydtl),

  %% Norm
  ensure_started(norm),
   
  PrivDir = soil_utls:priv_dir(),
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/static/[...]", cowboy_static, {dir,PrivDir ++ "/static",[{mimetypes, cow_mimetypes, all}]}}
      ,{"/app/[...]", cowboy_static, {dir,PrivDir ++ "/app",[{mimetypes, cow_mimetypes, all}]}}
      ,{"/", soil_rest, []}
      ,{"/bullet/[...]",bullet_handler,[{handler,soil_bullet_handler}]}
    ]}
  ]),
  cowboy:start_http(http_listener, 100,
    [{port, soil_utls:get_env(http_port)}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  io:fwrite("Priv dir: ~p~n",[PrivDir]),
  cowboy:start_https(https_listener, 100,
    [{port, soil_utls:get_env(https_port)}
     ,{cacertfile, PrivDir ++ "/ssl/ca.soil.in.crt"}
     ,{certfile, PrivDir ++ "/ssl/soil.in.crt"}
     ,{keyfile, PrivDir ++ "/ssl/soil.in.key"}
    ],
    [{env, [{dispatch, Dispatch}]}]
  ),
  soil_sup:start_link().

stop(_State) ->
  ok.

%% @doc
%% Ensures all dependencies are started.
%% @end

ensure_started(App) ->
  case application:start(App) of
    ok -> ok;
    {error,{already_started,App}} -> ok;
    Error -> io:fwrite("Could not start ~p ~p ~n",[App,Error])
  end.
