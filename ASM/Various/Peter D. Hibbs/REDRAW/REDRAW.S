;Redraw corrupted part of screen
;ENTRY (s_buffer...) holds screen copy 32000 bytes
;      (w_handle) holds window ident No
;EXIT  Screen data redrawn from (s_buffer..)

redraw	movem.l	a0-a2/d0-d5,-(sp)

	move	#640,d5	hi/med rez=640 pix width
	move	#400,d3	hi rez height=400 pix
	vq_extnd	#1	fetch extended attr
	move	intout+8,d4	fetch No of planes
	cmp	#1,d4	chk if Hi rez
	beq	redraw1	skip if hi rez
	move	#200,d3	Not Hi, must be med or low rez
	cmp	#2,d4	chk if med rez
	beq	redraw1	skip if yes
	move	#320,d5	low res=320 pix width
	
redraw1	v_hide_c		hide mouse
	wind_update	#1	begin update
	wind_get	w_handle,#11	get first rectangle

redraw2	move	int_out+6,d0	chk for zero width
	or	int_out+8,d0	and zero height
	beq	redraw3	exit if done

	clr.l	dest_mfdb	    use screen for destination
	move.l	#s_buffer,srce_mfdb fetch scrn buffer addr
	move	d5,srce_mfdb+4      set width (pix)
	move	d3,srce_mfdb+6      set height (pix)
	move	d5,d0               set width (words) (width/16)
	lsr	#4,d0	    width/16
	move	d0,srce_mfdb+8	    set width (words)
	clr	srce_mfdb+10        set mode
	move	d4,srce_mfdb+12     set planes
	clr	srce_mfdb+14        clr res1
	clr	srce_mfdb+16        clr res2
	clr	srce_mfdb+18        clr res3

	move	int_out+2,ptsin	    set x1 co-ords
	move	int_out+2,ptsin+8
	move	int_out+4,ptsin+2   set y1 co-ords
	move	int_out+4,ptsin+10
	move	int_out+2,d0        set x2 co-ords
	add	int_out+6,d0
	sub	#1,d0
	move	d0,ptsin+4
	move	d0,ptsin+12
	move	int_out+4,d0        set y2 co-ords
	add	int_out+8,d0
	sub	#1,d0
	move	d0,ptsin+6
	move	d0,ptsin+14

	vro_cpyfm	#3,#srce_mfdb,#dest_mfdb  copy data to scrn

	wind_get	w_handle,#12	get next rectangle
	bra	redraw2
	
redraw3	wind_update	#0	end update
	v_show_c	#1	show mouse
	movem.l	(sp)+,a0-a2/d0-d5
	rts

;Save screen image to (s_buffer..)
;ENTRY (screen) holds address of start of screen
;EXIT  Screen data copied to buffer (no registers changed)

save_scrn	movem.l	d0-d2/a0-a2,-(sp)
	v_hide_c		hide mouse
	move.l	screen,a0	fetch screen addr
	lea	s_buffer,a1	locate buffer
save_scrn2	move	#8000-1,d0	set repeat No
save_scrn1	move.l	(a0)+,(a1)+	copy data
	dbra	d0,save_scrn1	repeat
	v_show_c	#1	show mouse
	movem.l	(sp)+,d0-d2/a0-a2
	rts
	
;Restore (s_buffer..) to screen
;ENTRY (s_buffer..) holds screen image
;EXIT  Screen data restored

restore_scrn	movem.l	d0-d2/a0-a2,-(sp)
	v_hide_c		hide mouse
	move.l	screen,a1	fetch screen addr
	lea	s_buffer,a0	locate buffer
	bra	save_scrn2	use 'save_scrn' code

	section	BSS
	
screen	ds.l	1	screen address
w_handle	ds.w	1	window handle
srce_mfdb	ds.w	10	source data
dest_mfdb	ds.w	10	destination data
s_buffer	ds.b	32000	screen buffer