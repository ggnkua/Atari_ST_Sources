
*****************************************************************
*								*
* --> Getfile. Just load the d**n file.				*
*								*
*****************************************************************

* \Takes a filename in file_ptr. Gets length, mallocs memory, loads
*  file and returns address in image_ptr, and length in file_length.

getfile:	move.w	#$00,-(sp)
		move.l	file_ptr,-(sp)
		move.w	#$4E,-(sp)	* Get file info
		trap	#1
		addq.l	#8,sp
		tst.l	D0
		bmi	getfile_err1

		lea	dta_buf,A0
		add.l	#26,A0		* Point to length of file
		move.l	(A0),D7		* D7 = length of file
		move.l	D7,file_length
		
		move.l	D7,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	D0
		bmi	getfile_err2
		move.l	D0,image_ptr

		move.w	#$00,-(sp)	* Open file
		move.l	file_ptr,-(sp)	* Address of filename
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	D0
		bmi	getfile_err3
		move.w	D0,handle

		move.l	image_ptr,-(sp)	* Buffer pointer
		move.l	D7,-(sp)	* File length
		move.w	handle,-(sp)
		move.w	#$3F,-(sp)
		trap	#1
		add.l	#12,sp
		tst.l	D0
		bmi	getfile_err4

		move.w	handle,-(sp)	* Close file
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	D0
		bmi	getfile_err5
		clr.l	D0		* Ok
		rts

getfile_err1:	move.l	#-1,D0	* File not found
		rts

getfile_err2:	move.l	#-2,D0	* Cant malloc
		rts

getfile_err3:	move.l	#-3,D0	* Cant open
		rts

getfile_err4:	move.w	handle,-(sp)
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#4,sp
		move.l	#-4,D0	* Cant read
		rts

getfile_err5:	move.w	handle,-(sp)
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#4,sp
		move.l	#-5,D0	* Cant close
		rts

image_ptr:	ds.l	1
file_ptr:	ds.l	1
file_length:	ds.l	1
		EVEN

* --> Print an error according to D0 from getfile.

l_error:	cmp.l	#-1,D0
		beq	l_error1
		cmp.l	#-2,D0
		beq	l_error2
		cmp.l	#-3,D0
		beq	l_error3
		cmp.l	#-4,D0
		beq	l_error4
		cmp.l	#-5,D0
		beq	l_error5

		pea	l_unid
		jsr	error9
		rts

l_error1:	move.l	file_err1,-(sp)	* File not found
		jsr	error9
		rts
l_error2:	pea	file_err2	* Cant MALLOC
		jsr	error9
		rts
l_error3:	move.l	image_ptr,-(sp)	* Cant open
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		pea	open_err
		jsr	error9
		rts
l_error4:	move.l	image_ptr,-(sp)	* Cant read
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w	handle,-(sp)
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#4,sp
		pea	read_err
		jsr	error9
		rts
l_error5:	move.l	image_ptr,-(sp)	* Cant close
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		pea	close_err
		jsr	error9
		rts

error9:		move.l	(sp)+,A6
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	(A6)
