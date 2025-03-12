*=======================================================*
*	Falcon030 Doom project (Bad Mood) v2.06 alpha	*
*=======================================================*
*	Main core: latest update 25/03/96		*
*=======================================================*

	OPT		P=68030
	OPT		W-

*-------------------------------------------------------*
*	Conditional options				*
*-------------------------------------------------------*

;test					; enable for pre-defined WAD (debug).
;debuggable				; enable for 'soft' safe interrupts.
enable_timing				; enable for timing information.

*-------------------------------------------------------*
*	Compatibility settings				*
*-------------------------------------------------------*

;compat_level		=	1	; 16Mhz base Falcons.
;compat_level		=	3	; Accelerated Falcons.
compat_level		=	4	; MC68040 & super-accelerated Falcons.

*-------------------------------------------------------*
*	Display settings				*
*-------------------------------------------------------*

default_width		=	320	; default width
default_height		=	200	; vertical normal mode (status bar)
expanded_height		=	240	; vertical fullscreen mode

base_aspect		=	200	; base reference (unadjusted) ratio.
vga_aspect		=	240	; 240-line aspect ratio (VGA).
rgb_aspect		=	200	; 200-line aspect ratio (PAL).

*-------------------------------------------------------*

base_red		=	255
base_green		=	255
base_blue		=	255

*-------------------------------------------------------*
*	Keycodes for control & player movement		*
*-------------------------------------------------------*
*	These should go away once the event-based	*
*	keyboard routines are ready.			*
*-------------------------------------------------------*

rise_key		=	2
drop_key		=	3
hres_key		=	4
vres_key		=	5
text_key		=	28

rgb_key			=	19
vga_key			=	47
full_key		=	33

quit_key		=	1	; 'ESC' key
map_key			=	15	; 'TAB' key

minus_key		=	12	;
plus_key		=	13	;

left_key		=	$4b	; left arrow
right_key		=	$4d	; right arrow
forward_key		=	$48	; up arrow
back_key		=	$50	; down arrow
alt_key			=	$38	; 'ALT' key

lshift_key		=	42
rshift_key		=	54

*-------------------------------------------------------*
*	Main program includes				*
*-------------------------------------------------------*

	include		include\header.s
	include		include\macros.s
	include		include\video.s

*-------------------------------------------------------*
*	DSP core includes				*
*-------------------------------------------------------*

	include		include\dspconst.s
	
*-------------------------------------------------------*
*	Mark TEXT, DATA & BSS reference sections	*
*-------------------------------------------------------*
	bss
*-------------------------------------------------------*
bss_start:
*-------------------------------------------------------*
	data
*-------------------------------------------------------*
data_start:
*-------------------------------------------------------*
	text
*-------------------------------------------------------*
text_start:
*-------------------------------------------------------*
*	Path for pre-defined WAD			*	
*-------------------------------------------------------*
	bra		Doom
*-------------------------------------------------------*

default_path:		;dc.b	'l:\wads\doom.wad e4m8'
			;dc.b	'l:\wads\doom1.wad e1m3'
			;dc.b	'l:\wads\doom2.wad map06'
			dc.b	'l:\wads\heretic1.wad e1m4'
			dc.b	0

iwad_path:		ds.b	256
levelmarker:		ds.b	8

*-------------------------------------------------------*
*	Program starts here				*	
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*

Doom:	move.l		4(sp),a5
	lea		128(a5),a4	; command string
	move.l		a4,cli
	move.l		12(a5),d0	; text segment
	add.l		20(a5),d0	; data segment
	add.l		28(a5),d0	; bss segment
	add.l		#$100,d0	; base page
	move.l		d0,-(sp)
	move.l		a5,-(sp)
	clr.w		-(sp)
	move.w		#$4a,-(sp)
	trap		#1		; mshrink
	lea		12(sp),sp
*-------------------------------------------------------*
*	Hide mouse					*
*-------------------------------------------------------*
	dc.w		$A00A
*-------------------------------------------------------*
*	Commandline module				*
*-------------------------------------------------------*
	move.l		cli,a5
*-------------------------------------------------------*
	ifnd		test
*-------------------------------------------------------*
	moveq		#0,d0
	move.b		(a5)+,d0
	bne.s		.load
	moveq		#4,d0
	bra		safe_quit
*-------------------------------------------------------*
	elseif
*-------------------------------------------------------*
	lea		default_path,a5
	move.w		#255,d0
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
.load:	lea		iwad_path,a0
	lea		levelmarker,a2	
	move.l		#-1,(a2)
.nwad:	move.b		(a5)+,d1
	beq.s		.adon
	fixcase		d1
	cmp.b		#' ',d1
	beq.s		.lwad
	move.b		d1,(a0)+
	subq.w		#1,d0
	bne.s		.nwad
	bra.s		.adon
