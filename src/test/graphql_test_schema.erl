-module(graphql_test_schema).
-include("types.hrl").

%% API
-export([schema_root/0]).

print(Text, Args) -> io:format(Text ++ "~n", Args).

schema_root()->
  graphql_type_schema:new(#{
    query => fun query/0
  }).


query() ->
  graphql:objectType(<<"QueryRoot">>, <<"This is Root Query Type">>, #{
    <<"hello">> => #{
      type => ?STRING,
      description => <<"This is hello world field">>
    },
    <<"range">> => #{
      type => ?LIST(?INT),
      args => #{
        <<"seq">> => #{type => ?INT}
      },
      resolver => fun(_, #{<<"seq">> := Seq}) -> lists:seq(0, Seq) end
    },
    <<"range_objects">> => #{
      type => ?LIST(fun valueObject/0),
      args => #{
        <<"seq">> => #{type => ?INT}
      },
      resolver => fun(_, #{<<"seq">> := Seq}) -> lists:seq(0, Seq) end
    },
    <<"arg">> => #{
      type => fun arg/0,
      args => #{
        <<"hello">> => #{ type => ?STRING, default => <<"default value">> },
        <<"argument">> => #{ type => ?STRING, default => <<"Default argument value">>},
        <<"int">> => #{ type => ?INT },
        <<"list">> => #{ type => ?LIST(?INT) }
      },
      description => <<"Argument schema">>,
      resolver => fun(_, Args) -> Args end
    },
    <<"arg_bool">> => #{
      type => ?BOOLEAN,
      args => #{
        <<"bool">> => #{ type => ?BOOLEAN, description => <<"Proxied argument to result">> }
      },
      resolver => fun(_, #{<<"bool">> := Value}) -> Value end
    },
    <<"arg_without_resolver">> => #{
      type => fun arg/0,
      args => #{
        <<"argument">> => #{ type => ?STRING, default => <<"Default argument value">>}
      },
      description => <<"Argument schema">>
    },
    <<"arg_without_defaults">> => #{
      type => fun arg/0,
      description => <<"Pass arguments count down to three">>,
      args => #{
        <<"argument">> => #{ type => ?STRING }
      },
      resolver => fun(_, Args) ->
        print("RESOLVER FOR arg_without_defaults", []),
        #{<<"arguments_count">> => length(maps:keys(Args))}
      end
    },
    <<"nest">> => #{
      type => fun nest/0,
      description => <<"go deeper inside">>,
      resolver => fun() -> #{} end
    },
    <<"non_null">> => #{
      type => ?NON_NULL(?INT),
      args => #{
        <<"int">> => #{type => ?NON_NULL(?INT)}
      },
      resolver => fun(_, #{<<"int">> := Int}) -> Int end
    },
    <<"non_null_invalid">> => #{
      type => ?NON_NULL(?INT),
      resolver => fun() -> null end
    },
    <<"enum">> => #{
      type => ?INT,
      args => #{
        <<"e">> => #{
          type => ?ENUM(<<"Test">>, <<"Test description">>, [
            ?ENUM_VAL(1, <<"ONE">>, <<"This is 1 represent as text">>),
            ?ENUM_VAL(1, <<"TWO">>, <<"This is 2 represent as text">>)
          ])
        }
      },
      resolver => fun(_, #{<<"e">> := E}) -> E end
    },
    <<"enum_non_null">> => #{
      type => ?INT,
      args => #{
        <<"e">> => #{
          type => ?NON_NULL(?ENUM(<<"Test">>, <<"Test description">>, [
            ?ENUM_VAL(1, <<"ONE">>, <<"This is 1 represent as text">>),
            ?ENUM_VAL(1, <<"TWO">>, <<"This is 2 represent as text">>)
          ]))
        }
      },
      resolver => fun(_, #{<<"e">> := E}) -> E end
    }
  }).

nest()->
  graphql:objectType(<<"Nest">>, <<"Test schema for nesting">>, #{
    <<"info">> => #{
      type => ?STRING,
      description => <<"Information">>,
      resolver => fun(_,_) -> <<"information does not availiable">> end
    },
    <<"nest">> => #{
      type => fun nest/0,
      description => <<"go deeper inside">>,
      resolver => fun() -> #{} end
    }
  }).

arg()->
  graphql:objectType(<<"Arg">>, <<"when you pass argument - that return in specified field">>, #{
    <<"greatings_for">> => #{
      type => ?STRING,
      description => <<"Proxy hello argument to response">>,
      resolver => fun(Obj, _) -> maps:get(<<"hello">>, Obj, undefined) end
    },
    <<"argument">> => #{
      type => ?STRING,
      description => <<"This is argument passed to the parrent. It must be authomaticly resolved">>
    },
    <<"int">> => #{
      type => ?INT,
      description => <<"This is int argument">>
    },
    <<"arguments_count">> => #{
      type => ?INT,
      description => <<"Passed from parrent - count of arguments">>
    },
    <<"list">> => #{
      type => ?LIST(?INT)
    }
  }).

valueObject() -> graphql:objectType(<<"ValueObject">>, <<"">>, #{
  <<"value">> => #{
    type => ?LIST(?INT),
    description => <<"range of object value">>,
    resolver => fun(Value) -> lists:seq(0, Value) end
  }
}).