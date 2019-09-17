**********************************
* ENGLISH TO NORWEGIAN DAYS      *
* 5 NOVEMBER 1997 BONFIRE NIGHT. *
**********************************
* THIS IS DEMOSTRATION OF HOW TO *
* ENTER A ENGLISH DAY TO A       *
* NORWEGIAN DAY. IT IS A SIMPLE  *
* PROGRAM BUT A LONG TIME IN     *
* THINKING HOW TO GET IT TO WORK *
* PROPERLY. I GIVE THIS PROGRAM  *
* FREELY AS IT MAYBE USEFUL TO   *
* SEE IF IT CAN BE DONE EASER.   *
*                                *
*                                *
*************       **************
            *.J.N.O.*
            *********   
start:   move.l   #centa,-(sp)   *POSITION OF FIRST MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #4,sp          *ADJUST THE STACK POSITION
in:      move.l   #engla,-(sp)   *TYPE IN THE WORD MONDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #6,sp          *ADJUST THE STACK POSITION
wait:    move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST THE STACK POSITION
out:     move.l   #norsk,-(sp)   *DISPLAY OF THE WORD MANDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS(HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
stay:    move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
starta:  move.l   #centb,-(sp)   *POSITION OF SECOND MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #4,sp          *ADJUST THE STACK POSITION
inb:     move.l   #englb,-(sp)   *TYPE IN THE WORD TUESDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #6,sp          *ADJUST THE STACK POSITION
waitb:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST THE STACK POSITION
outb:    move.l   #norskb,-(sp)   *DISPLAY OF THE WORD TIRSDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS(HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
stayb:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
restartb:move.l   #centc,-(sp)   *POSITION OF THIRD MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #4,sp          *ADJUST STACK POSITION
incb:    move.l   #englc,-(sp)   *TYPE IN THE WORD WEDNESDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
waitc:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
outc:    move.l   #norskc,-(sp)  *DISPLAY IN THE WORD ONSDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO IT'S ME)
         addq.l   #6,sp          *ADJUST STACK POSITION
stayc:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
startd:  move.l   #centd,-(sp)   *POSITION OF FORTH MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #4,sp          *ADJUST THE STACK POSITION
ind:     move.l   #engld,-(sp)   *TYPE IN THE WORD THURSDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #6,sp          *ADJUST THE STACK POSITION
waitd:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST THE STACK POSITION
outd:    move.l   #norskd,-(sp)   *DISPLAY OF THE WORD TORSDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS(HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
stayd:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
restarte:move.l   #cente,-(sp)   *POSITION OF FIFTH MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #4,sp          *ADJUST STACK POSITION
ine:     move.l   #engle,-(sp)   *TYPE IN THE WORD FRIDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
waite:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
oute:    move.l   #norske,-(sp)  *DISPLAY IN THE WORD FREDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO IT'S ME)
         addq.l   #6,sp          *ADJUST STACK POSITION
staye:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
startf:  move.l   #centf,-(sp)   *POSITION OF SIXTH MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #4,sp          *ADJUST THE STACK POSITION
inf:     move.l   #englf,-(sp)   *TYPE IN THE WORD SATURDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO)
         addq.l   #6,sp          *ADJUST THE STACK POSITION
waitf:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST THE STACK POSITION
outf:    move.l   #norskf,-(sp)   *DISPLAY OF THE WORD L0RDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS(HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
stayf:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
restartg:move.l   #centg,-(sp)   *POSITION OF SEVENTH MESSAGE SCREEN
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #4,sp          *ADJUST STACK POSITION
ing:     move.l   #englg,-(sp)   *TYPE IN THE WORD SUNDAY
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONRS
         trap     #1             *CALL GEMDOS (HELLO AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
waitg:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
outg:    move.l   #norskg,-(sp)  *DISPLAY IN THE WORD S0NDAG
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO IT'S ME)
         addq.l   #6,sp          *ADJUST STACK POSITION
stayg:   move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (HELLO WAIT A SECOND)
         addq.l   #2,sp          *ADJUST STACK POSITION
endmess: move.l   #endmes,-(sp)  *POSITION OF THE LAST MESSAGE
         move     #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO IT'S ME)
         addq.l   #4,sp          *ADJUST STACK POSITION
gdbye:   move.l   #typein,-(sp)  *TYPE IN THE WORD FINISHED
         move.w   #$a,-(sp)      *READ EDITED STRING FROM KEYBOARD,C-CONWS
         trap     #1             *CALL GEMDOS (HELLO IT'S YOU AGAIN)
         addq.l   #6,sp          *ADJUST STACK POSITION
stop:    move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS (YES WE KNOW ALO)
         addq.l   #2,sp          *ADJUST STACK POSITION
gdbyea:  move.l   #exit,-(sp)    *DISPLAY THE THANKYOU MESSAGE
         move.w   #9,-(sp)       *WRITE STRING TO SCREEN,C-CONWS
         trap     #1             *CALL GEMDOS (SUPRISE ME HELLO IS IT)
         addq.l   #6,sp          *ADJUST STACK POSITION
hold:    move     #2,-(sp)       *WAIT FOR KEYPRESS
         move     #2,-(sp)       *READ A CHARACTER FROM A DEVICE,BCONIN
         trap     #13            *CALL BIOS ( GUESS WHAT? YES CORRECT)
         addq.l   #2,sp          *ADJUST STACK POSITION
end:     move.w   #20,-(sp)      *TIME TO LEAVE NOW
         move.w   #$4c,-(sp)     *TERMINATE PROGRAM,P-TERM
         trap     #1             *CALL GEMDOS ( THANK GOODNESS BYE)
         addq.l   #4,sp          *ADJUST STACK POSITION
centa:   dc.b     $1b,'Y....[Norsk Translator]...',45,35,0
centb:   dc.b     $1b,'Y....[Norsk Translator]....',45,35,0
centc:   dc.b     $1b,'Y....[Norsk Translator].....',45,35,0
centd:   dc.b     $1b,'Y....[Norsk Translator]......',45,35,0
cente:   dc.b     $1b,'Y....[Norsk Translator]........',45,35,0
centf:   dc.b     $1b,'Y....[Norsk Translator].........',45,35,0
centg:   dc.b     $1b,'Y....[Norsk Translator]...........',45,35,0
endmes:  dc.b     $1b,'Y....[Please Type Finished......',45,35,0

engla:   dc.b     '....monday.',0
norsk:   dc.b     '....MANDAG.',0
englb:   dc.b     '....tuesday.',0
norskb:  dc.b     '.....TIRSDAG.',0
englc:   dc.b     '....wednesday.',0
norskc:  dc.b     '......ONSDAG.',0
engld:   dc.b     '.....thursday.',0
norskd:  dc.b     '.....TORSDAG.',0
engle:   dc.b     '.......friday.',0
norske:  dc.b     '.....FREDAG.',0
englf:   dc.b     '.....saturday.',0
norskf:  dc.b     '......L0RDAG.',0
englg:   dc.b     '........sunday.',0
norskg:  dc.b     '.....S0NDAG.',0
typein:  dc.b     '......________.',0
exit:    dc.b     '......thankyou for trying this..PLEASE PRESS RETURN....',0
         end