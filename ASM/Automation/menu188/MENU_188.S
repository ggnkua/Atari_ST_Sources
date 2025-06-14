	MOVE.L 4(A7),A5
	MOVE.L #$100,-(SP)
	MOVE.L A5,-(SP)
	MOVE.L #$4A0000,-(SP)
	TRAP #1
	ADD.W #12,SP

	MOVE.W #2,-(SP)
	TRAP #14
	ADD.W #2,SP
	MOVE.L D0,OLD

	pea black
	move.w #$26,-(sp)
	trap #14
	add.w #6,sp


	CLR.W -(SP)
	PEA $40000
	PEA $40000
	MOVE.W #5,-(SP)
	TRAP #14
	ADD.W #12,SP

	PEA DRAWPIC
	MOVE.W #$26,-(SP)
	TRAP #14
	ADD.W #6,SP

	MOVE.L SP,SAVESTK
	
	MOVE.L #$2000,SP

	LEA $78000,A0
	MOVE.L #32000/4,D0
CLV	CLR.L (A0)+
	DBRA D0,CLV

	MOVE.L #RAS1,BG

	move.l #text,tpnt
	move.l #charset+34,stchar

*	BSR SAMP

	CLR.L -(SP)
	MOVE.W #$20,-(SP)
	TRAP #1
	ADD.W #6,SP
	MOVE.L D0,STACK

	MOVE.B $484,KB
	move.w #1,$4a6

	MOVE.B #$12,$FFFC02

	BSR SETUP

	LEA $40000+32000,A0
	MOVE.W #24000/4,D0
CLEAR	CLR.L (A0)+
	DBRA D0,CLEAR

	MOVE.B #$1A,$FFFC02


	LEA PIC+2,A0
	LEA $FF8240,A1
	MOVE.W #15,D0
COLS	MOVE.W (A0)+,(A1)+
	DBRA D0,COLS

	LEA $40000,A0
	LEA PIC+34,A1
	MOVE.L #32000/4,D0
PICY	MOVE.L (A1)+,(A0)+
	DBRA D0,PICY

	MOVE.L $118,S118
	MOVE.L #NEWKEY,$118

	MOVE.L #$78000,new_scrn
	MOVE.L #$48000-480+32+(160*9),INBORDER

	PEA HBL
	MOVE.W #1,-(SP)
	MOVE.W #%1000,-(SP)
	MOVE.W #1,-(SP)
	MOVE.W #31,-(SP)
	TRAP #14
	ADD.W #12,SP


	MOVE.L $70,STORE
	MOVE.L #INTA,$70

	MOVE.W #5,-(SP)
	MOVE.W #26,-(SP)
	TRAP #14
	ADD.W #4,SP

WAIT	MOVE.W TIMER,D0
HANGIT	CMP.W TIMER,D0
	BEQ HANGIT
	ADDQ.W #1,CANI
	BSR SCROLL
	LEA MUSIX,A0
	JSR 8(A0)
	MOVE.B KEY,D0
	CMP.B #$B,D0
	BEQ FLIPFREQ
TEST1	CMP.B #02,KEY
	BNE TEST2
	MOVE.L #'TERM',D4
	BRA EXITA
TEST2	CMP.B #03,KEY
	BNE TEST3
	MOVE.L #HARD,D4
	BRA EXITA
TEST3	CMP.B #04,KEY
	BNE TEST4
	MOVE.L #'TERM',D4
	BRA EXITA
TEST4	CMP.B #05,KEY
	BNE TEST5
	MOVE.L #'TERM',D4
	MOVE.W #$666,HERE	;	ZAP 60Hz
	BRA EXITA
TEST5	CMP.B #06,KEY
	BNE TESTA
	MOVE.L #'TERM',D4
	BRA EXITA
TESTA	CMP.B #$4A,KEY
	BNE TESTB
	BRA MINUS
TESTB	CMP.B #$4E,KEY
	BNE WAIT
	BRA PLUS
	

MINUS	CMP.W #1,spd
	BEQ WAIT
	CMP.W #12,TIMER
	BLT WAIT
	SUBQ.W #1,spd
	BSR DELAY
	BRA WAIT
PLUS	CMP.W #8,spd
	BEQ WAIT
	CMP.W #12,TIMER
	BLT WAIT
	ADDQ.W #1,spd
	BSR DELAY
	BRA WAIT

EXITA	MOVE.W #8,-(SP)
	MOVE.W #26,-(SP)
	TRAP #14
	ADD.W #4,SP


	MOVE.L S118,$118

	MOVE.L STORE,$70

	LEA $78000,A0
	MOVE.W #32000/4,D0
