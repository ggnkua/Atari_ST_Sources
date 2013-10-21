	list	+
* using envDEMO v29/12/89
* Brought to you by Stormlord of NOW 5
	list	-

* Program Environment
* version : Atari ST
* (C)1989 John M Phillips

* 2-screen only, low res or mono

* equates

mfp	equ	$FFFFFA00	mfp chip
td_vector equ	$110		timer d vector
tc_vector equ	$114		timer c vector
ikbd_vector equ $118		keyboard chip vector
tb_vector equ	$120		timer b vector
vbl_vector equ	$70		vertical sync vector
palette equ	$FFFF8240	16-colour palette

* these constants make timer D irq appear at bottom of screen

td_divider equ	7
td_count50 equ	208		50Hz version
td_count60 equ	208		60Hz version

mouse_sense equ 10		mouse sensitivity

* default environment parameters

	ifnd	_res
_res	equ	0		colour
	endc

	ifnd	_reloc
_reloc	equ	0		no relocation
	endc

	ifnd	_tosoff
	ifeq	_reloc
_tosoff equ	0		TOS on
	elseif
_tosoff	equ	1		TOS off if relocation
	endc
	endc

	ifnd	_frames
_frames	equ	1		1 frame/refresh
	endc

* macros

error	macro	(<message>)	exit with error message
	move.l	#.errm\@,error_message
	jmp	exit
.errm\@	dc.b	'\1',0
	even
	endm

sec	macro			set carry
	or	#1,ccr
	endm

clc	macro			clear carry
	and	#~1,ccr
	endm

copy	macro	(n,Dz,As,Ad)	copy bytes,words or longs
	move.w	#(\1)-1,\2
	ifc	'\0','b'
.copy\@	move.b	(\3)+,(\4)+
	dbra	\2,.copy\@
	endc
	ifc	'\0','w'
.copy\@	move.w	(\3)+,(\4)+
	dbra	\2,.copy\@
	endc
	ifc	'\0','l'
.copy\@	move.l	(\3)+,(\4)+
	dbra	\2,.copy\@
	endc
	endm

border	macro	(colour)	set border colour when timing active
	tst.w	_timing
	beq.s	.bord\@
	move.w	\1,(palette).w
.bord\@
	endm

* variables

	section	bss

prog_size ds.l 1		for memory allocation display only
memory_available ds.l 1

_timing	ds.w	1		timing border active 0=off/1=on

old_vbl	ds.l	1		saved irq vectors
old_ikbd ds.l	1
old_tb	ds.l	1
old_td	ds.l	1
old_mfp	ds.b	16		saved mfp irq/counter registers
old_pal ds.w 	16		saved screen
old_res	ds.w	1		old screen mode
old_phys ds.l	1		old screen addr
old_sr	ds.w	1		old status register

old_joy	ds.l	1		old joy/mouse vectors
old_mouse ds.l	1
old_jm	ds.l	1

old_keyclick ds.w 1		old key click status

joy_x	ds.w	1		joystick x (-1/0/+1)
joy_y	ds.w	1		joystick y (-1/0/+1)
mouse_x	ds.w	1		mouse x (-32k..+32k)
mouse_y	ds.w	1		mouse y (-32k..+32k)
fire	ds.w	1		fire/right mouse button
fire2	ds.w	1		left mouse button
sync	ds.w	1		frame count
frame_count ds.w 1		frame count (continuous)
logbase	ds.l	1		drawing screen
physbase ds.l	1		viewing screen
tempbase ds.l	1		temp for saving logbase in 1 screen mode

mouse_b	ds.b	1		bit0=fire,bit1=fire2
joy_xy	ds.b	1		bits0..3=joystick directions
	even

error_message ds.l 1		pointer to error message (0=none)

log_epl	ds.l	1		ptrs to Extended Palette lists (0=empty)
phys_epl ds.l	1

status_line ds.w 1		for logbase screen (-1=off/0=game/1=editor)
status_line2 ds.w 1		for physbase screen (swapped in flip)

sync_time ds.l	1		no. of time states (8MHz)
*				last game cycle took

stack	ds.l	256		my stack
stack_end

	ifne	_reloc
screen1 ds.b	32256		optional 1st screen if relocated
	endc
screen2 ds.b	32256		2nd screen

	section	text

