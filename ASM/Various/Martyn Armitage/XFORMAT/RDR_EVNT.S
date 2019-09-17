* redraw the window
* enter with a0 holding address of MESSAGE BUFFER
redraw		movem.w	6(a0),d0		get window handle
		cmp.w	window_handle(a6),d0	my window ?
		beq.s	re_do1			yes
		rts

re_do1		movem.w	8(a0),d0-d3		get redraw coords
		movem.w	d0-d3,rd_coords(a6)	save them
		bsr	hide_mouse
		move.w	#1,int_in(a6)
		gem	WIND_UPDATE
		move.w	#11,int_in+2(a6)		get 1st rect
next_rect	move.w	window_handle(a6),int_in(a6)
		gem	WIND_GET
		movem.w	int_out+2(a6),d0-d3	get coords
		move.w	d2,d4			copy height
		or.w	d3,d4			or width onto height
		beq.s	re_done			no height or width present

re_do2		bsr.s	clip			clip coords to redraw
		bmi.s	re_do3			not in redraw
		bsr	clipping_on		turn clipping on
		bsr	cls			clear the rectangle
		bsr	display			display the rectangle
		bsr	clipping_off		turn clipping off

re_do3		move.w	#12,int_in+2(a6)		get next rect
		bra.s	next_rect		get next rectangle

* no more rectangles
re_done		clr.w	int_in(a6)
		gem	WIND_UPDATE		end update
		bsr	show_mouse
		rts		

* clip coords to screen
* enter with:-
* coords of area in window to redraw in d0-d3.w (from rectangle list)
* total redraw coords in rd_coords
* returns with fill area in d0-d3.w -=IF=- area is in redraw
* else returns with -1 ($ffff) in d0.w

* labels used:
* wx, wy, wx1, wy1 >w = window
* rx, ry, rx1, ry1 >r = rectangle (redraw)

wx		equr	d0
wy		equr	d1
wx1		equr	d2
wy1		equr	d3
rx		equr	d4
ry		equr	d5
rx1		equr	d6
ry1		equr	d7

clip		add.w	d0,d2		get Wx1 coord (window)
		add.w	d1,d3		get Wy1 coord (window)

* d0-d3 are now screen coordinates of rectangle list rx, rx1, ry, ry1

		movem.w	rd_coords(a6),d4-d7	get redraw coords
		add.w	d4,d6		get Rx1 coord (redraw)
		add.w	d5,d7		get Ry1 coord (redraw)

* d4-d7 are now screen coordinates of redraw area
* right down to business...
* using names for the registers... see the equates at the top
		cmp.w	wx,rx		rx > wx ?
		bhs.s	clip01		yes
		cmp.w	wx,rx1		rx1 > wx ?
		ble	not_in_redraw	no
		cmp.w	wx1,rx1		rx1 > wx1 ?
		bhs.s	clip02		yes
		move.w	wx,xstart(a6)	save start x co-ord
		move.w	rx1,xend(a6)	save end x co-ord
		bra.s	clip03
clip01		cmp.w	wx1,rx		rx > wx1 ?
		bhs	not_in_redraw	yes
		cmp.w	wx1,rx1		rx1 > wx1 ?
		bhs.s	clip04		yes
		move.w	rx,xstart(a6)	save start xcoord
		move.w	rx1,xend(a6)	save end x coord
		bra.s	clip03
clip02		move.w	wx,xstart(a6)	save start x co-ord
		move.w	wx1,xend(a6)	save end x co-ord
		bra.s	clip03
clip04		move.w	rx,xstart(a6)	save start x co-ord
		move.w	wx1,xend(a6)	save end x co-ord

* now that the x co-ords have been got lets get the y coords
clip03		cmp.w	wy,ry		ry > wy ?
		bhs.s	clip05		yes
		cmp.w	wy,ry1		ry1 > wy ?
		ble	not_in_redraw	no
		cmp.w	wy1,ry1		ry1 > wy1 ?
		bhs.s	clip06		yes
		move.w	wy,ystart(a6)	save start y coord
		move.w	ry1,yend(a6)	save end y coord
		bra.s	coords_got
clip05		cmp.w	wy1,ry		ry > wy1 ?
		bhs.s	not_in_redraw	yes
		cmp.w	wy1,ry1		ry1 > wy1 ?
		bhs.s	clip07		yes
		move.w	ry,ystart(a6)	save start y coord
		move.w	ry1,yend(a6)	save end y coord
		bra.s	coords_got
clip06		move.w	wy,ystart(a6)	save start y coord
		move.w	wy1,yend(a6)	save end y coord
		bra.s	coords_got
clip07		move.w	ry,ystart(a6)	save start y coord
		move.w	wy1,yend(a6)	save end ycoord
coords_got	movem.w	xstart(a6),d0-d3	get coords for fill
		rts
not_in_redraw	move.w	#-1,d0		no redraw
		rts

* turn clipping on
* enter with coords to clip to in
clipping_on	move.w	#1,intin(a6)
		bra.s	set_clipping

* turn clipping off
clipping_off	clr.w	intin(a6)

set_clipping	move.l	#$40000,contrl+2(a6)
		move.l	#$10000,contrl+6(a6)
		lea	ptsin(a6),a0
		lea	xstart(a6),a1			addr of coords
		move.l	(a1)+,(a0)+
		move.l	(a1),(a0)
		vdi	VS_CLIP
		rts

clip_x		rs.w	1
clip_y		rs.w	1
clip_w		rs.w	1
clip_h		rs.w	1
rd_coords	rs.w	4	total redraw coords
xstart		rs.w	1	x coord to redraw
ystart		rs.w	1	y coord to redraw
xend		rs.w	1	end x coord
yend		rs.w	1	end y coord