CLRG	CLR.L (A0)+
	DBRA D0,CLRG

	CLR.W -(SP)
	MOVE.L OLD,-(SP)
	MOVE.L OLD,-(SP)
	MOVE.W #5,-(SP)
	TRAP #14
	ADD.W #12,SP


	MOVE.W #$0,$FF8240
	MOVE.W #$777,$FF825E

	MOVE.W #5,-(SP)
	MOVE.W #27,-(SP)
	TRAP #14
	ADD.W #4,SP

	bsr NOFX

	MOVE.B #$80,$FFFC02
	MOVE.W #$FFFF,D0
UYT	NOP
	DBRA D0,UYT
	MOVE.B #$1,$FFFC02

	BSR SETFREQ

	MOVE.B KB,$484

	MOVE.L STACK,-(SP)
	MOVE.W #$20,-(SP)
	TRAP #1
	ADD.W #6,SP

	CMP.L #'TERM',D4
	BNE LOADIT

	MOVE.L SAVESTK,SP
	MOVE.W #$4C,-(SP)
	TRAP #1

LOADIT	MOVE.L SAVESTK,SP

	MOVE.W #0,-(SP)
	PEA -1
	PEA -1
	MOVE.W #5,-(SP)
	TRAP #14
	ADD.W #12,SP

	CLR.L -(SP)
	MOVE.L #CT,-(SP)
	MOVE.L D4,-(SP)
	CLR.W -(SP)
	MOVE.W #$4B,-(SP)
	TRAP #1

	MOVE.W #$4C,-(SP)
	TRAP #1

CT	DC.L 0

	EVEN

DELAY	CLR.W TIMER
	RTS

HARD	DC.B "DRIVIN.DAK",00
	EVEN


INTA	MOVE.L D0,-(SP)

	LEA PIC+2,A0
	LEA $FF8240,A1
	MOVEQ.W #15,D0
KJH	MOVE.W (A0)+,(A1)+
	DBRA D0,KJH
	
	MOVE.L #RAS1,BG

	LEA $48000-(160*5),A0
	MOVE.W #160/4,D0
ERASE	CLR (A0)+
	DBRA D0,ERASE

	CLR.W LINE

*	LEA ROTATE-2,A0
*	MOVE.W (A0),SHIFTER
*	MOVE.W #39,D0
*UPQ	MOVE.W 2(A0),(A0)+
*	DBRA D0,UPQ
*	MOVE.W SHIFTER,(A0)


	ADD.W #1,TIMER

	MOVE.L (SP)+,D0
	RTE
SHIFTER	DC.W 0


NEWKEY	MOVE.B $FFFC02,KEY
	bclr.b #6,$fffffa11
	RTE
KEY	DC.W 0
S118	DC.L 0


NOFX	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	RTS

spd	dc.w 1



HBL	MOVE.L A0,SA0
	MOVE.L BG,A0
	MOVE.W 482(A0),$FF8240
	MOVE.W (A0),$FF8250
	ADDQ.L #2,BG
	ADD.W #1,LINE
	CMP.W #199,LINE
	BNE OUTHBL

	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	CLR.B $FFFF820A
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP
 	NOP

	MOVE.B #2,$FFFF820A
	
	move.l d0,-(sP)
	moveq.w #14,d0
	lea $ff8242,a0
lkj	move.w #$777,(a0)+
	dbra d0,lkj
	move.l (sp)+,d0


OUTHBL	BCLR.B #0,$FFFA0F
	MOVE.L SA0,A0
	RTE
SA0	DC.L 0
BG	DC.L 0



SCROLL	movem.l d0-d7/a0-a6,-(sP)

way1
	move.w spd,d4
secondb
	move.w SCRL,d0
	addq.w #1,d0
	move.w d0,SCRL
	cmp.w #16,d0
	bne GO_SCROLL
	moveq.w #0,d0
	move.w d0,SCRL

***
*** LOAD GRAPHIC FOR NEXT CHAR 
*** INTO BUFFER
***

	clr.l d1
	move.l tpnt,a0
	add.l #1,tpnt
BACK
	move.b (a0),d1
	cmp.b #$ff,d1
	bne next_char
	move.l #text,tpnt
	move.b #32,d1
	
next_char

	sub.b #$20,d1

***
*** calculate which line to copy
***
_p
	cmp.b #$50,d1
	blt _bsrk
	asl d1
	asl d1
	asl d1
	add.l #5600,d1
	bra out
_bsrk
	cmp.b #$3c,d1
	blt _H
	asl d1
	asl d1
	asl d1
	add.l #4160,d1
	bra out
