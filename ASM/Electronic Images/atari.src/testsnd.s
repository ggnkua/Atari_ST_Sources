move_to_snd		macro
		move.b	#\1,$ffff8800.w
		move.b	#\2,$ffff8802.w
		endm

set_noise	macro
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		and.b	#~(4<<\1),d0
		move.b	d0,$ffff8802.w
		endm

clear_noise	macro
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		or.b	#(4<<\1),d0
		move.b	d0,$ffff8802.w
		endm

set_tone	macro
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		and.b	#~(1<<(\1-1)),d0
		move.b	d0,$ffff8802.w
		endm

clear_tone	macro
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		or.b	#(1<<(\1-1)),d0
		move.b	d0,$ffff8802.w
		endm

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move_to_snd 1,3
		move_to_snd 0,-12

		move_to_snd 11,63
		move_to_snd 12,0
		
		move_to_snd 8,16
		move_to_snd 9,0
		move_to_snd 10,0

		move_to_snd 13,10

		clear_noise 1 
		clear_noise 2 
		clear_noise 3 
		set_tone 1 
		clear_tone 2 
		clear_tone 3 

		;move_to_snd 13,9

		clr -(sp)
		trap	#1