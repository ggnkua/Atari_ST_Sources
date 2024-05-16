	; ------------------------------------------- ;
	;        The maxi-optimyzed 3D Z-rout	 ;
	; (C) 1989-90 Vincent PENNE (Ziggy STARDUST). ;
	; ------------------------------------------- ;
	
	output	3d1.tos
	opt	o+,ow-,m+
	opt	P=68030
	
 ; #[ Constantes et macros:

TRUE	=	-1
FALSE	=	0

; Parametre systeme
NECR	=	8
DEBUG	=	TRUE
TSTCOL	=	TRUE
BOMB	=	FALSE
MUSIC	=	FALSE
PLOT	=	FALSE
MONIMONO	=	TRUE

	IFNE	DEBUG
	opt	x+
	ELSEIF
	opt	d-,x-
	ENDC
	
; Variable pour les calculs 3D
TSINUS	=	1024
DISTEC	=	32

; Organisation de la palette (Pour l'instant 1 plan par couleur)
COLFOND	=	$000
TAILPAL	=	16	; (Jusqu'a 512!!)
MINCOL	=	0
MAXCOL	=	3

; Parametre pour le tracage des lignes horizontales, configuration de l'ecran
NBLIG	=	200
LECRAN	=	320
DEPASSE	=	512
MINX	=	0
MAXX	=	320
CX	=	160	; Centre de l'ecran
CY	=	100
MIX	=	MINX	; Fenetre de clipping
MIY	=	0
MAX	=	MAXX-1
MAY	=	NBLIG
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

	IFNE	PLOT
	bsr	makeplot
	ENDC
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
	
	lea	$8.w,a0	; Redirection des bombes
	move.l	#fin,d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	ENDC
	
	move.l	#trap3,$80+3*4.w

	move	#$2700,sr ; Pour changer de moniteur sans reset.
	IFNE	MONIMONO
	not	$ffff8240.w
	ENDC
	bsr	relocation ; On attend pas pour rien.
	andi.b	#%11,oldrez
	IFNE	MONIMONO
	cmpi.b	#2,oldrez
	bne.s	.okmoni
	
.waitmoni:
	btst	#7,$fffffa01.w
	beq.s	.waitmoni
	
	Vsync_no_interrupt
	clr.b	$ffff8260.w
	
.waitsp:
	cmpi.b	#$39,$fffffc02.w
	bne.s	.waitsp
.waitsp2:
	cmpi.b	#$39,$fffffc02.w
	beq.s	.waitsp2
	
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

	move.b	ec1+3*4-4+1,$ffff8201.w
	move.b	ec1+3*4-4+2,$ffff8203.w
	
	rts

q68000	dc.w	0

	ds.b	256
	
jump68000:
	st	q68000
	move.l	#$4e714e71,putnop
	
	rte
	
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
	
	section	bss
	
oldvec	ds.l	24
oldmfp	ds.b	24

	section	text
	
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

ABSOLUTE_MOUSE	=	TRUE
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
	
Touche_objet	MACRO
	tst.b	\1(a0)
	beq.s	.\@
	
	move.l	#def_objets+\2*4,curobj
.\@
	ENDM
	
Touche_font	MACRO
	tst.b	\1(a0)
	beq.s	.\@
	
	move.l	#font3d+\2*4,curobj
.\@
	ENDM
	
Touche_objet2	MACRO
	tst.b	\1(a0)
	beq.s	.\@
	
	move.l	#def_objets3+\2*4,curobj
.\@
	ENDM
	
VITEZOOM	=	2
	
test_touche:
	btst	#0,mousek
	beq.s	.no
	addi	#VITEZOOM,obsz
.no:
	Flab
	btst	#1,mousek
	beq.s	.no
	subi	#VITEZOOM,obsz
.no:
	
	lea	clav(pc),a0
	
	Flab
	tst.b	$4e(a0)	; '+'?
	beq.s	.no
	addi	#VITEZOOM,obsz
.no:
	Flab
	tst.b	$4a(a0)	; '-'?
	beq.s	.no
	subi	#VITEZOOM,obsz
.no:
	Flab
	tst.b	$72(a0)	; <Enter>?
	beq.s	.no
	addi	#VITEZOOM*10,obsz
.no:
	Flab
	tst.b	$66(a0)	; '*'?
	beq.s	.no
	subi	#VITEZOOM*10,obsz
.no:
	Flab
	tst.b	$1(a0)	; <Esc>?
	beq.s	.no
	illegal
.no:
	Flab
	tst.b	$39(a0)	; <Espace>?
	beq.s	.no
	jmp	fin
.no:
	Flab
	tst.b	59(a0)	; <F1>?
	beq.s	.no
	st	$f(a0)
.no:
	Flab
	tst.b	60(a0)	; <F2>?
	beq.s	.no
	st	qaffn
.no:

	tst.b	qaffn
	beq	no_more_test_touch
	
	Flab
	tst.b	61(a0)	; <F3>?
	beq.s	.no
	sf	qaffn
	move	#NECR,neffecr
.no:
	Flab
	tst.b	62(a0)	; <F4>?
	beq.s	.no
	move	#1,nvbl
.no:
	Flab
	tst.b	63(a0)	; <F5>?
	beq.s	.no
	move	#2,nvbl
.no:
	Flab
	sf	tcol
	tst.b	$f(a0)	; <Tab>?
	beq.s	.no

	st	tcol	
.no:

	Flab
	tst.b	$68(a0)	; "8"?
	beq.s	.no
	addq	#1,va
.no:
	Flab
	tst.b	$6E(a0)	; "2"?
	beq.s	.no
	subq	#1,va
.no:
	Flab
	tst.b	$6C(a0)	; "6"?
	beq.s	.no
	addq	#1,vb
.no:
	Flab
	tst.b	$6A(a0)	; "4"?
	beq.s	.no
	subq	#1,vb
.no:
	Flab
	tst.b	$69(a0)	; "9"?
	beq.s	.no
	addq	#1,vg
.no:
	Flab
	tst.b	$6D(a0)	; "1"?
	beq.s	.no
	subq	#1,vg
.no:
	Flab
	tst.b	$0E(a0)	; <Backspace>?
	beq.s	.no
	clr	va
	clr	vb
	clr	vg
.no:

	Flab
	tst.b	$61(a0)	; <Undo>?
	beq.s	.no
		;#[ Reinit:
	move	#MAX_MOUSEX/2,mousex
	move	#MAX_MOUSEY/2,mousey
	move	#$2700,sr
	
	moveq	#128/4-1,d0
	move.l	a0,a1
.cl_clav:
	clr.l	(a1)+
	dbra	d0,.cl_clav
	
	bsr	init_mouse
	move	#$2300,sr
	
	lea	init_val(pc),a1
	lea	current_val(pc),a2
	moveq	#(init_val-current_val)/2-1,d0
.loop:
	move	(a1)+,(a2)+
	dbra	d0,.loop
	
		;#] Reinit:
	rts
.no:

	Touche_objet	2,0
	Touche_objet	3,1
	Touche_objet	4,2
	Touche_objet	5,3
	Touche_objet	6,4
	Touche_objet	7,5
	Touche_objet	8,6
	Touche_objet	9,7
	Touche_objet	10,8
	
	Touche_font	16,0
	Touche_font	17,1
	Touche_font	18,2
	Touche_font	19,3
	Touche_font	20,4
	Touche_font	21,25
	Touche_font	22,24
	Touche_font	23,23
	Touche_font	24,22
	Touche_font	25,17
	
	Touche_objet2	29,0
	Touche_objet2	30,1
	Touche_objet2	31,2
	Touche_objet2	32,3
	Touche_objet2	33,4
	Touche_objet2	34,5
	Touche_objet2	35,6
	Touche_objet2	36,7
	Touche_objet2	37,8
	Touche_objet2	38,9
	Touche_objet2	39,10
	Touche_objet2	40,11
	Touche_objet2	41,12
	Touche_objet2	42,13
	Touche_objet2	43,14
	Touche_objet2	44,15
	Touche_objet2	45,16
	Touche_objet2	46,17
	
no_more_test_touch:
	rts
	; #] Test touche:

 ; #] Clavier interupt:
 ; #[ Supervisor/User mode:
 
trap3:		; Pour passer en superviseur rapidement
	move	#$2300,(a7)
	rte
	
retour:
	move.l	oldpile(pc),a7
	trap	#3
	rts
	
oldpile	dc.l	0
	
 ; #] Supervisor/User mode:

 ; #[ Forme relocation:
;------------------------------
; Liste des routine:	;
;------------------------------
; 'Defp' : def_plot	;
; 'Anim' : anime_plot	;
; 'Anil' : ani_loop_plot	;
; 'Inic' : init_color	;
; 'Setc' : set_color	;
; 'Setp' : set-plane	;
; 'Affp' : affpoly	;
; 'F1p ' : face1p	;
; 'F1pt' : face1pt	;
; '1pti' : faceipti	;
; 'Hide' : hide	;
; 'Goto' : goto	;
; 'Enab' : enable	;
; 'Disa' : disable	;
; 'Fin ' : fin_afforme	;
;------------------------------

relocation:
	lea	def_objets,a1
	bsr.s	reloc_obj
	lea	def_objets2,a1
	bsr.s	reloc_obj
	lea	def_objets3,a1
	bsr.s	reloc_obj
	lea	font3d,a1
	bsr	reloc_obj

	lea	def_objets,a0
	lea	fin_routine_list(pc),a3
.reloc:
	lea	routine_list(pc),a2
	move.l	(a0),d1
	cmpi.l	#'Finr',d1
	beq.s	.fin_relocate
.reloc2:
	cmp.l	(a2)+,d1
	beq.s	.ident
	
	addq	#4,a2
	cmpa.l	a3,a2
	blt.s	.reloc2

	bra.s	.noident	
.ident:
	cmpi.l	#'Anim',d1
	beq.s	.defp
	cmpi.l	#'Anil',d1
	beq.s	.defp
	cmpi.l	#'Defp',d1
	bne.s	.nodefp
.defp:
	move.l	a0,d0
	addq.l	#4,d0
	add.l	d0,4(a0)
.nodefp:
	move.l	(a2)+,(a0)

.noident:

	addq	#2,a0
	bra.s	.reloc
	
.fin_relocate:
	rts

reloc_obj:	
	move.l	a1,d1
.reloc_def:
	move.l	(a1),d0
	cmpi.l	#"Find",d0
	beq.s	.fin_reloc_def
	add.l	d1,d0
	move.l	d0,(a1)+
	bra.s	.reloc_def
	
.fin_reloc_def:
	rts
	
routine_list:
	dc.b	"Defp"
	dc.l	def_plot
	
	dc.b	"Anim"
	dc.l	anime_plot
	
	dc.b	"Anil"
	dc.l	ani_loop_plot

	dc.b	"Inic"
	dc.l	init_color
	
	dc.b	"Setc"
	dc.l	set_color
	
	dc.b	"Setp"
	dc.l	set_plane
	
	dc.b	"Affp"
	dc.l	affpoly
	
	dc.b	"F1p "
	dc.l	face1p
	
	dc.b	"F1pt"
	dc.l	face1pt
	
	dc.b	"1pti"
	dc.l	face1pti
	
	dc.b	"Shpr"
	dc.l	sphere
	
	dc.b	"Hide"
	dc.l	hide
	
	dc.b	"Goto"
	dc.l	goto
	
	dc.b	"Enab"
	dc.l	enable
	
	dc.b	"Disa"
	dc.l	disable
	
	dc.b	"Fin "
	dc.l	fin_afforme
fin_routine_list:

 ; #] Forme relocation:
 ; #[ Afforme:

; ------------------------------------------------------------------------ ;
;	           Affichage d'une forme 3D		;
; ------------------------------------------------------------------------ ;
; A1 : Adresse de la structure d'objet
; Obja, objb, etc... sont pris en comptes.

	; #[ Datas:
		
current_val:		; Doivent etre consecutif
		; Position de l'observateur --->
obsx	dc.w	0
obsy	dc.w	0
obsz	dc.w	-312

obsa	dc.w	0	; Angle Alpha
obsb	dc.w	0	; Beta
obsg	dc.w	0	; et Gamma...

		; Position de l'objet --->
objx	dc.w	0
objy	dc.w	0
objz	dc.w	0

obja	dc.w	0
objb	dc.w	0
objg	dc.w	0

		; Vitesse angulaire --->
va	dc.w	0
vb	dc.w	0
vg	dc.w	0
		; Objet courant --->
curobj	dc.l	def_objets

init_val:
		; Position de l'observateur --->
	dc.w	0,0,-308	; X Y Z
	dc.w	0,0,0	; A B G

		; Position de l'objet --->
	dc.w	0,0,30	; X Y Z
	dc.w	0,0,0	; A B G

		; Vitesse angulaire --->
	dc.w	-3,6,-9	; VA VB VG
		; Objet courant --->
	dc.l	def_objets
	
m1	ds.w	1	; Doivent etre consecutifs!
m2	ds.w	1
m3	ds.w	1
n2	ds.w	1
n1	ds.w	1
n3	ds.w	1
o3	ds.w	1
o1	ds.w	1
o2	ds.w	1
x	dc.w	0
y	dc.w	0
z	dc.w	0
			; Limites minimal a effacer -->
limx1	ds.w	1
limx2	ds.w	1
limy1	ds.w	1
limy2	ds.w	1

sincos:			; Table de sinus et cosinus
	incbin	sincos
	even
	
ty1	dc.w	32000
ty2	dc.w	0

colorpoly	ds.w	1	; couleur du polygone

maxy	ds.w	1
miny	ds.w	1

curcol	dc.w	0
curpal	dc.l	pal2
;palette:
;	incbin	palette.pal
pal2:
 dc.w 0,$333,$444,$555,$666,$330,$550,$770,$700,$500,$007,$005,$500,$700,$770,$777
 ;    0   1	2    3    4	5    6    7	8    9    10	11   12   13	14  15
dispal	ds.b	TAILPAL
	even
affpal	dc.l	pal
	; #] Datas:
	; #[ Quelques MACROs...:
Tstx	MACRO

	cmpi	#-DEPASSE+1,\1
	bgt.s	.dep1\@

	move	#-DEPASSE+1,\1
.dep1\@:

	cmpi	#DEPASSE-1+LECRAN,\1
	blt.s	.dep2\@
	
	move	#DEPASSE-1+LECRAN,\1
.dep2\@:

	cmp	limx1(pc),\1
	bge.s	.l1\@
	move	\1,limx1
.l1\@:
	cmp	limx2(pc),\1
	ble.s	.l2\@
	move	\1,limx2
.l2\@:
	ENDM
	
Tsty	MACRO
	cmp	limy1(pc),\1
	bge.s	.l1\@
	move	\1,limy1
.l1\@:
	cmp	limy2(pc),\1
	ble.s	.l2\@
	move	\1,limy2
.l2\@:
	ENDM
	
Next	MACRO
	move.l	(a1)+,a3
	jmp	(a3)
	ENDM
	
	; #] Quelques MACROs...:

	; #[ Afforme:
afforme:
	Tstcol	$770
	
	Next
	
fin_afforme:
	rts
	; #] Afforme:
	
	; #[ Def_plot:
def_plot:
	move.l	(a1)+,a5
	; #] Def_plot:
	; #[ Calcul plot:
calcul_plot:
	lea	objx(pc),a2
	lea	obsx(pc),a3
		;#[ Translation: (Ramene a l'observateur)
	move	(a2)+,d0
	sub	(a3)+,d0
	move	d0,x
	move	(a2)+,d0
	sub	(a3)+,d0
	move	d0,y
	move	(a2)+,d0
	sub	(a3)+,d0
	move	d0,z
		;#] Translation:
		;#[ Init matrice: (Pour rotations)
	lea	sincos(pc),a0	; Table des sinus et cosinus...
sab	EQUR	d2
cab	EQUR	d3
sbb	EQUR	d4
cbb	EQUR	d5
sgb	EQUR	d6
cgb	EQUR	d7
	move	(a2)+,d0
	add	d0,d0
	add	d0,d0
	movem	(a0,d0),sab/cab

	move	(a2)+,d0
	add	d0,d0
	add	d0,d0
	movem	(a0,d0),sbb/cbb

	move	(a2)+,d0
	add	d0,d0
	add	d0,d0
	movem	(a0,d0),sgb/cgb
	
			; Preparation matrice
	lea	m1(pc),a6
	move	sab,d0
	muls	cgb,d0
	move	cab,d1
	muls	sbb,d1
	add.l	d1,d1
	swap	d1
	muls	sgb,d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; m1
	
	move	cab,d0
	muls	cbb,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; m2
	
	move	sab,d0
	muls	sgb,d0
	move	cab,d1
	muls	sbb,d1
	add.l	d1,d1
	swap	d1
	muls	cgb,d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; m3
	
	move	sbb,(a6)+	; n2
	
	move	cbb,d0
	muls	sgb,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a6)+	; n1
	
	move	cbb,d0
	muls	cgb,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; n3

	move	cab,d0
	muls	sgb,d0
	move	sab,d1
	muls	sbb,d1
	add.l	d1,d1
	swap	d1
	muls	cgb,d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; o3
	
	move	cab,d0
	muls	cgb,d0
	move	sab,d1
	muls	sbb,d1
	add.l	d1,d1
	swap	d1
	muls	sgb,d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a6)+	; o1
	
	move	sab,d0
	muls	cbb,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a6)+	; o2
	
		;#] Init matrice:
	
	Tstcol	$707
	lea	projection,a0
	
	move	(a5)+,d0	; Nbr de points
