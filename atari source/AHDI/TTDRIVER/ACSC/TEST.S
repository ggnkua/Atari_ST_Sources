;;; test.s
;
;	test -- repeated writes/reads to TOS logical device
;
;	mac -p -o test.prg test.s		; buffer in ST RAM
;	mac -dFASTRAM -p -o testfr.prg test.s	; buffer in FAST RAM
;	mac -dDEVICE=0 -p -o testflp.prg test.s	; device != 2
;	mac -dOFFSET=1 -p -o test1.prg test.s	; non-aligned xfers
;
;	15Mar89	jwt	kludged together, beware the Ides
;	16Mar89	jwt	added non-aligned transfers
;	08Aug89	jwt	more flexibility in buffer alignment, local stack
;	10Aug89	jwt	show device driver version
;	20Aug89	jwt	add test for second bank of system RAM (no Malloc()!)

  .if !(^^defined DEVICE)
DEVICE	EQU	2
  .endif

  .if !(^^defined OFFSET)
OFFSET	EQU	2
  .endif

  .if (DEVICE=0)|(DEVICE=1)
RECNO	EQU	$40
  .else ; a hard disk
RECNO	EQU	$1000
  .endif

SECCNT	EQU	40
BUFSIZ	EQU	SECCNT*$200
SLOP	EQU	8		; space allowed between buffers (in bytes)

RWABS	EQU	4
READ	EQU	0
WRITE	EQU	1

BIOS	EQU	13

LF	EQU	$0A
CR	EQU	$0D

hdv_bpb	equ	$472

  .if ^^defined FASTRAM
rbuffer	EQU	$01000000+OFFSET
rbuf2	EQU	rbuffer+BUFSIZ+SLOP
rbuf3	EQU	rbuf2+BUFSIZ+SLOP
  .endif

  .if ^^defined SYS2RAM
rbuffer	EQU	$00200000+OFFSET
rbuf2	EQU	rbuffer+BUFSIZ+SLOP
rbuf3	EQU	rbuf2+BUFSIZ+SLOP
  .endif

	.include "version.s"

	.text
start:	move.l	#stack,d0
	andi.b	#$FC,d0		; make sure it is long word aligned
	movea.l	d0,sp		; set up our local stack

	movea.l	#msg,a0
	bsr	puts
  .if !((^^defined FASTRAM)|(^^defined SYS2RAM))
	move.l	buffer,d0	; is it properly aligned?
	andi.l	#3,d0
	cmpi.w	#OFFSET,d0
	beq.s	start1
	neg.l	d0
	addq.l	#OFFSET+4,d0
	add.l	d0,buffer
	add.l	d0,buf2
	add.l	d0,buf3
  .endif ; no FASTRAM or SYS2RAM
start1:	move.l	buffer,d0
	bsr	putlon

	movea.l	#rb2msg,a0
	bsr	puts
	move.l	buf2,d0
	bsr	putlon

	movea.l	#rb3msg,a0
	bsr	puts
	move.l	buf3,d0
	bsr	putlon

	movea.l	#ofmsg,a0
	bsr	puts

	move.l	buffer,d0
	andi.w	#3,d0
	bsr	putbyt

	movea.l	#blkmsg,a0
	bsr	puts

	move.w	#RECNO,d0
	bsr	putwor

	movea.l	#secmsg,a0
	bsr	puts

	move.w	#SECCNT,d0
	bsr	putwor

  .if (DEVICE>1)
	movea.l	#crlf,a0
	bsr	puts

	movea.l	#crlf,a0
	bsr	puts

	move.l	#gethdv,-(sp)
	move.w	#38,-(sp)	; Supexec(GetHDV)
	trap	#14
	addq	#6,sp

	movea.l	lhdv_bpb,a3
.1:	cmpi.b	#'@',(a3)
	bne.s	.6
	cmpi.b	#'(',1(a3)
	bne.s	.6
	cmpi.b	#'#',2(a3)
	bne.s	.6
	cmpi.b	#')',3(a3)
	bne.s	.6
	lea	4(a3),a0
	bsr	puts
	bra.s	start2

.6:	subq	#1,a3
	cmpa.l	#$7FF,a3
	bne	.1

	movea.l	#unkdrv,a0
	bsr	puts
  .endif ; (DEVICE>1)

start2:	movea.l	#sure,a0
	bsr	puts
	move.w	#DEVICE,d0
	bsr	putbyt
	movea.l	#sure2,a0
	bsr	puts
	move.b	#80,rbuffer
	move.l	#rbuffer,-(sp)
	move.w	#$0a,-(sp)
	trap	#1
	addq	#6,sp
	movea.l	#crlf,a0
	bsr	puts

	move.b	rbuffer+2,d0	; get the first character of the answer
	cmpi.b	#'Y',d0
	beq.s	.0
	cmpi.b	#'y',d0
	bne	exit
