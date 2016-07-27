; fade: d‚part  blanc->palette
;       arriv‚e palette ->$101

;
; Zoomer
;

; rotozoom:
;
; (x',y') = pt de l'image de d‚part
; (X, Y)  = pt de l'‚cran
; On applique une d‚formation:
; x' = f(X,Y)
; y' = g(X,Y)
;
; zoom:
; x'=A*X
; y'=B*Y
;
; rotation:
; x'=X*cos(a) + Y*sin(a)
; y'=Y*cos(a) + X*sin(a)
;

; calcul des vecteurs directeurs:
; dax' = Gx * (cos(a)+sin(a))	; Gx,Gy = facteur de zoom
; day' = Gy * (cos(a)+sin(a))
; attention, ‡a ne marche peut ˆtre pas de cette maniŠre

transition_pourrie	equ	0	; faire joujou avec...
use_lib_screen		equ	1	; utilise l'‚cran par d‚faut fourni
					; par la lib par _screen.w (=1 -> oui)
finale_version		equ	1	; … 1 -> attend count_vbl au lieu d'attendre
					; un appui sur espace
showtime		equ	0	; … 1, affiche le temps cpu libre
count_vbl		equ	500	; nb de vbl prises par le roto
					; ne tient pas compte du pr‚calc
disp_lines		equ	50	; nombre de lignes rotozoom‚es

hotsync_value		equ	3
lib_debug		equ	0

	opt	brw,bdw,p=68000	; comment‚ -> compatibilit‚ assemble
	opt	o+
	opt	ow-	; pas de warnings, on s'en fout des warnings !
	opt	x-
	opt	d-

	incdir	"C:\zoomer.4pl"

	include	"C:\demo\video2.s"

vsync		macro
			move.l	d0,-(sp)
			move.w	$466+2.w,d0
			cmp.w	$466+2.w,d0
			beq.s	*-4
			move.l	(sp)+,d0
		endm

fast_vsync	macro
			move.w	$466+2.w,d0
			cmp.w	$466+2.w,d0
			beq.s	*-4
		endm

oh_qu_il_est_pas_bo_ce_code_oh_la_la_la_la_la_la_la
		moveq	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d1,d3
		move.l	d2,d4
		move.l	d0,d5
		move.l	d1,d6
		move.l	d2,d7

		move.l	_fxvbl.w,-(sp)
		move.l	_palvbl.w,-(sp)

		lea	$ffff8240.w,a0
		lea	t_palette_fx,a1
		lea	palette_fx,a2
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		movem.l	d0-d7,(a2)
	
		move.l	#vbl_fx,_fxvbl.w
		move.l	#vbl_pal,_palvbl.w

		move.l	#buf_ecrans,d0
		clr.b	d0
		add.l	#256,d0
		move.l	d0,log
	ifne	use_lib_screen
		move.l	_screen.w,a0	; pour transition future...
		move.l	a0,phys
	else
		add.l	#32000,d0
		move.l	d0,phys
	endc

.clear_screen
		move.l	log,a0
		move.l	phys,A1 
		move.w	#$1f3f,d0
		moveq	#0,d1
.efface
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		dbf	d0,.efface

		move.l	log,a0
		move.l	phys,a1
		lea	moongirl_pic,a2
		move.w	#8000-1,d0
.copy_pic	move.l	(a2)+,d1
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		dbra	d0,.copy_pic

		move.l	log,d0
		move.l	phys,log
		move.l	d0,phys
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		fast_vsync

		bsr	init_zoomer

go
;========================================================================================

	lea	t_palette_fx,a0		; d‚part = $ffff8240
	lea	palette_fx,a2		; arriv‚e
	bsr	Fade_In

Main
		move.l	log,d0
		move.l	phys,log
		move.l	d0,phys
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		fast_vsync

		bsr	zoomer

