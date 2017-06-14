%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - fixed states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_fixed_states(X, Result) :-
    append(X, [
		   room(room1),
		   room(room2),
		   room(room3),
		   room(corridor),
		   door(door1),
		   door(door2),
		   door(door3),
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
    write('- room(room1)'), nl,
    write('- room(room2)'), nl,
    write('- room(room3)'), nl,
    write('- door(door1)'), nl,
    write('- door(door2)'), nl,
    write('- door(door3)'), nl,
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
    write('- in(RobotName / ObjectName, RoomName)'), nl,
    write('- status(DoorName, StatusName)'), nl,
    write('- object(ObjectName)'), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions (order is important) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

action(
    move(From, To),
    [room(From), room(To), in(shakey, From), connected(To, From), connected(From, Door), connected(To, Door), status(Door, open)],
    [in(shakey, To)],
    [in(shakey, From)]).

action(
    move(From, To),
    [room(From), room(To), in(shakey, From), connected(From, To), connected(From, Door), connected(To, Door), status(Door, open)],
    [in(shakey, To)],
    [in(shakey, From)]).

action(
    put(ObjectName, RoomName),
    [object(ObjectName), room(RoomName), in(ObjectName, shakeysHand), in(shakey, RoomName)],
    [in(ObjectName, RoomName), in(nothing, shakeysHand)],
    [in(ObjectName, shakeysHand)]).

action(
    closeDoor(DoorName, RoomName),
    [door(DoorName), room(RoomName), connected(RoomName, DoorName), status(DoorName, open), in(shakey, RoomName)],
    [status(DoorName, closed)],
    [status(DoorName, open)]).

action(
    grab(ObjectName, RoomName),
    [object(ObjectName), room(RoomName), in(ObjectName, RoomName), in(shakey, RoomName), in(nothing, shakeysHand)],
    [in(ObjectName, shakeysHand)],
    [in(ObjectName, RoomName), in(nothing, shakeysHand)]).

action(
    openDoor(DoorName, RoomName),
    [door(DoorName), room(RoomName), connected(RoomName, DoorName), status(DoorName, closed), in(shakey, RoomName)],
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

subset([], _).
subset([Head|Tail], Set):-
    member(Head, Set),
    subset(Tail, Set).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - nested list member checker %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nested_List_member(List, [Head | Tail]) :-
    equal_lists(List, Head);
    nested_List_member(List, Tail).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - equal lists checker %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

equal_lists(List1, List2) :-
	subset(List1, List2),
	subset(List2, List1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - forward depth-first solver %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve(StateList, GoalList, _, ActionList):-
    equal_lists(GoalList, StateList), %% checks whether the goal and the state are equal
    print_list_reversed(ActionList).

solve(StateList, GoalList, Sofar, ActionList):-
    action(ActionName, Preconditions, AddList, DeleteList), %% choose next action
    subset(Preconditions, StateList), %% checks if the preconditions of this action are valid
    not(member(ActionName, ActionList)), %% checks if this action was already called (avoids loops)
    subtract(StateList, DeleteList, TmpList), %% deletes the given states from the current state list
    append(TmpList, AddList, NewStateList), %% adds the given states to the current state list
    not(nested_List_member(NewStateList, Sofar)), %% checks if this state was already reached (avoids unnecessary actions)
    solve(NewStateList, GoalList, [NewStateList|Sofar], [ActionName|ActionList]), !. %% recursively calls itself with the updated values


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

test(
    1,
    'move from room1 to corridor while the door is open',
    [in(shakey, room1), status(door1, open)],
    [in(shakey, corridor), status(door1, open)]).

test(
    2,
    'move from room1 to corridor while the door is closed',
    [in(shakey, room1), status(door1, closed)],
    [in(shakey, corridor), status(door1, open)]).

test(
    3,
    'move from room1 to corridor while the door is open and close it afterwards',
    [in(shakey, room1), status(door1, open)],
    [in(shakey, corridor), status(door1, closed)]).

test(
    4,
    'move from room1 to corridor while the door is closed and close it afterwards',
    [in(shakey, room1), status(door1, closed)],
    [in(shakey, corridor), status(door1, closed)]).

test(
    5,
    'take the box1 from room1 in the hand',
    [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1), object(box1)],
    [in(shakey, room1), in(box1, shakeysHand), object(box1)]).

test(
    6,
    'put the box1 from the hand in the room1',
    [in(shakey, room1), in(box1, shakeysHand), object(box1)],
    [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1), object(box1)]).

test(
    7,
    'take the box1 from room1, move to corridor and put the box1 in the corridor',
    [in(shakey, room1), in(box1, room1), in(nothing, shakeysHand), status(door1, closed), object(box1)],
    [in(shakey, corridor), in(box1, corridor), in(nothing, shakeysHand), status(door1, open), object(box1)]).

test(
    8,
    'move from room1 over corridor to room3 with open doors',
    [in(shakey, room1), status(door1, open), status(door3, open)],
    [in(shakey, room3), status(door1, open), status(door3, open)]).

test(
    9,
    'take the box1 from room1, move to room3 and put the box1 in the room3 (all doors closed and must be closed afterwards)',
    [in(shakey, room1), in(box1, room1), in(nothing, shakeysHand), status(door1, closed), status(door3, closed), object(box1)],
    [in(shakey, room3), in(box1, room3), in(nothing, shakeysHand), status(door1, closed), status(door3, closed), object(box1)]).

test(
    10,
    'take the box1 from room1, move to room3, put the box1 in room3, move to room2, take the box2 from room2, move to room1, put the box2 to room1 (all doors are closed and must be closed afterwards)',
    [in(shakey, room1), in(nothing, shakeysHand), in(box1, room1), in(box2, room2), status(door1, closed), status(door2, closed), status(door3, closed), object(box1), object(box2)],
    [in(shakey, room1), in(nothing, shakeysHand), in(box1, room3), in(box2, room1), status(door1, closed), status(door2, closed), status(door3, closed), object(box1), object(box2)]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - recursive testrunner %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test([]).
test([Head|Tail]) :-
    test(Head, Instruction, StartState, GoalState),
    nl, write('Test '), write(Head), write(': '), write(Instruction), nl,
    statistics(walltime, [Start,_]),
    run(StartState, GoalState),
    statistics(walltime, [End,_]),
    Time is End - Start,
    write('elapsed time: '), write(Time), write('ms'), nl,
    test(Tail).

runAllTests :-
    statistics(walltime, [Start,_]),
    test([1,2,3,4,5,6,7,8,9,10]),
    statistics(walltime, [End,_]),
    Time is End - Start,
    write('total elapsed time: '), write(Time), write('ms').
