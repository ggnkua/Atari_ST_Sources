
;
;
; scroller 320x64 but only with box of 8x8
; (use set of register)
;
; it work !
; 
; code by gloky/mjj
; 

	TEXT
mainstart	jmp startpc


trans8x8to16x8:
	lea fonte,a0
	lea fonte2,a1

	move.w #59*8-1,d7
	move.b #3,d3	masque or
.loop
	moveq #0,d4
	move.w #8-1,d5
.nextoctet
	move.b (a0)+,d0
	;ext.w d0
.toto	ext.w d0
	tst.w d0
	bmi.s ._1
._0
	;lsl.l #2,d4
	add.w d4,d4
	add.w d4,d4
	bra.s .suite
._1
	add.w d4,d4
	add.w d4,d4
	or.b d3,d4
.suite
	add.w d0,d0
	
	dbf d5,.toto
	move.w d4,(a1)+
	dbf d7,.loop
	
	rts


startpc
	
	jsr trans8x8to16x8
	jsr makecodevaluebitmap		; prepare les tables d'instruction move.w Xn,(a0/1)
	jsr initbufscrolltozero
	jsr initscroller
	jsr scrollnextcar
	jsr putcar
	clr.l -(sp)	
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp

	move.b #0,$ffff8260.w

	move.l $44e.w,a1
	jsr clsa1
	move.l $44e.w,a1
	move.l a1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	lea fonte2+8*2*(65-32),a0

	moveq #7,d1

boucle

off	set 0
	move.w (a0)+,d0
	move.w d0,(a1)
	move.w d0,160(a1)
	
	lea 320(a1),a1
	dbf d1,boucle

	move.l $44e.w,d0
	move.l d0,logscr
	jsr waitkey
blip

	jsr wait50scanline

	not.w $ffff8240.w
	jsr affichebuffscroll
	
	jsr shiftandencode
	
	move cptpix,d0
	addq #1,d0
	and.w #15,D0
	BNE.S .1
	
	jsr scrollnextcar
	jsr putcar
	moveq #0,D0
	
.1	MOVE.W D0,cptpix
	
	

	not $ffff8240.w

waitkey
	move.l $466.w,d0
.1	cmp.l $466.w,d0
	beq.s .1
	
	cmp.b #$b9,$fffffc02.w
	bne blip	


	move.b #1,$ffff8260.w



	clr.w -(sp)
	trap #1
	
cptpix	dc.w 0
wait50scanline
	move.w #150*10,d0
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
;	move.l #bufferscroll,d0
;	move.l #20*2*4*8,d1
;	lea offsetscr,a0
;	move.l d0,(a0)+
;	add.l d1,d0
;	move.l d0,(a0)+
;	add.l d1,d0
;	move.l d0,(a0)+
;	add.l d1,d0
;	move.l d0,(a0)

	lea asciiLong,a0
	move.l #fonte2,d0
	move.l #255,d1
.loop2	move.l d0,(a0)+
	dbf d1,.loop2
	lea asciiLong+32*4,a0



	moveq.l #16,d1
	moveq.l #59-1,d7
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
	move.w (a0)+,4(a1)
	move.w (a0)+,8(a1)
	move.w (a0)+,12(a1)

	move.w (a0)+,16(a1)
	move.w (a0)+,20(a1)
	move.w (a0)+,24(a1)
	move.w (a0)+,28(a1)

	
	rts
		
totoc macro
	swap \1
	move.b \1,d7
	and.b d6,d7
	add.b d7,d7
	move.l d7,a6
	move.w (a6),(a3)
	move.w 32(a6),d0
	move.w d0,4*8*20(a3)
	lea 4(a3),a3
	endm
	
totod macro

	move.b \1,d7
	and.b d6,d7
	add.b d7,d7
	move.l d7,a6
	move.w (a6),(a3)
	move.w 32(a6),d0
	move.w d0,4*8*20(a3)
	lea 4(a3),a3
	endm
	
shiftandencode

	lea buffercar,a0
	move.l bufferscrollindexfin,a3
	add.w posscroll+2,a3
		
	;vbl0,1,2,3 :
	
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
	
	swap d0
	move.l adropcode,d7
	move.b #$F,d6
	move.b d0,d7
	and.b d6,d7
	add.b d7,d7
	move.l d7,a6
	move.w (a6),(a3)
	move.w 32(a6),d0
	move.w d0,4*8*20(a3)
	lea 4(a3),a3


	totoc d1
	
	totoc d2
	
	totoc d3
	
	totoc d4
	totoc d5
	
	move.w 24(a0),d1
	move.w 28(a0),d2
	
	totod d1
	totod d2
	
	lea cptstageshift,a0
	move.w (a0),d0
	subq #1,d0
	tst d0
	beq.s .1			;endcyclescroll
	move.w d0,(a0)
	
	
	
	
	;lea -32(a3),a3
	move.l bufferscrollindexfin,a3
	lea 4*8*40+2(a3),a3
	move.l a3,bufferscrollindexfin

	bra.s .w1
