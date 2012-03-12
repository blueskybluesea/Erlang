-module(sum).
-export([sum/2,sum_helper/2]).

sum(N,M) when N=:=M -> N;
sum(N,M) when N<M -> N+sum(N+1,M).

sum_helper(N,M) when N=<M -> sum_acc(N,M,0).

sum_acc(N,M,Acc) when N=:=M -> N+Acc; 
sum_acc(N,M,Acc) -> sum_acc(N+1,M,Acc+N).