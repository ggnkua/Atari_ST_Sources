VARIABLES(u,v,w,x,y,z,U,V,W,X,Y,Z,n)

goal	:- number_prompt(),
	read(x),
	factorial(x,z),write(z).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
number_prompt() :- write("enter a number following the '?' prompt,"),
		   write("terminating the number with a period - i.e. \n"),
		   write("?100.<CR>").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list_prompt() :- write("enter a list in brackets following the '?' prompt,\n"),
		   write("terminating the list with a period - i.e. \n"),
		   write("?[cat,dog,mouse].").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gcd(x,y,z) :- z is the greatest common denominator of x and y (this 
% program uses Euclid's algorithm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gcd(x,0,x)	:- >(x,0).
gcd(x,y,_answer) :- 	is(z, x % y),
			gcd(y,z,_answer).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% not_square(x) :- x isn't a perfect square
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
not_square(x) :- 	square(x),
			!,
			fail.
not_square(x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% square(x) :- x is a perfect square
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
square(x) :-	square(x,x).
square(x,n) :-	is(_quotient x / n),
		is(_remainder x % n),
		=(n,_quotient),
		=(_remainder,0).

square(x,n) :-	>(n,0),
		is(_n1 n - 1),
		square(x,_n1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% range(n,m,list) :- list is a list of the integers between n and m inclusive
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
range(n,n,n).
range(_m,_n,_list) :-	tail(_tail,_list),
			is(_m1 _m + 1),
			range(_m1,_n,_ns),
			cons(_list,_m,_ns).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inner_product(x,y,_ip) :- ip is the inner product of the vectors x and y (i.e.,
%inner_product([1,2,3],[1,2,3]) = 1*1 + 2*2 + 3*3 = 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inner_product([],[],0).
inner_product(x,y,_ip) :-	head(_xhead,x),
				head(_yhead,y),
				tail(_xtail,x),
				tail(_ytail,y),
				inner_product(_xtail,_ytail,_ip1),
				is(_product _xhead * _yhead),
				is(_ip _product + _ip1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% factorial(n f) :- f is the factorial of n
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
factorial(n _f) :-	>(n 0),
			is(_n1 n - 1),
			factorial(_n1,_f1),
			is(_f n * _f1).
factorial(0 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ifactorial(n,f) :- f is the factorial of n -- this version uses iteration
% instead of recursion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifactorial(n _f)	ifactorial(0 n 1 _f).
ifactorial(_i n _t _f) :-	<(_i n),
				is(_i1 _i + 1),
				is(_t1 _t * _i1),
				ifactorial(_i1,n,_t1,_f).
ifactorial(n,n,_f,_f).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sumlist(list,sum) :- sum is the sum of the members of list list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sumlist(_list _sum) :-	head(_head _list),
			tail(_tail _list),
			sumlist(_tail _subsum),
			is(_sum _head + _subsum).
sumlist([] 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isumlist(list,sum) :- sum is the sum of the elements in list - this is an 
% iterative version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isumlist(_list _sum) :-		isumlist(_list 0 _sum).
isumlist(_list _temp _sum) :-	head(_head _list),
				tail(_tail _list),
				is(_temp1 _temp + _head),
				isumlist(_tail _temp1 _sum).
isumlist([] x x).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maximum(list max):- max is the largest member of the list list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maximum(_list _max)	:-	head(_head _list),
				tail(_tail _list),
				maximum(_tail _head _max).
maximum(_list _y _max)	:-	head(_head _list),
				tail(_tail _list),
				<=(_head _y),
				maximum(_tail _y _max).
maximum(_list _y _max)	:-	head(_head _list),
				tail(_tail _list),
				>(_head _y),
				maximum(_tail _head _max).
maximum([] _max _max).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% length(list,x) :- x is the number of elements in the list list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length([] 0).
length(_list n)	:-	tail(_tail _list),
			length(_tail _n1),
			is(n _n1 + 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% minimum(x,y,z) :- z is the lesser of x and y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minimum(x y x)	:-	!,<=(x y).
minimum(x y y)	:-	>(x y).

