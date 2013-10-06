'  Tutorial program MATMULT1.BAS supplied with DevpacDSP
'  (c) Copyright HiSoft 1993
'  All rights reserved

DEFINT i-n
CONST n=4


SUB Mult(a(2),b(2),c(2))
FOR i=0 TO N-1
	FOR j=0 TO N-1
		FOR k=0 TO N-1
			c(i,j)=c(i,j)+a(k,j)*b(i,k)
		NEXT k
	NEXT j
NEXT i
END SUB

DIM a(N-1,N-1),b(N-1,N-1),c(N-1,N-1)

FOR i=0 TO N-1
	FOR j=0 TO N-1
		a(i,j)=RND
		b(i,j)=RND
	NEXT j
NEXT i

showmat a()
showmat b()

t=TIMER
Mult a(),b(),c()

showmat c()
PRINT TIMER-t
STOP -1

SUB showmat(c(2))
FOR j= 0 TO N-1
	FOR i=0 TO N-1
		PRINT c(i,j),
	NEXT i
	PRINT
NEXT j
PRINT

END SUB
