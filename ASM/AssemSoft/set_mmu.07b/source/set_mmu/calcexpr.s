		
	;A0 = address of expression
		text

calc_expression:movem.l	d0-a6,-(sp)

		move.l	a0,a3
		sf.b	.got_sign
		sf.b	.sign
		clr.l	.result
		clr.b	.operator

.next:		move.b	(a3)+,d3
		cmp.b	#'$',d3
		beq	.hex
		cmp.b	#'#',d3
		beq	.dec
		cmp.b	#'%',d3
		beq	.bin
		cmp.b	#48,d3
		blo.s	.not_numerical
		cmp.b	#57,d3
		bhi.s	.not_numerical
		subq.l	#1,a3
		bra	.dec

.not_numerical:	tst.b	.got_sign
		bne	.error
		cmp.b	#'+',d3
		beq.s	.plus
		cmp.b	#'-',d3
		bne	.error
		st.b	.sign
		st.b	.got_sign
		bra.s	.next
.plus:		sf.b	.sign
		st.b	.got_sign
		bra.s	.next

;-------------------------------------------------------
.calc:		tst.b	.operator
		beq.s	.no_operator
		move.b	.operator(pc),d3
		cmp.b	#'+',d3
		beq.s	.op_plus
		cmp.b	#'-',d3
		beq.s	.op_minus
		cmp.b	#'*',d3
		beq.s	.op_mul
		cmp.b	#'/',d3
		beq.s	.op_div
		bra	.error

.no_operator:	bra	.op_done
	;	move.l	d0,.result
	;	move.b	(a3)+,.operator
	;	bne	.next
	;	bra	.ok_exit

.op_plus:	add.l	.result(pc),d0
		bra.s	.op_done

.op_minus:	move.l	.result(pc),d1
		sub.l	d0,d1
		exg.l	d0,d1
		bra.s	.op_done

.op_mul:	move.l	.result(pc),d1
		mulu.l	d0,d1
		exg.l	d0,d1
		bra.s	.op_done

.op_div:	move.l	.result(pc),d1
		divu.l	d0,d1
		exg.l	d0,d1
		bra.s	.op_done
		nop

.op_done:	move.l	d0,.result
		move.b	(a3)+,d0
		beq	.ok_exit
		cmp.b	#' ',d0
		beq	.ok_exit
		move.b	d0,.operator
		bra	.next

;------------------------------------------------------
.bin:		lea	.temp(pc),a0
		clr.b	(a0)
		bsr.s	.get_digits
		jsr	ascibintobin
		bsr.s	.sign_test
		tst.b	(a3)
		bra	.calc
;------------------------------------------------------
.dec:		lea	.temp(pc),a0
		clr.b	(a0)
		bsr.s	.get_digits
		jsr	ascidectobin
		bsr.s	.sign_test
		tst.b	(a3)
		bra	.calc
;------------------------------------------------------
.hex:		lea	.temp(pc),a0
		clr.b	(a0)
		bsr.s	.get_digits		
		jsr	ascihextobin
		bsr.s	.sign_test
		tst.b	(a3)
		bra	.calc
;------------------------------------------------------		
.sign_test:	tst.b	.sign
		beq.s	.sign_ok
		neg.l	d0
.sign_ok:	rts
;------------------------------------------------------		
;	 A3 = start of string to fetch number
;	 A0 = Temporary buffer to use to calculate
;
;	 D0 = Returns the binary number result
;	 A3 = Points to the character that terminated the number
.get_digits:	move.l	a0,-(sp)
.nxt_digit:	move.b	(a3)+,d3
		beq.s	.exit_getdigit
		bsr.s	.delim_check
		bcc.s	.exit_getdigit
		move.b	d3,(a0)+
		bra.s	.nxt_digit
.exit_getdigit:	subq.l	#1,a3
		clr.b	(a0)
		move.l	(sp)+,a0
		rts				
;------------------------------------------------------		
	;D3 = char to chekc
	;D3 returns the delimiter..
.delim_check:	movem.l	d0/a0,-(sp)
		lea	.delims(pc),a0

.nxt_delim:	move.b	(a0)+,d0
		beq.s	.nota_delim
		cmp.b	d3,d0
		bne.s	.nxt_delim
		and.b	#-2,ccr
		bra.s	.exit_delim
.nota_delim:	or.b	#1,ccr
.exit_delim:	movem.l	(sp)+,d0/a0
		rts
		data
.delims:	dc.b "+-/*() ",0
.operator:	dc.b 0,0
		bss
.result:	ds.l 1
.sign:		ds.b 1
.got_sign:	ds.b 1
.temp:		ds.b 200		
		even
		text
;------------------------------------------------------
.error:		and.b	#-2,ccr
		bra.s	.exit
.ok_exit:	move.l	.result(pc),(sp)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts
;------------------------------------------------------		