.loop_plot:
	movem	(a5)+,d2/d3/d7	  (X,Y,Z)
		;#[ Rotation:	  (autour du centre de l'objet)
	lea	m1(pc),a2
	; Rotation X
	move	d2,d6
	muls	(a2)+,d6
	move	d3,d5
	muls	(a2)+,d5
	add.l	d5,d6
	move	d7,d5
	muls	(a2)+,d5
	add.l	d6,d5
	add.l	d5,d5
	swap	d5
	
	; Rotation Y
	move	d3,d4
	muls	(a2)+,d4
	move	d2,d6
	muls	(a2)+,d6
	add.l	d6,d4
	move	d7,d6
	muls	(a2)+,d6
	add.l	d4,d6
	add.l	d6,d6
	swap	d6

	; Rotation Z
	muls	(a2)+,d7
	muls	(a2)+,d2
	muls	(a2)+,d3
	add.l	d2,d7
	add.l	d3,d7
	add.l	d7,d7
	swap	d7
		;#] Rotation:
		;#[ Translation: (On ramene tout au centre de l'objet)
	add	(a2)+,d5
	add	(a2)+,d6
	add	(a2)+,d7
	neg	d6
		;#] Translation:
		;#[ Projection:  (Sur la plan XY)
	cmpi	#DISTEC,d7	; Z inf‚rieur … DISTEC?
	ble.s	.clipz	; Oui --> Pas de projections!

	; Avec ZOOM = 256
	ext.l	d5
	asl.l	#8,d5
	divs	d7,d5
	addi	#CX,d5
	Tstx	d5
	add	d5,d5
	add	d5,d5
	
	ext.l	d6
	asl.l	#8,d6
	divs	d7,d6
	addi	#CY,d6
	Tsty	d6
	
