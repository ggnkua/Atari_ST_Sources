	output	a:stack.prg
DEBUG	EQU	0		;0=DEBUGGAGE
;
; STrack le soundtracker ultime sur ST
;  permet de jouer de la musique interpr‚t‚e au 50Šme
; le Replay prend moins de 8 rasterlines !!!
;
; caract‚ristiques du replay :
;	- capable de lire des musiques Madmax et Soundtracker
;	   +Whittaker...
;	- capable de jouer de la batterie sur une voix...
;
; ce qu'il faut faire :
;	- mettre une belle fonte
;	- choisir de bonnes couleurs
;
; V1.0	commenc‚ le 24/03/90
;	impl‚mentation des macros et routines d'affichage de base
;
;
rasters=10
mouse0=$100
mouse1=$101
mouse2=$102
mouse3=$103

HEX	MACRO
	cmp	#10,d0
	blo.s	.\@
	addq	#7,d0
.\@	add	#'0',d0
	ENDM
;
; liste des macros d‚finies :
;
;	gem_init
;	gem_exit
;	hidem
;	showm
;	wait_vbl
;	box	Xhg,Yhg,Xbd,Ybd
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
;
; macros utilis‚es dans Strack
;
hline	macro
	move	\1,d0
	move	\2,d1
	move	\3,d2
	bsr	hline2
	endm
vline	macro
	move	\1,d0
	move	\2,d1
	move	\3,d2
	bsr	vline2
	endm
box	macro
	hline	\2,\1,\3
	vline	\1,\2,\4
	vline	\3,\2,\4
	hline	\4,\1,\3
	endm
hidem	macro
	dc.w	$a00a
	endm
showm	macro
	dc.w	$a009
	endm
print	MACRO
	lea	\1,a0
	move	#\2,coordx
	move	#\3,coordy
	bsr	print2
	endm
wait_vbl:macro
	move	#37,-(sp)
	trap	#14
	addq	#2,sp
	endm
set_aes:macro
	lea	control(pc),a0
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\1*65536+\2,(a0)+
	endc
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\3*65536+\4,(a0)+
	endc
	ifeq	\5
	clr	(a0)+
	elseif
	move	#\5,(a0)+
	endc
	move.l	#aes_params,d1
	move	#$c8,d0
	trap	#2
	endm
set_vdi:macro
	lea	contrl(pc),a0
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\1*65536+\2,(a0)+
	endc
	ifeq	\3
	clr	2(a0)
	elseif
	move	#\3,2(a0)
	endc
	move	current_handle(pc),contrl+12
	move.l	#vdi_params,d1
	moveq	#$73,d0
	trap	#2
	endm

form_alert:macro
	move	\1,int_in
	move.l	\2,addr_in
	set_aes	52,1,1,1,0
	move	intout(pc),d0
	endm

form_error:macro
	move	\1,int_in
	set_aes	53,1,1,0,0
	move	intout(pc),d0
	endm

graf_mouse:macro
	move	\1,int_in
	IFNC	'\2',''
	move.l	\2,addr_in
	ENDC
	set_aes	78,1,1,1,0
;	move	intout(pc),d0		;inutile !!!
	endm

fsel_input:macro
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	set_aes	90,0,2,2,0
	movem	intout(pc),d0/d1
	endm

;
; lit l'‚tat de la souris
;
; retourne :
;	d0=‚tat des boutons
;		bit 0=bouton gauche
;		bit 1=bouton droit
;	d1=X
;	d2=Y
;
vq_mouse:macro
	set_vdi	124,0,0
	move	intout(pc),d0
	movem	ptsout(pc),d1/d2
	endm

gem_init:macro
	dc.w	$a000
	move.l	d0,a_buf
	set_aes	10,0,1,0,0			;appl_init
	set_aes	77,0,5,0,0			;graf_handle
	move	intout(pc),current_handle
	lea	intin(pc),a0
	move.l	#$10001,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move	#2,(a0)
	set_vdi	100,0,11			;v_opnvwk
	move	contrl+12(pc),current_handle
	endm

gem_exit:macro
	set_aes	19,0,1,0,0			;appl_exit
	set_vdi	101,0,0				;v_clsvwk
	endm

reso	macro
	move	#\1,-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

	SECTION	DATA
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out
vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout

	SECTION	BSS
a_buf		ds.l	1
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1

current_handle	ds.w	1

