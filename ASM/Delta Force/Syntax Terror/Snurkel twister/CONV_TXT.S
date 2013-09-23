;convert ascii to small-scroller
; Snurkel-Twister
; (C) by New Mode

convert:
	lea	source(pc),a0
	lea	dest(pc),a1
	lea	contab(pc),a2
prepare:
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	convende
	cmp.b	#$0a,d0
	beq.s	prepare
	cmp.b	#$0d,d0
	beq.s	prepare
	move.b  0(a2,d0.w),(a1)+
	bra.s   prepare
convende:
	move.b  #-1,(a1)+
	move.l	a1,d7
	sub.l	#dest,d7	; Length in Bytes
	
	clr.w	-(a7)
	pea	out_file(pc)
	move.w	#$3c,-(a7)	; F-Create
	trap	#1
	addq.l	#8,a7
	move.w	d0,-(a7)
	pea	dest(pc)
	move.l	d7,-(a7)
	move.w	d0,-(a7)
	move.w	#$40,-(a7)	; F-Write
	trap	#1
	lea	12(a7),a7
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7		; F-Close
	
	clr.w	-(a7)
	trap	#1
	
	
contab: dcb.b 33,38	; 0-32
	dc.b 44,42,38,$df,38,38,42,40,41,38,38,39,43,37,38 ; Sonder
	dc.b 26,27,28,29,30,31,32,33,34,35 ; 0-9
	dc.b 36,39,38,38,38,45,38	; Sonder
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; A-Z
	dcb.b 6,38
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; a-z
	dcb.b 133,38
	even	 

source:	INCBIN text.txt
	EVEN
source_end:
textlen EQU source_end-source

dest:	ds.b textlen+100	; 100 Bytes more 
	EVEN
out_file:
	dc.b "text.img",0
	EVEN