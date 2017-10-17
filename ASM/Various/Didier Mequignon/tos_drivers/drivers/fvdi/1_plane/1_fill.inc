/*-------------------------------------------------------*
 *    Draw in single plane modes                         *
 *-------------------------------------------------------*/

	.ifeq	shadow
mfdb_replace:
	.endc
	.ifne	shadow
shadow_replace:
	.endc
	move.l		a0,d3			// Too few registers available
//	move.l		4(a7),a0		// to get background colour efficiently
	move.l		(a7)+,a0		// to get background colour efficiently
	move.l		(a0),a0
	exg		a0,d3


	lsr.w		#4,d0
	beq		.single
	subq.w		#1,d0			// d0.w - number of 16 pixel blocks to blit

	moveq		#-1,d6
	lsr.w		d1,d6
	move.l		d6,d1
	swap		d1
	lsr.w		d2,d1
	not.w		d1

	move.l		d5,d2
	swap		d2

	swap		d0
.loop1:
	swap		d0
	move.l		a2,d7
	move.w		(a0,d5.w),d6
	and.w		d6,d7

	move.w		d3,d4
	not.w		d6
	and.w		d6,d4
	or.w		d4,d7

	move.w		d7,d6
	swap		d7
	move.w		d6,d7

	move.l		d1,d6
	swap		d6
	and.w		d6,d7
	not.w		d6

	RandorW

	swap		d7
	move.w		d0,d6			// Good idea?
	beq		.loop2_end
	subq.w		#1,d6
.loop2:
	nopW

	dbra		d6,.loop2
.loop2_end:

	move.w		d1,d6
	and.w		d6,d7
	not.w		d6		// Not needed before RandorW

	RandorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	swap		d0
	dbra		d0,.loop1

	moveq		#1,d0
	rts

.single:
	swap		d0
	moveq		#-1,d6
	lsr.w		d1,d6
	move.w		#-1,d4
	lsr.w		d2,d4
	not.w		d4
	and.w		d4,d6

	move.l		d5,d2
	swap		d2
.sloop1:
	move.l		a2,d7
	move.w		(a0,d5.w),d1
	and.w		d1,d7

	move.w		d3,d4
	not.w		d1
	and.w		d1,d4
	or.w		d4,d7

	and.w		d6,d7
	not.w		d6

	RandorWl

	not.w		d6

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	dbra		d0,.sloop1

	moveq		#1,d0
	rts

	.ifeq	shadow
mfdb_transparent:
	.endc
	.ifne	shadow
shadow_transparent:
	.endc
	addq.l		#4,a7
	lsr.w		#4,d0
	beq		.single1
	subq.w		#1,d0			// d0.w - number of 16 pixel blocks to blit

	moveq		#-1,d3
	lsr.w		d1,d3
	move.l		d3,d1
	swap		d1
	lsr.w		d2,d1

	move.l		d5,d2
	swap		d2

	swap		d0
.loop11:
	swap		d0
	move.l		a2,d7
	move.w		(a0,d5.w),d3

	move.w		d3,d6
	swap		d6
	move.w		d3,d6

	move.w		d7,d3
	swap		d7
	move.w		d3,d7

	move.l		d1,d3
	swap		d3
	and.w		d3,d6
	and.l		d6,d7
	not.l		d6

	RandorW

	swap		d6
	swap		d7
	move.w		d0,d3			// Good idea?
	beq		.loop22_end
	subq.w		#1,d3
.loop22:
	RandorW

	dbra		d3,.loop22
.loop22_end:

	move.w		d1,d3
	or.w		d3,d6
	not.w		d3
	and.w		d3,d7

	RandorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	swap		d0
	dbra		d0,.loop11

	moveq		#1,d0
	rts

.single1:
	swap		d0
	moveq		#-1,d3
	lsr.w		d1,d3
	move.w		#-1,d4
	lsr.w		d2,d4
	not.w		d4
	and.w		d4,d3

	move.l		d5,d2
	swap		d2
