
;
;
; c2P utilisant les segment de 64k
; 3 sinus de 7 bit

_NBlignes equ 36 50  37
HEMOROID EQU 0
pcstart
	IFEQ HEMOROID
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	ENDC
	
init:
	MOVE.W #$2700,SR
    MOVE.L $70.W,D0
    MOVE.L #ITVBL,$70
    MOVE.L D0,OLDITVBL
    MOVE.W #$2300,SR
    
	IFEQ HEMOROID
	move.b #0,$ffff8260.w
	jsr wvbl
	move.b #0,$ffff8260.w
	ENDC
	
	move.l #c2ptable,d0
	clr.w d0
	move.l d0,c2ptableptr
	add.l #65536,d0
	
	lea ptrscreen,a0
	move.l d0,(a0)+
	add.l #32000,d0
	move.l d0,(a0)
	
	
	jsr initc2ploop
	jsr inithalftone
	move.l c2ptableptr,a2
	jsr makec2ptable
	jsr prepsinAsinBsinC
	jsr initfonction
	move.l #16000-1,d1
	move.l ptrscreen,a0
	moveq #0,d0
.clrscr
	move.l d0,(a0)+
	dbf d1,.clrscr
	
	movem.l palette,d0-d7
	movem.l d0-d7,$ffff8240.w
	jsr sound

main
	lea ptrscreen,a0
	move.l (a0),d0
	move.l 4(a0),d1
	move.l d1,(a0)+
	move.l d0,(a0)
	
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	bsr wvbl

	move.l d1,a3
	move.l d1,-(sp)

	jsr plasmaaa
	move.l (sp)+,a0
	
	; copie des ligne
	;rept _NBlignes
;toto
;	movem.l (a0)+,d0-d7/a1-a6				14*4
;	movem.l d0-d7/a1-a6,160-14*4(a0)	
;	movem.l d0-d7/a1-a6,320-14*4(a0)	
;	movem.l d0-d7/a1-a6,480-14*4(a0)	
;	movem.l (a0)+,d0-d7/a1-a6				28*4
;	movem.l d0-d7/a1-a6,160-14*4(a0)
;	movem.l d0-d7/a1-a6,320-14*4(a0)
;	movem.l d0-d7/a1-a6,480-14*4(a0)
;	movem.l (a0)+,d0-d7/a1-a4				28+12*4=40*4
;	movem.l d0-d7/a1-a4,160-12*4(a0)
;	movem.l d0-d7/a1-a4,320-12*4(a0)
;	movem.l d0-d7/a1-a4,480-12*4(a0)

;	lea 640-80*2(a0),a0
	;endr

	jsr codegenmovem
	
	
	move.w #$777,$ffff8240.w
	move.w #$00,$ffff8240.w
	
	cmp.b #$39,$fffffc02.w
	bne main
	
	
	IFEQ HEMOROID
	move.b #1,$ffff8260.w
	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	endc
	
	jsr wvbl
	MOVE.W #$2700,SR
	MOVE.L OLDITVBL,D0
	MOVE.L D0,$70.W
	MOVE.W #$2300,SR
	jsr sound+4
	ifeq HEMOROID
	clr.w -(sp)
	trap #1
	ENDC
	ILLEGAL
	
	
ITVBL
	ADDQ.W #1,CPTVBL
	
	movem.l d0/d1,-(sp)
	jsr sound+8
	subq #1,cpttimer
	movem.l (sp)+,d0/d1
	RTE
CPTVBL	DC.W 0
cpttimer	dc.w 512
OLDITVBL	DC.L 0
*palette	dc.w 0,$111,$112,$222,$223,$333,$334,$555,$666,$777,$775,$764,$753,$742,$731,$720,$710

palette	dc.w 0,$112,$223,$334,$337,$237,$127,$226,$325,$424,$613,$712,$612,$511,$410,$300,$200

ptrfonction	dc.l firstfonction
initfonction
	; a0 = liste parametre
	;
	lea ptrfonction,a2
	move.l (a2),d0
	cmp.l #endfonction,d0
	bne.s .ok
	move.l #firstfonction,d0
	move.l d0,(a2)
.ok
	move.l d0,a0
	
	lea plasmaauto,a1

	move.w (a0)+,d0
	add d0,d0
	add d0,d0
	move.w d0,(a1)


	move.w (a0)+,d0
	add d0,d0
	add d0,d0
	move.w d0,4(a1)


	move.w (a0)+,d0
	add d0,d0
	add d0,d0
	move.w d0,8(a1)

	move.w (a0)+,_ad1+2			512
	move.w (a0)+,_ad2+2			512
	
	move.w (a0)+,_ad3+2			1540
	move.w (a0)+,_ad4+2			1540

	move.w (a0)+,_ad5+2			1540
	move.w (a0)+,_ad6+2			1540
	move.l a0,d0
	move.l d0,(a2)
	jsr initfx2
	rts

