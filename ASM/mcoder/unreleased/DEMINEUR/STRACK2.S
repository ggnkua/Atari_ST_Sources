	output	a:stack.prg
DEBUG	EQU	0		;0=DEBUGGAGE
;
; STrack le soundtracker ultime sur ST
;  permet de jouer de la musique interpr‚t‚e au 50Šme
; le Replay prend moins de 8 rasterlines !!!
;
; ce qu'il faut faire :
;	- mettre une belle fonte
;	- choisir de bonnes couleurs
;
; V1.0	commenc‚ le 24/03/90
;	impl‚mentation des macros et routines d'affichage de base
;
;
HEX	MACRO
	cmp	#10,d0
	blo.s	.\@
	addq	#7,d0
.\@	add	#'0',d0
	ENDM
	include	macro.s
;
; liste des macros d‚finies :
;
;	gem_init
;	gem_exit
;	hidem
;	showm
;	wait_vbl
;	hline	Y,Xgauche,Xdroit
;	vline	X,Yhaut,Ybas
;	print	debut message,coordx (0->79),coordy (0->199)
;	form_alert #carr‚ de clic,#adresse message
;		d0=num‚ro du carr‚ cliqu‚
;	form_error #num‚ro erreur TOS
;		d0=num‚ro du carr‚ cliqu‚
;	graf_mouse #num‚ro curseur[,#adresse d‚but]
;		d0= (0=erreur,1=OK)
;		num‚ro
;		 0	flŠche
;		 1	trait vertical
;		 2	abeille
;		 3	main point‚e
;		 4	main … plat
;		 5	r‚ticule mince
;		 6	r‚ticule ‚pais
;		 7	contour de r‚ticule
;	fsel_input #path,#filename
;		d0= (0=erreur)
;		d1= 0=cancel,1=OK
;	vq_mouse
;		d0=‚tat des boutons (bit0=gauche,bit1=droit)
;		d1=X,d2=Y
;
	section	text