.sloop11:
	move.l		a2,d7
	move.w		(a0,d5.w),d6
	and.w		d3,d6

	and.w		d6,d7
	not.w		d6

	RandorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	dbra		d0,.sloop11

	moveq		#1,d0
	rts

	.ifeq	shadow
mfdb_xor:
	.endc
	.ifne	shadow
shadow_xor:
	.endc
	addq.l		#4,a7
	lsr.w		#4,d0
	beq		.single2
	subq.w		#1,d0			// d0.w - number of 16 pixel blocks to blit

	moveq		#-1,d6
	lsr.w		d1,d6
	move.l		d6,d1
	swap		d1
	lsr.w		d2,d1
	not.w		d1

	move.l		d5,d2
	swap		d2

	swap		d0
.loop111:
	swap		d0
	move.w		(a0,d5.w),d7

	move.w		d7,d6
	swap		d7
	move.w		d6,d7

	move.l		d1,d6
	swap		d6
	and.w		d6,d7

	ReorW

	swap		d7
	move.w		d0,d6			// Good idea?
	beq		.loop222_end
	subq.w		#1,d6
.loop222:
	ReorW

	dbra		d6,.loop222
.loop222_end:

	and.w		d1,d7

	ReorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	swap		d0
	dbra		d0,.loop111

	moveq		#1,d0
	rts

.single2:
	swap		d0
	moveq		#-1,d6
	lsr.w		d1,d6
	move.w		#-1,d4
	lsr.w		d2,d4
	not.w		d4
	and.w		d4,d6

	move.l		d5,d2
	swap		d2
.sloop111:
	move.w		(a0,d5.w),d7

	and.w		d6,d7

	ReorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	dbra		d0,.sloop111

	moveq		#1,d0
	rts

	.ifeq	shadow
mfdb_revtransp:
	.endc
	.ifne	shadow
shadow_revtransp:
	.endc
	addq.l		#4,a7
	lsr.w		#4,d0
	beq		.single3
	subq.w		#1,d0			// d0.w - number of 16 pixel blocks to blit

	moveq		#-1,d3
	lsr.w		d1,d3
	move.l		d3,d1
	swap		d1
	lsr.w		d2,d1

	move.l		d5,d2
	swap		d2

	swap		d0
.loop1111:
	swap		d0
	move.l		a2,d7
	move.w		(a0,d5.w),d3

	move.w		d3,d6
	swap		d6
	move.w		d3,d6

	move.w		d7,d3
	swap		d7
	move.w		d3,d7

	move.l		d1,d3
	swap		d3
	and.w		d3,d6
	not.l		d6
	and.l		d6,d7
	not.l		d6

	RandorW

	swap		d6
	swap		d7
	move.w		d0,d3			// Good idea?
	beq		.loop2222_end
	subq.w		#1,d3
.loop2222:
	RandorW

	dbra		d3,.loop2222
.loop2222_end:

	move.w		d1,d3
	or.w		d3,d6
	not.w		d3
	and.w		d3,d7

	RandorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	swap		d0
	dbra		d0,.loop1111

	moveq		#1,d0
	rts

.single3:
	swap		d0
	moveq		#-1,d3
	lsr.w		d1,d3
	move.w		#-1,d4
	lsr.w		d2,d4
	not.w		d4
	and.w		d4,d3

	move.l		d5,d2
	swap		d2
.sloop1111:
	move.l		a2,d7
	move.w		(a0,d5.w),d6
	not.w		d3
	and.w		d3,d6

	and.w		d6,d7
	not.w		d6

	RandorWl

	add.w		d2,a1
	.ifne	both
	add.w		d2,a4
	.endc
	add.w		#2,d5
	and.w		#0x001e,d5

	dbra		d0,.sloop1111

	moveq		#1,d0
	rts
