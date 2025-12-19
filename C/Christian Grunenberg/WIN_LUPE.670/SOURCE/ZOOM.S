
		EXPORT  zoom_var
		EXPORT	zoom_inter
		EXPORT  zoom_pixel

		EXPORT  init_zoom_var
		EXPORT	init_zoom_pixel

		EXPORT	cache_flush

		IMPORT  p_faktor
		IMPORT	ind_tab
		IMPORT	longs
		IMPORT	il_offset

; void init_zoom_var()

init_zoom_var:
		move.l	d3,-(sp)

		moveq.l	#0,d3
		move.w	p_faktor,d0
		btst	#0,d0
		bne.s	odd

		moveq.l	#-1,d3

odd:	lea.l	make_zoom(pc),a1
		moveq.l	#1,d2
twice_copy:
		move.l	x_loop(pc),(a1)+

		move.w	p_faktor,d0
		cmp.w	#4,d0
		beq.s	copy_4
		cmp.w	#3,d0
		beq.s	copy_3
		cmp.w	#2,d0
		bne.s	copy_v

copy_2:	lea.l	x_loop_2(pc),a0
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)+
		bra.s	twice

copy_3:	lea.l	x_loop_3(pc),a0
		bra.s	copy_x

copy_4: lea.l	x_loop_4(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0),(a1)+
		bra.s	twice

copy_v: lea.l	x_loop_v(pc),a0
copy_x:	move.l	(a0)+,(a1)+
		move.l	(a0),(a1)+

		tst.b	d3
		bne.s	word_long

		subq.w	#1,d0
		move.w	bmove(pc),d1

		tst.w	d2
		beq.s	byte_copy

		addq.w	#1,d0
word_long:
		lsr.w	#1,d0
		subq.w	#1,d0
		beq.s	word_copy

		move.w	lmove(pc),d1
long_copy:
		move.w	d1,(a1)+
		subq.w	#2,d0
		bgt.s	long_copy
		bmi.s	last_byte

word_copy:
		move.w	wmove(pc),d1
byte_copy:
		move.w	d1,(a1)+
		dbra	d0,byte_copy

last_byte:
		tst.b	d3
		bne.s	twice

		tst.w	d2
		beq.s	twice

		move.w	bmove(pc),(a1)+

twice:	dbra	d2,twice_copy

		lea.l	make_zoom-2(pc),a0
		sub.l	a1,a0
		move.w	a0,next_xv+2

		move.l	next_xv(pc),(a1)+

		move.w	p_faktor,d0
		subq.w	#1,d0

		cmp.w	#6,d0
		bge.s	to_big

		mulu.w	p_faktor,d0
		subq.w	#1,d0
		move.w	y_loop_v(pc),(a1)+
		bra.s	do_copy

to_big:	move.w	x_copy_v(pc),(a1)+

do_copy:move.l	a1,d3

l_copy:	tst.w	d0
		beq.s	w_copy
		bmi.s	copy_loop

		move.w	move_l(pc),(a1)+
		subq.w	#2,d0
		bra.s	l_copy

w_copy:	move.w	move_w(pc),(a1)+

copy_loop:
		sub.l	a1,d3
		subq.w	#2,d3
		move.w	d3,next_cv+2
		move.l	next_cv(pc),(a1)+

		lea.l	y_loop_v-2(pc),a0
		sub.l	a1,a0
		move.w	a0,next_yv+2
		move.l	next_yv(pc),(a1)+

		lea.l	planes_v-2(pc),a0
		sub.l	a1,a0
		move.w	a0,next_pv+2

		lea.l	next_pv(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

		move.l	(sp)+,d3
		rts

; void zoom_var(int wd, int h, int pl,int *s, int *d)
;				    d0	   d1	   d2	  a0	  a1

zoom_var:
		movem.l	d3-d5/a2-a6,-(sp)

		lea.l	ind_tab,a2
		move.l	(a2),a6

		move.w	p_faktor,d5
		subq.w	#1,d5
		cmp.w	#5,d5
		ble.s	small

		move.w	d5,d3	; (faktor-1)*wd-1
		mulu.w	d0,d3
		subq.w	#1,d3
		move.w	d3,a5

small:	subq.w	#1,d0
		subq.w	#1,d1
		subq.w	#1,d2

planes_v:
		move.w	d1,d5

y_loop_v:
		move.w	d0,d3
		move.l	a1,a3

make_zoom:
		dcb.w	120,0

x_loop:
		moveq.l	#0,d4
		move.b	(a0)+,d4

next_xv:dbra	d3,make_zoom

x_copy_v:
		move.w	a5,d3
next_cv:dbra	d3,x_copy_v
next_yv:dbra	d5,y_loop_v
next_pv:dbra	d2,planes_v

		movem.l (sp)+,d3-d5/a2-a6
		rts

move_w:	move.w	(a3)+,(a1)+
move_l:	move.l	(a3)+,(a1)+

x_loop_v:
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a2,d4.w),a4

