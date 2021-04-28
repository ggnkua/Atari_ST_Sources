10    print"Testbspl.bas"
20    on error goto fehlerroutine
30    rem:Test for changing GOTO's and GOSUB's
40    print:rem:test for addition
50    ':test for change in REM's
60    print"***************"
70    print"test with variables a,b,x,y":input"x=";x
80    print x*x,x+x,sin(x),cos(sqr(abs(x)))
90    dim u1(10),u2(10),c(10,10):rem:test for field recognition
100   for i1=1 to 10
110   u1(i)=2*i:print u1(i):u(i)=sqr(u2(i))
120   for j=1 to 10
130   c(i,j)=u1(i)*u2(j)
140   print i,j,c(i,j):next:rem: Loop enlargement
150   next
160   anfang:print u1(1),u2(1),c(10,10)
170   rem: Jump destinations
180   if x<4 THEN print"x<4"
190   if x>4 THEN print"x<4 wrong ":a=2:print"multiple commands"
200   if x=4 then gosub  520
210   print"branching  ":if a<b THEN print"a<b":goto 180 ELSE print"old"
220   input q:rem: Jumping variables for menu
230   on q goto 320,850, marke1
240   on q gosub 300,860,testupro
250   on q GOSUB 860,520,unterprogramm
260   on Q GOTO 180,marke2,210
270   on q goto 370, 690,marke1,marke2
280   goto marke1:rem: Remarks    ...
290   rem: up follows
300   for i=1 to 10:y=a+i:next i
310   return
320   for j=1 to 3:rem: Destination for multiple jumps
330   for i=1 to 5:print i:next
340   rem: Loop test: Missing running variables
350   next
360   if a<5 then y=a+1
370   rem: Loop test: Destintion of multiple jumps
380   if 1<2 and a>4 THEN goto 210
390   b=2*a:print"xxxxx":rem:test for remarks
400   if a<0 then goto marke1
410   gosub 520:gosub 300
420   print"111111111111122222222222233333333";"4444555666";a;
430   print:print"New line  ":print"b,y=";b,y
440   print"Condition?"
450   if a<2 then if x=3 then print"1.condition" else print"2.condition"
460   print"a,x=";a,x
470   print"------abfrage---------"
480   print"aaaaabbbbbbbcccccdddddddeeeeex";"eeeeeyffffffggggggg"
490   marke1:
500   input"a,x=";a,x
510   print"Following the jump on marker 1":goto 550
520   rem:up-test
530   print"Long print...................................."
540   return
550   if a<5 then goto 380 else goto 570
560   print"end ":if 3<a then goto 190 else goto 380
570   print"Line 250"
580   print"Line 260"
590   print"Line 270":rem: Line number control
600   input"x-value=";x
610   if x>3 then goto marke1 else if x<2 then GOTO 570 else print "aaaaa"
620   if x<4 then if y=2 then goto 380:print"bbb"
630   print"Variable modification a,x,y"
640   if x=0 then gosub 300
650   goto marke2
660   rem:up-2
670   return
680   marke2:rem:marker
690   input"Change of variables at marker 2:a=";a
700   gosub unterprogramm
710   if x<a then goto 610 else goto 760
720   unterprogramm:
730   print"sub-program  "
740   rem
750   return
760   gosub 780
770   if a=1 or x=4 then goto 640 else GOTO 810
780   rem:Commands
790   print"Sub-program with GOSUB"
800   return
810   gosub 660
820   print"aaabbbbcccc:Clarification","bbbccc":rem: text
830   a=3:print"aaa:bbb:cccc":b=4
840   input"222:333:x=";x:if x=0 then print"end " else gosub unterprogramm
850   Rem: Destination of multiple jumps
860   rem:  from menu
870   return
880   testupro:
890   return
900   on Q goto  marke1,marke2, 570,370
910   on error goto 930
920   goto 960
930   print"Error "
940   if a=3 then resume 170
950   resume next
960   if a=2 then goto anfang else print"print at-Test"
970   rem:gotoxy-test
980   gotoxy 2,3:print"test"
990   print"Column 5,Line 7":GOTOXY 5,7
1000  GOTOXY 2,5:gotoxy 6,1
1010  rem: Loop variable test
1020  for k=1 to 10:print k
1030  for l=1 to 5 :print k,l
1040  for m=1 to 3:print k,l,m:next
1050  next:next k
1060  rem:test for erroneous GOTO's
1070  if k<10 then 1010
1080  if k=10 then 970:print"xxxxx"
1090  if k>10 then 760 else 960
1100  if l=5 then goto 1010 else 970:print"yyy"
1110  x=3:if m=2 then 380 else goto anfang:print
1120  xy=x+y*x1+yx:rem:test for variable identification
1130  print"xy,y=";xy,y:input"new xy=";xy
1140  print:x=x*x-asc(o$)+sin(y)+2*(x+log(abs(x1)+1))
1150  X=x+2*tan(k*y):if x<y then goto anfang
1160  fehlerroutine:
1170  if x<0 then resume 1000
1180  if x=0 then resume next
1190  if x>0 and x<5 then resume
1200  if x>10 then resume anfang else resume marke1
1210  'End of program