* this must be at the very beginning

env_ST	move.l	sp,a6			copy sp
	clr.l	-(sp)			into super mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_sp		save old super sp
	pea	cursor_off(pc)		text cursor off
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	move.w	#37,-(sp)		vsync
	trap	#14
	addq.w	#2,sp

	ifne	_reloc

	move.w	#$2700,sr		irqs off
	lea	env_ST(pc),a0		relocate if loaded as data file
	cmp.l	#env_ST,a0
	bne	en_reloc
env_3	lea	stack_end,sp		set stack
	bsr	en_active		setup irqs etc.
	jsr	start			run program
exit	bra.s	exit			stop (cos TOS corrupted)

	elseif

	move.l	4(a6),a5		allocate memory
	move.l	12(a5),d0		text
	add.l	20(a5),d0		bss
	add.l	28(a5),d0		data
	add.l	#$100,d0		basepage
	move.l	d0,prog_size
	lea	stack_end,sp		my stack
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4A,-(sp)		malloc
	trap	#1
	add.l	#12,sp
	move.l	$436,memory_available
	bsr	en_active		setup irqs etc.
	jsr	start			run program
exit	bsr	en_deactive		restore system
	bsr	en_report		report error if required
	move.l	old_sp,-(sp)		back to user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)			exit back to TOS
	move.w	#$4C,-(sp)
	trap	#1

	endc

old_sp	dc.l	0		old super sp

cursor_off
	dc.b	27,'f',0
	even

en_active
	clr.w	sync
	clr.l	error_message	no error
	lea	.ep(pc),a0	dummy extended palette
	move.l	a0,log_epl
	move.l	a0,phys_epl
	bsr	en_setscr	setup screens
	bsr	en_setirq
	rts

.ep	dc.w	$000,$333,$555,$777	dummy palette
	dc.w	$300,$500,$700,$030
	dc.w	$050,$070,$003,$005
	dc.w	$007,$330,$550,$770
	dc.w	0			no extended palette

	ifeq	_reloc

en_deactive
	bsr	en_canirq
	bsr	en_canscr
	rts

en_report
	tst.l	error_message	print any error message
	beq	.skip
	lea	.err,a0
	bsr	.pr
	move.l	error_message,a0
	bsr	.pr
	lea	.err2,a0
	bsr	.pr
	move.w	#1,-(sp)	wait for key
	trap	#1
	addq.w	#2,sp
.skip	rts
.pr	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

.err	dc.b	27,'E','Error Report: ',0
.err2	dc.b	13,10,13,10,'Press any key...',0
	even

	endc

en_page	macro	(addr)
	move.l	#\1,d0
	add.l	#256,d0
	clr.b	d0
	move.l	d0,a0
	endm

en_setscr
	ifeq	_reloc

	dc.w	$A00A			mouse cursor off
	move.w	#4,-(sp)		save resolution
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_res
	move.w	#2,-(sp)		save screen
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_phys
	move.b	$484.w,old_keyclick
	bclr	#0,$484.w		key click off
	lea	(palette).w,a0		save palette
	lea	old_pal,a1
	moveq	#16-1,d0
.pal	move.w	(a0)+,(a1)+
	dbra	d0,.pal
	move.l	old_phys,a0		clear 2 screens
	move.l	a0,physbase
	bsr	cls
	en_page	screen2
	move.l	a0,logbase
	bsr	cls
	move.w	#_res,-(sp)		resolution
	move.l	physbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)
	trap	#14			set screen
	lea	12(sp),sp
	move.w	#37,-(sp)
	trap	#14			vsync
	addq.w	#2,sp

	elseif

	en_page	screen1			2 screen
	move.l	a0,physbase
	bsr	cls
	en_page	screen2
	move.l	a0,logbase
	bsr	cls
	move.l	physbase,d0		tell hardware
	lsr.l	#8,d0
	move.b	d0,$FFFF8203.w		screen
	lsr.w	#8,d0
	move.b	d0,$FFFF8201.w
	move.b	#_res,$FFFF8260.w	resolution

	endc

	rts

	ifeq	_reloc

