*      include 3   January 4, 1990
*------------------------------
* ASPRITE	sprites, using chunks
* DISAP		Simon's venetian blind
* PIPLOT	pixel plot
* PIREAD	
* READ_SECTOR\WRITE_SECTOR
* BOOT_SECTOR  how to create an executionable boot sector
* SAVE_PAL \BLACK_PAL  \INVERT
* TRANSPARENT	merge two pictures
*---------------------------------------------------------

* SPRITES may be drawn in a variety of ways. Macros are available.
* At the other extreme, data may be moved from spr_screen to destination
* using pre-shifted pictures, and not a single loop (see Final Lap)

* a chunk is 16 pixel wide
* sprite screen expected in A0
* and several other parameters
asprite	move.l	a1,a3			save destination screen
	add.l	d4,a0			precise origin  was a4
	add.l	d5,a1			precise loc (16 boundary)

	lea	sprite_store,a2		destination:sprite data with mask
	move.l	d1,-(sp)		save start pixel
	move.w	8(a6),d7		height
	sub.w	#1,d7
.row_loop 
	move.w	10(a6),d4	chunks
	sub.w	#1,d4		-1 for loop
.chunk_loop
	movem.l	(a0)+,d2/d3	create a mask of that sprite
	move.l	d2,d0		combine...
	or.l	d3,d0		...the lot of them.
	move.w	d0,d1		convert result..
	swap	d0		into..
	or.w	d1,d0		..a mask
	not.w	d0		now invert it
	move.w	d0,(a2)+	store mask
	move.l	d2,(a2)+	store planes
	move.l	d3,(a2)+	..  ..
*	move.l	(a1)+,(a3)+	if saving..
*	move.l	(a1)+,(a3)+	..a buffer is needed
	dbra	d4,.chunk_loop
	add.l	a4,a0		offset
	add.l	a5,a1		offset
	dbra	d7,.row_loop
printsprite
	move.l	(sp)+,d0		retrieve start pixel
	lea	sprite_store,a0		created a moment ago
	move.l	a3,a1			retrieve destination  screen..
	add.l	d5,a1			precise loc (16 boundary)
	move.w	8(a6),d7		height
	sub.w	#1,d7
.loop1	move.w	10(a6),d6	
	sub.w	#1,d6	
	moveq	#-1,d1	
	moveq	#0,d2
	moveq	#0,d3	
	moveq	#0,d4
	moveq	#0,d5
.loop2	move.w	(a0)+,d1	mask
	move.w	(a0)+,d2	plane 1
	move.w	(a0)+,d3	plane 2 etc
	move.w	(a0)+,d4
	move.w	(a0),d5
	lsr.l	d0,d1		shift mask into place
	lsr.l	d0,d2		shift planes into place
	lsr.l	d0,d3
	lsr.l	d0,d4
	lsr.l	d0,d5
	and.w	d1,(a1)		
	or.w	d2,(a1)+	now write plane 1 
	and.w	d1,(a1)
	or.w	d3,(a1)+	and so on
	and.w	d1,(a1)
	or.w	d4,(a1)+
	and	d1,(a1)
	or	d5,(a1)+
	subq.l	#8,a0		
	move.l	(a0),d1	
	addq.l	#2,a0
	move.l	(a0),d2	
	addq.l	#2,a0		
	move.l	(a0),d3		
	addq.l	#2,a0		
	move.l	(a0),d4		
	addq.l	#2,a0		
	move.l	(a0),d5		
	addq.l	#2,a0
	dbra	d6,.loop2	
	move.w	#-1,d1
	clr.w	d2		
	clr.w	d3		
	clr.w	d4
	clr.w	d5
	lsr.l	d0,d1
	lsr.l	d0,d2
	lsr.l	d0,d3
	lsr.l	d0,d4
	lsr.l	d0,d5
	and.w	d1,(a1)	
	or.w	d2,(a1)+	
	and.w	d1,(a1)
	or.w	d3,(a1)+
	and.w	d1,(a1)
	or.w	d4,(a1)+
	and.w	d1,(a1)
	or.w	d5,(a1)+
	add.l	a5,a1		(2*chunks)-8
	dbra	d7,.loop1
	rts
sprite_store	ds.w 	1300 	enough for a sprite 3 chunks * 20
		ds.w	1300 	but bigger sprites need more room! 
*------------
* disappear (Venitian blind) [ Simon Rush  23.9.88 ]
* just call by jsr disap

disap	move.l	$44e,a0
	add.l	#1600,a0
	move.l	a0,a3
	move.l	a0,a2
	move.l	a0,a1
	sub.l	#160,a0
	add.l	#160,a2
	move.l	#9,d2
lp2	move.l	#9,d1
lp1	move.l	#359,d0
lp	move.l	-(a0),-(a1)
	move.l	(a2)+,(A3)+
	dbra	d0,lp

	move.l	#39,d0
lp4	move.l	#0,-(a1)
	move.l	#0,(a3)+
	dbra	d0,lp4

	add.l	#4640,a0
	add.l	#4800,a1
	add.l	#1600,a3
	add.l	#1760,a2
	dbra	d1,lp1

	sub.l	#32000,a0
	sub.l	#32000,a1
	sub.l	#32000,a2
	sub.l	#32000,a3
	wait	2
	dbra	d2,lp2
	rts
*-----------
* pixel plot  based on J Lawson's system
* use MACRO instead <<<<
* enter with A0 screen address
*   d0,d1  lateral,vertical coord x-y (W)   d2 color(W)
piplot
	mulu	#160,d1	(160 bytes per row)
	move.w	d0,d3		save lateral (horizontal)
	lsr.w	#1,d3
	and.w	#$fff8,d3	horizontal offset
	add.w	d3,d1		combine vert & horiz offsets
	adda	d1,a0		correct word on screen
	and.w	#$f,d0		correct pixel
	neg	d0		
	add.w	#15,d0		correct bit
