; Atari ST/e synclock demosystem
; September 2, 2011
;
; sys/cookie.s


maxcookie:	equ	128				;Maximum cookie entries to search

		section	text

cookie_check:
		move.l	$5a0.w,d0
		beq.s	.st				;Null pointer = ST
		move.l	d0,a0

		moveq	#maxcookie-1,d7
.search_mch:	tst.l	(a0)
		beq.s	.st				;Null termination of cookiejar, no _MCH found = ST

		cmp.l	#"_MCH",(a0)
		beq.s	.mch_found
		addq.l	#8,a0
		dbra	d7,.search_mch
		bra.s	.st				;Default to ST

.mch_found:	move.l	4(a0),d0
		cmp.l	#$00010000,d0
		beq.s	.ste
		cmp.l	#$00010010,d0
		beq.s	.megaste
		cmp.l	#$00020000,d0
		beq.s	.tt
		cmp.l	#$00030000,d0
		beq.s	.falcon

.st:		move.l	#"ST  ",computer_type
		bra.s	.cookie_done

.ste:		move.l	#"STe ",computer_type
		bra.s	.cookie_done

.megaste:	move.l	#"MSTe",computer_type
		bra.s	.cookie_done

.tt:		move.l	#"TT  ",computer_type
		bra.s	.cookie_done


.falcon:	;Check if we are on CT60/3
		move.l	$5a0.w,a0
		moveq	#maxcookie-1,d7
.search_ct60:
		cmp.l	#"CT60",(a0)
		beq.s	.f060
		addq.l	#8,a0
		dbra	d7,.search_ct60

.f030:		move.l	#"F030",computer_type
		bra.s	.cookie_done
.f060:		move.l	#"F060",computer_type

.cookie_done:
	ifne	show_infos
		move.l	#computer_text,d0
		jsr	print
	endc
		rts

		section	data

	ifne	show_infos
computer_text:	dc.b	"- Computer: "
	endc

computer_type:	dc.l	0				;"ST  ", "STe ", "MSTe", "TT  ", "F030", "F060"
		dc.b	13,10,0,0


		section	text

