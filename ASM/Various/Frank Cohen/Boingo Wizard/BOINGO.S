
* Boingo Wizard
* by Frank Cohen & William Robinson
* Copyright 1989 Antic Publishing

* Started December 22, 1988
* Version History
* 042389 My 28th Birthday
* 050489 Getting pressured to finish game
* 050989 Took day off to do interview on Starship Enterprise
* 051289 William makes the game work, thank God.
* 051989 "So how's the game coming?" asks Tom Byron
* 052189 Almost done!  Just have to keep it from crashing...
* 052289 Done [Thank God], and uploaded to Gregg at START 76703,1052
* 052389 Last minute tweeking, and complete. Enjoy!
* 070989 Heidi and I get into conceptual argument, after
*        arguing for hours, I add the duck wrap-around feature, it
*        doesn't work, so I take it out.

*----------Game Play Values----------*

WORMY_START_X EQU 792
WORMY_START_Y EQU 36

PLAYER_START_X1 EQU 776
PLAYER_START_X2 EQU 808

CELL_HEIGHT EQU 31
CELL_SIZE EQU CELL_HEIGHT*16
CELL_COUNT EQU 8

CLIP_TOP EQU CELL_HEIGHT
CLIP_SET EQU 1760    ;(Cell_height-21)*160
CLIP_BOTTOM EQU 200

SCORE_POS EQU 1288
SCORE_L EQU 1320
SCORE_MEN EQU 1416
SCORE_OVER EQU 1392

SCORE_DISC EQU 150
SCORE_PAD EQU 25
SCORE_LEVEL EQU 450

numberofscreens = 5 ; how many screens for page flipping

*----------Cold Entry Point---------*

START DC $A00A

 jsr _logbase
 move.l d0,screenh  *  address of highest screen
 move.l d0,screenpt ; address of current screen
 sub.l #numberofscreens*32000-32000,d0
 move.l d0,screenl  *  address of lowest screen
 sub.l #100,d0
 move.l d0,savea7  *  move stack to under lowest screen
 move.l d0,a7

 MOVE #2,-(A7)  ;GET PHYSICAL ADDRESS OF VIDEO RAM
 TRAP #14
 ADD.L #2,A7
 MOVE.L D0,OLDSCREEN

 MOVE #4,-(A7) ;GETREZ
 TRAP #14
 ADD.L #2,A7
 MOVE D0,OLD_REZ

 CMP #2,D0
 BNE NO_HIGH_REZ

 MOVE.L #HIGH_REZ_MES,-(A7)
 MOVE #9,-(A7)
 TRAP #1
 ADD.L #6,A7

 MOVE #500,D0
DEL1 MOVE #5000,D1
DEL2 TST.L D1
 DBF D1,DEL2
 DBF D0,DEL1

 CLR -(A7)
 TRAP #1

HIGH_REZ_MES DC.B 27,'E'
 DC.B 'Thus spake the master programmer:',13,10
 DC.B '  Without the wind, the grass does',13,10
 DC.B '  does not move.  Without software,',13,10
 DC.B '  hardware is useless.',13,10
 DC.B 13,10
 DC.B 'Thus spake the master games tester:',13,10
 DC.B '  Boingo will only play on a color monitor.',13,10,0
 EVEN

NO_HIGH_REZ CLR -(A7)  ;FORCE LOW REZ
 MOVE.L #-1,-(A7)
 MOVE.L #-1,-(A7)
 MOVE #5,-(A7)
 TRAP #14
 ADD.L #10,A7

 LEA OLD_COLORS,A4
 CLR COUNTER
SAVECLRS MOVE #-1,-(A7) ;SETCOLOR
 MOVE COUNTER,-(A7)
 MOVE #7,-(A7)
 TRAP #14
 ADD.L #6,A7
 MOVE D0,(A4)+
 ADD #1,COUNTER
 CMP #16,COUNTER
 BNE SAVECLRS

* Thus spake the master programmer:
* "When you have larned to snatch the error code from the
*  trap frame, it will be time for you to leave."

*---------------LOAD DATA FROM FILES---------------*

 LEA HLP_COLORS,A2
 LEA HELPDATA,A1
 LEA FNAME5,A0
 JSR LOADFILE

 LEA TTL_COLORS,A2
 LEA TITLEDATA,A1
 LEA FNAME4,A0
 JSR LOADFILE

 LEA COLORS,A2
 LEA SCOREDATA,A1
 LEA FNAME3,A0
 JSR LOADFILE

 LEA COLORS,A2
 LEA PLAYIMAGE,A1
 LEA FNAME2,A0
 JSR LOADFILE

 LEA REAL_COLORS,A2
 LEA OPPONENTS,A1
 LEA FNAME1,A0
 JSR LOADFILE

 move.l #instblok,INSTADD
 lea ID,a0 ; init sound effect driver
 jsr super

 lea gi_308,a0  *  set vblank pointer to my code
 jsr super

*---------------GAME INIT----------------*

 JSR INIT_CELLS
 JSR INIT_MOVEMENT

*----------Title Screen----------*

TITLEIT CLR PAUSE_FLAG

 LEA TITLEDATA,A0
 MOVE.L screenh,A1
 JSR movescreen
 MOVE.L screenh,screenpt

 LEA TTL_COLORS,A0
 LEA COLORS,A1
 MOVE #15,D0
SC1 MOVE (A0)+,(A1)+
 DBF D0,SC1

TITLE_LOOP MOVE #11,-(A7)  ;Key pressed?
 TRAP #1
 ADD #2,A7
 TST D0
 BEQ TITLE_LOOP

 JSR WAIT_KEY
 MOVE.L D0,D1
 SWAP D1
 CMP.B #$62,D1
 BEQ HELP_SCREEN
 CMP.B #97,D1
 BEQ QUIT
 JMP PLAYGAME

*----------Help Screen----------*

HELP_SCREEN LEA HELPDATA,A0
 MOVE.L screenh,A1
 JSR movescreen
 MOVE.L screenh,screenpt

 LEA HLP_COLORS,A0
 LEA COLORS,A1
 MOVE #15,D0
HSC1 MOVE (A0)+,(A1)+
 DBF D0,HSC1

HELP_LOOP MOVE #11,-(A7)  ;Key pressed?
 TRAP #1
 ADD #2,A7
 TST D0
 BEQ HELP_LOOP

 JSR WAIT_KEY
 MOVE.L D0,D1
 SWAP D1
 CMP.B #97,D1
 BEQ QUIT

*---------------Start A Game----------------*

* Something mysterious is formed, born in the silent void.
* Waiting alone and unmoving, it is at once still
* and yet in constant motion.  It is the source of all
* programs.  I do not know its name, so I will call
* it the Tao of Programming.

PLAYGAME CLR LEVEL
 CLR.L POINTS
 CLR.L BONUS
 MOVE #3,LIVES

*---------------Start A Round----------------*

PLAYROUND LEA PLAYIMAGE,A0
 LEA PLAYFIELD,A1
 JSR movescreen

 LEA REAL_COLORS,A0
 LEA COLORS,A1
 MOVE #15,D0
SC2 MOVE (A0)+,(A1)+
 DBF D0,SC2

 CLR FLOATING
 CLR FLOATING2
 MOVE #45,SQUARE_COUNT
 CLR QUIT_FLAG

 CLR.L D0
 JSR SCORED

 JSR INIT_PLAYERS

 MOVE #99,D0
 LEA GRID,A0
PI_101 CLR.B (A0)+
 DBF D0,PI_101

 JSR DISC_PLOT
 JSR RUN_OUT_KEYBOARD

*--------------MAIN LOOP---------------*

MAINLOOP TST QUIT_FLAG
 BNE QUIT
 TST SQUARE_COUNT
 BEQ END_OF_ROUND

 jsr findscreenn
 lea playfield,a0
 move.l screenn,a1
 jsr movescreen

 LEA PLAYER_INFO,A0
 CMP #2,DEAD(A0)
 BEQ DEATH

 JSR MOVE_MEN
 JSR MOVE_MEN
 JSR COLLIDE
 JSR WORMY_CONTROL
 JSR PLOT_PLAYERS
 move.l screenn,screenpt
 JMP MAINLOOP

*----------Death Comes To All----------*

* If the Tao is great, then the operating system is great.
* If the operating system is great, then the assembler is
* great.  If the assembler is great, then the application is
* great.  The user is pleased and there is harmony in the world.

DEATH jsr deathsoundon

 SUB #1,LIVES
 CLR.L D0
 JSR SCORED

 TST LIVES
 BPL DE_102

 LEA SCOREDATA+14080,A0
 lea playfield,a1
 ADD #SCORE_OVER,A1

 MOVE #7,D2
DE_101 MOVE.L (A0),(A1)
 MOVE.L 4(A0),4(A1)
 MOVE.L 8(A0),8(A1)
 MOVE.L 12(A0),12(A1)
 MOVE.L 16(A0),16(A1)
 MOVE.L 20(A0),20(A1)
 MOVE.L 24(A0),24(A1)
 MOVE.L 28(A0),28(A1)
 MOVE.L 32(A0),32(A1)
 MOVE.L 36(A0),36(A1)
 ADD #160,A0
 ADD #160,A1
 DBF D2,DE_101

DE_102 MOVE #160,EOR_VAL
 MOVE COLORS+14,-(A7)

DE_100 jsr findscreenn
 lea playfield,a0
 move.l screenn,a1
 jsr movescreen
 JSR PLOT_PLAYERS
 move.l screenn,screenpt

 EOR #-1,COLORS+14

 SUB #1,EOR_VAL
 TST EOR_VAL
 BNE DE_100

 MOVE (A7)+,COLORS+14

 jsr deathsoundoff
 JSR INIT_PLAYERS
 JSR RUN_OUT_KEYBOARD

 TST LIVES
 BPL MAINLOOP
 JMP TITLEIT

*----------Collision Detect----------*

* The Tao of Programming flows far away
* and returns on the wind of morning.

