	OUTPUT	GAME\BIKE.PRG

* NB. FOR PROTECTED VERSION REMOVE KEYTESTS, CHEAT FLAG STUFF,
*     CHANGE PROTECT+2 TO 1 AND PUT CALL TO CHECK_PROT BACK !!
*     AND REMOVE ALL *'S FROM THE GETBPB FOR HISCORE LOAD/SAVE

DEBUG	EQU	0
times1namexy:	equ	(52*160)+(12*4)
times2namexy:	equ	(73*160)+(12*4)
times3namexy:	equ	(95*160)+(12*4)
times4namexy:	equ	(117*160)+(12*4)
times5namexy:	equ	(139*160)+(12*4)
bright:	equ	8
dim:	equ	4	value to put in dot type tells prog how bright colons are on h s tab
digitstart:	equ	18*40

*************** INITIALISE ROUTINES **************

*	SAVE OLD SR AND SSP AND ENTER SUPERVISOR MODE

START	MOVE.L	A7,OLDUSP+2
	MOVE.W	SR,OLDSR+2
	MOVE.L	A7,-(A7)
	MOVE.W	#$20,-(A7)	CALL super
	TRAP	#1
	MOVE.L	D0,OLDSSP+2

*	TURN MOUSE OFF ?

	MOVE.L	#KEYS1,-(A7)
	MOVE.L	#$190002,-(A7)	MOFF
	TRAP	#14
	ADDQ	#8,A7

*	REMOVE MOUSE

	DC.W	$A000	INIT LINE A
	DC.W	$A00A	REMOVE MOUSE

*	STORE COLOUR PALLETTE

	IFEQ	DEBUG

	LEA	$FFFF8240.W,A0
	LEA	OLDPAL,A1
	MOVEQ	#7,D0
STOPAL	MOVE.L	(A0)+,(A1)+
	DBF	D0,STOPAL

	ENDC

*	ALL MFP IRQS OFF

	IFNE	DEBUG

	LEA	$FFFFFA01,A0
	MOVEQ	#0,D0
	MOVEP.L	D0,0(A0)
	MOVEP.L	D0,8(A0)
	MOVEP.L	D0,16(A0)
	MOVE.B	#$48,22(A0)

	ENDC

*	SET UP FLIP SCREEN ADDRESSES

	MOVE.L	$44E.W,SCREEN1+2    FLIP SCREEN 1
	MOVE.L	$44E.W,SCREENON+2
	MOVE.L	#DISPLAY,D0
	ANDI.W	#$FF00,D0
	MOVE.L	D0,SCREEN2+2	FLIP SCREEN 2
	MOVE.L	D0,BLITBASE+2

*	NEW KEYBRD/JYSTK VECTOR

	IFEQ	DEBUG

	MOVE.L	$118.W,OLDKEYVEC+2

	ENDC

	MOVE.L	#READKEY,-(A7)
	MOVE.L	#$D0006,-(A7)
	TRAP	#14
	ADDQ	#8,A7

*	SET UP TIMER B

	MOVE.L	#DEIRQ,-(A7)
	MOVE.L	#$60,-(A7)	STOP TIMER,COUNT 96
	MOVE.L	#$1F0001,-(A7)	XBTIMER B
	TRAP	#14
	ADDA.W	#12,A7

*	NEW VBL

	MOVE.L	$70.W,OLDVBL+2
	MOVE.L	#MYVBL,$70.W

*	FIRST ENTRY HAS SIX NEW SCORES

	MOVEQ	#5,D0
	BRA.S	SORTSCORES

*	MAIN  PROGRAM STARTS HERE (LOOP ON GAME OVER)
* NB. NUMBEROFPLAYERS = NUMBER-1 !!!

MAIN	MOVE.W	NUMBEROFPLAYERS,D0
SORTSCORES	LEA	PLAYER1SCORE,A0    NEW SCORES
	LEA	PLAYER1NAME,A1	   CURRENT NAMES

SORT1	LEA	HISCOREVALUES,A2   HIGH SCORES
	MOVE.L	(A0)+,D1	GET PLAYER'S SCORE
	MOVEQ	#4,D2	5 HISCORES

SORT2	CMP.L	(A2),D1	NEW HIGH ?
	BCS.S	SORT3	NO, TRY NEXT

	MOVE.L	(A2),D3	GET OLD HISCORE
	MOVE.L	D1,(A2)+	STORE NEW HISCORE
	LEA	HISCORE5NAME+10,A3
	SUBQ.W	#1,D2	LAST HISCORE ?
	BMI.S	SORT4	YES

SORT5	MOVE.L	(A2),D1	GET OLD HISCORE
	MOVE.L	D3,(A2)+	STORE FROM ONE ABOVE
	MOVE.L	D1,D3	COPY FOR NEXT POSITION
	MOVE.L	-40(A3),-(A3)	COPY NAME FROM
	MOVE.L	-40(A3),-(A3)	PREVIOUS POSITION
	MOVE.W	-38(A3),-(A3)	IN HISCORE TABLE
	SUBA.W	#26,A3
	DBF	D2,SORT5

SORT4	MOVE.W	8(A1),-(A3)	PUT NEW NAME
	MOVE.L	4(A1),-(A3)	INTO HISCORE
	MOVE.L	(A1),-(A3)	TABLE
	BRA.S	SORT6

HEXTODECSTRING	MOVE.L	#10000,D1
	BSR.S	DOCONV
HEXCONV1	MOVE.L	#1000,D1
	BSR.S	DOCONV
	MOVEQ.L	#100,D1
	BSR.S	DOCONV
	MOVEQ.L	#10,D1
	BSR.S	DOCONV
	MOVE.W	D2,(A0)+
	RTS
DOCONV	DIVU	D1,D2
	MOVE.W	D2,(A0)+
	MOVE.W	#0,D2
	SWAP	D2
	RTS

SORT3	ADDQ	#4,A2	NEXT HISCORE
	DBF	D2,SORT2
SORT6	ADDA.W	#10,A1	NEXT PLAYER
	DBF	D0,SORT1

	LEA	HISCORE1SCORE,A0
	LEA	HISCOREVALUES,A1
	MOVEQ	#4,D0
FIXSCORE	MOVE.L	(A1)+,D2
	BSR.S	HEXTODECSTRING
	ADDA.W	#26,A0
	DBF	D0,FIXSCORE

	LEA	BESTTIMES,A0	CURRENT BEST VALUES
	LEA	DONETIMES,A1	TIMES JUST DONE
	MOVEQ	#4,D0	5 SETS OF COURSES
SETTIME1	MOVEQ	#5,D1	MAX 6 PLAYERS
SETTIME2	MOVE.L	A0,A2	COPY FOR EACH PLAYER
	MOVEQ	#2,D2	3 COURSES PER SET
SETTIME3	TST.L	(A1)	ANY TIME ?
	BEQ.S	SETTIME5	NO, IGNORE
	MOVE.W	(A1),D3	GET MINUTES
	CMP.W	(A2),D3	BETTER ?
	BCS.S	SETTIME4	YES
	BNE.S	SETTIME5	NO
	MOVE.W	2(A1),D3	GET SECONDS
	CMP.W	2(A2),D3	BETTER ?
	BCC.S	SETTIME5	NO
SETTIME4	MOVE.L	(A1),(A2)	NEW BEST
	MOVEQ	#4,D4	5 SETS
	SUB.W	D0,D4	SET NUMBER
	MOVEQ	#2,D5	3 COURSES PER SET
	SUB.W	D2,D5	COURSE NUMBER
	MULU	#3,D4	3 COURSES PER SET
	ADD.W	D5,D4	NUMBER OF COURSE
	MULU	#36,D4	OFFSET TO NAME POSITION
	LEA	LEVELANAME,A3	FIRST NAME POSITION
	ADDA.W	D4,A3	ADD OFFSET
	LEA	PLAYER1NAME,A4	FIRST PLAYER
	MOVEQ	#5,D4	6 PLAYERS MAX
	SUB.W	D1,D4	GET PLAYER 0-5
	MULU	#10,D4	OFFSET TO NAME
	ADDA.W	D4,A4	PLAYER'S NAME
	MOVE.L	(A4)+,(A3)+	COPY NAME
	MOVE.L	(A4)+,(A3)+	TO BEST TIME
	MOVE.W	(A4)+,(A3)+	NAME POSITION
SETTIME5	ADDQ	#4,A1	NEXT NEW TIME
	ADDQ	#4,A2	NEXT BEST TIME
	DBF	D2,SETTIME3
	DBF	D1,SETTIME2
	ADDA.W	#12,A0	NEXT 3 BEST TIMES
	DBF	D0,SETTIME1

	LEA	LEVELATIME+2,A0
	LEA	BESTTIMES,A1
	MOVEQ	#14,D0
NEWTIMES	MOVE.W	(A1)+,(A0)+
	MOVE.W	(A1)+,D2
	BSR	HEXCONV1
	ADDA.W	#26,A0
	DBF	D0,NEWTIMES

*	START MAIN TUNE

	BSR	WVBL
	MOVE.L	#TUNE1,TUNEADD+2    MAIN TUNES
	CLR.B	TUNENO+1	FIRST MAIN TUNE
	MOVE.B	#-1,LOOPFLAG+1	LOOP ON
	MOVE.B	#-1,TUNEFLAG+1	TUNE START

TITLES	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	SCREENA,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	PIC1PAL,A0
	BSR	MAINFADE

	BSR	JOYDELAY

	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	SCREENB,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	PIC2PAL,A0
	BSR	MAINFADE

	BSR	JOYDELAY

	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	SCREENC,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	PIC3PAL,A0
	BSR	MAINFADE

	BSR.S	JOYDELAY

	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	STSCORE,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	SCR2MEM,A0
	MOVE.L	BLITBASE+2,A1
	BSR	DECOMIFF

	LEA	SCOREPALETTE,A0
	BSR.S	MAINFADE

	move.l	#dim,dottype
	BSR	JUSTPRINTNAMES	CLEAR DIGITS
	BSR	printhiscores
	BSR.S	JOYDELAY1
	BSR	print1sthilevels
	BSR.S	JOYDELAY1
	BSR	print2ndhilevels
	BSR.S	JOYDELAY1
	BSR	print3rdhilevels
	BSR.S	JOYDELAY1
	BRA	TITLES

JOYDELAY	MOVE.W	#499,D1
	BRA.S	JOYWAIT
JOYDELAY1	MOVE.W	#349,D1
JOYWAIT	BSR.S	WVBL
	MOVE.B	JOYSTICK+1,D0
	BTST	#4,D0
	BEQ.S	.GETNAMES
	ANDI.B	#$F,D0
	BNE.S	.DELDONE
	DBF	D1,JOYWAIT
.DELDONE	CMPI.B	#$10,JOYSTICK+1
	BNE.S	.DELDONE
	RTS
.GETNAMES	MOVE.L	(A7)+,D0
	BRA	THERE

WAITFADE1	BSR.S	WVBL
WAITFADE	MOVE.B	MAINFLAG+1,D0
	OR.B	PLANFLAG+1,D0
	OR.B	PANELFLAG+1,D0
	TST.B	D0
	BNE.S	WAITFADE1
	RTS

MAINFADE	BSR.S	WVBL
	BSR.S	MAINFADE1
	MOVE.B	D0,MAINFLAG+1	SET WHOLE SCREEN FADE FLAG/COUNTER
	BRA.S	WAITFADE

WVBL	MOVE.W	$468.W,D0
.WVBL	CMP.W	$468.W,D0
	BEQ.S	.WVBL
	RTS

PLANFADE	BSR.S	WVBL
	BSR.S	PLANFADE1
	MOVE.B	D0,PLANFLAG+1	SET PLAN/TEXT FADE FLAG/COUNTER
	BRA.S	WAITFADE

ALLFADE	BSR.S	WAITFADE
DEDONE	MOVEQ	#0,D0	LAST SPLIT DONE ?
	BEQ.S	DEDONE	NO
	BSR.S	MAINFADE1
	MOVE.L	A4,A0
	BSR.S	PLANFADE1
	MOVE.L	A5,A0
PANELFADE1	LEA	PANELPAL,A1	PALLET TO CHANGE (=INITIAL VALS)
	LEA	PANELSTORE,A2
	LEA	PANELVALS,A3
	BSR.S	SETFADE
	MOVE.B	D0,MAINFLAG+1
	MOVE.B	D0,PLANFLAG+1
	MOVE.B	D0,PANELFLAG+1	SET PANEL FADE FLAG/COUNTER
	RTS

MAINFADE1	LEA	MAINPAL,A1	PALLET TO CHANGE (=INITIAL VALS)
	LEA	MAINSTORE,A2
	LEA	MAINVALS,A3
	BRA.S	SETFADE

PLANFADE1	LEA	PLANPAL,A1	PALLET TO CHANGE (=INITIAL VALS)
	LEA	PLANSTORE,A2
	LEA	PLANVALS,A3

SETFADE	MOVEQ	#-1,D0
	BNE.S	SLOWFADE
FASTFADE	MOVEQ	#7,D1
.PAL	MOVE.L	(A0)+,(A1)+
	DBF	D1,.PAL
	RTS
SLOWFADE	MOVEQ	#15,D0	16 COLOURS
.FADE1	MOVE.W	(A0)+,D1	DESTINATION PALLET
	MOVE.W	(A1)+,D2	SOURCE PALLET
	MOVEQ	#2,D3	RGB
.FADE2	MOVE.W	D1,D4
	MOVE.W	D2,D5
	ANDI.W	#$700,D4
	ANDI.W	#$700,D5
	MOVE.W	D5,(A2)+	CURRENT VALUES
	SUB.W	D5,D4
	ASR.W	#4,D4	16 CHANGES
	MOVE.W	D4,(A3)+	ADDITION
	LSL.W	#4,D1
	LSL.W	#4,D2
	DBF	D3,.FADE2
	DBF	D0,.FADE1
	MOVEQ	#16,D0
	RTS

DECOMPRESS	MOVE.L	A1,A2
	ADDA.W	#32000,A2	END OF DATA

	MOVE.B	(A0),D0	FIRST CONTROL CODE
	MOVEQ	#0,D1	NO REPEAT BYTES
.DECOM1	MOVEQ	#7,D2	GET 8 BYTES
	MOVE.L	A1,A3	PUT THEM HERE
.DECOM2	DBF	D1,.DECOM3	DO REPEAT IF ANY
	MOVEQ	#0,D1	NO REPEATS
	MOVE.B	(A0)+,D3	GET NEXT BYTE
	CMP.B	D0,D3	CONTROL CODE ?
	BNE.S	.DECOM3	NO
	MOVE.B	(A0)+,D3	GET BYTE
	CMP.B	D0,D3	CONTROL CODE ?
	BNE.S	.DECOM6	NO
	MOVE.B	(A0)+,D0	NEW CONTROL CODE
	BRA.S	.DECOM3
.DECOM6	MOVE.B	(A0)+,D1	GET COUNT
	CMPI.B	#255,D1	WORD LENGTH ?
	BNE.S	.DECOM3	NO
	MOVE.B	(A0)+,D1	GET HIGH BYTE
	LSL.W	#8,D1	SHIFT HIGH BYTE
	MOVE.B	(A0)+,D1	GET LOW BYTE
.DECOM3	MOVE.B	D3,(A3)+	STORE NEXT BYTE
	DBF	D2,.DECOM2
	SWAP	D3	STORE CURRENT BYTE IN HIGH
	MOVE.L	A1,A3	8 BYTE BUFFER
	MOVE.L	(A3)+,D2	FIRST LONGWORD
	MOVEQ	#7,D7	8 BITS INTO EACH PLANE
.DECOM4	ROXL.L	#1,D2
	ROXL.W	#1,D3
	ROXL.L	#1,D2
	ROXL.W	#1,D4
	ROXL.L	#1,D2
	ROXL.W	#1,D5
	ROXL.L	#1,D2
	ROXL.W	#1,D6
	DBF	D7,.DECOM4
	MOVE.L	(A3)+,D2	SECOND LONGWORD
	MOVEQ	#7,D7	8 BITS INTO EACH PLANE
.DECOM5	ROXL.L	#1,D2
	ROXL.W	#1,D3
	ROXL.L	#1,D2
	ROXL.W	#1,D4
	ROXL.L	#1,D2
	ROXL.W	#1,D5
	ROXL.L	#1,D2
	ROXL.W	#1,D6
	DBF	D7,.DECOM5
	MOVE.W	D3,(A1)+
	MOVE.W	D4,(A1)+
	MOVE.W	D5,(A1)+
	MOVE.W	D6,(A1)+
	SWAP	D3	RESTORE CURRENT BYTE
	CMP.L	A1,A2
	BNE	.DECOM1
	RTS

DECOMIFF	MOVE.L	A0,A6
LOOP8	CMPI.B	#"B",(A6)+
	BNE.S	LOOP8
	MOVE.L	A6,A0
	CMPI.B	#"O",(A6)+
	BNE.S	DECOMIFF
	CMPI.B	#"D",(A6)+
	BNE.S	DECOMIFF
	CMPI.B	#"Y",(A6)+
	BNE.S	DECOMIFF
	move.l	#199,d0	;number of lines to do
	ADDQ	#4,A6
	MOVEQ.L	#0,D1	;plane pointer
	MOVEQ.L	#0,d2	;line length		
	MOVEQ.L	#0,d3
loop3:	MOVEQ.L	#0,d6
	MOVEQ.L	#0,d7
	move.b	(A6)+,d6
	cmp.b	#128,d6
	BCC.S	LOOP1
	add.l	d6,d2
loop2:	move.b	(A6),(a1,d3)
	ADDQ	#1,A6
	ADDQ	#1,A1
	dbf	d6,loop2
	addq.l	#01,d2
	cmp.w	#40,d2		;end of line
	BCC.S	loop5	;yes the next line or end
	BRA.S	loop3						
loop1:	move.l	#257,d7
	sub.l	d6,d7
	add.l	d7,d2
	sub.l	#01,d7
	move.b	(A6)+,d5
loop4:	move.b	d5,(a1,d3)
	add.l	#01,a1
	dbf	d7,loop4
	cmp.w	#40,d2
	BCC.S	loop5
	BRA.S	loop3	;get next bytes
loop5:	SUBA.W	#40,a1	;force screen to restart same line (different plane)
	MOVEQ.L	#0,d2	;reset line len
	add.l	#8000,d3	;next plane
	move.l	#32000,d4	;num of planes in pic*8000 bloddy 68000 ad tecks
	cmp.w	d3,d4	;done all planes
	BNE.S	loop3	;no then do next plane
	ADDA.W	#40,a1	;if its next plane the comp for above
	MOVEQ.L	#0,d3
	dbf	d0,loop3	;done all lines 		
bugout:	rts

;+=============================================================+;
; DECHOMP data at (a0) to (a1), can be the same address...	;
; Don't overlap with a1<a0 or it won't work			;
;-=============================================================-;
getbit	macro
	add.l	d0,d0
	bne.s	.\@
	move.l	-(a0),d0
	move	#-1,ccr
	addx.l	d0,d0
.\@
	endm


unpack	move.l	#"*FUN",d0	Find the end of the data.
	move.l	#"GUS*",d1	There is a 1:7.379x10^19/datalength
.suss_end	cmp.l	(a0)+,d0	Chance this will fail...
	beq.s	.yup
	cmp.l	(a0)+,d0	...I like the odds!
	bne.s	.suss_end
.yup	cmp.l	(a0)+,d1
	bne.s	.suss_end

	subq.w	#8,a0		Skip the "*FUNGUS*"
	move.l	-(a0),a2	Length
	MOVE.L	A2,LOADED+2
	add.l	a1,a2		Data goes to -(a2)
	move.l	-(a0),d0	Get first data out...

loop	getbit			See what to do
	bcs	code1xx
	moveq	#3,d1		Set up for small block
	moveq	#0,d3
	getbit
	bcs.s	block
;code 00 - tiny copy
code00	moveq	#1,d3
	moveq	#8,d1
	bra	copy

;code 111 - big block of data
code111	moveq	#8,d1
	moveq	#8,d3
;get a block of straight data out, size in d1
block	bsr	get_data		get count
	add.w	d2,d3
.0	moveq	#7,d1		Get byte out
.1	getbit
	addx.w	d2,d2
	dbra	d1,.1
	move.b	d2,-(a2)	Save it
	dbra	d3,.0		Do all block
	bra	next
;code is 1xx - work out where to go from here
code1xx	moveq	#0,d2		get next 2 bits out
	getbit
	addx.w	d2,d2
	getbit
	addx.w	d2,d2
	cmp.b	#2,d2
	blt.s	small_copy
	cmp.b	#3,d2
	beq.s	code111

big_copy	moveq	#8,d1
	bsr	get_data
	move.w	d2,d3
	move.w	#$c,d1
	bra	copy

small_copy	moveq	#2,d3
	add.w	d2,d3
	move.w	#9,d1
	add.w	d2,d1
;+=============================================================+;
; copy a block of memory, bit like the beeb copy key.		;
;-=============================================================-;
copy	bsr	get_data	Get offset size
	lea	1(a2,d2.w),a3	Point to matching block
.0	move.b	-(a3),-(a2)	Copy it backwards
	dbf	d3,.0
next	cmpa.l	a2,a1
	blt	loop
	rts
;+=============================================================+;
; get d1 bits of data in d2					;
;-=============================================================-;
get_data	subq.w	#1,d1
	clr.w	d2
.1	getbit
	addx.w	d2,d2
	dbf	d1,.1
	rts

*	ROUTINE TO OPEN A FILE NB. NAME AT LOADFILE+2

OPENFILE	MOVE.W	#2,-(A7)	OPEN FILE
LOADNAME	PEA	SPRITEFILE
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ	#8,A7
	MOVE.W	D0,FHANDLE+2
	RTS

*	ROUTINE TO READ FROM A FILE NB. FHANDLE+2 SET UP
*	ALSO READFILE+2=ADDRESS,FLENGTH+2=MAX LENGTH

READFILE	PEA	BLOCKS	LOAD ADDRESS
FLENGTH	PEA	90000	MAX LENGTH
FHANDLE	MOVE.W	#0,-(A7)
	MOVE.W	#$3F,-(A7)	LOAD FILE
	TRAP	#1
	ADDA.W	#12,A7
	MOVE.L	D0,LOADED+2	LENGTH LOADED
	RTS

*	ROUTINE TO LOAD A FILE, NAME AT A0, ADDRESS IN A1

LOADFILE	MOVE.L	A0,LOADNAME+2
	MOVE.L	A1,READFILE+2
.RETRY	BSR.S	OPENFILE
	BPL.S	NOSWAP
	BSR.S	DOSWAP
	BRA.S	.RETRY
NOSWAP	BSR.S	READFILE

*	ROUTINE TO CLOSE A FILE NB. FHANDLE+2 SET UP

CLOSEFILE	MOVE.W	FHANDLE+2,-(A7) CLOSE FILE
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ	#4,A7
	RTS

*	ROUTINE FOR SWAPPING DISK OVER

DOSWAP	BSR	FIREOFF
	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	SWAPSCRN,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	PIC5PAL,A0
	BSR	MAINFADE

.WAIT	BTST.B	#4,JOYSTICK+1
	BNE.S	.WAIT

	LEA	NOCOLORS,A0
	BRA	MAINFADE

printhiscores:
	move.l	#dim,dottype
	jsr	justprintnames
	jsr	scrollhiscore		;scroll on hi score name
	move.l	#dim,dottype
	move.l	#hiscore1oldname,a0	;old name to change
	jsr	setdigxy		;set name to scroll from
	move.l	#hiscore1name,a0	;source of name
	move.l	SCREENON+2,d0		;bass of print screen
	add.l	#times1namexy,d0	;were to put it on screen
	move.l	d0,hsprintpos		;position to print on screen
	jsr	do1timesnames		;rotate these digits
	move.l	#hiscore1score,a0	;were to get numbers vals from
	move.l	SCREENON+2,a1			
	add.l	#(times1namexy+(6*4))-160,a1	;were to print them
	jsr	printrowofnums		;print 6 digits up
* 2nd name
	move.l	#hiscore2oldname,a0	
	jsr	setdigxy		
	move.l	#hiscore2name,a0
	move.l	SCREENON+2,d0
	add.l	#times2namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#hiscore2score,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times2namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 3rd name
	move.l	#hiscore3oldname,a0	
	jsr	setdigxy		
	move.l	#hiscore3name,a0
	move.l	SCREENON+2,d0
	add.l	#times3namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#hiscore3score,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times3namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 4th name
	move.l	#hiscore4oldname,a0	
	jsr	setdigxy		
	move.l	#hiscore4name,a0
	move.l	SCREENON+2,d0
	add.l	#times4namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#hiscore4score,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times4namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 5th name
	move.l	#hiscore5oldname,a0	
	jsr	setdigxy		
	move.l	#hiscore5name,a0
	move.l	SCREENON+2,d0
	add.l	#times5namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#hiscore5score,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times5namexy+(6*4))-160,a1	
	jsr	printrowofnums		
	rts

*puts name in a0 inti digxycords so name has somthing to changw from
setdigxy:
	move.l	#digxycords,a1	;two words why 
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,8(a1)
	move.w	(a0)+,12(a1)
	move.w	(a0)+,16(a1)	;do all five
	move.w	#39,20(a1)	;force level number to space
	rts

*puts name in a0 inti digxycords so name has somthing to changw from
setleveldigxy:
	move.l	#digxycords,a1	;two words why 
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,8(a1)
	move.w	(a0)+,12(a1)
	move.w	(a0)+,16(a1)	;do all five
	rts

*print names of level
justprintnames:
*1st row
	move.l	#hiscore1oldname,a0	
	move.l	SCREENON+2,a1	
	add.l	#times1namexy,a1
	jsr	printrowofdigits
	move.l	SCREENON+2,a1	
	add.l	#times1namexy,a1
	jsr	printblank		;just print a blank in left hand box
	move.l	SCREENON+2,a1	
	add.l	#(times1namexy+24)-160,a1	;move cursore up
	jsr	printnullnumbs		;print row of blank digits
*2nd row
	move.l	#hiscore2oldname,a0	
	move.l	SCREENON+2,a1	
	add.l	#times2namexy,a1
	jsr	printrowofdigits
	move.l	SCREENON+2,a1	
	add.l	#times2namexy,a1
	jsr	printblank		
	move.l	SCREENON+2,a1	
	add.l	#(times2namexy+24)-160,a1
	jsr	printnullnumbs		

*3rd row
	move.l	#hiscore3oldname,a0	
	move.l	SCREENON+2,a1	
	add.l	#times3namexy,a1
	jsr	printrowofdigits
	move.l	SCREENON+2,a1	
	add.l	#times3namexy,a1
	jsr	printblank		
	move.l	SCREENON+2,a1	
	add.l	#(times3namexy+24)-160,a1
	jsr	printnullnumbs		
*4th row
	move.l	#hiscore4oldname,a0	
	move.l	SCREENON+2,a1	
	add.l	#times4namexy,a1
	jsr	printrowofdigits
	move.l	SCREENON+2,a1	
	add.l	#times4namexy,a1
	jsr	printblank		
	move.l	SCREENON+2,a1	
	add.l	#(times4namexy+24)-160,a1
	jsr	printnullnumbs		
*5th row
	move.l	#hiscore5oldname,a0	
	move.l	SCREENON+2,a1	
	add.l	#times5namexy,a1
	jsr	printrowofdigits
	move.l	SCREENON+2,a1	
	add.l	#times5namexy,a1
	jsr	printblank		
	move.l	SCREENON+2,a1	
	add.l	#(times5namexy+24)-160,a1
	jsr	printnullnumbs		
	rts

*print single row of names
*a0 = name to print
*a1= xy pos to print at
printrowofdigits:
	move.l	#0,d0	;number of digits
	move.l	#0,d4
	move.l	#0,d5
printrow2:	move.l	#0,d1
	move.l	d0,d3
	lsr.w	#1,d3	;as d1 go's up in 2 I need this as a byt so			
	move.w	(a0,d0),d1	;give me value for this digit
	move.l	a1,a3	;make copy of pos
	add.l	d4,a3	;add new position
	MOVE.L	BLITBASE+2,A2
	add.l	#digitstart,a2	;were gr data starts for screen
	add.l	d1,a2	;were letter comes from			
	move.l	#14,d2
printrow1:	move.b	(a2),(a3)		
	move.b	8000(a2),2(a3)
	move.b	(2*8000)(a2),4(a3)		
	move.b	(3*8000)(a2),6(a3)		
	add.l	#40,a2
	add.l	#160,a3
	dbf	d2,printrow1
	addq	#1,d5
	cmp	#2,d5	;printed 2 chars next to each other
	bne	printrow3	;no then just point to next byt
	moveq	#0,d5	;yes clr counter and add 7 point to next screen pos
	addq	#6,d4
printrow3:	addq	#1,d4
	add.w	#2,d0
	cmp.w	#10,d0
	bne	printrow2
	rts

*print a blank at a1-2
printblank:
	MOVE.L	BLITBASE+2,A0
	add.l	#(digitstart)+39,a0	;were gr data starts for screen
	sub.l	#8,a1
	move.l	#14,d2
printblank1:	move.b	(a0),(a1)		
	move.b	8000(a0),2(a1)
	move.b	(2*8000)(a0),4(a1)		
	move.b	(3*8000)(a0),6(a1)		
	ADDA.W	#40,a0
	ADDA.W	#160,a1
	dbf	d2,printblank1
	rts

* prints a row of digits from row in of values in x values in digxycords
*a0=row of word values for name hsprintpos=pos to print at

do1timesnames:
	move.w	#30,printranddel	;random numb jumble delay
	move.w	#1,digfinflags
	move.w	#1,digfinflags+2
	move.w	#1,digfinflags+4
	move.w	#1,digfinflags+6
	move.w	#1,digfinflags+8	;set no digtis finished
	move.w	#1,digfinflags+10	;set left digit not fished
dotimenam3:	moveq	#0,d1			;st counter for print
	moveq	#0,d4
	move.l	hsprintpos,a1
	MOVE.L	BLITBASE+2,A4
	add.l	#digitstart,a4	;were gr data starts for screen
dotimenam2:	move.l	#0,d0	;number of hight timess
dotimenam1:	add.w	#1,d1
	cmp.w	#2,d1
	bne	dotimenam5
	move.w	#0,d1
	move.w	#1,aflag1
	bra	dotimenam7
dotimenam5:	move.w	#0,aflag1
dotimenam7:	movem.l	d0-d4,-(a7)
	jsr	rolladigit	;print each digit
	movem.l	(a7)+,d0-d4		
	addq	#1,d4
	cmp.w	#0,aflag1
	beq	dotimenam6
	addq	#8,d0
dotimenam6:	move.l	hsprintpos,a1
	add.l	d0,a1
	cmp.w	#16,d0
	bne	dotimenam1
	cmp.w	#0,aflag1
	bne	dotimenam1	;has to be 2 words and be at beging of next
*print a digit in far left box eg level letter or number in hiscore
	move.l	a1,-(a7)
	sub.l	#6*4,a1
	move.w	#0,aflag1
	movem.l	d0-d4,-(a7)
	jsr	rolladigit	
	movem.l	(a7)+,d0-d4		
	move.l	(a7)+,a1

	jsr	printranddig
	BTST.B	#4,JOYSTICK+1
	BNE.S	DOTIMENAM4

	MOVEM.L	(A7)+,D0-D1
	BRA	THERE

