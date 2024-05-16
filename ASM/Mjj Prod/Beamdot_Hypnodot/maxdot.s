

;
;  maxdot.s
;
;
; 

COLFOND	equ $0
COLPIX	equ $777
COLCOLFOND	equ COLFOND*$10000+COLFOND
COLCOLPIX	equ COLPIX*$10000+COLPIX
TYPE2PLAN	equ 1
TYPE4PLAN	equ 2
typedot	equ TYPE2PLAN
enablesound	equ 1
weirdos	equ 0 1   = 0 = tunnel hyperespace

SUBXCTE	equ 200
SUBYCTE equ 120

	ifeq typedot-TYPE2PLAN
nbdot	equ 7008+48-enablesound*540			; 6516 point
taillecheatcode equ (nbdot*54-65536-65536-64000+54*4+6)
	endc
	ifeq typedot-TYPE4PLAN
nbdot	equ 8208-enablesound*30*12
taillecheatcode equ (nbdot*52-65536-65536-64000+54*4+6)
	endc
;nbdot	equ  8244+12 7008+960	; doit etre multiple de 12

pcstart:



	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	lea xxx-640,a0
	moveq #2,d2
.loop0
	moveq #0,d0
	move.w #320-1,d1
.loop
	move.w d0,(a0)+
	addq.w #1,d0
	dbf d1,.loop
	dbf d2,.loop0
	
	;jsr preparePrimetable
	
	
	;jsr initmemall
	jsr calculpositionsX
	ifeq typedot-TYPE2PLAN
	jsr reserve_screen
	jsr createClearcode
	jsr makecreate1
	jsr codegencreate1
	endc
	ifeq typedot-TYPE4PLAN
	jsr reserve_screen
	jsr mkclearcode4plan
	jsr makecreate2
	jsr codegencreate1
	endc
	;jsr createclearcode
	;jsr calculpositionsX
	;jsr codegencreate2
	jsr preparesinusfory
	
	lea lutmul160-400*2,a0
	move.w #160,d0
	moveq #2,d3
.loop1
	moveq #0,d1
	move.w #199,d2
.loop2	move d1,(a0)+
		move d1,(a0)+
		add d0,d1
		dbf d2,.loop2
	dbf d3,.loop1
	
	
	clr.w poslisteY
	move.w #nbdot/12,d7
.1	move.w d7,-(sp)
	jsr calcsinusy
	move.w (sp)+,d7
	dbf d7,.1
;	illegal				; not yet finished !

	;dc.w $a00a
	jsr _disable_mouse
	;clr.w poslisteY
	move.b $ffff8260.w,systeme+36

;	moveq #0,d0
;	;moveq.w #12-1,d7
;	move.l screen1,a0
;	addq.l #4,a0
;	jsr clearcode+4
	
;	move.l screen7,a0
;	addq.l #4,a0
;	moveq.w #12-1,d7
;	jsr clearcode+4


	move.w #0,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp
	
	move.w #$25,-(sp)
	trap #14
	addq.l #2,sp
	
	ifne enablesound
		;moveq #0,d0
		jsr sound
	endc
	
	lea systeme,a0
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,(a0)
	ifeq typedot-TYPE2PLAN
	jsr spreadpicturebatch
	endc
	lea systeme,a0
	
	move.l $466.w,d0
.wait	cmp.l $466,d0
	beq.s .wait
	
	

	move.w #$2700,sr
	move.l $70.w,32(a0)
	move.l #itvbl,$70.w
	move.w #$2300,sr
	
	jmp bigmainloop12vbl

	
towerofpixset:
	or.b d5,0(a0)			; d5 = 128
	or.b d4,0(a0)			; d4 = 64	
	or.b d3,0(a0)			; d3 = 32
	bset.b d1,0(a0)			; d1 = 4 2^4=16
	or.b d2,0(a0)			; d2 = 8
	or.b d1,0(a0)			; d1 = 4
	bset.b d0,0(a0)			; d0 = 1 2^1=2
	or.b d0,0(a0)			; d0 = 1
	
	or.b d5,1(a0)			; d5 = 128
	or.b d4,1(a0)			; d4 = 64	
	or.b d3,1(a0)			; d3 = 32
	bset.b d1,1(a0)			; d1 = 4 2^4=16
	or.b d2,1(a0)			; d2 = 8
	or.b d1,1(a0)			; d1 = 4
	bset.b d0,1(a0)			; d0 = 1 2^1=2
	or.b d0,1(a0)			; d0 = 1

;listvalueReg:		;dc.b 1,4,8,32,64,128
;	moveq #1,d0
;	moveq #4,d1
;	moveq #8,d2
;	moveq #32,d3
;	moveq #64,d4
;	moveq #-128,d5
;	move.l #96000,d7
;	move.l screen2,d6	base 64k
;	rts

;copiefondon12screen
;	move.l screen2,a0
;	pea .suite
;.rt	addq #4,a0
;	
;	lea -32000(a0),a1
;	lea 32000(a0),a2
;	lea 32000(a2),a3
;	lea 32000(a3),a4
;	lea 32000(a4),a5
;	move.w #3999,d0
;	lea picture2plan,a6
;.loop
;	move.l (a6)+,d1
;	move.l d1,(a0)+
;	move.l d1,(a1)+
;	move.l d1,(a2)+
;	move.l d1,(a3)+
;	move.l d1,(a4)+
;	move.l d1,(a5)+
;	addq.l #2,a0
;	addq.l #2,a1
;	addq.l #2,a2
;	addq.l #2,a3
;	addq.l #2,a4
;	addq.l #2,a5
;	dbf d0,.loop
;	rts
;.suite
;	move.l screen3,a0
;	jmp .rt

	ifeq typedot-TYPE2PLAN	
createClearcode:
	move.w #$2140,d0		move.l d0,dep(a0) opcode
	move.w #2000-1,d1
	lea clearcode,a0
	move.l #$41e83e80,(a0)+		; lea 16000(a0),a0
	moveq #0,d2	
.loop
	move.w d0,(a0)+
	move.w d2,(a0)+
	addq.w #8,d2
	dbf d1,.loop
	move.l #$51CFE0BA,(a0)+		; dbf d7,codeclear
	move.w #$4e75,(a0)+
	rts
	endc
	ifeq typedot-TYPE4PLAN
mkclearcode4plan
;	add.l #32000*3,a0
;	moveq #0,d0
;	moveq #0,d1
;	moveq #0,d2
;	moveq.l #$0,d3
;	moveq.l #$0,d4
;	moveq #0,d5
;	moveq #0,d6
;	moveq #0,d7
;	move.l d0,a1
;	move.l d0,a2
;	move.l d0,a3
;	move.l d0,a4
;	move.l d0,a5
;	move.l d0,a6
;	rept 1714 1714
;	movem.l d0-d7/a1-a6,-(a0)
;	endr
;	movem.l d0-d3,-(a0)
	
	lea codeeff4plan,a0
	move.l #$d1fc0001,(a0)+
	move.w #$7700,(a0)+

	move.w #$7000,d0
	move.w #$200,d1
	moveq #7,d2
