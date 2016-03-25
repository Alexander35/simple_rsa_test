-module(server).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([encode/1, decode/1, stop/0 ]).

%%send the message
encode(Msg) -> 
	gen_server:call(?MODULE, {rsa_encode, Msg}).

decode(Msg)->
	gen_server:call(?MODULE, {rsa_decode, Msg}).

%%send stop signal
stop() ->
        gen_server:cast(?MODULE, stop).

%%start server
start_link()->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%simple init
init([]) ->
	%%reading keys and save it into tab
	ets:new(rsa_keys, [set, named_table]),
	{Public_key, Private_key} = rsa:read_keys(),
	ets:insert(rsa_keys,[{public_key, Public_key},{private_key, Private_key}]),
	{ok, start}.

%%Recieving Msg
handle_call({rsa_encode, Msg}, From, State) ->
	io:format(" ~p Message Received From ~p to encode ~n",[Msg, From]),
	[{_,Pub_key}] = ets:lookup(rsa_keys, public_key),	
	Encrypted = rsa:encrypt(Msg, Pub_key),	
	{reply, Encrypted, State};

handle_call({rsa_decode, Msg}, From, State) ->
        io:format(" ~p Message Received From ~p to decode ~n",[Msg, From]),
        [{_,Priv_key}] = ets:lookup(rsa_keys, private_key),
        Decoded = rsa:decode(Msg, Priv_key),
        {reply, Decoded, State};

handle_call(Other, From, State) ->
        io:format(" ~p --Wrong Message has been received from ~p ~n",[Other, From]),
        {reply, error, State}.

%%handling stop signal
handle_cast(stop, State) ->
	{stop, normal, State}.

handle_info(_Info, State) ->
	{other, State}.

terminate(Reason, State) ->
	{ok, {Reason, State}}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