dotimenam4	move.w	#0,d1
	move.w	digfinflags,d1
	or.w	digfinflags+2,d1
	or.w	digfinflags+4,d1
	or.w	digfinflags+6,d1
	or.w	digfinflags+8,d1
	or.w	digfinflags+10,d1
	tst.w	d1	;are all bits 0
	bne	dotimenam3	;if not then can't of finished
	rts
		
*a0=bass of digits a1= destination cord to do d0=current digit
rolladigit:
	asl.l	#1,d4
	move.l	#digfinflags,a2
	cmp.w	#0,(a2,d4)	;this digit finished			
	beq	rolladig2
* work out cords for source from x y tables offset in d2
	move.l	#0,d2
	move.l	#digxycords,a3	;x y of cords
	move.l	d4,d1
	asl.l	#1,d1	;as x y are 2 words force this to 2*2 bytes long
	move.w	2(a3,d1),d2	;get y
	mulu	#40,d2	;give me y*40
	add.w	(a3,d1),d2	;get x value
*check to see if digits need changing
	move.w	(a3,d1),d6
	move.w	(a0,d4),d7
	cmp.w	d6,d7	is x pos = to name chr
	beq	bug1
*print digit
	move.l	#14,d3
* here we go bloody 68k addressing modes o for a 6502
	move.l	a4,a5
	add.w	d2,a5	;replaces	(a1,d2)
	move.l	a1,a6

	cmp.w	#1,aflag1
	bne	rolladig1
rolladig10:	move.b	(a5),1(a6)	print first row
	move.b	8000(a5),3(a6)
	move.b	(2*8000)(a5),5(a6)		
	move.b	(3*8000)(a5),7(a6)		
	ADDA.W	#40,a5
	ADDA.W	#160,a6
	dbf	d3,rolladig10
	bra	rolladig4	

rolladig1:	move.b	(a5),(a6)	;print first row
	move.b	8000(a5),2(a6)
	move.b	(2*8000)(a5),4(a6)		
	move.b	(3*8000)(a5),6(a6)		
	ADDA.W	#40,a5
	ADDA.W	#160,a6
	dbf	d3,rolladig1
rolladig4:	add.w	#1,2(a3,d1)	;increase y go to next line
	cmp	#15,2(a3,d1)
	bne	rolladig2	;not in mid char
	move.w	#0,2(a3,d1)	;in mid char reset y inc x
	add.w	#1,(a3,d1)	;increase x cord i.e position in data
	move.w	(a3,d1),d6	;pissing 68k addressing
	move.w	(a0,d4),d7	;still 6502 can't do this
	cmp.w	d6,d7 ;		is x pos = to name chr
	bne	rolladig3
bug1	move.w	#0,(a2,d4)	;set dig fin flag
	bra	rolladig2
rolladig3:	cmp.w	#40,(a3,d1)	;else check for wrap
	bne	rolladig2	;at end to point to start
	move.w	#0,(a3,d1)
rolladig2:	rts
		
printnullnumbs:
	move.l	#0,d0
printnullnum2:	move.l	a1,a2
	add.l	d0,a2
	MOVE.L	BLITBASE+2,A0
	add.l	#20,a0
	move.l	#15,d1			
printnullnum1:	move.w	(a0),(a2)	;print first row
	move.w	8000(a0),2(a2)
	move.w	(2*8000)(a0),4(a2)		
	move.w	(3*8000)(a0),6(a2)		
	ADDA.W	#40,a0
	ADDA.W	#160,a2
	dbf	d1,printnullnum1
	add.l	#2*4,d0
	cmp.w	#12*4,d0
	bne	printnullnum2
	move.l	a1,hsprintpos		;a1 holds startpos of were to print numbs
	add.l	#160-(6*4),hsprintpos	;set it back as printpos adds 6 & -40 expects pos to be here
	jsr	printdots		;print little dots
	rts
printranddig:
	movem.l	d0-d7/a0-a6,-(a7)	;save all regs
	subq	#1,printranddel 	;internal delay
	bne	printrand3
	move.w	#30,printranddel
	move.l	#0,d2
printrand2:	move.l	hsprintpos,a2		;were to print start of name
	sub.l	#(160-(6*4)),a2 		;add int difference for numbers pos
	add.l	d2,a2			;which number
	MOVE.L	BLITBASE+2,A0
	ADDA.W	#24,a0			;were random dig ims are
	move.l	#8,d0
	jsr	RANDOM			
	asl.l	#1,d0			;random WORD from 0 - 8
	and.l	#$ff,d0			
	add.l	d0,a0			;just give and bit I wont
	move.l	#15,d1			
printrand1:	move.w	(a0),(a2)		
	move.w	8000(a0),2(a2)
	move.w	(2*8000)(a0),4(a2)		
	move.w	(3*8000)(a0),6(a2)		
	ADDA.W	#40,a0
	ADDA.W	#160,a2
	dbf	d1,printrand1
	addq.l	#2*4,d2			;up in words
	cmp.w	#12*4,d2			;done 6 numbers
	bne	printrand2
	jsr	printdots
printrand3:	movem.l	(a7)+,d0-d7/a0-a6
	rts

* generates a random number
* 0 to upper limit ( in d0 )
* result returned in d0
* rnd must be seede at some time

