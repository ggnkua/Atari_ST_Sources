restore_all:
		IFNE playmusic
		jsr 	music+4
		move.l	#8*256,d0
  		move.l	#$ffff8800,a1
  		move.l	#3-1,d1
.loop:
  		movep.w	d0,(0,a1)
  		add.w	#256,d0
  		dbra	d1,.loop
		ENDC	

		move.w	#$2700,sr					;Stop all interrupts
		move.l	save_vbl,$70.w				;Restore old VBL
		move.l	save_hbl,$68.w				;Restore old HBL
		move.l	save_ta,$134.w				;Restore old Timer A
		move.l	save_tb,$120.w				;Restore old Timer B
		move.l	save_tc,$114.w				;Restore old Timer C
		move.l	save_td,$110.w				;Restore old Timer D
		move.l	save_acia,$118.w			;Restore old ACIA
		move.b	save_inta,$fffffa07.w
		move.b	save_inta_mask,$fffffa13.w	
		move.b	save_intb,$fffffa09.w		;Restore MFP state for interrupt enable B
		move.b	save_intb_mask,$fffffa15.w	;Restore MFP state for interrupt mask B
		clr.b	$fffffa1b.w					;Timer B control (Stop)

;		move.b mste_status,$ffff8e21		; mste back to original speed


		move.b	save_res,$ffff8260.w		;Restore old resolution
		movem.l	save_pal,d0-d7				;Restore old palette
		movem.l	d0-d7,$ffff8240.w			;

		lea		save_screenadr,a0			;Restore old screen address
		move.b	(a0)+,$ffff8201.w			;
		move.b	(a0)+,$ffff8203.w			;
		move.b	(a0)+,$ffff820d.w			;

		move.l	#$80,d0
.x
		btst	#1,$fffffc00.w
		beq.s	.x
		move.b	d0,$fffffc02.w

		move.l	#$01,d0
.y
		btst	#1,$fffffc00.w
		beq.s	.y
		move.b	d0,$fffffc02.w

		moveq	#0,d0
.z		
		btst	#0,$fffffc00.w
		beq.s	.z
		move.b	d0,$fffffc02.w

		move.b	#$8,$fffffc02.w				;Enable mouse
;		move.b	save_keymode,$484.w
		move.w	#$2300,sr					;Interrupts back on
		rts