* ramdisk.s

*------------------------------------------------------------------------
*									:
*	ST RAMDISK driver (M:)						:
*	Conditional assembly for 128K/512K Ramdisk			:
*									:
*	Public Domain (give it away, folks!)				:
*	This program, or any work derived from it, may not be sold	:
*	without permission from Atari Corp.				:
*									:
*----									:
*	Stick this program in the \AUTO folder of the boot volume.  Or,	:
*	you can simply double-click it after the desktop comes up.	:
*									:
*----									:
*  9-Aug-1985 lmd	Hacked it up					:
*  9-Jan-1986 lmd	Fixed sign-extension problem in _rw: and added	:
*			conditional assembly for two kinds of ramdisk.	:
*  9-Jan-1986 lmd	Make it "M:"					:
* 16-Apr-1986 lmd	Made it easier to adjust size of ramdisk. Print	:
*			correct size of ramdisk.			:
*									:
*------------------------------------------------------------------------


*+
* Define the size of the ramdisk here:
*
* (12k overhead)
*-
ramdisk_size	equ	400		; perceived size, in K


*+
*  OS variables and vectors;
*  (stuff we have to subvert.)
*
*-
hdv_init	equ	$46a		; hdv_init()
hdv_bpb		equ	$472		; hdv_bpb(dev)
hdv_rw		equ	$476		; hdv_rw(rw, buf, count, recno, dev)
hdv_boot	equ	$47a		; hdv_boot()
hdv_mediach	equ	$47e		; hdv_mediach(dev)
_drvbits	equ	$4c2		; block device bitVector
_dskbufp	equ	$4c6		; pointer to common disk buffer
realsize	equ	ramdisk_size+12	; *REAL* size of the disk


*+
*  Install driver;
*  setup ramdisk, then
*  terminate and stay resident.
*
*-
	move.l	4(sp),a4		; a4 -> our basepage
	lea	stack,a7		; new user stack
	clr.l	-(sp)			; get superuser mode
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)		; save old SSP on stack

	bset.b	#4,_drvbits+2		; set bit for M:
	clr.l	a5			; easy zero-based pointer
	move.l	hdv_bpb(a5),o_bpb	; save old disk vectors
	move.l	hdv_rw(a5),o_rw
	move.l	hdv_mediach(a5),o_mediach
	move.l	#hbpb,hdv_bpb(a5)	; install ramdisk's vectors
	move.l	#hrw,hdv_rw(a5)
	move.l	#hmediach,hdv_mediach(a5)

	move.w	#$20,-(sp)		; back to user mode
	trap	#1			; (SSP already on the stack)
	addq	#6,sp

*--- clear first 8K of ramdisk:
	lea	ramdisk(pc),a0
	move.w	#$400-1,d0
clrit:	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,clrit

*--- compute size of memory we want to keep:
	move.l	$c(a4),d3		; d3 = size of text
	add.l	$14(a4),d3		; d3 += size of data
	add.l	$1c(a4),d3		; d3 += size of bss
	add.l	#$0100,d3		; d3 += size of basepage
	add.l	#realsize*1024,d3	; d3 += size of ramdisk

	pea	message(pc)		; print something informative
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

*--- terminate and stay resident
	clr.w	-(sp)			; return code of zero
	move.l	d3,-(sp)		; # bytes to keep
	move.w	#$31,-(sp)		; Ptermres()
	trap	#1			; do it
	illegal				; "cannot happen"



*+
* LONG hbpb(dev) - return ptr to BPB (or NULL)
*
* Passed:	dev	4(sp).W
*
*-
hbpb:
	move.w	4(sp),d0		; d0 = devno
	move.l	o_bpb,a0		; a0 -> pass-through vector
	lea	_bpb(pc),a1		; a1 -> our handler
	bra	check_dev		; do it


*+
* LONG rw(rw, buf, count, recno, dev)
*
* Passed:	dev	$e(sp).W
*		recno	$c(sp).W
*		count	$a(sp).W
*		buf	6(sp).L
*		rw	4(sp).W
*
*-
hrw:
	move.w	$e(sp),d0		; d0 = devno
	move.l	o_rw,a0			; a0 -> pass-through vector
	lea	_rw(pc),a1		; a1 -> our handler
	bra	check_dev		; do it