COLLIDE TST FLOATING
 BNE COL_END
 TST FLOATING2
 BNE COL_END

 LEA PLAYER_INFO,A4
 MOVE GRIDY(A4),D0
 MOVE GRIDX(A4),D1
 MOVE YPOS(A4),D4
 ADD #6,D4
 MOVE XPOS(A4),D5
 ADD #2,D5

 MOVE #PLAYER_MAX-3,D2
COL_100 ADD.L #PLAYER_SIZE,A4

 TST ACTIVE(A4)
 BEQ COL_RCRS
 TST BIRTH(A4)
 BNE COL_RCRS
 TST DEAD(A4)
 BNE COL_RCRS

 TST GRIDX(A4)
 BNE KILL_100
 TST GRIDY(A4)
 BEQ COL_RCRS

KILL_100 CMP GRIDY(A4),D0
 BNE COL_RCRS
 CMP GRIDX(A4),D1
 BNE COL_RCRS

 MOVE YPOS(A4),D3
 CMP D3,D4
 BLT COL_RCRS
 ADD #10,D3
 CMP D3,D4
 BGT COL_RCRS

 MOVE XPOS(A4),D3
 CMP D3,D5
 BLT COL_RCRS
 ADD #4,D3
 CMP D3,D5
 BGT COL_RCRS

 LEA PLAYER_INFO,A4
 MOVE #2,DEAD(A4)
 RTS

COL_RCRS DBF D2,COL_100
COL_END RTS

*----------Next Level----------*

END_OF_ROUND MOVE COLORS+14,-(A7)
 MOVE #SCORE_LEVEL,EOR_VAL

EOR_100 jsr findscreenn
 lea playfield,a0
 move.l screenn,a1
 jsr movescreen
 JSR PLOT_PLAYERS
 move.l screenn,screenpt

 MOVE EOR_VAL,D0
 AND #$F,D0
 BNE EOR_101
 EOR #$FFFF,COLORS+14

EOR_101 MOVE #3,D0
 JSR SCORED

 SUB #3,EOR_VAL
 TST EOR_VAL
 BPL EOR_100

 MOVE (A7)+,COLORS+14

* The Tao gave birth to machine language, which gave birth to
* the assembler.  The assembler gave birth to the compiler.
* Now there are ten thousand languages.

* Each language has its purpose, however humble.  Each language
* expresses the yin and yang of software.  Each language
* has its place within the Tao.

* But do not program in Cobol if you can avoid it.

 JSR INIT_OPPONENTS

 MOVE #140,EOR_VAL

EOR_200 jsr findscreenn
 lea playfield,a0
 move.l screenn,a1
 jsr movescreen
 JSR PLOT_PLAYERS
 move.l screenn,screenpt

 SUB #1,EOR_VAL
 TST EOR_VAL
 BPL EOR_200

 ADD #1,LEVEL
 CLR D0
 JSR SCORED

 JMP PLAYROUND

EOR_VAL DS 1

*----------Wormy Movement----------*

WORMY_CONTROL MOVE #11,-(A7)  ;Key pressed?
 TRAP #1
 ADD #2,A7
 TST D0
 BEQ MW_RETURN

 JSR WAIT_KEY
 MOVE.L D0,D1
 SWAP D1
 CMP.B #97,D1
 BEQ MW_ENDIT
 CMP.B #27,D0
 BEQ MW_PAUSE
 CMP.B #'A',D0
 BEQ MW_LEVEL
 CMP.B #'a',D0
 BEQ MW_LEVEL

 CLR.L D2
 CMP.B #49,D0
 BEQ MW_DOJUMP
 ADD #1,D2
 CMP.B #50,D0
 BEQ MW_DOJUMP
 ADD #1,D2
 CMP.B #53,D0
 BEQ MW_DOJUMP
 ADD #1,D2
 CMP.B #52,D0
 BNE MW_RETURN

MW_DOJUMP TST FLOATING
 BNE MW_RETURN
 LEA PLAYER_INFO,A4
 TST STATUS(A4)
 BNE MW_RETURN

 jsr soundeffectstart ; move "bounce"
 dc 97,100,2,6,2
 MOVE D2,ANIMATE(A4)
 MOVE #1,TIME(A4)
 MOVE #1,STATUS(A4)
 CLR STRETCH(A4)

 MULU #4,D2
 ADD.L #GRIDMOVE,D2
 MOVE.L D2,A0
 MOVE GRIDY(A4),D0
 ADD (A0),D0
 MOVE D0,GRIDY(A4)
 MOVE GRIDX(A4),D0
 ADD 2(A0),D0
 MOVE D0,GRIDX(A4)
 RTS

MW_LEVEL CLR SQUARE_COUNT
 RTS

MW_ENDIT MOVE #1,QUIT_FLAG
 RTS

MW_PAUSE MOVE #1,PAUSE_FLAG
 JSR WAIT_KEY   ;Pause mode
 CMP.B #27,D0
 BNE MW_PAUSE
 CLR PAUSE_FLAG

MW_RETURN RTS

PAUSE_FLAG DC 0

GRIDMOVE
 DC 1,0
 DC 0,1
 DC -1,0
 DC 0,-1

RUN_OUT_KEYBOARD MOVE #11,-(A7)  ;Key pressed?
 TRAP #1
 ADD #2,A7
 TST D0
 BEQ RUN_OUT2
 JSR WAIT_KEY
 MOVE.L D0,D1
 SWAP D1
 CMP.B #97,D1
 BEQ MW_ENDIT
 CMP.B #27,D0
 BEQ MW_PAUSE
 JMP RUN_OUT_KEYBOARD

RUN_OUT2 RTS

*----------Move Players----------*

XPOS EQU 0
YPOS EQU 2
ANIMATE EQU 4  ;0-DOWN 1-RIGHT 2-UP 3-LEFT
SPEED EQU 6
TIME EQU 8
STATUS EQU 10
STRETCH EQU 12
GRIDX EQU 14
GRIDY EQU 16
TYPE EQU 18   ;0-Wormy 1-Snake 2-Shades 3-Eraser
PRIORITY EQU 20
DEAD EQU 22
BIRTH EQU 24
ACTIVE EQU 26
WAITING EQU 28

PLAYER_SIZE EQU 30
PLAYER_MAX EQU 12

MOVE_MEN LEA PLAYER_INFO,A4
 CLR COUNTER

 TST FLOATING2
 BNE MWF_DOWN
 TST FLOATING
 BEQ MV_LOOP

 MOVE TIME(A4),D0
 ADD SPEED(A4),D0
 MOVE D0,TIME(A4)
 CMP #100,D0
 BLT MV_RCRS
 SUB #100,TIME(A4)

 ADD #1,FLOATING
 MOVE FLOATING,D0
 AND #3,D0
 TST D0
 BEQ MWF_OVER
 SUB #1,YPOS(A4)
MWF_OVER TST ANIMATE(A4)
 BEQ MWF_LEFT
 SUB #1,XPOS(A4)
 JMP MVF_CHECK
MWF_LEFT ADD #1,XPOS(A4)

MVF_CHECK CMP #WORMY_START_X,XPOS(A4)
 BNE MV_RCRS
 MOVE #1,FLOATING2
 JSR INIT_OPPONENTS
 MOVE #SCORE_DISC,D0
 JMP SCORED

MWF_DOWN ADD #1,YPOS(A4)
 CMP #WORMY_START_Y,YPOS(A4)
 BNE MV_RCRS
 jsr soundeffectstop
 dc 3
 CLR FLOATING
 CLR FLOATING2
 JSR RUN_OUT_KEYBOARD
 JMP MV_RCRS

*---Move Opponents---*

MV_LOOP TST ACTIVE(A4)
 BEQ MV_RCRS

 TST WAITING(A4)
 BEQ MV_IT_NOW
 SUB #1,WAITING(A4)
 JMP MV_RCRS

MV_IT_NOW MOVE TIME(A4),D0
 ADD SPEED(A4),D0
 MOVE D0,TIME(A4)
 CMP #100,D0
 BLT MV_RCRS
 SUB #100,TIME(A4)

 TST DEAD(A4)
 BNE PLAYER_FALLS
 TST BIRTH(A4)
 BNE MV_ALIVE
 TST STATUS(A4)
 BNE MV_JUMPING

 TST COUNTER  ;Direct Opponents
 BEQ MV_RCRS
 CMP #1,TYPE(A4)
 BEQ MV_SNAKE

;Shades movement logic

 MOVE #1,STATUS(A4)
 CLR STRETCH(A4)
 MOVE #10,TIME(A4)

 jsr _random
 dc 10
 move random,d2
 AND.L #1,D2
 MOVE D2,ANIMATE(A4)

 JSR EDGE_DETECT
 MOVE D0,DEAD(A4)
 BNE MV_RCRS

 MULU #4,D2
 ADD.L #GRIDMOVE,D2
 MOVE.L D2,A0
 CLR.L D0
 MOVE GRIDY(A4),D0
 ADD (A0),D0
 MOVE D0,GRIDY(A4)
 MOVE GRIDX(A4),D0
 ADD 2(A0),D0
 MOVE D0,GRIDX(A4)
 JMP MV_RCRS

;Snake movement logic

MV_SNAKE MOVE #1,STATUS(A4)
 CLR STRETCH(A4)
 MOVE #10,TIME(A4)

 MOVE GRIDX(A4),D4
 MOVE GRIDY(A4),D5

 CLR.L D2
 TST FLOATING
 BEQ MV_SNAKE99
 jsr _random
 dc 4
 move random,d2
 JMP MV_SNAKE101

MV_SNAKE99 LEA PLAYER_INFO,A0
 MOVE #3,D2
 MOVE GRIDX(A0),D0
 CMP GRIDX(A4),D0
 BEQ MV_SNAKE100
 BLT MV_SNAKE101
 MOVE #1,D2
 JMP MV_SNAKE101

MV_SNAKE100 MOVE #2,D2
 MOVE GRIDY(A0),D0
 CMP GRIDY(A4),D0
 BLT MV_SNAKE101
 CLR D2

