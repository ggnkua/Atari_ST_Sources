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
	PEA $50000
	PEA $50000
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

	LEA $50000+32000,A0
	MOVE.W #24000/4,D0
CLEAR	CLR.L (A0)+
	DBRA D0,CLEAR

	MOVE.B #$1A,$FFFC02


	LEA PIC+2,A0
	LEA $FF8240,A1
	MOVE.W #15,D0
COLS	MOVE.W (A0)+,(A1)+
	DBRA D0,COLS

	LEA $50000,A0
	LEA PIC+34,A1
	MOVE.L #32000/4,D0
PICY	MOVE.L (A1)+,(A0)+
	DBRA D0,PICY

	MOVE.L $118,S118
	MOVE.L #NEWKEY,$118

	MOVE.L #$78000,new_scrn
	MOVE.L #$58000-480+32+(160*5),INBORDER



	PEA HBL
	MOVE.W #1,-(SP)
	MOVE.W #%1000,-(SP)
	MOVE.W #1,-(SP)
	MOVE.W #31,-(SP)
	TRAP #14
	ADD.W #12,SP


	MOVE.L $4CE,STORE
	MOVE.L #INTA,$4CE

	MOVE.W #5,-(SP)
	MOVE.W #26,-(SP)
	TRAP #14
	ADD.W #4,SP

WAIT	MOVE.W TIMER,D0
HANGIT	CMP.W TIMER,D0
	BEQ HANGIT
	ADDQ.W #1,CANI
	BSR SCROLL
	JSR $6E00C
	MOVE.B KEY,D0
	CMP.B #$B,D0
	BEQ FLIPFREQ
TEST1	CMP.B #02,KEY
	BNE TEST2
	MOVE.L #'TERM',D4
	BRA EXITA
TEST2	CMP.B #03,KEY
	BNE TEST3
	MOVE.L #RANA,D4
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
PLUS	CMP.W #9,spd
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

	MOVE.L STORE,$4CE

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

	LEA $58000-(160*5),A0
	MOVE.W #160/4,D0
ERASE	CLR (A0)+
	DBRA D0,ERASE

	CLR.W LINE


	ADD.W #1,TIMER

	MOVE.L (SP)+,D0
	RTS


NEWKEY	MOVE.B $FFFC02,KEY
	bclr.b #6,$fffffa11
	RTE
KEY	DC.W 0
S118	DC.L 0

RANA	DC.B "RANARAMA.LAW",00
	EVEN

NOFX	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	RTS

spd	dc.w 1


