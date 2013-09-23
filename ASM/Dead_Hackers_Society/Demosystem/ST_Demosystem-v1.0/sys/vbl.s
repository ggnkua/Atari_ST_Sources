; Atari ST/e synclock demosystem
; September 1, 2011
;
; sys/vbl.s


		section	text


vbl:
		movem.l	d0-a6,-(sp)

		;Micro demopart sequencer
		move.l	part_position,a0
		lea	timera_delay,a1
		subq.l	#1,(a0)+
		bne.s	.no_switch
		add.l	#24,part_position
.no_switch:	move.l	(a0)+,(a1)+			;timera_delay
		move.l	(a0)+,(a1)+			;timera_div
		move.l	(a0)+,(a1)+			;vbl_routine
		move.l	(a0)+,(a1)+			;timera_routine
		move.l	(a0)+,(a1)+			;main_routine

	ifeq	music_sndh_fx
		move.b	-17(a1),$fffffa1f.w		;timera_delay+3	delay (data)
		move.b	-13(a1),$fffffa19.w		;timera_div+3	prediv (start Timer-A)
	endc

		move.l	-12(a1),a0			;vbl_routine
		jsr	(a0)

		jsr	music_play			;Call music driver

		
		cmp.b	#$39,$fffffc02.w
		bne.s	.nokey
		move.w	#1,exit_demo
.nokey:
		addq.w	#1,vbl_counter
		addq.w	#1,global_vbl
		movem.l	(sp)+,d0-a6
		rte


		section	data

;--------------	System variables - do not shift order
part_position:	dc.l	partlist
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
vbl_counter:	dc.w	0
global_vbl:	dc.w	0
exit_demo:	dc.w	0

		section	text