.clipz:
	move	d5,(a0)+
	move	d6,(a0)+
	move	d7,(a0)+
		;#] Projection:
	dbra	d0,.loop_plot

	Tstcol	$000
	Next
	
		;#] Calcul points 3d:
	; #] Calcul plot:
	; #[ Anime plot:
anime_plot:
	move.l	(a1)+,a5
	move.l	a5,a4
	move	(a1),d0
	adda	d0,a5
	move	(a5),d1
	add	d1,d1
	add	d1,d0
	add	d1,d1
	add	d1,d0
	addq	#8,d0
	
	tst	(a4,d0)
	bge.s	.no_last_anime
	
	moveq	#0,d0
.no_last_anime:
	move	d0,(a1)+
	
	bra	calcul_plot
	; #] Anime plot:
	; #[ Loop plot:
ani_loop_plot:
	move.l	(a1)+,a5
	move.l	a5,a4
	move	(a1),d0
	adda	d0,a5
	move	(a5),d1
	add	d1,d1
	add	d1,d0
	add	d1,d1
	add	d1,d0
	addq	#8,d0
	
	tst	(a4,d0)
	bge.s	.no_last_anime
	
	move.l	#ani_loop_plot2,-8(a1)
	move.l	a4,a5
	bra.s	ani_loop_plot2_jmp
.no_last_anime:
	move	d0,(a1)+
	
	bra	calcul_plot

ani_loop_plot2:
	move.l	(a1)+,a5
	move.l	a5,a4
ani_loop_plot2_jmp:
	move	(a1),d0
	adda	d0,a5
	move	(a5),d1
	add	d1,d1
	sub	d1,d0
	add	d1,d1
	sub	d1,d0
	subq	#8,d0
	
	tst	d0
	bge.s	.no_last_anime

	move.l	#ani_loop_plot,-8(a1)
	moveq	#0,d0

.no_last_anime:
	move	d0,(a1)+
	
	bra	calcul_plot
	; #] Loop plot:

	; #[ Init color:
cur_dispal	dc.l	0
cur_plane	dc.w	0
	
init_color:
	lea	dispal(pc),a6
	REPT	TAILPAL
	move.b	#-1,(a6)+
	ENDR
	move	(a1)+,d1	; Couleur No 1
	lea	dispal(pc),a6
	clr.b	(a6,d1)
	move.l	affpal(pc),a6
	move	#COLFOND,(a6)+	; Couleur 0 = couleur de fond
	move.l	curpal,a4
	add	d1,d1
	move	(a4,d1),(a6)+
	move.l	a6,cur_dispal
	move	#MINCOL,cur_plane
	
	Next
	; #] Init color:
	; #[ Set color:
set_color:
	move.l	cur_dispal(pc),a6
	move	cur_plane(pc),d6
	move	(a1)+,d0	; Couleur de la face
	
	lea	dispal(pc),a2
	tst.b	(a2,d0)
	bge.s	.okcol
	
	cmpi	#MAXCOL,d6
	blt.s	.nomaxcol
	
	move.b	#MAXCOL,(a2,d0)
	bra.s	.okcol
	
.nomaxcol:
	addq	#1,d6
	move.b	d6,(a2,d0)
	move	d6,d2
	
	cmpi.b	#4-1,d6
	bne.s	.col1
	move	#8-1,d2
.col1:
	
	cmpi.b	#3-1,d6
	bne.s	.col2
	move	#4-1,d2
.col2:

	move.l	curpal,a2
	move	d0,d3
	add	d3,d3
	move	(a2,d3),d3
.copal:
	move	d3,(a6)+
	dbra	d2,.copal
	
	lea	dispal(pc),a2
	
.okcol:
	move.b	(a2,d0),d2
	ext	d2
	move	d2,colorpoly
	bset	d2,used_plane
	
	move.l	a6,cur_dispal
	move	d6,cur_plane
	
	Next
	; #] Set color:
	; #[ Set plane:
set_plane:
	move	(a1)+,d2
	bset	d2,used_plane
	move	d2,colorpoly
	Next
	; #] Set plane:

	; #[ Hide:
hide:
	Tstcol	$070
	
	lea	projection,a0
	
	movem	(a1)+,d4/d5/d7
	
	cmpi	#DISTEC,4(a0,d4) ; Point derriere ecran?
	blt.s	.ok ; Oui --> On ne peut pas tester la visibilit‚e
	cmpi	#DISTEC,4(a0,d5)
	blt.s	.ok
	cmpi	#DISTEC,4(a0,d7)
	blt.s	.ok
	
	move	(a0,d4),d3
	move	(a0,d7),d1
	sub	(a0,d5),d3
	sub	(a0,d5),d1
	move	2(a0,d7),d2
	sub	2(a0,d5),d2
	muls	d2,d3
	move	2(a0,d4),d2
	sub	2(a0,d5),d2
	muls	d2,d1
	cmp.l	d3,d1		; Face visible?
	bgt.s	.ok		; Oui --> Ok

	add	(a1),a1
	Next
	
.ok:
	addq	#2,a1
	Next
	; #] Hide:
	; #[ Goto face:
goto:
	add	(a1),a1
	Next
	; #] Goto face:

	; #[ Enable:
enable:
	move	(a1)+,d3
	move.l	#enabled,-2(a1,d3)
	Next
	; #] Enable:
	; #[ Disable:
disable:
	move	(a1)+,d3
	move.l	#disabled,-2(a1,d3)
	Next
	; #] Disable:
	; #[ Enabled:
enabled:
	move.l	#hide,-4(a1)
	addq	#8,a1
	Next
	; #] Enabled:
	; #[ Disabled:
disabled:
	move.l	#hide,-4(a1)
	addq	#6,a1
	adda	(a1),a1
	Next
	; #] Disabled:

	; #[ Init 1 plane face:
face1p:
	move.l	#hline_one_plane,curline
	Next
	; #] Init 1 plane face:
	; #[ Init 1 plane tramed face:
face1pt:
	move.l	#hline_one_plane_tramed,curline
	Next
	; #] Init 1 plane tramed face:
	; #[ Init inversed 1 plane tramed face:
face1pti:
	move.l	#hline_inversed_one_plane_tramed,curline
	Next
	; #] Init inversed 1 plane tramed face:

	; #[ Sphere:
sphere:
	move	(a1)+,d3
	move	(a1)+,d1
	
	lea	projection,a2
	move	4(a2,d3),d0
	cmpi	#DISTEC,d0
	blt.s	.nosphere

	ext.l	d1	; Calcul du rayon
	asl	#8,d1
	divs	d0,d1

	cmpi	#2,d1	
	bgt.s	.ok

