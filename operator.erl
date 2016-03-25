-module(operator).

-export([main/1, main/0]).

main()->
	main({bad,args}).

main([Arg])->
        case Arg of
                "stop" ->
                        server:stop();
                _Other ->
                        server:start_link(),
                        E = server:encode(Arg),
			io:format("~p~n",[E])
        end;

main(_Other)->
        io:format("bad args~n",[]).
