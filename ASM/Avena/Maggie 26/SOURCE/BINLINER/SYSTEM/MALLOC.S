;
;
;
;
; MALLOC.S
;
; code to handle memory allocation and deallocation
;

mal_buffer_size		equ	100		;max no of mallocs

;-----------------------------------------------------------------
			section	text
;-----------------------------------------------------------------
			rsreset

;-----------------------------------------------------------------
mal_init:
		lea	mal_buffer,a0
		moveq	#0,d0
		move.w	#mal_buffer_size-1,d1
.clr:		move.l	d0,(a0)+
		dbf	d1,.clr
		rts

mal_deinit:
		lea	mal_buffer,a6
		move.w	#mal_buffer_size-1,d7
.clr:		move.l	(a6)+,d0
		beq.s	.skipit
		move.l	d0,a0
		bsr	mal_mfree_trap
.skipit:
		dbf	d7,.clr
		rts


;-----------------------------------------------------------------
; a0 = address to free
mal_mfree_trap:
		pea	(a0)
		move.w	#$49,-(a7)		;gemdos $49, mfree
		trap	#1
		addq.l	#6,a7
		tst.l	d0			;hmmm
		rts

;-----------------------------------------------------------------
; a0 = address to free
; OUT return d0 if OK
mal_mfree:
		movem.l	d1-d7/a0-a6,-(a7)
		move.l	a0,d1
		lea	mal_buffer,a6
		move.w	#mal_buffer_size-1,d7
.clr:		move.l	(a6)+,d0
		cmp.l	d1,d0
		beq.s	.doit
		dbf	d7,.clr
		moveq	#-1,d0
.ret		movem.l	(a7)+,d1-d7/a0-a6
		rts
.doit:
		bsr	mal_mfree_trap
		clr.l	-4(a6)			;mark as freed
		bra.s	.ret

;-----------------------------------------------------------------
; mal_malloc
; IN  d0 = length of buffer to reserve
; OUT d0 = >0 address of buffer if success, d0<0 if failure
; KILLS a0,d0

mal_malloc:
		movem.l	d1-d7/a1-a6,-(a7)
		move.l	d0,d7
		bsr	mal_find_slot
		tst.l	d0
		bmi.s	.fail

		move.l	d7,d0
		move.l	d0,-(a7)
		move.w	#$48,-(a7)	;gemdos $48, malloc
		trap	#1
		addq.l	#6,a7
		tst.l	d0
		bmi.s	.fail

		move.l	d0,(a6)		;store in list
		movem.l	(a7)+,d1-d7/a1-a6
		rts

.fail		moveq	#-1,d0		;doh!
		movem.l	(a7)+,d1-d7/a1-a6
		rts



;-----------------------------------------------------------------
; IN nothing
; OUT d0 = 0 if OK, a6 = address
;     d1 = -1 if fails
; KILLS a6,d0
mal_find_slot:
		lea	mal_buffer,a6
.loop:		tst.l	(a6)+
		bmi.s	.fail
		bne.s	.loop
		subq.l	#4,a6
		moveq	#0,d0
		rts
.fail:		moveq	#-1,d0
		rts


;-----------------------------------------------------------------
mal_buffer		ds.l	mal_buffer_size
			dc.l	-1
;-----------------------------------------------------------------
			section	text