firstfonction:

	;dc.w 511,1539,1539			ajout each vbl sin1,sin2,sin3
	;dc.w 511,511				ajout sin 1: pas sur la ligne(x), pas retour a la ligne(y)
	;dc.w 1539,1539				ajout sin 2: pas sur la ligne, pas retour a la ligne
	;dc.w 1539,1539				ajout sin 3: pas sur la ligne, pas retour a la ligne
	; les valeur si dessus sont les valeur max que peuvent prendre les valeur
	; (ici ca correspond a un pas de -1 partout)
	; a part sur les pas each vbl , les 0 sont mal accepté (ca prend beaucoup de memoire)

	dc.w 1,2,4
	dc.w 30,35
	dc.w 16*30+1,16*35+1
	dc.w 4,1
	
	dc.w 2,1,4
	dc.w 30,35
	dc.w 31*16+1,36*16+1
	dc.w 4,1
	
	dc.w 4,2,1
	dc.w 35,40
	dc.w 16*35+1,16*40+1
	dc.w 1,4
	
	dc.w 1,2,3
	dc.w 80,85
	dc.w 80*16+1,85*16+1
	dc.w 3,1
	
	dc.w 1,2,3
	dc.w 85,90
	dc.w 85*16+1,90*16+1
	dc.w 2,3
	
	dc.w 1,2,4
	dc.w 95,100
	dc.w 1600+1-1540,95*16+1
	dc.w 2,4
	
	dc.w 1,2,4
	dc.w 100,105
	dc.w 105*16+1-1540,1600+1-1540
	dc.w 2,4
	
	dc.w 2,3,7
	dc.w 100,110
	dc.w 100*16+1-1540,110*16+2-1540
	dc.w 1,2
	
	
	
	
	
	
	
	
	dc.w 10,20,1540-30
	dc.w 101,201
	dc.w 16*10+1,16*20+1,3,4
	
	dc.w 16,17,18
	dc.w 256+128+1,256+128+64+16+2
	dc.w 1,2
	dc.w 3,4
	
	dc.w 1,2,3
	dc.w 2,3
	dc.w 4,5
	dc.w 6,7
	
	dc.w 1+4,2+4,3+4
	dc.w 2+4,3+4
	dc.w 4+4,5+4
	dc.w 6+4,7+4


	dc.w 1,1540-11,1540-2
	dc.w 10,15
	dc.w 11,16
	dc.w 12,1540-17


	dc.w 512-11,3,17
	dc.w 9,511-4
	dc.w 15,1540-12
	dc.w 1540-19,22

	dc.w 1,2,3
	dc.w 511-7,10
	dc.w 1540-9,7
	dc.w 1540-6,13
	

	dc.w 1,11,1540-5
	dc.W 1,7
	dc.w 3,6
	dc.w 1540-4,1
	
	dc.w 3,2,5
	dc.w 4,2
	dc.w 5,1
	dc.w 1,4

	dc.w 6,1540-3,2
	dc.w 4,512-2
	dc.w 5,4
	dc.w 1540-3,1
	
	dc.w 2,4,11
	dc.w 5,3
	dc.w 7,9
	dc.w 1540-10,26
	
	
endfonction
plasmaaa	
	; a3 = logscreen
	movem.w anglex4,d1-d3
	move.l adrrefA,a6
	add d1,a6
	move.l adrrefB,a4
	add d2,a4
	move.l adrrefC,a5
	add d3,a5
	move.l (a6),a6
	move.l (a4),a4
	move.l (a5),a5
	move.l (a6)+,a0
	move.l (a4)+,a1
	move.l (a5)+,a2
	move.l a6,d5
	move.w #_NBlignes-1,d7			; nombre de ligne
	move.l c2ptableptr,d0
		
	jsr codegenere
	movem.w anglex4,d1-d3
plasmaauto equ *+2
	add.w #(512-11)*4,d1
	add.w #(3)*4,d2
	add.w #(17)*4,d3
	and.w #511*4,d1
	move.w #1540*4,d0
	cmp.w d0,d2
	blt.s .1
	sub d0,d2
.1	cmp.w d0,d3
	blt.s .2
	sub d0,d3
.2	movem.w d1-d3,anglex4
	rts
	
	
wvbl:	move.w d7,-(sp)
		move.w CPTVBL,d7
.1		cmp.w CPTVBL,d7
		beq.s .1
		move.w (sp)+,d7

		tst.w cpttimer
		bpl.s .2
		move.w #4096,cpttimer
		movem.l d0/d1,-(sp)
		jsr initfonction
		movem.l (sp)+,d0/d1
.2
		rts
	dc.l $f0000000
	dc.l $0f000000
	;dc.l
	DC.L $3000
	dc.l $0C00 
initfonte
	;lea fonte,a0
	;lea doublezero,a1
	moveq #7,d7
	moveq #0,d1
.loop
	move.b (a0),(a1)
	move.w (a1),d0
	lsl.w #1,d0
	bvc .suite
.putbloc
	move.l #$F000,d1
	
.suite
	lsl.w #1,d0
	bvc.s .suite2
.putbloc2
	or.w #$0F00,d1

.suite2
	lsl.w #1,d0
	bvc.s .suite3
