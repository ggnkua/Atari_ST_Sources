;Finds a predefined box with mouse cursor
;ENTRY  a3=address of box list
;       d0=x co-ord of mouse
;       d1=y co-ord of mouse
;EXIT   d4=-1 (not valid) or box number (0-n)

box_find	move.l	a3,-(sp)	save a3
	move	#-1,d4	set counter
	sub.l	#8,a3	dec list pointer
box_find1	add.l	#8,a3	inc list pointer
	addq	#1,d4	inc counter
	cmp	#-1,(a3)	end of list ?
	beq	box_find2	bra if so
	cmp	(a3),d0	
	ble	box_find1	loop if to left
	cmp	4(a3),d0
	bge	box_find1	loop if to right
	cmp	2(a3),d1
	ble	box_find1	loop if above
	cmp	6(a3),d1
	bge	box_find1	loop if below
box_find3	move.l	(sp)+,a3	must be in box, d4=box No
	rts
	
box_find2	move	#-1,d4	d4=-1 if no box found
	bra	box_find3

;Screen box list

scrn_list	dc.w	x_top_left	box No 0
	dc.w	y_top_left
	dc.w	x_bottom_right
	dc.w	y_bottom_right
	
	dc.w	x_top_left	box No 1
	dc.w	y_top_left
	dc.w	x_bottom_right
	dc.w	y_bottom_right
	
	dc.w	-1	end of list

