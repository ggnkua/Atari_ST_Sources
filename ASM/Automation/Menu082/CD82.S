	MOVE.L 4(A7),A5
	MOVE.L #$100,-(SP)
	MOVE.L A5,-(SP)
	MOVE.L #$4A0000,-(SP)
	TRAP #1
	ADD.L #12,SP

	MOVE.L #FILE1,A0
	MOVE.L #$68000-34,A1
	MOVE.L #32066,D0
	JSR COPY

	MOVE.L #FILE2,A0
	MOVE.L #$24826,A1
	MOVE.L #8000,D0
	JSR COPY

	move.l #text,tpnt

	MOVE.L #BACKG,POS1A
	MOVE.L #BACKG+400,POS2A

	PEA MENU
	MOVE.W #$26,-(SP)
	TRAP #14
	ADD.W #6,SP

	cmp.l #'term',which
	bne runprg

	MOVE.W #$4C,-(SP)
	TRAP #1

runprg	clr.l -(sp)	
	pea ct
	pea ct
	move.l which,-(sp)
	clr.w -(sp)
	move.w #$4b,-(sP)
	trap #1
	add.w #16,sp
	clr.w -(sp)
	trap #1

ct	dc.l 0

MENU

	MOVE.W #2,-(SP)
	TRAP #14
	ADD.W #2,SP

	move.l d0,SC

	move.w #5,-(sp)
	move.w #26,-(sp)
	trap #14
	add.w #4,sp


	MOVE.L SC,A0
	MOVE.W #31999,D0
CLR	CLR.B (A0)+
	DBRA D0,CLR

	LEA $FF8240,A0
	LEA $68000-32,A1
	MOVE.W #15,D0
COLS	MOVE.W (A1)+,(A0)+
	DBRA D0,COLS

	CLR.W D0
	JSR $24826

	MOVE.L $70,SAV70
	MOVE.L #VERT,$70

	MOVE.W vbl_timer,d0
hang1	cmp.w vbl_timer,D0
	beq hang1

	pea hbl
	move #1,-(sP)
	move.w #%1000,-(sp)
	move.w #1,-(sp)
	move.w #31,-(sP)
	trap #14
	add.w #12,sp

	LEA $68000+(55*160),A0
	MOVE.L SC,A1
	ADD.L #(20*160),A1
	MOVE.L #32000-(55*160),d0
SCR	MOVE.B (A0)+,(A1)+
	DBRA D0,SCR



test0	cmp.b #$b,KEY
	bne test1
	bchg.b #1,$ff820a
	clr.w vbl_timer
waitmo	cmp.w #25,vbl_timer
	blt waitmo
	bra test0
test1	cmp.b #2,KEY
	bne test2
	move.l #def,which
	bra ret
test2	cmp.b #3,KEY
	bne test3
	move.l #pink,which
	bra ret
test3	cmp.b #4,KEY
	bne test0
	move.l #'term',which
	
ret	move.w #5,-(sp)
	move.w #27,-(sp)
	trap #14
	add.w #4,sp

	move.l SC,a0
	move.l #32066/4,d0
blk	clr.l (a0)+
	dbra d0,blk

	move.w #8,-(sp)
	move.w #26,-(sp)
	trap #14
	add.w #4,sp

	MOVE.L SAV70,$70


	lea $ff8240,a0
	move.w #15,d0
eras	clr.w (a0)+
	dbra d0,eras

	move.w #$777,$ff825e

	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w

	RTS

KEY	DC.W 0


which	dc.l 0
def	dc.b "crown.jek",00
	even
pink	dc.b "panther.jek",00
	even

LINE	DC.W 198

hbl
	TST.W LINE
	BEQ BOTTOM

	move.l a0,sa0
	
	move.l POS1B,a0
	move.w (a0),$ff8240
	addq.l #2,POS1B
	move.l POS2B,a0
	move.w (a0),$ff825E
	addq.l #2,POS2B
	SUBQ.W #1,LINE
	move.l sa0,a0
EXITHBL	bclr.b #0,$fffa0f
	rte
sa0	dc.l 0
S118	DC.L 0
NKY	CLR.B $FFFC02
	RTE

BOTTOM	CLR.W $FF8240
	BRA EXITHBL

