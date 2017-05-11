%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - initial state %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
room(a).
room(b).
room(c).
room(corridor).

%% connected(X, Y) -- ob Raum X mit Raum Y verbunden ist
connected(a, corridor).
connected(b, corridor).
connected(c, corridor).

%% inroom(X) -- ob shakey sich im raum X befindet
inroom(a).

%%%%%%%%%%%%%%%%%%%%%%
%% Shakey - actions %%
%%%%%%%%%%%%%%%%%%%%%%


%% move(X, Y) -- moves shakey von raum X nach Raum Y
% Precondition = inroom(X), connected(X, Y)
%
move(X, Y) :-

