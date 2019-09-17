
*  Subroutine  to  transform  a  block  of  memory  from  device  dependant
*  to  device  independant  or  visa-versa .
*  Written  using  Devpack 2 .

*  Passing  parameters  to  transform :

*  Put  address's  of  source  and  destination  memory  blocks  into 
*  mfdb's . These  can  be  the  same , however  this  takes  longer .

*	move.l	#source_blck,source_mfdb
*	move.l	#dest_blck,dest_mfdb	

*  Next, put  format  code  into  mfdb's . 
*  0 = device  dependant , 1 = device  independant .
	
*	move.w	#0 or #1,source_mfdb+10	
*	move.w	#1 or #0,dest_mfdb+10	
	
*  Then , put  pixel  width  &  height  of  block  into  d0  &  d1 .

*	move.w	pix_height,d0
*	move.w	pix_width,d1

*  Finally , call  subroutine .	
	
*	jsr	transform

transform	move.w	#110,contrl		(vdi vr_trnfm)		
	move.w	#0,contrl+2		
	move.w	#0,contrl+6
	move.w	ws_handle,contrl+12
	move.l	#strans_mfdb,contrl+14
	move.l	#dtrans_mfdb,contrl+18
	move.w	d0,source_mfdb+4	set pixel width	
	move.w	d0,dest_mfdb+4
	move.w	d1,source_mfdb+6	set pixel height
	move.w	d1,dest_mfdb+6
	ext.l	d0		calc word width
	divu	#16,d0
	cmpi.l	#$FFFF,d0		if rem
	bmi	.no_rem
	addq.w	#1,d0	
.no_rem	ext.l	d0
	move.w	d0,source_mfdb+8
	move.w	d0,dest_mfdb+8
	move.w	bit_planes,source_mfdb+12
	move.w	bit_planes,dest_mfdb+12
	jsr	vdi
	rts 

	data

source_mfdb	ds.w	10	
dest_mfdb	ds.w	10
bit_planes	ds.w	1	must be set depending upon screen res