*+
* LONG mediach(dev)
*
* Passed:	dev	4(sp).W
*
*-
hmediach:
	move.w	4(sp),d0		; d0 = devno
	move.l	o_mediach,a0		; a0 -> pass-through vector
	lea	_mediach(pc),a1	; a1 -> our handler


*+
* check_dev - use handler, or pass vector through
*
* Passed:	d0.w = device#
*		a0 ->  old handler
*		a1 ->  new handler
*		a5 ->  $0000 (zero-page ptr)
*
* Jumps-to:	(a1) if dev in range for this handler
*		(a0) otherwise
*
*-
check_dev:
	cmp.w	#12,d0			; M:?
	bne	chkd_f			; (no)
	move.l	a1,a0			; yes -- follow success vector
chkd_f:	jmp	(a0)			; do it



*+
* _bpb - return BPB for RAMDISK
*  Synopsis:	LONG _bpb(dev)
*		WORD dev;
*
*  Returns:	NULL, or a pointer to the BPB buffer
*
*-
_bpb:
	move.l	#thebpb,d0
	rts


*+
* _rw - read/write ramdisk sectors
*  Synopsis:	_rw(rw, buf, count, recno, dev)
*
*  Passed:	dev	$e(sp).W
*		recno	$c(sp).W
*		count	$a(sp).W
*		buf	6(sp).L
*		rw	4(sp).W
*
*-
_rw:
	lea	ramdisk(pc),a0		; a0 -> base of ramdisk
	moveq	#0,d0
	move.w	$c(sp),d0		; d0 = sect# << 9
	lsl.l	#8,d0
	lsl.l	#1,d0
	add.l	d0,a0			; a0 -> ramdisk mem

	moveq	#0,d2			; d2 = byte count / 32
	move.w	$a(sp),d2
	lsl.l	#4,d2			; log2(512 / 32) = 4

	move.l	6(sp),a1		; a1 -> buffer
	tst.w	4(sp)			; if (rw) exchange(a0, a1)
	beq	_rrw1
	exg	a0,a1			; swap src & dest

_rrw1:
_rrw2:	move.l	(a0)+,(a1)+		; move 32 bytes
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	subq.l	#1,d2			; while (--d2)
	bmi	_rrwq
	bne	_rrw2

_rrwq:	clr.l	d0			; return OK
	rts


*+
* _mediach - return FALSE media change (RAMDISK never changes)
* Synopsis:	_mediach(dev)
*		WORD dev;
*
* Returns:	0L
*
*-
_mediach:
	clr.l	d0
	rts


*+
*  BPB for ramdisk
*
*-
thebpb:
	dc.w	512			; #bytes/sector
	dc.w	2			; #sectors/cluster
	dc.w	1024			; #bytes/cluster
	dc.w	4			; rdlen (64 files)
	dc.w	4			; fat size
	dc.w	4			; 2nd FAT start
	dc.w	12			; 1st cluster start
	dc.w	realsize-12		; #clusters on media
	dc.w	1			; flags (16-bit FATs)



o_init:		dc.l	0		; old hdv_init
o_bpb:		dc.l	0		; old hdv_bpb
o_rw:		dc.l	0		; old hdv_rw
o_mediach:	dc.l	0		; old hdv_mediach

rds100		equ	ramdisk_size/100
rds10		equ	(ramdisk_size-(rds100*100))/10
rds1		equ	(ramdisk_size-((rds100*100)+(rds10*10)))

message:
siz100:		dc.b	rds100+'0'
siz10:		dc.b	rds10+'0'
siz1:		dc.b	rds1+'0'
		dc.b	'K RAMDISK installed as M:'
		dc.b	13,10
		dc.b	'version 16-Apr-1986 lmd.'
		dc.b	13,10
		dc.b	0

    even
ramdisk:	dc.w	0		; beginning of Ramdisk
stack		equ	ramdisk+realsize