_H
	cmp.b #$28,d1
	blt _4
	asl d1
	asl d1
	asl d1

	add.l #2880,d1
	bra out
_4
	cmp.b #$14,d1
	blt _spc
	asl d1
	asl d1
	asl d1

	add.l #1280,d1
	bra out

_spc
	asl d1
	asl d1
	asl d1

	
out
	move.l stchar,a5
	add.l d1,a5

	lea CHBUFF,a4
	move.l #8,d7
lip
	move.w (a5),(a4)+
	add.l #160,a5
	dbra d7,lip
	
GO_SCROLL lea CHBUFF,a0
	  move.l new_scrn,a1
	  
	  move.l #9,d2


 
EACHUN	add.l #160,a1
	move.l a1,a2
	
	asl.w (a0)+

	roxl.w -2(a2)
	roxl.w -10(a2)
	roxl.w -18(a2)
	roxl.w -26(a2)
	roxl.w -34(a2)
	roxl.w -42(a2)
	roxl.w -50(a2)
	roxl.w -58(a2)
	roxl.w -66(a2)
	roxl.w -74(a2)
	roxl.w -82(a2)
	roxl.w -90(a2)
	roxl.w -98(a2)
	roxl.w -106(a2)
	roxl.w -114(a2)
	roxl.w -122(a2)
	roxl.w -130(a2)
	roxl.w -138(a2)
	roxl.w -146(a2)
	roxl.w -154(a2)

	dbra d2,EACHUN
	dbra d4,secondb

	LEA $78000,A0
	MOVE.L INBORDER,A1
	MOVE.L A1,A2
	ADD.L #160,A2
	MOVEQ.W #12,D0
TWICE	MOVE.W #(156/4),D2
HIGHT	MOVE.L (A0),(A1)+
	MOVE.L (A0)+,(A2)+
	DBRA D2,HIGHT
	ADD.L #160,A1
	ADD.L #160,A2
	DBRA D0,TWICE

	addq.w #1,count
OUTG	movem.l (sp)+,d0-d7/a0-a6
	RTS

SCRL	dc.w 15
tpnt	dc.l 0
CHBUFF	ds.w 15
new_scrn	DC.L $78000
PTR	dc.l $40000+(180*160)
count	dc.w 0
stchar	dc.l 0
GOTO 	DC.L 0
TIMER	DC.W 0
LINE	DC.W 0
STORE	DC.L 0
STACK	DC.L 0
text	
	DC.B "WELCOME TO vwxyz{ MENU 188...... (OR 187 CONT.)     "
	DC.B "KEYS: PLUS AND MINUS ON KEYPAD FOR SPEED     "
	DC.B "ZERO (TOP ROW) FOR 50/60 HERTZ      "
	DC.B "                            "
	DC.B "COCA-COLA KILLS GUT CELLS.....     "
	DC.B "HARD DRIVIN IS 512K AND WILL RUN EXTRA DATA DISKS "
	DC.B "WITHOUT US HAVING TO PROCESS THEM FIRST...    "
	DC.B "THIS IS SHORT 'COS WE ARE FED UP......       "
	DC.B "WHY IS IT THAT WHEN WE PACK GAMES THEY NEVER "
	DC.B "SEEM TO FIT ONTO DISKS WITH LESS THAN 10K FREE....  "
	DC.B "OR THEY TAKE UP 830K AND WON'T FIT AT ALL!!!     "
	DC.B "WE HAVE THE FOLLOWING READY, BUT CAN'T "
	DC.B "BLOODY FIT THEM ON A DISK... (YET!! - MAYBE TOMORROW - "
	DC.B "OH, YES, IT IS TOMORROW!!!)     "
	DC.B "RED-STORM RISING (ONE MEG), CONFLICT IN EUROPE (ONE MEG) "
	DC.B "AND POWERPLAY (512K).....    "
	DC.B "GREETING TO:-        "
	DC.B "THE REPLICANTS, THE UNION, THE BLADERUNNERS, "
	DC.B "THE MEDWAY BOYS, THE POMPEY PIRATES (JUST), THE GUARDIANS OF LOGIK, "	
	DC.B "SEWER SOFTWARE, EMPIRE, BIRDY.......      "
	DC.B "COL,BRI,MAL,NEIL,DEAN,MERLIN,I.R.S.,SIMON,XERID,"
	DC.B "MORAY,MAL,KKK,AND NOT DEREK FROM MAL......PHILL WENT HOME EIGHT AND A HALF HOURS AGO.....    "
	DC.B "JUST A QUICK WORD HERE FROM DACK...."
	DC.B ".......SPEEDY...THERE THATS PRETTY QUICK....ANYWAY ITS SEEMS THAT A PERSON MENTIONED SEVERAL"
	DC.B " MENUS AGO IS SELLING OUR (AND OTHER CREWS) MENUS......HMM..I CANT GUESS WHO THAT COULD BE "
	DC.B "(I BET YOU KNOW WHO I MEAN THOUGH CHILDEN.... DONT YOU)....ANYWAY THE APOLOGY ON 169 IS NOW "
	DC.B "RECINDED......THE END.....AND THEY ALL WENT BACK TO THE BIG PUMPKIN HOUSE AND LIVED HAPPILY(ISH) "
	DC.B "EVER AFTER.......P.S. SLAMING A PHONE DOWN COULD DAMAGE YOUR MODEM OR YOUR REPUTATION.....P.P.S "
	DC.B "THIS SCROLL WAS WRITTEN AFTER 12 PINTS OF COKE AND A BEEF CURRY PLEASE EXCUSE THE SPOOLING...SORRY SPELLIN"
	DC.B "(AS IN HARD DRIVIN).....THE REAL END.............RED RUM BACKWARDS SPELLS MURDER DONTCHA KNOW....LETS WRAP........"
	DC.B "HONEST....."



	DC.B "       P.S.   I AM NOT TELLING YOU WHAT SYNCHROGUSH IS!!  (YET - MAYBE NEXT TIME)....   "
	DC.B "DACK AND THE LAW....29TH OF DECEMBER....1:57 AM....WHAT? IS THAT THE TIME? DAMN! TIME TO GO HOME"
	DC.B "(SUNG TO A VERY WELL KNOWN TUNE)......WE'RE GONE........"

	DC.B $FF
	even

