-module(add_two).
-export([start/1,request/2,loop/0,stop/1]).

start(Name)->
    case whereis(Name) of
	Pid when is_pid(Pid)->{error,instance};
	undefined->
	    process_flag(trap_exit,true),
	    Pid=spawn_link(add_two,loop,[]),
	    register(Name,Pid),
	    {ok,Pid}
    end.

stop(Name)->
    Name!{stop,self()},
    receive {result,Result}->Result end.

request(Name,Int)->
    flush(),
    Name!{request,self(),Int},
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
%	exit(terminated),
    receive
	{request,Pid,Msg}->
	    Pid!{result,Msg+2},
	    loop();
	{stop,From}->
	    From!{result,ok}
    end.
