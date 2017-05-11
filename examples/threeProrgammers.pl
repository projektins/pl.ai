programms(otto, cplusplus).
programms(paul, java).
programms(heinz, pascal).

older(paul, otto).
older(heinz, paul).

sister(X, _) :- programms(X, cplusplus),!.
brother(X, _) :- programms(X, cplusplus),!.

married(_, _) :- sister(otto), heinz.