MV_SNAKE101 MOVE D2,ANIMATE(A4)
 MOVE D4,GRIDX(A4)
 MOVE D5,GRIDY(A4)

 MOVE.L D2,D3
 MULU #4,D3
 ADD.L #GRIDMOVE,D3
 MOVE.L D3,A0
 CLR.L D0
 MOVE GRIDY(A4),D0
 ADD (A0),D0
 MOVE D0,GRIDY(A4)
 MOVE GRIDX(A4),D0
 ADD 2(A0),D0
 MOVE D0,GRIDX(A4)
 JSR EDGE_DETECT
 CLR PRIORITY(A4)
 TST D0
 BEQ MV_RCRS

 ADD #1,D2
 AND.L #3,D2
 JMP MV_SNAKE101

* Player jumps through the air, with the greatest of ease.

MV_JUMPING ADD #1,STATUS(A4)

 CLR.L D6
 MOVE ANIMATE(A4),D6
 MULU #MOVEMENT3-MOVEMENT,D6
 ADD.L #MOVETBL,D6
 MOVE.L D6,A0
 CLR.L D0
 MOVE STATUS(A4),D0
 SUB #2,D0
 MULU #6,D0
 ADD.L D0,A0
 CMP #99,(A0)
 BEQ MV_HIT

 CLR.L D0
 MOVE YPOS(A4),D0
 ADD (A0),D0
 MOVE D0,YPOS(A4)

 CLR.L D0
 MOVE XPOS(A4),D0
 ADD 2(A0),D0
 MOVE D0,XPOS(A4)

 CLR.L D0
 MOVE STRETCH(A4),D0
 ADD 4(A0),D0
 MOVE D0,STRETCH(A4)
 JMP MV_RCRS

* Player lands?

MV_HIT CLR STATUS(A4)  ;Jump onto a floating disc?
 CLR STRETCH(A4)
 CLR WAITING(A4)

 MOVE TYPE(A4),D0      ;Did Wormy or Eraser land on a tile?
 BEQ MV_CHECK_TILE
 CMP #3,D0
 BNE MV_RCRS

MV_CHECK_TILE MOVE.L DISC_ADR,A0  ;Did Wormy land on a disc?
 MOVE #3,D1
MV_HIT2 TST.L (A0)
 BEQ MV_HIT3
 MOVE GRIDX(A4),D0
 CMP 2(A0),D0
 BNE MV_HIT3
 MOVE GRIDY(A4),D0
 CMP (A0),D0
 BEQ MV_FLOAT
MV_HIT3 ADD.L #4,A0
 DBF D1,MV_HIT2

 JSR EDGE_DETECT  ;Nope, landed on a regular tile.
 MOVE D0,DEAD(A4)
 TST D0
 BNE MV_FELL
 JSR FILL_SQUARE
 JMP MV_RCRS

MV_FELL TST COUNTER  ;Fell of side of grid
 BNE MV_RCRS
 jsr soundeffectstart
 dc 111,127,1,6,1
 JMP MV_RCRS

MV_FLOAT JSR DISC_REMOVE  ;Set up variables to float Wormy to top of grid
 LEA PLAYER_INFO,A4
 jsr soundeffectstart
 dc 72,120,3,6,3
 MOVE #1,FLOATING
 CLR FLOATING2
 MOVE #1,TIME(A4)
 CLR STRETCH(A4)
 MOVE #1,GRIDX(A4)
 MOVE #1,GRIDY(A4)
 MOVE #1,D0
 CMP #3,ANIMATE(A4)
 BNE MM_F100
 CLR D0
MM_F100 MOVE D0,ANIMATE(A4)

MV_RCRS ADD.L #PLAYER_SIZE,A4
 ADD #1,COUNTER
 CMP #PLAYER_MAX,COUNTER
 BNE MV_LOOP

MV_END RTS

* Player falls off grid

PLAYER_FALLS CLR GRIDX(A4)
 CLR GRIDY(A4)

 ADD #1,YPOS(A4)
 CMP #CLIP_BOTTOM+CELL_HEIGHT,YPOS(A4)
 BNE MV_RCRS
 MOVE #2,DEAD(A4)
 CLR ACTIVE(A4)

 TST COUNTER
 BEQ MV_RCRS

 jsr _random
 dc 60000
 move random,d0
 MOVE D0,D2
 MOVE D2,D3
 MOVE #PLAYER_START_X1,D1
 MOVE #1,GRIDX(A4)
 MOVE #2,GRIDY(A4)
 AND #1,D0
 BEQ MV_PI_200
 MOVE #PLAYER_START_X2,D1
 MOVE #2,GRIDX(A4)
 MOVE #1,GRIDY(A4)

MV_PI_200 MOVE D1,XPOS(A4)
 MOVE #1,YPOS(A4)
 MOVE #1,PRIORITY(A4)
 MOVE #15*60,WAITING(A4)
 MOVE #1,BIRTH(A4)
 MOVE #1,ACTIVE(A4)
 CLR DEAD(A4)
 CLR STATUS(A4)
 JMP MV_RCRS

MV_ALIVE CMP #1,YPOS(A4)    ;Fall from sky onto screen
 BNE MV_ALIVE3
 jsr soundeffectstart
 dc 93,100,0,6,0

MV_ALIVE3 ADD #1,YPOS(A4)
 CMP #CLIP_TOP,YPOS(A4)
 BEQ MV_ALIVE2
 CMP #49,YPOS(A4)
 BNE MV_RCRS
 CLR BIRTH(A4)
 CMP #3,TYPE(A4)
 BNE MV_RCRS
 JSR FILL_SQUARE
 JMP MV_RCRS
MV_ALIVE2 CLR PRIORITY(A4)
 JMP MV_RCRS

*----------Fall Off Side----------*

EDGE_DETECT TST GRIDX(A4)
 BMI EDGE_YES
 BEQ EDGE_YES
 TST GRIDY(A4)
 BMI EDGE_YES
 BEQ EDGE_YES

 MOVE #10,D0
 SUB GRIDY(A4),D0
 CMP GRIDX(A4),D0
 BGE EDGE_NO
 CLR PRIORITY(A4)
 MOVE #1,D0
 RTS

EDGE_YES MOVE #1,PRIORITY(A4)
 MOVE #1,D0
 RTS

EDGE_NO CLR D0
 RTS

*----------Install Movement Tables---------*

* A novice asked the master: "Here is a programmer who
* never designs, documents, or tests his programs.  Yet
* all who know him consider him one of the best programmers
* in the world.  Why is this?"

* The master replied: "That programmer has mastered the Tao.
* He has gone beyond the need for design;  he does not
* become angry when the system crashes, but accepts the universe
* without concern.  He has gone beyond the need for documentation;
* he no longer cares if anyone sees his code.  He has gone beyond
* the need for testing;  each of his programs are perfect within
* themselves, serene and elegant, their purpose self-evident.

* "Truly, he has entered the mystery of Tao."

INIT_MOVEMENT LEA MOVETBL,A1

 LEA MOVEMENT,A0
 MOVE #1,D0
 MOVE #1,D1
 MOVE.L #6,D3
 JSR IM_100

 LEA MOVEMENT,A0
 MOVE #1,D0
 MOVE #-1,D1
 MOVE.L #6,D3
 JSR IM_100

 LEA MOVEMENT2,A0
 MOVE #-1,D0
 MOVE #-1,D1
 MOVE.L #-6,D3
 JSR IM_100

 LEA MOVEMENT2,A0
 MOVE #-1,D0
 MOVE #1,D1
 MOVE.L #-6,D3

IM_100 MOVE (A0),(A1)
 CMP #99,(A0)
 BEQ IM_101

 MOVE (A0),D2
 MULS D0,D2
 MOVE D2,(A1)

IM_101 MOVE 2(A0),D2
 MULS D1,D2
 MOVE D2,2(A1)

 MOVE 4(A0),4(A1)

 CMP #99,(A0)
 BEQ IM_END
 ADD.L D3,A0
 ADD #6,A1
 JMP IM_100

IM_END ADD #6,A1
 RTS

 DC 99,0,0 ;END MARKER
MOVEMENT
 DC -1,0,0
 DC -1,0,0
 DC -1,-1,0
 DC -1,0,0
 DC -1,-1,0
 DC -1,-1,0
 DC -1,-1,0
 DC -1,-1,0
 DC 0,-1,0
 DC -1,0,0
 DC 0,-1,1
 DC 0,-1,0
 DC 1,-1,0
 DC 0,-1,0
 DC 1,-1,0
 DC 0,-1,0
 DC 1,0,0
 DC 1,-1,0
 DC 1,0,0
 DC 1,-1,0
 DC 1,0,0
 DC 1,0,0
 DC 1,0,0
 DC 1,-1,0
 DC 1,0,0
 DC 1,0,0
 DC 1,0,0
 DC 1,0,0
 DC 1,-1,0
 DC 1,0,0
 DC 1,0,0
 DC 1,0,0
 DC 1,0,1
 DC 1,0,0
 DC 1,0,0
MOVEMENT2 DC 1,0,0
 DC 99,0,0 ;END MARKER
MOVEMENT3 DC 0,0,0

*----------Fill A Square----------*

FILL_SQUARE TST GRIDX(A4)
 BMI NO_FILL
 TST GRIDY(A4)
 BMI NO_FILL
 TST DEAD(A4)
 BNE NO_FILL
 TST STATUS(A4)
 BNE NO_FILL

 CLR.L D0   ;Find tile info
 MOVE GRIDY(A4),D0
 SUB #1,D0
 MULU #9,D0
 ADD GRIDX(A4),D0
 SUB #1,D0
 ADD.L #GRID,D0
 MOVE.L D0,A0

 TST COUNTER   ;Wormy or Eraser?
 BNE FILL_ERASER

 TST.B (A0)    ;Tile ready for flipping?
 BNE NO_FILL
 MOVE.B #1,(A0)
 SUB #1,SQUARE_COUNT
 MOVE #SCORE_PAD,D0
 JSR SCORED
 MOVE #1,D7
 JMP FILL_IT

