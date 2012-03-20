-module(my_supervisor).
-export([start_link/2,stop/1,start_child/2,stop_child/2]).
-export([init/1]).

start_link(Name,ChildSpecList)->
	register(Name,spawn_link(?MODULE,init,[ChildSpecList])),
	ok.

init(ChildSpecList)->
	process_flag(trap_exit,true),
	loop(start_children(ChildSpecList,{1,[]})).

start_children([],Acc)->Acc;
start_children([{M,F,A,T}|Rest],{C,L})->
	case (catch apply(M,F,A)) of
	     {ok,Pid}->start_children(Rest,{C+1,[{Pid,C,{M,F,A,T,0}}|L]});
	     _->start_children(Rest,{C,L})
	end.

start_child(Name,{M,F,A,T})->
    Name!{start_child,self(),{M,F,A,T}},
    receive 
	{reply,Reply}->
	    Reply
    end.

stop_child(Name,Id)->
    Name!{stop_child,self(),Id},
    receive
	{reply,Reply}->
	    Reply
    end.

loop({Count,ChildList})->
    receive
	{start_child,From,{M,F,A,T}}->
	    {Reply,{NewCount,NewChildList}}=startChild({M,F,A,T},{Count,ChildList}),
	    From!{reply,Reply},
	    loop({NewCount,NewChildList});
	{stop_child,From,Id}->
	    Reply=stopChild(Id,ChildList),
	    From!{reply,Reply},
	    loop({Count,ChildList});
	{'EXIT',Pid,normal}->
	    loop({Count,lists:keydelete(Pid,1,ChildList)});
	{'EXIT',Pid,Reason}->
	    NewChildList=restart_child(Pid,Reason,ChildList),
	    loop({Count,NewChildList});
	{stop,From}->
	    From!{reply,terminate(ChildList)}
    end.

startChild({M,F,A,T},{Count,ChildList})->
	case (catch apply(M,F,A)) of
	     {ok,Pid}->{{Count,Pid},{Count+1,[{Pid,Count,{M,F,A,T,0}}|ChildList]}};
	     _->{{error,error_apply},{Count,ChildList}}
	end.

stopChild(Id,ChildList)->
    case lists:keysearch(Id,2,ChildList) of
	false->{error,instant};
	{value,{Pid,Id,_}}->
	    Pid!{stop,self()},
	    receive 
		Reply->Reply 
	    end
    end.


restart_child(Pid,Reason,ChildList)->
    {value,{Pid,Id,{M,F,A,T,C}}}=lists:keysearch(Pid,1,ChildList),
    io:format("Process terminated with ~w~n",[Reason]),
    case {Reason,T,C<5} of
	{normal,_,_}->lists:keydelete(Pid,1,ChildList);
	{Reason,permanent,false}->
	    io:format("Process ~w ~w had reached max retry times,remove it~n",[M,F]),
	    lists:keydelete(Pid,1,ChildList);
	{Reason,permanent,true}->
	    io:format("~w:Retry to restart process ~w ~w for ~w time~n",[time(),M,F,C+1]),
	    {ok,NewPid}=apply(M,F,A),
	    receive
	    after 12000->
		    [{NewPid,Id,{M,F,A,T,C+1}}|lists:keydelete(Pid,1,ChildList)]
	    end
    end.

stop(Name)->
	Name!{stop,self()},
	receive {reply,Reply}->Reply end.

terminate([{Pid,_}|Rest])->
	exit(Pid,kill),
	terminate(Rest);
terminate([])-> ok.
