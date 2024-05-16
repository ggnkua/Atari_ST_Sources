; Ninja Remix selecter - Coded 13/12/90
; Music ripped by Andy the Arfling of The BBC

; Set tabs to 10 for correct spacing
; With comments !!!!

	pea	supv(pc)		Call routine in supervisor mode
	move.w	#$26,-(a7)
	trap	#$e
	addq.w	#6,-(a7)

	clr.w	-(a7)		Quit proggy
	trap	#1

supv
	pea	clrscr		Clear screen,disable cursor
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#$666,d6		Fade background to black
.loop1	move.w	d6,$ffff8240.w
	bsr	delay
	sub.w	#$111,d6
	bpl.s	.loop1

	pea	mess		Print message
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#$111,d6		Fade text to white
.loop2	move.w	d6,$ffff825e.w
	bsr	delay
	add.w	#$111,d6
	cmp.w	#$888,d6
	bne.s	.loop2

.key_loop	move.w	#7,-(a7)		Get key
	trap	#1
	addq.l	#2,a7

	sub.w	#'0',d0
	beq.s	music_off		Quit?
	bmi.s	.key_loop		Less than a number?
	cmp.w	music,d0		Current music?
	beq.s	.key_loop
	cmp.w	#6,d0
	bgt.s	.key_loop		Greater than a number
	move.w	d0,music		Store music number
	bsr.s	music_off		Kill old music
	bsr.s	music_on		Start new music
	bra.s	.key_loop		Loop

music_on
	move.w	music,d0		Copy music to different position
	subq.w	#1,d0			so it can be restarted
	add.w	d0,d0			any number of times.
	add.w	d0,d0
	move.l	posn(pc,d0.w),a0	a0=Start of music
	lea	init_music,a1	a1=Destination address
	move.w	#$2000,d0		Length of music < $8000
.copy	move.l	(a0)+,(a1)+	Move it
	dbf	d0,.copy
	jsr	init_synth	Initialise synth
	moveq	#1,d0		Tune 1
	jsr	init_music	Initialise music
	move.l	#vbl,$4d6.w	Setup VBL
	rts

music_off
	clr.l	$4d6.w		Kill VBL
	jsr	shut_synth	Restore interrupts
	rts


delay	moveq	#7,d7		Delay used in fading colours
.1	move.w	#$25,-(a7)	Wait for VBL
	trap	#14
	addq.l	#2,a7
	dbf	d7,.1
	rts

music	dc.w	0		Current music playing

posn	dc.l	music_1		Table of music positions
	dc.l	music_2
	dc.l	music_3
	dc.l	music_4
	dc.l	music_5
	dc.l	music_6

music_1	incbin	'ninja_1.max'	Include music files
music_2	incbin	'ninja_2.max'
music_3	incbin	'ninja_3.max'
music_4	incbin	'ninja_4.max'
music_5	incbin	'ninja_5.max'
music_6	incbin	'ninja_6.max'

clrscr	dc.b	27,'E',27,'f',0
mess	dc.b	'      The BBC proudly presents....',10,13,10,13
	dc.b	'           Ninja Remix Music',10,13,10,13
	dc.b	'       Ripped by Andy the Arfling',10,13,10,13
	dc.b	'     Press 1-6 for different tunes',10,13
	dc.b	'            Press 0 to exit',10,13,10,13
	dc.b	'          Format of music is:',10,13,10,13
	dc.b	'music+0   -  Music initialisation (D0=1)',10,13
	dc.b	'music+4   -  VBL',10,13
	dc.b	'music+8   -  Synth initialisation',10,13
	dc.b	'music+12  -  Synth shutdown',10,13,0
	even

init_music	ds.l	1
vbl		ds.l	1
init_synth	ds.l	1
shut_synth	rts		rts so first shutdown returns
		ds.w	1

	section	bss

	ds.b	$7ff0		Enough memory for music
