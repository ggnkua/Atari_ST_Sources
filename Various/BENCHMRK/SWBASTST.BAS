10    rem test program for Softworks Basics
20    MAP1 tresult,F:MAP1 tymestart,B,4:MAP1 tymestop,B,4
25    MAP1 tymediff,B,4:MAP1 tpi,F:MAP1 mlt,F:MAP1 result,F 
30    MAP1 tyme,B
35    MAP1 dummy$,S,255:MAP1 xx$,S,255:MAP1 yy$,S,255
40    tyme=&h462 rem system timer location
50    Print Tab(-1,0):Open #2,"PRT:",Output
60    Print Tab(1,1);"SoftWorks BASIC Timing Test"
70    Print #2,"SoftWorks BASIC Timing Test"
100   rem compute the value of pi
110   tresult=1:tymestart=Long(tyme)
120   for loop=1 to 500
130   if int(loop/2)=loop/2 then mlt=1 else mlt=-1
140   tresult=tresult+mlt/(loop*2+1)
150   next loop
155   tpi=4*tresult
160   tymestop=Long(tyme):tymediff=tymestop-tymestart
170   Print Tab(2,1);"the computed value of pi is ";tpi
180   print "time necessary for pi calculation is "; tymediff
190   Print #2,"the computed value of pi is ";tpi
195   Print #2,"time necessary for pi calculation is ";tymediff
200   rem compute the sine function in a loop
210   tresult=0:tymestart=Long(tyme)
220   for loop=1 to 100
230   tresult=tresult+sin(loop)
240   next loop:tymestop=Long(tyme)
250   tymediff=tymestop-tymestart
260   Print Tab(4,1);"computed sum of sines is ";tresult
270   print "time necessary to calc sum of sines is ";tymediff
280   Print #2,"computed sum of sines is ";tresult
290   Print #2,"time necessary to calc sum of sines is ";tymediff
300   rem compute the sum of square roots
310   tresult=0:tymestart=Long(tyme)
320   for loop=1 to 100
330   tresult=tresult+sqr(loop)
340   next loop
350   tymestop=Long(tyme):tymediff=tymestop-tymestart
360   Print Tab(6,1);"sum of square roots is ";tresult
370   print "time necessary to sum square roots is ";tymediff
380   Print #2,"sum of square roots is ";tresult
390   Print #2,"time necessary to sum square roots is ";tymediff
400   rem count up using real numbers
410   result=0:tymestart=Long(tyme)
420   for loop=1 to 5000
430   result=result+1
440   next loop
450   tymestop=Long(tyme):tymediff=tymestop-tymestart
460   Print Tab(8,1);"time to count (real) to 5000 is ";tymediff
470   Print #2,"time to count (real) to 5000 is ";tymediff
500   rem count up using integers
510   result%=0:tymestart=Long(tyme)
520   for loop=1 to 5000
530   result%=result%+1
540   next loop
550   tymestop=Long(tyme):tymediff=tymestop-tymestart
560   Print Tab(9,1);"time to count (integer) to 5000 is ";tymediff
570   Print #2,"time to count (integer) to 5000 is ";tymediff
600   rem time to do some gosubbing
610   tymestart=Long(tyme)
620   for loop=1 to 1000
630   gosub 1000
640   next loop
650   tymestop=Long(tyme):tymediff=tymestop-tymestart
660   Print Tab(10,1);"time to gosub 1000 times is ";tymediff
670   Print #2, "time to gosub 1000 times is "; tymediff
700   rem some string handling music!!!
710   FOR loop=1 TO 255
720   dummy$[loop;1]="A"
730   next loop
740   tymestart=Long(tyme)
750   for loop=1 to 255
760   xx$[loop;1]=dummy$[loop;1]
770   yy$[loop;1]=dummy$[loop;1]
780   next loop
790   tymestop=Long(tyme):tymediff=tymestop-tymestart
800   Print Tab(11,1);"time to do 512 string manipulations is ";tymediff
810   Print #2,"time to do 512 string manipulations is ";tymediff
850   rem some disk access, just for fun
860   tymestart=Long(tyme)
870   open #1,"Test.dat",Output
880   for loop=1 to 1000
890   print #1,loop;
900   next loop:print #1,dummy$:print#1,dummy$
910   tymestop=Long(tyme):tymediff=tymestop-tymestart
920   Print Tab(12,1);"time to do disk access is ";tymediff
930   Print #2,"time to do disk access is ";tymediff
999   end
1000  rem a dummy subroutine
1010  return
