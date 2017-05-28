%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - fixed states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_fixed_states(X, Result) :-
    append(X, [
               connected(room1, corridor),
               connected(room2, corridor),
               connected(room3, corridor)
           ], Result).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - help output %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

shakey_help :-
    write('Fixed conditions:'), nl,
    write('- connected(room1, corridor)'), nl,
    write('- connected(room2, corridor)'), nl,
    write('- connected(room3, corridor)'), nl,
    write('Possible conditions to set:'), nl,
    write('- inRoom(RoomName)'), nl,
    write('- doorOpen(RoomName1, RoomName2)'), nl,
    write('- boxInRoom(BoxName, RoomName)'), nl,
    write('- boxInHand(BoxName)'), nl,
    write('- handEmpty()'), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (order is important) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(RoomName1, RoomName2),
    [inRoom(RoomName1), connected(RoomName1, RoomName2), doorOpen(RoomName1, RoomName2)],
    [inRoom(RoomName2)],
    [inRoom(RoomName1)]).

action(
    takeBox(BoxName, RoomName),
    [boxInRoom(BoxName, RoomName), inRoom(RoomName), handEmpty()],
    [boxInHand(BoxName)],
    [boxInRoom(BoxName, RoomName), handEmpty()]).

action(
    putBox(BoxName, RoomName),
    [boxInHand(BoxName), inRoom(RoomName)],
    [boxInRoom(BoxName, RoomName), handEmpty()],
    [boxInHand(BoxName)]).

action(
    closeDoor(RoomName1, RoomName2),
    [connected(RoomName1, RoomName2), doorOpen(RoomName1, RoomName2), inRoom(RoomName1)],
    [],
    [doorOpen(RoomName1,RoomName2)]).

action(
    closeDoor(RoomName1, RoomName2),
    [connected(RoomName1, RoomName2), doorOpen(RoomName1, RoomName2), inRoom(RoomName2)],
    [],
    [doorOpen(RoomName1,RoomName2)]).

action(
    openDoor(RoomName1, RoomName2),
    [connected(RoomName1, RoomName2), inRoom(RoomName2)],
    [doorOpen(RoomName1, RoomName2)],
    []).

action(
    openDoor(RoomName1, RoomName2),
    [connected(RoomName1, RoomName2), inRoom(RoomName1)],
    [doorOpen(RoomName1, RoomName2)],
    []).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursively print a list (last element first) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_list_reversed([]).
print_list_reversed([Head|Tail]) :-
    print_list_reversed(Tail),
    write('- '), write(Head), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive depth-first solver %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, _, Actions):-
    subset(Goal, State), %% check wheter the goal is a subset of the actual state
    print_list_reversed(Actions).

solve(State, Goal, Sofar, Actions):-
    action(ActionName, Preconditions, AddList, DeleteList), %% choose next action
    subset(Preconditions, State), %% checks if the preconditions of this action are valid
    not(member(ActionName, Actions)), %% checks if the new state was already reached (loop avoiding)
    subtract(State, DeleteList, Remainder), %% deletes the given states from the current state list
    append(Remainder, AddList, NewState), %% adds the given states to the current state list
    solve(NewState, Goal, [NewState|Sofar], [ActionName|Actions]), !. %% recursively calls itself with the updated values



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - runner with initial state and goal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run(Start, Goal) :-
    add_fixed_states(Start, FullStart),
    add_fixed_states(Goal, FullGoal),
    solve(FullStart, FullGoal, [FullStart], []).


%%%%%%%%%%%%%%%%%%%%
%% Shakey - tests %%
%%%%%%%%%%%%%%%%%%%%

test1 :-
    write('move from room1 to corridor while the door is open'), nl,
    run(
        [inRoom(room1), doorOpen(room1, corridor)],
        [inRoom(corridor), doorOpen(room1, corridor)]).

test2 :-
    write('move from room1 to corridor while the door is closed'), nl,
    run(
        [inRoom(room1)],
        [inRoom(corridor), doorOpen(room1, corridor)]).

test3 :-
    write('move from room1 to corridor while the door is open and close it afterwards'), nl,
    run(
        [inRoom(room1), doorOpen(room1, corridor)],
        [inRoom(corridor)]).

test4 :-
    write('move from room1 to corridor while the door is closed and close it afterwards'), nl,
    run(
        [inRoom(room1)],
        [inRoom(corridor)]).

test5 :-
    write('take the box1 from room1 in the hand'), nl,
    run(
        [inRoom(room1), handEmpty(), boxInRoom(box1, room1)],
        [inRoom(room1), boxInHand(box1)]).

test6 :-
    write('put the box1 from the hand in the room1'), nl,
    run(
        [inRoom(room1), boxInHand(box1)],
        [inRoom(room1), handEmpty(), boxInRoom(box1, room1)]).

test7 :-
    write('take the box1 from room1, move to corridor and put the box1 in the corridor'), nl,
    run(
        [inRoom(room1), boxInRoom(box1, room1), handEmpty()],
        [inRoom(corridor), boxInRoom(box1, corridor), handEmpty()]).

runAllTests :-
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7.


