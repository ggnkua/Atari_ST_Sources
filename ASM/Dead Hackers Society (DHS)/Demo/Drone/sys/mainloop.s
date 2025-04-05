; Atari ST/e synclock demosystem
; March 28, 2010
;
; mainloop.s


		section	text


mainloop:
		tst.w	vbl_counter
		beq.s	mainloop

		clr.w	vbl_counter

		move.l	main_routine,a0
		jsr	(a0)

		tst.w	exit_demo
		beq.s	mainloop
		

		section	text
