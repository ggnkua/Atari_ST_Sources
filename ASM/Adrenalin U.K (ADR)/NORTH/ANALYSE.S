*
* Tune Analyser
*

	opt	o+,w-,ow2-,ow3-

TUNE_NUMBER	equ	1
TUNE_ISR_OFFSET	equ	8		;tune+???

MAX_BARS	equ	80
MAX_NOTES	equ	4096
AFINE		equ	0
ACOURSE		equ	1	
BFINE		equ	2
BCOURSE		equ	3	
CFINE		equ	4
CCOURSE		equ	5	
AAMP		equ	8
BAMP		equ	9
CAMP		equ	10


	SECTION	TEXT

start
	bsr	super_mode
	bsr	disable_mj
	bsr	start_tune

.loop
	bsr	vsync
	not.w	$ffff8240.w
	bsr	tune+TUNE_ISR_OFFSET	; for the new tune.
	bsr	analyse
	not.w	$ffff8240.w
	cmp.b	#$01,$fffffc02.w
	bne.s	.loop

	bsr	stop_tune
	bsr	find_best
	bsr	rewrite
	bsr	create_file
	bsr	write_file
	bsr	close_file

	bsr	enable_mj
	bsr	user_mode
exit
	clr.w	-(sp)		; Exit.
	trap	#1


***************
* Subroutines *
***************

create_file
	clr.w	-(sp)
	pea	filename(pc)
	move.w	#60,-(sp)
	trap	#1
	addq.w	#8,sp
	move.w	d0,handle
	rts

write_file
	pea	note_usage(pc)
	pea	(MAX_NOTES*2)
	move.w	handle,-(sp)
	move.w	#64,-(sp)
	trap	#1
	add.w	#12,sp
	rts

close_file
	move.w	handle,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.w	#4,sp
	rts


rewrite
	lea	note_usage,a0
	move.w	#(MAX_NOTES-1),d0
.set	move.w	#-1,(a0)+
	dbf	d0,.set

	lea	note_values,a0
	lea	note_usage,a1
	move.w	#(MAX_BARS-1),d0
.clear
	move.w	(a0)+,d2
	clr.w	(a1,d2)
	dbf	d0,.clear

	lea	note_usage,a0
	move.w	#(MAX_BARS-1),d1
	move.w	#(MAX_NOTES-1),d0
.loop
	tst.w	(a0)+
	bmi.s	.skip
	move.w	d1,-2(a0)
	subq.w	#1,d1
.skip
	dbf	d0,.loop
	rts


find_best
	lea	note_values,a0
	lea	note_usage,a1
	move.w	#(MAX_BARS-1),d0
.loop
	bsr	highest
	move.w	d7,(a0)+
	clr.w	(a1,d7)
	dbf	d0,.loop
	rts

highest
	moveq	#0,d1
	moveq	#0,d7
	move.w	#(MAX_NOTES-1),d2
.loop
	move.w	(a1,d7),d3
	cmp.w	(a1,d1),d3
	bge.s	.skip
	move.w	d1,d7
.skip
	addq.w	#2,d1
	dbf	d2,.loop
	rts


analyse
	lea	note_usage,a0
	lea	$ffff8800.w,a1
	bsr	channel_a
	bsr	channel_b
	bsr	channel_c
	rts


channel_a
	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	.end
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	.end
	lsl.w	#1,d0
	addq.w	#1,(a0,d0)
.end	rts


channel_b
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	.end
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	.end
	lsl.w	#1,d0
	addq.w	#1,(a0,d0)
.end	rts


channel_c
	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	.end
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	.end
	lsl.w	#1,d0
	addq.w	#1,(a0,d0)
.end	rts


super_mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


disable_mj
	pea	mj_off
	move.w	#1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	rts

enable_mj
	pea	mj_on
	move.w	#1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	rts


start_tune
	moveq	#TUNE_NUMBER,d0		; Change these two lines
	jmp	tune			; for the new tune.

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


********************
* Initialised data *
********************

	SECTION	DATA

mj_off		dc.b	$12,$1a
mj_on		dc.b	$14,$08

filename
	dc.b	'g:SPECTRUM.DAT',0
	even

tune
	incbin	"g:\music\max\prestale.tlb\in_game3.mus"		; Change this for the new tune.
	even


**********************
* Uninitialised data *
**********************

	SECTION	BSS

handle		ds.w	1

note_values	ds.w	MAX_BARS
note_usage	ds.w	MAX_NOTES

save_stk	ds.l	1
