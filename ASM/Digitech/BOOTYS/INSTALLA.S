* Antivirus Installer v1.0!!
* Coded by Agrajag again!! (4/10/91)

; Installs the classic ANTIVIRUS onto any disk.

; This was coded from my PHOENIX installer, just to annoy a couple of
; friends of mine, who NEVER put antivirus bootsectors on their disks!

loop	pea	crap1
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	waitkey
	cmp.b	#$10,d0			Q for quit....?
	beq	quit			Quit then!!!
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

read_boot
	move.w	#1,-(sp)	read one sector...
	move.w	#0,-(sp)	on side 0 of the disk...
	move.w	#0,-(sp)	on track 0 of the disk...
	move.w	#1,-(sp)	and sector 1... Hey! A bootsector!
	move.w	#0,-(sp)	device: 0 for A etc..
	clr.l	-(sp)		filler  (unused)
	pea	buffer
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp
	tst.w	d0
	beq	read_ok		
	bra	disk_error
read_ok	rts



make_boot
	bsr	copy_code
	move.w	#1,-(sp)		executable
	move.w	#-1,-(sp)		disk type no change
	move.l	#-1,-(sp)		same serial number
	pea	buffer			bootsector buffer
	move.w	#18,-(sp)		make boot
	trap	#14
	add.l	#14,sp
	rts

write_boot
	move.w	#1,-(sp)	write 1 sec
	move.w	#0,-(sp)	on side 0
	move.w	#0,-(sp)	track 0
	move.w	#1,-(sp)	sector 1- it's the bootsector again! (Oh shut up!)
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
	pea	err1
	move	#9,-(sp)
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
	move.l	#' HN0',(a1)+
	adda.l	#22,a1
.loop	cmpa.l	#bootend,a0
	beq	.end
	move.b	(a0)+,(a1)+
	bra	.loop
.end	rts

err1	dc.b	'DISK ERROR!!! ',13,10,13,10

crap1	dc.b	27,'EAntivirus Bootsector Installer v1.0',13,10,13,10
	dc.b	'Press Q to quit, any other key to start.',13,10,13,10,13,10,0
crap2	dc.b	13,10,'Bootsector Installed. ',13,10
	dc.b	'Press any key to restart.',13,10,0

bootdat	incbin	anti.img
bootend

	even
buffer	ds.b	512			The bootsector store