.putbloc3
	or.w #$00F0,d1
.suite3
	lsl.w #1,d0
	bvc .suite4
.putbloc4
	or.w #$000F,d1

.suite4
	move.w d1,(a2)+
	moveq #0,d1
	move.w #$F000,d2
	
	
	

	;moveq #0,d1
	;btst d1,d0
	;b;eq.s .1
	;move.l #00000000000000,d2
	

initc2ploop
	lea codegenere,a6
	lea automovep1,a1
	lea automovep2,a2
	move.w #0,(a1)			; pas necessaire sauf si on appelle une seconde fois la routine
	move.w #1,(a2)
	
	lea c2ptounrol,a3
	move.l a3,a4
;.;loopligne
	moveq #19,d7
.loop
	move.l a4,a3
	lea c2ptounrolend,a5
.cpy
	move.w (a3)+,(a6)+
	cmp.l a3,a5
	bne.s .cpy
	add.w #8,(a1)
	add.w #8,(a2)
	dbf d7,.loop

	lea c2pinita0a1a2,a3
	lea c2pfina0a1a2,a5
.cpy2
	move.w (a3)+,(a6)+
	cmp.l a3,a5
	bne.s .cpy2
	
	lea codegenmovem,a6
	move.l #$4CD87EFF,d0		movem.l (a0)+,d0-d7/a1-a6
	move.l #$48E87EFF,d1		movem.l d0-d7/a1-a6,dep(a0)
	move.w #$68,d2
	move.w #$108,d3
	move.w #$1a8,d4
	move.l #$48e81eff,d6
	
			
	move.w #_NBlignes-1,d7
.cpynbligne
	moveq #1,d5