.1	move.w #4,(a0)


	move.l #bufferscroll,d2
		;move.l d2,bufferscrollindexfin

	lea posscroll,a3
	move.w (a3),d0
	move.w 2(a3),d1
	add #8*4,d1
	addq #8,d0
	cmp.w #160,d0
	bne.s .ok
	moveq #0,d0
	moveq #0,d1
.ok
	move.w d0,(a3)+
	move.w d1,(a3)
	;ext.l d1
	;add.l d1,d2
	move.l d2,bufferscrollindexfin

.w1
	
	rts



	
	
tableinsdcw1
	dc.w $3140,$3141,$3142,$3143,$3144,$3145,$3146,$314A,$314B,$314C
tableinsdcw2
	dc.w $3340,$3341,$3342,$3343,$3344,$3345,$3346,$334A,$334B,$334C
tableinstruction1
	move.w d0,$0(a0)	; 0000
	move.w d1,$0(a0)	; 000F	;0.01
	move.w d2,$0(a0)	; 00FF 	;01
	move.w d3,$0(a0)	; 0FF0	;0.1.0
	move.w d4,$0(a0)	; 0FFF	;1.1
	move.w d5,$0(a0)	; F000
	move.w d6,$0(a0)	; F00F	; a determiner si besoin de plus d'un registre de donne
	move.w a2,$0(a0)	; FF00
	move.w a3,$0(a0)	; FFF0
	move.w a4,$0(a0)	; FFFF
tableinstruction2
	move.w d0,$0(a1)	; 0000
	move.w d1,$0(a1)	; 000F	;0.01
	move.w d2,$0(a1)	; 00FF 	;01
	move.w d3,$0(a1)	; 0FF0	;0.1.0
	move.w d4,$0(a1)	; 0FFF	;1.1
	move.w d5,$0(a1)	; F000
	move.w d6,$0(a1)	; F00F
	move.w a2,$0(a1)	; FF00
	move.w a3,$0(a1)	; FFF0
	move.w a4,$0(a1)	; FFFF
initbufscrolltozero:
	move.l tableinstruction1,d0
	move.l tableinstruction2,d1
	lea bufferscroll,a0
	lea 4*8*40+2(a0),a1		; le 2 correspond a un rts ou un jmp (an)
	lea 4*8*40+2(a1),a2
	lea 4*8*40+2(a2),a3
	move.w #20-1,d2
	moveq #0,d4
	move.w #160*8,d6
.loopcol
	move.w #7,d3
	move.w d4,d5
.loopy
	move.w d5,d0
	move.w d5,d1
	add.w d6,d5
	move.l d0,(a0)+
	move.l d1,4*8*20-4(a0)
	
	move.l d0,(a1)+
	move.l d1,4*8*20-4(a1)
	
	move.l d0,(a2)+
	move.l d1,4*8*20-4(a2)
	
	move.l d0,(a3)+
	move.l d1,4*8*20-4(a3)
	
	
	dbf d3,.loopy
	
	add.w #8,d4
	dbf d2,.loopcol
	
	; on est arrivé a d4=20*8=160
	move.w coderts1,d0
	lea bufferscroll+4*8*40,a0
	move.w d0,(a0)+
	lea 4*8*40(a0),a0
	move.w d0,(a0)+
	lea 4*8*40(a0),a0
	move.w d0,(a0)+
	lea 4*8*40(a0),a0
	move.w d0,(a0)+					; 4 'rts' final
	
	rts
coderts1
	jmp (a6)

affichebuffscroll
	move.l bufferscrollindexfin,a5
	move.w posscroll,d0	; n entre 0 et 19*8,  cad ce qu'on va soustraire l'adresse ecran a0 sachant qu'on va commencer en n*8 pour le dep(a0)
	move.w posscroll+2,d1	; n entre 0 et 19*(4*8) = 1 colonne d'instruction
	add.w d1,a5			; adresse de saut
	lea 4*8*20(a5),a0	; fin du code du scroll
	move.w (a0),d7
	move.w d7,-(sp)		; sauve l'instruction
	move.l a0,-(sp)
	move.w coderts1,(a0)	on place un jmp (a6) a la fin du code 
	
	move.l logscr,a0
	lea 80*160(a0),a0		; depart du scroll a la ligne 50
	lea 160(a0),a1
	sub.w d0,a0
	sub.w d0,a1
prout
	movem.w regvalue,d0-d6/a2-a4
	lea retour,a6
	jmp (a5)
