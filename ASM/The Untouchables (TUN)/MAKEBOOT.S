*-------------------------------------------------------------------------*
* Create executable bootsector's onto DRIVE A..
*-------------------------------------------------------------------------*
* Coded by the Highlander in November 91.
*-------------------------------------------------------------------------*
* Please be warned that I accept no responsibility if you fuck up any of
* your disks with this program!
*-------------------------------------------------------------------------*

;TEST			; have this un-commented to just run boot sector
			; and not install it on the disk

*-------------------------------------------------------------------------*

GET:		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		IFD	TEST
		move.w	#0,-(sp)	; go low rez
		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea.l	12(sp),sp
		bsr	BOOTSECTOR	; run bootsector
		ELSE
LD:		move.w	#1,-(sp)	; load existing boot sector
		move.w	#0,-(sp)
		move.w	#0,-(sp)
		move.w	#1,-(sp)
		move.w	#0,-(sp)
		clr.l	-(sp)
		move.l	#BT,-(sp)
		move.w	#8,-(sp)
		trap	#14
		lea.l	20(sp),sp
		lea	CODE,a0
		lea	BT+$3a,a1
		move.w	#((512-$3a)/4)-1,d0
.copy:		move.l	(a0)+,(a1)+		; copy new boot
		dbra	d0,.copy		; over.
		move.w	BOOTSECTOR,BT

		lea.l	BT,a0
		move.w	#(512/2)-2,d7
		moveq	#0,d0
.ADD:		add.w	(a0)+,d0
		dbra	d7,.ADD	
		move.w	#$1234,d1
		sub.w	d0,d1
		move.w	d1,BT+$1fe		; make checksum correct.

SAVE:		move.w	#1,-(sp)		; save new boot sector.
		move.w	#0,-(sp)
		move.w	#0,-(sp)
		move.w	#1,-(sp)
		move.w	#0,-(sp)
		clr.l	-(sp)
		move.l	#BT,-(sp)
		move.w	#9,-(sp)
		trap	#14
		lea.l	20(sp),sp
		ENDC
		move.w	#$777,$fff8240
		clr.w	$fff8240+30
		clr.w	-(sp)
		trap	#1

BT:		ds.l	512/4

BOOTSECTOR:	bra.s	CODE
		ds.b	$38

*-------------------------------------------------------------------------*
* OKAY FROM HERE ON IN, YOU CAN PUT YOUR OWN CODE ALL 454 BYTES.
* Remember to make sure all code is fully address independent.
*-------------------------------------------------------------------------*
* What is here at the moment is a simple screen fade.
* Which afterwards displays a virus all clear message,
* before exiting.
*-------------------------------------------------------------------------*
	
CODE:		lea	$fff8242,a0
		moveq	#0,d0
		move.w	#$777,d7
		move.w	d7,$fff8240	; colour 0 = white
		move.w	d7,$fff8240+30	; colour 15 also = white
.FADE:		moveq.w	#3,d6
.FADE2:		move.w	#37,-(sp)
		trap	#14
		addq.w	#2,sp
		dbra	d6,.FADE2
		sub.w	#$111,d7
		bmi.s	.END
		move.w	d7,$fff8240
		bra.s	.FADE
.END:		pea	TEXT(PC)
		move.w	#9,-(sp)	; display text
		trap	#1
		addq.l	#6,sp
		moveq	#30,d6		; hold screen for while.
.WT1:		move.w	#-1,d7
.WT2:		dbra	d7,.WT2
		dbra	d6,.WT1
		rts			; exit boot sector.

TEXT:		dc.b	27,"E"		; clear screen
		dc.b	"THE HIGHLANDER OF TPT AND THE ENTERPRISE",10,13
		dc.b	"========================================",10,13
		dc.b	10,13
		dc.b	"FIND'S NO VIRUS ON THIS BOOTSECTOR!!!!!!",10,13
		dc.b	0
		