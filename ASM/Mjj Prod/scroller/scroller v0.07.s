
;
;
; scroller 320x64 but only with box of 8x8
; (use set of register)
; sc39.s
; code by gloky/mjj
; 

	TEXT
;libscroll equ 1

plein equ 1  ; 1 = filled bloc  

lny	equ 8		; nombre de bloc de 8x8 en hauteur -de 8= plantage
lnx	equ 20      		; nombre de bloc de 16 pixel: 20 = 320

lnty	equ 8		; lnty = hauteur des bloc soit lnty= 8 normalement


tlcol	equ 4*lny
nbcar	equ 249-32
offscreenscroll	equ (100)*160

tmach	equ 1

start
	jmp startpc

trans8x8to16x8:
	lea fonte,a0
	lea fonte2,a1

	move.w #nbcar*8-1,d7
	moveq #%11,d3	masque or
.loop
	moveq #0,d4
	moveq #lny-1,d5
.nextoctet
	move.b (a0)+,d0
	
.toto	
	add.w d4,d4
	add.w d4,d4
	tst.b d0
	bpl.s ._0
	or.b d3,d4
._0
.suite
	add.b d0,d0
	dbf d5,.toto
	move.w d4,(a1)+
	dbf d7,.loop
	rts
startpc
	
	jsr preparejeuderegvalueforonecar
	
	jsr trans8x8to16x8
	jsr makecodevaluebitmap		; prepare les tables d'instruction move.w Xn,(a0/
	jsr secondopcodegen
	jsr initbufscrolltozero
	jsr initscroller
	jsr scrollnextcar
	jsr putcar

	clr.l -(sp)	
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	move.b $ffff8260.w,d0
	move.w d0,-(sp)
	move.b #0,$ffff8260.w

	move.l $44e.w,a1
	jsr clsa1
	move.l $44e.w,a1
	move.l a1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.l $44e.w,d0
	move.l d0,logscr
	bsr waitvbl
blip


	ifne tmach
	not.b $ffff8240.w
	endc

	jsr shiftandencode4by4


	jsr affichebuffscrollCARA
	
	ifne tmach
	not.b $ffff8240.w
	endc
	
	jsr waitvbl

	ifne tmach
	not.b $ffff8240.w
	endc


	add.l #4*lny*lnx*2+2,bufferscrollindex
	jsr affichebuffscrollCARA

	ifne tmach
	not.b $ffff8240.w
	endc


	jsr waitvbl

	ifne tmach
	not.b $ffff8240.w
	endc



	add.l #4*lny*lnx*2+2,bufferscrollindex
	jsr affichebuffscrollCARA

	ifne tmach
	not.b $ffff8240.w
	endc


	jsr waitvbl

	ifne tmach
	not.b $ffff8240.w
	endc


	add.l #4*lny*lnx*2+2,bufferscrollindex
	jsr affichebuffscrollCARA

	move.l #bufferscroll,bufferscrollindex


	move cptpix,d0
	addq #1,d0
	and.w #3,D0
	BNE.S .1
	
	jsr scrollnextcar
	jsr putcar
	moveq #0,D0
	
.1	MOVE.W D0,cptpix

	ifne tmach
	 not.b $ffff8240.w
	endc
		
waitkey
	bsr waitvbl
	cmp.b #$b9,$fffffc02.w
	bne blip	

	move.w (sp)+,d0
	
	move.b d0,$ffff8260.w
	
	clr.w -(sp)
	trap #1
	
waitvbl
	move.l $466.w,d0
.1	cmp.l $466.w,d0
	beq.s .1

	bsr waitscanline


	rts
cptpix	dc.w 0
waitscanline
	move.w #1500,d0
.loop
	nop
	nop
	dbf d0,.loop

	rts
clsa1
	move.w #1999,d0
	moveq #0,d1
.loopcls
	move.l d1,(a1)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	dbf d0,.loopcls
	rts
initscroller

	lea asciiLong,a0
	move.l #fonte2,d0
	move.l #255,d1
.loop2	move.l d0,(a0)+
	dbf d1,.loop2
	lea asciiLong+32*4,a0

	moveq.l #2*lny,d1
	move.w #nbcar-1,d7
.loop
	move.l d0,(a0)+
	add.l d1,d0
	dbf d7,.loop
	; asciiLong pret
	rts
	
scrollnextcar
	lea wheretext,a0
	move.l (a0),a1
	lea asciiLong,a2
	moveq #0,d0
	move.b (a1)+,d0
	add d0,d0
	add d0,d0
	add.w d0,a2
	move.l (a2),d1
	move.l d1,actualcar
	cmp.l #fintext,a1
	bne.s .1
	lea starttext,a1
.1	move.l a1,(a0)
	rts
