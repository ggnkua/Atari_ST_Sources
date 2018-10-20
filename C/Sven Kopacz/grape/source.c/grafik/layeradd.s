; Kopiert eine Quellebene in die Bildschirmzielebene
;Eingabe:
;long dst_lines=Zielebenenh”he
;long dst_width=(Zielebenenbreite/6)
;long dst_2width=(Zielebenenbreite/2)
;Startadressen der Zielebenen:
;void *dst_red
;void *dst_blue
;void *dst_yellow

;Offset der am Ende einer Zeile auf die Quelladressen
;addiert werden muž: (=Quellbreite-Zielbreite)
;long src_offset
;Startadressen der Quellebenen
;(nicht die eigentliche Startadresse sondern die des ersten
; zu kopierenden Bytes)
;Unbenutzte fr lasierend auf Null setzen
;(fr deckend mssen alle gesetzt sein)
;void *src_red
;void *src_blue
;void *src_yellow

;Kopiermodus:
;int layeradd_mode=
;Bit 0 :	0=lasierend
;					1=deckend ohne weiž
;Bit 1 :	0=Normale Intensit„t
;					1=halbe Intensit„t

;Einsprung:
;void layer_add(void)

.EXPORT dst_lines, dst_width, dst_red, dst_blue, dst_yellow
.EXPORT dst_2width
.EXPORT src_offset, src_red, src_blue, src_yellow
.EXPORT layeradd_mode, layer_add



layer_add:
	btst	#0,layeradd_mode+1	;Nur Byte-Breite m”glich!
	bne		add_opaque

	btst	#1,layeradd_mode+1	;Halbe Intensit„t?
	bne		half_las						;Ja->
;lasierend addieren:
	movem.l	d0-d7/a0-a3,-(sp)

;Lasierend schreiben Makro
.MACRO	LAS_ADD dn
.LOCAL  n0
	cmp.b		(a1)+,dn
	bls			n0
	move.b	dn,-1(a1)
n0:
.ENDM

;Kopiermakro
.MACRO LAS_LOOP
.LOCAL l_yloop, l_xloop
l_yloop:
	move.l	dst_width,d1
l_xloop:
;6 Bytes einlesen
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	move.b	(a0)+,d6
	move.b	(a0)+,d7

	LAS_ADD d2
	LAS_ADD d3
	LAS_ADD d4
	LAS_ADD d5
	LAS_ADD d6
	LAS_ADD d7

	subq.l	#1,d1
	bne			l_xloop	
;end_red_x
	adda.l	a2,a0
	subq.l	#1,d0
	bne			l_yloop
;end_red_y
.ENDM

;Jetzt ausfhren:

	move.l	src_offset,a2

;Rot:
	tst.l		src_red
	beq			blue
	move.l	src_red,a0
	move.l	dst_red,a1
	move.l	dst_lines,d0
	LAS_LOOP
	
;Blau:
blue:
	tst.l		src_blue
	beq			yellow
	move.l	src_blue,a0
	move.l	dst_blue,a1
	move.l	dst_lines,d0
	LAS_LOOP

;Gelb:
yellow:
	tst.l		src_yellow
	beq			l_fin
	move.l	src_yellow,a0
	move.l	dst_yellow,a1
	move.l	dst_lines,d0
	LAS_LOOP

l_fin:
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;Fertig lasierend

;*
;*
;*
;Lasierend mit halber Intensit„t
half_las:
	movem.l	d0-d7/a0-a3,-(sp)

;Kopiermakro
.MACRO HLAS_LOOP
.LOCAL l_yloop, l_xloop
l_yloop:
	move.l	dst_width,d1
l_xloop:
;6 Bytes einlesen
	move.b	(a0)+,d2
	lsr.b		#1,d2
	move.b	(a0)+,d3
	lsr.b		#1,d3
	move.b	(a0)+,d4
	lsr.b		#1,d4
	move.b	(a0)+,d5
	lsr.b		#1,d5
	move.b	(a0)+,d6
	lsr.b		#1,d6
	move.b	(a0)+,d7
	lsr.b		#1,d7

	LAS_ADD d2
	LAS_ADD d3
	LAS_ADD d4
	LAS_ADD d5
	LAS_ADD d6
	LAS_ADD d7

	subq.l	#1,d1
	bne			l_xloop	
;end_red_x
	adda.l	a2,a0
	subq.l	#1,d0
	bne			l_yloop
;end_red_y
.ENDM