.nosphere:
	Next	
.ok:
	move	2(a2,d3),d2
	move	(a2,d3),d3
	move.l	a1,-(a7)
	
	move	d2,d4
	move	d2,d5
	add	d1,d4
	sub	d1,d5
	Tsty	d4
	Tsty	d5
	
	move	d3,d4
	asr	#2,d4
	move	d4,d5
	add	d1,d4
	sub	d1,d5
	Tstx	d4
	Tstx	d5
	
	move	d1,-(a7)
	move	d2,-(a7)
	bsr	circle
	move	(a7)+,d0
	move	(a7)+,d1
	
	sub	d1,d0
	add	d1,d1
	
	move.l	ec1,a6
	move	colorpoly,d7
	add	d7,d7
	adda	d7,a6
	bsr	call_line
	move.l	(a7)+,a1
	
	Next
	; #] Sphere:

	; #[ Affpoly:
affpoly:
	Tstcol	$700

	lea	projection,a0
	lea	pxy,a5
	move.l	a5,a6
	move.l	a5,a4
	move	#32767,d1
	move	(a1)+,d0	; --> No 1er point
	
.loop_plot:			; Place les points dans la table.
	move.l	(a0,d0),d5
	cmpi	#DISTEC,4(a0,d0)
	blt.s	.clipz
	cmp	d1,d5
	bge.s	.highter
	move.l	a5,a4
	move	d5,d1
.highter:
	move.l	d5,(a5)+
.clipz:
	move	(a1)+,d0
	bge.s	.loop_plot
	
	cmp	#MAY,d1	; Polygone sous ecran?
	ble.s	.okpoly
	Next		; On sort
.okpoly:
	
	move.l	a5,d7
	sub.l	#pxy,d7	; Y'a-t-il moins de trois segments?
	cmpi	#3*2,d7
	ble	nopoly
	
	Tstcol	$007	
	move.l	a1,-(a7)
	
; ------------------------------------------------------------------------ ;
;		 Filled polygone,		;
; ------------------------------------------------------------------------ ;
; A4: Adresse du point le plus haut dans la liste
; A5: Adresse du dernier point de la liste
; A6: Adresse du premier point de la liste
	
	move	2(a4),d0
	move	#MAY,d7
	cmp	#MIY,d0	; Miny plus petit que miy?
	bge.s	.cnegaplot	; Non
	move	#MIY,d0
.cnegaplot:
	move	d0,d5

	lea	points_droite,a2
	move.l	a4,a3
	lea	retour_right(pc),a1
	lea	calc_plot(pc),a0
		;#[ Calcul right plot:
; D0 : Position Y courante
; D7 : May
; A2 : Table points droites
; A4 : Adresse points le plus haut
; A5 : Adresse du dernier point
; A6 : Adresse du premier point
	move	(a4)+,d1	; X1
	move	(a4)+,d2	; Y1
	cmp.l	a5,a4
	blt.s	.ok

	move.l	a6,a4
.ok:
	movem	(a4),d3-d4	; X2 Y2
	cmp.l	a3,a4
	beq.s	fin_plotr
loop_plotr:
	cmp	d0,d4
	ble.s	new_plotr
	move	d4,d6
	cmp	d7,d6	; Point plus bas que may?
	blt.s	.oklow	; Non
	move	d7,d6
	cmp	d2,d7	; Y2 superieur a Y1 courant?
	ble.s	fin_plotr
.oklow:
	sub	d1,d3
	sub	d2,d4

	cmp	#MIY,d2
	bge.s	.noclip
	sub	d0,d2	; On cherche X de d‚part par rapport … D0
	muls	d3,d2
	divs	d4,d2
	sub	d2,d1
.noclip:

	ext.l	d3
	lsl.l	#5,d3
	divs	d4,d3
	ext.l	d3
	lsl.l	#8,d3
	lsl.l	#3,d3

	sub	d6,d0
	bge.s	retour_right
	swap	d1
	move	d3,d1
	beq	fast_plot
	addi	#$8000,d1
	swap	d1
	swap	d3
	add	d0,d0
	add	d0,d0
	jmp	(a0,d0)

retour_right:	
	move	d6,d0
	
new_plotr:
	move	(a4)+,d1	; X1
	move	(a4)+,d2	; Y1
	cmp.l	a5,a4
	blt.s	.ok

	move.l	a6,a4
.ok:
	movem	(a4),d3-d4	; X2 Y2
	cmp.l	a3,a4
	bne.s	loop_plotr
	
fin_plotr:
		;#] Calcul right plot:

	lea	points_gauche,a2
	addq	#4,a3
	move.l	a3,a4
	move	d5,d0
	lea	retour_left(pc),a1
		;#[ Calcul left plot:
; D0 : Position Y courante
; D7 : May
; A2 : Table points gauches
; A4 : Adresse points le plus haut
; A5 : Adresse du dernier point
; A6 : Adresse du premier point
	move	-(a4),d2	; Y1
	move	-(a4),d1	; X1
	cmp.l	a6,a4
	bgt.s	.ok
	move.l	a5,a4
.ok:
	movem	-4(a4),d3-d4	; X2 Y2

	cmp.l	a3,a4
	beq.s	fin_plotl
loop_plotl:
	cmp	d0,d4
	ble.s	new_plotl
	move	d4,d6
	cmp	d7,d6	; Point plus bas que may?
	blt.s	.oklow	; Non
	move	d7,d6
	cmp	d2,d7	; Y2 superieur a Y1 courant?
	ble.s	fin_plotl
.oklow:
	sub	d1,d3
	sub	d2,d4

	cmp	#MIY,d2
	bge.s	.noclip
	sub	d0,d2	; On cherche X de d‚part par rapport … d0
	neg	d2
	muls	d3,d2
	divs	d4,d2
	add	d2,d1
.noclip:

	ext.l	d3
	lsl.l	#5,d3
	divs	d4,d3
	ext.l	d3
	lsl.l	#8,d3
	lsl.l	#3,d3

	sub	d6,d0
	bge.s	retour_left
	swap	d1
	move	d3,d1
	beq.s	fast_plot
	addi	#$8000,d1
	swap	d1
	swap	d3
	add	d0,d0
	add	d0,d0
	jmp	(a0,d0)

retour_left:
	move	d6,d0

new_plotl:
	move	-(a4),d2	; Y1
	move	-(a4),d1	; X1
	cmp.l	a6,a4
	bgt.s	.ok
	move.l	a5,a4
.ok:
	movem	-4(a4),d3-d4	; X2 Y2

	cmp.l	a3,a4
	bne.s	loop_plotl
	
fin_plotl:
		;#] Calcul left plot:

	move	d0,d1
	sub	d5,d1
	move	d5,d0
	move	colorpoly(pc),d2
	move.l	ec1,a6
	add	d2,d2
	adda	d2,a6

	Tstcol	$077	
	lea	points_gauche,a4
	lea	points_droite,a5

	bsr	call_line_no_clip
	
	move.l	(a7)+,a1
	
nopoly:
	Next
	
		;#[ Particular case:
fast_plot:
	swap	d1
	swap	d3
;	beq.s	very_fast_plot
	
	add	d0,d0
	add	d0,d0
	lea	calc_fplot(pc),a0
	jmp	(a0,d0)
	
very_fast_plot:
	bclr	#0,d0
	bne.s	.no
	move	d1,(a2)+
.no:
	move	d1,d2
	swap	d1
	move	d2,d1
	lea	calc_vfplot(pc),a0
	jmp	(a0,d0)
		;#] Particular case:
		;#[ Calcul plot:
	dcb.l	NBLIG,$34c1d383
	; #[ --> Ca veut dire:
;	move	d1,(a2)+
;	addx.l	d3,d1
	; #] --> Ca veut dire:
calc_plot:
	jmp	(a1)
	
	dcb.l	NBLIG,$34c1d243
	; #[ --> Ca veut dire:
;	move	d1,(a2)+
;	add	d3,d1
	; #] --> Ca veut dire:
calc_fplot:
	lea	calc_plot(pc),a0
	jmp	(a1)
	
	dcb.w	NBLIG/2,$24c1
	; #[ --> Ca veut dire:
;	move.l	d1,(a2)+
	; #] --> Ca veut dire:
calc_vfplot:
	lea	calc_plot(pc),a0
	jmp	(a1)
		;#] Calcul plot:
	
	; Pas encore implant‚:
		;#[ Calcul screen intersection:
	IFNE	FALSE
	cmpi	#$8000,(a0,d0) ; Point derriere ecran?
	bne	.no_clipz	; Non
			; Oui --> calcul intersection
	add	d0,d3
	move	-4(a1),d4
	cmpa.l	a2,a1	; Premier point?
	bgt.s	.nofirstp	; Non
	
	move.l	a1,a3