* now actually write pixel in color held in d2
	moveq	#4-1,d3		4 planes loop
.loop	move.w	(a0),d1		read screen
	lsr.w	#1,d2		is it a set bit?
	bcs.s	.set_bit	yes
	bclr	d0,d1
	bra.s	.write_back
.set_bit bset	d0,d1
.write_back
	move.w	d1,(a0)+
	dbra	d3,.loop
	rts
*---------
* pixel read 
* use MACRO instead !
* answer in D2 (W)
piread
	clr.w	d2		will return color 0 to 15
	mulu	#160,d1		
	move.w	d0,d3	
	lsr.w	#1,d3
	and.w	#$fff8,d3	horizontal offset
	add.w	d3,d1		combine vert & horiz offsets
	adda	d1,a0		correct word on screen
	and.w	#$f,d0		correct pixel
	neg	d0		reverse
	add.w	#15,d0		correct bit

	moveq	#0,d4		bits to create 0 to 15 (0-1-2-3)
	moveq	#4-1,d3		4 planes loop
.loop	move.w	(a0)+,d1	read screen, one word at a time
	btst	d0,d1
	bne	.set
	bclr	d4,d2
	bra	.clear
.set	bset	d4,d2
.clear	add.w	#1,d4
	dbra	d3,.loop
	rts
*----------
* FLOPRD  read disk sector (currently set on boot sector)
read_sector
	move.w	#1,-(sp)	number of sectors to read (1-9)
	move.w	#0,-(sp)	side number selected  (0-1)
	move.w	#0,-(sp)	track number (0-79)
	move.w	#1,-(sp)	sector number (0-9)
	move.w	#0,-(sp)	device: 0 for A etc..
	clr.l	-(sp)		filler  (unused)
	move.l	#read_buffer,-(sp) 512 bytes times sectors read
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp
	tst.w	d0
	beq	read_ok		local label not recommended
	bra	disk_error

read_ok	rts
read_buffer
	ds.b	512		can be used for other purposes
	even
*-------------------------------
* WRITE SECTOR  currently set to write boot sector
write_sector
	move.w	#1,-(sp)	1 sector to write
	move.w	#0,-(sp)	on side 0
	move.w	#0,-(sp)	track zero
	move.w	#1,-(sp)	sector 1 (not zero)
	move.w	#0,-(sp)	drive A
	clr.l	-(sp)
	move.l	#read_buffer,-(sp)
	move.w	#9,-(sp)
	trap	#14
	add.l	#20,sp
	tst.w	d0		error?
	beq	wr_sc_ok
	bra	disk_error
wr_sc_ok rts	
*--------------------------------
* the next XBIOS call produces an executable boot sector
* ie it reads a buffer and checksums it
* the buffer must be ready in advance: the first two bytes being $60 $38
* meaning BRA $38 bytes. The code starts at byte 58 
* so first prepare a 512 byte buffer by loading an existing valid
* boot sector in it, using read_sector routine
* Put a $60 and $38 in bytes 0-1     Copy code from somewhere else
* to bytes 58 onwards. Then call boot_sector to checksum it.
* Then call write_sector to save it. It should now be executable
*
boot_sector
	move.w	#1,-(sp)		executable
	move.w	#-1,-(sp)		disk type no change
	move.l	#-1,-(sp)		same serial number
	move.l	#read_buffer,-(sp)
	move.w	#18,-(sp)
	trap	#14
	add.l	#14,sp
	rts
*----------------------------------------------------
disk_error	
	cmp.w	#-17,d0
	beq	insertdisk
	cmp.w	#-13,d0
	beq	writeon
	cmp.w	#-2,d0
	beq	drivenot
	tst.w	d0
	bmi	diskerror
	rts
insertdisk
	pen	$070
	home
	string	<insert disk>
	getkey
	rts
writeon	
	pen	$070
	home
	string <error:write-protect on>
	getkey
	rts
drivenot 
	pen	$070
	home
	string <error:drive not ready>
	getkey
	rts
diskerror
	pen	$070
	home
	string	<disk error>
	getkey
	rts
*----------
* one way of saving the entire palette in one go
save_pal
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palet
	rts

* one way of blanking the screen by making all colors black
black_pal
	movem.l	coal(pc),d0-d7		
	movem.l	d0-d7,$ff8240
	rts	
coal	ds.w 	16

* how to invert the screen
invert	move.l	$44e,a0
	move.l	#8000-1,d0	loop
.lp	not.l	(a0)+		invert
	dbra	d0,.lp
	rts
*----------
* screen one expected in a0
* screen two (destination) in a1 (currently physical)
* color 0 will be transparent
transparent
	move.l	$44e,a1
	move.l	a0,a2		duplicate origin
	move.l	a1,a3		and destination
	move.w	#4000-1,d7	loop
.lp	move.w	(a0)+,d0	get first plane word
	or.w	(a0)+,d0	or it with next one
	or.w	(a0)+,d0	and next
	or.w	(a0)+,d0
	eori.w	#-1,d0		invert to obtain mask
	and.w	d0,(a1)+	mask with destination
	and.w	d0,(a1)+
	and.w	d0,(a1)+
	and.w	d0,(a1)+
	move.l	(a2)+,d1	source L
	or.l	d1,(a3)+	or with the new destination
	move.l	(a2)+,d1
	or.l	d1,(a3)+
	dbra	d7,.lp
	rts
*----------
