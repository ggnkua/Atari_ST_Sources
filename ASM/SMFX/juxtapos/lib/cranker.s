
;	raw LZO Decruncher for MC68000
;	2008, 2010, 2015 by bifat/tek
;
;	Note that the cruncher produces a 4 byte header, $b0 followed by the
;	24bit length of the decrunched data. Strip off or skip these first
;	four bytes from the crunched data when passing them to this routine.
;
;	In-place decrunching: Align the crunched data to the end of the
;	destination area PLUS overhead.
;	 _________________________________________________
;	|                   |                           : |
;	|    destination    |       crunched data       : |
;	|___________________|___________________________:_|
;	^-- destptr (a1)    ^-- srcptr (a0)              ^- overhead
;

		; a0	inp
		; a1	outp

cranker:
lzodecrunch:
		addq.l	#4,a0
		movem.l	d2-d6/a2-a3,-(a7)

		moveq	#0,d3
		st	d3		; 000000ff
		moveq	#15,d4
		moveq	#3,d5
		moveq	#63,d6
		lea		$4000.w,a3
		
		moveq	#0,d0
		moveq	#0,d1
		moveq	#17,d2
		
		move.b	(a0)+,d1
		cmp.w	d2,d1
		ble.b	.loop2
		
		sub.w	d2,d1
		cmp.w	#4,d1
		blt.b	.match_next

		subq.w	#1,d1
.cop1
		move.b	(a0)+,(a1)+		; data
		dbf	d1,.cop1
		bra.b	.litrun
.zup
		tst.w	d1
		bne.b	.no0

		moveq	#15,d1
		move.b	(a0)+,d2
		bne.b	.ok1
.lop1	
		add.w	d3,d1
		move.b	(a0)+,d2
		beq.b	.lop1
.ok1
		add.w	d2,d1
.no0
		; copy d1+3 bytes
		moveq	#7,d0			; 4
		and.w	d1,d0			; 4
		neg.w	d0			; 4
		add.w	d0,d0			; 4
		lsr.w	#3,d1			; 10
		jmp	.copl(pc,d0.w)		; 14	=> 40
		move.b	(a0)+,(a1)+		; data
		move.b	(a0)+,(a1)+
.lop41
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
.copl
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+		; 12
		move.b	(a0)+,(a1)+
		dbf	d1,.lop41		; 10(14)
.litrun	
		moveq	#0,d1			; !!
		move.b	(a0)+,d1
		cmp.w	d4,d1
		bgt.b	.match

		lea	-$801(a1),a2
		move.w	d1,d0
		lsr.w	#2,d0
		sub.l	d0,a2
		move.b	(a0)+,d0
		lsl.w	#2,d0
		sub.l	d0,a2
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
.match_done
		and.w	d5,d1
		beq.b	.loop
.match_next
		move.b	(a0)+,(a1)+		; data
		subq.w	#1,d1
		bne.b	.match_next

		move.b	(a0)+,d1
		bra.b	.match
.loop
		move.b	(a0)+,d1
;	IFND FINAL
;		move.w	d1,$dff180
;	ENDC
.loop2
		cmp.w	d4,d1	; #15
		ble.b	.zup
.match
		cmp.w	d6,d1	; #63
		ble.b	.no1
		
		lea	-1(a1),a2
		moveq	#31,d0
		and.w	d1,d0
		lsr.w	#2,d0
		sub.l	d0,a2
		move.b	(a0)+,d0
		lsl.w	#3,d0
		sub.l	d0,a2
		move.w	d1,d2
		lsr.w	#5,d2
		subq.w	#1,d2
		bra.b	.copy_match
.no1
		moveq	#31,d2
		cmp.w	d2,d1
		ble.b	.no2

		and.w	d1,d2
		bne.b	.no11
		
		moveq	#31,d2
		move.b	(a0)+,d1
		bne.b	.ok2
.lop2
		add.w	d3,d2
		move.b	(a0)+,d1
		beq.b	.lop2
.ok2
		add.w	d1,d2
.no11
		lea	-1(a1),a2
		moveq	#0,d1
		move.b	(a0)+,d1
		move.w	d1,d0
		lsr.w	#2,d0
		sub.l	d0,a2
		move.b	(a0)+,d0
		lsl.w	#6,d0
		sub.l	d0,a2
.copy_match
		; copy d2+2 bytes:
		move.b	(a2)+,(a1)+
		
		moveq	#7,d0
		and.w	d2,d0
		neg.w	d0
		add.w	d0,d0
		lsr.w	#3,d2
		jmp	.copl2(pc,d0.w)
.lop42
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+
.copl2
		move.b	(a2)+,(a1)+
		dbf	d2,.lop42
		moveq	#0,d2
		bra	.match_done
.no2
		cmp.w	d4,d1
		ble.b	.no3

		move.l	a1,a2
		moveq	#8,d0
		and.w	d1,d0
		ror.w	#5,d0
		and.w	#$f800,d0
		sub.l	d0,a2
		moveq	#7,d2
		and.w	d1,d2
		bne.b	.no21

		move.b	(a0)+,d1
		bne.b	.ok3
.lop3
		add.w	d3,d2
		move.b	(a0)+,d1
		beq.b	.lop3
.ok3
		add.w	d1,d2
		addq.w	#7,d2
.no21
		moveq	#0,d1
		move.b	(a0)+,d1
		move.w	d1,d0
		lsr.w	#2,d0
		sub.l	d0,a2
		move.b	(a0)+,d0
		lsl.w	#6,d0
		sub.l	d0,a2
		cmp.l	a2,a1
		beq.b	.end

		sub.l	a3,a2
		bra.b	.copy_match
.no3
		lea		-1(a1),a2
		move.w	d1,d0
		lsr.w	#2,d0
		sub.l	d0,a2
		move.b	(a0)+,d0
		lsl.w	#2,d0
		sub.l	d0,a2
		move.b	(a2)+,(a1)+
		move.b	(a2),(a1)+
		bra		.match_done
.end	
		movem.l	(a7)+,d2-d6/a2-a3
		rts
