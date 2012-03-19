-module(add_two).
-export([start/0,request/1,loop/0,stop/0]).

start()->
	process_flag(trap_exit,true),
	Pid=spawn_link(add_two,loop,[]),
	register(add_two,Pid),
	{ok,Pid}.

stop()->
	add_two!{stop,self()},
	receive {result,Result}->Result end.

request(Int)->
	flush(),
	add_two!{request,self(),Int},
	receive
		{result,Result}->Result;
		{'EXIT',_Pid,Reason}->{error,Reason}
	after 1000->timeout
	end.

flush()->
	receive
		_-> ok
	after 0 -> ok
	end.

loop()->
	exit(terminated),
	receive
		{request,Pid,Msg}->
			Pid!{result,Msg+2},
			loop();
		{stop,From}->
			From!{result,ok}
	end.