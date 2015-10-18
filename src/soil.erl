-module(soil).

-export([
  handle/3
  ,reply/2
  ,sessions/0
  ,get_cbid/1
]).

%% ------------------------------------------------------------------

handle(<<"register">>,JsonMap,Key) ->
  Body = maps:get(<<"body">>,JsonMap),
  User = maps:get(<<"user">>,Body),
  UserNoVerify = maps:remove(<<"password_verify">>,User),
  UserSave = maps:put(<<"__meta__">>,#{ <<"name">> => <<"user">>},UserNoVerify),
  {ok,UserId} = norm:save(UserSave),
  Address = maps:get(<<"address">>,Body),
  AddressSave = maps:put(<<"__meta__">>,#{ <<"name">> => <<"address">>},Address),
  {ok,AddressId} = norm:save(AddressSave), 
  Customer = maps:get(<<"customer">>,Body),
  CustomerAddMeta = maps:put(<<"__meta__">>,#{ <<"name">> => <<"customer">>},Customer),
  CustomerAddUserId = maps:put(<<"user_id">>,UserId,CustomerAddMeta),
  CustomerAddUserAddressId = maps:put(<<"address_id">>,AddressId,CustomerAddUserId),
  {ok,CustomerId} = norm:save(CustomerAddUserAddressId), 
  io:fwrite("Norm save: ~p ~p ~p ~n",[UserId,AddressId,CustomerId]),
  Reply = #{ <<"header">> => #{ <<"type">> => <<"register">>, <<"cbid">> => get_cbid(JsonMap) }, <<"body">> => <<"ok">> },
  reply(Key,Reply);
 
handle(<<"view">>,JsonMap,Key) ->
  Reply = #{
    header => #{ <<"type">> => <<"view">>, <<"cbid">> => get_cbid(JsonMap) }
    ,body => sessions()
  },
  reply(Key,Reply);
handle(undefined,JsonMap,_Sid) ->
  io:fwrite("UNDEFINED ACTION: ~p~n",[JsonMap]),
  ok.

reply(Key,Reply) ->
  gproc:send(Key,Reply).
 
%% ------------------------------------------------------------------

sessions() ->
  List = gproc:select([{{'_', '_', '_'},[],['$$']}]),
  lists:foldl(fun(Elem,Acc) ->
    [Key,_Pid1,_Pid2] = Elem,
    {_,_,Sid} = Key,
    Acc ++ [[{sid,Sid},{properties,gproc:get_attribute(Key,map)}]]
  end,[],List).

get_cbid(JsonMap) ->
  HeaderMap = maps:get(<<"header">>,JsonMap,#{}),
  maps:get(<<"cbid">>,HeaderMap,0). 


