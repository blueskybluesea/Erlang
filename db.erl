-module(db).
-export([new/0,destroy/1,write/3,delete/2,delete2/2,read/2,match/2]).

% new db
new() ->
  [].

% destroy db
destroy(Db) ->
  "destroy db "++Db.

% wirte data to db
write(Key,Element,Db) ->
  [{Key,Element}|Db].

delete2(_,[]) ->
 [];
delete2(Key,[{Key,_}|T]) ->
 T;
delete2(Key,[H|T]) ->
 [H|delete2(Key,T)].

delete(Key,Db) ->
  delete_acc(Key,Db,[]).

delete_acc(_,[],Acc) ->
  Acc;
delete_acc(Key,[{Key,_}|T],Acc) ->
  delete_acc(Key,T,Acc);
delete_acc(Key,[H|T],Acc) ->
  delete_acc(Key,T,[H|Acc]).

% read data from DB
read(_,[]) ->
  {error,instance};
read(Key,[{Key,Element}|_]) ->
  {ok,Element};
read(Key,[_|T]) ->
  read(Key,T).

% query data from db by key
match(Element,Db) ->
  match_acc(Element,Db,[]).

match_acc(_,[],Acc) ->
  Acc;
match_acc(Element,[{Key,Element}|T],Acc) ->
  match_acc(Element,T,[Key|Acc]);
match_acc(Element,[_|T],Acc) ->
  match_acc(Element,T,Acc).

  
   