-module(mutex).
-export([start/0,stop/0]).
-export([wait/0,signal/0]).
-export([init/0]).

start()->
	register(mutex,spawn(?MODULE,init,[])).

stop()->
	mutex!stop.

wait()->
	mutex!{wait,self()},
	receive
		ok->ok
	end.

signal()->
	mutex!{signal,self()},
	ok.

init()->
	process_flag(trap_exit,true),
	free().

free()->
	receive
		{wait,Pid}->
			try link(Pid) of
			    true->
				Pid!ok,
				busy(Pid)
			catch
			    error:Error->
				io:format("Can not link to client waiting,~w~n",[Error]),
				free()
			end;
		stop->
			terminate()
	end.

busy(Pid)->
	receive 
		{signal,Pid}->
			unlink(Pid),
			free();
		{'EXIT',Pid,Reason}->
			io:format("Client crashed,~w",[{error,{Pid,Reason}}]),
			free()
	end.

terminate()->
	receive
		{wait,Pid}->
			exit(Pid,kill),
			terminate()
	after
		0-> ok
	end.