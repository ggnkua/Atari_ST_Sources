%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	This file deals with non-deterministic finite automata (NDFA).  An NDFA
% is a conceptual machine which begins operation in a state defined as "init-
% state", and which can only be in one of a finite number of states.  The NDFA 
% is fed a string of characters, and either accepts or rejects the string,
% accepting it if it finds itself in a pre-defined final state when the string
% is finished, and rejecting it otherwise.  The machine's state changes are de-
% fined by a set of functions called "delta functions", which define the state
% before reception of a string symbol, the string symbol, and the new state.  So
% for example, the delta function
%	delta(state1,#,state2)
% says that if the machine is in state1 and receives a '#', it should enter 
% state2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VARIABLES(q,s)

goal :-		list_prompt(),
		read(_list),
		Accept(_list).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list_prompt() :- write("enter a list in brackets following the '?' prompt,\n"),
		   write("terminating the list with a period - i.e. \n"),
		   write("?[cat,dog,mouse].").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accept(string) :- string is a palindrome (reads the same backwards and
% forwards).  This is actually an NPDA, a non-deterministic pushdown finite
% automaton, and it uses a stack
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accept(s) :-	initial(q),
		Accept(q,s,[]).

Accept(q,_string,_stack)	head(_stringhead,_string),
				delta(q,_stringhead,_stack,_q1,_newstack),
				tail(_stringtail,_string),
				Accept(_q1,_stringtail,_newstack).

Accept(q,[],[]) :- 	final(q).

initial(q0).
final(q1).
delta(q0,_x,_string,q0,_newstack) :-	cons(_newstack,_x,_string).
delta(q0,_x,_string,q1,_newstack) :-	cons(_newstack,_x,_string).
delta(q0,_x,_string,q1,_string).
delta(q1,_x,_string,q1,_newstack) :-	write(comparing)write(_x),
					write(_string),write("\n"),
					head(_x,_string),
					tail(_newstack,_string).

		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% accept(string) :- string is of the form (ab)* (that is, of the form 
% "a b a b ... a b"  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
accept(s)	initial(q),
		accept(q,s).
accept(q,s)	head(_head,s),
		tail(_tail,s),
		delta(q,_head,_),
		accept(_,_tail).
accept(q,[])	final(q).



initial(initstate).
final(initstate).
delta(initstate,a,finalstate).
delta(finalstate,b,initstate).