RANDOM:	MOVE.W	D2,-(SP)
	MOVE.W	D0,D2		save upper limit
	BEQ.S	random1		range of 0 returns 0 always
	BSR.S	LongRnd		get a longword random number
	CLR.W	D0		use upper word (it's most random)
	SWAP	D0
	DIVU.W	D2,D0		divide by range...
	CLR.W	D0		...and use remainder for the value
	SWAP	D0		result in D0.W
random1:	MOVE.W	(SP)+,D2
	RTS

LongRnd:	MOVEM.L	D2-D3,-(SP)	
	MOVEM.L	RND,D0/D1	D0=LSB's, D1=MSB's of random number
	ANDI.B	#$0E,D0		ensure upper 59 bits are an...
	ORI.B	#$20,D0		...odd binary number
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	ADD.L	D2,D2		accounts for 1 of 17 left shifts
	ADDX.L	D3,D3		[D2/D3] = RND*2
	ADD.L	D2,D0
	ADDX.L	D3,D1		[D0/D1] = RND*3
	SWAP	D3		shift [D2/D3] additional 16 times
	SWAP	D2
	MOVE.W	D2,D3
	CLR.W	D2
	ADD.L	D2,D0		add to [D0/D1]
	ADDX.L	D3,D1
	MOVEM.L	D0/D1,RND	save for next time through
	MOVE.L	D1,D0		most random part to D0
	MOVEM.L	(SP)+,D2-D3
	RTS

*print single row of numbers
*a0 = name to print
*a1= xy pos to print at
printrowofnums:
	move.l	#0,d0			;number of #
	moveq	#0,d5
printrown2:	move.l	#0,d1
	move.l	d5,d3
	move.w	(a0,d0),d1		;give me value for this num
	asl.w	#1,d1			;make it a word
	move.l	a1,a3	;make copy of pos
	add.l	d3,a3	;add new position
	MOVE.L	BLITBASE+2,A2
	add.l	d1,a2	;were letter num from			
	move.l	#15,d2
printrown1:	move.w	(a2),(a3)		
	move.w	8000(a2),2(a3)
	move.w	(2*8000)(a2),4(a3)		
	move.w	(3*8000)(a2),6(a3)		
	ADDA.W	#40,a2
	ADDA.W	#160,a3
	dbf	d2,printrown1
	ADDQ.W	#8,d5
	ADDQ.W	#2,d0
	cmp.w	#12,d0			;do six digits
	bne	printrown2
	move.l	a1,hsprintpos
	add.l	#(160-(6*4)),hsprintpos
	jsr	printdots	;see above
	rts
*prints dots in numbers 
*place to print in hsprintpos
printdots:
	MOVE.L	BLITBASE+2,A0
	add.l	#(47*40)+8,a0	;were to get mask
	move.l	hsprintpos,a1	;get pos to print
	sub.l	#(160-(6*4)),a1 		;add 6 and sub 40 to align plopley
	move.l	a0,a2	;copy it 
	sub.l	dottype,a2	;get light or dark image bass 
	MOVEQ	#15,d1		
printdots1	
	move.w	(a0),d0
	and.w	d0,(8)(a1)
	and.w	d0,(8)+2(a1)	
	and.w	d0,(8)+4(a1)	
	and.w	d0,(8)+6(a1)	

	move.w	2(a0),d0
	and.w	d0,(8*2)(a1)
	and.w	d0,(8*2)+2(a1)	
	and.w	d0,(8*2)+4(a1)	
	and.w	d0,(8*2)+6(a1)	

	move.w	(a0),d0
	and.w	d0,(8*3)(a1)
	and.w	d0,(8*3)+2(a1)	
	and.w	d0,(8*3)+4(a1)	
	and.w	d0,(8*3)+6(a1)	

	move.w	2(a0),d0
	and.w	d0,(8*4)(a1)
	and.w	d0,(8*4)+2(a1)	
	and.w	d0,(8*4)+4(a1)	
	and.w	d0,(8*4)+6(a1)	;and hole in screen for dots numbs in for x x : x x : x x


	move.w	(a2),d0
	or.w	d0,(8)(a1)
	move.w	2(a2),d0
	or.w	d0,(8*2)(a1)

	move.w	(1*8000)(a2),d0
	or.w	d0,(8)+2(a1)
	move.w	(1*8000)+2(a2),d0
	or.w	d0,(8*2)+2(a1)

	move.w	(2*8000)(a2),d0
	or.w	d0,(8)+4(a1)
	move.w	(2*8000)+2(a2),d0
	or.w	d0,(8*2)+4(a1)

	move.w	(3*8000)(a2),d0
	or.w	d0,(8)+6(a1)
	move.w	(3*8000)+2(a2),d0
	or.w	d0,(8*2)+6(a1)


	move.w	(a2),d0
	or.w	d0,(8*3)(a1)
	move.w	2(a2),d0
	or.w	d0,(8*4)(a1)

	move.w	(1*8000)(a2),d0
	or.w	d0,(8*3)+2(a1)
	move.w	(1*8000)+2(a2),d0
	or.w	d0,(8*4)+2(a1)

	move.w	(2*8000)(a2),d0
	or.w	d0,(8*3)+4(a1)
	move.w	(2*8000)+2(a2),d0
	or.w	d0,(8*4)+4(a1)

	move.w	(3*8000)(a2),d0
	or.w	d0,(8*3)+6(a1)
	move.w	(3*8000)+2(a2),d0
	or.w	d0,(8*4)+6(a1)

	ADDA.W	#40,a0
	ADDA.W	#160,a1
	ADDA.W	#40,a2
	dbf	d1,printdots1
	rts

*scroll words hiscore onto board
scrollhiscore:
	move.l	#1,d0	;size
	move.l	#12,d1	;len
scrhis3:
	move.l	#6,d3
	sub.l	d0,d3	;were to print first digit
	bmi	scrhis4
		
	MOVE.L	BLITBASE+2,A0
	add.l	#(49*40)+12,a0	;start of digits
	move.l	SCREENON+2,a1
	add.l	#(28*160)+(27*8),a1	;were to print
	move.l	d3,d5
	mulu	#8,d5
	add.l	d5,a1	;get were to print
	move.l	d0,d4	;counter for how many times to do
scrhis2:
	move.l	#14,d7
scrhis1:
	move.b	(a0),(a1)
	move.b	8000(a0),2(a1)
	move.b	(2*8000)(a0),4(a1)
	move.b	(3*8000)(a0),6(a1)

	ADDA.W	#40,a0
	ADDA.W	#160,a1
	dbf	d7,scrhis1

	cmp.w	#1,d4
	beq	scrhis11
	sub.l	#(15*40),a0	;move back
	sub.l	#(15*160),a1	;move forward
	move.l	#14,d7
scrhis10:
	move.b	1(a0),1(a1)
	move.b	8001(a0),3(a1)
	move.b	(2*8000)+1(a0),5(a1)
	move.b	(3*8000)+1(a0),7(a1)

	ADDA.W	#40,a0
	ADDA.W	#160,a1
	dbf	d7,scrhis10
scrhis11:
	sub.l	#(15*40)-2,a0	;move back
	sub.l	#(15*160)-8,a1	;move forward

	sub.l	#1,d4	;done all chars
	bne	scrhis2
	add.l	#1,d0
	move.l	#25,d1
de1:	move.l	#600,d7
de2:	dbf	d7,de2
	dbf	d1,de1
	bra	scrhis3
scrhis4:	rts

*change hiscore to best times
scrollbesttimes:
	move.l	#1,d0	;size
	move.l	#12,d1	;len
scrbt3:
	move.l	#6,d3
	sub.l	d0,d3	;were to print first digit
	bmi	scrbt4
	
	MOVE.L	BLITBASE+2,A0
	add.l	#(49*40)+24,a0	;start of digits
	move.l	SCREENON+2,a1
	add.l	#(28*160)+(27*8),a1	;were to print
	move.l	d3,d5
	mulu	#8,d5
	add.l	d5,a1	;get were to print
	move.l	d0,d4	;counter for how many times to do
scrbt2:
	move.l	#14,d7
scrbt1:
	move.b	(a0),(a1)
	move.b	8000(a0),2(a1)
	move.b	(2*8000)(a0),4(a1)
	move.b	(3*8000)(a0),6(a1)

	ADDA.W	#40,a0
	ADDA.W	#160,a1
	dbf	d7,scrbt1

	cmp.w	#1,d4
	beq	scrbt11
	sub.l	#(15*40),a0	;move back
	sub.l	#(15*160),a1	;move forward
	move.l	#14,d7
scrbt10:
	move.b	1(a0),1(a1)
	move.b	8001(a0),3(a1)
	move.b	(2*8000)+1(a0),5(a1)
	move.b	(3*8000)+1(a0),7(a1)

	ADDA.W	#40,a0
	ADDA.W	#160,a1
	dbf	d7,scrbt10
scrbt11:
	sub.l	#(15*40)-2,a0	;move back
	sub.l	#(15*160)-8,a1	;move forward

	sub.l	#1,d4	;done all chars
	bne	scrbt2
	add.l	#1,d0
	move.l	#25,d1
btde1:	move.l	#600,d7
btde2:	dbf	d7,btde2
	dbf	d1,btde1
	bra	scrbt3
scrbt4:	rts

print1sthilevels:
	jsr	scrollbesttimes
	move.l	#bright,dottype
	move.l	#hiscore1name,a0	;old name to change
	jsr	setleveldigxy		;set name to scroll from
	move.l	#levelAname,a0		;source of name
	move.l	SCREENON+2,d0			;bass of print screen
	add.l	#times1namexy,d0	;were to put it on screen
	move.l	d0,hsprintpos		;position to print on screen
	jsr	do1timesnames		;rotate these digits
	move.l	#levelAtime,a0		;were to get numbers vals from
	move.l	SCREENON+2,a1			
	add.l	#(times1namexy+(6*4))-160,a1	;were to print them
	jsr	printrowofnums		;print 6 digits up
* 2nd name
	move.l	#hiscore2name,a0	
	jsr	setleveldigxy		
	move.l	#levelBname,a0
	move.l	SCREENON+2,d0
	add.l	#times2namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelBtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times2namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 3rd name
	move.l	#hiscore3name,a0	
	jsr	setleveldigxy		
	move.l	#levelCname,a0
	move.l	SCREENON+2,d0
	add.l	#times3namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelCtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times3namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 4th name
	move.l	#hiscore4name,a0	
	jsr	setleveldigxy		
	move.l	#levelDname,a0
	move.l	SCREENON+2,d0
	add.l	#times4namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelDtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times4namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 5th name
	move.l	#hiscore5name,a0	
	jsr	setleveldigxy		
	move.l	#levelEname,a0
	move.l	SCREENON+2,d0
	add.l	#times5namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelEtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times5namexy+(6*4))-160,a1	
	jsr	printrowofnums		
	rts

print2ndhilevels:
	move.l	#bright,dottype
	move.l	#levelAname,a0	;name from prev screen
	jsr	setleveldigxy	;set name to scroll from
	move.l	#levelFname,a0	;source of name
	move.l	SCREENON+2,d0			;bass of print screen
	add.l	#times1namexy,d0	;were to put it on screen
	move.l	d0,hsprintpos	;position to print on screen
	jsr	do1timesnames	;rotate these digits
	move.l	#levelFtime,a0	;were to get numbers vals from
	move.l	SCREENON+2,a1			
	add.l	#(times1namexy+(6*4))-160,a1	;were to print them
	jsr	printrowofnums	;print 6 digits up
* 2nd name
	move.l	#levelBname,a0	
	jsr	setleveldigxy		
	move.l	#levelGname,a0
	move.l	SCREENON+2,d0
	add.l	#times2namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelGtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times2namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 3rd name
	move.l	#levelCname,a0	
	jsr	setleveldigxy		
	move.l	#levelHname,a0
	move.l	SCREENON+2,d0
	add.l	#times3namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelHtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times3namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 4th name
	move.l	#levelDname,a0	
	jsr	setleveldigxy		
	move.l	#levelIname,a0
	move.l	SCREENON+2,d0
	add.l	#times4namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelItime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times4namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 5th name
	move.l	#levelEname,a0	
	jsr	setleveldigxy		
	move.l	#levelJname,a0
	move.l	SCREENON+2,d0
	add.l	#times5namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelJtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times5namexy+(6*4))-160,a1	
	jsr	printrowofnums		
	rts
print3rdhilevels:
	move.l	#bright,dottype
	move.l	#levelFname,a0	;name from prev screen
	jsr	setleveldigxy	;set name to scroll from
	move.l	#levelKname,a0	;source of name
	move.l	SCREENON+2,d0	;bass of print screen
	add.l	#times1namexy,d0	;were to put it on screen
	move.l	d0,hsprintpos	;position to print on screen
	jsr	do1timesnames	;rotate these digits
	move.l	#levelKtime,a0	;were to get numbers vals from
	move.l	SCREENON+2,a1			
	add.l	#(times1namexy+(6*4))-160,a1	;were to print them
	jsr	printrowofnums	;print 6 digits up
* 2nd name
	move.l	#levelGname,a0	
	jsr	setleveldigxy		
	move.l	#levelLname,a0
	move.l	SCREENON+2,d0
	add.l	#times2namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelLtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times2namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 3rd name
	move.l	#levelHname,a0	
	jsr	setleveldigxy		
	move.l	#levelMname,a0
	move.l	SCREENON+2,d0
	add.l	#times3namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelMtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times3namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 4th name
	move.l	#levelIname,a0	
	jsr	setleveldigxy		
	move.l	#levelNname,a0
	move.l	SCREENON+2,d0
	add.l	#times4namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelNtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times4namexy+(6*4))-160,a1	
	jsr	printrowofnums		
* 5th name
	move.l	#levelJname,a0	
	jsr	setleveldigxy		
	move.l	#levelOname,a0
	move.l	SCREENON+2,d0
	add.l	#times5namexy,d0
	move.l	d0,hsprintpos
	jsr	do1timesnames
	move.l	#levelOtime,a0		
	move.l	SCREENON+2,a1			
	add.l	#(times5namexy+(6*4))-160,a1	
	jsr	printrowofnums		
	rts

*	ROUTINES TO SELECT PLAYERS ETC. FOR NEW GAME

THERE	CLR.L	CURRENTLEVEL
	MOVE.W	#3,LEVELCOUNT
	MOVE.W	#1,PLAYER+2
	MOVEQ	#5,D0
	LEA	PLAYER1SCORE,A0
.CLEAR	CLR.L	(A0)+
	DBF	D0,.CLEAR
	LEA	DONETIMES,A0
	MOVEQ	#89,D0
.CLEARTIME	CLR.L	(A0)+
	DBF	D0,.CLEARTIME
	CLR.L	PLAYERSOUT
	CLR.W	PLAYERSOUT+4
	MOVE.B	#-1,PRACTICE+1

*	ROUTINE FOR PLAY/PRACTICE AND LOAD/SAVE HISCORES GOES HERE
*	NB. FLAG FOR PRACTICE-NO HISCORE OR BEST TIME

MENUON	LEA	NOCOLORS,A0
	BSR	MAINFADE

	LEA	MENU,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	MENUPAL,A0
	BSR	MAINFADE

.WAIT	CMPI.B	#$10,JOYSTICK+1
	BNE.S	.WAIT
	CLR.W	$468.W

READMENU	CMPI.W	#3000,$468.W
	BEQ	TITLES
	CMPI.B	#$10,JOYSTICK+1
	BNE	TITLES
	BSR	KEYREAD
	BPL.S	READMENU
	ANDI.W	#$7F,D0
	SUBQ	#2,D0
	BEQ	PLAYGAME
	SUBQ	#1,D0
	BEQ	PLEVEL
	SUBQ	#1,D0
	BEQ	LOADHIGH
	SUBQ	#1,D0
	BNE.S	READMENU
	LEA	SAVETEXT,A6
	BSR	INPUTTEXT
	BRA.S	WAITSAVE
SAVERR1	BSR	CLOSEFILE
SAVERR	LEA	ERRTEXT,A6
	BSR	INPUTTEXT
WAITSAVE	BSR	KEYREAD
	CMPI.B	#$B1,D0
	BEQ	MENUON
	CMPI.B	#$95,D0
	BNE.S	WAITSAVE
*	MOVE.W	#0,-(A7)
*	MOVE.W	#7,-(A7)
*	TRAP	#13
*	ADDQ	#4,A7
*	TST.L	D0
*	BMI.S	SAVERR
	LEA	INPUTNAME1,A0
	BSR.S	CHECKSUM
	MOVE.L	D0,(A0)
	MOVE.W	#0,-(A7)
	PEA	HISCOREFILE
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ	#8,A7
	MOVE.W	D0,FHANDLE+2
	BMI.S	SAVERR
	PEA	INPUTNAME1	SAVE ADDRESS
	MOVE.L	#PLANCOLORS-INPUTNAME1,-(A7)    LENGTH TO SAVE
	MOVE.W	FHANDLE+2,-(A7)
	MOVE.W	#$40,-(A7)
	TRAP	#1
	ADDA.W	#12,A7
	TST.L	D0
	BMI.S	SAVERR1
	BSR	CLOSEFILE
	BRA	MENUON

CHECKSUM	MOVEQ	#0,D0
	MOVE.W	#HICOUNT-INPUTNAME1-1,D1
.COUNT	ADD.B	(A0)+,D0
	DBF	D1,.COUNT
	RTS

LOADHIGH	MOVE.L	#HISCOREFILE,LOADNAME+2
	MOVE.L	BLITBASE+2,READFILE+2
	LEA	LOADTEXT,A6
	BSR	INPUTTEXT
	BRA.S	WAITLOAD
LOADERR1	BSR	CLOSEFILE
LOADERR	LEA	ERRTEXT,A6
	BSR	INPUTTEXT
WAITLOAD	BSR	KEYREAD
	CMPI.B	#$B1,D0
	BEQ	MENUON
	CMPI.B	#$95,D0
	BNE.S	WAITLOAD
*	MOVE.W	#0,-(A7)
*	MOVE.W	#7,-(A7)
*	TRAP	#13
*	ADDQ	#4,A7
*	TST.L	D0
*	BMI.S	LOADERR
	BSR	OPENFILE
	BMI.S	LOADERR
	BSR	READFILE
	TST.L	D0
	BMI.S	LOADERR1
	BSR	CLOSEFILE
	MOVE.L	BLITBASE+2,A0
	BSR.S	CHECKSUM
	CMP.L	(A0),D0
	BNE	MAIN
	MOVE.L	BLITBASE+2,A0
	LEA	INPUTNAME1,A1
	MOVE.W	#HICOUNT-INPUTNAME1-1,D1
.MOVE	MOVE.B	(A0)+,(A1)+
	DBF	D1,.MOVE
	BRA	MENUON

*	ROUTINE TO GET PRACTICE LEVEL

PLEVEL	BSR	WVBL
	MOVE.B	#1,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
	LEA	PRACTICETEXT,A6
	BSR	INPUTTEXT
	MOVE.B	LEVELDONE+1,D3
GETPRACTICE	MOVEQ	#8,D2
	BSR	DELAY
GETLEVEL	MOVE.W	D3,D1
	ADDI.B	#"A"+128,D1	ODD PRINT
	MOVE.L	SCREENON+2,A1
	ADDA.W	#112*160+96,A1
	BSR	PRINTCHAR
	MOVE.B	JOYSTICK+1,D1
	BTST	#4,D1
	BEQ.S	.EXIT
	BTST	#3,D1
	BEQ.S	.NOTUP
	ADDQ	#1,D3
.NOTUP	BTST	#2,D1
	BEQ.S	.NOTDOWN
	SUBQ	#1,D3
.NOTDOWN	BTST	#1,D1
	BEQ.S	.NOTLEFT
	SUBQ	#1,D3
.NOTLEFT	BTST	#0,D1
	BEQ.S	.NOTRIGHT
	ADDQ	#1,D3
.NOTRIGHT	TST.B	D3
	BPL.S	.NOTSMALL
	ADDI.B	#15,D3
	BRA.S	GETPRACTICE
.NOTSMALL	CMPI.B	#15,D3
	BLT.S	GETPRACTICE
	SUBI.B	#15,D3
	BRA.S	GETPRACTICE
.EXIT	MOVE.B	D3,LEVELDONE+1
	LEA	NOCOLORS,A0
	BSR	MAINFADE
	BRA	LEVELDONE

PLAYGAME	CLR.B	PRACTICE+1
	LEA	PLAYERTEXT,A6
	BSR	INPUTTEXT
	MOVE.W	NUMBEROFPLAYERS,D3
	ADDQ	#1,D3
	BRA.S	GETNUMBER
CONTESTANTS	MOVEQ	#8,D2
	BSR	DELAY
GETNUMBER	MOVE.W	D3,D1
	ORI.B	#$80,D1	ODD PRINT
	MOVE.L	SCREENON+2,A1
	ADDA.W	#144*160+72,A1
	BSR	PRINTCHAR
	BSR	KEYREAD
	MOVE.B	JOYSTICK+1,D1
	BTST	#4,D1
	BEQ.S	.EXIT
	CMPI.B	#$9C,D0
	BEQ.S	.EXIT
	CMPI.B	#$82,D0
	BCS.S	.NOTKEY
	CMPI.B	#$88,D0
	BCC.S	.NOTKEY
	SUBI.B	#$81,D0
	MOVE.B	D0,D3
.NOTKEY	BTST	#3,D1
	BEQ.S	.NOTUP
	ADDQ	#1,D3
.NOTUP	BTST	#2,D1
	BEQ.S	.NOTDOWN
	SUBQ	#1,D3
.NOTDOWN	BTST	#1,D1
	BEQ.S	.NOTLEFT
	SUBQ	#1,D3
.NOTLEFT	BTST	#0,D1
	BEQ.S	.NOTRIGHT
	ADDQ	#1,D3
.NOTRIGHT	TST.W	D3
	BGT.S	.NOTSMALL
	ADDQ	#6,D3
	BRA.S	CONTESTANTS
.NOTSMALL	CMPI.W	#7,D3
	BLT.S	CONTESTANTS
	SUBQ	#6,D3
	BRA.S	CONTESTANTS
.EXIT	SUBQ	#1,D3
	MOVE.W	D3,NUMBEROFPLAYERS

	MOVE.B	#1,PLAYERNUMBER	NAME COUNT
	LEA	INPUTNAME1,A5	NAME OF FIRST PLAYER
	BSR.S	SETNAME	COPY TO INPUTNAME
	LEA	NAMETEXT,A6	TEXT FOR ENTRY
	BSR.S	INPUTTEXT	PRINT SCREEN
	MOVEQ	#0,D3	CURSOR AT START OF NAME
	LEA	INPUTNAME,A4	NAME ENTERED HERE
	BRA	GETNAME1

INPUTTEXT	LEA	TEXTCOLORS,A4
INPUT	LEA	NOCOLORS,A0
	BSR	MAINFADE
	BSR	CLEARMAIN
	BSR.S	PRINTLINE
	BSR.S	FIREOFF
	MOVE.L	A4,A0
	BRA	MAINFADE

PRINTLINE	MOVE.L	SCREENON+2,A0
FASTLINE	MOVE.L	A0,A1
	BSR	WVBL
.LINE	MOVE.B	(A6)+,D1
	BNE.S	.DOCHAR
	RTS
.DOCHAR	CMPI.B	#13,D1
	BNE.S	.OUTCHAR
	ADDA.W	#16*160,A0
	MOVE.L	A0,A1
	BRA.S	.LINE
.OUTCHAR	BSR	FASTCHAR
	BRA.S	.LINE

FIREOFF	BTST	#4,JOYSTICK+1
	BEQ.S	FIREOFF
	RTS

SETNAME	MOVE.L	A5,A0
	LEA	INPUTNAME,A1
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	RTS

GETNAME	ADDQ.B	#1,PLAYERNUMBER
	BSR.S	SETNAME	COPY NAME TO INPUTNAME
	BSR.S	FIREOFF
	LEA	ALLWHITE,A0
	BSR	MAINFADE
	MOVE.L	SCREENON+2,A1
	ADDA.W	#48*160+104,A1
	MOVE.B	PLAYERNUMBER,D1
	BSR	PRINTCHAR
	MOVE.L	A4,A6
	MOVE.L	SCREENON+2,A0
	ADDA.W	#144*160+56,A0
	BSR.S	FASTLINE
	LEA	TEXTCOLORS,A0
	BSR	MAINFADE
	MOVEQ	#0,D3	FIRST CHARACTER
GETNAME1	MOVE.B	0(A4,D3.W),D4	GET CHARACTER
GETNAME2	MOVEQ	#4,D2
	BSR	DELAY
	CLR.W	$468.W	COUNTER FOR BLINK
GETNAME3	MOVE.W	$468.W,D0	GET COUNT FOR BLINK
	ANDI.W	#$1F,D0	BLINK ON ?
	BNE.S	.NOTZERO	NO
	MOVE.B	D4,0(A4,D3.W)	DISPLAY CHAR
	BRA.S	.PRINTIT	IN TEXT
.NOTZERO	CMPI.W	#$10,D0	BLINK OFF ?
	BNE.S	.NOTBLINK	NO
	MOVE.B	#" "+128,0(A4,D3.W)    DISPLAY SPACE
.PRINTIT	MOVE.L	A4,A6	IN TEXT
	MOVE.L	SCREENON+2,A0
	ADDA.W	#144*160+56,A0
	BSR	FASTLINE
.NOTBLINK	MOVE.B	JOYSTICK+1,D0	READ JOYSTICK
	BTST	#4,D0
	BEQ.S	GOTNAME
	BTST	#0,D0	UP ?
	BEQ.S	.NOTUP	NO
	CMPI.B	#$8C,D4	CHAR=SPC ?
	BNE.S	.NOTSPACE	NO
	MOVEQ	#"A"+128,D4	CHANGE TO AN A
	BRA.S	GETNAME2
.NOTSPACE	CMPI.B	#"Z"+128,D4	CHAR=Z ?
	BEQ.S	.ASPACE	YES, SET TO SPC
	ADDQ	#1,D4	ELSE JUST ADD 1
	BRA.S	GETNAME2
.NOTUP	BTST	#1,D0	DOWN ?
	BEQ.S	.NOTDOWN	NO
	CMPI.B	#$8C,D4	CHAR=SPC ?
	BNE.S	.NOTSPACE1	NO
	MOVEQ	#"Z"+128,D4	CHANGE TO A Z
	BRA.S	GETNAME2
.NOTSPACE1	CMPI.B	#"A"+128,D4	CHAR=A ?
	BNE.S	.NOTA	NO
.ASPACE	MOVEQ	#$8C,D4	SET CHAR TO A SPC
	BRA.S	GETNAME2
.NOTA	SUBQ	#1,D4	ELSE JUST SUBTRACT 1
	BRA.S	GETNAME2
.NOTDOWN	BTST	#2,D0	LEFT ?
	BEQ.S	.NOTLEFT	NO
	MOVE.B	D4,0(A4,D3.W)	ENSURE CHAR DISPLAYED
	SUBQ.W	#1,D3
	BPL.S	.MOVED
	MOVEQ	#4,D3
	BRA.S	.MOVED
.NOTLEFT	BTST	#3,D0	RIGHT ?
	BEQ	GETNAME3	NO
	MOVE.B	D4,0(A4,D3.W)
	ADDQ.W	#1,D3
	CMPI.W	#5,D3
	BNE.S	.MOVED
	MOVEQ	#0,D3
.MOVED	MOVE.B	0(A4,D3.W),D4
	MOVEQ	#4,D2
	BSR	DELAY
	MOVE.W	#$10,$468.W
	BRA	GETNAME3
GOTNAME	MOVE.B	D4,0(A4,D3.W)	ENSURE CHAR
	MOVE.L	A4,A6	IN TEXT
	MOVE.L	SCREENON+2,A0
	ADDA.W	#144*160+56,A0
	BSR	FASTLINE
	MOVE.L	A4,A0
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	CLR.B	(A5)+
	MOVE.W	NUMBEROFPLAYERS,D0
	ADDQ	#1,D0
	CMP.B	PLAYERNUMBER,D0
	BNE	GETNAME

	LEA	INPUTNAME1,A0
	LEA	PLAYER1NAME,A1
	MOVEQ	#5,D2
.COPY1	MOVEQ	#4,D0
.COPY	MOVE.B	(A0)+,D1
	ANDI.W	#$7F,D1
	CMPI.W	#$C,D1
	BEQ.S	.SPACE
	SUBI.W	#65,D1
	BRA.S	.GOTIT
.SPACE	MOVEQ	#39,D1
.GOTIT	MOVE.W	D1,(A1)+
	DBF	D0,.COPY
	ADDQ	#1,A0
	DBF	D2,.COPY1
	BRA	SELECTION

*	ROUTINE FOR PLAYER FINISHED COURSE OR DEAD

SELECTLEVEL	TST.B	DEDONE+1
	BEQ.S	SELECTLEVEL
	CLR.B	DEFLAG+1	DISABLE SPLIT SCREEN

PRACTICE	MOVEQ	#0,D0	PRACTISING ?
	BNE	MAIN	YES

*	RELOAD AND START TUNE HERE ?

	CMPI.W	#-1,CRASH+2	COMPLETED COURSE ?
	BNE.S	NEWSELECT	NO
	CMPI.L	#4,CURRENTLEVEL	LAST SECTION ?
	BNE.S	NEWSELECT	NO
	CMPI.W	#1,LEVELCOUNT	LAST COURSE ?
	BNE.S	NEWSELECT	NO

*	LOAD CONGRATULATIONS SCREEN

	LEA	ENDFILE,A0
	MOVE.L	BLITBASE+2,A1
	BSR	LOADFILE

	MOVE.L	BLITBASE+2,A0
	MOVE.L	SCREENON+2,A1	DISPLAY SCREEN
	BSR	DECOMPRESS

	LEA	PIC4PAL,A0
	BSR	MAINFADE

UNTILJOY	BTST.B	#4,JOYSTICK+1
	BNE.S	UNTILJOY

NEWSELECT	MOVE.W	PLAYER+2,D0	PLAYER JUST GONE
	MOVE.W	D0,D1
	SUBQ	#1,D0
	LSL.W	#2,D0
	LEA	PLAYER1SCORE,A0
	MOVE.L	SCORE+2,0(A0,D0.W)  STORE NEW SCORE

	CMPI.W	#-2,CRASH+2	DIED ?
	BNE.S	NOTENDED	NO

	LEA	PLAYERSOUT-1,A0
	MOVE.B	#-1,0(A0,D1.W)
	ADDQ.W	#1,ENDCOUNT+2

ENDCOUNT	CMPI.W	#-1,NUMBEROFPLAYERS
	BEQ.S	GAMEND

NOTENDED	CMP.W	NUMBEROFPLAYERS,D1    LAST PLAYER ?
	BLS.S	NOTNEXTLEVEL	NO

	MOVEQ	#0,D1
	SUBQ.W	#1,LEVELCOUNT
	BNE.S	NOTNEXTLEVEL

	MOVE.W	#3,LEVELCOUNT
	ADDQ.L	#1,CURRENTLEVEL
PROTECT	CMPI.L	#5,CURRENTLEVEL	CHANGE TO #1, !!
	BNE.S	NOTNEXTLEVEL

GAMEND	MOVE.W	#-1,ENDCOUNT+2
	BRA	MAIN

NOTNEXTLEVEL	ADDQ	#1,D1	NEXT PLAYER
	LEA	PLAYERSOUT-1,A0
	TST.B	0(A0,D1.W)
	BNE.S	NOTENDED

	MOVE.W	D1,PLAYER+2

*	COURSE SELECTION

SELECTION	BSR	WVBL
	MOVE.L	#TUNE1,TUNEADD+2
	MOVE.B	#-1,LOOPFLAG+1
	MOVE.B	#1,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
	MOVE.W	PLAYER+2,D0
	MOVE.B	D0,SELECTPLAYER
	LEA	PLAYER1SCORE,A0
	SUBQ	#1,D0
	LSL.W	#1,D0	*2
	MOVE.W	D0,D1
	LSL.W	#1,D0	*4
	MOVE.L	0(A0,D0.W),SCORE+2
	ADD.W	D1,D0	=*6
	LEA	INPUTNAME1,A0
	ADDA.W	D0,A0
	LEA	SELECTNAME,A1
	MOVEQ	#4,D0
.LOOP	MOVE.B	(A0)+,D1
	CMPI.B	#$8C,D1
	BNE.S	.NOTSPC
	MOVE.B	#" "+128,D1
.NOTSPC	MOVE.B	D1,(A1)+
	DBF	D0,.LOOP
	MOVE.L	CURRENTLEVEL,D0
	MOVE.B	D0,D1
	ADDI.B	#$81,D1
	MOVE.B	D1,SELECTSECTION
	MOVE.W	D0,D1	*1
	LSL.W	#1,D0	+*2
	ADD.W	D0,D1	=*3
	MOVE.B	D1,LEVELDONE+1
	ADDI.W	#"A",D1
	MOVE.B	D1,SELECTCOURSE1
	ADDQ	#1,D1
	MOVE.B	D1,SELECTCOURSE2
	ADDQ	#1,D1
	MOVE.B	D1,SELECTCOURSE3
	MOVE.L	CURRENTLEVEL,D0
	MULU	#9,D0
	LEA	LEVELTIMES,A0
	ADDA.W	D0,A0
	MOVE.B	(A0)+,SELECTTIME1
	MOVE.B	(A0)+,SELECTTIME2
	MOVE.B	(A0)+,SELECTTIME3
	MOVE.B	(A0)+,SELECTTIME4
	MOVE.B	(A0)+,SELECTTIME5
	MOVE.B	(A0)+,SELECTTIME6
	MOVE.B	(A0)+,SELECTTIME7
	MOVE.B	(A0)+,SELECTTIME8
	MOVE.B	(A0)+,SELECTTIME9

	LEA	NOCOLORS,A4	COLOR PALLET
	LEA	SELECTTEXT,A6	SELECTION TEXT
	BSR	INPUT	PRINT SCREEN

	MOVE.W	#28,SPLIT+2

	LEA	DONETIMES,A3
	MOVE.L	CURRENTLEVEL,D0
	MULU	#72,D0
	ADDA.W	D0,A3
	MOVE.W	PLAYER+2,D0
	SUBQ.W	#1,D0
	MOVE.W	D0,D1
	LSL.W	#1,D0	*2
	ADD.W	D1,D0	*3
	LSL.W	#2,D0	*12
	ADDA.W	D0,A3
	MOVEQ	#0,D1
.CHECK	TST.L	0(A3,D1.W)
	BEQ.S	.HERE
	ADDQ.W	#4,D1
	BRA.S	.CHECK
.HERE	LEA	TEXTCOLORS,A1
	BSR.S	COURSEPAL
	MOVE.B	#1,DEFLAG+1	ENABLE SPLIT SCREEN

.WAIT	MOVE.B	JOYSTICK+1,D0
	BTST	#4,D0
	BEQ	GOTCOURSE
	BTST	#3,D0
	BNE.S	.UP
	BTST	#1,D0
	BEQ.S	.NOTUP
.UP	ADDQ	#4,D1
	CMPI.W	#12,D1
	BNE.S	.UPOK
	MOVEQ	#0,D1
.UPOK	TST.L	0(A3,D1.W)
	BNE.S	.UP
	BRA.S	.SHOWSELECT
.NOTUP	BTST	#2,D0
	BNE.S	.DOWN
	BTST	#0,D0
	BEQ.S	.WAIT
.DOWN	SUBQ	#4,D1
	BPL.S	.DOWNOK
	MOVEQ	#8,D1
.DOWNOK	TST.L	0(A3,D1.W)
	BNE.S	.DOWN
.SHOWSELECT	BSR.S	COURSEPAL1
	MOVEQ	#8,D2
	BSR	DELAY
	BRA.S	.WAIT

*	ROUTINE TO SET UP SPLIT PALLETS FOR COURSE SELECTION

COURSEPAL	BSR	WVBL
	LEA	MAINPAL,A0
	BSR.S	PALLET
	BRA.S	COURSEPAL2
COURSEPAL1	BSR	WVBL
.WAIT	CMPI.B	#3,DENUMBER+1
	BNE.S	.WAIT
	LEA	PLANPAL,A0
COURSEPAL2	MOVEQ	#0,D0
.LOOP	CMP.W	D0,D1
	BEQ.S	.HIGH
	TST.L	0(A3,D0.W)
	BNE.S	.LOW
	LEA	TEXTCOLORS,A2
	BRA.S	.DOIT
.HIGH	LEA	HICOLORS,A2
	BRA.S	.DOIT
.LOW	LEA	LOCOLORS,A2
.DOIT	BSR.S	PALLET1
	ADDQ	#4,D0
	CMPI.W	#12,D0
	BNE.S	.LOOP
	RTS

PALLET1	MOVE.L	A2,A1
PALLET	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	RTS

*	EXIT HAVING CHOSEN A COURSE

GOTCOURSE	ADDA.W	D1,A3
	MOVE.L	A3,USETIME+2
	LSR.W	#2,D1
	ADD.B	D1,LEVELDONE+1
	LEA	MAINPAL,A0
	LEA	NOCOLORS,A2
	BSR	WVBL
.WAIT	CMPI.B	#3,DENUMBER+1
	BNE.S	.WAIT
	MOVEQ	#3,D0
.LOOP	BSR.S	PALLET1
	DBF	D0,.LOOP
	CLR.B	DEFLAG+1
	MOVE.W	#37,SPLIT+2

LEVELDONE	MOVEQ	#0,D0
	MOVE.W	D0,D1
	LSL.W	#2,D1
	LEA	TIMES,A0
	MOVE.W	0(A0,D1.W),D2
	MOVE.W	D2,STARTMIN+2
	MOVE.W	D2,MINUTES+2
	MOVE.W	2(A0,D1.W),D2
	MOVE.W	D2,STARTSEC+2
	MOVE.W	D2,SECONDS+2
LASTLEVEL	CMPI.W	#-1,D0
	BEQ	STARTCOURSE
	MOVE.W	D0,LASTLEVEL+2
	ADDI.W	#"A",D0
	MOVE.B	D0,NEWTOPS
	CMPI.B	#"D",D0
	BCS.S	MUD
	CMPI.B	#"G",D0
	BCS	CON
	CMPI.B	#"J",D0
	BCS.S	GRASS
	CMPI.B	#"M",D0
	BCS	CON
MUD	MOVEQ	#"M",D0
	MOVE.L	#MUDINTRNL,INTHGHTS+2
	MOVE.L	#MTRCTN,TRACTION
	MOVE.L	#MSPEEDS,SPEEDS
	MOVE.L	#MBHGHTS,BLCKHGHTS
	MOVE.W	#GBHGHTS-MBHGHTS,LENGTH+2
	MOVE.W	#9,MAXBRAKE+2
	BRA.S	MUDGRASS
GRASS	MOVEQ	#"G",D0
	MOVE.L	#GRSINTRNL,INTHGHTS+2
	MOVE.L	#GTRCTN,TRACTION
	MOVE.L	#GSPEEDS,SPEEDS
	MOVE.L	#GBHGHTS,BLCKHGHTS
	MOVE.W	#CBHGHTS-GBHGHTS,LENGTH+2
	MOVE.W	#19,MAXBRAKE+2
MUDGRASS	CMP.B	SPRITEFILE,D0
	BEQ	SAMETYPE
	MOVEQ	#"M",D1
	MOVE.W	#$50,COLOUR1
	MOVE.W	#$60,COLOUR2
	MOVE.W	#$532,COLOUR3
	MOVE.L	#$FFFFFFFF,PLANES12
	MOVE.L	#$FFFF,PLANES34
	CLR.L	GRND1+2
	MOVE.L	#$FFFF,GRND2+2
	BRA	SETNAMES
CON	MOVEQ	#"C",D0
	MOVE.L	#CONINTRNL,INTHGHTS+2
	MOVE.L	#CTRCTN,TRACTION
	MOVE.L	#CSPEEDS,SPEEDS
	MOVE.L	#CBHGHTS,BLCKHGHTS
	MOVE.W	#ENDHGHTS-CBHGHTS,LENGTH+2
	CMP.B	SPRITEFILE,D0
	BEQ	SAMETYPE
	MOVE.B	D0,D1
	MOVE.W	#29,MAXBRAKE+2
	MOVE.W	#$555,COLOUR1
	MOVE.W	#$333,COLOUR2
	MOVE.W	#$550,COLOUR3
	MOVE.L	#$FFFFFFFF,PLANES12
	MOVE.L	#$0,PLANES34
	MOVE.L	#$FFFF,GRND1+2
	MOVE.L	#$FFFF0000,GRND2+2
SETNAMES	MOVE.B	D1,BACKFILE
	MOVE.B	D0,SPRITEFILE
	MOVE.B	D0,MASKFILE
	MOVE.B	D0,GRADFILE
	MOVE.B	D0,TVIEWFILE

*	LOAD BACKGROUND

NEWTYPE	LEA	BACKFILE,A0
	MOVE.L	BLITBASE+2,A1
	BSR	LOADFILE

*	EXPAND

	MOVE.L	BLITBASE+2,A0
	LEA	PLANVIEW,A1
	BSR	unpack

*	EXPAND BACKGROUND

	LEA	PLANVIEW,A0
	LEA	BACKGROUND,A1
	LEA	BACKGROUND+256,A2
	LEA	BACKGROUND+512,A3

	MOVEQ	#47,D0	48 LINES

.LOOP	MOVE.L	A1,A4
	MOVE.L	A2,A5
	MOVE.L	A3,A6
	MOVEQ	#63,D1	64 LONG WORDS

.LOOP1	MOVE.L	(A0),(A4)+
	MOVE.L	(A0),(A5)+
	CMPI.W	#32,D1
	BCS.S	.HALFDONE
	MOVE.L	(A0),(A6)+
.HALFDONE	ADDQ	#4,A0

	DBF	D1,.LOOP1

	ADDA.W	#640,A1
	ADDA.W	#640,A2
	ADDA.W	#640,A3
	DBF	D0,.LOOP

	LEA	PROTECT+2,A6

*	LOAD INTERNAL BLOCK HEIGHTS

INTHGHTS	MOVE.L	#MUDINTRNL,A0
	LEA	HEIGHTS,A1
	BSR	unpack

*	LOAD BLOCK GRADIENTS

	LEA	GRADFILE,A0
	MOVE.L	BLITBASE+2,A1
	BSR	LOADFILE

*	EXPAND

	MOVE.L	BLITBASE+2,A0
	LEA	GRADIENTS,A1
	BSR	unpack

*	LOAD BLOCKS

	LEA	SPRITEFILE,A0
	LEA	BLOCKS,A1
	BSR	LOADFILE

LOADED	MOVE.L	#0,A1	LENGTH OF FILE LOADED
	ADD.L	#BLOCKS,A1	START OF BLOCKS
	MOVE.L	A1,BLOCKADDS	PUT TABLE HERE
	MOVE.L	BLCKHGHTS,A0
	MOVE.L	A0,A2	COPY AS END OF HEIGHTS
LENGTH	ADDA.W	#0,A2

*	BUILD BLOCK POINTERS TABLE

	MOVE.L	#BLOCKS,(A1)	FIRST BLOCK STARTS HERE
	MOVEQ	#0,D1	NUMBER OF BLOCKS

.LOOP	MOVE.B	(A0)+,D0	BLOCK HEIGHT
	BEQ.S	.DONE
	ADDQ	#1,D1
	MOVE.L	(A1)+,A3	BLOCK BASE
	EXT.W	D0
	LSL.W	#4,D0	*16 (2*4 PLANES PER LINE)
	ADDA.W	D0,A3	START OF NEXT BLOCK
	MOVE.L	A3,(A1)
	CMP.L	A0,A2	END OF HEIGHTS ?
	BNE.S	.LOOP	NO
.DONE	MOVE.L	A1,MASKBASE+2	STORE BASE OF MASKS

*	LOAD MASKS

	LEA	MASKFILE,A0
	BSR	LOADFILE

	MOVE.L	BLCKHGHTS,A0	HEIGHTS TABLE
	MOVE.L	A0,A2
	ADDA.W	LENGTH+2,A2	END OF HEIGHTS TABLE
	MOVE.L	MASKBASE+2,A1	MASKS
	ADD.L	LOADED+2,A1	MASK POINTERS GO HERE
	MOVE.L	A1,MASKADDS

*	BUILD MASK POINTERS TABLE

MASKBASE	MOVE.L	#0,(A1)

.LOOP	MOVE.B	(A0)+,D0	BLOCK HEIGHT
	BEQ.S	.DONE
	MOVE.L	(A1)+,A3	MASK BASE
	EXT.W	D0
	LSL.W	#3,D0	*8 (2 LONG WORD MASKS PER LINE)
	ADDA.W	D0,A3	START OF NEXT BLOCK
	MOVE.L	A3,(A1)
	CMP.L	A0,A2	END OF HEIGHTS ?
	BNE.S	.LOOP	NO

*	NB. A1=FREE SPACE AFTER MASK TABLE

.DONE	MOVE.L	A1,BLOCK0	START OF COURSE DATA

*	PROTECTION CHECK

*	MOVE.L	BLITBASE+2,A0
*	BSR	check_prot

*	LOAD TOPBLOCK OFFSETS

SAMETYPE	LEA	TOPFILE,A0
	LEA	TOPBLOCKS,A1
	BSR	LOADFILE

*	LOAD REST ANGLES

	LEA	ANGLETABLE,A0
	MOVE.B	LEVELDONE+1,D0
	EXT.W	D0
	LSL.W	#2,D0
	MOVE.L	0(A0,D0.W),A0
	LEA	RANGLES,A1
	BSR	unpack

*	LOAD COURSE

	LEA	COURSETABLE,A0
	MOVE.B	LEVELDONE+1,D0
	EXT.W	D0
	LSL.W	#2,D0
	MOVE.L	0(A0,D0.W),A0
	MOVE.L	BLOCK0,A1
	BSR	unpack

*	CONVERT OFFSETS TO ADDRESSES

	MOVE.L	BLOCK0,D0
	LEA	TOPBLOCKS,A0
	MOVE.W	#250,D1
SETTOPBLCKS	ADD.L	D0,(A0)+
	DBF	D1,SETTOPBLCKS

*	LOAD TOP VIEW MAP

	LEA	PLANTABLE,A0
	MOVE.B	LEVELDONE+1,D0
	EXT.W	D0
	LSL.W	#2,D0
	MOVE.L	0(A0,D0.W),A0
	LEA	PLANMAP,A1
	BSR	unpack

*	LOAD TOP VIEW BLOCKS

	LEA	TVIEWFILE,A0
	LEA	PLANVIEW,A1
	BSR	LOADFILE

*	EXPAND

	LEA	PLANVIEW,A0
	MOVE.L	BLITBASE+2,A1
	BSR	unpack

*	NOW BUILD PLAN VIEW FROM BLOCKS AND MAP

BUILDPLAN	LEA	PLANMAP+8,A0
	LEA	PLANVIEW,A1
	MOVEQ	#3,D0	4 BLOCKS HIGH

.LOOP	MOVE.L	A1,A2	COPY FOR EACH LINE OF BLOCKS
	MOVE.W	#129,D1	130*2 BLOCKS PER LINE

.LOOP1	MOVE.L	A2,A3	COPY FOR START OF EACH 2 BLOCKS
	MOVE.L	BLITBASE+2,A4
	MOVE.L	A4,A5
	MOVE.B	(A0)+,D2	1ST BLOCK NO.
	EXT.W	D2
	LSL.W	#5,D2	*32
	ADDA.W	D2,A4
	MOVE.B	(A0)+,D2	2ND BLOCK NO.
	EXT.W	D2
	LSL.W	#5,D2
	ADDA.W	D2,A5
	MOVEQ	#7,D2	8 LINES HIGH

.LOOP2	MOVE.B	(A4)+,(A3)+
	MOVE.B	(A5)+,(A3)+
	MOVE.B	(A4)+,(A3)+
	MOVE.B	(A5)+,(A3)+
	MOVE.B	(A4)+,(A3)+
	MOVE.B	(A5)+,(A3)+
	MOVE.B	(A4)+,(A3)+
	MOVE.B	(A5)+,(A3)+
	ADDA.W	#1032,A3	NEXT LINE
	DBF	D2,.LOOP2

	ADDQ	#8,A2	NEXT 2 BLOCK PSTN
	DBF	D1,.LOOP1

	ADDA.W	#1040*8,A1	NEXT LINE OF BLOCKS
	DBF	D0,.LOOP

	LEA	PLANVIEW,A0
	MOVEQ	#31,D0	32 LINES

.LOOP3	MOVE.W	D0,D1	COPY FOR ROTATION
	LSR.W	#1,D1	0-15
	MOVE.W	#259,D2	260 LONG WORDS PER LINE

.LOOP4	MOVE.L	(A0),D3
	ROR.L	D1,D3
	MOVE.L	D3,(A0)+
	DBF	D2,.LOOP4

	DBF	D0,.LOOP3

*	ALL DATA SET UP NOW START PLAY

STARTCOURSE	MOVE.L	#320*24*65536,RESETPOS+2
	BSR	WVBL
	MOVE.B	#-1,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
	BSR	WVBL
	MOVE.L	#TUNE2,TUNEADD+2
	CLR.B	LOOPFLAG+1
	MOVEQ	#3,D0
	MOVE.B	LEVELDONE+1,D1
	CMPI.B	#6,D1
	BLT.S	EASY
	ADDQ	#1,D0
	CMPI.B	#12,D1
	BLT.S	EASY
	ADDQ	#4,D0
EASY	MOVE.B	D0,RESETSTART+1
	MOVE.B	D0,RESETCOUNT+1
	MOVE.B	#-1,RESETMOVE+1
	MOVE.B	#-1,STARTFLAG+1
	CLR.B	SNDFLAG+1	TURN SOUND OFF/INIT CHIP

*	ASSUME AT THIS POINT THAT FLIP IS DISABLED
*	IF NOT AT START THEN ALL PALLETS ARE ZEROED
*	IF AT START THEN DEIRQ IS OFF AND PALLETS NEED ZEROING

RESETPOS	MOVE.L	#0,D0
	MOVE.W	#14,BIKEZ+2
	MOVE.B	#3,BFATT+1
	MOVE.B	#3,OLDBFATT+1
	CLR.L	ACCEL+2
	CLR.L	XSPEED+2
	CLR.L	YSPEED+2
	CLR.L	COMSPEED+2
*	CLR.L	SPRAYVAL+2
	CLR.B	REVS+1
	CLR.B	OLDREVS+1
	CLR.W	DRAWSCREEN1+2
	CLR.W	SNDREVS+2
	CLR.W	CRASH+2
	MOVE.B	#-1,GEAR+1	NOT YET STARTED
	CLR.B	FLAGTEST+1	ENSURE CLOCK IS OFF

	LEA	TOPBLOCKS,A1
	LEA	HEIGHTS,A2
	LEA	RANGLES,A4
	LEA	BIKEDIFFS,A5
RESETMOVE	MOVEQ	#-1,D1
	BNE.S	RESETOK
	SWAP	D0
	ADDI.W	#320-80,D0	BACK WHEEL
	LSR.W	#3,D0
	ANDI.W	#$FFFC,D0
SEARCH	SUBQ.W	#4,D0
	MOVE.L	0(A1,D0.W),A6
ALLCOLUMN	MOVE.W	4(A6),D1
	BTST	#10,D1
	BNE.S	FOUNDRESET
	TST.W	(A6)
	BMI.S	SEARCH
	ADDQ	#6,A6
	BRA.S	ALLCOLUMN

FOUNDRESET	BTST	#13,D1
	BNE.S	LASTONE
	LSL.W	#3,D0
	SUBI.W	#320-80,D0	MAP POS
	SWAP	D0
	MOVE.L	D0,RESETPOS+2
	SUBI.W	#2000,SECONDS+2
	BPL.S	RESETOK
	ADDI.W	#6000,SECONDS+2
	SUBQ.W	#1,MINUTES+2
	BPL.S	RESETOK
	CLR.W	SECONDS+2
	CLR.W	MINUTES+2
	BRA.S	RESETOK
LASTONE	MOVE.L	RESETPOS+2,D0

RESETOK	SWAP	D0
FINDFLAT	MOVE.B	0(A4,D0.W),D1	GET REST ANGLE
	BEQ.S	FOUNDFLAT
	SUBQ.W	#1,D0
	BRA.S	FINDFLAT
FOUNDFLAT	CLR.W	ANGLE+2
	CLR.W	NEWANGLE+2
	SWAP	D0
	MOVE.L	D0,BIKEX+2
	SWAP	D0
	ADDI.W	#320-64,D0	TO START OF BIKE BLOCK
	MOVE.L	(A5),D2	ALL 4 OFFSETS
	MOVE.L	D2,D3
	LSR.L	#8,D2
	ANDI.W	#$FF,D2
	ANDI.L	#$FF00FF,D3	BACK HEIGHT
	SWAP	D2
	NEG.W	D2
	ADD.W	D0,D2
	MOVE.W	D2,MAPFRONT+2
	SWAP	D2
	NEG.W	D2
	ADD.W	D0,D2
	MOVE.W	D2,MAPBACK+2
	MOVE.W	D2,D5
	LSR.W	#3,D5
	ANDI.W	#$FFFC,D5
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDTOP0	TST.W	(A6)+
	BMI.S	FOUNDTOP0
	ADDQ	#4,A6
	BRA.S	FINDTOP0
FOUNDTOP0	MOVE.W	(A6)+,D5	Y POSITION OF BLOCK TOP
	MOVE.W	(A6)+,D6
	ANDI.W	#$FF,D6	BLOCK ID
	MOVE.W	D6,BACKID+2
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6
	ANDI.W	#$1F,D2	PIXEL POSITION
	SUB.W	D2,D6
	MOVE.B	0(A2,D6.W),D2
	ADD.W	D2,D5
	MOVE.W	D5,YBACK+2
	MOVE.W	D5,YFRONT+2
	ADD.W	D3,D5
	SWAP	D5
	CLR.W	D5
	MOVE.L	D5,BIKEY+2
	MOVE.W	MAPFRONT+2,D5
	LSR.W	#3,D5
	ANDI.W	#$FFFC,D5
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDFID	TST.W	(A6)+
	BMI.S	FOUNDFID
	ADDQ	#4,A6
	BRA.S	FINDFID
FOUNDFID	ADDQ	#2,A6
	MOVE.W	(A6)+,D6
	ANDI.W	#$FF,D6	BLOCK ID
	MOVE.W	D6,FRONTID+2

STARTFLAG	MOVEQ	#-1,D0	AT COURSE START ?
	BEQ.S	RESTART	NO, SCREENS BLACK
	CLR.B	SNDSTRT+1	NO REVS YET
	MOVE.B	#-1,DEFLAG+1	ENABLE SPLIT SCREEN
	LEA	PANELSCRN,A0	EXPAND SMALL BIKES
	MOVE.L	BLITBASE+2,A1	AND PANEL TO BLITSCREEN
	BSR	DECOMPRESS
	MOVE.L	BLITBASE+2,A0	COPY PANEL
	ADDA.W	#138*160,A0	FROM BLITSCREEN
	MOVE.L	SCREENON+2,A1	TO DISPLAY SCREEN
	ADDA.W	#138*160,A1
	MOVE.W	#2479,D0
.COPY	MOVE.L	(A0)+,(A1)+
	DBF	D0,.COPY
RESTART	MOVE.L	BLITBASE+2,A0	COPY PLAN AREA
	ADDA.W	#96*160,A0	BACK TO VIEW SCREEN
	MOVE.L	SCREENON+2,A1	FROM THE FLIP SCREEN
	ADDA.W	#96*160,A1
	MOVE.W	#1679,D0
.COPY	MOVE.L	(A0)+,(A1)+
	DBF	D0,.COPY
	MOVE.L	#COLORUP,MAINLOOP+2
	BSR	FIREOFF
	BRA	DRAWSCREEN1	NO FLIP WAIT !!

COLORUP	BSR	WVBL	ENSURE COUNTER JUST DONE
	MOVE.W	#4,$468.W	SET UP TO FLIP NEXT TIME
	CLR.B	FLIPFLAG+1	ENABLE SCREEN FLIP
WAITFIRST	TST.W	$468.W	DONE FLIP ?
	BNE.S	WAITFIRST	NO
	LEA	COLOURS,A0	MAIN COLOURS
	LEA	PLANCOLORS,A4	PLAN COLOURS
	LEA	PANELCOLORS,A5	PANEL COLOURS
	BSR	ALLFADE

	TST.B	STARTFLAG+1
	BEQ	ENGINEON

*	ROUTINE TO WAIT FOR JOYSTICK AND GO BEEP-BEEP
*	SET LOOP TO JUMP BACK TO DRAWSCREEN

	CLR.B	STARTFLAG+1
	MOVE.L	#JOYSTART,MAINLOOP+2
	BRA	DRAWSCREEN

JOYSTART	BTST.B	#4,JOYSTICK+1
	BNE	DRAWSCREEN
	MOVE.W	#20,SOUNDCOUNT
	MOVE.L	#COUNTDOWN,MAINLOOP+2
	MOVE.B	#1,SNDFLAG+1
	BRA	CRASH

COUNTDOWN	SUBQ.W	#1,SOUNDCOUNT
	CMPI.W	#5,SOUNDCOUNT
	BNE	CRASH
	MOVE.B	#2,SNDFLAG+1
	MOVE.L	#LASTBIT,MAINLOOP+2
	BRA	CRASH

KEYREAD	MOVEQ	#0,D0
	BEQ.S	NOKEYS
	CLR.B	KEYREAD+1
	TST.B	D0
NOKEYS	RTS

LASTBIT	SUBQ.W	#1,SOUNDCOUNT
	BNE	CRASH
	MOVE.B	#3,SNDFLAG+1
	MOVE.B	#-1,SNDSTRT+1
	BRA.S	NOISEON

ENGINEON	MOVE.B	#4,SNDFLAG+1
NOISEON	MOVE.B	#-1,FLAGTEST+1	ENABLE CLOCK
	MOVE.L	#NEWMAIN,MAINLOOP+2
	BRA	DRAWSCREEN

NEWMAIN	BSR.S	KEYREAD
	BPL	CRASH

	CMPI.B	#$B9,D0
	BNE	NOTPAUSE
	BSR	TEXTONPLAN	SWITCH FROM PLAN TO TEXT
	LEA	PAUSETEXT,A6
.LINE	BSR	NEXTCHAR
	BNE.S	.LINE

PAUSED	BSR.S	KEYREAD
	BMI.S	PAUSEOFF
	BTST.B	#4,JOYSTICK+1
	BNE.S	PAUSED

PAUSEOFF	LEA	NOCOLORS,A0
	BSR	PLANFADE
	BRA	RESTART

NOTPAUSE	CMPI.B	#$81,D0
	BNE.S	NOTRESTART
	MOVE.W	#-2,CRASH+2
	BRA.S	CRASH

NOTRESTART	CMPI.B	#$C4,D0
	BNE.S	NOTFIXFADE
	NOT.B	SETFADE+1
	BRA.S	CRASH

NOTFIXFADE	CMPI.B	#$BB,D0
	BNE.S	NOTCHEAT
	MOVE.W	#9,MINUTES+2
	MOVE.W	#6000,SECONDS+2
	BRA.S	CRASH

NOTCHEAT	CMPI.B	#$BC,D0
	BNE.S	NOTCOLL
	NOT.W	COLLIDE+2
	BRA.S	CRASH

NOTCOLL	CMPI.B	#$E2,D0
	BNE.S	NOTCOMPLETE
	MOVE.W	#-1,CRASH+2
	BRA.S	CRASH

NOTCOMPLETE	CMPI.B	#$99,D0
	BNE.S	NOTFREEZE
.WAIT	TST.B	$469.W	WAIT UNTIL FLIP
	BNE.S	.WAIT	IS DONE
	MOVE.B	#-1,FLIPFLAG+1
	BRA	PAUSED

NOTFREEZE	CMPI.B	#$E1,D0
	BEQ	OLDKEYVEC

CRASH	MOVE.W	#0,D0
	BEQ	NOTCRASHED

*	REMOVE THIS BIT

	BMI.S	NOTCHEATING
COLLIDE	MOVE.W	#0,D1
	BEQ.S	NOTCHEATING
	CLR.W	CRASH+2
	BRA	NOTCRASHED

*	TO HERE

NOTCHEATING	BSR.S	TEXTONPLAN

	MOVE.W	CRASH+2,D0
	BMI.S	ENDLEVEL
	LSL.W	#2,D0
	LEA	CRASHES,A6
	MOVE.L	-4(A6,D0.W),A6
	BRA	WAITCRASH

ENDLEVEL	ADDQ.W	#1,D0
	BEQ.S	DONECOURSE
	LEA	GAMEOVER,A6
PLAYER	MOVE.W	#1,D0
	BRA.S	DEADMAN

DONECOURSE	LEA	FINISH,A6
	MOVE.B	LEVELDONE+1,D0
	ADDI.B	#"A",D0
DEADMAN	MOVE.B	D0,NUMBER+1
	BRA	CONGRATS

NEXTCHAR	MOVE.B	(A6)+,D1
	BEQ.S	CHARSDONE
	CMPI.B	#13,D1
	BNE.S	PRINTCHAR
	ADDA.W	#16*160,A0
	MOVE.L	A0,A1
	BRA.S	NEXTCHAR

TEXTONPLAN	TST.B	$469.W	WAIT UNTIL FLIP
	BNE.S	TEXTONPLAN	IS DONE
	MOVE.B	#-1,FLIPFLAG+1	DISABLE FLIP (CLOCK OFF !)
	CLR.B	SNDFLAG+1	SOUND OFF
	BSR	NEWSCORE	CORRECT SCORE ON BOTH SCREENS
	LEA	NOCOLORS,A0
	BSR	PLANFADE	PLAN TO BLACK
	BSR	CLEARTEXT	ALL BLANK
	LEA	TEXTCOLORS,A0
	BSR	PLANFADE	PLAN AREA IN TEXT COLOURS
	MOVE.L	SCREENON+2,A0	CURRENT VIEW SCREEN
	ADDA.W	#101*160,A0	TO TEXT AREA
	MOVE.L	A0,A1
.WAITJOY	BTST.B	#4,JOYSTICK+1
	BEQ.S	.WAITJOY
CHARSDONE	RTS

PRINTCHAR	MOVEQ	#1,D2
	BSR	DELAY
FASTCHAR	MOVE.B	D1,D0
	ANDI.W	#$7F,D1
	CMPI.W	#"!",D1
	BNE.S	NOTEXCLM
	MOVEQ	#38,D1
	BRA.S	PRINTIT
NOTEXCLM	CMPI.W	#" ",D1
	BNE.S	NOTSPACE
	MOVEQ	#26,D1
	BRA.S	PRINTIT
NOTSPACE	CMPI.W	#10,D1	NUMBER ?
	BCS.S	ANUMBER
	BNE.S	NOTNUMBER
	MOVEQ	#0,D1
ANUMBER	ADDI.W	#27,D1
	BRA.S	PRINTIT
NOTNUMBER	CMPI.W	#".",D1
	BNE.S	NOTFULLSTOP
	MOVEQ	#39,D1
	BRA.S	PRINTIT
NOTFULLSTOP	SUBI.W	#"A",D1
	CMPI.W	#26,D1
	BCS.S	PRINTIT
	MOVEQ	#37,D1	SPC

PRINTIT	LEA	CRASHTEXT,A3
	LSL.W	#7,D1	SIZE OF A CHARACTER
	ADDA.W	D1,A3	SOURCE
	MOVE.L	A1,A2	DESTINATION
	MOVEQ	#15,D2
PRINT	TST.B	D0	ODD PRINT ?
	BMI.S	PRINTODD	YES
	MOVE.L	(A3)+,(A2)
	MOVE.L	(A3)+,4(A2)
	BRA.S	PRINTED
PRINTODD	MOVE.B	(A3)+,1(A2)
	MOVE.B	(A3)+,8(A2)
	MOVE.B	(A3)+,3(A2)
	MOVE.B	(A3)+,10(A2)
	MOVE.B	(A3)+,5(A2)
	MOVE.B	(A3)+,12(A2)
	MOVE.B	(A3)+,7(A2)
	MOVE.B	(A3)+,14(A2)
PRINTED	ADDA.W	#160,A2	NEXT LINE
	DBF	D2,PRINT
	ADDQ	#8,A1	NEXT CHARACTER POSITION
	TST	D2
	RTS

CLEARMAIN	MOVE.L	SCREENON+2,A0
	MOVEQ	#11,D7
	BSR.S	CLEARTEXT1
	SUBA.W	#8*160,A0
	MOVEQ	#0,D7
	BRA.S	CLEARTEXT1
CLEARTEXT	MOVEQ	#1,D7	2 LINES
SCREENON	LEA	DISPLAY,A0
	ADDA.W	#101*160,A0
	MOVEQ	#1,D7	2 LINES
CLEARTEXT1	MOVEQ	#0,D0	ENSURE EVEN PRINT
	MOVE.L	A0,A1
	MOVEQ	#19,D6	20 CHARS
SPACES	MOVEQ	#26,D1	SPACE
	BSR.S	PRINTIT
	DBF	D6,SPACES
	ADDA.W	#16*160,A0
	DBF	D7,CLEARTEXT1
	RTS

CRASHEXIT	TST.B	(A6)+
	BNE.S	CRASHEXIT
	MOVE.B	(A6),NUMBER+1
	BRA	CRASHDONE

WAITCRASH	BTST.B	#4,JOYSTICK+1
	BEQ.S	CRASHEXIT
	BSR	NEXTCHAR
	BNE.S	WAITCRASH
	MOVE.B	(A6),NUMBER+1

	BSR.S	WAIT2SEC
	BEQ	CRASHDONE
	BSR.S	CLEARTEXT
	LEA	LOSE,A6
	MOVE.L	SCREENON+2,A0
	ADDA.W	#101*160,A0
	MOVE.L	A0,A1

CONGRATS	TST.W	CRASH+2
	BMI.S	NOEXIT
	BTST.B	#4,JOYSTICK+1
	BEQ.S	CRASHDONE
NOEXIT	BSR	NEXTCHAR
	BNE.S	CONGRATS
NUMBER	MOVEQ	#0,D1
	BSR	PRINTCHAR
	MOVE.W	CRASH+2,D0
	BPL.S	ACRASH
	ADDQ.W	#1,D0
	BEQ.S	EXTRAS
	MOVE.B	#1,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
	BRA	ALLOFF
EXTRAS	LEA	COMPLETED,A6
	BRA.S	ENDTEXT

WAIT2SEC	MOVEQ	#99,D2
DELAY	BSR	WVBL
	BTST.B	#4,JOYSTICK+1
	BEQ.S	DELAYDONE
	DBF	D2,DELAY
	MOVEQ	#-1,D0
DELAYDONE	RTS

ACRASH	LEA	LOSE1,A6

ENDTEXT	TST.W	CRASH+2
	BMI.S	NOEXIT1
	BTST.B	#4,JOYSTICK+1
	BEQ.S	CRASHDONE
NOEXIT1	BSR	NEXTCHAR
	BNE.S	ENDTEXT

CRASHDONE	TST.W	CRASH+2
	BMI.S	FINISHED
	BSR.S	WAIT2SEC
RESETCOUNT	MOVEQ	#0,D0
	SUBQ	#1,D0
	BEQ.S	RESETSTART
	MOVE.B	#-1,RESETMOVE+1
	BRA.S	NOTFORWARD
RESETSTART	MOVEQ	#0,D0
	CLR.B	RESETMOVE+1

NOTFORWARD	MOVE.B	D0,RESETCOUNT+1
	MOVE.B	NUMBER+1,D0
	EXT.W	D0
	MULU	#100,D0
	SUB.W	D0,SECONDS+2
	BPL	TEXTOFF
	ADDI.W	#6000,SECONDS+2
	SUBQ	#1,MINUTES+2
	BPL	TEXTOFF
	CLR.W	SECONDS+2
	CLR.W	MINUTES+2
	BRA	TEXTOFF

FINISHED	BSR	WAIT2SEC
	MOVE.W	PLAYER+2,D0
	ADDQ	#1,D0
	CMPI.L	#4,currentlevel
	BNE.S	NOTFINISHED
	CMPI.W	#1,LEVELCOUNT
	BNE.S	NOTFINISHED
	MOVEQ	#0,D0
NOTFINISHED	MOVE.B	D0,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
	BSR	CLEARTEXT
	TST.B	PRACTICE+1
	BNE.S	NOHIGH
STARTMIN	MOVE.W	#0,D0
	SUB.W	MINUTES+2,D0
STARTSEC	MOVE.W	#0,D1
	SUB.W	SECONDS+2,D1
	BPL.S	USETIME
	SUBQ.W	#1,D0
	ADDI.W	#6000,D1
USETIME	LEA	DONETIMES,A2
	MOVE.W	D0,(A2)
	MOVE.W	D1,2(A2)
NOHIGH	LEA	BONUSES,A6
	MOVE.L	SCREENON+2,A0
	ADDA.W	#101*160,A0
	MOVE.L	A0,A1
BONUSTEXT	BTST.B	#4,JOYSTICK+1
	BEQ.S	BONUSDONE
	BSR	NEXTCHAR
	BNE.S	BONUSTEXT

DOBONUS1	BTST.B	#4,JOYSTICK+1
	BEQ.S	BONUSDONE
	TST.W	MINUTES+2
	BEQ.S	MIDSCORE
	ADD.L	#22,SCORE+2
	SUB.W	#132,SECONDS+2
	BPL.S	SCOREOK
	ADD.W	#6000,SECONDS+2
	SUBQ.W	#1,MINUTES+2
	BRA.S	SCOREOK
MIDSCORE	CMPI.W	#1000,SECONDS+2
	BLT.S	SLOWSCORE
	ADD.L	#11,SCORE+2
	SUB.W	#66,SECONDS+2
	BRA.S	SCOREOK
SLOWSCORE	CMPI.W	#6,SECONDS+2
	BLT.S	BONUSDONE
	ADDQ.L	#1,SCORE+2
	SUB.W	#6,SECONDS+2
SCOREOK	BSR	WVBL
	BSR	NEWSCORE
	BRA.S	DOBONUS1

BONUSDONE	MOVE.W	MINUTES+2,D0
	MULU	#600,D0
	MOVE.W	SECONDS+2,D1
	EXT.L	D1
	DIVU	#10,D1
	ADD.W	D1,D0
	CLR.W	MINUTES+2
	CLR.W	SECONDS+2
	EXT.L	D0
	ADD.L	D0,SCORE+2

ALLOFF	BSR	WVBL
	BSR	NEWSCORE
	BSR	FIREOFF
	BSR	WAIT2SEC

TUNEWAIT	TST.B	TUNEFLAG+1
	BEQ.S	TEXTOFF
	BTST.B	#4,JOYSTICK+1
	BNE.S	TUNEWAIT
	MOVE.B	#-1,TUNENO+1
	MOVE.B	#-1,TUNEFLAG+1
.WAIT	TST.B	TUNEFLAG+1
	BNE.S	.WAIT

TEXTOFF	LEA	NOCOLORS,A0
	MOVE.L	A0,A4
	MOVE.L	A4,A5
	BSR	ALLFADE
	BSR	WAITFADE

	TST.W	CRASH+2
	BPL	RESETPOS
	BRA	SELECTLEVEL

NEWSCORE	MOVE.L	SCREENON+2,A3
SCORE	MOVE.L	#0,D0
	MOVE.L	A3,A1
	ADDA.W	#170*160+128,A1
	MOVE.W	#10000,D2
	BSR	ODDSCORE
	MOVE.W	#1000,D2
	BSR	EVENSCORE
	MOVEQ	#100,D2
	BSR	ODDSCORE
	MOVEQ	#10,D2
	BSR	EVENSCORE
	MOVEQ	#0,D2
	BSR	ODDSCORE
MINUTES	MOVE.W	#9,D0
	MOVE.L	A3,A1
	ADDA.W	#170*160+8,A1
	MOVEQ	#0,D2
	BSR.S	EVENSCORE
	ADDQ	#8,A1
SECONDS	MOVE.W	#6000,D0
	MOVE.W	#1000,D2
	BSR.S	EVENSCORE
	MOVEQ	#100,D2
	BSR.S	ODDSCORE
	MOVEQ	#10,D2
	BSR.S	ODDSCORE
	MOVEQ	#0,D2
EVENSCORE	MOVEQ	#0,D3
	BRA.S	DOSCORE
ODDSCORE	MOVEQ	#-1,D3
DOSCORE	TST.W	D2
	BNE.S	NOTUNITS
	MOVE.W	D0,D1
	LSL.W	#5,D1
	BRA.S	GOTDIGIT
NOTUNITS	MOVEQ	#0,D1
GETDIGIT	CMP.W	D2,D0
	BCS.S	GOTDIGIT
	ADDI.W	#32,D1
	SUB.W	D2,D0
	BRA.S	GETDIGIT

GOTDIGIT	LEA	DIGITS,A0
	ADDA.W	D1,A0
	MOVE.L	A1,A2
	TST.W	D3
	BEQ	EVENDIGIT
	ADDQ	#1,A2

DIGLOW	REPT	7

	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDA.W	#154,A2

	ENDR

	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)

	ADDQ	#8,A1
	RTS