en_canscr
	move.w	#37,-(sp)		vsync
	trap	#14
	addq.w	#2,sp
	move.l	#old_pal,-(sp)		restore palette
	move.w	#6,-(sp)
	trap	#14
	addq.w	#6,sp
	move.w	old_res,-(sp)		restore resolution & screen
	move.l	old_phys,-(sp)
	move.l	old_phys,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.w	#37,-(sp)		vsync
	trap	#14
	addq.w	#2,sp
	move.b	old_keyclick,$484.w	restore old key click
	move.w	#0,-(sp)		ensure ALT not pressed
	move.w	#11,-(sp)		(ikbd driver may miss this if you
	trap	#13			run using Alt-X from Devpac !!)
	addq.w	#4,sp
	dc.w	$A009			mouse cursor on
	rts

	endc

* clear screen (to colour 0)
* entry	A0=screen address

cls	move.w	#32000/4-1,d0
.cls	clr.l	(a0)+
	dbra	d0,.cls
	rts

single_screen
	move.l	logbase,tempbase
	move.l	physbase,logbase
	rts

double_screen
	move.l	tempbase,logbase
	rts

* wait for sync then flip screens and epl lists and status/indics ptrs

* 50Hz version

flip_once
	move.w	sync,d0
.wait	cmp.w	sync,d0
	beq.s	.wait
	bra.s	flip2

* 17Hz version
* exit	sync_time = no. of time states last game cycle took

flip	tst.w	_timing		if timing border on then border=black
	beq.s	.br
	clr.w	(palette).w
.br	moveq	#-1,d1		clear timer
	lea	sync,a0
.wait	move.w	(a0),d0		wait for change
.wait2	addq.w	#1,d1		4
	cmp.w	(a0),d0		8
	beq.s	.wait2		10 = 22tc
.change	cmp.w	#_frames,(a0)
	bcs.s	.wait
	move.w	(a0),d2		time used = 160000*sync-22*d1
	mulu	#20000,d2
	lsl.l	#3,d2
	mulu	#22,d1
	sub.l	d1,d2
	move.l	d2,sync_time

flip2	clr.w	sync		then clear sync
	move.l	logbase,d0		swap log<->phys
	move.l	physbase,logbase
	move.l	d0,physbase	
	lsr.l	#8,d0
	move.b	d0,$FFFF8203.w		tell hardware
	lsr.w	#8,d0
	move.b	d0,$FFFF8201.w

	ifeq	_tosoff
	move.l	logbase,$44E.w		tell TOS if on
	endc

	move.l	log_epl,d0		swap epl lists if required
	beq.s	.noepl
	move.l	d0,phys_epl
	clr.l	log_epl
.noepl	move.w	status_line,d0		swap status line flags
	move.w	status_line2,status_line
	move.w	d0,status_line2
	rts

* get key
* exit	d0=Upper Case Ascii value if key pressed
*	if no key pressed then d0=0 and Z=1

get_key
	ifeq	_tosoff
	move.w	#2,-(sp)		get key from TOS
	move.w	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	tst.b	d0
	beq	.skip
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	move.l	d0,d1			put key code in bits 8..15
	swap	d1
	lsl.w	#8,d1
	add.w	d1,d0
	lea	special_keys,a0		convert special keys to $C0..
.find	cmp.w	(a0)+,d0
	beq.s	.found
	addq.w	#2,a0
	cmp.l	#special_keys_end,a0
	bne.s	.find
	bra.s	.normal
.found	move.w	(a0),d0
	bra.s	.skip
.normal	cmp.b	#'a',d0			UC only
	blt.s	.skip
	cmp.b	#'z',d0
	bgt.s	.skip
	add.b	#'A'-'a',d0
.skip	and.l	#$FF,d0
	elseif
	move.b	k_last,d0		get last key pressed
	clr.b	k_last			clear
	and.l	#$FF,d0
	endc
	rts

k_left	equ	$C0		cursor
k_right	equ	$C1
k_up	equ	$C2
k_down	equ	$C3
k_sleft	equ	$C4		cursor+shift
k_sright equ	$C5
k_sup	equ	$C6
k_sdown	equ	$C7
k_insert equ	$C8
k_home	equ	$C9
k_help	equ	$CA
k_undo	equ	$CB
k_f1	equ	$CC		function keys
k_f2	equ	$CD
k_f3	equ	$CE
k_f4	equ	$CF
k_f5	equ	$D0
k_f6	equ	$D1
k_f7	equ	$D2
k_f8	equ	$D3
k_f9	equ	$D4
k_f10	equ	$D5
k_esc	equ	$D6

	section	data

