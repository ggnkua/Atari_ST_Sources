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
	MOVE.L #$48000-480+32+(160*7),INBORDER

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
	MOVE.L #'TERM',D4
	BRA EXITA
TEST3	CMP.B #04,KEY
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

	LEA ROTATE-2,A0
	MOVE.W (A0),SHIFTER
	MOVE.W #39,D0
UPQ	MOVE.W 2(A0),(A0)+
	DBRA D0,UPQ
	MOVE.W SHIFTER,(A0)


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
	DC.B "WELCOME TO vwxyz{ MENU 187......     "
	DC.B "KEYS: PLUS AND MINUS ON KEYPAD FOR SPEED     "
	DC.B "ZERO (TOP ROW) FOR 50/60 HERTZ      "

	DC.B "HERE ARE TWO MORE OLDIES FOR YOUR BLANK BOX.....    "
	DC.B "UNLESS YOU ARE INTO MORE THAN ARCADE GAMES THAT IS....   "
	
	DC.B "THIS IS THE FIRST DISK TO BE REALEASED AT THE "
	DC.B "FIRST (AND PROBABLY LAST!) UN-NAMEABLES-BRING-A-"
	DC.B "BOTTLE-OF-COKE-COPY-PARTY....   PHILL WHERE'S YOUR BOTTLE???     "
	
	DC.B "(PAUSE WHILE PHILL COMES TO KEYBOARD....   PLOD....   THUMP....  ) "

	DC.B "HEY! WOW! MY FIRST SCROLLY THINGY! OH DEAR I'VE ALREADY RUN OUT OF THINGS TO SAY, OH,  "
      	DC.B "THE ART IS FROM AN ORIGINAL BY JAMIE HEWLETT IN DEADLINE, BYE BYE. "

	DC.B ".....HI COL....      "

	DC.B "(YES THE GREETS WILL APPEAR EVERY SO OFTEN JUST TO KEEP YOU ON YOUR TOES).."
	DC.B "...        "
	
	DC.B "HI MORAY......SEE WHAT I MEAN...(PRIORITY 7 INTERRUPT - DEAR CHRISPY NOODLE"
	DC.B " PHILL SAYS THE ART IS ON ITS WAY - THE LAW SAYS: WHEN ARE YOU GOING TO PHONE?...BCLR.B #0,SCROLLTEXT...RTI)       "
	DC.B ".....HI REPLICANTS.....    "
	DC.B "HEY, DEAN, GUESS WHO HAS GOT CHAOS??? (COMING SOON GUYS....)       "
	DC.B "PLEASE NOTE WE COULD HAVE GOT GUNSHIP SMALLER BUT THEN IT WOULD HAVE NEEDED 1MEG...THE SAME FOR KILLDOZERS "
	DC.B "(EVEN IF IT IS MORE DOZE THAN KILL)....WHOOPS SORRY...BUT THE COKE IS STARTING TO TAKE ITS LEGENDARY EFFECT.."
	DC.B "THE LAW HAS JUST BROKEN THE RECORD FOR PLAYING SYNCHROGUSH....(SEE NEXT MENU FOR DETAILS)..WHILE IM "
	DC.B "HOPING MY UNDERWEAR IS GOING TO REMAIN INTACT - FART! (GOD, STOP IT) -........ HI UNION........"
	DC.B "   TO BE CONTINUED ON AUTOMATION 188......       OH YES... HI ERAWTFOS REWES...(IN JOKE)..GOSH ITS COLD HERE AT"
	DC.B " TUN H.Q...TIME TO THROW ANOTHER KYLIE MINOGUE ON THE FIRE...  WE SHOULD BE SO LUCKY....    IF WE DUST HER "
	DC.B "THIGHS FIRST WOULD WE FIND JASON DONOVANS FINGERPRINTS???.......  COME ON PHILL, HURRY UP WITH THIS PIC!!!"
	DC.B "....(SOUND OF WHIP CRACKING BUT I CANT SPELL KITTTZZCH AND WE DON'T HAVE A BBC SOUND FX TAPE...)..ANYHOW.."
	DC.B "HI BOB, STEVE,PETE,KKK,MAL,MERLIN,TUCKER,IRS,SIMON (SIMPLE? - THAT WAS DACK, NOT THE LAW),THE ORIGINAL SNOT GOBBLER"
	DC.B ",BIRDY,SCC,...OH ALRIGHT AND THE MEDWAY BOYS, BUT I DRAW THE LINE WITH THE POMPEY PIRATES..........   TIME TO WRAP AFTER ALL THIS"
	DC.B " (INSERT YOUR OWN WORD WHICH RHYMES WITH WRAP)......BYE..BYE..SEE YOU ALL LATER....   THE LAW (CODING + DRIVEL)..... DACK (MINDLESS DRIVEL).... AND PHILL (GRAFIX AND FONT).....    "

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

	DS.W 201
	DC.W $777
	DC.W $0
ROTATE
	DC.W $10,$20,$30,$40,$50,$60,$70
*	DC.W $70
	DC.W $70,$60,$50,$40,$30,$20,$10

	DC.W $11,$22,$33,$44,$55,$66
	DC.W $66,$55,$44,$33,$22,$11
	
	DC.W $110,$220,$330,$440,$550,$660,$770
*	DC.W $770
	DC.W $770,$660,$550,$440,$330,$220,$110



SETUP
	MOVEQ.W #1,D0
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
	INCBIN "\MENU.187\CAMPBACK.PI1"
	EVEN
charset	
	INCBIN "\MENU.187\CHARSETX.PI1"
	EVEN
MUSIX	
	INCBIN "\MENU.187\BARB2.MAX"
	EVEN
SAVESTK	DC.L 0
INBORDER	DC.L 0
OLD	DC.L 0




