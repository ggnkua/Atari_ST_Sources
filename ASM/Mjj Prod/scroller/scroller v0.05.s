
;
;
; scroller 320x64 but only with box of 8x8
; (use set of register)
; megasc36.s
; code by gloky/mjj
; 

	TEXT

lny	equ 8		; nombre de bloc de 8x8 en hauteur -de 8= plantage
lnx	equ 20      		; nombre de bloc de 16 pixel: 20 = 320

lnty	equ 16		; lnty = hauteur des bloc soit lnty= 8 normalement


tlcol	equ 4*lny
nbcar	equ 59
offscreenscroll	equ (100-64)*160

tmach	equ 1

mainstart
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

	bsr waitscanline

	ifne tmach
	not.b $ffff8240.w
	endc
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
	moveq.l #nbcar-1,d7
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
	rept lny-8
		move.l (a0),d0
		lsl.l d0,d0
		move.l d0,(a0)+
		swap d0
		totoc d0
	endr
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

tableinsdcw1
	dc.w $3140,$3141,$3142,$3143,$3144,$3145,$3146,$314A,$314B,$314C
;tableinstruction1
;	move.w d0,$0(a0)	; 0000
;	move.w d1,$0(a0)	; 000F	;0.01
;	move.w d2,$0(a0)	; 00FF 	;01
;	move.w d3,$0(a0)	; 0FF0	;0.1.0
;	move.w d4,$0(a0)	; 0FFF	;1.1
;	move.w d5,$0(a0)	; F000
;	move.w d6,$0(a0)	; F00F	; a determiner si besoin de plus d'un registre de donn‚e
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
	
	lea retour,a6
	lea regvalueR+10,a4
.0	lea 10(a4),a4		; regvalue +10+10 =+20 ou +10-10 = 0 !
	neg.w -12(a6)	
	movem.w (a4),d0-d6/a2-a4
	jmp (a5)
retour

	lea 160*(lnty-1)(a0),a0
	
	lea 10(a6),a6
	jmp (a5)

.1
	lea regvalue+10,a4 						;+6
.zob
	lea -10(a4),a4								;+4
	nop
	nop
	;neg.w 8(a6)		;neg .zob+2	vu que a6 =.1	;+4
	movem.w (a4),d0-d6/a2-a4					;+4 total = 18
	
	lea -160*(lnty-1)+160(a0),a0
	lea 10+18(a6),a6				;+18 pour que a6 arrive a .2
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
	;move.l #$31400000,d3	; instruction bitmap 0 d'office 
				; mais normalement, non utilis‚
				; par le programme (schema bitmap impossible)
	subq #2,a0
	moveq #0,d0
	bra.s .1			
.exist
	move.w (a1)+,d0
.1;
	move.w d0,(a4)+
	
	addq #1,d7
	and.w d6,d7
	bne.s .loop
	rts

	
	DATA
adropcode	dc.l opcodes
bufferscrollindexfin	dc.l bufferscroll		;+5*8*4
			;dc.w 0
