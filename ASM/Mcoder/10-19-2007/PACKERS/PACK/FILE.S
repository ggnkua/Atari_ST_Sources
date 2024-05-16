;
; complete filing system
;
	clr	-(sp)
	pea	file(pc)
	move	#$4e,-(sp)
	trap	#1		;search_first
	addq	#8,sp
	tst	d0
	bne.s	error

	move	#$2f,-(sp)
	trap	#1		;get_dta
	addq	#2,sp
	move.l	d0,a0
	move.l	26(a0),length

	bra.s	error

	clr	-(sp)
	pea	file(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	bmi.s	error

	pea	buffer
	move.l	length(pc),-(sp)
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1		;read_file
	lea	12(sp),sp

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
error:
	illegal

length:	dc.l	0
file:	dc.b	'genst2.prg',0
buffer:
