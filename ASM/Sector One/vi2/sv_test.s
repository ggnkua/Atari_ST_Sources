; Programme de test de la routine de g‚n‚ration de modes vid‚o
; par Zerkman/Trisomic Development

	opt	o-,x+
	bra	start

larg_tc		equ	640
haut_tc		equ	200
taille_tc	equ	320*200*2

larg_256	equ	640	;largeur en octets
haut_256	equ	480
taille_256	equ	640*480

larg_16		equ	160
haut_16		equ	200
taille_16	equ	320*200/2

larg_2		equ	80
haut_2		equ	400
taille_2	equ	640*400/8

	include	'set_vid.s'	;la routine en question

*****************************************************************************************
;	D‚but de la routine de test
*****************************************************************************************

start

	pea	super(pc)
	move	#38,-(sp)	;supexec()
	trap	#14
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

super
	lea	source_tbl(pc),a0
	lea	dest_tbl(pc),a1
	bsr	genere_mode
	tst	d0
	bpl.s	.suite
	bsr	bip
	rts
.suite

	bsr	sauve_videl
	bsr	installe_mode
	bsr	sauve_palette_pointeur_video
	bsr	affiche_image

	bsr	attend_touche
	bsr	restaure_palette_pointeur_video
	bsr	restaure_videl

	rts

sauve_videl
	lea	save_regs(pc),a1
	lea	vector_list(pc),a0
	lea	$ffff8200.w,a2
.bcl	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.fin_bcl
	lea	(a2,d0.w),a3	;adresse du registre
	move	(a3),(a1)+
	bra.s	.bcl
.fin_bcl
	rts

restaure_videl
	bsr	synchro_vbl

	clr	$ffff8266.w
	lea	save_regs(pc),a1
	lea	vector_list(pc),a0
	lea	$ffff8200.w,a2
.bcl	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.fin_bcl
	lea	(a2,d0.w),a3	;adresse du registre
	move	(a1)+,(a3)
	bra.s	.bcl
.fin_bcl
	rts

installe_mode
	bsr	synchro_vbl
	lea	dest_tbl(pc),a1
	lea	vector_list(pc),a0
	lea	$ffff8200.w,a2
.bcl	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.fin_bcl
	lea	(a2,d0.w),a3	;adresse du registre
	move	(a1)+,(a3)
	bra.s	.bcl
.fin_bcl
	clr.b	$ffff8265.w
	rts

affiche_image
; Charge et affiche l'image dans la m‚moire ‚cran en affichant la palette

	move	nc(pc),d6
	lea	file_list(pc),a0
	move.l	(a0,d6.w*4),a0

	clr	-(sp)
	pea	(a0)
	move	#$3d,-(sp)	;fopen
	trap	#1
	addq.l	#8,sp
	move	d0,d7
	bmi	file_error

	bsr	synchro_vbl

	lea	screen_mem(pc),a6
	move.l	a6,d0
	addq.l	#3,d0
	and.l	#-4,d0
	move.l	d0,a6

	move	d0,d1
	lsr.w	#8,d0

	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	tst	d6
	bne.s	no_2

; Routine de gestion du mode 2 couleurs :
	clr	-(sp)
	move	d7,-(sp)
	pea	34.w
	move	#$42,-(sp)	;fseek()
	trap	#1
	lea	10(sp),sp

	clr.l	$ffff9804.w

	move.l	#taille_2,d3
	move	#larg_2,d5
	move	#haut_2,d4

	bra	no_tc
no_2	subq	#1,d6
	bne.s	no_16

	clr	-(sp)
	move	d7,-(sp)
	pea	2.w
	move	#$42,-(sp)	;fseek()
	trap	#1
	lea	10(sp),sp

	pea	(a6)
	pea	32.w
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

;	lea	$ffff8240.w,a0	;4096 couleurs
	lea	$ffff9800.w,a0	;262144 couleurs
	move.l	a6,a1
	moveq	#15,d0
.bcl	move	(a1)+,d1
;	move	d1,(a0)+	;4096 couleurs
	move	d1,d2
	and.l	#$700,d2
	swap	d2
	lsl.l	#5,d2
	move	d1,d3
	and.l	#$070,d3
	swap	d3
	lsl.l	#1,d3
	or.l	d3,d2
	and.l	#$007,d1
	lsl.l	#5,d1
	or.l	d1,d2
	move.l	d2,(a0)+	;262144 couleurs
	dbra	d0,.bcl

	move.l	#taille_16,d3
	move	#larg_16,d5
	move	#haut_16,d4

	bra.s	no_tc
no_16	subq	#1,d6
	bne.s	no_256

	pea	(a6)
	pea	1024.w
	move	d7,-(sp)
	move	#$3f,-(sp)	;fread
	trap	#1
	lea	12(sp),sp

	move.l	a6,a0
	lea	$ffff9800.w,a1
	moveq	#127,d0
