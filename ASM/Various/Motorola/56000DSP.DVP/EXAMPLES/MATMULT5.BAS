'  Tutorial program MATMULT5.BAS supplied with DevpacDSP
'  (c) Copyright HiSoft 1993
'  All rights reserved
 
DEFINT a-z
REM	$NOFNSINLIBS
LIBRARY "falcon"
CONST n=4
	MulAbility=Dsp_RequestUniqueAbility
DEFSNG a-c

SUB InitMult
SHARED MultHandle,MulAbility
MultHandle=Dsp_InqSubrAbility(MulAbility)
	IF MultHandle=0 THEN
		OPEN "MATMULT5.B56" FOR INPUT AS #1
		a$=INPUT$(LOF(1),#1)
		MultHandle=Dsp_LoadSubroutine(SADD(a$),LOF(1)\3,MulAbility)
		IF Multhandle=0 THEN 
			PRINT "Can't load subroutine"
		END IF
	END IF
END SUB

SUB Mult(a(2),b(2),c(2))
SHARED MultHandle
InitMult
DIM a1&(N-1,N-1),b1&(N-1,N-1),c1&(N-1,N*2-1)
' First we need to convert the values to fixed point
FOR i=0 TO N-1
	FOR j=0 TO N-1
		a1&(i,j)=&h800000*a(i,j)
		b1&(i,j)=&h800000*b(i,j)
	NEXT j
NEXT i

	IF Dsp_RunSubroutine(Multhandle) THEN
		PRINT "Can't run subroutine"
		STOP
	END IF
Dsp_BlkUnpacked VARPTR(a1&(0,0)),N*N,0,0
Dsp_BlkUnpacked VARPTR(b1&(0,0)),N*N,0,0
' the c1& array should now contain pairs of integer and fractional parts

FOR i=0 TO N-1
	FOR j=0 TO N-1
		Dsp_BlkUnpacked 0,0,VARPTR(c1&(i,j*2)),2
		c(i,j)=c1&(i,j*2)*2+c1&(i,j*2+1)/&h800000
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

Mult a(),b(),c()

showmat c()
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
