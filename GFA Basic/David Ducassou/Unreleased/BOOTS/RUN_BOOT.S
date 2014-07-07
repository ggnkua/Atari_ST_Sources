	opt	d-

	bra	DADU_RUN_BOOT
	dc.b	" DADU RUN BOOT  v1.0  19/07/92.   ",$a,$d

	dc.b	"This routine may be able to run an executable boot-sector. "
	dc.b	"The risks to crash the ST are enormous.  ",$a,$d

	dc.b	"Code by DAvid DUcassou, route de monsegur, 40700 Hagetmau, France.  ",$00
	even

DADU_RUN_BOOT:
	bsr	SUPERVISOR

	move.w	#$2714,sr		; SR boot value

	bsr	GETREZ	
	
	cmp.b	#$0,d0
	beq.s	CONTINUE
	cmp.b	#$2,d0
	beq.s	CONTINUE

	move.w	d0,OLD_RES
	move.w	#$0,d1
	bsr	SETSCREEN

CONTINUE	
	bsr	BOOT_SECTOR
AFTER:
	bsr	GETREZ	
	move.w	(OLD_RES),d1
	cmp.w	d1,d0
	beq.s	DONT_CHANGE_RES

	bsr	SETSCREEN

DONT_CHANGE_RES:	
	bsr	SUPERVISOR

	clr.w	-(sp)
	trap	#1

SUPERVISOR
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	

GETREZ	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

SETSCREEN:
	move.w	d1,-(sp)

	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.l	#12,sp	
	rts

OLD_RES	ds.w	1

	dc.b	"   Here, copy the 512 bytes of the boot:"
	even

BOOT_SECTOR:	
;	incbin	"e:\gfabasic\divers\boots\fract*.bin"
	incbin	"e:\devpac\div_a\boots\revol*.bin"


	ds.b	5000		

	dc.b	"These free bytes may avoid the boot to "
	dc.b	"crush some usefull stuffs. DADU.",$0
