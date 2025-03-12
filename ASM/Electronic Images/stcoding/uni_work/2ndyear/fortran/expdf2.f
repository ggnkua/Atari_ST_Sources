c	Scientific Computing Exercise 1
c	Martin Griffiths (CST 714)

c	Q(ii). Double precision FORTRAN function to evaluate exp(x)
c	       using the exponential series :-

c		x^2   x^3               x^n	
c 	1 + x + --- + --- + ........... ---
c		 2!    3!                n!

c 	Deals with negative argument to exp function by using the following
c	(in this way we do not lose any accuracy caused by cancellation)

c	   -x       1
c	  e    =   ---
c		     x
c		    e 

c 	- "Tidy" Version, that is in the pascal sense of the word! 

	DOUBLE PRECISION FUNCTION EXPAB (X)
	DOUBLE PRECISION X,NSER,LASSUM,CURSUM,EPS
	INTEGER COUNT
	PARAMETER (EPS = 10.0 E-10)
	CURSUM = 1D0
	COUNT = 1
	NSER = 1D0
1	CONTINUE
		LASSUM = CURSUM
		NSER = (NSER * X) / COUNT
		CURSUM = CURSUM + NSER
		COUNT = COUNT + 1
	IF (ABS(LASSUM - CURSUM) .GE. EPS) GOTO 1 
	EXPAB = CURSUM
	END

	DOUBLE PRECISION FUNCTION EXPMYD(X) 
	DOUBLE PRECISION X,EXPAB
	IF (X .LT. 0D0) THEN
		EXPMYD = 1D0/EXPAB(-X)
	ELSE
		EXPMYD = EXPAB(X)
	ENDIF
	END

c	TEST Program , print exp(X) for X=-20.. 20 
	
	PROGRAM TESTIT
	DOUBLE PRECISION X , EXPMYD
	WRITE (*,*) "     X     | FORTRAN77 EXP(x)   |   my EXP(x)"
	DO 2 , X = -20 ,20 , 1
	WRITE (*,*) X, EXP(X), EXPMYD(X)
2	CONTINUE
	END

