****
* 256b Zoomer, Emphii / eXtream, 10.8.2022 - 12.8.2022
*
* For Silly Venture 2022 Summer Edition
* Intro runs small object and zooms it around and changes colors, dual screen
*
* I recommend to shutdown the computer after wathcing enough as this writes
* to system vectors.
*
* Intro runs on plain Falcon 030, RGB/TV, no VGA support this time,
* sorry about that.
*
* Yours,
*	Emphii / eXtream
****

		comment	HEAD=%111

RELEASE	= 1
DEBUG = 0
TEST = 0

		IFNE	RELEASE
		opt	d-
		ENDC

		opt	o+,ow-
		opt	p=68030/68881/68882


		section TEXT

zoom256		clr.l	-(sp)			; super()
		move.w	#$20,-(sp)
		trap	#1
		IFEQ	TEST|RELEASE
		addq.l	#6,sp
		move.l	d0,saveStack
		ENDC

		IFEQ	DEBUG
		move.w	#%000100100,-(sp)	; hicolor 320 rgb
		move.w	#$58,-(sp)
		trap	#14
		IFEQ	TEST|RELEASE
		addq.l	#4,sp
		ENDC
		ENDC

		move.l	#screenSpace,d0		; Alusta ruutu
		clr.b	d0
		add.w	#256,d0
		move.l	d0,a4

****
		lea	vakioita(pc),a6
		move.l	#42*640+64*2,(a6)+	; 0 zoomattavan alueen yl„kulma
		move.l	#91*640+156*2,(a6)+	; 4 blokin alkuosoite
		move.w	#3<<11+3<<6+2,(a6)	; 8 v„rivakio

		moveq	#17,d4			; l„ht”v„ri
		move.w	#%0111101111011111,d5	; rajoitin
		clr.w	rptr			; ruutupointterin pointteri

		lea	ruutuptr(pc),a5
		move.l	a4,(a5)+		; buf1
		move.l	a4,(a5)+		; buf2
		move.l	a4,(a5)			; buf1
		add.l	#2*320*240,-(a5)	; buf2 fix
		move.l	(a5),a4			; aseta ruutu
****

		IFEQ	DEBUG
		move.l	#$0,$ffff9800.w
		ENDC

main		
		IFEQ	DEBUG
		move.l	a4,$45e.w		; aseta ruutu
		ENDC

****
* 0.w zoomattavan alueen yl„kulma
* 2.w blokin alkuosoite
* 4.w v„rivakio

		subq.l	#8,a6		; palauta vakioita alkuun

* Aseta ruudut
		lea	ruutuptr(pc),a5

		move.w	rptr(pc),d0
		addq.w	#4,d0
		and.w	#8-1,d0
		move.w	d0,rptr

		add.w	d0,a5
		move.l	(a5)+,a0	; kohde
		move.l	(a5),a2		; l„hde

		move.l	(a6),d0		; blokin alkuosoite (4->8)
		add.l	#640+6,d0
		cmp.l	#58*640+95*2,d0
		blt.s	.jb0
		move.l	#42*640+64*2,d0
.jb0		move.l	d0,(a6)+
		add.l	d0,a2


* kopioi ja zoomaa ruudusta toiseen
		moveq	#100-1,d7
.zyloop		move.w	#160-1,d6
		lea	640(a0),a1	; toinen rivi
.zxloop		move.w	(a2)+,d0
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		dbra	d6,.zxloop

		lea	640(a0),a0	; rivin ylitys
		lea	320(a2),a2	; seuraava rivi

		dbra	d7,.zyloop


* piirr„ uusi blokki l„hdebufferiin
		move.l	-(a5),a0
		move.l	a0,a4
		add.l	(a6)+,a0
		add.w	rptr(pc),a0

		moveq	#0,d6

		moveq	#4-1,d7
.b1loop		move.w	d4,(a0)+
		dbra	d7,.b1loop
		lea	640-5*2(a0),a0

		moveq	#4-1,d7
.b2loop		move.w	d4,(a0)+
		add.w	(a6),d4		; (8 -> 8)
		move.l	d6,(a0)+
		move.l	d6,(a0)+
		move.w	d4,(a0)+
		add.w	(a6),d4		; (8 -> 8)
		lea	640-6*2(a0),a0
		dbra	d7,.b2loop
		addq.l	#2,a0

		moveq	#4-1,d7
.b3loop		move.w	d4,(a0)+
		dbra	d7,.b3loop

		sub.w	(a6),d4		; (8 -> 8)
		and.w	d5,d4
****

		IFEQ	DEBUG|TEST|RELEASE
		cmp.b	#$39,$fffffc02.w	; Spazce?
		beq.s	Logout
		ENDC

		bra.w	main		

		IFEQ	TEST|RELEASE
Logout		move.l	#-1,$ffff9800.w

		move.w	#%100101010,-(sp)	; 4pln 640 il rgb
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

		move.l	saveStack,-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1
		ENDC


		section	BSS

		EVEN
		IFEQ	TEST|RELEASE
saveStack	ds.l	1			; old stackpointer
		ENDC


*** TŽHŽN VOI JŽŽDŽ VAIN YKSI VARSINAISESSA RELEASESSA!
		IFEQ	TEST
vakioita	ds.l	3
ruutuptr	ds.l	3
rptr		ds.w	1
screenSpace	ds.l	(2*320*240*2+256)/4
		ELSE
vakioita	ds.l	0
ruutuptr	ds.l	0
rptr		ds.w	0
screenSpace	ds.l	0
		ENDC
