-module(frequency).
-export([start/0,stop/0,allocate/0,deallocate/1]).
-export([init/0]).

start()->
	register(frequency,spawn(?MODULE,init,[])).

call(Msg)->
	frequency!{request,self(),Msg},
	receive
		{reply,Reply}->
			Reply
	end.

stop()->
	call(stop).

allocate()->
	call(allocate).

deallocate(Freq)->
	call({deallocate,Freq}).

init()->
	Frequencies=get_frequencies(),
	loop({Frequencies,[]}).

get_frequencies()->
	[10,11,12,13,14,15].

reply(To,Reply)->
	To!{reply,Reply}.

loop(State)->
	receive
		{request,From,allocate}->
			{NewState,Reply}=allocate(State,From),
			reply(From,Reply),
			loop(NewState);
		{request,From,{deallocate,Freq}}->
			{NewState,Reply}=deallocate(State,Freq,From),
			reply(From,Reply),
			loop(NewState);
		{request,From,stop}->
			case terminate(State) of
			     true->reply(From,ok);
			     Error->
				reply(From,Error),
				loop(State)
			end
	end.

terminate({_Frenquencies,[]})->
	true;
terminate(_State)->
	{error,frequency_occupy}.

allocate({[],Allocated},_From)->
	{{[],Allocated},{error,no_frequency}};
allocate({[Hd|Tl],Allocated},From)->
	case occupyNum(Allocated,From)<3 of
	     true->{{Tl,[{Hd,From}|Allocated]},{ok,Hd}};
	     false->{{[Hd|Tl],Allocated},{error,max_limit}}
	end.

occupyNum([],_)->
	0;
occupyNum([{_,From}|Rest],From)->
	1+occupyNum(Rest,From);
occupyNum([{_,_}|Rest],From)->
	occupyNum(Rest,From).
	
deallocate({Frequencies,Allocated},Freq,Pid)->
	case lists:keysearch(Freq,1,Allocated) of
	     false->
		{{Frequencies,Allocated},{error,no_allocated}};
	     {value,{Freq,Pid}}->
	     	NewAllocated=lists:keydelete(Freq,1,Allocated),
		{{[Freq|Frequencies],NewAllocated},{ok}};
	     {value,{Freq,_Pid}}->
		{{Frequencies,Allocated},{error,no_self}}
	end.
	
	