.copy	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.copy

	move.l	#taille_256,d3
	move	#larg_256,d5
	move	#haut_256,d4

	bra.s	no_tc
no_256
	move.l	#taille_tc,d3
	move	#larg_tc,d5
	move	#haut_tc,d4

no_tc

*	move.l	#$ffff00ff,$ffff9800.w
	pea	(a6)
	move.l	d3,-(sp)
	move	d7,-(sp)
	move	#$3f,-(sp)	;fread
	trap	#1
	lea	12(sp),sp

	move	d7,-(sp)
	move	#$3e,-(sp)	;fclose
	trap	#1
	addq.l	#4,sp

	move.l	#screen2_mem,d0
	addq.l	#3,d0
	andi.w	#-4,d0
	move.l	d0,a5		;‚cran destination

	move	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	move	x_width(pc),d0
	subq	#1,d0		;largeur ‚cran en mots - 1

	move.l	a6,a0		;‚cran source
	move.l	a6,a4
	add.l	d3,a4		;adresse de fin d'image
	move.l	a5,a1

	move	yr(pc),d2
	subq	#1,d2
.ligne_bcl
	move.l	a0,a3
	add.w	d5,a3		;adresse de bouclage de ligne
	move.l	a0,a2		;pointeur ligne source
	move	d0,d1
.mot_bcl
	move	(a2)+,(a1)+
	cmp.l	a3,a2		;on a fini la ligne source ?
	bmi.s	.ok
	move.l	a0,a2		;oui : on reboucle sur la mˆme ligne
.ok
	dbra	d1,.mot_bcl
	add	d5,a0
	cmp.l	a4,a0
	bmi.s	.ok2
	move.l	a6,a0
.ok2
	dbra	d2,.ligne_bcl
	rts

file_error
	bsr	bip
	rts

sauve_palette_pointeur_video
	lea	spalette_ecr(pc),a0
	move.l	$ffff8200.w,d0
	lsl.w	#8,d0
	move.b	$ffff820d.w,d0	;d0 = adresse ‚cran
	move.l	d0,(a0)+
	lea	$ffff9800.w,a1
	moveq	#127,d0
.bcl	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,.bcl
	rts

restaure_palette_pointeur_video
	lea	spalette_ecr(pc),a0
	move.l	(a0)+,d0
	move.b	d0,$ffff820d.w
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	lea	$ffff9800.w,a1
	moveq	#127,d0
.bcl	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.bcl
	rts

attend_touche
	move	#2,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	rts
synchro_vbl
	move.l	$466.w,d0
.bcl	cmp.l	$466.w,d0
	beq.s	.bcl
	rts
bip
	move	#7,-(sp)
	move	#2,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	rts

	section	data
vector_list
	dc.b	$82
	dc.b	$84
	dc.b	$86
	dc.b	$88
	dc.b	$8a
	dc.b	$8c
	dc.b	$a2
	dc.b	$a4
	dc.b	$a6
	dc.b	$a8
	dc.b	$aa
	dc.b	$ac
	dc.b	$c0
	dc.b	$c2
	dc.b	$10
	dc.b	$66
	dc.b	0

	even
source_tbl
;	dc.w	800	;npix
;	dc.w	640	;xres
;	dc.w	140	;xdec
;	dc.w	322	;nlin
;yr	dc.w	592	;yres
;	dc.w	21	;ydec
;nc	dc.w	2	;ncolour
;	dc.w	6	;vmode
;	dc.w	0	;mhz

	dc.w	270	;npix
	dc.w	208	;xres
	dc.w	78	;xdec
	dc.w	630	;nlin
yr	dc.w	304	;yres
	dc.w	9	;ydec
nc	dc.w	2	;ncolour
	dc.w	1	;vmode
	dc.w	1	;mhz

file_list	dc.l	pict_2,pict_16,pict_256,pict_tc
pict_2		dc.b	'd:\devpac\sources.s\vi_2_0\pict_2.pi3',0
pict_16		dc.b	'd:\devpac\sources.s\vi_2_0\pict_16.pi1',0
pict_256	dc.b	'd:\devpac\sources.s\vi_2_0\pict_256.zer',0
pict_tc		dc.b	'd:\devpac\sources.s\vi_2_0\pict_tc.f16',0
	even
	section	bss
save_regs	ds.w	64

dest_tbl
x_hht		ds.w	1
x_hbb		ds.w	1
x_hbe		ds.w	1
x_hdb		ds.w	1
x_hde		ds.w	1
x_hss		ds.w	1
x_vft		ds.w	1
x_vbb		ds.w	1
x_vbe		ds.w	1
x_vdb		ds.w	1
x_vde		ds.w	1
x_vss		ds.w	1
x_rco		ds.w	1
x_vco		ds.w	1
x_width		ds.w	1
x_colour	ds.w	1

spalette_ecr	ds.b	1024+4

screen_mem	ds.b	1011712/2	;r‚so max. 1664x608 256 couleurs ou 832*604 True Color
screen2_mem	ds.b	1011712/2
