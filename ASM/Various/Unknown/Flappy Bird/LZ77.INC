
;LZ77 compression

ENABLELZ77CHECKSUM = 0						;Set to 1 to test simple checksum after uncompress

	SECTION	TEXT

;----------------------------------
;Uncompress LZ77 data, a0.l as compressed data, a1.l as uncompressed buffer
;Corrupt d0-d4/a0-a2
lz77uncompress
	IFGT ENABLELZ77CHECKSUM
	move.l	a0,-(sp)						;Store a0/a1 as need later for checksum
	move.l	a1,-(sp)
	ENDC

	move.l	(a0)+,d0						;Read uncompressed byte total and checksum
	and.l	#$00ffffff,d0					;Mask out checksum
.loop
	move.b	(a0)+,d1						;Read flag bit-mask
	
	moveq.w	#8-1,d2							;Loop on each flag bit
.loopflags
	lsl.b	#1,d1							;Move upper bit into carry
	bcc.s	.copybyte						;If carry is clear copy byte, else copy string
.copystring
	moveq.l	#0,d3
	move.b	(a0)+,d3						;Read offset and length to d3
	move.l	d3,d4							;Copy to d4
	and.b	#$f0,d3							;Mask 12-bit offset
	lsl.w	#4,d3
	move.b	(a0)+,d3						;Combine with lower 8-bits of offset
	neg.w	d3
	lea		-1(a1,d3.w),a2					;Set a2 as dst-offset-1 to copy from
	and.w	#$f,d4							;Mask and get length+3
	addq.w	#3,d4
	sub.l	d4,d0							;Decrement total bytes
	add.w	d4,d4							;Get length as word-offset
	neg.w	d4
	jmp		.endcopystring(pc,d4.w)			;Jump ahead into unrolled loop
	move.b	(a2)+,(a1)+						;Copy previous string bytes
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
.endcopystring
	tst.l	d0
	ble.s	.done							;Have uncompressed all bytes?
	dbra.w	d2,.loopflags
	bra.s	.loop	
.copybyte
	move.b	(a0)+,(a1)+						;Copy single byte
	subq.l	#1,d0							;Decrement total bytes
	ble.s	.done							;Have uncompressed all bytes?
	dbra.w	d2,.loopflags
	bra.s	.loop
.done

	IFGT ENABLELZ77CHECKSUM
	tst.l	d0								:Check how many we uncompressed
	bne		errorlz77sizemismatch			;Error if uncompress too many bytes
	move.l	(sp)+,a1						;Restore pointers
	move.l	(sp)+,a0
	bsr		lz77testchecksum				;Test checksum
	ENDC
	rts

;----------------------------------
;Test LZ77 checksum, a0.l as compressed data, a1.l as uncompressed buffer
lz77testchecksum
	IFGT ENABLELZ77CHECKSUM
	move.l	(a0),d0							;Read uncompressed byte total and checksum
	move.l	d0,d1
	and.l	#$00ffffff,d0					;Mask d0 as total bytes
	rol.l	#8,d1
	and.l	#$ff,d1							;Get d1 as source checksum byte
	
	moveq.b	#0,d2							;d2 as uncompressed checksum
.loop
	add.b	(a1)+,d2						;Add to checksum
	subq.l	#1,d0							;Decrement total bytes
	bgt.s	.loop							;Have checked all bytes?
	
	cmp.b	d2,d1							;Compare final checksum values
	bne		errorlz77checksumfail			;Error if different
	ENDC
	rts
