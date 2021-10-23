-module(jiansu).
-export([two_sum/2,
        next_greater_element/2,
        frequency_sort/1]).

two_sum([], _) -> no;
two_sum(L, T) -> two_sum(L, T, 0).

two_sum([], _, _) -> no;
two_sum([H|T], Total, I) -> 
  case two_sum(H, T, Total, I, 1) of
    false -> two_sum(T, Total, I + 1);
    J -> io:fwrite("[~w,~w]~n", [I, I + J])
  end.

two_sum(X, [H|T], Total, I, J) ->
  case X + H == Total of
    true -> J;
    false -> two_sum(X, T, Total, I, J + 1)
  end;
two_sum(_, _, _, _, _) -> false.


%% Next Greater element
next_greater_element(L, L2) -> next_greater_element(L, L2, []).

next_greater_element([H|T], L2, Results) ->
  NewResults = [match(H, L2) | Results],
  next_greater_element(T, L2, NewResults);
next_greater_element([], _, Results) -> lists:reverse(Results).

% Don't need fallback, guaranteed to find match.
match(N, [H|T]) ->
  case N == H of
    true -> next(N, T);
    false -> match(N, T)
  end.

next(N, [H|T]) ->
  case N < H of
    true -> H;
    false -> next(N, T)
  end;
next(_, []) -> -1.

%% Frequency sort string
-spec frequency_sort(S :: unicode:unicode_binary()) -> unicode:unicode_binary().
frequency_sort(<<H/utf8,T/binary>>) ->
  io:format("~ts~n",[<<H/utf8>>]),
  frequency_sort(T);
frequency_sort(S) -> ok.