; gestion bˆte et m‚chante du nombre de lignes affich‚es
; -> transition de d‚but
	ifne	transition_pourrie
		lea	how_many_above,a0
		cmp.w	#disp_lines-1,(a0)
		beq.s	.ok
		addq.w	#1,(a0)
.ok
	endc

; version finale: effacer les lignes non comment‚es
; et d‚commenter les deux lignes suivantes:
	ifne	finale_version
		tst.w	flag_quit_effet
		beq.s	Main
	else
		cmp.b	#$39+$80,$fffffc02.w
		bne.s	Main
	endc

.END

		lea	t_palette_fx,a0
		move.w	#$101,d0		; vers la couleur de fond
		bsr	Fade_Out

; oh, t'as vu ? je t'efface mˆme l'‚cran !
.clear_screen
		move.l	log,a0
		move.l	phys,A1 
		move.w	#$1f3f,d0
		moveq	#0,d1
.efface
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		dbf	d0,.efface

		move.l	(sp)+,_palvbl.w
		move.l	(sp)+,_fxvbl.w

		rts

cnt_vbl		dc.w	count_vbl

;========================================================================================
;========================================================================================
;========================================================================================

vbl_fx		addq.l	#1,$466.w
		tst.l	_music.w
		beq.s	.nozic
		move.l	_music.w,a0
		jsr	(a0)
.nozic
		rts

vbl_pal
		lea	t_palette_fx,a0
off		set	0
		REPT	7
		move.l	(a0)+,$ffff8240+off.w
off		set	off+4
		ENDR
		move.l	(a0),$ffff8240+off.w
		rts


;========================================================================================
;========================================================================================

init_zoomer

;	move.w	#0,TAILLE

.gen_c2p_table
		lea	c2p_table,a0
		lea	.c2p1,a1
		lea	.c2p2,a2
		lea	.c2p3,a3
		lea	.c2p4,a4
		moveq	#5,d7	; pour lsl.w
		moveq	#0,d0	; compteur

.calc_c2p
	; on fait ‡a pour 65536 valeurs...
		move.w	d0,d1
		move.w	d0,d2
		move.w	d0,d3
		move.w	d0,d4

		and.w	#$f000,d1
		and.w	#$f00,d2
		and.w	#$f0,d3
		and.w	#$f,d4
		lsr.w	d7,d1		; #5
		lsr.w	#4,d1
		lsr.w	d7,d2		; #5
		lsr.w	#1,d3
		lsl.w	#3,d4

		move.l	(a4,d1.w),d5	; pixel 1
		move.l	4(a4,d1.w),d6
		or.l	(a3,d2.w),d5	; pixel 2
		or.l	4(a3,d2.w),d6
		or.l	(a2,d3.w),d5	; pixel 3
		or.l	4(a2,d3.w),d6
		or.l	(a1,d4.w),d5	; pixel 4
		or.l	4(a1,d4.w),d6

		move.l	d5,(a0)+
		move.l	d6,(a0)+

		addq.w	#1,d0
;		move.w	d0,d0	; remplace un 'tst.w d0'
		bne.s	.calc_c2p

.copy_chunky
chunky_size	equ	256*128
		lea	chunky_orig_1,a0
		lea	chunky_orig_0,a1
		move.l	#chunky_size,d0
		lea	chunky_copy_1,a2
		move.l	a2,a3
		add.l	d0,a3
		move.l	a3,a4
		add.l	d0,a4
		move.l	a4,a5
		add.l	d0,a5
		move.w	#256*128/4-1,d7
		moveq	#4,d6
.copy_1_decal_0
		move.l	(a0)+,d0
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		move.l	d0,(a4)+
		move.l	d0,(a5)+
		lsl.l	d6,d0
		move.l	d0,(a1)+
		dbra	d7,.copy_1_decal_0

		lea	chunky_orig_0,a0
		move.l	#chunky_size,d0
		move.l	a0,a2
		add.l	d0,a2
		move.l	a2,a3
		add.l	d0,a3
		move.l	a3,a4
		add.l	d0,a4
		move.w	#256*128/4-1,d7
