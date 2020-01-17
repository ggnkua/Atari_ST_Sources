* Ballistix single file 1 meg memory loader
* Hacked, cracked and single parted by KrazyK
* Runs from the auto folder or from a menu.


unpackto=$82000		* relocate the disk data to above 520k
memcode= $80000

super	pea	0
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	
	clr.w	-(a7)		* set low res
	pea	-1
	pea	-1
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7

	pea	mess(pc)	* print some text
	move.w	#9,-(a7)
	trap	#1
	addq	#6,a7
	
	
	lea	file(pc),a0	* packed disk data
	lea	unpackto,a1	* destination
	bsr	atomic		* unpack

* relocate our memory loading code to above 520k

	move.l	#file-main,d0	* length of our memory loading code
	lea	main(pc),a0	* start address
	move.l	#memcode,d1	* copy above to 520k
	move.l	d1,a1
	move.l	a1,a3		* copy
reloc	move.b	(a0)+,(a1)+	* relocate
	dbf	d0,reloc

	* replace disk loader with our memory loader

	move.l	d1,unpackto+$1110		* jsr $80000
	move.l	d1,unpackto+$15884		* 

	move.w	#0,d0		* track
	move.w	#2,d1		* sector
	move.w	#8,d2		* number of sectors to read
	lea	$30000,a5	* load arress
	move.l	a5,a4		* copy address
	bsr 	main		* read and relocate

* Bootsector did the following on the original.
* There are checks for this later in the game code.

	move.l	#$67934691,$2f500
	move.l	#$15800,$2f600
	move.w	#$6589,d0
	move.w	#$7801,d2
	move.w	#$1206,d3

	jmp	(a4)		* run game


main	movem.l	d0-a6,-(a7)	* save regs
	bsr	calc		* get the offset and number of bytes to read
	bsr	read		* read and relocate
	movem.l	(a7)+,d0-a6	* restore regs
	moveq	#0,d2		* clear d2, all bytes read
	rts

read	move.l	#unpackto,a6	* unpacked disk data
	add.l	d6,a6		* offset
	move.l	a5,a3		* copy destination address
	move.l	d3,d4		* copy length
copymem	move.b	(a6)+,(a5)+	* relocate
	dbf	d3,copymem

	cmp.l	#$15800,a3	* 2nd main game code loaded?


* replace sector loader with file loader
	move.l	#memcode,$1b284

* remove 3 disk checks
	move.w	#$601e,d0
	move.w	d0,$1b496	* bra.s $1b4b6
	move.w	d0,$1cb08	* bra.s $1cb28
	move.w	d0,$20bf4	* bra.s $20c14

	rts


* calculate the offset of the track data

calc	sub.l	#1,d1		* -1 from track
	mulu	#5120,d0	* 512k*10 sectors
	mulu	#512,d1		* 512k per sector
	add.l	d1,d0		* add them
	mulu	#512,d2		* multiply by how many sectors
	move.l	d2,d3		* bytes to read
	move.l	d0,d6		* offset to read from
	rts


atomic	include	"atomic35.s"
	rts

data
mess	
	dc.b	27,"E"
	dc.b	27,"Y",32+4,32+15,"BALLISTIX"
	dc.b	27,"Y",32+6,32+13,"1MEG VERSION"
	dc.b	27,"Y",32+8,32+7,"CRACKED, FILED AND PACKED"
	dc.b	27,"Y",32+10,32+15,"BY KRAZYK"
	dc.b	0
	even
	

file	incbin	"disk.pak"
filend
 


