	opt	alink,lattice

* assembly-language graphics for Mon
* supports all normal modes + large mono
* also handles 2-screens-in-use modes
* loads external screen device drivers

* assumes shorts-pushed-as-longs and
* a4 base relative code

TEST_COLOUR	equ	0		number of bitplanes to pretend

******** debug exports ********


* function exports
	xdef	_init_graphics,_deinit_graphics
	xdef	_cursor_out,_char_out
	xdef	_border_out,_clear_rect
	xdef	_scroll_rect
	xdef	_must_show_screen,_may_hide_screen
	xdef	_must_hide_screen,_show_other_screen
	xdef	_draw_mouse,_hide_mouse
	xdef	_kick_mode,_screen_clear

* function imports
	xref	_finish,_getvideomem,_progstate,_calloc
	xref	find_cookie,_sprintf

* variable exports
	xdef	_maxw,_maxh,_switch_mode,_user_mouse
	xdef	_mousex,_mousey,_hackmouse,_mousestate
	xdef	_defaultvideomode,_fshift,_fontsize

* variable imports
	xref	_screentimer,_linebuf,_screen_driver

	include	mon.i

BD_FIRST	equ	$f8
BD_BACKGROUND	equ	BD_FIRST+7

CREGS4	reg	d2-d7/a2-a5

SUPER	macro	code<,arg>
	IFNC	'\2',''
	move.l	\2,-(sp)
	ENDC
	pea	\1(pc)
	move.w	#$26,-(sp)
	trap	#14
	IFC	'\2',''
	addq.l	#6,sp
	ELSEIF
	lea	10(sp),sp
	ENDC
	endm

SWITCH_HWTIMER	equ	2
SWITCH_HW	equ	1
SWITCH_NONE	equ	0		MUST be zero
SWITCH_SW	equ	-1

logbase		equ	$44e
timer_200	equ	$4ba
colorptr	equ	$45a
screenpt	equ	$45e
phystop		equ	$42e

RET_NOMEM	equ	1
RET_NOGRAPHICS	equ	2

	rsreset
m_address	rs.l	1		address of screen RAM (0 if no xmon)
m_planes	rs.w	1		planes
m_bytesperline	rs.w	1
m_pwidth	rs.w	1
m_pheight	rs.w	1
m_font		rs.w	1
m_init		rs.l	1		ptr to init code (in actual program)
m_usegem	rs.b	1		NE=in use
m_usetos	rs.b	1
m_mstart	rs.l	1
m_mend		rs.l	1
m_sizeof	rs.w	1

* the defaultvideomode longword is treated as four bytes:
* bits 0-7:	video mode wanted+1 (0=default, same as current)
* bits 8-15:	number  of monitors (0=default, 1 or 2)
*		bit 15 set=half Moniterm mode
* bits 16-23:	switching mode wanted: (0=default, 1=notimer,
*			2=timer (others internal only)
*		bit 23 set=disable mouse
* bits 24-31:	passed on to external drivers
* all other bits reserved for future use

_init_graphics
*	SUPER	initg2		cannot do this as not MiNT-friendly, use GEMDOS instead
	movem.l	d2/d3/a2/a6,-(sp)
	lea	-m_sizeof(sp),sp
	move.l	sp,a6		external buffer
	clr.l	(sp)		indicate no program

* find an external device driver. If found, {a6}.l non-zero
	tst.b	_screen_driver(a4)
	beq.s	.nodriver

	move.l	_defaultvideomode(a4),d0
	lsr.w	#7,d0			move half bit to bit 8
	and.l	#$ff000100,d0
	move.l	d0,d1
	swap	d1
	or.w	d1,d0
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	pea	1.w			version
	pea	xmonstr
	pea	_linebuf+1(a4)
	jsr	_sprintf
	lea	5*4(sp),sp
	lea	_linebuf+1(a4),a0
	move.l	a0,a1
.getlen	tst.b	(a0)+
	bne.s	.getlen
	move.l	a0,d0
	sub.l	a1,d0
	subq.w	#1,d0
	move.b	d0,-(a1)		build command line

	clr.l	-(sp)
	move.l	sp,-(sp)		no env
	move.l	a1,-(sp)		cmd line
	pea	_screen_driver(a4)
	move.l	#$004b0003,-(sp)
	trap	#1			load, dont execute
	lea	16+4(sp),sp
	tst.l	d0
	bmi.s	.nodriver		if couldn't load
* exec it
	move.l	d0,_screen_driver(a4)	save bp addr
	clr.l	-(sp)
	move.l	d0,-(sp)
	clr.l	-(sp)
	move.l	#$004b0004,-(sp)
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bpl.s	.nodriver		if driver OK
* driver load failed, so clean up
	clr.l	_screen_driver(a4)
	clr.l	(a6)
	bsr	clean_driver
.nodriver
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,-(sp)
	bsr.s	initg2		do the initialising
	move.l	d0,d3
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d3,d0			the return code
	lea	m_sizeof(sp),sp
	movem.l	(sp)+,d2/d3/a2/a6
	beq.s	.ok
	move.l	d0,-(sp)
	jsr	_finish
.ok	rts

initg2	movem.l	CREGS4,-(sp)
	GETA4
	clr.b	current_swap(a4)

	move.l	#scr_mode,mode_reg(a4)
	move.l	#'_VDO',d1
	bsr	find_cookie		ASSUMES all but ST have extra reg
	bne.s	.novid
	swap	d0
	tst.w	d0
	sne	_vidtype(a4)		0 means ST, FF means STE
	subq.w	#2,d0
	bne.s	.novid
	move.l	#scr_ttmode,mode_reg(a4)
	move.b	#1,_vidtype(a4)		1 means TT
.novid
	moveq	#%11,d0
	and.b	_defaultvideomode+2(a4),d0	monitors wanted
	beq.s	.defmon				if whatever we have
	subq.b	#1,d0
	beq	.onemon
* we want two monitors - can only do this if we *have* two monitors
	tst.l	(a6)
	beq	.onemon				if we dont
	bra.s	.twomon

* use as many monitors as we have
.defmon	tst.l	(a6)
	beq	.onemon

* use two monitors - we use the non-GEM one
.twomon	tst.b	m_usegem(a6)
	beq.s	.notbigmain
* we have a big one attached, for GEM use, so use little one for mon
	bsr	get_standard_monitor	attr table into a3, d7=physbase
	bne	.nogrf			exit if dont understand
	move.b	d0,my_hardware_mode(a4)
	lea	pal_st(pc),a5
	bsr	set_2_switch_mode
	bra	.initmon

* we have a big monitor, but nothing is using it, so we will!
.notbigmain
	bsr	set_2_switch_mode
	bra	.usebig

* use one monitor, how boring!
.onemon	dc.w	$a000
	moveq	#-6,d0
	add.l	a0,d0
	move.l	d0,cursor_var(a4)	store linea-6

	move.l	logbase.w,d1
	cmp.l	phystop.w,d1
	bcc.s	.defaultmode		if one big monitor (driver not required)
	
	move.b	_defaultvideomode+3(a4),d0
	beq.s	.defaultmode
* use what the user wants, assuming it is possible
	subq.w	#1,d0
	bsr	check_valid_mode
	bne.s	.defaultmode		if not available
	ext.w	d0
	move.b	d0,my_hardware_mode(a4)
	lsl.w	#3,d0
	lea	vidMode0(pc),a3
	add.w	d0,a3
	move.b	#SWITCH_HW,_switch_mode(a4)
	sf	multimon(a4)
	lea	pal_st(pc),a5
	bra.s	.initmon
	
.defaultmode
	bsr	get_physbase
	move.l	d0,d7
	move.l	mode_reg(a4),a1
	move.b	(a1),my_hardware_mode(a4)
	move.w	(a0),d2			d2=planes
	move.w	2(a0),d3		d3=linebytes
	move.w	-12(a0),d4		d4=pixwidth
	move.w	-4(a0),d5		d5=pixhite
* RSN use the switching specified by the user
	move.b	#SWITCH_HW,_switch_mode(a4)
	sf	multimon(a4)
	lea	pal_st(pc),a5
	move.l	logbase.w,d1
	cmp.l	phystop.w,d1
	bcs.s	.initmon2
* a single big-screen. No driver required
	sf	multimon(a4)
	move.l	logbase.w,d7
	move.b	#SWITCH_SW,_switch_mode(a4)
	lea	pal_big(pc),a5
	tst.b	_defaultvideomode+2(a4)
	bpl.s	.initmon2
	lsr.w	#1,d5			halve vertical res
	bra.s	.initmon2

.usebig	lea	pal_big(pc),a5
	move.l	m_address(a6),d7
	lea	m_planes(a6),a3
	movem.l	d3-d7/a3-a6,-(sp)
	move.l	m_init(a6),a0
	jsr	(a0)				init the big screen
	movem.l	(sp)+,d3-d7/a3-a6
	tst.w	d0
	bne.s	.nogrf				if failed somehow

* here a3=ptr to table of planes, linebytes, pixwidth, pixhite
* d7=where the screen is
.initmon
	movem.w	(a3),d2/d3/d4/d5
.initmon2
	tst.b	_vidtype(a4)
	ble.s	.nottt
	lea	pal_tt(pc),a5		TT palette is different (cannot be Moniterm!)
.nottt	subq.w	#1,d2
	beq	.mono
	cmp.w	#2-1,d2
	beq.s	.medium
	cmp.w	#4-1,d2
	beq.s	.medium			really Low!
	cmp.w	#8-1,d2
	beq.s	.medium			really TT low!
.nogrf	moveq	#RET_NOGRAPHICS,d0
	movem.l	(sp)+,CREGS4
	rts
.nogrfmem
	moveq	#RET_NOMEM,d0
	movem.l	(sp)+,CREGS4
	rts

.medium	move.w	d3,linebytes(a4)
	move.w	d2,-(sp)
	dc.w	$a000
	move.w	(sp)+,d2
	move.l	a1,a0
	moveq	#3,d1				8 pix high font
	move.l	4(a0),a1
	cmp.l	#400,d5
	blt.s	.gotcfont
	moveq	#4,d1				if deep vertically, use big font
	move.l	8(a0),a1
** ignores font variable in colour
.gotcfont
	move.w	#-1,last_y(a4)
	move.w	d1,_fshift(a4)
	move.w	d4,d0
	lsr.w	#3,d0
	move.w	d0,_maxw(a4)
	move.w	d5,d0
	lsr.w	d1,d0
	move.w	d0,_maxh(a4)
	IFNE	0
	cmp.w	#4-1,d2
	seq	d6
	and.w	#1,d6
	addq.w	#1,d6				1=medium, 2=low
	ELSEIF
	moveq	#1,d6
	add.w	d2,d6
	lsr.w	#1,d6				1=medium, 2=low, 4=TT low (temp)
	cmp.w	#4,d6
	bne.s	.all
	subq.w	#1,d6				TT low is 3, not 4
	ENDC
	bra.s	.all

* mono for both small and large
.mono
	move.w	d3,linebytes(a4)
* get font ptr
	dc.w	$a000
	tst.l	_fontsize(a4)
	beq.s	.normal
	move.l	4(a1),a1		8x8
	moveq	#3,d1
	bra.s	.ff

.normal	move.l	8(a1),a1		8x16
	moveq	#4,d1

.ff	move.w	d1,_fshift(a4)
	move.w	d4,d0
	lsr.w	#3,d0
	move.w	d0,_maxw(a4)
	move.w	d5,d0
	lsr.w	d1,d0
	move.w	d0,_maxh(a4)

	moveq	#0,d6
.all	move.l	76(a1),fontptr(a4)
	move.w	d6,themode(a4)

* free up the RAM for the bigscreen driver (else malloc will fail)
	tst.l	_screen_driver(a4)
	beq.s	.nobig
	bsr	clean_driver
	bsr	we_have_large			add RAM to list anyway
.nobig
	tst.b	_switch_mode(a4)
	beq.s	.noswitch

* allocate our own screen

	moveq	#0,d0
	move.w	d3,d0
	mulu	d5,d0

	move.l	d0,d1
	lsr.l	#2,d1
	move.l	d1,longsize(a4)			longs/screen
	
	add.l	#256,d0
	cmp.l	m_address(a6),d7
	bne.s	.getvid
	pea	1.w
	move.l	d0,-(sp)
	jsr	_calloc				dont care about type if using big-screen
	addq.w	#4,sp
	bra.s	.gotvid
.getvid	move.l	d0,-(sp)
	jsr	_getvideomem			guaranteed zero
.gotvid	addq.l	#4,sp
	tst.l	d0
	beq	.nogrfmem			if no mem
	add.l	#256,d0
	clr.b	d0				align it
	move.l	d0,myscreen(a4)
	move.l	d7,oldscreen(a4)
	bra.s	.x

.noswitch
	tst.b	multimon(a4)
	beq.s	.one
	move.l	d7,myscreen(a4)
	clr.l	oldscreen(a4)			never use it
	bra.s	.x

* if only one monitor then easy
.one	move.l	d7,myscreen(a4)
	move.l	d7,oldscreen(a4)

.x	subq.w	#1,d4
	subq.w	#1,d5
	movem.w	d4/d5,pixsize(a4)

	move.l	a5,pal_code(a4)
	jsr	-2(a5)
	movem.w	d0/d1,my_white(a4)		get our colours

	tst.b	_defaultvideomode+1(a4)
	seq	_hackmouse(a4)
	bne.s	.nohack

* install custom mouse handler
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0
	lea	16(a0),a0
	move.l	a0,mousevec(a4)
	move.l	(a0),oldmouse(a4)
	move.l	#newmouse,(a0)
	clr.b	_mousestate(a4)		**proper RSN**
	dc.w	$a000
	movem.w	-344(a0),d0/d1
	cmp.w	pixsize(a4),d0		in case mon screen is smaller
	blt.s	.xok
	move.w	pixsize(a4),d0
.xok	cmp.w	pixsize+2(a4),d1
	blt.s	.yok
	move.w	pixsize+2(a4),d1
.yok	movem.w	d0/d1,_mousex(a4)

.nohack
	move.w	#-1,last_y(a4)

* install custom critical error handler
	lea	newcritical(pc),a0
	bsr	do_critter
	move.l	d0,oldcritical(a4)

* replace VBL handler with our one
	move.w	sr,-(sp)
	or.w	#$700,sr		dont interrupt
	pea	my_vbl(pc)
	move.w	#$1c,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.w	#8,sp
	move.l	d0,old_vbl(a4)
	move.w	(sp)+,sr

	bsr	_must_show_screen

	movem.l	(sp)+,CREGS4

	moveq	#0,d0
	rts

	xref	_memory_add
we_have_large
	move.l	#1+2,-(sp)			r/w
	move.l	m_mend(a6),-(sp)
	move.l	m_mstart(a6),-(sp)
	jsr	_memory_add
	lea	3*4(sp),sp			ignore errors
	rts

* we have a 2 monitor setup. The user wants to use the non-system screen, which means
* no switching required, *except* if he is using both screens for output!
set_2_switch_mode
	st	multimon(a4)			always
	clr.b	_switch_mode(a4)		default=no switching
;	dc.w	$a000
;	move.l	-34(a0),d0			TOS's cursor address
;	sub.l	logbase.w,d0			minus GEM's screen
;	bmi.s	.2x2				eg if GEM is big, TOS is small
;	move.w	2(a0),d1			width of screen line in bytes
;	mulu	-4(a0),d1			*pixel height
;	cmp.l	d1,d0
;	bcs.s	.rts				if is within possible screen area then 1 screen
	move.b	m_usegem(a6),d0
	and.b	m_usegem(a6),d0
	beq.s	.rts				if not using both
.2x2	move.b	#SWITCH_HW,_switch_mode(a4)
	cmp.l	m_address(a6),d7
	bne.s	.rts
	move.b	#SWITCH_SW,_switch_mode(a4)
.rts	rts

clean_driver
	move.l	_screen_driver(a4),a0
	move.l	$2c(a0),-(sp)			save env ptr
	move.w	#$49,-(sp)
	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1				free prog
	addq.w	#6,sp
	trap	#1				free env
	addq.w	#6,sp
	rts

* because TurboST fucks this code up, we have to be naughty
*	move.w	#$101,-(sp)
*	move.w	#5,-(sp)
*	trap	#13
*	addq.l	#8,sp
* supervisor mode required
do_critter2
	move.l	8(sp),a0		as called by Supexec
do_critter
	move.l	$404.w,d0
	move.l	a0,$404.w
	rts

* return a3 suitable for internal monitor, d7=where, ignores system
* returns NE if does not understand the mode
* returns hw mode number in d0
get_standard_monitor
	move.l	mode_reg(a4),a0
	move.b	(a0),d0
	tst.b	_vidtype(a4)
	bne.s	.nomask
	bclr	#2,d0				STs only have 2 bits
.nomask	and.w	#%111,d0
	cmp.w	#%11,d0
	beq.s	.badmode
	move.w	d0,d1
	lsl.w	#3,d0				*8
	lea	vidMode0(pc,d0.w),a3
	tst.w	(a3)
	beq.s	.badmode
	bsr	get_physbase
	move.l	d0,d7
	move.w	d1,d0
	moveq	#0,d1
	rts
.badmode
	moveq	#-1,d0
	rts

* table of planes, linebytes, pixwidth, pixhite
vidMode0	dc.w	4,160,320,200		low
vidMode1	dc.w	2,160,640,200		med
vidMode2	dc.w	1,80,640,400		high
vidMode3	dc.w	0,0,0,0
		dc.w	4,320,640,480		TT medium	4
		dc.w	0,0,0,0
		dc.w	1,160,1280,960		TT high		6
		dc.w	8,320,320,480		TT low		7

* palette handlers: three entry points.
* init returns d0.w=white, d1.w=black
* tomon, frommon
hw_pal0	equ	$FFFF8240
hw_pal1	equ	$FFFF8242

* big monitor palettes dont exist
	rts				big init=crap
pal_big	rts
	rts

* ST palette regs are easy enough
	bra.s	pal_st_init
pal_st	bra.s	pal_st_tomon
; from mon to program
	move.w	old_pal0,hw_pal0.w
	move.w	old_pal1,hw_pal1.w
	rts
pal_st_tomon
; from program to mon
	move.w	hw_pal0.w,old_pal0
	move.w	hw_pal1.w,old_pal1
	move.w	my_white,hw_pal0.w
	move.w	my_black,hw_pal1.w
	rts
; initial colours are based on current mode, not desired mode
pal_st_init
	move.l	mode_reg(a4),a0
	move.b	(a0),d1
	tst.b	_vidtype(a4)
	bne.s	.nomask
	bclr	#2,d1				STs only have 2 bits
.nomask	and.w	#%111,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	vidMode0(pc),a0
	move.w	0(a0,d1.w),d1		planes
* will fail if 256-colour mode
	moveq	#1,d0
	lsl.w	d1,d0			d0=colours
	subq.w	#1,d0
	add.w	d0,d0
	lea	hw_pal0.w,a0
	move.w	0(a0,d0.w),d1		get black
	move.w	(a0),d0			get white
	rts

tt_mode	equ	$ffff8262
tt_pal	equ	$ffff8400


* TT palette regs depend on TT lookup bits and duochrome strangeness

; initial colours are based on current mode, not desired mode
pal_tt_init
	move.l	mode_reg(a4),a0
	move.b	(a0),d1
	and.w	#%111,d1
	cmp.w	#%010,d1
	bne.s	.notduo
; duochrome is strange, deeply strange
	move.w	tt_pal+254*2.w,d0	dont movem cos will fall off end
	move.w	tt_pal+255*2.w,d1
	btst	#1,tt_pal+1.w
	beq.s	.invers
	exg	d0,d1
.invers	rts

.notduo	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	vidMode0(pc),a0
	move.w	0(a0,d1.w),d1		planes
* use TT palette area only
	moveq	#1,d0
	lsl.w	d1,d0			d0=colours
	subq.w	#1,d0
	add.w	d0,d0
	lea	tt_pal.w,a0
	cmp.w	#8,d1
	beq.s	.256			256 col mode has no lookup
	moveq	#%1111,d1
	and.b	tt_mode+1.w,d1
	lsl.w	#4,d1			*16
	add.w	d1,a0
.256	move.w	0(a0,d0.w),d1		get black
	move.w	(a0),d0			get white
	rts

	bra.s	pal_tt_init
pal_tt	bra.s	pal_tt_tomon
; from mon to program
	move.l	last_tt_pal0,a0
	move.w	old_pal0,(a0)
	move.l	last_tt_pal1,a0
	move.w	old_pal1,(a0)
	rts
pal_tt_tomon
; from program to mon - saves palette address
	lea	tt_pal.w,a0
	moveq	#%111,d0
	and.b	tt_mode.w,d0
	cmp.b	#%111,d0
	beq.s	.256
	subq.b	#2,d0
	bne.s	.notduo
; duochrome uses palette 254 and 255!
	lea	254*2(a0),a0
	lea	2(a0),a1
	btst	#0,tt_mode.w
	bne.s	.set
	exg	a0,a1
	bra.s	.set

.notduo	moveq	#%1111,d0
	and.b	tt_mode+1.w,d0
	lsl.w	#4,d0
.add	add.w	d0,a0
.256	lea	2(a0),a1
.set	move.l	a0,last_tt_pal0		*not* a4!
	move.w	(a0),old_pal0
	move.w	my_white,(a0)
	move.l	a1,last_tt_pal1
	move.w	(a1),old_pal1
	move.w	my_black,(a1)
	rts

**	xdef	check_valid_mode	debug only
* given d0.b as requested mode, see if can be done
* returns NE if not, uses d1/a0
check_valid_mode
	move.l	mode_reg(a4),a0
	move.b	(a0),d1
	tst.b	_vidtype(a4)
	bne.s	.nomask
	bclr	#2,d1				STs only have 2 bits
.nomask	and.w	#%111,d1			d1=current mode
	tst.b	_vidtype(a4)
	ble.s	.jokebox			if ST or STE
* TTs can be any recognised mode, unless super-high res
	cmp.b	#6,d1
	beq.s	.checksame
* any allowed mode here
	cmp.b	#2,d0
	ble.s	.okmode
	cmp.b	#4,d0
	beq.s	.okmode
	cmp.b	#7,d0
	beq.s	.okmode
.badmode
	moveq	#-1,d1
	rts
* STs and STEs can be mono if mono, or colour if either colour
.jokebox
	cmp.b	#2,d1
	beq.s	.checksame			if mono then only mono
	bgt.s	.badmode			shouldnt happen
	cmp.b	#2,d0
	bge.s	.badmode
.okmode	moveq	#0,d1
	rts
.checksame
	cmp.b	d0,d1
	rts

* if we are not already showing, show us
_must_show_screen
	sf	countdown_timer(a4)	do immediately
	sf	want_new_screen(a4)	stop pending switch
	move.b	_switch_mode(a4),d0
	beq.s	.no
	cmp.b	#SWITCH_SW,d0
	bne.s	.hwswitch		either mode
* software switching
	tst.b	current_swap(a4)
	bne.s	.no			if already db
	bsr	swap_screens
.no	rts
.hwswitch
	move.l	myscreen(a4),d1
	bsr.s	get_physbase
	cmp.l	d1,d0
	beq.s	.noshow
	move.l	d0,oldscreen(a4)			remember user addr
	move.l	mode_reg(a4),a0
	move.b	(a0),old_hardware_mode(a4)	and user mode
	move.b	my_hardware_mode(a4),new_mode(a4)
	move.l	d1,d0
	bsr.s	set_physbase
.noshow	rts

scr_high	equ	$ffff8201
scr_low		equ	$ffff8203
scr_vlow	equ	$ffff820d		STE/TT only
scr_mode	equ	$ffff8260
scr_ttmode	equ	$ffff8262		TT only

	xref	_vidtype

get_physbase
	clr.l	-(sp)
	move.b	(scr_high).w,1(sp)
	move.b	(scr_low).w,2(sp)
	tst.b	_vidtype(a4)
	beq.s	.noste
	move.b	(scr_vlow).w,3(sp)
.noste	move.l	(sp)+,d0
	rts

; a4 is OK, can trash 0-1 regs
; if countdown timer is zero then waits
; also sets hw reg to new_mode
set_physbase
	move.l	d0,new_physbase(a4)
	lea	want_new_screen(a4),a0
	move.b	#1,(a0)
	tst.b	countdown_timer(a4)
	beq.s	.wait
	rts
.wait	tst.b	(a0)
	bne.s	.wait			wait till VBL does it
	rts

swap_screens
	not.b	current_swap(a4)
	beq.s	.toprog
	move.l	cursor_var(a4),a0
	move.b	(a0),cursor_state(a4)		remember it
	bclr	#0,(a0)
.toprog	move.l	myscreen(a4),a0
	move.l	oldscreen(a4),a1
	movem.l	d2-d4/a0/a1,-(sp)
	move.l	longsize(a4),d0
	moveq	#3,d1
	and.l	d0,d1
	beq.s	.noextra

.spare	move.l	(a0),d2
	move.l	(a1),(a0)+
	move.l	d2,(a1)+			swap extra long
	subq.b	#1,d1
	bne.s	.spare

.noextra
	lsr.l	#2,d0				into 4 longs/time
	subq.w	#1,d0				for the DBF

.swap	movem.l	(a0),d1-d4
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	d1-d4,-16(a1)
	dbf	d0,.swap

	movem.l	(sp)+,d2-d4/a0/a1
	move.l	a0,oldscreen(a4)
	move.l	a1,myscreen(a4)
	tst.b	current_swap(a4)
	bne.s	.x
	move.l	cursor_var(a4),a0
	move.b	cursor_state(a4),(a0)
.x	rts

* hide our screen, perhaps
_may_hide_screen
	move.b	_screentimer(a4),d0
	beq.s	_must_hide_screen
	cmp.b	#SWITCH_HW,_switch_mode(a4)
	bne.s	_must_hide_screen
	move.b	d0,countdown_timer(a4)
	move.l	oldscreen(a4),d0
	move.b	old_hardware_mode(a4),new_mode(a4)
	bra	set_physbase

_must_hide_screen
	sf	countdown_timer(a4)	do immediately
	move.b	_switch_mode(a4),d0
	beq.s	.no
	cmp.b	#SWITCH_SW,d0
	bne.s	.hw
	tst.b	current_swap(a4)
	bne	swap_screens
.no	rts
* assume hw
.hw	move.l	oldscreen(a4),d0
	move.b	old_hardware_mode(a4),new_mode(a4)
	bra	set_physbase			always for now

* display an arbritary screen - use user palette & mode
_show_other_screen
	sf	countdown_timer(a4)
	move.l	4(sp),d0			the one we want
	move.b	old_hardware_mode(a4),new_mode(a4)
	bra	set_physbase

_deinit_graphics

	move.l	oldcritical(a4),d0
	beq.s	.nocrit
	SUPER	do_critter2,d0
.nocrit

	move.l	mousevec(a4),d0
	beq.s	.nounm
	move.l	d0,a0
	move.l	oldmouse(a4),(a0)		restore
.nounm
	move.l	oldscreen(a4),d0
	beq.s	.noscr
	SUPER	_must_hide_screen		restore it
.noscr
	move.l	old_vbl(a4),d0
	beq.s	.novbl
	move.l	d0,-(sp)
	move.l	#$0005001C,-(sp)
	trap	#13
	addq.w	#8,sp
.novbl

	tst.b	multimon(a4)
	beq.s	.onemon
* we should clear out the monitor we're not using
	tst.b	_switch_mode(a4)
	bne.s	.onemon				unless were a 2x2 mode
	bsr	clear_all
.onemon	rts

* C interface to below routine
	xdef	_check_long_rw
_check_long_rw
	move.l	4(sp),a0
	move.l	d2,-(sp)
	bsr.s	check_rw_long
	seq	d0
	move.l	(sp)+,d2
	rts

* given a0 and supervisor mode, see if we can read and write
* in supervisor mode without bus errors
* if OK EQ
* uses d0-d2/a0-a1
	xdef	check_rw_long
check_rw_long
* before performing this check, ensure it doesnt crap on our code or stack!
	cmp.l	#.START,a0
	blt.s	.notcode
	cmp.l	#.END,a0
	blt.s	.reteq				if in this code
.notcode
	moveq	#-20,d0
	add.l	sp,d0				base of sp area
	cmp.l	d0,a0
	blt.s	.test
	cmp.l	sp,a0
	bgt.s	.test
.reteq	moveq	#0,d0				assume we can r/w
	rts
.test	move.w	sr,-(sp)
	or.w	#$0700,sr			dont interrupt me
	move.l	sp,d1
	lea	8.w,a1
	tst.w	$59e.w
	beq.s	.novbr
	OPT	P=68010
	movec	vbr,a1
	addq.w	#8,a1
	OPT	P=68000
.novbr	move.l	(a1),d2
	move.l	#.bad,(a1)
.START	move.l	#'AMP!',d0			scientific test pattern
	move.l	(a0),-(sp)			remember old contents
	move.l	d0,(a0)
	cmp.l	(a0),d0
	bne.s	.bad
	move.l	(sp)+,(a0)			restore if OK
	moveq	#0,d0
.bad	move.l	d2,(a1)				restore handler
.END	move.l	d1,sp				and SSP
	move.w	(sp)+,sr			(note:craps on flags)
	tst.l	d0
	rts


* try to change fonts - return 0 if cannot
* although works in any mode! (almost!)
_kick_mode
	move.w	_fshift(a4),d1
	eor.w	#4^3,d1

	moveq	#1,d0
	add.w	pixsize+2(a4),d0
	lsr.w	d1,d0
	cmp.w	#MAXY,d0
	bgt.s	.toobig				eg full Moniterm

	move.w	d1,_fshift(a4)
	moveq	#1,d0
	add.w	pixsize(a4),d0
	lsr.w	#3,d0
	move.w	d0,_maxw(a4)
	moveq	#1,d0
	add.w	pixsize+2(a4),d0
	lsr.w	d1,d0
	move.w	d0,_maxh(a4)
	movem.l	d2/a2,-(sp)
	dc.w	$a000
	movem.l	(sp)+,d2/a2
	move.l	4(a1),a0			8x8
	cmp.w	#3,_fshift(a4)
	beq.s	.8x8
	move.l	8(a1),a0
.8x8	move.l	76(a0),fontptr(a4)
	moveq	#1,d0
	rts
.toobig	moveq	#0,d0
	rts

* x reg returns with fontshift
* y reg trashed
* outAn screen addr
* outDn linebytes
* trashDn returns with fshift
* we remember the last Y co-ord for speed reasons (to save mulus)
mcalc	macro	x,y,outAn,outDn,trashDn
	cmp.w	last_y(a4),\2
 	bne.s	.calcy\@
	move.l	last_addr(a4),\3	last Y calced address
	add.w	\1,\3			add in X offset
	move.w	linebytes(a4),\4
	move.w	_fshift(a4),\5
	bra.s	.goty\@
.calcy\@
	move.w	\2,last_y(a4)
	move.w	linebytes(a4),\4
	mulu	\4,\2			bytes/line * Y
	move.w	_fshift(a4),\5
	lsl.l	\5,\2			Y * fontheight
	add.l	myscreen(a4),\2		screen+yoffset
	move.l	\2,last_addr(a4)	remember it
	move.l	\2,\3
	add.w	\1,\3			+xoffset
.goty\@
	endm

* change x offset for different modes
changex	macro	inx,scratchDn
	move.w	themode(a4),\2
	beq.s	.x\@			if mono
	cmp.w	#2,\2
	bge.s	.\@low
	and.w	\1,\2			\2 is really one
	add.w	\1,\1
	sub.w	\2,\1
	bra.s	.x\@
.\@low	bne.s	.\@ttlow
	moveq	#1,\2
	and.w	\1,\2
	bclr	#0,\1
	add.w	\1,\1
	add.w	\1,\1
	add.w	\2,\1
	bra.s	.x\@
.\@ttlow
	moveq	#1,\2
	and.w	\1,\2
	bclr	#0,\1
	add.w	\1,\1
	add.w	\1,\1
	add.w	\1,\1
	add.w	\2,\1
.x\@
	endm

* in colour, increment a register horizontally
* works in low or medium
bumpcol	macro	oldAn,newAn,scratchDn
	move.w	\1,\3
	and.w	#1,\3			0 / 1
	add.w	\3,\3			0 / 2
	cmp.w	#1,themode(a4)
	beq.s	.med\@
	tst.w	\3
	sne	\3
	cmp.w	#2,themode(a4)
	bne.s	.ttlo\@
	and.w	#6,\3			0 / 6
	bra.s	.med\@
.ttlo\@	and.w	#14,\3			0 / 14
.med\@	lea	1(\1,\3.w),\2
	endm

_char_out
	PROC
	cargs	#8,.x.l,.y.l,.c.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	move.l	.c(a6),d2

	changex	d0,d3	
	mcalc	d0,d1,a0,d7,d3

	move.l	fontptr(a4),a1
	and.w	#$ff,d2
	add.w	d2,a1

	moveq	#0,d1
	bset	d3,d1
	subq.w	#1,d1
	move.w	#256,d0
.mfont	move.b	(a1),(a0)
	add.w	d0,a1
	add.w	d7,a0
	dbf	d1,.mfont

	ENDPROC

_cursor_out
	PROC
	cargs	#8,.x.l,.y.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1

	changex	d0,d2	
	mcalc	d0,d1,a0,d7,d2

	moveq	#0,d1
	bset	d2,d1
	subq.w	#1,d1
.mcurs	not.b	(a0)
	add.w	d7,a0
	dbf	d1,.mcurs

	ENDPROC


_border_out
	PROC
	cargs	#8,.x.l,.y.l,.c.l,.f.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	move.l	.c(a6),d2
	move.l	.f(a6),d3
	sne	d3

	or.b	#%10101010,d3

	lea	borderdata,a1

	changex	d0,d4
	mcalc	d0,d1,a0,d7,d4

	cmp.b	#BD_BACKGROUND,d2
	bne.s	.notback
	cmp.w	#4,_fshift(a4)
	bne.s	.notback			8x8 mode is normal
* 16x8 background is a special pattern
	moveq	#8-1,d1
.doback	move.b	#%10101010,(a0)
	add.w	d7,a0
	move.b	#%01010101,(a0)
	add.w	d7,a0
	dbf	d1,.doback
	bra	.endproc

.notback
	sub.b	#BD_FIRST,d2
	ext.w	d2
	lsl.w	#3,d2
	add.w	d2,a1			a1 points to 8x8 data

	moveq	#8-1,d1

	move.b	d3,d4
	ror.b	#1,d4			build mask2
	
	cmp.w	#4,_fshift(a4)
	bne.s	.bordermed		if 8x8

* 16x16 is made by doubling 8x8
.mbord	move.b	(a1),d0
	and.b	d3,d0
	move.b	d0,(a0)
	add.w	d7,a0
	move.b	(a1)+,d0
	and.b	d4,d0
	move.b	d0,(a0)
	add.w	d7,a0
	dbf	d1,.mbord
	bra.s	.endproc

.bordermed
	move.b	(a1)+,d0
	and.b	d3,d0
	move.b	d0,(a0)
	add.w	d7,a0
	dbf	d1,.bordermed

.endproc
	ENDPROC

_clear_rect
	PROC
	cargs	#8,.x.l,.y.l,.width.l,.height.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	move.l	.width(a6),d2
	beq	.noclr
	move.l	.height(a6),d3
	beq	.noclr

	changex	d0,d4
	mcalc	d0,d1,a0,d7,d4
	lsl.w	d4,d3			d3=pixel height
	subq.w	#1,d3
	subq.w	#1,d2

	bsr.s	clear_lines

.noclr	ENDPROC

; a0=start posn, d2=width-1, d3=lines-1, d7=magic
clear_lines
	moveq	#0,d4			what we clear with
	tst.w	themode(a4)
	bne.s	.col_clear
.yloop	move.l	a0,a1			a1=start of line
	move.w	d2,d0
.clr	move.b	d4,(a0)+
	dbf	d0,.clr			do a pix line
	lea	0(a1,d7.w),a0		next line
	dbf	d3,.yloop
	rts
.col_clear
	move.l	a0,a2			start of line
	move.w	d3,d0
.clrd	move.b	d4,(a0)
	add.w	d7,a0
	dbf	d0,.clrd		go down
	bumpcol	a2,a0,d0
	dbf	d2,.col_clear
	rts

* makes everything black in any mode
clear_all
	move.l	myscreen(a4),a0
	move.w	pixsize+2(a4),d0
	addq.w	#1,d0
	mulu	linebytes(a4),d0
	lsr.l	#2,d0			into longs
	moveq	#-1,d1			all black
.black	move.l	d1,(a0)+
	subq.l	#1,d0
	bne.s	.black
	rts

* important: no clipping performed! - DANGER
_scroll_rect
	PROC	
	cargs	#8,.x.l,.y.l,.width.l,.height.l,.disp.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	move.l	.width(a6),d2
	tst.w	d2
	beq	.endscr
	move.l	.height(a6),d3
	tst.w	d3
	beq	.endscr
	move.l	.disp(a6),d4
	tst.w	d4
	beq	.endscr

	changex	d0,d5
	mcalc	d0,d1,a0,d7,d5
	lsl.w	d5,d3			d3=pixel lines

	subq.w	#1,d2			ready for DBFs
	subq.w	#1,d3

	cmp.w	#1,themode(a4)
	bge	.scrcolour

	muls	d7,d4
	asl.l	d5,d4			d4=byte displacement
	bmi.s	.scrup

.scrdown
	move.w	d7,d0
	mulu	d3,d0
	add.l	d0,a0			last line of source rect
	lea	0(a0,d4.l),a1		dest
	neg.w	d7			so we go up
.ydown	move.l	a0,a2
	move.l	a1,a3
	move.w	d2,d0
.xscrd	move.b	(a0)+,(a1)+
	dbf	d0,.xscrd
	lea	0(a2,d7.w),a0
	lea	0(a3,d7.w),a1
	dbf	d3,.ydown
	neg.w	d7
	move.l	a2,a0
	bra	.clrlin

; a0=source
.scrup	lea	0(a0,d4.l),a1		d4=neg, a1=dest
.yscrup	move.l	a0,a2
	move.l	a1,a3
	move.w	d2,d0
.xscr	move.b	(a0)+,(a1)+
	dbf	d0,.xscr		a line
	lea	0(a2,d7.w),a0
	lea	0(a3,d7.w),a1
	dbf	d3,.yscrup
; clear the bottom line
	move.l	a1,a0
	bra	.clrlin

; low & med the same
.scrcolour
; we scroll a column at a time cos its much easier
	move.w	d2,d6			remember width
	asl.w	d5,d4
	bpl.s	.meddown
; going up means start a line down, the copy to the top
	muls	d7,d4			will be negative
	add.l	d4,a0
	neg.l	d4

	moveq	#1,d0
	add.w	d3,d0			d0=true pixel height
	mulu	d7,d0			bytes/line
	lea	0(a0,d0.l),a3		remember bottom line addr

.collp	move.l	a0,a2			remember dest address
	lea	0(a0,d4.l),a1		a1=source, a0=dest
	move.w	d3,d0			pixel height
.vloop	move.b	(a1),(a0)
	add.w	d7,a0
	add.w	d7,a1
	dbf	d0,.vloop		do a column
; move a2 over a character square
	bumpcol	a2,a0,d0
	dbf	d2,.collp
	move.w	d6,d2
	move.l	a3,a0
	bra	.clrlin

; to scroll down, start at bottom pixel of second-to-last line
; and copy one line above it
.meddown
	muls	d7,d4			will be positive
	move.l	a0,a3			line to clear
	add.l	d4,a0
	move.w	d3,d5			true pixel height (-1)
	mulu	d7,d5			offset to bottom line
	add.l	d5,a0
	sub.l	d4,a0
.mdloop	move.l	a0,a2
	lea	0(a0,d4.l),a1		dest
	move.w	d3,d0
.mdl2	move.b	(a0),(a1)
	sub.w	d7,a0
	sub.w	d7,a1
	dbf	d0,.mdl2
; move a2 over a character square
	bumpcol	a2,a0,d0
	dbf	d2,.mdloop
	move.w	d6,d2
	move.l	a3,a0

.clrlin	moveq	#0,d3
	move.w	_fshift(a4),d0
	bset	d0,d3
	subq.w	#1,d3			pix lines to clear
	bsr	clear_lines		d2/d7 is ready
.endscr
	ENDPROC

* we are allowed to trash a0-a1/d0-d1, usefully
newcritical
	cmp.b	#2,_progstate
	beq.s	.oldcrit		if running program
	move.l	a4,-(sp)
	GETA4
	bsr	_must_hide_screen
	move.b	_progstate(a4),-(sp)
	move.l	4+4+2(sp),-(sp)		copy error code
	move.b	#2,_progstate		so mouse works
	move.l	oldcritical(a4),a0
	jsr	(a0)
	addq.l	#4,sp
	move.l	d0,-(sp)
	bsr	_must_show_screen
	move.l	(sp)+,d0
	move.b	(sp)+,_progstate(a4)
	move.l	(sp)+,a4
	rts
.oldcrit
	move.l	oldcritical,-(sp)
	rts

* we are the direct VBL handler - take care!
my_vbl	tst.b	want_new_screen
	beq.s	.old
	tst.l	colorptr.w
	bne.s	.flip			flip if new palette loading
	tst.l	screenpt.w
	bne.s	.flip			or if new screen!
	tst.b	countdown_timer
	beq.s	.flip			else use timer
	subq.b	#1,countdown_timer
	bra.s	.old
.flip	movem.l	d0-d1/a0-a1,-(sp)
	move.l	new_physbase,d0
	move.l	d0,-(sp)
	move.b	1(sp),(scr_high).w
	move.b	2(sp),(scr_low).w
	tst.b	_vidtype		no a4!
	beq.s	.noste
	move.b	3(sp),(scr_vlow).w
.noste	addq.w	#4,sp
	move.l	mode_reg,a0
	move.b	new_mode,(a0)
; set palette
	move.l	pal_code,a0
	cmp.l	myscreen,d0
	beq.s	.tomon
	addq.w	#2,a0
.tomon	jsr	(a0)
	sf	want_new_screen
	movem.l	(sp)+,d0-d1/a0-a1
.old	move.l	old_vbl,-(sp)
	rts

newmouse
	tst.b	_user_mouse
	bne.s	.old
	cmp.b	#2,_progstate
	bne.s	.monmouse
.old	move.l	oldmouse,-(sp)
	rts
.monmouse
	movem.l	d0/d1/a0,-(sp)
	move.b	(a0),d0
	and.b	#$f8,d0
	cmp.b	#$f8,d0
	bne	.x
	moveq	#%11,d0
	and.b	(a0)+,d0		d0=new button state
	cmp.b	_mousestate,d0
	beq.s	.nobutchange
; button state has changed - debug & record
	move.b	_mousestate,d1
	eor.b	d0,d1			d1=mask of changed buttons
	cmp.b	#%10,d1
	bne.s	.nobutchange		**hack one button only**
; d0=new button state, d1=mask of the button
	and.b	d1,d0			d0=new state (masked)
	not.b	d1
	and.b	_mousestate,d1		lose old state
	or.b	d0,d1			add in new state
	move.b	d1,_mousestate
; handle the movement packets
.nobutchange
	move.b	(a0)+,d0
	ext.w	d0
	move.w	_mousex,d1
	add.w	d0,d1
	bpl.s	.pl
	moveq	#0,d1
.pl	cmp.w	pixsize,d1
	ble.s	.lt
	move.w	pixsize,d1
.lt	move.w	d1,_mousex

	move.b	(a0)+,d0
	ext.w	d0
	move.w	_mousey,d1
	add.w	d0,d1
	bpl.s	.pl2
	moveq	#0,d1
.pl2	cmp.w	pixsize+2,d1
	ble.s	.lt2
	move.w	pixsize+2,d1
.lt2	move.w	d1,_mousey

.x	movem.l	(sp)+,d0/d1/a0
	rts

* given d0.w=x, d1.w=y (pixels), find screen address
* into a0, d7=step to next line, d6=height
* bits to shift right in d2
* d3=mask of up to 16 bits to stop going off RHS
* d5=2 4 or 8 depending on mode
get_mouse_info
	move.w	pixsize+2(a4),d6		pix height-1
	addq.w	#1,d6
	sub.w	d1,d6
	cmp.w	#16,d6
	blt.s	.clipbot
	moveq	#16,d6
.clipbot
	move.l	myscreen(a4),a0
	move.w	linebytes(a4),d7
	mulu	d7,d1

	add.l	d1,a0
	moveq	#%1111,d2
	and.w	d0,d2			get shift count, 0-15


	moveq	#-1,d3			full mask
	move.w	pixsize(a4),d4
	addq.w	#1,d4
	sub.w	d0,d4
	cmp.w	#16,d4
	bge.s	.norhs
* d4=full width-y pos=number of bits to set, 0-15
	moveq	#0,d3
	bset	d4,d3
	subq.w	#1,d3
	swap	d3
.norhs
	lsr.w	#3,d0			pixels -> chars
	bclr	#0,d0			ensure even
	move.w	themode(a4),d1
	lsl.w	d1,d0			*2 for medium, *4 for low, *8 for TT low
	add.w	d0,a0
	moveq	#0,d5
	addq.w	#1,d1
	bset	d1,d5			2 4 or 8
	rts

_draw_mouse
	PROC	
	cargs	#8,.x.l,.y.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	bsr	get_mouse_info
	subq.w	#1,d6
	bmi.s	.q
	lea	mousebuf,a1
	lea	mousedat,a2

; all mice are the same!

.mloop	move.w	(a0),(a1)+		save first word
	move.w	0(a0,d5.w),(a1)+	and second word

	move.w	(a2)+,d1
	swap	d1
	clr.w	d1
	lsr.l	d2,d1
	and.l	d3,d1			mask to screen
	not.l	d1			for cookie cut

	move.w	(a2)+,d0
	swap	d0
	clr.w	d0
	lsr.l	d2,d0
	and.l	d3,d0

; do both words
	and.w	0(a0,d5.w),d1		mask out screen
	or.w	d0,d1			or in data
	move.w	d1,0(a0,d5.w)
	swap	d1
	swap	d0
	and.w	(a0),d1
	or.w	d0,d1
	move.w	d1,(a0)

	add.w	d7,a0
	dbf	d6,.mloop

.q
	ENDPROC

_hide_mouse
	PROC	
	cargs	#8,.x.l,.y.l
	move.l	.x(a6),d0
	move.l	.y(a6),d1
	bsr	get_mouse_info
	subq.w	#1,d6
	bmi.s	.q
	lea	mousebuf,a1

.mhide
	move.w	(a1)+,(a0)
	move.w	(a1)+,0(a0,d5.w)
	add.w	d7,a0
	dbf	d6,.mhide

.q
	ENDPROC

	rts

* clear the whole screen, for real
_screen_clear
	move.l	longsize(a4),d0
	moveq	#0,d1
	move.l	myscreen(a4),a0
	subq.w	#1,d0
.clr	move.l	d1,(a0)+
	subq.l	#1,d0
	bne.s	.clr
	rts

	section	DATA,DATA

* BD_LIST		"©ª\\/|-ð "

* based on 8x8
borderdata
	dc.b	0,0
	dc.b	%00011111
	dc.b	%00011111
	dc.b	%00011111
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011000

	dc.b	0,0
	dc.b	%11111000
	dc.b	%11111000
	dc.b	%11111000
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00011111
	dc.b	0,0,0

	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%11111000
	dc.b	0,0,0


	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000

	dc.b	0,0,0
	dc.b	-1,-1
	dc.b	0,0,0

	dc.b	0,0
	dc.b	-1,-1,-1,-1
	dc.b	0,0

	dc.b	%10101010
	dc.b	%01010101
	dc.b	%10101010
	dc.b	%01010101
	dc.b	%10101010
	dc.b	%01010101
	dc.b	%10101010
	dc.b	%01010101

mdat	macro
	dc.w	\1,0,\1,0
	endm

; word of mask, word of data, borrowed from the ROM
mousedat
	DC.W	$C000,0,$E000,$4000
	DC.W	$F000,$6000,$F800,$7000
	DC.W	$FC00,$7800,$FE00,$7C00
	DC.W	$FF00,$7E00,$FF80,$7F00
	DC.W	$FFC0,$7F80,$FFE0,$7C00
	DC.W	$FE00,$6C00,$EF00,$4600
	DC.W	$CF00,$600,$8780,$300
	DC.W	$780,$300,$380,0

xmonstr	dc.b	"VER=%x BUF=%lx MODE=%x",0
	even

	section	__MERGED,BSS
* public globals:
_maxw	ds.w	1
_maxh	ds.w	1
_switch_mode	ds.b	1
_hackmouse	ds.b	1		NE=use it, EQ=dont
_fontsize	ds.l	1		NE=small, EQ=normal
_defaultvideomode	ds.l	1
_user_mouse	ds.b	1

* private globals:
linebytes	ds.w	1
fontptr		ds.l	1
myscreen	ds.l	1
_fshift		ds.w	1
oldscreen	ds.l	1
longsize	ds.l	1
current_swap	ds.b	1		0=prog, -1=db
multimon	ds.b	1		NE=two monitors
want_new_screen	ds.b	1		NE to switch
countdown_timer	ds.b	1		0 means Switch
my_hardware_mode ds.b	1
old_hardware_mode ds.b	1
new_mode	ds.b	1
new_physbase	ds.l	1
oldcritical	ds.l	1
old_vbl		ds.l	1
themode		ds.w	1		0=mono, 1=med, 2=low, 3=TT low (log2(planes))
mode_reg	ds.l	1		ptr to mode register
last_y		ds.w	1
last_addr	ds.l	1
last_tt_pal0	ds.l	1
last_tt_pal1	ds.l	1

pal_code	ds.l	1
my_white	ds.w	1		keep
my_black	ds.w	1		together
old_pal0	ds.w	1		keep
old_pal1	ds.w	1		together

cursor_var	ds.l	1
cursor_state	ds.b	1

_mousex		ds.w	1
_mousey		ds.w	1
oldmouse	ds.l	1
mousevec	ds.l	1
pixsize		ds.w	2		one less than pixwidth
mousebuf	ds.l	16
_mousestate	ds.b	1
