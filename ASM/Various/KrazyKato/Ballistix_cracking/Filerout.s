*	Ballistix file loader and depacker by Krazyk
*	All files saved from the original unfiled game
*	Now repacked with Speedpak 3


filecode=$10000		

* Our file loading code goes here. 
* Low enough so it doesn't bump into the game code but not
* low enough to crash tos 1.02
* Tos 1.00 and 1.62 work fine from lower down but not 1.02.
* Try relocating down to membot or even $ca00 and it crashes.


super	pea	0
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7


* first relocate the whole lot high up

	lea	main(pc),a0
	lea	$70000,a1
	move.l	a1,a2
	move.l	#loaderend-super,d0	
moveit	move.b	(a0)+,(a1)+
	dbf	d0,moveit
	jmp	(a2)

main	bsr	print

* relocate our file loading code
	
reloc	move.w	#$2700,sr
	move.l	#endcode-floader,d0	* length to relocate
	lea	floader(pc),a0 		* start of our file loading code
	move.l	#filecode,a1		* our file loading code to here
copy	move.b	(a0)+,(a1)+		* move it
	dbf	d0,copy			* all of it!
	addq	#1,a1

* relocate the initial game loader that the bootsector loads
	lea	loader(pc),a0		* ripped game loader
	lea	$30000,a1		* stick it here
	move.l	#loaderend-loader,d0	* length
reloc2	move.b	(a0)+,(a1)+		* move it
	dbf	d0,reloc2		* keep going

* bootsector did this on the unfiled game.
* there are checks later in the game for this.
	move.l	#$67934691,$2f500
	move.l	#$15800,$2f600		* 2nd game code loads here
	move.w	#$6589,d0
	move.w	#$7801,d2
	move.w	#$1206,d3
	move.w	#$2300,sr

* patch the 1st sector loader with our file loader
	move.l	#filecode,$30f10	* jsr filecode

	jmp	$30000			* run

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Create a unique filename with the value of the loaded sectors

* d0=track, d1=start sector, d2=numberof sectors

floader	movem.l	d0-a6,-(a7)		* save all regs
	lea	name(pc),a0		* file name
	lea	store(pc),a2		* temp store
	move.b	d0,(a2)			* poke track
	move.b	d1,1(a2)		* poke sector
	move.w	d2,2(a2)		* poke loaded sectors
	move.l	(a2),d0			* move the complete value back to d0
	bsr	hextoascii		* convert d0 to ascii


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	
open	clr.w	-(a7)		* open
	pea	name(pc)	* filename
	move.w	#$3d,-(a7)	* fopen
	trap	#1
	addq.l	#8,a7
	tst.l	d0		* error?
	bgt	read		* read ok
hang	add.w	#1,$ff8240	* error
	bra	hang		* shite!
	

read	move.w	d0,d7		* save the file handle
	move.l	a5,-(a7)	* original load address
	move.l	#999999,-(a7)	* length - whole file
	move.w	d0,-(a7)	* handle
	move.w	#$3f,-(a7)	* read
	trap	#1
	add.l	#12,a7
	tst.l	d0		* error?
	bmi	hang		* crap!

close	move.w	d7,-(a7)	* file handle
	move.w	#$3e,-(a7)	* close
	trap	#1
	addq.l	#4,a7
	tst.l	d0		* error?
	bmi	hang		* bollocks!

	move.l	a5,a0		* buffer address
	bsr	speed3		* depack it

	movem.l	(a7)+,d0-a6	* restore regs
	moveq	#0,d2		* all ok!

	cmp.l	#$15800,a5	* main game loader? need to patch it!
	bne	exit

* replace sector loader with file loader
	move.l	#filecode,$1b284

* remove 3 disk checks
	move.w	#$601e,d0
	move.w	d0,$1b496	* bra.s $1b4b6
	move.w	d0,$1cb08	* bra.s $1cb28
	move.w	d0,$20bf4	* bra.s $20c14
exit	rts

* --------  hex to ascii routine ----------------

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
	divs	#16,d0		* divide by 16, d0 swaps round
	swap	d0		* swap it back
	bsr	convert		* make ascii
	clr.w	d0		* clear it
	swap	d0		* do hi word now
	bsr	convert		* make ascii	
	dbf	d2,again	* keep going
fin	movem.l	(a7)+,d0-a6	* restore registers
	rts

convert	move.b	(a0,d0),-1(a1,d1)	
	subq	#1,d1		* move back 1 byte
	clr.w	d0		* blank d0
	rts		

speed3	include	"speed3.s"

store	ds.l	1
name	ds.l	2
	dc.b	".pak"
	dc.b	0
table	dc.b	"0123456789abcdef"
	even
endcode	

print	include	"mess.s"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*	
	
	data
	even

loader	incbin	"30000.bin"
	even
loaderend


		