x_loop_2:
		add.w	d4,d4
		move.w	(a6,d4.w),(a1)+

x_loop_3:
		add.w	d4,d4
		add.w	d4,d4
		lea.l	(a6,d4.w),a4

x_loop_4:
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a6,d4.w),(a1)+

lmove:	move.l	(a4)+,(a1)+
wmove:	move.w	(a4)+,(a1)+
bmove:	move.b	(a4)+,(a1)+

; void init_zoom_pixel(int bytes,int invert)
;						   d0		 d1

init_zoom_pixel:
		move.l	a2,-(sp)

		subq.w	#1,d0	; (bytes-1)*4
		add.w	d0,d0
		add.w	d0,d0

		lea.l	make_pixel(pc),a0

		tst.w	d1
		bne.s	invert

		lea.l	pixel_tab(pc),a1
		bra.s	tabelle

invert:	lea.l	pixel_tab_inv(pc),a1

tabelle:add.w	d0,a1
		move.l	(a1),a1

		move.w	(a1)+,d1
		bmi.s	copy
init_code:
		move.w	(a1)+,(a0)+
		dbra	d1,init_code

copy:	move.w	(a1)+,d1
		move.w	p_faktor,d2
		subq.w	#1,d2

copy_code:
		move.l	a1,a2
		move.w	d1,d0
copy_instr:
		move.w	(a2)+,(a0)+
		dbra	d0,copy_instr
		dbra	d2,copy_code

		lea.l	make_pixel-2(pc),a1
		sub.l	a0,a1
		move.w	a1,next_xp+2

		lea.l	next_xp(pc),a1
		moveq.l	#(next_yp-next_xp)/2-1,d0
loop_code:
		move.w	(a1)+,(a0)+
		dbra	d0,loop_code

		lea.l	y_loop_p-2(pc),a1
		sub.l	a0,a1
		move.w	a1,next_yp+2

		lea.l	next_yp(pc),a1
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.w	(a1),(a0)

		move.l	(sp)+,a2
		rts

pixel_tab:
		dc.l byte_1,byte_2,byte_3,byte_4
pixel_tab_inv:
		dc.l byte_i_1,byte_i_2,byte_i_3,byte_i_4

byte_1: dc.w	0			; init-Befehle - 1
		move.b	(a0)+,d6
		dc.w	0			; copy-Befehle - 1
		move.b	d6,(a1)+

byte_2: dc.w	0
		move.w	(a0)+,d6
		dc.w	0
		move.w	d6,(a1)+

byte_4: dc.w	0
		move.l	(a0)+,d6
		dc.w	0
		move.l	d6,(a1)+

byte_3: dc.w	2
		move.b	(a0)+,d5
		move.b	(a0)+,d6
		move.b	(a0)+,d7
		dc.w	2
		move.b	d5,(a1)+
		move.b	d6,(a1)+
		move.b	d7,(a1)+

byte_i_1:dc.w	1			; init-Befehle - 1
		move.b	(a0)+,d6
		not.b	d6
		dc.w	0			; copy-Befehle - 1
		move.b	d6,(a1)+

byte_i_2:dc.w	1
		move.w	(a0)+,d6
		not.w	d6
		dc.w	0
		move.w	d6,(a1)+

byte_i_4:dc.w	1
		move.l	(a0)+,d6
		not.l	d6
		dc.w	0
		move.l	d6,(a1)+

byte_i_3:dc.w	5
		move.b	(a0)+,d5
		move.b	(a0)+,d6
		move.b	(a0)+,d7
		not.b	d5
		not.b	d6
		not.b	d7
		dc.w	2
		move.b	d5,(a1)+
		move.b	d6,(a1)+
		move.b	d7,(a1)+

; void zoom_pixel(int wd, int h, int bytes,int *s, int *d)
;					  d0	  d1	 d2 	   a0	   a1

