*
* XaAES - XaAES Ain't the AES
*
* A multitasking AES replacement for MiNT
*

	globl	,get_butpaks
	globl	btst,bchg,bclr,bset

stdargs equ 0

	text
;	void bclr(long *row,long bit);
bclr:
.if stdargs
	move.l 	8(sp),d0
	move.l	4(sp),a0
.endif
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	rts

;	short btst(long *row,long bit);
btst:
.if stdargs
	move.l 	8(sp),d0
	move.l	4(sp),a0
.endif
	move.b	d0,d1
	lsr.l	#3,d0
	btst	d1,0(a0,d0.l)
	sne		d0
	and		#1,d0
	rts

;	void bchg(long *row,long bit);
bchg:
.if stdargs
	move.l 	8(sp),d0
	move.l	4(sp),a0
.endif
	move.b	d0,d1
	lsr.l	#3,d0
	bchg	d1,0(a0,d0.l)
	rts

;	void bset(long *row,long bit);
bset:
.if stdargs
	move.l 	8(sp),d0
	move.l	4(sp),a0
.endif
	move.b	d0,d1
	lsr.l	#3,d0
	bset	d1,0(a0,d0.l)
	rts

get_butpaks:		; used for debugging the moose
	trap	#4
	rts

