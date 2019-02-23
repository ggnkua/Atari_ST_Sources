10    rem test program for Atari Basics
20    defdbl t
30    rem
40    time=&h462 'system timer location
50    fullw 2:clearw 2
60    gotoxy 0,0:print "STBASIC Timing Test"
70    lprint "STBASIC Timing Test"
100   'compute the value of pi
110   tresult=1:Timestart=peek_L(time)
120   for loop=1 to 500
130   if int(loop/2)=loop/2 then mlt=1 else mlt=-1
140   tresult=tresult+mlt/(loop*2+1)
150   next loop
155   tpi=4*tresult
160   timestop=peek_L(time):timediff=timestop-timestart
170   gotoxy 0,1:print "the computed value of pi is ";tpi
180   print "time necessary for pi calculation is "; timediff
190   lprint "the computed value of pi is ";tpi
195   lprint "time necessary for pi calculation is ";timediff
200   'compute the sine function in a loop
210   tresult=0:timestart=peek_L(time)
220   for loop=1 to 100
230   tresult=tresult+sin(loop)
240   next loop:timestop=peek_L(time)
250   timediff=timestop-timestart
260   gotoxy 0,3:print "computed sum of sines is ";tresult
270   print "time necessary to calc sum of sines is ";timediff
280   lprint "computed sum of sines is ";tresult
290   lprint "time necessary to calc sum of sines is ";timediff
300   rem compute the sum of square roots
310   tresult=0:timestart=peek_L(time)
320   for loop=1 to 100
330   tresult=tresult+sqr(loop)
340   next loop
350   timestop=peek_L(time):timediff=timestop-timestart
360   gotoxy 0,5:print "sum of square roots is ";tresult
370   print "time necessary to sum square roots is ";timediff
380   lprint "sum of square roots is ";tresult
390   lprint "time necessary to sum square roots is ";timediff
400   rem count up using real numbers
410   result=0:timestart=peek_L(time)
420   for loop=1 to 5000
430   result=result+1
440   next loop
450   timestop=peek_L(time):timediff=timestop-timestart
460   gotoxy 0,7:print "time to count (real) to 5000 is ";timediff
470   lprint "time to count (real) to 5000 is ";timediff
500   rem count up using integers
510   result%=0:timestart=peek_L(time)
520   for loop=1 to 5000
530   result%=result%+1
540   next loop
550   timestop=peek_L(time):timediff=timestop-timestart
560   gotoxy 0,8:print "time to count (integer) to 5000 is ";timediff
570   lprint "time to count (integer) to 5000 is ";timediff
600   rem time to do some gosubbing
610   timestart=peek_L(time)
620   for loop=1 to 1000
630   gosub 1000
640   next loop
650   timestop=peek_L(time):timediff=timestop-timestart
660   gotoxy 0,9:print "time to gosub 1000 times is ";timediff
670   lprint "time to gosub 1000 times is "; timediff
700   rem some string handling music!!!
710   rem dim dummy$(255),xx$(255),yy$(255)
730   rem dummy$=string$(255,"A")
740   rem timestart=peek_L(time)
750   rem for loop=1 to 255
760   rem mid$(xx$,loop,1)=mid$(dummy$,loop,1)
765   rem balance of lines commented out because they crash Basic 2.0
770   rem mid$(yy$,loop,1)=mid$(dummy$,loop,1)
780   rem next loop
790   rem timestop=peek_L(time):timediff=timestop-timestart
800   rem gotoxy 0,10:print "time to do 512 string manipulations is ";timediff
810   rem lprint "time to do 512 string manipulations is ";timediff
850   rem some disk access, just for fun
860   rem timestart=peek_L(time)
870   rem open "O",#1,"Test.dat",128
880   rem for loop=1 to 1000
890   rem print #1,loop;
900   rem next loop:print #1,dummy$:print#1,dummy$
910   rem timestop=peek_L(time):timediff=timestop-timestart
920   rem gotoxy 0,11:print "time to do disk access is ";timediff
930   rem lprint "time to do disk access is ";timediff
999   end
1000  rem a dummy subroutine
1010  return
