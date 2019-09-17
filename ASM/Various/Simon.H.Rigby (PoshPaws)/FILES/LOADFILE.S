;Load a file, allocating the necessary memory
;ENTRY:	a0.l = Pointer to Full Path & File Name
;EXIT:	d0.l = 0 if OK or -ve GEMDOS Error Code
;	a0.l = start of file
;	d1.l = length of file
;USES:	d0-d2/a0-a2

       		TEXT
Load_file	
		clr.w	-(sp)
		move.l	a0,-(sp)
		move.w	#$3d,-(sp)
		trap	#1		;Fopen filename for read
		addq.w	#8,sp
		tst.l	d0
		blt	Load_file_exit1
		move.l	d0,-(sp)	;file_handle (as long for later swap round)
		
		move.l	#-1,-(sp)
		move.w	#$48,-(sp)
		trap	#1		;Gemdos Malloc
		addq.w	#6,sp
		move.l	d0,-(sp)	;memory available
		move.w	#$48,-(sp)
		trap	#1		;Gemdos Malloc
		addq.w	#2,sp		;leave max size on stack
		tst.l	d0
		beq.s	Load_file_exit2	;malloc fail
		
		move.l	4(sp),d1
		move.l	d0,4(sp)	;start address stacked where file handle was
		move.w	d1,-(sp)	;file handle stacked last
		
		move.w	#$3f,-(sp)	;rest of parameters already on stack
		trap	#1		;read as much file as fits in memory block
		addq.w	#2,sp
		tst.l	d0
		blt.s	Load_file_exit3	;failed to read file
		cmp.l	2(sp),d0
		beq.s	Load_file_exit4	;file too big for malloc block
				
		move.l	d0,-(sp)	;size of block
		move.l	10(sp),-(sp)	;start of block
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1		;Gemdos Mshrink
		addq.w	#8,sp		;leave size on stack
		tst.l	d0
		blt.s	Load_file_exit5 ;cannot shrink so release memory
		
		move.w	4(sp),-(sp)	;file handle
		move.w	#$3e,-(sp)
		trap	#1		;Gemdos close file
		addq.w	#4,sp
		tst.l	d0
		blt.s	Load_file_exit5	;cannot close so release memory

		move.l	(sp)+,d1	;length of file
		clr.l	d0		;no error
		addq.w	#6,sp		;clear stack
		move.l	(sp)+,a0	;start of file in memory
		rts
;Error Exits
;===========
Load_file_exit5	addq.w	#4,sp
		bra.s	Load_file_exit3
Load_file_exit4 moveq.l	#-39,d0		;not enough memory
Load_file_exit3	move.l	d0,-(sp)	;error code
		move.l	6(sp),-(sp)
		move.w	#$49,-(sp)
		trap	#1		;release memory on fail
		addq.w	#6,sp		;get rid of stacked parameters
		move.l	(sp)+,d0	;error code
		lea	10(sp),sp	;get rid of stacked parameters
		rts
Load_file_exit2	addq.w	#8,sp		;(get rid of file handle & malloc size)		
		moveq.l	#-39,d0		;malloc fail code
Load_file_exit1	rts			;d0 = error code
