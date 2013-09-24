; Atari ST/e synclock demosystem
; March 28, 2010
;
; timers.s


		section	text


timer_a:	movem.l	d0-a6,-(sp)
		move.l	timera_routine,a0
		jsr	(a0)
		movem.l	(sp)+,d0-a6
		move.w	#$2300,sr
		rte

timer_b:
timer_c:
timer_d:
acia:
hbl:		rte

		section	text
