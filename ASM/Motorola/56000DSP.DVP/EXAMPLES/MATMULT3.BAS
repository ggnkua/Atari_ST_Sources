'  Tutorial program MATMULT3.BAS supplied with DevpacDSP
'  (c) Copyright HiSoft 1993
'  All rights reserved
 
DEFINT a-z
REM	$NOFNSINLIBS
LIBRARY "falcon"
CONST n=4

DEFSNG a-c

DIM c(N-1,N-1),c1&(N-1,N*2-1)
abil=Dsp_RequestUniqueAbility

IF Dsp_lock THEN
		PRINT "DSP is already in use"
		STOP
END IF
IF Dsp_reserve(&h40+N*N,&h1000+N*N*2) THEN
	PRINT "Can't reserve enough DSP RAM"
	STOP
END IF

OPEN "matmult3.p56" FOR INPUT AS #1
progsize&=LOF(1)\3
buffer$=INPUT$(progsize&*3,#1)
CLOSE #1
'now run the program
'	progsize&=Dsp_LodToBinary&("MATMULT3.LOD",SADD(buffer$))
	Dsp_Execprog SADD(buffer$),progsize&,abil

' get the results back as unpacked long words
	Dsp_BlkUnpacked 0,0,VARPTR(c1&(0,0)),N*N*2
' now convert them to floating point
FOR i=0 TO N-1
	FOR j=0 TO N-1
	c(i,j)=c1&(i,j*2)*2+c1&(i,j*2+1)/&h800000
	NEXT j
NEXT i

Dsp_Unlock

showmat c()

SUB showmat(c(2))
FOR j= 0 TO N-1
	FOR i=0 TO N-1
		PRINT c(i,j),
	NEXT i
	PRINT
NEXT j
PRINT

END SUB
