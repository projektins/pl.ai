%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Blocks world - states %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% clear(X) -- ob der oberste block = X ist
%% on(X, Y) -- ob X auf Y liegt
%% ontable(X) -- ob der block X auf dem tisch ist
%% handempty() -- ob die hand leer ist
%% holding(X) -- ob der block X gehalten wird


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Blocks world - initial state %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ontable(a).
ontable(c).
on(b, a).
handempty().
clear(b).
clear(c).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Blocks world - actions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pickup(X) :- [ontable(X), handempty(), clear(X)],[add(holding(X)), del(ontable(X)), del(handempty()), del(clear(X))].

putdown(X) :- holding(X), [add(ontable(X)), add(handempty()), add(clear(X)), del(holding(X))].

stack(X) :- [holding(X), clear(X)], [add(on(X,Y)), add(handempty()), add(clear(X)), del(clea(Y)), del(holding(X))].

unstack(X) :- [handempty(), clear(X), on(X,Y)], [add(holing(X)), add(clear(Y)), del(cler(X)), del(handempty()), del(on(X,Y))].

move(X,Y,Z) :- [on(X,Y), clear(X), clear(Z)], [add(on(X,Y)), add(clear(Y)), add(clear(f1)), del(clear(Z)), del(on(X,Y))].

























































