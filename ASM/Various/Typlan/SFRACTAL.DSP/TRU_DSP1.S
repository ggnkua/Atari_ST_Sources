*  attention : utilise true_dsp.lod / asm ....
*	1) 68030 -> dsp						*
*	2) dsp   -> 68030					*
DEBUG	=	0	; METTRE ¶ 1 POUR DEBUGGER
************************************************
;    VGA		  RVB
xrsl=320		; 768
yrsl=480		; 240
x_img=320/4		; 400
y_img=200/4		; 200

coul2=0
coul4=1
coul16=2
coul256=3
truecolor=4
col40=0
col80=8
tv=0
vga=16
ntsc=0
pal=32
overscan=64
comp=128		! compatibilit‚ ST
entrelace=256	! en vga = le mettre pour avoir 240 de haut seulement

mode_scr=truecolor+col40+vga+pal+entrelace



		**********************************************
		****  nom:     Julzzpwr			  ****
; Amiga		****  projet:  Trackmo			  ****
		****  auteur:  LIONEL from DEFCON4        ****
		****  version: V1.00  			  ****
		****  date:    12-04-92                   ****
		****  asm:     Asm-one V1.01 (the only!)  ****
		**********************************************

		**********************************************
		****  nom:     tru_julia		  ****
; Falcon	****  projet:  prise de t‚te		  ****
		****  auteur:  Typlan and sidewinder      ****
		****  version: V1.02  dsp                 ****
		****  date:    16-05-94                   ****
		****  asm:     Devpac Developper 0.7 (THE)****
		**********************************************



	OPT O+,x+

	CLR.L -(SP)
	MOVE #$20,-(SP)	
	TRAP #1				; supervisor mode
	ADDQ.L #6,SP
	MOVE.L D0,oldsp
*****************************************
 
	jsr	inits


	move.w	#-307,xc
	move.w	#307+50,yc

main:



	move.l	phys1,d0
	move.l	phys2,phys1
	move.l	d0,phys2
	move.l	phys1,physbase

	move.l	physbase,a2
	bsr.s	draw_julia

	jsr	vsync
	move.l	physbase,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	ADDQ.W	#2,XC
	SUBQ	#1,YC

	bra.s	main


*************************************************
*****  calcul l'ensemble de julia et l'affiche  *
*************************************************

draw_julia:

	move.w	#9,d6
	move.w	#508,yn_tmp

	lea	table_y,a3
	lea	palettt,a4
	MOVE.L	#$FFFFA200,A5	NOTRE COPAIN LE DSP

	move.w	#y_img,d1

*	move.l	#$505,d0
*	movec.l	d0,cacr		! youpi cache

loop_y

	move.w	#-636,xn_tmp
	move.w	#x_img-1,d0
loop_x
	move.w	yn_tmp,d2
	move.w	xn_tmp,d3	
	moveq	#30+20,d7
depth
********************************************
*	move.l	#2,memoire	
*debut	move.l	memoire,$ffffa204	;1)  envoie data vers le dsp
*	move.l	$ffffa204,d2		;2)  receive data from dsp
*	add.l	#2,memoire
*	jmp	debut	
********************************************

	move.w	d3,d4

	EXT.L	D2
 	EXT.L	D4

*D	move.L	d2,$ffffa204		;1)  envoie data vers le dsp
*	move.L	d4,$ffffa204		;1)  envoie data vers le dsp
*	move.L	$ffffa204,d4		;2)  receive data from dsp


wait_dsp1
	btst.b	#1,2(a5)
	beq	wait_dsp1

	MOVE.l	D2,4(A5)
	MOVE.l	D4,4(A5)


wait_dsp2
	btst.b	#0,2(a5)
	beq	wait_dsp2

	MOVE.L	4(A5),D4

