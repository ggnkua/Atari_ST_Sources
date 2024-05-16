; palette.s, the non equilibred version of palette transition (better appropriate for palette)
; in fact it's the debugged version, used with c2pla7b.s

lstorder
a equ 0
b equ 32
c equ 64
	dc.b a,b,c
	dc.b a,c,b
	dc.b b,a,c
	dc.b c,a,b
	dc.b b,c,a
	dc.b c,b,a
	dc.b 0
	even
red 	dc.w 0,$100,$200,$300,$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
green	dc.w 0,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
blue	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15



makemultipalette
; construit 6 palette a partir de la palette de base en changeant l'ordre des composante rvb

; a0 = palette de base		  format dc.b r,v,b,r,v,b,r,v,b etc
; a1 = ram 	contenant palette convertit en word $rvb
; d0 = nombre de couleur	 

	lea lstorder,a2
	move.l a0,a6
	moveq #5,d6
.mp
	move.w d0,d7
	subq #1,d7

	moveq #0,d3
	move.b (a2)+,d3
	lea red,a3
	move.l a3,a4
	move.l a3,a5
	add.w d3,a3

	move.b (a2)+,d3
	add.w d3,a4
	move.b (a2)+,d3
	add.w d3,a5

.loop	
	move.b (a0)+,d2		; composante
	ext.w d2
	add d2,d2
	move (a3,d2),d4
	move.b (a0)+,d2		; composante
	ext.w d2
	add d2,d2
	or (a4,d2),d4
	move.b (a0)+,d2		; composante
	ext.w d2
	add d2,d2
	or (a5,d2),d4

	move.w d4,(a1)+
	dbf d7,.loop	

	move.l a6,a0
	dbf d6,.mp

	rts
convRVBtoW
; a0 = liste r,v,b
; a1 = ram liste $rvb
; d0 = nombre de composante (r v b)
	lea red,a4		; red
	lea 32(a4),a5	; green
	lea 32(a5),a6	; blue

	move.w d0,d7
	subq #1,d7

	moveq #0,d3
.loop
	move.b (a0)+,d3		; red
	add d3,d3
	move.w (a4,d3),d4
	move.b (a0)+,d3
	add d3,d3
	or.w (a5,d3),d4
	move.b (a0)+,d3
	add d3,d3
	or.w (a6,d3),d4
	move.w d4,(a1)+
	dbf d7,.loop
	rts


convclassicpalette
; converti 16 couleur format dc.b r,v,b  en dc.w $rvb

; a0 = 16 couleur word  $rvb
; a1 = format dc.b r,v,b  , r,v,b  , r,v,b  , etc
;

	moveq #15,d0
.loop
	move.b (a0)+,d1		; rouge
	move.b (a0)+,d2		; $vb
	move.b d2,d3
	lsr.b #4,d2			; vert
	and.b #$F,d3		; bleu
	
	move.b d1,(a1)+
	move.b d2,(a1)+
	move.b d3,(a1)+
	dbf d0,.loop
	rts
convbetween2classicpalette
; convertit 2 palette de 16 couleur format r,v,b en 16 palettes
; intermediaire de palette1 a palette2
; idem au format dc.b r,v,b
; NOTE:  format STF


; a0 = format r,v,b, r,b,v,r,b,v,etc depart
; a1 = idem arrivé
; a2 = 16* r,v,b de depart a arrivé 


	
	moveq #3*16-1,d0
.loop

	move.b (a1)+,d2
	move.b (a0)+,d1
	move.b d1,d3		; valeur de depart
	sub.b d1,d2
	add.b d2,d2
	moveq #1,d6
	ext.w d2
	bpl.s .ok
	neg.w d2
	move.w #-1,d6
.ok
	moveq #15,d7
.0
	move.w #30,d4
	move.w #0,d5    ;-15 here it was move.w #-15,d5 whitch was the equilibred version but false method for palette
					; it's the only change i done
	bra.s .2