swap	dc.w 0
vbl_timer	dc.l 0
SCRL		dc.w 15
tpnt		dc.l 0
COUN		DC.W 200
CHBUFF		ds.w 16


VERT	
	movem.l d0-d7/a0-a6,-(a7)
	clr.w KEY

	tst.w swap
	beq noflip

	bchg.b #1,$ff820a
	clr.w swap
noflip

	move.b $fffc02,KEY

nordk
	MOVE.W #198,LINE
	MOVE.L DIR1,D0
	add.l D0,POS1A
	MOVE.L POS1A,POS1B
	MOVE.L DIR2,D0
	ADD.L D0,POS2A
	MOVE.L POS2A,POS2B
	SUBQ.W #1,COUN
	BNE RUNMUS

	NEG.L DIR1
	NEG.L DIR2
	MOVE.W #200,COUN

RUNMUS	
	move.w #2,d4
second
* TIMER ROUTINE
TIMER
	lea vbl_timer,a0
	addq #1,(a0)

* SCROLL ROUTINE


	move.w SCRL,d0
	addq.w #1,d0
	move.w d0,SCRL
	cmp.w #16,d0
	bne GO_SCROLL
	moveq.w #0,d0
	move.w d0,SCRL

********** copy next char into buffer
* find start of char & place in a5
	
	clr.l d1
	move.l tpnt,a0
	add.l #1,tpnt
BACK
	move.b (a0),d1
	cmp.b #$ff,d1
	bne next_char
	move.l #text,tpnt
	move.l tpnt,a0
	add.l #1,tpnt
	move.b (a0),d1
	
next_char

	sub.b #$20,d1

** calculate which line to copy

_p
	cmp.b #$50,d1
	blt _bsrk
	muls #8,d1
	add.l #5600,d1
	bra out
_bsrk
	cmp.b #$3c,d1
	blt _H
	muls #8,d1
	add.l #4160,d1
	bra out
_H
	cmp.b #$28,d1
	blt _4
	muls #8,d1
	add.l #2880,d1
	bra out
_4
	cmp.b #$14,d1
	blt _spc
	muls #8,d1
	add.l #1280,d1
	bra out

_spc
	muls #8,d1
	
out
	move.l #$68000,a5
	add.l d1,a5

	lea CHBUFF,a4
	move.l #8,d7
lip
	move.w (a5),(a4)+
	add.l #160,a5
	dbra d7,lip
	



*****************************

GO_SCROLL lea CHBUFF,a0
	  move.l SC,a1
	  add.l #160*3,a1
	  add.l #320,a1
	  move.l #9,d2


 
EACHUN	add.l #160,a1
	move.l a1,a2
	
	asl.w (a0)+
	roxl.w -(a2)
	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)

	subq.l #6,a2

	roxl.w -(a2)
	
	dbra d2,EACHUN
	dbra d4,second




CARRYON
	
EXIT_VBL
	jsr $24834
	movem.l (a7)+,d0-d7/a0-a6
	rte

DIR1	DC.L 2
DIR2	DC.L -2

POS1A	DC.L 0
POS1B	DC.L 0
POS2A	DC.L 0
POS2B	DC.L 0

BACKG
	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0

	DC.W $000,$100,$200,$300,$400,$500,$600
	DC.W $700
	DC.W $600,$500,$400,$300,$200,$100,$000

	DC.W $00,$10,$20,$30,$40,$50,$60
	DC.W $70
	DC.W $60,$50,$40,$30,$20,$10,$00

	DC.W $0,$1,$2,$3,$4,$5,$6
	DC.W $7
	DC.W $6,$5,$4,$3,$2,$1,$0






SAV70	DC.L 0
SC	DC.L 0

FILE1	INCBIN "DEGAS2.PI1"
	EVEN
FILE2	INCBIN "MUSIC"
	EVEN

COPY	MOVE.B (A0)+,(A1)+
	DBRA D0,COPY
	RTS


text	dc.b "      Welcome to Automation menu 82 version 2.0       "
	dc.b "This disk was redone for two reasons.......    "
	dc.b "Firstly because Defender of the Crown didn't load everything in in one go on a meg system, and "
	dc.b "secondly because with Packer v 2.0 we can fit another game on. (Even if it is Mega-Crap - Its still over 15K smaller than Birdy's version!)       "
	dc.b "got to go now....... Bye Bye from THE LAW......        "

	dc.b $ff