EVENDIGIT:
DIGHIGH	REPT	7

	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDA.W	#154,A2

	ENDR

	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)
	ADDQ	#2,A2
	MOVE.B	(A0)+,(A2)

	RTS

*	NB. ROUTINE TO GET REVS AND JOIYSTICK MOVEMENT ETC.
*	D2=GEAR FLAG D3=ACCEL FLAG D4=GEAR NO. D5=BFATT D6=REVS

NOTCRASHED	CLR.W	CHANGE+2	NOT LIFTING
	MOVEQ	#0,D2	GEARCHANGE FLAG
	MOVEQ	#0,D3	ACCELERATION FLAG
	MOVE.B	BFATT+1,D5
GEAR	MOVEQ	#0,D4	GEAR NO. -1,0,1,2
	BMI.S	REVS	NOT IN GEAR
	BTST	#1,D5	BACK ON GROUND ?
	BEQ.S	REVS	NO
	MOVE.L	COMSPEED+2,D6	CURRENT SPEED
	TST.W	D4	FIRST GEAR ?
	BNE.S	NOTG1	NO
	MOVE.W	#8,D1	*256
	BRA.S	SETREVS
NOTG1	CMPI.W	#1,D4	SECOND GEAR ?
	BNE.S	NOTG2	NO
	LSR.L	#7,D6	SPEED/128
	DIVU	#3,D6
	BRA.S	SNDREVSDONE
NOTG2	MOVE.W	#7,D1	*128
SETREVS	LSL.L	D1,D6	DO SUM
	SWAP	D6	HIGH WORD ONLY
SNDREVSDONE	MOVE.W	D6,SNDREVS+2
	LSR.W	#4,D6
	BRA.S	REVSDONE
REVS	MOVEQ	#0,D6	USE LAST REVS
	MOVE.W	D6,D0
	LSL.W	#4,D0
	MOVE.W	D0,SNDREVS+2
REVSDONE	ANDI.W	#$7E,D6	EVEN AND <$80
	MOVE.B	D6,OLDREVS+1	STORE FOR DISPLAY
JOYSTICK	MOVEQ	#16,D0
	LSL.W	#2,D0
	LEA	JOYJUMPS,A1
	MOVE.L	0(A1,D0.W),A1
	JSR	(A1)
	MOVE.B	D4,GEAR+1	NEW GEAR
	TST.W	D3	ACCELERATING ?
	BNE.S	GEARCHANGE	YES
	TST.W	D4	IN GEAR ?
	BPL.S	GEARDECAY	YES
	SUBI.W	#16,D6	NEUTRAL REV DECAY
	BRA.S	REVDECAY
GEARDECAY	BTST	#1,D5	BACK ON GROUND ?
	BNE.S	GEARCHANGE	YES
	SUBQ.W	#2,D6	DECAY WHEN IN AIR
REVDECAY	CMPI.W	#7,D6	IF IN AIR OR IN NEUTRAL
	BGT.S	GEARCHANGE	THEN REVS NEVER GET TO 0
	MOVEQ	#8,D6
GEARCHANGE	MOVE.B	D6,REVS+1	STORE NEW REV VALUE
	MOVE.B	D2,GEARUP+1
	MOVE.B	D2,GEARDOWN+1
	BRA	BFATT

BIKEOUT	TST.B	D5
	BEQ.S	NOMOVE1
	TST.W	D4
	BMI.S	NOMOVE1
	MOVE.W	#-1,ZMOVE+2
NOMOVE1	RTS

BIKEACCEL	LEA	ACCELTABLE,A1
	MOVEQ	#-1,D3	ACCELERATION FLAG
	MOVE.W	D4,D1
	BMI.S	INNEUTRAL
	BTST	#1,D5
	BEQ.S	INNEUTRAL
	LSL.W	#7,D1
	ADD.W	D6,D1
	MOVE.W	0(A1,D1.W),D0
INFIRST	MOVE.W	D0,ACCEL+4
	RTS
INNEUTRAL	ADDI.W	#16,D6
	CMPI.W	#$7F,D6
	BCS.S	REVSOK
	MOVEQ	#$7E,D6
REVSOK	RTS

DOWNRIGHT	MOVE.L	DOWN,A1
	JSR	(A1)
DORIGHT	MOVE.L	RIGHT,A1
	JMP	(A1)

BIKEIN	TST.B	D5
	BEQ.S	NOMOVE3
	TST.W	D4
	BMI.S	NOMOVE3
	MOVE.W	#1,ZMOVE+2
NOMOVE3	RTS

UPRIGHT	MOVE.L	UP,A1
	JSR	(A1)
	BRA.S	DORIGHT

BIKEBRAKE	TST.W	D4
	BMI.S	NOMOVE3
	MOVE.L	#-$6800,ACCEL+2
	RTS

DOWNLEFT	MOVE.L	DOWN,A1
	JSR	(A1)
DOLEFT	MOVE.L	LEFT,A1
	JMP	(A1)

UPLEFT	MOVE.L	UP,A1
	JSR	(A1)
	BRA.S	DOLEFT

DUCK	TST.W	D4
	BMI.S	NOMOVE
	TST.B	DUCKFLAG+1
	BNE.S	NOMOVE
	MOVE.B	#16,DUCKFLAG+1
	RTS

GEARDOWN	MOVEQ	#0,D2
	BMI.S	NOGDOWN
	TST.W	D4
	BLE.S	NOGDOWN
	CMPI.W	#$60,D6
	BGT.S	NOGDOWN
	LSL.W	#1,D6
	SUBQ.W	#1,D4
	CMPI.W	#$7F,D6
	BCS.S	NOGDOWN
	MOVEQ	#$7E,D6
NOGDOWN	MOVEQ	#-1,D2

NOMOVE	RTS

FRONTLIFT	TST.W	D4
	BMI.S	NOMOVE
	TST.B	D5
	BEQ.S	FRONTLIFT1
	BTST	#1,D5
	BEQ.S	NOMOVE
	BTST	#0,D5
	BNE.S	FRONTLIFT1
CHANGED	MOVE.W	#0,D0
	BGT.S	NOMOVE
FRONTLIFT1	MOVE.W	#1,CHANGE+2
	CLR.B	DUCKFLAG+1
	RTS

FDOWNRIGHT	MOVE.L	FDOWN,A1
	JSR	(A1)
DOFRIGHT	MOVE.L	FRIGHT,A1
	JMP	(A1)

GEARUP	MOVEQ	#0,D2
	BGT.S	NOGUP
	CMPI.W	#2,D4
	BEQ.S	NOGUP
	TST.B	FLAGTEST+1
	BPL.S	NOGUP
	LSR.W	#1,D6
	ANDI.W	#$7E,D6
	ADDQ.W	#1,D4
	BNE.S	NOGUP
	MOVE.W	D6,D0
	SWAP	D0
	LSR.L	#4,D0
	MOVE.L	D0,ACCEL+2
	MOVEQ	#-1,D3
NOGUP	MOVEQ	#1,D2
	RTS

FUPRIGHT	MOVE.L	FUP,A1
	JSR	(A1)
	BRA.S	DOFRIGHT

BACKLIFT	TST.W	D4
	BMI.S	NOMOVE2
	TST.B	D5
	BEQ.S	BACKLIFT1
	BTST	#0,D5
	BEQ.S	NOMOVE2
	BTST	#1,D5
	BNE.S	BACKLIFT1
	TST.W	CHANGED+2
	BLT.S	NOMOVE2
BACKLIFT1	MOVE.W	#-1,CHANGE+2
	CLR.B	DUCKFLAG+1
NOMOVE2	RTS

FDOWNLEFT	MOVE.L	FDOWN,A1
	JSR	(A1)
DOFLEFT	MOVE.L	FLEFT,A1
	JMP	(A1)

FUPLEFT	MOVE.L	FUP,A1
	JSR	(A1)
	BRA.S	DOFLEFT

JOYJUMPS	DC.L	DUCK
FUP	DC.L	GEARUP
FDOWN	DC.L	GEARDOWN,NOMOVE
FLEFT	DC.L	BACKLIFT,FUPLEFT,FDOWNLEFT,NOMOVE
FRIGHT	DC.L	FRONTLIFT,FUPRIGHT,FDOWNRIGHT,NOMOVE
	DC.L	NOMOVE,NOMOVE,NOMOVE,NOMOVE
	DC.L	NOMOVE
UP	DC.L	BIKEIN
DOWN	DC.L	BIKEOUT,NOMOVE
LEFT	DC.L	BIKEBRAKE,UPLEFT,DOWNLEFT,NOMOVE
RIGHT	DC.L	BIKEACCEL,UPRIGHT,DOWNRIGHT,NOMOVE
	DC.L	NOMOVE,NOMOVE,NOMOVE,NOMOVE

ACCELTABLE	DC.W	$2000,$2100,$2200,$2300
	DC.W	$2400,$2500,$2600,$2700
	DC.W	$2800,$2900,$2A00,$2B00
	DC.W	$2C00,$2D00,$2E00,$2F00

	DC.W	$3000,$3100,$3200,$3300
	DC.W	$3400,$3500,$3600,$3700
	DC.W	$3800,$3C00,$4000,$4800
	DC.W	$5000,$5800,$5A00,$5C00

	DC.W	$5D00,$5E00,$5F00,$5F80
	DC.W	$6000,$6080,$6100,$6180
	DC.W	$6200,$6280,$6300,$6280
	DC.W	$6200,$6180,$6100,$6080

	DC.W	$6000,$5F00,$5E00,$5C00
	DC.W	$5A00,$5800,$5600,$5400
	DC.W	$5000,$4C00,$4800,$4400
	DC.W	$4000,$3C00,$3800,$3400

	DC.W	$F00,$F40,$F80,$FC0
	DC.W	$1000,$1040,$1080,$10C0
	DC.W	$1100,$1140,$1180,$11C0
	DC.W	$1200,$1280,$1300,$1380

	DC.W	$1400,$1500,$1600,$1700
	DC.W	$1800,$1A00,$1C00,$1E00
	DC.W	$2000,$2400,$2800,$2C00
	DC.W	$3000,$3400,$3800,$3C00

	DC.W	$4000,$4200,$4400,$4600
	DC.W	$4700,$4800,$4700,$4600
	DC.W	$4500,$4400,$4300,$4200
	DC.W	$4000,$3C00,$3800,$3400

	DC.W	$3000,$2C00,$2800,$2400
	DC.W	$2000,$1C00,$1A00,$1800
	DC.W	$1600,$1400,$1300,$1200
	DC.W	$1100,$1000,$F00,$E00

	DC.W	$E00,$E40,$E80,$EC0
	DC.W	$F00,$F40,$F80,$FC0
	DC.W	$1000,$1080,$1100,$1180
	DC.W	$1200,$1280,$1300,$1380

	DC.W	$1400,$1480,$1500,$1580
	DC.W	$1600,$1680,$1700,$1780
	DC.W	$1800,$1880,$1900,$1980
	DC.W	$1A00,$1A80,$1B00,$1B80

	DC.W	$1C00,$1C80,$1D00,$1D80
	DC.W	$1E00,$1E80,$1F00,$1F80
	DC.W	$2000,$1F80,$1F00,$1E80
	DC.W	$1E00,$1D80,$1D00,$1C80

	DC.W	$1C00,$1B00,$1A00,$1900
	DC.W	$1800,$1700,$1600,$1500
	DC.W	$1400,$1300,$1200,$1100
	DC.W	$1000,$F80,$F00,$E80

BFATT	MOVEQ	#3,D0	GET WHEEL ATTITUDE
	BNE.S	GROUND
GRAVITY	ADDI.L	#$10000,YSPEED+2    FRACTIONAL GRAVITY
	BRA	BIKEX

*------------------------------------------------------------------------
*	GET NEW COMSPEED (WHEEL/S ON GROUND)
*------------------------------------------------------------------------

GROUND	LEA	GRAVALS,A1
	MOVE.L	TRACTION,A2
	LEA	GRADIENTS,A3
	LEA	SINCOS,A4
	CLR.L	D1	COMBINED ACCEL

	BTST	#1,D0	REAR WHEEL ON GROUND ?
	BEQ	REAROFF	NO

ACCEL	MOVE.L	#0,D5	ACCEL DUE TO ENGINE
*	MOVE.L	D5,SPRAYVAL+2
	ADD.L	D5,D1
	TST.L	D5
	BPL.S	REMOVEACCEL
	ADDQ.W	#1,BREAKCNT+2
BREAKCNT	MOVE.W	#0,D5
MAXBRAKE	CMPI.W	#9,D5
	BNE.S	BREAKING
	MOVE.W	#5,CRASH+2	SKIDDED
REMOVEACCEL	CLR.W	BREAKCNT+2
BREAKING	CLR.L	ACCEL+2
MAPBACK	MOVE.W	#0,D7	CONTACT POSITION FOR BACK (X)
BACKID	MOVE.W	#10,D5	GET BLOCK TYPE UNDER BACK WHEEL
	MOVE.W	D5,D6
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6
	ANDI.W	#$1F,D7	PIXEL POSITION
	SUB.W	D7,D6
	MOVE.B	0(A3,D6.W),D7	READ GRADIENT
	EXT.W	D7
	MOVE.W	D7,D3	COPY BACK GRADIENT
	MOVE.W	D3,BACKGRAD+2	AND STORE IT
	ASL.W	#2,D7	ANGLE*4 AS INDEX
	MOVE.L	0(A1,D7.W),D7
	SUB.L	D7,D1	CHANGE ACCELERATION
*	ADD.L	D7,SPRAYVAL+2
	LSL.W	#1,D5	TYPE*2 AS INDEX
	MOVE.W	0(A2,D5.W),D5
	EXT.L	D5
	SUB.L	D5,D1	REDUCE ACCEL BY TRACTION
*	ADD.L	D5,SPRAYVAL+2

OLDBFATT	MOVEQ	#3,D7	IN AIR LAST TIME ?
	BNE.S	REAROFF	NO
	CMPI.W	#$10,YSPEED+2
	BGT.S	LANDBACK
	BSR	GETCRASH
	CMPI.L	#$10008000,D3
	BLT.S	REAROFF
LANDBACK	MOVE.W	#1,CRASH+2	BACK TOO HARD

REAROFF	BTST	#0,D0	FRONT WHEEL ON GROUND ?
	BEQ.S	COMSPEED	NO
