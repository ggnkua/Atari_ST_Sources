	; A0 = Buffer in which to put the path
		text
get_curnt_path:	movem.l	d0/a0,-(sp)

		jsr	Dgetdrv			;Get current drive

		move.b	d0,(a0)+		;..
		move.b	#':',(a0)+		;Insert a colon..
		moveq	#0,d0			;Then get
		jsr	Dgetpath		;..the current path

	;Check if the last char in the path is a '\'. If not, append it
.check_end:	move.l	4(sp),a0
.get_end:	tst.b	(a0)+
		bne.s	.get_end
		cmp.b	#'\',-2(a0)
		beq.s	.oki
    		move.b	#'\',-1(a0)
    		clr.b	(a0)
.oki:		movem.l	(sp)+,d0/a0
		rts
