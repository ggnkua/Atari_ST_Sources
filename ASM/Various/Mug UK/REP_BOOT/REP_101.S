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
	dc.b	"| Source #101 Bootsector Repairer |",13,10
	dc.b	"|                                 |",13,10
	dc.b	"|   by: MUG U.K (of The Source)   |",13,10
	dc.b	"+---------------------------------+",13,10,10
	dc.b	"Use this program to repair the",13,10
	dc.b	"bootsector on Source #101.",13,10
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
; Source Menu 101 - Bootsector by MUG U.K
;
; This disk will contain 'The Black Demo', which is why the
; bootsector loader is necessary
;
; If the user holds down 'F1' in the permitted time, then the menu
; is loaded, else the Black Demo is loaded !!

	opt	p+

	bra.s	start
	dc.b	"Code by: MUG U.K",191," (of The Source)"
	even

start	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	bclr	#0,$484.w		; bell off

	move.l	#80000,d1		; slight pause
pause	cmp.b	#$3B,$fffffc02.w	; hold down F1 for menu
	beq.s	exit
	subq.l	#1,d1 
	bne.s	pause

loadblk	lea	blackdemo(pc),a0	; F1 was NOT pressed, so we
	bra.s	loadfile		; load The Black Demo

exit	lea	desktop(pc),a0	; We want to see the menu !!

loadfile	pea	null(pc)		; command line
	pea	null(pc)		; environment
	move.l	a0,-(sp)		; filename
	clr.w	-(sp)		; load & execute
	move.w	#$4b,-(sp)	; p_exec
	trap	#1		; do it !!
	lea	16(sp),sp		; tidy stack

	bset	#0,$484.w		; bell on 
	rts

text	dc.b	27,"E"
	dc.b	"Source 101",13,10
	dc.b	"----------",13,10,10
	dc.b	"Hold down F1 to load 'Source 94' Menu",13,10
	dc.b	"or wait for The Black Demo to load !!",13,10,10

	dc.b	"The menu has the full graphic account",13,10
	dc.b	"of why this disk has been set out in this",13,10
	dc.b	"way - but at least it's 150K smaller !!!",13,10,10

	dc.b	"All packing, hacking and bootsector/menu",13,10
	dc.b	"coding by: MUG U.K",191," - 04/12/1991",13,10
	dc.b	"",0
	even

blackdemo	dc.b	'\blackdem.mug',0
	even

desktop	dc.b	'\sourc101.mug',0
	even

null	dc.b	'',0
	even

blanks	ds.w	15