.0:	move.l	#0,pass
	move.l	#0,errors
	move.b	#0,bHadError

  .if (DEVICE=0) | (DEVICE=1)
	move.w	#DEVICE,-(sp)
	move.w	#7,-(sp)	; getBPB()
	trap	#13
	addq	#4,sp
  .endif

loop:	movea.l	buffer,a0	; initialize the buffer
	move.l	pass,d0		; data pattern
	move.w	#BUFSIZ-1,d1
loop1:	move.b	d0,(a0)+
	addq.b	#1,d0
	dbra	d1,loop1

	move.l	#$11223344,(a0)+
	move.l	#$55667788,(a0)

	movea.l	#pasmsg,a0
	bsr	puts

	move.l	pass,d0
	bsr	putlon

	movea.l	#ecntmsg,a0
	bsr	puts

	move.l	errors,d0
	bsr	putlon

	move.w	#' ',d0	
	bsr	putc

	move.w	#'W',d0
	bsr	putc

	move.w	#DEVICE,-(sp)
	move.w	#RECNO,-(sp)
	move.w	#SECCNT,-(sp)
	move.l	buffer,-(sp)
	move.w	#WRITE,-(sp)
	move.w	#RWABS,-(sp)
	trap	#BIOS
	adda.l	#14,sp

	or.b	d0,d0
	beq.s	.1

	neg	d0
	bsr	putbyt
	addi.l	#1,errors
	movea.l	#crlf,a0
	bra	.55

.1:	movea.l	buf2,a0		; clear out the buffer(s)
	movea.l	buf3,a1
	clr.l	d0
	move.w	#BUFSIZ-1,d1
.10:	move.b	d0,(a0)+
	move.b	d0,(a1)+
	dbra	d1,.10

	move.w	#'R',-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp

	move.w	#DEVICE,-(sp)
	move.w	#RECNO,-(sp)
	move.w	#SECCNT,-(sp)
	move.l	buf2,-(sp)
	move.w	#READ,-(sp)
	move.w	#RWABS,-(sp)
	trap	#BIOS
	adda.l	#14,sp

	or.b	d0,d0
	beq.s	.2

	neg	d0
	bsr	putbyt
	addi.l	#1,errors
	movea.l	#crlf,a0
	bra	.55

.2:	move.w	#'S',-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp

	move.w	#DEVICE,-(sp)
	move.w	#RECNO,-(sp)
	move.w	#SECCNT,-(sp)
	move.l	buf3,-(sp)
	move.w	#READ,-(sp)
	move.w	#RWABS,-(sp)
	trap	#BIOS
	adda.l	#14,sp

	or.b	d0,d0
	beq.s	.21

	neg	d0
	bsr	putbyt
	addi.l	#1,errors
	movea.l	#crlf,a0
	bra	.55

.21:	move.w	#'C',-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp

	movea.l	buffer,a3	; pointer to the write buffer
	movea.l	buf2,a4		; pointer to the read buffer
	movea.l	buf3,a5		; pointer to second read buffer
	move.w	#BUFSIZ-1,d5	; number of bytes in the buffer
.3:	move.b	(a3)+,d3	; get a byte that was written
	move.b	(a4)+,d4	; get the byte as read back
	move.b	(a5)+,d5	; get the other read result
	cmp.b	d3,d4		; are they the same
	bne.s	.31		; yes, okay fine
	cmp.b	d3,d5
	beq	.4

.31:	addi.l	#1,errors
	move.w	#-1,bHadError

	movea.l	#errmsg,a0
	bsr	puts

	move.l	a3,d0
	subq.l	#1,d0		; adjust for already auto ++ing
	bsr	putlon

	movea.l	#err1msg,a0
	bsr	puts

	move.l	a3,d0
	sub.l	buffer,d0
	subq.w	#1,d0
	bsr	putwor

	movea.l	#err2msg,a0
	bsr	puts

	move.w	d3,d0
	bsr	putbyt		; show d3 == (a3)

	movea.l	#err3msg,a0
	bsr	puts

	move.w	d4,d0		; show d4 == (a4)
	bsr	putbyt

	movea.l	#err4msg,a0
	bsr	puts

	move.w	d5,d0		; show d5 == (a5)
	bsr	putbyt

  .if (DEVICE>1)
	move.l	#getres,-(sp)
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp

	movea.l	#resmsg,a0
	bsr	puts

	move.l	lresidue,d0
	bsr	putlon

	movea.l	#ptrmsg,a0
	bsr	puts

	move.l	lptr,d0
	bsr	putlon
  .endif ;(DEVICE>1)

	move.w	#$b,-(sp)	; is there a character typed?
	trap	#1
	addq	#2,sp

	or.w	d0,d0		; -1 if so
	bne.s	.99