.find_end:
	tst	(a3)+
	bge.s	.find_end
	
	move	-4(a3),d4
	lea	plot3d,a3
.nofirstp:
	move	d4,d2
	add	d4,d2
	add	d4,d2
	add	d2,d2		; * 6
	cmpi	#DISTEC,4(a3,d2)
	ble	.badp1
	
	; cx + zoom * ((x + (xx - x) * (DISTEC - z)) / (zz - z)) / DISTEC
	move	(a3,d3),d4
	sub	(a3,d2),d4
	move	#DISTEC,d5
	sub	4(a3,d2),d5
	muls	d5,d4
	move	4(a3,d3),d5
	sub	4(a3,d2),d5
	divs	d5,d4
	add	(a3,d2),d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	addi	#CX,d4
	
	Tstx	d4
	move	d4,(a2)+
	
	; cy + zoom * ((y + (yy - y) * (DISTEC - z)) / (zz - z)) / DISTEC
	move	2(a3,d3),d4
	sub	2(a3,d2),d4
	move	#DISTEC,d5
	sub	4(a3,d2),d5
	muls	d5,d4
	move	4(a3,d3),d5
	sub	4(a3,d2),d5
	divs	d5,d4
	add	2(a3,d2),d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	addi	#CY,d4
	
	Tsty	d4
	move	d4,(a2)+
	
.badp1:
	move	(a1),d4
	bge.s	.nolastp		; Si dernier point
	move	-2(a2),d4
.nolastp:
	move	d4,d2
	add	d4,d2
	add	d4,d2
	add	d2,d2
	cmpi	#DISTEC,4(a3,d2)
	ble	.badp2
	
	; cx + zoom * ((x + (xx - x) * (DISTEC - z)) / (zz - z)) / DISTEC
	move	(a3,d3),d4
	sub	(a3,d2),d4
	move	#DISTEC,d5
	sub	4(a3,d2),d5
	muls	d5,d4
	move	4(a3,d3),d5
	sub	4(a3,d2),d5
	divs	d5,d4
	add	(a3,d2),d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	addi	#CX,d4
	
	Tstx	d4
	move	d4,(a2)+
	
	; cy + zoom * ((y + (yy - y) * (DISTEC - z)) / (zz - z)) / DISTEC
	move	2(a3,d3),d4
	sub	2(a3,d2),d4
	move	#DISTEC,d5
	sub	4(a3,d2),d5
	muls	d5,d4
	move	4(a3,d3),d5
	sub	4(a3,d2),d5
	divs	d5,d4
	add	2(a3,d2),d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	addi	#CY,d4
	
	Tsty	d4
	move	d4,(a2)+
	
.badp2:
	bra	.loop_plot
.no_clipz:
	ENDC
		;#] Calcul screen intersection:

	; #] Affpoly:

 ; #] Afforme:

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
	add	d2,d3
	adda	d3,a6
	
curline	=	*+2
	jmp	$0.l
	
	rts
	
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
bord:
	dc	%111111111111111,%11111111111111,%1111111111111,%111111111111,%11111111111,%1111111111,%111111111,%11111111,%1111111,%111111,%11111,%1111,%111,%11,%1,0

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
	
	section	bss

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

	section	text
	
	; #] Genere hline:
	
 ; #] Very fast horizontal line:
 ; #[ Circle rout:
; ------------------------------------------------------------------------ ;
;		Routine de cercle.		;
; ------------------------------------------------------------------------ ;

	; #[ Calling rout:
; D1 = Rayon du cercle
; D2 = Position Y de centre du cercle
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
genere_circle:
	lea	debut_circle_rout,a1
	move	#(NBLIG+DEPASSE)/3-1,d0
	
.g_circle:
	lea	circle1(pc),a0
	move	#(circle2-circle1)/2-1,d1
.g_circle2:
	move	(a0)+,(a1)+
	dbra	d1,.g_circle2
	dbra	d0,.g_circle
	
	move	#$4e75,(a1)+
	
	rts

	section	bss
	
debut_circle_rout:
	ds.b	(circle2-circle1)*NBLIG*2
circle_rout:
	ds.w	1
	
	section	text
	; #] Genere cercle:
	
 ; #] Circle rout:

 ; #[ Main programm:

mainloop:
	bsr	anime
	
	subq	#1,curseq_time
	bgt.s	.no_new_sequence
	
	move.l	curseq_list(pc),a0
	move.l	(a0)+,a1
	jsr	(a1)
	move.l	(a0)+,curseq
	move.l	(a0)+,curobj
	move	(a0)+,obsx
	move	(a0)+,obsy
	move	(a0)+,obsz
	move	(a0)+,va
	move	(a0)+,vb
	move	(a0)+,vg
	move	(a0)+,curseq_time
	move.l	a0,curseq_list
	
.no_new_sequence:
curseq	=	*+2
	jsr	start_seq
	
	bra.s	mainloop
	
 ; #] Main programm:
 ; #[ Anime:

	; #[ Animation sequence list:
	
		;#[ Format:
;	dc.l	Init_sequence,Sequence
;	dc.l	Objet
;	dc.w	obsx,obsy,obsz
;	dc.w	va,vb,vg
;	dc.w	time
		;#] Format:

	section	data
sequences:
	section	text
	
		;#[Current sequence:
curseq_list	dc.l	sequences
curseq_time	dc.w	$7fff

start_seq:
	bsr	mouse_xyz
	tst.b	clav+$1c
	beq.s	.no

	clr	curseq_time	
.no:
	bsr	anime3d
	rts
		;#]Current sequence:
	
	; #] Animation sequence list:

; Ne pas toucher a A0 pendant les inits, les autres registres sont inchang‚s.
	; #[ Intro:
		;#[ Sequence:
	section	data

	IFNE	TRUE
	dc.l	init_text1,scrolltext
	dc.l	font3d
	dc.w	0,-256,0
	dc.w	0,0,0
	dc.w	1
	ENDC
	
	section	text
		;#] Sequence:
text1	dc.b	"hello to",0
	dc.b	"everybody",0
	dc.b	"and welcome",0
	dc.b	"to the",0
	dc.b	-1	; --> Fin de texte
	dc.w	100	; Temps d'attente
	
	dc.w	512	; Position Z de l'observateur
	dc.w	0	; Position Y
	dc.b	"mega tridi demo",0
	dc.b	-1
	dc.w	200
	
	dc.w	0
	dc.w	$8000	; --> Fin sequence de texte
	
init_text1:
	move	#8,neffecr
	lea	text1(pc),a5
	rts
	; #] Intro:
	; #[ Deliro cylindre:

DELIROY	=	300
DELIROZ	=	-1430
	
	section	data
	dc.l	init_deliro,deliro_arrive
	dc.l	def_objets+6*4
	dc.w	0,-900,DELIROZ
	dc.w	0,0,0
	dc.w	90+DELIROY/10
	
	dc.l	nothing,deliro
	dc.l	def_objets+6*4
	dc.w	0,DELIROY,DELIROZ
	dc.w	9,0,0
	dc.w	1024
	
	dc.l	nothing,deliro_back
	dc.l	def_objets+6*4
	dc.w	0,DELIROY,DELIROZ
	dc.w	0,0,0
	dc.w	100
	section	text
	
init_deliro:
	clr	obja
	clr	objb
	clr	objg
	clr	objx
	clr	objy
	clr	objz
	
	move.l	def_objets+6*4,a3
	clr	8(a3)	; Remise a zero de l'animation
	
	move	#292,obja
	lea	sincos(pc),a2
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	rts
deliro_arrive:
	addi	#10,obsy
	bsr	anime3d
	rts
deliro_back:
	addi	#20,obsy
	bsr	anime3d
	rts
deliro:
	addq	#8,d1
	andi	#TSINUS/2-1,d1
	move	d1,d2
	add	d2,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#1500,d2
	swap	d2
	move	d2,objy
	
	addq	#5,d3
	andi	#TSINUS-1,d3
	move	d3,d2
	add	d2,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#600,d2
	swap	d2
	addi	#DELIROZ,d2
	move	d2,obsz
	
	addq	#7,d4
	andi	#TSINUS-1,d4
	move	d4,d2
	add	d2,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#500,d2
	swap	d2
	move	d2,obsx
	asr	#2,d2
;	tst	d2
;	bge.s	.neg
;	neg	d2
;.neg:
	andi	#TSINUS-1,d2
	move	d2,objb
	
	bsr	anime3d
	rts
	; #] Deliro cylindre:

	; #[ Last sequence:
	
	section	data
	dc.l	init_normal_sequence,last_sequence
	dc.l	def_objets
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0
	section	text
	
