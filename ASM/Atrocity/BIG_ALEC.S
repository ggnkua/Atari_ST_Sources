*** By AKRILIK
	opt	o+

	section	text

Supervisor_mode:
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

Switch_off_keyboard:
	move.b	$484.w,Keyboard_buffer
	clr.b	$484.w

Switch_off_and_hide_mouse_cursor:
	dc.w	$a00a
	move.b	#$12,$fffffc02.w

Put_screen_in_white:
	pea	Text(pc)
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp

Initialisation_of_big_alec_music:
	moveq	#1,d0
	bsr.s	Big_alec_music

Call_big_alec_music:
	move.l	#Big_alec_music+8,$4d2.w

Repeat_until_space_bar_pressed_and_released:
	cmpi.b	#$39+$80,$fffffc02.w
	bne.s	Repeat_until_space_bar_pressed_and_released

Clear_three_voices_for_music:
	clr.l	$4d2.w
	moveq	#0,d0
	bsr.s	Big_alec_music
	movea.w	#$8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

Switch_on_and_show_mouse_cursor:
	dc.w	$a009
	move.b	#$08,$fffffc02.w

Switch_on_interrupts:
	move.b	Keyboard_buffer,$484.w

User_mode:
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp

Pterm_function:
	clr.w	-(sp)
	trap	#1

	section	data

Text:
	dc.b	$1b,"E"
	dc.b	0

Big_alec_music:even
	incbin	"e:\totf\bigalec.snd"

	section	bss

Keyboard_buffer:
	ds.b	1

	end