.loopcpy
	move.l d0,(a6)+
	move.l d1,(a6)+
	move.w d2,(a6)+
	move.l d1,(a6)+
	move.w d3,(a6)+
	move.l d1,(a6)+
	move.w d4,(a6)+						; (22 octet*2
	dbf d5,.loopcpy		
	move.l #$4cd81eff,(a6)+
	move.l d6,(a6)+
	move.w #$70,(a6)+
	move.l d6,(a6)+
	move.w #$110,(a6)+
	move.l d6,(a6)+
	move.w #$1b0,(a6)+
	move.l #$41e801e0,(a6)+				; +26 octet) * nbligne   22+13 = 35 word*nbligne
	dbf d7,.cpynbligne
	move.w #$4e75,-4(a6)		; rts a la place du dernier lea 
										; -2

	rts
		
; code mort a unrolé comme il faut

;cp2routinitline
;	lea 320(a3),a3
c2ptounrol
	move.w (a0)+,d0
	add.w (a1)+,d0
	add.w (a2)+,d0
	move.l d0,a6
	move.l (a6),d4
automovep1 equ *+2
	movep.l d4,0(a3)
	
	move.w (a0)+,d0
	add.w (a1)+,d0
	add.w (a2)+,d0
	move.l d0,a6
	move.l (a6),d4
automovep2 equ *+2
	movep.l d4,1(a3)
c2ptounrolend
c2pinita0a1a2
	move.l d5,a6
	move.l (a6)+,a0
	move.l (a4)+,a1
	move.l (a5)+,a2
	move.l a6,d5
	lea 640(a3),a3				640
	; dbf d7,codegenere
	dc.w $51CF,$FDC0
	rts
c2pfina0a1a2





c2p1pixtounrol
	;lea c2p1pixauto,a0
	;move.w #0,(a0)
initc2ploop1pix
	lea codegenere,a6
	lea c2p1pixauto,a1
	move.w #0,(a1)			; pas necessaire sauf si on appelle une seconde fois la routine
		
	lea c2p1pix,a3
	move.l a3,a4
;.;loopligne
	moveq #3,d7
.loop
	move.l a4,a3
	lea c2p1pixfin,a5
.cpy
	move.w (a3)+,(a6)+
	cmp.l a3,a5
	bne.s .cpy
	btst #0,(a1)
	bne.s .add7
	addq.w #1,(a1)
	bra.s .add0
.add7	addq.w #7,(a1)
.add0
	dbf d7,.loop

	lea c2p1pixinita0a1a2,a3
	lea c2p1pixfina0a1a2,a5
.cpy2
	move.w (a3)+,(a6)+
	cmp.l a3,a5
	bne.s .cpy2
	move.w #$4e75,(a6)+
	rts
c2p1pixinita0a1a2
	move.l d5,a6
	move.l (a6)+,a0
	move.l (a4)+,a1
	move.l (a5)+,a2
	move.l a6,d5
	lea 160(a3),a3				640
	; dbf d7,codegenere
	dc.w $51CF,$Ff40
c2p1pixfina0a1a2
	rts
	

c2p1pix
	move.w (a0)+,d0  %11000000
	add.w (a1)+,d0
	add.w (a2)+,d0
	;and.w dn=%11110000,d0
	move.l d0,a6
	move.l (a6),d4

	
	move.w (a0)+,d1		00110000
	add (a1)+,d1
	add (a2)+,d1
	move.l d1,a6
	or.l (a6),d4
	
	move.w (a0)+,d2   00001100   
	add (a1)+,d2
	add (a2)+,d2
	move.l d2,a6
	or.l (a6),d4
		
	move.w (a0)+,d3		00000011
	add (a1)+,d3
	add (a2)+,d3
	move.l d3,a6
	or.l (a6),d4
	
c2p1pixauto equ *+2
	movep d4,0(a4)
c2p1pixfin

	move.l d5,a6
	move.l (a6)+,a0
	move.l (a4)+,a1
	move.l (a5)+,a2
	move.l a6,d5
	lea 160(a3),a3				640
	dc.w $51cf,$ff40
	
debug
	rept 4
	move.w (a0)+,d0  %11000000
	add.w (a1)+,d0
	add.w (a2)+,d0
	;and.w dn=%11110000,d0
	move.l d0,a6
	move.l (a6),d4

	
	move.w (a0)+,d1		00110000
	add (a1)+,d1
	add (a2)+,d1
	move.l d1,a6
	or.l (a6),d4
	
	move.w (a0)+,d2   00001100   
	add (a1)+,d2
	add (a2)+,d2
	move.l d2,a6
	or.l (a6),d4
		
	move.w (a0)+,d3		00000011
	add (a1)+,d3
	add (a2)+,d3
	move.l d3,a6
	or.l (a6),d4
	
;c2p1pixauto equ *+2
	movep d4,1(a4)

	endr

	move.l d5,a6
	move.l (a6)+,a0
	move.l (a4)+,a1
	move.l (a5)+,a2
	move.l a6,d5
	lea 160(a3),a3				640
	 dbf d7,debug
	;dc.w $51CF,$FDC0

	

	move.w (a0)+,d0  %10001000
	add.w (a1)+,d0
	add.w (a2)+,d0
	;and.w dn=%11110000,d0
	move.l d0,a6
	move.l (a6),d5
	and.l d7,d5
	or.l d5,d4
	
	move.w (a0)+,d1		01000100
	add (a1)+,d1
	add (a2)+,d1
	move.l d1,a6
	move.l (a6),d5
	and.l d7,d5
	or.l d5,d4
	
	move.w (a0)+,d2
	add (a1)+,d2
	add (a2)+,d2
	move.l d2,a6
	move.l (a6),d5
	and.l d7,d5
	or.l d5,d4
	
	move.w (a0)+,d3
	add (a1)+,d3
	add (a2)+,d3
	move.l d3,a6
	move.l (a6),d5
	and.l d7,d5
	or.l d5,d4

	movep.l d4,2(a4)





	
	move.w (a0)+,d3
	add (a1)+,d3
	add (a2)+,d3
	move.l d3,a6
	or.l (a6),d4
	
	move.w (a0)+,d0
	add.w (a1)+,d0
	add (a2)+,d0
	
	


;
;
; routine de test qui permet de calculer l'opcode du dbf d7,codegenere
;superdupont
;	rept 20
;	move.w (a0)+,d0
;	add.w (a1)+,d0
;	add.w (a2)+,d0
;	move.l d0,a6
;	move.l (a6),d4
;;automovep1 equ *+2
;	movep.l d4,0(a3)
	
;	move.w (a0)+,d0
;	add.w (a1)+,d0
;	add.w (a2)+,d0
;	move.l d0,a6
;	move.l (a6),d4
;;utomovep2 equ *+2
;	movep.l d4,1(a3)
;	endr
;	move.l d5,a6
;	move.l (a6)+,a0
;	move.l (a4)+,a1
;	move.l (a5)+,a2
;	move.l a6,d5
;	lea 640(a3),a3;
;	dbf d7,superdupont	; a voir la valeur au debuggueur: $51CF,$FDC0
;	rts
 

; CODe that calculate c2phalftone	data
; once the value calculated in debugger
; it cost less octet to put the data directly in dc.l
; and the code is deprecated but i need to keep this routine for the futur


inithalftone
	
	move.l #$55555555,d2
	move.l d2,d3
	not.l d3
.dumb	
	lea c2ptable0,a0
	lea c2phalftone,a1
	moveq #15,d7
	move.l (a0)+,d0;
	move.l d0,(a1)+
toto
	move.l (a0)+,d1
	move.l d0,(a1)+
	move.l d0,d4
	and.l d2,d4
	move.l d1,d5
	and.l d3,d5
	or.l d4,d5
	move.l d5,(a1)+
	
	move.l d1,d0
	dbf d7,toto
	;move.l d5,(a1)+
	rts
;	illegal

c2pcolor1pix	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
				dc.b 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
				dc.b 15,15,15,14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0
				




c2ptable0	DC.L $00000000
			DC.L $FF000000
			DC.L $00FF0000
			DC.L $FFFF0000
			DC.L $0000FF00
			DC.L $FF00FF00
			DC.L $00FFFF00
			DC.L $FFFFFF00
			DC.L $000000FF
			DC.L $FF0000FF
			DC.L $00FF00FF
			DC.L $FFFF00FF
			DC.L $0000FFFF
			DC.L $FF00FFFF
			DC.L $00FFFFFF
			DC.L $FFFFFFFF
		
;c2phalftone
;			dc.l $00000000
;			dc.l $AA000000
;			dc.l $FF000000
;			dc.l $55AA0000
;			dc.l $00FF0000
;			dc.l $AAFF0000
;			dc.l $5555AA00
;			dc.l $0000FF00
;			dc.l $AA00FF00
;			dc.l $FF00FF00
;			dc.l $55AAFF00
;			dc.l $00FFFF00
;			dc.l $AAFFFF00
;			dc.l $FFFFFF00
;			dc.l $555555AA
;			dc.l $000000FF
;			dc.l $AA0000FF
;			dc.l $FF0000FF
;			dc.l $55AA00FF
;			dc.l $00FF00FF
;			Dc.l $AAFF00FF
;			DC.L $FFFF00FF
;			DC.L $5555AAFF
;			DC.L $0000FFFF
;			DC.L $AA00FFFF
;			DC.L $FF00FFFF
;			DC.L $55AAFFFF
;			DC.L $00FFFFFF
;			DC.L $AAFFFFFF
;			DC.L $FFFFFFFF
;		
;			dc.l $FFFFFFFF		; repeated to have 32 value ??? est ce qu'on doit metre 32 valeur ou est ce qu'il
;			dc.l 0,0,0,0						; vaut mieux pas garder 31 valeur et faire le tableau en consequence
;			BSS
;c;2phalftone	ds.l 32
;			ds.l 1
			
;		3 valeur 7 bit additionné table c2p : 2 texel  14bit +2bit=4 octet pour le movep
;		
;		pour chaque sin:
;		un word  7+7+2 bit
;		deployé en paire impaire
		DATA
liste128colorj
	dc.b 0,0,1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29
	dc.b 29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,1,0,0
	dc.b 0,0,1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29
	dc.b 29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,1,0,0
liste128colord
	dc.b 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b 16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,30,30,30,30
	dc.b 30,30,30,30,29,29,28,28,27,27,26,26,25,25,24,24,23,23,22,22,21,21,20,20,19,19,18,18,17,17,16,16
	dc.b 15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0

liste128color
	dc.b 0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7
	dc.b 8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15
	dc.b 16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23,23
	dc.b 24,24,24,24,25,25,25,25,26,26,26,26,27,27,27,27,28,28,28,28,29,29,29,29
liste128colore
	dc.b 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7
	dc.b 8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
	dc.b 16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23,23
	dc.b 24,24,24,25,25,25,26,26,26,27,27,27,28,28,28,28,28,29,29,29,29,29,29,29
	
	DC.B 30,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

	;dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	;dc.b 31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
		TEXT
makec2ptable
	lea liste128color,a0 ; une couleur = un octet entre 0 et 31  128 octet qui represente le c2p
	; a2 = ram page de 64k
	; 
	lea c2phalftone,a1
	
	;move.l #-1,d0
	move.l #$F0F0F0F0,d0
	;move.l #$0F0F0F0F,d1
;mask4bit 	dc.l $F0F0F0F0
;			dc.l $0F0F0F0F
			
;mask2bit	dc.l $C0C0C0C0
;			dc.l $30303030
;			dc.l $0C0C0C0C
;			dc.l $03030303


	move.l d0,d1
	not.l d1
	
	moveq #0,d2
	moveq #127,d7
.loop0
	moveq #0,d4
	move.b (a0,d2),d4
;	ext.w d4
	add d4,d4
	add d4,d4
	move.l (a1,d4),d5 		;c2p premier mot
	and.l d0,d5

	moveq #0,d3
.loop
	moveq #0,d4
	move.b (a0,d3.w),d4
;	ext.w d4
	add d4,d4
	add d4,d4
	move.l (a1,d4.w),d6
	and.l d1,d6
	or.l d5,d6					; d5 n'est pas modifié dans la .loop
	move.l d6,(a2)+
	addq.w #1,d3
	and.w d7,d3
	tst d3
	bne.s .loop
	clr.l d3
	addq.w #1,d2
	and.w d7,d2
	tst d2
	bne.s .loop0
	rts
	
makec2ptable1pix
	lea c2ptable0,a1
	lea c2pcolor1pix,a0
	move.l #$80808080,d0
	move.l #$40404040,d1
	move.l c2ptableptr,a2
	
	moveq #0,d2
	moveq #127,d7
.loop0
	moveq #0,d4
	move.b (a0,d2),d4
;	ext.w d4
	add d4,d4
	add d4,d4
	move.l (a1,d4),d5 		;c2p premier mot
	and.l d0,d5

	moveq #0,d3
.loop
	moveq #0,d4
	move.b (a0,d3.w),d4
;	ext.w d4
	add d4,d4
	add d4,d4
	move.l (a1,d4.w),d6
	and.l d1,d6
	or.l d5,d6					; d5 n'est pas modifié dans la .loop
	move.l d6,(a2)+
	addq.w #1,d3
	and.w d7,d3
	tst d3
	bne.s .loop
	clr.l d3
	addq.w #1,d2
	and.w d7,d2
	tst d2
	bne.s .loop0
	
	move.l #$20202020,d0
	move.l #$10101010,d1
	move.l c2ptableptr,d2
	add.l #$10000,d2
	move.l d2,a2
	
	moveq #0,d2
	moveq #127,d7
.loop1
	moveq #0,d4
	move.b (a0,d2),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4),d5
	and.l d0,d5
	
	moveq #0,d3
