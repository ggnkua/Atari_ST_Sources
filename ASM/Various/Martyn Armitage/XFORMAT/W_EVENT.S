MU_KEYBD	equ	1
MU_BUTTON	equ	2
MU_M1		equ	4
MU_M2		equ	8
MU_MESAG	equ	16
MU_TIMER	equ	32

wait_event	lea	int_in(a6),a0		int_in array
		lea	event_type(a6),a1	address of param table

		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+

		move.l	a1,addr_in(a6)
		gem	EVNT_MULTI
		lea	event_buffer(a6),a0	buffer address
evnt_out	rts

event_type	rs.w	1		messsage event
mouse_clicks	rs.w	1		number of clicks
mouse_button	rs.w	1		button to wait for
m_button_status	rs.w	1		button status for exit

m_entry_exit1	rs.w	1		entry or exit
mouse_x1	rs.w	1		mouse x coord
mouse_y1	rs.w	1		mouse y coord
m_rect1_width	rs.w	1		width of rectangle
m_rect1_height	rs.w	1		height of rectangle

m_entry_exit2	rs.w	1		entry or exit
mouse_x2	rs.w	1		mouse x coord
mouse_y2	rs.w	1		mouse y coord
m_rect2_width	rs.w	1		width of rectangle
m_rect2_height	rs.w	1		height of rectangle

timer_lo	rs.w	1		timer lo count
timer_hi	rs.w	1		timer hi count

event_buffer	rs.b	16		16 byte buffer for mesages