.1	lea 16*3(a2),a2
.2	move.b d1,(a2)
	add.b d2,d5
	dbge d7,.1
	tst.w d7
	bmi.s .fin
	sub.b d4,d5
	add.b d6,d1
	dbf d7,.1
.fin
	lea -15*3*16+1(a2),a2
	
	dbf d0,.loop
	
	rts
couleurste015		dc.b 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
couleur015ste		dc.b 0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15
convbetween2classicpaletteSTE
; convertit 2 palette de 16 couleur format r,v,b en 16 palettes
; intermediaire de palette1 a palette2
; idem au format dc.b r,v,b
; NOTE:  format ST E


; a0 = format r,v,b, r,b,v,r,b,v,etc depart
; a1 = idem arrivé
; a2 = 16* r,v,b de depart a arrivé 

	lea couleurste015,a3
	lea couleur015ste,a4
	
	
	move.l a2,-(sp)
	
	moveq #0,d2
	moveq #0,d1
	
	moveq #3*16-1,d0
.loop

	move.b (a1)+,d2
	move.b (a3,d2),d2		; conv palste to 0..15
	move.b (a0)+,d1
	move.b (a3,d1),d1
	
	move.b d1,d3		; valeur de depart
	sub.b d1,d2
	add.b d2,d2
	moveq #1,d6
	ext.w d2
	bpl.s .ok
	neg.w d2
	move.w #-1,d6
.ok
	moveq #15,d7
.0
	move.w #30,d4
	move.w #-15,d5
	bra.s .2
.1	lea 16*3(a2),a2
.2
	move.b d1,(a2)
;	move.b (a4,d1),d1
;	move.b d1,(a2)
;	move.b (a3,d1),d1
	

	add.b d2,d5
	dbge d7,.1
	tst.w d7
	bmi.s .fin
	sub.b d4,d5
	add.b d6,d1
	dbf d7,.1
.fin
	lea -15*3*16+1(a2),a2
	
	dbf d0,.loop
	move.l (sp)+,a2
	; converti tout les composante en ste
	move.w #3*16*16-1,d0
	moveq #0,d1
	
.loop2
	move.b (a2),d1
	move.b (a4,d1.w),d1
	move.b d1,(a2)+
	dbf d0,.loop2
	
	
	rts

convbetween2pal
; a0 = palette type $rvb
; a1 = palette type $rvb
; a2 = ram resultat 16*$rvb

	movem.l a0-a2,-(sp)
	
	;move.l a0,a0
	lea tempbuffer1,a1
	jsr convclassicpalette
	movem.l (sp)+,a0-a2
	move.l a1,a0
	lea tempbuffer2,a1
	move.l a2,-(sp)
	jsr convclassicpalette
	lea tempbuffer1,a0    16*3
	lea tempbuffer2,a1    16*3
	lea tempbuffer3,a2    16* 16*3
	jsr convbetween2classicpalette
	
	move.l (sp)+,a1		     ; ram resultat 16*$rvb
	move.w #16*16,d0		; 16 palette de 16 triplet (r,v,b)
	lea tempbuffer3,a0
	jsr convRVBtoW
	
	rts

convbetween2palSTE
; a0 = palette type $rvb
; a1 = palette type $rvb
; a2 = ram resultat 16*$rvb

	movem.l a0-a2,-(sp)
	
	;move.l a0,a0
	lea tempbuffer1,a1
	jsr convclassicpalette
	movem.l (sp)+,a0-a2
	move.l a1,a0
	lea tempbuffer2,a1
	move.l a2,-(sp)
	jsr convclassicpalette
	lea tempbuffer1,a0    16*3
	lea tempbuffer2,a1    16*3
	lea tempbuffer3,a2    16* 16*3
	jsr convbetween2classicpaletteSTE
	
	move.l (sp)+,a1		     ; ram resultat 16*$rvb
	move.w #16*16,d0		; 16 palette de 16 triplet (r,v,b)
	lea tempbuffer3,a0
	jsr convRVBtoW
	
	rts
		
	BSS
tempbuffer1	ds.b 16*3
tempbuffer2	ds.b 16*3
tempbuffer3	ds.b 16*16*3
