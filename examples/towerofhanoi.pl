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
ontable(A).
on(B, A).
ontable(C).
handempty().
clear(B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Blocks world - actions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 pickup(X)
  - Precondition = ontable(X), handempty(), clear(X)
  - Add Effect = holding(X)
  - Delete Effect = ontable(X), handempty(), clear(X)

 putdown(X)
  - Precondition = holding(X)
  - Add Effect = ontable(X), handempty(), clear(X)
  - Delete Effect = holding(X)

 stack(X,Y)
  - Precondition = holding(X), clear(X)
  - Add Effect = on(X, Y), handempty(), clear(X)
  - Delete Effect = clear( Y), holding(X)

 unstack(X,Y)
  - Precondition = handempty(), clear(X), on(X, Y)
  - Add Effect = holding(X), clear( Y)
  - Delete Effect = clear(X), handempty(), on(X, Y)

 move(X,Y,Z)
  - Precondition = on(x, y), clear(x), clear(z)
  - Add Effect = on(x, z), clear(y), clear(Fl)
  - Delete Effect = clear(z), on(x, y)