.copy_0
		move.l	(a0)+,d0
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		move.l	d0,(a4)+
		dbra	d7,.copy_0

		rts
.c2p1
		dc.l	$00000000,$00000000
		dc.l	$000f0000,$00000000
		dc.l	$0000000f,$00000000
		dc.l	$000f000f,$00000000
		dc.l	$00000000,$000f0000
		dc.l	$000f0000,$000f0000
		dc.l	$0000000f,$000f0000
		dc.l	$000f000f,$000f0000
		dc.l	$00000000,$0000000f
		dc.l	$000f0000,$0000000f
		dc.l	$0000000f,$0000000f
		dc.l	$000f000f,$0000000f
		dc.l	$00000000,$000f000f
		dc.l	$000f0000,$000f000f
		dc.l	$0000000f,$000f000f
		dc.l	$000f000f,$000f000f

.c2p2
		dc.l	$00000000,$00000000
		dc.l	$00f00000,$00000000
		dc.l	$000000f0,$00000000
		dc.l	$00f000f0,$00000000
		dc.l	$00000000,$00f00000
		dc.l	$00f00000,$00f00000
		dc.l	$000000f0,$00f00000
		dc.l	$00f000f0,$00f00000
		dc.l	$00000000,$000000f0
		dc.l	$00f00000,$000000f0
		dc.l	$000000f0,$000000f0
		dc.l	$00f000f0,$000000f0
		dc.l	$00000000,$00f000f0
		dc.l	$00f00000,$00f000f0
		dc.l	$000000f0,$00f000f0
		dc.l	$00f000f0,$00f000f0

.c2p3
		dc.l	$00000000,$00000000
		dc.l	$0f000000,$00000000
		dc.l	$00000f00,$00000000
		dc.l	$0f000f00,$00000000
		dc.l	$00000000,$0f000000
		dc.l	$0f000000,$0f000000
		dc.l	$00000f00,$0f000000
		dc.l	$0f000f00,$0f000000
		dc.l	$00000000,$00000f00
		dc.l	$0f000000,$00000f00
		dc.l	$00000f00,$00000f00
		dc.l	$0f000f00,$00000f00
		dc.l	$00000000,$0f000f00
		dc.l	$0f000000,$0f000f00
		dc.l	$00000f00,$0f000f00
		dc.l	$0f000f00,$0f000f00

.c2p4
		dc.l	$00000000,$00000000
		dc.l	$f0000000,$00000000
		dc.l	$0000f000,$00000000
		dc.l	$f000f000,$00000000
		dc.l	$00000000,$f0000000
		dc.l	$f0000000,$f0000000
		dc.l	$0000f000,$f0000000
		dc.l	$f000f000,$f0000000
		dc.l	$00000000,$0000f000
		dc.l	$f0000000,$0000f000
		dc.l	$0000f000,$0000f000
		dc.l	$f000f000,$0000f000
		dc.l	$00000000,$f000f000
		dc.l	$f0000000,$f000f000
		dc.l	$0000f000,$f000f000
		dc.l	$f000f000,$f000f000


;========================================================================================

zoomer
calc_zoomer
	move.l	#"Dune",d3
	move.l	adr_delta,A0
	lea	DELTA,a1
	MOVE.L	(A0)+,(a1)		; d‚termine la rotation
; organisation de la table: word 1 = Delta, word 2 = Sygma ...

	CMP.L	(A0),d3 
	bne.s	.no_reset_delta

	LEA	tab_delta,A0 
