;
; Accessing sectors (including the bootsector) using the XBIOS
; (c)1993 Glenn Edwards
;
; From studying this source code, you should be able to work out how
; to read/write sectors using 68000.
;
; *** If you are using Devpac 1 then delete the line 'section bss' ***
;

	opt	o+

start	movem.l	d0-d7/a0-a6,-(sp)	;Store registers
	moveq.w	#1,d4			;Read 1 sector
	moveq.w	#0,d3			;Side 0
	moveq.w	#0,d2			;Track 0
	moveq.w	#1,d1			;Start reading from sector 1
	moveq.w	#0,d0			;Drive 0
	lea	buffer(pc),a0		;Buffer address
	bsr.s	read			;Read sector(s)
	movem.l	(sp)+,d0-d7/a0-a6	;Restore registers
exit	clr.w	-(sp)			;Exit to desktop
	trap	#1

read	;d0=drive, d1=start_sec, d2=track, d3=side, d4=num_sec, a0=buffer
	move.w	d4,-(sp)		;Number of sectors to read
	move.w	d3,-(sp)		;Side number (0 or 1)
	move.w	d2,-(sp)		;Track number(0 to ??)
	move.w	d1,-(sp)		;Start sector (1 to ??)
	move.w	d0,-(sp)		;Drive (0 or 1)
	clr.l	-(sp)
	move.l	a0,-(sp)		;Buffer address
	move.w	#8,-(sp)		;XBIOS _floprd
	trap	#14
	lea	20(sp),sp
	rts

write	;d0=drive, d1=start_sec, d2=track, d3=side, d4=num_sec, a0=buffer
	move.w	d4,-(sp)		;Number of sectors to read
	move.w	d3,-(sp)		;Side number (0 or 1)
	move.w	d2,-(sp)		;Track number(0 to ??)
	move.w	d1,-(sp)		;Start sector (1 to ??)
	move.w	d0,-(sp)		;Drive (0 or 1)
	clr.l	-(sp)
	move.l	a0,-(sp)		;Buffer address
	move.w	#9,-(sp)		;XBIOS _flopwr
	trap	#14
	lea	20(sp),sp
	rts

	section	bss
buffer	ds.b	512			;Read/write buffer