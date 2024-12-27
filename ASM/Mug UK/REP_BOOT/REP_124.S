;--------------------------------------------------
; Bootsector Installer by MUG U.K for personal use
;--------------------------------------------------
;
; Go to the end of this source code and press 'Alt' & 'I' to insert
; some new bootsector code
;
;
* Ask which drive is to be protected

guard	pea	guardmess
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Wait for the 'a', 'b' and 'esc' keys.

_kloop	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0
	
	cmp.b	#1,d0	ESC key
	beq.s	_exit
	cmp.b	#$1e,d0	'a' key
	beq.s	guarda
	cmp.b	#$30,d0	'b' key
	bne.s	_kloop
	
guardb	move.w	#1,guarddrv+2
	bra.s	do_guard
	
guarda	clr.w	guarddrv+2

do_guard	pea	guardclr	Display 'Writing'
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Read the current bootsector and insert the main data into ours

	bsr.s	read
		
	move.w	#29,d0
	lea	mybuffer,a1
	lea	bootbuffer,a0
cloop1	move.b	(a0)+,(a1)+
	dbf	d0,cloop1
	move.w	#$601c,mybuffer	 ; Add BSR code
		
* Calculate new checksum

	lea	mybuffer,a0	My bootsector
	clr.w	d7	Clear checksum count
	clr.w	$1fe(a0)	In buffer as well
	move.w	#$ff,d5
calop	add.w	(a0)+,d7	Make checksum in D7
	dbf	d5,calop
	move.w	#$1234,d0
	sub.w	d7,d0
	move.w	d0,$1fe+mybuffer
	
	bsr.s	write
	
	bra	guard
	
_exit	move.w	#$4c,-(sp)
	trap	#1

* Subroutines to read and write the bootsector

read	move.w	#$08,d0
	lea	bootbuffer,a0
	bra.s	perform
write	move.w	#$09,d0
	lea	mybuffer,a0
perform	move.w	#$01,-(sp)	Read 1 sector
	clr.w	-(sp)	Side 0
	clr.w	-(sp)	Track 0
	move.w	#$01,-(sp)	Sector 1
guarddrv	move.w	#0,-(sp)	Drive A
	clr.l	-(sp)	Filler
	move.l	a0,-(sp)	Address of buffer
	move.w	d0,-(sp)	Floprd/flopwr
	trap	#14
	add.l	#20,sp
	rts

guardmess	dc.b	27,"E"
	dc.b	"+---------------------------------+",13,10
	dc.b	"| Source #124 Bootsector Repairer |",13,10
	dc.b	"|                                 |",13,10
	dc.b	"|   by: MUG U.K (of The Source)   |",13,10
	dc.b	"+---------------------------------+",13,10,10
	dc.b	"Use this program to repair the",13,10
	dc.b	"bootsector on Source #124.",13,10
	dc.b	"DO NOT USE IT TO REPAIR ANY OTHER",13,10
	dc.b	"DISK, OR YOU WILL SCREW IT UP !!",13,10,10
	dc.b	"Insert Disk To Be Repaired.",13,10,10
	dc.b	" 'A' to write to the disk in drive A",13,10
	dc.b	" 'B' to write to the disk in drive B",13,10
	dc.b	"'ESC' to abort."
	dc.b	0
	even

guardclr	dc.b	13,10,10,10
	dc.b	"Writing ... Please Wait",0
		
	even
	
* 512 byte buffer for bootsector read from disk
	
bootbuffer	ds.b	512

* Pre constructed boot sector minus statistics

bootst
mybuffer	ds.b	30

* Insert the bootsector source of your choice after 'bootcode'

bootcode
 
; The Source Menu 124
; -------------------
;
; Bootsector Coded by: MUG U.K(tm)
;

	opt p+,o+

	clr.w	$ffff8240.w
	move.w	#$777,$ffff825e.w

	lea	text(pc),a1
	bsr.s	print

get_key	move.b	$fffffc02.w,d0

key1	cmp.b	#$3b,d0	; was 1 pressed ???
	bne.s	key2	; no it wasn't
	lea	file1(pc),a0	; if it was then a0 = filename
	bra.s	load		; and load it

key2	cmp.b	#$3c,d0
	bne.s	key3
	lea	file2(pc),a0
	bra.s	load

key3	cmp.b	#$3d,d0
	bne.s	key4
	lea	file3(pc),a0
	bra.s	load

key4	cmp.b	#$3e,d0
	bne.s	key5
	lea	file4(pc),a0
	bra.s	load

key5	cmp.b	#$3f,d0
	bne.s	key6
	lea	file5(pc),a0
	bra.s	load

key6	cmp.b	#$40,d0
	bne.s	keysp
	lea	file6(pc),a0
	bra.s	load

keysp	cmp.b	#$39,d0
	beq.s	exit
	bne.s	get_key

load	lea	loading(pc),a1
	bsr.s	print

	pea	null(pc)		; load file
	pea	null(pc)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	move.l	$4.w,a0		; Hard-reset
	jmp	(a0)

exit	rts

print	move.l	a1,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

null	dc.l	0

file1	dc.b	"a_mine.src",0
	even

file2	dc.b	"beachtro.src",0
	even

file3	dc.b	"fuzion.src",0
	even

file4	dc.b	"legacy.src",0
	even

file5	dc.b	"illusion.src",0
	even

file6	dc.b	"no_coopr.src",0
	even

text	dc.b	27,'Y',32+0,32+12,"The Source #124"
	dc.b	27,'Y',32+1,32+12,"---------------"
	dc.b	27,'Y',32+4,32+8,"F1 = Animal Mine Dentro"
	dc.b	27,'Y',32+6,32+8,"F2 = Hemoroids Beachtro"
	dc.b	27,'Y',32+8,32+11,"F3 = Fuzion Intro"
	dc.b	27,'Y',32+10,32+11,"F4 = Legacy Dentro"
	dc.b	27,'Y',32+12,32+8,"F5 = Illusion (STE only)"
	dc.b	27,'Y',32+14,32+10,"F6 = No Cooper Demo"
	dc.b	27,'Y',32+20,32+8,"Disk compiled by: MUG U.K",191
	dc.b	0
	even

loading	dc.b	27,'E',7,'Loading ....',13,10,0
	even

blanks	ds.b	14
