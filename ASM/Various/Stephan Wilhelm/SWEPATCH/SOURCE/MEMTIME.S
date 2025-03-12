; Speichertest-Timeout fÅr Atapi-Patch

		org $7fe60c00

		move.l	d0,-(sp)
		move.l	$5d2,d0		; timer-mem
		tst.l	d0
		bne.s	nonewtime
		move.l	$4ba,d0
		add.l	#$800,d0	; 4 sec to timeout
		move.l	d0,$5d2
nonewtime:	cmp.l	$4ba,d0
		bhi.s	nobreak
		move.l	(sp)+,d0
		clr.l	$5d2
timeout:	jmp	$7fe00aca
nobreak:	move.l	(sp)+,d0
		cmpa.w	#0,a5
		bne.s	jump
		jmp	$7fe009be
jump:		jmp	$7fe00a6e