FILL_ERASER TST.B (A0) ;Tile already flipped?
 BEQ NO_FILL
 CLR.B (A0)
 ADD #1,SQUARE_COUNT
 CLR D7

FILL_IT LEA PLAYFIELD,A1

 CLR.L D0
 MOVE GRIDY(A4),D0
 ADD GRIDX(A4),D0
 SUB #2,D0
 MULU #13,D0
 ADD #54,D0
 MULU #160,D0
 ADD.L D0,A1

 CLR.L D0
 MOVE #10,D0
 SUB GRIDY(A4),D0
 ADD GRIDX(A4),D0
 SUB #1,D0
 MULU #8,D0

 ADD.L D0,A1

 MOVE #6,D3
 LEA UN_FILL_PAT,A0
 TST D7
 BEQ UN_FILL_100
 LEA FILL_PAT,A0

FILL_100 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 OR.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 OR.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 OR.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 MOVE.L (A0),D1
 EOR.L #-1,D1
 AND.L D1,D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 ADD #4,A0
 ADD #160-8,A1
 DBF D3,FILL_100
 RTS

UN_FILL_100 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 AND.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 MOVE.L (A0),D1
 EOR.L #-1,D1
 OR.L D1,D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 AND.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 MOVE (A1),D0
 SWAP D0
 MOVE 8(A1),D0
 AND.L (A0),D0
 MOVE D0,8(A1)
 SWAP D0
 MOVE D0,(A1)+

 ADD #4,A0
 ADD #160-8,A1
 DBF D3,UN_FILL_100

NO_FILL RTS

FILL_PAT
 DC.L $000FF000
 DC.L $00FFFF00
 DC.L $0FFFFFF0
 DC.L $FFFFFFFF
 DC.L $0FFFFFF0
 DC.L $00FFFF00
 DC.L $000FF000

UN_FILL_PAT
 DC.L $FFF00FFF
 DC.L $FF0000FF
 DC.L $F000000F
 DC.L $00000000
 DC.L $F000000F
 DC.L $FF0000FF
 DC.L $FFF00FFF

*----------Draw Characters----------*

PLOT_PLAYERS LEA PLAYER_INFO,A4
 CLR COUNTER
PP_RPT TST ACTIVE(A4)
 BEQ PP_RPT2
 JSR DO_PLOT
PP_RPT2 ADD.L #PLAYER_SIZE,A4
 ADD #1,COUNTER
 CMP #PLAYER_MAX,COUNTER
 BLT PP_RPT
 RTS

DO_PLOT MOVE TYPE(A4),D2
 CMP #3,D2
 BNE PP_F1B
 MOVE #2,D2
PP_F1B MULU #96,D2
 MOVE ANIMATE(A4),D3
 MULU #24,D3
 ADD.L D3,D2
 MOVE STRETCH(A4),D3
 MULU #8,D3
 ADD.L D3,D2
 MOVE XPOS(A4),D0
 LSR #1,D0
 AND.L #7,D0
 ADD.L D0,D2
 MULU #CELL_SIZE,D2
 ADD.L #CELLS,D2
 MOVE.L D2,A0

 MOVE #CELL_HEIGHT-1,D3
 move.l screenn,a1
 move XPOS(a4),d0
 lsr #4,d0
 lsl #3,d0
 add d0,a1
 move YPOS(a4),d0
 add #19,d0
 sub d3,d0
 bpl en210
 add d0,d3
 muls #-16,d0
 add.l d0,a0
 clr d0
en210 move d0,d1
 mulu #160,d1
 add.l d1,a1
 move d0,d1
 add d3,d1
 cmp #200,d1
 bcs en218
 move #199,d3
 sub d0,d3
en218 tst d3
 bmi rtss

 TST PRIORITY(A4)
 BNE PP_BACKGROUND

PP_100 move (a0),d0
 or 2(a0),d0
 or 4(a0),d0
 or 6(a0),d0
 eor #-1,d0
 and d0,(a1)
 and d0,2(a1)
 and d0,4(a1)
 and d0,6(a1)
 move 8(a0),d0
 or 10(a0),d0
 or 12(a0),d0
 or 14(a0),d0
 eor #-1,d0
 and d0,8(a1)
 and d0,10(a1)
 and d0,12(a1)
 and d0,14(a1)
 move.l (a0),d0
 or.l d0,(a1)
 move.l 4(a0),d0
 or.l d0,4(a1)
 move.l 8(a0),d0
 or.l d0,8(a1)
 move.l 12(a0),d0
 or.l d0,12(a1)

 ADD #16,A0
 ADD #160,A1

 dbf d3,PP_100
 rts

PP_BACKGROUND move (a1),d2 ; Player has lower priority than playfield
 or 2(a1),d2
 or 4(a1),d2
 or 6(a1),d2
 eor #-1,d2
 move d2,d0
 swap d0
 move d2,d0
 move 8(a1),d2
 or 10(a1),d2
 or 12(a1),d2
 or 14(a1),d2
 eor #-1,d2
 move d2,d1
 swap d1
 move d2,d1
 move.l (a0),d2
 and.l d0,d2
 or.l d2,(a1)
 move.l 4(a0),d2
 and.l d0,d2
 or.l d2,4(a1)
 move.l 8(a0),d2
 and.l d1,d2
 or.l d2,8(a1)
 move.l 12(a0),d2
 and.l d1,d2
 or.l d2,12(a1)

 ADD #16,A0
 ADD #160,A1

 dbf d3,PP_BACKGROUND
 rts

* A novice programmer was once assigned to code a simplified
* financial package.
* The novice worked furiously for many days, but when his master
* reviewed the program, he discovered that it contained a screen
* editor, a set of generalized graphics routines, an artificial
* inteligence interface, but not the slightest mention of
* anything financial.

* When the master asked about this, the novice became indignant.
* "Don't be so impatient, " he said, "I'll put in the financial
* stuff eventually."

*----------------ESTABLISH CELL PATTERNS----------------*

INIT_CELLS LEA CELLS,A1

 LEA OPPONENTS,A0  ;Wormy
 ADD #9*160,A0
 LEA CELLS,A1
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #49*160,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #129*160,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #89*160,A0
 JSR CELL_GRAB

 LEA OPPONENTS,A0  ;Mr. Snake
 ADD #9*160,A0
 ADD #48,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #49*160,A0
 ADD #48,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #129*160,A0
 ADD #48,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #89*160,A0
 ADD #48,A0
 JSR CELL_GRAB

 LEA OPPONENTS,A0  ;Shades
 ADD #9*160,A0
 ADD #96,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #49*160,A0
 ADD #96,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #129*160,A0
 ADD #96,A0
 JSR CELL_GRAB
 LEA OPPONENTS,A0
 ADD #89*160,A0
 ADD #96,A0

CELL_GRAB CLR COUNT

CE_PAT2 CLR COUNT2

CE_PAT1 MOVE COUNT2,D2
 LSL #1,D2
 JSR MAKE_CELL

 ADD #1,COUNT2
 CMP #CELL_COUNT,COUNT2
 BNE CE_PAT1

 ADD #16,A0
 ADD #1,COUNT
 CMP #3,COUNT
 BNE CE_PAT2
rtss rts

*---------------FILL A CELL---------------*
* A0 - Source address from DEGAS screen
* A1 - Destination Cell address
* D2 - # of bits to rotate right

MAKE_CELL MOVE.L A0,A2
 MOVE.L A1,A3
 MOVE #CELL_HEIGHT-1,D0
CE_100 MOVE.L (A2)+,(A3)+
 MOVE.L (A2)+,(A3)+
 MOVE.L (A2)+,(A3)+
 MOVE.L (A2)+,(A3)+
 ADD #160-16,A2
 DBF D0,CE_100

 TST D2
 BEQ CE_DONE

CE_101 MOVE #CELL_HEIGHT-1,D0
 MOVE.L A1,A2
CE_102 CLR.L D1
 MOVE (A2),D1
 SWAP D1
 MOVE 8(A2),D1
 ROR.L #1,D1
 MOVE D1,8(A2)
 SWAP D1
 MOVE D1,(A2)

 CLR.L D1
 MOVE 2(A2),D1
 SWAP D1
 MOVE 10(A2),D1
 ROR.L #1,D1
 MOVE D1,10(A2)
 SWAP D1
 MOVE D1,2(A2)

 CLR.L D1
 MOVE 4(A2),D1
 SWAP D1
 MOVE 12(A2),D1
 ROR.L #1,D1
 MOVE D1,12(A2)
 SWAP D1
 MOVE D1,4(A2)

 CLR.L D1
 MOVE 6(A2),D1
 SWAP D1
 MOVE 14(A2),D1
 ROR.L #1,D1
 MOVE D1,14(A2)
 SWAP D1
 MOVE D1,6(A2)

 ADD.L #16,A2
 DBF D0,CE_102
 DBF D2,CE_101

CE_DONE ADD #CELL_SIZE,A1
 RTS

*----------Init Playfield----------*

COPYFLIP2 MOVE.L (A0)+,(A1)+
 DBF D0,COPYFLIP2
 RTS

*----------Floating Discs----------*

DISC_PLOT LEA DISCLOC2,A0
 LEA DISCLOC,A1
 MOVE #127,D0
DISC_I100 MOVE.B (A0)+,(A1)+
 DBF D0,DISC_I100

 MOVE LEVEL,D0
 AND.L #7,D0
 MULU #16,D0
 ADD.L #DISCLOC,D0
 MOVE.L D0,A0
 MOVE.L A0,DISC_ADR

 MOVE #3,D5

DISC_LOOP TST.L (A0)
 BEQ DISC_RCRS

 LEA OPPONENTS,A1
 ADD #9*160,A1
 ADD #144,A1

 CLR.L D0
 MOVE (A0),D0
 ADD 2(A0),D0
 SUB #2,D0
 MULU #13,D0
 ADD #54,D0
 MULU #160,D0
 ADD.L #PLAYFIELD,D0
 MOVE.L D0,A2
 CLR.L D0
 MOVE #10,D0
 SUB (A0),D0
 ADD 2(A0),D0
 SUB #1,D0
 MULU #8,D0
 ADD.L D0,A2

 MOVE #8,D3