.loop1b
	moveq #0,d4
	move.b (a0,d3.w),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4.w),d6
	and.l d1,d6
	or.l d5,d6
	move.l d6,(a2)+
	and.w d7,d3
	tst d3
	bne.s .loop1b
	addq #1,d2
	and.w d7,d2
	tst d2
	bne.s .loop1
	
	
	move.l #$08080808,d0
	move.l #$04040404,d1
	move.l c2ptableptr,d2
	add.l #$20000,d2
	move.l d2,a2
	
	moveq #0,d2
	moveq #127,d7
.loop2
	moveq #0,d4
	move.b (a0,d2),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4),d5
	and.l d0,d5
	
	moveq #0,d3
.loop2b
	moveq #0,d4
	move.b (a0,d3.w),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4.w),d6
	and.l d1,d6
	or.l d5,d6
	move.l d6,(a2)+
	and.w d7,d3
	tst d3
	bne.s .loop2b
	addq #1,d2
	and.w d7,d2
	tst d2
	bne.s .loop2
	
	
	move.l #$02020202,d0
	move.l #$01010101,d1
	move.l c2ptableptr,d2
	add.l #$30000,d2
	move.l d2,a2
	
	moveq #0,d2
	moveq #127,d7
.loop3
	moveq #0,d4
	move.b (a0,d2),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4),d5
	and.l d0,d5
	
	moveq #0,d3
