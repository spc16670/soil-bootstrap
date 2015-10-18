-module(soil_bullet_handler).

-export([init/4]).
-export([stream/3]).
-export([info/3]).
-export([terminate/2]).

-record(state,{sid}).

-define(GPROC_KEY(Sid),{p,l,Sid}).

%% ------------------------------------------------------------------
%% The process running this code executes effectively the business
%% logic via the norm.erl module. 
%% ------------------------------------------------------------------
%%

init(_Transport, Req, _Opts, Active) ->
  {[Sid],Req1} = cowboy_req:path_info(Req),
  %% ensure registered
  gproc:reg(?GPROC_KEY(Sid),[{map,#{ active => Active }}]),
  {ok, Req1, #state{ sid = Sid }}.

stream(Data, Req, #state{sid=Sid}=State) ->  
  JsonMap = jsx:decode(Data,[return_maps]),
  HeaderMap = maps:get(<<"header">>,JsonMap,#{}),
  Action = maps:get(<<"action">>,HeaderMap,undefined), 
  soil:handle(Action,JsonMap,?GPROC_KEY(Sid)),
  {ok, Req, State}.

info(Map, Req, State) ->
  Json = jsx:encode(Map),
  {reply, Json, Req, State}.

terminate(_Req,#state{sid=Sid}=_State) ->
  %% ensure unregistered
  gproc:unreg(?GPROC_KEY(Sid)),
  ok.


