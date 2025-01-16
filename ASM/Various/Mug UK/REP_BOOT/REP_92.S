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
	dc.b	"+--------------------------------+",13,10
	dc.b	"| Source #92 Bootsector Repairer |",13,10
	dc.b	"|                                |",13,10
	dc.b	"|   by: MUG U.K(of The Source)   |",13,10
	dc.b	"+--------------------------------+",13,10,10
	dc.b	"Use this program to repair the",13,10
	dc.b	"bootsector on Source #92.",13,10
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
 
 
;
; Bootsector Menu by MUG U.K - 18/10/1991
; ---------------------------------------
;
	opt p+,o+,d-,s-

color	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

key1	cmp.b	#$31,d0	; was 1 pressed ???
	bne.s	key2	; no it wasn't - try for 2 or 3
	lea	file1(pc),a0	; if it was then set-up filename in (a0)
	bra.s	load	; and load it

key2	cmp.b	#$32,d0	; was 2 pressed ???
	bne.s	key3	; no it wasn't - try for 3
	lea	file2(pc),a0 ; if it was then set-up filename in (a0)
	bra.s	load	; and load it

key3	cmp.b	#$33,d0	; was 3 pressed ??
	bne.s	key4	; no it wasn't - try for 4
	lea	file3(pc),a0	; if it was then set-up filename in (a0)
	bra.s	load
	
key4	cmp.b	#$34,d0
	bne.s	exit
	lea	file4(pc),a0


load	move.w	#$777,$ff8240	; reset palette
	move.w	#$000,$ff825e
	
	pea	xxx(pc)		; load file
	pea	xxx(pc)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

exit	rts

xxx	dc.l 	0

file1	dc.b "reflex.mug",0

file2	dc.b "cardiaxx.mug",0

file3	dc.b "under_p.mug",0

file4	dc.b "lazer_st.mug",0

text	dc.b "Source 92",$d,$a
	dc.b "---------",$d,$a,$a,$a
	dc.b "Press:  1 - Reflex Demo",$d,$a,$a
	dc.b "        2 - Cardiaxx Demo",$d,$a,$a
	dc.b "        3 - Under Pressure Demo",$d,$a,$a
	dc.b "        4 - Lazer ST Demo",$d,$a,$a
	dc.b "Any other = Exorcist v2.0",$d,$a,$a,$a
	dc.b "Bootsector menu coded by MUG U.K",191,$d,$a
	dc.b 0


blanks	ds.w	50