HBL	MOVE.L A0,SA0
	MOVE.L BG,A0
	MOVE.W (A0),$FF8240
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
PTR	dc.l $50000+(180*160)
count	dc.w 0
stchar	dc.l 0
GOTO 	DC.L 0
TIMER	DC.W 0
LINE	DC.W 0
STORE	DC.L 0
STACK	DC.L 0
text	
	DC.B "WELCOME TO vwxyz{ |}~ 170 - BROUGHT TO YOU BY abc OF jkl OF vwxyz{......    "
	DC.B "PASSENGERS ON THE WIND WAS HACKED BY DACK......    MAL'S DREAM HAS COME TRUE.....   PRESS PLUS AND MINUS ON THE KEYPAD, MAL!!         "
	DC.B "GREETS GO TO DACK , def , ghi , mno , pqr , stu , WAYNE , AND PHILL....  BOB, COL, BRI, MAL THE BIKE, "
	DC.B "DEAN AND ALL THE OTHER LOONIES WITH HIM! (ONLY KIDDING, GUYS!!), KHALED (FINALLY AN ST OWNER), "
	DC.B "NEIL E, CHRIS E, K.K.K. (MIKE.W - SEND MORE GRAFIX!), DAVID E. (SEND MORE GRAFIX - IN CASE YOU ARE WONDERING HE DREW THIS PICTURE), "
	DC.B "SIMON AND HIS RED SHADE DIGI-PICS, SIMON'S TWO FRIENDS WHOSE NAMES I CAN'T REMEMBER (ALTHOUGH I THINK ONE OF THEM IS MARK!), MAL'S FRIEND IN NORTH WALES (MERLIN COMPUTERS), THE REPLICANTS (ANY MORE MAD MAX MUSIC IN "
	DC.B "YOUR INTROS LATELY???), THE CAREBEARS (MEGA DEMO), THE UNION (BIG HELLO TO MAD - THE BEST MUSIC EVER ON THE ST - MAX - HOW ABOUT ANOTHER DEMO, GUYS?), THE BLADERUNNERS, BIRDY/SCC (WHO?), THE MEDWAY BOYS (SEE, SOMETIMES I DON'T RUN YOU "
	DC.B "DOWN!! - ONE OF THE BEST CREWS IN BRITAIN - HOW ABOUT SOME NEW MUSIC THOUGH ?), THE POMPEI PIRATES (WOT, NO OLD GAMES?!? - IF WE DIDN'T PACK THE OLD GAMES HOW MANY DISKS WOULD YOU HAVE? - DON'T RUN US DOWN 'COS WE'LL BEAT YOU "
	DC.B "AT PACKING GAMES ANY DAY OF ANY WEEK OF ANY MONTH OF ANY YEAR.......), IAN C, DELIGHT (NICE INTRO), ROB NORTHEN (A.K.A. THE REDUNDANT PROTECTION MAN - AUTOHACK 2.0 RULES OK!!), WALLY BEBEN AND DAVID WHITTAKER "
	DC.B "(FOR MAKING CRAP GAMES JUST A BIT BETTER WITH SOME GOOD MUSIC!), ANDY PENNEL (AUTHOR OF DEVPAC 2), AND TO YOU FOR READING ALL THIS RUBBISH YET AGAIN.............                 "
	DC.B "COMING TO AN vwxyz{ MENU NEAR YOU SOON.......    FERRARI F1 - PASSENGERS ON THE WIND 2 - MAKE A BREAK........    "
	DC.B "   -   HOW DO I KNOW - WELL I HAVE ALREADY DONE THEM AND THEY ARE GOING ON MENU 171.....   NO MORE 'FUSION COMING SOONS' AGAIN........    "
	DC.B "                         "
	DC.B "IF YOU READ THIS SCROLL ONE HUNDRED TIMES I WILL MOST DEFINATELY NOT TELL YOU HOW TO PACK A GAME , OR TO REMOVE ALL THE BORDERS , OR EVEN TELL YOU HOW TO MAKE THE SCREEN GO RED - IN FACT NOTHING WILL HAPPEN EXCEPT YOU GETTNIG "	
	DC.B "VERY,VERY,VERY,VERY BORED.......                   HEY, WHAT'S THIS?       ANOTHER SCROLLER.......      "     
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
	MOVE.W #7,D0
	BRA COLQ

S5060	NEG.W FFLAG
	MOVE.W #$700,D0
	
COLQ	LEA HERE,A0
	MOVE.W #40,D5
FPL	MOVE.W D0,(A0)+
	DBRA D5,FPL
	CLR.W CANI
	BRA WAIT
CANI	DC.W 20

SETFREQ	CMP.W #$7,HERE
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

HERE	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700
	DC.W $700

SETUP	LEA MUSIX,A0
	LEA $6E000,A1
	MOVE.L #12008,D0
CMUS	MOVE.B (A0)+,(A1)+
	DBRA D0,CMUS

	JSR $6E000

	RTS



*SAMP	LEA SAMPLAY,A0
*	ADD.L #28,A0
*
*	MOVE.L #SAMPLE+12,2(A0)
*	MOVE.L #END,A3
*	MOVE.L #SAMPLE+12,A2
*	SUB.L A2,A3
*	MOVE.L A3,6(A0)
*	MOVE.L #2,10(A0)
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

SAMPLAY
*	INCBIN "BASCODE.EXE"
	EVEN
SAMPLE	
*	INCBIN "SAMPLE.SAM"
END	EVEN

PIC
	INCBIN "\MENU.170\VERMIN.PI1"
	EVEN
charset	
	INCBIN "\MENU.170\CHARSETX.PI1"
	EVEN
MUSIX	
	INCBIN "\MENU.170\DIST.MAX"
	EVEN
SAVESTK	DC.L 0
INBORDER	DC.L 0
OLD	DC.L 0

