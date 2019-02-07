VARIABLES(x,y,z)


goal :- brother(Charles,x),write(x),fail.

grandson(x,y) :- 	son(x,z),
			son(z,y).
grandson(x,y) :- 	daughter(x,z),
			son(z,y).
brother(x,y) :-		son(z,x),
			son(z,y),
			different(x,y).
brother(x,y) :-		son(z,x),
			daughter(z,y).
son(Elizabeth,Charles).
son(Elizabeth,Andrew).
son(Elizabeth,Edward).
daughter(Elizabeth,Anne).
son(Anne,Mark).
son(Charles,William).
son(Charles,Henry).
