/*-------------------------------------------------------*
 *	Macros for planar mode drawing			 *	
 *-------------------------------------------------------*/

  .ifne 0
	.macro
	setpix1	mask,data,temp
	.ifeq	both
	 .ifeq	get
	and.l		\1,(a0)
	or.l		\2,(a0)+
	 .endif
	 .ifne	get
	move.l		(a0),\3
	and.l		\1,\3
	or.l		\2,\3
	move.l		\3,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.l		\1,(a4)
	or.l		\2,(a4)
	  .ifeq	longs
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		(a4)+,(a0)+
	  .endif
	 .endif
	 .ifne	get
	move.l		(a4),\3
	and.l		\1,\3
	or.l		\2,\3
	  .ifeq	longs
	move.l		\3,(a4)
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		\3,(a4)+
	move.l		\3,(a0)+
	  .endif
	 .endif
	.endif
	.endm

	.macro
	setpix2	mask,data,temp
	.ifeq	both
	 .ifeq	get
	and.l		\1,(a0)
	or.l		\2,(a0)+
	 .endif
	 .ifne	get
	move.l		(a0),\3
	and.l		\1,\3
	or.l		\2,\3
	move.l		\3,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	longs
	move.w		(a4)+,(a0)+
	 .endif
	 .ifeq	get
	and.l		\1,(a4)
	or.l		\2,(a4)
	  .ifeq	longs
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		(a4)+,(a0)+
	  .endif
	 .endif
	 .ifne	get
	move.l		(a4),\3
	and.l		\1,\3
	or.l		\2,\3
	  .ifeq	longs
	move.l		\3,(a4)
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		\3,(a4)+
	move.l		\3,(a0)+
	  .endif
	 .endif
	.endif
	.endm

	.macro
	setpix3	mask,data,temp
	.ifeq	both
	 .ifeq	get
	and.l		\1,(a0)
	or.l		\2,(a0)+
	 .endif
	 .ifne	get
	move.l		(a0),\3
	and.l		\1,\3
	or.l		\2,\3
	move.l		\3,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	longs
	move.w		(a4)+,(a0)+
	 .endif
	 .ifeq	get
	and.l		\1,(a4)
	or.l		\2,(a4)
	  .ifeq	longs
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		(a4)+,(a0)+
	  .endif
	 .endif
	 .ifne	get
	move.l		(a4),\3
	and.l		\1,\3
	or.l		\2,\3
	  .ifeq	longs
	move.l		\3,(a4)
	move.w		(a4)+,(a0)+
	move.w		(a4)+,(a0)+
	  .endif
	  .ifne	longs
	move.l		\3,(a4)+
	move.l		\3,(a0)+
	  .endif
	 .endif
	.endif
	.endm

	.macro
	setpix4	mask,data,temp
	and.l		\1,\3
	or.l		\2,\3
	.ifeq	both
	move.l		\3,(a0)+
	.endif
	.ifne	both
	 .ifeq	longs
	move.l		\3,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	longs
	move.l		\3,(a4)+
	move.l		\3,(a0)+
	 .endif
	.endif
	.endm

	.macro
	setpix5	mask,data,temp
	and.l		\1,\3
	or.l		\2,\3
	.ifeq	both
	move.l		\3,(a0)+
	.endif
	.ifne	both
	 .ifeq	longs
	move.w		(a4)+,(a0)+
	 .endif
	 .ifeq	longs
	move.l		\3,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	longs
	move.l		\3,(a4)+
	move.l		\3,(a0)+
	 .endif
	.endif
	.endm
  .endif


	.macro	label name
	.ifeq	shadow
mfdb_\name:
	.else