zoom_pixel:
		movem.l	d3-d7/a2,-(sp)

		move.w	longs,d4	; faktor*(faktor-1)/2*wd-1
		mulu.w	d0,d4
		subq.w	#1,d4

		lsl.w	#4,d0
		subq.w	#1,d0
		subq.w	#1,d1
		subq.w	#1,d2

y_loop_p:
		move.w	d0,d3
		move.l	a1,a2

make_pixel:
		dcb.w	128,0

next_xp:dbra	d3,make_pixel

		move.w	d2,d5
x_copy_bytes:
		move.w	d4,d3
x_copy_p:
		rept 8
		move.l	(a2)+,(a1)+
		endm
		dbra	d3,x_copy_p
		dbra	d5,x_copy_bytes

next_yp:dbra	d1,y_loop_p

		movem.l (sp)+,d3-d7/a2
		rts

; void zoom_inter(int wd, int h, int pl,int *s, int *d)
;					  d0	 d1		 d2		a0		a1

zoom_inter:
		movem.l	d3-d7/a2-a6,-(sp)

		lea.l	ind_tab,a2
		move.w	il_offset,d6	; Offset : planes*(faktor-1)*2
		move.w	p_faktor,d5
		subq.w	#1,d5
		
		move.w	longs,d3		; faktor*(faktor-1)/2*wd-1
		mulu.w	d0,d3
		subq.w	#1,d3
		move.w	d3,a5

		subq.w	#1,d0
		subq.w	#1,d1
		subq.w	#1,d2

		swap	d1
		move.w	d2,d1
		add.w	d1,d1
		swap	d1

		btst	#0,d5
		beq.s	y_loop_o

		lsr.w	#1,d5

y_loop_i:
		swap	d1
		move.w	d0,d3
		move.l	a1,a6

x_loop_i:
		move.w	d2,d7

planes_i:
		move.l	a6,a3
		addq.w	#2,a6

		moveq.l	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a2,d4.w),a4
		move.w	d5,d4

lo_byte_i:
		move.w	(a4)+,(a3)+
		add.w	d1,a3
		dbra	d4,lo_byte_i

		moveq.l	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a2,d4.w),a4
		move.w	d5,d4

hi_byte_i:
		move.w	(a4)+,(a3)+
		add.w	d1,a3
		dbra	d4,hi_byte_i

		dbra	d7,planes_i
		add.w	d6,a6
		dbra	d3,x_loop_i

		move.w	d2,d7
x_copy_bytes_i:
		move.w	a5,d3
x_copy_i:
		move.l	(a1)+,(a6)+
		dbra	d3,x_copy_i
		dbra	d7,x_copy_bytes_i

		move.l	a6,a1
		swap	d1
		dbra	d1,y_loop_i

return_inter:
		movem.l (sp)+,d3-d7/a2-a6
		rts

y_loop_o:
		swap	d1

		move.w	d0,d3
		move.l	a1,a6

x_loop_o:
		move.w	d2,d7

planes_o:
		move.l	a6,a3
		addq.w	#2,a6

		moveq.l	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a2,d4.w),a4
		move.w	d5,d4

lo_byte_o:
		move.b	(a4)+,(a3)+
		subq.w	#1,d4
		bmi.s	next_byte_o

		move.b	(a4)+,(a3)+
		add.w	d1,a3
		dbra	d4,lo_byte_o

next_byte_o:
		moveq.l	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		add.w	d4,d4
		move.l	(a2,d4.w),a4
		move.w	d5,d4

hi_byte_o:
		move.b	(a4)+,(a3)+
		subq.w	#1,d4
		bmi.s	next_plane_o

		add.w	d1,a3
		move.b	(a4)+,(a3)+
		dbra	d4,hi_byte_o

next_plane_o:
		dbra	d7,planes_o
		add.w	d6,a6
		dbra	d3,x_loop_o

		move.w	d2,d7
x_copy_bytes_o:
		move.w	a5,d3
x_copy_o:
		move.l	(a1)+,(a6)+
		dbra	d3,x_copy_o
		dbra	d7,x_copy_bytes_o

		move.l	a6,a1
		swap	d1
		dbra	d1,y_loop_o
		bra		return_inter

; void cache_flush();

cache_flush:
		movec	cacr,d0
		bset	#3,d0
		movec	d0,cacr
		rts

		end