DISC_100 MOVE #3,D2
DISC_101 MOVE (A2),D0
 SWAP D0
 MOVE 8(A2),D0

 MOVE (A1),D1
 SWAP D1
 MOVE 8(A1),D1

 OR.L D1,D0

 MOVE D0,8(A2)
 SWAP D0
 MOVE D0,(A2)

 ADD #2,A1
 ADD #2,A2

 DBF D2,DISC_101

 ADD #160-8,A1
 ADD #160-8,A2

 DBF D3,DISC_100

DISC_RCRS ADD #4,A0
 DBF D5,DISC_LOOP
 RTS

DISC_REMOVE CLR.L D0
 MOVE (A0),D0
 ADD 2(A0),D0
 SUB #2,D0
 MULU #13,D0
 ADD #54,D0
 MULU #160,D0
 MOVE.L D0,A2
 CLR.L D0
 MOVE #10,D0
 SUB (A0),D0
 ADD 2(A0),D0
 SUB #1,D0
 MULU #8,D0
 ADD.L D0,A2
 ADD.L #PLAYFIELD,A2

 CLR.L (A0)  ;Remove this disc

 LEA FILL_PAT,A1
 MOVE #7,D3
DISC_R100 MOVE #3,D2
DISC_R101 MOVE (A2),D0
 SWAP D0
 MOVE 8(A2),D0

 MOVE.L (A1),D1
 EOR.L #-1,D1
 AND.L D1,D0

 MOVE D0,8(A2)
 SWAP D0
 MOVE D0,(A2)+

 DBF D2,DISC_R101
 ADD #160-8,A2
 ADD #4,A1
 DBF D3,DISC_R100
 RTS

*-----------LOAD A FILE-------------*
* A0 = PTR TO FILE NAME
* A1 = PTR TO LOCATION

LOADFILE MOVE.L A1,LFADR
 SUB.L #2,A2
 MOVE.L A2,LFCOLORADR

 CLR -(A7)  ;F_OPEN
 MOVE.L A0,-(A7)
 MOVE #$3D,-(A7)
 TRAP #1
 ADD #8,A7

 TST D0
 BMI QUIT
 MOVE D0,FHANDLE

 MOVE.L LFCOLORADR,-(A7) ;F_read
 MOVE.L #34,-(A7)
 MOVE FHANDLE,-(A7)
 MOVE #$3F,-(A7)
 TRAP #1
 ADD #12,A7

 MOVE.L #DECODE,-(A7)  ;F_READ
 MOVE.L #32000,-(A7)
 MOVE FHANDLE,-(A7)
 MOVE #$3F,-(A7)
 TRAP #1
 ADD #12,A7
 MOVE.L D0,LFSIZE

 MOVE FHANDLE,-(A7)   ;F_CLOSE
 MOVE #$3E,-(A7)
 TRAP #1
 ADD #4,A7

 MOVE.L LFSIZE,D0
 MOVE.L LFADR,A0
 MOVE.L #DECODE,A1

*****************************************************
* DEGAS COMPRESSED PICTURE DECODER (LOW RESOLUTION) *
* D0 - # OF BYTES TO DECOMPRESS                     *
* A0 - DESTINATION ADDRESS                          *
* A1 - SOURCE ADDRESS                               *
*****************************************************

 CLR D3
 MOVE #200,D6
DEGAS_LINE MOVE #4,D5
 SUB #1,D6
 TST D6
 BEQ DEGAS_DONE

DE_COLOR MOVE #40,D4
DEGAS_LOOP CMP.L #1,D0
 BLT DEGAS_DONE

 SUB.L #1,D0
 CLR.L D1
 MOVE.B (A1)+,D1
 CMP.B #128,D1
 BEQ DEGAS_LOOP

 TST.B D1
 BMI DEGAS_DUPLICATE

DEGAS_COPYLP MOVE.B (A1)+,(A0)
 SUB.L #1,D0
 SUB #1,D4

 TST D3
 BNE DEGAS_COPYLP2
 ADD #1,A0
 MOVE #1,D3
 JMP DEGAS_COPYRCRS
DEGAS_COPYLP2 ADD #7,A0
 CLR D3

DEGAS_COPYRCRS DBF D1,DEGAS_COPYLP
 TST D4
 BNE DEGAS_LOOP
 SUB #158,A0
 SUB #1,D5
 TST D5
 BNE DE_COLOR
 ADD #152,A0
 JMP DEGAS_LINE

DEGAS_DUPLICATE MULS #-1,D1
 AND #$FF,D1
 MOVE.B (A1)+,D2
 SUB.L #1,D0

DEGAS_DUPLP MOVE.B D2,(A0)

 SUB #1,D4

 TST D3
 BNE DEGAS_DUPLP2
 ADD #1,A0
 MOVE #1,D3
 JMP DEGAS_DUPRCRS
DEGAS_DUPLP2 ADD #7,A0
 CLR D3

DEGAS_DUPRCRS DBF D1,DEGAS_DUPLP

 TST D4
 BNE DEGAS_LOOP
 SUB #158,A0
 SUB #1,D5
 TST D5
 BNE DE_COLOR
 ADD #152,A0
 JMP DEGAS_LINE

DEGAS_DONE RTS

*-------------EXIT-------------*

QUIT lea gi_309,a0  ;Disable 200 HZ interrupt
 jsr super

 MOVE OLD_REZ,-(A7)
 MOVE.L OLDSCREEN,-(A7)
 MOVE.L #-1,-(A7)
 MOVE #5,-(A7)
 TRAP #14
 ADD.L #12,A7

 MOVE.L #OLD_COLORS,-(A7)  ;SET COLOR PALETTE
 MOVE #6,-(A7)
 TRAP #14
 ADD.L #6,A7

 DC $A009

 CLR -(A7)
 TRAP #1

WAIT_KEY MOVE #7,-(A7)
 TRAP #1
 ADD.L #2,A7
 RTS

*---------------Scoring--------------*

SCORED AND.L #$FFFF,D0
 MOVE.L D0,D1
 ADD.L POINTS,D0
 MOVE.L D0,POINTS

 ADD.L BONUS,D1     ;Bonus life
 MOVE.L D1,BONUS
 CMP.L #5000,D1
 BLE BUTUSCREWT
 CLR.L BONUS
 ADD #1,LIVES

BUTUSCREWT AND.L #$FFFF,D0
 DIVU #10000,D0
 MOVE.L D0,D1
 AND.L #15,D0
 MULU #1280,D0
 ADD.L #SCOREDATA,D0
 MOVE.L D0,A0
 lea playfield,a1
 ADD.L #SCORE_POS,A1
 JSR SCOR_IT

 SWAP D1
 AND.L #$FFFF,D1
 DIVU #1000,D1
 MOVE.L D1,D0
 AND.L #15,D1
 MULU #1280,D1
 ADD.L #SCOREDATA,D1
 MOVE.L D1,A0
 lea playfield,a1
 ADD.L #SCORE_POS+1,A1
 JSR SCOR_IT

 SWAP D0
 AND.L #$FFFF,D0
 DIVU #100,D0
 MOVE.L D0,D1
 AND.L #15,D0
 MULU #1280,D0
 ADD.L #SCOREDATA,D0
 MOVE.L D0,A0
 lea playfield,a1
 ADD.L #SCORE_POS+8,A1
 JSR SCOR_IT

 SWAP D1
 AND.L #$FFFF,D1
 DIVU #10,D1
 MOVE.L D1,D0
 AND.L #15,D1
 MULU #1280,D1
 ADD.L #SCOREDATA,D1
 MOVE.L D1,A0
 lea playfield,a1
 ADD.L #SCORE_POS+9,A1
 JSR SCOR_IT

 SWAP D0
 AND.L #15,D0
 MULU #1280,D0
 ADD.L #SCOREDATA,D0
 MOVE.L D0,A0
 lea playfield,a1
 ADD.L #SCORE_POS+16,A1
 JSR SCOR_IT

* Plot Level Display

 CLR.L D1
 MOVE LEVEL,D1
 ADD #1,D1
 DIVU #10,D1
 MOVE.L D1,D0
 AND.L #15,D1
 MULU #1280,D1
 ADD.L #SCOREDATA,D1
 MOVE.L D1,A0
 lea playfield,a1
 ADD.L #SCORE_L,A1
 JSR SCOR_IT

 SWAP D0
 AND.L #15,D0
 MULU #1280,D0
 ADD.L #SCOREDATA,D0
 MOVE.L D0,A0
 lea playfield,a1
 ADD.L #SCORE_L+1,A1
 JSR SCOR_IT

* Plot lives

 LEA SCOREDATA+15360,A0
 lea playfield,a1
 ADD #SCORE_MEN,A1
 JSR SCOR_IT

 LEA SCOREDATA+15360,A0
 lea playfield,a1
 ADD #SCORE_MEN+1,A1
 JSR SCOR_IT

 LEA SCOREDATA+15360,A0
 lea playfield,a1
 ADD #SCORE_MEN+8,A1
 JSR SCOR_IT

 LEA SCOREDATA+15360,A0
 lea playfield,a1
 ADD #SCORE_MEN+9,A1
 JSR SCOR_IT

 MOVE LIVES,D1
 BEQ SCOREND

 LEA SCOREDATA+12800,A0
 lea playfield,a1
 ADD #SCORE_MEN,A1
 JSR SCOR_IT

 CMP #1,D1
 BEQ SCOREND

 LEA SCOREDATA+12800,A0
 lea playfield,a1
 ADD #SCORE_MEN+1,A1
 JSR SCOR_IT

 CMP #2,D1
 BEQ SCOREND

 LEA SCOREDATA+12800,A0
 lea playfield,a1
 ADD #SCORE_MEN+8,A1
 JSR SCOR_IT

 CMP #3,D1
 BEQ SCOREND

 LEA SCOREDATA+12800,A0
 lea playfield,a1
 ADD #SCORE_MEN+9,A1

