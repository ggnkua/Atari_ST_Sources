;-----------------------------------------------------------
; Bootsector Installer by Eqqyfump for personal use
;
; This one contains a complete menu for packed programs etc.
;-----------------------------------------------------------


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
	
_exit	clr.w	-(sp)
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
		
guardmess	dc.b	27,"EInsert Disk To Be Installed.",13,10,10
	dc.b	"Press 'A' to write to the disk in drive A",13,10
	dc.b	"      'B' to write to the disk in drive B",13,10
	dc.b	"     'ESC' to abort.",0
guardclr	dc.b	13,10,10,10
	dc.b	"Writing ... Please Wait",0
		
	even
	
* 512 byte buffer for bootsector read from disk
	
bootbuffer	ds.b	512

* Pre constructed boot sector minus statistics

bootst
mybuffer	ds.b	30

	opt p+

color	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea text(pc)
	move.w #9,-(sp)
	trap #1

	move.l	$70.w,-(a7)
	lea	new_vbl(pc),a0
	move.l	a0,$70.w

get_key	move.w #7,-(sp)
	trap #1
	addq.l #2,sp

key1	cmp.b #$31,d0	; was 1 pressed ???
	bne.s key2	; no it wasn't - try for 2 or 3
	lea welltris(pc),a0	; if it was then set-up filename in (a0)
	bra.s load	; and load it

key2	cmp.b #$32,d0	; was 2 pressed ???
	bne.s key3	; no it wasn't - try for 3
	lea buildland(pc),a0 ; if it was then set-up filename in (a0)
	bra.s load	; and load it

key3	cmp.b #$33,d0	; was 3 pressed ??
	bne.s key4	; no it wasn't - redo key_loop
	lea l_puff(pc),a0	; if it was then set-up filename in (a0)
	bra.s load

key4	cmp.b #$34,d0
	bne.s get_key
	lea please(pc),a0

load	move.l	(a7)+,$70.w	; re-install $70 address
	move.w	#$777,$ff8240	; reset palette
	move.w	#$000,$ff825e
	
	pea xxx(pc)		; load file
	pea xxx(pc)
	move.l a0,-(sp)
	clr.w -(sp)
	move.w #$4b,-(sp)
	trap #1

xxx	dc.l $0,$f0f1f0f1

new_vbl	lea $ffff8800.w,a0
	move.l	#$700f800,(a0)
	move.l	#$f300,(a0)
	move.l	#$1000600,(a0)
	move.l	#$200f000,(a0)
	move.l	#$3000600,(a0)
	move.l	#$8000f00,(a0)
	move.l	#$9000f00,(a0)
	rte

welltris	dc.b "welltris.eqq",0

buildland	dc.b "build.eqq",0

l_puff	dc.b "l_puff.eqq",0

please	dc.b "pleasure.m_v",0

text	dc.b "The Bog Brothers Disk Saver #1",$d,$a
	dc.b "------------------------------",$d,$a,$a,$a
	dc.b "Press: 1 for Welltris.",$d,$a,$a
	dc.b "       2 for Builderland.",$d,$a,$a
	dc.b "       3 for Little Puff.",$d,$a,$a
	dc.b "       4 for Pleasure Dome.",$d,$a,$a,$a
	dc.b "Bootsector menu coded by Eqqyfump!",$d,$a
	dc.b 0
	ds.w 20
