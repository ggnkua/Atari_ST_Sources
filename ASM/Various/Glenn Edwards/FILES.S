;
; Loading and saving files using GEMDOS
; (c)1993 Glenn Edwards
;
; From studying this source code, you should be able to work out how
; to load and save (read and write) files in 68000.
;
; Notes: File handles are used by GEMDOS to keep track of files which
; are open. You should store handles returned to you by the f_open
; function, so that you can refer to the files later on.
;
; *** If you are using Devpac 1 then delete the line 'section bss' ***
;

	opt	o+

_read	equ	0
_write	equ	1
_rd_wr	equ	2

start	movem.l	d0-d7/a0-a6,-(sp)	;Store registers
	moveq.w	#_rd_wr,d0
	bsr.s	open			;Open file for read/write
	bmi.s	exit			;If error, then exit
	
	bsr.s	read			;Read from file

	bsr.s	close			;Close file
	movem.l	(sp)+,d0-d7/a0-a6	;Restore registers
exit	clr.w	-(sp)			;Exit to desktop
	trap	#1

open	move.w	d0,-(sp)		;mode passed in d0
	pea	fname(pc)		;filename address
	move.w	#$3d,-(sp)		;GEMDOS f_open
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle		;Store file handle
	rts

close	move.w	handle(pc),-(sp)	;File handle
	move.w	#$3e,-(sp)		;GEMDOS f_close
	trap	#1
	addq.l	#4,sp
	rts

read	pea	buffer(pc)		;Buffer address
	move.l	#150,-(sp)		;Number of bytes = 150
	move.w	handle(pc),-(sp)	;File handle
	move.w	#$3f,-(sp)		;GEMDOS f_read
	trap	#1
	lea	12(sp),sp
	rts

write	pea	buffer(pc)		;Buffer address
	move.l	#150,-(sp)		;Number of bytes = 150
	move.w	handle(pc),-(sp)	;File handle
	move.w	#$40,-(sp)		;GEMDOS f_write
	trap	#1
	lea	12(sp),sp
	rts

fname	dc.b	'b:\tips.txt',0		;Filename

	even

	section	bss
handle	ds.w	1			;Storage for file handle
buffer	ds.b	10000			;Read/write buffer