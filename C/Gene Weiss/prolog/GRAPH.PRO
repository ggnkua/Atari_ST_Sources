%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	This database deals with graphs.  Since the interpreter needn't know
% anything about the shape of the graph, but only needs to know about which
% nodes have edges between them, an entire graph can be recorded as a collection
% of facts of the form "edge(A,B)", which says that there is an edge between
% edge A and edge B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
VARIABLES(A,B,X,Y,Z)

goal	(connected a i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	connected(A,B) :- there is a path between A and B. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
connected(A A).
connected(A B)	:-	edge(A _N),
			write(_N,"\n"),
			connected(_N B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Connected(A,B) :- there is a path between A and B. This program keeps
% track of the nodes that have been visited so far, to avoid going in circles
% in a cyclic graph.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Connected(A B)	:- Connected(A B A).
Connected(A A _visited).
Connected(A B _visited)	:-	edge(A _n),
				not_member(_n _visited),
				write(_n,"\n"),
				cons(_visited2,_n,_visited),
				Connected(_n,B,_visited2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% not_member(X,Y) :- X isn't an element of the list Y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
not_member(X,Y)	:-	member(X,Y),
			!,
			fail.
not_member(X,Y).

member(X,Y) :-	head(X,Y).
member(X,Y) :-	head(_head,Y),
		tail(_tail,Y),
		member(X,_tail).

edge(a b).
edge(a c).
edge(a d).
edge(a e).
edge(d j).
edge(c f).
edge(c g).
edge(f h).
edge(e k).
edge(f i).
edge(x y).
edge(y z).
edge(z x).
edge(y u).
edge(z v).
