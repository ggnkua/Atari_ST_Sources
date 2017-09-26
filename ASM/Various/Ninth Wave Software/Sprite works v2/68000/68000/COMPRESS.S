;
; Compress screen image into Degas Elite (&IFF) format.
;
; I first wrote this compressor in GFA, then after some tweeking
; converted into 68000. It's one of my favourite methods of
; writing code of this kind.
;
; 	~C:compress(l:source,l:destination)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	opt o+
	
main	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a0		; compress from
	move.l	64(a7),a2		; compress to
	lea	(a2),a4			
	lea	buffer(pc),a1		; compress buffer
	move	#199,d4			; 200 lines high
.lines	moveq	#3,d3			; 4 bit planes
.planes	lea	(a0),a3
	moveq	#19,d0			; 20 words width
.clp	move	(a3),(a1)+		; make a copy
	addq	#8,a3			
	dbf	d0,.clp
	bsr.s	compress		; compress the buffer
	addq	#2,a0
	dbf	d3,.planes		; next bit plane
	lea	152(a0),a0
	dbf	d4,.lines		; next line
	sub.l	a4,a2
	move.l	a2,d0			; return length in d0
	movem.l	(a7)+,d1-7/a0-6
	rts

compress				
	lea	buffer(pc),a1	; your on your own from here ....
	move.b	39(a1),d0	; only the BASIC comments are added
	addq	#1,d0
	move.b	d0,40(a1)
	move.b	d0,41(a1)
	moveq	#0,d7		; l=0
	
.repeat	move.b	(a1,d7),d0	; l1
	move.b	1(a1,d7),d1	; l2
	move.b	2(a1,d7),d2	; l3
	cmp.b	d0,d1
	bne.s	.else
	cmp.b	d0,d2
	bne.s	.else
	
	move	d7,d6		; a=l
.loop1	cmp.b	(a1,d6),d0
	bne.s	.exit1
	addq	#1,d6
	bra.s	.loop1
.exit1	move	#257,d1
	move	d6,d2
	sub	d7,d2		; a-l
	sub	d2,d1		; 257-(a-l)
	move.b	d1,(a2)+	; store length
	move.b	d0,(a2)+	; store byte
	move	d6,d7		; l=a
	bra.s	.fin?

.else	move	d7,d6		; a=l
.loop2	move.b	(a1,d6),d0	; m1
	move.b	1(a1,d6),d1	; m2
	move.b	2(a1,d6),d2	; m3
	cmp.b	#39,d6
	bgt.s	.exit2
	cmp.b	d0,d1
	bne.s	.inca
	cmp.b	d0,d2
	beq.s	.exit2
.inca	addq	#1,d6
	bra.s	.loop2
.exit2	move	d6,d1
	sub	d7,d1		; a-l
	subq	#1,d1		; (a-l)-1
	move.b	d1,(a2)+	; store length
	move	d7,d5
.strlp	move.b	(a1,d5),(a2)+
	addq	#1,d5
	cmp.b	d6,d5
	blt.s	.strlp
	move	d6,d7

.fin?	cmp.b	#39,d7
	ble.s	.repeat
	rts

buffer	ds.w	22

 