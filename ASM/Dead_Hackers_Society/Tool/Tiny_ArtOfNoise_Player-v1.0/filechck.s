;
; TAP
; Tiny ArtOfNoise Player v1.0
;
; May 31, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; filechck.s


		section	text

filename_print:	move.l	#filename_name,d0
		bsr.w	print
		
		move.l	filename,d0
		bsr.w	print
		
		bsr.w	newrow
		

channels:	move.l	filebuffer,a0
		move.l	(a0),d0

		cmp.l	#"AON4",d0
		bne.s	.aon6
		move.b	#"4",channels_text+10
		bra.s	.ok
		
.aon6:		cmp.l	#"AON6",d0
		bne.s	.aon8
		move.b	#"6",channels_text+10
		bra.s	.ok

.aon8:		cmp.l	#"AON8",d0
		bne.w	exit_not_aon
		move.b	#"8",channels_text+10
.ok:

.print:		move.l	#channels_text,d0
		bsr.w	print

		bsr.w	newrow


songname:	lea.l	$36(a0),a0
		lea.l	songname_text,a1
		move.l	#"AUTH",d0

		move.w	#2048-2,d7
.loop:		cmp.l	(a0),d0
		beq.s	.print
		move.b	(a0)+,(a1)+
		dbra	d7,.loop
		bra.w	nomore_info

.print:		clr.b	(a1)

		move.l	#songname_name,d0
		bsr.w	print
		
		move.l	#songname_text,d0
		bsr.w	print
		
		bsr.w	newrow



composer:	addq.l	#8,a0
		lea.l	composer_text,a1
		move.l	#"DATE",d0
		
		move.w	#2048-2,d7
.loop:		cmp.l	(a0),d0
		beq.s	.print
		move.b	(a0)+,(a1)+
		dbra	d7,.loop
		bra.w	nomore_info

.print:		clr.b	(a1)

		move.l	#composer_name,d0
		bsr.w	print
		
		move.l	#composer_text,d0
		bsr.w	print
		
		bsr.w	newrow
		
	

date:		addq.l	#8,a0
		lea.l	date_text,a1
		move.l	#"RMRK",d0
		
		move.w	#2048-2,d7
.loop:		cmp.l	(a0),d0
		beq.s	.print
		move.b	(a0)+,(a1)+
		dbra	d7,.loop
		bra.w	nomore_info

.print:		clr.b	(a1)

		move.l	#date_name,d0
		bsr.w	print
		
		move.l	#date_text,d0
		bsr.w	print
		
		bsr.w	newrow


remark:		addq.l	#8,a0
		lea.l	remark_text,a1
		move.l	#"INFO",d0
		
		move.w	#2048-2,d7
.loop:		cmp.l	(a0),d0
		beq.s	.print
		move.b	(a0)+,(a1)+
		dbra	d7,.loop
		bra.w	nomore_info

.print:		clr.b	(a1)

		move.l	#remark_name,d0
		bsr.w	print
		
		move.l	#remark_text,d0
		bsr.w	print
		
		bsr.w	newrow


nomore_info:
