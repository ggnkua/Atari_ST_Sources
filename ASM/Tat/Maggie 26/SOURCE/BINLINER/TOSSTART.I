init_dsp	MACRO
		JSR	dsp_library+0
		ENDM

init_dsp_routine MACRO
		LEA	(\1),A0
		JSR	dsp_library+4
		LEA	(\2).W,A0
		JSR	dsp_library+8
		ENDM

install_vbl	MACRO
		move.l	#\1,my_vbl
		ENDM

loadfile	MACRO
		lea	.file(pc),a0
		lea	\2,a1
		jsr	load_file
		bra.s	\@
.file		dc.b	\1
		even
\@
		ENDM

		CLR.L -(A7)
		MOVE.W #$20,-(A7)
		TRAP #1
		MOVE.L D0,save_stack
		ADDq.L #6,A7		;use existing stacks

		ifne	messageon
		pea	message
		move.w	#9,-(a7)
		trap	#1
		addq.l	#6,a7
		move.w	#8,-(a7)
		trap	#1
		addq.l	#2,a7
		endc

		bsr	preload

		BSR savevectors
		BRA program_start

;wait_transmit	macro
;	btst	#1,$ffffa202.w
;	beq.s	*-6
;	endm
;
;wait_receive	macro
;	btst	#0,$ffffa202.w
;	beq.s	*-6
;	endm
;
;
;OFF		equ	0
;ON		equ	1
;

*********************************
*	vector-saving routines:	*
*********************************
savevectors:
	move.w	#-1,-(a7)
	move.w	#$58,-(a7)
	trap	#14
	addq.l	#4,a7
	move.w	d0,resolution

	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen_base_2
	move.l	$44e.w,old_44e

	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a1)+,(a0)+
	dbf	d0,.copy1
	
	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a1),(a0)+
	addq.l	#2,a1
	dbf	d0,.copy2

;set  error vectors:
	lea	$8.w,a0
	lea	restore_vectors(pc),a1
	moveq	#9,d0
.copy3	move.l	a1,(a0)+
	dbf	d0,.copy3
	bclr	#3,$fffffa17.w
	rts

quit:
restore_vectors:
	movem.l	d0-a6,save_registers
	IFNE	Tracker_On
	JSR	stop_tracker
	ENDC
	move.w	6(a7),a0
	move.w	a0,which_error

	move.l	(a0),-(a7)
	move.w	#$2700,sr
	lea	save_vectors(pc),a0
	lea	$8.w,a1
	moveq	#($140-8)/4-1,d0
.copy1	move.l	(a0)+,(a1)+
	dbf	d0,.copy1

	lea	$fffffa01.w,a1
	moveq	#21,d0
.copy2	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbf	d0,.copy2

	move.b	#$c8,$fffffa23.w

;	lea	mouse_on(pc),a0
;	bsr	send_ikbd
;; Flush:
;.flush	move.b	$fffffc02.w,d0
;	btst	#0,$fffffc00.w
;	bne.s	.flush
;	move.w	#$2300,sr

	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7		;wait vbl

	tst.w	screenshot
	beq.s	.ok
	jsr	save_screenshot
.ok
	move.w	resolution(pc),-(a7)
	move.w	#3,-(a7)
	move.l	screen_base(pc),-(a7)
	move.l	screen_base_2(pc),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	14(a7),a7

	;move.l	#$6f6f006f,$ffff9800.w
	;clr.l	$ffff9804.w
	;clr.b	$ffff8265.w

	move.l	#$3919,d0
	movec	d0,cacr

	movem.l	save_registers(pc),d0-a6
	illegal
	;clr.w	-(a7)
	;trap	#1

which_error	dc.w 0
error_flag	dc.w -1		;assume error

screen_base:
	ds.l 1
screen_base_2:
	ds.l 1
resolution:
	ds.w 1
save_stack:
	ds.l 1

*****************************************
*	Keyboard handler:		*
*****************************************

keyboard:
	move.w	#$2300,sr
	move.w	d6,-(a7)
	move.l	a6,-(a7)
.read_data
	move.w	status(pc),d6
	move.w	.jumplist(pc,d6.w),d6
	jmp	.jumplist(pc,d6.w)

.jumplist
	dc.w	.keypress-.jumplist	;0 - keypress
	dc.w	.mouse1-.jumplist	;$f8 2
	dc.w	.mouse1-.jumplist	;$f9 4
	dc.w	.mouse1-.jumplist	;$fa 6
	dc.w	.mouse1-.jumplist	;$fb 8
	dc.w	.keypress-.jumplist	;$fc 10 - keypress
	dc.w	.mouse2-.jumplist	;$fd 12
	dc.w	.joy1-.jumplist		;$fe 14 - get j1 data
	dc.w	.joy2-.jumplist		;$ff 16 - get j2 data

*routines:
.keypress
	sub.w	d6,d6			;cant use MOVEQ
	move.b	$fffffc02.w,d6
	move.b	d6,keypress

	cmp.w	#$f8,d6			;special cases....
	bge.s	.special

	lea	keyboard_matrix,a6
	bclr	#7,d6			;ignore	bit 7
	bne.s	.keyup

	move.b	d6,lastkey
	st.b	(a6,d6.w)
	bra.s	.end
.keyup	clr.b	(a6,d6.w)
					;falls through
.end
	btst	#4,$fffffa01.w
	beq.s	.read_data		;another interrupt
	move.l	(a7)+,a6
	move.w	(a7)+,d6
	rte

**** Handle joysticks:
.special:	sub.w	#$f7,d6		; 1 or 2
	add.w	d6,d6			; 2 or 4...
	move.w	d6,status
	bra.s	.end