putcar
	move.l actualcar,a0
	lea buffercar+2,a1
.loop
	move.w (a0)+,(a1)
c	set 4
	rept lny-1
	move.w (a0)+,c(a1)
c	set c+4
	endr
	rts
		
totoc macro
	
	move.b \1,d7
	and.b d6,d7
	;add.b d7,d7
	move.l d7,a6
	move.w (a6),d0
	move.w d0,(a3)
	move.w d0,4*lny*lnx(a3)
	addq #4,a3
	endm
	
	
	
shiftandencode

	lea buffercar,a0
	move.l bufferscrollindexfin,a3
	add.w posscroll+2,a3
		
	;vbl0,1,2,3 :
	;rept lny/8
c	set lny-8
d	set 0
  rept 5
	ifge c
	movem.l (a0),d0-d7
	add.l d0,d0
	add.l d1,d1
	add.l d2,d2
	add.l d3,d3
	add.l d4,d4
	add.l d5,d5
	add.l d6,d6
	add.l d7,d7
	movem.l d0-d7,(a0)
	;endr
	move.l adropcode,d7
	move.b #$F*2,d6
	
	swap d0
	totoc d0
	swap d1
	totoc d1
	swap d2	
	totoc d2
	swap d3
	totoc d3
	swap d4
	totoc d4
	swap d5
	totoc d5
	
	move.w 24(a0),d1
	move.w 28(a0),d2
	
	totoc d1
	totoc d2
	
	lea 32(a0),a0
c	set c-8
	endc
	
   endr
   ; ici c=lny-8*k tel que negatif
    ifgt c+8
	rept c+8
		move.l (a0),d0
		lsl.l d0,d0
		move.l d0,(a0)+
		swap d0
		totoc d0
	endr
	
   endc
	lea cptstageshift,a0
	move.w (a0),d0
	subq #1,d0
	tst d0
	beq.s .1			;endcyclescroll
	move.w d0,(a0)

	;lea -32(a3),a3
	lea bufferscrollindexfin,a6
	move.l (a6),a3
	lea 4*lny*lnx*2+2(a3),a3
	move.l a3,(a6)
	rts
.1	move.w #4,(a0)
	move.l #bufferscroll,bufferscrollindexfin
	lea posscroll,a3
	move.l (a3),d0
	;move.w 2(a3),d1
	add.l #lny*4+8*$10000,d0
	cmp.w #lny*4*lnx,d0
	bne.s .ok
	moveq #0,d0
.ok
	move.l d0,(a3)	
	rts
;************************

		
;totoc macro
	
;	move.b \1,d7
;	and.b d6,d7
;	;add.b d7,d7
;	move.l d7,a6
;	move.w (a6),d0
;	move.w d0,(a3)
;	move.w d0,4*lny*lnx(a3)
;	addq #4,a3
;	endm


shiftandencode4by4
tlbuf	set 4*lnx*lny*2+2
	lea buffercar,a0
	lea bufferscroll+1,a3	move.l bufferscrollindexfin,a3
	add.w posscroll+2,a3
		
	;vbl0,1,2,3 :
	;rept lny/8
c	set lny-8
d	set 0
  rept 5
	ifge c
	movem.l (a0),d0-d7
	lsl.l #4,d0
	lsl.l #4,d1
	lsl.l #4,d2
	lsl.l #4,d3
	lsl.l #4,d4
	lsl.l #4,d5
	lsl.l #4,d6
	lsl.l #4,d7
	movem.l d0-d7,(a0)
	swap d5
	swap d6
	swap d7
	movem.w d5-d7,-(sp)
	;endr
	move.l #opcodes2,d7
	and.w #-512,d7
	move.w #%111111100,d6
	
	move.l d7,d5
	swap d0
	and.w d6,d0
	or.w d0,d5
	move.l d5,a6
	bsr .routinealacon
	
	move.l d7,d5
	swap d1
	and.w d6,d1
	or.w d1,d5
	move.l d5,a6
	bsr .routinealacon
	
	move.l d7,d5
	swap d2	
	and d6,d2
	or d2,d5
	move.l d5,a6
	bsr .routinealacon
	
	move.l d7,d5
	swap d3	
	and d6,d3
	or d3,d5
	move.l d5,a6	
	bsr .routinealacon

	move.l d7,d5
	swap d4
	and d6,d4
	or d4,d5
	move.l d5,a6
	bsr .routinealacon

	movem.w (sp)+,d0-d2
	
	move.l d7,d5
	and.w d6,d0
	or.w d0,d5
	move.l d5,a6
	bsr .routinealacon
	
	move.l d7,d5
	and.w d6,d1
	or.w d1,d5
	move.l d5,a6
	bsr .routinealacon
	
	move.l d7,d5
	and.w d6,d2
	or.w d2,d5
	move.l d5,a6
	bsr .routinealacon
		
	lea 32(a0),a0
		
