VARIABLES(u,v,w,x,y,z,U,V,W,X,Y,Z)

goal :- list_prompt(),
	read(x),
	reverse(x,y),
	write("the reversed list is ",y,"\n").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list_prompt() :- write("enter a list in brackets following the '?' prompt,\n"),
		   write("terminating the list with a period - i.e. \n"),
		   write("?[cat,dog,mouse].").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
atom_prompt() :- write("enter an item following the '?' prompt, "),
		 write("terminating the item with a period, i.e. \n"),
		   write("?mouse.<CR>").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% flatten(x,y) :- y is a list of the atoms of x (that is (cat,(dog,mouse))
% becomes cat,dog,mouse.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flatten(x,y) :-	head(_head,x),
		tail(_tail,x),
		flatten(_head,_y1),
		flatten(_tail,_y2),
		append(_y1,_y2,y).
flatten([],[]).
flatten(x,x) :-	constant(x).

constant(x) :-	head(_head,x),
		!,
		fail.
constant(x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% append(x,y,z) :- z is the result of appending x to y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
append([],x,x).

append(X,y,Z) :-	head(u,X),
			tail(_x_tail,X),
			append(_x_tail,y,_),
			cons(Z,u,_).

append(x,y,z) :-	cons(z,x,y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% quicksort(x,y) :- y is the sorted version of x - this is a quicksort
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
quicksort(_list,_ys) :-	head(_head,_list),
			tail(_tail,_list),
			partition(_tail,_head,_littles,_bigs),
			quicksort(_littles,_ls),
			quicksort(_bigs,_bs),
			cons(_,_head,_bs),
			append(_ls,_,_ys).
quicksort([],[]).

partition(_list,_element,_ls,_bs) :-	head(_head,_list),
					<=(_head,_element),
					tail(_tail,_list),
					partition(_tail,_element,_temp,_bs),
					cons(_ls,_head,_temp),
					write("ls: ",_ls),
					write("bs: ",_bs,"\n").

partition(_list,_element,_ls,_bs) :-	head(_head,_list),
					>(_head,_element),
					tail(_tail,_list),
					partition(_tail,_element,_ls,_temp),
					cons(_bs,_head,_temp),
					write("ls: ",_ls),
					write("bs: ",_bs,"\n").
partition([],x,[],[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% delete(x,y,z) :- z is the result of deleting all instances of y from list x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete(_list,x _ys) :-	head(x,_list),
			tail(_tail,_list),
			delete(_tail,x,_ys).

delete(_list1,z,_list2)	:-	head(x,_list1),
				tail(_xs,_list1),
				delete(_xs,z,_ys),
				cons(_list2,x,_ys).

delete([],x,[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sublist(x,y) :- x is a sub-list of y (i.e., [b,c] is a sublist of [a,b,c,d,e]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sublist(x,y) :-	prefix(x,y).
sublist(x,Y) :-	head(_y_head,Y),
		tail(_y_tail,Y),
		sublist(x,_y_tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prefix(x,y) :- x is a prefix of y (i.e., [a,b] is a prefix of [a,b,c,d,e]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prefix([],x).

prefix(X,Y) :-	head(_x_head,X),
		head(_x_head,Y),
		tail(_x_tail,X),
		tail(_y_tail,Y),
		prefix(_x_tail,_y_tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% length(x,n) :- n is the length of the list x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length([],0).
length(X,y)  :-	head(x,X),
		tail(_tail,X),
		length(_tail,_sub),
		is(y,_sub + 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% suffix(x,y) :- x is a suffix of y (i.e., [d,e] is a suffix of [a,b,c,d,e]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
suffix(Y,Y).
suffix(X,Y)	head(u,Y),
		tail(_y_tail,Y),
		suffix(X,_y_tail).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% member(x y) :- the element x is a member of the list y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
member(x,y) :-	head(x,y).

member(x,y) :-	head(_head,y),
		tail(_tail,y),
		member(x,_tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% psort(x,y) :- y is the sorted version of x.  This sort is extremely naive-
% it simply creates all ossible permutations of x and tests them for orderdness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
psort(x,y)	:-	permutation(x,y),
			write("trying  "),
			write(y),
			write("\n"),
			ordered(y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single(x) :- x has fewer than two elements 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
single(x)	:-	tail(_tail,x),
			head(_head,_tail),
			!,
			fail.

single(x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ordered(x) :- the list x is ordered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ordered(X)	:-	(single X).

ordered(X)	:-	head(u,X),
			tail(x,X),
			head(v,x),
			(<= u,v),
			(ordered x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% permutation(xs,perm) :- perm is a permutation of the list xs.  This program
% has the effect of generating all possible permutations of xs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
permutation(_xs,_perm) :-	(select z,_xs _ys),
				(permutation,_ys,_zs),
				(cons _perm,z,_zs).
permutation([],[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select(x,list,newlist) :- newlist is the result of removing the instances
% f x from list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
select(x,_list,_newlist) :- 	head(x,_list),
				tail(_newlist,_list).

select(x,_list,_newlist) :-	head(_head,_list),
				tail(_tail,_list),
				select(x,_tail,_),
				cons(_newlist,_head,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reverse(list,tsil) :- tsil is the reverse of the list list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reverse([],[]).	

reverse(_list,_tsil)	head(_head,_list),
			tail(_tail,_list),
			reverse(_tail,z),
			append(z,_head,_tsil). 

