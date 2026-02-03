;display picture & play sample
;most of this code by

;The Mockingbird for Steve's PD

	;opt w-,o+,d+
;equates
del1 equ 14		delay for ?
sam_len equ 319424	length of the sample

start
	move.l	4(sp),a3	setup stack & mem requirements
	move.l	#mystack,sp
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l 	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	dc.w	$a00a		switch de rat off
	bsr	go_super	switch to super mode
	bsr	get_mode	get screen rez
	bsr	screen_adr	get screen base address
	bsr	draw_it		draw the picture

;***************************************************************
;***************************************************************
;sample section

	move.l	#sample+sam_len,d6		sample end address
	lea	sample,a4	a4 sample pointer
	move.l	a4,d7		d7 marker for repeat
	move.l	a4,a5		a5 start reference
	move.w	#del1,d5
	lea	del_data,a0
	move.w	d5,2(a0)
	move.w	sr,savesr
	move.w	sr,d3
	move.w	#$2700,sr
	moveq	#10,d0

loopy	move.b	d0,$fff8800
	clr.b	$fff8802
	dbf	d0,loopy
	clr.b	$fff8800
	clr.b	$fff8802
	move.b	#7,$fff8800
	move.b	#$fb,$fff8802
	lea	l30234,a3
	lea	l30334,a2
	lea	l30434,a1

	move.w	d3,sr
	andi	#$f8ff,sr
	ori	#$500,sr
	andi.w	#$fd,$484	keyboard cfg
	move.b	#12,d1

	lea	del_data,a6
	lea	l30534,a0
key
	btst	#0,$fffc00	check key press?
	beq.s	skip1

	move.b	$fffc02,d0	key reg
	cmp.b	#$39,d0		space quit
	beq	exit

	cmp.b	#$72,d0		'enter' repeat from marker
	bne.s	skip
	move.l	d7,a4

skip
	cmp.b	#$70,d0		'0' set marker
	bne.s	skipa
	move.l	a4,d7
skipa
	cmp.b	#$63,d0		'(' reset marker
	bne.s	skipb
	move.l	a5,d7
skipb
	cmp.b	#$64,d0		')' reset sample speed
	bne.s	skipc
	move.w	#12,d1
	bra.s	do_it
skipc
	cmp.b	#$4e,d0		'+' sample speed
	bne.s	skip1
	addi.b	#2,d1		d1 = sample speed control
	cmp.b	#$18,d1
	blt.s	do_it
	clr.b	d1
skip1
	cmp.b	#$4a,d0		'-' sample speed
	bne.s	skip2
	cmp.b	#0,d1
	bne.s	.skip
	move.b	#$1a,d1
.skip	subi.b	#2,d1
do_it
	andi.w	#$ff,d1
	move.w	0(a0,d1.w),2(a6)

skip2
	move.b	(a4)+,d0
	cmpa.l	d6,a4
	blt.s	.jmp
	move.l	a5,a4
.jmp
	andi.w	#$ff,d0
	move.b	#8,$ffff8800
	move.b	0(a3,d0.w),$ffff8802

	move.b	#9,$ffff8800
	move.b	0(a2,d0.w),$ffff8802

 	move.b	#10,$ffff8800
	move.b	0(a1,d0.w),$ffff8802

del_data
	move.w	#0,d0
.loop
	nop
	dbf	d0,.loop
	bra	key

exit
	clr.b	d5
	ori.b	#3,$484
	bsr	rest_mode	restore screen mode
	bsr	rest_cols	restore screen colours
	move.w	savesr,sr	restor status register
	bsr	go_user		switch back to user mode
	clr.w	-(sp)
	trap	#1		bye! bye!

go_super
	clr.l	-(sp)
	move.w	#$20,-(sp)	go super mode
	trap	#1
	addq.l	#6,sp
	move.l	d0,sstack
	rts
go_user
	move.l	sstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
sstack	dc.l	0

get_mode
	move.w	$fff8260,smode	save screen mode
	move.b	#$0,$ffff8260
	rts
rest_mode
	move.w	smode,$fff8260
	rts
smode	dc.w	0

screen_adr
	move.w	#2,-(sp)	;find screen address
	trap	#14
	addq.l	#2,sp
	move.l	d0,sbase
	rts
sbase	dc.l	0

rest_cols
	movem.l	oldcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

draw_it					;let's set the screen up
	movem.l	$ffff8240.w,d0-d7	;set & save colours
	movem.l	d0-d7,oldcol
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	lea	picture+34,a0
	move.l	sbase,a1
	move.l	#32000/4,d7
	sub.l	#1,d7
