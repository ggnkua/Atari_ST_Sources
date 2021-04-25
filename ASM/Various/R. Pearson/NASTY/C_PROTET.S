* COPY PROTECTION, by R. Pearson, (c) NOVEMBER, 1987	 

* for ATARI ST

	opt	d+		* only used by HiSoft debugger

* copy protect //////////// for single sided disks, drive A only

	move.l	#format_d,a2		* message
	jsr	print_line
	jsr	wait_for_key
	
format					
	move.w	#$e5e5,-(sp)	
	move.l	#$87654321,-(sp)	* magic constant
	move.w	#1,-(sp)
	move.w	#0,-(sp)		* side 0
	move.w	#80,-(sp)		* track 80
	move.w	#9,-(sp)		* 9 sectors per track
	move.w	#0,-(sp)		* drive A
	clr.l	-(sp)
	move.l	#f_buffer,-(sp) 	* buffer
	move.w	#10,-(sp)		* format, xbios trap call
	trap	#14
	add.l	#26,sp
	tst	d0
	bmi	error

* write to sector, track 80, a simple checksum *

	move.l	#9999,s_buffer		* this can be any constant
	move.w	#1,-(sp)		* write to one sector only
	move.w	#0,-(sp)		* side 0
	move.w	#80,-(sp)		* track 80
	move.w	#1,-(sp)		* sector 1
	move.w	#0,-(sp)		* drive A
	clr.l	-(sp)
	move.l	#s_buffer,-(sp)
	move.w	#9,-(sp)
	trap	#14			* trap routine for write 
	add.l	#20,sp			* disk sector
	tst	d0
	bmi	error
	
* ONLY NEED 'READ SECTOR' TO CHECK PREVIOUS CODING IS OK/////////////

* read sector
	move.w	#1,-(sp)	read 1 sector
	move.w	#0,-(sp)	side 0
	move.w	#80,-(sp)	track 80
	move.w	#1,-(sp)	sector 1	
	move.w	#0,-(sp)	drive A
	clr.l	-(sp)
	move.l	#rd_s_buffer,-(sp)
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp
	tst	d0
	bmi	error
	cmpi.l	#9999,rd_s_buffer
	bne	error
	move.l	#correct,a2
	jsr	print_line
	jsr	wait_for_key
	bra	finish

*/////// end of 'read sector' //////////////////

print_line
	move.l	a2,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

wait_for_key
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
error					

* if error exit program
	
finish
	clr.w	-(sp)
	trap	#1


f_buffer
	ds.b	$2000		8K buffer
	even	

format_d
	dc.b	'place disk in drive A to write checksum,' 
	dc.b   	' press any key to continue',0
	even
	
s_buffer
	ds.b	512
	
rd_s_buffer
	ds.b	512
	even
correct
	dc.b	10,13,'copy protection ok!!  press any key to exit',0
