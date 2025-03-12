	OPT	X+
CPU=1			;0=TPS CPU
XGAUCHE=40+16
XMILIEU=$50+8+80
YMILIEU=$64
MAX=320
MAY=200
;
; - scrolling
; - majorer … 3 VBLs
; - mettre les bonnes palettes
; - mettre le scrolling originel
;
; L21D=COMPTEUR DE VBL EN BYTE
; L1B1=SAISIE CLAVIER
; L153=WORD MODULO ECRAN
;
	IFEQ	1
	LEA	L25D,A0
	LEA	BUFFER3,A0
	LEA	BUFFER6,A0
	LEA	L238(PC),A0
	ENDC

HARD=0

Vsync_no_interrupt	MACRO
.waitvbl\@:
	move.b	$ffff8205.w,d0
	cmp.b	$ffff8201.w,d0
	bne.s	.waitvbl\@

	move.b	$ffff8207.w,d0
	cmp.b	$ffff8203.w,d0
	bne.s	.waitvbl\@

	tst.b	$ffff8209.w
	bne.s	.waitvbl\@

	ENDM

	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	bsr	INIT_TEXT
	bsr.s	init

	bra	mainprg
fin:
	bsr	uninit
	ILLEGAL
	clr	-(sp)
	trap	#1

init:
	move.b	$ffff8260.w,oldrez

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal

	move	#$2700,sr

	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb

	lea	$8.w,a0	; Redirection des bombes
	move.l	#fin,d0
	REPT	8
	move.l	d0,(a0)+
	ENDR

	Vsync_no_interrupt
	clr.b	$ffff8260.w

;	CLR.L	-(SP)
;	MOVE	#$20,-(SP)
;	TRAP	#1
;	ADDQ	#6,SP
;	MOVE	#37,-(SP)
;	TRAP	#14
;	ADDQ	#2,SP
;
;	CLR.B	$FFFF8260.W
	bsr	initmfp
	bsr	init_mouse
	move	#$2300,sr
	bsr	error_clavier

	rts

;NEWPAL:
;	DC.W	$000/2,$FFF/2,$EEE/2,$BBB/2,$AAA/2,$999/2,$777/2,$555/2
;	DC.W	$000/2,$FA8/2,$FE0/2,$080/2,$0D0/2,$0CC/2,$06F/2,$00A/2
;	DC.W	$000,$111,$222,$333,$444,$555,$666,$777
;	DC.W	$000,$011,$022,$033,$044,$055,$066,$077

uninit:
	move	#$2700,sr

	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w

	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	jsr	finmfp

	cmpi.b	#2,oldrez
	bne.s	.no_change_moni

.waitmoni:
	btst	#7,$fffffa01.w
	bne.s	.waitmoni

	moveq	#50-1,d0
	bsr	wait

.no_change_moni:
	Vsync_no_interrupt
	move.b	oldrez,$ffff8260.w
	move.l	$44e.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	error_clavier
	move	#$2300,sr

	bsr	waitc
	move.b	#$8,$fffffc02.w

	rts
	
initmfp:
	move	sr,-(a7)
	move	#$2700,sr

	move.b	$ffff820a.w,oldfreq

	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move	#16,d0

savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp

	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40

	bsr	finmfp

	bclr	#3,$fffffa17.w

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w

	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa15.w

	move.l	#vbl,$70.w
	move.l	#clavier,$118.w


	JSR	BASE+$564

	MOVE.L	#MUSIC,BASE+$34

; LANCEMENT MUSIQUE
	JSR	BASE+$5E6

	move	(a7)+,sr
	rts
vbl:
	movem.l	d0-a6,-(sp)

	MOVE	#$777,PALETTE+15*2
	MOVEM.L	PALETTE,D0-D7
	move	d0,$ffff8242.w
	MOVEM.L	D1-D7,$FFFF8244.W

	BSR	BASE+$79A
	BSR	AFF_FNT

	tst	prgvbl
	beq.s	.novbl
	move	#$2300,sr
	CLR	prgvbl
	IFEQ	CPU
	move	#$555,$ffff8240.w
	ENDC
	jSR	INTERRUPTION
	IFEQ	CPU
	clr	$ffff8240.w
	ENDC
	addq	#1,prgvbl
.novbl:
;	cmp.b	#$39,$fffffc02.w
;	beq	fin
	tst.b	clav+$39
	bne	fin

	movem.l	(sp)+,d0-a6
	rte
prgvbl:	dc.w	0
BASE:	INCBIN	MUSICLOG.BIN
MUSIC:	INCBIN	MUS2.LOG

oldfreq	dc.w	0

finmfp:
	move	sr,-(a7)
	move	#$2700,sr

;	moveq	#0,d1	; Ecran noir
;	lea	$ffff8240.w,a0
;	moveq	#16/2-1,d0
;.noir:
;	move.l	d1,(a0)+
;	dbra	d0,.noir

	bsr	waitc
	move.b	#$22,(a0)
	bsr	waitc
	move.b	#$f0,(a0)
	bsr	waitc
	move.b	#$00,(a0)

	IFNE	HARD
	reset
	dcb.w	50,$4e71
	tst.b	$fffffc00.w
	dcb.w	10,$4e71
	move.b	#2,$ffff820a.w

	lea	$fffffc02.w,a0

	move.b	#$03,$fffffc00.w
	move.b	#$96,$fffffc00.w

	move	#4-1,d0
	bsr	wait

	move.l	#$0700c000,$ffff8800.w	; Reinitialise drive
	move.l	#$0e000700,$ffff8800.w

	ENDC

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move	#16,d0

restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp

	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	move	(a7)+,sr
	rts


clavier:
	btst	#0,$fffffc00.w
	beq.s	noclav

	move	d0,-(a7)

	clr	d0
	move.b	$fffffc02.w,d0

	cmpi.b	#$f7,d0
	beq.s	absolute_mouse_1

	move.l	a0,-(a7)
	bclr	#7,d0
	lea	clav(pc),a0
	seq	(a0,d0)
	move.l	(a7)+,a0

	move	(a7)+,d0
noclav:
	rte

absolute_mouse_1:
	move.l	#absolute_mouse_2,$118.w
	move	(a7)+,d0
	rte

absolute_mouse_2:
	btst	#0,$fffffc00.w
	beq.s	noclav

	move	d0,-(a7)

	move.b	$fffffc02.w,d0
	beq.s	.finclav

	btst	#0,d0
	beq.s	.er
	bset	#0,mousek
	bra.s	.finclav
.er:
	btst	#1,d0
	beq.s	.rr
	bclr	#0,mousek
	bra.s	.finclav
.rr:

	btst	#2,d0
	beq.s	.el
	bset	#1,mousek
	bra.s	.finclav
.el:
	btst	#3,d0
	beq.s	.rl
	bclr	#1,mousek
.rl:

.finclav:
	move	(a7)+,d0

	move.l	#absolute_mouse_3,$118.w
	rte

absolute_mouse_3:
	btst	#0,$fffffc00.w
	beq.s	noclav
	move.b	$fffffc02.w,cmousex

	move.l	#absolute_mouse_4,$118.w
	rte

absolute_mouse_4:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousex+1

	move.l	#absolute_mouse_5,$118.w
	rte

absolute_mouse_5:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousey

	move.l	#absolute_mouse_6,$118.w
	rte

absolute_mouse_6:
	btst	#0,$fffffc00.w
	beq	noclav
	move.b	$fffffc02.w,cmousey+1

	move	cmousex,mousex
	move	cmousey,mousey

	move.l	#clavier,$118.w
	rte

MAX_MOUSEX	=	2000
MAX_MOUSEY	=	2000

clav	ds.b	128
mouse_maxx	dc.w	MAX_MOUSEX
mouse_maxy	dc.w	MAX_MOUSEY
cmousex	dc.w	0
cmousey	dc.w	0
mousex	dc.w	MAX_MOUSEX/2
mousey	dc.w	MAX_MOUSEY/2
mousek	dc.b	0
	even

init_mouse:
	lea	$fffffc02.w,a0

	bsr.s	waitc	; Set mouse limit
	move.b	#$09,(a0)
	bsr.s	waitc
	move.b	mouse_maxx,(a0)
	bsr.s	waitc
	move.b	mouse_maxx+1,(a0)

	bsr.s	waitc
	move.b	mouse_maxy,(a0)
	bsr.s	waitc
	move.b	mouse_maxy+1,(a0)

	bsr.s	waitc	; Set mouse position
	move.b	#$0e,(a0)
	bsr	waitc
	clr.b	(a0)
	bsr.s	waitc
	move.b	mousex,(a0)
	bsr.s	waitc
	move.b	mousex+1,(a0)
	bsr.s	waitc
	move.b	mousey,(a0)
	bsr.s	waitc
	move.b	mousey+1,(a0)

	bsr.s	error_clavier

	rts

waitc:
	btst	#1,$fffffc00.w
	beq.s	waitc
	rts

error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:

	rts

wait:
	move	#13333,d1
.wait:
	dbra	d1,.wait
	dbra	d0,wait

	rts

	section	bss

oldvec	ds.l	24
oldmfp	ds.b	24

oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.b	1
	even
	section	text


; ------------------------------------------------------------------------ ;
;		Routine de droite		;
;	        (Gere le clippping en X et en Y)		;
; ------------------------------------------------------------------------ ;
; Appel:
; d0 : X1
; d1 : Y1
; d2 : X2
; d3 : Y2
; a0 : Adresse ‚cran

; Entr‚e -->
X1	EQUR	d0
Y1	EQUR	d1
X2	EQUR	d2
Y2	EQUR	d3
ADECRAN	EQUR	a0
; Registres temporaire -->
DX	EQUR	d4
DY	EQUR	d5
XX	EQUR	d6
NLOOP	EQUR	d7
LX	EQUR	d1
LY	EQUR	d1
CURDOT	EQUR	d2
ADEC	EQUR	d3

fin_line:
	rts

draw_line:
	; #[ Clipping:
	cmp	Y1,Y2
	bge.s	.noswap2
	exg	Y1,Y2
	exg	X1,X2
.noswap2:

	move	Y2,DY	; Droite dans ‚cran?
	blt.s	fin_line
	cmpi	#MAY,Y1	;   ""    ""	""  ?
	bgt.s	fin_line
	sub	Y1,DY

	move	X2,DX	; Calcul DX
	sub	X1,DX

	cmpi	#MAY,Y2	; Doit on clipper?
	ble.s	.noclip_bas

	subi	#MAY,Y2
	muls	DX,Y2
	divs	DY,Y2
	sub	Y2,X2
	move	#MAY,Y2
.noclip_bas:

	tst	Y1
	bge.s	.noclip_haut

	muls	DX,Y1
	divs	DY,Y1
	sub	Y1,X1
	clr	Y1
.noclip_haut:

	cmp	X1,X2
	bge.s	.noswap

	exg	X1,X2
	exg	Y1,Y2
.noswap:

	tst	X2	; Droite visible?
	blt.s	fin_line
	cmpi	#MAX,X1
	bgt	fin_line

	cmpi	#MAX,X2	; Doit on clipper?
	ble.s	.noclip_droite

	subi	#MAX,X2
	muls	DY,X2
	divs	DX,X2
	sub	X2,Y2
	move	#MAX,X2
.noclip_droite:

	tst	X1
	bge.s	.noclip_gauche

	muls	DY,X1
	divs	DX,X1
	sub	X1,Y1
	clr	X1
.noclip_gauche:
	; #] Clipping:


	move	X2,DX
	sub	X1,DX
	move	Y2,DY
	sub	Y1,DY

	MOVE.L	ADRECRAN,ADECRAN
	muls	#160,Y2
	adda	Y2,ADECRAN
	move	X2,XX
	andi	#$ff0,XX
	lsr	#1,XX
	adda	XX,ADECRAN
	clr	XX
	not	X2
	andi	#$f,X2
	bset	X2,XX

	move	#-160,ADEC
	tst	DY
	bge.s	.okneg
	neg	DY
	neg	ADEC
.okneg:

	cmp	DX,DY
	blt.s	penteinf1

	tst	DY
	beq	fin_line
	move	DY,LY
	asr	#1,LY
	move	DY,NLOOP
	subq	#1,NLOOP

.loop:
	or	XX,(ADECRAN)
	or	XX,2(ADECRAN)
	or	XX,4(ADECRAN)
	or	XX,6(ADECRAN)
	adda	ADEC,ADECRAN
	sub	DX,LY
	bgt.s	.noaddplot
	add	DY,LY
	add	XX,XX
	bcc.s	.noaddplot
	subq	#8,ADECRAN
	moveq	#1,XX
.noaddplot:
	dbra	NLOOP,.loop


	or	XX,(ADECRAN)
	or	XX,2(ADECRAN)
	or	XX,4(ADECRAN)
	or	XX,6(ADECRAN)

	rts

penteinf1:
	clr	CURDOT
	move	DX,LX
	asr	#1,LX
	move	DX,NLOOP
	subq	#1,NLOOP

.loop:
	or	XX,CURDOT
	sub	DY,LX
	bge.s	.ok
	or	CURDOT,(ADECRAN)
	or	CURDOT,2(ADECRAN)
	or	CURDOT,4(ADECRAN)
	or	CURDOT,6(ADECRAN)
	adda	ADEC,ADECRAN
	add	DX,LX
	clr	CURDOT
.ok:
	add	XX,XX
	bcs.s	.plot
	dbra	NLOOP,.loop

	or	CURDOT,(ADECRAN)
	or	CURDOT,2(ADECRAN)
	or	CURDOT,4(ADECRAN)
	or	CURDOT,6(ADECRAN)

.fin:
	rts
.plot:
	or	CURDOT,(ADECRAN)
	or	CURDOT,2(ADECRAN)
	or	CURDOT,4(ADECRAN)
	or	CURDOT,6(ADECRAN)
	subq	#8,ADECRAN
	clr	CURDOT
	moveq	#1,XX

	dbra	NLOOP,.loop

	or	CURDOT,(ADECRAN)
	or	CURDOT,2(ADECRAN)
	or	CURDOT,4(ADECRAN)
	or	CURDOT,6(ADECRAN)

	rts


*************************************************
*~~~	Routines du Scroll	~~~*
*************************************************
*~~~	Initialisation du Texte	~~~*
INIT_TEXT:	lea	TEXT,a0
	addq	#1,a0
	move.l	a0,MEM_TEXT
	rts

*~~~	Affichage de la fonte	~~~*
AFF_FNT:	moveq	#0,d0
	moveq	#0,d1
	lea	LETTRES,a1
	
	cmp	#1,PART_FONT
	blo	PART_FONT_1
	beq	PART_FONT_2
	cmp	#3,PART_FONT
	blo	PART_FONT_3
	beq	PART_FONT_4
	
