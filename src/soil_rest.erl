-module(soil_rest).

-export([init/3]).
-export([
  rest_init/2
  ,content_types_provided/2
  ,to_html/2
  ,to_json/2
  ,to_text/2
  ,rest_terminate/2
]).

-record(state,{templates_path,sid}).

init(_Transport, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Opts) ->
  {ok, Req, #'state'{}}.

content_types_provided(Req, State) ->
  {[
    {<<"text/html">>, to_html},
    {<<"application/json">>, to_json},
    {<<"text/plain">>, to_text}
  ], Req, State}.

to_html(Req, State) ->
  Sid = soil_utls:random(),
  ClientTimeout = 5000,
  Req1 = soil_session:set_cookie(Req,<<"TSID">>,Sid),
  Req2 = soil_session:set_cookie(Req1,<<"clientTimeout">>,integer_to_binary(ClientTimeout)),
  Template = soil_utls:priv_dir() ++ "/app/templates/index.tpl",
  {ok,_Module} = erlydtl:compile_file(Template,index_dtl),
  {ok,Body} = index_dtl:render([]),
  {Body, Req2, State}.

to_json(Req, State) ->
  Body = <<"{\"rest\": \"Hello World!\"}">>,
  {Body, Req, State}.

to_text(Req, State) ->
  {<<"REST Hello World as text!">>, Req, State}.

rest_terminate(_Req,_State) ->
  ok.