.loopy
	move.l	(a0)+,(a1)+
	dbf	d7,.loopy
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

				;place the picture where it should be
	lea	picture1+34,a0	;fetch it from here
	move.l	sbase,a1	;and lose it here, simple!
	move.l	#32000/4,d7
	sub.l	#1,d7		;-1 because of minus
.loopy1
	move.l	(a0)+,(a1)+	;I hope!!!!
	dbf	d7,.loopy1
	rts			;done



	SECTION DATA
l30234		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00010000,$00000001,$00000000,$00000001
		dc.l	$02000000,$00010000,$01020001,$00010203
		dc.l	$00010000,$00000100,$01020000,$00010203
		dc.l	$00010204,$00000001,$02000100,$00010001
		dc.l	$02030001,$00010200,$01020403,$03000102
		dc.l	$06050300,$00010001,$02000000,$01020001
		dc.l	$02000100,$01020000,$01020203,$00010204
		dc.l	$05030001,$02060503,$00010200,$01020207
		dc.l	$03030504,$04050000,$00010200,$01020001
		dc.l	$00010203,$00010202,$04000102,$04000100
		dc.l	$01020305,$03040404,$00010206,$07030304
		dc.l	$04040505,$05060600,$00010207,$0B030309
		dc.l	$04080001,$02020603,$03000001,$02020303
		dc.l	$06080404,$05070706,$06060908,$07070707
		dc.l	$0B0B0000,$00000102,$00010200,$01000100

l30334		dc.l	$00000001,$02000102,$00010001,$02030001
		dc.l	$02020400,$01020404,$04030001,$02060503
		dc.l	$03030400,$01020207,$03030304,$04050505
		dc.l	$04060600,$01020707,$03030304,$08050505
		dc.l	$04060606,$08000102,$02020303,$08040405
		dc.l	$05050406,$06090909,$07070706,$07070808
		dc.l	$08060708,$0A0A0A09,$09090001,$02020203
		dc.l	$03030404,$0505050A,$06060606,$0A070707
		dc.l	$060A0708,$08080607,$080B0B0B,$09090909
		dc.l	$0709090B,$09090900,$01020202,$03030304
		dc.l	$04050505,$04060606,$06050707,$07060B0B
		dc.l	$0808080B,$07080B08,$08090909,$0B070909
		dc.l	$09090909,$09090909,$0A0A0A0A,$090B0A0A
		dc.l	$0B0A090C,$0C0C0C0A,$0C0C0B0B,$0B0B0B0B
		dc.l	$0C0A0B0B,$0B0C0C0B,$0B0B0A0C,$0B0B0B0B
		dc.l	$0B0B0000,$01020202,$03030304,$0405050C
l30434		dc.l	$00010202,$02030303,$04040505,$05040606
		dc.l	$06060507,$07070606,$07080808,$06070808
		dc.l	$08080909,$09090709,$09090909,$09090909
		dc.l	$09090A0A,$0A09090A,$0A0A0A0A,$0A0A0A0A
		dc.l	$0A0A0A09,$0B0B0B0B,$0B0B0B0A,$0B0B0B0B
		dc.l	$0B0B0B0B,$0A0A0A0B,$0B0B0B0B,$0B0B0B0B
		DC.L	$0B0B0B0A,$0A0A0B0B,$0B0C0C0C,$0C0C0C0C
		DC.L	$0C0C0C0C,$0C0C0B0C,$0C0C0C0B,$0C0C0C0C
		DC.L	$0B0C0C0C,$0C0C0C0C,$0B0B0B0C,$0C0C0C0C
		DC.L	$0C0C0B0C,$0C0C0D0D,$0D0D0D0D,$0D0D0D0D
		DC.L	$0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0D0C0C0D
		DC.L	$0D0D0C0D,$0D0C0D0D,$0D0D0D0C,$0D0D0D0D
		DC.L	$0D0D0D0D,$0D0D0D0D,$0D0D0D0D,$0B0D0D0C
		DC.L	$0D0D0C0C,$0C0C0D0C,$0C0D0D0D,$0D0D0D0D
		DC.L	$0C0D0D0D,$0D0C0C0D,$0D0D0D0C,$0D0D0D0D
		DC.L	$0C0C0E0E,$0E0E0E0E,$0E0E0E0E,$0E0E0E0D
l30534		DC.L	$0050003C,$00320023,$00190012,$000E000A
		DC.L	$00080006,$00050002
		DC.B	00,00


	even
picture		incbin	"demo1.pi1",0
	even
picture1	incbin	"demo.pi1",0
	even
sample		incbin	"demo.snd",0
	even
savesr		ds.w	1
handle		ds.w	1
oldcol		ds.w	16
	ds.b	$2000
mystack	ds.l	1