special_keys
	dc.w	$4B00,k_left
	dc.w	$4D00,k_right
	dc.w	$4800,k_up
	dc.w	$5000,k_down
	dc.w	$4B34,k_sleft
	dc.w	$4D36,k_sright
	dc.w	$4838,k_sup
	dc.w	$5032,k_sdown
	dc.w	$5200,k_insert
	dc.w	$4700,k_home
	dc.w	$6200,k_help
	dc.w	$6100,k_undo
	dc.w	$3B00,k_f1
	dc.w	$3C00,k_f2
	dc.w	$3D00,k_f3
	dc.w	$3E00,k_f4
	dc.w	$3F00,k_f5
	dc.w	$4000,k_f6
	dc.w	$4100,k_f7
	dc.w	$4200,k_f8
	dc.w	$4300,k_f9
	dc.w	$4400,k_f10
	dc.w	$011B,k_esc
special_keys_end

	section	text

random	move.w	.seed,d0	seed=(seed*1509)+41
	mulu	#1509,d0
	add.w	#41,d0
	move.w	d0,.seed
	rts
.seed	dc.w	42

* enable interrupts

en_setirq
	ifeq	_tosoff

	move.w	#$14,-(sp)		joystick returns changes
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.w	#6,sp
	move.w	#$08,-(sp)		relative mouse
	move.w	#4,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.w	#6,sp
	move.w	#34,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,a0
	move.l	24(a0),old_joy
	move.l	16(a0),old_mouse
	move.l	a0,old_jm
	move.l	#en_joy_do,24(a0)
	move.l	#en_mouse_do,16(a0)
	clr.b	joy_xy
	clr.w	joy_x
	clr.w	joy_y
	clr.w	fire
	clr.w	fire2
	clr.w	mouse_x
	clr.w	mouse_y
	clr.b	mouse_b
	move.w	sr,d0			save status register
	move.w	d0,old_sr
	move.w	#$2700,sr		irqs off
	lea	old_mfp,a0		save mfp registers
	move.b	mfp+7,(A0)+			enable A
	move.b	mfp+9,(A0)+			enable B
	move.b	mfp+$13,(A0)+			mask A
	move.b	mfp+$15,(A0)+			mask B
	move.b	mfp+$1F,(A0)+			timer A data
	move.b	mfp+$19,(A0)+			timer A control
	move.b	mfp+$1B,(a0)+			timer B control
	move.b	mfp+$1D,(A0)+			timer C+D control
	move.b	mfp+$17,(A0)			vector register
	move.l	tb_vector,old_tb	     save irq vectors
	move.l	td_vector,old_td
	move.l	tc_vector,en_tcpat+2
	move.l	#en_tcirq,tc_vector
	move.l	ikbd_vector,old_ikbd
	move.l	vbl_vector,old_vbl
	move.l	old_ikbd,en_ikbdpat+2
	move.l	#en_ikbdirq,ikbd_vector		new IKBD
	and.b	#$FE,(mfp+7).w			timer B inactive
	move.b	#0,(mfp+$1B).w			stop timer B
	or.b	#1,(mfp+7).w			timer B active
	or.b	#1,(mfp+$13).w			set timer B mask
	move.l	old_vbl,vbl_patch+2
	move.l	#en_vblirq,vbl_vector		new VBL
	move.w	#$2300,sr			enable irqs

	elseif

	ifeq	_reloc
	dc.w	$A00A
	endc
	move.w	sr,d0			save status register
	move.w	d0,old_sr
	move.w	#$2700,sr		irqs off
	bsr	copy_epl_irq		copy epl_irq down to page 2
	clr.l	epl_ptr
.send1	btst	#1,$FFFFFC00.w
	beq.s	.send1
	move.b	#$14,$FFFFFC02.w	joystick returns changes