MAPFRONT	MOVE.W	#0,D7	CONTACT POSITION FOR FRONT (X)
FRONTID	MOVE.W	#10,D5	GET BLOCK TYPE UNDER FRONT WHEEL
	MOVE.W	D5,D6	COPY BLOCK TYPE
	LSL.W	#1,D5	TYPE*2 AS INDEX
	MOVE.W	0(A2,D5.W),D5
	EXT.L	D5
	SUB.L	D5,D1	REDUCE ACCEL BY TRACTION
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6
	ANDI.W	#$1F,D7	PIXEL POSITION
	SUB.W	D7,D6
	MOVE.B	0(A3,D6.W),D7
	EXT.W	D7
	MOVE.W	D7,D3	COPY FRONT GRADIENT
	MOVE.W	D3,FRONTGRAD+2	AND STORE IT
	BTST	#1,D0	BACK ON GROUND ?
	BNE.S	COMSPEED	YES,  ACCEL CALCULATED
	ASL.W	#2,D7	ANGLE*4 AS INDEX
	SUB.L	0(A1,D7.W),D1	CHANGE ACCELERATION
	TST.B	OLDBFATT+1
	BNE.S	COMSPEED
	CMPI.W	#$F,YSPEED+2
	BGT.S	LANDFRONT
	BSR	GETCRASH
	CMPI.L	#$E000000,D3
	BLT.S	COMSPEED
LANDFRONT	MOVE.W	#2,CRASH+2	FRONT TOO HARD

COMSPEED	ADDI.L	#0,D1	NEW COMSPEED
	BGE.S	NOTDEAD	NOT STOPPED
STOPPED	MOVEQ	#0,D1	STOP BIKE
	TST.B	GEAR+1
	BMI	SPEEDOK
	MOVE.W	#3,CRASH+2	STALLED
NOTDEAD	BTST	#1,BFATT+1
	BEQ.S	NOTDEAD1
	TST.B	GEAR+1
	BNE.S	NOTFIRST
	CMPI.L	#$80000,D1
	BCS.S	SPEEDOK
	MOVE.L	#$7FFFF,D1
	BRA.S	SPEEDOK

GETCRASH	MOVE.L	XSPEED+2,D2
	MOVE.W	D3,D6	COPY GRADIENT ANGLE
	BPL.S	POSANG1
	NEG.W	D3
POSANG1	LSL.W	#2,D3	LONGWORD INDEX INTO TABLE
	MOVE.L	0(A4,D3.W),D4	SINE IN HIGH, COSINE IN LOW WORD
	MOVE.W	D4,D3	GET COSINE IN D3
	SWAP	D4	GET SINE IN LOW WORD
	MOVE.W	D4,D7	COPY IT
	MULU	D2,D4	MULTIPLY SPEED BY SINE VALUE
	TST.W	D6
	BPL.S	LOWDONE
	NEG.L	D4
LOWDONE	SWAP	D2
	MULU	D2,D7
	TST.W	D6
	BPL.S	HIGHDONE
	NEG.L	D7
HIGHDONE	SWAP	D7
	CLR.W	D7
	ADD.L	D7,D4
POSANG2	MOVE.L	YSPEED+2,D2
	MOVE.W	D3,D7
	MULS	D2,D3
	SWAP	D2
	MULS	D2,D7
	SWAP	D7
	CLR.W	D7
	ADD.L	D7,D3
	ADD.L	D4,D3
	RTS

NOTFIRST	CMPI.B	#1,GEAR+1
	BNE.S	NOTDEAD1
	CMPI.L	#$C0000,D1
	BCS.S	SPEEDOK
	MOVE.L	#$BFFFF,D1
	BRA.S	SPEEDOK
NOTDEAD1	CMPI.L	#$100000,D1	TOO FAST ?
	BCS.S	SPEEDOK NO
	MOVE.L	#$FFFFF,D1	MAX SPEED
SPEEDOK	MOVE.L	D1,COMSPEED+2	STORE NEW COMBINED SPEED
	BTST	#1,D0	BACK ON GROUND ?
	BEQ.S	FRONTGRAD	NO
BACKGRAD	MOVE.W	#0,D2	USE BACK GRADIENT FOR SPEEDS
	BRA.S	HVCALSINE
FRONTGRAD	MOVE.W	#0,D2

*-------------------------------------------------------------------------		
*	SPEED OF LANDSCAPE CALCULATION IN BOTH HORIZONTAL AND VERTICAL
*	DIRECTIONS DERIVED FROM FORWARD MOTION OF BIKE
*	COMSPEED=TOTAL SPEED OF BIKE : ANGLE : DOWN UP TABLES IN A4
*-------------------------------------------------------------------------

HVCALSINE	MOVE.W	D2,D0	ANGLE
	MOVE.L	D1,D3	COMBINED SPEED
	TST.W	D0
	BPL.S	POSANG3
	NEG.W	D0
POSANG3	LSL.W	#2,D0	LONGWORD INDEX INTO TABLE
	MOVE.L	0(A4,D0.W),D4	SINE IN HIGH, COSINE IN LOW WORD
	MOVE.W	D4,D5
	SWAP	D4	GET SINE IN LOW WORD
	MULU	D4,D3	MULTIPLY SPEED BY SINE VALUE
	LSR.L	#8,D3
	MOVE.L	D1,D6
	SWAP	D6
	MULU	D4,D6
	LSL.L	#8,D6
	ADD.L	D3,D6
	TST.W	D2
	BMI.S	HVCALCOS
	NEG.L	D6
HVCALCOS	ADDI.L	#$10000,D6
	MOVE.L	D6,YSPEED+2
	MOVE.L	D1,D6
	MULU	D5,D1      MULTIPLY BY COSINE
	LSR.L	#8,D1
	SWAP	D6
	MULU	D5,D6
	LSL.L	#8,D6
	ADD.L	D1,D6
	MOVE.L	D6,XSPEED+2	CHANGE XSPEED

*----------------------------------------------------------------------------
*	MOVE TO NEW POSITION AND ADJUST ANGLE ETC.
*----------------------------------------------------------------------------

BIKEX	MOVE.L	#320*24*65536,D0
XSPEED	SUBI.L	#0,D0
	BGT.S	NOWRAP
	ADDI.L	#320*24*65536,D0
	BRA.S	WRAPOK
NOWRAP	CMPI.L	#320*24*65536,D0
	BLS.S	WRAPOK
	SUBI.L	#320*24*65536,D0
WRAPOK	MOVE.L	D0,D1
	SWAP	D0
	SUB.W	BIKEX+2,D0
	MOVE.L	D1,BIKEX+2

	LEA	TOPBLOCKS,A1
	LEA	HEIGHTS,A2
	LEA	RANGLES,A4
	LEA	BIKEDIFFS,A5
	SWAP	D1
	MOVE.B	0(A4,D1.W),D1	READ REST ANGLE AT NEW MAPOS
	EXT.W	D1
	MOVE.W	D1,RESTANGLE+2
	ADD.W	D0,MAPFRONT+2
	ADD.W	D0,MAPBACK+2

BIKEY	MOVE.L	#0,D0
YSPEED	ADDI.L	#0,D0
	MOVE.L	D0,D1
	SWAP	D0
	SUB.W	BIKEY+2,D0
	MOVE.L	D1,BIKEY+2
	ADD.W	D0,YFRONT+2
	ADD.W	D0,YBACK+2

BIKEZ	MOVE.W	#0,D0
ZMOVE	ADDI.W	#0,D0
	BPL.S	NEWZOK1
	MOVEQ	#0,D0
	BRA.S	NEWZOK
NEWZOK1	CMPI.W	#27,D0
	BCS.S	NEWZOK
	MOVE.W	#27,D0
NEWZOK	MOVE.W	D0,BIKEZ+2
	CLR.W	ZMOVE+2

	MOVE.B	BFATT+1,OLDBFATT+1

CHANGE	MOVE.W	#0,D0
	BEQ	NOLIFT

	MOVE.W	ANGLE+2,D1
	CMPI.W	#10,D1
	BLT.S	NOTDUCKING
	MOVEQ	#0,D1
NOTDUCKING	ADD.W	D1,D0
	CMPI.W	#9,D0
	BGT.S	NOLIFT1
	CMPI.W	#-9,D0
	BLT.S	NOLIFT1
	TST.B	BFATT+1
	BEQ.S	LIFTOK
	CMPI.W	#6,D0
	BGT.S	NOLIFT1
	CMPI.W	#-7,D0
	BGT.S	LIFTOK
NOLIFT1	MOVE.W	CHANGE+2,CHANGED+2
	BRA	NOLIFT

LIFTOK	CLR.W	CHANGED+2
	MOVE.W	D0,NEWANGLE+2
	ASL.W	#2,D0
	MOVE.L	0(A5,D0.W),D5	ALL 4 OFFSETS
	MOVE.L	D5,D2	COPY FOR YPOS
	ANDI.L	#$FF00FF,D2
	MOVE.W	BIKEX+2,D1
	ADDI.W	#320-64,D1	TO START OF BIKE BLOCK
	LSR.L	#8,D5
	ANDI.W	#$FF,D5
	NEG.W	D5
	ADD.W	D1,D5	NEW BACK X
	MOVE.W	D5,MAPBACK+2
	BSR.S	GETHEIGHT1
	ANDI.W	#$FF,D4
	MOVE.W	D4,BACKID+2
	SWAP	D5
	NEG.W	D5
	ADD.W	D1,D5	NEW FRONT X
	MOVE.W	D5,MAPFRONT+2
	BSR.S	GETHEIGHT1
	ANDI.W	#$FF,D4
	MOVE.W	D4,FRONTID+2
	TST.W	CHANGE+2
	BPL.S	LIFTFRONT
	TST.B	BFATT+1
	BNE.S	BWHEELIE
	MOVE.W	YFRONT+2,D5
BWHEELIE	MOVE.W	D5,YFRONT+2
	SWAP	D2	GET FRONT IN LOW
	ADD.W	D2,D5
	MOVE.W	D5,BIKEY+2
	SWAP	D2
	SUB.W	D2,D5
	MOVE.W	D5,YBACK+2
	BRA.S	NOLIFT

LIFTFRONT	SWAP	D5
	TST.B	BFATT+1
	BNE.S	FWHEELIE
	MOVE.W	YBACK+2,D5
FWHEELIE	MOVE.W	D5,YBACK+2
	ADD.W	D2,D5
	MOVE.W	D5,BIKEY+2
	SWAP	D2
	SUB.W	D2,D5
	MOVE.W	D5,YFRONT+2
	BRA.S	NOLIFT

GETHEIGHT1	MOVE.W	D5,D7
	ANDI.W	#$1F,D7	PIXEL POSITION
GETHEIGHTX	LSR.W	#3,D5
	ANDI.W	#$FFFC,D5	BLOCK POSITION
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDTOPS2	TST.W	(A6)+
	BMI.S	FOUNDTOPS2
	ADDQ	#4,A6
	BRA.S	FINDTOPS2
FOUNDTOPS2	MOVE.W	(A6)+,D5	Y POSITION OF BLOCK TOP
	MOVE.W	(A6)+,D6
	BTST	#9,D6
	BEQ.S	LORRYOK
	CLR.B	BFATT+1
LORRYOK	MOVE.W	D6,D4	COPY FLAGS AND ID
	ANDI.W	#$FF,D6	BLOCK ID
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6
	SUB.W	D7,D6
	MOVE.B	0(A2,D6.W),D7
	ADD.W	D7,D5
	RTS

NOLIFT	MOVE.W	MAPFRONT+2,D5	FRONT WHEEL X CONTACT
	BSR	GETHEIGHT	GET HEIGHT,FLAG/ID,ZVALS
	MOVE.W	D0,FFLAG+2
	MOVE.B	D0,FRONTID+3
YFRONT	SUB.W	#0,D5	DISTANCE FROM GROUND
	MOVE.W	D5,GRNDFRONT+2	FOR FRONT WHEEL

	MOVE.W	D4,D1	COPY ZSIZE+ZPOS
	ANDI.W	#$FF,D1	ZPOS
	SUBQ.W	#2,D1	CENTRE OF BIKE
	SUB.W	BIKEZ+2,D1	IN FRONT OF BLOCK ?
	BGT.S	MISSEDIT	YES
	LSR.W	#8,D4	ZSIZE
	ADD.W	D1,D4	BEHIND BLOCK ?
	BGT.S	FRONTINAIR	NO
MISSEDIT	MOVE.W	#9,CRASH+2	MISSED OBSTACLE
	BRA	FRONTDONE

FRONTINAIR	BTST	#13,D0	CRASH FLAG SET ?
	BEQ.S	FRONTDONE	NO
	LEA	CRASHDIFFS,A6
	MOVE.W	NEWANGLE+2,D3
	ASL.W	#2,D3
	MOVE.W	0(A6,D3.W),D2
	MOVE.W	D2,D3
	LSR.W	#8,D2	X OFFSET
	ANDI.W	#$FF,D3	Y OFFSET
	MOVE.W	BIKEX+2,D5
	ADDI.W	#320-64,D5
	SUB.W	D2,D5
	MOVE.W	D5,D7
	ANDI.W	#$1F,D7
	CMPI.W	#$10,D7
	BCS.S	FRONTDONE
	BSR	GETHEIGHTX
	BTST	#12,D4	LIFT FLAG SET ?
	BEQ.S	FRONTDONE	NO
	MOVE.W	-6(A6),D4
	MOVE.W	D4,D1
	ANDI.W	#$FF,D1
	ANDI.W	#$3F00,D4
	SUBQ.W	#2,D1
	SUB.W	BIKEZ+2,D1	IN FRONT OF BLOCK ?
	BGT.S	MISSEDITA	YES
	LSR.W	#8,D4	ZSIZE
	ADD.W	D1,D4	BEHIND BLOCK ?
	BGT.S	NOTMISSEDA	NO
MISSEDITA	TST.W	GRNDFRONT+2
	BGT.S	NOTMISSEDA
	MOVE.W	#9,CRASH+2	MISSED OBSTACLE
	BRA.S	FRONTDONE
NOTMISSEDA	SUB.W	BIKEY+2,D5
	ADD.W	D3,D5
	BPL.S	FRONTDONE
	MOVE.W	#6,CRASH+2	CRASHED ON FRONT WHEEL

FRONTDONE	MOVE.W	MAPBACK+2,D5	REAR WHEEL X CONTACT
	BSR	GETHEIGHT	GET GROUND HEIGHT
	MOVE.W	D0,BFLAG+2
	MOVE.B	D0,BACKID+3
YBACK	SUB.W	#0,D5

	BTST	#10,D0
	BEQ.S	NOTRESET
	BTST	#13,D0
	BEQ.S	NOTEND
	MOVE.W	#-1,CRASH+2
	BRA.S	NOTRESET
NOTEND	MOVE.W	MAPBACK+2,D1
	ANDI.W	#$FFE0,D1
	SUBI.W	#320-80,D1
	SWAP	D1
	CLR.W	D1
	CMP.L	RESETPOS+2,D1
	BEQ.S	NOTRESET
	MOVE.L	D1,RESETPOS+2
	MOVE.B	RESETSTART+1,RESETCOUNT+1

NOTRESET	MOVE.W	D5,GRNDBACK+2	FOR BACK WHEEL
	BGT	BACKINAIR

	MOVE.L	SPEEDS,A6	MAX SPEEDS
	MOVE.W	D0,D1	COPY FLAGS+ID
	ANDI.W	#$FF,D1	ID
	MOVE.B	0(A6,D1.W),D1	GET MAX SPEED
	CMP.W	COMSPEED+2,D1	TOO FAST ?
	BCC.S	CHCKPOS1	NO
	MOVE.W	#8,CRASH+2	TOO FAST
	BRA	GRNDFRONT

CHCKPOS1	MOVE.W	D4,D1	COPY ZSIZE+ZPOS
	ANDI.W	#$FF,D1	ZPOS
	SUBQ.W	#2,D1	CENTRE OF BIKE
	SUB.W	BIKEZ+2,D1	IN FRONT OF BLOCK ?
	BGT.S	MISSEDIT1	YES
	LSR.W	#8,D4	ZSIZE
	ADD.W	D1,D4	BEHIND BLOCK ?
	BGT.S	BACKINAIR	NO
MISSEDIT1	MOVE.W	#9,CRASH+2	MISSED OBSTACLE
	BRA	GRNDFRONT

BACKINAIR	BTST	#13,D0	LIFT FLAG SET ?
	BEQ	NOBCRASH	NO
	LEA	CRASHDIFFS,A6
	MOVE.W	NEWANGLE+2,D3
	ASL.W	#2,D3
	MOVE.W	2(A6,D3.W),D2
	MOVE.W	D2,D3
	LSR.W	#8,D2	X OFFSET
	ANDI.W	#$FF,D3	Y OFFSET
	MOVE.W	BIKEX+2,D5
	ADDI.W	#320-64,D5
	SUB.W	D2,D5
	MOVE.W	D5,D7
	ANDI.W	#$1F,D7
	CMPI.W	#$18,D7
	BCS.S	NOBCRASH
	BSR	GETHEIGHTX
	BTST	#12,D4	LIFT FLAG SET ?
	BEQ.S	NOBCRASH	NO
	MOVE.W	-6(A6),D4
	MOVE.W	D4,D1
	ANDI.W	#$FF,D1
	ANDI.W	#$3F00,D4
	SUBQ.W	#2,D1
	SUB.W	BIKEZ+2,D1	IN FRONT OF BLOCK ?
	BGT.S	MISSEDITB	YES
	LSR.W	#8,D4	ZSIZE
	ADD.W	D1,D4	BEHIND BLOCK ?
	BGT.S	NOTMISSEDB	NO
MISSEDITB	TST.W	GRNDBACK+2
	BGT.S	NOTMISSEDB
	MOVE.W	#9,CRASH+2	MISSED OBSTACLE
	BRA	BACKDONE
NOTMISSEDB	SUB.W	BIKEY+2,D5
	ADD.W	D3,D5
	BPL.S	NOBCRASH
	MOVE.W	#7,CRASH+2	CRASHED ON BACK WHEEL
	BRA	GRNDFRONT

NOBCRASH	BTST	#9,D0
	BEQ.S	NOTDROPOFF
	TST.W	GRNDFRONT+2
	BGT.S	NOTDROPOFF
	CMPI.W	#-6,NEWANGLE+2
	BGE.S	NOTDROPOFF
	MOVE.W	#11,CRASH+2
	BRA	GRNDFRONT

NOTDROPOFF	BTST	#11,D0	HOLE ?
	BEQ.S	FFLAG	NO
	MOVE.W	MAPBACK+2,D5
	ANDI.W	#$1F,D5
	CMPI.W	#$6,D5
	BCS.S	FFLAG
	CMPI.W	#$1A,D5
	BCC.S	FFLAG
	TST.W	GRNDBACK+2	BACK ON GROUND ?
	BLE.S	FALLB	YES
	TST.W	NEWANGLE+2	DROPPED WHEEL ?
	BLE.S	FFLAG	NO
	TST.W	GRNDFRONT+2	FRONT ON GROUND ?
	BGT.S	FFLAG	NO
FALLB	MOVE.W	#10,CRASH+2	FELL IN HOLE
	BRA	GRNDFRONT

FFLAG	MOVE.W	#0,D0
	BTST	#11,D0	HOLE ?
	BEQ.S	BACKDONE	NO
	MOVE.W	MAPFRONT+2,D5
	ANDI.W	#$1F,D5
	CMPI.W	#$6,D5
	BCS.S	BACKDONE
	CMPI.W	#$1A,D5
	BCC.S	BACKDONE
	TST.W	GRNDFRONT+2	FRONT ON GROUND ?
	BLE.S	FALLF	YES
	TST.W	NEWANGLE+2	DROPPED WHEEL ?
	BPL.S	BACKDONE	NO
	TST.W	GRNDBACK+2	BACK ON GROUND ?
	BGT.S	BACKDONE	NO
FALLF	MOVE.W	#10,CRASH+2	FELL IN HOLE
	BRA	GRNDFRONT

BACKDONE	MOVE.W	MAPBACK+2,D5
	ADD.W	MAPFRONT+2,D5
	LSR.W	#1,D5	CENTRE X
	ADDQ.W	#4,D5
	MOVE.W	D5,D7
	ANDI.W	#$1F,D7
	CMPI.W	#$8,D7
	BCS.S	GRNDFRONT
	CMPI.W	#$18,D7
	BCC.S	GRNDFRONT
	LSR.W	#3,D5
	ANDI.W	#$FFFC,D5
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDTOP1	MOVE.L	(A6)+,D0	TOPBLOCK ?
	BMI.S	NEXTDUCK	YES
	MOVE.W	(A6),D5	GET FLAGS
	BTST	#9,D5	DUCK ?
	BEQ.S	NEXTDUCK	NO
	MOVE.B	#-1,DUCKTEST+1
	BRA.S	GRNDFRONT
NEXTDUCK	MOVE.W	(A6)+,D5	ENDBLOCK ?
	BPL.S	FINDTOP1	NO

GRNDFRONT	MOVE.W	#0,D4
GRNDBACK	MOVE.W	#0,D5
	BLE.S	NEWANGLE
	TST.W	D4
	BLE.S	NEWANGLE
	CLR.B	BFATT+1	BOTH WHEELS IN AIR
	CLR.W	FRONTDROP+2
	CLR.W	BACKDROP+2
	BRA	DUCKFLAG

NEWANGLE	MOVE.W	#0,D0
	CMPI.W	#10,D0
	BLT.S	NOTADUCK
	MOVEQ	#0,D0
NOTADUCK	MOVE.B	#3,BFATT+1
	MOVE.W	BIKEX+2,D2
	ADDI.W	#320-64,D2	START OF BIKE BLOCK
RESTANGLE	MOVE.W	#0,D1

	TST.B	OLDBFATT+1
	BNE.S	NOTLAND
	MOVE.W	D4,D6
	SUB.W	D5,D6
	BPL.S	POSDIFF
	NEG.W	D6
POSDIFF	CMPI.W	#14,D6
	BLT.S	NOTLAND
	CMPI.W	#8,YSPEED+2
	BGE.S	LANDCRASH
	CMPI.W	#40,D6
	BLT.S	NOTLAND
LANDCRASH	CMP.W	D4,D5
	BGT.S	NOTONBACK
	MOVE.W	#1,CRASH+2
	BRA.S	NOTLAND
NOTONBACK	MOVE.W	#2,CRASH+2

NOTLAND	TST.W	D5	BACK WHEEL IN AIR ?
	BLE.S	NOTBACKUP	NO

	CMP.W	D1,D0
	BGE	USEREST
	CLR.W	FRONTDROP+2
	MOVE.B	#1,BFATT+1	BACK IN AIR
	TST.W	CHANGE+2	BEING LIFTED ?
	BGE.S	DOBDROP	NO SO DROP IT
	CLR.W	BACKDROP+2
	BRA.S	DROPPED
DOBDROP	NEG.W	D4
	LSR.W	#1,D4
	ADDQ.W	#1,BACKDROP+2
BACKDROP	ADDI.W	#0,D4
DROPBACK	ADDQ.W	#1,D0
	CMP.W	D0,D1
	DBEQ	D4,DROPBACK
	BRA.S	DROPPED

NOTBACKUP	TST.W	D4	FRONT WHEEL IN AIR ?
	BLE.S	DROPPED	NO

	CMP.W	D1,D0
	BLE.S	USEREST
	CLR.W	BACKDROP+2
	MOVE.B	#2,BFATT+1	FRONT IN AIR
	TST.W	CHANGE+2	BEING LIFTED ?
	BLE.S	DOFDROP	NO SO DROP IT
	CLR.W	FRONTDROP+2
	BRA.S	DROPPED
DOFDROP	BTST	#1,OLDBFATT+1	BACK LANDED ?
	BEQ.S	MOREFDROP	YES
	MOVEQ	#0,D5
MOREFDROP	NEG.W	D5
FRONTDROP	ADDI.W	#0,D5
	LSR.W	#2,D5	BACK DIST UNDER/2
	ADDQ.W	#1,FRONTDROP+2	INCREASE DROP RATE
DROPFRONT	SUBQ.W	#1,D0	DROP FRONT WHEEL
	CMP.W	D0,D1	UNTIL AT REST OR REACHED
	DBEQ	D5,DROPFRONT	REQUIRED RAISE AMOUNT

DROPPED	CMP.W	D0,D1	NOW AT REST ANGLE ?
	BEQ.S	ATREST	YES
	BTST	#1,BFATT+1	BACK ON GROUND ?
	BEQ.S	USEFRONT	NO
	BTST	#0,BFATT+1	FRONT ON GROUND ?
	BEQ.S	USEBACK	NO
USEREST	CMPI.W	#6,CRASH+2	CRASHED ?
	BEQ.S	ATREST	YES, DRAW AT THIS POSITION
	CMPI.W	#7,CRASH+2
	BEQ.S	ATREST
	MOVE.W	D1,D0	USE REST ANGLE

ATREST	MOVE.B	#3,BFATT+1	BIKE LANDED
	CLR.W	FRONTDROP+2
	CLR.W	BACKDROP+2
BFLAG	MOVE.W	#0,D1
*	BTST	#12,D1	LIFT FLAG SET AT BACK ?
*	BNE.S	USEFRONT	YES SO USE FRONT WHEEL

USEBACK	BSR	GETOFFSETS
	MOVE.W	D5,YBACK+2	BACK ON GROUND
	ADD.W	D1,D5	TO BASE OF BIKE BLOCK
	MOVE.W	D5,BIKEY+2	BIKE BLOCK POSITION
	SWAP	D1	OFFSET TO FRONT WHEEL
	SUB.W	D1,D5
	MOVE.W	D5,YFRONT+2
	BRA.S	DUCKFLAG

USEFRONT	BSR	GETOFFSETS
	MOVE.W	D3,YFRONT+2	FRONT ON GROUND
	SWAP	D1	OFFSET TO FRONT WHEEL
	ADD.W	D1,D3	TO BASE OF BIKE BLOCK
	MOVE.W	D3,BIKEY+2	BIKE BLOCK POSITION
	SWAP	D1	OFFSET TO BACK WHEEL
	SUB.W	D1,D3
	MOVE.W	D3,YBACK+2

DUCKFLAG	MOVEQ	#0,D0
	BEQ.S	DUCKTEST
	CMPI.B	#3,BFATT+1
	BNE.S	DUCKOFF
	TST.W	NEWANGLE+2
	BNE.S	DUCKOFF
	SUBQ.W	#1,D0
	CMPI.B	#13,D0
	BGT.S	HALFDUCK
	CMPI.B	#6,D0
	BLT.S	DEADDUCK
	CMPI.B	#8,D0
	BLT.S	HALFDUCK
	MOVE.W	#11,NEWANGLE+2
	BRA.S	DUCKDONE
DEADDUCK	CLR.W	NEWANGLE+2
	BRA.S	DUCKDONE
HALFDUCK	MOVE.W	#10,NEWANGLE+2
	BRA.S	DUCKDONE

DUCKOFF	MOVEQ	#0,D0
DUCKDONE	MOVE.B	D0,DUCKFLAG+1

DUCKTEST	MOVEQ	#0,D1
	BEQ.S	DOENGINE
	CMPI.W	#11,NEWANGLE+2
	BEQ.S	NOTLIMBO
	MOVE.W	#12,CRASH+2	HIT LIMBO
NOTLIMBO	CLR.B	DUCKTEST+1

DOENGINE	LEA	CENTREDIFFS,A6
	MOVE.W	NEWANGLE+2,D3
	ASL.W	#1,D3
	MOVE.W	0(A6,D3.W),D2
	MOVE.W	D2,D3
	LSR.W	#8,D2	X OFFSET
	ANDI.W	#$FF,D3	Y OFFSET
	MOVE.W	BIKEX+2,D5
	ADDI.W	#320-64,D5
	SUB.W	D2,D5
	MOVE.B	BFATT+1,D0
	BSR	GETHEIGHT1
	MOVE.B	D0,BFATT+1
	SUB.W	BIKEY+2,D5
	ADD.W	D3,D5
	BPL	PSTNSET
	MOVE.W	#13,CRASH+2	GROUNDED ENGINE
	BRA	PSTNSET

GETOFFSETS	MOVE.W	D0,NEWANGLE+2
	ASL.W	#2,D0
	MOVE.L	0(A5,D0.W),D0	ALL 4 OFFSETS
	MOVE.L	D0,D1	COPY FOR YPOS
	ANDI.L	#$FF00FF,D1	Y OFFSETS
	LSR.L	#8,D0	X OFFSETS
	ANDI.W	#$FF,D0	BACK X
	NEG.W	D0
	ADD.W	D2,D0	NEW BACK X
	MOVE.W	D0,MAPBACK+2
	SWAP	D0
	NEG.W	D0
	ADD.W	D2,D0	NEW FRONT X
	MOVE.W	D0,MAPFRONT+2
	MOVE.W	D0,D5
	BSR.S	GROUNDY
	MOVE.W	D4,FRONTID+2
	MOVE.W	D5,D3	FRONT GROUND HEIGHT
	MOVE.W	MAPBACK+2,D5
	BSR.S	GROUNDY
	MOVE.W	D4,BACKID+2
	RTS

GROUNDY	MOVE.W	D5,D7	COPY X POS
	LSR.W	#3,D5
	ANDI.W	#$FFFC,D5
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDTOP2	TST.W	(A6)+
	BMI.S	FOUNDTOP2
	ADDQ	#4,A6
	BRA.S	FINDTOP2
FOUNDTOP2	MOVE.W	(A6)+,D5	Y POSITION OF BLOCK TOP
	MOVE.W	(A6)+,D6
	ANDI.W	#$FF,D6 BLOCK ID
	MOVE.W	D6,D4
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6
	ANDI.W	#$1F,D7	PIXEL POSITION
	SUB.W	D7,D6
	MOVE.B	0(A2,D6.W),D7
	ADD.W	D7,D5
	RTS

*	ROUTINE TO GET GROUND HEIGHT REQUIRES :-
*	A1=TOPBLOCKS A2=INTERNAL HEIGHTS D5=X POSITION (WORD)
*	RETURNS :-
*	D5=Y POSITION (WORD) D0=FLAGS+BLOCK ID D4=ZSIZE+ZPOS

GETHEIGHT	MOVE.W	D5,D7	COPY X POS
	LSR.W	#3,D5	/16
	ANDI.W	#$FFFC,D5	*4
	MOVE.L	0(A1,D5.W),A6	START OF COLUMN
FINDTOP	MOVE.W	(A6)+,D4	ZSIZE+ZPOS
	BMI.S	FOUNDTOP
	MOVE.L	(A6)+,D2	FLAGS
	BTST	#13,D2	TEST CRASH FLAG
	BEQ.S	FINDTOP	NOT OBSTRUCTION
	MOVE.W	D4,D1	COPY ZSIZE+ZPOS
	ANDI.W	#$FF,D1 ZPOS
	SUBQ.W	#2,D1	CENTRE OF BIKE
	SUB.W	BIKEZ+2,D1	IN FRONT OF BLOCK ?
	BGT.S	FINDTOP	YES
	LSR.W	#8,D4	ZSIZE
	ADD.W	D1,D4	BEHIND BLOCK ?
	BLE.S	FINDTOP YES
	MOVE.W	#4,CRASH+2	HIT OBSTRUCTION
	BRA.S	FINDTOP

