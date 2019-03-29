* AGRABOOT v1.0 source code.
; Coded (mostly) by Agrajag in March 1992.
; Based upon some routines used in the 'English Antivirus'
; However, all other code is completely original!

* use for testing it out purposes.
;	pea	code
;	move	#38,-(sp)
;	trap	#14
;	addq.l	#6,sp
;	clr	-(sp)
;	trap	#1

	opt	o+,p+		Optimisation on, and pc-relative

code

start	equ	code-$1e		start of bootsector.

	move	#$7,$ffff8240
	move	#$777,$ffff8242
	bsr.s	clear_r			check reset vector.
	pea     text(pc) 		Nice text message
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	start(pc),a0		Get the start of the bootsector
	movea.l $4c6,a1			ST disk directory buffer.
	lea     3*512(a1),a1 		Add bootsector + 2 FATS - safe place in memory.
	movea.l	a1,a2 
	move	#(512/4)-1,d0		Copy whole bootsector....
.cloop1	move.l	(a0)+,(a1)+		into buffer
	dbf	d0,.cloop1 
	lea	install(pc),a0		Install bit.
	lea	start(pc),a1
	suba.l	a1,a0 
	adda.l  a0,a2 			Work out where it compared in buffer.
	jmp	(a2)			and jump there...

* Check reset vector - to see if it's set. If it is, offer to clear it.

clear_r	lea	$426,a5			Reset vector
	move.l	(a5),d0
	cmpi.l	#$31415926,d0		Is it set?
	bne.s	.ok
.shit	move	#$700,$ffff8240		Warning colours!
	pea	clr(pc)
	move	#9,-(sp)
	trap	#1
	move	#7,-(sp)
	trap	#1
	addq	#8,sp
	swap	d0
	cmp.b	#$15,d0			Clear reset vector?
	bne.s	.ok
	clr	(a5)			Clear it...
	move.l	4,$70			...and reset!
.ok	rts

* Install hdv_vec and flash colours!

install	lea     oldhdv(pc),a0		Save old Hd_Bpb vector
	move.l	$472,(a0) 
	lea	agravec(pc),a0		Put in AGRABOOT vector
	move.l	a0,$472
	moveq	#7,d2 			Flash colours.
.wait1	moveq	#-3,d3
.wait2	eori	#$777,$ffff8240		invert colours
	dbf     d3,.wait2
	dbf	d2,.wait1
	rts 				And return to TOS...

* AGRABOOT v1.0 hdv_vec routine. Called every time directory is read.
; It's pretty shitty now, since I understand how to do this a bit better,
; but what the hell, it's only version 1.0!!!!!

agravec	link    a6,#0		Link a6 to stack (Don't ask- it's shit!)
	move	8(a6),-(a7)		Push drive number on stack (and you thought it'd be 4(a7)!!!)
	movea.l	oldhdv(pc),a0
	jsr	(a0)			Jump through old hdv_vec to update bootsector.
	addq.l	#2,a7 			Correct stack
	movem.l	a0-a2/d0-d4,-(a7) 

* Now to check whether a bootsector is executable or not.

	movea.l	$4c6,a0			The STs own bootsector buffer
	move	#256-1,d1 		512 bytes/2 (We're using word values.)
	moveq	#0,d0 			Clear d0 for checksum
.chksum	add	(a0)+,d0		Add up word values.
	dbf     d1,.chksum
	cmp	#$1234,d0		If they add up to $1234, then the bootsector is executable.
	bne	exit 			If not, it's a clean disk...

* Now check if it's OUR antivirus!

	move.l	$4c6,a0
	adda	#(name-start)+2,a0	At this point, should be 'AGRABOOT'
	move.l	(a0)+,d0
	cmp.l	#'AGRA',d0		Check 1st 4 letters...
	bne.s	check
	move.l	(a0)+,d0
	cmp.l	#'BOOT',d0		...then next 4.
	beq	exit

* Check for virus. There are 2 pointers to a virus - trap #13 rwabs and
* trap #14 flopwr. This is where we check for it.

check	movea.l	$4c6,a0 		bootsector store
	lea	512(a0),a2		end of bootsector
	moveq	#0,d1			status flag
	move	d1,d0
.loop1	add	d0,d1
	cmpa.l	a0,a2			end of bootsector?
	beq.s	get_ready		time to flash colours!
	clr	d0
	cmpi	#$3f3c,(a0)+		move.w command?
	bne.s	.loop1
	lea	virtab(pc),a1		table of hex codes.
.loop2	move	(a0),d3
	move	(a1)+,d4		try 1 - trap #13 rwabs
	cmp.	d3,d4
	bne.s	.again
	addq	#1,d0
	bra.s	.loop2
.again	move	(a0)+,d3
	move	(a1)+,d4		try 2 - trap #14 floprd
	cmp	d3,d4
	bne.s	.ok
	addq	#1,d0
	bra.s	.loop2
.ok	tst.b	d0
	beq.s	.loop1
	subq	#1,d0
	bra.s	.loop1

virtab	dc.w	4,9
	dc.w	$4e4d,$4e4e

get_ready

flash	lea	$ffff8240,a1 		Get ready to flash colour!
	move	(a1),d2
	tst.b	d1			Is alert flag raised.
	beq.s	.ok			If so, flash.....
	move	#$700,(a1)		RED - Suspicious!!
	bra.s	.bing			.... or ....
.ok	eori	#$777,(a1)		INVERT - executable but not suspicious
.bing	lea	$ffff8800,a0 		Now we muck about with the sound....
	move.l	#$5000100,(a0)		BIIIIIiiiiiinnnnngggggggg.......
	move.l	#$a001000,(a0)
	move.l	#$c00a000,(a0)
	move.l	#$700fb00,(a0)
	move.l	#$d000000,(a0)
	moveq	#4,d0 			Wait a bit
.wait1	moveq   #-3,d1
.wait2	dbf     d1,.wait2
	dbf	d0,.wait1
	move	d2,(a1)			Restore background colour

exit	movem.l	(a7)+,a0-a2/d0-d4 	Restore registers.
	unlk	a6			And free a6 from it's terrible ordeal!
	rts

* The nice text message!

text	dc.b	27,'b1',27,'E ',27,'Y',(32+0),(32+15)
name	dc.b	'AGRABOOT!'
	dc.b	27,'Y',(32+7),(32+6),'Flashes if executable boot.'
	dc.b	27,'Y',(32+9),(32+11),'RED if suspicious.',0

; Reset vector message.

clr	dc.b	27,'EReset vector set! Clear?',0

oldhdv	ds.l   1

; END OF CODE ------------------------------------------