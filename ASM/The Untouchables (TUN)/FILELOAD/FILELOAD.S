**************************************************
*
* TOS File Loader by Mat of the Untouchables
*
* A0 - Pointer to filename
* A1 - Address of Destination
*

loadem	clr.w	-(sp)			Read/Write
	move.l	a0,-(sp)      		Filename
	move.w	#$3d,-(sp)		OPEN
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	quit			Error so quit

	move.w	d0,d7			Copt file handle
	move.l	a1,-(sp)		Buffer
	move.l	#$ffffff,-(sp)		All of the file
	move.w	d0,-(sp)		HANDLE
	move.w	#$3f,-(sp)		READ
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	quit

	move.l	d0,d5			Copy number of bytes read in
	subq.l	#1,d5			Minus one
	move.w	d7,-(sp)		HANDLE
	move.w	#$3e,-(sp)		CLOSE
	trap	#1
	addq.l	#4,sp
	rts
