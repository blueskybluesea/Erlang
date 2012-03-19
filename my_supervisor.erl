-module(my_supervisor).
-export([start_link/2,stop/1]).
-export([init/1]).

start_link(Name,ChildSpecList)->
	register(Name,spawn_link(?MODULE,init,[ChildSpecList])),
	ok.

init(ChildSpecList)->
	process_flag(trap_exit,true),
	loop(start_children(ChildSpecList)).

start_children([])->[];
start_children([{M,F,A,T}|Rest])->
	case (catch apply(M,F,A)) of
	     {ok,Pid}->[{Pid,{M,F,A,T,0}}|start_children(Rest)];
	     _->start_children(Rest)
	end.

loop(ChildList)->
	receive
		{'EXIT',Pid,Reason}->
			NewChildList=restart_child(Pid,Reason,ChildList),
			loop(NewChildList);
		{stop,From}->
			From!{reply,terminate(ChildList)}
	end.

restart_child(Pid,Reason,ChildList)->
	{value,{Pid,{M,F,A,T,C}}}=lists:keysearch(Pid,1,ChildList),
	io:format("Child terminated by  ~w~n",[{Reason,T}]),
	case {Reason,T,C<5} of
	     {normal,transient,_}->lists:keydelete(Pid,1,ChildList);
	     {Reason,permanent,false}->
		io:format("Process ~w ~w  had reached max retry times,remove it~n",[M,F]),
		lists:keydelete(Pid,1,ChildList);
	     {Reason,permanent,true}->
		receive after 12000->
			io:format("~w:Retry to restart process ~w ~w for ~w time~n",[time(),M,F,C+1]),
			{ok,NewPid}=apply(M,F,A),
			[{NewPid,{M,F,A,T,C+1}}|lists:keydelete(Pid,1,ChildList)]
		end
	end.

stop(Name)->
	Name!{stop,self()},
	receive {reply,Reply}->Reply end.

terminate([{Pid,_}|Rest])->
	exit(Pid,kill),
	terminate(Rest);
terminate([])-> ok.