FOUNDTOP	ANDI.W	#$3FFF,D4	TOPBLOCK ZSIZE+ZPOS
	MOVE.W	(A6)+,D5	TOPBLOCK Y POSITION
	MOVE.W	(A6)+,D0	FLAGS+ID
	MOVE.W	D0,D6	COPY FLAGS+ID
	ANDI.W	#$FF,D6	BLOCK ID
	LSL.W	#5,D6	ID*32
	ADDI.W	#$1F,D6	BLOCK START
	ANDI.W	#$1F,D7	PIXEL POSITION
	SUB.W	D7,D6	WITHIN BLOCK
	MOVE.B	0(A2,D6.W),D7	INTERNAL HEIGHT
	ADD.W	D7,D5	TOTAL HEIGHT
	TST.W	D0	ENDBLOCK ?
	BMI.S	GOTHEIGHT

FINDEND	MOVE.W	(A6)+,D2	ZSIZE+ZPOS
	MOVE.L	(A6)+,D1	FLAGS
	BTST	#13,D1	TEST CRASH FLAG
	BEQ.S	FINDEND1	NOT OBSTRUCTION
	MOVE.W	D2,D7	COPY ZSIZE+ZPOS
	ANDI.W	#$FF,D2	ZPOS
	SUBQ.W	#2,D2	CENTRE OF BIKE
	SUB.W	BIKEZ+2,D2	IN FRONT OF BLOCK ?
	BGT.S	FINDEND1	YES
	LSR.W	#8,D7	ZSIZE
	ADD.W	D2,D7	BEHIND BLOCK ?
	BLE.S	FINDEND1	YES
	MOVE.W	#4,CRASH+2	HIT OBSTRUCTION
FINDEND1	TST.W	D1
	BPL.S	FINDEND
GOTHEIGHT	RTS

PSTNSET	MOVE.W	NEWANGLE+2,ANGLE+2

*	WAIT FOR SCREEN FLIP

DRAWSCREEN	CMPI.W	#1,$468.W	RASTER DONE FOR NEW SCREEN ?
	BNE.S	DRAWSCREEN	NO
	MOVE.B	#-1,DRAWFLAG+1	DRAWING IN PROGRESS !!

*	BIKE NOISE

DRAWSCREEN1	MOVE.W	#0,D0
SNDSTRT	MOVEQ	#0,D1
	BEQ.S	NOTYET
	ADDI.W	#$7FF,D0
SNDREVS	SUB.W	#0,D0	0-7FF
	MOVE.W	D0,D1
	ADDI.W	#$400,D1	400-BFF
	LSR.W	#2,D1	100-2FF
	EXT.L	D0
	DIVU	#11,D0
	ADDI.W	#50,D0
	LEA	$FFFF8800.W,A0
	MOVE.B	#$B,(A0)
	MOVE.B	D0,2(A0)
	MOVE.B	#$C,(A0)
	LSR.W	#8,D0
	MOVE.B	D0,2(A0)
	MOVE.B	#4,(A0)
	MOVE.B	D1,2(A0)
	MOVE.B	#5,(A0)
	LSR.W	#8,D1
	MOVE.B	D1,2(A0)

*	ROUTINE TO PRINT SKY, BACKGROUND AND GRASS

NOTYET	MOVE.W	BIKEY+2,D0
	NEG.W	D0
	ASR.W	#3,D0
	ADDI.W	#24,D0	LINES OF SKY
	MOVE.W	D0,BACKPOS+2	LINES DOWN FOR BACKGROUND
	MOVEQ	#48,D6
	ADD.W	D0,D6	GROUND JUMP OFFSET
	MOVEQ	#96,D7
	SUB.W	D0,D7	SKY JUMP OFFSET IF - THEN USE 0 IF >= 96 THEN NO SKY
	BPL.S	SKYSIZEOK
	MOVEQ	#0,D7
	MOVEQ	#96,D0
SKYSIZEOK	CMPI.W	#95,D7
	BHI.S	NOSKY
	MOVE.L	BLITBASE+2,A4
	MULU	#160,D0
	ADDA.W	D0,A4	START ADDRESS FOR SKY (BACKWARDS)
	LEA	SKYGROUND,A5
	LSL.W	#4,D7
	ADDA.W	D7,A5
	MOVE.L	#$FFFF0000,D0
	MOVE.L	#0,D1
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	MOVE.L	D0,D4
	MOVE.L	D1,D5
	MOVE.L	D0,A0
	MOVE.L	D1,A1
	MOVE.L	D0,A2
	MOVE.L	D1,A3
	JSR	(A5)
NOSKY	TST.W	D6
	BPL.S	GRNDSIZEOK
	MOVEQ	#0,D6
GRNDSIZEOK	CMPI.W	#95,D6
	BHI.S	NOGROUND
	MOVE.L	BLITBASE+2,A4
	ADDA.W	#96*160,A4
	LEA	SKYGROUND,A5
	LSL.W	#4,D6
	ADDA.W	D6,A5
GRND1	MOVE.L	#$0,D0
GRND2	MOVE.L	#$FFFF,D1
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	MOVE.L	D0,D4
	MOVE.L	D1,D5
	MOVE.L	D0,A0
	MOVE.L	D1,A1
	MOVE.L	D0,A2
	MOVE.L	D1,A3
	JSR	(A5)
NOGROUND	MOVEQ	#48,D2	NORMAL SIZE (LINES)
	MOVEQ	#0,D1	LINES DOWN SOURCE
BACKPOS	MOVE.W	#0,D0	LINES DOWN DEST.
	BPL.S	BACKON
	NEG.W	D0
	CMPI.W	#47,D0
	BHI	NOBACKGRND
	MOVE.W	D0,D1	THIS MANY OFF TOP
	SUB.W	D0,D2	REDUCE COUNT
	MOVEQ	#0,D0	START AT TOP
	BRA.S	BACKSET
BACKON	CMPI.W	#95,D0
	BHI	NOBACKGRND
	CMPI.W	#49,D0
	BCS.S	BACKSET
	MOVEQ	#96,D2
	SUB.W	D0,D2
BACKSET	MOVE.W	D2,LINECOUNT
	MOVEQ	#47,D6
	SUB.W	D1,D6
	MOVE.W	BIKEX+2,D3
	LSR.W	#3,D3
	MOVE.W	D3,D7
	ANDI.W	#15,D7
	LSR.W	#1,D3
	ANDI.W	#$FFF8,D3
	LEA	BACKGROUND+640-168,A0
	MULU	#640,D1
	SUB.W	D3,D1
	ADDA.W	D1,A0
	MOVE.L	BLITBASE+2,A1
	MULU	#160,D0
	ADDA.W	D0,A1

	LEA	MASKS,A2	MASKS FOR CARRIES
	MOVE.W	D7,D1	COPY REQUIRED ROTATION
	LSL.W	#2,D1	LONGWORD MASKS
	MOVE.L	0(A2,D1.W),D1	GET MASKS FOR CARRIES
	MOVE.L	D1,D2	COPY MASKS
	NOT.L	D2	NOT FOR MASKS FOR REMAINS

NEXTLINE	MOVE.W	D6,D0	COPY LINE COUNT FOR SOURCE ROTATION
	ANDI.W	#15,D0	SOURCE ROTATION 0-15
	SUB.W	D7,D0	SUBTRACT REQUIRED ROTATION
	BGT	NORMLBACKR	>0 THEN EITHER NORMAL LEFT OR BACKWARDS RIGHT
	CMPI.W	#-8,D0	<-8 THEN BACKWARDS LEFT
	BLT	BACKLEFT	ELSE NORMAL RIGHT

NORMRIGHT	NEG.W	D0	0-8 FOR RIGHT

.NORMRIGHT	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROR.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROR.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS

.LINE1	REPT	19

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTBACKLINE

BACKLEFT	ADDI.W	#16,D0	1-7 FOR LEFT

	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROL.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROL.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER

.LINE1	REPT	19

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTBACKLINE

NORMLBACKR	CMPI.W	#7,D0	0<X>7 THEN BACKWARDS RIGHT
	BHI	BACKRIGHT	ELSE NORMAL LEFT

NORMLEFT	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROL.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROL.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS

.LINE1	REPT	19

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTBACKLINE

BACKRIGHT	NEG.W	D0	0-8 FOR RIGHT
	ADDI.W	#16,D0	ROTATION

	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROR.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROR.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER

.LINE1	REPT	19

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

NEXTBACKLINE	ADDA.W	#472,A0	NEXT SOURCE LINE
	SUBQ.W	#1,D6
	SUBQ.W	#1,LINECOUNT
	BNE	NEXTLINE	NEXT LINE

*	ROUTINE TO PRINT BLOCKS BEHIND BIKE

NOBACKGRND	MOVE.W	BIKEX+2,D6	IGNORE FRACTION
	MOVE.W	D6,D3	COPY
	ANDI.W	#31,D3	INTERNAL BIT POSITION 0-31
	MOVE.W	D3,D1	COPY REQUIRED ROTATION
	ANDI.W	#15,D1	ROTATION 0-15
	LEA	MASKS,A0	CARRY MASK TABLE
	LSL.W	#2,D1	LONG WORD INDEX
	MOVE.L	0(A0,D1.W),D1	CARRY MASK
	MOVE.L	D1,CARRYMASK+2	STORE
	NOT.L	D1	REMAINS MASK
	MOVE.L	D1,RMNSMASK+2	STORE
	LSR.W	#5,D6	FIRST BLOCK POSITION
	ADDI.W	#10,D6	TEN FOR LAST SCREEN
	LSL.W	#2,D6	LONG WORD INDEX
	MOVE.W	D6,D7	COPY FOR FRONTBLOCKS
	MOVEQ	#0,D2	NUMBER OF BLOCKS IN FRONT
	MOVEQ	#0,D5	COLUMN 0 OF 11 (0-160)
	LEA	TOPBLOCKS,A0	POINTERS TO FIRST BLOCKS
	MOVE.L	BLCKHGHTS,A5	OVERALL HEIGHTS
BACKBLOCKS	MOVE.L	0(A0,D6.W),A1	DATA BASE FOR COLUMN
DRAWTEST	MOVE.W	(A1)+,D0	FLAGS, ZSIZE+ZPOS
	BTST	#14,D0	FLAG FOR SKIP+WATER ?
	BNE.S	SKIPWATER	YES, GOES IN FRONT OF BIKE
	TST.W	D0	TOPBLOCK ?
	BMI.S	BEHIND	YES, GOES BEHIND BIKE
SKIPWATER	SUBQ	#2,D0
	CMP.B	BIKEZ+3,D0	BEHIND BIKE ?
	BGT.S	BEHIND	YES
	ADDQ.W	#1,D2	ANOTHER IN FRONT
	ADDQ	#2,A1	SKIP DATA FOR THIS BLOCK
	TST.W	(A1)+	LAST BLOCK ?
	BMI.S	NEWCOLUMN	YES
	BRA.S	DRAWTEST
BEHIND	BSR	BLOCKPOS	PSTN AND DRAW BLOCK
FLAGHERE	MOVE.W	#0,D4	LAST BLOCK ?
	BPL.S	DRAWTEST	NO
NEWCOLUMN	SUBQ.W	#4,D6	NEXT COLUMN IN BLOCKS
	ADDI.W	#16,D5	NEXT COLUMN ON SCREEN
	CMPI.W	#176,D5	DONE ALL 11 COLUMNS ?
	BNE.S	BACKBLOCKS	NO

*	ROUTINE TO DRAW BIKE
*	A0, D2, D7 RESERVED

	MOVE.L	BLITBASE+2,A3
	ADDA.W	#32+20*160,A3
	LEA	BIKES,A4
ANGLE	MOVE.W	#0,D0
	MULS	#2688,D0
	ADDA.W	D0,A4

DRAWBIKE	REPT	56

	MOVE.L	(A4)+,D0	GET MASK
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN

	MOVE.L	(A4)+,D0	GET MASK
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN

	MOVE.L	(A4)+,D0	GET MASK
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN

	MOVE.L	(A4)+,D0	GET MASK
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN
	MOVE.L	(A3),D1	SCREEN DATA
	AND.L	D0,D1	HOLE FOR GRAPHICS
	OR.L	(A4)+,D1	OR IN GRAPHICS
	MOVE.L	D1,(A3)+	BACK TO SCREEN

	ADDA.W	#128,A3

	ENDR

*	ROUTINE TO PRINT BLOCKS IN FRONT OF BIKE

	TST.W	D2	ANY BLOCKS IN FRONT ?
	BEQ.S	NOFRONT	NO
	MOVE.W	BIKEX+2,D3	IGNORE FRACTION
	ANDI.W	#31,D3	INTERNAL BIT POSITION 0-31
	MOVEQ	#0,D5	CLOUMN 0 OF 11 (0-160)
	MOVE.L	BLCKHGHTS,A5	OVERALL HEIGHTS
FRONTBLOCKS	MOVE.L	0(A0,D7.W),A1	DATA BASE FOR NEXT BLOCK
NEXTBLOCK1	MOVE.W	(A1)+,D0
	BTST	#14,D0
	BNE.S	SKIPWATER1
	TST.W	D0
	BMI.S	DRAWN
SKIPWATER1	SUBQ	#2,D0
	CMP.B	BIKEZ+3,D0
	BLE.S	ATFRONT
DRAWN	ADDQ	#2,A1
	TST.W	(A1)+
	BPL.S	NEXTBLOCK1
NEXTCOL	SUBQ.W	#4,D7
	ADDI.W	#16,D5
	CMPI.W	#176,D5
	BNE.S	FRONTBLOCKS
	BRA.S	NOFRONT
ATFRONT	BSR	BLOCKPOS
	SUBQ.W	#1,D2
	BEQ.S	NOFRONT
	TST.W	FLAGHERE+2
	BMI.S	NEXTCOL
	BRA.S	NEXTBLOCK1

*	ROUTINE TO PRINT PLAN VIEW

NOFRONT	MOVE.W	BIKEX+2,D3
	LSR.W	#2,D3
	MOVE.W	D3,D7
	ANDI.W	#15,D7
	LSR.W	#1,D3
	ANDI.W	#$FFF8,D3
	LEA	PLANVIEW+1040-88,A0
	SUBA.W	D3,A0
	MOVE.L	BLITBASE+2,A1
	ADDA.W	#101*160+40,A1

	LEA	MASKS,A2	MASKS FOR CARRIES
	MOVE.W	D7,D1	COPY REQUIRED ROTATION
	LSL.W	#2,D1	LONGWORD MASKS
	MOVE.L	0(A2,D1.W),D1	GET MASKS FOR CARRIES
	MOVE.L	D1,D2	COPY MASKS
	NOT.L	D2	NOT FOR MASKS FOR REMAINS

	MOVEQ	#31,D6	32 LINES HIGH

PNEXTLINE	MOVE.W	D6,D0	COPY LINE COUNT FOR SOURCE ROTATION
	LSR.W	#1,D0	SOURCE ROTATION 0-15
	SUB.W	D7,D0	SUBTRACT REQUIRED ROTATION
	BGT	PNORMLBACKR	>0 THEN EITHER NORMAL LEFT OR BACKWARDS RIGHT
	CMPI.W	#-8,D0	<-8 THEN BACKWARDS LEFT
	BLT	PBACKLEFT	ELSE NORMAL RIGHT

PNORMRIGHT	NEG.W	D0	0-8 FOR RIGHT

.NORMRIGHT	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROR.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROR.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS

.LINE1	REPT	9

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTPLANLINE

PBACKLEFT	ADDI.W	#16,D0	1-7 FOR LEFT

	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROL.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROL.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER

.LINE1	REPT	9

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTPLANLINE

PNORMLBACKR	CMPI.W	#7,D0	0<X>7 THEN BACKWARDS RIGHT
	BHI	PBACKRIGHT	ELSE NORMAL LEFT

PNORMLEFT	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROL.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROL.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS

.LINE1	REPT	9

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D4	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D5	PUT CARRIES IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROL.L	D0,D3	ROTATE PLANES
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	BRA	NEXTPLANLINE

PBACKRIGHT	NEG.W	D0	0-8 FOR RIGHT
	ADDI.W	#16,D0	ROTATION

	MOVE.L	(A0)+,D4	SOURCE 1ST 2 PLANES
	ROR.L	D0,D4	ROTATE PLANE1
	AND.L	D1,D4	CARRY-OVER
	MOVE.L	(A0)+,D5	SOURCE 2ND 2 PLANES
	ROR.L	D0,D5	ROTATE PLANE3
	AND.L	D1,D5	CARRY-OVER

.LINE1	REPT	9

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D4	COPY PLANES
	AND.L	D1,D4	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	MOVE.L	D3,D5	COPY PLANES
	AND.L	D1,D5	CARRY-OVER
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	ENDR

	MOVE.L	D4,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	1ST 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

	MOVE.L	D5,(A1)	STORE CARRY-OVER
	MOVE.L	(A0)+,D3	2ND 2 PLANES
	ROR.L	D0,D3	ROTATE PLANES
	SWAP	D3	PUT REMAINS IN CORRECT WORDS
	AND.L	D2,D3	REMAINS
	OR.L	D3,(A1)+	PUT REMAINS ON SCREEN

NEXTPLANLINE	ADDA.W	#952,A0	NEXT SOURCE LINE
	ADDA.W	#80,A1	NEXT DEST. LINE
	DBF	D6,PNEXTLINE

*	ROUTINE TO PRINT TOP VIEW BIKE

	LEA	TOPBIKE,A0
	MOVE.W	ANGLE+2,D0
	ASL.W	#1,D0
	LEA	TOPOFFS,A1
	ADDA.W	0(A1,D0.W),A0
	MOVE.L	BLITBASE+2,A1
	MOVE.W	BIKEZ+2,D0
	MULU	#160,D0
	ADDA.W	#(101+27)*160+48,A1
	SUBA.W	D0,A1

DOTOP	REPT	4

	MOVE.L	(A0)+,D0
	AND.L	D0,(A1)
	MOVE.L	(A0)+,D1
	OR.L	D1,(A1)+
	AND.L	D0,(A1)
	MOVE.L	(A0)+,D1
	OR.L	D1,(A1)+

	ADDA.W	#152,A1

	ENDR

	MOVE.L	(A0)+,D0
	AND.L	D0,(A1)
	MOVE.L	(A0)+,D1
	OR.L	D1,(A1)+
	AND.L	D0,(A1)
	MOVE.L	(A0)+,D1
	OR.L	D1,(A1)+

*	ROUTINE TO PRINT REV COUNTER

	LEA	DIALS,A0
OLDREVS	MOVEQ	#0,D0
	LSR.W	#2,D0	0-15
	ANDI.W	#$1E,D0	*2
	LEA	DIALVALS,A1
	ADDA.W	0(A1,D0.W),A0
	MOVE.L	BLITBASE+2,A1
	ADDA.W	#162*160+96,A1

DOREVS	REPT	15

	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+

	ADDA.W	#152,A1

	ENDR

	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+

*	ROUTINE TO PRINT SPEEDO

	LEA	DIALS,A0
	MOVE.W	COMSPEED+2,D0
	ANDI.W	#$F,D0
	LSL.W	#1,D0	0-15 *2
	LEA	DIALVALS,A1
	ADDA.W	0(A1,D0.W),A0
	MOVE.L	BLITBASE+2,A1
	ADDA.W	#162*160+56,A1

DOSPEED	REPT	15

	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+

	ADDA.W	#152,A1

	ENDR

	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+

*	ROUTINE TO PRINT GEAR LIGHT

	MOVE.L	BLITBASE+2,A0
	ADDA.W	#150*160+80,A0
	MOVEQ	#0,D1
	MOVEQ	#$40,D2
	MOVEQ	#$7F,D3
	MOVEQ	#$2,D4
	MOVEQ	#$FE,D5
	MOVEQ	#$3F,D6
	MOVE.B	GEAR+1,D0
	CMPI.B	#2,D0
	BNE.S	GEAR2OFF

	MOVE.B	D2,-327(A0)
	MOVE.B	D3,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D5,-314(A0)
	MOVE.B	D1,-167(A0)
	MOVE.B	D3,-161(A0)
	MOVE.B	D4,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D1,-7(A0)
	MOVE.B	D3,-1(A0)
	MOVE.B	D4,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D1,153(A0)
	MOVE.B	D3,159(A0)
	MOVE.B	D4,160(A0)
	MOVE.B	D5,166(A0)
	BRA.S	DOGEAR1

GEAR2OFF	MOVE.B	D1,-327(A0)
	MOVE.B	D1,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D4,-314(A0)
	MOVE.B	D6,-167(A0)
	MOVE.B	D6,-161(A0)
	MOVE.B	D5,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D6,-7(A0)
	MOVE.B	D6,-1(A0)
	MOVE.B	D5,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D6,153(A0)
	MOVE.B	D6,159(A0)
	MOVE.B	D5,160(A0)
	MOVE.B	D5,166(A0)

DOGEAR1	ADDA.W	#8*160,A0
	CMPI.B	#1,D0
	BNE.S	GEAR1OFF

	MOVE.B	D2,-327(A0)
	MOVE.B	D3,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D5,-314(A0)
	MOVE.B	D1,-167(A0)
	MOVE.B	D3,-161(A0)
	MOVE.B	D4,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D1,-7(A0)
	MOVE.B	D3,-1(A0)
	MOVE.B	D4,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D1,153(A0)
	MOVE.B	D3,159(A0)
	MOVE.B	D4,160(A0)
	MOVE.B	D5,166(A0)
	BRA.S	DOGEAR0

GEAR1OFF	MOVE.B	D1,-327(A0)
	MOVE.B	D1,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D4,-314(A0)
	MOVE.B	D6,-167(A0)
	MOVE.B	D6,-161(A0)
	MOVE.B	D5,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D6,-7(A0)
	MOVE.B	D6,-1(A0)
	MOVE.B	D5,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D6,153(A0)
	MOVE.B	D6,159(A0)
	MOVE.B	D5,160(A0)
	MOVE.B	D5,166(A0)

DOGEAR0	ADDA.W	#8*160,A0
	TST.B	D0
	BNE.S	GEAR0OFF

	MOVE.B	D2,-327(A0)
	MOVE.B	D3,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D5,-314(A0)
	MOVE.B	D1,-167(A0)
	MOVE.B	D3,-161(A0)
	MOVE.B	D4,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D1,-7(A0)
	MOVE.B	D3,-1(A0)
	MOVE.B	D4,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D1,153(A0)
	MOVE.B	D3,159(A0)
	MOVE.B	D4,160(A0)
	MOVE.B	D5,166(A0)
	BRA.S	GEARSDONE

GEAR0OFF	MOVE.B	D1,-327(A0)
	MOVE.B	D1,-321(A0)
	MOVE.B	D4,-320(A0)
	MOVE.B	D4,-314(A0)
	MOVE.B	D6,-167(A0)
	MOVE.B	D6,-161(A0)
	MOVE.B	D5,-160(A0)
	MOVE.B	D5,-154(A0)
	MOVE.B	D6,-7(A0)
	MOVE.B	D6,-1(A0)
	MOVE.B	D5,(A0)
	MOVE.B	D5,6(A0)
	MOVE.B	D6,153(A0)
	MOVE.B	D6,159(A0)
	MOVE.B	D5,160(A0)
	MOVE.B	D5,166(A0)

GEARSDONE	MOVE.L	BLITBASE+2,A3
	BSR	SCORE
	CLR.B	DRAWFLAG+1
	MOVE.W	BIKEX+2,D0
	LSR.W	#3,D0
LASTSCORE	CMPI.W	#0,D0
	BCC.S	NOSCORE
	ADDQ.L	#1,SCORE+2
NOSCORE	MOVE.W	D0,LASTSCORE+2
	MOVEQ	#7,D1
	MOVE.B	$FFFF8209.W,D0
	LSR.W	#1,D0
	ANDI.W	#7,D0	0-7
	MOVE.W	D0,DRAWSCREEN1+2
	ADD.W	D0,D1	7-14
	CMPI.W	#11,D1	7-10 ?
	BCS.S	TIMESET	YES
	SUBQ.W	#1,D1	10-13
TIMESET	MOVE.W	D1,TIME+2
MAINLOOP	JMP	NEWMAIN

*	ROUTINE TO POSITION AND DRAW BLOCKS ON SCREEN

BLOCKPOS	MOVEM.L	D0-D7,-(A7)	STACK REGS.
	MOVE.W	(A1)+,D0	BLOCKS YPOS
	MOVE.W	(A1)+,D4	BLOCK ID. AND FLAGS
	MOVE.W	D4,FLAGHERE+2	STORE FLAGS
	SUB.W	BIKEY+2,D0	SUBTRACT BIKES YPOS
	ADDI.W	#76,D0	BASE OF BIKE
	CMPI.W	#96,D0	BELOW DISPLAY ?
	BLT.S	NOTBELOW	NO
	MOVEM.L	(A7)+,D0-D7	RESTORE REGS.
	RTS

NOTBELOW	MOVE.W	D0,BLOCKTOP+2	STORE FOR BASEBLOCK
	MOVE.W	D4,D2	COPY ID.
	ANDI.W	#$FF,D2	ID.
	MOVE.B	0(A5,D2.W),D2	HEIGHT OF BLOCK
	MOVE.W	D2,BLOCKHGHT+2	STORE FOR BASEBLOCK
	MOVE.W	D0,D1	ABOVE SCREEN ?
	BPL.S	ONSCREEN	NO
	ADD.W	D2,D1	SOME ON SCREEN ?
	BLE	DRAWBASE	NO
	NEG.W	D0	NO. OF LINES ABOVE SCREEN
	MOVE.W	D0,D7	POSITION DOWN BLOCK
	MOVEQ	#0,D0	AT TOP OF SCREEN
	CMPI.W	#96,D1	>AREA ?
	BCS.S	GOTLINE	NO
	MOVEQ	#96,D1	MAX HEIGHT
	BRA.S	GOTLINE
ONSCREEN	MOVEQ	#0,D7	TOP OF SOURCE
	NEG.W	D1	SUBTRACT START LINE
	ADDI.W	#96,D1	FROM 96 GIVES HEIGHT
	CMP.W	D2,D1	< BLOCK HEIGHT ?
	BCS.S	GOTLINE	YES ONLY PART OF BLOCK
	MOVE.W	D2,D1	ELSE USE ALL BLOCK

*    NB. D0=LINES DOWN SCREEN D1=LINES TO PRINT D7=LINES DOWN BLOCK/SOURCE ROTATION
*        D5=COLUMN ACROSS SCREEN D3=ROTATION (0-31) D4=BLOCK ID.

GOTLINE	MOVE.W	D1,LINECOUNT	LINES TO PRINT
BLITBASE	MOVE.L	#0,A2	SCREEN BASE
	MULU	#160,D0	OFFSET DOWN SCREEN
	ADD.W	D5,D0	OFFSET ACCROSS SCREEN
	LEA	-16(A2,D0.W),A2 ONE BLOCK EARLY
	MOVE.L	BLOCKADDS,A3	ADDRESSES OF BLOCKS
	ANDI.W	#$FF,D4	ID.
	LSL.W	#2,D4	LONG WORD OFFSET
	MOVE.L	0(A3,D4.W),A3	BLOCK BASE ADDRESS
	MOVE.L	MASKADDS,A4	ADDRESSES OF MASKS
	MOVE.L	0(A4,D4.W),A4	MASK BASE ADDRESS
	MOVE.W	D7,D0	COPY START LINE FOR SOURCE ROTATION
	ANDI.W	#15,D0	ROTATION 0-15
	LSL.W	#3,D7	LINES DOWN*8 FOR MASKS
	ADDA.W	D7,A4	START LINE IN MASK DATA
	LSL.W	#1,D7	LINES DOWN*16 FOR BLOCKS
	ADDA.W	D7,A3	START LINE IN BLOCK DATA

*	SOURCE ROTATION IN D0,REQUIRED ROTATION IN D3

CARRYMASK	MOVE.L	#0,D1
RMNSMASK	MOVE.L	#0,D2

	TST.W	D5	FIRST BLOCK ?
	BEQ	FIRSTBLOCK	YES
	CMPI.W	#160,D5	LAST BLOCK ?
	BEQ	LASTBLOCK	YES

	CMPI.W	#16,D3	ROTATION 0-15 ?
	BLT.S	MIDROTOK	YES
	ADDQ	#8,A2	HALF A BLOCK ACROSS
	ANDI.W	#15,D3	ROTATION 0-15
MIDROTOK	MOVE.B	D3,MIDROT+1	STORE REQUIRED ROTATION

MIDLINE	SUB.W	D0,D3	-SOURCE ROTATION
	BMI	MIDREV	IF - THEN CARRY CORRECT FOR ROR
	CMPI.W	#8,D3	IF 0-8 THEN REMAINS CORRECT FOR ROR
	BHI	MIDBACKL	ELSE CARRY CORRECT FOR ROL

MIDNORMR	SWAP	D0	STORE SOURCE ROTATION IN HIGH WORD
	MOVE.W	D3,D0	ROR 0-8

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSIION OF CARRY MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D4
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D5
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTMIDLINE

MIDBACKL	SWAP	D0
	MOVE.W	#16,D0
	SUB.W	D3,D0	ROL 1-7

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTMIDLINE

MIDREV	CMPI.W	#-7,D3
	BLT	MIDBACKR

MIDNORML	SWAP	D0
	MOVE.W	D3,D0
	NEG.W	D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSIION OF CARRY MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D4
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D5
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTMIDLINE

MIDBACKR	SWAP	D0
	MOVE.W	#16,D0
	ADD.W	D3,D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

NEXTMIDLINE	ADDA.W	#136,A2	NEXT DEST. LINE
	SWAP	D0
	ADDQ.W	#1,D0
	ANDI.W	#15,D0
MIDROT	MOVEQ	#0,D3
	SUBQ.W	#1,LINECOUNT
	BNE	MIDLINE

	BTST	#6,FLAGHERE+2	ANY INFILL ?
	BEQ.S	NOBASE	NO
BLOCKTOP	MOVE.W	#0,D0	TOP OF BLOCK
BLOCKHGHT	ADD.W	#0,D0	HEIGHT OF BLOCK
	BGT.S	NOTATTOP
	MOVEQ	#0,D0
NOTATTOP	CMPI.W	#96,D0
	BGE.S	NOBASE

*	ROUTINE TO DRAW INFILL IN CENTRE OF SCREEN
*	NB. A2 POINTS TO START OF DESTINATION
*	    CARRY MASK IN D1, REMAINS MASK IN D2
*	    JUMP OFFSET IN D0 (0-119) FOR 120-1 LINE/S

DRAWMIDBASE	LEA	MIDFILLS,A4
	LSL.W	#3,D0	*8
	ADDA.W	D0,A4	+
	LSL.W	#1,D0	*16
	ADDA.W	D0,A4	=*24
	MOVE.L	PLANES12,D0	1ST 2 PLANES
	MOVE.L	D0,D4	COPY FOR REMAINS
	MOVE.L	D0,D6	COPY FOR CARRY
	AND.L	D2,D4	REMAINS BITS
	AND.L	D1,D6	CARRY BITS
	MOVE.L	PLANES34,D3	2ND 2 PLANES
	MOVE.L	D3,D5	COPY FOR REMAINS
	MOVE.L	D3,D7	COPY FOR CARRY
	AND.L	D2,D5	REMAINS BITS
	AND.L	D1,D7	CARRY BITS
	JMP	(A4)

NOBASE	MOVEM.L	(A7)+,D0-D7
	RTS

*	ROUTINE TO DRAW INFILL IF BLOCK ENTIRELY OFF TOP OF SCREEN

