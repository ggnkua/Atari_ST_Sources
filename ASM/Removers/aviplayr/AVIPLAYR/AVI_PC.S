; changement de palette pour les fichier AVI


********************************************************************************
	TEXT
********************************************************************************
; a0 : buffer source
; a2 : adresse palette TC
palette_change:
	clr.w	d0
	move.b	(a0)+,d0
	lea	(a2,d0.w*2),a2
	move.b	(a0)+,d0
	addq.w	#2,a0
	subq.b	#1,d0
.loop_pc:
	move.b	(a0)+,d1	; Attention : format RVB normal
	move.b	(a0)+,d2	; (ils sont logiques chez Crimo$oft !!)
	move.b	(a0)+,d3	; R V B X ( 4 octets )
	addq.w	#1,a0		; Que l'on va convertir en True Color
	lsr.w	#3,d1
	lsr.w	#2,d2		
	lsr.w	#3,d3
	bfins	d1,d4{16:5}	; Eh oui, ces instructions existent !
	bfins	d2,d4{21:6}	; Dingue hein !!!
	bfins	d3,d4{27:5}
	move.w	d4,(a2)+
	dbf	d0,.loop_pc
	rts



