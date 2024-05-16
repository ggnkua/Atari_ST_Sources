	COMMENT	HEAD=%001
;	opt	d-

	move.l	4(sp),a5			; mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	addi.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			; even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

; supervisor mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,old_sp

; save and set palette
	lea	$FFFF8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,old_pal
	moveq	#-1,d0
	rept	8
	move.l	d0,(a0)+
	endr

; back to user mode
;	move.l	old_sp,-(sp)
;	move.w	#32,-(sp)
;	trap	#1
;	addq	#6,sp

; cracktro
	clr.l	-(sp)
	clr.l	-(sp)
	pea	part1_name(pc)
	move.l	#$004B0000,-(sp)
	trap	#1
	lea	16(sp),sp

; main part
	clr.l	-(sp)
	clr.l	-(sp)
	pea	part2_name(pc)
	move.l	#$004B0000,-(sp)
	trap	#1
	lea	16(sp),sp

; supervisor mode
;	clr.l	-(sp)
;	move.w	#32,-(sp)
;	trap	#1
;	addq	#6,sp
;	move.l	d0,old_sp

; fading
	moveq	#8-1,d7
	lea	fade_table,a1

loop:	lea	$FFFF8240.w,a0
	move.l	(a1)+,d0
	move.w	$0468.w,d1
.wait:	cmp.w	$0468.w,d1
	beq.s	.wait
	rept	8
	move.l	d0,(a0)+
	endr
	dbf	d7,loop

; back to user mode
;	move.l	old_sp,-(sp)
;	move.w	#32,-(sp)
;	trap	#1
;	addq	#6,sp

; endpart
	clr.l	-(sp)
	clr.l	-(sp)
	pea	part3_name(pc)
	move.l	#$004B0000,-(sp)
	trap	#1
	lea	16(sp),sp

	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$FFFF8240.w

	clr.w	-(sp)
	trap	#1

part1_name:
	dc.b	"cracked.bin",0
part2_name:
	dc.b	"mainpar2.bin",0
part3_name:
	dc.b	"endpart.bin",0
	even

fade_table:
	dc.l	$0FFF0FFF
	dc.l	$06660666
	dc.l	$05550555
	dc.l	$04440444
	dc.l	$03330333
	dc.l	$02220222
	dc.l	$01110111
	dc.l	$01010101

	bss

old_pal:ds.w	16
old_sp:	ds.l	1
