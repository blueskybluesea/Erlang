-module(echo).
-export([start/0,print/1,stop/0,loop/0]).

start()->
	case whereis(echo) of
	     undefined->
	     	register(echo,spawn(?MODULE,loop,[]));
	     Pid when is_pid(Pid)->
		ok
	end.

stop()->
	echo!stop.

print(Msg)->
	echo!{self(),Msg},
	receive
		EMsg -> 
			      io:format("Echo message=>~w~n",[EMsg])
	end.

loop()->
	receive
		{Pri,Msg}->
			io:format("Received message=>~w~n",[Msg]),
			Pri!Msg,
			loop();
		stop->
			true
	end.