c	set c-8
;	ifgt c
;	lea 32(a0),a0
;	endc
	endc
	
   endr
   ; ici c=lny-8*k tel que negatif
    ifgt c+8
	rept c+8
		move.l (a0),d0
		lsl.l #4,d0
		move.l d0,(a0)+
		swap d0
		move.l d7,d5
		and.w d6,d0
		or.w d0,d5
		move.l d5,a6
		bsr .routinealacon
		
	endr
	
   endc
;	lea cptstageshift,a0
;	move.w (a0),d0
;	subq #1,d0
;	tst d0
;	beq.s .1			;endcyclescroll
;	move.w d0,(a0)

;	;lea -32(a3),a3
;	lea bufferscrollindexfin,a6
;	move.l (a6),a3
;	lea 4*lny*lnx*2+2(a3),a3
;	move.l a3,(a6)
;	rts
.;1	move.w #4,(a0)
	; move.l #bufferscroll,bufferscrollindexfin
	lea posscroll,a3
	move.l (a3),d0
	;move.w 2(a3),d1
	add.l #lny*4+8*$10000,d0
	cmp.w #lny*4*lnx,d0
	bne.s .ok
	moveq #0,d0
.ok
	move.l d0,(a3)	
	rts

.routinealacon	
	move.b (a6)+,d0
	move.b d0,(a3)
	move.b d0,4*lny*lnx(a3)
	move.b (a6)+,d0
	move.b d0,tlbuf(a3)
	move.b d0,tlbuf+4*lny*lnx(a3)
	move.b (a6)+,d0
	move.b d0,tlbuf*2(a3)
	move.b d0,tlbuf*2+4*lny*lnx(a3)
	move.b (a6)+,d0
	move.b d0,tlbuf*3(a3)
	move.b d0,tlbuf*3+4*lny*lnx(a3)
	addq.l #4,a3
	rts



;************************



tableinsdcw1
	dc.w $3140,$3141,$3142,$3143,$3144,$3145,$3146,$314A,$314B,$314C

	dc.w 0,1,3,6,7,8,9,12,14,15
tablebyteop
	dc.b $40,$41,0,$42,0,0,$43,$44,$45,$46,0,0,$4a,0,$4b,$4c
;tableinstruction1
;	move.w d0,$0(a0)	; 0000
;	move.w d1,$0(a0)	; 000F	;0.01
;	move.w d2,$0(a0)	; 00FF 	;01
;	move.w d3,$0(a0)	; 0FF0	;0.1.0
;	move.w d4,$0(a0)	; 0FFF	;1.1
;	move.w d5,$0(a0)	; F000
;	move.w d6,$0(a0)	; F00F	; a determiner si besoin de plus d'un registre de donne
;	move.w a2,$0(a0)	; FF00
;	move.w a3,$0(a0)	; FFF0
;	move.w a4,$0(a0)	; FFFF
initbufscrolltozero:
	move.l #$31400000,d0	; premiere instruction

	lea bufferscroll,a0
	lea 4*lny*lnx*2+2(a0),a1		; le 2 correspond a un rts ou un jmp (an)
	lea 4*lny*lnx*2+2(a1),a2
	lea 4*lny*lnx*2+2(a2),a3
	moveq #lnx-1,d2
	moveq #0,d4
	move.w #160*lnty,d6

.loopcol

	moveq #lny-1,d3
	move.w d4,d5
.loopy

	move.w d5,d0
	add.w d6,d5
	move.l d0,(a0)+
	move.l d0,(a1)+
	move.l d0,(a2)+
	move.l d0,(a3)+
	add #lnx*8,d0
	move.l d0,4*lny*lnx-4(a0)
	move.l d0,4*lny*lnx-4(a1)
	move.l d0,4*lny*lnx-4(a2)
	move.l d0,4*lny*lnx-4(a3)

	dbf d3,.loopy
	
	addq #8,d4
	dbf d2,.loopcol
	
	; on est arrivé a d4=20*8=160
	move.w #$4ed6,d0		;jmp (a6) opcode
	lea bufferscroll+4*lny*lnx*2,a0
	move.w d0,(a0)+
	lea 4*lny*lnx*2(a0),a0
	move.w d0,(a0)+
	lea 4*lny*lnx*2(a0),a0
	move.w d0,(a0)+
	lea 4*lny*lnx*2(a0),a0
	move.w d0,(a0)+					; 4 'rts' final
	
	rts
;coderts1
;	jmp (a6) 4ed6

