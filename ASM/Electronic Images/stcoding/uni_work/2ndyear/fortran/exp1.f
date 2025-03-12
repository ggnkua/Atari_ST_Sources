c	Scientific Computing Exercise 1
c	Martin Griffiths (CST 714)

c	Q(i). Single precision FORTRAN function to evaluate exp(x)
c	      using the exponential series :-

c		x^2   x^3               x^n	
c 	1 + x + --- + --- + ........... ---
c		 2!    3!                n!

	REAL FUNCTION EXPMY(X)
	REAL X,NSER,LASSUM,CURSUM,EPS
	INTEGER COUNT
	PARAMETER (EPS = 10.0 E-10)
	CURSUM = 1.0
	COUNT = 1
	NSER = 1.0
1	CONTINUE
		LASSUM = CURSUM
		NSER = (NSER * X) / COUNT
		CURSUM = CURSUM + NSER
		COUNT = COUNT + 1
	IF (ABS(LASSUM - CURSUM) .GE. EPS) GOTO 1
	EXPMY = CURSUM
	END

c	TEST Program - prints out exp(x) for x = -20 ... 20 

	PROGRAM TESTIT
	REAL X,EXPMY
	WRITE (*,*) "  x   |  FORTRAN77 EXP(x)   |   my EXP(x)"
	DO 2 , X = -20 , 20 , 1	
	WRITE (*,*) X, EXP(X), EXPMY(X)
2	CONTINUE
	END