.send2	btst	#1,$FFFFFC00.w
	beq.s	.send2
	move.b	#$08,$FFFFFC02.w	relative mouse
	clr.b	joy_xy
	clr.w	joy_x
	clr.w	joy_y
	clr.w	fire
	clr.w	fire2
	clr.w	mouse_x
	clr.w	mouse_y
	clr.b	mouse_b
	clr.b	k_flag
	clr.b	k_last
	lea	old_mfp,a0		save mfp registers
	move.b	mfp+7,(A0)+			enable A
	move.b	mfp+9,(A0)+			enable B
	move.b	mfp+$13,(A0)+			mask A
	move.b	mfp+$15,(A0)+			mask B
	move.b	mfp+$1F,(A0)+			timer A data
	move.b	mfp+$19,(A0)+			timer A control
	move.b	mfp+$1B,(a0)+			timer B control
	move.b	mfp+$1D,(A0)+			timer C+D control
	move.b	mfp+$17,(A0)			vector register
	move.l	tb_vector,old_tb	save irq vectors
	move.l	td_vector,old_td
	move.l	tc_vector,en_tcpat+2
	move.l	ikbd_vector,old_ikbd
	move.l	vbl_vector,old_vbl
	move.l	#en_ikbdirq,ikbd_vector	new IKBD
	and.b	#$CF,(mfp+9).w		timer C and D inactive
	and.b	#$DE,(mfp+7).w		timer A and B inactive
	move.b	#0,(mfp+$1B).w		disable timer B
	or.b	#1,(mfp+7).w		timer B active
	or.b	#1,(mfp+$13).w		set timer B mask
	move.l	#en_syncirq,td_vector	new timer D : frame sync
	move.b	(mfp+$1D).w,d0
	and.b	#$F0,d0
	or.b	#td_divider,d0		set timer D divider
	move.b	d0,(mfp+$1D).w
	or.b	#$10,(mfp+9).w		enable timer D
	or.b	#$10,(mfp+$15).w	set timer D mask
	move.l	#en_vblirq,vbl_vector	new VBL
	move.w	#$2300,sr		enable irqs

	endc

	rts

* cancel irqs

	ifeq	_reloc

en_canirq
	move.w	#$2700,sr
	lea	old_mfp+9,a0		restore mfp registers
	move.b	-(a0),mfp+$17			vector register
	move.b	-(a0),mfp+$1D			timer C+D control
	move.b	-(a0),mfp+$1B			timer B control
	move.b	-(a0),mfp+$19			timer A control
	move.b	-(a0),mfp+$1F			timer A data
	move.b	-(a0),mfp+$15			mask B
	move.b	-(a0),mfp+$13			mask A
	move.b	-(a0),mfp+9			enable B
	move.b	-(a0),mfp+7			enable A
	move.l	old_tb,tb_vector		restore irq vectors
	move.l	old_td,td_vector
	move.l	en_tcpat+2,tc_vector
	move.l	old_ikbd,ikbd_vector
	move.l	old_vbl,vbl_vector
	move.l	old_jm,a0			restore joy/mouse vectors
	move.l	old_joy,24(a0)
	move.l	old_mouse,16(a0)
	move.w	old_sr,sr			restore status register
	rts

	endc

* timer C irq
* enables interrupts to allow colour irqs to have priority

en_tcirq move.w	#$2500,sr
en_tcpat jmp	$80000000

* ikbd irq
* enables interrupts to allow colour irqs to have priority

en_ikbdirq
	ifeq	_tosoff

	move.w	#$2500,sr		enable irqs
en_ikbdpat jmp	$80000000		exit to old routine (patched addr)

	elseif

	move.w	#$2500,sr		enable irqs
	movem.l	d0-d1/a0,-(sp)		save regs
.irq	move.b	$FFFFFC00.w,d0		test status
	bpl.s	.skip			skip if no interrupt
	btst	#0,d0			if receiver full then
	beq.s	.over
	move.b	$FFFFFC02.w,d0		get byte
	bsr	en_ikbd_do		process it
	bra.s	.skip
.over	btst	#5,d0			if overflow then
	beq.s	.skip
	move.b	$FFFFFC02.w,d0		flush buffer
.skip	btst	#4,(mfp+1).w		loop if irq
	beq.s	.irq
	movem.l	(sp)+,d0-d1/a0		restore regs
	bclr	#6,(mfp+$11).w		cancel irq
	rte

	endc

* frame sync irq (called by timer B)
* bumps sync_flag