.nlwad:	move.b		(a5)+,d1
	beq.s		.done
	fixcase		d1
	move.b		d1,(a2)+
.lwad	subq.w		#1,d0
	bne.s		.nlwad
.done:	clr.b		(a2)
.adon:	clr.b		(a0)
*-------------------------------------------------------*
*	Flush out BSS					*
*-------------------------------------------------------*
	lea		bss_start,a0
	move.l		#(bss_end-bss_start)/4,d0
	moveq		#0,d1
.clr:	move.l		d1,(a0)+
	subq.l		#1,d0
	bne.s		.clr
*-------------------------------------------------------*
*	Allocate ST-RAM space for 3 screenbuffers	*
*-------------------------------------------------------*
	bsr		allocate_screens
*-------------------------------------------------------*
*	Initialise memory manager			*
*-------------------------------------------------------*
	bsr		init_block_manager
*-------------------------------------------------------*
*	Flush keyboard buffer				*
*-------------------------------------------------------*
	bsr		empty_buffer
*-------------------------------------------------------*
*	Parse Doom WAD file				*
*-------------------------------------------------------*
	bsr		parse_iwad
*-------------------------------------------------------*
*	Load level resources				*
*-------------------------------------------------------*
	bsr		load_leveldata
*-------------------------------------------------------*
*	Initialise textures & colourmaps		*
*-------------------------------------------------------*
	bsr		init_textures
	bsr		init_cache
	bsr		init_colours
	bsr		thrash_level
	Cconws		#ascii_replacedone
*-------------------------------------------------------*
*	Calculate wall lengths				*
*-------------------------------------------------------*
	bsr		measure_linedefs
*-------------------------------------------------------*
*	Wad parsing complete - close wadfile & pause	*
*-------------------------------------------------------*
	bsr		close_wad
	Crawcin
*-------------------------------------------------------*
*	Switch to supervisor mode			*
*-------------------------------------------------------*
	pea		ourstack
	push.w		#32
	trap		#1
;	addq.l		#6,sp
	push.l		d0
*-------------------------------------------------------*
*	Setup new truecolour video mode			*
*-------------------------------------------------------*
	bsr		select_video
*-------------------------------------------------------*
*	Kickstart DSP Doom Core				*
*-------------------------------------------------------*
	bsr		kickstart_doomcore
*-------------------------------------------------------*
*	Select initial window size & prepare lists	*
*-------------------------------------------------------*
	move.w		#window_max,window_size
	bsr		select_window
*-------------------------------------------------------*
*	Set up global display structure			*
*-------------------------------------------------------*
	bsr		init_displaystruct
*-------------------------------------------------------*
*	Enable VBI & timing interrupts			*
*-------------------------------------------------------*
	bsr		init_timing
*-------------------------------------------------------*
*	Replace keyboard handler			*
*-------------------------------------------------------*
	bsr		initialise_ikbd
*-------------------------------------------------------*
	bsr		open_wad
*-------------------------------------------------------*
*	Main program loop				*
*-------------------------------------------------------*
game_loop:
*-------------------------------------------------------*
*	Read keyboard (debug mode only)			*
*-------------------------------------------------------*
	ifd		debuggable
	bsr		read_key
	endc
*-------------------------------------------------------*
*	Move player 					*
*-------------------------------------------------------*
	bsr		player_control
*-------------------------------------------------------*
*	Get player direction				*	
*-------------------------------------------------------*
	bsr		triangulate
*-------------------------------------------------------*
*	Display 3D environment				*
*-------------------------------------------------------*
	bsr		display_engine
*-------------------------------------------------------*
*	Display level map				*	
*-------------------------------------------------------*
	bsr		display_map
*-------------------------------------------------------*
*	Display framerate in corner of screen		*
*-------------------------------------------------------*
	ifd		enable_timing
	bsr		timing
	endc
*-------------------------------------------------------*
*	Double-buffered display				*
*-------------------------------------------------------*
	vsync
	bsr		adjust_scanlines
	doublebuffer
*-------------------------------------------------------*
*	Check for exit key				*
*-------------------------------------------------------*
	tst.b		program_quit
	beq.s		game_loop

*-------------------------------------------------------*
*	Program end - restore parameters & exit		*
*-------------------------------------------------------*
game_exit:
*-------------------------------------------------------*
*	Restore system					*
*-------------------------------------------------------*
	bsr		close_wad
	bsr		remove_ikbd
	bsr		reset_timing
	bsr		empty_buffer
	bsr		restore_video
*-------------------------------------------------------*
*	Return to user mode				*
*-------------------------------------------------------*
	move.w		#32,-(sp)
	trap		#1
	lea		10(sp),sp
