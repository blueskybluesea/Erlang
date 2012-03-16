-module(event_manager).
-export([start/2,stop/1]).
-export([add_handler/3,delete_handler/2,swap_handlers/3,get_data/2,send_event/2]).
-export([init/1]).

start(Name,HandlerList)->
	register(Name,spawn(?MODULE,init,[HandlerList])),
	ok.

stop(Name)->
	Name!{stop,self()},
	receive
		{reply,Msg}->Msg
	end.

init(HandlerList)->
	loop(initialize(HandlerList)).

initialize([])->
	[];
initialize([{Handler,InitData}|Rest])->
	[{Handler,Handler:init(InitData)}|initialize(Rest)].

loop(State)->
	receive
		{request,From,Msg}->
			{Reply,NewState}=handle_msg(Msg,State),
			reply(From,Reply),
			loop(NewState);
		{stop,From}->
			reply(From,terminate(State))
	end.

reply(To,Reply)->
	To!{reply,Reply}.

call(Name,Msg)->
	Name!{request,self(),Msg},
	receive
		{reply,Reply}->
			Reply
	end.

handle_msg({add_handler,Handler,InitData},LoopData)->
	{ok,[{Handler,Handler:init(InitData)}|LoopData]};
handle_msg({swap_handlers,OldHandler,NewHandler},LoopData)->
	{Reply,NewLoopData}=handle_msg({delete_handler,OldHandler},LoopData),
	case Reply of
	     {error,instance}->{Reply,NewLoopData};
	     {OldHandler,Data}->
		{ok,[{NewHandler,NewHandler:init(Data)}|NewLoopData]}
	end;
handle_msg({delete_handler,Handler},LoopData)->
	case lists:keysearch(Handler,1,LoopData) of
	     false-> 
	     	     {{error,instance},LoopData};
	     {value,{Handler,Data}}->
		     Reply={Handler,Handler:terminate(Data)},
		     NewLoopData=lists:keydelete(Handler,1,LoopData),
		     {Reply,NewLoopData}
	end;
handle_msg({get_data,Handler},LoopData)->
	case lists:keysearch(Handler,1,LoopData) of
	     false->
		     {{error,instance},LoopData};
	     {value,{Handler,Data}}->
		     {{data,Data},LoopData}
	end;
handle_msg({send_event,Event},LoopData)->
	{ok,event(Event,LoopData)}.

event(_,[])->
	[];
event(Event,[{Handler,Data}|Rest])->
	[{Handler,Handler:handle_event(Event,Data)}|event(Event,Rest)].

add_handler(Name,Handler,InitData)->
	call(Name,{add_handler,Handler,InitData}).

swap_handlers(Name,OldHandler,NewHandler)->
	call(Name,{swap_handlers,OldHandler,NewHandler}).

delete_handler(Name,Handler)->
	call(Name,{delete_handler,Handler}).

get_data(Name,Handler)->
	call(Name,{get_data,Handler}).

send_event(Name,Event)->
	call(Name,{send_event,Event}).

terminate([])->[];
terminate([{Handler,Data}|Rest])->
	[{Handler,Handler:terminate(Data)}|terminate(Rest)].
	