SCOR_IT MOVE #7,D2
SCOR_100 MOVE.B (A0),(A1)
 MOVE.B 2(A0),2(A1)
 MOVE.B 4(A0),4(A1)
 MOVE.B 6(A0),6(A1)
 ADD #160,A0
 ADD #160,A1
 DBF D2,SCOR_100
 SUB #160*8,A0
 SUB #160*8,A1

SCOREND RTS

deathsoundon jsr soundeffectstart
 dc 70,127,4,6,4
 rts
deathsoundoff jsr soundeffectstop
 dc 4
 rts

*----------Start Players----------*

INIT_PLAYERS lea PLAYER_INFO,a0
 MOVE #PLAYER_SIZE-1,D0
IP_100 CLR.B (A0)+
 DBF D0,IP_100

 LEA PLAYER_INFO,A4
 MOVE #WORMY_START_X,XPOS(A4)
 MOVE #WORMY_START_Y,YPOS(A4)
 MOVE #1,ACTIVE(A4)
 MOVE #1,GRIDX(A4)
 MOVE #1,GRIDY(A4)
 MOVE #98,SPEED(A4)

INIT_OPPONENTS LEA PLAYER_INFO+PLAYER_SIZE,A0
 MOVE #PLAYER_MAX-2,D0
IOP_100 MOVE #PLAYER_SIZE-1,D1
IOP_101 CLR.B (A0)+
 DBF D1,IOP_101
 DBF D0,IOP_100

 MOVE LEVEL,D0
 AND.L #7,D0
 MULU #4,D0
 ADD.L #LEVS,D0
 MOVE.L D0,A0
 MOVE.L (A0),A3

 LEA PLAYER_INFO,A4

PI_402 ADD.L #PLAYER_SIZE,A4
 CMP #EOF,(A3)
 BEQ rtss

 MOVE (A3),TYPE(A4)
 MOVE 2(A3),D0
 MULU #60,D0
 MOVE D0,WAITING(A4)
 MOVE 4(A3),SPEED(A4)

 jsr _random
 dc 2 ; get value (0-1)
 move random,d0
 MOVE #PLAYER_START_X1,D1
 MOVE #1,GRIDX(A4)
 MOVE #2,GRIDY(A4)
 tst d0
 BEQ PI_200
 MOVE #PLAYER_START_X2,D1
 MOVE #2,GRIDX(A4)
 MOVE #1,GRIDY(A4)
PI_200 MOVE D1,XPOS(A4)
 MOVE #1,YPOS(A4)
 MOVE #1,PRIORITY(A4)
 MOVE #1,BIRTH(A4)
 MOVE #1,ACTIVE(A4)

 ADD.L #6,A3
 JMP PI_402

LEVS DC.L LEVEL1,LEVEL2,LEVEL3,LEVEL4,LEVEL5,LEVEL6,LEVEL7,LEVEL8

WORMY EQU 0
SNAKE EQU 1
SHADES EQU 2
ERASER EQU 3
EOF EQU -1

LEVEL1 DC SHADES,10,80
 DC SHADES,20,85
 DC SHADES,25,90
 DC SHADES,30,95
 DC SHADES,35,96
 DC EOF

LEVEL2 DC SHADES,5,65
 DC SHADES,10,70
 DC SHADES,15,75
 DC SNAKE,20,80
 DC SHADES,25,90
 DC SHADES,30,95
 DC EOF

LEVEL3 DC SHADES,5,100
 DC SNAKE,10,85
 DC SHADES,15,50
 DC SHADES,20,60
 DC ERASER,25,70
 DC SHADES,28,80
 DC SHADES,30,85
 DC SHADES,34,90
 DC SHADES,40,95
 DC EOF

LEVEL4 DC ERASER,5,60
 DC SNAKE,10,80
 DC SHADES,12,70
 DC SHADES,14,65
 DC ERASER,18,86
 DC SHADES,24,90
 DC SHADES,28,75
 DC EOF

LEVEL5 DC SNAKE,8,45
 DC SNAKE,10,80
 DC ERASER,13,85
 DC ERASER,16,40
 DC EOF

LEVEL6 DC SHADES,5,80
 DC SHADES,8,85
 DC SHADES,10,90
 DC SHADES,12,85
 DC ERASER,18,80
 DC ERASER,22,75
 DC SNAKE,25,82
 DC EOF

LEVEL7 DC SHADES,2,65
 DC SHADES,4,62
 DC SHADES,6,75
 DC ERASER,8,85
 DC SHADES,15,90
 DC SNAKE,18,85
 DC SNAKE,22,85
 DC EOF

LEVEL8 DC SNAKE,2,93
 DC ERASER,4,93
 DC SNAKE,6,40
 DC SHADES,8,89
 DC SNAKE,12,85
 DC ERASER,14,85
 DC SNAKE,16,60
 DC ERASER,18,95
 DC SHADES,22,91
 DC EOF

DISCLOC2
 DC 4,0  ;Locations of floating discs
 DC 7,0  ;Each level has four possible discs
 DC 0,5
 DC 0,8

 DC 5,0  ;Level 2
 DC 8,0
 DC 0,9
 DC 0,0

 DC 2,0  ;Level 3
 DC 8,0
 DC 0,4
 DC 0,7

 DC 5,0  ;Level 4
 DC 0,0
 DC 0,0
 DC 0,0

 DC 8,0  ;Level 5
 DC 9,0
 DC 0,8
 DC 0,9

 DC 3,0  ;Level 6
 DC 5,0
 DC 0,8
 DC 0,0

 DC 0,7  ;Level 7
 DC 0,2
 DC 0,0
 DC 0,0

 DC 9,0  ;Level 8
 DC 3,0
 DC 0,9
 DC 0,2

*----------Sound Effects----------*

shrink_box     move.l   #shrink_noise,-(a7)
               move.w   #32,-(a7)      ; output sound string
               trap     #14            ; call xbios
               addq.l   #6,a7          ; restore stack
               rts
shrink_noise   dc.b  $00,$08,$01,$02,$02,$00,$03,$00,$04,$00,$05,$00
               dc.b  $06,$00,$07,$fe,$08,$10,$09,$00,$0a,$00,$0b,$00
               dc.b  $0c,$00,$0d,$0d,$80,$08,$81,$00,$02,$20,$07,$ff
               dc.b  $ff,$00

*---------Text Storage---------*

FNAME1 DC.B 'BOINKMEN.PC1',0
FNAME2 DC.B 'BOINKFLD.PC1',0
FNAME3 DC.B 'BOINKSCR.PC1',0
FNAME4 DC.B 'BOINKTTL.PC1',0
FNAME5 DC.B 'BOINKHLP.PC1',0
 EVEN

_logbase move #3,-(a7)
 trap #14
 add #2,a7
 rts

gi_308 move.l 112,gi_318
 move.l #gi_315,112
 move.l $114,xs_114  *  200hz system clock interrupt vector
 move.l #xs_115,$114
 rts

gi_309 move.l gi_318,112
 move.l xs_114,$114
 BSET #0,1156
 rts

* This is the VBLANK code
gi_315 move.b screenpt+1,$ff8201
 move.b screenpt+2,$ff8203

 ADD #1,VCOUNT

 TST PAUSE_FLAG
 BNE RT_DONE
 ADD #1,COLOR_COUNT  ;Rotate colors
 CMP #5,COLOR_COUNT
 BLT RT_DONE
 CLR COLOR_COUNT
 MOVE.L D0,-(A7)
 MOVE COLORS+24,D0
 MOVE COLORS+22,COLORS+24
 MOVE COLORS+20,COLORS+22
 MOVE COLORS+18,COLORS+20
 MOVE D0,COLORS+18
 MOVE.L (A7)+,D0

RT_DONE move.l COLORS,$ff8240
 move.l COLORS+4,$ff8240+4
 move.l COLORS+8,$ff8240+8
 move.l COLORS+12,$ff8240+12
 move.l COLORS+16,$ff8240+16
 move.l COLORS+20,$ff8240+20
 move.l COLORS+24,$ff8240+24
 move.l COLORS+28,$ff8240+28

 dc $4ef9
gi_318 dc.l 0

super move.l a0,-(a7)
 move #38,-(a7)
 trap #14
 add #6,a7
 rts

* This routine gets jumped to 200 times per second.  It maintains the
* 1000hz timer.
xs_115 movem.l a0-a6/d0-d7,-(a7)
 add.l #5,hz_1000
 jsr music200
 movem.l (a7)+,a0-a6/d0-d7
 dc $4ef9
xs_114 dc.l 0
hz_1000 dc.l 0 ; 1000 hz clock

movescreen move #799,d0  *  copy 32000 bytes from (a0) to (a1)
kv329 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 dbf d0,kv329
 rts

clearscreen move #799,d0  *  clear 32000 bytes from (a0)
dg403 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 clr.l (a0)+
 dbf d0,dg403
 rts

findscreenn move.l screenpt,a0  *  find next screen to use
 add #32000,a0
 cmp.l screenh,a0
 ble kx204
 move.l screenl,a0
kx204 move.l a0,screenn
 rts
screenl dc.l 0
screenh dc.l 0
screenn dc.l 0
screenpt dc.l 0

; put a 16bit random number in random
; all registers are preserved
_random movem.l a0-a2/d0-d2,-(a7)
 move #17,-(a7)  *  generate a random number
 trap #14
 add #2,a7
 and.l #$ffff,d0
 move.l 24(a7),a0
 divu (a0)+,d0
 swap d0
 move d0,random
 move.l a0,24(a7)
 movem.l (a7)+,a0-a2/d0-d2
 rts
random dc 0