.loop
	move.w d0,(a0)+
	add d1,d0
	dbf d2,.loop
	move.w #$2240,d0
	moveq #5,d2
.loop2
	move.w d0,(a0)+
	add d1,d0
	dbf d2,.loop2

	move.w #1714-1,d2
	move.l #$48e0ff7e,d0
.loop3	move.l d0,(a0)+
	dbf d2,.loop3
	swap d0
	move.w d0,(a0)+
	move.w #$F000,(a0)+
	move.w #$4e75,(a0)+
	rts
	endc
;reserve_screens:
;	move.l #65536*13+32768,d0
;	jsr getMem
;	; the second screen must be multiple of 64k
;	; the second+6 screen must be multiple of 64k
;	; casse tete, provisoirement je reserve bcp plus de memoire
;	add.l #32000+65536,d0
;	clr.w d0
;	move.l d0,screen2
;	add.l #96000,d0
;	move.l d0,screen3
;

;	reserve 6 premier screen
	ifeq typedot-TYPE2PLAN
reserve_screen
	;move.l #65536+32000*6+32000,d0
	;jsr getMem
	lea bufferscreens,a0
	move.l a0,d0
		move.l d0,d1
	add.l #65536+32000,d0
	clr.w d0
		move.l d0,d2
	sub.l #32000,d2			; zone memoire de d1 a d2
	move.l d0,screen2		; screen2.H dans d6 au sein du code genere pour les 6 premiers ecrans
	move.l d2,screen1
	add.l #32000,d0
	move.l d0,screen3
	add.l #32000,d0
	move.l d0,screen4
	add.l #32000,d0
	move.l d0,screen5
	add.l #32000,d0
	move.l d0,screen6
	move.l d0,d3
		add.l #32000,d3		d3 start adresse zone memoire a la fin
		move.l d3,d4
		sub.l d1,d4			; d4 = taille totale
		move.l #65536+32000*6+32000,d5	; taille allouÃ©
		sub.l d4,d5			; d5 = taille zone memoire de fin
	
	move.l d1,bank1
	sub.l d1,d2
	move.l d2,taillebank1
	move.l d3,bank2
	move.l d5,taillebank2
	
	move.l #bufferscreens+65536+32000*6+32000,d0
	;jsr getMem
	;move.l a0,d0
		move.l d0,d1
	add.l #65536+32000,d0
	clr.w d0
		move.l d0,d2
	sub.l #32000,d2		; zone memoire de d1 a d2
	move.l d2,screen7
		move.l d1,bank3
		sub.l d1,d2
		move.l d2,taillebank3
	move.l d0,screen8		; screen8.h dans d6 au sein du code genere pour les 6 ecrans suivant
	add.l #32000,d0
	move.l d0,screen9
	add.l #32000,d0
	move.l d0,screen10
	add.l #32000,d0
	move.l d0,screen11
	add.l #32000,d0
	move.l d0,screen12
		move.l d0,d3
		add.l #32000,d3
		move.l d3,d4
		sub.l d1,d4		; d4 = taille totale 
	move.l #65536+32000*6+32000,d5
	sub.l d4,d5
	move.l d3,bank4
	move.l d5,taillebank4
	
	rts
	endc
	ifeq typedot-TYPE4PLAN
reserve_screen
	;move.l #65536+32000*6+32000,d0
	;jsr getMem
	lea bufferscreens,a0
	move.l a0,d0
		move.l d0,d1
	add.l #65536+32000,d0
	clr.w d0
		move.l d0,d2
	sub.l #32000,d2			; zone memoire de d1 a d2
	move.l d0,screen2		; screen2.H dans d6 au sein du code genere pour les 6 premiers ecrans
	move.l d2,screen1
	add.l #32000,d0
	move.l d0,screen3
;	add.l #32000,d0
;	move.l d0,screen4
;	add.l #32000,d0
;	move.l d0,screen5
;	add.l #32000,d0
;	move.l d0,screen6
	move.l d0,d3
		add.l #32000,d3		d3 start adresse zone memoire a la fin
		move.l d3,d4
		sub.l d1,d4			; d4 = taille totale
		move.l #65536+32000*3+32000,d5	; taille allouÃ©
		sub.l d4,d5			; d5 = taille zone memoire de fin
	
	move.l d1,bank1
	sub.l d1,d2
	move.l d2,taillebank1
	move.l d3,bank2
	move.l d5,taillebank2
	
	move.l #bufferscreens+65536+32000*3+32000,d0
	;jsr getMem
	move.l #bufferscreens+65536+32000*3+32000,d0
	;move.l a0,d0
		move.l d0,d1
	add.l #65536+32000,d0
	clr.w d0
		move.l d0,d2
	sub.l #32000,d2		; zone memoire de d1 a d2
	move.l d2,screen4
		move.l d1,bank3
		sub.l d1,d2
		move.l d2,taillebank3
	move.l d0,screen5		; screen8.h dans d6 au sein du code genere pour les 6 ecrans suivant
	add.l #32000,d0
	move.l d0,screen6
;	add.l #32000,d0;
;	move.l d0,screen10
;	add.l #32000,d0
;	move.l d0,screen11
;	add.l #32000,d0
;	move.l d0,screen12
		move.l d0,d3
		add.l #32000,d3
		move.l d3,d4
		sub.l d1,d4		; d4 = taille totale 
	move.l #65536+32000*3+32000,d5
	sub.l d4,d5
	move.l d3,bank4
	move.l d5,taillebank4
	
	rts
	endc
shrinka0
	; de a0 a a0 + 50, virer tout les nop
	movem.l d0/d1/d2/a1,-(sp)
	move.w #$4e71,d1
	move.l a0,a1
	move.w #25,d2
.loop:
	move.w (a0)+,d0
	cmp.w d1,d0		; d0 = nop ?
	beq.s .1		
	move d0,(a1)+
.1	dbf d2,.loop
	
	move.l a1,-(sp)
	cmp.l a1,a0
	beq.s .2		; branchement si cas ou aucun nop de trouvé
.3	move.w #$4e71,(a1)+
	cmp.l a1,a0
	bne.s .3
.2	
	move.l (sp)+,a0
	movem.l (sp)+,d0/d1/d2/a1
	rts
	
	ifeq 1
shrinka0bis
	; de a0 a a0 + 50, virer tout les nop
	movem.l d0/d1/d2/a1,-(sp)
	move.w #$4e71,d1
	move.l a0,a1
	move.w #25,d2
.loop:
	move.w (a0)+,d0
	cmp.w d1,d0		; d0 = nop ?
	beq.s .1		
	move d0,(a1)+