PART_FONT_1:	move.l	MEM_TEXT,a2
	move.b	-1(a2),d0	;Lettre precedente
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a3	;Adresse du graph
	moveq	#0,d0
	
	move.b	(a2),d0	;Lettre courante
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a4	;Adresse du graph
	moveq	#0,d0
	
	lea	BUF_TXT_SCR1,a0
	add	PNT_BUF_SCR,a0	;a0 partie gauche du buffer
	lea	8*41(a0),a1	;a1 partie droite du buffer
	rept	8
	move.b	(a3)+,d0
	lsl	#2,d0
	move.b	(a4)+,d1
	lsr	#6,d1
	or.b	d1,d0
	move.b	d0,(a0)+
	move.b	d0,(a1)+
	endr
	
	lea	BUF_TXT_SCR1,a1	
	bsr	COPY_BUF
	
	move	#1,PART_FONT
	bra	End_aff_font

PART_FONT_2:	move.l	MEM_TEXT,a2
	move.b	-1(a2),d0	;Lettre precedente
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a3	;Adresse du graph
	moveq	#0,d0
	
	move.b	(a2),d0	;Lettre courante
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a4	;Adresse du graph
	moveq	#0,d0
	
	lea	BUF_TXT_SCR2,a0
	add	PNT_BUF_SCR,a0	;a0 partie gauche du buffer
	lea	8*41(a0),a1	;a1 partie droite du buffer
	rept	8
	move.b	(a3)+,d0
	lsl	#4,d0
	move.b	(a4)+,d1
	lsr	#4,d1
	or.b	d1,d0
	move.b	d0,(a0)+
	move.b	d0,(a1)+
	endr
	
	lea	BUF_TXT_SCR2,a1	
	bsr	COPY_BUF
	
	move	#2,PART_FONT
	bra	End_aff_font
	
PART_FONT_3:	move.l	MEM_TEXT,a2
	move.b	-1(a2),d0	;Lettre precedente
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a3	;Adresse du graph
	moveq	#0,d0
	
	move.b	(a2),d0	;Lettre courante
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a4	;Adresse du graph
	moveq	#0,d0
	
	lea	BUF_TXT_SCR3,a0
	add	PNT_BUF_SCR,a0	;a0 partie gauche du buffer
	lea	8*41(a0),a1	;a1 partie droite du buffer
	rept	8
	move.b	(a3)+,d0
	lsl	#6,d0
	move.b	(a4)+,d1
	lsr	#2,d1
	or.b	d1,d0
	move.b	d0,(a0)+
	move.b	d0,(a1)+
	endr
	
	lea	BUF_TXT_SCR3,a1	
	bsr	COPY_BUF
	
	move	#3,PART_FONT
	bra	End_aff_font

PART_FONT_4:	move.l	MEM_TEXT,a2
	move.b	(a2),d0	;Lettre courante
	sub	#32,d0	;
	lsl	#3,d0	;
	lea	(a1,d0.w),a4	;Adresse du graph
	moveq	#0,d0
	
	lea	BUF_TXT_SCR4,a0
	add	PNT_BUF_SCR,a0	;a0 partie gauche du buffer
	lea	8*41(a0),a1	;a1 partie droite du buffer
	rept	8
	move.b	(a4)+,d0
	move.b	d0,(a0)+
	move.b	d0,(a1)+
	endr
	
	lea	BUF_TXT_SCR4,a1	
	bsr	COPY_BUF
	
	move	#0,PART_FONT
	addq	#8,PNT_BUF_SCR
	addq.l	#1,MEM_TEXT
	
	move.l	MEM_TEXT,a0
	tst.b	(a0)
	bne.s	.Cont
	bsr	INIT_TEXT	
.Cont:	cmp	#(40+1)*8,PNT_BUF_SCR
	bne.s	End_aff_font
	clr	PNT_BUF_SCR
End_aff_font:	rts

*~~~ Copie du buffer scroll dans l'ecran ~~~*
COPY_BUF:
	moveq	#0,d0
	move.l	d0,a0
	movep.w	$ffff8201(a0),d0
	asl.l	#8,d0
	move.l	d0,a0
	lea	192*160(a0),a0
;	move.l	ADRECRAN,A0
;	move.l	SCREENA,a0
;	lea	160*100(a0),a0
	add	PNT_BUF_SCR,a1
	addq	#8,a1
	
INC	set	0
	rept	20
	move.b	(a1)+,INC(a0)
	move.b	(a1)+,INC+160*1(a0)
	move.b	(a1)+,INC+160*2(a0)
	move.b	(a1)+,INC+160*3(a0)
	move.b	(a1)+,INC+160*4(a0)
	move.b	(a1)+,INC+160*5(a0)
	move.b	(a1)+,INC+160*6(a0)
	move.b	(a1)+,INC+160*7(a0)
	move.b	(a1)+,INC+1(a0)
	move.b	(a1)+,INC+160*1+1(a0)
	move.b	(a1)+,INC+160*2+1(a0)
	move.b	(a1)+,INC+160*3+1(a0)
	move.b	(a1)+,INC+160*4+1(a0)
	move.b	(a1)+,INC+160*5+1(a0)
	move.b	(a1)+,INC+160*6+1(a0)
	move.b	(a1)+,INC+160*7+1(a0)
INC	set	INC+8
	endr
	
	rts

	section	data

*~~~ Donnees relatives au scroll text ~~~*
LETTRES:	INCBIN	LETTRES.AFF
TEXT:
	dc.b	" HELLO, THIS IS ANOTHER GREAT CONVERSION FROM MRIPPER. "
	DC.B	"HERE ARE THE CREDITS : CUBE BY BUDDHA FROM SPREADPOINT, "
	DC.B	"LINE AND MOUSE ROUTINES BY ZIGGY STARDUST AND SCROLLER "
	DC.B	"BY ADSO... "

	dc.b	0
;	dc.b	" [\]^_^_^_^_   Tchoooo Tchooooo "
;	dc.b	" ADSO from The OVERLANDERS..... ",0
	EVEN

	section	bss

*~~~ Variables en rapport avec le scroll text ~~~*
MEM_TEXT:	ds.l	1
PART_FONT:	ds.w	1
PNT_BUF_SCR:	ds.w	1

BUF_TXT_SCR1:	ds.b	(40*2+2)*8
BUF_TXT_SCR2:	ds.b	(40*2+2)*8
BUF_TXT_SCR3:	ds.b	(40*2+2)*8
BUF_TXT_SCR4:	ds.b	(40*2+2)*8

	SECTION	TEXT
;
;L237=FLAG QUIT DEMO
;L59=QUIT DEMO
;L15E,L1B4,L1B7,L1BA
;
mainprg:
	BSR	L14D
	BSR	L131
	BSR	L5
	BSR	LC
	BSR	L149

	LEA	L1,A2
	LEA	L2,A4
	LEA	L254(PC),A5
	MOVEQ	#$19,D7
L2B:	MOVE.L	A2,A0
	BSR	L129
	MOVE.L	A2,(A5)+
	LEA	3004(A2),A0
	MOVE.L	A0,(A5)+
	ADDA	#-$BD8,A2
	ADDA	#$200,A4
	DBF	D7,L2B

	MOVE	#$23EF,D7
	LEA	BUFFER6,A0
L36:	CLR.B	(A0)+
	DBF	D7,L36

	LEA	L24C(PC),A0
	LEA	L24D(PC),A1
	LEA	L24F(PC),A2
	MOVEQ	#0,D0
	MOVEQ	#5,D7
L38:	MOVE.B	D0,(A0)+
	ST	(A1)+
	MOVE	D0,(A2)+
	ADDQ	#1,D0
	DBF	D7,L38

	LEA	L21E(PC),A0
	CLR.B	(A0)
	LEA	L23D(PC),A1
	LEA	L244(PC),A0
	MOVE.L	A0,(A1)
	LEA	L24A(PC),A0
	LEA	L22D(PC),A1
	MOVE.L	A0,(A1)
	LEA	L24B(PC),A0
	LEA	L22C(PC),A1
	MOVE.L	A0,(A1)
	LEA	L233(PC),A1
	CLR	(A1)
	LEA	L232(PC),A1
	CLR	(A1)
	LEA	L7A(PC),A0
	LEA	L21B(PC),A1
	MOVE.L	A0,(A1)


	MOVE.L	#ECRANS+255,D0
	CLR.B	D0
	LEA	L1FC,A0
	MOVE.L	D0,(A0)+
	ADD.L	#32000,D0
	MOVE.L	D0,(A0)+
	ADD.L	#32000,D0
	MOVE.L	D0,(A0)+

	JMP	L29
;
; ROUTINES D'INIT
;
L14D:
	LEA	BUFFER1,A1
	MOVE.L	A1,A2
	MOVEQ	#0,D0
	MOVEQ	#$7F,D7
L14E:
	MOVE	D0,D2
	MOVE	D2,(A1)+
	NEG	D2
	MOVE	D2,(A2)+
	MOVEQ	#1,D1

L14F:
	MOVE.L	D1,D2
	LSR	#1,D2
	ADD.L	D0,D2
	DIVS	D1,D2

;	MOVE.L	D0,D2
;	DIVS	D1,D2
;	SWAP	D2
;	ADD	D2,D2
;	CMP	D1,D2
;	BCS.S	L150
;	ADD.L	#$10000,D2
;L150:	SWAP	D2
	MOVE	D2,(A1)+
	NEG	D2
	MOVE	D2,(A2)+
	ADDQ.B	#1,D1
	BNE.S	L14F
	LEA	-$400(A2),A2
	ADD.L	#$100,D0
	DBF	D7,L14E
	RTS
L131:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L25A,A0
	LEA	L25B,A1
	LEA	L25C,A2
	MOVEQ	#0,D7
L132:	MOVE.B	D7,D0
	MOVE.B	D0,D1
	AND.B	#$F,D0
	LSR.B	#4,D1
	MOVE.B	D0,D2
	MOVE.B	D1,D3
	MOVE.B	D0,D4
	MOVE.B	D1,D5
	ADDQ.B	#1,D0
	LSL.B	#4,D0
	ADDQ.B	#1,D1
	LSL.B	#4,D1
	MOVE.B	D1,(A0)+
	MOVE.B	D0,(A0)+
	MOVEQ	#$B,D0
	ADD.B	D0,D2
	LSL.B	#3,D2
	ADD.B	D0,D3
	LSL.B	#3,D3
	MOVE.B	D3,(A1)+
	MOVE.B	D2,(A1)+
	MOVEQ	#$15,D0
	ADD.B	D0,D4
	LSL.B	#3,D4
	ADD.B	D0,D5
	LSL.B	#3,D5
	MOVE.B	D5,(A2)+
	MOVE.B	D4,(A2)+
	ADDQ.B	#1,D7
	BNE.S	L132
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L5:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L4,A0
	LEA	BUFFER2,A1
	LEA	L22A(PC),A5
	MOVEQ	#0,D5
	MOVEQ	#$15,D6
	MOVEQ	#$19,D7
L6:	MOVE.L	A1,(A5)+
	CLR	(A5)
L7:	MOVE.L	A0,A6
	BSR	L18
	BNE.S	L8
	ADDQ	#1,D5
	CMPI	#$140,D5
	BCS.S	L7
	ADDA	#$410,A0
	MOVEQ	#0,D5
	BRA.S	L7
L8:	ADDQ	#1,(A5)
	LEA	0(A0,D3.W),A2
	MOVE	D6,D0
L9:	MOVE.B	#$40,(A1)+
	BTST	D4,(A2)
	BEQ.S	LA
	MOVE.B	#-$80,-1(A1)
LA:	ADDA	#$28,A2
	DBF	D0,L9
	ADDQ	#1,D5
	CMPI	#$140,D5
	BCS.S	LB
	ADDA	#$410,A0
	MOVEQ	#0,D5
LB:	MOVE.L	A0,A6
	BSR	L18
	BNE.S	L8
	ADDQ	#4,A5
	DBF	D7,L6
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LC:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	BUFFER5,A1
	LEA	L228(PC),A0
	MOVE.L	A1,(A0)+
	MOVE	#$10,(A0)+
	MOVEQ	#$5B,D7
LD:	CLR.L	(A1)+
	DBF	D7,LD
;
; INIT FONTE
;
	LEA	L2,A0
	LEA	L226(PC),A2
	MOVEQ	#0,D5
	MOVEQ	#$16,D6
LE:	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	LSL	#3,D0
	LEA	L227(PC),A3
	ADDA	D0,A3
	MOVE.L	A1,(A3)+
	CLR	(A3)
LF:	MOVEQ	#3,D7
	MOVE.L	A0,A6
L10:	BSR	L18
	BNE.S	L11
	ADDA	#$1220,A6
	DBF	D7,L10
	ADDQ	#1,D5
	CMPI	#$140,D5
	BCS.S	LF
	ADDA	#$460,A0
	MOVEQ	#0,D5
	BRA.S	LF
L11:	MOVEM.L	D3-D4,-(A7)
L12:	ADDQ	#1,(A3)
	ADDQ	#1,D5
	MOVEQ	#3,D7
	MOVE.L	A0,A6
L13:	BSR	L18
	BNE.S	L12
	ADDA	#$1220,A6
	DBF	D7,L13
	MOVEM.L	(A7)+,D3-D4
	NEG.B	D4
	ADDQ.B	#7,D4
	MOVEQ	#-1,D1
	MOVE	(A3),D0
	ADDQ	#2,(A3)+
	ADDQ	#2,A3
	LSR.L	D0,D1
	NOT.L	D1
	LEA	0(A0,D3.W),A4
	MOVE	D6,D0
L14:	MOVEQ	#3,D7
L15:	MOVE.B	(A4)+,D2
	LSL	#8,D2
	MOVE.B	(A4)+,D2
	LSL.L	#8,D2
	MOVE.B	(A4)+,D2
	LSL.L	#8,D2
	MOVE.B	(A4)+,D2
	MOVE.B	(A4)+,D3
	LSL	#8,D3
	MOVE.B	(A4)+,D3
	LSL.L	#8,D3
	MOVE.B	(A4)+,D3
	LSL.L	#8,D3
	MOVE.B	(A4)+,D3
	SWAP	D7
	MOVE	D4,D7
	BRA.S	L17
L16:	ADD.L	D3,D3
	ADDX.L	D2,D2
