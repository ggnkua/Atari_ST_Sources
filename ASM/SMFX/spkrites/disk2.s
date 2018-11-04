makeboot	equ 1
	IFNE	makeboot
loadboot	
	move.w	#1,-(sp)			Read old boot sector
	move.w	#0,-(sp)			from side 0
	move.w	#0,-(sp)			track 0
	move.w	#1,-(sp)			sector 1
	move.w	#0,-(sp)			drive A
	clr.l	-(sp)				Filler
	move.l	#buffer,-(sp)		Address to load to
	move.w	#8,-(sp)			Function number
	trap	#14					Call XBIOS
	add.l	#20,sp				Correct stack

	move.w	#240,d0				Set up counter
	move.l	#buffer,a0			Address of old boot sector
	lea		30(a0),a0			Skip past header
	move.l	#bootprog,a1		Address of new program
loop22	
	move.w	(a1)+,(a0)+			Copy across word
	dbf		d0,loop22			Copy next word
	move.l	loader,buffer		Copy across new header
	move.l	loader+4,buffer+4	Copy across new header

	move.w	#1,-(sp)			Executable boot sector
	move.w	#-1,-(sp)			Don't change disk type
	move.l	#-1,-(sp)			Don't change serial number
	move.l	#buffer,-(sp)		Address of new program
	move.w	#18,-(sp)			Modify boot sector
	trap	#14					Call XBIOS
	add.l	#14,sp				Correct stack

	move.w	#1,-(sp)			Write boot sector
	move.w	#0,-(sp)			to side 0
	move.w	#0,-(sp)			track 0
	move.w	#1,-(sp)			sector 1
	move.w	#0,-(sp)			drive A
	clr.l	-(sp)				Filler
	move.l	#buffer,-(sp)		Address to write from
	move.w	#9,-(sp)			Function number
	trap	#14					Call XBIOS
	add.l	#20,sp				Correct stack

	clr.w	-(sp)				Exit program
	trap	#1					Call GEMDOS

buffer	ds.b	512
loader	dc.b	$60,$1C,"*C&D* "

bootprog
	ENDC
	IFNE makeboot
	ELSE
	clr -(sp)
	pea $78000
	pea $78000
	move.w #5,-(sp)
	trap #14
	lea.l 12(sp),sp
	pea doCode
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp
	clr -(sp)
	trap #1
	ENDC

doCode
	; here we copy from disk to memory


	move.w	#96-1,d7
.lx
	move.l	bufptr,d0
	jsr		read5120
	jsr		doInc
	dbra	d7,.lx

	jmp		27000+1024+28

;	move.l	#1024+27000,a0
;	lea		demo,a1
;	moveq	#-4,d0
;.l
;		addq.l	#4,d0
;		cmp.l	(a0)+,(a1)+
;		beq		.l


	clr	-(sp)
	trap	#1

doInc
	lea		bufptr,a0
	add.l	#5120,(a0)
	lea		side,a0
	tst.w	(a0)
	beq		.do1
.nextTrack
		lea		side,a0
		move.w	#0,(a0)
		lea		track,a0
		add.w	#1,(a0)
		jmp		.sidedone
.do1
		lea		side,a0
		move.w	#1,(a0)
.sidedone
	rts

bufptr	dc.l	27000+1024

read5120
	move.w 	#10,-(sp)
	move.w 	side,-(sp)
	move.w 	track,-(sp)
	move.w 	sector,-(sp)
	move.w 	#0,-(sp)
	move.l 	#0,-(sp)	
	move.l	bufptr,a0
	pea 	(a0)
	move.w 	#$08,-(sp)
	trap 	#14
	lea 	20(sp),sp
	rts


side	dc.w	0
track	dc.w	1
sector	dc.w	1

;demo	incbin	sprite.tos
;	even



	even