last_sequence:
	move.l	#sequences,curseq_list
	rts
	
	; #] Last sequence:
	; #[ Normal sequence:
init_normal_sequence:
	clr	obja
	clr	objb
	clr	objg
nothing:
	rts
normal_sequence:
	bsr	anime3d
	rts
	; #] Normal sequence:
	; #[ Draw text:
DISTLET	=	4*512
VITLET	=	64	; 32
ECARLET	=	512	; 512
scrolltext:
	move	#1,nvbl
	move.l	a5,a1
	moveq	#-1,d0
.len:
	addq	#1,d0
	tst.b	(a1)+
	bne.s	.len

	asl	#6,d0
	move	d0,obsx	

	lea	font3d,a6
	lea	list_let(pc),a2
	lea	posz_let(pc),a3
	move	#ECARLET,d1
.loop:
	move.b	(a5)+,d0
	beq.s	.fin
	ext	d0
	cmpi	#' ',d0
	bne.s	.nospace
	clr.l	(a2)+
	bra.s	.space
.nospace:
	subi	#'a',d0
	add	d0,d0
	add	d0,d0
	move.l	(a6,d0),(a2)+
.space:
	subi	#ECARLET,d1
	move	d1,(a3)+
	bra.s	.loop
.fin:
	move.l	#-1,(a2)+
	
	move	#TSINUS/4,objg
.loop1:
	st	finaff
	lea	list_let(pc),a2
	lea	posz_let(pc),a3
	move	#48,objx
.loop2:
	move	#1,colorpoly
	move.b	#2,used_plane
	move.l	(a2)+,a1
	move	(a3),d0
	move.l	a1,d7
	blt	.finloop2
	cmpi	#DISTLET+NECR*VITLET,d0
	bgt.s	.noaddz
	addi	#VITLET,d0
	move	d0,d1
;	subi	#TSINUS/4+DISTLET,d1
	subi	#DISTLET,d1
	andi	#TSINUS-1,d1
	
	move	d0,(a3)
	cmpi	#DISTLET,d0
	ble.s	.okplane
	clr	colorpoly
;	move	#TSINUS-TSINUS/4,d1
	clr	d1
	move	#DISTLET,d0
.okplane:

	sf	finaff	
	move	d1,objg
	move	d0,objz
	blt.s	.noaddz
	tst.l	d7
	beq.s	.noaddz
	movem.l	a2/a3/a5,-(a7)
	bsr	afforme
	movem.l	(a7)+,a2/a3/a5
	
.noaddz:
	addi	#128,objx
	addq	#2,a3
	bra.s	.loop2
.finloop2:
	move.l	affpal(pc),a6
	move.l	#$007,(a6)+
	move.l	#$07700770,(a6)+
	bsr	anime
	
	tst.b	finaff
	beq	.loop1
	
	addi	#128,obsy
	tst.b	(a5)
	bge	scrolltext
	move.l	a5,d0
	addq	#2,d0
	andi	#-2,d0
	move.l	d0,a5
	
	move	#1,nvbl
	move	(a5)+,d0
.wait:
	bsr	anime
	dbra	d0,.wait
	
	move	#8,neffecr
	move	(a5)+,obsz
	move	(a5)+,d0
	move	d0,obsy
	cmpi	#$8000,d0
	bne	scrolltext
	
	move	#30,objz
	rts
	
eff:
	move	#8,neffecr
	rts
	
finaff	ds.b	1
	even
list_let	ds.l	20	; 20 lettres maximum
posz_let	ds.w	20
	; #] Draw text:
	; #[ Vbl synchro, clearing screen, calling Afforme:
anime3d:
	movem.l	d0-a6,-(a7)
	
	tst.b	clav+67	; <F9>?
	bne.s	.norot

	move	obja,d0
	add	va,d0
	andi	#TSINUS-1,d0
	move	d0,obja

	move	objb,d0
	add	vb,d0
	andi	#TSINUS-1,d0
	move	d0,objb
	
	move	objg,d0
	add	vg,d0
	andi	#TSINUS-1,d0
	move	d0,objg
.norot:

	move.l	curobj(pc),a1
	move.l	(a1),a1
	bsr	afforme
	
	movem.l	(a7)+,d0-a6
	rts

neffecr:	dc	0

anime:
	movem.l	d0-a6,-(a7)
	Tstcol	$000
	
	bsr	test_touche

	IFNE	DEBUG
	tst.b	qaffn
	beq.s	.no
	
	move	obsz,d0
	move.l	ec1,a0
	lea	2*8*160(a0),a0
	bsr	affnr
.no:
	ENDC

.waitvbl:
		;#[ Set limit and used plane:
	move.l	curlim,a0
	
	move	limx1,d0
	cmpi	#MIX,d0
	bge.s	.1
	move	#MIX,d0
.1:
	move	d0,(a0)+
	
	move	limx2,d0
	cmp	#MAX,d0
	ble.s	.2
	move	#MAX,d0
.2:
	move	d0,(a0)+
	
	move	limy1,d0
	cmp	#MIY,d0
	bge.s	.3
	move	#MIY,d0
.3:
	move	d0,(a0)+
	
	move	limy2,d0
	cmp	#MAY,d0
	ble.s	.4
	move	#MAY,d0
.4:
	move	d0,(a0)+
	
	move.b	used_plane,(a0)+
	
		;#] Set limit and used plane:
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
	move.l	NECR*2*4*1(a0),curlim
	move.l	NECR*2*4*2(a0),affpal
	move.l	a0,curec
	
	move.l	ec1,a0
	move.l	curlim,a1
	movem	(a1),d0-d3
	move.b	8(a1),used_plane
	
	move.l	#.ret,retcls
	bra	cls
.ret:
;	move.b	#1,used_plane
	clr.b	used_plane
	clr	colorpoly
	move	#MAX,limx1
	move	#MIX,limx2
	move	#MAY,limy1
	move	#MIY,limy2

	Flab
	tst	neffecr
	beq.s	.no
	subq	#1,neffecr
	move.l	ec1,a0
	bsr	cls1plan
.no:

	Tstcol	$700
	movem.l	(a7)+,d0-a6
	rts
	
	; #] Vbl synchro, clearing screen, calling Afforme:
	; #[ Get (X,Y) mouse position:
	
mouse_xyz:
	IFNE	ABSOLUTE_MOUSE
	move	mousex,d0
	subi	#MAX_MOUSEX/2,d0
	neg	d0
	move	d0,obsx
	
	move	mousey,d0
	subi	#MAX_MOUSEY/2,d0
	move	d0,obsy
	
	jsr	waitc
	move.b	#$0d,$fffffc02.w ; Ask for mouse position
	ENDC

	rts	
	; #] Get (X,Y) mouse position:

 ; #] Anime:
 ; #[ Fin:
fin:
	tst.b	mousek
	bne.s	fin

	jsr	uninit
	
	clr	-(a7)
	trap	#1
	
 ; #] Fin:

 ; #[ Cls one plane:

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

 ; #] Cls one plane:
 ; #[ Cls a variable area and number of plane:

	; #[ Calling rout:
; Routine d'effacement
; D0: Min X
; D1: Max X
; D2: Min Y
; D3: Max Y
; A0: Adresse ecran
; retcls: Adresse retour du CLS

	section	bss
oa7	ds.l	1
used_plane	ds.b	1
	even
	section	text

cls:
	tst.b	clav+68	; <F10>?
	beq.s	.no
	move.b	#$0f,used_plane
.no:

	move	#$0300,sr
	move.l	a7,oa7
	move.l	a0,a7
	
	andi	#$fff0,d0
	addi	#16,d1
	andi	#$fff0,d1	; Multiple de 16 pixel
	move	d1,d5
	lsr	#1,d5
	
	sub	d0,d1	; Largeur
	lsr	#2,d1
	
	sub	d2,d3
	subq	#1,d3
	ble	cls0
	
	asl	#5,d2	; * 32
	move	d2,d4
	add	d2,d2
	add	d2,d2	; * 128
	add	d4,d2	; --> * 160
	
	add	d2,d5
	adda	d5,a7
	move	d3,d0
	
	moveq	#0,d7
	move.b	used_plane,d7
	add	d7,d7
	add	d7,d7
	jmp	.jmp_plane(pc,d7)
	
.jmp_plane:
	bra.w	fcls
	bra.w	plan0001
	bra.w	plan0010
	bra.w	plan0011
	bra.w	plan0100
	bra.w	plan0101
	bra.w	plan0110
	bra.w	plan0111
	bra.w	plan1000
	bra.w	plan1001
	bra.w	plan1010
	bra.w	plan1011
	bra.w	plan1100
	bra.w	plan1101
	bra.w	plan1110
	bra.w	plan1111
	; #] Calling rout:
	; #[ Four plane:	
