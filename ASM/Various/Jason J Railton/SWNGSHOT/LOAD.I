*** MACRO TO LOAD A FILE ***

*
* Include between STARTUP and MAIN program.
*
* Call with LOAD file_name,address,length
* where: file_name - points to the file name (then a 0b, then 'even').
*        address   - is the address of a _pointer_ to the load address.
*        length    - is the length of the file in bytes.
*
* Alternatively, set up the following:
*	a0 - Address of filename, terminated with a 0 byte.
*	a1 - Address to load file to.
*	d1 - Length of file to load.
*
* And call the main routine with:
*	jsr do_load	
*
* Either way, on return a0,a1 and d1 are as above, and d0 contains
* either a 0 for a successful operation, or -1 for an error.
*

LOAD	MACRO
	move.l	#\1,a0
	move.l	\2,a1
	move.l	#\3,d1
	jsr	do_load
	ENDM

do_load
	clr.w	-(sp)			|Read only.
	move.l	a0,-(sp)		|Address of filename, param. 1.
	move.w	#$3d,-(sp)		|For FOPEN.
	trap	#1			|
	addq.l	#8,sp			|FOPEN
	tst.l	d0			|d0 is either the handle
	blt	bad_load		|or a negative error code.
	
	move.l	a1,-(sp)		|Address to load to, param. 2.
	move.l	d1,-(sp)		|File length, param 3.
	 move.l	d0,d1			 |Preserve file handle.
	move.w	d0,-(sp)		|File handle from FOPEN.
	move.w	#$3f,-(sp)		|For FREAD.
	trap	#1			|
	add.l	#12,sp			|FREAD
	tst.l	d0			|d0 is either the number of
	ble	bad_load		|bytes read, 0 or -ve.
	
	move.w	d1,-(sp)		|Why d0 (handle) was preserved.
	 move.l	d0,d1			|Return no bytes loaded to d1.
	move.w	#$3e,-(sp)		|For FCLOSE.
	trap	#1			|
	addq.l	#4,sp			|FCLOSE
	tst.l	d0			|d0 is 0 for success,
	blt	bad_load		|-ve for failure.
	
	clr.l	d0			|Signal OK.
	rts				|Finished.

bad_load
	move.l	#-1,d0			|Signal error.
	rts				|Return.
