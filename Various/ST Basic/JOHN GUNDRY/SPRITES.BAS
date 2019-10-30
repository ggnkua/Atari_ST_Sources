10    REM           ****************************
20    REM           * ATARI BASIC SPRITES DEMO *
30    REM           * BY JOHN GUNDRY           *
40    REM           * 1-6-87                   *
50    REM           ****************************
60    REM * DIM INTEGER VARIABLES FOR SPRITE DEFINITION BLOCKS +
70    REM * DECLARE STRING VARIABLES TO HOLD M/C ROUTINES +
80    REM * DECLARE A FEW OTHER VARIABLES
86    REM * ALL REM STATEMENTS MAY BE OMITTED
87    REM
88    REM ******** DECLARE VARIABLES **************************************
89    REM
90    dim sp1%(170),sp2%(170) :sp1=varptr(sp1%(0)) :sp2=varptr(sp2%(0))
100   draw$=space$(30) :draw =varptr(draw$)
110   undraw$=space$(20) :undraw=varptr(undraw$)
120   point$=space$(34) :point=varptr(point$)
130   p%=255 :ptr=varptr(p%) :x=40 :y=80
140   fullw 2 :clearw 2 :poke 1155,252 :REM * KEYCLICK + REPEAT OFF
147   REM
148   REM ******** CHECK SCREEN RESOLUTION *******************************
149   REM
150   if peek(systab)<>4 then 580
157   REM
158   REM ******** POKE M/C DATA + SPRITE DATA INTO MEMORY ***************
159   REM
160   gosub mcode
167   REM
168   REM ******** DRAW A SIMPLE BACKGROUND ******************************
169   REM
170   gosub background
177   REM
178   REM ******** MAIN LOOP *********************************************
179   REM
180   call draw(x,y,sp1) :REM * DRAW SPRITE IN INITIAL POSITION
188   REM * &HFFFC02 = 8 BIT KEYBOARD ACIA DATA PORT
189   REM * JOYSTICK MOVEMENTS ARE ALSO RETURNED, BUT NOT FIRE BUTTON
190   key=int(peek(&hfffc02)/256) :REM * SCAN CODE OF PRESSED KEY
200   if key<>44 and key<>45 and key<>37 and key<>50 then 190
210   x=x+8*(key=44 and x>40)-8*(key=45 and x<264)
220   y=y+6*(key=37 and y>50)-6*(key=50 and y<164)
230   call undraw(sp1) :call point(x,y,ptr) :REM * COLOUR IN P%
240   if p%=1 then goto exitdemo :REM * SPRITE IN RED CIRCLE
250   call draw(x,y,sp1) :sound 1,8,4,6,1 :sound 1,0,0,0,0
260   for l=0 to 36 :temp%=sp1%(l) :sp1%(l)=sp2%(l)
270   sp2%(l)=temp% :next l :REM * SWAP SPRITES
280   goto 190 :REM * LOOP BACK FOR ANOTHER KEYPRESS
287   REM
288   REM ******** MCODE SUB ROUTINE *************************************
289   REM
290   mcode :
300   place=draw :num=14 :gosub enter   :REM * SELECT APPROPRIATE
310   restore 720                       :REM * BLOCK OF DATA
320   place=undraw :num=9 :gosub enter  :REM * STATEMENTS FOR EACH
330   restore 740                       :REM * ROUTINE.  PASS THE
340   place=point :num=16 :gosub enter  :REM * NUMBER OF DATA ITEMS
350   restore 770                       :REM * AND THE ADDRESS
360   place=sp1 :num=36 :gosub enter    :REM * WHERE THEY WILL BE
370   restore 820                       :REM * STORED TO THE ENTER
380   place=sp2 :num=36 :gosub enter    :REM * SUB ROUTINE FOR POKING.
390   return
397   REM
398   REM ******** ENTER SUB ROUTINE *************************************
399   REM
400   enter :
410   for l=0 to num :read h$
420   v=val("&h"+h$) :poke place+2*l,v :next l
430   return
437   REM
438   REM ******** BACKGROUND SUB ROUTINE ********************************
439   REM
440   background :
450   poke &hff8240,0 :REM * COLOUR REGISTER 0 TO BLACK ******************
460   color 1,6,5,21,2
470   linef 15,10,285,10 :linef 15,10,15,160
480   linef 285,10,285,160 :linef 15,160,285,160
490   linef 25,20,275,20 :linef 25,20,25,150
500   linef 275,20,275,150 :linef 25,150,275,150
510   color 1,11,3,12,2 :fill 20,20 :color 1,9,1,1,1 :fill 5,5
520   color 1,4,1,21,2 :pellipse 140,76,30,20
530   color 5,2,1,1,1 :pcircle 140,76,10
540   gotoxy 8,3 :?"USE KEYS Z-X-K-M"
550   gotoxy 8,4 :?"TO MOVE SPRITE"
560   gotoxy 4,12 :?"ENTER RED CIRCLE TO EXIT DEMO"
570   return
577   REM
578   REM ******** DISPLAY AN ALERT BOX **********************************
579   REM
580   sound 1,15,2,6,40 :sound 1,0,0,0,0
590   a#=gb :control=peek(a#) :global=peek(a#+4)
600   gintin=peek(a#+8) :gintout=peek(a#+12)
610   addrin=peek(a#+16) :addrout=peek(a#+20)
620   a$="[3][     SORRY!!   |  | THIS PROGRAM  | REQUIRES A  | LO-REZ"
630   a$=a$+" DISPLAY  ][  OK  ]"
640   a=varptr(a$) :a1=int(a/65536) :a2=a-(a1*65536)
650   poke addrin,a1 :poke addrin+2,a2 :poke gintin,1
660   gemsys(52) :poke 1155,255 :end
667   REM
668   REM ******** EXIT FROM DEMO ****************************************
669   REM
670   exitdemo :
680   poke &hff8240,&h777 :sound 1,0,0,0,0 :REM * BACKGROUND WHITE *******
690   poke 1155,255 :color 1,1 :end        :REM * CLICK + REPEAT ON ******
697   REM
698   REM ******** M/C DATA FOR DRAW ROUTINE *****************************
699   REM
700   data 2c0e,2a6f,0006,2015,222d,0004,206d,0008
710   data 2448,d5fc,0000,004a,a00d,2c46,4e75
717   REM
718   REM ******** M/C DATA FOR UNDRAW ROUTINE ***************************
719   REM
720   data 2c0e,246f,0006,2452,d5fc,0000,004a,a00c
730   data 2c46,4e75
737   REM
738   REM ******** M/C DATA FOR POINT ROUTINE ****************************
739   REM
740   data 2c0e,2c6f,0006,a000,2868,000c,38ae,0002
750   data 396e,0006,0002,a002,2c6e,0008,3c80,2c46
760   data 4e75
767   REM
768   REM ******** SP1 - SPRITE 1 DATA. (GOBBLER - MOUTH CLOSED) *********
769   REM
770   data 0008,0008,0000,000f,000c
780   data 0000,0000,0000,0000,0000,03c0,0000,0ff8
790   data 0000,3f3c,00c0,7f3e,00c0,7fff,0000,ff33
800   data 0000,ffcc,0000,7fff,0000,7ffe,0000,3ffc
810   data 0000,0ff8,0000,03c0,0000,0000,0000,0000
817   REM
818   REM ******** SP2 - SPRITE 2 DATA. (GOBBLER - MOUTH OPEN) ***********
819   REM
820   data 0008,0008,0000,000f,000c
830   data 0000,0000,0000,0000,0000,03c0,0000,0fe0
840   data 0300,3cf0,0300,7cc0,0000,7f80,0000,ff00
850   data 0000,ff00,0000,7f80,0000,7fc0,0000,3ff0
860   data 0000,0fe0,0000,03c0,0000,0000,0000,0000
868   REM
869   REM ****************************************************************