.1	dbf d2,.loop
	
	move.l a1,-(sp)
	cmp.l a1,a0
	beq.s .2		; branchement si cas ou aucun nop de trouvé
.3	move.w #$4e71,(a1)+
	cmp.l a1,a0
	bne.s .3
.2	
	move.l (sp)+,a0
	movem.l (sp)+,d0/d1/d2/a1
	rts
	endc
fillnopa0
	move.w #$4e71,d2
	move.w #25*12-1,d0			; nombre de nop a determiner 
.1	move.w d2,(a0)+
	dbf d0,.1
	lea -25*12*2(a0),a0
	rts
	ifeq typedot-TYPE4PLAN
makecreate2
	lea data2,a0
	bra automodifaralonge
	endc
makecreate1
	ifeq typedot-TYPE2PLAN
	lea data1,a0
	endc
automodifaralonge:
	move.l (a0)+,d0
	lea PLEASE1,a1
	lea PLEASE2,a2
	lea PLEASE3,a3
	move.l d0,(a1)+
	move.l d0,(a2)+
	move.l d0,(a3)+
	move.w (a0)+,d0
	move.w d0,(a1)+
	move.w d0,(a2)+
	move.w d0,(a3)+
	lea PLEASE4,a1
	lea PLEASE5,a2
	lea PLEASE6,a3
	move.l (a0)+,d0
	move.l d0,(a1)+
	move.l d0,(a2)+
	move.l d0,(a3)+
	move.w (a0)+,d0
	move.w d0,(a1)+
	move.w d0,(a2)+
	move.w d0,(a3)+
	move.l (a0)+,d0
	move.l d0,PLEASE7
	move.l (a0)+,d0
	move.l d0,PLEASE8
	move.l (a0)+,PLEASE9
	rts
	ifeq typedot-TYPE2PLAN
data1
	lea listeoffset2plan,a5		PLEASE1 a 3
	move.w #$d1c7,24(a0)    PLEASE4 a 6
	divu #54,d0				PLEASE7
	lea 50(a0),a0
	dc.l paramvbl
	endc
	ifeq typedot-TYPE4PLAN
data2
	lea listeoffset4plan,a5
	nop
	nop
	nop
	divu #52,d0
	lea 50-2(a0),a0
	dc.l paramvbl2
	endc
		
codegencreate1
	
	ifgt taillecheatcode
	move.l #bigcheatcode,bank5				; normalement bank5
	move.l #(nbdot*54-65536-65536-64000)+54*4+6,bank5+4	; et bank5+4
	endc
	sf.b rtsfinish
	lea towerofpixset,a1
	lea listeX,a2			; listeX polycrome wohohohoa listeX pour les hommes (balavoine)
	
	;move.w #7008-24-12,cpt
	move.w #nbdot-12-12,cpt	
	
	; gestion 12 premier points
	;
* * * * x1

* * * x1 x2

* * x1 x2 x3

* x1 x2 x3 x4  dans le cas ou y'a 5 truc ici y'a 12
	moveq #12-1,d3
	lea cheatcodedebut,a0
	bsr fillnopa0
	moveq #$F,d5	 
.bcldebut0:
	move.l #$3c192046,(a0)+
	move.l a2,a4
	move.w #11,d2
	sub.w d3,d2		; au debut = 0 = un tour de boucle = x1 seulement
PLEASE1 equ *
	nop
	nop
	nop	lea .listeoffset,a5     ***** listeoffset4plan
	add.w d3,a5
	add.w d3,a5     ; au debut listeoffset+22 =dernier ecran

	pea .suite2
	
.bcldebut1:
	move.w (a2)+,d0			; x1
	move.w d0,d1
	and.w d5,d1
	sub d1,d0
	add d1,d1
	add d1,d1
	move.l (a1,d1.w),d1		; instruction bset correspondant a x mod 16
	;lsr #4,d0
	;lsl #3,d0
	;and.b #$F0,d0
	lsr #1,d0			; int (x/16)*8
	add.w d0,d1
	add.w (a5)+,d1
	move.w 24-2(a5),d4
	move.l d1,(a0,d4)		; cg
	dbf d2,.bcldebut1
	rts
	
.suite2
PLEASE4	equ *
	move.w #$d1c7,24(a0)		; D1C7 = add.l d7,a0  ; d7 = 96000 ***** nop nop nop pour create2
	bsr shrinka0
	move.l a4,a2
	dbf d3,.bcldebut0
	move.w #$4e75,(a0)+
	addq #2,a2
.autoto1:
	move.l bank1,a0
	move.l taillebank1,d0
	subq.l #6,d0				; pour metre le jmp adresse a la fin
PLEASE7 equ *
	divu #54,d0	**** divu52 pour create2
	ext.l d0
	
	sub.w d0,cpt
	bpl.s .itsok
	; sinon arg kefaire ca doit finir par un rts
	add.w d0,cpt
	move.w cpt,d0
	move.w #0,cpt
	st.b rtsfinish
.itsok
	moveq #0,d3
	move.w d0,d3
	subq #1,d3

.bcl0
	move.l #$3c192046,(a0)+		<-	2 opcode :  
								; move.w (a1)+,d6
								; move.l d6,a0
	lea 2(a2),a4

	moveq #11,d2
PLEASE2	equ *
	NOP 
	NOP 
	NOP
	;lea .listeoffset,a5		; ***listeoffset4plan pour create2
	bsr .bcldebut1

PLEASE5 equ *
	move.w #$d1c7,24(a0)	*** nop nop nop pour create2	; D1C7 = add.l d7,a0  ; d7 = 96000
PLEASE8 equ *
	lea 50(a0),a0			*** 50-2 pour create2
	
	move.l a4,a2
	dbf d3,.bcl0
	tst.b rtsfinish
	beq.w .1

************************************************** 12 derniers points
;PLEASE	equ *
	move.w #$4ef9,(a0)+
	move.l #cheatcodefin,d3
	move.l d3,(a0)
	move.l d3,a0

	moveq #11,d3
	;lea cheatcodefin,a0
	bsr fillnopa0


.bcldebut2:
	move.l #$3c192046,(a0)+
	lea 2(a2),a4
	move.w d3,d2
	;sub.w d3,d2		; au debut = 11 dot a la fin 1 seulement
PLEASE3 equ *
	nop	lea .listeoffset,a5    **** listeoffset4plan
	nop
	nop
	bsr .bcldebut1
PLEASE6	equ *
	move.w #$d1c7,24(a0)	**** nop nop nop	; D1C7 = add.l d7,a0  ; d7 = 96000
	bsr shrinka0			*** shrinka0bis
	move.l a4,a2
	dbf d3,.bcldebut2

*************************************************
	move.w #$4e75,(a0)+
	rts
.1
	move.w #$4ef9,(a0)+	jmp opcode
.autoto2
	move.l bank2,(a0)
	move.l (a0),a0
	addq.l #8,.autoto2+2
	addq.l #8,.autoto1+2
	addq.l #8,.autoto1+8
	bra.w .autoto1
	
