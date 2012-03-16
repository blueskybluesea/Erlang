-module(my_db).
-export([start/0,stop/0]).
-export([write/2,delete/1,read/1,match/1]).
-export([init/0]).

start()->
	register(my_db,spawn(?MODULE,init,[])).

stop()->
	my_db!{stop,self()},
	receive ok->ok end.

init()->
	Db=db:new(),
	loop(Db).

reply(To,Msg)->
	To!{reply,Msg}.

call(Msg)->
	my_db!{request,self(),Msg},
	receive
		{reply,Reply}->Reply
	end.

loop(Db)->
	receive
		{request,From,Msg}->
			{Reply,NewDb}=handle_msg(Msg,Db),
			reply(From,Reply),
			loop(NewDb);
		{stop,From}->
			reply(From,terminate(Db))
	end.

write(Key,Element)->
	call({write,{Key,Element}}).
delete(Key)->
	call({delete,Key}).
read(Key)->
	call({read,Key}).
match(Element)->
	call({match,Element}).

handle_msg({write,{Key,Element}},Db)->
	{ok,db:write(Key,Element,Db)};
handle_msg({delete,Key},Db)->
	{ok,db:delete(Key,Db)};
handle_msg({read,Key},Db)->
	{db:read(Key,Db),Db};
handle_msg({match,Element},Db)->
	{db:match(Element,Db),Db}.

terminate(Db)->
	db:destroy(Db).