* Phoenix Bootsector Installer v1.0!!
* Coded by Agrajag again!! (4/10/91)

; Installs my Phoenix Bootsector v1.0 onto any disk.

; Just to explain, when I did a menu for Phoenix PD, I put a nice bootsector
; with menu number on it. It's NOT an official Phoenix PD piece of software,
; since they do not believe in putting their names over everything unless
; it's really necessary. I include it here because it allows you to put
; your own custom message on any normal bootsector, and also detects if the
; reset vector has been changed. (I don't know how successful this is,
; really!)

; Again, you can check in your AUTO programs that the bootsector exists,
; cause it puts #$1991 into $160.w

loop	pea	crap1
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	waitkey
	cmp.b	#$10,d0			Q for quit....?
	beq	quit			Quit then!!!
	bsr	alter_message
	bsr	read_boot
	bsr	make_boot
	bsr	write_boot
	pea	crap2
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	waitkey
	bra	loop

quit	clr	-(sp)
	trap	#1

waitkey	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0
	rts

alter_message
	pea	crap3
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	(bootext+1)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	crap4
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	waitkey
	cmp.b	#$15,d0			Key 'Y' pressed?
	bne	.end
	pea	crap5
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	d0
	pea	message
	move	#$a,-(sp)
	trap	#1
	addq.l	#6,sp
	move.b	d0,d1
	subq	#1,d0
	lea	(message+2),a0
	lea	(bootext+1),a1
.copy	move.b	(a0)+,(a1)+
	dbf	d0,.copy
	clr.b	(a1)
	move.l	#19,d0
	lsr	#1,d1
	sub.b	d1,d0
	addi.b	#32,d0
	lea	bootext,a1
	move.b	d0,(a1)
.end	rts

read_boot
	move.w	#1,-(sp)	read one sector...
	move.w	#0,-(sp)	on side 0 of the disk...
	move.w	#0,-(sp)	on track 0 of the disk...
	move.w	#1,-(sp)	and sector 0... Hey! A bootsector!
	move.w	#0,-(sp)	device: 0 for A etc..
	clr.l	-(sp)		filler  (unused)
	pea	buffer
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp
	tst.w	d0
	beq	read_ok
	bsr	disk_error
read_ok
	rts

make_boot
	bsr	copy_code
	move.w	#1,-(sp)		executable
	move.w	#-1,-(sp)		disk type no change
	move.l	#-1,-(sp)		same serial number
	pea	buffer
	move.w	#18,-(sp)
	trap	#14
	add.l	#14,sp
	rts

write_boot
	move.w	#1,-(sp)	1 sector to write
	move.w	#0,-(sp)	on side 0
	move.w	#0,-(sp)	track zero
	move.w	#1,-(sp)	sector 1 (not zero)
	move.w	#0,-(sp)	drive A
	clr.l	-(sp)
	pea	buffer
	move.w	#9,-(sp)
	trap	#14
	add.l	#20,sp
	tst.w	d0		error?
	beq	wr_sc_ok
	bra	disk_error
wr_sc_ok rts	

disk_error	
	cmp.w	#-17,d0
	beq	insert
	cmp.w	#-13,d0
	beq	write
	cmp.w	#-2,d0
	beq	drive
	tst.w	d0
	bmi	diskerr
	rts

drive	pea	err4
	bra	dend
write	pea	err3
	bra	dend
insert	pea	err2
	bra	dend
diskerr	pea	err1
dend	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	waitkey
	addq.l	#2,sp
	bra	loop

copy_code
	lea	bootdat,a0
	lea	buffer,a1
	move	#$6038,(a1)+		BRA instruction
	move	#'by',(a1)+		Loader
	move.l	#' AGR',(a1)
	lea	(buffer+$3a),a1
.loop	cmpa.l	#bootend,a0
	beq	.end
	move.b	(a0)+,(a1)+
	bra	.loop
.end	rts

err1	dc.b	'Oh no! A bloody disk error!!! ',13,10,13,10,0
err2	dc.b	'Please insert the disk first!! ',13,10,13,10,0
err3	dc.b	'This disk is write protected ',13,10,13,10,0 
err4	dc.b	'Funny.. This drive doesn''t exist..',13,10,13,10,0

crap1	dc.b	27,'EPhoenix PD Bootsector Installer v1.0',13,10,13,10
	dc.b	'Coded by Agrajag (1/10/91).',13,10,13,10
	dc.b	'Press Q to quit, any other key to start.',13,10,13,10,13,10,0
crap2	dc.b	13,10,'Bootsector Installed. ',13,10
	dc.b	'Press any key to restart.',13,10,0
crap3	dc.b	'Do you wish to alter the current text?',13,10,13,10
	dc.b	'-----------------------------------------',13,10,0
crap4	dc.b	13,10,'-----------------------------------------'
	dc.b	13,10,13,10,13,10,0
crap5	dc.b	'Enter New text here-',13,10
	dc.b	'*****************************************',13,0

bootdat	incbin	phnx_bt.img
bootend

bootext	equ	bootdat+$7d

buffer	ds.b	512			The bootsector store

message	dc.b	40
	dc.b	0
	ds.b	40