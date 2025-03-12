* Boot for POVERTY DEMO (c) MSD of POV 1995
* STE 80/10 VERSION

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,rez

	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	clr.w	-(sp)
	clr.w	-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,colour0

	move.w	#$fff,-(sp)
	move.w	#3,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,colour3

go	pea	message1(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	insert_disc
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	cmp.b	#"Q",d0
	beq	exit
	cmp.b	#"q",d0
	beq	exit

	bsr	do_boot

	pea	another_disc
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#6,sp

	cmp.b	#"Y",d0
	beq	go
	cmp.b	#"y",d0
	beq	go

exit	move.w	rez,-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	colour0,-(sp)
	clr.w	-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	colour3,-(sp)
	move.w	#3,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1






do_boot
;first we read the old boot
	move.w	#1,-(sp)	;1 sector to read
	clr.w	-(sp)		;side 0
	clr.w	-(sp)		;track 0
	move.w	#1,-(sp)	;start @ sector 1
	clr.w	-(sp)		;drive A
	clr.l	-(sp)		;not used
	pea	buffer		;read into here
	move.w	#8,-(sp)	;read boot sector
	trap	#14
	lea	20(sp),sp

	lea	mycode,a0	;move my code into buffer
	lea	buffer+32,a1
	move.l	#mycodeend-mycode,d0
loop	move.b	(a0)+,(a1)+
	subq	#1,d0
	bne.s	loop

	move.b	skip,buffer
	move.b	skip+1,buffer+1
	move.b	skip+2,buffer+2

	move.w	#1,-(sp)	;now make it a boot sector
	move.w	#-1,-(sp)
	pea	-1
	pea	buffer
	move.w	#$12,-(sp)
	trap	#14
	lea	14(sp),sp

	move.w	#1,-(sp)	;write new bootsector out
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	#1,-(sp)
	clr.w	-(sp)
	clr.l	-(sp)
	pea	buffer
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	rts



message1
	dc.b	27,'E'
	dc.b	27,'Y',32+0,32+17,27,'p',"POVERTY DEMO STE VERSION BOOT SECTOR WRITER",27,'q'
	dc.b	27,'Y',32+2,32+23,"Written by MAC SYS DATA of P.O.V."
	dc.b	0
	even
insert_disc
	dc.b	27,'Y',32+7,32+8,"Insert disc to write bootsector to and press a key (Q to quit)."
	dc.b	0
	even
another_disc
	dc.b	27,'Y',32+10,32+30,"Another disc (Y/N)?"
	dc.b	0
	even
rez	ds.w	1
colour0	ds.w	1
colour3	ds.w	1





	opt	p+
***************************** boot code ********************************
skip	bra.s	skip+32

mycode		move.l	sp,$200.w
;		move.l	#$4ffe,sp
		movem.l	d0-a6,-(sp)

		lea	$20000,a6	;load address
		move.w	#6,d7		;track number
		move.w	#1,d6		;start sector
		move.w	#3-1,d5
readloop	move.w	#10,-(sp)	;no. sectors to read
		move.w	#0,-(sp)	;side
		move.w	d7,-(sp)	;track
		move.w	d6,-(sp)	;sector to start at
		clr.w	-(sp)		;floppy drive A
		clr.l	-(sp)		;reserved
		move.l	a6,-(sp)	;buffer to read to
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp
		lea	512*10(a6),a6
		add.w	#1,d7
		dbf	d5,readloop

		movem.l	(sp)+,d0-a6
		move.l	$200.w,sp
		jmp	$20000

	dc.b	"  (c) MSD of POV 1995"
	even
mycodeend

buffer	dcb.l	512/4,"MSD!"
	dc.b	"POV!"