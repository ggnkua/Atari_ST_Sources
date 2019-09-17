* code to hide / unhide the mouse
* using this is better than the ALINE equivalent

* make the mouse an arrow
arrow_mouse	clr.w	int_in(a6)	arrow
		bra.s	set_mouse

* make the mouse a cursor
cursor_mouse	move.w	#1,int_in(a6)	cursor
		bra.s	set_mouse

* make the mouse a bee
bee_mouse	move.w	#2,int_in(a6)	bee
		bra.s	set_mouse

* make the mouse a finger
finger_mouse	move.w	#3,int_in(a6)

* set the mouse
set_mouse	gem	GRAF_MOUSE
mouse_out	rts

* hide the mouse
hide_mouse	move.w	#256,int_in(a6)		disable
		bra.s	set_mouse

show_mouse	move.w	#257,int_in(a6)		enable
		bra.s	set_mouse

* test the mouse button
test_m_button	clr.w	contrl+2(a6)
		move.w	#1,contrl+4(a6)
		clr.w	contrl+6(a6)
		move.w	#1,contrl+8(a6)
		move.w	device(a6),contrl+12(a6)
		vdi	VQ_MOUSE
		move.w	intout(a6),d0		get button
		rts