;Jetzt ausfhren:

	move.l	src_offset,a2

;Rot:
	tst.l		src_red
	beq			hblue
	move.l	src_red,a0
	move.l	dst_red,a1
	move.l	dst_lines,d0
	HLAS_LOOP
	
;Blau:
hblue:
	tst.l		src_blue
	beq			hyellow
	move.l	src_blue,a0
	move.l	dst_blue,a1
	move.l	dst_lines,d0
	HLAS_LOOP

;Gelb:
hyellow:
	tst.l		src_yellow
	beq			hl_fin
	move.l	src_yellow,a0
	move.l	dst_yellow,a1
	move.l	dst_lines,d0
	HLAS_LOOP

hl_fin:
	movem.l	(sp)+,d0-d7/a0-a3
	rts

;Fertig halb-lasierend


;*
;*
;*
; Deckend ohne weiž addieren

add_opaque:
	btst	#1,layeradd_mode+1	;Halbe Intensit„t?
	bne		half_opaque						;Ja->

	movem.l	d0-d7/a0-a6,-(sp)

	move.l	src_red,a0
	move.l	src_blue,a1
	move.l	src_yellow,a2
	move.l	dst_red,a3
	move.l	dst_blue,a4
	move.l	dst_yellow,a5
	move.l	src_offset,a6

	move.l	dst_lines,d0

o_yloop:
	move.l	dst_2width,d1
o_xloop:
;Je 2 Bytes einlesen
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	(a1)+,d4
	move.b	(a1)+,d5
	move.b	(a2)+,d6
	move.b	(a2)+,d7

	tst.b		d2
	bne			o_store
	tst.b		d4
	bne			o_store
	tst.b		d6
	beq			n_store
o_store:
	move.b	d2,(a3)
	move.b	d4,(a4)
	move.b	d6,(a5)

n_store:
	tst.b		d3
	bne			o2_store
	tst.b		d5
	bne			o2_store
	tst.b		d7
	beq			n2_store
o2_store:
	move.b	d3,1(a3)
	move.b	d5,1(a4)
	move.b	d7,1(a5)
n2_store:
	addq.l	#2,a3
	addq.l	#2,a4
	addq.l	#2,a5
	
	subq.l	#1,d1
	bne			o_xloop	
;end_o_x
	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	subq.l	#1,d0
	bne			o_yloop
;end_o_y

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;Fertig deckend


;*
;*
;*
; Deckend ohne weiž addieren, halbe Intensit„t

half_opaque:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	src_red,a0
	move.l	src_blue,a1
	move.l	src_yellow,a2
	move.l	dst_red,a3
	move.l	dst_blue,a4
	move.l	dst_yellow,a5
	move.l	src_offset,a6

	move.l	dst_lines,d0

ho_yloop:
	move.l	dst_2width,d1
ho_xloop:
;Je 2 Bytes einlesen
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	(a1)+,d4
	move.b	(a1)+,d5
	move.b	(a2)+,d6
	move.b	(a2)+,d7

	tst.b		d2
	bne			ho_store
	tst.b		d4
	bne			ho_store
	tst.b		d6
	beq			hn_store
ho_store:
	lsr.b		#1,d2
	move.b	d2,(a3)
	lsr.b		#1,d4
	move.b	d4,(a4)
	lsr.b		#1,d6
	move.b	d6,(a5)

hn_store:
	tst.b		d3
	bne			ho2_store
	tst.b		d5
	bne			ho2_store
	tst.b		d7
	beq			hn2_store
ho2_store:
	lsr.b		#1,d3
	move.b	d3,1(a3)
	lsr.b		#1,d5
	move.b	d5,1(a4)
	lsr.b		#1,d7
	move.b	d7,1(a5)
hn2_store:
	addq.l	#2,a3
	addq.l	#2,a4
	addq.l	#2,a5
	
	subq.l	#1,d1
	bne			ho_xloop	
;end_o_x
	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	subq.l	#1,d0
	bne			ho_yloop
;end_o_y

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;Fertig deckend



;Variablen:

dst_lines:
	.DS.L	1
dst_width:
	.DS.L	1
dst_2width:
	.DS.L 1
dst_red:
	.DS.L	1
dst_blue:
	.DS.L	1
dst_yellow:
	.DS.L	1

src_offset:
	.DS.L	1
src_red:
	.DS.L	1
src_blue:
	.DS.L	1
src_yellow:
	.DS.L	1

layeradd_mode:
	.DS.W	1