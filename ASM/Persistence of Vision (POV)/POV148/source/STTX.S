*************************************************************************
*		WIDGET Transmitting code for Atari ST Family		*
*		--------------------------------------------		*
*				MIDI VERSION				*
*									*
*									*
* Written by:	Mac Sys Data of Persistence Of Vision			*
*									*
* Date:		29-March-1995						*
*									*
* Version:	3.0							*
*									*
*************************************************************************
*
*		All code (c) Persistence Of Vision 1995
*
*
*
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp

		bsr	write_preamble
		bsr	sync
		bsr	write_code_start
		bsr	sync
		bsr	write_length
		bsr	sync
		bsr	write_data
		clr.w	-(sp)
		trap	#1

write_data
		lea	DL_CODE_START,a6
		move.l	#CODE_LENGTH,d3
.write_loop	move.b	(a6)+,d0
		bsr	send_byte
		bsr	sync
		sub.l	#1,d3
		bne.s	.write_loop
		rts
;sync is used to slow down output as Slave ST has to write data to screen
; whilst receiving data from Master (Midi port works at same rate on both Ataris)
sync		move.w	#900-1,d5
.sync		nop
		dbf	d5,.sync
		rts



write_preamble	move.b	#"M",d0
		bsr	send_byte
		move.b	#"S",d0
		bsr	send_byte
		move.b	#"D",d0
		bsr	send_byte
		move.b	#"!",d0
		bsr	send_byte
		rts

write_code_start
		move.l	#exec_addr,d7
		bsr	sort_bytes
		move.w	d4,d0
		bsr	send_byte
		move.w	d5,d0
		bsr	send_byte
		move.w	d6,d0
		bsr	send_byte
		move.w	d7,d0
		bsr	send_byte
		rts

write_length	move.l	#CODE_LENGTH,d7
		bsr	sort_bytes
		move.w	d4,d0
		bsr	send_byte
		move.w	d5,d0
		bsr	send_byte
		move.w	d6,d0
		bsr	send_byte
		move.w	d7,d0
		bsr	send_byte
		rts

sort_bytes	;entry=D7.l holding 4 bytes to be sent
		;exit=d4,d5,d6,d7.b holding 4 bytes to be sent
		move.l	d7,d6
		move.l	d7,d5
		swap	d5
		move.w	d5,d4
		lsr.w	#8,d4
		and.l	#$ff,d5
		lsr.w	#8,d6
		and.l	#$ff,d6
		and.l	#$ff,d7
;results are now in bytes of d4,d5,d6,d7
		rts


send_byte	;write midi data
		and.w	#$ff,d0		;mask off crap
		move.w	d0,-(sp)	;char
		move.w	#3,-(sp)	;midi
		move.w	#3,-(sp)	;call
		trap	#13
		addq.w	#6,sp
		rts


DL_CODE_START
