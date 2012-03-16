-module(log_handler).
-export([init/1,terminate/1,handle_event/2]).

init(File)->
	{ok,Fd}=file:open(File,write),
	{Fd,File}.

terminate({Fd,File})->
	file:close(Fd),
	{_,_,Ms}=now(),
	file:rename(File,File++integer_to_list(Ms)),
	File.

handle_event({Action,Id,Event},{Fd,File})->
	{MegaSec,Sec,MicroSec}=now(),
	io:format(Fd,"~w,~w,~w,~w,~w,~p~n",[MegaSec,Sec,MicroSec,Action,Id,Event]),
	{Fd,File};
handle_event(_,{Fd,File})->
	{Fd,File}.