affichebuffscroll
	move.l bufferscrollindexfin,a5
	lea posscroll,a0
	move.w (a0)+,d0	; n entre 0 et 19*8,  cad ce qu'on va soustraire l'adresse ecran a0 sachant qu'on va commencer en n*8 pour le dep(a0)
	move.w (a0),d1	; n entre 0 et 19*(4*8) = 1 colonne d'instruction
	add.w d1,a5			; adresse de saut
	lea 4*lny*lnx(a5),a1	; fin du code du scroll
	move.w (a1),d7
;	move.w d7,-(sp)		; sauve l'instruction
;	move.l a0,-(sp)
	move.w #$4ed6,(a1)	on place un jmp (a6) a la fin du code 
	move.l logscr,a0
	lea  offscreenscroll(a0),a0		; depart du scroll a la ligne 50
	sub.w d0,a0
	
	lea .retour,a6
	lea regvalueR+10,a4
.0	lea 10(a4),a4		; regvalue +10+10 =+20 ou +10-10 = 0 !
	neg.w -12(a6)	
	movem.w (a4),d0-d6/a2-a4
	jmp (a5)
.retour

	lea 160*(lnty-1)(a0),a0
	
	lea 10(a6),a6
	jmp (a5)

.1
	ifne plein
	movem.w regvalue,d0-d6/a2-a4 						;+8
	endc
	
	ifeq plein
	lea regvalueT+10,a4
	lea 10(a4),a4
	neg.w 8(a6)
	movem.w (a4),d0-d6/a2-a4					;+4 total = 18
	endc
6
									;+4
	;neg.w 8(a6)		;neg .zob+2	vu que a6 =.1	;+4


	lea -160*(lnty-1)+160(a0),a0
	ifne plein
	lea 10+8(a6),a6				;+18 pour que a6 arrive a .2
	endc
	ifeq plein
	lea 10+18(a6),a6
	endc 
	jmp (a5)
.2
	rept lnty-3
	lea 160(a0),a0
	lea 10(a6),a6
	jmp (a5)
	endr
.3
	
;	lea 160(a0),a0
;	lea 10(a6),a6
;	jmp (a5)
;.4
;	lea 160(a0),a0
;	lea 10(a6),a6
;	jmp (a5)
;.5
;	lea 160(a0),a0
;	lea 10(a6),a6
;	jmp (a5)
;.6
;
;	lea 160(a0),a0
;	lea 10(a6),a6
;	jmp (a5)
;.7
;;	move.l (sp)+,a0
;;	move.w (sp)+,d7
;	move.w d7,(a1) 			; restaure le jmp (a6) en move.w skifo
;
	move.w d7,(a1)
	rts
;

affichebuffscrollCARA
	move.l bufferscrollindex,a5
	lea posscroll,a0
	move.w (a0)+,d0	; n entre 0 et 19*8,  cad ce qu'on va soustraire l'adresse ecran a0 sachant qu'on va commencer en n*8 pour le dep(a0)
	move.w (a0),d1	; n entre 0 et 19*(4*8) = 1 colonne d'instruction
	add.w d1,a5			; adresse de saut
	lea 4*lny*lnx(a5),a1	; fin du code du scroll
	move.w (a1),d7
;	move.w d7,-(sp)		; sauve l'instruction
;	move.l a0,-(sp)
	move.w #$4ed6,(a1)	on place un jmp (a6) a la fin du code 
	move.l a1,-(sp)
	move.l logscr,a0
	lea  offscreenscroll(a0),a0		; depart du scroll a la ligne 50
	sub.w d0,a0

.ins
	SF D0
	TST.b D0
	BEQ.S .P0
.P1
	move.l adrpatern,a1
	bra.s .titi
.P0
	move.l adrpatern+4,a1
.titi
	eor.w #$0100,.ins

	lea .retour,a6
	movem.w (a1)+,d0-d6/a2-a4
	jmp (a5)
.retour

	rept lnty-1
	movem.w (a1)+,d0-d6/a2-a4
	lea 160(a0),a0
	lea 10+4(a6),a6
	jmp (a5)
	endr
.3
	move.l (sp)+,a1
	move.w d7,(a1)
	rts

	
tablebinvalue
	dc.w 0,1,3,6,7,8,9,12,14,15
regvalue	dc.w 0,$F,$FF,$FF0,$FFF,$F000,$F00F,$FF00,$FFF0,$FFFF
;regvalue2	dc.w 0,$9,$99,$990,$999,$9000,$9009,$9900,$9990,$9999
;regvalue3	dc.w 0,$3,$33,$330,$333,$3000,$3003,$3300,$3330,$3333
;regvalue4	dc.w 0,$1,$11,$110,$111,$1000,$1001,$1100,$1110,$1111
regvalueR	dc.w 0,$7,$7E,$7E0,$07E7,$E000,$E007,$7E00,$E7e0,$E7E7
regvalueR2	dc.w 0,$7,$7E,$7E0,$07E7,$E000,$E007,$7E00,$e7E0,$7E7E
regvalueT	dc.w 0,$8,$81,$810,$0818,$1000,$1008,$8100,$1810,$1818
regvalueT2	dc.w 0,$8,$81,$810,$0818,$1000,$1008,$8100,$1810,$8181


