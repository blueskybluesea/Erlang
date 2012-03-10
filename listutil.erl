-module(listutil).
-export([quickSort/1,mergeSort/1]).

% Simple quick sort algorithm implemention
quickSort([])->
    [];
quickSort([Hd|[]]) ->
    [Hd];
quickSort([Hd|Tl]) ->
    quickSort_acc(Hd,Tl,[],[]).

quickSort_acc(Pivot,[],Less,Greater)->
    quickSort(Less)++[Pivot]++quickSort(Greater);
quickSort_acc(Pivot,[Hd|Tl],Less,Greater) when Hd=<Pivot ->
    quickSort_acc(Pivot,Tl,[Hd|Less],Greater);
quickSort_acc(Pivot,[Hd|Tl],Less,Greater) ->
    quickSort_acc(Pivot,Tl,Less,[Hd|Greater]).

% Merge sort algorithm implemention
mergeSort([])->
    [];
mergeSort([Hd|[]])->
    [Hd];
mergeSort(List) ->
    {Left,Right}=split(List,sizeOf(List) div 2),
    merge(mergeSort(Left),mergeSort(Right)).

merge(Left,Right)->
    merge_acc(Left,Right,[]).

merge_acc([],[],Acc)->
    lists:reverse(Acc);
merge_acc([Lhd|Ltl],[],Acc) ->
    merge_acc(Ltl,[],[Lhd|Acc]);
merge_acc([],[Rhd|Rtl],Acc) ->
    merge_acc([],Rtl,[Rhd|Acc]);
merge_acc([Lhd|Ltl],[Rhd|Rtl],Acc) when Lhd>Rhd  ->
    merge_acc([Lhd|Ltl],Rtl,[Rhd|Acc]);
merge_acc([Lhd|Ltl],[Rhd|Rtl],Acc) ->
    merge_acc(Ltl,[Rhd|Rtl],[Lhd|Acc]).

split(List,X)->
    split_acc(List,X,0,[]).

split_acc(List,X,X,Acc)->
    {Acc,List--Acc};
split_acc([Hd|Tl],X,Y,Acc) ->
    split_acc(Tl,X,Y+1,[Hd|Acc]).
    
sizeOf(List)->
    size_acc(List,0).

size_acc([],Acc)->
    Acc;
size_acc([_|Tl],Acc) ->
    size_acc(Tl,Acc+1).

