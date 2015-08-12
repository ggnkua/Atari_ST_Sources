
	EXPORT MEM, IOM
	EXPORT get_mrosversion

MEM:
	move.l	(sp)+,savmemp		; save caller's return address
	trap	#8					; call trap
	move.l	savmemp(pc),-(sp)	; restore return address
	rts
savmemp:
	dc.l	0

IOM:
	move.l	(sp)+,saviomp
	trap	#10
	move.l	saviomp(pc),-(sp)
	rts
saviomp:
	dc.l	0

; LONG get_mrosversion(BYTE *string);

get_mrosversion:
	movem.l	d7/a5,-(sp)
	move.l	a0,a5
	clr.l	-(sp)
	move.w	#$20,-(sp)	; super
	trap	#1
	lea		6(sp),sp
	
	move.l	#-1,d7			; prepare return value
	move.l	$a0,a0			; trap #8
	move.l	-(a0),d7
	cmp.l	#$b0aeb31f,d7	; magic no
	bne		notfound
	move.l	-(a0),d7		; version
	lea		-12(a0),a0
	move.l	(a0)+,(a5)+		; copy string
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
notfound:
	move.l	d0,-(sp)
	move.w	#$20,-(sp)	; super
	trap	#1
	lea		6(sp),sp
	move.l	d7,d0
	movem.l	(sp)+,d7/a5
	rts