andd0 macro
	move.w d0,d2
	and.w (a0)+,d2
	move.w d2,(a1)+

	endm
andd1 macro
	move.w d1,d2
	and.w (a0)+,d2
	move.w d2,(a1)+
	endm
putanypatern
; d0.b = valeur repete 2 fois en.w  : $xyxy
; a1 = buffer 10 word destination
;
	lea regvalue,a0
	move.w d0,d1		;xyxy
	ror.w #4,d1
	move.w (a0)+,(a1)+  ;0000  
	andd1				;000f = x

	andd0				;00ff=XY
	andd1				;0ff0=0xY0
	andd1				;0fff=0xyx
	andd1				;F000=y
	andd1				;F00F=y00x
	andd0				;FF00
	andd1				;FFF0=yxy0
	andd0				;FFFF=xyxy	? ou yxyx? deuxieme routine
	rts

putanypatern2
; d0.b = valeur repte 2 fois en.w  : $xyxy
; a1 = buffer 10 word destination
;
	lea regvalue,a0
	move.w d0,d1		;xyxy
	ror.w #4,d1			;yxyx
	move.w (a0)+,(a1)+  ;0000  
	andd1				;000f = x

	andd0				;00ff=XY
	andd1				;0ff0=0xY0
	andd1				;0fff=0xyx
	andd1				;F000=y
	andd1				;F00F=y00x
	andd0				;FF00
	andd1				;FFF0=yxy0
	andd1				;FFFF=xyxy	? ou yxyx? deuxieme routine
	rts
zerozero	dc.w 0


bloc8x8
	dc.b %00111100
	dc.b %01111110
	dc.b %11100111
	dC.b %11000011
	dC.b %11000011
	dc.b %11111111
	dc.b %01111110
	dc.b %11111111

preparejeuderegvalueforonecar

	;lea fonte+('G'-32)*8,a2
	lea bloc8x8,a2
	lea rampatern,a1
	lea adrpatern,a4
	move.l a1,(a4)+
	lea zerozero,a3
	clr.w (a3)
	moveq #lny-1,d7
.loop
	moveq #0,d0
	move.b (a2)+,d0
	move.b d0,(a3)
	or.w (a3),d0
	bsr putanypatern
	dbf d7,.loop
	sub #lny,a2
	
	move.l a1,(a4)+
	
	moveq #lny-1,d7
.loop2
	moveq #0,d0
	move.b (a2)+,d0
	move.b d0,(a3)
	or.w (a3),d0
	bsr putanypatern2
	dbf d7,.loop2
	rts
	
***************
minimumsetofregvalue:

listesbinvalue	dc.w 0,3,12,15,-1
				dc.w 0,1,6,7,8,14,15,-1
				dc.w -1
liste1:		
		dc.w $0000,$00FF,$FF00,$FFFF		; 4 value pour aligné sur 16 pixel
		;dc.W 0.00.0
		dc.w $0,$000F,$0FF0,$0FFF,$F000,$F00F,$FFF0,$FFFF		; 8 valeur pour mod 16=4
;****************

		;dc.w 00.00
listeregvalueadr	dc.l regvalueR,regvalueR2,regvalueR,regvalueR2
makecodevaluebitmap
	lea adropcode,a0
	sf.b  3(a0)
	move.l (a0),a4
	
	lea tablebinvalue,a0
	lea tableinsdcw1,a1
	
	move.w #0,d7	; compteur 0 a 15
	moveq #15,d6
.loop
	move.w d7,d0
	move.w (a0)+,d1
	cmp.w d0,d1
	beq.s .exist

	subq #2,a0
	move.W #$3140,d0
	bra.s .1			
.exist
	move.w (a1)+,d0
.1
	move.w d0,(a4)+
	
	addq #1,d7
	and.w d6,d7
	bne.s .loop
	rts


secondopcodegen
	move.l #opcodes2,d0		; before opcodes2	ds.b 512
	and.w #%1111111000000000,d0	; -512
	move.l d0,a0
	lea tablebyteop,a1
	move.w #4,d0
	moveq #0,d1