retour
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.1
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.2
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.3
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.4
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.5
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.6
	lea 160(a0),a0
	lea 160(a1),a1
	lea 14(a6),a6
	jmp (a5)
.7
	move.l (sp)+,a0
	move.w (sp)+,d7
	move.w d7,(a0) 			; restaure le jmp (a6) en move.w skifo
	

	
	
	
	rts
	
tablebinvalue
	dc.w 0,1,3,6,7,8,9,12,14,15
regvalue	dc.w 0,$F,$FF,$FF0,$FFF,$F000,$F00F,$FF00,$FFF0,$FFFF
	
	
makecodevaluebitmap
	clr.b  adropcode+3
	move.l adropcode,a4
	lea tablebinvalue,a0
	lea tableinstruction1,a1
	
	lea table16insa0,a2
	lea table16insa1,a3

	moveq #0,d2		;indexvalue
	
	move.w #0,d7	; compteur 0 a 15

.loop
	move.w d7,d0
	move.w (a0),d1
	cmp.w d0,d1
	beq.s .exist
	move.l tableinstruction1,d3	; instruction bitmap 0 d'office 
				; mais normalement, non utilis
				; par le programme (schema bitmap impossible)
	move.l tableinstruction2,d5
	move.l d3,d0
	swap d0
	move.l d5,d4
	swap d4
	bra.s .1			
.exist
	move.l (a1)+,d3
	move.l 40-4(a1),d5	; meme mais version a1
	move.l d3,d0
	swap d0
	move.l d5,d4
	swap d4
	addq.w #1,d2
	addq.w #2,a0

.1
	move.l d3,(a2)
	move.l d5,(a3)
	move.w d0,(a4)+
	move.w d4,32-2(a4)
	move.w #160*8,d4
	moveq #7,d6
.bcl	lea 64(a2),a2
	lea 64(a3),a3
	add.w d4,d3
	move.l d3,(a2)	; copie le meme set d'instruction
	add.w d4,d5
	move.l d3,(a3)
	dbf d6,.bcl		; mais de 8 ligne en 8 lignes
	
	lea -64*8+4(a2),a2
	lea -64*8+4(a3),a3
	
	addq #1,d7
	and.w #15,d7
	bne.s .loop


	rts

	
	DATA
adropcode	dc.l opcodes
bufferscrollindexfin	dc.l bufferscroll		;+5*8*4
			dc.w 0
cptstageshift	dc.w 4			; 4-> 3 2 1 0->4
fonte: 	;dcb.w 4,%1010101001010101
	incbin "G:SYSFONT.DAT"
	even
wheretext	dc.l starttext
starttext
	dc.b 'BONJOUR CECI EST UN PREMIER ESSAI DE SCROLL,'
	dc.b ' IL FAIT BEAU ET JE CODE LENTEMENT MAIS SUREMENT'
	dc.b ' PI=3.14159265358979 LET''S WRAAP           '
fintext
	even
posscroll	dc.w 0   ; 5*8
		dc.w 0       ; 5*8*4

buffercar	dcb.w 8*2,0
	BSS
fonte2:
	ds.l 472*2*8
table16insa0	ds.l 16*8
table16insa1	ds.l 16*8

bufferscroll
		ds.l 8*20*2 ; cas align 16    ;a chaque long correspond une
		ds.w 1		; rts ? dbf ?
		ds.l 8*20*2  cas align 16 +8 ;instruction move.w dn,dep(a0) ou (a1)
		ds.w 1
		ds.l 8*20*2 ; cas align 16    ;a chaque long correspond une
		ds.w 1		; rts ? dbf ?
		ds.l 8*20*2  cas align 16 +8 ;instruction move.w dn,dep(a0) ou (a1)
		ds.w 1
; format buffer scroll
;	colone de 8
;	 move.w dn,dep + col*8*160(a0)
;	puis 8 colone
;	 move.w dn,dep+8+col*8*160(a0)
;	et ainsi de suite
;	; si offset depart scroll est au milieu on fait lea a0 en consequence
;	; on retire n*8 
;	; offset revient a 0
; bande= 2 fois largeur de l'ecran
;
;	20x 8 ligne de move.w dn,0..19*8+ligne*8*160(a0)
;puis    20x 8 ligne de move.w dn,0..19*8+ligne*8*160(a1)
;si n=5
;	on appelle a la 5iem colonne de la bande des (a0)
;	on set a0 a a0-n*8
;puis a1 commence a a0+(20-n)*8 = a0 + 15 *8

logscr		ds.l 1

		ds.b 256
screens		ds.w 32000




offsetscr	ds.l 4
actualcar	ds.l 1
asciiLong	ds.l 256


bufferscrw		ds.w 20*8*2*2+1

			ds.b 256
opcodes		ds.w 32	