*****************************************************************
*  SOUND EFFECT ROUTINES
*****************************************************************
CHANINST EQU 0
CHANTRK EQU 6
CHANVOL EQU 12
CHANPIT EQU 18
CHANAEST EQU 24
CHANAESTp1 = CHANAEST+1
CHANARELST EQU 30
CHANPEST EQU 36
CHANPESTp1 = CHANPEST+1
CHANPRELST EQU 42
CHANPRIO EQU 48
CHANSTLO EQU 54
CHANSTHI EQU 60
CHANVM EQU 66
CHANPITOFF EQU 72
CHANPORTPIT EQU 78
CHANPORTSPD EQU 84
CHANPORTSPDp1 = CHANPORTSPD+1
CHANVIBPIT EQU 90
CHANVIBSPD EQU 96
CHANVIBSPDp1 = CHANVIBSPD+1
CHANVIBDEP EQU 102
CHANVIBDEPp1 = CHANVIBDEP+1
INSAENV EQU 0
INSAENVp2 = INSAENV+2
INSAREL EQU 32
INSAREP EQU 33
INSPENV EQU 34
INSPENVp2 = INSPENV+2
INSPREL EQU 66
INSPREP EQU 67
INSVIBSPD EQU 68
INSVIBDEP EQU 69
INSTRN EQU 71
INSPORT EQU 72
INSWAVE EQU 73
INSSIZE EQU 74
TRKINDEX EQU 0
TRKNOTEOFF EQU 32
TRKFETCH EQU 64
TRKINST EQU 96

ID BCLR #0,1156 ;NO BLEEPS
 CLR MUSICON
 MOVE.B #$7F,REG7
 MOVE.L #-1,CHANDATA
 MOVE #-1,CHANDATA+4 ;CHAN INST
 MOVE.L #-1,CHANDATA+CHANTRK
 MOVE #-1,CHANDATA+CHANTRK+4
 RTS

STOPSONG lea STOPS,a0
 jsr super
 RTS

STOPS CLR MUSICON
 move.b #127,REG7
 MOVE #4,D2
 lea CHANDATA,A2
STOPS0 move.b #-1,CHANINST(A2,D2.w)
 CLR D1
 MOVE D2,D0
 LSR #1,D0
 ADD #8,D0
 jsr WSCHIP
 SUB #2,D2
 BPL STOPS0
 RTS

STARTSONG MOVE.L SONGADD,A0
 MOVE.L #TRKDATA,A1
 MOVE #7,D1
SS1 move.b #-1,TRKNOTEOFF(A1)
 move.b #-1,TRKFETCH(A1)
 CLR.L TRKINST(A1)
 CLR.L D0
 MOVE (A0)+,D0
 BEQ SS2
 ADD.L SONGADD,D0
 CLR.L TRKFETCH(A1)
SS2 MOVE.L D0,(A1)+ ;TRKINDEX
 DBF D1,SS1
 MOVE.L #-1,CLOCK
 move.b #-1,MUSICON
 RTS

music200 BCHG #1,HALF
 BEQ RTSS
 TST MUSICON
 BEQ EXIT
 ADD.L #1,CLOCK
 MOVE.L #TRKDATA,A0
INT1 MOVE.L CLOCK,D0
 CMP.L TRKNOTEOFF(A0),D0
 BEQ DONOTEOFF
 CMP.L TRKFETCH(A0),D0
 BNE NEXTTRK
 MOVE.L TRKINDEX(A0),A1
 MOVE 2(A1),D1
 EXT.L D1
 ADD.L D0,D1
 MOVE.L D1,TRKFETCH(A0)
 MOVE.B 4(A1),D1
 BPL NOTE
 AND.L #$7F,D1
 MOVE.L D1,TRKINST(A0)
 ADD.L #6,TRKINDEX(A0)
 jmp DONOTEOFF

NOTE CLR.L D1
 MOVE (A1),D1
 ADD.L D0,D1
 MOVE.L D1,TRKNOTEOFF(A0)
 CLR D1
 MOVE.B 4(A1),D1  ;NOTE NUMBER
 CLR D2
 MOVE.B 5(A1),D2  ;NOTE VOLUME
 MOVE.L TRKINST(A0),D3 ;NOTE INSTRUMENT
 MOVE #5,D4  ;PRIORITY
 MOVE.L A0,D5
 SUB.L #TRKDATA,D5
 LSR #2,D5  ;TRACK
 jsr NOTEON
 ADD.L #6,TRKINDEX(A0)
 jmp INT1
DONOTEOFF MOVE.L #-1,TRKNOTEOFF(A0)
 MOVE.L TRKINST(A0),D3
 MOVE.L INSTADD,A1
 MULU 2(A1),D3
 ADD.L D3,A1
 ADD #4,A1
 TST.B INSPORT(A1)
 BNE INT1
 MOVE.L A0,D5  ;ONLY NEEDS TRACK #
 SUB.L #TRKDATA,D5
 LSR #2,D5
 jsr NOTEOFF
 jmp INT1
NEXTTRK ADD #4,A0
 CMP.L #TRKDATA+32,A0
 BNE INT1
EXIT jmp UPDATECHAN

soundeffectstart movem.l a0-a6/d0-d7,-(a7)
 move.l 60(a7),a0
 move (a0)+,d1
 move (a0)+,d2
 move (a0)+,d3
 move (a0)+,d4
 move (a0)+,d5
 move.l a0,60(a7)
 jsr STARTNOTE
 movem.l (a7)+,a0-a6/d0-d7
 rts

soundeffectstop movem.l a0-a6/d0-d7,-(a7)
 move.l 60(a7),a0
 move (a0)+,d5
 move.l a0,60(a7)
 jsr STOPNOTE
 movem.l (a7)+,a0-a6/d0-d7
 rts

STARTNOTE
NOTEON MOVE.L #CHANDATA,A2
 MOVE D3,D6
 MOVE.L INSTADD,A3
 MULU 2(A3),D6
 ADD D6,A3
 ADD #4,A3
 TST.B INSPORT(A3)
 BNE STARTPORT
NOPORT MOVE #4,D0 ;STEAL ANY CHAN NOT USED
NO1 TST CHANINST(A2,D0.w)
 BMI STEAL
 SUB #2,D0
 BPL NO1

 MOVE #4,D0 ;STEAL ANY CHAN OF LOWER PRIORITY
NO2 CMP CHANPRIO(A2,D0.w),D4
 BHI STEAL
 SUB #2,D0
 BPL NO2

 MOVE #4,D0 ;STEAL ANY CHAN OF SAME TRK
NO0 CMP CHANTRK(A2,D0.w),D5
 BEQ STEAL
 SUB #2,D0
 BPL NO0

 MOVE #4,D0 ;STEAL ANY CHAN IN RELEASE STAGE
NO3 MOVE CHANAEST(A2,D0.w),D6
 CMP.B CHANARELST(A2,D0.w),D6
 BCS NO33
 CMP CHANPRIO(A2,D0.w),D4
 BCC STEAL
NO33 SUB #2,D0
 BPL NO3

 MOVE #4,D0 ;STEAL OLDEST CHAN
 MOVE.L CLOCK,TEMP1
 move.b #-1,TEMP2
NO4 MOVE CHANSTHI(A2,D0.w),D6
 SWAP D6
 MOVE CHANSTLO(A2,D0.w),D6
 CMP.L TEMP1,D6
 BCC NO5
 CMP CHANPRIO(A2,D0.w),D4
 BCS NO5
 MOVE.L D6,TEMP1
 MOVE D0,TEMP2
NO5 SUB #2,D0
 BPL NO4
 MOVE TEMP2,D0
 BMI RTSS

STEAL move.b #-1,CHANINST(A2,D0.w)
 MOVE D5,CHANTRK(A2,D0.w)
 CLR CHANVOL(A2,D0.w)
 MOVE.L #PITCHTAB,A1
 ADD.B INSTRN(A3),D1
 AND.L #$FF,D1
 DIVU #12,D1
 SWAP D1
 ASL #1,D1
 MOVE 0(A1,D1.w),D5
 SWAP D1
 SUB #2,D1
 LSR D1,D5
 MOVE D5,CHANPITOFF(A2,D0.w)
 MOVE.B INSAREL(A3),CHANARELST(A2,D0.w)
 CLR CHANPEST(A2,D0.w)
 MOVE.B INSPREL(A3),CHANPRELST(A2,D0.w)
 CLR CHANVIBSPD(A2,D0.w)
 MOVE.B INSVIBSPD(A3),CHANVIBSPDp1(A2,D0.w)
 MOVE.B INSVIBDEP(A3),CHANVIBDEPp1(A2,D0.w)
 MOVE.B INSPORT(A3),CHANPORTSPDp1(A2,D0.w)
 CLR CHANPIT(A2,D0.w)
 CLR CHANPORTPIT(A2,D0.w)
 CLR CHANVIBPIT(A2,D0.w)
 CLR CHANAEST(A2,D0.w)

 MOVE D4,CHANPRIO(A2,D0.w)
 MOVE CLOCK+2,CHANSTLO(A2,D0.w)
 MOVE CLOCK,CHANSTHI(A2,D0.w)
 MOVE D2,CHANVM(A2,D0.w)
 MOVE D3,CHANINST(A2,D0.w)

 LSR #1,D0
 MOVE.B #%11110110,D1
 ASL.B D0,D1
 AND.B D1,REG7
 MOVE.B INSWAVE(A3),D1
 ASL.B D0,D1
 OR.B D1,REG7
RTSS RTS

STARTPORT MOVE #4,D0
STPORT1 CMP CHANTRK(A2,D0.w),D5
 BEQ DOPORT
 SUB #2,D0
 BPL STPORT1
 jmp NOPORT
DOPORT CMP CHANINST(A2,D0.w),D3
 BNE STEAL
 MOVE CHANPITOFF(A2,D0.w),CHANPORTPIT(A2,D0.w)
 MOVE.L #PITCHTAB,A1
 ADD.B INSTRN(A3),D1
 AND.L #$FF,D1
 DIVU #12,D1
 SWAP D1
 ASL #1,D1
 MOVE 0(A1,D1.w),D3
 SWAP D1
 SUB #2,D1
 LSR D1,D3
 MOVE D3,CHANPITOFF(A2,D0.w)
 SUB D3,CHANPORTPIT(A2,D0.w)
 MOVE D2,CHANVM(A2,D0.w)
 RTS