plan1111:
plan1010:
plan0101:
plan1110:
plan1101:
plan1011:
plan0111:
	addq	#2,d1
	ble	cls0
	move	d1,.ajmp+2
	
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	
.ajmp:
	bra.w	tcls
	
tcls:
	bra.w	cls0
	bra.w	cls1
	bra.w	cls2
	bra.w	cls3
	bra.w	cls4
	bra.w	cls5
	bra.w	cls6
	bra.w	cls7
	bra.w	cls8
	bra.w	cls9
	bra.w	cls10
	bra.w	cls11
	bra.w	cls12
	bra.w	cls13
	bra.w	cls14
	bra.w	cls15
	bra.w	cls16
	bra.w	cls17
	bra.w	cls18
	bra.w	cls19
	bra.w	cls20
	
cls1:
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+8(a7),a7
	dbra	d0,cls1
	bra	fcls
	
cls2:
	movem.l	d1-d4,-(a7)
	lea	160+16(a7),a7
	dbra	d0,cls2
	bra	fcls
	
cls3:
	movem.l	d1-d6,-(a7)
	lea	160+24(a7),a7
	dbra	d0,cls3
	bra	fcls
	
cls4:
	movem.l	d1-a0,-(a7)
	lea	160+32(a7),a7
	dbra	d0,cls4
	bra	fcls
	
cls5:
	movem.l	d1-a2,-(a7)
	lea	160+40(a7),a7
	dbra	d0,cls5
	bra	fcls
	
cls6:
	movem.l	d1-a4,-(a7)
	lea	160+48(a7),a7
	dbra	d0,cls6
	bra	fcls
	
cls7:
	movem.l	d1-a6,-(a7)
	lea	160+56(a7),a7
	dbra	d0,cls7
	bra	fcls
	
cls8:
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+64(a7),a7
	dbra	d0,cls8
	bra	fcls
	
cls9:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+72(a7),a7
	dbra	d0,cls9
	bra.s	fcls
	
cls10:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+80(a7),a7
	dbra	d0,cls10
	bra.s	fcls
	
cls11:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+88(a7),a7
	dbra	d0,cls11
	bra.s	fcls
	
cls12:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+96(a7),a7
	dbra	d0,cls12
	bra.s	fcls
	
cls13:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+104(a7),a7
	dbra	d0,cls13
	bra.s	fcls
	
cls14:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	lea	160+112(a7),a7
	dbra	d0,cls14
	bra.s	fcls
	
cls15:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+120(a7),a7
	dbra	d0,cls15
;	bra.s	fcls
	
two_plane_cls0:
one_plane_cls0:
cls0:
fcls:
	move.l	oa7,a7
	trap	#3
	clr.b	used_plane
	dc	$4ef9	; --> Jmp
retcls	dc.l	0
	
cls16:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+128(a7),a7
	dbra	d0,cls16
	bra.s	fcls
	
cls17:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+136(a7),a7
	dbra	d0,cls17
	bra.s	fcls
	
cls18:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+144(a7),a7
	dbra	d0,cls18
	bra.s	fcls
	
cls19:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+152(a7),a7
	dbra	d0,cls19
	bra.s	fcls
	
cls20:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+160(a7),a7
	dbra	d0,cls20
	bra	fcls
	
	; #] Four plane:	
	; #[ Two plane:
plan1001:	addq	#2,a7
plan1100:	addq	#2,a7
plan0110:	addq	#2,a7
plan0011:
	addq	#2,d1
	ble	fcls
	move	d1,.ajmp+2
	
	moveq	#0,d1
	
.ajmp:
	bra.w	two_plane_cls
	
two_plane_cls:
	bra.w	two_plane_cls0
	bra.w	two_plane_cls1
	bra.w	two_plane_cls2
	bra.w	two_plane_cls3
	bra.w	two_plane_cls4
	bra.w	two_plane_cls5
	bra.w	two_plane_cls6
	bra.w	two_plane_cls7
	bra.w	two_plane_cls8
	bra.w	two_plane_cls9
	bra.w	two_plane_cls10
	bra.w	two_plane_cls11
	bra.w	two_plane_cls12
	bra.w	two_plane_cls13
	bra.w	two_plane_cls14
	bra.w	two_plane_cls15
	bra.w	two_plane_cls16
	bra.w	two_plane_cls17
	bra.w	two_plane_cls18
	bra.w	two_plane_cls19
	bra.w	two_plane_cls20
	
Tpcls	MACRO
two_plane_loop\@:
	IFGE	\1-1
	move.l	d1,-8(a7)
	ENDC
	IFGE	\1-2
	move.l	d1,-16(a7)
	ENDC
	IFGE	\1-3
	move.l	d1,-24(a7)
	ENDC
	IFGE	\1-4
	move.l	d1,-32(a7)
	ENDC
	IFGE	\1-5
	move.l	d1,-40(a7)
	ENDC
	IFGE	\1-6
	move.l	d1,-48(a7)
	ENDC
	IFGE	\1-7
	move.l	d1,-56(a7)
	ENDC
	IFGE	\1-8
	move.l	d1,-64(a7)
	ENDC
	IFGE	\1-9
	move.l	d1,-72(a7)
	ENDC
	IFGE	\1-10
	move.l	d1,-80(a7)
	ENDC
	IFGE	\1-11
	move.l	d1,-88(a7)
	ENDC
	IFGE	\1-12
	move.l	d1,-96(a7)
	ENDC
	IFGE	\1-13
	move.l	d1,-104(a7)
	ENDC
	IFGE	\1-14
	move.l	d1,-112(a7)
	ENDC
	IFGE	\1-15
	move.l	d1,-120(a7)
	ENDC
	IFGE	\1-16
	move.l	d1,-128(a7)
	ENDC
	IFGE	\1-17
	move.l	d1,-136(a7)
	ENDC
	IFGE	\1-18
	move.l	d1,-144(a7)
	ENDC
	IFGE	\1-19
	move.l	d1,-152(a7)
	ENDC
	IFGE	\1-20
	move.l	d1,-160(a7)
	ENDC
	
	lea	160(a7),a7

	dbra	d0,two_plane_loop\@
	
	bra	fcls
	
	ENDM
	
two_plane_cls1		Tpcls	1
two_plane_cls2		Tpcls	2
two_plane_cls3		Tpcls	3
two_plane_cls4		Tpcls	4
two_plane_cls5		Tpcls	5
two_plane_cls6		Tpcls	6
two_plane_cls7		Tpcls	7
two_plane_cls8		Tpcls	8
two_plane_cls9		Tpcls	9
two_plane_cls10	Tpcls	10
two_plane_cls11	Tpcls	11
two_plane_cls12	Tpcls	12
two_plane_cls13	Tpcls	13
two_plane_cls14	Tpcls	14
two_plane_cls15	Tpcls	15
two_plane_cls16	Tpcls	16
two_plane_cls17	Tpcls	17
two_plane_cls18	Tpcls	18
two_plane_cls19	Tpcls	19
two_plane_cls20	Tpcls	20
	
	; #] Two plane:
	; #[ One plane:
plan1000:	addq	#2,a7
plan0100:	addq	#2,a7
plan0010:	addq	#2,a7
plan0001:
	addq	#2,d1
	ble	fcls
	move	d1,.ajmp+2
	
	moveq	#0,d1
	
.ajmp:
	bra.w	one_plane_cls
	
one_plane_cls:
	bra.w	one_plane_cls0
	bra.w	one_plane_cls1
	bra.w	one_plane_cls2
	bra.w	one_plane_cls3
	bra.w	one_plane_cls4
	bra.w	one_plane_cls5
	bra.w	one_plane_cls6
	bra.w	one_plane_cls7
	bra.w	one_plane_cls8
	bra.w	one_plane_cls9
	bra.w	one_plane_cls10
	bra.w	one_plane_cls11
	bra.w	one_plane_cls12
	bra.w	one_plane_cls13
	bra.w	one_plane_cls14
	bra.w	one_plane_cls15
	bra.w	one_plane_cls16
	bra.w	one_plane_cls17
	bra.w	one_plane_cls18
	bra.w	one_plane_cls19
	bra.w	one_plane_cls20
	
Opcls	MACRO
one_plane_loop\@:
	IFGE	\1-1
	move	d1,-8(a7)
	ENDC
	IFGE	\1-2
	move	d1,-16(a7)
	ENDC
	IFGE	\1-3
	move	d1,-24(a7)
	ENDC
	IFGE	\1-4
	move	d1,-32(a7)
	ENDC
	IFGE	\1-5
	move	d1,-40(a7)
	ENDC
	IFGE	\1-6
	move	d1,-48(a7)
	ENDC
	IFGE	\1-7
	move	d1,-56(a7)
	ENDC
	IFGE	\1-8
	move	d1,-64(a7)
	ENDC
	IFGE	\1-9
	move	d1,-72(a7)
	ENDC
	IFGE	\1-10
	move	d1,-80(a7)
	ENDC
	IFGE	\1-11
	move	d1,-88(a7)
	ENDC
	IFGE	\1-12
	move	d1,-96(a7)
	ENDC
	IFGE	\1-13
	move	d1,-104(a7)
	ENDC
	IFGE	\1-14
	move	d1,-112(a7)
	ENDC
	IFGE	\1-15
	move	d1,-120(a7)
	ENDC
	IFGE	\1-16
	move	d1,-128(a7)
	ENDC
	IFGE	\1-17
	move	d1,-136(a7)
	ENDC
	IFGE	\1-18
	move	d1,-144(a7)
	ENDC
	IFGE	\1-19
	move	d1,-152(a7)
	ENDC
	IFGE	\1-20
	move	d1,-160(a7)
	ENDC
	
	lea	160(a7),a7

	dbra	d0,one_plane_loop\@
	
	bra	fcls
	
	ENDM
	
one_plane_cls1		Opcls	1
one_plane_cls2		Opcls	2
one_plane_cls3		Opcls	3
one_plane_cls4		Opcls	4
one_plane_cls5		Opcls	5
one_plane_cls6		Opcls	6
one_plane_cls7		Opcls	7
one_plane_cls8		Opcls	8
one_plane_cls9		Opcls	9
one_plane_cls10	Opcls	10
one_plane_cls11	Opcls	11
one_plane_cls12	Opcls	12
one_plane_cls13	Opcls	13
one_plane_cls14	Opcls	14
one_plane_cls15	Opcls	15
one_plane_cls16	Opcls	16
one_plane_cls17	Opcls	17
one_plane_cls18	Opcls	18
one_plane_cls19	Opcls	19
one_plane_cls20	Opcls	20
	
	; #] One plane:
	
 ; #] Cls a variable area and number of plane:

 ; #[ Vbl:

	; #[ Datas:
qaffn	dc.b	0
	even
curec	dc.l	ec+3*4
affec	dc.l	ec
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
	
	; #[ Real_VBL:
	
att_vbl	dc.w	0
	
vbl:
	move.l	#vbl2,$134.w
	
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
	
	rte
	; #] Real_VBL:
	; #[ Timer_VBL:
	
FREQUENCE	=	50
	
vbl2:
;	move	#$005,$ffff8240
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
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	move.l	NECR*2*4*2(a0),a0
	movem.l	(a0),d0-d7
;	movem.l	palette(pc),d0-d7
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

	
	IFNE	MUSIC
	jsr	player+8
	ENDC
	IFNE	PLOT
	bsr	affplot
	ENDC
	
	movem.l	(a7)+,d0-a6
	clr.b	$fffffa19.w
;	move	#$500,$ffff8240.w
	rte
	; #] Timer_VBL:

 ; #] Vbl:
 ; #[ Affn:

affnr:
	tst	d0
	bge.s	.ok

	neg	d0	
.ok:
	ext.l	d0
	divs	#100,d0
	cmpi	#100,d0
	bge.s	.noaffn
	add	d0,d0
	add	d0,d0
	jsr	nombre(pc,d0)
	
	swap	d0
	add	d0,d0
	add	d0,d0
	addq	#8,a0
	jmp	nombre(pc,d0)
	
.noaffn:
	rts
	
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
music:	incbin	e:\music\coso\tera3.*
	even
	ENDC
	
 ; #] Music:
 ; #[ 3D Plot:
 
	IFNE	PLOT
CENTRE	=	NBLIG/2
NPOS	=	75
NPLT	=	50

makeplot:			* Pr‚paration des points
	lea	posxy,a0
	move.w	#NPOS-1,d0	* NPOS positions diff‚rente (1.5 secondes)
;	lea	sinus,a2
loopplt1:
	lea	iposxy,a1
	move.w	#NPLT-1,d1	* NPLT points.
loopplt2:
	IFLT	NPLT-200
	addq	#6,a1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	(a1),d4
	ENDC
	subq.w	#1,d4
	tst.w	d4
	bgt.s	posiz
	addi.w	#NPOS,d4
posiz:
	move.w	d4,(a1)+
	move.w	d4,d6

	IFNE	FALSE	; Rotation
	bra	norot
	move.w	d2,d4
	move.w	d3,d5
	
	muls	(a2),d2
	muls	2(a2),d3
	add.l	d3,d2
	asr.l	#8,d2
	asr.l	#6,d2
	
	muls	(a2),d5
	muls	2(a2),d4
	sub.l	d4,d5
	asr.l	#8,d5
	asr.l	#6,d5
	move.w	d5,d3
	ENDC
	
	muls	#20,d2
	divs	d6,d2
	muls	#20,d3
	divs	d6,d3

	addi.w	#160,d2
*	addi.w	#CENTRE,d3
	
	move.w	#%1000000000000000,d5
	
	cmpi.w	#0,d2
	bge.s	oknx
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
oknx:
	cmpi.w	#-CENTRE,d3
	bge.s	okny
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okny:
	cmpi.w	#320,d2
	blt.s	okpx
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okpx:
	cmpi.w	#200-CENTRE,d3
	blt.s	okpy
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okpy:
	muls	#160,d3
	move.w	d2,d4
	lsr.w	#4,d2
	lsl.w	#3,d2
	andi.w	#$f,d4
	ext.l	d2
	add.l	d3,d2

	neg.w	d6
	addi.w	#NPOS,d6	
	ext.l	d6
	divs	#NPOS/3,d6
	cmpi.w	#2,d6
	blt.s	okcol
	move.w	#1,d6
	tst.w	d5
	beq.s	okcol
	move.w	#%1100000000000000,d5
okcol:
	lsr.w	d4,d5
	lsl.w	#1,d6
	
;	add.w	d6,d2
	move.w	d2,(a0)+
	move.w	d5,(a0)+

	dbra	d1,loopplt2
	
	lea	4(a2),a2
	
	dbra	d0,loopplt1
	
	rts
	
oldec_plot	dc.l	ecran+CENTRE*160

affplot:	
	move.l	cposxy,a6
	lea	-2*NPLT*2(a6),a4
	cmpa.l	#posxy,a4
	bge.s	okxy2
	adda.l	#4*NPLT*NPOS,a4
okxy2:
	move.l	oldec_plot,a5
	move.w	#NPLT/10-1,d7
	moveq.l	#0,d3
loopeffp:
	REPT	10
	move.w	(a4)+,d1
	move.w	(a4)+,d2
	not.w	d2
	and.w	d2,(a5,d1.w)
	ENDR
	
	dbra	d7,loopeffp
	
	move.l	affec,a5
	move.l	(a5),a5
	lea	CENTRE*160(a5),a5
	move.l	a5,oldec_plot
	
	move.w	#NPLT/10-1,d7
loopaffp:
	REPT	10
	move.w	(a6)+,d1
	move.w	(a6)+,d2
	or.w	d2,(a5,d1.w)
	ENDR
	
	dbra	d7,loopaffp

	cmpa.l	#fposxy,a6
	blt.s	okxy
	move.l	#posxy,a6
okxy:
	move.l	a6,cposxy
	
	rts

	section	data

cposxy:
	dc.l	posxy
	
iposxy:
	incbin	posxy2
;sinus:
;	incbin	\ziggy.dmo\star\sinus

	section	bss
posxy:
	ds.l	NPLT*NPOS
fposxy:
	
	section	text
	ENDC
	
 ; #] 3D Plot:

 ; #[ 3D Objects:

def_objets	=	*+$1c
	incbin	objets.prg
def_objets2	=	*+$1c
	incbin	objets2.prg
def_objets3	=	*+$1c
	incbin	objets3.prg
font3d	=	*+$1c
	incbin	font3d.prg
	dc.b	"Finr"
	
 ; #] 3D Objects:

 ; #[ Variables:
	
	section	bss
	
	; #[ Variables_systemes:
oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.b	1
oldrez_tt	ds.b	1
	even
oldec	ds.l	1
	; #] Variables_systemes:

projection	ds.w	128*2	* 128 points max dans une forme 3D

pxy	ds.l	16	* Tableau du polygone

points_gauche	ds.w	NBLIG
	ds.w	DEPASSE*2
points_droite	ds.w	NBLIG
	ds.w	DEPASSE*2

num	ds.b	20

	ds.b	256
ecran	ds.b	32000*NECR
	even
	
 ; #] Variables:

