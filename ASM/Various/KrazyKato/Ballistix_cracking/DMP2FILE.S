
*	Ballistix sector to file creator by krazyk
*	Creates files each time the disk is acessed from the raw disk dump
*	Relocated to high memory to avoid game data

*	on entry from game:
*	d0 = start sector
*	d1 = start track
*	d2 = number of sectors to read
*	a5 = read address
*	must be run from auto folder and have 1mb




super	pea	0
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

reloc	lea	sector(pc),a0
	move.l	#$8ca00,a1
	move.l	#buffer-sector,d0
copy	move.b	(a0)+,(a1)+
	dbf	d0,copy


	lea	cracked(pc),a0
	lea	$30000,a1
	move.l	#crackend-cracked,d0
reloc2	move.b	(a0)+,(a1)+
	dbf	d0,reloc2


	move.l	#$67934691,$2f500	* boot sector code did
	move.l	#$15800,$2f600		* this on the original
	move.w	#$6589,d0		* unfiled version
	move.w	#$7801,d2		* 
	move.w	#$1206,d3		* 
	move.w	#$2300,sr
	
	move.l	#$8ca00,$30f10		* jsr $8ca00

	jmp	$30000
	

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*


sector	movem.l	d0-a6,-(a7)		* save all registers
	lea	savea5(pc),a6
	move.l	a5,(a6)			* save the loading address


* Create a unique filename based on the loaded sectors

* d0=track, d1=start sector, d2=loaded sectors

	lea	name(pc),a0		;filename
	lea	store(pc),a2		;temp store
	move.b	d0,(a2)			;poke track
	move.b	d1,1(a2)		;poke sector
	move.w	d2,2(a2)		;poke loaded sectors
	move.l	(a2),d0			;move it all back to d0
	bsr	hextoascii		;convert to ascii
	movem.l	(a7)+,d0-a6		;restore regs


calc	movem.l	d0-a6,-(a7)	* save all registers
	sub.l	#1,d1		* -1 from track
	mulu	#5120,d0	* 512k*10 sectors
	mulu	#512,d1		* 512k per sector
	add.l	d1,d0		* add them together
	mulu	#512,d2		* multiply by how many sectors
	move.l	d2,d3		* bytes to read
	move.l	d0,d6		* offset to read from in the disk dump


* open, fseek, read,close


opendump
	clr.w	-(a7)
	pea	dump(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
hang	bmi	hang
	move.w	d0,d7		* save handle

lseek	move.w	#1,-(a7)	* relative from top of file		
	move.w	d7,-(a7)	* file handle
	move.l	d6,-(a7)	* offset from top of file
	move.w	#$42,-(a7)
	trap	#1
	add.l	#10,a7
	tst.l	d0
	bmi 	hang
	cmp.l	d0,d6		* has the file pointer moved correctly ?
	bne	hang

fread	move.l	a5,-(a7)	* buffer
	move.l	d3,-(a7)	* length
	move.w	d7,-(a7)	* handle
	move.w	#$3f,-(a7)	* fread
	trap	#1
	add.l	#12,a7
	tst.l	d0
	bmi	hang

	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.l	d0
	bmi	hang


open	clr.w	-(a7)
	pea	file(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	create		
	bra 	nosave		* ignore if it exists already

create	move.w	#0,-(a7)	* r/w status
	pea	file(pc)	* address of filename
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	bsr	err_check
	move.w	d0,d7		* store handle

write	move.l	a5,-(a7)	* address to write from
	move.l	d3,-(a7)	* length to write
	move.w	d7,-(a7)	* file handle
	move.w	#$40,-(a7)	
	trap	#1
	add.l	#12,a7
	bsr	err_check

close	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	bsr	err_check

nosave	movem.l	(a7)+,d0-a6	* restore all registers
	moveq	#0,d2

	cmp.l	#$15800,a5
	bne	exit

* replace 2nd loader
	move.l	#$8ca00,$1b284	* jsr $8ca00

* remove 3 disk checks
	move.w	#$601e,d0
	move.w	d0,$1b496	* bra.s $1b4b6
	move.w	d0,$1cb08	* bra.s $1cb28
	move.w	d0,$20bf4	* bra.s $20c14
exit	rts



err_check
	tst.l	d0
	bmi	hang
	rts



hextoascii
	movem.l	d0-a6,-(a7)	* save registers
	lea	name(pc),a1	* file name
	lea	table(pc),a0	* ascii table
	lea	store(pc),a2	* temp store
	move.l	d0,(a2)		* save d0 here and move bytes from it
	moveq	#0,d0		* clear it first
	moveq	#8,d1		* position in filename
	moveq	#3,d2		* number of bytes-1
again	move.b	(a2,d2),d0	* next byte to process
	divs	#16,d0		* divide by 16 , d0 swaps round
	swap	d0		* swap it back
	bsr	convert		* make ascii
	clr.w	d0		* clear it
	swap	d0		* do hi word now
	bsr	convert		* make ascii	
	dbf	d2,again	* keep going
fin	movem.l	(a7)+,d0-a6	* restore registers
	rts


convert	move.b	(a0,d0),-1(a1,d1)	* convert byte	
	subq	#1,d1			* move back 1 byte
	clr.w	d0			* blank d0
	rts		

store	ds.l	1
	even
file	dc.b	"c:\balistix\files\"
name	dc.b	"        "
	dc.b	".pak"
	dc.b	0
table	dc.b	"0123456789abcdef"
dump	dc.b	"disk.dat",0
	even

buff	ds.l	4




*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*	
	
	data
	even


trap10	ds.l	1
savea5	ds.l	1	
length	ds.w	1
buffer	even

cracked	incbin	"c:\balistix\files\30000.bin"
crackend


		
