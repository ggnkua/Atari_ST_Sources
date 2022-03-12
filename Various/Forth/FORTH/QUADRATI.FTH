( Quadratic.fth)
( How to use local variables to create readable code. The following both
  could be used to solve for integer solutions of the quadratic equation.
  One is more readable.)

( method 1)
: quad1 ( a b c--x1 x2 )  2 pick * 4 *    over dup * swap -  sqrt
	swap negate 2dup +   3 pick 2* / >r
	swap - swap 2* / r> ;

( method 2)
: quad2	{ a b c | 2a radical -- x1 x2 }
	b b *
	4 a c * *   -
	sqrt -> radical
	a 2* -> 2a
	b negate radical -   2a /
	b negate radical +   2a / ;
