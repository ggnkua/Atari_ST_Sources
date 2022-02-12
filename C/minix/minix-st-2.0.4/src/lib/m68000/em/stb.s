#
! struct copy for ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
	.sect	.text

	.define	___stb
___stb:	move.w	4(sp),d0	! count
	beq	ret		! all done if zero
	movem.l	6(sp),a0-a1	! from and to
	bra	lpend		! jump into loop
loop:	move.b	(a0)+,(a1)+	! copy one byte
lpend:	dbra	d0,loop		! until d0 < 0
ret:	rts			! return (value?)