.bcl
	move d1,d2
	and.w #%000000111100000,d2
	lsr #5,d2

	; d2=4 premier bit,%
	;lsl #8,d5
	moveq #0,d5
	move.b (a1,d2),d5
	;tst.b d5
	;beq.s .invalide
	move d1,d2
	and.w #%000000011110000,d2
	lsr #4,d2
	
	lsl.l #8,d5
	move.b (a1,d2),d5
	move d1,d2
	and.w #%000000001111000,d2
	lsr #3,d2
	
	lsl.l #8,d5
	move.b (a1,d2),d5
	move d1,d2
	and.w #%000000000111100,d2
	lsr #2,d2
	
	lsl.l #8,d5
	move.b (a1,d2),d5
	
	move.l d5,(a0)+
	add d0,d1
	cmp.w #512,d1			; 
	bne.s .bcl
	
	rts
	


	
	DATA
adropcode	dc.l opcodes
bufferscrollindexfin	dc.l bufferscroll		;+5*8*4
			;dc.w 0
bufferscrollindex		dc.l bufferscroll
cptstageshift	dc.w 4			; 4-> 3 2 1 0->4
fonte:
	dc.b 0,0,0,0,0,0,0,0
	dc.b 24,24,24,24,24,0,24,0
	dc.b 102,102,102,0,0,0,0,0
	dc.b 0,108,254,108,108,254,108,0
	dc.b 24,62,96,60,6,124,24,0
	dc.b 0,102,108,24,48,102,70,0
	dc.b 56,108,56,112,222,204,118,0
	dc.b 24,24,24,0,0,0,0,0

	dc.b 14,28,24,24,24,28,14,0
	dc.b 112,56,24,24,24,56,112,0
	dc.b 0,102,60,255,60,102,0,0
	dc.b 0,24,24,126,24,24,0,0
	dc.b 0,0,0,0,0,48,48,96
	dc.b 0,0,0,126,0,0,0,0
	dc.b 0,0,0,0,0,24,24,0
	dc.b 2,6,12,24,48,96,64,0

	dc.b 60,102,110,118,102,102,60,0
	dc.b 24,56,24,24,24,24,126,0
	dc.b 60,102,6,12,24,48,126,0
	dc.b 126,12,24,12,6,102,60,0
	dc.b 12,28,60,108,126,12,12,0
	dc.b 126,96,124,6,6,102,60,0
	dc.b 60,96,96,124,102,102,60,0
	dc.b 126,6,12,24,48,48,48,0

	dc.b 60,102,102,60,102,102,60,0
	dc.b 60,102,102,62,6,12,56,0
	dc.b 0,24,24,0,24,24,0,0
	dc.b 0,24,24,0,24,24,48,0
	dc.b 6,12,24,48,24,12,6,0
	dc.b 0,0,126,0,0,126,0,0
	dc.b 96,48,24,12,24,48,96,0
	dc.b 60,102,6,12,24,0,24,0

	dc.b 60,102,110,106,110,96,62,0
	dc.b 24,60,102,102,126,102,102,0
	dc.b 124,102,102,124,102,102,124,0
	dc.b 60,102,96,96,96,102,60,0
	dc.b 120,108,102,102,102,108,120,0
	dc.b 126,96,96,124,96,96,126,0
	dc.b 126,96,96,124,96,96,96,0
	dc.b 62,96,96,110,102,102,62,0

	dc.b 102,102,102,126,102,102,102,0
	dc.b 60,24,24,24,24,24,60,0
	dc.b 6,6,6,6,6,102,60,0
	dc.b 102,108,120,112,120,108,102,0
	dc.b 96,96,96,96,96,96,126,0
	dc.b 198,238,254,214,198,198,198,0
	dc.b 102,118,126,126,110,102,102,0
	dc.b 60,102,102,102,102,102,60,0

	dc.b 124,102,102,124,96,96,96,0
	dc.b 60,102,102,102,118,108,54,0
	dc.b 124,102,102,124,108,102,102,0
	dc.b 60,102,96,60,6,102,60,0
	dc.b 126,24,24,24,24,24,24,0
	dc.b 102,102,102,102,102,102,62,0
	dc.b 102,102,102,102,102,60,24,0
	dc.b 198,198,198,214,254,238,198,0

	dc.b 102,102,60,24,60,102,102,0
	dc.b 102,102,102,60,24,24,24,0
	dc.b 126,6,12,24,48,96,126,0
	dc.b 30,24,24,24,24,24,30,0
	dc.b 64,96,48,24,12,6,2,0
	dc.b 120,24,24,24,24,24,120,0
	dc.b 16,56,108,198,0,0,0,0
	dc.b 0,0,0,0,0,0,254,0

	dc.b 0,192,96,48,0,0,0,0
	dc.b 0,0,60,6,62,102,62,0
	dc.b 96,96,124,102,102,102,124,0
	dc.b 0,0,60,96,96,96,60,0
	dc.b 6,6,62,102,102,102,62,0
	dc.b 0,0,60,102,126,96,60,0
	dc.b 28,48,124,48,48,48,48,0
	dc.b 0,0,62,102,102,62,6,124

	dc.b 96,96,124,102,102,102,102,0
	dc.b 24,0,56,24,24,24,60,0
	dc.b 24,0,24,24,24,24,24,112
	dc.b 96,96,102,108,120,108,102,0
	dc.b 56,24,24,24,24,24,60,0
	dc.b 0,0,236,254,214,198,198,0
	dc.b 0,0,124,102,102,102,102,0
	dc.b 0,0,60,102,102,102,60,0

	dc.b 0,0,124,102,102,102,124,96
	dc.b 0,0,62,102,102,102,62,6
	dc.b 0,0,124,102,96,96,96,0
	dc.b 0,0,62,96,60,6,124,0
	dc.b 0,24,126,24,24,24,14,0
	dc.b 0,0,102,102,102,102,62,0
	dc.b 0,0,102,102,102,60,24,0
	dc.b 0,0,198,198,214,124,108,0

	dc.b 0,0,102,60,24,60,102,0
	dc.b 0,0,102,102,102,62,6,124
	dc.b 0,0,126,12,24,48,126,0
	dc.b 14,24,24,48,24,24,14,0
	dc.b 24,24,24,24,24,24,24,24
	dc.b 112,24,24,12,24,24,112,0
	dc.b 0,96,242,158,12,0,0,0
	dc.b 0,24,24,52,52,98,126,0

	dc.b 0,60,102,96,102,60,8,56
	dc.b 102,0,0,102,102,102,62,0
	dc.b 12,24,0,60,126,96,60,0
	dc.b 24,102,0,60,6,126,62,0
	dc.b 102,0,60,6,62,102,62,0
	dc.b 48,24,0,60,6,126,62,0
	dc.b 24,24,0,60,6,126,62,0
	dc.b 0,0,60,96,96,60,8,24

	dc.b 24,102,0,60,126,96,60,0
	dc.b 102,0,60,102,126,96,60,0
	dc.b 48,24,0,60,126,96,60,0
	dc.b 102,0,0,56,24,24,60,0
	dc.b 24,102,0,56,24,24,60,0
	dc.b 96,48,0,56,24,24,60,0
	dc.b 102,0,24,60,102,126,102,0
	dc.b 24,0,24,60,102,126,102,0

	dc.b 12,24,126,96,124,96,126,0
	dc.b 0,0,126,27,127,216,126,0
	dc.b 63,120,216,222,248,216,223,0
	dc.b 24,102,0,60,102,102,60,0
	dc.b 102,0,0,60,102,102,60,0
	dc.b 48,24,0,60,102,102,60,0
	dc.b 24,102,0,102,102,102,62,0
	dc.b 48,24,0,102,102,102,62,0

	dc.b 102,0,102,102,102,62,6,124
	dc.b 102,0,60,102,102,102,60,0
	dc.b 102,0,102,102,102,102,62,0
	dc.b 24,24,60,96,96,60,24,24
	dc.b 28,58,48,124,48,48,126,0
	dc.b 102,102,60,24,60,24,24,0
	dc.b 28,54,102,124,102,102,124,96
	dc.b 30,48,124,48,48,48,96,0

	dc.b 12,24,0,60,6,126,62,0
	dc.b 12,24,0,56,24,24,60,0
	dc.b 12,24,0,60,102,102,60,0
	dc.b 12,24,0,102,102,102,62,0
	dc.b 52,88,0,124,102,102,102,0
	dc.b 52,88,0,102,118,110,102,0
	dc.b 0,60,6,62,102,62,0,60
	dc.b 0,60,102,102,102,60,0,60

	dc.b 0,24,0,24,48,96,102,60
	dc.b 0,0,0,62,48,48,48,0
	dc.b 0,0,0,124,12,12,12,0
	dc.b 198,204,216,54,107,195,134,15
	dc.b 198,204,216,54,110,214,159,6
	dc.b 0,24,0,24,24,24,24,24
	dc.b 27,54,108,216,108,54,27,0
	dc.b 216,108,54,27,54,108,216,0

	dc.b 52,88,0,60,6,126,62,0
	dc.b 52,88,0,60,102,102,60,0
	dc.b 2,60,102,110,118,102,60,64
	dc.b 0,2,60,110,118,102,60,64
	dc.b 0,0,126,219,223,216,126,0
	dc.b 127,216,216,222,216,216,127,0
	dc.b 48,24,0,24,60,102,126,102
	dc.b 52,88,0,24,60,102,126,102

	dc.b 52,88,60,102,102,102,102,60
	dc.b 102,0,0,0,0,0,0,0
	dc.b 12,24,48,0,0,0,0,0
	dc.b 0,16,56,16,16,16,0,0
	dc.b 122,202,202,202,122,10,10,10
	dc.b 126,195,189,177,177,189,195,126
	dc.b 126,195,189,165,185,173,195,126
	dc.b 241,91,95,85,81,0,0,0

	dc.b 102,0,230,102,102,246,6,28
	dc.b 246,102,102,102,102,246,6,28
	dc.b 0,102,118,60,110,102,0,0
	dc.b 0,124,12,12,12,126,0,0
	dc.b 0,30,6,14,30,54,0,0
	dc.b 0,126,12,12,12,12,0,0
	dc.b 0,124,6,102,102,102,0,0
	dc.b 0,28,12,12,12,12,0,0

	dc.b 0,30,12,6,6,6,0,0
	dc.b 0,126,54,54,54,54,0,0
	dc.b 96,110,102,102,102,126,0,0
	dc.b 0,60,12,12,0,0,0,0
	dc.b 0,62,6,6,6,62,0,0
	dc.b 96,126,6,6,6,14,0,0
	dc.b 0,108,62,102,102,110,0,0
	dc.b 0,28,12,12,12,60,0,0

	dc.b 0,62,54,54,54,28,0,0
	dc.b 0,54,54,54,54,126,0,0
	dc.b 0,126,102,118,6,126,0,0
	dc.b 0,102,102,60,14,126,0,0
	dc.b 0,62,6,54,54,52,48,0
	dc.b 0,120,12,12,12,12,0,0
	dc.b 0,214,214,214,214,254,0,0
	dc.b 0,124,108,108,108,236,0,0

	dc.b 0,28,12,12,12,12,12,0
	dc.b 0,62,6,6,6,6,6,0
	dc.b 0,254,102,102,102,126,0,0
	dc.b 0,126,102,118,6,6,6,0
	dc.b 0,54,54,28,12,12,12,0
	dc.b 14,27,60,102,102,60,216,112
	dc.b 0,16,56,108,198,130,0,0
	dc.b 102,247,153,153,239,102,0,0

	dc.b 0,0,118,220,200,220,118,0
	dc.b 28,54,102,124,102,102,124,96
	dc.b 0,254,102,98,96,96,96,248
	dc.b 0,0,254,108,108,108,108,72
	dc.b 254,102,48,24,48,102,254,0
	dc.b 0,30,56,108,108,108,56,0
	dc.b 0,0,108,108,108,108,127,192
	dc.b 0,0,126,24,24,24,24,16

	dc.b 60,24,60,102,102,60,24,60
	dc.b 0,60,102,126,102,102,60,0
	dc.b 0,60,102,102,102,36,102,0
	dc.b 28,54,120,220,204,236,120,0
	dc.b 12,24,56,84,84,56,48,96
	dc.b 0,16,124,214,214,214,124,16
	dc.b 62,112,96,126,96,112,62,0
	dc.b 60,102,102,102,102,102,102,0

	dc.b 0,126,0,126,0,126,0,0
	dc.b 24,24,126,24,24,0,126,0
	dc.b 48,24,12,24,48,0,126,0
	dc.b 12,24,48,24,12,0,126,0
	dc.b 0,14,27,27,24,24,24,24
	dc.b 24,24,24,24,216,216,112,0
	dc.b 24,24,0,126,0,24,24,0
	dc.b 0,50,76,0,50,76,0,0

	dc.b 56,108,56,0,0,0,0,0
	dc.b 56,124,56,0,0,0,0,0

	even