*-------------------------------------------------------*
*	Exit program					*
*-------------------------------------------------------*
safe_quit:
*-------------------------------------------------------*
*	Unhide the mouse				*
*-------------------------------------------------------*
	dc.w		$A009
*-------------------------------------------------------*
*	Terminate program				*
*-------------------------------------------------------*
	clr.w		-(sp)
	trap		#1

*-------------------------------------------------------*
*	Player control module with turning & movement	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
player_control:
*-------------------------------------------------------*
	lea		key_buffer,a6

	tst.b		rgb_key(a6)
	beq.s		.nrgb
	move.w		#rgb_aspect,aspect_ratio
	bsr		select_window
.nrgb:
	tst.b		vga_key(a6)
	beq.s		.nvga
	move.w		#vga_aspect,aspect_ratio
	bsr		select_window
.nvga:
	tst.b		full_key(a6)
	beq.s		.nf
	move.w		#expanded_height,viewport_height
	not.b		fullscreen
	bne.s		.nf1
	move.w		#default_height,viewport_height
.nf1:	bsr		select_window
.nf:
	
;	tst.b		text_key(a6)
;	beq.s		.ntx
;	bsr		texture_loop
;.ntx:
	tst.b		hres_key(a6)
	beq.s		.ndh
	not.b		halfrows
	bsr		select_window
.ndh:
	tst.b		vres_key(a6)
	beq.s		.ndv
	not.b		halflines
	bsr		select_window
.ndv:


	tst.b		plus_key(a6)
	beq.s		.nwp
	add.w		#32,window_size
	bsr		select_window
.nwp:	tst.b		minus_key(a6)
	beq.s		.nwm
	sub.w		#32,window_size
	bsr		select_window
.nwm:	tst.b		quit_key(a6)
	beq.s		.nox
	st		program_quit
.nox:	tst.b		map_key(a6)
	beq.s		.nmk
	not.b		map_enabled
.wlp:	tst.b		map_key(a6)
	bne.s		.wlp
.nmk:	rts

player_movement:
	lea		key_buffer,a6

	move.l		#rotate_speed,d5
	move.l		#slide_speed,d6
	move.l		#walk_speed,d7

	tst.b		lshift_key(a6)
	bne.s		.ys
	tst.b		rshift_key(a6)
	beq.s		.ns
.ys:	add.l		d5,d5
	add.l		d6,d6
	add.l		d7,d7
.ns:

	tst.b		rise_key(a6)
	beq.s		.nr
	addq.w		#4,pho
.nr:	tst.b		drop_key(a6)
	beq.s		.nd
	subq.w		#4,pho
.nd:
	tst.b		left_key(a6)
	beq.s		.not_left
	tst.b		alt_key(a6)
	bne.s		.slide_left
	add.l		d5,pangle
	bra.s		.not_left
.slide_left:
	add.l		d6,right_speed
.not_left:
	tst.b		right_key(a6)
	beq.s		.not_right
	tst.b		alt_key(a6)
	bne.s		.slide_right
	sub.l		d5,pangle
	bra.s		.not_right
.slide_right:
	sub.l		d6,right_speed
.not_right:
	tst.b		forward_key(a6)
	beq.s		.not_forward
	add.l		d7,front_speed
.not_forward:
	tst.b		back_key(a6)
	beq.s		.not_back
	sub.l		d7,front_speed
.not_back:
	move.w		mouse_dy,d0
	beq.s		.no_mouse_y
	clr.w		mouse_dy
	ext.l		d0
	muls.l		#walk_speed,d0
	asr.l		d0
	move.l		d0,d1
	asr.l		#1,d1
	sub.l		d1,d0
	sub.l		d0,front_speed	
.no_mouse_y:
	move.w		mouse_dx,d0
	beq.s		.no_mouse_x
	clr.w		mouse_dx
	ext.l		d0
	cmp.b		#1,buttons
	bne.s		.rotate
	muls.l		#slide_speed,d0
	asr.l		d0
	move.l		d0,d1
	asr.l		#1,d1
	sub.l		d1,d0
	sub.l		d0,right_speed	
	bra.s		.no_mouse_x
.rotate:
	muls.l		#rotate_speed,d0
	asr.l		#3,d0
	move.l		d0,d1
	asr.l		#2,d1
	sub.l		d1,d0
	sub.l		d0,pangle
.no_mouse_x:
	move.l		right_speed,d0
	beq.s		.no_right
	move.w		#right_angle,d1
	bsr		move_player
	lea		right_speed,a0
	bsr		decay_speed
