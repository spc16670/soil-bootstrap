-module(soil_models).

-compile(export_all).

pgsql() -> 
  #{
    <<"user">> => #{
      <<"create_rank">> => <<"1">>
      ,<<"fields">> => #{
        <<"id">> => #{  <<"type">> => <<"bigserial">>, <<"null">> => <<"false">> }
        ,<<"email">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"password">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"date_registered">> => #{ <<"type">> => <<"timestamp">> }
      }
      ,<<"constraints">> => #{
        <<"pk">> => #{ <<"fields">> => [<<"id">>] }
      }
    }
    ,<<"customer">> => #{
      <<"create_rank">> => <<"3">>
      ,<<"fields">> => #{
        <<"id">> => #{ <<"type">> => <<"bigserial">>, <<"null">> => <<"false">> }
        ,<<"fname">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"lname">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"gender">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"1">> }
        ,<<"dob">> => #{ <<"type">> => <<"date">> }
        ,<<"user_id">> => #{ <<"type">> => <<"bigint">>, <<"null">> => <<"false">> }
        ,<<"address_id">> => #{ <<"type">> => <<"bigint">>, <<"null">> => <<"false">> }
      }
      ,<<"constraints">> => #{
        <<"pk">> => #{ <<"name">> => <<"pk_customer">>, <<"fields">> => [<<"id">>] }
        ,<<"fk">> => [ #{ <<"references">> => #{ <<"table">> => <<"user">>, <<"fields">> => [<<"id">>] }, <<"fields">> => [<<"user_id">>] }
          ,#{ <<"references">> => #{ <<"table">> => <<"address">>, <<"fields">> => [<<"id">>] }, <<"fields">> => [<<"address_id">>] }]
      }
    }
    ,<<"address">> => #{
      <<"create_rank">> => <<"2">>
      ,<<"fields">> => #{
        <<"id">> => #{  <<"type">> => <<"bigserial">>, <<"null">> => <<"false">> }
        ,<<"line1">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"line2">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"postcode">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
        ,<<"city">> => #{ <<"type">> => <<"varchar">>, <<"length">> => <<"50">> }
      }
      ,<<"constraints">> => #{
        <<"pk">> => #{ <<"fields">> => [<<"id">>] }
      }
    }

  }.

mnesia() ->
  #{
    <<"views">> => #{
      <<"key">> => <<"id">>
      ,<<"type">> => <<"set">>
      ,<<"fields">> => #{
        <<"id">> => #{ <<"type">> => <<"binary">> }
        ,<<"visits">> => #{ <<"type">> => <<"integer">> }
        ,<<"reviews">> => #{ <<"type">> => <<"map">> }
        ,<<"purchases">> => #{ <<"type">> => <<"map">> }
      }
    }
  }.
