








				avena_1_9_96:




Tracker_On	EQU	0

ScreenLines	EQU	200
BytesPerLine	EQU	384
Lines		EQU	200
Pixels		EQU	384

Back_Colour	EQU	0

xmax		EQU	383
ymax		EQU	099

noscreens	EQU	2
Keys		EQU	0
Demo		EQU	1

Direction	EQU	0





start:

	IFNE	Demo
		INCLUDE	F:\Source\Tdf\Main\Equates.S
		output	c:\_demo\data\letters.prg
		opt	nodebug
	ENDC


	IFEQ	Demo
		INCLUDE EQUATES.S
		INCLUDE	TOSSTART.I
	ELSE
		INCLUDE	DEMSTART.I
	ENDC


;--------------------------------------------------------------
Initialize_Routine:
		RTS

Display_Routine:
		init_screens
		move.l	sequence_data,d0
		move.l	(letterlist1.l,d0.w*4),a0
		bsr	do_letter

		update_screens
		MOVE.L	(A7)+,A0		;restore stack info
		RTS

do_letter:
		pea	(a0)
		bsr	clear_screen
		move.l	(a7)+,a0
		bsr	copy_letter
		bsr	screen_swap
		bsr	wait_vbl
		move.l	#-1,$ffff9800.w
		move.l	#0,$ffff9804.w
		bsr	set_res
		rts


copy_letter:
		move.l	logic,a1
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.w	d0,d2
		move.w	d0,d3
		asl.w	#4,d2			;16bytes/chunk
		ext.l	d2
		neg.w	d2
		add.w	#BytesPerLine,d2

		move.w	#200,d5
		sub.w	d1,d5			;full height - full pixheight
		asr.w	d5
		mulu	#BytesPerLine,d5
		add.l	d5,a1

; Centre the letter:
		move.w	#BytesPerLine,d4
		asl.w	#4,d3
		sub.w	d3,d4
		asr.w	d4			;halve it
		and.w	#$fff0,d4
		add.w	d4,a1

		subq.w	#1,d0
		subq.w	#1,d1
		moveq	#16,d4
.copya:
		move.w	d0,d3
.copyb		move.w	(a0)+,(a1)
		add.w	d4,a1
		dbf	d3,.copyb

		add.w	d2,a1
		dbf	d1,.copya
		rts

clear_screen:
		MOVE.L	logic,A0
		MOVE.L	#Back_Colour,D0
		MOVE.L	#ScreenLines*BytesPerLine/4/8,D1
.Wipe:
		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+

		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A0)+
		SUBQ.L	#1,D1
		BNE.S	.Wipe
		rts


set_res:
		include	f:\data\tdf\res\3820v256.s
		rts


		section	data
letterlist1	dc.l	.s,.o,.n,.l_,.u,.m,.i,.e,.z
		dc.l	.i1,.i2,.i3,.i4
.s		incbin	c:\_data\letters\3\s.dat
.o		incbin	c:\_data\letters\3\o.dat
.n		incbin	c:\_data\letters\3\n.dat
.l_		incbin	c:\_data\letters\3\l.dat
.u		incbin	c:\_data\letters\3\u.dat
.m		incbin	c:\_data\letters\3\m.dat
.i		incbin	c:\_data\letters\3\i.dat
.e		incbin	c:\_data\letters\3\e.dat
.z		incbin	c:\_data\letters\3\z.dat
.i1		incbin	c:\_data\letters\2\i1.dat
.i2		incbin	c:\_data\letters\2\i2.dat
.i3		incbin	c:\_data\letters\2\i3.dat
.i4		incbin	c:\_data\letters\2\i4.dat

			section	bss
letter_offset		ds.l	1
			ds.l	1000
stack