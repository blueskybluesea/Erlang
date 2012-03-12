-module(printNum).
-export([print/1,printeven/1]).

%This is a pring module

%Pring 1-n integer
print(X) when X>=1 -> print_helper(X,1).

print_helper(N,N) -> io:format("Number:~p~n",[N]);
print_helper(X,N) -> 
   io:format("Number:~p~n",[N]),
   print_helper(X,N+1).



printeven(X) when X>1 -> 
  printeven_helper(X,1).

printeven_helper(N,N) ->
  if
   N rem 2 == 0 -> io:format("Number:~p~n",[N]);
   true -> true
  end;
printeven_helper(X,N) ->
  if
   N rem 2 == 0 -> io:format("Number:~p~n",[N]);
   true -> true
  end,
  printeven_helper(X,N+1).