*	NASTY.S (c) R. Pearson 1988

* Use in conjunction with C_PROTET.S

* This source code attempts to read
* track 80 checksum. If checksum cannot be found then program
* will create hidden TRASH file.

	opt	d+	* used when debugging

* copy protect test////////////for single sided disks, drive A


* read sector
	move.w	#1,-(sp)		* read 1 sector
	move.w	#0,-(sp)		* side 0
	move.w	#80,-(sp)		* track 80
	move.w	#1,-(sp)		* sector 1	
	move.w	#0,-(sp)		* drive A
	clr.l	-(sp)
	move.l	#rd_s_buffer,-(sp)
	move.w	#8,-(sp)
	trap	#14			* xbios trap routine to 
	add.l	#20,sp			* read a sector
	tst	d0
	bmi	create_trash_file
	cmpi.l	#9999,rd_s_buffer
	beq	error 	** not really errror; must be original disk

create_trash_file

	move.w	#2,-(sp) 	*attribute #0 will create non-hidden file
	move.l	#trash_filename,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	error		* maybe write protect on?
	move	d0,handle

	move.l	#20,buffer
*write sum to file

	move.l	#buffer,-(sp)
	move.l	#4,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0  	
	bmi error	*error?
	
*close file
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	error	 	* error?

		
error
	clr.w	-(sp)		back to desktop
	trap	#1
	

rd_s_buffer
	ds.b	512
	even
handle	ds.w	1
	even
trash_filename	dc.b	'TRASH.DSK',0
	even
buffer	ds.l	1
	

	