L17:	DBF	D7,L16
	SWAP	D7
	AND.L	D1,D2
	MOVE.L	D2,(A1)+
	ADDA	#$1218,A4
	DBF	D7,L15
	SUBA	#$4858,A4
	DBF	D0,L14
	TST.B	(A2)
	BNE	LE
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L18:	MOVE	D5,D4
	MOVE	D4,D3
	AND	#7,D4
	NEG	D4
	ADDQ	#7,D4
	LSR	#3,D3
	MOVE	D3,D2
	MOVE	D6,D0
L19:	BTST	D4,0(A6,D2.W)
	BNE.S	L1A
	ADD	#$28,D2
	DBF	D0,L19
	MOVEQ	#0,D0
L1A:	RTS

L149:	MOVEM.L	A2-A6/D2-D7,-(A7)
	LEA	L259(PC),A0
	MOVEQ	#0,D7
L14A:	MOVE.L	A0,A1
	MOVEQ	#0,D6
L14B:	MOVE	D7,D0
	MULU	D6,D0
	DIVU	#$18,D0
	CMP	D7,D0
	BLE.S	L14C
	MOVE	D7,D0
L14C:	MOVE	D0,(A1)
	ADDA	#$20,A1
	ADDQ	#1,D6
	CMPI	#$20,D6
	BCS.S	L14B
	ADDQ	#2,A0
	ADDQ	#1,D7
	CMPI	#$10,D7
	BCS.S	L14A
	MOVEM.L	(A7)+,A2-A6/D2-D7
	RTS


L29:

;WAIT BLITTER

	CLR.L	L218

;
; WAIT 30 VBLS
;
	IFEQ	1

	MOVEQ	#0,D7
L39:

	LEA	L25E(PC),A0
	LEA	$FFFF8240.W,A1
	MOVEQ	#7,D6
L3A:	MOVE	(A0)+,D0
	MOVE	D0,D1
	AND	#$F,D0
	LSR	#4,D1
	MOVE	D1,D2
	AND	#$F,D1
	LSR	#4,D2
	AND	#$F,D2
	MULU	D7,D0
	MULU	D7,D1
	MULU	D7,D2
	LSR	#4,D0
	AND	#$F0,D1
	AND	#$F0,D2
	LSL	#4,D2
	ADD	D1,D0
	ADD	D2,D0
	MOVE	D0,(A1)+
	DBF	D6,L3A

	ADDQ	#1,D7
	CMPI	#$11,D7
	BCS.S	L39
	ENDC

	LEA	L239(PC),A0
	CLR.B	(A0)
;	JSR	INITREPLAY
	st	prgvbl
L3B:	BSR	L13C
	BSR	L141
	BSR	L146

.L88	TST.B	L21D
	BEQ.S	.L88
	CLR.B	L21D

;	BSR	INTERRUPTION

;WAIT BLITTER
	LEA	L1FC(PC),A1
	MOVEM.L	(A1),D0-D2
	EXG	D1,D0
	EXG	D2,D1
	MOVEM.L	D0-D2,(A1)
	MOVE.L	D0,ADRECRAN
	MOVE.L	D1,L218
	LSR	#8,D2
	MOVE.L	D2,$FFFF8200.W

	BSR	L164

	MOVE	L184(PC),D1
	LSR	#6,D1
	MOVEQ	#$1F,D0
	SUB	D1,D0
	BPL.S	L3C
	MOVEQ	#0,D0