wheretext	dc.l starttext
starttext
		dc.b ' ascii from 32 to 249.5 +/- 0.5 :p ,  WELLCOME TO MY SCROLLER, LET''S WRAAAAAP !!!!!!'
		DC.B ' i''m sorry i have no imagination for a text for the scrOller'
		dc.b '         '
		
fintext
	even
posscroll	dc.w 0   ; 5*8
		dc.w 0       ; 5*8*4

	BSS
fonte2:
	ds.w lny*nbcar


buffercar	ds.w lny*2
bufferscroll
		ds.l lny*lnx*2 ; cas align 16    ;a chaque long correspond une
		ds.w 1		; rts ? dbf ?
		ds.l lny*lnx*2  cas align 16 +8 ;instruction move.w dn,dep(a0) ou (a1)
		ds.w 1
		ds.l lny*lnx*2 ; cas align 16    ;a chaque long correspond une
		ds.w 1		; rts ? dbf ?
		ds.l lny*lnx*2  cas align 16 +8 ;instruction move.w dn,dep(a0) ou (a1)
		ds.w 1

logscr		ds.l 1

		ds.b 256
screens		ds.w 32000

offsetscr	ds.l 4
actualcar	ds.l 1
asciiLong	ds.l 256

			ds.b 256
opcodes		ds.w 32	
			
			ds.b 512
opcodes2	ds.l 128

adrpatern	ds.l 2
rampatern	ds.w 10*8*2
