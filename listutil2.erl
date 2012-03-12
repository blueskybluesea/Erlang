-module(listutil2).
-export([filter/2,reverse/1,concatenate/1,flatten/1]).

% filter integer from integers 
filter(L,I) ->
  filter_acc(L,I,[]).

filter_acc([],_,Acc) ->
  reverse(Acc);
filter_acc([H|T],I,Acc) when H=<I ->
  filter_acc(T,I,[H|Acc]);
filter_acc([_|T],I,Acc) ->
  filter_acc(T,I,Acc).

reverse(L) ->
  reverse_acc(L,[]). 

reverse_acc([],Acc) ->
  Acc;
reverse_acc([H|T],Acc) ->
  reverse_acc(T,[H|Acc]).

concatenate(L) ->
  reverse(concatenate_acc(L,[])).

concatenate_acc([],Acc) ->
  Acc;
concatenate_acc([H|T],Acc) when is_list(H)->
  concatenate_acc(T,concatenate_acc(H,Acc));
concatenate_acc([H|T],Acc) ->
  concatenate_acc(T,[H|Acc]).

flatten(L) -> 
  reverse(concatenate_acc(L,[])).
