	;finds the RESET handler routine in Adebug and catches the RESET with it
	; the magic has changed for Adebug Pro
	;BRST
	;ADBG
	;RSET
	output	.ro

main:
	move.w	#'ET',d0
	lea	main(pc),a0
	cmp.l	#'CDEB',$fa0018
	bne.s	.l1
	lea	$fc0000,a0
.l1:
	move.l	a0,d1
	beq.s	.end
	cmp.w	-(a0),d0
	bne.s	.l1

	cmp.w	#'RS',-(a0)
	bne.s	.l1
	cmp.l	#'ADBG',-(a0)
	bne.s	.l1
	cmp.l	#'BRST',-(a0)
	bne.s	.l1

	lea	3*4(a0),a0
	move.l	a0,$42a.w
	move.l	#$31415926,$426.w
	moveq	#-1,d0
	rts
.end:
	moveq	#0,d0
	rts
