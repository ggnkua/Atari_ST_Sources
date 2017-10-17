	;A0 = Address to a string of comma separated flag-names
	;A1 = Address of a flag-attribute table
parse_flags:	movem.l	d1-a6,-(sp)

		moveq	#0,d0
		tst.b	(a0)
		beq.s	.ok_exit

	;Get a flag-name from comma sep string into a temp buffer
.next_flag:	lea	.temp(pc),a2
.nxt:		move.b	(a0)+,d1
		beq.s	.check_this
		cmp.b	#Asc_cr,d1
		beq.s	.check_this
		cmp.b	#Asc_lf,d1
		beq.s	.check_this
		cmp.b	#',',d1
		beq.s	.check_this
		move.b	d1,(a2)+
		bra.s	.nxt

	;Now a name from the comma sep string is in the temp buffer.
	;Terminate the temp buffer
.check_this:	clr.b	(a2)
		lea	.temp(pc),a2
		move.l	a1,a3

	;Check the current flag-name in the table agains the flag-name
	;in the temp buffer
.cmp_nxt:	move.b	(a3)+,d1
		beq.s	.maybe
		cmp.b	(a2)+,d1
		beq.s	.cmp_nxt

	;The two flag names did not match, advance to the next flag-name
	;in the flag-attribute table
.srch_nxt_flag:	tst.b	(a3)+
		bne.s	.srch_nxt_flag
.get_nxt_flag:	addq.l	#2,a3		;A3 now points to the next flag-name in attr table
		tst.b	(a3)		;No more flags?
		beq.s	.parse_error	;yes, then we didn't understand this flag-name
		lea	.temp(pc),a2	;Reset temp to start and try this flag-name
		bra.s	.cmp_nxt

	;The flag-name in the attribute table was terminated. Check if
	;the flag-name in the temp buffer is terminated too, in wich case
	;we have found the flag in the attribute table
.maybe:		tst.b	(a2)		;Found the flag-name?
		bne.s	.get_nxt_flag	;No, try next flag in attribute table

	;We have found the flag in the attribute table.
.found:		moveq	#0,d1
		move.b	(a3),d1		;Get shift value (Flag position)
		moveq	#0,d2
		move.b	1(a3),d2	;Get flag value
		lsl.l	d1,d2		;Shift flag value into correct position
		or.l	d2,d0		;Or into the result
	;Check the flag-name delimiter in the comma sep string.
		move.b	-1(a0),d1
		beq.s	.ok_exit
		cmp.b	#Asc_lf,d1
		beq.s	.ok_exit
		cmp.b	#Asc_cr,d1
		bne.s	.next_flag
		bra.s	.ok_exit

.parse_error:	and.b	#-2,ccr
		bra.s	.exit
.ok_exit:	or.b	#1,ccr
.exit:		movem.l	(sp)+,d1-a6
		rts

		bss
.temp:		ds.b 100				
		text