.loop3b
	moveq #0,d4
	move.b (a0,d3.w),d4
	add d4,d4
	add d4,d4
	move.l (a1,d4.w),d6
	and.l d1,d6
	or.l d5,d6
	move.l d6,(a2)+
	and.w d7,d3
	tst d3
	bne.s .loop3b
	addq #1,d2
	and.w d7,d2
	tst d2
	bne.s .loop3	
	rts
		
createsintabspecial
; a0 ram
; a1 sinustable octet
; d1 nombre d'element de la table
; d0 = pas interne

	;move d1,d2
	;ext.l d2
	;add.l d2,d2
	;add.l d2,d2
	;lea (a0,d2.l),a2				; a0 = refsintable adresse 4*nombre d'element
	lea addd0d2,a5
	lea tempSinref,a2
									; a2 = datasin
	lea buffer2octet,a6						
	lea tabflag,a3
	move d1,d2
	subq #1,d2
.1	clr.b (a3)+
	dbf d2,.1
	moveq #0,d2		; angle courant
	lea tabflag,a3
.while
	tst.b (a3,d2)
	bne.s .flaga1
.flaga0
	st.b (a3,d2)
	move d2,d3
	add d3,d3
	add d3,d3
	move.l a0,(a2,d3)
	move.b (a1,d2),d3
	move.b d3,(a6)
	move.w (a6),d3
	jsr (a5)
	move.b (a1,d2),d3
	add.b d3,d3
	add.w d3,d3
	move.w d3,(a0)+
	jsr (a5)  			;bsr addd0d2
	bra.s .while
.flaga1
	move.w d2,-(sp)
	moveq #39,d4		; 80 valeur = 40 word on reste sur des adresse paire
.looprept
	move.b (a1,d2),d3
	;lsl.w #8,d3
	move.b d3,(a6)
	move.w (a6),d3
	jsr (a5)			;bsr addd0d2
	move.b (a1,d2),d3
	add.b d3,d3
	add.w d3,d3
	move.w d3,(a0)+
	jsr (a5)			;bsr addd0d2
	dbf d4,.looprept
	
	move.w (sp)+,d2
	addq #1,d2
	tst.b (a3,d2)
	beq.s .flaga0
	rts
addd0d2
	add d0,d2
	cmp.w d1,d2
	bmi.s .1
	sub.w d1,d2
.1 	rts
buffer2octet	dc.w 0
createbufferadresse
; meme principe que createsintabspecial
; a2 ram adresse calculé d'apres a0
; a0 =efadresse a0 +4*d1 = ram valeur pioché dans a1 = a2
; a1 tempsinref
; d1 nombre d'element de la table
; d0 = pas interne


	move.w d1,d2
	add d2,d2
	add d2,d2
	lea (a0,d2),a2
	lea addd0d2,a6
	lea tempSinref,a1

	lea tabflag,a3
	move d1,d2
	subq #1,d2
.1	clr.b (a3)+
	dbf d2,.1
	moveq #0,d2		; angle courant
	lea tabflag,a3
.while
	tst.b (a3,d2)
	bne.s .flaga1