en_syncirq
	addq.w	#1,sync			bump sync flag
	addq.w	#1,frame_count		bump frame_count
	clr.b	(mfp+$1B).w		stop timer B
	bclr	#0,(mfp+$0F).w		clear timer B irq flag
	rte

* my vbl irq

en_vblirq
	clr.b	(mfp+$1B).w		disable timer B
	movem.l	d0/a0,-(sp)
	move.l	phys_epl,a0		setup palette if required
	cmp.l	#0,a0
	beq.s	.set199
	tst.w	_timing
	beq.s	.notime
	addq.l	#2,a0			skip colour 0 if timing border
	move.w	(a0)+,(palette+2).w
	bra.s	.time
.notime	move.l	(a0)+,(palette).w	copy palette
.time	move.l	(a0)+,(palette+4).w
	move.l	(a0)+,(palette+8).w
	move.l	(a0)+,(palette+12).w
	move.l	(a0)+,(palette+16).w
	move.l	(a0)+,(palette+20).w
	move.l	(a0)+,(palette+24).w
	move.l	(a0)+,(palette+28).w
	move.w	(a0)+,d0		get palette change offset
	bne.s	.setirq			if =0 then no palette change
.set199	move.b	#199,d0
.setb	move.b	d0,(mfp+$21).w		set timer B = 199
	cmp.b	(mfp+$21).w,d0
	bne.s	.setb
	move.l	#en_syncirq,(tb_vector).w	vectored to sync
	move.b	#8,(mfp+$1B).w			enable timer B
	bra.s	.done
.setirq	move.b	d0,(mfp+$21).w		set timer B
	cmp.b	(mfp+$21).w,d0
	bne.s	.setirq
	move.l	#epl_irq0,(tb_vector).w		vectored to palette switch
	move.b	#8,(mfp+$1B).w			enable timer B
.done	bsr	en_joyread			read joystick/mouse
	movem.l	(sp)+,d0/a0
.skip
	ifeq	_tosoff
vbl_patch
	jmp	$80000000		exit to old routine
	elseif
	rte				or exit if TOS off
	endc

	ifeq	_tosoff

* joystick handler
* entry	a0=ptr to ikbd string
* exit	all registers preserved

en_joy_do
	cmp.b	#$FF,(a0)		update joystick 1 only
	bne.s	.skip
	move.b	2(a0),joy_xy
.skip	rts

* mouse handler
* entry	a0=ptr to ikbd string
* exit	all registers preserved

en_mouse_do
	move.w	d0,-(sp)
	move.b	(a0),d0			check relative mouse command
	sub.b	#$F8,d0
	cmp.b	#3,d0
	bcc.s	.skip
	and.b	#3,d0			save buttons
	move.b	d0,mouse_b
	move.b	1(a0),d0		sum mouse x
	ext.w	d0
	add.w	d0,mouse_x
	move.b	2(a0),d0		sum mouse y
	ext.w	d0
	add.w	d0,mouse_y
.skip	move.w	(sp)+,d0
	rts

	elseif

k_ptr	dc.l	0	ptr into k_buffer
k_count dc.b	0	number of bytes in ikbd string
k_last	dc.b	0	last key pressed (0 if none)
k_flag	dc.b	0	set if ikbd string being processed
k_buffer ds.b	9	buffer for ikbd string
	even

en_ikbd_do
	tst.b	k_flag			1st byte ?
	bne.s	.more
	cmp.b	#$F6,d0			command ?
	bcs	.key
	st	k_flag			flag commmand
	move.b	d0,k_buffer		save in buffer
	move.l	#k_buffer+1,k_ptr	set ptr
	sub.b	#$F6,d0			set parameter byte count
	and.w	#255,d0
	move.b	.counts(pc,d0.w),k_count
	rts
.counts	dc.b	8,5,2,2,2,2,6,8,1,1
.more	move.l	k_ptr,a0		store next byte in buffer
	move.b	d0,(a0)+
	move.l	a0,k_ptr		update ptr
	subq.b	#1,k_count		last ?
	bne.s	.skip
	clr.b	k_flag			cancel command flag
	move.b	k_buffer,d0		get command no.
	cmp.b	#$FF,d0			joystick 1 ?
	bne.s	.mouse
.joy	move.b	k_buffer+1,joy_xy		save byte
	rts