contrl	ds.w	12
intin	ds.w	128		min 30
intout	ds.w	128		min 45
ptsin	ds.w	128		min 30
ptsout	ds.w	128		min 12
	section	text

	ifeq	1
	bra	start
	dc.b	"This program is freeware, so if you find some bugs, "
	dc.b	"or if you want to have the latest version, send "
	dc.b	"xxx F to the following address",0
	even
	endc

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

	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,ecran

	pea	superinit(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	move	#4,-(sp)
	trap	#14
	addq	#2,sp
	cmp	#1,d0
	bne	erreur1

	reso	0

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

	add	#$100,d0
;
; recherche des commandes accessibles … la souris...
;
	move	typemenu,d3
	add	d3,d3
	add	d3,d3
	lea	menus(pc),a0
	move.l	(a0,d3.w),a0
	lea	-(8+4)(a0),a0
.search
	lea	8+4(a0),a0
	move	(a0)+,d3
	bmi.s	.notmenu

	cmp	d3,d0
	bne.s	.search

	cmp	(a0),d1
	blt.s	.search
	cmp	2(a0),d2
	blt.s	.search
	cmp	4(a0),d1
	bgt.s	.search
	cmp	6(a0),d2
	bgt.s	.search

	pea	.noclick(pc)
	move.l	8(a0),-(sp)
	movem	(a0),d4-d7
	hidem
	box	d4,d5,d6,d7
	showm
	rts
.notmenu
;
; recherche des commandes accessibles au clavier
;
exit:
	pea	superexit(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	reso	1

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
	box	#0,#rasters,#319,#199

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
	asl	#3,d0
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
	asl	#3,d0
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
	move	#1,typemenu
	hidem
	bsr	cls

	print	snd_edit,1,2

	print	snd_opt0,1,2*8
	move	#1,coordx
	move	#4*8,coordy
	bsr	.carre1

	print	snd_opt1,16,2*8
	move	#16,coordx
	move	#4*8,coordy
	bsr	.carre1

;	box	#6*8,#4*8,#17*8,#24*8	;zone de collision
	showm
	rts

.carre1
	clr	.var
.pr2
	move	.var,d0
	lsr	#4,d0
	add	#'0',d0
	bsr	putc2
	moveq	#$f,d0
	and	.var,d0
	HEX
	bsr	putc2
	moveq	#4-1,d7
.pr3
	addq	#1,coordx
	moveq	#'_',d0
	bsr	putc2
	moveq	#'_',d0
	bsr	putc2
	dbra	d7,.pr3
	sub	#14,coordx
	addq	#8,coordy
	addq	#1,.var
	cmp	#20,.var
	blo.s	.pr2
	rts
.var	dc.w	0


	section	data
menu1:
	dc.w	mouse1,4*8,4*8,15*8,24*8
	dc.l	menu10
	dc.w	-1
	section	text
menu10:
	rts


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
	lsr	#1,d0
	add	d0,a0
;
; d1=0 … 15
; d2=nb plans+nbpixels&15
;
	add	d1,d1
	add	d1,d1
	lea	maskgau(pc),a1
	move.l	maskgau-maskgau(a1,d1.w),d0

	moveq	#$f,d1
	and	d2,d1
	eor	d1,d2
	add	d1,d1
	add	d1,d1
	move.l	maskdro-maskgau(a1,d1.w),d1
;
; d2=nb plans … afficher
; d0=mask gauche
; d1=mask droit
;
	tst	d2
	beq.s	.one

	or.l	d0,(a0)+
	or.l	d0,(a0)+
	lsr	#2,d2
	lea	.brch+4(pc),a2
	sub	d2,a2
	moveq	#-1,d0
	jmp	(a2)
	rept	(160/4)-4
	move.l	d0,(a0)+
	endr
.brch
	or.l	d1,(a0)
	or.l	d1,(a0)
	rts
.one
	and.l	d0,d1
	or.l	d1,(a0)
	or.l	d1,(a0)
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
	mulu	#160,d1
	add	d1,a0

	moveq	#$f,d1
	eor	d1,d0
	and	d0,d1
	eor	d1,d0
	lsr	#1,d0
	add	d0,a0
	moveq	#0,d0
	bset	d1,d0
	move	d0,d1
	swap	d0
	move	d1,d0
.line
	or.l	d0,(a0)+
	or.l	d0,(a0)+
	lea	160-8(a0),a0
	dbra	d2,.line
	rts

	section	data
palette:dc.w	$004,$555,$600,$777
	dcb.w	11,0
	dc.w	$777

typemenu:ds.w	1
menus:
	dc.l	menu1		;0
	dc.l	menu1		;1
	rept	10
	dc.l	menu1
	endr

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
snd_edit:dc.b	"MCODER'S SOUND EDITOR V1.0",0
snd_opt0:dc.b	"VOLUME",0
snd_opt1:dc.b	"FREQUENCE",0
snd_opt2:dc.b	"INSTRUMENT 00 + -",0
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