cptstageshift	dc.w 4			; 4-> 3 2 1 0->4
fonte: 
    dc.b $0,$0,$0,$0,$0,$0,$0,$0
    dc.b $0,$18,$18,$18,$18,$18,$0,$18
    dc.b $0,$66,$66,$66,$0,$0,$0,$0
    dc.b $0,$0,$6C,$FE,$6C,$6C,$FE,$6C
    dc.b $0,$18,$3E,$60,$3C,$6,$7C,$18
    dc.b $0,$0,$66,$6C,$18,$30,$66,$46
    dc.b $0,$38,$6C,$38,$70,$DE,$CC,$76
    dc.b $0,$18,$18,$18,$0,$0,$0,$0
    dc.b $0,$E,$1C,$18,$18,$18,$1C,$E
    dc.b $0,$70,$38,$18,$18,$18,$38,$70
    dc.b $0,$0,$66,$3C,$FF,$3C,$66,$0
    dc.b $0,$0,$18,$18,$7E,$18,$18,$0
    dc.b $0,$0,$0,$0,$0,$0,$30,$30
    dc.b $0,$0,$0,$0,$7E,$0,$0,$0
    dc.b $0,$0,$0,$0,$0,$0,$18,$18
    dc.b $0,$2,$6,$C,$18,$30,$60,$40
    dc.b $0,$3C,$66,$6E,$76,$66,$66,$3C
    dc.b $0,$18,$38,$18,$18,$18,$18,$7E
    dc.b $0,$3C,$66,$6,$C,$18,$30,$7E
    dc.b $0,$7E,$C,$18,$C,$6,$66,$3C
    dc.b $0,$C,$1C,$3C,$6C,$7E,$C,$C
    dc.b $0,$7E,$60,$7C,$6,$6,$66,$3C
    dc.b $0,$3C,$60,$60,$7C,$66,$66,$3C
    dc.b $0,$7E,$6,$C,$18,$30,$30,$30
    dc.b $0,$3C,$66,$66,$3C,$66,$66,$3C
    dc.b $0,$3C,$66,$66,$3E,$6,$C,$38
    dc.b $0,$0,$18,$18,$0,$18,$18,$0
    dc.b $0,$0,$18,$18,$0,$18,$18,$30
    dc.b $0,$6,$C,$18,$30,$18,$C,$6
    dc.b $0,$0,$0,$7E,$0,$0,$7E,$0
    dc.b $0,$60,$30,$18,$C,$18,$30,$60
    dc.b $0,$3C,$66,$6,$C,$18,$0,$18
    dc.b $0,$3C,$66,$6E,$6A,$6E,$60,$3E
    dc.b $0,$18,$3C,$66,$66,$7E,$66,$66
    dc.b $0,$7C,$66,$66,$7C,$66,$66,$7C
    dc.b $0,$3C,$66,$60,$60,$60,$66,$3C
    dc.b $0,$78,$6C,$66,$66,$66,$6C,$78
    dc.b $0,$7E,$60,$60,$7C,$60,$60,$7E
    dc.b $0,$7E,$60,$60,$7C,$60,$60,$60
    dc.b $0,$3E,$60,$60,$6E,$66,$66,$3E
    dc.b $0,$66,$66,$66,$7E,$66,$66,$66
    dc.b $0,$3C,$18,$18,$18,$18,$18,$3C
    dc.b $0,$6,$6,$6,$6,$6,$66,$3C
    dc.b $0,$66,$6C,$78,$70,$78,$6C,$66
    dc.b $0,$60,$60,$60,$60,$60,$60,$7E
    dc.b $0,$C6,$EE,$FE,$D6,$C6,$C6,$C6
    dc.b $0,$66,$76,$7E,$7E,$6E,$66,$66
    dc.b $0,$3C,$66,$66,$66,$66,$66,$3C
    dc.b $0,$7C,$66,$66,$7C,$60,$60,$60
    dc.b $0,$3C,$66,$66,$66,$76,$6C,$36
    dc.b $0,$7C,$66,$66,$7C,$6C,$66,$66
    dc.b $0,$3C,$66,$60,$3C,$6,$66,$3C
    dc.b $0,$7E,$18,$18,$18,$18,$18,$18
    dc.b $0,$66,$66,$66,$66,$66,$66,$3E
    dc.b $0,$66,$66,$66,$66,$66,$3C,$18
    dc.b $0,$C6,$C6,$C6,$D6,$FE,$EE,$C6
    dc.b $0,$66,$66,$3C,$18,$3C,$66,$66
    dc.b $0,$66,$66,$66,$3C,$18,$18,$18
    dc.b $0,$7E,$6,$C,$18,$30,$60,$7E
    dc.b $0,$1E,$18,$18,$18,$18,$18,$1E
    dc.b $0,$40,$60,$30,$18,$C,$6,$2
 

	even
wheretext	dc.l starttext
starttext
	dc.b ' --- MAKE DEMOS (OR LOVE) --- NOT WAR ! --- PLEASE ! ....  '
	dc.b ' IL FAIT BEAU ET JE CODE LENTEMENT MAIS SUREMENT'
	dc.b ' JE VOUDRAIS MANGER DES FRITE CE MIDI MAIS FAUT PAS REVER, CETTE DURE REALITE PASCALIENNE EST INSUPORTABLE !!! :P  '
	dc.b ' PENSER A ACHETER DE LA SOUPE DEMAIN A ALDI, OUI EN FAIT ON PEUT METRE LE TEXTE QU''ON VEUT, TOUTEFOIS UN CARACTERE ASCII<32 ET >92 NE SERA PAS AFFICHE, MAIS C''EST  MOI QUI L''EST DECIDE  ... * PI=3.14159265358979 !!!!..... '
	DC.B ' LET''S WRAAP...           '
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

			ds.b 256
opcodes		ds.w 16	
