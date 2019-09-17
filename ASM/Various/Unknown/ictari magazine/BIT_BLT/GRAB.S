
*  Subroutine  to  grab  an  area  of  the  screen  and  store  it  in  a    
*  buffer .
*  Written  using  Devpack 2 .                      
   
*  Passing  parameters  to  grab :

*  Put  address  of  buffer  to  hold  grab  into  the  mfdb .        

*	move.l	#scrn_buffer,dest_mfdb   

*  Next , put  the  bounding  rectangle  coordinates  (in  vdi  format)
*  of  the  screen  area  to  grab  into  coordinate  array .     	
*  NOTE:- These  coordinates  must  not  describe  an  area  whose  memory
*  is  greater  than  the  buffer  which  will  contain  it .
  	
*	move.w	top_left_x,x1	                
*	move.w	top_left_y,y1                   
*	move.w	bot_right_x,x2                   
*	move.w	bot_right_y,y2                   

*  And  finally , call  subroutine .

*	jsr	grab                         

grab	move.l	#0,source_mfdb	0 = screen  address
	move.w	x2,d0	          	calc pixel width of
	sub.w	x1,d0		screen area
	addq.w	#1,d0
	move.w	d0,dest_mfdb+4
	move.w	d0,d1		calc word width of
	ext.l	d1		screen area
	divu	#16,d1
	cmpi.l	#$FFFF,d1		if there is a remainder
	bmi	.no_rem		
	addq.w	#1,d1		add another word 
.no_rem	move.w	d1,dest_mfdb+8
	move.w	y2,d1		calc pixel height of
	sub.w	y1,d1		screen area
	addq.w	#1,d1
	move.w	d1,dest_mfdb+6
	move.w	#0,dest_mfdb+10	fill remaining dest mfdb
	move.w	bit_planes,dest_mfdb+12
	move.w	#0,dest_mfdb+14
	move.w	#0,dest_mfdb+16
	move.w	#0,dest_mfdb+18
	move.w	#109,contrl		(vdi vro_cpyfm)
	move.w	#4,contrl+2
	move.w	#1,contrl+6
	move.w	ws_handle,contrl+12
	move.l	#source_mfdb,contrl+14
	move.l	#dest_mfdb,contrl+18
	move.w	#3,intin		replace mode
	move.w	x1,ptsin		bounding rect of source
	move.w	y1,ptsin+2		
	move.w	x2,ptsin+4		
	move.w	y2,ptsin+6		
	move.w	#0,ptsin+8		bounding rect of dest		
	move.w	#0,ptsin+10		These are the source coords	
	subq.w	#1,d0		shifted to the origon of		
	subq.w	#1,d1		the buffer . This enables
	move.w	d0,ptsin+12		the buffer to be only as 		
	move.w	d1,ptsin+14		large as the screen area 
	jsr	vdi		it contains .
	rts

	data

x1	ds.w	1	coordinate array
y1	ds.w	1
x2	ds.w	1
y2	ds.w	1
source_mfdb	ds.w	10
dest_mfdb	ds.w	10
bit_planes	ds.w	1	this must be set depending upon res

