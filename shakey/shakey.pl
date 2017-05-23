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

help :-
    write('Fixed conditions:'), nl,
    write('- connected(room1, corridor)'), nl,
    write('- connected(room2, corridor)'), nl,
    write('- connected(room3, corridor)'), nl,
    write('Possible conditions to set:'), nl,
    write('- inRoom(roomName)'), nl,
    write('- doorOpen(roomName1, roomName2)'), nl,
    write('- boxInRoom(boxName, roomName)'), nl,
    write('- boxInHand(boxName)'), nl,
    write('- handEmpty()'), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (strips) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(roomName1, roomName2),
    [inRoom(roomName1), connected(roomName1, roomName2), doorOpen(roomName1, roomName2)],
    [inRoom(roomName2)],
    [inRoom(roomName1)]).

action(
    openDoor(roomName1, roomName2),
    [connected(roomName1, roomName2), inRoom(roomName1)],
    [doorOpen(roomName1, roomName2)],
    []).

action(
    closeDoor(roomName1, roomName2),
    [connected(roomName1, roomName2), doorOpen(roomName1, roomName2), inRoom(roomName1)],
    [],
    [doorOpen(roomName1,roomName2)]).

action(
    takeBox(boxName, roomName),
    [boxInRoom(boxName, roomName), inRoom(roomName), handEmpty()],
    [boxInHand(boxName)],
    [boxInRoom(boxName,roomName), handEmpty()]).

action(
    putBox(boxName, roomName),
    [boxInHand(boxName), inRoom(roomName)],
    [boxInRoom(boxName, roomName), handEmpty()],
    [boxInHand(boxName)]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursively print a list %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_list([]).
print_list([X|List]) :-
    write(X), nl,
    print_list(List).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursively reverse a list %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reverse_list(Inputlist, Outputlist):-
    reverse(Inputlist, [], Outputlist).
reverse([], Outputlist, Outputlist).
reverse([Head|Tail], List1, List2):-
    reverse(Tail, [Head|List1], List2).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive forward solution searcher %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(State, Goal, _, Actions):-
    subset(Goal, State), %% check wheter the goal is a subset of the actual state
    write('finished with the following actions:'), nl,
    reverse_list(Actions, ReversedActions),
    print_list(ReversedActions).

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

run(Start, Goal) :-
    add_fixed_states(Start, FullStart),
    add_fixed_states(Goal, FullGoal),
    solve(FullStart, FullGoal, [FullStart], []).


%%%%%%%%%%%%%%%%%%%%
%% Shakey - tests %%
%%%%%%%%%%%%%%%%%%%%

test1 :-
    write('test1: move from room1 to corridor while the door is open'), nl,
    run(
        [inRoom(room1), doorOpen(room1, corridor)],
        [inRoom(corridor), doorOpen(room1, corridor)]).

test2 :-
    write('test2: move from room1 to corridor while the door is closed'), nl,
    run(
        [inRoom(room1)],
        [inRoom(corridor), doorOpen(room1, corridor)]).

test3 :-
    write('test3: move from room1 to corridor while the door is open and close it afterwards'), nl,
    run(
        [inRoom(room1), doorOpen(room1, corridor)],
        [inRoom(corridor)]).

test4 :-
    write('test4: move from room1 to corridor while the door is closed and close it afterwards'), nl,
    run(
        [inRoom(room1)],
        [inRoom(corridor)]).

test5 :-
    write('test5: take the box1 from room1 in the hand'), nl,
    run(
        [inRoom(room1), handempty(), boxInRoom(box1, room1)],
        [inRoom(room1), boxInHand(box1)]).

test6 :-
    write('test6: put the box1 from the hand in the room1'), nl,
    run(
        [inRoom(room1), boxInHand(box1)],
        [inRoom(room1), handempty(), boxInRoom(box1, room1)]).

test7 :-
    write('test7: take the box1 from room1, move to corridor and put the box1 in the corridor'), nl,
    run(
        [inRoom(room1), boxInRoom(box1, room1)],
        [inRoom(corridor), boxInRoom(box1, corridor)]).


runAllTests :-
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7.


