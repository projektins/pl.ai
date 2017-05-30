%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - fixed states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_fixed_states(X, Result) :-
    append(X, [
               connected(room1, corridor),
               connected(room2, corridor),
               connected(room3, corridor),
               connected(room1, door1),
               connected(room2, door2),
               connected(room3, door3),
               connected(corridor, door1),
               connected(corridor, door2),
               connected(corridor, door3)
           ], Result).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - help output %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

shakey_help :-
    write('Fixed conditions:'), nl,
    write('- connected(room1, corridor)'), nl,
    write('- connected(room2, corridor)'), nl,
    write('- connected(room3, corridor)'), nl,
    write('- connected(room1, door1)'), nl,
    write('- connected(room2, door2)'), nl,
    write('- connected(room3, door3)'), nl,
    write('- connected(corridor, door1)'), nl,
    write('- connected(corridor, door2)'), nl,
    write('- connected(corridor, door3)'), nl,
    write('Possible conditions to set:'), nl,
    write('- in(Object, RoomName)'), nl,
    write('- status(Object, StatusName)'), nl.


%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions %%
%%%%%%%%%%%%%%%%%%%%%%

action(
    move(From, To),
    [in(shakey, From), connected(From, To), connected(From, Door), connected(To, Door), status(Door, open)],
    [in(shakey, To)],
    [in(shakey, From)]).

action(
    move(From, To),
    [in(shakey, From), connected(To, From), connected(From, Door), connected(To, Door), status(Door, open)],
    [in(shakey, To)],
    [in(shakey, From)]).

action(
    grab(Object, RoomName),
    [in(Object, RoomName), in(shakey, RoomName), in(nothing, shakeysHand)],
    [in(Object, shakeysHand)],
    [in(Object, RoomName), in(nothing, shakeysHand)]).

action(
    put(Object, RoomName),
    [in(Object, shakeysHand), in(shakey, RoomName)],
    [in(Object, RoomName), in(nothing, shakeysHand)],
    [in(Object, shakeysHand)]).

action(
    closeDoor(DoorName, RoomName),
    [connected(RoomName, DoorName), status(DoorName, open), in(shakey, RoomName)],
    [status(DoorName, closed)],
    [status(DoorName, open)]).

action(
    openDoor(DoorName, RoomName),
    [connected(RoomName, DoorName), status(DoorName, closed), in(shakey, RoomName)],
    [status(DoorName, open)],
    [status(DoorName, closed)]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursively print a list (last element first) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_list_reversed([]).
print_list_reversed([Head|Tail]) :-
    print_list_reversed(Tail),
    write('- '), write(Head), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - subset checker                                       %%
%% the subset/2 from swi does not work cause of this reason:     %%
%% https://stackoverflow.com/questions/4912869/subsets-in-prolog %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subset([Head|Tail], Set):-
    member(Head, Set),
    subset(Tail, Set).
subset([], _).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - equal lists checker %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

equal_lists(List1, List2) :-
	subset(List1, List2),
	subset(List2, List1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive depth-first solver %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, Actions):-
    equal_lists(Goal, State), %% checks wheter the goal and the state are equal
    print_list_reversed(Actions).

solve(State, Goal, Actions):-
    action(ActionName, Preconditions, AddList, DeleteList), %% choose next action
    subset(Preconditions, State), %% checks if the preconditions of this action are valid
    not(member(ActionName, Actions)), %% checks if this action was already called (loop avoiding)
    subtract(State, DeleteList, Remainder), %% deletes the given states from the current state list
    append(Remainder, AddList, NewState), %% adds the given states to the current state list
    solve(NewState, Goal, [ActionName|Actions]), !. %% recursively calls itself with the updated values


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - runner with initial state and goal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run(Start, Goal) :-
    add_fixed_states(Start, FullStart),
    add_fixed_states(Goal, FullGoal),
    solve(FullStart, FullGoal, []).


%%%%%%%%%%%%%%%%%%%%
%% Shakey - tests %%
%%%%%%%%%%%%%%%%%%%%

test1 :-
    write('move from room1 to corridor while the door is open'), nl,
    run(
        [in(shakey, room1), status(door1, open)],
        [in(shakey, corridor), status(door1, open)]).

test2 :-
    write('move from room1 to corridor while the door is closed'), nl,
    run(
        [in(shakey, room1), status(door1, closed)],
        [in(shakey, corridor), status(door1, open)]).

test3 :-
    write('move from room1 to corridor while the door is open and close it afterwards'), nl,
    run(
        [in(shakey, room1), status(door1, open)],
        [in(shakey, corridor), status(door1, closed)]).

test4 :-
    write('move from room1 to corridor while the door is closed and close it afterwards'), nl,
    run(
        [in(shakey, room1), status(door1, closed)],
        [in(shakey, corridor), status(door1, closed)]).

test5 :-
    write('take the box1 from room1 in the hand'), nl,
    run(
        [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1)],
        [in(shakey, room1), in(box1, shakeysHand)]).

test6 :-
    write('put the box1 from the hand in the room1'), nl,
    run(
        [in(shakey, room1), in(box1, shakeysHand)],
        [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1)]).

test7 :-
    write('take the box1 from room1, move to corridor and put the box1 in the corridor'), nl,
    run(
        [in(shakey, room1), in(box1, room1), in(nothing, shakeysHand), status(door1, closed)],
        [in(shakey, corridor), in(box1, corridor), in(nothing, shakeysHand), status(door1, open)]).

test8 :-
    write('move from room1 over corridor to room3 with open doors'), nl,
    run(
        [in(shakey, room1), status(door1, open), status(door3, open)],
        [in(shakey, room3), status(door1, open), status(door3, open)]).

test9 :-
    write('take the box1 from room1, move to room3, put the box1 in room3, move to room2, take the box2 from room2, move to room1, put the box2 to room1 (all doors are closed and must be closed afterwards)'), nl,
    run(
        [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1), in(box2, room2), status(door1, closed), status(door2, closed), status(door3, closed)],
        [in(shakey, room1), in(nothing, shakeysHand), in(box1, room3), in(box2, room1), status(door1, closed), status(door2, closed), status(door3, closed)]).


runAllTests :-
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
    test9.
