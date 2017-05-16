%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - initial state %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
room(a).
room(b).
room(c).
room(corridor).

%% connected(X, Y) -- ob Raum X mit Raum Y verbunden ist
connected(a,corridor).
connected(b,corridor).
connected(c,corridor).

%% inroom(X) -- ob shakey sich im raum X befindet
inroom(a).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (strips) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(X,Y),
    [inroom(X), connected(X,Y)],
    [inroom(Y)],
    [inroom(X)]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive forward solution searcher %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, Plan, Plan):-
    is_subset(Goal, State). %% check wheter the actual state is already the goal
solve(State, Goal, Sofar, Plan):-
    action(ActionName, Preconditions, DeleteList, AddList), %% calles the action
    not(member(ActionName, Sofar)), %% checks if this action was already called
    is_subset(Preconditions, State), %% checks if the
    delete_list(DeleteList, State, Remainder), %% deletes the given states from the current state list
    append(AddList, Remainder, NewState), %% adds the given states to the current state list
    solve(NewState, Goal, [ActionName|Sofar], Plan). %% recursively calls itself with the updated values



