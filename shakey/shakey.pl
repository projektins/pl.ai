%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - fixed states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_fixed_states(X, Result) :-
    append(X, [
               connected(a, corridor),
               connected(b, corridor),
               connected(c, corridor)
           ], Result).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - variable states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_variable_states :-
    write('Possible parameters (rooms) = a, b, c, corridor'), nl,
    write('- inroom(X)'), nl,
    write('- doorOpen(X, Y)'), nl.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (strips) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(X,Y),
    [inroom(X), connected(X,Y)],
    [inroom(Y)],
    [inroom(X)]).

action(
    openDoor(X,Y),
    [connected(X,Y), not(doorOpen(X,Y)), (inroom(X); inroom(Y))],
    [doorOpen(X,Y)],
    []).

action(
    closeDoor(X,Y),
    [connected(X,Y), doorOpen(X,Y), (inroom(X); inroom(Y))],
    [],
    [doorOpen(X,Y)]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive way to print a list %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_list([]).
print_list([X|List]) :-
    write(X),nl,
    print_list(List).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive forward solution searcher %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, _, Actions):-
    subset(Goal, State), %% check wheter the goal is a subset of the actual state
    write('finished with the following actions:'), nl,
    print_list(Actions).

solve(State, Goal, Sofar, Actions):-
    action(ActionName, Preconditions, AddList, DeleteList), %% choose next action
    subset(Preconditions, State), %% checks if the preconditions of this action are valid
    subtract(State, DeleteList, Remainder), %% deletes the given states from the current state list
    append(Remainder, AddList, NewState), %% adds the given states to the current state list
    not(member(NewState, Sofar)), %% checks if the new state was already reached (loop avoiding)
    solve(NewState, Goal, [NewState|Sofar], [ActionName|Actions]), !. %% recursively calls itself with the updated values



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - runner with initial state and goal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run(S, E) :-
    add_fixed_states(S, S2),
    add_fixed_states(E, E2),
    solve(S2, E2, [S2], []).


%%%%%%%%%%%%%%%%%%%%
%% Shakey - tests %%
%%%%%%%%%%%%%%%%%%%%

test1 :-
    run(
        [inroom(a)],
        [inroom(corridor)]). %% move from room a to corridor

test2 :-
    run(
        [inroom(a)],
        [inroom(c)]). %% move from room a over corridor to room c