STOPNOTE
NOTEOFF MOVE #4,D0
 MOVE.L #CHANDATA,A2
NOFF0 CMP CHANTRK(A2,D0.w),D5
 BNE NOFF1
 TST CHANINST(A2,D0.w)
 BMI NOFF1
 MOVE.B CHANARELST(A2,D0.w),CHANAESTp1(A2,D0.w)
 MOVE.B CHANPRELST(A2,D0.w),CHANPESTp1(A2,D0.w)
NOFF1 SUB #2,D0
 BPL NOFF0
 RTS

UPDATECHAN MOVE #4,D0
 MOVE.L #CHANDATA,A0
UPDATECHAN1 MOVE CHANINST(A0,D0.w),D1
 BMI NEXTCHAN
 MOVE.L INSTADD,A1
 MULU 2(A1),D1
 ADD D1,A1
 ADD #4,A1
 MOVE CHANVOL(A0,D0.w),D1
 MOVE CHANAEST(A0,D0.w),D2
 ASL #2,D2
 CMP INSAENV(A1,D2.w),D1
 BCS ADDTOA
 SUB INSAENVp2(A1,D2.w),D1
 CMP INSAENV(A1,D2.w),D1
 BGT DOPITCH
 MOVE INSAENV(A1,D2.w),D1
 ADD #1,CHANAEST(A0,D0.w)
 MOVE.B INSAREP(A1),D3
 LSR #2,D2
 CMP.B D2,D3
 BNE DOPITCH
 CLR CHANAEST(A0,D0.w)
 jmp DOPITCH
ADDTOA ADD INSAENVp2(A1,D2.w),D1
 CMP INSAENV(A1,D2.w),D1
 BLT DOPITCH
 MOVE INSAENV(A1,D2.w),D1
 ADD #1,CHANAEST(A0,D0.w)
 MOVE.B INSAREP(A1),D3
 LSR #2,D2
 CMP.B D2,D3
 BNE DOPITCH
 CLR CHANAEST(A0,D0.w)
DOPITCH MOVE D1,CHANVOL(A0,D0.w)
 MULU CHANVM(A0,D0.w),D1
 LSR.L #7,D1
 MULU VOLUME,D1
 LSR.L #8,D1
 LSR.L #7,D1
 LSR #1,D0
 ADD #8,D0
 jsr WSCHIP
 SUB #8,D0
 ASL #1,D0
 TST CHANVOL(A0,D0.w)
 BNE DOP2
 move.b #-1,CHANINST(A0,D0.w)
 jmp NEXTCHAN
DOP2 MOVE CHANPIT(A0,D0.w),D1
 MOVE CHANPEST(A0,D0.w),D2
 ASL #2,D2
 CMP INSPENV(A1,D2.w),D1
 BLE ADDTOP
 SUB INSPENVp2(A1,D2.w),D1
 CMP INSPENV(A1,D2.w),D1
 BGT DOOTHER
 MOVE INSPENV(A1,D2.w),D1
 ADD #1,CHANPEST(A0,D0.w)
 MOVE.B INSPREP(A1),D3
 LSR #2,D2
 CMP.B D2,D3
 BNE DOOTHER
 CLR CHANPEST(A0,D0.w)
 jmp DOOTHER
ADDTOP ADD INSPENVp2(A1,D2.w),D1
 CMP INSPENV(A1,D2.w),D1
 BLT DOOTHER
 MOVE INSPENV(A1,D2.w),D1
 ADD #1,CHANPEST(A0,D0.w)
 MOVE.B INSPREP(A1),D3
 LSR #2,D2
 CMP.B D2,D3
 BNE DOOTHER
 CLR CHANPEST(A0,D0.w)
DOOTHER MOVE D1,CHANPIT(A0,D0.w)
 MOVE CHANPORTPIT(A0,D0.w),D1
 BEQ DOOTHER2
 BPL SUBPORT
 ADD CHANPORTSPD(A0,D0.w),D1
 BMI DOOTHER2
 CLR D1
 jmp DOOTHER2
SUBPORT SUB CHANPORTSPD(A0,D0.w),D1
 BPL DOOTHER2
 CLR D1
DOOTHER2 MOVE D1,CHANPORTPIT(A0,D0.w)
 CLR D1
 TST CHANVIBDEP(A0,D0.w)
 BEQ DOOTHER3
 MOVE CHANVIBDEP(A0,D0.w),D2
 MOVE CHANVIBPIT(A0,D0.w),D1
 ADD CHANVIBSPD(A0,D0.w),D1
 BPL CHKPOSVIB
 NEG D2
 CMP D2,D1
 BCC DOOTHER3
 MOVE D2,D1
 NEG CHANVIBSPD(A0,D0.w)
 jmp DOOTHER3
CHKPOSVIB CMP D1,D2
 BCC DOOTHER3
 MOVE D2,D1
 NEG CHANVIBSPD(A0,D0.w)
DOOTHER3 MOVE D1,CHANVIBPIT(A0,D0.w)
 ASR #4,D1  ;VIB RANGE RED.
 MOVE CHANPIT(A0,D0.w),D2
 ASR #4,D2 ;ALSO RANGE REDUCED
 SUB D2,D1  ;PITCH ENV
 ADD CHANPITOFF(A0,D0.w),D1 ;NOTE
 ADD CHANPORTPIT(A0,D0.w),D1 ;PORTAMENTO
 MOVE D0,D2
 MOVE D1,D3
 LSR #1,D2
 BTST D2,REG7
 BNE MAYBNOISE
 jsr WSCHIP
 LSR #8,D1
 AND #$0F,D1
 ADD #1,D0
 jsr WSCHIP
 SUB #1,D0
MAYBNOISE ADD #3,D2
 BTST D2,REG7
 BNE NEXTCHAN
 MOVE D3,D1
 LSR #3,D1 ;NOISE FREQ RANGE RED. 0-7
 AND #31,D1
 MOVE D0,D3
 MOVE #6,D0
 jsr WSCHIP
 MOVE D3,D0

NEXTCHAN SUB #2,D0
 BPL UPDATECHAN1
 MOVE.B REG7,D1
 MOVE.B #7,D0
 jmp WSCHIP

WSCHIP MOVE.B D0,$FF8800
 MOVE.B D1,$FF8802
 RTS
PITCHTAB DC 3822,3607,3405,3214,3033,2863
 DC 2702,2551,2407,2272,2145,2024
MUSICON dc 0
CLOCK dc.l 0
CHANDATA dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TRKDATA dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
HALF dc 0
TEMP1 dc.l 0
TEMP2 dc 0
REG7 dc 0
OLDIRQ dc.l 0
SONGADD DC.L 0
INSTADD DC.L 0
VOLUME DC 16
instblok
 dc.l $0005004A,$7F001200,$7E000002,$00001200,$00000000,$00000000
 dc.l $00000000,$00000000,$00000000,$0207AC00,$00570000,$00000000
 dc.l $00000000,$00000000,$00000000,$00000100,$00000000,$00000007
 dc.l $00000000,$00087F00,$12000000,$00480000,$00000000,$00000000
 dc.l $00000000,$00000000,$00000000,$00000107,$AC00004A,$00000000
 dc.l $00000000,$00000000,$00000000,$00000000,$01000000,$00000000
 dc.l $000765FF,$00000008,$7F001200,$4A000400,$00000E00,$00000000
 dc.l $00000000,$00000000,$00000000,$00000000,$0207F000,$014A0600
 dc.l $01030000,$00000000,$00000000,$00000000,$00000100,$00000000
 dc.l $00000107,$B8FF0000,$00087F00,$12000000,$00000000,$12000000
 dc.l $00000000,$00000000,$00000000,$00000000,$00000207,$0B000006
 dc.l $00000004,$00000004,$00000000,$00000000,$00000000,$01000000
 dc.l $00000000,$0201B8FF,$00000008,$7F007F00,$000000DA,$00001200
 dc.l $00000000,$00000000,$00000000,$00000000,$00000000,$02071600
 dc.l $0900F500,$0B000D00,$0C00F900,$07000E00,$0A00F300,$0D001200
 dc.l $1100F400,$0C000007,$1AFF0000,$01002064,$632E6C20,$24303030

* Thus spoke the master programmer:
* "Time for you to leave."

*---------Variables and Storage---------*

 BSS
 EVEN

* CELL_SIZE x CELL_COUNT x CELL_TYPES x num of chars

CELLS DS.L 35712
 EVEN

SQUARE_COUNT DS 1
LEVEL DS 1
QUIT_FLAG DS 1
DISC_ADR DS.L 1
FLOATING DS 1
FLOATING2 DS 1
POINTS DS.L 1
BONUS DS.L 1
LIVES DS 1

HOLDEN DS.L 1
VCOUNT DS 1
COLOR_COUNT DS 1
COUNT DS 1
COUNT2 DS 1
COUNT3 DS 1
COUNTER DS 1

DONT_MOVE_THIS DS 2
COLORS DS 18
HLP_COLORS DS 18
TTL_COLORS DS 18
REAL_COLORS DS 18
OLD_REZ DS 1
OLD_COLORS DS 16
OLDSCREEN DS.L 1

SCREENFLIP DS.L 1
FLIPSTATUS DS 1

SOUND_COUNT DS 1

PLAYER_INFO DS.B PLAYER_SIZE*PLAYER_MAX
 EVEN

LFSIZE DS.L 1  ;File Loader Variables
LFADR DS.L 1
LFCOLORADR DS.L 1
FHANDLE DS 1

GRID DS.B 100    ;Square status block
DISCLOC DS.B 128 ;Disc Location Information
 EVEN

STOREA7 DS.L 1
savea7 ds.l 1
HELPDATA DS.B 32000
TITLEDATA DS.B 32000
SCOREDATA DS.B 32000
DECODE DS.B 32000
OPPONENTS DS.B 32000
PLAYIMAGE DS.B 32000
playfield
PLAYFIELD DS.B 32000
 EVEN

MOVETBL DS 500 ;Movement information

 END
