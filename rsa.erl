-module(rsa).
-export([encrypt/2, decode/2, read_keys/0, test/0]).

encrypt(Msg, Pub_key)->
	public_key:encrypt_public(list_to_binary(Msg), Pub_key).

decode(Encrypt_Msg, Priv_key)->
	binary_to_list(public_key:decrypt_private(Encrypt_Msg, Priv_key)).
	

read_keys()->
	{ok, PBin} = file:read_file("pub_rsa.pem"),
        [PEntry] = public_key:pem_decode(PBin),
        PKey = public_key:pem_entry_decode(PEntry),

        {ok, Bin} = file:read_file("priv_rsa.pem"),
        [Entry] = public_key:pem_decode(Bin),
        Key = public_key:pem_entry_decode(Entry,"Erlang"),
	{PKey, Key}.

%%--------
test()->
	{ok, PBin} = file:read_file("pub_rsa.pem"),
	[PEntry] = public_key:pem_decode(PBin),
	PKey = public_key:pem_entry_decode(PEntry),

	{ok, Bin} = file:read_file("priv_rsa.pem"),
        [Entry] = public_key:pem_decode(Bin),
        Key = public_key:pem_entry_decode(Entry,"Erlang"),
	
	Msg = <<"123 df dsfsdf 11">>,
	
	RsaEncrypted = public_key:encrypt_public(Msg, PKey),

	public_key:decrypt_private(RsaEncrypted, Key).