.flaga0
	st.b (a3,d2)
	move d2,d3
	add d3,d3
	add d3,d3
	move.l a2,(a0,d3)
	move.l (a1,d3),d7
	move.l d7,(a2)+
	jsr (a6)
	bra.s .while
.flaga1
	move.w d2,-(sp)
	move.w #_NBlignes-1,d4		; 80 valeur = 40 word on reste sur des adresse paire
.looprept
	move.w d2,d3
	add d3,d3
	add d3,d3
	
	move.l (a1,d3),d7
	move.l d7,(a2)+
	
	jsr (a6)		;bsr addd0d2
	dbf d4,.looprept
	
	move.w (sp)+,d2
	addq #1,d2
	tst.b (a3,d2)
	beq.s .flaga0
	; a0 n'a pas bougé depuis le debut, ca represente la ram libre
	; donc 
	move.l a2,a0
	; on modifie a0 pour le metre a la fin
	rts

preparequartersin
	lea quartsin1540,a0
	lea sin1540,a1
	lea 1540/4*2*2(a1),a2
	move.l a2,a3
	lea 1540/4*2*2(a3),a4
	move.w #$8000,d7
	move.w #1540/4-1,d6
	bsr .routine
	
	lea quartsin512,a0
	lea sin512,a1
	lea 512/4*2*2(a1),a2
	move.l a2,a3
	lea 512/4*2*2(a3),a4
	move.w #512/4-1,d6
	;bra .routine
	
.routine:
.loop1
	move.w (a0)+,d0
	move.w d0,d1
	add d7,d0
	move.w d0,(a1)+
	move.w d0,-(a2)
	move.w d7,d2
	sub.w d1,d2
	
	move.w d2,(a3)+
	move.w d2,-(a4)
	dbf d6,.loop1
	rts
	
	
prepsinAsinBsinC
	jsr preparequartersin
	moveq #0,d0
	
	lea sin512,a0
	lea sinA,a1
	move.w #511,d1
.cpy
	moveq #0,d0
	move.w (a0)+,d0
	mulu #42,d0			16+6	; diametre sur table 512 
	swap d0
	move.b d0,(a1)+
	dbf d1,.cpy
	
	move.w #1540-1,d1
	lea sin1540,a0
	lea sinB,a1
	lea sinC,a2
.cpy2
	moveq #0,d0
	moveq #0,d2
	move.w (a0)+,d0
	move.w d0,d2
	mulu #42-16,d0						; diametre sur table 1540
	mulu #42+16,d2					; diametre sur table 1540
	swap d0
	swap d2
	move.b D0,(a1)+
	move.b d2,(a2)+
	dbf d1,.cpy2

	rts
;;createsintabspecial
;;;; a0 ram
;;;; a1 sinustable octet
;;;; d1 nombre d'element de la table
;;;; d0 = pas interne
initfx2	
	lea ramsinus,a0
	lea sinA,a1
	move.w #512,d1
_ad1
	move.w #9+4,d0
	;move.l a0,sinrefA
	jsr createsintabspecial
	move.w #512,d1
_ad2
	move.w #511-18-9+1,d0
	move.l a0,adrrefA
	jsr createbufferadresse
	
	lea sinB,a1
	move.w #1540,d1
_ad3
	move.w #8*3,d0
	;move.l a0,sinrefB
	jsr createsintabspecial
	move.w #1540,d1
_ad4
	move.w #1540-22*3,d0
	move.l a0,adrrefB
	jsr createbufferadresse
	
	lea sinC,a1
	move.w #1540,d1
_ad5
	move.w #16,d0
	;move.l a0,sinrefC
	jsr createsintabspecial
	move.w #1540,d1
_ad6
	move.w #11,d0
	move.l a0,adrrefC
	jsr createbufferadresse
	rts

;  d0=+2
; d1=+1
;d2=-1
;d3=-2
;d4=10
;d5à-10
;d6 20
;d7 -20


;8+8




		DATA

