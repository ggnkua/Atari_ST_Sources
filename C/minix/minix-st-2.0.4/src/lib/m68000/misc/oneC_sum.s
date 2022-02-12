#
! u16_t oneC_sum(U16_t prev, void *data, size_t size)

.sect .text; .sect .rom; .sect .data; .sect .bss
.sect .text

	.define	_oneC_sum
	.globl	_oneC_sum

!	a0 = dptr
!	d0 = sum
!	d1 = temp
!	d2 = swap
!	d3 = temp
!	d4 = size, n
_oneC_sum:
	movem.l	d3/d4,-(sp)
#ifdef __NOLONGS__
	move.l	20(sp),d4	! d4 = size
	move.l	16(sp),a0	! a0 = data = dptr
	move.l	12(sp),d0	! d0 = prev = sum
#else
	move.w	18(sp),d4	! d4 = size
	move.l	14(sp),a0	! a0 = data = dptr
	move.l	#0,d0		! sweep reg
	move.w	12(sp),d0	! d0 = prev = sum
#endif /* __NOLONGS__ */

	move.l	#0,d3		! sweep reg (upper word will remain 0)
	move.l	#0,d1		! sweep reg

	move.w	a0,d2
	and.w	#1,d2		! swap = ((size_t) dptr & 1

	beq	I5		! if (swap) {
	rol.w	#8,d0	! sum =((sum & 0xff) << 8)|((sum & 0xff00) >> 8)
	tst.w	d4		! if (n > o) {
	bls	I9		! statt I5
	move.b	(a0)+,d3 ! ((u8_t *)&word)[0]=0; ((u8_t *)&word)[1] = *dptr++
	add.l	d3,d0		!		sum += (u32_t) word;
	sub.w	#1,d4		!		n-= 1
	bra	I5

II2:
	move.w	(a0)+,d3
	add.l	d3,d1		!               d1 = (u32_t) ((u16_t *) dptr[0]
	move.w	(a0)+,d3	!		 (u32_t) ((u16_t) *) dptr[1]
	add.l	d3,d1		!		d1 = +
	move.w	(a0)+,d3	!	 	 (u32_t) ((u16_t *) dptr)[2]
	add.l	d3,d1		!		d1 = +
	move.w	(a0)+,d3	!	 	 (u32_t) ((u16_t *) dptr)[3]
	add.l	d3,d1		!		d1 = +
	sub.w	#8,d4		!		n-= 8
I5:
	cmp.w	#8,d4		! while (n >= 8) {
	bcc	II2

	add.l	d1,d0		!		sum += ...
	bra	I7

II3:
	move.w	(a0)+,d3	!	 d0 = (u32_t) ((u16_t *) dptr)[0]
	add.l	d3,d0		!	sum+=
	sub.w	#2,d4		!	n-= 2
I7:
	cmp.w	#2,d4		! while (n >= 2) {
	bcc	II3

	tst.w	d4		! if (n > 0) {
	bls	I9
	move.b	(a0)+,d3	!	(u32_t) word = (*dptr++ << 8) + 0;
	lsl.w	#8,d3
	add.l	d3,d0		!	sum+=
I9:
	move.w	d0,d3		! d3 = sum & 0xffff
	move.w	#0,d0
	swap	d0		! d0 = (sum >> 16)
	add.l	d3,d0		! sum = (sum & 0xffff) + (sum >> 16)

	cmp.l	#0x0ffff,d0	! if (sum > 0xffff)
	bls	I10
	add.l	#1,d0		!	sum++;
I10:
	tst.w	d2		! if (swap) {
	beq	I11
	rol.w	#8,d0	! d0 = ((sum & 0xff) << 8)|((sum & 0xff00) >> 8)
I11:
	movem.l	(sp)+,d3/d4	! return d0 = sum
	rts