.joy1	move.b	$fffffc02.w,joy1
	clr.w	status
	bra.s	.end
.joy2	move.b	$fffffc02.w,joy2
	clr.w	status
	bra.s	.end

.mouse1	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_x
	move.w	status(pc),d6		;2-8
	lsr.w	#1,d6			;1-4
	subq.w	#1,d6			;0-3
	move.b	d6,mouse_button
	move.w	#12,status
	bra.s	.end

.mouse2	move.b	$fffffc02.w,d6
	ext.w	d6
	add.w	d6,mouse_y
	clr.w	status
	bra.s	.end

*****************************
send_ikbd:
	move.w	#$fc00,a1

.loop	btst	#1,(a1)			;ready to send?
	beq.s	.loop
	move.b	(a0)+,2(a1)		;plonk it in
	cmp.b	#-5,(a0)		;end?
	bne.s	.loop
	rts

*****************************
mouse_on	dc.b	$1a,$8,-5
joy_on	dc.b	$14,$8,-5
	even

*********************
vbl:
	addq.l	#1,$466.w
	addq.w	#1,vbl_timer
	cmp.b	#$39,$fffffc02.w	;check for user quit
	beq	quit
	cmp.b	#$62,$fffffc02.w
	bne	_1
	st	screenshot	
	illegal
_1
	movem.l	d0-a6,-(A7)
	move.l	my_vbl(pc),a0
	jsr	(a0)
	movem.l	(a7)+,d0-a6
	rte

rts	rts

wait_vbl:
	clr.w	vbl_timer
.wv	tst.w	vbl_timer
	beq.s	.wv
	rts

save_screenshot:
	move.w	#0,-(a7)
	pea	.outfile(pc)
	move.w	#$3c,-(a7)		;gemdos 3c, create
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7

	move.l	physic,a0
	subq.l	#6,a0
	move.w	#"G4",(a0)+
	move.w	#pixels,(a0)+
	move.w	#lines,(a0)+

	pea	-6(a0)
	pea	BytesPerLine*Lines+6
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7

	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

.outfile:
	dc.b	"e:\scrn.god",0
	even

*************************
*	Data Section:	*
*************************
* Mouse information:
lastkey		dc.b 0
mouse_button	dc.b 0
		even
mouse_x		dc.w 0
screenshot	dc.w 0
mouse_y		dc.w 0
save_a0		ds.l 1
status		ds.w 1
keypress	ds.w 1
keyboard_matrix	ds.b 128
joy1		ds.w 1
joy2		ds.w 1
kb_data		ds.w 1
vbl_timer	ds.w 1
logic		ds.l 1
physic		ds.l 1
old_44e		ds.l 1
my_vbl		dc.l rts

save_vectors	ds.l 350/4
save_registers	ds.l 16

program_start:
; Set original vectors and screens etc.

		LEA	stack,A7
		MOVE.W	#$2700,sr
		;LEA	mouse_on(PC),A0
		;BSR	send_ikbd

;---------------------------------------------------------------
		MOVE.L	#STACK+4000,D0		;top of memory - change!
		SUB.B	D0,D0
		MOVE.L	D0,logic
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,physic
		 IFEQ noscreens-3
		ADD.L	#BytesPerLine*Lines,D0
		MOVE.L	D0,third
		 ENDC
		MOVE.W	#$2300,SR

		MOVE.L	#vbl,$70.W
		MOVE.L	#keyboard,$118.W
		MOVE.L	#$ff00ff40,$fffffA06.W
		MOVE.L	#$ff00ff40,$fffffA12.W
		BCLR	#3,$fffffA17.W 

begin:
		init_dsp
		BSR	ClearScreens
		BSR	Initialize_Routine
		move.w	#-1,d7			;do 65535 frames ;)
		JSR	Display_Routine
		ILLEGAL


; Utility routines:
;--------------------------------------------------------------
screen_swap:
	IFEQ	noscreens-3
		MOVE.L	logic,D0
		MOVE.L	third,logic
		MOVE.L	physic,third
		MOVE.L	D0,physic
	ELSE
		MOVE.L	logic,D0
		MOVE.L	physic,logic
		MOVE.L	D0,physic
	ENDC
		MOVE.L	physic,-(A7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		ADDQ.L	#4,A7
		RTS

;--------------------------------------------------------------
ClearScreens:
		MOVE.L	physic,A0
		MOVE.L	logic,A1
	IFEQ	noscreens-3
		MOVE.L	third,A2
	ENDC
		MOVE.L	#Back_Colour,D0
		MOVE.L	#ScreenLines*BytesPerLine/4,D1
.Wipe:		MOVE.L	D0,(A0)+
		MOVE.L	D0,(A1)+
	IFEQ	noscreens-3
		MOVE.L	D0,(A2)+
	ENDC
		SUBQ.L	#1,D1
		BNE.S	.Wipe
		RTS

;Wait_Vbl:
;		move.l	vbl_timer,d0		;already defined
;.wait		cmp.l	vbl_timer,d0
;		beq.s	.wait
;		rts

*--------------------------------------------------------
load_file:
	pea	(a1)
	bsr	open_file
	move.l	(a7)+,a1
	bsr	read_file
	bsr	close_file
	rts

open_file:
	clr.w	-(a7)
	move.l	a0,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7
	rts

close_file:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

read_file:
	move.l	a1,-(a7)
	pea	$ffffff
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

		section	bss
		IFEQ	noscreens-3
third			ds.l	1
		ENDC






		SECTION	DATA

		IFNE	Tracker_On
		INCLUDE	TRACKERC.S
		ELSE
Dsp_Library:	INCLUDE NEW_OS3.S
		ENDC

		SECTION	TEXT

