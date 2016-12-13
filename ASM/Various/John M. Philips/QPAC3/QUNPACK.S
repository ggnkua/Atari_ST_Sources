	list	+
* QPAC : unpacker v2.1
	list	-

*--------------------------------------------------------------
* unpack file
* entry	a0=addr of packed file
*	a1=addr of unpacked file
* exit	d0=error code
*		0 = ok
*		1 = not a QPAC2 file
*		2 = checksum failed
*		3 = file overflowed
*	a0=start address
*	a1=end address
* note	self-contained, position independent

get_bit	macro
	add.l	d6,d6		get bit
	bne.s	.gb\@		if empty then
	move.l	(a0)+,d6	get next long
	eor.l	d6,d7		update checksum
	move.b	#%10000,ccr	get bit and set marker
	addx.l	d6,d6
.gb\@
	endm

unpack_file
	move.l	a1,a6
	lea	.head(pc),a2
	moveq	#4-1,d0
.valid	cmpm.l	(a0)+,(a2)+
	bne	.error1
	dbra	d0,.valid
	move.l	a1,a2		end of dest=dest+length of unpacked file
	add.l	(a0)+,a2
	move.l	(a0)+,d7	d7=checksum
	moveq	#0,d6		empty source
.loop	get_bit
	bcs	.com1xx
	get_bit
	bcs	.com01
.com00	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
.com00_loop
	get_bit			command %00nnn, insert 1..8 bytes
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	move.b	d0,(a1)+
	dbra	d2,.com00_loop
	cmp.l	a2,a1
	bcs	.loop
	bra	.done
.com01	moveq	#8-1,d1		command %01aaaaaaaa, copy 2 bytes
	moveq	#2-1,d2
	bra.s	.copy
.com1xx	get_bit
	bcs.s	.com11x
	get_bit
	bcs.s	.com101
.com100	moveq	#9-1,d1		command %100a..a, copy 3 bytes
	moveq	#3-1,d2
	bra.s	.copy
.com101	moveq	#10-1,d1	command %101a..a, copy 4 bytes
	moveq	#4-1,d2
	bra.s	.copy
.com11x	get_bit
	bcs.s	.com111
.com110	bsr.s	.get_byte	command %110n..na..a, copy 3..258 bytes
	addq.w	#3-1,d2
	moveq	#12-1,d1
.copy	moveq	#0,d0
.copy2	get_bit
	addx.w	d0,d0
	dbra	d1,.copy2
	lea	-1(a1),a3
	sub.w	d0,a3			copy from dest-offset-1
.copy3	move.b	(a3)+,(a1)+
	dbra	d2,.copy3
	cmp.l	a2,a1
	bcs	.loop
	bra.s	.done
.com111	bsr.s	.get_byte		command %111n..n, insert 9..264 bytes
	addq.w	#9-1,d2
	bra	.com00_loop
.done	bne.s	.error3
	move.l	a6,a0			start
	move.l	a2,a1			end
	move.l	d7,d0
	bne.s	.error2
	rts
.error1	moveq	#1,d0
	rts
.error2	moveq	#2,d0
	rts
.error3	moveq	#3,d0
	rts

.get_byte
	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	rts

.head	dc.b	'QPAC2-JMP(C)1989'
	even

*--------------------------------------------------------------

