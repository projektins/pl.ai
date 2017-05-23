% Simple STRIPS-like planner
% Monkey and Bananas Problem

% Artificial intelligence programming in prolog
% Practical 9

% 23/11/04 Tim Smith

% This predicate initialises the problem states. The first argument
% of solve/3 is the initial state, the 2nd the goal state, and the 
% third the plan that will be produced.

test(Plan):-   
    solve([on(monkey,floor),on(box,floor),at(monkey,a),at(box,b),
           at(bananas,c),status(bananas,hanging)],
	  [status(bananas,grabbed)],
                 Plan).

solve(State, Goal, Plan):-
    solve(State, Goal, [], Plan).

% This predicate produces the plan. Once the Goal list is a subset 
% of the current State the plan is complete and it is written to 
% the screen using write_sol/1.

solve(State, Goal, Plan, Plan):-
	is_subset(Goal, State), nl,
	write_sol(Plan).

solve(State, Goal, Sofar, Plan):-
	opn(Op, Preconditions, Delete, Add),
	is_subset(Preconditions, State),
	\+ member(Op, Sofar),
	delete_list(Delete, State, Remainder),
	append(Add, Remainder, NewState),
	write(Op), nl,   % Show the operators it is trying to apply
	solve(NewState, Goal, [Op|Sofar], Plan).
   
% The M&B problem has three operators.
% 1st arg = name
% 2nd arg = preconditions
% 3rd arg = delete list
% 4th arg = add list.

opn(go(X,Y),
    [at(monkey,X), on(monkey,floor)],
    [at(monkey,X)],
    [at(monkey,Y)]).
    
opn(push(B,X,Y),
    [at(monkey,X), at(B,X), on(monkey,floor), on(B,floor)],
    [at(monkey,X), at(B,X)],
    [at(monkey,Y), at(B,Y)]).

opn(climbon(B),   
    [at(monkey,X), at(B,X), on(monkey,floor), on(B,floor)],
    [on(monkey,floor)],
    [on(monkey,B)]).

opn(grab(B),
    [on(monkey,box), at(box,X), at(B,X), status(B,hanging)],
    [status(B,hanging)],
    [status(B,grabbed)]).

% Utility predicates.

% Check is first list is a subset of the second

is_subset([H|T], Set):-
    member(H, Set),
    is_subset(T, Set).
is_subset([], _).

% Remove all elements of 1st list from second to create third.

delete_list([H|T], List, Final):-
    remove(H, List, Remainder),
    delete_list(T, Remainder, Final).
delete_list([], List, List).
    
remove(X, [X|T], T).
remove(X, [H|T], [H|R]):-
    remove(X, T, R).

write_sol([]).
write_sol([H|T]):-
	write_sol(T),
	write(H), nl.
                 
append([H|T], L1, [H|L2]):-
    append(T, L1, L2).
append([], L, L).

member(X, [X|_]).
member(X, [_|T]):-
    member(X, T).

