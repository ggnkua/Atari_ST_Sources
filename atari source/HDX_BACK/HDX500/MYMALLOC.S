;    char*
;    mymalloc(size)
;    int size;
;
;    returns whatever malloc() returns.
;
.globl	_malloc
_mymalloc::	move.w	sr, d0		; Get status
		btst	#$d, d0		; In supervisor mode?
		beq.s	USER		; No, go to USER
		
		; Yes, we are in supervisor mode.
		; move SSP to old USP
		; malloc, then move it back
		move.w	4(sp), d0	; Get arguement to malloc
		move.l	a5, -(sp)	; save a5
		move.l	sp, a5		; save current stack pointer
		move.l	usp, sp		; user's stack becomes current
		move.w  d0, -(sp)	; size to be allocated
		jsr	_malloc		; malloc it
		move.l	a5, sp		; restore saved stack pointer
		move.l  (sp)+, a5	; restore a5
		rts			; return in d0

USER:		jmp	_malloc		; just malloc it