.no_reset_delta
	move.l	a0,adr_delta 

	cmp.b	#2,$fffffc02.w
	beq.S	.no_reset_taille

	move.l	ADR_TAIL,a0
	MOVE.W	(A0)+,4(a1)		; d‚termine le zoom (move.w (a0)+,TAILLE
	CMP.L	(A0),d3
	BNE.S	.no_reset_taille
; ici, je dois quitter l'effet...
.quit_effet
	not.w	flag_quit_effet
.no_reset_taille
	MOVE.L	A0,ADR_TAIL 

;	addq.w	#1,TAILLE

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	(a1)+,D0
	MOVE.W	(a1),D1
	subq.l	#2,a1
;	bra.s	.skip_zoom
	MULS	TAILLE,D0	; applique le zoom
	MULS	TAILLE,D1	; Z
	MOVEQ	#9,D2		; Z
	ASR.L	D2,D0		; Z
	ASR.L	D2,D1		; Z
.skip_zoom
	MOVE.W	D0,(a1)+	; move.w	d0,DELTA
	MOVE.W	D1,(a1)		; move.w	d1,SYGMA

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	(a1),D0
	EXT.L	D0
	NEG.L	D0

	MOVEA.L	D0,A0		; = composant pour calcul offsets...
				; cad vecteur X
	MOVE.W	-(a1),D1	; move.w	DELTA,d1
	EXT.L	D1
	ROR.L	#8,D1
	MOVEA.L	D1,A1		; = composant pour calcul offsets...
				; cad vecteur X
	MOVEQ	#0,D0		; le vecteur X est un d‚placement
	MOVEQ	#0,D1		; relatif … chaque point ‚cran
	MOVEQ	#0,D2		; afin de d‚terminer quel donn‚e
	MOVEQ	#0,D3		; chunky prendre

modif	macro
	MOVE.W	D0,D2
	MOVE.B	D1,D2
	MOVE.W	D2,offset1(A6)

	ADD.W	A0,D0
	ADD.L	A1,D1
	ADDX.W	D3,D1
	MOVE.W	D0,D2
	MOVE.B	D1,D2
	MOVE.W	D2,offset2(A6)

	ADD.W	A0,D0
	ADD.L	A1,D1
	ADDX.W	D3,D1
	MOVE.W	D0,D2
	MOVE.B	D1,D2
	MOVE.W	D2,offset3(A6)

	ADD.W	A0,D0
	ADD.L	A1,D1
	ADDX.W	D3,D1
	MOVE.W	D0,D2
	MOVE.B	D1,D2
	MOVE.W	D2,offset4(A6)

	ADD.W	A0,D0
	ADD.L	A1,D1
	ADDX.W	D3,D1
	endm

	lea	_rotate_me_the_face,a6

; o— se trouve les offsets … modifier dans le code
offset1		set	4
offset2		set	8
offset3		set	18
offset4		set	22
taille_code	equ	34

	REPT	12
		modif
offset1		set	offset1+taille_code	; on
offset2		set	offset2+taille_code	; ‚vite
offset3		set	offset3+taille_code	; un
offset4		set	offset4+taille_code	; lea
	ENDR

; le code qui sera r‚p‚t‚ et modifi‚
rotate	macro
; 0
		moveq	#0,d0								; 4
; +2
		move.b	"Du"(a0),d0							; 12
; +6
		or.b	"ne"(a1),d0							; 12 = 4+8
; +10
		add.w	d0,d0	; aligement word					; 4
; +12
		move.w	(a6,d0.w),d0	; on d‚cale en gagnant 4 cycles			; 12
; +16
		move.b	"Du"(a0),d0							; 12
; +20
		or.b	"ne"(a1),d0							; 12		
; +24
		lsl.l	d2,d0	; #3, alignement sur 8 octets				; 16
; +26
; rempla‡able par lea (a2,d0.l),a3 ??? -> cycles ?? 12
		move.l	a2,a3								; 4
; +28
		add.l	d0,a3								; 8
; +30
		move.l	(a3)+,(a4)+							; 20
; +32
		move.l	(a3),(a4)+							; 20
; +34
	endm

		ifne	showtime
		sub.w	#$222,$ffff8240.w
		endc

draw_zoomer
		lea	DELTA,a2
		move.w	d2,d6
		swap	d6
		move.w	(a2)+,a5	; sign extended...

		move.w	(a2),d1
		ext.l	d1
		ror.l	#8,d1
		move.l	d1,d4		; composante vecteur Y
		moveq	#0,d5

	ifeq	transition_pourrie
		move.w	#disp_lines-1,d6
	else
		move.w	how_many_above,d6
	endc

		moveq	#3,d2
		lea	decal_table,a6	; remplace le lsl.w
		lea	c2p_table,a2
		move.l	log,a4

		moveq	#0,d1
draw_zoomer_boucle

		swap	d6	; on range le compteur

		move.w	d6,d5		; calcule
		move.b	d3,d5 		; le vecteur Y'

		lea	chunky_data_0,a0
		lea	chunky_data_1,a1
		lea	(a0,d5.l),a0
		lea	(a1,d5.l),a1

		add.w	a5,d6
		add.l	d4,d3
		addx.w	d1,d3		; on recalcule le vecteur Y

_rotate_me_the_face
		rotate	; 16 pixels...
		rotate	; 32
		rotate	; 48
		rotate	; 64
		rotate	;
		rotate	;
		rotate	;
		rotate	; 128
		rotate	; 144
		rotate	; 160
		rotate	; 186
		rotate	; 202 px

		lea	4*8+4*8+160*3(a4),a4
;		lea	4*8+4*8+8+160*3(a4),a4

	swap	d6

	dbra	d6,draw_zoomer_boucle

		ifne	showtime
		sub.w	#$222,$ffff8240.w
		endc

blit_lines
		move.l	log,a0		; src
		lea	160(a0),a1	; dest 1
		lea	160(a1),a2	; dest 2

		move.w	#disp_lines,cnt_blit
.blit_line
		movem.l	(a0),d0-d7/a3-a6
		movem.l	d0-d7/a3-a6,(a1)
		movem.l	d0-d7/a3-a6,(a2)
		movem.l	d0-d7/a3-a6,160(a2)
		movem.l	48(a0),d0-d7/a3-a6
		movem.l	d0-d7/a3-a6,48(a1)
		movem.l	d0-d7/a3-a6,48(a2)
		movem.l	d0-d7/a3-a6,48+160(a2)
		lea	640(a0),a0
		lea	160(a0),a1
		lea	160(a1),a2

		subq.w	#1,cnt_blit
		bne.s	.blit_line

		ifne	showtime
		sub.w	#$222,$ffff8240.w
		endc

		rts

cnt_blit	dc.w	0

* a0 = src (??)
* a1 = dest (??)
* a2 = palette de r‚f‚rence pour l'arriv‚e
* equ nb_palettes = nb de pal dans le raster neo (si =1 ou pas def -> pas de raster)
Fade_In
; d5 = couleur de fin
; d6 = pareil, mais masqu‚ pour les comparaisons
; d4 = ??
	move.l	a0,a4
	move.l	a2,a5
.again_all
	move.l	a4,a0
	move.l	a5,a2

.again_palette
	moveq	#15,d0
	moveq	#0,d7	* flag, si=0, alors fade termin‚

.fadred
	move.w	(a0),d1
	move.w	(a2)+,d5	; si comparaison avec une autre palette
	bsr	ste_to_human
	cmp.w	d5,d1
	beq	.dbra2
	moveq	#1,d7	* pas fini pour le fading
	move.w	d1,d2
	move.w	#0,(a0)
* on traite le rouge d'abord (d1)
	move.w	d5,d6
	and.w	#$f00,d6
	and.w	#$f00,d2
	cmp.w	d6,d2
	beq.s	.vert
	bgt.s	.subr
.addr	add.w	#$100,d2
	bra.s	.vert
.subr	sub.w	#$100,d2
* ensuite le composante verte (d2)
.vert
	or.w	d2,(a0)
	move.w	d1,d2
	move.w	d5,d6
	and.w	#$f0,d6
	and.w	#$f0,d2
	cmp.w	d6,d2
	beq.s	.bleu
	bgt.s	.subv
.addv	add.w	#$10,d2
	bra.s	.bleu
.subv	sub.w	#$10,d2
* et pi la composante bleu (d3)
.bleu
	or.w	d2,(a0)
	move.w	d1,d2
	move.w	d5,d6
	and.w	#$f,d6
	and.w	#$f,d2
	cmp.w	d6,d2
	beq.s	.gocolor
	bgt.s	.subb
.addb	addq.w	#1,d2
	bra.s	.gocolor
.subb	subq.w	#1,d2
.gocolor
	or.w	d2,(a0)
	move.w	(a0),d2
	bsr	human_to_ste
	move.w	d2,(a0)+
.dbra	dbra	d0,.fadred
	bsr	Hot_Sync
	tst.w	d7
	bne	.again_all
.outta	rts
.dbra2	addq.l	#2,a0
	bra.s	.dbra

Hot_Sync
	REPT	3
	vsync
	ENDR
	rts

* In : d0=coul d'arrivee
* a0 = src (??)
* a1 = dest (??)
* equ nb_palettes = nb de pal dans le raster neo (si =1 ou pas def -> pas de raster)
Fade_Out
; d5 = couleur de fin
; d6 = pareil, mais masqu‚ pour les comparaisons
; d4 = ??
	move.w	d0,d5
	move.w	d0,d3
	move.l	a0,a4
	move.l	a1,a5
.again_all
	move.l	a4,a0
	move.l	a5,a1
	move.l	a1,a2

.again_palette
	moveq	#15,d0
	moveq	#0,d7	* flag, si=0, alors fade termin‚

.fadred
	move.w	d3,d5
	move.w	(a0),d1
	bsr	ste_to_human

	cmp.w	d5,d1
	beq	.dbra2
	moveq	#1,d7	* pas fini pour le fading
	move.w	d1,d2
	clr.w	(a0)
* on traite le rouge d'abord (d1)
	move.w	d5,d6
	and.w	#$f00,d6
	and.w	#$f00,d2
	cmp.w	d6,d2
	beq.s	.vert
	bgt.s	.subr
.addr	add.w	#$100,d2
	bra.s	.vert
.subr	sub.w	#$100,d2
* ensuite le composante verte (d2)
.vert	or.w	d2,(a0)
	move.w	d1,d2
	move.w	d5,d6
	and.w	#$f0,d6
	and.w	#$f0,d2
	cmp.w	d6,d2
	beq.s	.bleu
	bgt.s	.subv
.addv	add.w	#$10,d2
	bra.s	.bleu
.subv	sub.w	#$10,d2
* et pi la composante bleu (d3)
.bleu
	or.w	d2,(a0)
	move.w	d1,d2
	move.w	d5,d6
	and.w	#$f,d6
	and.w	#$f,d2
	cmp.w	d6,d2
	beq.s	.gocolor
	bgt.s	.subb
.addb	addq.w	#1,d2
	bra.s	.gocolor
.subb	subq.w	#1,d2
.gocolor
	or.w	d2,(a0)
	move.w	(a0),d2
	bsr	human_to_ste
	move.w	d2,(a0)+
	
.dbra	dbra	d0,.fadred
	vsync
	vsync
	vsync
	tst.w	d7
	bne	.again_all
.outta	rts
.dbra2	addq.l	#2,a0
	bra.s	.dbra


; converti une couleur ste en couleur normale
; agit sur les registres d1 et d5
ste_to_human
	movem.l	d0/d2-d4/d6-d7/a0-a6,-(sp)

	lea	ste2col,a3

; on converti d1
	moveq	#0,d3
	moveq	#$f,d4
	move.b	d1,d3
	lsr.w	#8,d1
	and.b	d3,d4
	lsr.b	#4,d3
	move.b	(a3,d1.w),d1
	move.b	(a3,d3.w),d3
	move.b	(a3,d4.w),d4
	lsl.w	#8,d1
	lsl.b	#4,d3
	or.b	d4,d1
	or.b	d3,d1

; on converti d5
	moveq	#0,d3
	moveq	#$f,d4
	move.b	d5,d3
	lsr.w	#8,d5
	and.b	d3,d4
	lsr.b	#4,d3
	move.b	(a3,d5.w),d5
	move.b	(a3,d3.w),d3
	move.b	(a3,d4.w),d4
	lsl.w	#8,d5
	lsl.b	#4,d3
	or.b	d4,d5
	or.b	d3,d5

	movem.l	(sp)+,d0/d2-d4/d6-d7/a0-a6
	rts

; on converti uniquement d2, et d5 aussi (fadeout)
human_to_ste
	movem.l	d0-d1/d3-d5/d7/a0-a6,-(sp)

	lea	ste2col+32,a3

; extrait composante rvb de d2
	and.w	#$0fff,d2	; change le machin !!
	moveq	#0,d3
	moveq	#$f,d4
	move.b	d2,d3
	lsr.w	#8,d2
	and.b	d3,d4
	lsr.b	#4,d3
; convertion d2
	move.b	(a3,d2.w),d2
	lsl.w	#8,d2
	move.b	(a3,d3.w),d2
	lsl.b	#4,d2
	or.b	(a3,d4.w),d2

	and.w	#$0fff,d5
	moveq	#0,d3
	moveq	#$f,d4
	move.b	d5,d3
	lsr.w	#8,d5
	and.b	d3,d4
	lsr.b	#4,d3
; convertion d2
	move.b	(a3,d5.w),d5
	lsl.w	#8,d5
	move.b	(a3,d3.w),d5
	lsl.b	#4,d5
	or.b	(a3,d4.w),d5

	movem.l	(sp)+,d0-d1/d3-d5/d7/a0-a6
	rts


; ====================================================

		Section Data

; combien de lignes sont affich‚es … l'‚cran
	ifne	transition_pourrie
how_many_above	dc.w	1	; on commence par afficher une ligne
	endc

; table de d‚calage: octet bas -> octet haut, gagne 4 cyles sur un lsl.w
val		set	0
decal_table
		REPT	256
		dc.w	val<<8
val		set	val+1
		ENDR

DELTA:		dc.w	0
SYGMA:		dc.w	0
TAILLE		dc.w	0

adr_delta	dc.l	tab_delta
tab_delta	include	"tab_delt.s"
		dc.l	"Dune"

ADR_TAIL:	dc.l	TAB_TAIL
TAB_TAIL:	incbin	"tabz.bin"
;	include	"tab_tail.s"
		dc.l	"Dune"

;color conversions:
; ste2col: converts palette nibble into real intensity
; ste2col+32: backward conversion, with trimming to 0 and $f
ste2col	dc.b	0,2,4,6,8,$a,$c,$e,1,3,5,7,9,$b,$d,$f
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,8,1,9,2,$a,3,$b,4,$c,5,$d,6,$e,7,$f
	dc.b	$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f

; image chunky non pack‚e (1 octets=1 pixel)
chunky_orig_1
		incbin	"chunky1.bin"

t_palette_fx
		dcb.b	32,0

palette_fx
		include	"tile_pal.s"

moongirl_pic	incbin	"atari16.bin"


	Section Bss

flag_quit_effet	ds.w	1

chunky_orig_0	ds.b	256*128
chunky_data_0	ds.b	256*128*3

chunky_copy_1	ds.b	256*128
chunky_data_1	ds.b	256*128*3

c2p_table	ds.l	512*256

log		ds.l	1
phys		ds.l	1

	ifne	use_lib_screen
buf_ecrans	ds.b	32256
	else
buf_ecrans	ds.b	64256
	endc