*	muls	d2,d4
	muls	d3,d3
	muls	d2,d2
	move.l	d3,d5
	add.l	d2,d5
	sub.l	d2,d3
	lsr.l	d6,d3
	add.w	xc,d3	*	-307
	moveq.w	#8,d2
	lsr.l	d2,d4
	add.w	yc,d4	*	307
	move.l	d4,d2

	cmpi.l	#8388606/8,d5
	bhi	fin_bcle
	dbra	d7,depth
*	dbhi	d7,depth
fin_bcle
	move.w	50*2(a4,d7.w*2),(a2)+

	addq	#4,xn_tmp
	dbra	d0,loop_x

	cmp.b	#$39,$fffffc02.w
	beq	stop

 	lea	xrsl*2-x_img*2(a2),a2


	subq	#4,yn_tmp
	dbra	d1,loop_y

	rts

*plot:
*	move.l	physbase,a2
*	adda.l (a3,d1.w*4),a2
*	move.w	(a4,d7.w*2),(a2,d0.w*2)

vsync
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp
	rts

inits
	lea	buffer,a0	! atention: bufer et buffer 2 
	moveq.l	#$1f,d0		! doivent ‚tre … la suite
	move.w	#xrsl*yrsl*2*2/128-1,d1
.1
	rept	16
	move.l	d0,(a0)+
	endr
	dbra	d1,.1

	move.l	#buffer2,d0
	add.l	#256,d0
	and.l	#$fffffff0,d0
	move.l	d0,phys2
	move.l	#buffer,d0
	add.l	#256,d0
	and.l	#$fffffff0,d0
	move.l	d0,phys1
	move.l	d0,physbase

	IFEQ	DEBUG

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,oldrez

	move.w	#mode_scr,-(sp)			RVB:  #$4c
	move.w	#3,-(sp)
	move.l	physbase,-(sp)
	move.l	physbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(a7),a7

	ENDC

init_palet
	lea	palettt,a0
	lea	palettt,a1
	move.w	#512*2,d7
.1	clr.w	d0
	clr.w	d1
	clr.w	d2
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	lsl.w	#8,d0
	lsl.w	#3,d0
	lsl.w	#6,d1
	or.w	d2,d0
	or.w	d1,d0
	move.w	d0,(a1)+
	dbra	d7,.1
	
	move.w	#113,-(sp)	;fnc save_ability
	trap	#14
	addq.l	#2,sp
	move.w	d0,save_ability

	pea	DSP_buffer			;charge le .lod en memoire
	move.w	save_ability,-(sp)
	pea	dsp_prog
	move.w	#108,-(sp)
	trap	#14
	lea.l	12(sp),sp

	rts

*****************************************
stop
*	move.l	#$2505,d0
*	movec.l	d0,cacr		! restore cache

	move.w	oldrez,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
*****************************************
	MOVE.L oldsp,-(SP)
	MOVE #$20,-(SP)	
	TRAP #1				; user mode
	ADDQ.L #6,SP
redir	CLR -(SP)
	TRAP #1
*****************************************
	section	data

table_y
a	set	0
	rept	512
	dc.l	a*768*2
a	set	a+1
	endr


*****************************
****   zone de donnees   ****
*****************************


palettt		incbin	e:\shadebob\pal_shade.dat
dsp_prog	dc.b	'e:\dsp56001.mot\dsp_tool\true_dsp.lod'

	section BSS
memoire		ds.l	1
DSP_buffer	ds.l	5000

physbase:	ds.l	0
phys1	ds.l	1
phys2	ds.l	1

yn_tmp	ds.w	1
xn_tmp	ds.w	1
xc	ds.w	1
yc	ds.w	1

oldrez	ds.l	1
oldsp	ds.l	1
x	ds.w	1
y	ds.w	1

save_ability	ds.w	1
nothing		ds.w	xrsl*4
buffer:		ds.w	xrsl*yrsl
buffer2:	ds.w	xrsl*yrsl
nothingg	ds.w	xrsl*4