start	move.l	4(a7),a3
	lea	stack,a7
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	pea	(a3)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	gem_init
	graf_mouse	#0		;flŠche

	move	#4,-(sp)
	trap	#14
	addq	#2,sp
	cmp	#1,d0
	bne	erreur1

	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,ecran

	pea	superinit(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	bsr	cls
	print	welcome1(pc),10,12*8
	print	welcome2(pc),10,13*8
	print	welcome3(pc),10,14*8

	IFNE	DEBUG
	move.l	#$20000,d0
waitwel	subq.l	#1,d0
	bne.s	waitwel
	ENDC

	bsr	draw_editor_son

.noclick:
	vq_mouse
	tst	d0
	beq.s	.noclick

exit:
	pea	superexit(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	gem_exit
	clr	-(sp)
	trap	#1

erreur1
	form_alert	#1,#badres
	bra	exit

cls:
	hidem
	move.l	ecran,a0
	move	#32000/16-1,d0
	moveq	#0,d1
1$
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,1$

	hline	0,0,639
	vline	0,0,199
	vline	639,0,199
	hline	199,0,639

	showm
	rts

print2:
	PEA	(A0)
	hidem
	MOVE.L	(SP)+,A0
1$
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	.fini
	lea	FONTE-$20*8,a2
	asl	#3,d0
	add	d0,a2

	move	coordy,d0
	mulu	#160,d0
	move.l	ecran,a1
	add.l	d0,a1
	move	coordx,d0
	lsr	#1,d0
	bcc.s	.pair
	addq	#1,a1
.pair
	asl	#2,d0
	add	d0,a1

x	set	0
	rept	8
	move.b	(a2)+,x(a1)
x	set	x+160
	endr

	addq	#1,coordx
	bra.s	1$
.fini
	showm
	rts

putc2:
	lea	FONTE-$20*8,a2
	asl	#3,d0
	add	d0,a2

	move	coordy,d0
	mulu	#160,d0
	move.l	ecran,a1
	add.l	d0,a1
	move	coordx,d0
	lsr	#1,d0
	bcc.s	.pair
	addq	#1,a1
.pair
	asl	#2,d0
	add	d0,a1

x	set	0
	rept	8
	move.b	(a2)+,x(a1)
x	set	x+160
	endr

	addq	#1,coordx
	rts
;
; FONCTIONS SOUS-MENUS
;
	bsr	cls
	print	mesload,8,1*8
	fsel_input	#path,#filename

	bsr	cls

	form_alert	#1,#alert1


draw_editor_son
	hidem
	bsr	cls

	print	snd_edit,1,2

	print	snd_opt0,5,2*8
	print	snd_opt1,60,1*8
	print	snd_opt2,60,4*8
	print	snd_opt3,60,5*8

	move	#4*8,coordy
	bsr	.carre1

	print	snd_opt5,5,12*8
	print	snd_opt2,60,15*8
	print	snd_opt3,60,16*8

	move	#14*8,coordy
	bsr	.carre1
	showm
	rts

.carre1
	move	#5,coordx
	clr	.var
.pr1
	moveq	#'0',d0
	bsr	putc2
	move	.var,d0
	HEX
	bsr	putc2
	addq	#1,coordx
	addq	#1,.var
	cmp	#16,.var
	blo.s	.pr1

	addq	#8,coordy
	clr	.var
.pr2
	move	#2,coordx
	move	.var,d0
	HEX
	bsr	putc2
	moveq	#'0',d0
	bsr	putc2
	moveq	#16-1,d7
.pr3
	addq	#1,coordx
	moveq	#'_',d0
	bsr	putc2
	moveq	#'_',d0
	bsr	putc2
	dbra	d7,.pr3
	addq	#8,coordy
	addq	#1,.var
	cmp	#4,.var
	blo.s	.pr2
	rts
.var	dc.w	0

superinit:
	move.b	$484.w,sav484
	move.b	#%1010,$484.w		;repeat clavier
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savpalette
	pea	palette(pc)
	move	#6,-(sp)
	trap	#14
	addq	#6,sp
	rts
superexit:
	move.b	sav484(pc),$484.w
	wait_vbl
	movem.l	savpalette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
;
; routine de ligne horizontale (640*200)
;
; entr‚e :
;	d0=Y
;	d1=Xgauche
;	d2=Xdroit
;
hline2:
	move.l	ecran,a0
	cmp	d1,d2
	bhs.s	.noswap
	exg	d1,d2
.noswap
	mulu	#160,d0
	add.l	d0,a0
	moveq	#-16,d0
	and	d1,d0
	eor	d0,d1
	sub	d0,d2
	lsr	#2,d0
	add	d0,a0
;
; d1=0 … 15
; d2=nb plans+nbpixels&15
;
	add	d1,d1
	add	d1,d1
	lea	maskgau(pc),a1
	move.l	maskgau-maskgau(a1,d1.w),d4

	moveq	#$f,d5
	and	d2,d5
	eor	d5,d2
	add	d5,d5
	add	d5,d5
	move.l	maskdro-maskgau(a1,d5.w),d5
;
; d2=nb plans … afficher
; d4=mask gauche
; d5=mask droit
;
	tst	d2
	beq.s	.one

	or.l	d4,(a0)+
	moveq	#-1,d6
	lsr	#3,d2
	lea	.brch+2(pc),a2
	sub	d2,a2
	jmp	(a2)
	rept	(160/4)-2
	move.l	d6,(a0)+
	endr
.brch
	or.l	d5,(a0)
	rts
.one
	and.l	d4,d5
	or.l	d5,(a0)
	rts
maskgau:
	dc.l	$FFFFFFFF,$7FFF7FFF,$3FFF3FFF,$1FFF1FFF
	DC.L	$0FFF0FFF,$07FF07FF,$03FF03FF,$01FF01FF
	DC.L	$00FF00FF,$007F007F,$003F003F,$001F001F
	DC.L	$000F000F,$00070007,$00030003,$00010001
maskdro:
	DC.L	$80008000,$C000C000,$E000E000,$F000F000
	DC.L	$F800F800,$FC00FC00,$FE00FE00,$FF00FF00
	DC.L	$FF80FF80,$FFC0FFC0,$FFE0FFE0,$FFF0FFF0
	DC.L	$FFF8FFF8,$FFFCFFFC,$FFFEFFFE,$FFFFFFFF
;
; routine de droite verticale
;
; entr‚e :
;	D0=X
;	D1=Yhaut
;	D2=Ybas
;
vline2:
	sub	d1,d2		;nb lignes
	move.l	ecran,a0
	moveq	#$f,d3
	eor	d3,d0
	and	d0,d3
	eor	d3,d0
	lsr	#2,d0
	add	d0,a0
	mulu	#160,d1
	add	d1,a0
	moveq	#0,d0
	bset	d3,d0
	move	d0,d1
	swap	d0
	move	d1,d0
.line
	or.l	d0,(a0)
	lea	160(a0),a0
	dbra	d2,.line
	rts

	section	data
palette:dc.w	$004,$555,$600,$777
	dcb.w	12,0

	EVEN
FONTE
	INCBIN	FONTE.IMG
path:	dc.b	"a:\*.*",0
	ds.b	40
filename:dc.b	0
	dc.b	'        .   ',0

;
; [0]=pas d'icone
; [1]=!
; [2]=?
; [3]=STOP
;
alert1:	dc.b	"[1][This is a Desk Accessory|"
	dc.b	"written with DevpacST v2][ OK ]",0
badres:	dc.b	"[3][STrack works only|"
	dc.b	"  in medium res][ OK ]",0
;
; message de bienvenue
;
welcome1:dc.b	"     STRACK V1.0     ",0
welcome2:dc.b	"ATARI ST SOUNDTRACKER",0
welcome3:dc.b	"Author : JC Meyrignac",0
;
; messages pour l'‚diteur de sons
;
snd_edit:dc.b	"SOUND EDITOR V1.0",0
snd_opt0:dc.b	"MODULATION VOLUME : 00 + -",0
snd_opt1:dc.b	"EDITER MUSIQUE",0
snd_opt2:dc.b	"CHARGER",0
snd_opt3:dc.b	"SAUVER",0
snd_opt5:dc.b	"MODULATION FREQUENCE : 00 + -",0
mesload:dc.b	"CHARGER MODULATION DE VOLUME",0
	section	bss
sav484:	ds.b	1
	even
savpalette:ds.b	32
coordx	ds.w	1
coordy	ds.w	1
ecran:	ds.l	1
	ds.l	100
stack:
zonefre:
