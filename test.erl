-module(test).
-export([sum/1,sumHelper/1]).

sum(0) -> 0;
sum(N) when N>0 ->
     N+sum(N-1).

sumHelper(0) -> 0;
sumHelper(N) when N>0 -> 
     sum_acc(N,0).

sum_acc(0,Acc) -> Acc;
sum_acc(N,Acc) -> sum_acc(N-1,Acc+N).