listeoffset2plan	dc.w -32000,0,32000,-32000,0,32000,-32000+2,2,32002,-32000+2,2,32002
		dc.w 0,4,8,26,30,34,12,16,20,38,42,46
					
listeoffset4plan
	dc.w -32000,0,32000,-32000+2,2,32002,-32000+4,4,32000+4,-32000+6,6,32000+6
	dc.w 0,4,8,12,16,20,24,28,32,36,40,44
;					x1 0		-32000
;					x2 4		0
;					x3 8		32000	
;					x7 12		-32000+2
;					x8 16		2
;					x9 20		32000+2
;					+ 2 (add.l d7,a0)
;					x4 26		-32000
;					x5 30		0
;					x6 34		32000
;					x10 38		-32000+2
;					x11 42		2
;					x12 46		32000+2
; 3 nop + 12*4 nop + 2 nop = 53 nop pour 12 point = 4,41666 nop
;

listeoffset1plan	dc.w -32000,0,32000,-32000,0,32000
					dc.w 0,4,8,14,18,22
;		x1 0 -32000
;		x2 4 0
;       x3 8 32000
;	add d7,a0
;;		x4 14 -32000
;		x5 18 0
;		x6 22 32000
; total (6*4+5)/6 nop= 4+5/6 = 4,8333333 nop avec effacement 12000 nop:=5793 point soit environ 5000 point c la zone
; avec le blitter 7000 point

*codegencreate2
*	
*	ifgt taillecheatcode
*	move.l #bigcheatcode,bank5				; normalement bank5
*	move.l #(nbdot*54-65536-65536-64000)+54*4+6,bank5+4	; et bank5+4
*	endc
*	sf.b rtsfinish
*	lea towerofpixset,a1
*	lea listeX,a2			; listeX polycrome wohohohoa listeX pour les hommes (balavoine)
*	
*	;move.w #7008-24-12,cpt
*	move.w #nbdot-12-12-12,cpt	
*	
*	; gestion 12 premier points
*	;
** * * * x1
*
** * * x1 x2
*
** * x1 x2 x3
*
** x1 x2 x3 x4  dans le cas ou y'a 5 truc ici y'a 12
*	moveq #12-1,d3
*	lea cheatcodedebut,a0
*	bsr fillnopa0
*	moveq #$F,d5	 
*.bcldebut0:
*	move.l #$3c192046,(a0)+
*	move.l a2,a4
*	move.w #11,d2
*	sub.w d3,d2		; au debut = 0 = un tour de boucle = x1 seulement
*	lea listeoffset4plan,a5
*	add.w d3,a5
*	add.w d3,a5     ; au debut listeoffset+22 =dernier ecran
*
*	pea .suite2
*	
*.bcldebut1:
*	move.w (a2)+,d0			; x1
*	move.w d0,d1
*	and.w d5,d1
*	sub d1,d0
*	add d1,d1
*	add d1,d1
*	move.l (a1,d1.w),d1		; instruction bset correspondant a x mod 16
*	;lsr #4,d0
*	;lsl #3,d0
*	;and.b #$F0,d0
*	lsr #1,d0			; int (x/16)*8
*	add.w d0,d1
*	add.w (a5)+,d1
*	move.w 24-2(a5),d4
*	move.l d1,(a0,d4)		; cg
*	dbf d2,.bcldebut1
*	rts
*	
*.suite2
*	;move.w #$d1c7,24(a0)		; D1C7 = add.l d7,a0  ; d7 = 96000
*	bsr shrinka0bis
*	move.l a4,a2
*	dbf d3,.bcldebut0
*	move.w #$4e75,(a0)+
*	addq #2,a2
*.autoto1:
*	move.l bank1,a0
*	move.l taillebank1,d0
*	subq.l #6,d0				; pour metre le jmp adresse a la fin
*	divu #52,d0
*	ext.l d0
*	
*	sub.w d0,cpt
*	bpl.s .itsok
*	; sinon arg kefaire ca doit finir par un rts
*	add.w d0,cpt
*	move.w cpt,d0
*	move.w #0,cpt
*	st.b rtsfinish
*.itsok
*	moveq #0,d3
*	move.w d0,d3
*	subq #1,d3
*
*.bcl0
*	move.l #$3c192046,(a0)+		<-	2 opcode :  
*								; move.w (a1)+,d6
*								; move.l d6,a0
*	lea 2(a2),a4
*
*	moveq #11,d2
*	lea listeoffset4plan,a5
*	bsr .bcldebut1
*	
*	;move.w #$d1c7,24(a0)		; D1C7 = add.l d7,a0  ; d7 = 96000
*	lea 50-2(a0),a0
*	
*	move.l a4,a2
*	dbf d3,.bcl0
*	tst.b rtsfinish
*	beq.w .1
*
*************************************************** 12 derniers points
*;PLEASE2	equ *
*	move.w #$4ef9,(a0)+
*	move.l #cheatcodefin,d3
*	move.l d3,(a0)
*	move.l d3,a0
*
*	moveq #11-1,d3
*	;lea cheatcodefin,a0
*	bsr fillnopa0
*
*
*.bcldebut2:
*	move.l #$3c192046,(a0)+
*	lea 2(a2),a4
*	move.w d3,d2
*	;sub.w d3,d2		; au debut = 11 dot a la fin 1 seulement
*	lea listeoffset4plan,a5
*
*	bsr .bcldebut1
*	;move.w #$d1c7,24(a0)		; D1C7 = add.l d7,a0  ; d7 = 96000
*	bsr shrinka0bis
*	move.l a4,a2
*	dbf d3,.bcldebut2
*
**************************************************
*	move.w #$4e75,(a0)+
*	rts
*.1
*	move.w #$4ef9,(a0)+	jmp opcode
*.autoto2
*	move.l bank2,(a0)
*	move.l (a0),a0
*	addq.l #8,.autoto2+2
*	addq.l #8,.autoto1+2
*	addq.l #8,.autoto1+8
*	bra.w .autoto1
*
*
	
*datasequence:
*		lea datasequencetodolist,a6
*		move.l (a6),a0	; ecran effacement
		
parametreX	;dc.w 0,220,40,180,550,60,450,200		; les 8 valeur de sinus au depart
		dc.w 30,0,400,10,1200,1060,0,700
			dc.w 1*2,2*2,1*2,(512-3)*2			; les 4 valeur ajouter au depart des sinus de 512 elements
			dc.w (2)*7,1540*2-16*2,1540*2-(5*2),3*2	; les 4 vlaeur ajouter au depart des sinus de 1540 elements