.no_right:
	move.l		front_speed,d0
	beq.s		.no_front
	move.w		#front_angle,d1
	bsr		move_player

	move.l		front_speed,d0
	add.l		bob_shift,d0
	move.l		d0,bob_shift

	move.l		d0,d1
	lsl.l		#4,d0
	lsl.l		#3,d1
	add.l		d1,d0
	lsr.l		d1
	add.l		d1,d0

	swap		d0
	and.w		#sinres-1,d0
	move.w		(sine.l,d0.w*2),d0
	asr.w		#8,d0
	asr.w		#4,d0
	move.w		d0,pho

	lea		front_speed,a0
	bsr		decay_speed
.no_front:
	rts

decay_speed:
	move.l		(a0),d0
	bmi.s		.neg	
	move.l		d0,d1
	lsr.l		#2,d0
	sub.l		d0,d1
	and.l		#-128,d1
	move.l		d1,(a0)
	rts
.neg:	neg.l		d0
	move.l		d0,d1
	lsr.l		#2,d0
	sub.l		d0,d1
	and.l		#-128,d1
	neg.l		d1
	move.l		d1,(a0)
	rts


bob_shift:	ds.l	1

	rept		0

	tst.b		left_key(a6)
	beq.s		not_left
	tst.b		alt_key(a6)
	bne.s		move_left
	add.w		#turn_speed,pangle
	bra.s		not_left
move_left:
	move.w		#$4000,d1
	move.w		#player_speed,d0
	bsr		move_player
not_left:
	tst.b		right_key(a6)
	beq.s		not_right
	tst.b		alt_key(a6)
	bne.s		move_right
	sub.w		#turn_speed,pangle
	bra.s		not_right
move_right:
	move.w		#$4000,d1
	move.w		#-player_speed,d0
	bsr		move_player
not_right:
	tst.b		forward_key(a6)
	beq.s		not_forward
	move.w		#player_speed,d0
	moveq		#0,d1
	bsr		move_player
not_forward:
	tst.b		back_key(a6)
	beq.s		not_back
	move.w		#-player_speed,d0
	moveq		#0,d1
	bsr		move_player
not_back:
	move.w		mouse_dy,d0
	beq		no_mouse_y
	neg.w		d0
	moveq		#0,d1
	bsr		move_player
	clr.w		mouse_dy
no_mouse_y:
	move.w		mouse_dx,d0
	beq		no_mouse_x
	cmp.b		#1,buttons
	bne.s		rotate
	neg.w		d0
	move.w		#$4000,d1
	bsr		move_player
	bra.s		no_mouse_x
rotate:
	move.w		mouse_dx,d0
	asl.w		#5,d0
	sub.w		d0,pangle
no_mouse_x:
	clr.w		mouse_dx

	endr
	
	rts

*-------------------------------------------------------*
* Generic movement routine -	d0 = distance		*
*				d1 = angle offset	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
move_player:
*-------------------------------------------------------*
	lsl.l		#2,d0
	move.l		d0,d2			; save distance for later 
	add.w		pangle,d1
	lsr.w		#(16-12),d1
	move.w		(sine.l,d1.w*2),d3
	ext.l		d3
	muls.l		d3,d3:d0
	move.w		d3,d0
	swap		d0
	add.w		#sinres/4,d1
	and.w		#sinres-1,d1
	move.w		(sine.l,d1.w*2),d3
	ext.l		d3
	muls.l		d3,d3:d2
	move.w		d3,d2
	swap		d2
	add.l		d0,py
	add.l		d2,px
	rts

*-------------------------------------------------------*
*	Convert rotational angle into a vector		*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
triangulate:
*-------------------------------------------------------*
	move.w		pangle,d0
	andi.l		#$ffff,d0	
	neg.l		d0
	lsr.w		#(16-12),d0
	lea		sine,a0
	move.w		(a0,d0.w*2),d1
	add.w		#sinres/4,d0
	and.w		#sinres-1,d0
	ext.l		d1
	lsl.l		#2,d1
	move.l		d1,sinpangle
	move.w		(a0,d0.w*2),d1
	ext.l		d1
	lsl.l		#2,d1
	move.l		d1,cospangle
	rts
	
*-------------------------------------------------------*
*	Program modules					*
*-------------------------------------------------------*

	include		io.s
	include		levelmap.s
	include		keyboard.s
	include		screen.s
	include		textures.s
	include		engine.s
	include		memory.s
	include		cache.s

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

cli:			ds.l	1		; command line pointer

px:			ds.l	1		; player-x
py:			ds.l	1		; player-y
pho:			ds.w	1		; player height offset (for flying)
pangle:			ds.l	1		; player direction
cospangle:		ds.l	1		; Cos[d]
sinpangle:		ds.l	1		; Sin[d]

right_speed:		ds.l	1
front_speed:		ds.l	1

			ds.b	16384
ourstack:		ds.l	4		; hefty stack for BSP algorithm


program_quit:		ds.b	1		; exit flag

string_space:		ds.b	256		; general string space

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*
bss_end:
*-------------------------------------------------------*
