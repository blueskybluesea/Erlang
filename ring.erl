-module(ring).
-export([start/3,loop/5]).

start(M,N,Message)->
	io:format("Ring begin at~w~n",[self()]),
	loop(M,N,Message,self(),self()).

loop(M,0,Message,Pid,_NPid)->
	sendMsg(M,Message,Pid);
loop(M,N,Message,Pid,NPid) when Pid==NPid->
	NextPid=spawn(?MODULE,loop,[M,N-1,Message,Pid,Pid]),
	loop(M,N,Message,Pid,NextPid);
loop(M,N,Message,Pid,NPid)->
	receive
		{From,Msg}->
			io:format("~w receive message from ~w:~w~n",[self(),From,Msg]),
			NPid!{self(),Msg},
			loop(M,N,Message,Pid,NPid);
		stop->
			io:format("~w receive stop command~n",[self()]),
			NPid!stop
	end.

sendMsg(0,_Message,Pid)->
	Pid!stop;
sendMsg(M,Message,Pid)->
	Pid!{self(),Message},
	sendMsg(M-1,Message,Pid).