quartsin1540
	dc.w 66,200,334,467,601,735,868,1002			;66=132/2,+134,+134,+133,+134,134,134,133,134
	dc.w 1136,1269,1403,1536,1670,1803,1937,2070	;134,133
	dc.w 2204,2337,2470,2604,2737,2870,3003,3136
	dc.w 3269,3402,3535,3668,3801,3934,4067,4199
	dc.w 4332,4464,4597,4729,4861,4993,5125,5257
	dc.w 5389,5521,5653,5784,5916,6047,6179,6310
	dc.w 6441,6572,6703,6834,6965,7095,7226,7356
	dc.w 7486,7616,7746,7876,8006,8135,8265,8394
	dc.w 8523,8652,8781,8910,9038,9167,9295,9423
	dc.w 9551,9679,9807,9934,10061,10189,10316,10442
	dc.w 10569,10695,10822,10948,11074,11199,11325,11450
	dc.w 11576,11701,11825,11950,12074,12198,12322,12446
	dc.w 12570,12693,12816,12939,13062,13184,13307,13429
	dc.w 13551,13672,13794,13915,14036,14156,14277,14397
	dc.w 14517,14637,14756,14875,14994,15113,15232,15350
	dc.w 15468,15586,15703,15820,15937,16054,16170,16286
	dc.w 16402,16518,16633,16748,16863,16978,17092,17206
	dc.w 17319,17433,17546,17658,17771,17883,17995,18106
	dc.w 18218,18329,18439,18550,18660,18770,18879,18988
	dc.w 19097,19205,19313,19421,19529,19636,19743,19849
	dc.w 19956,20061,20167,20272,20377,20482,20586,20690
	dc.w 20793,20896,20999,21102,21204,21305,21407,21508
	dc.w 21608,21709,21809,21908,22008,22106,22205,22303
	dc.w 22401,22498,22595,22692,22788,22884,22979,23075
	dc.w 23169,23264,23358,23451,23544,23637,23729,23821
	dc.w 23913,24004,24095,24185,24275,24365,24454,24543
	dc.w 24631,24719,24807,24894,24981,25067,25153,25238
	dc.w 25323,25408,25492,25576,25659,25742,25825,25907
	dc.w 25989,26070,26150,26231,26311,26390,26469,26548
	dc.w 26626,26704,26781,26858,26934,27010,27085,27160
	dc.w 27235,27309,27383,27456,27529,27601,27673,27744
	dc.w 27815,27885,27955,28025,28094,28163,28231,28298
	dc.w 28365,28432,28498,28564,28629,28694,28758,28822
	dc.w 28886,28948,29011,29073,29134,29195,29256,29316
	dc.w 29375,29434,29492,29550,29608,29665,29722,29778
	dc.w 29833,29888,29943,29997,30050,30103,30156,30208
	dc.w 30259,30310,30361,30411,30461,30510,30558,30606
	dc.w 30654,30701,30747,30793,30838,30883,30928,30972
	dc.w 31015,31058,31100,31142,31183,31224,31264,31304
	dc.w 31343,31382,31420,31458,31495,31532,31568,31603
	dc.w 31638,31673,31707,31740,31773,31806,31838,31869
	dc.w 31900,31930,31960,31989,32018,32046,32073,32101
	dc.w 32127,32153,32179,32204,32228,32252,32275,32298
	dc.w 32320,32342,32363,32384,32404,32423,32442,32461
	dc.w 32479,32496,32513,32529,32545,32560,32575,32589
	dc.w 32603,32616,32629,32641,32652,32663,32673,32683
	dc.w 32692,32701,32709,32717,32724,32730,32736,32742
	dc.w 32747,32751,32755,32758,32761,32763,32765,32766
	dc.w 32766
	
quartsin512
	dc.w 201,603,1005,1406,1808,2209,2610,3011
	dc.w 3411,3811,4210,4608,5006,5403,5799,6195
	dc.w 6589,6982,7375,7766,8156,8545,8932,9319
	dc.w 9703,10087,10469,10849,11227,11604,11980,12353
	dc.w 12724,13094,13462,13827,14191,14552,14911,15268
	dc.w 15623,15975,16325,16672,17017,17360,17699,18036
	dc.w 18371,18702,19031,19357,19680,20000,20317,20631
	dc.w 20942,21249,21554,21855,22153,22448,22739,23027
	dc.w 23311,23592,23869,24143,24413,24679,24942,25201
	dc.w 25456,25707,25954,26198,26437,26673,26905,27132
	dc.w 27355,27575,27790,28001,28208,28410,28608,28802
	dc.w 28992,29177,29358,29534,29706,29873,30036,30195
	dc.w 30349,30498,30643,30783,30918,31049,31175,31297
	dc.w 31413,31525,31633,31735,31833,31926,32014,32097
	dc.w 32176,32249,32318,32382,32441,32495,32544,32588
	dc.w 32628,32662,32692,32717,32736,32751,32761,32766
	

anglex4	dc.w 10*4,220*4,330*4
sound	incbin '0103_4.SND'

	BSS

sin1540		ds.w 1540
sin512		ds.w 512
sinA		ds.b 512
sinB		ds.b 1540
sinC		ds.b 1540
tabflag		ds.b 1540
sinrefA		ds.l 1
sinrefB		ds.l 1
sinrefC		ds.l 1
adrrefA		ds.l 1
adrrefB		ds.l 1
adrrefC		ds.l 1
codegenere	ds.w 14*40+25+1		; 1 = rts
			ds.w 90			; pour etre sur de pas depasser :p
codegenmovem	ds.w 35*_NBlignes
zonevariable	ds.l 16
tempSinref	ds.l 1540
ptrscreen	ds.l 2
c2ptableptr	ds.l 1
c2phalftone		ds.l 30
ramsinus	ds.l 14600	; 128k is enough	deja pris, les sinref: 512*4 +1540*2*4=14368 octet
		
		ds.b 65536
c2ptable	ds.l 16384
		ds.l 16384
		ds.l 16384
		ds.l 16384		; 256kilo
screens	ds.l 8000
		ds.l 8000
		ds.l 16000
