VARIABLES(s,p,remainder,remainder2)
TRACE
[] :- sentence([Brave Washington crossed the chilly Delaware]).

sentence(s) :-	noun_phrase(s,remainder),
		verb_phrase(remainder).

noun_phrase(p,remainder) :-	head(_head,p),
				tail(remainder2,p),
				art(_head),
				noun_phrase2(remainder2,remainder).

noun_phrase(s,remainder) :-	noun_phrase2(s,remainder).

noun_phrase2(p,remainder) :-	head(_head,p),
				tail(remainder2,p),
				adj(_head),
				noun_phrase2(remainder2,remainder).

noun_phrase2(s,remainder) :-	head(_head,s),
				tail(remainder,s),
				noun(_head).

verb_phrase(p) :-		head(_head,p),
				tail(remainder,p),
				verb(_head),
				noun_phrase(remainder,remainder2).
noun(Washington).
art(the).
adj(chilly).
noun(Delaware).
verb(crossed).
adj(Brave).
