%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (strips) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(X,Y),
    [inroom(X), connected(X,Y)],
    [inroom(Y)],
    [inroom(X)]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive way to print a list %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_list(0, _) :- !.
print_list(_, []).
print_list(N, [H|T]) :-
    write(H),
    nl,
    N1 is N - 1,
    print(N1, T).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive forward solution searcher %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, Plan, Plan):-
    subset(Goal, State), %% check wheter the goal is a subset of the actual state
    write('finished!'),
    print_list(5, Plan).

solve(State, Goal, Sofar, Plan):-
    action(ActionName, Preconditions, DeleteList, AddList), %% calles the action
    not(member(ActionName, Sofar)), %% checks if this action was already called
    subset(Preconditions, State), %% checks whether the precondition is a subset of the actual state
    delete(DeleteList, State, Remainder), %% deletes the given states from the current state list
    append(AddList, Remainder, NewState), %% adds the given states to the current state list
    solve(NewState, Goal, [ActionName|Sofar], Plan). %% recursively calls itself with the updated values



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - runner with initial state and goal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run(S, E) :- solve(S, E, [S], []).


%%%%%%%%%%%%%%%%%%%%
%% Shakey - tests %%
%%%%%%%%%%%%%%%%%%%%

test1 :-
    run(
        [connected(a, corridor), connected(b, corridor), connected(c, corridor), inroom(a)],
        [inroom(corridor)]). %% move from room a to corridor

test2 :-
    run(
        [connected(a, corridor), connected(b, corridor), connected(c, corridor), inroom(a)],
        [inroom(c)]). %% move from room a over corridor to room c







