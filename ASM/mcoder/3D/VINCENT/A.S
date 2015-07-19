	; ------------------------------------------- ;
	;        The maxi-optimyzed 3D Z-rout	 ;
	; (C) 1989-90 Vincent PENNE (Ziggy STARDUST). ;
	; ------------------------------------------- ;

	output	A.TOS
	opt	O+,OW-,M+
	opt	P=68030

 ; #[ Constantes et macros:

TRUE	=	-1
FALSE	=	0

; Parametre systeme
NECR	=	3
DEBUG	=	TRUE
TSTCOL	=	TRUE
BOMB	=	TRUE
MUSIC	=	FALSE
MONIMONO	=	TRUE
TT	=	TRUE

	IFNE	DEBUG
	opt	x+
	ELSEIF
	opt	d-,x-
	ENDC

; Variable pour les calculs 3D
TSINUS	=	1024
DISTEC	=	8

; Organisation de la palette (Pour l'instant 1 plan par couleur)
COLFOND	=	$000
TAILPAL	=	16	; (Jusqu'a 512!!)
MINCOL	=	0
MAXCOL	=	3

; Parametre pour le tracage des lignes horizontales, configuration de l'ecran
NBLIG	=	200
LECRAN	=	320
DEPASSE	=	1024
MINX	=	0
MAXX	=	320
CX	=	160	; Centre de l'ecran
CY	=	100
MIX	=	MINX	; Fenetre de clipping
MIY	=	0
MAX	=	MAXX-1
MAY	=	NBLIG-1
ZOOM	=	256

Vsync	MACRO
	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	ENDM

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

Tstcol	MACRO
	IFNE	TSTCOL
	tst.b	tcol
	beq.s	.nc\@
	move	#\1,$ffff8240.w
.nc\@:
	ENDC
	ENDM

Print	MACRO
	pea	\1
	move	#9,-(a7)
	trap	#1
	addq	#6,a7
	ENDM

Flab	MACRO
a\@:
	ENDM

 ; #] Constantes et macros:
 ; #[ Debut:

debut:
	clr	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#4,a7

	bsr.s	init

	jmp	mainloop

Copyright:
	dc.b	"(C) Copyright Vincent PENNE 1990. "
	dc.b	"Don't spread!!",0
	even

 ; #] Debut:
 ; #[ Init:

	; #[ Init_system:
init:
	move.b	#2,$484.w

	bsr	init_hline
	bsr	genere_circle

	IFNE	MUSIC
	moveq	#1,d0
	lea	music,a0
	jsr	player
	ENDC

	move.l	$44e.w,oldec

	move.l	#ecran,d0
	andi.l	#$ffff00,d0
	lea	ec,a0
	moveq	#NECR-1,d7
.loop:
	move.l	d0,NECR*4(a0)
	move.l	d0,(a0)+
	addi.l	#32000,d0
	dbra	d7,.loop
	move.l	ec,ec1

	move.b	$ffff8260.w,oldrez
	move.b	$ffff8262.w,oldrez_tt

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal

	move	#$2700,sr
	IFNE	BOMB
	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb

;	tst.b	$75.w
;	blt.s	.nobomb
	lea	$8.w,a0	; Redirection des bombes
	move.l	#fin,d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
.nobomb:
	ENDC

	move.l	#trap3,$80+3*4.w

	move	#$2700,sr ; Pour changer de moniteur sans reset.
	IFNE	MONIMONO
	not	$ffff8240.w
	ENDC
	andi.b	#%11,oldrez
	IFNE	MONIMONO
;	tst.b	$75.w
;	blt.s	.okmoni
	cmpi.b	#2,oldrez
	bne.s	.okmoni

.waitmoni:
	btst	#7,$fffffa01.w
	beq.s	.waitmoni

	Vsync_no_interrupt
	clr.b	$ffff8260.w

.okmoni:
	ENDC
	Vsync_no_interrupt
	clr.b	$ffff8260.w

	bsr	initmfp
	bsr	init_mouse
	move	#$2300,sr
	bsr	error_clavier

	btst	#1,$ffff820a.w
	bne.s	.no
	move	#60,qfreq
	move	#190,qtimer
.no:

	IFNE	TT
	move.l	$10.w,-(a7)
	move.l	#jump68000,$10.w
	sub.l	a0,a0
putnop:
	movec	a0,vbr

	tst.b	q68000
	bne.s	.no68030

	move	#$4ef9,line68000
	move.l	#line68030,line68000+2
	move	#$4ef9,line68000t
	move.l	#line68030t,line68000t+2
.no68030:
	move.l	(a7)+,$10.w
	ENDC

	move.b	ec1+3*4-4+1,$ffff8201.w
	move.b	ec1+3*4-4+2,$ffff8203.w

	rts

	IFNE	TT
q68000	dc.w	0

	ds.b	256

jump68000:
	st	q68000
	move.l	#$4e714e71,putnop

	rte
	ENDC

	; #] Init_system:
	; #[ Uninit:
uninit:
	move	#$2700,sr

	IFNE	BOMB
	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	ENDC

	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	jsr	finmfp

	IFNE	MONIMONO
	cmpi.b	#2,oldrez
	bne.s	.no_change_moni

.waitmoni:
	btst	#7,$fffffa01.w
	bne.s	.waitmoni

	moveq	#50-1,d0
	bsr	wait

.no_change_moni:
	ENDC
	Vsync_no_interrupt
	move.b	oldrez,$ffff8260.w
	move.b	oldrez_tt,$ffff8262.w

	bsr	error_clavier
	move	#$2300,sr

	move	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move	#5,-(a7)
	trap	#14
	adda.l	#12,a7

	move	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	waitc
	move.b	#$8,$fffffc02.w

	rts
	; #] Uninit:

 ; #] Init:
 ; #[ Init/reinstall interupt:

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

	bsr.s	finmfp

	bclr	#3,$fffffa17.w

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w

	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa15.w

	move.l	#vbl,$70.w
	move.l	#clavier,$118.w
	move.l	#vbl2,$134.w

	move	(a7)+,sr
	rts

oldfreq	dc.w	0

finmfp:
	move	sr,-(a7)
	move	#$2700,sr

	moveq	#0,d1	; Ecran noir
	lea	$ffff8240.w,a0
	moveq	#16/2-1,d0
.noir:
	move.l	d1,(a0)+
	dbra	d0,.noir

	bsr	waitc
	move.b	#$22,(a0)
	bsr	waitc
	move.b	#$f0,(a0)
	bsr	waitc
	move.b	#$00,(a0)

	IFNE	FALSE
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

	IFNE	FALSE
	btst.b	#1,oldfreq
	beq.s	.ok
	Vsync
	clr.b	$ffff820a.w
	Vsync
	move.b	#2,$ffff820a.w
.ok:
	ENDC

	move	(a7)+,sr
	rts

	SECTION	BSS

oldvec	ds.l	24
oldmfp	ds.b	24

	SECTION	TEXT

 ; #] Init/reinstall interupt:
 ; #[ Wait:
wait:
	move	#13333,d1
.wait:
	dbra	d1,.wait
	dbra	d0,wait

	rts

 ; #] Wait:
 ; #[ Clavier interupt:

ABSOLUTE_MOUSE =	TRUE
	; #[ Interuption:
clavier:
	btst	#0,$fffffc00.w
	beq.s	.noclav

	move	d0,-(a7)

	clr	d0
	move.b	$fffffc02.w,d0

	IFNE	ABSOLUTE_MOUSE
	cmpi.b	#$f7,d0
	beq.s	absolute_mouse_1
	ENDC

	move.l	a0,-(a7)
	bclr	#7,d0
	lea	clav(pc),a0
	seq	(a0,d0)
	move.l	(a7)+,a0

	move	(a7)+,d0
.noclav:
	rte

	IFNE	ABSOLUTE_MOUSE
absolute_mouse_1:
	move.l	#absolute_mouse_2,$118.w
	move	(a7)+,d0
	rte

absolute_mouse_2:
	btst	#0,$fffffc00.w
	beq.s	.noclav

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
.noclav:
	rte

absolute_mouse_3:
	btst	#0,$fffffc00.w
	beq.s	.noclav
	move.b	$fffffc02.w,cmousex

	move.l	#absolute_mouse_4,$118.w
.noclav:
	rte

absolute_mouse_4:
	btst	#0,$fffffc00.w
	beq.s	.noclav
	move.b	$fffffc02.w,cmousex+1

	move.l	#absolute_mouse_5,$118.w
.noclav:
	rte

absolute_mouse_5:
	btst	#0,$fffffc00.w
	beq.s	.noclav
	move.b	$fffffc02.w,cmousey

	move.l	#absolute_mouse_6,$118.w
.noclav:
	rte

absolute_mouse_6:
	btst	#0,$fffffc00.w
	beq.s	.noclav
	move.b	$fffffc02.w,cmousey+1

	move	cmousex,mousex
	move	cmousey,mousey

	move.l	#clavier,$118.w
.noclav:
	rte
	ENDC
	; #] Interuption:
	; #[ Init mouse:

MAX_MOUSEX	=	320
MAX_MOUSEY	=	200

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

	IFNE	ABSOLUTE_MOUSE
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
	bsr.s	waitc
	clr.b	(a0)
	bsr.s	waitc
	move.b	mousex,(a0)
	bsr.s	waitc
	move.b	mousex+1,(a0)
	bsr.s	waitc
	move.b	mousey,(a0)
	bsr.s	waitc
	move.b	mousey+1,(a0)

	ELSEIF
	bsr.s	waitc
	move.b	#$12,(a0)

	ENDC

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
	; #] Init mouse:
	; #[ Test touche:
test_touche:
	lea	clav(pc),a0

	Flab
	tst.b	$4e(a0)	; '+'?
	beq.s	.no
	addq	#1,rayon
.no:
	Flab
	tst.b	$4a(a0)	; '-'?
	beq.s	.no
	subq	#1,rayon
.no:
	Flab
	tst.b	$1(a0)	; <Esc>?
	beq.s	.no
	illegal
.no:
	Flab
	tst.b	59(a0)	; <F1>?
	beq.s	.no
	st	$f(a0)
.no:
	Flab
	tst.b	60(a0)	; <F2>?
	beq.s	.no
	move.l	#hline_one_plane,curline
.no:
	Flab
	tst.b	61(a0)	; <F3>?
	beq.s	.no
	move.l	#hline_one_plane_tramed,curline
.no:

	sf	tcol
	tst.b	$f(a0)	; <Tab>?
	beq.s	.nocol

	st	tcol
.nocol:

	rts
	; #] Test touche:

 ; #] Clavier interupt:
 ; #[ Supervisor/User mode:

trap3:		; Pour passer en superviseur rapidement
	rtr

retour:
	move.l	oldpile(pc),a7
	trap	#3
	rts

oldpile	dc.l	0

 ; #] Supervisor/User mode:

 ; #[ Very fast horizontal line:
; ------------------------------------------------------------------------ ;
;	     Appel routine de tracage horizontal		;
;	           (Gere le clipping en Y)		;
; ------------------------------------------------------------------------ ;

	; #[ Calling rout:
; Routine d'appele
; {curline} : Routine a appele
; A6 : Adresse ecran
; D0 : Position Y
; D1 : Nbr de ligne a afficher

no_aff_line:
	rts

call_line:
	tst	d1
	blt.s	no_aff_line

	lea	points_gauche,a4
	lea	points_droite,a5

	cmp	#MIY,d0
	bge.s	.ok

	sub	#MIY,d0
	add	d0,d1
	blt.s	no_aff_line

	add	d0,d0
	suba	d0,a4
	suba	d0,a5

	move	#MIY,d0
.ok:

	move	d0,d2
	add	d1,d2
	cmpi	#NBLIG,d2
	blt.s	.ok2

	move	#NBLIG,d1
	sub	d0,d1
	blt.s	no_aff_line
.ok2:

; Sans clipping en Y
; A0 : Routine a appele
; A6 : Adresse ecran
; D0 : Position Y
; D1 : Nbr de ligne a afficher
call_line_no_clip:
	move	d0,d3
	lsl	#5,d3
	move	d3,d2
	add	d3,d3
	add	d3,d3
	add	d2,d3	; * 160
	adda	d3,a6

curline	=	*+2
	jmp	hline_one_plane

; ------------------------------------------------------------------------ ;
;	       Tracage de ligne horizontal 1 plan.		;
; ------------------------------------------------------------------------ ;
; D1: Nombre le ligne en hauteur
; A4: Table des points gauches
; A5:   "    "    "    droits
; A6: Adresse ecran

; ************ ;
; Non tram‚es: ;
; ************ ;
hline_one_plane:
	moveq	#$ffffffff,d5
	lea	ldecal,a1
	lea	rdecal,a2

line68000:
	lsl	#7,d1 ; La routine fait 128 octets
	neg	d1
	lea	phline2,a3
	jmp	(a3,d1)

line68030:
	subq	#1,d1
	; #[ One plane:	(128 octets)
hline2:
	moveq	#-4,d0
	and	(a4)+,d0
	moveq	#-4,d1
	and	(a5)+,d1

	move.l	(a1,d0),d0
	move.l	(a2,d1),d1

	sub	d1,d0
	bge.s	.little_line

	move.l	a6,a0
	adda	d1,a0
	swap	d1
	or	d1,(a0)
	adda	d0,a0

	asr	#1,d0
	jmp	.loopline+4(pc,d0)

.little_line:
	bne.s	.nohline

	and.l	d1,d0
	swap	d0
	or	d0,(a6,d1)
	bra.s	.nohline

N	set	(LECRAN-32)/2
	REPT	(LECRAN-32)/16
	move	d5,N(a0)
N	set	N-8
	ENDR

.loopline:
	swap	d0
	or	d0,(a0)
.nohline:
	lea	160(a6),a6

hline1:
	; #] One plane:
	dbra	d1,hline2

	rts

; ****************** ;
; tram‚es invers‚es: ;
; ****************** ;
hline_inversed_one_plane_tramed:
	move.l	#$aaaaaaaa,d5
	btst	#0,d0
	bne.s	.ok
	not	d5
.ok:
	bra.s	jmp_one_plane_tramed

; ******** ;
; tram‚es: ;
; ******** ;
hline_one_plane_tramed:
	move.l	#$aaaaaaaa,d5
	btst	#0,d0
	beq.s	.ok
	not	d5
.ok:
jmp_one_plane_tramed:
	lea	ldecal,a1
	lea	rdecal,a2

line68000t:
	lsl	#3,d1
	move	d1,d0
	lsl	#4,d1
	add	d0,d1 ; La routine fait 136 octets
	neg	d1
	lea	phlinet2,a3
	jmp	(a3,d1)

line68030t:
	subq	#1,d1
	; #[ One plane tramed:	(136 octets)
hline_tramed2:
	moveq	#-4,d0
	and	(a4)+,d0
	moveq	#-4,d1
	and	(a5)+,d1

	move.l	(a1,d0),d0
	move.l	(a2,d1),d1

	sub	d1,d0
	bge.s	.little_line

	move.l	a6,a0
	adda	d1,a0
	swap	d1
	and	d5,d1
	or	d1,(a0)
	adda	d0,a0

	asr	#1,d0
	jmp	.loopline+4(pc,d0)

.little_line:
	bne.s	.nohline

	and.l	d1,d0
	swap	d0
	and	d5,d0
	or	d0,(a6,d1)
	bra.s	.nohline

N	set	(LECRAN-32)/2
	REPT	(LECRAN-32)/16
	move	d5,N(a0)
N	set	N-8
	ENDR

.loopline:
	swap	d0
	and	d5,d0
	or	d0,(a0)
.nohline:
	not	d5
	lea	160(a6),a6

hline_tramed1:
	; #] One plane tramed:
	dbra	d1,hline_tramed2

	rts

	; #] Calling rout:
	; #[ Genere hline:
bord:	dc	%111111111111111,%11111111111111,%1111111111111,%111111111111,%11111111111,%1111111111,%111111111,%11111111,%1111111,%111111,%11111,%1111,%111,%11,%1,0

init_hline:
	lea	phline,a1	; Pregenere les lignes 1 plan
	move	#NBLIG-1,d0
.lphline:
	lea	hline2,a0
	move	#(hline1-hline2)/2-1,d1
.lphline2:
	move	(a0)+,(a1)+

	dbra	d1,.lphline2

	dbra	d0,.lphline

	move	#$4e75,(a1)+

	Flab
	lea	phlinet,a1	; Pregenere les lignes 1 plan tram‚es
	move	#NBLIG-1,d0
.lphline:
	lea	hline_tramed2,a0
	move	#(hline_tramed1-hline_tramed2)/2-1,d1
.lphline2:
	move	(a0)+,(a1)+

	dbra	d1,.lphline2

	dbra	d0,.lphline

	move	#$4e75,(a1)+

	lea	ldecal,a0		; Precalcul le bord des lignes H
	lea	rdecal,a2
	move	#0,d2
	move	#0,d3
	move	#LECRAN/16-1,d0
decal1:
	lea	bord,a1
	move	#15,d1
decal2:
	move	(a1)+,d7
	move	d7,(a0)+
	move	d2,(a0)+

	not	d7
	bne.s	.pazero

	move	#-1,(a2)+
	subq	#8,d3
	move	d3,(a2)+
	addq	#8,d3
	bra.s	.zero
.pazero
	move	d7,(a2)+
	move	d3,(a2)+
.zero
	dbra	d1,decal2
	addq	#8,d2
	addq	#8,d3

	dbra	d0,decal1

	lea	ldecal-DEPASSE*4,a0 ; Precalcul pour le cliping en X
	lea	rdecal-DEPASSE*4,a1
	move	#DEPASSE+MINX-1,d0
.ld:
	move.l	#$7fff0000+MINX/2,(a0)+
	move.l	#$7fff0000+MINX/2-8,(a1)+
	dbra	d0,.ld

	lea	rdecal+MAXX*4,a0
	lea	ldecal+MAXX*4,a1
	move	#DEPASSE+(LECRAN-MAXX)-1,d0
.rd:
	move.l	#$ffff0000+MAXX/2-8,(a0)+
	move.l	#$ffff0000+MAXX/2,(a1)+
	dbra	d0,.rd

	rts

	SECTION	BSS

phline:
	ds.b	(hline1-hline2)*NBLIG
phline2:
	ds	1	; Pour RTS
	even

phlinet:
	ds.b	(hline_tramed1-hline_tramed2)*NBLIG
phlinet2:
	ds	1	; Pour RTS
	even

	ds.l	DEPASSE
ldecal	ds.l	LECRAN
	ds.l	DEPASSE

	ds.l	DEPASSE
rdecal	ds.l	LECRAN
	ds.l	DEPASSE

	SECTION	TEXT

	; #] Genere hline:

 ; #] Very fast horizontal line:
 ; #[ Very slow line:

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
	subq	#1,Y1
	addq	#1,Y1
	addq	#1,Y2
	subq	#1,Y2

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
	adda	ADEC,ADECRAN
	add	DX,LX
	clr	CURDOT
.ok:
	add	XX,XX
	bcs.s	.plot
	dbra	NLOOP,.loop

	or	CURDOT,(ADECRAN)

.fin:
	rts
.plot:
	or	CURDOT,(ADECRAN)
	subq	#8,ADECRAN
	clr	CURDOT
	moveq	#1,XX

	dbra	NLOOP,.loop

	rts

 ; #] Very slow line:
 ; #[ Circle rout:
; ------------------------------------------------------------------------ ;
;		Routine de cercle.		;
; ------------------------------------------------------------------------ ;

	; #[ Calling rout:
; D1 = Rayon du cercle
; D3 = Position X du centre du cercle

circle:
	move	d1,d7
	move	d1,d2
	add	d1,d2

	lea	points_droite,a0
	move.l	a0,a4
	adda	d2,a0
	move.l	a0,a5
	adda	d2,a5
	move.l	a0,a1

	lea	points_gauche,a6
	move.l	a6,a3
	adda	d2,a3

	move	d1,d4
	add	d4,d4
	add	d4,d4

	move	d3,d5
	sub	d4,d5
	add	d3,d4

	move	d1,d2
	asr	#1,d2

	neg	d7
	muls	#23170/2,d7
	asr.l	#6,d7
	asr.l	#8,d7
	addq	#1,d7

	asl	#3,d7
	move	d7,d0
	add	d7,d7
	add	d7,d7
	add	d0,d7	; * 40 octets

	clr	d0
	lea	circle_rout,a2
	adda	d7,a2
	move	d3,d6
	move	d3,d7

	jsr	(a2)

	move	d6,(a4)+
	move	d6,-(a5)
	move	d7,(a6)+
	move	d7,points_gauche-points_droite(a5)

	rts

	; #] Calling rout:
	; #[ Initiale routine:	(40 octets...)

; D0 = Y
; D1 = X
; D2 = X2

circle1:
	add	d0,d2
	blt.s	.ok

.tst:
	subq	#4,d4
	addq	#4,d5

	move	d6,(a4)+
	move	d6,-(a5)
	move	d7,(a6)+
	move	d7,points_gauche-points_droite(a5)

	subq	#1,d1
	sub	d1,d2
	bge.s	.tst
.ok:
	addq	#1,d0

	addq	#4,d6
	subq	#4,d7

	move	d4,-(a0)
	move	d4,(a1)+
	move	d5,points_gauche-points_droite(a0)
	move	d5,(a3)+

circle2:
	; #] Initiale routine:
	; #[ Genere cercle:
NBCIRCLE	=	(NBLIG+DEPASSE)/3
genere_circle:
	lea	debut_circle_rout,a1
	move	#NBCIRCLE-1,d0

.g_circle:
	lea	circle1(pc),a0
	move	#(circle2-circle1)/2-1,d1
.g_circle2:
	move	(a0)+,(a1)+
	dbra	d1,.g_circle2
	dbra	d0,.g_circle

	move	#$4e75,(a1)+

	rts

	SECTION	BSS

debut_circle_rout:
	ds.b	(circle2-circle1)*NBCIRCLE
circle_rout:
	ds.w	1

	SECTION	TEXT
	; #] Genere cercle:

 ; #] Circle rout:
 ; #[ Ellipse rout:
; ------------------------------------------------------------------------ ;
;		Routine d'ellipse.		;
; ------------------------------------------------------------------------ ;

; D0 = Rayon X de l'ellipse
; D1 = Rayon Y de l'ellipse
; D4 = Position X du centre de l'ellipse
; A6 = Pente (A6 utilis‚ comme registre de donn‚e)

retell:
	rts
ellipse:
	move	d1,d7
	ble.s	retell
	
	move	d1,d2
	add	d2,d2
	add	d2,d2

	lea	points_droite,a0
	move.l	a0,a1
	add	d2,a1
	lea	points_gauche,a3

	swap	d4
	clr	d4
	swap	d4
	move.l	d4,d5
	
	muls	d0,d0
	move.l	d0,d3
	asr.l	#4,d3
	muls	d1,d3
	asl.l	#3,d3
	muls	d1,d1
	
	move.l	d3,d2
	add.l	d3,d3
	neg.l	d2
	moveq	#0,d6
	move.l	d0,a4
	move.l	d1,a2
	move.l	a6,d1
	asr.l	#8,d1
	muls	d7,d1
	asr.l	#8,d1
	move.l	d1,d0

	subq	#1,d7

	bra.s	.saute

.loop:
	swap	d0
	sub.l	a6,d0
	swap	d0
	swap	d1
	sub.l	a6,d1
	swap	d1

.saute:
	add.l	d3,d2
	blt.s	.ok

.tst:
	addq	#4,d4
	subq	#4,d5

	add.l	a2,d6
	sub.l	d6,d2
	bge.s	.tst
.ok:
	sub.l	a4,d3

	sub	d0,d4
	move	d4,(a0)+
	add	d0,d4
	add	d1,d4
	move	d4,-(a1)
	sub	d1,d4
	sub	d0,d5
	move	d5,(a3)+
	add	d0,d5
	add	d1,d5
	move	d5,points_gauche-points_droite(a1)
	sub	d1,d5
	
	dbra	d7,.loop
	
	rts

 ; #] Ellipse rout:

 ; #[ Main programm:

my	dc.w	0
rayon	dc.w	0

mainloop:
	Tstcol	$000
	bsr	anime

	move.l	ec1,a0
	bsr	cls1plan
	Tstcol	$700

	; #[ Affichage des valeurs: Rayon, X et Y:

	move	rayon(pc),d0
	move.l	ec1(pc),a0
	bsr	affnr

	move	mousex(pc),d0
	move.l	ec1,a0
	lea	8*160(a0),a0
	bsr	affnr

	move	mousey(pc),d0
	move.l	ec1,a0
	lea	16*160(a0),a0
	bsr	affnr

	; #] Affichage des valeurs: Rayon, X et Y:

	Tstcol	$070
         	move	mousex(pc),d0	; Rx
	move	mousey(pc),d1	; Ry
	move	#160,d4	; X
	add	d4,d4
	add	d4,d4
	move	rayon(pc),d2
	ext.l	d2
	asl.l	#8,d2
	asl.l	#4,d2
	move.l	d2,a6
	bsr	ellipse

	Tstcol	$007
	move.l	ec1(pc),a6
	move	mousey(pc),d1	; Ry
	move	#100,d0	; Y
	sub	d1,d0
	add	d1,d1
	bsr	call_line

	bra	mainloop

 ; #] Main programm:
 ; #[ Anime:

anime:

.waitvbl:
	move.l	curec,a0
	sub.l	affec,a0
	cmpa.l	#NECR*4-1*4,a0
	bge.s	.waitvbl

	move.l	curec,a0
	addq.l	#4,a0
	cmpa.l	#ec+NECR*4*2,a0
	blt.s	okswap
	suba	#NECR*4,a0
	sub.l	#NECR*4,affec

okswap:
	move.l	(a0),ec1
;	move.l	(NECR*2)*4*1(a0),curlim
;	move.l	(NECR*2)*4*2(a0),affpal
	move.l	a0,curec

	btst	#0,mousek
	bne	fin

	bsr	test_touche

	rts

 ; #] Anime:
 ; #[ Fin:
fin:
	tst.b	mousek
	bne.s	fin

	jsr	uninit

;	IFNE	DEBUG
;	illegal
;	elseif
	clr	-(a7)
	trap	#1
;	ENDC

 ; #] Fin:

 ; #[ Cls_one_plane:

cls1plan:
	moveq	#0,d0
	move	#NBLIG-1,d1

.loop:
N	set	0
	REPT	20
	move	d0,N(a0)
N	set	N+8
	ENDR
	lea	160(a0),a0

	dbra	d1,.loop

	rts

 ; #] Cls_one_plane:

 ; #[ Vbl:

	; #[ Datas:
qaffn	dc.b	0
	even
valaffplot	dc.l	0
curec	dc.l	ec+3*4
affec	dc.l	ec
curaffec	dc.l	ecran
oldaffec	dc.l	ecran
cvbl	dc.w	0
cvbl1	dc.w	0
cvbl2	dc.w	0
cvbl3	dc.w	0
tcol	dc.w	0

ec1	ds.l	1
curlim	dc.l	lim

ec:
	ds.l	NECR*2

tlim:
N	set	0
	REPT	NECR
	dc.l	lim+N
N	set	N+10
	ENDR
N	set	0
	REPT	NECR
	dc.l	lim+N
N	set	N+10
	ENDR

tpal:
N	set	0
	REPT	NECR
	dc.l	pal+N
N	set	N+32
	ENDR
N	set	0
	REPT	NECR
	dc.l	pal+N
N	set	N+32
	ENDR

lim:
	REPT	NECR*2
	dc	10,30,20,30,0
	ENDR

pal:
	REPT	NECR
	dc.w	0
	dc.w	$777
	ds.w	14
	ENDR

	section	text
	; #] Datas:

	; #[ Real VBL:

att_vbl	dc.w	0

vbl:
	clr.b	$fffffa19.w
	subq	#1,att_vbl
	bgt.s	novbl
nvbl	=	*+2
	move	#1,att_vbl

	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
qtimer	=	*+2
	move.b	#220,$fffffa1f.w
	move.b	#7,$fffffa19.w

novbl:
	movem.l	d0-a6,-(a7)

	IFNE	MUSIC
	jsr	player+4
;	ELSEIF
;	move	#6*128/3,d0
;.wait:
;	dbra	d0,.wait
	ENDC

	jsr	waitc
	move.b	#$0d,$fffffc02.w ; Ask for mouse position

	movem.l	(a7)+,d0-a6
	rte
	; #] Real VBL:
	; #[ Timer VBL:

FREQUENCE	=	50

vbl2:
	movem.l	d0-a6,-(a7)

	addq	#1,cvbl
	addq	#1,cvbl1
qfreq	=	*+2
	cmpi	#FREQUENCE,cvbl1
	blt.s	okcvbl

	move	cvbl2,cvbl3
	clr	cvbl1
	clr	cvbl2
okcvbl:

	IFNE	DEBUG
	tst.b	qaffn
	beq.s	.no
	sub.l	a1,a1
	move	cvbl3,a1
	add	a1,a1
	add	a1,a1
	adda.l	#nombre,a1
	move.l	ec1,a0
	jsr	(a1)
.no:
	ENDC

	move.l	curec,a1
	sub.l	affec,a1
	cmpa.l	#2*4,a1
	blt.s	noswap

	addq	#1,cvbl2
	move.l	affec(pc),a0
	addq	#4,a0
	move.l	a0,affec
	move.l	(a0),curaffec
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	move.l	NECR*2*4*2(a0),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

noswap:
	IFNE	DEBUG
	tst.b	qaffn
	beq.s	.no
	adda.l	#nombre,a1
	move.l	ec1,a0
	lea	8*160(a0),a0
	jsr	(a1)
.no:
	ENDC

	movem.l	(a7)+,d0-a6
	clr.b	$fffffa19.w
	rte
	; #] Timer VBL:

 ; #] Vbl:
 ; #[ Affn:

affnr:
	tst	d0
	bge.s	.ok

	neg	d0
.ok:
	ext.l	d0
	divs	#100,d0
	add	d0,d0
	add	d0,d0
	jsr	nombre(pc,d0)

	swap	d0
	add	d0,d0
	add	d0,d0
	addq	#8,a0
	jmp	nombre(pc,d0)

nombre:
	incbin	zeroa99.bin
	even
	rts

affn:
	lea	num,a6

affn1:
	divs	#10,d7
	move.w	d7,-(a7)
	swap	d7
	addi.w	#'0',d7
	move.b	d7,-(a6)

	move.w	(a7)+,d7
	ext.l	d7
	bne.s	affn1

	Print	(a6)

	rts

 ; #] Affn:
 ; #[ Music:

	IFNE	MUSIC
player:	incbin	e:\music\replay.bin
music:	incbin	e:\music\coso\atomix.*
	even
	ENDC

 ; #] Music:
 ; #[ Palette:

palette:	dc.w	$000
.Blue0:	dc.w	$023,$034,$045,$056
.Red0:	dc.w	$510,$720,$740,$760
.BlueBis:	dc.w	$013,$024,$035,$046
	dc.w	$047,$555,$777

 ; #] Palette:

 ; #[ Variables:

	SECTION	BSS

	; #[ Variables_systemes:
oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.b	1
oldrez_tt	ds.b	1
oldec	ds.l	1
	; #] Variables_systemes:

	SECTION	DATA

ty1	dc.w	32000
ty2	dc.w	0
hy	dc.w	0

	SECTION	BSS

colorpoly	ds.w	1		; couleur du polygone

maxy	ds.w	1
miny	ds.w	1

tplot	ds.w	128*3	* Table des points apres calcul 3D

plot	ds.l	128	* 128 points max dans une forme 3D
	ds.w	2
pxy	ds.l	16	* Tableau du polygone

tpxy1	ds.l	16	* 16 points maximum pour les polygone remplis.
tpxy2	ds.l	16

	ds.w	NBLIG*2
points_gauche	ds.w	NBLIG
	ds.w	NBLIG*2
points_droite	ds.w	NBLIG
	ds.w	NBLIG*2

num	ds.b	20

	ds.b	256
ecran	ds.b	32000*NECR+256
	even
 ; #] Variables:

