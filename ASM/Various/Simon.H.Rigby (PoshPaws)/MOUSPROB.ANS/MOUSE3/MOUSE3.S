CUR_X		EQU	-$158	;current x pointer (restricted by screen res)
CUR_Y		EQU	-$156	;current y pointer

start		dc.w	$a000
;This is an 'illegal' instruction that generates a Line A Trap
;It is used to call Line A subroutines like TRAP #1 calls GEMDOS
;the last digit decides which routine is called
;This instruction returns a pointer to a table of values in a0
;These values are stored both before and after this pointer
		move.l	a0,A_Table
		
check_key	
		move.w	#$b,-(sp)
		trap	#1		;exit on any key
		addq.w	#2,sp
		tst.l	d0
		bne.s	end_prog
		
;show_position	
		move.l	A_Table,a6	;pointer to table of values
		move.w	CUR_X(a6),d0
		ext.l	d0
		move.l	#mouse_x_str,a0
		move.l	#$20202020,(a0)	;put spaces in string
		bsr.s	Dec_str	
		move.w	CUR_Y(a6),d0
		ext.l	d0
		move.l	#mouse_y_str,a0
		move.l	#$20202020,(a0)	;put spaces in string
		bsr.s	Dec_str	

;write_string
		pea	mouse_string
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp

		bra.s	check_key
		
end_prog	move.w	#1,-(sp)
		trap	#1
		addq.w	#2,sp		;get detected key
		clr.w	-(sp)
		trap	#1				
		
		DATA
mouse_string	dc.b	27,'H',"Mouse X: "
mouse_x_str	dc.b	"           "
		dc.b	" Mouse Y: "
mouse_y_str	dc.b	"           ",0
		even		
		BSS
A_Table		ds.l	1	;Pointer to Line A Table of values

;***************************************************************************
;LIBRARY ROUTINE

		TEXT
;Convert Signed Long into Decimal String
;ENTRY:	A0 = Address to put string into
;	D0 = Value to Convert
;EXIT:	A0 = Address of first byte after converted string
;USES:	d0-d2/a0

;Note: Does not terminate string and could use 1-11 digits (bytes)

Dec_str	moveq	#0,d1
	moveq	#0,d2	;byte set when first digit is not zero
	tst.l	d0	;check for plus or minus
	bpl.s	.pos
	neg.l	d0
	move.b	#'-',(a0)+
.pos	addq.b	#1,d1
	sub.l	#1000000000,d0
	bpl.s	.pos
	subq.b	#1,d1
	add.l	#1000000000,d0
	tst.b	d1		;skip if zero
	beq.s	.e8
	st	d2		;first digit not zero
	add.b	#'0',d1
	move.b	d1,(a0)+
	moveq	#0,d1
.e8	addq.b	#1,d1
	sub.l	#100000000,d0
	bpl.s	.e8
	subq.b	#1,d1
	add.l	#100000000,d0
	tst.b	d1		;skip if zero
	beq.s	.e7
	st	d2		;first digit not zero
	add.b	#'0',d1
	move.b	d1,(a0)+
	moveq	#0,d1
.e7	addq.b	#1,d1
	sub.l	#10000000,d0
	bpl.s	.e7
	subq.b	#1,d1
	add.l	#10000000,d0
	tst.b	d1		;skip if zero
	beq.s	.e6
	st	d2		;first digit not zero
	add.b	#'0',d1
	move.b	d1,(a0)+
	moveq	#0,d1
.e6	addq.b	#1,d1
	sub.l	#1000000,d0
	bpl.s	.e6
	subq.b	#1,d1
	add.l	#1000000,d0
	tst.b	d1		;skip if zero
	beq.s	.e5
	st	d2		;first digit not zero
	add.b	#'0',d1
	move.b	d1,(a0)+
	moveq	#0,d1
.e5	addq.b	#1,d1
	sub.l	#100000,d0
	bpl.s	.e5
	subq.b	#1,d1
	add.l	#100000,d0
	tst.b	d1		;skip if zero
	beq.s	.e4
	st	d2		;first digit not zero
	add.b	#'0',d1
	move.b	d1,(a0)+
	moveq	#0,d1		;small enough for divu now
.e4	divu	#10000,d0
	tst.b	d0
	beq.s	.e3
	st	d2
	add.b	#'0',d0
	move.b	d0,(a0)+
.e3	clr.w	d0		;word only clear
	swap	d0		;remainder
	divu	#1000,d0
	tst.b	d0
	beq.s	.e2
	st	d2
	add.b	#'0',d0
	move.b	d0,(a0)+
.e2	clr.w	d0
	swap	d0		;remainder
	divu	#100,d0
	tst.b	d0
	beq.s	.e1
	st	d2
	add.b	#'0',d0
	move.b	d0,(a0)+
.e1	clr.w	d0
	swap	d0		;remainder
	divu	#10,d0
	tst.b	d0
	beq.s	.e0
	st	d2
	add.b	#'0',d0
	move.b	d0,(a0)+
.e0	clr.w	d0
	swap	d0		;remainder
	add.b	#'0',d0
	move.b	d0,(a0)+
	rts
