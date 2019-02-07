VARIABLES(u,v,w,x,y,z,U,V,W,X,Y,Z)

goal	:-  	Queens(7,x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Queens(n,x) :- x is the solution to the n-queens problem.  The problem is as
% as follows: place n chess queens on a square board with n rows and n columns
% so that no queen is attacking another queen.  In other words, place them
% so that no two queens are on the same row, same column, or same diagonal.
% Obviously, this is possible if each column contains exactly one queen; consequent-
% ly, this program stores possible answers as n-tuples of the integers from 1
% to n, with each integer representing the row-position.  So, for example, with
% n = 4, [2,3,1,4] is a possible arrangement with the queen  in column 1
% on row 2, the queen on coulumn 2 on row 3, and so on (notice that this is 
% an illegal position, since the first queen is attacking the second). 
% The program works by placing one queen at a time, checking for safety, and
% backtracking when necessary.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Queens(_n,_qs) :-	range(1,_n,_ns),
			Queens(_ns,[],_qs).

Queens(_unplaced,_safe,_qs)	write("safe: "),write(_safe),		
				write("unplaced: "),write(_unplaced),write("\n"),
				select(_q,_unplaced,_unplaced1),
				not_attack(_q,_safe),
				cons(_newsafe,_q,_safe),
				Queens(_unplaced1,_newsafe,_qs).

Queens([],_qs,_qs).

not_attack(_q1,_q2)	attack(_q1,_q2),
			!,
			fail.

not_attack(_q1,_q2).

attack(x,_xs)		attack(x,1,_xs).

attack(x,_n,_qs)	head(y,_qs),
			(is x y + _n).

attack(x,_n,_qs)	head(y,_qs),
			is(x y - _n).

attack(x,_n,_qs)	head(u,_qs),
			tail(_ys,_qs),
			is(_n1 _n + 1),
			attack(x,_n1,_ys).

single(x)		tail(_tail,x),
			head(_head,_tail),
			!,
			fail.

single(x).

permutation(x,x)	single(x).

permutation(_xs,_perm)	select(z,_xs,_ys),
			permutation(_ys,_zs),
			cons(_perm,z,_zs).

select(x,_list,_newlist)	head(x,_list),
				tail(_newlist,_list).

select(x,_list,_newlist)	head(_head,_list),
				tail(_tail,_list),
				select(x,_tail,_),
				cons(_newlist,_head,_).

range(x,x,x).

range(_m,_n,_list)	(< _m,_n),
			tail(_tail,_list),
			is(_m1 _m + 1),
			range(_m1,_n,_ns),
			cons(_list,_m,_ns).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is another and much less intelligent version of queens.  It works by brute
% force, trying every possible board position for legality, and stopping when
% it finds a correct position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
queens(_n,_qs)		(range 1,_n,_ns),
			permutation(_ns,_qs),
			write("trying "),write(_qs)write(\n),
			safe(_qs).

safe([]).

safe(_position)		head(_q,_position),
			tail(_qs,_position),
			safe(_qs),
			not_attack(_q,_qs).
