-module(io_handler).
-export([init/1,terminate/1,handle_event/2]).

init(Count)->
	Count.

terminate(Count)->
	Count.

handle_event({raise_alarm,Id,Alarm},Count)->
	print(alarm,Id,Alarm,Count),
	Count+1;
handle_event({clear_alarm,Id,Alarm},Count)->
	print(clear,Id,Alarm,Count),
	Count+1;
handle_event(_Event,Count)->
	Count.

print(Type,Id,Alarm,Count)->
	Date=fmt(date()),
	Time=fmt(time()),
	io:format("#~w,~s,~s,~w,~w,~p~n",[Count,Date,Time,Type,Id,Alarm]).

fmt({A,B,C})->
	Astr=pad(integer_to_list(A)),
	Bstr=pad(integer_to_list(B)),
	Cstr=pad(integer_to_list(C)),
	[Astr,$:,Bstr,$:,Cstr].

pad([M1])->[$0,M1];
pad(Other)->Other.