DRAWBASE	BTST	#6,FLAGHERE+2	INFILL ?
	BEQ.S	NOBASE	NO
	MOVEQ	#0,D0	TOP LINE
	MOVE.L	BLITBASE+2,A2	SCREEN BASE
	LEA	-16(A2,D5.W),A2 ONE BLOCK EARLY
	CMPI.W	#16,D3	ROTATION 0-15 ?
	BLT.S	DESTOK	YES
	ADDQ	#8,A2	HALF A BLOCK ACROSS
DESTOK	MOVE.L	CARRYMASK+2,D1	CARRY MASK
	MOVE.L	RMNSMASK+2,D2	REMAINS MASK
	TST.W	D5	FIRST COLUMN ?
	BEQ.S	LEFTFILL	YES
	CMPI.W	#160,D5	LAST COLUMN ?
	BNE	DRAWMIDBASE	NO

RIGHTFILL	CMPI.W	#15,D3
	BHI.S	ONERIGHT
FILL2RIGHT	LEA	RIGHT2FILLS,A4
	LSL.W	#4,D0	*16
	ADDA.W	D0,A4
	MOVE.L	PLANES12,D0	1ST 2 PLANES
	MOVE.L	D0,D4	COPY FOR REMAINS
	AND.L	D2,D4	REMAINS BITS
	MOVE.L	PLANES34,D3	2ND 2 PLANES
	MOVE.L	D3,D5	COPY FOR REMAINS
	AND.L	D2,D5	REMAINS BITS
	JMP	(A4)

LEFTFILL	TST.W	D3
	BEQ.S	NOBASE
	CMPI.W	#16,D3
	BLT.S	ONELEFT
	ADDQ	#8,A2
FILL2LEFT	LEA	LEFT2FILLS,A4
	LSL.W	#4,D0	*16
	ADDA.W	D0,A4
	MOVE.L	PLANES12,D0	1ST 2 PLANES
	MOVE.L	D0,D6	COPY FOR CARRY
	AND.L	D1,D6	CARRY BITS
	MOVE.L	PLANES34,D3	2ND 2 PLANES
	MOVE.L	D3,D7	COPY FOR CARRY
	AND.L	D1,D7	CARRY BITS
	JMP	(A4)

ONERIGHT	LEA	RIGHT1FILLS,A4
	LSL.W	#2,D0	*4
	ADDA.W	D0,A4	+
	LSL.W	#1,D0	*8
	ADDA.W	D0,A4	=*12
	MOVE.L	PLANES12,D0	1ST 2 PLANES
	AND.L	D2,D0	REMAINS BITS
	MOVE.L	PLANES34,D3	2ND 2 PLANES
	AND.L	D2,D3	REMAINS BITS
	JMP	(A4)

ONELEFT	ADDA.W	#16,A2
FILL1LEFT	LEA	LEFT1FILLS,A4
	LSL.W	#2,D0	*4
	ADDA.W	D0,A4
	LSL.W	#1,D0	+*8
	ADDA.W	D0,A4	=*12
	MOVE.L	PLANES12,D0	1ST 2 PLANES
	AND.L	D1,D0	CARRY BITS
	MOVE.L	PLANES34,D3	2ND 2 PLANES
	AND.L	D1,D3	CARRY BITS
	JMP	(A4)

MIDFILLS	REPT	96

	AND.L	D1,(A2)	HOLE FOR REMAINS
	OR.L	D4,(A2)+
	AND.L	D1,(A2)
	OR.L	D5,(A2)+

	MOVE.L	D0,(A2)+
	MOVE.L	D3,(A2)+

	AND.L	D2,(A2)	HOLE FOR CARRY
	OR.L	D6,(A2)+
	AND.L	D2,(A2)
	OR.L	D7,(A2)+

	ADDA.W	#136,A2

	ENDR

	BRA	NOBASE

LEFT2FILLS	REPT	96

	MOVE.L	D0,(A2)+
	MOVE.L	D3,(A2)+

	AND.L	D2,(A2)
	OR.L	D6,(A2)+
	AND.L	D2,(A2)
	OR.L	D7,(A2)+

	ADDA.W	#144,A2

	ENDR

	BRA	NOBASE

LEFT1FILLS	REPT	96

	AND.L	D2,(A2)
	OR.L	D0,(A2)+
	AND.L	D2,(A2)
	OR.L	D3,(A2)+

	ADDA.W	#152,A2

	ENDR

	BRA	NOBASE

RIGHT2FILLS	REPT	96

	AND.L	D1,(A2)	HOLE FOR REMAINS
	OR.L	D4,(A2)+
	AND.L	D1,(A2)
	OR.L	D5,(A2)+

	MOVE.L	D0,(A2)+
	MOVE.L	D3,(A2)+

	ADDA.W	#144,A2

	ENDR

	BRA	NOBASE

RIGHT1FILLS	REPT	96

	AND.L	D1,(A2)	HOLE FOR REMAINS
	OR.L	D0,(A2)+
	AND.L	D1,(A2)
	OR.L	D3,(A2)+

	ADDA.W	#152,A2

	ENDR

	BRA	NOBASE

FIRSTBLOCK	ADDA.W	#16,A2
	CMPI.W	#16,D3
	BLT	LEFT1LINE
	ANDI.W	#15,D3
	MOVE.B	D3,LEFT2ROT+1	STORE REQUIRED ROTATION

LEFTLINE2	SUB.W	D0,D3	-SOURCE ROTATION
	BMI	LEFT2REV	IF - THEN CARRY CORRECT FOR ROR
	CMPI.W	#8,D3	IF 0-8 THEN REMAINS CORRECT FOR ROR
	BHI	LEFT2BACKL	ELSE CARRY CORRECT FOR ROL

LEFT2NORMR	SWAP	D0	STORE SOURCE ROTATION IN HIGH WORD
	MOVE.W	D3,D0	ROR 0-8

	MOVE.L	(A4)+,D7	MASK FOR 1ST HALF
	ROR.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROR.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROR.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSIION OF CARRY MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D4
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D5
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTLEFTLINE2

LEFT2BACKL	SWAP	D0
	MOVE.W	#16,D0
	SUB.W	D3,D0	ROL 1-7

	MOVE.L	(A4)+,D7	MASK FOR 1ST HALF
	ROL.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROL.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROL.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTLEFTLINE2

LEFT2REV	CMPI.W	#-7,D3
	BLT	LEFT2BACKR

LEFT2NORML	SWAP	D0
	MOVE.W	D3,D0
	NEG.W	D0

	MOVE.L	(A4)+,D7	MASK FOR 1ST HALF
	ROL.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROL.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROL.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSIION OF CARRY MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D4
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D5
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

	BRA	NEXTLEFTLINE2

LEFT2BACKR	SWAP	D0
	MOVE.W	#16,D0
	ADD.W	D3,D0

	MOVE.L	(A4)+,D7	MASK FOR 1ST HALF
	ROR.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROR.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROR.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D4
	AND.L	D1,D4
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	MOVE.L	D3,D5
	AND.L	D1,D5
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	AND.L	D7,(A2)
	OR.L	D4,(A2)+
	AND.L	D7,(A2)
	OR.L	D5,(A2)+

NEXTLEFTLINE2	ADDA.W	#144,A2	NEXT DEST. LINE
	SWAP	D0
	ADDQ.W	#1,D0
	ANDI.W	#15,D0
LEFT2ROT	MOVEQ	#0,D3
	SUBQ.W	#1,LINECOUNT
	BNE	LEFTLINE2

	BTST	#6,FLAGHERE+2	ANY INFILL ?
	BEQ	NOBASE	NO
	MOVE.W	BLOCKTOP+2,D0	TOP OF BLOCK
	ADD.W	BLOCKHGHT+2,D0	HEIGHT OF BLOCK
	BGT.S	NOTATTOP1
	MOVEQ	#0,D0
NOTATTOP1	CMPI.W	#96,D0
	BGE	NOBASE
	BRA	FILL2LEFT

LEFT1LINE	MOVE.B	D3,LEFT1ROT+1	STORE REQUIRED ROTATION

LEFTLINE1	SUB.W	D0,D3	-SOURCE ROTATION
	BMI	LEFT1REV	IF - THEN CARRY CORRECT FOR ROR
	CMPI.W	#8,D3	IF 0-8 THEN REMAINS CORRECT FOR ROR
	BHI	LEFT1BACKL	ELSE CARRY CORRECT FOR ROL

LEFT1NORMR	SWAP	D0	STORE SOURCE ROTATION IN HIGH WORD
	MOVE.W	D3,D0	ROR 0-8

	ADDQ	#4,A4	NO 1ST HALF MASK
	ADDQ	#8,A3	NO 1ST HALF DATA

	MOVE.L	(A4)+,D7	MASK FOR 2ND HALF
	ROR.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROR.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROR.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D4,(A2)+	1ST TWO PLANES CARRY DONE
	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D5,(A2)+	2ND TWO PLANES CARRY DONE

	BRA	NEXTLEFTLINE1

LEFT1BACKL	SWAP	D0
	MOVE.W	#16,D0
	SUB.W	D3,D0	ROL 1-7

	ADDQ	#4,A4	NO 1ST HALF MASK
	ADDQ	#8,A3	NO 1ST HALF DATA

	MOVE.L	(A4)+,D7	MASK FOR 2ND HALF
	ROL.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROL.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROL.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D4,(A2)+	1ST TWO PLANES CARRY DONE
	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D5,(A2)+	2ND TWO PLANES CARRY DONE

	BRA	NEXTLEFTLINE1

LEFT1REV	CMPI.W	#-7,D3
	BLT	LEFT1BACKR

LEFT1NORML	SWAP	D0
	MOVE.W	D3,D0
	NEG.W	D0

	ADDQ	#4,A4	NO 1ST HALF MASK
	ADDQ	#8,A3	NO 1ST HALF DATA

	MOVE.L	(A4)+,D7	MASK FOR 2ND HALF
	ROL.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROL.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROL.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D4,(A2)+	1ST TWO PLANES CARRY DONE
	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D5,(A2)+	2ND TWO PLANES CARRY DONE

	BRA	NEXTLEFTLINE1

LEFT1BACKR	SWAP	D0
	MOVE.W	#16,D0
	ADD.W	D3,D0

	ADDQ	#4,A4	NO 1ST HALF MASK
	ADDQ	#8,A3	NO 1ST HALF DATA

	MOVE.L	(A4)+,D7	MASK FOR 2ND HALF
	ROR.L	D0,D7	ROTATE
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D4	GET 1ST TWO PLANES
	ROR.L	D0,D4	ROTATE
	AND.L	D1,D4	CARRY BITS ONLY

	MOVE.L	(A3)+,D5	GET 2ND TWO PLANES
	ROR.L	D0,D5	ROTATE
	AND.L	D1,D5	CARRY BITS ONLY

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D4,(A2)+	1ST TWO PLANES CARRY DONE
	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	OR.L	D5,(A2)+	2ND TWO PLANES CARRY DONE

NEXTLEFTLINE1	ADDA.W	#152,A2	NEXT DEST. LINE
	SWAP	D0
	ADDQ.W	#1,D0
	ANDI.W	#15,D0
LEFT1ROT	MOVEQ	#0,D3
	SUBQ.W	#1,LINECOUNT
	BNE	LEFTLINE1

	BTST	#6,FLAGHERE+2	ANY INFILL ?
	BEQ	NOBASE	NO
	MOVE.W	BLOCKTOP+2,D0	TOP OF BLOCK
	ADD.W	BLOCKHGHT+2,D0	HEIGHT OF BLOCK
	BGT.S	NOTATTOP2
	MOVEQ	#0,D0
NOTATTOP2	CMPI.W	#96,D0
	BGE	NOBASE
	BRA	FILL1LEFT

LASTBLOCK	CMPI.W	#15,D3
	BHI	RIGHTLINE1
	MOVE.B	D3,RIGHT2ROT+1	STORE REQUIRED ROTATION

RIGHT2LINE	SUB.W	D0,D3	-SOURCE ROTATION
	BMI	RIGHT2REV	IF - THEN CARRY CORRECT FOR ROR
	CMPI.W	#8,D3	IF 0-8 THEN REMAINS CORRECT FOR ROR
	BHI	RIGHT2BACKL	ELSE CARRY CORRECT FOR ROL

RIGHT2NORMR	SWAP	D0	STORE SOURCE ROTATION IN HIGH WORD
	MOVE.W	D3,D0	ROR 0-8

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	BRA	NEXTRIGHT2LINE

RIGHT2BACKL	SWAP	D0
	MOVE.W	#16,D0
	SUB.W	D3,D0	ROL 1-7

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	BRA	NEXTRIGHT2LINE

RIGHT2REV	CMPI.W	#-7,D3
	BLT	RIGHT2BACKR

RIGHT2NORML	SWAP	D0
	MOVE.W	D3,D0
	NEG.W	D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK
	SWAP	D7	CORRECT POSITION OF CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D4	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D5	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROL.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROL.L	D0,D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	BRA	NEXTRIGHT2LINE

RIGHT2BACKR	SWAP	D0
	MOVE.W	#16,D0
	ADD.W	D3,D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	MOVE.L	D6,D7	COPY FOR CARRY
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK
	OR.L	D2,D7	SET REMAINS BITS FOR CARRY MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D4	COPY FOR CARRY
	AND.L	D1,D4	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	MOVE.L	D3,D5	COPY FOR CARRY
	AND.L	D1,D5	CARRY BITS ONLY
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	AND.L	D7,(A2)	CLEAR HOLE FOR CARRY
	AND.L	D7,4(A2)	FOR ALL PLANES
	OR.L	D4,(A2)	1ST TWO PLANES CARRY DONE

	MOVE.L	(A4)+,D6	MASK FOR 2ND HALF
	ROR.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSIION OF REMAINS MASK

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

	OR.L	D5,(A2)

	MOVE.L	(A3)+,D3
	ROR.L	D0,D3
	SWAP	D3
	AND.L	D2,D3
	AND.L	D6,(A2)
	OR.L	D3,(A2)+

NEXTRIGHT2LINE	ADDA.W	#144,A2	NEXT DEST. LINE
	SWAP	D0
	ADDQ.W	#1,D0
	ANDI.W	#15,D0
RIGHT2ROT	MOVEQ	#0,D3
	SUBQ.W	#1,LINECOUNT
	BNE	RIGHT2LINE

	BTST	#6,FLAGHERE+2	ANY INFILL ?
	BEQ	NOBASE	NO
	MOVE.W	BLOCKTOP+2,D0	TOP OF BLOCK
	ADD.W	BLOCKHGHT+2,D0	HEIGHT OF BLOCK
	BGT.S	NOTATTOP3
	MOVEQ	#0,D0
NOTATTOP3	CMPI.W	#96,D0
	BGE	NOBASE
	BRA	FILL2RIGHT

RIGHTLINE1	ANDI.W	#15,D3
	ADDQ	#8,A2
	MOVE.B	D3,RIGHT1ROT+1	STORE REQUIRED ROTATION

RIGHT1LINE	SUB.W	D0,D3	-SOURCE ROTATION
	BMI	RIGHT1REV	IF - THEN CARRY CORRECT FOR ROR
	CMPI.W	#8,D3	IF 0-8 THEN REMAINS CORRECT FOR ROR
	BHI	RIGHT1BACKL	ELSE CARRY CORRECT FOR ROL

RIGHT1NORMR	SWAP	D0	STORE SOURCE ROTATION IN HIGH WORD
	MOVE.W	D3,D0	ROR 0-8

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	ADDQ	#4,A4	NO 2ND HALF MASK
	ADDQ	#8,A3	NO 2ND HALF DATA

	BRA	NEXTRIGHT1LINE

RIGHT1BACKL	SWAP	D0
	MOVE.W	#16,D0
	SUB.W	D3,D0	ROL 1-7

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	ADDQ	#4,A4	NO 2ND HALF MASK
	ADDQ	#8,A3	NO 2ND HALF DATA

	BRA	NEXTRIGHT1LINE

RIGHT1REV	CMPI.W	#-7,D3
	BLT	RIGHT1BACKR

RIGHT1NORML	SWAP	D0
	MOVE.W	D3,D0
	NEG.W	D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROL.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROL.L	D0,D3	ROTATE
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROL.L	D0,D3	ROTATE
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	ADDQ	#4,A4	NO 2ND HALF MASK
	ADDQ	#8,A3	NO 2ND HALF DATA

	BRA	NEXTRIGHT1LINE

RIGHT1BACKR	SWAP	D0
	MOVE.W	#16,D0
	ADD.W	D3,D0

	MOVE.L	(A4)+,D6	MASK FOR 1ST HALF
	ROR.L	D0,D6	ROTATE
	OR.L	D1,D6	SET CARRY BITS FOR REMAINS MASK
	SWAP	D6	CORRECT POSITION OF REMAINS MASK

	MOVE.L	(A3)+,D3	GET 1ST TWO PLANES
	ROR.L	D0,D3	ROTATE
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	1ST TWO PLANES REMAINS DONE

	MOVE.L	(A3)+,D3	GET 2ND TWO PLANES
	ROR.L	D0,D3	ROTATE
	SWAP	D3	CORRECT POSITION
	AND.L	D2,D3	REMAINS BITS ONLY
	AND.L	D6,(A2)	CLEAR HOLE FOR REMAINS
	OR.L	D3,(A2)+	2ND TWO PLANES REMAINS DONE

	ADDQ	#4,A4	NO 2ND HALF MASK
	ADDQ	#8,A3	NO 2ND HALF DATA

NEXTRIGHT1LINE	ADDA.W	#152,A2	NEXT DEST. LINE
	SWAP	D0
	ADDQ.W	#1,D0
	ANDI.W	#15,D0
RIGHT1ROT	MOVEQ	#0,D3
	SUBQ.W	#1,LINECOUNT
	BNE	RIGHT1LINE

	BTST	#6,FLAGHERE+2	ANY INFILL ?
	BEQ	NOBASE	NO
	MOVE.W	BLOCKTOP+2,D0	TOP OF BLOCK
	ADD.W	BLOCKHGHT+2,D0	HEIGHT OF BLOCK
	BGT.S	NOTATTOP4
	MOVEQ	#0,D0
NOTATTOP4	CMPI.W	#96,D0
	BGE	NOBASE
	BRA	ONERIGHT

SKYGROUND	REPT	96*4

	MOVEM.L	D0-D5/A0-A3,-(A4)

	ENDR

	RTS

*	RESTORE COLOUR PALLETTE, MOUSE, STACK AND EXIT

OLDKEYVEC	MOVE.L	#READKEY,-(A7)
	MOVE.L	#$D0006,-(A7)
	TRAP	#14
	ADDQ.W	#8,A7
	MOVE.L	#KEYS1,-(A7)
	MOVE.L	#$190001,-(A7)	RESET KYBRD,MON,JON
	TRAP	#14
	ADDQ	#8,A7
OLDVBL	MOVE.L	#0,$70.W
	CLR.B	$FFFFFA1B.W	STOP TIMER B
	DC.W	$A009	PUT MOUSE BACK
	LEA	$FFFF8240.W,A1
	LEA	OLDPAL,A0
	MOVEQ	#7,D0
RESTOPAL	MOVE.L	(A0)+,(A1)+
	DBF	D0,RESTOPAL
	MOVE.L	SCREEN1+2,D0
	SWAP	D0
	MOVE.B	D0,$FFFF8201.W
	SWAP	D0
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8203.W
OLDSSP	MOVE.L	#0,A7
OLDSR	MOVE.W	#0,SR
OLDUSP	MOVE.L	#0,A7
	CLR.W	-(A7)
	TRAP	#1

*	READ KYBRD/JOYSTICK

READKEY	MOVEM.L	D0/D1/A0,-(A7)
	LEA	$FFFFFC00.W,A0
	MOVE.B	(A0),D0
	MOVE.B	2(A0),D0
JKFLG	MOVEQ	#0,D1
	BNE.S	JOYVAL

	CMPI.B	#$FD,D0
	BHI.S	NEWJOY

	MOVE.B	D0,KEYREAD+1
	BRA.S	JKDONE

NEWJOY	MOVE.B	D0,D1
	BRA.S	JKDONE

JOYVAL	CMPI.B	#$FF,D1
	BNE.S	JKDONEA

	MOVEQ	#0,D1
	TST.B	D0
	BMI.S	FIREON
	MOVEQ	#$10,D1
FIREON	ANDI.B	#$F,D0
	OR.B	D1,D0
	MOVE.B	D0,JOYSTICK+1

JKDONEA	MOVEQ	#0,D1
JKDONE	MOVE.B	D1,JKFLG+1
	BCLR	#6,$FFFFFA11.W
	MOVEM.L	(A7)+,D0/D1/A0
	RTE

*	VBL ROUTINE
*	COUNT,FLIP,FADE AND RESET NO. OF LINES FOR DE TIMER B

MYVBL	MOVEM.L	D0-D2/A0-A2,-(A7)
	LEA	$FFFF8240.W,A0
	LEA	MAINPAL,A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	CLR.B	$FFFFFA1B.W	STOP TIMER B
DEFLAG	MOVEQ	#0,D0	SPLIT SCREEN ?
	BEQ.S	NOSPLIT	NO
	MOVE.B	#96,$FFFFFA21.W CHANGE ON LINE 96
	MOVE.B	#8,$FFFFFA1B.W	TIMER B EVENT COUNT
	CLR.B	DENUMBER+1	SET COUNTER FOR DEIRQ
NOSPLIT	ADDQ.W	#1,$468.W	COUNTER
	CLR.B	DEDONE+1	LAST SPLIT NOT DONE
FLIPFLAG	MOVEQ	#-1,D0	FLIP ENABLED ?
	BNE.S	MAINFLAG	NO
	CMPI.W	#5,$468.W	FLIP YET ?
	BCS.S	MAINFLAG	NO
DRAWFLAG	MOVEQ	#0,D0	DRAWN SCREEN ?
	BNE.S	MAINFLAG	NO
	CLR.W	$468.W	RESET COUNTER
FLAGTEST	MOVEQ	#0,D1	TIMER ON ?
	BEQ.S	SCREEN1	NO
TIME	SUBI.W	#10,SECONDS+2	SECONDS GONE ?
	BPL.S	SCREEN1	NO
	ADDI.W	#6000,SECONDS+2   ADD A MINUTE
	SUBQ.W	#1,MINUTES+2	MINUTES GONE ?
	BPL.S	SCREEN1	NO
	CLR.W	SECONDS+2	RUN OUT
	CLR.W	MINUTES+2	OF TIME
	MOVE.W	#-2,CRASH+2	GAME OVER
SCREEN1	MOVE.L	#0,D0	FLIP SCREEN 1
SCREEN2	MOVE.L	#0,D1	FLIP SCREEN 2
	NOT.W	FLIP	DRAW ON SCREEN 1 ?
	BNE.S	DISPLAY2	YES
	MOVE.L	D1,BLITBASE+2	DRAW ON SCREEN 2
	BRA.S	SETDISPLAY	AND DISPLAY SCREEN 1
DISPLAY2	MOVE.L	D0,BLITBASE+2	DRAW ON SCREEN 1
	MOVE.L	D1,D0	AND DISPLAY SCREEN 2
SETDISPLAY	MOVE.L	D0,SCREENON+2
	SWAP	D0	HIGH WORD
	MOVE.B	D0,$FFFF8201.W	LOW BYTE
	SWAP	D0	LOW WORD
	LSR.W	#8,D0	HIGH BYTE
	MOVE.B	D0,$FFFF8203.W
MAINFLAG	MOVEQ	#0,D0	ANY FADE ?
	BEQ.S	DISKWAIT	NO
	LEA	MAINPAL,A0	COLOURS
	LEA	MAINSTORE,A1	CURRENT VALUES OF RGB
	LEA	MAINVALS,A2	FRACTIONAL CHANGES
	MOVEQ	#15,D0	16 COLOURS
.FADE	MOVE.W	(A1),D1	GET CURRENT RED
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE RED
	MOVE.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT GREEN
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE GREEN
	LSR.W	#4,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT BLUE
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE BLUE
	LSR.W	#8,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	D2,(A0)+	NEW DISPLAY COLOUR
	DBF	D0,.FADE	DO ALL 16
	SUBQ.B	#1,MAINFLAG+1	REDUCE MAIN FADE COUNT
DISKWAIT	TST.W	$43E.W	FLOPPIES IN USE ?
	BEQ.S	FLOPFLAG	NO
	MOVE.B	#-1,FLOPFLAG+1	ENABLE DESELECT
	BRA.S	SNDFLAG
FLOPFLAG	MOVEQ	#-1,D0	FLOPPIES DESELECTED ?
	BEQ.S	SNDFLAG	YES
	MOVE.W	#$80,$FFFF8606.W   SELECT STATUS REG.
.WAIT	MOVE.W	$FFFF8604.W,D0	GET STATUS
	BTST	#7,D0	MOTOR ON ?
	BNE.S	SNDFLAG	YES
	MOVE.B	#$E,$FFFF8800.W	SELECT PORT A
	MOVE.B	$FFFF8800.W,D0	READ BYTE
	ORI.W	#7,D0	SET BITS FOR DESELECT
	MOVE.B	D0,$FFFF8802.W
	CLR.B	FLOPFLAG+1	FLOPPIES DESELECTED
SNDFLAG	MOVEQ	#-1,D0
	BMI.S	TUNEFLAG
	LEA	$FFFF8800.W,A0
	NOT.B	SNDFLAG+1
	LSL.W	#2,D0
	LEA	MYSOUNDS,A1
	MOVE.L	0(A1,D0.W),A1
.NEXTREG	MOVE.B	(A1)+,D0
	MOVE.B	D0,(A0)
	CMPI.B	#7,D0
	BEQ.S	.LASTREG
	MOVE.B	(A1)+,2(A0)
	BRA.S	.NEXTREG
.LASTREG	MOVE.B	(A0),D0	CONTROL
	ANDI.B	#$C0,D0	ALTER
	OR.B	(A1)+,D0	TONE AND NOISE
	MOVE.B	D0,2(A0)	WITHOUT DISTURBING
TUNEFLAG	MOVEQ	#0,D0
	BEQ.S	EXITVBL
	MOVEM.L	D3-D7/A3-A6,-(A7)
	TST.W	D0
	BMI.S	TUNEOFF
TUNEADD	LEA	TUNE1,A0
	TST.B	8(A0)
	BNE.S	NOTFIN
	CLR.B	TUNEFLAG+1
	BRA.S	TUNEDONE
NOTFIN	CMPI.B	#1,8(A0)	TUNE FINISHED ?
	BNE.S	PLAYING	NO
LOOPFLAG	MOVEQ	#-1,D0	LOOP TUNE ?
	BNE.S	TUNENO	YES
	BRA.S	PLAYING
TUNEOFF	MOVE.L	TUNEADD+2,A0
	LEA	14(A0),A0
	JSR	(A0)
	CLR.B	TUNEFLAG+1
TUNENO	MOVEQ	#-1,D0
	BMI.S	TUNEDONE
	MOVE.B	#1,TUNEFLAG+1
	MOVE.L	TUNEADD+2,A0
	JSR	(A0)
	MOVE.L	TUNEADD+2,A0	PLAY CURRENT TUNE
PLAYING	LEA	4(A0),A0
	JSR	(A0)
TUNEDONE	MOVEM.L	(A7)+,D3-D7/A3-A6
EXITVBL	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTE

*	DISPLAY ENABLE INTERRUPT

DEIRQ	MOVEM.L	D0-D2/A0-A2,-(A7)
	CLR.B	$FFFFFA1B.W	STOP TIMER B
	LEA	$FFFF8240.W,A0
DENUMBER	MOVEQ	#0,D0	PLAN AREA ?
	BNE	DOPANEL	NO, PANEL
	LEA	PLANPAL,A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
SPLIT	MOVE.B	#37,$FFFFFA21.W SET NUMBER OF LINES
	MOVE.B	#8,$FFFFFA1B.W	RESTART TIMER B
	ADDQ.B	#1,DENUMBER+1	SET TO PANEL
PLANFLAG	MOVEQ	#0,D0	ANY FADE ?
	BEQ.S	PLANDONE	NO
	LEA	PLANPAL,A0	PALLET
	LEA	PLANSTORE,A1	CURRENT VALUES OF RGB
	LEA	PLANVALS,A2	FRACTIONAL CHANGES
	MOVEQ	#15,D0	16 COLOURS
.FADE	MOVE.W	(A1),D1	GET CURRENT RED
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE RED
	MOVE.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT GREEN
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE GREEN
	LSR.W	#4,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT BLUE
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE BLUE
	LSR.W	#8,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	D2,(A0)+	NEW DISPLAY COLOUR
	DBF	D0,.FADE	DO ALL 16
	SUBQ.B	#1,PLANFLAG+1	REDUCE MAIN FADE COUNT
PLANDONE	BCLR	#0,$FFFFFA0F.W
	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTE

DOPANEL	CMPI.B	#1,D0
	BNE	DOEND
	LEA	PANELPAL,A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.B	#-1,DEDONE+1	LAST SPLIT DONE
	TST.B	DEFLAG+1
	BMI.S	PANELFLAG
	MOVE.B	#16,$FFFFFA21.W SET NUMBER OF LINES
	MOVE.B	#8,$FFFFFA1B.W	RESTART TIMER B
	ADDQ.B	#1,DENUMBER+1	SET TO END
PANELFLAG	MOVEQ	#0,D0	ANY FADE ?
	BEQ.S	PANELDONE	NO
	LEA	PANELPAL,A0	COLOURS
	LEA	PANELSTORE,A1	CURRENT VALUES OF RGB
	LEA	PANELVALS,A2	FRACTIONAL CHANGES
	MOVEQ	#15,D0	16 COLOURS
.FADE	MOVE.W	(A1),D1	GET CURRENT RED
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE RED
	MOVE.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT GREEN
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE GREEN
	LSR.W	#4,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	(A1),D1	GET CURRENT BLUE
	ADD.W	(A2)+,D1	ADD CHANGE
	MOVE.W	D1,(A1)+	STORE AS CURRENT
	ANDI.W	#$700,D1	ISOLATE BLUE
	LSR.W	#8,D1	PUT IN CORRECT PLACE
	OR.W	D1,D2	COPY
	MOVE.W	D2,(A0)+	NEW DISPLAY COLOUR
	DBF	D0,.FADE	DO ALL 16
	SUBQ.B	#1,PANELFLAG+1	REDUCE MAIN FADE COUNT
PANELDONE	BCLR	#0,$FFFFFA0F.W
	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTE

DOEND	LEA	ENDPAL,A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADDQ.B	#1,DENUMBER+1	SET TO DONE
	BCLR	#0,$FFFFFA0F.W
	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTE
;+=============================================================+;
; Gremlin protection check			;
;-=============================================================-;
;set up register pointer
check_prot	move.l	a0,ptr
	lea	$ffff8604,a5
	st	$43e.w
;select side 0, drive A
	moveq	#5,d1
	bsr	select_drive_A
	moveq	#0,d0
	bsr	seek_track	seek track 0
	bsr.s	read_track	read it
	bsr	get_dma		get length
	move.l	d0,-(a7)