**  1  -  50
** -1  -  60

FFLAG	DC.W 1
FLIPFREQ	
	CMP.W #15,CANI
	BLS WAIT
	TST.W FFLAG
	BPL S5060
S6050	NEG.W FFLAG
	MOVE.W #$777,D0
	BRA COLQ

S5060	NEG.W FFLAG
	MOVE.W #$666,D0
	
COLQ	LEA HERE,A0
	MOVE.W #40,D5
FPL	MOVE.W D0,(A0)+
	DBRA D5,FPL
	CLR.W CANI
	BRA WAIT
CANI	DC.W 20

SETFREQ	CMP.W #$666,HERE
	BNE ITS50
	MOVE.B #%11111100,$FF820A
	BRA RTY
ITS50	MOVE.B #%11111110,$FF820A
RTY	RTS

black	move.w #15,d0
	lea $ff8240,a0
ffff	clr.w (a0)+
	dbra d0,ffff
	rts
KB	DC.W 0
RAS1	
	DS.W 200

HERE	REPT 40
	DC.W $777
	ENDR

	DS.W 195
	DC.W $0
ROTATE
	dc.w 0,1,1,2,2,3,3,4,4,5,5,6,6
	rept 20
	dc.w $7
	endr
	dc.w 6,6,5,5,4,4,3,3,2,2,1,1,0
	ds.w 50

SETUP
	MOVEQ.W #6,D0
	JSR MUSIX
	RTS

	JSR $50D80

*SAMP	LEA SAMPLAY,A0
*	ADD.L #28,A0
*
*	MOVE.L #SAMPLE+12,2(A0)
*	MOVE.L #END,A3
*	MOVE.L #SAMPLE+12,A2
*	SUB.L A2,A3
*	MOVE.L A3,6(A0)
*	MOVE.L #4,10(A0)
*
*	JSR (A0)
*	
*	RTS

DRAWPIC	LEA PIC+34,A0
	LEA $50000,A1
	MOVE.L #32000/4,D0
TYU	MOVE.L (A0)+,(A1)+
	DBRA D0,TYU

	LEA PIC+2,A0
	LEA $FF8240,A1
	MOVE.W #15,D0
UYT2	MOVE.W (A0)+,(A1)+
	DBRA D0,UYT2

	RTS

*SAMPLAY
*	INCBIN "BASCODE.EXE"
*	EVEN
*SAMPLE	
*	INCBIN "batman.SAM"
*END	EVEN

PIC
	INCBIN "\MENU.188\CD188.PI1"
	EVEN
charset	
	INCBIN "\MENU.188\CHARSETX.PI1"
	EVEN
MUSIX	
	INCBIN "\MENU.188\BARB2.MAX"
	EVEN
SAVESTK	DC.L 0
INBORDER	DC.L 0
OLD	DC.L 0




