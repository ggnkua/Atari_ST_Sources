;-----------------------------------------------------------------------------
;File name:	PROG_nnn.S		Revised:	1993.08.10
;Created by:	URAn of Munin		Created:	1991.07.03
;-----------------------------------------------------------------------------
;Purpose:	Lib to implement numeric argument in file name
;   -"-		or as command tail (the latter over-riding).
;-----------------------------------------------------------------------------
; 2 functions:	calc_nnn(selfpath, comdtail, extrapath); /* all args being "char *" */
;	-"-	show_nnn(number); short int number;
;-----------------------------------------------------------------------------
calc_nnn:	;args: char *selfpath; char *comdtail; char *extrapath;
	link	a6,#-44
	move.l	12(a6),a0
	move.l	a0,d0
	beq.s	.no_arg
	move.b	(a0)+,d0
	beq.s	.no_arg
	and	#7,d0
	clr.b	(a0,d0)
	bra.s	.calc_number
;
.no_arg:
	pea	-44(a6)
	move	#$1A,-(sp)	;gemdos Fsetdta
	trap	#1
	addq	#6,sp
	tst.l	8(a6)
	beq.s	.try_extra
	clr	-(sp)
	move.l	8(a6),-(sp)
	move	#$4E,-(sp)
	trap	#1
	addq	#8,sp
	lea	35-44(a6),a0	;a0->6'th char of filename
	tst	d0
	bpl.s	.calc_number
.try_extra:
	tst.l	16(a6)
	beq.s	.self_not_found
	clr	-(sp)
	move.l	16(a6),-(sp)
	move	#$4E,-(sp)
	trap	#1
	addq	#8,sp
	lea	35-44(a6),a0	;a0->6'th char of filename
	tst	d0
	bmi.s	.self_not_found
.calc_number:
	clr.l	d1
	clr.l	d0
.calc_loop:
	move.b	(a0)+,d0
	beq.s	.calc_end
	cmp.b	#'.',d0
	beq.s	.calc_end
	sub.b	#'0',d0
	bmi.s	.calc_end
	cmp.b	#10,d0
	bge.s	.calc_end
	mulu	#10,d1
	add	d0,d1
	bra.s	.calc_loop
;
.calc_end:
	move.l	d1,d0
	bra.s	.calc_exit
;
.self_not_found:
	clr.l	d1
	moveq	#-33,d0
.calc_exit:
	unlk	a6
	rts
;
;-----------------------------------------------------------------------------
;
show_nnn:
	clr.l	d0
	move	4(sp),d0
	subq	#8,sp
	move.l	sp,a0
	clr.b	(a0)+
	moveq	#6-1,d1
.show_lp1:
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	clr	d0
	swap	d0
	dbeq	d1,.show_lp1
	move.l	sp,a1
.show_lp2:
	move.b	-(a0),d0
	move.b	(a1),(a0)
	move.b	d0,(a1)+
	cmp.l	a0,a1
	blo.s	.show_lp2
	move.l	sp,-(sp)
	move	#$09,-(sp)	;gemdos Cconws
	trap	#1
	addq	#6,sp
	addq	#8,sp
	rts
;-----------------------------------------------------------------------------
; End of file:	PROG_nnn.S
;-----------------------------------------------------------------------------
