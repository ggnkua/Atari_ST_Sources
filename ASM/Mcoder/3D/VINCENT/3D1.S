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
BOMB	=	TRUE
MUSIC	=	FALSE
PLOT	=	FALSE

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
TAILPAL	=	16 	; (Jusqu'a 512!!)
MINCOL	=	0
MAXCOL	=	3

; Parametre pour le tracage des lignes horizontales, configuration de l'ecran
NBLIG	=	200
LECRAN	=	320
DEPASSE	=	512
MINX	=	0
MAXX	=	320

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
	IFNE	DEBUG
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
	dc.b	"(C) Copyright Vincent PENNE (Ziggy STARDUST) 1990. "
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
	bsr	relocation
	bsr	init_hline
	bsr	genere_circle

	IFNE	MUSIC
	moveq	#2,d0
	lea	LA2E,a0
	jsr	initmus
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

	move	#$2700,sr
	andi.b	#%11,oldrez
	cmpi.b	#2,oldrez
	bne.s	.okmoni
	not	$ffff8240.w
	
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

	move.l	#line68030,qline
	move.l	#line68030t,qlinet
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

ABSOLUTE_MOUSE	=	FALSE
	; #[ Interuption:
clavier:
	btst	#0,$fffffc00.w
	beq.s	noclav
	
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
noclav:
	rte
	
	IFNE	ABSOLUTE_MOUSE
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
	
	move.l	\2,curobj
.\@
	ENDM
	
VITEZOOM	=	2
	
test_touche:
	btst	#0,mousek
	beq.s	.no
	addi	#VITEZOOM,oz
.no:
	Flab
	btst	#1,mousek
	beq.s	.no
	subi	#VITEZOOM,oz
.no:
	
	lea	clav(pc),a0
	
	Flab
	tst.b	$4e(a0)	; '+'?
	beq.s	.no
	addi	#VITEZOOM,oz
.no:
	Flab
	tst.b	$4a(a0)	; '-'?
	beq.s	.no
	subi	#VITEZOOM,oz
.no:
	Flab
	tst.b	$72(a0)	; <Enter>?
	beq.s	.no
	addi	#VITEZOOM*10,oz
.no:
	Flab
	tst.b	$66(a0)	; '*'?
	beq.s	.no
	subi	#VITEZOOM*10,oz
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
.no:

	Touche_objet	2,#obj1
	Touche_objet	3,#obj2
	Touche_objet	4,#obj3
	Touche_objet	5,#obj4
	Touche_objet	6,#obj5
	Touche_objet	7,#obj6
	Touche_objet	8,#obj7
	Touche_objet	9,#obj8
	
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
; 'Inic' : init_color	;
; 'Setc' : set_color	;
; 'Affp' : call_poly	;
; 'F1p ' : face1p	;
; 'F1pt' : face1pt	;
; '1pti' : faceipti	;
; 'Vert' : vertices	;
; 'Hide' : hide	;
; 'Goto' : goto	;
; 'Enab' : enable	;
; 'Disa' : disable	;
; 'Fin ' : fin_afforme	;
;------------------------------

relocation:
	lea	debut_objets_def-16,a0
	lea	debut_objets,a1
	move.l	a1,d1
.reloc_def:
	lea	16(a0),a0
	move.l	(a0),d0
	blt.s	.fin_reloc_def
	
	bgt.s	.reloc_def
	move.l	(a1)+,d0
	add.l	d1,d0
	move.l	d0,(a0)
	bra.s	.reloc_def
	
.fin_reloc_def:

	lea	debut_objets,a0
	lea	.fin_routine_list,a3
.reloc:
 	lea	.routine_list,a2
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
	cmpi.l	#'Defp',d1
	bne.s	.nodefp
.defp:
	move.l	a0,d0
	addi.l	#4,d0
	add.l	d0,4(a0)
.nodefp:
	move.l	(a2)+,(a0)

.noident:

	addq	#2,a0
	bra.s	.reloc
	
.fin_relocate:
	rts
	
.routine_list:
	dc.b	'Defp'
	dc.l	def_plot
	
	dc.b	'Anim'
	dc.l	anime_plot

	dc.b	'Inic'
	dc.l	init_color
	
	dc.b	'Setc'
	dc.l	set_color
	
	dc.b	'Affp'
	dc.l	call_poly
	
	dc.b	'F1p '
	dc.l	face1p
	
	dc.b	'F1pt'
	dc.l	face1pt
	
	dc.b	'1pti'
	dc.l	face1pti
	
	dc.b	'Vert'
	dc.l	vertices
	
	dc.b	'Shpr'
	dc.l	sphere
	
	dc.b	'Hide'
	dc.l	hide
	
	dc.b	'Goto'
	dc.l	goto
	
	dc.b	'Enab'
	dc.l	enable
	
	dc.b	'Disa'
	dc.l	disable
	
	dc.b	'Fin '
	dc.l	fin_afforme
.fin_routine_list:

 ; #] Forme relocation:
 ; #[ Afforme:

	; #[ Datas:
		* Position de l'observateur --->
		
oa	dc.w	0	* Angle Alpha
ob	dc.w	0	* Beta
og	dc.w	0	* et Gamma...
oba	dc.w	0
obb	dc.w	0
obg	dc.w	0

current_val:
ox	dc.w	0
oy	dc.w	0
oz	dc.w	0
cz	dc.w	0

va	dc.w	0
vb	dc.w	0
vg	dc.w	0

init_val:
	dc.w	0
	dc.w	0
	dc.w	-310
	dc.w	0

	dc.w	-3
	dc.w	6
	dc.w	-9
	
m1	ds.w	1	; Doivent etre consecutifs!
m2	ds.w	1
m3	ds.w	1
n2	ds.w	1
n1	ds.w	1
n3	ds.w	1
o3	ds.w	1
o1	ds.w	1
o2	ds.w	1
obx	ds.w	1
oby	ds.w	1
obz	ds.w	1

limx1	ds.w	1
limx2	ds.w	1
limy1	ds.w	1
limy2	ds.w	1

zoom	dc.w	256	; Valeur du zoom

table:			; Table de sinus
	incbin	table2
	even
	
		; Fenetre de clipping -->
mix	dc.w	MINX
miy	dc.w	0
max	dc.w	MAXX-1
may	dc.w	NBLIG

ty1	dc.w	32000
ty2	dc.w	0

colorpoly	ds.w	1	; couleur du polygone

maxy	ds.w	1
miny	ds.w	1

		; Centre de l'‚cran   --->
cx	dc.w	160
cy	dc.w	100-4

curcol	dc.w	0
curpal	dc.l	pal2
;palette:
;	incbin	palette.pal
pal2:
 dc.w 0,$333,$444,$555,$666,$330,$550,$770,$700,$500,$007,$005,$500,$700,$770,$777
 ;    0   1    2    3    4    5    6    7    8    9    10   11   12   13   14  15
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
	even
afforme:
	Tstcol	$770
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	-16(a6),a1
	
	Next
	
fin_afforme:
		;#[ Set limit and used plane:
	move.l	curlim,a0
	
	move	limx1,d0
	cmp	mix(pc),d0
	bge.s	.1
	move	mix(pc),d0
.1:
	move	d0,(a0)+
	
	move	limx2,d0
	cmp	max(pc),d0
	ble.s	.2
	move	max(pc),d0
.2:
	move	d0,(a0)+
	
	move	limy1,d0
	cmp	miy(pc),d0
	bge.s	.3
	move	miy(pc),d0
.3:
	move	d0,(a0)+
	
	move	limy2,d0
	cmp	may(pc),d0
	ble.s	.4
	move	may(pc),d0
.4:
	move	d0,(a0)+
	
	move.b	used_plane,(a0)+
	
		;#] Set limit and used plane:
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	; #] Afforme:
	
	; #[ Def_plot:
def_plot:
	move.l	(a1)+,a5
	; #] Def_plot:
	; #[ Calcul plot:
calcul_plot:
		;#[ Init matrice:
	move	-12(a6),obx
	move	-10(a6),oby
	move	-8(a6),obz
	move	ox(pc),d0
	sub	d0,obx
	move	oy(pc),d0
	sub	d0,oby
	move	oz(pc),d0
	sub	d0,obz
	
	lea	table+TSINUS/2(pc),a0	; Table des sinus...
	lea	table(pc),a2		; et des cosinus

sab	equr	d2
cab	equr	d3
sbb	equr	d4
cbb	equr	d5
sgb	equr	d6
cgb	equr	d7
	
	move	-6(a6),d0
	add	d0,d0
	move	(a0,d0),sab
	move	(a2,d0),cab

	move	-4(a6),d0
	add	d0,d0
	move	(a0,d0),sbb
	move	(a2,d0),cbb

	move	-2(a6),d0
	add	d0,d0
	move	(a0,d0),sgb
	move	(a2,d0),cgb
	
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
		;#[ Calcul points 3d:
	Tstcol	$707
	move	max(pc),limx1
	move	mix(pc),limx2
	move	may(pc),limy1
	move	miy(pc),limy2
	
	lea	plot2d,a0
	lea	plot3d,a3
	
	move	(a5)+,d2
	lea	m1(pc),a6
loop_plot:
	move	(a5)+,d3
	move	(a5)+,d4
	
			; Rotation autour du centre de l'objet
	move.l	a6,a2
	; Rotation X
	move	d2,d6
	muls	(a2)+,d6
	move	d3,d5
	muls	(a2)+,d5
	add.l	d5,d6
	move	d4,d5
	muls	(a2)+,d5
	add.l	d5,d6
	add.l	d6,d6
	swap	d6
	
	; Rotation Y
	move	d3,d7
	muls	(a2)+,d7
	move	d2,d5
	muls	(a2)+,d5
	add.l	d5,d7
	move	d4,d5
	muls	(a2)+,d5
	add.l	d5,d7
	add.l	d7,d7
	swap	d7

	; Rotation Z
	muls	(a2)+,d4
	muls	(a2)+,d2
	add.l	d2,d4
	muls	(a2)+,d3
	add.l	d3,d4
	add.l	d4,d4
	swap	d4
	
				; On ramene aux coordon‚e de l'obs	
	add	(a2)+,d6
	add	(a2)+,d7
	add	(a2)+,d4
	neg	d7
	
	move	d6,(a3)+
	move	d7,(a3)+
	move	d4,(a3)+
	
	cmpi	#DISTEC,d4	; Z inf‚rieur … DISTEC?
	ble	.clipz	; Oui --> clipz
	
	; Avec ZOOM = 256
	; (X * ZOOM) / Z + CX
	
	ext.l	d6
	asl.l	#8,d6
	divs	d4,d6
	add	cx(pc),d6
	
	Tstx	d6
	move	d6,(a0)+
	
	
	; (Y * ZOOM) / Z + CY
	
	ext.l	d7
	asl.l	#8,d7
	divs	d4,d7
	add	cy(pc),d7
	move	d7,(a0)+
	
	cmp	ty1(pc),d7
	bgt.s	.okty1
	
	move	d7,ty1
.okty1:

	cmp	ty2(pc),d7
	blt.s	.okty2
	
	move	d7,ty2
.okty2:
	
	Tsty	d7
	
	move	(a5)+,d2
	cmpi	#$8000,d2
	bne	loop_plot

.fin_plot:
	Tstcol	$000
	Next
	
.clipz:
	addq.l	#4,a0
	move	(a5)+,d2
	cmpi	#$8000,d2
	bne	loop_plot

	Tstcol	$000
	Next
	
		;#] Calcul points 3d:
	; #] Calcul plot:
	; #[ Anime plot:
anime_plot:
	move.l	(a1)+,a5
	move	(a1),d0
	adda	d0,a5
	move.l	a5,a4
.search_last:
	cmpi	#$8000,(a4)
	beq.s	.fin_search
	addq	#6,a4
	addq	#6,d0
	
	bra.s	.search_last
	
.fin_search:
	cmpi	#$8000,2(a4)
	bne.s	.no_last_anime
	
	moveq	#-2,d0
.no_last_anime:
	addq	#2,d0
	move	d0,(a1)+
	
	bra	calcul_plot
	; #] Anime plot:

	; #[ Init color:
init_color:
	moveq	#MINCOL,d6
	lea	dispal(pc),a6
	REPT	TAILPAL
	move.b	#-1,(a6)+
	ENDR
	move	(a1)+,d1
	lea	dispal(pc),a6
	clr.b	(a6,d1)
	move.l	affpal(pc),a6
	move	#COLFOND,(a6)+	; Couleur 0 = couleur de fond
	move.l	curpal,a4
	add	d1,d1
	move	(a4,d1),(a6)+
	
	Next
	; #] Init color:
	; #[ Set color:
set_color:
	move	(a1)+,d0		; Couleur de la face N
	
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
	
	Next
	; #] Set color:

	; #[ Hide:
hide:
	Tstcol	$070
	
	lea	plot2d,a0
	lea	plot3d,a4
	
	movem	(a1)+,d0-d2
	
	move	d0,d3
	add	d0,d3
	move	d3,d4
	add	d0,d3
	add	d3,d3
	cmpi	#DISTEC,4(a4,d3) ; Point derriere ecran?
	ble.s	.ok ; Oui --> On ne peut pas tester la visibilit‚e
	move	d1,d3
	add	d1,d3
	move	d3,d5
	add	d1,d3
	add	d3,d3
	cmpi	#DISTEC,4(a4,d3)
	ble.s	.ok
	move	d2,d3
	add	d2,d3
	move	d3,d7
	add	d2,d3
	add	d3,d3
	cmpi	#DISTEC,4(a4,d3)
	ble.s	.ok
	
	add	d4,d4
	add	d5,d5
	add	d7,d7
	
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
	move.l	a1,a3
	adda	(a1)+,a3
	move.l	#enabled,(a3)
	Next
	; #] Enable:
	; #[ Disable:
disable:
	move.l	a1,a3
	adda	(a1)+,a3
	move.l	#disabled,(a3)
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

	; #[ Vertices:
vertices:
	Tstcol	$700

	lea	2(a1),a5
	move.l	a2,a4
	lea	plot2d,a0
	lea	plot3d,a3
	lea	pxy,a2
	move	#32767,d1
	
.loop_plot:
	move	(a1)+,d0	; --> No points
	blt	.fin_plot
	add	d0,d0
	move	d0,d3
	add	d0,d0	; No point * 4 dans D0
	add	d0,d3	; No point * 6 dans D3

	IFNE	TRUE
	cmpi	#DISTEC,4(a3,d3) ; Point derriere ecran?
	bgt	.okscreen	; Non
			; Oui --> calcul intersection
		;#[ Calcul screen intersection:
	move	-4(a1),d4
	cmpa.l	a5,a1	; Premier point?
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
;	ext.l	d4
;	asl.l	#8,d4
;	divs	#DISTEC,d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	add	cx,d4
	
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
;	ext.l	d4
;	asl.l	#8,d4
;	divs	#DISTEC,d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	add	cy,d4
	
	Tsty	d4
	move	d4,(a2)+
	
.badp1:
	move	(a1),d4
	bge.s	.nolastp		; Si dernier point
	move	-2(a5),d4
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
;	ext.l	d4
;	asl.l	#8,d4
;	divs	#DISTEC,d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	add	cx,d4
	
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
;	ext.l	d4
;	asl.l	#8,d4
;	divs	#DISTEC,d4
	asl	#8-5,d4	; Pour ZOOM = 256 et DISTEC = 32
	add	cy,d4
	
	Tsty	d4
	move	d4,(a2)+
	
.badp2:
	bra	.loop_plot
		;#] Calcul screen intersection:
.okscreen:
	ENDC
	move.l	(a0,d0),d5
	
	cmp	d1,d5
	bge.s	.highter
	move.l	a2,a4
	move	d5,d1
.highter:

	move.l	d5,(a2)+

	bra	.loop_plot
	
.fin_plot:
	move.l	a2,a5
	Next
	; #] Vertices:
	; #[ Sphere:
sphere:
	move	(a1)+,d0
	move	(a1)+,d1
	
	lea	plot2d,a2
	lea	plot3d,a3
	add	d0,d0
	move	d0,d2
	add	d0,d0
	move	d0,d3
	add	d2,d0
	move	4(a3,d0),d0
	cmpi	#DISTEC,d0
	blt	.nosphere

	ext.l	d1	; Calcul du rayon
	asl	#8,d1
	divs	d0,d1
	
	move	2(a2,d3),d2
	move	(a2,d3),d3
	movem.l	d6/a6/a1,-(a7)
	
	move	d2,d4
	move	d2,d5
	add	d1,d4
	sub	d1,d5
	Tsty	d4
	Tsty	d5
	
	move	d3,d4
	move	d3,d5
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
	
	move.l	curline,a0
	move.l	ec1,a6
	move	colorpoly,d7
	add	d7,d7
	adda	d7,a6
	bsr	call_line
	movem.l	(a7)+,d6/a6/a1
	
.nosphere:
	Next
	; #] Sphere:

	; #[ Call poly:
call_poly:
	move.l	a5,d7
	sub.l	#pxy,d7	; Y'a-t-il moins de trois segments?
	cmpi	#3*2,d7
	ble	.nopoly
	
	Tstcol	$007	
	movem.l	d6/a1/a6,-(a7)
	lea	pxy,a6
	bsr.s	affpoly
	movem.l	(a7)+,d6/a1/a6
	
.nopoly:
	Next
	; #] Call poly:

 ; #] Afforme:
 ; #[ Affpoly:
; ------------------------------------------------------------------------ ;
;		 Filled polygone,		;
;	(C) Copyright 1989-90 Vincent PENNE (Ziggy STARDUST)	;
; ------------------------------------------------------------------------ ;
; A4: Adresse du point le plus haut dans la liste
; A5: Adresse du dernier point de la liste
; A6: Adresse du premier point de la liste
	
nopoly:
	rts
	
affpoly:
	lea	4(a4),a0
	move	2(a4),d0
	move	may(pc),d7
	cmp	miy(pc),d0	; Miny plus petit que miy?
	bge.s	cnegaplot	; Non
	move	miy(pc),d0
cnegaplot:
	move	d0,d5

	lea	points_droite,a2
	move.l	a4,a3
		;#[ Calcul right plot:
; D0 : Position Y courante
; D7 : May
; A2 : Table points droites
; A4 : Adresse points le plus haut
; A5 : Adresse du dernier point
; A6 : Adresse du premier point
new_plotr:
	movem	(a4),d1-d4	; X1 Y1 X2 Y2
	addq	#4,a4
	cmp.l	a5,a4
	blt.s	.ok

	move.l	a6,a4
	move	(a4),d3
	move	2(a4),d4
.ok:
	cmp.l	a3,a4
	beq	fin_plotr
	cmp	d0,d4
	ble.s	new_plotr
	move	d4,d6
	cmp	d7,d6	; Point plus bas que may?
	blt.s	.oklow	; Non
	move	d7,d6
	cmp	d2,d7	; Y2 superieur a Y1 courant?
	ble	fin_plotr
.oklow:
	add	d1,d1
	add	d1,d1
	add	d3,d3
	add	d3,d3
	
	sub	d1,d3
	sub	d2,d4

	cmp	miy(pc),d2
	bge.s	.noclip
	sub	d0,d2	; On cherche X de d‚part par rapport … D0
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
	bge	.nobord
	addi	#NBLIG,d0
	swap	d1
	move	d3,d1
	beq	fast_plotr
	addi	#$8000,d1
	swap	d1
	swap	d3
	add	d0,d0
	add	d0,d0
	jmp	.calc_plot(pc,d0)
	
.calc_plot:
	dcb.l	NBLIG-1,$34c1d383
;	REPT	NBLIG-1
;	move	d1,(a2)+
;	addx.l	d3,d1
;	ENDR
	move	d1,(a2)+
	
	IFNE	DEBUG*0
	cmp	(a0),d1
	bne.s	.nobord
	
	not	$ffff8240
	ENDC
.nobord:
	move	d6,d0
	
	bra	new_plotr
	
fin_plotr:
		;#] Calcul right plot:

	lea	points_gauche,a2
	move.l	a0,a3
	move	d5,d0
		;#[ Calcul left plot:
; D0 : Position Y courante
; D7 : May
; A2 : Table points gauches
; A0 : Adresse points le plus haut
; A5 : Adresse du dernier point
; A6 : Adresse du premier point
new_plotl:
	move	-(a0),d2	; Y1
	move	-(a0),d1	; X1
	cmp.l	a6,a0
	bgt.s	.ok
	move.l	a5,a0
.ok:
	move	-2(a0),d4	; Y2
	move	-4(a0),d3	; X2

	cmp.l	a3,a0
	beq	fin_plotl
	cmp	d5,d4
	ble.s	new_plotl
	move	d4,d6
	cmp	d7,d6	; Point plus bas que may?
	blt.s	.oklow	; Non
	move	d7,d6
	cmp	d2,d7	; Y2 superieur a Y1 courant?
	ble	fin_plotl
.oklow:
	add	d1,d1
	add	d1,d1
	add	d3,d3
	add	d3,d3
	
	sub	d1,d3
	sub	d2,d4

	cmp	miy(pc),d2
	bge.s	.noclip
	sub	d5,d2	; On cherche X de d‚part par rapport … d5
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
	
	sub	d6,d5
	bge	.nobord
	addi	#NBLIG,d5
	swap	d1
	move	d3,d1
	beq	fast_plotl
	addi	#$8000,d1
	swap	d1
	swap	d3
	add	d5,d5
	add	d5,d5
	jmp	.calc_plot(pc,d5)
	
.calc_plot:
	dcb.l	NBLIG-1,$34c1d383
;	REPT	NBLIG-1
;	move	d1,(a2)+
;	addx.l	d3,d1
;	ENDR
	move	d1,(a2)+
	
	IFNE	DEBUG*0
	cmp	(a0),d1
	bne.s	.nobord
	
	not	$ffff8240
	ENDC
.nobord:
	move	d6,d5
	
	bra	new_plotl
	
fin_plotl:
		;#] Calcul left plot:
	
	move	d5,d1
	sub	d0,d1
	move	colorpoly(pc),d2
	move.l	ec1,a6
	add	d2,d2
	adda	d2,a6

	Tstcol	$077	
	move.l	curline,a0
	bsr	call_line

	rts
	
		;#[ Fast calcul:
fast_plotl:
	swap	d1
	swap	d3
	beq	very_fast_plotl
	
	add	d5,d5
	add	d5,d5
	jmp	.calc_fplot(pc,d5)
	
.calc_fplot:
	dcb.l	NBLIG,$34c1d243
;	REPT	NBLIG
;	move	d1,(a2)+
;	add	d3,d1
;	ENDR
	
	move	d6,d5
	
	bra	new_plotl
	
very_fast_plotl:
	bclr	#0,d5
	bne.s	.no
	move	d1,(a2)+
.no:
	move	d1,d2
	swap	d1
	move	d2,d1
	jmp	.calc_fplot(pc,d5)
	
.calc_fplot:
	dcb.w	NBLIG/2,$24c1
;	REPT	NBLIG/2
;	move.l	d1,(a2)+
;	ENDR
	
	move	d6,d5
	
	bra	new_plotl
	
fast_plotr:
	swap	d1
	swap	d3
	beq	very_fast_plotr
	
	add	d0,d0
	add	d0,d0
	jmp	.calc_fplot(pc,d0)
	
.calc_fplot:
	dcb.l	NBLIG,$34c1d243
;	REPT	NBLIG
;	move	d1,(a2)+
;	add	d3,d1
;	ENDR
	
	move	d6,d0
	
	bra	new_plotr
	
very_fast_plotr:
	bclr	#0,d0
	bne.s	.no
	move	d1,(a2)+
.no:
	move	d1,d2
	swap	d1
	move	d2,d1
	jmp	.calc_fplot(pc,d0)
	
.calc_fplot:
	dcb.w	NBLIG/2,$24c1
;	REPT	NBLIG/2
;	move	d1,(a2)+
;	ENDR
	
	move	d6,d0
	
	bra	new_plotr
	
		;#] Fast calcul:
	
 ; #] Affpoly:

 ; #[ Very fast horizontal line:
; ------------------------------------------------------------------------ ;
; 	     Appel routine de tracage horizontal		;
;	           (Gere le clipping en Y)		;
; ------------------------------------------------------------------------ ;
 
	; #[ Calling rout:
; Routine d'appele
; A0 : Routine a appele
; A6 : Adresse ecran
; D0 : Position Y
; D1 : Nbr de ligne a afficher

curline	dc.l	hline_one_plane

call_line:
	tst	d1
	blt.s	.noaff

	lea	points_gauche,a4
	lea	points_droite,a5

	cmp	miy(pc),d0
	bge.s	.ok

	sub	miy(pc),d0
	add	d0,d1
	blt.s	.noaff
	
	add	d0,d0
	suba	d0,a4
	suba	d0,a5
	
	move	miy(pc),d0
.ok:

	move	d0,d2
	add	d1,d2
	cmpi	#NBLIG,d2
	blt.s	.ok2
	
	move	#NBLIG,d1
	sub	d0,d1
	blt	.noaff
.ok2:

	move	d0,d3	
	lsl	#5,d3
	move	d3,d2
	add	d3,d3
	add	d3,d3
	add	d2,d3
	adda	d3,a6
	move	d1,d7	; * 160
	
	jmp	(a0)
	
.noaff:
	rts
	
; ------------------------------------------------------------------------ ;
;	       Tracage de ligne horizontal 1 plan.		;
; ------------------------------------------------------------------------ ;
; A4: Table des points gauches
; A5:   "    "    "    droits
; A6: Adresse ecran
; D7: Nombre le ligne en hauteur

; ************ ;	
; Non tram‚es: ;
; ************ ;
hline_one_plane:
	moveq	#$ffffffff,d5
	lea	ldecal,a1
	lea	rdecal,a2

qline	=	*+2	
	jmp	line68000
	
line68000:
	lsl	#7,d7 ; La routine fait 128 octets
	neg	d7
	lea	phline2,a3
	jmp	(a3,d7)
	
line68030:
	subq	#1,d7
	
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
	dbra	d7,hline2
	
	rts

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
	
qlinet	=	*+2
	jmp	line68000t
	
line68000t:
	lsl	#3,d7
	move	d7,d0
	lsl	#4,d7
	add	d0,d7 ; La routine fait 136 octets
	neg	d7
	lea	phlinet2,a3
	jmp	(a3,d7)
	
line68030t:
	subq	#1,d7
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
	dbra	d7,hline_tramed2
	
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
	bra	jmp_one_plane_tramed
	
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
; ---------------------------------------------------------------------------- ;
;	Routine de cercle. (C) Copyright 1990 Ziggy STARDUST.	    ;
; ---------------------------------------------------------------------------- ;

	; #[ Calling rout:
; D1 = Rayon du cercle
; D2 = Position Y de centre du cercle
; D3 = Position X du centre du cercle

circle:
	move	#$0300,sr
	move.l	a7,oldpile
	
	move	d1,d7
	move	d1,d2
	add	d1,d2
	
	lea	points_droite,a0
	move.l	a0,a4
	move.l	a0,a5
	adda	d2,a5
	adda	d2,a5
	adda	d2,a0
	move.l	a0,a1
	
	lea	points_gauche,a2
	move.l	a2,a6
	move.l	a2,a7
	adda	d2,a7
	adda	d2,a7
	adda	d2,a2
	move.l	a2,a3
	
	cmpi	#1,d7
	ble.s	.nocircle
	
	add	d3,d3
	add	d3,d3

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
	
	add	d7,d7
	add	d7,d7
	move	d7,d0
	asl	#3,d7
	add	d0,d7	; * 36 octets

	clr	d0
	ext.l	d7
	move.l	#circle_rout,jmpcircle
	add.l	d7,jmpcircle
	move	d3,d6
	move	d3,d7

jmpcircle:	=	*+2
	jmp	$0.l
	
.nocircle:
	moveq	#0,d0
	move	d0,-(a0)
	move	d0,(a1)+
	move	d0,-(a2)
	move	d0,(a3)+

	move.l	oldpile(pc),a7
	trap	#3
	
	rts
	
	; #] Calling rout:
	; #[ Initiale routine:	(36 octets...)
	
; D0 = Y
; D1 = X
; D2 = X2

circle1:
	add	d0,d2
	blt.s	.ok

.tst:
	subq	#1,d1
	subq	#4,d4
	addq	#4,d5
	
	move	d6,(a4)+
	move	d6,-(a5)
	move	d7,(a6)+
	move	d7,-(a7)

	sub	d1,d2
	bge.s	.tst
.ok:
	addq	#1,d0

	addq	#4,d6
	subq	#4,d7
	
	move	d4,-(a0)
	move	d4,(a1)+
	move	d5,-(a2)
	move	d5,(a3)+

circle2:
	; #] Initiale routine:
	; #[ Genere cercle:
genere_circle:
	lea	debut_circle_rout,a1
	move	#NBLIG*2-1,d0
	
.g_circle:
	lea	circle1(pc),a0
	move	#(circle2-circle1)/2-1,d1
	
.g_circle2:
	move	(a0)+,(a1)+

	dbra	d1,.g_circle2

	dbra	d0,.g_circle
	
	move	#$4ef9,(a1)+
	move.l	#retour,(a1)+	; --> Jmp	retour
	
	rts

	section	bss
	
debut_circle_rout:
	ds.b	(circle2-circle1)*NBLIG*2
circle_rout:
	ds.w	3
	
	section	text
	; #] Genere cercle:
	
 ; #] Circle rout:

 ; #[ Main programm:

mainloop:
	subq	#1,curseq_time
	bgt.s	.no_new_sequence
	
	move.l	curseq_list(pc),a0
	move.l	(a0)+,a1
	jsr	(a1)
	move.l	(a0)+,curseq
	move.l	(a0)+,curobj
	move	(a0)+,ox
	move	(a0)+,oy
	move	(a0)+,oz
	move	(a0)+,va
	move	(a0)+,vb
	move	(a0)+,vg
	move	(a0)+,curseq_time
	move.l	a0,curseq_list
	
.no_new_sequence:
	move.l	curseq(pc),a0
	jsr	(a0)
	bsr	anime3d

	bra.w	mainloop
	
 ; #] Main programm:
 ; #[ Anime:

	; #[ Animation sequence list:
	
		;#[ Format:
;	dc.l	Init_sequence,Sequence
;	dc.l	Objet
;	dc.w	ox,oy,oz
;	dc.w	va,vb,vg
;	dc.w	time
		;#] Format:

	section	data
sequences:
	section	text
	
		;#[Current sequence:
curseq_list	dc.l	sequences
curseq	dc.l	start_seq
curobj	dc.l	obj1
curseq_time	dc.w	$7fff

start_seq:
	tst.b	clav+$1c
	beq.s	.no

	clr	curseq_time	
.no:
	rts
		;#]Current sequence:
	
	; #] Animation sequence list:

; Ne pas utiliser le registre A0. Les autres sont inchang‚s d'une VBL a l'autre.
	; #[ Deliro cylindre:

DELIROY	=	300
DELIROZ	=	-1400
	
	section	data
	dc.l	init_deliro,deliro_arrive
	dc.l	obj7
	dc.w	0,-900,DELIROZ
	dc.w	0,0,0
	dc.w	90+DELIROY/10
	
	dc.l	nothing,deliro
	dc.l	obj7
	dc.w	0,DELIROY,DELIROZ
	dc.w	9,0,0
	dc.w	1024
	
	dc.l	nothing,deliro_back
	dc.l	obj7
	dc.w	0,DELIROY,DELIROZ
	dc.w	0,0,0
	dc.w	100
	section	text
	
init_deliro:
	clr	oba
	clr	obb
	clr	obg
	
	move.l	obj7,a3
	clr	8(a3)	; Remise a zero de l'animation
	
	move	#292,oba
	lea	table+TSINUS/2,a2
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	rts
deliro_arrive:
	addi	#10,oy
	rts
deliro_back:
	addi	#20,oy
	rts
deliro:
	addq	#8,d1
	andi	#TSINUS/2-1,d1
	move	d1,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#1500,d2
	swap	d2
	addi	#DELIROY,d2
	move	d2,oy
	
	addq	#5,d3
	andi	#TSINUS-1,d3
	move	d3,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#600,d2
	swap	d2
	addi	#DELIROZ,d2
	move	d2,oz
	
	addq	#7,d4
	andi	#TSINUS-1,d4
	move	d4,d2
	add	d2,d2
	move	(a2,d2),d2
	muls	#500,d2
	swap	d2
	move	d2,ox
	asr	#2,d2
;	tst	d2
;	bge.s	.neg
;	neg	d2
;.neg:
	andi	#TSINUS-1,d2
	move	d2,obg
	
	rts
	; #] Deliro cylindre:

	; #[ Last sequence:
	
	section	data
	dc.l	init_normal_sequence,last_sequence
	dc.l	obj1
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
	clr	oba
	clr	obb
	clr	obg
nothing:
	rts
normal_sequence:
	rts
	; #] Normal sequence:
	; #[ Vbl synchro, clearing screen, calling Afforme:
anime3d:
	movem.l	d0-a6,-(a7)
	bsr.w	anime
	
	IFNE	ABSOLUTE_MOUSE
	move	mousex,d0
	subi	#MAX_MOUSEX/2,d0
	neg	d0
	move	d0,ox
	
	move	mousey,d0
	subi	#MAX_MOUSEY/2,d0
	move	d0,oy
	
	jsr	waitc
	move.b	#$0d,$fffffc02.w ; Ask for mouse position
	ENDC
	
	tst.b	clav+67	; <F9>?
	bne.s	.norot

	move	oba,d0
	add	va,d0
	andi	#TSINUS-1,d0
	move	d0,oba

	move	obb,d0
	add	vb,d0
	andi	#TSINUS-1,d0
	move	d0,obb
	
	move	obg,d0
	add	vg,d0
	andi	#TSINUS-1,d0
	move	d0,obg
.norot:

	move.l	curobj,a0
	move	oba,10(a0)
	move	obb,12(a0)
	move	obg,14(a0)
	
	lea	16(a0),a6
	bsr	afforme
	
	movem.l	(a7)+,d0-a6
	rts

neffecr:	dc	0
anime:
	Tstcol	$000

	IFNE	DEBUG
	tst.b	qaffn
	beq.s	.no
	
	move	oz,d0
	move.l	ec1,a0
	lea	2*8*160(a0),a0
	bsr	affnr
.no:
	ENDC

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
	clr.b	used_plane

	Flab
               tst	neffecr
               beq.s	.no
               subq	#1,neffecr
	move.l	ec1,a0
	bsr	cls1plan
.no:

	Tstcol	$700
	rts
	
	; #] Vbl synchro, clearing screen, calling Afforme:

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
curlim	ds.l	1

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
	bsr	playmus
	ENDC
	bsr	test_touche
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
	include	e:\musique.ovr\replay\replay.s
music:	incbin	e:\musique.ovr\replay\coso\sevgate2.*
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

debut_objets	=	*+$1c
	incbin	objets.prg
	
 ; #] 3D Objects:
 ; #[ Objects defs:
	; #[ Macros:
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
;		 X  Y  Z  A  B  G
	ENDM
OBJETR	MACRO
	dc.l	0
	dc.w	\1,\2,\3,\4,\5,\6
;		 X  Y  Z  A  B  G
	ENDM
	; #] Macros:

debut_objets_def:
obj1	OBJETR	0,0,30,0,0,0	; Cube
obj2	OBJETR	0,0,30,0,0,0	; 'A'
obj3	OBJETR	0,0,1975,0,0,0	; Dodecaedre
obj4	OBJETR	0,0,200,0,0,0	; Vaisseau
obj5	OBJETR	0,0,30,0,0,0	; Boule
obj6	OBJETR	0,0,30,0,0,0	; Pyramide
obj7	OBJETR	0,0,30,0,0,0	; Deliro cylindre
obj8	OBJETR	0,0,30,0,0,0	; Cube transparent
	dc.l	-1
 ; #] Objects defs:

 ; #[ Variables:
 	
 	section	data
		
	section	bss
	
	; #[ Variables_systemes:
oldpal	ds.w	16

oldbomb	ds.l	8
oldrez	ds.b	1
oldrez_tt	ds.b	1
	even
oldec	ds.l	1
	; #] Variables_systemes:

plot3d	ds.w	128*3	* Table des points apres calcul 3D
plot2d	ds.w	128*2	* 128 points max dans une forme 3D

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

