
*  Subroutine  to  paste  an  area  of  memory , previously  defined  with
*  grab , to  the  screen .
*  Written  using  Devpack 2 .                      
   
*  Passing  parameters  to  paste :

*  Put  address  of  buffer  to  holding  data  into  the  mfdb .        

*	move.l	#scrn_buffer,source_mfdb   

*  Next , put  the  bounding  rectangle  coordinates  (in  vdi  format)
*  of  the  memory  area  to  paste  into  coordinate  array .     	
*  NOTE:- These  coordinates  must  not  describe  an  area  whose  memory
*  is  greater  than  the  screen  which  will  contain  it .  Also  they
*  must  be  of  the  same  dimensions  as  those  used  in  grab (this
*  does  not  mean  they  must  be  the  same  coordinates , just  that
*  the  width  and  height  must  be  the  same ) .
  	
*	move.w	top_left_x,x1	                
*	move.w	top_left_y,y1                   
*	move.w	bot_right_x,x2                   
*	move.w	bot_right_y,y2                   

*  And  finally , call  subroutine .

*	jsr	paste                        
	
paste	move.l	#0,dest_mfdb	0 = screen
	move.w	x2,d0	          	calc source width
	sub.w	x1,d0		in pixels
	addq.w	#1,d0
	move.w	d0,source_mfdb+4
	move.w	d0,d1		calc source width
	ext.l	d1		in words
	divu	#16,d1
	cmpi.l	#$FFFF,d1		if there is a remainder
	bmi	.no_rem		
	addq.w	#1,d1		add another word 
.no_rem	move.w	d1,source_mfdb+8
	move.w	y2,d1		calc source height
	sub.w	y1,d1		in pixels
	addq.w	#1,d1
	move.w	d1,source_mfdb+6
	move.w	#0,source_mfdb+10	fill remaining source mfdb
	move.w	bit_planes,source_mfdb+12
	move.w	#0,source_mfdb+14
	move.w	#0,source_mfdb+16
	move.w	#0,source_mfdb+18
	move.w	#109,contrl		(vdi vro_cpyfm)
	move.w	#4,contrl+2
	move.w	#1,contrl+6
	move.w	ws_handle,contrl+12
	move.l	#source_mfdb,contrl+14
	move.l	#dest_mfdb,contrl+18
	move.w	paste_mode,intin
	move.w	#0,ptsin		bounding rect of source
	move.w	#0,ptsin+2		this is dest coords
	subq.w	#1,d0		shifted to memory block
	subq.w	#1,d1		origon (0,0) .
	move.w	d0,ptsin+4
	move.w	d1,ptsin+6
	move.w	x1,ptsin+8		bounding rect of dest
	move.w	y1,ptsin+10
	move.w	x2,ptsin+12
	move.w	y2,ptsin+14
	jsr	vdi
	rts

	data

x1	ds.w	1	coordinate array
y1	ds.w	1
x2	ds.w	1
y2	ds.w	1
source_mfdb	ds.w	10
dest_mfdb	ds.w	10
paste_mode	dc.w	3	replace mode
bit_planes	ds.w	1	this must be set depending upon res

