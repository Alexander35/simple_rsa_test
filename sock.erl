-module(sock).

-export([operate/1]).

operate(Msg)->
	{ok, Server_Sock} = start_server(),
	{ok, Client_Sock} = connect("127.0.0.1"),

	send(Client_Sock, Msg),
	
	Answer = fetch(Server_Sock),
	Encoded = server:encode(Msg),

	ok=close_sock(Server_Sock),
	ok=close_sock(Client_Sock),
	
	Encoded.

connect(Server_name) ->
	gen_tcp:connect(Server_name, 5678, [binary, {packet, 0}]).

send(Sock,Message)->	
	ok = gen_tcp:send(Sock, Message).

close_sock(Sock)->
	gen_tcp:close(Sock).

start_server() ->
	server:start_link(),
	gen_tcp:listen(5678, [list, inet, {packet, 0}, {active, false}]).

fetch(Sock)->
	{ok, Socket}= gen_tcp:accept(Sock),
	{ok, Bin} = do_recv(Socket, []),
	[_|[M]]=Bin,
	M.

do_recv(Sock, Bs) ->
    	case gen_tcp:recv(Sock, 0, 1000) of
        	{ok, B} ->
        		do_recv(Sock, [Bs, B]);
        	{error, closed} ->
        		{ok, list_to_binary(Bs)};
		{error, timeout} ->
			%% all messeges has been received
			{ok, Bs};
		Else ->
			{somt_els_rcv, Else}
    	end.
