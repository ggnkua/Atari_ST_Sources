*
* BORIS SAMPLE PACKER II
* Version 2
*

	opt	o+,ow-

	SECTION	TEXT

start
	bsr	out_title
	bsr	get_fname
	bsr	open_file
	bsr	read_file
	bsr	close_file
	lea	pack_mess,a0
	bsr	out_mess

	lea	emptyram(pc),a0
	move.l	a0,a1
	add.l	old_size,a1
	move.l	a1,a2

	move.l	#"BSP2",(a1)+		; Packer ident.
	move.b	#2,(a1)+		; Version.
	move.b	mask,(a1)+		; Mask.
	move.l	old_size,(a1)+		; Unpacked length.

	moveq	#0,d0
	moveq	#0,d1
.loop
	move.b	(a0)+,d2
	move.b	d0,d3
	move.b	d2,d4
	and.b	mask,d4
	and.b	mask,d3
	cmp.b	d4,d3
	bne	.store
	move.b	d2,d7
	move.b	mask,d3
	not.b	d3
	and.b	d3,d7
	lsl.w	#2,d7
	lsl.w	#8,d7
	moveq	#5,d6
	bsr	place
	bra	.cont
.store	move.b	d2,d7
	bset	#8,d7
	lsl.w	#7,d7
	moveq	#8,d6
	bsr	place
.cont	move.b	d2,d0
	cmp.l	a2,a0
	blt.s	.loop

	tst.w	d1
	beq	.ok
	moveq	#0,d7			; Tidy up.
	moveq	#16,d6
	sub.w	d1,d6
	bsr	place
.ok	move.l	a1,d0
	sub.l	a2,d0
	move.l	d0,new_size
	move.l	a2,a6

	lea	save_mess(pc),a0
	bsr	out_mess
	bsr	get_fname
	bsr	create_file
	bsr	write_file
	bsr	close_file
	lea	done_mess(pc),a0
	bsr	out_mess

exit	clr.w	-(sp)
	trap	#1


place
	lsl.w	#1,d7
	roxl.w	#1,d5
	addq.w	#1,d1
	and.w	#15,d1
	bne.s	.ok
	move.w	d5,(a1)+
.ok	dbf	d6,place
	rts


out_mess
	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

out_title
	lea	title(pc),a0
	bra.s	out_mess


get_fname
	pea	filename(pc)
	move.w	#10,-(sp)
	trap	#1
	addq.w	#6,sp
	lea	filename(pc),a0
	moveq	#0,d0
	move.b	1(a0),d0
	clr.b	2(a0,d0)
	rts


create_file
	clr.w	-(sp)
	pea	filename+2(pc)
	move.w	#60,-(sp)
	trap	#1
	addq.w	#8,sp
	move.w	d0,handle
	rts

open_file
	clr.w	-(sp)
	pea	filename+2(pc)
	move.w	#61,-(sp)
	trap	#1
	addq.w	#8,sp
	move.w	d0,handle
	rts

read_file
	pea	emptyram(pc)
	pea	1000000
	move.w	handle,-(sp)
	move.w	#63,-(sp)
	trap	#1
	add.w	#12,sp
	btst.l	#0,d0
	beq.s	.ok
	addq.l	#1,d0
.ok	move.l	d0,old_size
	rts

write_file
	pea	(a6)
	move.l	new_size,-(sp)
	move.w	handle,-(sp)
	move.w	#64,-(sp)
	trap	#1
	add.w	#12,sp
	rts

close_file
	move.w	handle,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.w	#4,sp
	rts


	SECTION	DATA

mask	dc.b	$e0
	even

title
	dc.b	'BORIS SAMPLE PACKER II',13,10
	dc.b	'Version 2.0',13,10
	dc.b	189,' 1990',13,10
	dc.b	'By Boris of "Persistence of Vision"',13,10
	dc.b	10,'Filename ? ',0
	even

pack_mess
	dc.b	13,10,10,'Packing...',0
	even

save_mess
	dc.b	13,10,'Save as ? ',0
	even

done_mess
	dc.b	13,10,'Done.',13,10,0
	even

filename
	dc.b	99,0
	ds.b	100


	SECTION	BSS

old_size	ds.l	1
new_size	ds.l	1

handle		ds.w	1

header		ds.b	10
emptyram	even