L3C:	LSL	#5,D0
	LEA	L259(PC),A0
	ADDA	D0,A0
	LEA	L256(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	(A1)+,D0
	MOVE.B	(A1)+,D1
	MOVE.B	(A1)+,D2
	ADD	D0,D0
	ADD	D1,D1
	ADD	D2,D2
	MOVE	0(A0,D0.W),D0
	MOVE	0(A0,D1.W),D1
	MOVE	0(A0,D2.W),D2
	LSL	#4,D0
	ADD	D1,D0
	LSL	#4,D0
	ADD	D2,D0
;	MOVE.L	L20C(PC),A1
;	MOVE	D0,122(A1)

; QU'EST-CE QUE C'EST ???

	LEA	L18A(PC),A3
	LEA	L173(PC),A4
	LEA	L18B(PC),A5
	MOVEQ	#0,D7
L3D:	LEA	L24F(PC),A6
	MOVE	0(A6,D7.W),D0
	LEA	L250(PC),A6
	LSL	#4,D0
	ADDA	D0,A6
	MOVE	(A4)+,D0
	MOVE	(A4),D4
	MOVE	0(A3,D0.W),D0
	SUB	0(A3,D4.W),D0
	LSR	#5,D0
	AND	#-$40,D0
	MOVE	L184(PC),D1
	LSR	#1,D1
	AND	#-$40,D1
	SUB	D1,D0
	BMI.S	L3E
	LEA	L185(PC),A0
	SUB	0(A0,D7.W),D0
	BPL.S	L3F
L3E:	MOVEQ	#0,D0
L3F:	MOVEM	(A4),D1-D4
	LEA	L152(PC),A1
	MOVE.L	0(A5,D1.W),(A1)+
	MOVE.L	0(A5,D2.W),(A1)+
	MOVE.L	0(A5,D3.W),(A1)+
	MOVE.L	0(A5,D4.W),(A1)+
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	MOVE	L157(PC),D2
	SUB	L153(PC),D2
	MULS	D2,D1
	MOVE	L156(PC),D3
	SUB	L152(PC),D3
	MOVE	L155(PC),D4
	SUB	L153(PC),D4
	MULS	D4,D3
	SUB.L	D3,D1
	BMI	L43
	MOVE.B	L221(PC),D1
	BNE.S	L40
	MOVE	#$3E0,D0
L40:

;	IFEQ	1
;
; CHANGEMENT DE PALETTE TEMPS REEL
;
;	ADDQ	#7,$FFFF8240.W
	LEA	L259(PC),A2
	ADDA	D0,A2
	MOVE	8(A6),D1
	ADD	D1,D1
	LEA	L257(PC),A1
	LEA	-2(A1,D1.W),A1
	MOVE.L	4(A6),A0
	MOVEQ	#9,D3
L41:	MOVE	(A0)+,D0
	MOVE	D0,D1
	LSR	#4,D1
	MOVE	D1,D2
	LSR	#4,D2
	AND	#$F,D0
	AND	#$F,D1
	AND	#$F,D2
	ADD	D0,D0
	ADD	D1,D1
	ADD	D2,D2
	MOVE	0(A2,D0.W),D0
	MOVE	0(A2,D1.W),D1
	MOVE	0(A2,D2.W),D2
	LSL	#4,D2
	ADD	D1,D2
	LSL	#4,D2
	ADD	D0,D2

	LSR	#1,D2

	MOVE	D2,(A1)+
	DBF	D3,L41
;	ENDC

	MOVE.L	10(A6),A2
	LEA	L185(PC),A0
	CMP	#$3E0,0(A0,D7.W)
	BEQ.S	L42
	MOVE.L	(A6),A0
	ADD	14(A6),A0
	MOVE.L	ADRECRAN,A1
	BSR	L8D

;
; TRACE DU SQUELETTE DU CUBE
;
L42:
	movem.l	d0-a6,-(sp)
	MOVEM	L152(PC),D0-D3
	BSR	draw_line
	MOVEM	L154(PC),D0-D3
	BSR	draw_line
	MOVEM	L156(PC),D0-D3
	BSR	draw_line
	MOVEM	L158(PC),D0-D1
	MOVEM	L152(PC),D2-D3
	BSR	draw_line
	movem.l	(sp)+,d0-a6
L43:	ADDQ	#8,A4
	ADDQ	#2,D7
	CMPI	#$C,D7
	BCS	L3D
	MOVE.B	L238(PC),D0
	BEQ.S	L44
	BSR	L89
L44:	MOVEQ	#1,D1
L45:	MOVE.B	L220(PC),D0
	BEQ.S	L46
	BSR	L6D
	DBF	D1,L45
L46:	LEA	L235(PC),A0
	TST.B	(A0)
	BEQ.S	L47
	SUBQ.B	#1,(A0)
L47:
	IFEQ	1
	LEA	L257(PC),A0
	MOVE.L	L20C(PC),A1
	ADDQ	#2,A1
	MOVEQ	#$1D,D0
L48:	MOVE	(A0)+,(A1)+
	ADDQ	#2,A1
	DBF	D0,L48
	ENDC

	MOVE.B	L237(PC),D0
	BMI	L59
	BNE	L3B
	LEA	L238(PC),A0
	LEA	L247(PC),A1
	LEA	L249(PC),A2
	TST.B	(A0)
	BEQ.S	L49
	BMI.S	L4A
	BPL.S	L4B
L49:
	BRA	L3B
L4A:
	MOVE.B	#1,(A0)
	CLR.B	L239
	CLR.B	L23A
	CLR	L234
	CLR.B	L235
	CLR	L22E
	MOVE.L	A1,L22D
	MOVE.L	A2,L22C
	BRA	L3B
L4B:
;
; TEST DE TOUCHE
;
	LEA	L1B1(PC),A0
	MOVE.B	(A0),D0
	BEQ.S	L49
	BMI.S	L4E
	LEA	L4F(PC),A1
	LEA	L50(PC),A2
L4C:	CMP.B	(A1),D0
	BEQ.S	L4D
	ADDQ	#2,A2
	TST.B	(A1)+
	BNE.S	L4C
	BRA.S	L4E
L4D:	MOVE	(A2),D0
	ILLEGAL
	JSR	L50(PC,D0.W)
L4E:	LEA	L1B1(PC),A0
	CLR.B	(A0)
	BRA.S	L49
L4F:	DC.B	$0F,$1D,$1E,$1F,'-./='
	DC.B	'>!(&',$17,$00
L50:	DC.W	X1A-L50
	DC.W	X52-L50
	DC.W	X6A-L50
	DC.W	X6E-L50
	DC.W	X72-L50
	DC.W	X76-L50
	DC.W	X7A-L50
	DC.W	X7E-L50
	DC.W	XBE-L50
	DC.W	XE2-L50
	DC.W	XF8-L50
	DC.W	X100-L50
	DC.W	X110-L50
X1A:
	LEA	L220(PC),A0
	MOVEQ	#0,D0
	TST.B	(A0)
	BNE.S	L52
	MOVE.L	#BUFFER3,L21A
	MOVE.L	L21B(PC),A0
	LEA	L75(PC),A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	LEA	L21B(PC),A1
	TST	(A0)
	BNE.S	L51
	LEA	L7A(PC),A0
L51:	MOVE.L	A0,(A1)
	LEA	L220(PC),A0
	MOVEQ	#1,D0
L52:	MOVE.B	D0,(A0)
	RTS

X52:
	MOVEQ	#0,D0
L53:	LEA	L24C(PC),A0

	ADDA	D0,A0
	MOVE.B	(A0),D0
	ADDQ.B	#1,D0
	CMPI.B	#$1A,D0
	BCS.S	L54
	MOVEQ	#0,D0
L54:	MOVE.B	D0,(A0)
	RTS
X6A:	MOVEQ	#1,D0
	BRA.S	L53
X6E:	MOVEQ	#2,D0
	BRA.S	L53
X72:	MOVEQ	#3,D0
	BRA.S	L53
X76:	MOVEQ	#4,D0
	BRA.S	L53
X7A:	MOVEQ	#5,D0
	BRA.S	L53
X7E:	LEA	L24C(PC),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ADDQ.B	#1,D0
	CMPI.B	#$1A,D0
	BCS.S	L55
	MOVEQ	#0,D0
L55:	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	L56(PC,D0.W),D0
	BRA	L1DB
L56:	DS.W	2
	DC.B	$04,$00,$01,$03,$02,$00,$00,$00
	DC.B	$00,$04,$00,$00,$00,$00,$00,$00
	DS.W	3
XBE:	LEA	L24F(PC),A0
	MOVE	(A0),D0
	ADDQ	#1,D0
	CMPI	#6,D0
	BCS.S	L57
	MOVEQ	#0,D0
L57:	MOVE	D0,(A0)+
	MOVE	D0,(A0)+
	MOVE	D0,(A0)+
	MOVE	D0,(A0)+
	MOVE	D0,(A0)+
	MOVE	D0,(A0)+
	LEA	L221(PC),A0
	CLR.B	(A0)
	RTS
XE2:	LEA	L21E(PC),A0
	NOT.B	(A0)
	LEA	L243(PC),A0
	ADDQ	#2,A0
	MOVE.L	A0,D0
	LEA	L23C(PC),A0
	MOVE.L	D0,(A0)
	RTS
XF8:	LEA	L221(PC),A0
	NOT.B	(A0)
	RTS
X100:	LEA	L7F(PC),A0
	MOVEQ	#1,D0
	TST.B	(A0)
	BMI.S	L58
	MOVEQ	#-1,D0
L58:	MOVE.B	D0,(A0)
	RTS
X110:	LEA	L248(PC),A1
	MOVE.L	A1,L22D
	LEA	L249(PC),A1
	MOVE.L	A1,L22C
	RTS
;	DC.B	$09,$99,$09,$99,$09,$99,$09,$99
;	DC.B	$09,$99,$09,$99,$09,$99,$09,$99
;	DC.B	$09,$99
L59:
	ILLEGAL

L6D:	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE.B	L220(PC),D0
	MOVEM.L	L21C(PC),A0-A5/D0-D7
	BMI.S	L70
	MOVE.L	L21A(PC),A0
	MOVE.L	A0,A1
	MOVEQ	#$4A,D7
L6E:	MOVE.L	A1,A2
	MOVEQ	#$4A,D6
L6F:	CLR.B	(A2)+
	DBF	D6,L6F
	LEA	256(A1),A1
	DBF	D7,L6E
	LEA	$4000.w,A1
	MOVE	L75(PC),A4
	MOVEQ	#$C,D6
	MOVEQ	#$4A,D7
L70:	SWAP	D7
	MOVE	L76(PC),A5
	MOVE	#$4A,D7
L71:	MOVEQ	#$14,D5
	MOVEQ	#0,D1
	MOVEQ	#0,D2
L72:	MOVE.L	D1,D0
	MULS	D0,D0
	LSR.L	D6,D0
	ADD.L	D2,D1
	MULS	D2,D2
	LSR.L	D6,D2
	MOVE.L	D2,D3
	ADD.L	D0,D3
	CMP.L	A1,D3
	BGT.S	L73
	SUB.L	D0,D2
	ADD.L	A5,D2
	MULS	D1,D1
	LSR.L	D6,D1
	SUB.L	D3,D1
	ADD.L	A4,D1
	DBF	D5,L72
L73:	ADDA	L78(PC),A5
	MOVE.B	L79(PC,D5.W),(A0)+
	DBF	D7,L71
	SWAP	D7
	ADDA	#$B5,A0
	ADDA	L77(PC),A4
	DBF	D7,L74
	LEA	L220(PC),A0
	CLR.B	(A0)
	LEA	L239(PC),A0
	BCLR	#3,(A0)
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L74:	LEA	L21C(PC),A6
	MOVEM.L	A0-A5/D0-D7,(A6)
	LEA	L220(PC),A0
	ST	(A0)
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L75:	DC.B	$F0,$00
L76:	DC.B	$E0,$00
L77:	DC.B	$00,'m'
L78:	DC.B	$00,$A3,$10
L79:	DC.B	' 0@P`p',$80,$90,$A0
	DC.B	' 0@P`p',$80,$90
	DC.B	$A0,' 0@P`p',$80
	DC.B	$90,$A0,' 0@P`p'
	DC.B	$80,$90,$A0,$00
L7A:	DC.B	$F0,$00,$E0,$00,$00,'m',$00,$A3
	DC.B	$F0,$00,$F0,$00,$00,$1B,$00,'='
	DC.B	$FE,$00,$E8,$00,$00,$0D,$00,$0D
	DC.B	$04,$00,$EB,$00,$00,$0A,$00,$0A
	DS.W	1
L7B:	DS.W	1
	DC.B	$00,$D2,$00,'x',$00,'K',$00,$1E
	DC.B	$0D,$DF,$0A,$AF,$07,'',$04,'O'
	DC.B	$01,$1F,$00,$00,$00,$00,$00,$00
	DS.W	4
	DC.B	$0D,' ',$07,$80,$04,$B0,$01,$E0
	DC.B	$0D,$FD,$0A,$FA,$07,$F7,$04,$F4
	DC.B	$01,$F1,$00,$00,$00,$00,$00,$00
	DS.W	4
	DC.B	$02,$0D,$08,$07,$0B,$04,$0E,$01
	DC.B	$0F,$DD,$0F,$AA,$0F,'w',$0F,'D'
	DC.B	$0F,$11,$00,$00,$00,$00,$00,$00
	DS.W	4
	DC.B	$00,$D2,$00,'x',$00,'K',$00,$1E
	DC.B	$0D,$DF,$0A,$AF,$07,'',$04,'O'
	DC.B	$01,$1F,$00,$00,$00,$00,$00,$00
	DS.W	3
L7C:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L81(PC),A0
	SUBQ.B	#1,(A0)
	BPL.S	L7E
	MOVE.B	#2,(A0)
	LEA	L80(PC),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ADDQ.B	#1,D0
	CMPI.B	#$C,D0
	BCS.S	L7D
	MOVEQ	#0,D0
L7D:	MOVE.B	D0,(A0)
	ADD.B	#$E,D0
	LEA	L24C(PC),A1
	MOVEQ	#0,D1
	MOVE.B	L7F(PC),D1
	MOVE.B	D0,0(A1,D1.W)
L7E:	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L7F:	DC.B	$FF
L80:	DC.B	$00
L81:	DS.W	1
L82:	EXT	D0
	LSL	#4,D1
	LEA	L85(PC,D1.W),A0
	LEA	L172(PC),A1
	MOVE	(A0)+,D1
	ADD	0(A1,D1.W),D0
	CMPI	#$3C,D0
	BHI.S	L83
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	NEG	D0
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	MOVE	(A0)+,D1
	MOVE	D0,0(A1,D1.W)
	RTS
L83:	CLR.B	-1(A2)
	LEA	L239(PC),A1
	BCLR	#2,(A1)
	RTS
L84:	DS.W	3
L85:	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
	DC.B	$00,$1E,$00,'$',$00,'&',$00,','
	DC.B	$00,$18,$00,$1A,$00,' ',$00,'*'
L89:
	LEA	L25D,A0
	CLR	280(A0)
	CLR	240(A0)
	CLR	200(A0)
	CLR	160(A0)
	CLR	120(A0)
	CLR	80(A0)
	CLR	40(A0)
	CLR	(A0)+
	MOVEQ	#0,D0
	MOVE.B	L21D(PC),D0
	AND	#$3F,D0
L8A:	DIVU	#$A,D0
	SWAP	D0
	MOVE	D0,D1
	SWAP	D0
	EXT.L	D0
	LSL	#3,D1
	LEA	L8C(PC,D1.W),A1
	MOVE.L	A0,A2
	MOVEQ	#7,D7
L8B:	MOVE.B	(A1)+,D1
	MOVE.B	D1,(A2)
	ADDA	#$28,A2
	DBF	D7,L8B
	SUBQ	#1,A0
	TST	D0
	BNE.S	L8A
	RTS
L8C:	DC.B	'|',$82,$82,$82,$82,$82,$82,'|'
	DC.B	$08,$18,'(',$08,$08,$08,$08,$08
	DC.B	'|',$82,$02,$0C,'0@',$80,$FE
	DC.B	'|',$82,$02,$0C,$02,$02,$82,'|'
	DC.B	$80,$84,$84,$FE,$04,$04,$04,$04
	DC.B	$FE,$80,$80,$FC,$02,$02,$02,$FC
	DC.B	'|',$82,$80,$FC,$82,$82,$82,'|'
	DC.B	$FE,$02,$04,$08,$10,' @',$80
	DC.B	'|',$82,$82,'|',$82,$82,$82,'|'
	DC.B	'|',$82,$82,'~',$02,$02,$82,'|'
L8D:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L10D(PC),A3
	MOVE.L	A2,(A3)
;	MOVE	#$64,D7
	MOVE	#160,D7		;MODULO REEL

	MOVE.L	#$4A0000,A2
	MOVEM.L	L152(PC),D1-D4
	MOVE	D1,D5
	CMP	D3,D5
	BCS.S	L8E
	MOVE	D3,D5
L8E:	MOVE	D2,D6
	CMP	D4,D6
	BCS.S	L8F
	MOVE	D4,D6
L8F:	CMP	D6,D5
	BHI	LCE
	CMP	D1,D5
	BNE	LAF

	MOVE	L153(PC),D0
	MULS	D7,D0

;	MOVE	D7,D0
;	MULS	#160,D0

	ADDA	D0,A1
	MOVE	L152(PC),D0
	ADDQ	#1,D0
	MOVE	D0,D1
	ASR	#4,D0
;	ADD	D0,D0
	ASL	#3,D0
	ADDA	D0,A1

	MOVEQ	#$F,D2
	AND	D2,D1
	SUB	D1,D2
	SWAP	D2
	LEA	BUFFER1,A3
	MOVE	L158(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	L90
	NEG	D0
L90:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1,A4
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	L91
	NEG	D0
L91:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A5
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	L92
	NEG	D0
L92:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	LEA	BUFFER1+$9600,A6
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	L93
	NEG	D0
L93:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	CMPA.L	A3,A4
	BLT	L9B
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D0
	MOVEQ	#0,D1
L94:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	LA4
	CMP.L	A2,D6
	BCS.S	L94
	MOVE.L	A2,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L156(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	L95
	NEG	D0
L95:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	L96
	NEG	D0
L96:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
L97:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9F
	CMP.L	A2,D6
	BCS.S	L97
	MOVE.L	#$4A004A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L158(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	L98
	NEG	D0
L98:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	L99
	NEG	D0
L99:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
L9A:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	TST.L	D6
	BGT.S	L9A
L9B:	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L9C:	MOVE.L	A2,D1
	MOVEQ	#0,D6
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L156(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	L9D
	NEG	D0
L9D:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	L9E
	NEG	D0
L9E:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	BRA.S	LA0
L9F:	MOVEQ	#$4A,D0
	CMP.L	A2,D6
	BGE.S	L9B
	MOVEM.L	D6/D0-D1,-(A7)
LA0:	LEA	BUFFER1,A3
	MOVE	L156(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LA1
	NEG	D0
LA1:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LA2
	NEG	D0
LA2:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LA3:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	CMP.L	A2,D6
	BCS.S	LA3
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LA4:	MOVEQ	#$4A,D0
	CMP.L	A2,D6
	BGE	L9C
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L156(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LA5
	NEG	D0
LA5:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LA6
	NEG	D0
LA6:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LA7:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	LAB
	CMP.L	A2,D6
	BCS.S	LA7
	MOVE.L	A2,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L156(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LA8
	NEG	D0
LA8:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LA9
	NEG	D0
LA9:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
LAA:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	CMP.L	A2,D6
	BCS.S	LAA
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LAB:	MOVE.L	#$4A004A,D0
	CMP.L	A2,D6
	BGE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L154(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LAC
	NEG	D0
LAC:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LAD
	NEG	D0
LAD:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
LAE:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	CMP.L	A2,D6
	BCS.S	LAE
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LAF:	MOVE	L157(PC),D0
	MULS	D7,D0
	ADDA	D0,A1
	MOVE	L156(PC),D0
	ADDQ	#1,D0
	MOVE	D0,D1
	ASR	#4,D0
;	ADD	D0,D0
	ASL	#3,D0
	ADDA	D0,A1
	MOVEQ	#$F,D2
	AND	D2,D1
	SUB	D1,D2
	SWAP	D2
	LEA	BUFFER1,A3
	MOVE	L154(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LB0
	NEG	D0
LB0:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1,A4
	MOVE	L158(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LB1
	NEG	D0
LB1:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A5
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LB2
	NEG	D0
LB2:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	LEA	BUFFER1+$9600,A6
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LB3
	NEG	D0
LB3:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	CMPA.L	A3,A4
	BLT	L9B
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.L	A2,D5
	MOVE.L	A2,D6
	MOVE.L	#$4A004A,D0
	MOVE.L	#$4A004A,D1
LB4:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	LC3
	TST.L	D6
	BGT.S	LB4
	MOVEQ	#$4A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L152(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LB5
	NEG	D0
LB5:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LB6
	NEG	D0
LB6:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
LB7:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	LBE
	TST.L	D6
	BGT.S	LB7
	MOVEQ	#0,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LB8
	NEG	D0
LB8:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LB9
	NEG	D0
LB9:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
LBA:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	CMP.L	A2,D6
	BCS.S	LBA
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LBB:	MOVEQ	#$4A,D1
	MOVE.L	A2,D6
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L152(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LBC
	NEG	D0
LBC:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LBD
	NEG	D0
LBD:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	BRA.S	LBF
LBE:	MOVE.L	A2,D0
	TST.L	D6
	BLE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
LBF:	LEA	BUFFER1,A3
	MOVE	L152(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LC0
	NEG	D0
LC0:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LC1
	NEG	D0
LC1:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
LC2:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	TST.L	D6
	BGT.S	LC2
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LC3:	MOVE.L	A2,D0
	TST.L	D6
	BLE	LBB
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L152(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LC4
	NEG	D0
LC4:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LC5
	NEG	D0
LC5:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
LC6:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	LCA
	TST.L	D6
	BGT.S	LC6
	MOVEQ	#$4A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L152(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LC7
	NEG	D0
LC7:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LC8
	NEG	D0
LC8:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
LC9:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	TST.L	D6
	BGT.S	LC9
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LCA:	MOVEQ	#0,D0
	TST.L	D6
	BLE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L158(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LCB
	NEG	D0
LCB:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LCC
	NEG	D0
LCC:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LCD:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	TST.L	D6
	BGT.S	LCD
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LCE:	CMP	D2,D6
	BNE	LED
	MOVE	L155(PC),D0
	MULS	D7,D0
	ADDA	D0,A1
	MOVE	L154(PC),D0
	ADDQ	#1,D0
	MOVE	D0,D1
	ASR	#4,D0
;	ADD	D0,D0
	ASL	#3,D0
	ADDA	D0,A1
	MOVEQ	#$F,D2
	AND	D2,D1
	SUB	D1,D2
	SWAP	D2
	LEA	BUFFER1,A3
	MOVE	L152(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LCF
	NEG	D0
LCF:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1,A4
	MOVE	L156(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LD0
	NEG	D0
LD0:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A5
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	LD1
	NEG	D0
LD1:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	LEA	BUFFER1+$9600,A6
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LD2
	NEG	D0
LD2:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	CMPA.L	A3,A4
	BLT	L9B
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.L	A2,D5
	MOVEQ	#0,D6
	MOVE.L	A2,D0
	MOVE.L	A2,D1
LD3:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	LE2
	CMP.L	A2,D6
	BCS.S	LD3
	MOVE.L	#$4A004A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L158(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LD4
	NEG	D0
LD4:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LD5
	NEG	D0
LD5:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
LD6:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	LDD
	TST.L	D6
	BGT.S	LD6
	MOVEQ	#$4A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L152(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LD7
	NEG	D0
LD7:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LD8
	NEG	D0
LD8:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
LD9:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	TST.L	D6
	BGT.S	LD9
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LDA:	MOVE.L	#$4A004A,D1
	MOVE.L	A2,D6
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L158(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LDB
	NEG	D0
LDB:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LDC
	NEG	D0
LDC:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	BRA.S	LDE
LDD:	MOVEQ	#0,D0
	TST.L	D6
	BLE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
LDE:	LEA	BUFFER1,A3
	MOVE	L158(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LDF
	NEG	D0
LDF:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LE0
	NEG	D0
LE0:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LE1:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	TST.L	D6
	BGT.S	LE1
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LE2:	MOVEQ	#0,D0
	CMP.L	A2,D6
	BGE	LDA
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L158(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LE3
	NEG	D0
LE3:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L159(PC),D0
	SUB	L153(PC),D0
	BPL.S	LE4
	NEG	D0
LE4:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LE5:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	LE9
	CMP.L	A2,D6
	BCS.S	LE5
	MOVE.L	#$4A004A,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L158(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LE6
	NEG	D0
LE6:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L159(PC),D0
	SUB	L157(PC),D0
	BPL.S	LE7
	NEG	D0
LE7:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVE.L	A2,D6
	MOVEM.L	(A7)+,D5/D0-D1
LE8:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	TST.L	D6
	BGT.S	LE8
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LE9:	MOVEQ	#$4A,D0
	CMP.L	A2,D6
	BGE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L156(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LEA
	NEG	D0
LEA:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LEB
	NEG	D0
LEB:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVEQ	#0,D5
	MOVEM.L	(A7)+,D6/D0-D1
LEC:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	CMP.L	A2,D6
	BCS.S	LEC
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LED:	MOVE	L159(PC),D0
	MULS	D7,D0
	ADDA	D0,A1
	MOVE	L158(PC),D0
	ADDQ	#1,D0
	MOVE	D0,D1
	ASR	#4,D0
;	ADD	D0,D0
	ASL	#3,D0
	ADDA	D0,A1
	MOVEQ	#$F,D2
	AND	D2,D1
	SUB	D1,D2
	SWAP	D2
	LEA	BUFFER1,A3
	MOVE	L156(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LEE
	NEG	D0
LEE:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1,A4
	MOVE	L152(PC),D1
	SUB	L158(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LEF
	NEG	D0
LEF:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A5
	MOVE	L157(PC),D0
	SUB	L159(PC),D0
	BPL.S	LF0
	NEG	D0
LF0:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	LEA	BUFFER1+$9600,A6
	MOVE	L153(PC),D0
	SUB	L159(PC),D0
	BPL.S	LF1
	NEG	D0
LF1:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	CMPA.L	A3,A4
	BLT	L9B
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVE.L	A2,D6
	MOVEQ	#$4A,D0
	MOVEQ	#$4A,D1
LF2:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L101
	TST.L	D6
	BGT.S	LF2
	MOVEQ	#0,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LF3
	NEG	D0
LF3:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LF4
	NEG	D0
LF4:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
LF5:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	LFC
	CMP.L	A2,D6
	BCS.S	LF5
	MOVE.L	A2,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L156(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LF6
	NEG	D0
LF6:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L157(PC),D0
	SUB	L155(PC),D0
	BPL.S	LF7
	NEG	D0
LF7:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
LF8:	BSR	L10C
	ADD.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	CMP.L	A2,D5
	BGE	L9B
	CMP.L	A2,D6
	BCS.S	LF8
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
LF9:	MOVEQ	#0,D1
	MOVEQ	#0,D6
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LFA
	NEG	D0
LFA:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	LFB
	NEG	D0
LFB:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	BRA.S	LFD
LFC:	MOVE.L	#$4A004A,D0
	CMP.L	A2,D6
	BGE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
LFD:	LEA	BUFFER1,A3
	MOVE	L154(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LFE
	NEG	D0
LFE:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	LFF
	NEG	D0
LFF:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
L100:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	CMP.L	A2,D6
	BCS.S	L100
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L101:	MOVE.L	#$4A004A,D0
	TST.L	D6
	BLE	LF9
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L154(PC),D1
	SUB	L156(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	L102
	NEG	D0
L102:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L155(PC),D0
	SUB	L157(PC),D0
	BPL.S	L103
	NEG	D0
L103:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
L104:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	L108
	TST.L	D6
	BGT.S	L104
	MOVEQ	#0,D1
	MOVEM.L	D5/D0-D1,-(A7)
	LEA	BUFFER1,A4
	MOVE	L154(PC),D1
	SUB	L152(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A4
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	L105
	NEG	D0
L105:	ADD	D0,D0
	MOVE	0(A4,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A4
	LEA	BUFFER1+$9600,A6
	MOVE	L155(PC),D0
	SUB	L153(PC),D0
	BPL.S	L106
	NEG	D0
L106:	ADD	D0,D0
	MOVE	0(A6,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A6
	MOVEQ	#0,D4
	MOVEQ	#0,D6
	MOVEM.L	(A7)+,D5/D0-D1
L107:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	MOVE	D5,D0
	SWAP	D5
	ADD.L	A6,D6
	SWAP	D6
	SWAP	D1
	MOVE	D6,D1
	SWAP	D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	CMP.L	A2,D6
	BCS.S	L107
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L108:	MOVE.L	A2,D0
	TST.L	D6
	BLE	L9B
	MOVEM.L	D6/D0-D1,-(A7)
	LEA	BUFFER1,A3
	MOVE	L152(PC),D1
	SUB	L154(PC),D1
	EXT.L	D1
	MOVEQ	#9,D0
	LSL.L	D0,D1
	ADDA.L	D1,A3
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	L109
	NEG	D0
L109:	ADD	D0,D0
	MOVE	0(A3,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A3
	LEA	BUFFER1+$9600,A5
	MOVE	L153(PC),D0
	SUB	L155(PC),D0
	BPL.S	L10A
	NEG	D0
L10A:	ADD	D0,D0
	MOVE	0(A5,D0.W),D1
	EXT.L	D1
	LSL.L	#8,D1
	MOVE.L	D1,A5
	MOVEQ	#0,D3
	MOVE.L	A2,D5
	MOVEM.L	(A7)+,D6/D0-D1
L10B:	BSR	L10C
	SUB.L	A5,D5
	SWAP	D5
	SWAP	D0
	MOVE	D5,D0
	SWAP	D0
	SWAP	D5
	SUB.L	A6,D6
	SWAP	D6
	MOVE	D6,D1
	SWAP	D6
	TST.L	D5
	BLE	L9B
	TST.L	D6
	BGT.S	L10B
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L10C:	MOVEM.L	A0-A6/D0-D7,-(A7)
	SUBQ	#1,D2
	MOVE.L	L10D(PC),A2
	JSR	(A2)
	MOVEM.L	(A7)+,A0-A6/D0-D7

;	ASL	#3,D7
	ADDA	D7,A1
;	ASR	#3,D7

;	LEA	-160*4(A1),A1

	ADD.L	A3,D3
	ADD.L	A4,D4
	SWAP	D3
	SWAP	D4
	SUB	D3,D2
	ADD	D4,D2
	SWAP	D2
	SUB	D3,D2
	MOVE	D2,D3
	AND	#$F,D2
	SUB	D2,D3

	AND	#-16,D3
	ASR	#1,D3

	SUB	D3,A1
	SWAP	D2
	CLR	D3
	CLR	D4
	SWAP	D3
	SWAP	D4
	RTS
L10D:	DS.W	2

;
; 4 PLANS
;
L10E:
	IFEQ	CPU
	ADDQ	#7,$FFFF8240.W
	ENDC
	MOVE	D2,D7
	BMI	L116
	ADDQ	#1,D2
	MOVE	D1,D4
	SUB	D0,D4
	MOVE	D0,D3
	LSL	#8,D3
	SWAP	D0
	ADD	D0,D3
	ADDA	D3,A0
	SWAP	D1
	MOVE	D1,D5
	SUB	D0,D5
	EXT.L	D4
	EXT.L	D5
	MOVEQ	#9,D0
	LSL.L	D0,D4
	LSL.L	D0,D5
	LEA	BUFFER1,A2
	MOVE.L	A2,A3
	ADDA.L	D4,A2
	ADDA.L	D5,A3
	ADD	D2,D2
	MOVE	0(A2,D2.W),A2
	MOVE	0(A3,D2.W),D5
	ROR	#8,D5
	MOVE	D5,A6

	MOVEQ	#0,D4
	MOVEQ	#0,D5
	SWAP	D2
	SUB	D2,D7
	BPL.S	L10F
	MOVE	D7,D0
	ADD	D2,D0
	NEG	D7
	SWAP	D7
	MOVE	D0,D7
	BRA	L113
L10F:	SWAP	D7
	MOVE	D2,D7
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
L110:
	MOVEQ	#0,D6
	ADD	A6,D4
	ADDX	D6,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
	ADD.B	D6,D6
	ADDX	D3,D3
	DBF	D7,L110

	OR	D0,(A1)+
	OR	D1,(A1)+
	OR	D2,(A1)+
	OR	D3,(A1)+

	SWAP	D7
	MOVE	D7,D0
	BEQ	L116
	AND	#$F,D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7
	LSR	#4,D7

	BRA	L112
L111:
	REPT	16
	MOVEQ	#0,D6
	ADD	A6,D4
	ADDX	D6,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
	ADD.B	D6,D6
	ADDX	D3,D3
	ENDR

	MOVEM	D0-D3,(A1)
	ADDQ	#8,A1
L112:
	DBF	D7,L111
	SWAP	D7
	MOVE	D7,D0
	MOVEQ	#$10,D0
	SUB	D7,D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7

L113:
	MOVEQ	#0,D0		;OBLIGATOIRE
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	BRA.S	L115
L114:
	MOVEQ	#0,D6
	ADD	A6,D4
	ADDX	D6,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
	ADD.B	D6,D6
	ADDX	D3,D3
L115:	DBF	D7,L114
	SWAP	D7
	LSL	D7,D0
	LSL	D7,D1
	LSL	D7,D2
	LSL	D7,D3
	OR	D0,(A1)+
	OR	D1,(A1)+
	OR	D2,(A1)+
	OR	D3,(A1)+

L116:	RTS

;
; 3 PLANS
;
L117:	MOVE	D2,D7
	BMI	L11F
	ADDQ	#1,D2
	MOVE	D1,D4
	SUB	D0,D4
	MOVE	D0,D3
	LSL	#8,D3
	SWAP	D0
	ADD	D0,D3
	ADDA	D3,A0
	SWAP	D1
	MOVE	D1,D5
	SUB	D0,D5
	EXT.L	D4
	EXT.L	D5
	MOVEQ	#9,D0
	LSL.L	D0,D4
	LSL.L	D0,D5
	LEA	BUFFER1,A2
	MOVE.L	A2,A3
	ADDA.L	D4,A2
	ADDA.L	D5,A3
	ADD	D2,D2
	MOVE	0(A2,D2.W),A2
	MOVE	0(A3,D2.W),D5
	ROR	#8,D5
	MOVE	D5,A6

	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	SWAP	D2
	SUB	D2,D7
	BPL.S	L118
	MOVE	D7,D0
	ADD	D2,D0
	NEG	D7
	SWAP	D7
	MOVE	D0,D7
	BRA	L11C
L118:	SWAP	D7
	MOVE	D2,D7
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
L119:
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
	DBF	D7,L119

	OR	D0,(A1)+
	OR	D1,(A1)+
	OR	D2,(A1)+
	ADDQ	#2,A1

	SWAP	D7
	MOVE	D7,D0
	BEQ	L11F
	AND	#$F,D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7
	LSR	#4,D7
	BRA	L11B
L11A:
	REPT	16
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
	ENDR

	MOVEM	D0-D2,(A1)
	ADDQ	#8,A1

L11B:
	DBF	D7,L11A
	SWAP	D7
	MOVE	D7,D0
	SUB	#$10,D0
	NEG	D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7
L11C:
	MOVEQ	#0,D0		;OBLIGATOIRE
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	BRA.S	L11E
L11D:
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ADD.B	D6,D6
	ADDX	D2,D2
L11E:	DBF	D7,L11D
	SWAP	D7
	LSL	D7,D0
	LSL	D7,D1
	LSL	D7,D2

	OR	D0,(A1)+
	OR	D1,(A1)+
	OR	D2,(A1)+

L11F:	RTS

;
; 2 PLANS
;

L120:	MOVE	D2,D7
	BMI	L128
	ADDQ	#1,D2
	MOVE	D1,D4
	SUB	D0,D4
	MOVE	D0,D3
	LSL	#8,D3
	SWAP	D0
	ADD	D0,D3
	ADDA	D3,A0
	SWAP	D1
	MOVE	D1,D5
	SUB	D0,D5
	EXT.L	D4
	EXT.L	D5
	MOVEQ	#9,D0
	LSL.L	D0,D4
	LSL.L	D0,D5
	LEA	BUFFER1,A2
	MOVE.L	A2,A3
	ADDA.L	D4,A2
	ADDA.L	D5,A3
	ADD	D2,D2
	MOVE	0(A2,D2.W),A2
	MOVE	0(A3,D2.W),D5
	ROR	#8,D5
	MOVE	D5,A6

	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	SWAP	D2
	SUB	D2,D7
	BPL.S	L121
	MOVE	D7,D0
	ADD	D2,D0
	NEG	D7
	SWAP	D7
	MOVE	D0,D7
	BRA	L125
L121:	SWAP	D7
	MOVE	D2,D7
	MOVEQ	#0,D0
	MOVEQ	#0,D1
L122:
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	DBF	D7,L122
	OR	D0,(A1)+
	OR	D1,(A1)+
	ADDQ	#4,A1

	SWAP	D7
	MOVE	D7,D0
	BEQ	L128
	AND	#$F,D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7
	LSR	#4,D7
	BRA	L124
L123:
	REPT	16
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
	ENDR

	MOVE	D0,(A1)+
	MOVE	D1,(A1)+
	ADDQ	#4,A1

L124:
	DBF	D7,L123
	SWAP	D7
	MOVE	D7,D0
	SUB	#$10,D0
	NEG	D0
	SWAP	D7
	MOVE	D0,D7
	SWAP	D7
L125:
	MOVEQ	#0,D0		;OBLIGATOIRE
	MOVEQ	#0,D1
	BRA.S	L127
L126:
	ADD	A6,D4
	ADDX	D3,D4
	ADD	A2,D5

	MOVE	D5,D6
	MOVE.B	D4,D6

	MOVE.B	0(A0,D6.W),D6
	ADD.B	D6,D6
	ADDX	D0,D0
	ADD.B	D6,D6
	ADDX	D1,D1
L127:	DBF	D7,L126
	SWAP	D7
	LSL	D7,D0
	LSL	D7,D1

	OR	D0,(A1)+
	OR	D1,(A1)+

L128:	RTS
L129:	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE.L	A0,A3
	LEA	BUFFER3,A1
	MOVE.L	A1,A4
	MOVEQ	#$4A,D7
L12A:	MOVE.L	A1,A5
	LEA	2250(A0),A2
	MOVEQ	#7,D2
	MOVEQ	#$4A,D6
L12B:	MOVEQ	#0,D1
	MOVEQ	#3,D5
L12C:	ADD.B	D1,D1
	BTST	D2,(A2)
	BEQ.S	L12D
	ADDQ.B	#1,D1
L12D:	SUBA	#$2EE,A2
	DBF	D5,L12C
	ADDA	#$BB8,A2
	SUBQ.B	#2,D1
	MOVE.B	D1,(A5)+
	SUBQ.B	#1,D2
	BPL.S	L12E
	ADDQ	#1,A2
	MOVEQ	#7,D2
L12E:	DBF	D6,L12B
	ADDA	#$100,A1
	ADDA	#$A,A0
	DBF	D7,L12A
	MOVEQ	#$4A,D7
L12F:	MOVE.L	A4,A5
	ADDA	#$100,A4
	MOVEQ	#$25,D6
L130:	MOVE.B	(A5)+,D0
	LSL.B	#4,D0
	OR.B	(A5)+,D0
	MOVE.B	D0,(A3)+
	DBF	D6,L130
	DBF	D7,L12F
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L133:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L25A,A2
	SUBQ	#8,D0
	BMI.S	L134
	LEA	L25B,A2
	SUBQ	#8,D0
	BMI.S	L134
	LEA	L25C,A2
L134:	MOVEQ	#$4A,D7
L135:	MOVE.L	A1,A3
	MOVEQ	#$25,D6
L136:	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD	D0,D0
	MOVE	0(A2,D0.W),(A3)+
	DBF	D6,L136
	ADDA	#$100,A1
	DBF	D7,L135
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L137:	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE	D1,D2
	CMPI	#6,D2
	BNE.S	L138
	SUBQ	#1,D2
L138:	LEA	L250(PC),A2
	LSL	#4,D2
	ADDA	D2,A2
	LEA	BUFFER3,A3
	LSL	#2,D1
	ADDA.L	L13B(PC,D1.W),A3
	MOVE.L	A3,(A2)+
	MOVE.L	A0,(A2)+
	LEA	L120(PC),A0
	MOVE	D0,(A2)
	BEQ.S	L139
	LEA	L117(PC),A0
	SUBQ	#1,D0
	BEQ.S	L139
	LEA	L10E(PC),A0
L139:	TST	(A2)
	BNE.S	L13A
	ADDQ	#1,(A2)
L13A:	ADDQ	#2,A2
	MOVE.L	A0,(A2)+
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L13B:	DS.W	3
	DC.B	$00,'P',$00,$00,'K',$00,$00,$00
	DC.B	'KP',$00,$00,$96,$00,$00,$00
	DC.B	$96,'P',$00,$00,$96,'P'
L13C:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L258(PC),A2
	LEA	BUFFER3,A3
	LEA	L24C(PC),A5
	LEA	L24D(PC),A6
	MOVEQ	#0,D2
	MOVEQ	#4,D7
	MOVEQ	#0,D6
L13D:	MOVE	(A2)+,D3
	MOVE.B	(A5)+,D0
	CMP.B	(A6)+,D0
	BEQ.S	L13E
	MOVE.B	D0,-1(A6)
	LEA	L254(PC),A4
	EXT	D0
	LSL	#3,D0
	ADDA	D0,A4
	MOVE.L	(A4)+,A0
	MOVE.L	A3,A1
	MOVE	D3,D0
	BSR	L133
	MOVE.L	(A4),A0
	MOVE	D3,D0
	MOVE	D2,D1
	BSR	L137
L13E:	ADDQ	#1,D2
	NOT.B	D6
	BNE.S	L13F
	ADDA	#$4A60,A3
L13F:	ADDA	#$50,A3
	DBF	D7,L13D
	MOVE.B	L21F(PC),D0
	BNE.S	L140
	MOVE	(A2)+,D3
	MOVE.B	(A5)+,D0
	CMP.B	(A6)+,D0
	BEQ.S	L140
	MOVE.B	D0,-1(A6)
	LEA	L254(PC),A4
	EXT	D0
	LSL	#3,D0
	ADDA	D0,A4
	MOVE.L	(A4)+,A2
	MOVE.L	A2,A0
	MOVE.L	A3,A1
	MOVE	D3,D0
	BSR	L133
	MOVE.L	(A4)+,A0
	MOVE	D2,D1
	MOVE	D3,D0
	BSR	L137
L140:	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L141:	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE.B	L21E(PC),D0
	LEA	L21F(PC),A0
	CMP.B	(A0),D0
	BEQ.S	L145
	TST.B	D0
	BNE.S	L144
	MOVE.B	D0,(A0)
	LEA	L24E(PC),A1
	ST	(A1)
	LEA	BUFFER3+$9650,A0
	MOVEQ	#$4A,D7
L142:	MOVE.L	A0,A1
	MOVEQ	#$4B,D6
L143:	CLR	(A1)+
	DBF	D6,L143
	ADDA	#$100,A0
	DBF	D7,L142
	LEA	L253(PC),A0
	CLR	(A0)
	BRA.S	L145
L144:	LEA	L229(PC),A0
	MOVEQ	#0,D0
	MOVEQ	#6,D1
	BSR	L137
	LEA	BUFFER3+$9650,A1
	LEA	L23E(PC),A0
	MOVE.L	A1,(A0)
	LEA	L225(PC),A0
	BSR	L1BD
	LEA	L23D(PC),A1
	MOVE.L	L23C(PC),(A1)
	LEA	L241(PC),A1
	CLR.L	(A1)
	LEA	L240(PC),A1
	CLR	(A1)
	LEA	L214(PC),A1
	MOVE	#1,(A1)
	LEA	L21F(PC),A0
	MOVE.B	L21E(PC),(A0)
L145:	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L146:	LEA	L185(PC),A0
	LEA	L186(PC),A1
	MOVEQ	#5,D7
L147:	MOVE.B	(A1)+,D0
	EXT	D0
	LSL	#5,D0
	ADD	(A0)+,D0
	CMPI	#$3E0,D0
	BHI.S	L148
	MOVE	D0,-2(A0)
	DBF	D7,L147
	RTS
L148:
	BSET	#5,L23A
	CLR.B	-1(A1)
	DBF	D7,L147
	RTS
L152:	DC.B	$00,'u'
L153:	DC.W	$54
L154:	DC.B	$00,$CB
L155:	DC.B	$00,'U'
L156:	DC.B	$00,$CA
L157:	DC.B	$00,$AA
L158:	DC.B	$00,'u'
L159:	DC.B	$00,$AA
;
; ROUTINE SOURIS
;
L15A:	LEA	L17A(PC),A0
	LEA	L189(PC),A2

	move	mousex,d0
	bsr	L15B
	move	mousey,d0
	bsr	L15B
	rts
L15B:
	MOVE.B	(A2),D1
	MOVE.B	D0,(A2)+
	SUB.B	D1,D0
	EXT	D0
	ADD	D0,D0
	ADD	D0,(A0)
	ANDI	#$3FF,(A0)
	ADDQ	#2,A0
	RTS


L15C:	MOVE.B	(A1)+,D0
	MOVE.B	(A2),D1
	MOVE.B	D0,(A2)+
	SUB.B	D1,D0
	EXT	D0
	LEA	L184(PC),A0
	ADD	(A0),D0
	BMI.S	L15D
	MOVE	D0,(A0)
L15D:	LEA	L17B(PC),A0
	MOVE.B	(A1)+,D0
	MOVE.B	(A2),D1
	MOVE.B	D0,(A2)+
	SUB.B	D1,D0
	EXT	D0
	ADD	D0,D0
	ADD	D0,(A0)
	ANDI	#$3FF,(A0)
	RTS



L164:	MOVEM.L	A0-A6/D0-D7,-(A7)
	BSR.S	L16A
	LEA	L172(PC),A0
	LEA	L18B(PC),A1
	LEA	L18A(PC),A3
	MOVEQ	#7,D7
L165:	MOVEM	(A0)+,D0-D2
	BSR.S	L166
	DBF	D7,L165
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L166:	LEA	L179(PC),A2
	MOVEQ	#2,D6
L167:	MOVEQ	#0,D3
	MOVEQ	#2,D5
L168:	MOVE	D0,D4
	EXG	D1,D0
	EXG	D2,D1
	MULS	(A2)+,D4
	ADD	D4,D3
	DBF	D5,L168
	MOVE	D3,(A3)+
	DBF	D6,L167
	MOVEM	-6(A3),D0-D2
	EXT.L	D1
	EXT.L	D2
	MOVEQ	#0,D4
	MOVE	#$104,D4
	ASR	#8,D0
	ADD	D4,D0
	ADD	L184(PC),D0
	DIVS	D0,D1
	DIVS	D0,D2
	ASR	#1,D2
	ASR	#1,D1
	ADD	#XMILIEU,D2
	ADD	#YMILIEU,D1
	MOVE	D2,(A1)+
	MOVE	D1,(A1)+
	ADDQ	#2,A1
	RTS
L16A:	LEA	L175(PC),A0
	LEA	L17A(PC),A1
	LEA	L170(PC),A2
	BSR.S	L16F
	BSR.S	L16F
	BSR.S	L16F
	LEA	L177(PC),A0
	LEA	L176(PC),A1
	LEA	L178(PC),A2
	BSR.S	L16B
	LEA	L174(PC),A1
L16B:	MOVEQ	#2,D5
L16C:	MOVEQ	#2,D6
L16D:	MOVE.L	A0,A3
	MOVE.L	A1,A4
	MOVEQ	#0,D0
	MOVEQ	#2,D7
L16E:	MOVE	(A3)+,D1
	MULS	(A4),D1
	ADD.L	D1,D0
	ADDQ.L	#6,A4
	DBF	D7,L16E
	ASR.L	#8,D0
	MOVE	D0,(A2)+
	ADDQ.L	#2,A1
	DBF	D6,L16D
	SUBQ.L	#6,A1
	ADDQ.L	#6,A0
	DBF	D5,L16C
	RTS
L16F:	MOVEM	(A2)+,D4-D7
	MOVE	(A1)+,D0
	ADD	D0,D0
	MOVE	L171(PC,D0.W),D1
	ADD	#$200,D0
	MOVE	L171(PC,D0.W),D0
	ST	(A0)
	MOVE	D0,-1(A0,D4.W)
	MOVE	D0,-1(A0,D5.W)
	MOVE	D1,-1(A0,D6.W)
	NEG	D1
	MOVE	D1,-1(A0,D7.W)
	ADDA	#$1A,A0
	RTS
L170:	DC.B	$00,$08,$00,$10,$00,$0E,$00,$0A
	DC.B	$FF,$F8,$00,$08,$FF,$FC,$00,$04
	DC.B	$FF,$F0,$FF,$F8,$FF,$F6,$FF,$F2
L171:
	INCBIN	SINUS.TAB
L172:	DC.B	$FF,$C4,$FF,$C4,$00,'<',$00,'<'
	DC.B	$FF,$C4,$00,'<',$00,'<',$00,'<'
	DC.B	$00,'<',$FF,$C4,$00,'<',$00,'<'
	DC.B	$FF,$C4,$FF,$C4,$FF,$C4,$00,'<'
	DC.B	$FF,$C4,$FF,$C4,$00,'<',$00,'<'
	DC.B	$FF,$C4,$FF,$C4,$00,'<',$FF,$C4
L173:	DC.B	$00,$18,$00,$00,$00,$06,$00,$0C
	DC.B	$00,$12,$00,$0C,$00,$06,$00,$00
	DC.B	$00,$18,$00,$1E,$00,$12,$00,$0C
	DC.B	$00,$06,$00,$1E,$00,'$',$00,$00
	DC.B	$00,$12,$00,$0C,$00,'$',$00,'*'
	DC.B	$00,$06,$00,$00,$00,$12,$00,'*'
	DC.B	$00,$18,$00,$12,$00,'*',$00,'$'
	DC.B	$00,$1E,$00,$18
L174:	DC.B	$00
L175:	DC.B	$00,$00,$00,$00,$00,$00,$00,$00,$00
	DS.W	4
L176:	DS.W	9
L177:	DS.W	9
L178:	DS.W	9
L179:	DS.W	9
L17A:	DS.W	2
L17B:	DC.B	$00,$FF
L17C:	DS.W	1
L17D:	DS.W	1
L17E:	DS.W	1
L17F:	DS.W	1
L180:	DS.W	1
L181:	DS.W	1
L182:	DS.W	1
L183:	DS.W	1

L184:	DC.B	$08,$00
L185:	DCB.W	6,$03E0
L186:	DS.B	6
L187:	DS.B	6
L188:	DS.B	6

L189:	DS.W	1
L18A:	DS.W	30
L18B:	DS.W	30
;
; VECTEUR D'INTERRUPTION
;
INTERRUPTION:
	MOVEM.L	A0-A6/D0-D7,-(A7)

	move.b	#$0d,$fffffc02.w ; Ask for mouse position

	MOVE.B	L208,D2
	BEQ.S	L19D
	CLR.B	L208
	BSET	#7,L23A
L19D:
	BSR	L1A4
	BSR	L1C4
	MOVE.L	L218,D0
	BEQ	L18D
	CLR.L	L218
	MOVE.L	D0,A0
;
; EFFACEMENT DE L'ECRAN
;
;	MOVE	#32000/4-1,D0
;	MOVEQ	#0,D1
;.CLS	MOVE.L	D1,(A0)+
;	DBRA	D0,.CLS


	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,D7
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	MOVE.L	D0,A5
	MOVE.L	D0,A6

X	SET	44*160+XGAUCHE
	REPT	112
	MOVEM.L	D0-D7/A1-A6,X(A0)
X	SET	X+160
	ENDR

;	ILLEGAL
	IFEQ	1
	LEA	$00DFF000,A5
	MOVEQ	#0,D0
;WAIT BLITTER
	MOVE.L	#$1000000,64(A5)
	MOVE	D0,102(A5)
	MOVE.L	A0,84(A5)
	MOVE	#$7D14,88(A5)
	ENDC

L18D:	MOVE.B	L236(PC),D0
	BEQ.S	L18E
	BSR	L15A
L18E:	LEA	L17A(PC),A0
	LEA	L17C(PC),A1
	LEA	L17F(PC),A2
	MOVE	#$3FF,D1
	MOVEQ	#0,D3
	MOVEQ	#2,D7
L18F:	MOVE	(A1)+,D0
	ADD	(A0),D0
	AND	D1,D0
	MOVE	(A2)+,D2
	BMI.S	L190
	BSET	D7,D3
	CMP	(A0),D2
	BNE.S	L190
	BSET	#8,D3
	BCLR	D7,D3
	CLR	-2(A1)
	ST	-2(A2)
	MOVE	D2,D0
L190:	MOVE	D0,(A0)+
	DBF	D7,L18F
	TST	D3
	BEQ.S	L191
	TST.B	D3
	BNE.S	L191
	BSET	#6,L23A
L191:	LEA	L182(PC),A0
	MOVE	(A0),D0
	BEQ.S	L194
	LEA	L184(PC),A1
	MOVE	(A1),D1
	ADD	(A1),D0
	BMI.S	L192
	SUB	L183(PC),D1
	BEQ.S	L192
	MOVE	D0,D2
	SUB	L183(PC),D2
	EOR	D2,D1
	BPL.S	L193
L192:	CLR	(A0)
	BRA.S	L194
L193:	MOVE	D0,(A1)
L194:	MOVE.B	L21F(PC),D0
	BEQ.S	L195
	LEA	L215(PC),A0
	SUBQ	#1,(A0)
	BPL.S	L195
	MOVE	L214(PC),(A0)
	BSR	L1DE
L195:	MOVE.B	L7F(PC),D0
	BMI.S	L196
	BSR	L7C
L196:	LEA	L84(PC),A2
	MOVEQ	#5,D7
L197:	MOVE.B	(A2)+,D0
	BEQ.S	L198
	MOVEQ	#5,D1
	SUB	D7,D1
	BSR	L82
L198:	DBF	D7,L197
	LEA	L21D(PC),A0
	ADDQ.B	#1,(A0)
L199:
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS

L1A4:	LEA	L187(PC),A0
	LEA	L252(PC),A1
	LEA	L188(PC),A3
	MOVEQ	#5,D7
L1A5:	MOVE.B	(A0)+,D0
	TST.B	(A3)+
	BEQ.S	L1A7
	EXT	D0
	ADD	(A1),D0
	SUBQ.B	#1,-1(A3)
	BNE.S	L1A6
	BSET	#4,L23A
	BRA.S	L1A7
L1A6:	MOVE	D0,(A1)
L1A7:	LEA	$10(A1),A1
	DBF	D7,L1A5
	RTS

L1B1:	DS.W	1

L1BD:	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE.L	A1,A5
	MOVEQ	#$18,D7
L1BE:	MOVE.L	A0,A2
	LEA	100(A2),A3
	MOVE.B	(A2)+,D0
	MOVE.B	(A3)+,D1
	MOVEQ	#7,D5
	MOVE.L	A1,A4
	MOVEQ	#$18,D6
L1BF:	MOVEQ	#0,D2
	ADD.B	D0,D0
	ADDX.B	D2,D2
	ADD.B	D1,D1
	ADDX.B	D2,D2
	ROR.B	#2,D2
	MOVE.B	D2,(A4)+
	SUBQ.B	#1,D5
	BPL.S	L1C0
	MOVE.B	(A2)+,D0
	MOVE.B	(A3)+,D1
	MOVEQ	#7,D5
L1C0:	DBF	D6,L1BF
	MOVE.L	A1,A2
	MOVEQ	#$7D,D5
L1C1:	MOVE.B	(A2)+,24(A2)
	DBF	D5,L1C1
	ADDA	#$100,A1
	ADDA	#4,A0
	DBF	D7,L1BE
	MOVEQ	#$31,D7
L1C2:	MOVE	#$95,D6
L1C3:	MOVE.B	(A5)+,(A1)+
	DBF	D6,L1C3
	ADDA	#$6A,A1
	ADDA	#$6A,A5
	DBF	D7,L1C2
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L1C4:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L239(PC),A0
	LEA	L23A(PC),A1
	MOVE.B	(A0),D0
	MOVE.B	(A1),D1
	NOT.B	D0
	AND.B	D0,D1
	OR.B	(A1),D0
	NOT.B	D0
	MOVE.B	D1,(A1)
	MOVE.B	D0,(A0)
	BNE	L1CD
	MOVE.B	L235(PC),D0
	BNE	L1CD
	LEA	L234(PC),A0
	TST	(A0)
	BEQ.S	L1C5
	SUBQ	#1,(A0)
	BRA	L1CD
L1C5:	LEA	L22D(PC),A0
	LEA	L233(PC),A1
	MOVE.L	(A0),A2
	LEA	L231(PC),A4
	ADDQ	#2,(A1)+
	MOVE	(A1),D0
	CMP	-(A1),D0
	BHI	L1C8
L1C6:	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	BMI	L1CE
	LSL	#3,D0
	LEA	L227(PC),A3
	ADDA	D0,A3
	MOVE.L	(A3)+,(A4)
	CLR	(A1)+
	MOVE	(A3)+,(A1)
	SUBQ	#2,A1

	IFEQ	1
;
; QU'EST-CE QUE C'EST QUE CE BORDEL ???
;
; COPIE BLITTER
;
; C'EST SUREMENT LE SCROLLING DU BAS
;  RAFRAICHISSEMENT DU SCROLLING DU BAS
;
;	A1=(A4)=SOURCE
;	A=DESTINATION
;
	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	$00DFF000,A5
	LEA	BUFFER6,A0
	MOVE	L232(PC),D0
	MOVE	D0,D1
	AND	#$F,D1
	LSR	#3,D0
	BCLR	#0,D0
	ADDA	D0,A0
	MOVE	#$5E,D2
	ROR	#4,D1
	MOVE	D1,D3
	OR	#$7CA,D3
	MOVEQ	#-1,D4
	MOVEQ	#0,D5
	MOVE	#$1703,D6
	MOVE.L	(A4),A1
	MOVE	#-2,D7
;WAIT BLITTER
	MOVE.L	A1,76(A5)
	MOVE.L	A0,72(A5)
	MOVE.L	A0,84(A5)
	MOVE	D4,68(A5)
	MOVE	D7,98(A5)
	MOVE	D2,96(A5)
	MOVE	D2,102(A5)
	MOVE	D1,66(A5)
	MOVE	D3,64(A5)
	MOVE	D4,116(A5)
	MOVE	D5,70(A5)
	MOVE	D6,88(A5)
	ADDA	#$30,A0
;WAIT BLITTER
	MOVE.L	A1,76(A5)
	MOVE.L	A0,72(A5)
	MOVE.L	A0,84(A5)
	MOVE	D4,68(A5)
	MOVE	D7,98(A5)
	MOVE	D2,96(A5)
	MOVE	D2,102(A5)
	MOVE	D1,66(A5)
	MOVE	D3,64(A5)
	MOVE	D4,116(A5)
	MOVE	D5,70(A5)
	MOVE	D6,88(A5)
	MOVEM.L	(A7)+,A0-A6/D0-D7
	ENDC

	TST.B	(A2)
	BNE.S	L1C7
	MOVE.L	L22C(PC),A2
L1C7:	MOVE.L	A2,(A0)
L1C8:	LEA	L22E(PC),A0
	MOVE	(A0),D0
	BEQ.S	L1CA
	SUBQ	#2,D0
	BGT.S	L1C9
	LEA	L22D(PC),A1
	MOVE.L	L230(PC),(A1)
	MOVEQ	#0,D0
L1C9:	MOVE	D0,(A0)
L1CA:	LEA	L232(PC),A0
	MOVE	(A0),D0
	ADDQ	#2,D0
	MOVE	#$180,D1
	CMP	D1,D0
	BCS.S	L1CB
	SUB	D1,D0
L1CB:	MOVE	D0,(A0)
	MOVE	D0,D1
	AND	#$F,D1
	NEG	D1
	ADD	#$F,D1
	MOVE	D1,D2
	LSL	#4,D1
	ADD	D2,D1

;	MOVE.L	L1FB(PC),A1
;	MOVE	D1,(A1)


L1CD:	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L1CE:
	MOVEM.L	A0-A1/D0-D1,-(A7)
	LEA	L1CF(PC),A1
	EXT	D0
	NEG	D0
	ADD	D0,D0
	ADDA	-2(A1,D0.W),A1
	JSR	(A1)
	MOVEM.L	(A7)+,A0-A1/D0-D1
	BRA	L1C6

L1CF	DC.W	Y4A-L1CF	;$FF
	DC.W	Y5E-L1CF	;FE
	DC.W	Y68-L1CF	;FD
	DC.W	Y72-L1CF	;FC
	DC.W	Y7C-L1CF	;FB
	DC.W	Y86-L1CF	;FA
	DC.W	Y8E-L1CF	;F9
	DC.W	Y98-L1CF	;F8
	DC.W	YA2-L1CF	;F7
	DC.W	YC6-L1CF	;F6
	DC.W	YC0-L1CF	;F5
	DC.W	YB4-L1CF	;F4
	DC.W	YCC-L1CF	;F3
	DC.W	Y104-L1CF	;F2
	DC.W	Y10E-L1CF	;F1
	DC.W	Y118-L1CF	;F0
	DC.W	Y138-L1CF	;EF
	DC.W	Y14C-L1CF	;EE
	DC.W	Y15C-L1CF	;ED
	DC.W	Y174-L1CF	;EC
	DC.W	Y188-L1CF	;EB
	DC.W	Y1AE-L1CF	;EA
	DC.W	Y1CA-L1CF	;E9
	DC.W	Y202-L1CF	;E8
	DC.W	Y21C-L1CF	;E7
	DC.W	Y22C-L1CF	;E6
	DC.W	Y23E-L1CF	;E5
	DC.W	Y254-L1CF	;E4
	DC.W	Y270-L1CF	;E3
	DC.W	Y318-L1CF	;E2
	DC.W	Y290-L1CF	;E1
	DC.W	Y29C-L1CF	;E0
	DC.W	Y2E2-L1CF	;DF
	DC.W	Y2EA-L1CF	;DE
	DC.W	Y2F2-L1CF	;DD
	DC.W	Y2FA-L1CF	;DC
	DC.W	Y308-L1CF	;DB
Y4A:
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	LSL	#2,D0
;
; REGLAGE VITESSE
;
;	MOVE	D0,L234
L1D0:	MOVE.L	A2,(A0)
	ADDA	#$14,A7
	BRA.S	L1CD
Y5E:
	BSET	#6,L239
	BRA.S	L1D0
Y68:
	BSET	#7,L239
	BRA.S	L1D0
Y72:
	BSET	#5,L239
	BRA.S	L1D0
Y7C:
	BSET	#4,L239
	BRA.S	L1D0
Y86:
	MOVE.B	(A2)+,L235
	BRA.S	L1D0
Y8E:
	BSET	#3,L239
	BRA.S	L1D0
Y98:
	BSET	#2,L239
	BRA.S	L1D0
YA2:
;
; SAISIE SOURIS
;
	LEA	L236(PC),A1
	MOVE.B	(A2)+,(A1)
	LEA	L189(PC),A1
;	MOVE	$00DFF00A,(A1)
	MOVE	mousex,d0
	move.b	d0,(a1)+
	move	mousey,d0
	move.b	d0,(a1)+
	RTS
YB4:
;L1D1:
	MOVE.B	(A2)+,D0
	EXT	D0
	MOVE	D0,L17C
	RTS
YC0:
	MOVE.B	(A2)+,D0
	EXT	D0
	MOVE	D0,L17D
	RTS
YC6:
	MOVE.B	(A2)+,D0
	EXT	D0
	MOVE	D0,L17E
	RTS
YCC:
	LEA	L17C(PC),A0
	LEA	L17F(PC),A1
L1D2:	MOVE.B	(A2)+,D0
	EXT	D0
	LSL	#3,D0
	MOVE	D0,(A1)
	BMI.S	L1D5
	MOVEQ	#2,D1
	ANDI	#-2,-6(A0)
	SUB	-6(A0),D0
	BPL.S	L1D3
	NEG	D1
	NEG	D0
L1D3:	CMPI	#$200,D0
	BHI.S	L1D4
	NEG	D1
L1D4:	MOVE	D1,(A0)
L1D5:
	BCLR	#6,L23A
	RTS

Y104:
	LEA	L17D(PC),A0
	LEA	L180(PC),A1
	BRA.S	L1D2
Y10E:
	LEA	L17E(PC),A0
	LEA	L181(PC),A1
	BRA.S	L1D2
Y118:
	MOVEQ	#0,D2
	MOVE.B	(A2)+,D2
	MOVE.B	(A2)+,D0
	MOVEQ	#0,D1
	BSET	D0,D1
	MOVE	D1,L183
	CMP	L184(PC),D1
	BHI.S	L1D6
	NEG	D2
L1D6:	MOVE	D2,L182
	RTS
Y138:
	MOVE.B	(A2)+,D0
	MOVEQ	#0,D1
	BSET	D0,D1
	MOVE	D1,L184
	MOVE	D1,L183
	RTS
Y14C:
	MOVE.B	(A2)+,D0
	LEA	L24C(PC),A1
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	MOVE.B	D0,0(A1,D1.W)
	RTS
Y15C:
	MOVE.B	(A2)+,D0
	LEA	L24F(PC),A1
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	ADD	D1,D1
	MOVE	D0,0(A1,D1.W)
	LEA	L221(PC),A0
	CLR.B	(A0)
	RTS
Y174:
	MOVEQ	#5,D0
	LEA	L250(PC),A1
L1D7:	MOVE	D0,-(A1)
	DBF	D0,L1D7
	ST	L221
	RTS
Y188:
	LEA	L21E(PC),A1
	MOVE.B	(A2)+,(A1)
	BEQ.S	L1DA
	LEA	L243(PC),A0
	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	ST	(A1)
	SUBQ.B	#1,D0
	BRA.S	L1D9
L1D8:	ADDA	(A0),A0
L1D9:	DBF	D0,L1D8
	ADDQ	#2,A0
	LEA	L23C(PC),A1
	MOVE.L	A0,(A1)
L1DA:	RTS
Y1AE:
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
L1DB:	LEA	L256(PC),A1
	LEA	L255(PC),A0
	MOVE	D0,D1
	ADD	D1,D1
	ADD	D0,D1
	ADDA	D1,A0
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	RTS
Y1CA:
	MOVE	#$140,D0
	MOVE.L	A2,A1
	LEA	L227(PC),A0
L1DC:	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	BMI.S	L1DD
	LSL	#3,D1
	SUB	4(A0,D1.W),D0
	BRA.S	L1DC
L1DD:	LSR	#1,D0
	MOVE	D0,L22E
	MOVE	D0,L22F
	MOVE.L	A2,L230
	MOVE.L	#L245,L22D
	RTS
Y202:
	MOVE	L22F(PC),L22E
	MOVE.L	A2,L230
	MOVE.L	#L245,L22D
	RTS
Y21C:
;
; AFFICHE RIDEAU ECRAN QUI S'OUVRE
;
	BCLR	#7,L23A
	ST	L208
	RTS
Y22C:
;
; AFFICHE RIDEAU ECRAN QUI SE FERME
;
	BCLR	#7,L23A
	MOVE.B	#1,L208
	RTS
Y23E:
	BCLR	#5,L23A
	LEA	L186(PC),A1
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	MOVE.B	(A2)+,0(A1,D0.W)
	RTS
Y254:
	MOVE.B	(A2)+,D0
	LSL.B	#4,D0
	ADD.B	(A2)+,D0
	LSL	#4,D0
	ADD.B	(A2)+,D0
;	MOVE.L	L202(PC),A0
;	MOVE.L	L203(PC),A1
;	MOVE	D0,2(A0)
;	MOVE	D0,2(A1)
	RTS
Y270:
	BCLR	#4,L23A
	LEA	L188(PC),A0
	LEA	L187(PC),A1
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	MOVE.B	(A2)+,0(A1,D0.W)
	MOVE.B	#$4B,0(A0,D0.W)
	RTS
Y290:
	MOVE.B	(A2)+,D0
	NEG.B	D0
	MOVE.B	D0,L221
	RTS
Y29C:
	LEA	L220(PC),A0
	MOVEQ	#1,D0
	MOVE.B	D0,(A0)
	MOVE.B	(A2)+,D0
	LSL	#3,D0
	LEA	L7A(PC),A0
	ADDA	D0,A0
	LEA	L75(PC),A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	#BUFFER3,L21A
	LEA	L7B(PC),A0
	LSL	#2,D0
	ADD.L	A0,D0
	LEA	L251(PC),A0
	MOVE.L	D0,(A0)
	MOVEQ	#$7F,D0
	LEA	L24C(PC),A0
	MOVE.B	D0,(A0)
	LEA	L24D(PC),A0
	MOVE.B	D0,(A0)
	LEA	L24F(PC),A0
	CLR	(A0)
	RTS
Y2E2:
	CLR.B	L220
	RTS
Y2EA:
	MOVE.B	(A2)+,L7F
	RTS
Y2F2:
	ST	L7F
	RTS
Y2FA:
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	LEA	L84(PC),A0
	ST	0(A0,D0.W)
	RTS
Y308:
	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	LEA	L84(PC),A0
	MOVE.B	#1,0(A0,D0.W)
	RTS
Y318:
	LEA	L237(PC),A1
	ST	(A1)
	RTS
L1DE:	MOVEM.L	A0-A6/D0-D7,-(A7)
	LEA	L23D(PC),A0
	LEA	L241(PC),A1
	MOVE.L	(A0),A2
	LEA	L23F(PC),A4
	LEA	L242(PC),A5
	SUBQ	#1,(A5)
	BPL.S	L1E5
	ADDQ	#1,(A1)+
	MOVE	(A1),D0
	CMP	-(A1),D0
	BHI.S	L1E1
	MOVE	#2,(A5)
L1DF:	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	SUB.B	#$61,D0
	BPL.S	L1E0
	ADDI	#$C,(A5)
	BRA.S	L1DF
L1E0:	LSL	#3,D0
	LEA	L22A(PC),A3
	ADDA	D0,A3
	MOVE.L	(A3)+,(A4)
	CLR	(A1)+
	MOVE	(A3)+,(A1)
	SUBQ	#2,A1
L1E1:	TST.B	(A2)
	BNE.S	L1E2
	MOVE.L	L23C(PC),A2
L1E2:	MOVE.L	A2,(A0)
	MOVE.L	(A4),A0
	MOVE	(A1),D0
	MULU	#$16,D0
	ADDA	D0,A0
	TST	(A5)
	BPL.S	L1E5
	MOVE.L	L23E(PC),A1
	ADDA	L240(PC),A1
	ADDA	#$1C00,A1
	MOVEQ	#$15,D7
L1E3:	MOVE.B	(A0)+,D0
	BMI.S	L1E4
	MOVE.B	6400(A1),D0
L1E4:	MOVE.B	D0,(A1)
	MOVE.B	D0,75(A1)
	ADDA	#$100,A1
	DBF	D7,L1E3
	BRA.S	L1E7
L1E5:	MOVE.L	L23E(PC),A1
	ADDA	L240(PC),A1
	ADDA	#$1A00,A1
	MOVEQ	#$40,D0
	MOVEQ	#$15,D7
L1E6:	MOVE.B	6400(A1),D0
	MOVE.B	D0,(A1)
	MOVE.B	D0,75(A1)
	ADDA	#$100,A1
	DBF	D7,L1E6
L1E7:	LEA	L240(PC),A0
	MOVE	(A0),D0
	ADDQ	#1,D0
	CMPI	#$4B,D0
	BCS.S	L1E8
	MOVEQ	#0,D0
L1E8:	MOVE	D0,(A0)
	LEA	L253(PC),A0
	MOVE	D0,(A0)
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L1FC:	DC.L	0,0,0
L206:	DC.B	$00,'G'
L207:	DC.B	$00,'H'
L208:	DC.B	$00
	EVEN
;L20C:	DS.W	2
L214:	DS.W	1
L215:	DS.W	1
L218:	DS.W	2
L21A:	DS.W	2
L21B:	DS.W	2
L21C:	DS.W	30
L21D:	DC.B	$00
L21E:	DC.B	$00
L21F:	DC.B	$00
L220:	DC.B	$00
L221:	DC.B	$FF,$00
L225:	DC.B	$FF,$FF,$FF,$80,$80,$00,$00,$80
	DC.B	$80,$00,$00,$80,$80,$00,$00,$80
	DC.B	$80,$00,$00,$80,$80,$00,$00,$80
	DC.B	$80,$00,$00,$80,$80,$01,$FC,$80
	DC.B	$80,$03,'l',$80,$80,$06,$D8,$80
	DC.B	$80,$0D,$B0,$80,$BF,$9B,'`',$80
	DC.B	$A4,$B6,$C0,$80,$92,'m',$80,$80
	DC.B	$92,$DB,$00,$80,$89,$B6,$00,$80
	DC.B	$8B,'l',$00,$80,$86,$D8,$00,$80
	DC.B	$87,$F0,$00,$80,$80,$00,$00,$80
	DC.B	$80,$00,$00,$80,$80,$00,$00,$80
	DC.B	$80,$00,$00,$80,$80,$00,$00,$80
	DC.B	$FF,$FF,$FF,$80,$00,$00,$00,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,'',$FF,$FF,$80
	DC.B	'',$FF,$FF,$80,$FF,$FF,$FF,$80
	DS.W	1
	DC.B	$0F,$FF,$0A,$AE,$04,'G'
L226:	DC.B	'abcdefgh'
	DC.B	'ijklmnop'
	DC.B	'qrstuvwx'
	DC.B	'yz123456'
	DC.B	'7890.!:?'
	DC.B	$27,'+-()',$00
L227:	DS.W	128
L228:	DS.W	384
L229:	DC.B	$0C,$CC,$07,'z',$04,'G',$00,$00
	DS.W	6
L22A:	DS.W	104
L22C:	DS.W	2
L22D:	DS.W	2
L22E:	DS.W	1
L22F:	DS.W	2
L230:	DS.W	2
L231:	DS.W	2
L232:	DS.W	1
L233:	DS.W	2
L234:	DS.W	1
L235:	DC.B	$00
L236:	DC.B	$00
L237:	DC.B	$00
L238:	DC.B	$00
L239:	DC.B	$FF
L23A:	DC.B	$00
L23C:	DS.W	2
L23D:	DS.W	2
L23E:	DS.W	2
L23F:	DS.W	2
L240:	DS.W	1
L241:	DS.W	2
L242:	DS.W	1
L243:	DC.B	$00,'>'
L244:	DC.B	' scroll '
	DC.B	'on a cub'
	DC.B	'e    use'
	DC.B	' your mo'
	DC.B	'use to r'
	DC.B	'otate th'
	DC.B	'e cube  '
	DC.B	'  ',$00,$00,$00,'6 j'
	DC.B	'oin the '
	DC.B	'power   '
	DC.B	'  no com'
	DC.B	'promises'
	DC.B	'    no l'
	DC.B	'imits   '
	DC.B	' ',$00,$00
L245:	DC.B	'         '
	DC.B	'        '
	DC.B	'        '
	DC.B	'     ',$00
L247:	DC.B	$E6,'...now '
	DC.B	'entering'
	DC.B	' hidden '
	DC.B	'mode   ',$E9
	DC.B	'active',$E8,$FD
	DC.B	$EF,$0B,$E1,$01,$F6,$00,$F5,$00
	DC.B	$F4,$00,$F3,$FF,$F2,$FF,$F1,$FF
	DC.B	$EA,$00,$EB,$00,$DD,$EE,$00,$00
	DC.B	$EE,$01,$01,$EE,$02,$02,$EE,$03
	DC.B	$03,$EE,$04,$04,$EE,$05,$05,$EC
	DC.B	$FA,$02,$EF,$00,$FA,$03,$E7,$E1
	DC.B	$01,$E5,$00,$FF,$E5,$01,$FF,$E5
	DC.B	$02,$FF,$E5,$03,$FF,$E5,$04,$FF
	DC.B	$E5,$05,$FF,$F7,$01,$FD,' ',$00
L248:	DC.B	$EF,$0B,$E1,$01,$F6,$00,$F5,$00
	DC.B	$F4,$00,$F3,$FF,$F2,$FF,$F1,$FF
	DC.B	$EA,$00,$EB,$00,$DD,$EE,$00,$00
	DC.B	$EE,$01,$01,$EE,$02,$02,$EE,$03
	DC.B	$03,$EE,$04,$04,$EE,$05,$05,$EC
	DC.B	$FA,$02,'...ini'
	DC.B	't  ',$EF,$00,' ',$00
L249:	DC.B	'use the k'
	DC.B	'eyboard '
	DC.B	'+ the mo'
	DC.B	'use to c'
	DC.B	'ontrol t'
	DC.B	'he cube!'
	DC.B	'    ',$E9,' ',$E8,'s'
	DC.B	'pecial g'
	DC.B	'reetings'
	DC.B	' to the '
	DC.B	'followin'
	DC.B	'g people'
	DC.B	': marcel'
	DC.B	'  tobi  '
	DC.B	'joe + ma'
	DC.B	't + tim '
	DC.B	'of mda f'
	DC.B	'or being'
	DC.B	' very ol'
	DC.B	'd friend'
	DC.B	's --- uc'
	DC.B	'om + mat'
	DC.B	' for the'
	DC.B	' graphic'
	DC.B	's and so'
	DC.B	'und --- '
	DC.B	'amicom f'
	DC.B	'or being'
	DC.B	' the har'
	DC.B	'dware wi'
	DC.B	'zard (li'
	DC.B	'zard?) a'
	DC.B	'nd for b'
	DC.B	'eing a g'
	DC.B	'reat fri'
	DC.B	'end --- '
	DC.B	'grampa f'
	DC.B	'or the f'
	DC.B	'ont an t'
	DC.B	'extures '
	DC.B	'--- mark'
	DC.B	' for the'
	DC.B	' origina'
	DC.B	'l mandel'
	DC.B	'brot rou'
	DC.B	'tine ---'
	DC.B	' mike + '
	DC.B	'the rest'
	DC.B	' for fou'
	DC.B	'nding sp'
	DC.B	'readpoin'
	DC.B	't --- ti'
	DC.B	'lt + geo'
	DC.B	'rge 2 fo'
	DC.B	'r being '
	DC.B	'cool guy'
	DC.B	's (genia'
	DC.B	'l!!) ---'
	DC.B	'depeche '
	DC.B	'(ahh yea'
	DC.B	'hh!!!) a'
	DC.B	'lthough '
	DC.B	'he left '
	DC.B	'spreadpo'
	DC.B	'int in a'
	DC.B	' strange'
	DC.B	' way...:'
	DC.B	'-(  --- '
	DC.B	'sca for '
	DC.B	'sca-nnin'
	DC.B	'g those '
	DC.B	'pictures'
	DC.B	' and lot'
	DC.B	's of oth'
	DC.B	'er amiga'
	DC.B	' magic! '
	DC.B	'--- all '
	DC.B	'of sprea'
	DC.B	'dpoint ('
	DC.B	'those i',$27
	DC.B	've met a'
	DC.B	'nd those'
	DC.B	' i haven'
	DC.B	$27,'t (yet!'
	DC.B	')) --- b'
	DC.B	'yte ride'
	DC.B	'r and ti'
	DC.B	'gger  fr'
	DC.B	'iends an'
	DC.B	'd mtv-lo'
	DC.B	'vers ---'
	DC.B	' olaf bo'
	DC.B	'ehm: for'
	DC.B	'get thos'
	DC.B	'e stupid'
	DC.B	' freezer'
	DC.B	's! the a'
	DC.B	'miga is '
	DC.B	'not wort'
	DC.B	'h such c'
	DC.B	'rap! ---'
	DC.B	' all who'
	DC.B	' believe'
	DC.B	' in the '
	DC.B	'idea of '
	DC.B	'friendsh'
	DC.B	'ip (inst'
	DC.B	'ead of b'
	DC.B	'usiness:'
	DC.B	' unbrauc'
	DC.B	'hbar!) -'
	DC.B	'--     ',$E9
	DC.B	' ',$E8,' ',$00,$FD,$FD,$00
L24A:	DC.B	$E4,$00,$00,$00,$FF,$01,$E4,$02,$02
	DC.B	$02,$FF,$01,$E4,$04,$04,$04,$FF
	DC.B	$01,$E4,$06,$06,$06,$FF,$01,$E4
	DC.B	$08,$08,$08,$FF,$01,$E4,$0A,$0A
	DC.B	$0A,$FF,$01,$E4,$0C,$0C,$0C,$FF
	DC.B	$01,$E4,$0F,$0F,$0F
L24B:
	INCBIN	MESS1.BIN
	even

L24C:	DS.W	3
L24D:	DS.W	2
	DC.B	$00
L24E:	DC.B	$00
L24F:	DS.W	6
L250:	DS.W	2
L251:	DS.W	5
L252:	DS.W	40
L253:	DS.W	1
L254:	DS.W	104
L255:	DC.B	$06,$06,$06,$06,$03,$00,$04,$04
	DC.B	$04,$03,$02,$04,$06,$06,$00,$00
L256:	DS.W	2
;PALETTE

PALETTE	DC.W	0
L257	DC.W	$FFF/2,$EEE/2,$BBB/2,$AAA/2,$999/2,$777/2,$555/2
	DC.W	$000/2,$FA8/2,$FE0/2,$080/2,$0D0/2,$0CC/2,$06F/2
	DC.W	$00A/2
	DS.W	16
;L257:	DS.W	32
L258:	DC.B	$00,$01,$00,$0B,$00,$15,$00,$0B
	DC.B	$00,$15,$00,$01
L259:	DS.W	512
L25D:	INCBIN	INC10.BIN
L25E:	DS.W	1
	DC.B	$0F,$FF,$0E,$EE,$0B,$BB,$0A,$AA
	DC.B	$09,$99,$07,'w',$05,'U'

	EVEN
L0:
	INCBIN	INC1.BIN
L1:
	INCBIN	INC2.BIN
L2:
	INCBIN	INC3.BIN
L4:
	INCBIN	INC4.BIN

	SECTION	BSS

ADRECRAN:DS.L	1
	DS.B	65536
BUFFER1:			;SE REMPLIT DES 2 COTES A LA FOIS
	DS.B	65536

L25A:	DS.B	512
L25B:	DS.B	512
L25C:	DS.B	512

BUFFER2:DS.B	$2710		;$2402 EN FAIT

BUFFER3:DS.B	65536		;QUELLE EST LA TAILLE ???

BUFFER5:DS.B	$4220
BUFFER6:DS.B	$23F0

ECRANS:
	DS.B	32000*3+255
;INITREPLAY:
;REPLAY:
