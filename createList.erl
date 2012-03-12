-module(createList).
-export([create/1,create2/1,reverse_create/1]).

create(0) -> [];
create(X) when X>0 -> [X|create(X-1)].

create2(X) -> create_acc(X,[]).
reverse_create(X) -> lists:reverse(create2(X)).

create_acc(0,Acc) -> Acc;
create_acc(X,Acc) when X>0 -> create_acc(X-1,[X|Acc]). 