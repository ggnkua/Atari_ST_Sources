;Initialise wait form graph
;ENTRY (wait_max)=max number of steps
;EXIT  (wait_count)=0
;      (wait_x1)=x co-ord of left edge of bar
;      (wait_y1)=y co-ord of top edge of bar
;      (wait_y2)=y co-ord of bottom edge of bar
;      Wait bar form displayed on screen
;      Fill colour set
;      Graphics write mode set to 'replace'
;      Fill attributes changed (if used)

wait_init	movem.l	d0-d2/a0-a2,-(sp)
	v_hide_c
	vswr_mode	#1	replace
	vsf_color	#1	fill colour
;	vsf_style	#4	set fill style
;	vsf_interior	#2	set fill interior
	rsrc_gaddr	#0,#WAIT_FORM	display 'Please Wait'
	move.l	addr_out,a3
	form_center	a3
	objc_draw	a3,#0,#2,int_out+2,int_out+4,int_out+6,int_out+8
	objc_offset	a3,#WAIT_FORM1
	add	#1,int_out+2
	move	int_out+2,wait_x1  save x1 co-ord
	add	#1,int_out+4
	move	int_out+4,wait_y1  & y1 co-ord
	move	int_out+4,wait_y2  & y2 co-ord
	add	#16-3,wait_y2
	clr	wait_count	reset counter
	v_show_c	#1
	movem.l	(sp)+,d0-d2/a0-a2
	rts
	
;Update wait graph bar on screen
;ENTRY (wait_max)=max No of steps	
;      (wait_step)=current step count
;      (wait_x1)=x co-ord of left edge of bar
;      (wait_y1)=y co-ord of top edge of bar
;      (wait_y2)=y co-ord of bottom edge of bar
;EXIT  (wait_count) incremented once (until count=max)
;      Graph bar redrawn

wait_step	movem.l	d0-d2/a0-a2,-(sp)
	v_hide_c
	move	wait_count,d0	fetch count
	cmp	wait_max,d0	chk for max count
	beq	wait_step1	abort if already max
	add	#1,wait_count	inc counter
	mulu	#200,d0	* bar width
	divu	wait_max,d0	divide by max
	add	wait_x1,d0	add x1 offset
	vr_recfl	wait_x1,wait_y1,d0,wait_y2
	v_show_c	#1
wait_step1	movem.l	(sp)+,d0-d2/a0-a2
	rts

	section	BSS
	
wait_count	ds.w	1	wait display counter
wait_max	ds.w	1	max No of steps
wait_x1	ds.w	1	x1 co-ord of bar
wait_y1	ds.w	1	y1 co-ord of bar
wait_y2	ds.w	1	y2 co-ord of bar
