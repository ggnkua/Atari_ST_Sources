/********************************************************************
	SVRO.C	:	COPYRIGHT 1990 Samuel Streeper

	The following call replaces the megamax C or laser C library
	binding for the vro_cpyfm() blitter call. This binding takes the
	structures normally passed to that call and uses that data to set
	up the line-a variables, and then it does the blit using the
	line-a function. There are 2 advantages:

		1)	Trap #2 is not used, so the AES (and the event manager)
			is not invoked.
		2)	AES just sets up the line-a variables anyway, and I do
			it almost 3 times as fast.
		3)	Ok, there are 3 advantages... a virtual workstation handle
			is not required, so the blit works whether or not you have
			a valid workstation handle.

	Operation of the faster binding is transparent; If you link with
	this object module you get the fast binding, otherwise you get the
	normal one. In any case, you don't have to modify your source code.

	This function does not work in low res right now (I don't think)
	but it would be an easy fix.
********************************************************************/

static int blit(),s_form();

asm{
blit:	dc.w 0,0,0,0,0
		dc.l 0
		dc.w 0,0
s_form:	dc.l 0
		dc.w 0,0
		dc.w 2			;always 2!
s_xmin:	dc.w 0
s_ymin:	dc.w 0
d_form:	dc.l 0
		dc.w 0,0
		dc.w 2			;always 2!
		dc.l 0			;pattern, always 0
		dc.w 0,0,0
		dc.w 0,0,0,0,0,0,0,0,0,0,0,0
   }

vro_cpyfm(handle,mode,pxyarray,src,dest)
int **pxyarray, **src, **dest;
{	asm{
		lea blit,A0
		move mode(A6),D0
		andi #0xF,D0
		move D0,D1
		lsl #8,D0
		add D1,D0
		move D0,D1
		lsl.l #8,D0
		lsl.l #8,D0
		add D1,D0				;d0 = mask for 2 bit planes
		move.l D0,10(A0)

		movea.l pxyarray(A6),A1	;A1 -> int[8]
		move	4(A1),D0
		sub	(A1),D0
		addq	#1,D0			;D0 = width
		move	D0,(A0)
		move	6(A1),D0
		sub	2(A1),D0
		addq	#1,D0
		move	D0,2(A0)		;height

		move	(A1),14(A0)		;source x
		move	2(A1),16(A0)	;source y
		move	8(A1),28(A0)	;dest x
		move	10(A1),30(A0)	;dest y

		movea.l src(A6),A1		;A1 -> src MFDB
		move	12(A1),D0
		move	D0,4(A0)		;num planes
		move	D0,D1			;save # planes
		subq	#1,D1
		add	D0,D0
		move	D0,22(A0)		;bytes to next word in line
		move	#1,6(A0)		;foreground color (?)
		clr	8(A0)				;bckgnd color (?)
		move	8(A1),D0		;words to next line
		add	D0,D0
		tst	D1
		beq	v1
		add	D0,D0
	v1:	move	D0,24(A0)		;bytes to next line
		move.l	(A1),18(A0)		;src &

		movea.l dest(A6),A1		;A1 -> src MFDB
		move.l	(A1),32(A0)		;src &
		move	12(A1),D0
		add	D0,D0
		move	D0,36(A0)		;bytes to next word in line
		move	8(A1),D0		;words to next line
		add	D0,D0
		tst	D1
		beq	v2
		add	D0,D0
	v2:	move	D0,38(A0)		;bytes to next line

		move.l	A6,-(A7)
		lea	blit,A6
		dc.w	0xA007
		move.l	(A7)+,A6
	   }
}
