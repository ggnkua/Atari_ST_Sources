*FIC V2
	text
begin
	clr.l	-(sp)		;supervisor
	move.w	#$20,-(sp)
	trap	#1

	movea.l	$42e.w,a0	;RAM top
	lea	-8(a0),a7	;make stack at RAM top
	move	a7,usp

	cmpi.b	#2,$44c.w	;check for high rez
	bne.s	.skip
	addq.w	#1,rez		;make rez high (change default from med rez)
.skip	move.w	#1,-(a7)	;put into high rez at default
rez	equ	*-2
	pea	$ffffffff.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)	;change rez
	trap	#$e
	lea	12(a7),a7

	move.l	#$7770700,$ffff8240.w	;sort colours
	move.l	#$700000,$ffff8244.w

	move.l	$44e.w,d0	;get screen base
	subi.l	#loadarea,d0
	move.l	d0,l000d
	move.l	d0,l0011

*we need to search for the CRC check data...
	lea	filelist(pc),a4	;point to list of filenames
	movea.l	a4,a6		;stash this is A6
.crc	cmpi.w	#" c",(a6)+	;is " c"????
	bne.s	.crc		;no so get another lot
	addq.l	#2,a6		;yes it says " c" so add past "rc"
l0003	cmpi.b	#" ",(a4)
	beq.s	fin
	tst.b	(a4)
	beq.s	fin

	lea	checking(pc),a0
	bsr.s	print

	movea.l	a4,a0
	bsr.s	print

	bsr.s	l000b

	cmp.l	#$1001b,d0	;*******
	beq.s	fin
l0004	tst.b	(a4)+
	bne.s	l0004
	move.l	(a6)+,d6
	cmp.l	d0,d6
	beq.s	l0003
	st	fail_flag

	lea	bad(pc),a0
l0005	bsr.s	print
	bra.s	l0003

fin	moveq	#0,d0
fail_flag	equ	*-1
	tst.l	d0		;any file probles
	beq.s	.allok		;no
	lea	file_fail(pc),a0	;yes
	bra.s	.common
.allok	lea	all_okay(pc),a0
.common	bsr.s	print
	bsr	getkey
	move.l	4.w,-(a7)	;reset
	rts

print	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

l000b	bsr	check_key
	cmp.b	#27,d0		;check for ESC key
	beq.s	return

	clr.w	-(a7)		;select read only
	pea	(a4)		;put filename on stack
	move.w	#$3d,-(a7)	;open file
	trap	#1
	addq.l	#8,a7
	tst.l	d0		;test for good load
	bmi.s	open_err	;bad open! (file not found)
	clr.l	crc

	move.w	d0,d7		;put file handle into D7
l000c	pea	loadarea
	pea	$deadface.l	;number of bytes to read (self mod code)
l000d	equ	*-4
	move.w	d7,-(a7)	;handle
	move.w	#$3f,-(a7)	;read
	trap	#1
	lea	12(a7),a7
	tst.l	d0		;test for good load
	bmi.s	read_err
	move.l	d0,bytesread	;number of bytes read

	bsr.s	check_key
	cmp.b	#27,d0		;is ESC key
	beq.s	close_file

	lea	loadarea,a0
	move.l	#$deadface,d0	;number of bytes read
bytesread	equ	*-4
	move.l	d0,d1
	move.l	d0,d2
	move.l	#$deadface,d0	;crc
crc	equ	*-4
.check_loop
	add.b	(a0)+,d0	;add a byte from the file to our crc
	rol.l	#1,d0		;do something with the numbers (it actually rotates it left!)
				;the 'do something' could be anything
				;from an add to an eor, etc.
	subq.l	#1,d1		;decrease file length
	bne.s	.check_loop	;carry on doing check
	move.l	d0,crc
	cmp.l	#$deadface,d2
l0011	equ	*-4
	beq.s	l000c

close_file
	move.l	d0,-(a7)	;save D0
	move.w	d7,-(a7)	;handle
	move.w	#$3e,-(a7)	;close file
	trap	#1
	addq.l	#4,a7
	move.l	(a7)+,d0	;restore D0
return	rts

open_err
	lea	erroropen(pc),a0
	bra.s	l0016

read_err
	lea	errorread(pc),a0
l0016	addq.l	#4,a7		;skip over RTS command
	st	fail_flag
l0017	tst.b	(a4)+
	bne.s	l0017
	move.l	(a6)+,d6
	bra	l0005

getkey	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

check_key
	pea	$600ff		;read a byte from standard input (kbd)
	trap	#1
	addq.l	#4,a7
	rts

	data
checking	dc.b	$1b,'lChecking: ',0

bad	dc.b	7,' : ',$1b,'b1BAD!',$1b,'b',$f,7,$d,$a
	dc.b	$a,0

erroropen
	dc.b	7,' : ',$1b,'b1File not found!',$1b,'b'
	dc.b	$f,7,$d,$a,$a,0

errorread
	dc.b	7,' : ',$1b,'b1Error reading file, recopy this disk!',$1b,'b',$f,7
	dc.b	$d,$a,$a,0

all_okay
	dc.b	27,'l',$a,'This disk is a perfect copy, all files are '
	dc.b	'intact!',7,0

file_fail
	dc.b	27,'l',$a,'The above file(s) failed to checksum correctly'
	dc.b	'!',0

filelist
	dc.b	'WITCHLRD.PRG',0
	dc.b	'SCRUSADE.PRG',0
	dc.b	'READ_ME.PP',0
	dc.b	'AUTO\MENU113.PRG',0
	dc.b	' crc'
;CRC for each file
	dc.l	$42a52836
	dc.l	$8867aa6f
	dc.l	$0d910a24
	dc.l	$b1ca1e4a

loadarea