scaletable:
		moveq #0,d2
		move.w (a0)+,d2		; 0..65536 = (0.5+0.5*sinus(angle)) = [0..1[
		mulu.w d1,d2
		swap d2
		move.w d2,(a1)+
		dbf d0,scaletable
		rts
temp	dc.w 0,0,0,0,0,0,0,0

calculpositionsX
	
		lea sinus512,a0
		lea sinus1,a1
		move.w #512-1,d0
		move.l #16*30,d1
		bsr scaletable
		lea sinus1540,a0
		lea sinus2,a1
		move.w #1540-1,d0
		move.l #16*50,d1
		bsr scaletable
		lea sinus1,a0			512 valeurs
		lea sinus2,a1			1540 valeurs
		lea parametreX,a2
		lea temp,a3
		lea listeX,a4			; le resultat
		;lea tabtemp+3000*2,a6
		moveq #7,d7		; 8 sinus
.2b		move.w (a2)+,(a3)+
		dbf d7,.2b
		lea -16(a3),a3  ; a3 = temp
		move.w #nbdot-1,d7
do7000		
		moveq #3,d0
.3		move (a2)+,d1	; pas
		move.w (a3),d2	; position
		add d1,d2
		cmp.w #512*2,d2
		blt.s .glok
		sub.w #512*2,d2
.glok		move.w d2,(a3)+
		dbf d0,.3
		
		moveq #3,d0
.4		move (a2)+,d1	; pas
		move.w (a3),d2	; position
		add d1,d2
		cmp.w #1540*2,d2
		blt.s .glok2
		sub.w #1540*2,d2
.glok2		move.w d2,(a3)+
		dbf d0,.4
		lea -16(a3),a3
		lea -16(a2),a2
	
		moveq #0,d4


		moveq #3,d0
		moveq #0,d2

.5		moveq #0,d1
	
		move.w (a3)+,d1
		moveq #0,d4
		move (a0,d1.w),d4		; sinus1 d1
		add.l d4,d2	
		dbf d0,.5

		moveq #3,d0

.6		moveq #0,d1
		move.w (a3)+,d1
		moveq #0,d4
		move (a1,d1.w),d4
		add.l d4,d2
		dbf d0,.6
		;add (a6)+,d2


		lsr.l #3,d2
		sub.w #SUBXCTE,d2
		asl #1,d2
		lea xxx,a5
		move.w (a5,d2.w),d2
break
		move.w d2,(a4)+				; calcul du x final
		lea -16(a3),a3
		dbf d7,do7000
		rts
	
preparesinusfory
		lea sinus512,a0
		lea sinus1,a1
		move.w #512-1,d0
		move.l #20*16,d1
		bsr scaletable	;andlsl
		
		lea sinus1540,a0
		lea sinus2,a1
		move.w #1540-1,d0
		move.l #30*16,d1
		bsr scaletable	;andlsl
	
		lea parametreY,a6
		lea ramresultat,a2		
		lea reftable1,a1
		
		moveq #3,d7
.bcl1	lea sinus1,a0
		move.w #512,d2
		move (a6)+,d0		; pas interne
		move.w #12,d1		; nombre de copie de valeur
		jsr createSpecialSin1540
		lea 512*4(a1),a1
		dbf d7,.bcl1

		moveq #3,d7
.bcl2	lea sinus2,a0
		move.w #1540,d2
		move (a6)+,d0
		move.w #12,d1
		jsr createSpecialSin1540
		lea 1540*4(a1),a1
		dbf d7,.bcl2
		rts
	
calcsinusy:
		
		sub.w #12*2,poslisteY
		move.w poslisteY,d0
		tst d0
		bpl.s .1
		move.w #nbdot*2-24,d0
		move.w d0,poslisteY
.1

;		move.w postabtemp,d7
;		sub.w #2*12,d7
;		tst.w d7	
;		bge.s .zig	
;		add.w #8209*2,d7
;.zig	move.w d7,postabtemp


;		move.w postabtemp,d7
;		add.w #2*120,d7
;		cmp.w #8209*2,d7	
;		blt.s .zig	
;		sub.w #8209*2,d7
;.zig		move.w d7,postabtemp
		
		


		lea parametreY+8*2,a6
		lea listeY,a0
		add.w poslisteY,a0
		lea reftable1,a1
		;moveq #2,d7
.piconbierre
		moveq #0,d0
		move.w (a6)+,d0
		move.l (a1,d0.l),a2
		move.l (a2)+,d6
		move.l (a2)+,d5
		move.l (a2)+,d4
		move.l (a2)+,d3
		move.l (a2)+,d2
		move.l (a2)+,d1
		lea 512*4(a1),a1
.bcl1
		move.w (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1

		lea 512*4(a1),a1
		move.w (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1

		lea 512*4(a1),a1
		move.w (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1

		lea 512*4(a1),a1
		;dbf d7,.bcl1
		;moveq #3,d7
.bcl2	
		move (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1
		lea 1540*4(a1),a1
		move (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1
		lea 1540*4(a1),a1
		move (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1

		lea 1540*4(a1),a1
		move (a6)+,d0
		move.l (a1,d0.l),a2
		add.l (a2)+,d6
		add.l (a2)+,d5
		add.l (a2)+,d4
		add.l (a2)+,d3
		add.l (a2)+,d2
		add.l (a2)+,d1
		;lea 1540*4(a1),a1
		;dbf d7,.bcl2

		;lea tabtemp,a2
		;add.w postabtemp,a2
		;add.l (a2)+,d6
		;add.l (a2)+,d5
		;add.l (a2)+,d4
		;add.l (a2)+,d3
		;add.l (a2)+,d2
		;add.l (a2)+,d1
		
		
		
		move.l #%11111111111111100011111111111110,d7
		lea lutmul160-SUBYCTE*2,a1
		lsr.l #1,d1
		lsr.l #1,d2
		lsr.l #1,d3
		lsr.l #1,d4
		lsr.l #1,d5
		lsr.l #1,d6
		and.l d7,d1
		and.l d7,d2
		and.l d7,d3
		and.l d7,d4
		and.l d7,d5
		and.l d7,d6
		move.w (a1,d1.w),d1
		move.w (a1,d2.w),d2
		move.w (a1,d3.w),d3
		move.w (a1,d4.w),d4
		move.w (a1,d5.w),d5
		move.w (a1,d6.w),d6
		swap d1
		swap d2
		swap d3
		swap d4
		swap d5
		swap d6
		;lsr #4,d1
		;lsr #4,d2
		;lsr #4,d3
		;lsr #4,d4
		;lsr #4,d5
		;lsr #4,d6
		move.w (a1,d1.w),d1
		move.w (a1,d2.w),d2
		move.w (a1,d3.w),d3
		move.w (a1,d4.w),d4
		move.w (a1,d5.w),d5
		move.w (a1,d6.w),d6
		movem.l d1-d6,(a0)
		movem.l d1-d6,nbdot*2(a0)		; doit etre un multiple de 12*2  7008 point*2 
		
		lea -16(a6),a5		; a5 = positions a metre a jour
						
		;moveq #3,d7
		move.w #511*4,d7						; a6 = ajout a faire a position
.loop	
		movem.w (a6)+,d0-d6
		add (a5)+,d0
		and.w d7,d0
		add (a5)+,d1
		and.w d7,d1
		add (a5)+,d2
		and.w d7,d2
		add (a5)+,d3
		and.w d7,d3
		move.w #1540*4,d7
.loop2	
		add (a5)+,d4
		cmp.w d7,d4
		blt.s .toto
		sub.w d7,d4
.toto
		add (a5)+,d5
		cmp.w d7,d5
		blt.s .toto2
		sub.w d7,d5
.toto2
		add (a5)+,d6
		cmp.w d7,d6
		blt.s .toto3
		sub.w d7,d6
.toto3	movem.w d0-d6,-2*7(a5)
	
		move.w (a6)+,d0
		add (a5),d0
		cmp.w d7,d0
		blt.s .toto4
		sub.w d7,d0
.toto4		move.w d0,(a5)+
		rts
		
;postabtemp	dc.w 0
		
createSpecialSin1540
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupÃ© sur buffer resultat

	movem.l d0-d7/a0/a1/a3-a6,-(sp)
	move.w d2,d3
	lea bufferFlag1540,a3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag

	move.w d2,.auto1+2
	move.w d2,.auto2+2
	move.w d2,.auto3+2
	move.w d2,.auto4+2
	move.w d2,.auto5+2
	move.w d2,.auto6+2

	move.w d2,d3	; 512 ou 1024
	subq #1,d3		; 511  ou 1023 pour le and de l'angle

	lea bufferFlag1540,a3
	subq #1,d2		; 511 ou 1023 iteration
	moveq #0,d4		; angle
.loop
	tst.b (a3,d4)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)
	add d5,d5
	move.l a2,(a1,d5)			; a2 referencer en reftable+angle*4
	addq.l #2,a2
	st (a3,d4)		positione flag(angle) a 1
	add d0,d4		; pas interne
	;and d2,d4		; mod 512 ou 1022
.auto1
	cmp.w #1540,d4
	blt.s .1
.auto2
	sub.w #1540,d4
.1

	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d4,d5		; angle courant copier sur d5
	move.w d1,d7
	subq #1,d7
.cpy
	move.w d5,d6
	add d6,d6
	move.w (a0,d6),(a2)+
	add d0,d5
.auto3
	cmp.w #1540,d5
	blt.s .2
.auto4
	sub.w #1540,d5
.2
	;and d2,d5
	dbf d7,.cpy
	
	;sub d0,d4
	addq #1,d4
.auto5
	cmp.w #1540,d4
	blt.s .3
.auto6
	sub.w #1540,d4
.3
	;and d2,d4
	tst.b (a3,d4)
	;bne.s .fin
	beq.s .flagA0
.fin
	movem.l (sp)+,d0-d7/a0/a1/a3-a6
	rts
spreadpicturebatch
	lea picturebatch,a1
	;movem.l (a1),d0-d7
	;movem.l d0-d7,$ffff8240.w

	;lea picturebatch-32,a1


	move.l screen1,a2
	move.l screen7,a0
	addq.l #4,a0
	addq.l #4,a2
	moveq #5,d7
.loop0
	move.w d7,-(sp)
	;lea 66(a1),a1
	move #399,d7
	;move.l a0,-(sp)
	;move.l a2,-(sp)
.loop
	movem.l (a1)+,d0-d6/a3-a5
	move.l d0,(a2)
	move.l d0,(a0)
	move.l d1,8(a2)
	move.l d1,8(a0)
	move.l d2,16(a2)
	move.l d2,16(a0)
	move.l d3,24(a2)
	move.l d3,24(a0)
	move.l d4,32(a2)
	move.l d4,32(a0)
	move.l d5,40(a2)
	move.l d5,40(a0)
	move.l d6,48(a2)
	move.l d6,48(a0)
	move.l a3,56(a2)
	move.l a3,56(a0)
	move.l a4,64(a2)
	move.l a4,64(a0)
	move.l a5,72(a2)
	move.l a5,72(a0)
	lea 80(a0),a0
	lea 80(a2),a2

	dbf d7,.loop
	;move.l (sp)+,a2
	;move.l (sp)+,a0
	;lea 32000(a0),a0
	;lea 32000(a2),a2
	move.w (sp)+,d7
	dbf d7,.loop0
; now s'occuper de la palette

	rts
	
bigmainloop12vbl

		ifeq typedot-TYPE4PLAN
		move.l screen1,a0
		jsr codeeff4plan
		endc
		ifeq typedot-TYPE2PLAN
		moveq #0,d0
		move.l screen1,a0
		moveq.w #11,d7
		jsr clearcode+4
		endc
		
		lea cheatcodedebut,a0
		lea listeY,a1
		add.w poslisteY,a1
		moveq #1,d0
		moveq #4,d1
		moveq #8,d2
		moveq #32,d3
		moveq #64,d4
		move.w #128,d5
		move.l screen2,d6	base 64k
		move.l #96000,d7
		jsr (a0)		; affichage de 12 point*7008 sur 6 ecran et 2 plan
		move.l bank1,a0
		jsr (a0)
		
		jsr calcsinusy		

		move.w every12vbl,d0
.1		move.w every12vbl,d1
		cmp.w d0,d1
		beq.s .1
		
		;move.w d1,-(sp)


		ifeq typedot-TYPE4PLAN
		move.l screen4,a0
		jsr codeeff4plan
		endc
		ifeq typedot-TYPE2PLAN
		moveq #0,d0
		move.l screen7,a0
		moveq #11,d7
		jsr clearcode+4
		endc
		;move.l screen7,a0
		;jsr clearcode4plan
		
		lea cheatcodedebut,a0
		lea listeY,a1
		add.w poslisteY,a1
		moveq #1,d0
		moveq #4,d1
		moveq #8,d2
		moveq #32,d3
		moveq #64,d4
		move.w #128,d5
		ifeq typedot-TYPE2PLAN
		move.l screen8,d6
		endc
		ifeq typedot-TYPE4PLAN
		move.l screen5,d6
		endc
		move.l #96000,d7
		jsr (a0)
		move.l bank1,a0
		jsr (a0)
		
		jsr calcsinusy

		move.w every12vbl,d0
.2		move.w every12vbl,d1
		cmp.w d0,d1
 		beq.s .2
		
		cmp.b #$b9,$fffffc02.w
		beq.s .fin
		jmp bigmainloop12vbl
.fin
		
		lea systeme,a0
		movem.l (a0)+,d0-d7
		movem.l d0-d7,$ffff8240.w
		move.w #$2700,sr
		move.l (a0),d0
		move.l d0,$70.w
		move.w #$2300,sr

	moveq #0,d1
	move.b systeme+36,d1
	move.w d1,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp

	ifne enablesound
		jsr sound+4
		
		lea    $ffff8800.w,a0
       move.l    #$08000000,(a0)		; 08 amplitude chanel A,00 dummy,00 volume,00 dummy
       move.l    #$09000000,(a0)		; 09 amplitude chanel B
       move.l    #$0a000000,(a0)		; 10 amplitude chanel C
		; merci evil
		
	endc

	;dc.w $a009
	jsr _enable_mouse
	;and.b #8,$fffffc02.w
	
	
		clr.w -(sp)
		trap #1
		

compteurVBLMOD12	dc.w 0

itvbl:	movem.l d0-d7/a0-a6,-(sp)
		addq.l #1,$466.w

		ifne enablesound
			jsr sound+8
		endc

		move.w compteurVBLMOD12,d0
		lsl #3,d0		; *8
		ext.l d0
PLEASE9	equ *+2
		lea $12345678,a2	; paramvbl2
		add d0,a2
		
		move.l (a2)+,a0
		move.l (a0),d2
		lsr.w #8,d2
		move.l d2,$ffff8200.w
		
		move.l (a2)+,a6 ; adresse code changement de palette
		jmp (a6)
suitevbl:
		move.w compteurVBLMOD12,d0			; en fait c'est mod 24
		tst d0
		bne.s .1
		addq.w #1,every12vbl
.1
		cmp.w #12,d0
		bne.s .2
		addq.w #1,every12vbl
.2
		addq.w #1,d0
		cmp.w #24,d0
		blt.s .3
		clr.w d0
.3		move.w d0,compteurVBLMOD12
		
		movem.l (sp)+,d0-d7/a0-a6
		rte
		
;paramvbl	ds.l 12*2*2
	
	ifeq typedot-TYPE2PLAN
codepalchangeplan1
	movem.w palfond,d0-d3/d4-d7
; d0 = fond 00
; d1 = fond 01
; d2= fond 10
; d3 = fond 11
; d4 = couleur point
; plan 0 selectionnÃ©, le plan 1 = couleur du fond
	;jmp suitevbl
	lea $ffff8240.w,a0
	move.w d0,(a0)+			00 00
	move.w d4,(a0)+ 	        10 00 
	move.w d0,(a0)+			01 00
	move.w d4,(a0)+			11 00
	move.w d1,(a0)+        		00 10  
	move.w d5,(a0)+			10 10
	move.w d1,(a0)+			01 10
	move.w d5,(a0)+			11 10
	move.w d2,(a0)+			00 01
	move.w d6,(a0)+			10 01
	move.w d2,(a0)+			01 01
	move.w d6,(a0)+			11 01
	move.w d3,(a0)+			00 11
	move.w d7,(a0)+			10 11
	move.w d3,(a0)+			01 11
	move.w d7,(a0)+			11 11
	jmp suitevbl
	
codepalchangeplan2
	;jmp suitevbl
	movem.w palfond,d0-d7
; d0 = fond 00
; d1 = fond 01
; d2= fond 10
; d3 = fond 11
; d4 = couleur point fond 00 d5 fond 01 etc
; plan 1 selectionnÃ©, le plan 1 = couleur du fond
	lea $ffff8240.w,a0
	move.w d0,(a0)+			00 00
	move.w d0,(a0)+			10 00
	move.w d4,(a0)+			01 00	
	move.w d4,(a0)+			11 00
	move.w d1,(a0)+			00 10	
	move.w d1,(a0)+         10 10
	move.w D5,(a0)+			01 10
	move.w d5,(a0)+		    11 10
	move.w d2,(a0)+			00 01
	move.w d2,(a0)+			10 01
	move.w d6,(a0)+			01 01
	move.w d6,(a0)+			11 01
	move.w d3,(a0)+			00 11
	move.w d3,(a0)+			10 11
	move.w d7,(a0)+			01 11
	move.w d7,(a0)+			11 11
	jmp suitevbl

	endc
	ifeq typedot-TYPE4PLAN
codechange1
	;move.w #COLFOND,d0
	move.l #COLFOND*$10000+COLPIX,d1
	lea $ffff8240.w,a0
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	jmp suitevbl
codechange2
	move.l #COLCOLFOND,d0
	move.l #COLCOLPIX,d1
	lea $ffff8240.w,a0
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	jmp suitevbl
codechange3
	move.l #COLCOLFOND,d0
	move.l #COLCOLPIX,d1
	lea $ffff8240.w,a0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	jmp suitevbl
codechange4
	move.l #COLCOLFOND,d0
	move.l #COLCOLPIX,d1
	lea $ffff8240.w,a0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	jmp suitevbl
	
	endc
;-----------------------------------------------------------------------------
_disable_mouse:
;-----------------------------------------------------------------------------
	btst		#1,$FFFFFC00.W
	beq.s		_disable_mouse
	move.b		#$12,$FFFFFC02.W
	rts

;-----------------------------------------------------------------------------
_enable_mouse:
;-----------------------------------------------------------------------------
	btst		#1,$FFFFFC00.W
	beq.s		_enable_mouse
	move.b		#$8,$FFFFFC02.W
	rts

;preparePrimetable
;	lea tab8209,a0
;	lea tabtemp,a1
;	move.w #8208,d0
;	move.w #50*16/3,d1
;	jsr scaletable
;	
;	
;	
;	lea tabtemp,a0
;	move.w #8208,d7
;	move.w #17*2,d0
;	move.w #23*2,d1
;	move.w #2*2,d2
;	moveq #0,d3
;	moveq #0,d4
;	moveq #0,d5
;	lea 8209*2(a0),a1
;boucle	
;	move.w (a0,d3),d6
;	add (a0,d4),d6
;	add (a0,d5),d6
;	
;	add d0,d3
;	cmp.w #8209*2,d3
;	blt.s .1
;	sub.w #8209*2,d3
;
;.1	add d1,d4
;	cmp.w #8209*2,d4
;	blt.s .2
;	sub.w #8209*2,d4
;
;.2	add d2,d5
;	cmp.w #8209*2,d5
;	blt.s .3
;	sub.w #8209*2,d5
;.3
;	;lsr #2,d6
;	move.w d6,(a1)+
;	dbf d7,boucle
;	lea tabtemp,a0
;	lea tabtemp+8209*2,a1
;	move.w #8208,d0
;.cpy
;	move (a1)+,(a0)+
;	dbf d0,.cpy
;	
;	moveq #11,d3
;	lea tabtemp,a0
;	lea tabtemp+8209*4,a1
;.cpy2
;	move (a0)+,(a1)+
;	dbf d3,.cpy2
;	rts
;	
palfond:	;dc.w 0,$246,$124,$235	; PALETTE PICTURES	
		;	dc.w $777,$746,$724,$735  COULEUR PIXEL TRANSPARENCE (TOUT IDEM= PAS DE TRANSPARENCE)
		ifeq weirdos		; cas hyperspace
		dc.w $001,$333,$013,$024		; couleur bleu
		dC.w $555,$777,$666,$777
		
	
		endc
		ifne weirdos		; cas spiral onde
			dc.w 0,$530,$210,$420	  ; palette pictures maron
			DC.W $706,$777,$755,$637  ;  palette couleur transparences		
		endc
	DATA

picturebatch
			ifne weirdos
			incbin 'E:\1B.2PL'		raw picture animation 320x200 2 plan
			incbin 'E:\2B.2PL'
			incbin 'E:\3B.2PL'
			incbin 'E:\4B.2PL'
			incbin 'E:\5B.2PL'
			incbin 'E:\6B.2PL'
			endc
			ifeq weirdos			; si weirdos=0, hyperespace
			incbin 'E:\1C.2PL'
			incbin 'E:\2C.2PL'
			incbin 'E:\3C.2PL'
			incbin 'E:\4C.2PL'
			incbin 'E:\5C.2PL'
			incbin 'E:\6C.2PL'
			
			endc
	ifeq typedot-TYPE2PLAN
paramvbl
			dc.l screen8,codepalchangeplan1			; depart sur screen7, screen8 est la vbl suivante
			dc.l screen9,codepalchangeplan1
			dc.l screen10,codepalchangeplan1
			dc.l screen11,codepalchangeplan1
			dc.l screen12,codepalchangeplan1
			dc.l screen7,codepalchangeplan1
			dc.l screen8,codepalchangeplan2
			dc.l screen9,codepalchangeplan2
			dc.l screen10,codepalchangeplan2
			dc.l screen11,codepalchangeplan2
			dc.l screen12,codepalchangeplan2
			dc.l screen1,codepalchangeplan2
			
			dc.l screen2,codepalchangeplan1
			dc.l screen3,codepalchangeplan1
			dc.l screen4,codepalchangeplan1
			dc.l screen5,codepalchangeplan1
			dc.l screen6,codepalchangeplan1
			dc.l screen1,codepalchangeplan1
			dc.l screen2,codepalchangeplan2
			dc.l screen3,codepalchangeplan2
			dc.l screen4,codepalchangeplan2
			dc.l screen5,codepalchangeplan2
			dc.l screen6,codepalchangeplan2
			dc.l screen7,codepalchangeplan2
		
		;	dc.l screen7,codepalchangeplan2
	endc
	ifeq typedot-TYPE4PLAN	
paramvbl2		dc.l screen5,codechange1
			dc.l screen6,codechange1
			dc.l screen4,codechange1
			
			dc.l screen5,codechange2
			dc.l screen6,codechange2
			dc.l screen4,codechange2

			dc.l screen5,codechange3
			dc.l screen6,codechange3
			dc.l screen4,codechange3

			dc.l screen5,codechange4
			dc.l screen6,codechange4
			dc.l screen1,codechange4

			dc.l screen2,codechange1
			dc.l screen3,codechange1
			dc.l screen1,codechange1

			dc.l screen2,codechange2
			dc.l screen3,codechange2
			dc.l screen1,codechange2

			dc.l screen2,codechange3
			dc.l screen3,codechange3
			dc.l screen1,codechange3

			dc.l screen2,codechange4
			dc.l screen3,codechange4
			dc.l screen4,codechange4
		endc
		
parametreY	dc.w 1,7,512-4,6,1540-12,3,5,1540-1
			;dc.w 11,2,3,40,5,6,7,8
			dc.w 100,20,100,0,300,700,0,1200			; position dans reftable (*4)
			dc.w 1*4*12,(7)*4*12,512*4-4*4*12,6*4*12,(1540*4-12*4*12),3*4*12,5*4*12,1540*4-1*4*12
			
sinus512		incbin 'SIN512.GLK'		
sinus1540		incbin 'SIN1540.GLK'			
;tab8209			incbin 'SIN8209.GLK'
sound		incbin 'PYM_BEST.SND'
		even

	BSS
systeme	ds.l 8
		ds.l 1		; oldvbl
		ds.b 1		; 8260.w
		ds.b 1
;compteurvblMOD12	ds.w 1
			ds.w 200*2
lutmul160	ds.w 200*2
			ds.w 200*2
			
			ds.w 320
xxx			ds.w 320
			ds.w 320
			
every12vbl	ds.w 1

poslisteY	ds.w 1
bank1	ds.l 1
taillebank1	ds.l 1
bank2	ds.l 1
taillebank2	ds.l 1
bank3	ds.l 1
taillebank3	ds.l 1
bank4	ds.l 1
taillebank4	ds.l 1
bank5	ds.l 1
		ds.l 1

cheatcodedebut	ds.b 54*12		; valeur a determiner
cheatcodefin	ds.w 54*11 
		ds.b 54			; fillnop fill 54*12
	ifgt taillecheatcode
bigcheatcode	ds.b taillecheatcode	; normalement ca tombe juste pour 7008 dot
		;ds.b taillecheatcode
		;ds.b taillecheatcode
		;ds.b taillecheatcode
		;ds.b taillecheatcode
;bigcheatdebug	ds.b 20
	endc
cpt			ds.w 1
rtsfinish	ds.w 1
screen1		ds.l 1
screen2		ds.l 1		; this one is on 64k page
screen3		ds.l 1
screen4		ds.l 1
screen5		ds.l 1
screen6		ds.l 1
screen7		ds.l 1
screen8		ds.l 1		; this one is on 64k page
screen9		ds.l 1
screen10	ds.l 1
screen11	ds.l 1
screen12	ds.l 1
sinus1		ds.w 512
sinus2		ds.w 1540
;tabtemp	ds.w 8209*2+12
reftable1		ds.l 512
			ds.l 512
			ds.l 512
			ds.l 512
			ds.l 1540
			ds.l 1540
			ds.l 1540
			ds.l 1540
valuereftab	ds.w 8
ramresultat	ds.w 40000		; pas plus de 50k ???
		ifeq typedot-TYPE2PLAN
clearcode:	ds.w 2000*2+2+2+1
		ds.w 200
		endc
listeY	ds.w nbdot	; en fait 2x7000 mais comme on utilise la listeX que pour faire le code genere au depart, y'a plus besoin de listeX
		;ds.w 24
listeX	ds.w nbdot
		ds.w 24			; a enlever peut etre plus tard
		
		; peut etre mis a la place de sinus1 et sinus 2 qui sont plus utilisÃ© apres
bufferFlag1540	ds.b 1540
		ifeq typedot-TYPE4PLAN
codeeff4plan
		ds.w 17+1+2*1714+2
		endc
	ifeq typedot-TYPE2PLAN
bufferscreens ds.b (65536+32000*6)*2+32000
	endc
	ifeq typedot-TYPE4PLAN
bufferscreens ds.b (65536+32000*3)*2+32000
	endc
;picture2plan	ds.l 4000
;	TEXT
;	include 'MYMEM.S'