.4:	dbra	d5,.3

	tst.w	bHadError
	beq.s	.5

	movea.l	#crlf,a0
	bsr	puts

	clr.w	bHadError

.5:	move.w	#'.',-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp

	movea.l	#crmsg,a0
.55:	bsr	puts

	addi.l	#1,pass

	move.w	#$b,-(sp)	; is there a character typed?
	trap	#1
	addq	#2,sp

	or.w	d0,d0		; -1 if so
	beq	loop

.99:	move.w	#1,-(sp)	; read and ignore the character
	trap	#1
	addq	#2,sp

exit:	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1

  .if (DEVICE>1)
gethdv:	move.l	hdv_bpb,lhdv_bpb
	rts

getres:	move.l	$FFFF8710,lresidue
	movea.l	#$FFFF8701,a0
	movep.l	(a0),d0
	move.l	d0,lptr
	rts
  .endif (DEVICE>1)

;
;	putlon - put d0.l as 8 hex digits
;	putwor - put d0.w as 4 hex digits
;	putbyt - put d0.b as 2 hex digits
;	putnib - put 4 lsbs as a hex digit

putlon:	move.l	d0,-(sp)
	swap	d0
	bsr.s	putwor
	move.l	(sp)+,d0
putwor:	move.w	d0,-(sp)
	asr	#8,d0
	bsr.s	putbyt
	move.w	(sp)+,d0
putbyt:	move.w	d0,-(sp)
	asr	#4,d0
	bsr.s	putnib
	move.w	(sp)+,d0
putnib:	andi.b	#$0f,d0
	addi.b	#'0',d0
	cmpi.b	#'9',d0
	ble.s	putb2
	addq.b	#7,d0
putc:
putb2:	move.l	d0,-(sp)

	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp

	move.l	(sp)+,d0
	rts

puts:	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

	.data
msg:	dc.b	'Disk Read/Write  (through Rwabs())'
	dc.b	CR,LF
	dc.b	'  ('
	VERSION
	dc.b	')',CR,LF
	dc.b	' Write buffer @ 0x',0
rb2msg:	dc.b	CR,LF,' Read buffer1 @ 0x',0
rb3msg:	dc.b	CR,LF,' Read buffer2 @ 0x',0
ofmsg:	dc.b	CR,LF,'  offset: ',0
blkmsg:	dc.b	CR,LF,'  starting at sector: 0x',0
secmsg:	dc.b	'  number of sectors: 0x',0

  .if (DEVICE>1)
unkdrv:	dc.b	'*** Unknown device driver***',CR,LF,0
resmsg:	dc.b	CR,LF,'Residue: 0x',0
ptrmsg:	dc.b	'  Ptr: 0x',0
  .endif ;(DEVICE>1)

sure:	dc.b	CR,LF
	dc.b	'Are you SURE you want to trash media in TOS unit ',0
sure2:	dc.b	' ?',0
crlf:	dc.b	CR,LF,0
crmsg:	dc.b	CR,0

pasmsg:	dc.b	'Pass: 0x',0
ecntmsg: dc.b	' Errors: 0x',0
errmsg:	dc.b	CR,LF,'Error @ wbuf 0x',0
err1msg: dc.b	' (offset 0x',0
err2msg: dc.b	')  Wr: 0x',0
err3msg: dc.b	' Rd: 0x',0
err4msg: dc.b	' 2nd Rd: 0x',0
	.even

buffer:	dc.l	rbuffer
buf2:	dc.l	rbuf2
buf3:	dc.l	rbuf3

	.bss
pass:	ds.l	1
errors:	ds.l	1
lhdv_bpb: ds.l	1
lresidue: ds.l	1
lptr:	ds.l	1
bHadError: ds.w	1

  .if !((^^defined FASTRAM)|(^^defined SYS2RAM))
	ds.b	SLOP
rbuffer: ds.b	BUFSIZ
	ds.b	SLOP
rbuf2:	ds.b	BUFSIZ
	ds.b	SLOP
rbuf3:	ds.b	BUFSIZ
	ds.l	2
  .endif

	ds.l	1
	ds.b	4096
stack:	ds.l	1
	.end