.mouse	sub.b	#$F8,d0			relative mouse ?
	cmp.b	#3,d0
	bcc.s	.skip
	and.b	#3,d0				save buttons
	move.b	d0,mouse_b
	move.b	k_buffer+1,d0			sum mouse x
	ext.w	d0
	add.w	d0,mouse_x
	move.b	k_buffer+2,d0			sum mouse y
	ext.w	d0
	add.w	d0,mouse_y
	rts
.key	ext.w	d0			key pressed ?
	bmi.s	.skip
	lea	key_matrix,a0
	move.b	(a0,d0.w),k_last		convert to ascii
.skip	rts

	section	data

.matrix	dc.b	0,27,'1234567890-=',8,9
	dc.b	'QWERTYUIOP[]',13,$90,'AS'
	dc.b	"DFGHJKL;'`",$91,'#ZXCV'
	dc.b	'BNM,./',$92,0,$93,' ',$94,$80,$81,$82,$83,$84
	dc.b	$85,$86,$87,$88,$89,0,0,$95,$96,0,'-',$98,0,$99,'+',0
	dc.b	$97,0,$9A,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	'\',$9B,$9C,'()/*789456123'
	dc.b	'0.',13,0,0,0,0,0,0,0,0,0,0,0,0,0

	section	text

	endc

* update joystick/mouse info
* exit	d0/a0 used
*	joy_x,joy_y,fire,fire2

en_joyread
	move.b	mouse_b,d0		read fire,fire2 from mouse buttons
	and.w	#1,d0
	move.w	d0,fire
	move.b	mouse_b,d0
	and.w	#2,d0
	lsr.w	#1,d0
	move.w	d0,fire2
	move.b	joy_xy,d0		get joystick
	and.w	#15,d0			isolate directions
	lsl.w	#2,d0
	move.w	.joy(pc,d0.w),joy_x	convert to x,y values -1/0/+1
	move.w	.joy+2(pc,d0.w),joy_y
	rts

.joy	dc.w	0,0,0,1,0,-1,0,1,-1,0,-1,1,-1,-1,-1,1
	dc.w	1,0,1,1,1,-1,1,1,1,0,1,1,1,-1,1,1

	ifne	_reloc

* program relocator
* entry	in supervisor mode with irqs off

* NOTE: this routine MUST be position independent

reloc_buf equ $200			safe place for shift code

en_reloc
	move.l	#_reloc,d2		d2=relocation offset
	lea	env_ST(pc),a0		program address
	lea	-$1C(a0),a2		header address
	cmp.w	#-1,$1A(a2)		if no reloc. info then run
	beq	.shift
	move.l	a0,a1			a1=pointer to relocation info
	add.l	2(a2),a1		= TEXT	+ sizeof(TEXT)
	add.l	6(a2),a1			+ sizeof(DATA)
	add.l	14(a2),a1			+ sizeof(SYMBOLS)
	clr.l	d1
	move.l	(a1)+,d0		get long index to first addr
	beq	.shift			if 0 then run
.loop	add.l	d2,0(a0,d0.l)		add reloc. offset to address
.byte	move.b	(a1)+,d1		get byte
	beq	.shift			if 0 then end of list so run
	cmp.b	#1,d1			if 1 then add 254 to index
	bne	.small
	add.l	#254,d0
	bra	.byte
.small	add.l	d1,d0			else add byte 2..253 to index
	bra	.loop			and relocate address
.shift	lea	env_ST(pc),a0		source
	move.l	#_reloc,a1		dest
	move.l	2(a2),d0		size=text+data
	add.l	6(a2),d0
	lea	(a1,d0.l),a3		start of bss= dest+size
	move.l	10(a2),d1		size of bss
	lea	.copy(pc),a4
	lea	reloc_buf,a5
	move.w	#.copy_end-.copy-1,d7
.s2	move.b	(a4)+,(a5)+
	dbra	d7,.s2
	lea	_reloc+(env_3-env_ST),a4	return address
	jmp	reloc_buf			copy down

.copy	move.b	(a0)+,(a1)+		copy text,data
	subq.l	#1,d0
	bne.s	.copy
	tst.w	d1
	beq.s	.copy3
.copy2	clr.b	(a3)+			wipe bss
	subq.l	#1,d1
	bne.s	.copy2
.copy3	jmp	(a4)			return to program
.copy_end

	endc