shadow_\name:
	.endif
	.endm

	.macro	jump type,name
	.ifeq	shadow
	\type	mfdb_\name
	.else
	\type	shadow_\name
	.endif
	.endm


	.macro	RandorW
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	and.w		d6,d4
	or.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)+
	.endif
	.ifne	both
	move.w		d4,(a4)+
	move.w		d4,(a1)+
	.endif
	.endm

	.macro	RorW
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	or.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)+
	.endif
	.ifne	both
	move.w		d4,(a4)+
	move.w		d4,(a1)+
	.endif
	.endm

	.macro	RandW
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	and.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)+
	.endif
	.ifne	both
	move.w		d4,(a4)+
	move.w		d4,(a1)+
	.endif
	.endm

	.macro	ReorW
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endc
	eor.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)+
	.endif
	.ifne	both
	move.w		d4,(a4)+
	move.w		d4,(a1)+
	.endif
	.endm

	.macro	RandorWl
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	and.w		d6,d4
	or.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)
	.endif
	.ifne	both
	move.w		d4,(a4)
	move.w		d4,(a1)
	.endif
	.endm

	.macro	RorWl
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	or.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)
	.endif
	.ifne	both
	move.w		d4,(a4)
	move.w		d4,(a1)
	.endif
	.endm

	.macro	RandWl
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	and.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)
	.endif
	.ifne	both
	move.w		d4,(a4)
	move.w		d4,(a1)
	.endif
	.endm

	.macro	ReorWl
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	eor.w		d7,d4
	.ifeq	both
	move.w		d4,(a1)
	.endif
	.ifne	both
	move.w		d4,(a4)
	move.w		d4,(a1)
	.endif
	.endm

	.macro	nopW
	.ifeq	both
	move.w		d7,(a1)+
	.endif
	.ifne	both
	move.w		d7,(a4)+
	move.w		d7,(a1)+
	.endif
	.endm


	.macro	opmWw
	.ifeq	both
	move.w		(a1),d4
	.endif
	.ifne	both
	move.w		(a4),d4
	.endif
	jsr		(a6)
	.ifeq	both
	move.w		d4,(a1)+
	.endif
	.ifne	both
	move.w		d4,(a4)+
	move.w		d4,(a1)+
	.endif
	.endm

	.macro	opWl
	.ifeq	both
	move.l		(a1),d4
	.endif
	.ifne	both
	move.l		(a4),d4
	.endif
	jsr		12(a6)
	.ifeq	both
	move.l		d4,(a1)+
	.endif
	.ifne	both
	move.l		d4,(a4)+
	move.l		d4,(a1)+
	.endif
	.endm

  .ifne 0
	.macro	opmWlr	dst,shadow,v,tmp,mask
	.ifeq	both
	move.l		(a1),\4
	.endif
	.ifne		both
	move.l		(a4),\4
	.endif
	jsr		(a6)
	.ifeq	both
	move.l		\4,(a1)+
	.endif
	.ifne	both
	move.l		\4,(a4)+
	move.l		\4,(a1)+
	.endif
	.endm

	.macro	opWlr	dst,shadow,v,tmp
	.ifeq	both
	move.l		(a1),\4
	.endif
	.ifne		both
	move.l		(a4),\4
	.endif
	jsr		12(a6)
	.ifeq	both
	move.l		\4,(a1)+
	.endif
	.ifne	both
	move.l		\4,(a4)+
	move.l		\4,(a1)+
	.endif
	.endm

	.macro	nopmWlr	dst,shadow,v,tmp,mask
	.ifeq	both
	move.l		(\1),\4
	.endif
	.ifne		both
	move.l		(\2),\4
	.endif
	eor.l		\4,\3
	and.l		\5,\3
	eor.l		\4,\3
	.ifeq	both
	move.l		\3,(\1)+
	.endif
	.ifne	both
	move.l		\3,(\2)+
	move.l		\3,(\1)+
	.endif
	.endm

	.macro	nopmWlrs	dst,shadow,v,tmp,mask
	.local	.draw,.no_draw
	.ifeq	both
	move.l		(\1),\4
	.endif
	.ifne		both
	move.l		(\2),\4
	.endif
	eor.l		\4,\3
	and.l		\5,\3
	eor.l		\4,\3

	.ifne	smartdraw
	cmp.l		(\2),\3
	bne		.draw
	addq.l		#4,\2
	addq.l		#4,\1
	bra		.no_draw
.draw:
	.endif
	.ifeq	both
	move.l		\3,(\1)+
	.endif
	.ifne	both
	move.l		\3,(\2)+
	move.l		\3,(\1)+
	.endif
.no_draw:
	.endm

	.macro	nopWlr	dst,shadow,v
	.ifeq	both
	move.l		\3,(\1)+
	.endif
	.ifne	both
	move.l		\3,(\2)+
	move.l		\3,(\1)+
	.endif
	.endm

	.macro	nopWlrs	dst,shadow,v,delta
	.local	.draw,.no_draw
	.ifne	smartdraw
	.ifne	0
	cmp.l		\4(\2),\3
	bne		.draw
	addq.l		#4,\1
	bra		.no_draw
.draw:
;	move.l		\3,(\2)+
;	move.l		\3,a3
	move.l		\3,\4(\2)
	move.l		\3,(\1)+
;	move.l		\3,\4(\1)
.no_draw:
	.endif
	.ifeq	0
	cmp.l		\4(\2),\3
	beq		.no_draw
.draw:
	move.l		\3,\4(\2)
	move.l		\3,(\1)
.no_draw:
	addq.l		#4,\1
	.endif
	.endif
	.ifeq	smartdraw
;	move.l		\3,(\2)+
;	move.l		\3,a3
	.ifne	both
	move.l		\3,\4(\2)
	move.l		\3,(\1)+
	.endif
	.ifeq	both
	move.l		\3,(\1)+
	.endif
;	move.l		\3l,\4(\1)
	.endif
	.endm
  .endif