;	bsr	wait2
	moveq	#79,d0
	bsr	seek_track	seek track 79
	bsr.s	read_track	read it
	bsr	get_dma		get length
	sub.l	d0,(a7)
;	bsr	wait2
	cmpi.l	#60,(a7)+
	bgt.s	okay
error	clr.l	$420.w	Memory invalid
	move.l	4.w,a0	Reset
	jmp	(a0)
okay	moveq	#7,d1
	bsr	select_drive_A
	bra	load_game

read_track	bsr.s	wait
	bsr	set_dma
	move.w	#$90,2(a5)
	move.w	#$190,2(a5)		select read
	move.w	#$90,2(a5)
	MOVE.L	#5,(A6)
	bsr.s	fdc_delay
	move.w	#$1f,(a5)		set sector count register
	bsr.s	fdc_delay
	move.w	#$80,2(a5)		get command register
	bsr.s	fdc_delay
	move.w	#$e4,(a5)		read track (with settling delay)
	bsr.s	fdc_delay
.w_wait	btst	#5,$fffffa01		INTRQ ?
	bne.s	.w_wait
	rts

wait	move.w	#8000,d1
.wait	dbf	d1,.wait
	rts

get_status
	move.w	#$80,2(a5)	select status register
	bsr.s	fdc_delay
	move.w	(a5),d1
	bra.s	fdc_delay

d02fdc	bsr.s	fdc_delay
	move.w	d0,(a5)		send command/data
fdc_delay
	moveq	#36,d4
.delay	dbf	d4,.delay
	rts

get_dma	moveq	#0,d0
	move.b	5(a5),d0		get dma high
	swap	d0
	move.b	7(a5),d0		get dma mid
	lsl.w	#8,d0
	move.b	9(a5),d0		set dma low
	rts

seek_track
	bsr.s	wait
	move.w	#$86,2(a5)		select data register
	bsr.s	d02fdc
	moveq	#16,d0
	move.w	#$80,2(a5)	select command register
	bsr.s	d02fdc

	move.l	#$60000,d3	allow for motor start-up
.wait	subq.l	#1,d3
	beq	error
	btst	#5,$fffffa01	INTRQ ?
	bne.s	.wait		yes

wait2	move.w	#200,d0
.hold	bsr.s	wait
	dbf	d0,.hold
	bsr	get_status
	rts

select_drive_A
	move.w	sr,-(a7)	save status
	ori.w	#$700,sr	no interrupts
	move.b	#14,$ffff8800	select port A
	move.b	$ffff8800,d0	read port A
	andi.b	#248,d0		clear lower three bits
	or.b	d1,d0
	move.b	d0,$ffff8802	write port A
	move.w	(a7)+,sr	reset status
	rts

set_dma	move.l	ptr,d0
	move.b	d0,9(a5)		set dma low
	lsr.w	#8,d0
	move.b	d0,7(a5)		set dma mid
	swap	d0
	move.b	d0,5(a5)		set dma high
	rts
ptr	dc.l	0
;main os stuff !!
load_game	clr.w	$43e.w
	rts

DIGXYCORDS	DC.W	"K"-65,0,"I"-65,0,"L"-65,0,"L"-65,0,"D"-65,0,39,0
PRINTRANDDEL	DC.W	10
RND	DC.L	$f443,$7654

INPUTNAME1	DC.B	"D"+128,"A"+128,"V"+128,"E"+128,$8C,0
	DC.B	"A"+128,"N"+128,"D"+128,"Y"+128,$8C,0
	DC.B	"P"+128,"E"+128,"T"+128,"E"+128,"R"+128,0
	DC.B	"S"+128,"H"+128,"A"+128,"U"+128,"N"+128,0
	DC.B	"J"+128,"E"+128,"Z"+128,$8C,$8C,0
	DC.B	"D"+128,"O"+128,"U"+128,"G"+128,$8C,0

PLAYER1SCORE	DC.L	10000
PLAYER2SCORE	DC.L	8500
PLAYER3SCORE	DC.L	7000
PLAYER4SCORE	DC.L	5500
PLAYER5SCORE	DC.L	4000
PLAYER6SCORE	DC.L	3000

PLAYER1NAME	DC.W	"D"-65,"A"-65,"V"-65,"E"-65,39
PLAYER2NAME	DC.W	"A"-65,"N"-65,"D"-65,"Y"-65,39
PLAYER3NAME	DC.W	"M"-65,"I"-65,"C"-65,"H"-65,28
PLAYER4NAME	DC.W	"P"-65,"E"-65,"T"-65,"E"-65,"R"-65
PLAYER5NAME	DC.W	"S"-65,"H"-65,"A"-65,"U"-65,"N"-65
PLAYER6NAME	DC.W	"J"-65,"E"-65,"Z"-65,39,39

BESTTIMES	DC.W	1,5463,1,5547,1,4514,1,4758,1,5339
	DC.W	1,4294,2,1454,2,2083,1,4628,2,5750
	DC.W	2,2804,2,5984,1,2756,1,2233,1,4516

HISCOREVALUES	DC.L	100,100,100,100,100,150,100

*	LAST NUMBER IS PRINTED IN LEFT BOX

HISCORE1NAME	DC.W	"S"-65,"T"-65,"E"-65,"V"-65,"E"-65,30
HISCORE1OLDNAME DC.W	39,39,39,39,39,39
HISCORE1SCORE	DC.W	0,0,0,0,0,0

HISCORE2NAME	DC.W	"D"-65,"A"-65,"V"-65,"E"-65,39,31
HISCORE2OLDNAME DC.W	39,39,39,39,39,39
HISCORE2SCORE	DC.W	0,0,0,0,0,0

HISCORE3NAME	DC.W	"A"-65,"N"-65,"D"-65,"Y"-65,39,32
HISCORE3OLDNAME DC.W	39,39,39,39,39,39
HISCORE3SCORE	DC.W	0,0,0,0,0,0

HISCORE4NAME	DC.W	"M"-65,"I"-65,"C"-65,"H"-65,28,33
HISCORE4OLDNAME DC.W	39,39,39,39,39,39
HISCORE4SCORE	DC.W	0,0,0,0,0,0

HISCORE5NAME	DC.W	"J"-65,"E"-65,"Z"-65,39,39,34
HISCORE5OLDNAME DC.W	39,39,39,39,39,39
HISCORE5SCORE	DC.W	0,0,0,0,0,0

LEVELANAME	DC.W	"D"-65,"A"-65,"V"-65,"E"-65,39,"A"-65
LEVELAOLDNAME	DC.W	"M"-65,"I"-65,"C"-65,"H"-65,39,"A"-65
LEVELATIME	DC.W	0,1,2,4,5,4

LEVELBNAME	DC.W	"M"-65,"I"-65,"C"-65,"H"-65,28,"B"-65
LEVELBOLDNAME	DC.W	"S"-65,"T"-65,"E"-65,"V"-65,"E"-65,"B"-65
LEVELBTIME	DC.W	0,1,3,0,1,2

LEVELCNAME	DC.W	"S"-65,"T"-65,"E"-65,"V"-65,"E"-65,"C"-65
LEVELCOLDNAME	DC.W	"A"-65,"N"-65,"D"-65,"Y"-65,39,"C"-65
LEVELCTIME	DC.W	0,3,1,1,5,3

LEVELDNAME	DC.W	"A"-65,"N"-65,"D"-65,"Y"-65,39,"D"-65
LEVELDOLDNAME	DC.W	"J"-65,"E"-65,"Z"-65,39,39,"D"-65
LEVELDTIME	DC.W	0,3,5,6,2,4

LEVELENAME	DC.W	"J"-65,"E"-65,"Z"-65,39,39,"E"-65
LEVELEOLDNAME	DC.W	"P"-65,"E"-65,"T"-65,"E"-65,"R"-65,"E"-65
LEVELETIME	DC.W	0,2,5,1,2,6

LEVELFNAME	DC.W	"P"-65,"E"-65,"T"-65,"E"-65,"R"-65,"F"-65
LEVELFOLDNAME	DC.W	"D"-65,"O"-65,"U"-65,"G"-65,39,"F"-65
LEVELFTIME	DC.W	0,1,0,0,0,4

LEVELGNAME	DC.W	"D"-65,"O"-65,"U"-65,"G"-65,39,"G"-65
LEVELGOLDNAME	DC.W	"P"-65,"O"-65,"P"-65,"P"-65,"Y"-65,"G"-65
LEVELGTIME	DC.W	0,2,2,5,5,9

LEVELHNAME	DC.W	"P"-65,"O"-65,"P"-65,"P"-65,"Y"-65,"H"-65
LEVELHOLDNAME	DC.W	"N"-65,"E"-65,"I"-65,"L"-65,39,"H"-65
LEVELHTIME	DC.W	0,1,2,2,2,4

LEVELINAME	DC.W	"N"-65,"E"-65,"I"-65,"L"-65,39,"I"-65
LEVELIOLDNAME	DC.W	"J"-65,"U"-65,"L"-65,"I"-65,"A"-65,"I"-65
LEVELITIME	DC.W	0,3,6,9,5,9

LEVELJNAME	DC.W	"J"-65,"U"-65,"L"-65,"I"-65,"A"-65,"J"-65
LEVELJOLDNAME	DC.W	"L"-65,"U"-65,"G"-65,"A"-65,39,"J"-65
LEVELJTIME	DC.W	0,2,3,4,5,1

LEVELKNAME	DC.W	"L"-65,"U"-65,"G"-65,"A"-65,39,"K"-65
LEVELKOLDNAME	DC.W	"T"-65,"U"-65,"R"-65,"E"-65,"N"-65,"K"-65
LEVELKTIME	DC.W	0,1,2,2,2,3

LEVELLNAME	DC.W	"T"-65,"U"-65,"R"-65,"E"-65,"N"-65,"L"-65
LEVELLOLDNAME	DC.W	"J"-65,"A"-65,"N"-65,"E"-65,39,"L"-65
LEVELLTIME	DC.W	0,2,2,6,1,1

LEVELMNAME	DC.W	"J"-65,"A"-65,"N"-65,"E"-65,39,"M"-65
LEVELMOLDNAME	DC.W	"S"-65,"H"-65,"A"-65,"U"-65,"N"-65,"M"-65
LEVELMTIME	DC.W	0,8,7,6,5,4

LEVELNNAME	DC.W	"S"-65,"H"-65,"A"-65,"U"-65,"N"-65,"N"-65
LEVELNOLDNAME	DC.W	"V"-65,"I"-65,"N"-65,"N"-65,"Y"-65,"N"-65
LEVELNTIME	DC.W	0,3,2,3,5,1

LEVELONAME	DC.W	"V"-65,"I"-65,"N"-65,"N"-65,"Y"-65,"O"-65
LEVELOOLDNAME	DC.W	"E"-65,"R"-65,"N"-65,"I"-65,"E"-65,"O"-65
LEVELOTIME	DC.W	0,2,3,4,5,0

HICOUNT	DC.L	0

PLANCOLORS:
COLOURS	DC.W	$000,$337,$777,$222,$000,$660,$007,$444
	DC.W	$040,$030
COLOUR1	DC.W	$050,$311,$421,$440
COLOUR2	DC.W	$060
COLOUR3	DC.W	$532

HICOLORS	DC.W	$000,$774,$441,$446,$227,$663,$000,$000
	DS.W	8

TEXTCOLORS	DC.W	$000,$777,$333,$446,$227,$666,$000,$000
	DS.W	8

LOCOLORS	DC.W	$000,$555,$111,$446,$227,$444,$000,$000
	DS.W	8

PANELCOLORS	DC.W	$000,$222,$333,$444,$555,$666,$777,$023
	DC.W	$700,$400,$002,$003,$004,$446,$227,$000

PIC1PAL	DC.W	$000,$777,$000,$002,$003,$111,$004,$224
	DC.W	$005,$222,$006,$333,$444,$337,$555,$666

PIC2PAL	DC.W	$000,$777,$111,$020,$210,$222,$310,$320
	DC.W	$040,$321,$333,$431,$444,$555,$666,$777

PIC3PAL	DC.W	$000,$777,$020,$111,$030,$004,$222,$040
	DC.W	$333,$050,$116,$444,$037,$555,$760,$666

PIC4PAL	DC.W	$000,$765,$100,$210,$121,$320,$332,$340
	DC.W	$431,$333,$443,$543,$554,$555,$654,$655

PIC5PAL	DC.W	$000,$777,$002,$003,$111,$004,$224,$005
	DC.W	$222,$006,$333,$007,$444,$555,$666,$777

MENUPAL	DC.W	$000,$007,$006,$005,$004,$003,$002,$001
	DC.W	$170,$170,$777,$333,$447,$227,$555,$000

NAMEPALETTE	DC.W	$000,$007,$006,$005,$004,$003,$002,$001
	DC.W	$666,$555,$444,$333,$222,$111,$111,$777

SCOREPALETTE	DC.W	$000,$777,$422,$221,$222,$240,$350,$333
	DC.W	$431,$452,$641,$751,$047,$444,$754,$666

ALLWHITE	DC.W	$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF
	DC.W	$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF

MASKS	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE

PLANES12	DC.L	$FFFFFFFF
PLANES34	DC.L	$FFFF

KEYS1	DC.B	$80,1	RESET KEY READ STATE
KEYSET	DC.B	$12,$1A	MOUSE OFF,JOYSTICK OFF

TOPFILE	DC.B	"TOPBLCK"
NEWTOPS	DC.B	0,0
BACKFILE	DC.B	"MBCKGRND.CRN",0
SPRITEFILE	DC.B	"XBLOCKS",0
MASKFILE	DC.B	"MBMASKS",0
GRADFILE	DC.B	"MBGRADS.CRN",0
TVIEWFILE	DC.B	"MBTOP.CRN",0
ENDFILE	DC.B	"ENDSCRN.CMP",0
HISCOREFILE	DC.B	"HISCORES.SSS",0

CRASH1	DC.B	"  YOU LANDED BADLY",13," ON YOUR BACK WHEEL",0,7
CRASH2	DC.B	"  YOU LANDED BADLY",13,"O"+128,"N"+128," "+128,"Y"+128,"O"+128,"U"+128,"R"+128," "+128
	DC.B	"F"+128,"R"+128,"O"+128,"N"+128,"T"+128," "+128,"W"+128,"H"+128,"E"+128,"E"+128,"L"+128,0,7
CRASH3	DC.B	"    ","Y"+128,"O"+128,"U"+128," "+128,"S"+128,"T"+128,"A"+128,"L"+128,"L"+128,"E"+128,"D"+128
	DC.B	13,"      THE BIKE",0,5
CRASH4	DC.B	" ","Y"+128,"O"+128,"U"+128," "+128,"C"+128,"O"+128,"L"+128,"L"+128,"I"+128,"D"+128,"E"+128,"D"+128
	DC.B	" "+128,"W"+128,"I"+128,"T"+128,"H"+128,13,"   AN OBSTRUCTION",0,6
CRASH5	DC.B	"Y"+128,"O"+128,"U"+128," "+128,"B"+128,"R"+128,"A"+128,"K"+128,"E"+128,"D"+128
	DC.B	" "+128,"T"+128,"O"+128,"O"+128," "+128,"H"+128,"A"+128,"R"+128,"D"+128,13
	DC.B	"    AND SKIDDED!",0,6
CRASH6	DC.B	"   YOU CRASHED ON",13,"  YOUR FRONT WHEEL",0,7
CRASH7	DC.B	"   YOU CRASHED ON",13,"  ","Y"+128,"O"+128,"U"+128,"R"+128," "+128,"B"+128,"A"+128,"C"+128,"K"+128
	DC.B	" "+128,"W"+128,"H"+128,"E"+128,"E"+128,"L"+128,0,7
CRASH8	DC.B	" ","Y"+128,"O"+128,"U"+128," "+128,"W"+128,"E"+128,"N"+128,"T"+128," "+128,"T"+128,"O"+128,"O"+128
	DC.B	" "+128,"F"+128,"A"+128,"S"+128,"T"+128,13,"  AND LOST CONTROL",0,6
CRASH9	DC.B	"      YOU WENT",13,"     OFF COURSE",0,4
CRASH10	DC.B	"YOUR WHEEL GOT STUCK",13,"     IN A DITCH",0,6
CRASH11	DC.B	"  YOU LOST CONTROL",13,"    OF THE BIKE!",0,8
CRASH12	DC.B	"TRY NOT TO LOSE YOUR",13,"   HEAD NEXT TIME",0,4
CRASH13	DC.B	" OUCH! YOU GROUNDED",13,"      THE BIKE",0,8
LOSE	DC.B	"    TIME PENALTY",13," YOU LOSE ",0
LOSE1	DC.B	" SECONDS",0
FINISH	DC.B	"  CONGRATULATIONS!",13," COURSE ",0
COMPLETED	DC.B	" COMPLETED",0
BONUSES	DC.B	"  ","B"+128,"O"+128,"N"+128,"U"+128,"S"+128," "+128,"S"+128,"C"+128,"O"+128,"R"+128,"E"+128," "+128
	DC.B	"F"+128,"O"+128,"R"+128,13,"   TIME REMAINING",0
PAUSETEXT	DC.B	"    GAME PAUSED!",13,"  FIRE TO CONTINUE",0
GAMEOVER	DC.B	"YOU RAN OUT OF TIME!",13," GAME OVER PLAYER ",0
PRACTICETEXT	DC.B	13,"   PRACTICE LEVEL",13,"     ","S"+128,"E"+128,"L"+128,"E"+128,"C"+128,"T"+128,"I"+128,"O"+128,"N"+128
	DC.B	13,13,"USE THE JOYSTICK AND",13,"FIRE TO PICK A LEVEL",13
	DC.B	13,"      ","L"+128,"E"+128,"V"+128,"E"+128,"L"+128,0
PLAYERTEXT	DC.B	13,"  SELECTION OF THE",13," ","N"+128,"U"+128,"M"+128,"B"+128,"E"+128,"R"+128," "+128
	DC.B	"O"+128,"F"+128," "+128,"P"+128,"L"+128,"A"+128,"Y"+128,"E"+128,"R"+128,"S"+128,13
	DC.B	13,"USE THE JOYSTICK AND",13,"F"+128,"I"+128,"R"+128,"E"+128," "+128,"O"+128,"R"+128
	DC.B	" "+128,"K"+128,"E"+128,"Y"+128,"S"+128," "+128,129," "+128,"T"+128,"O"+128," "+128,134
	DC.B	13,"AND RETURN TO CHOOSE",13,13," ","N"+128,"U"+128,"M"+128,"B"+128,"E"+128,"R"+128," "+128
	DC.B	"O"+128,"F"+128," "+128,"P"+128,"L"+128,"A"+128,"Y"+128,"E"+128,"R"+128,"S"+128,0
NAMETEXT	DC.B	13,"     NAME ENTRY",13,13,"      PLAYER "
PLAYERNUMBER	DC.B	1,13,13,"USE THE JOYSTICK AND",13," FIRE TO ENTER YOUR"
	DC.B	13,"        NAME",13,13,"       "
INPUTNAME	DC.B	"DAVE",12,0
SELECTTEXT	DC.B	13,"     ","S"+128,"E"+128,"C"+128,"T"+128,"I"+128,"O"+128,"N"+128," "+128
SELECTSECTION	DC.B	129,13,"      PLAYER "
SELECTPLAYER	DC.B	1,13,"       "
SELECTNAME	DC.B	"DAVE ",13,13,"  ","S"+128,"E"+128,"L"+128,"E"+128,"C"+128,"T"+128," "+128,"A"+128," "+128
	DC.B	"C"+128,"O"+128,"U"+128,"R"+128,"S"+128,"E"+128,13,13
	DC.B	"  COURSE "
SELECTCOURSE1	DC.B	"A   ",10
SELECTTIME1	DC.B	10,"."
SELECTTIME2	DC.B	10
SELECTTIME3	DC.B	10,13
	DC.B	"  COURSE "
SELECTCOURSE2	DC.B	"B   ",10
SELECTTIME4	DC.B	10,"."
SELECTTIME5	DC.B	10
SELECTTIME6	DC.B	10,13
	DC.B	"  COURSE "
SELECTCOURSE3	DC.B	"C   ",10
SELECTTIME7	DC.B	10,"."
SELECTTIME8	DC.B	10
SELECTTIME9	DC.B	10,0
SAVETEXT	DC.B	13,"  PUT THE DISK YOU",13,"  WANT TO SAVE THE"
	DC.B	13,"  HIGHSCORES ON IN",13,"  DRIVE A AND THEN"
	DC.B	13,"PRESS Y TO SAVE THEM",13,13,"  PRESS N TO ABORT"
	DC.B	13," NB. DO NOT USE THE",13,"    GAME DISKS !",0
ERRTEXT	DC.B	13,"  A DISK ERROR HAS",13,"     OCCURRED !",13,13
	DC.B	13,"     Y TO RETRY",13,"     N TO ABORT",0
LOADTEXT	DC.B	13," PUT YOUR HIGHSCORE",13,"SAVE DISK IN DRIVE A",13
	DC.B	13,"PRESS Y TO LOAD THEM",13,"         OR",13,"     N TO ABORT",0

LEVELTIMES	DC.B	2,10,10,2,10,10,1,5,10
	DC.B	1,5,5,2,10,10,1,5,10
	DC.B	2,2,10,2,2,5,1,5,10
	DC.B	3,10,10,2,3,10,3,10,5
	DC.B	1,3,10,1,2,5,1,5,10

SOUNDOFF	DC.B	8,0,9,0,10,0,11,0,12,0,13,0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,$3F
BEEPON	DC.B	$D,8,$C,$10,1,1,8,$10,7,$3E
BEEP	DC.B	8,$F,7,$3E
BEEPOFF	DC.B	8,0,$D,10,$C,0,$B,90,10,$10,7,$3B
ENGINE	DC.B	$D,10,$C,0,$B,90,10,$10,7,$3B

	EVEN

TIMES	DC.W	2,0,2,0,1,5000,1,5500,2,0,1,5000
	DC.W	2,2000,2,2500,1,5000,3,0,2,3000,3,500
	DC.W	1,3000,1,2500,1,5000

CRASHES	DC.L	CRASH1,CRASH2,CRASH3,CRASH4,CRASH5,CRASH6,CRASH7
	DC.L	CRASH8,CRASH9,CRASH10,CRASH11,CRASH12,CRASH13

MYSOUNDS	DC.L	SOUNDOFF,BEEPON,BEEP,BEEPOFF,ENGINE

ANGLETABLE	DC.L	ANGLESA,ANGLESB,ANGLESC,ANGLESD,ANGLESE
	DC.L	ANGLESF,ANGLESG,ANGLESH,ANGLESI,ANGLESJ
	DC.L	ANGLESK,ANGLESL,ANGLESM,ANGLESN,ANGLESO

COURSETABLE	DC.L	COURSEA,COURSEB,COURSEC,COURSED,COURSEE
	DC.L	COURSEF,COURSEG,COURSEH,COURSEI,COURSEJ
	DC.L	COURSEK,COURSEL,COURSEM,COURSEN,COURSEO

PLANTABLE	DC.L	PLANA,PLANB,PLANC,PLAND,PLANE
	DC.L	PLANF,PLANG,PLANH,PLANI,PLANJ
	DC.L	PLANK,PLANL,PLANM,PLANN,PLANO

	DC.B	45,2,20,28
	DC.B	45,2,17,23,46,1,17,20
	DC.B	48,1,14,17,48,0,14,13
	DC.B	49,0,14,10,49,0,15,6
	DC.B	50,0,15,4,51,0,15,2
BIKEDIFFS	DC.B	51,0,15,0,51,2,15,0
	DC.B	52,5,16,0,52,7,17,0
	DC.B	53,9,18,0,52,14,18,0
	DC.B	52,15,19,1,50,19,20,1
	DC.B	48,24,21,2,46,26,21,2
	DC.B	51,0,15,0,51,0,15,0

	DC.B	59,4,32,28
	DC.B	59,4,29,22,59,4,30,24
	DC.B	59,4,26,19,59,4,25,16
	DC.B	59,4,24,14,59,4,24,10
	DC.B	59,4,24,8,59,4,23,6
CRASHDIFFS	DC.B	59,4,23,4,59,6,23,4
	DC.B	59,9,23,4,58,11,23,4
	DC.B	58,13,23,4,56,17,23,4
	DC.B	56,18,23,4,53,22,23,4
	DC.B	50,26,23,4,48,28,23,4
	DC.B	59,4,23,4,59,4,23,4

	DC.B	39,23,36,20,36,19
	DC.B	36,17,35,15,34,14,33,12
	DC.B	34,11,34,10
CENTREDIFFS	DC.B	33,9,33,10,33,11,33,12
	DC.B	33,13,34,16,34,17,31,19
	DC.B	29,21,27,21,33,9,33,9

SINCOS	DC.W	0,$100,9,$100,$12,$100,$1A,$FF,$33,$FC
	DC.W	$4A,$F6,$60,$EE,$84,$DC
	DC.W	$A0,$C8,$B6,$B6

	DC.L	-$5A82,-$4FF6,-$41DB
	DC.L	-$2F8A,-$24C8,-$191A,-$CBD,-$884,-$444
GRAVALS	DC.L	0,$444,$884,$CBD,$191A,$24C8,$2F8A
	DC.L	$41DB,$4FF6,$5A82

DIALVALS	DC.W	0,128,128,256,384,384,512,640
	DC.W	640,768,896,896,1024,1152,1152,1280

	DC.W	240,240,240,180,180,180,180,120,120
TOPOFFS	DC.W	120,120,120,60,60,60,60,0,0,0,120,120

BIKEBASE	INCBIN	BIKES
BIKES	EQU	BIKEBASE+24192
TOPBIKE	INCBIN	TOPBIKE
DIALS	INCBIN	DIALS
DIGITS	INCBIN	DIGITS
SCREENA	INCBIN	SCREEN1.CMP
SCREENB	INCBIN	SCREEN2.CMP
SCREENC	INCBIN	SCREEN3.CMP
STSCORE	INCBIN	STSCORE.CMP
SCR2MEM	INCBIN	NUMBERS
PANELSCRN	INCBIN	DIALBIKE.CMP
SWAPSCRN	INCBIN	SWAPDISK.CMP
MENU	INCBIN	MENU.CMP
CRASHTEXT	INCBIN	CRASHTXT
TUNE1	INCBIN	BIKE1.MUS
TUNE2	INCBIN	BIKE2.MUS
MSPEEDS	INCBIN	MSPEEDS
MTRCTN	INCBIN	MTRCTN
GSPEEDS	INCBIN	GSPEEDS
GTRCTN	INCBIN	GTRCTN
CSPEEDS	INCBIN	CSPEEDS
CTRCTN	INCBIN	CTRCTN
MBHGHTS	INCBIN	MBHGHTS
GBHGHTS	INCBIN	GBHGHTS
CBHGHTS	INCBIN	CBHGHTS
ENDHGHTS:
MUDINTRNL	INCBIN	MHINTRNL.CRN
GRSINTRNL	INCBIN	GHINTRNL.CRN
CONINTRNL	INCBIN	CHINTRNL.CRN
ANGLESA	INCBIN	ANGLFLEA.CRN
ANGLESB	INCBIN	ANGLFLEB.CRN
ANGLESC	INCBIN	ANGLFLEC.CRN
ANGLESD	INCBIN	ANGLFLED.CRN
ANGLESE	INCBIN	ANGLFLEE.CRN
ANGLESF	INCBIN	ANGLFLEF.CRN
ANGLESG	INCBIN	ANGLFLEG.CRN
ANGLESH	INCBIN	ANGLFLEH.CRN
ANGLESI	INCBIN	ANGLFLEI.CRN
ANGLESJ	INCBIN	ANGLFLEJ.CRN
ANGLESK	INCBIN	ANGLFLEK.CRN
ANGLESL	INCBIN	ANGLFLEL.CRN
ANGLESM	INCBIN	ANGLFLEM.CRN
ANGLESN	INCBIN	ANGLFLEN.CRN
ANGLESO	INCBIN	ANGLFLEO.CRN
COURSEA	INCBIN	COURSEA.CRN
COURSEB	INCBIN	COURSEB.CRN
COURSEC	INCBIN	COURSEC.CRN
COURSED	INCBIN	COURSED.CRN
COURSEE	INCBIN	COURSEE.CRN
COURSEF	INCBIN	COURSEF.CRN
COURSEG	INCBIN	COURSEG.CRN
COURSEH	INCBIN	COURSEH.CRN
COURSEI	INCBIN	COURSEI.CRN
COURSEJ	INCBIN	COURSEJ.CRN
COURSEK	INCBIN	COURSEK.CRN
COURSEL	INCBIN	COURSEL.CRN
COURSEM	INCBIN	COURSEM.CRN
COURSEN	INCBIN	COURSEN.CRN
COURSEO	INCBIN	COURSEO.CRN
PLANA	INCBIN	PLANA.CRN
PLANB	INCBIN	PLANB.CRN
PLANC	INCBIN	PLANC.CRN
PLAND	INCBIN	PLAND.CRN
PLANE	INCBIN	PLANE.CRN
PLANF	INCBIN	PLANF.CRN
PLANG	INCBIN	PLANG.CRN
PLANH	INCBIN	PLANH.CRN
PLANI	INCBIN	PLANI.CRN
PLANJ	INCBIN	PLANJ.CRN
PLANK	INCBIN	PLANK.CRN
PLANL	INCBIN	PLANL.CRN
PLANM	INCBIN	PLANM.CRN
PLANN	INCBIN	PLANN.CRN
PLANO	INCBIN	PLANO.CRN

DATABSS	SECTION	BSS

OLDPAL	DS.W	16

NUMBEROFPLAYERS	DS.W	1
PLAYERSOUT	DS.B	6
CURRENTLEVEL	DS.L	1
PLAYERSNAMES	DS.L	7
DIGFINFLAGS	DS.W	6
AFLAG1	DS.W	1
HSPRINTPOS	DS.L	1
DOTTYPE	DS.L	1
NOCOLORS	DS.W	16
MAINPAL	DS.W	16
PLANPAL	DS.W	16
PANELPAL	DS.W	16
ENDPAL	DS.W	16
MAINSTORE	DS.W	48
PLANSTORE	DS.W	48
PANELSTORE	DS.W	48
MAINVALS	DS.W	48
PLANVALS	DS.W	48
PANELVALS	DS.W	48

SPEEDS	DS.L	1
TRACTION	DS.L	1
BLCKHGHTS	DS.L	1	POINTER TO TABLE
BLOCKADDS	DS.L	1	POINTER TO TABLE
MASKADDS	DS.L	1	POINTER TO TABLE
BLOCK0	DS.L	1	POINTER TO COURSE DATA
FLIP	DS.W	1
LINECOUNT	DS.W	1
SOUNDCOUNT	DS.W	1

LEVELCOUNT	DS.W	1
DONETIMES	DS.L	90

	DS.B	256	EXTRA 256 FOR BOUNDARY
DISPLAY	DS.B	32000
BACKGROUND	DS.B	30720
PLANVIEW	DS.B	1040*32
PLANMAP	DS.B	1048
TOPBLOCKS	DS.L	251
RANGLES	DS.B	7682
HEIGHTS	DS.B	1312
GRADIENTS	DS.B	1312

BLOCKS	EQU	*

	END



