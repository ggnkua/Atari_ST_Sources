createContigustable
;
; a0 = ram
; d0 = nombre d'element de la table sinus
; d1 = pas interne
; d2 = nombre de copie de valeurs
; a3 = table de sinus d'amplitude final
;
; pendant le fonctionnement:
; constante  d3,d4,d5 = pas interne,*2,*4
;

; retour:
; a0 = ram
; a1 = adresse table de d0 adresses  reftable pris a partir de la ram
;  


	move.l a0,a1		; a1 = table refsin
	move.w d0,d3
	add.w d3,d3		; *2
	move.l a3,a4
	add d3,a4
	add.w d3,d3		; *4
	add.w d3,a0			; a0 =ram
	
	;; edit :   move.l a3,a4  bug!!!


	lea tempbuffer,a2
	move.w d0,d4
	lsr #2,d4
	moveq #0,d3
.clearFlag
	move.l d3,(a2)+
	dbf d4,.clearFlag	; +- 4 octet

	lea tempbuffer,a2
	move.l a2,a5
	add.w d0,a5
	add.w d0,a5			; a5 = fin tempbuffer


	;moveq #0,d5			; angle
	
	move.w d1,d3		; pas interne<>0
	move.w d3,d4
	add d4,d4			; pas interne*2
	move.w d4,d5
	add.w d5,d5			; pas interne*4
	neg.w d0
	move.w d0,.auto1+2			; nombre d'elements
	add.w d0,d0
	move.w d0,.auto2+2
	move.w d0,.auto2b+2
	add.w d0,d0
	move.w d0,.auto3+2
;----------------------------------------
.loop
	move.w (a3),d7
	tst.b (a2)
	bne.s .flaga1
	st.b (a2)
	move.l a0,(a1)		; on stoque l'adresse de la valeur dans table refsin
	move.w d7,(a0)+
	; on met a jour a3 avec le pas interne*2
	; on met a jour a2 avec le pas interne (flags)
	add.w d3,a2
	add.w d4,a3
	add.w d5,a1

	cmp.l a2,a5
	blt.s .loop
.auto1
	lea 0(a2),a2
.auto2
	lea 0(a3),a3
.auto3
	lea 0(a1),a1
	bra.s .loop
.flaga1
	move.w d2,d6		; nombre de copie
	subq.w #1,d6

	move.l a3,-(sp)
.cpy
	move.w d7,(a0)+
	add.w d4,a3
	cmp.l a3,a4
	blt.s .1
.auto2b
	lea 0(a3),a3

.1
	move.w (a3),d7
	dbf d6,.cpy
	move.l (sp)+,a3

	addq.w #1,a2
	addq.w #2,a3
	addq.w #4,a1
	tst.b (a2)
	bne.s .fin
	bra.s .loop
.fin
	rts	
	BSS

	even
tempbuffer
	ds.w 4096 ; max 8192 elements
	ds.l 1

