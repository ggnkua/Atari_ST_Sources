*=======================================================*
*	Falcon030 Doom project (Bad Mood) v3.07 alpha	*
*=======================================================*
*	Main program: updated 14/06/97			*
*=======================================================*

	COMMENT		HEAD=7
	OPT		P=68040,P=68881,NOTYPE
	OPT		W-

*-------------------------------------------------------*
*	Program version					*
*-------------------------------------------------------*

version			=	$307	; edit this to set the version number!
					; it's BCD encoded so $227 means v2.27.

*-------------------------------------------------------*
*	Debugging options				*
*-------------------------------------------------------*

test					; enable for pre-defined WAD (debug).
;debuggable				; enable for 'soft' safe interrupts.

*-------------------------------------------------------*
*	Timing options					*
*-------------------------------------------------------*

enable_timing				; enable for scaled movement
show_timing				; enable for timing information.

*-------------------------------------------------------*
*	Display options					*
*-------------------------------------------------------*

;intel					; use little-endian truecolour
;frsb					; use fast-ram screen buffering
sprites					; enable sprite rendering
;povmesh				; generate POVRay script for map

*-------------------------------------------------------*
*	Audio options					*
*-------------------------------------------------------*

;audio					; enable sample multiplexer
;midi					; enable MIDI player

*-------------------------------------------------------*
*	Machine-specific options			*
*-------------------------------------------------------*

;m68040					; enable special 68040 optimisations
;use_xmmu				; enable 68040 PMMU speed-up options
;use_alignment				; enable for long-aligned data (32-bit)

*-------------------------------------------------------*
*	Compatibility settings				*
*-------------------------------------------------------*

;compat_level		=	0	; minimum handshaking (fast/flakey)
compat_level		=	99	; full handshaking (slow/solid)

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
timer_key		=	6
all_map_key		=	7
turbulence_key		=	8

text_key		=	28

rgb_key			=	19
vga_key			=	47
full_key		=	33
snap_key		=	102

quit_key		=	1	; 'ESC' key
map_key			=	15	; 'TAB' key

minus_key		=	12	; '+'
plus_key		=	13	; '-'

left_key		=	$4b	; left arrow
right_key		=	$4d	; right arrow
forward_key		=	$48	; up arrow
back_key		=	$50	; down arrow
alt_key			=	$38	; 'ALT' key

lshift_key		=	42
rshift_key		=	54

fire_key		=	$1D	; 'Control' key

sndtst1key		=	$3B	; 'F1' key
sndtst2key		=	$3C	; 'F2' key
sndtst3key		=	$3D	; 'F3' key
sndtst4key		=	$3E	; 'F4' key

cookie_jar		=	$5a0

*-------------------------------------------------------*
*	Main program includes				*
*-------------------------------------------------------*

	include		include\header.inc
	include		include\dspequ.inc

	include		include\video.inc
	include		include\macros.inc

	include		include\wadram.inc
	include		include\wadfile.inc

	ifd		use_xmmu
	include		pmmu.s
	endc

*-------------------------------------------------------*
*	Mark TEXT, DATA & BSS reference sections	*
*-------------------------------------------------------*
	bss
*-------------------------------------------------------*
	ds.b		8192
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

default_path:
			;dc.b	'-if:\doom.wad -pf:\example.wad -we1m1'
			;dc.b	'-if:\doom2.wad -pf:\example2.wad -wmap01'
			;dc.b 'g:\games\fc_games\badmood\wads\iwads\doom1.wad e1m1'
			;dc.b	'f:\doom2.wad map01'
			;dc.b	'f:\heretic1.wad'
			dc.b	'-if:\doom.wad'
			;dc.b	'-if:\doom2.wad -pf:\icarus.wad -wmap04'
			;dc.b	'd:\spel\bad_mood\heretic.wad e1m2'
			;dc.b	'f:\heretic1.wad e1m1'
			dc.b	0
			ds.b	255

iwad_path:		ds.b	256
pwad_path:		ds.b	256
levelmarker:		ds.b	8

*-------------------------------------------------------*
*	Program starts here				*	
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
Doom:	move.l		4(sp),a5
	lea		128(a5),a4	; command string
	move.l		a4,cli
*-------------------------------------------------------*
*	Mshrink						*
*-------------------------------------------------------*
	move.l		12(a5),d0	; text segment
	add.l		20(a5),d0	; data segment
	add.l		28(a5),d0	; bss segment
	add.l		#256,d0		; base page
	lea		usp_stack,sp
	move.l		d0,-(sp)
	move.l		a5,-(sp)
	clr.w		-(sp)
	move.w		#$4a,-(sp)
	trap		#1
	lea		12(sp),sp
*-------------------------------------------------------*
*	Flush keyboard buffer				*
*-------------------------------------------------------*
	bsr		empty_buffer
*-------------------------------------------------------*
*	Commandline module				*
*-------------------------------------------------------*
	bsr		parse_cli
*-------------------------------------------------------*
*	Find size of system display area		*
*-------------------------------------------------------*
	jsr		appl_init
	jsr		graf_handle
	jsr		v_opnvwk
	jsr		v_extnd
	jsr		v_hidemouse
	move.w		vwork_w,os_screen_w
	move.w		vwork_h,os_screen_h
*-------------------------------------------------------*
*	Check for bad monitor types			*
*-------------------------------------------------------*
	jsr		monitor_detect
	tst.w		d0
	beq		safe_quit
*-------------------------------------------------------*
*	Initialise internal memory manager		*
*-------------------------------------------------------*
	bsr		init_block_manager
*-------------------------------------------------------*
*	Parse Doom WAD files				*
*-------------------------------------------------------*
	move.l		#hash_space,hash_array
	bsr		parse_iwad
	bsr		parse_pwad
	Cconws		#ascii_entriesdone
*-------------------------------------------------------*
*	Integrate PWAD into main IWAD directory		*
*-------------------------------------------------------*
	bsr		integrate_wads
*-------------------------------------------------------*
*	Load demo lump					*
*-------------------------------------------------------*
;	bsr		load_demo
*-------------------------------------------------------*
*	Load level resources				*
*-------------------------------------------------------*
	bsr		load_leveldata
*-------------------------------------------------------*
*	Initialise textures & colourmaps		*
*-------------------------------------------------------*
	jsr		init_turbulence
	bsr		init_textures
	bsr		init_cache
	bsr		init_colours
	Cconws		#ascii_replacedone
*-------------------------------------------------------*
*	Precalculate wall lengths			*
*-------------------------------------------------------*
	bsr		measure_linedefs
*-------------------------------------------------------*
*	Set up global display structure			*
*-------------------------------------------------------*
	bsr		init_displaystruct
*-------------------------------------------------------*
*	Assign frames to things				*
*-------------------------------------------------------*
	bsr		assign_thingnames
*-------------------------------------------------------*
*	Assign things to ssectors			*
*-------------------------------------------------------*
	bsr		assign_things
*-------------------------------------------------------*
*	Build reference mesh for rendering		*
*-------------------------------------------------------*
	ifd		povmesh
	bsr		output_mesh
	endc
*-------------------------------------------------------*
*	Initiate SFX engine				*
*-------------------------------------------------------*
	ifd		audio
	moveq.l		#4,d0			; 4 channels
	moveq.l		#5,d1			; update every 5th VBL
	moveq.l		#1,d2			; replay at 12.5kHz
	bsr		sound_init
	endc
*-------------------------------------------------------*
*	Initiate MIDI engine				*
*-------------------------------------------------------*
	ifd		midi
	lea		midi_file_name,a2	
	bsr		midi_load_file 		; load but don't play yet!
	endc
*-------------------------------------------------------*
*	Pause						*
*-------------------------------------------------------*
	Cconws		#PressKey
	Crawcin
*-------------------------------------------------------*
*	Switch to supervisor mode			*
*-------------------------------------------------------*
	pea		ssp_stack
	push.w		#32
	trap		#1
	move.l		d0,os_ssp_ptr
	st		super_on
*-------------------------------------------------------*
*	Setup new truecolour video mode			*
*-------------------------------------------------------*
	jsr		save_screen
	jsr		save_palette
	jsr		default_video
	jsr		configure_viewport
	move.b		clearcount,refresh
*-------------------------------------------------------*
*	Mark MMU pages for extra speed on 68040		*
*-------------------------------------------------------*
	jsr		initialise_pmmu
*-------------------------------------------------------*
*	Kickstart DSP Doom engine			*
*-------------------------------------------------------*
	bsr		kickstart_doomcore
*-------------------------------------------------------*
*	Select initial window size & prepare lists	*
*-------------------------------------------------------*
	move.w		#window_max,window_size
	bsr		select_window
*-------------------------------------------------------*
*	Enable VBI & timing interrupts			*
*-------------------------------------------------------*
	bsr		init_timing
*-------------------------------------------------------*
*	Replace keyboard handler			*
*-------------------------------------------------------*
	bsr		initialise_ikbd
*-------------------------------------------------------*
*	Start SFX engine				*
*-------------------------------------------------------*
	ifd		audio
	bsr		sound_start
	endc
*-------------------------------------------------------*
*	Start MIDI playback				*
*-------------------------------------------------------*
	ifd		midi
	bsr		midi_start
	endc
*-------------------------------------------------------*
	clr.l		accumulated_dx
	clr.l		accumulated_dy
	st		turbulence_on
*-------------------------------------------------------*
	bsr		thrash_level
*-------------------------------------------------------*
*	Main program loop				*
*-------------------------------------------------------*
game_loop:
*-------------------------------------------------------*
;	bsr		run_demo
*-------------------------------------------------------*
;	move.w		$FFFF82C2.w,d0
;	bset		#0,d0
;	move.w		d0,$FFFF82C2.w
*-------------------------------------------------------*
*	Read keyboard (debug mode only)			*
*-------------------------------------------------------*
	ifd		debuggable
	bsr		read_key
	endc
*-------------------------------------------------------*
*	Control player 					*
*-------------------------------------------------------*
	bsr		player_control
*-------------------------------------------------------*
*	Get player direction				*	
*-------------------------------------------------------*
	bsr		triangulate
*-------------------------------------------------------*
*	Find player sector, and set up player height	*
*-------------------------------------------------------*
	lea		display_struct,a6
	move.l		gbl_player_x(a6),d6
	move.l		gbl_player_y(a6),d7
	bsr		find_sector
	move.l		a0,gbl_player_sector(a6)
	move.l		a1,gbl_player_ssector(a6)
	move.w		sector_floorht(a0),d0
	add.w		#player_height,d0
	swap		d0
	clr.w		d0
	move.l		d0,gbl_player_height(a6)
*-------------------------------------------------------*
*	Bob player					*
*-------------------------------------------------------*
	move.l		bob_shift,d0
	move.l		d0,d1
	lsl.l		#4,d0
	lsl.l		#2,d1
	add.l		d1,d0
	add.l		d1,d1
	add.l		d1,d0
	swap		d0
	and.w		#sinres-1,d0
	move.w		(sine.l,d0.w*2),d0
	ext.l		d0
	lsl.l		#4,d0
	add.l		d0,gbl_player_height(a6)
*-------------------------------------------------------*
*	Move player					*
*-------------------------------------------------------*
	move.l		accumulated_dx,d0
	clr.l		accumulated_dx
	move.l		accumulated_dy,d2
	clr.l		accumulated_dy
	add.l		px,d0
	add.l		py,d2
	move.l		d0,nextx
	move.l		d2,nexty
	bsr		check_move
	move.l		nextx,px
	move.l		nexty,py
*-------------------------------------------------------*
*	Advance turbulence index			*
*-------------------------------------------------------*
	move.l		clock,d0
	divu.l		#12,d0
	and.l		#turbres-1,d0
	add.l		d0,d0
	add.l		#r_turb,d0
	move.l		d0,turb_ptr
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
	tst.b		timer_on
	beq.s		.no_timer
	bsr		timing
.no_timer:
	endc
*-------------------------------------------------------*
*	Debug sound					*
*-------------------------------------------------------*
	ifd		audio
	bsr		sfx_debug
	endc
*-------------------------------------------------------*
*	Wait for at least [vbilock] vblanks to elapse	*
*-------------------------------------------------------*
	vsync
	bsr		adjust_scanlines
*-------------------------------------------------------*
*	(F)ast (R)AM (S)creen (B)uffer mode		*
*-------------------------------------------------------*
	ifd		frsb
*-------------------------------------------------------*
	move.l		ScreenLog,a0
	move.l		ScreenPhy,a1
	move.w		width,d7
	tst.b		halfrows
	beq.s		.nhr
	add.w		d7,d7
.nhr:	move.w		scrwidth,d0
	lsr.w		d0
	move.w		d7,d1
	lsr.w		d1
	sub.w		d1,d0
	lsr.w		#3,d0		; d0 = dphrase start
	move.w		d0,d6
	lsl.w		#3,d6
	add.w		d7,d6
	addq.w		#8-1,d6
	lsr.w		#3,d6		; d6 = qphrase end
	sub.w		d0,d6		; qphrase length
	lsl.w		#3+1,d0
	add.w		d0,a0
	add.w		d0,a1
	move.w		height,d7
	move.w		scrwidth,a2
	add.l		a2,a2
	move.w		d6,d5
	lsl.w		#3+1,d5
	sub.w		d5,a2
	subq.w		#1,d6
	subq.w		#1,d7
.yl:	move.w		d6,d0
.xl:	move16		(a0)+,(a1)+
	dbra		d0,.xl
	add.l		a2,a0
	add.l		a2,a1
	dbra		d7,.yl
*-------------------------------------------------------*
*	Standard triple-buffering mode			*
*-------------------------------------------------------*
	elseif
*-------------------------------------------------------*
	doublebuffer
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
*	Check for exit key				*
*-------------------------------------------------------*
	tst.b		program_quit
	beq		game_loop

*-------------------------------------------------------*
*	Program end - restore parameters & exit		*
*-------------------------------------------------------*
game_exit:
safe_quit:
*-------------------------------------------------------*
*	Restore system					*
*-------------------------------------------------------*
	ifd		midi
	bsr		midi_stop
	endc
*-------------------------------------------------------*
	ifd		audio
	bsr		sound_shutdown
	endc
*-------------------------------------------------------*
	bsr		close_wad
	bsr		empty_buffer
	bsr		remove_ikbd
	bsr		reset_timing
	jsr		restore_pmmu
	jsr		restore_screen
	jsr		restore_palette
	bsr		empty_buffer
*-------------------------------------------------------*
*	Return to user mode				*
*-------------------------------------------------------*
	tst.b		super_on
	beq.s		.skip
	push.l		os_ssp_ptr
	move.w		#32,-(sp)
	trap		#1
	addq.l		#6,sp
*-------------------------------------------------------*
*	Exit program					*
*-------------------------------------------------------*
.skip:	jsr		v_showmouse
	jsr		v_clsvwk
	jsr		appl_exit
*-------------------------------------------------------*
	move.l		error_ptr,d0
	beq.s		.nerr
	Cconws		d0
	bsr		empty_buffer
	Crawcin
*-------------------------------------------------------*
*	Terminate program				*
*-------------------------------------------------------*
.nerr:
	ifd		povmesh
	move.l		#mesh_buffer,d4
	move.l		mesh_buffer_ptr,d5
	endc
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
	move.w		sys_rgb_aspect,aspect_ratio
;	move.w		#rgb_aspect,aspect_ratio
	bsr		select_window
.nrgb:
	tst.b		vga_key(a6)
	beq.s		.nvga
	move.w		sys_vga_aspect,aspect_ratio
;	move.w		#vga_aspect,aspect_ratio
	bsr		select_window
.nvga:
	tst.b		full_key(a6)
	beq.s		.nf
	move.w		sys_expanded_height,viewport_height
;	move.w		#expanded_height,viewport_height
	not.b		fullscreen
	bne.s		.nf1
	move.w		sys_default_height,viewport_height
;	move.w		#default_height,viewport_height
.nf1:	bsr		select_window
.nf:
	
;	tst.b		text_key(a6)
;	beq.s		.ntx
;	bsr		texture_loop
;.ntx:

	tst.b		hres_key(a6)
	beq.s		.ndh
	push.l		a6
	jsr		toggle_h_detail
	pop.l		a6
.wdh:	tst.b		hres_key(a6)
	bne.s		.wdh
.ndh:
	tst.b		vres_key(a6)
	beq.s		.ndv
	push.l		a6
	jsr		toggle_v_detail
	pop.l		a6
.wdv:	tst.b		vres_key(a6)
	bne.s		.wdv
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
.nox:
	lea		map_key(a6),a5
	lea		map_enabled,a4
	jsr		toggle_option

	tst.b		snap_key(a6)
	beq.s		.nss
	bsr		save_snapshot
.nss:

	lea		timer_key(a6),a5
	lea		timer_on,a4
	jsr		toggle_option

	ifd		audio
	tst.b		fire_key(a6)
	beq.s		.nfk
	lea		shootsample,a0			; address to sample
	move.l		#shootsampleend-shootsample,d0	; length of sample
	moveq.l		#3,d1				; play as ambient
	move.w		#$5000,d2			; quite high priority
	moveq.l		#0,d3				; not realy neseasy with
	moveq.l		#0,d4				; position for ambient.
	bsr		new_sound			; and lets register it.
.nfk

	tst.b	sndtst1key(a6)
	beq.s	.nst1k
	lea	painsample,a0	; address to sample
	move.l	#painsampleend-painsample,d0	; length of sample
	moveq.l	#1,d1		; play as positioned
	move.w	#$1000,d2		; low priority
	move.w	px,d3		; not realy neseasy with
	move.w	py,d4		; position for ambient.
	bsr	new_sound		; and lets register it.
.nst1k:
	tst.b	sndtst2key(a6)
	beq.s	.nst2k
	lea	growlsample,a0	; address to sample
	move.l	#growlsampleend-growlsample,d0	; length of sample
	moveq.l	#2,d1		; play as positioned
	move.w	#$2000,d2		; maybe low priority
	move.w	px,d3		; not realy neseasy with
	move.w	py,d4		; position for ambient.
	bsr	new_sound		; and lets register it.
.nst2k:
	tst.b	sndtst3key(a6)
	beq.s	.nst3k
	lea	talksample,a0	; address to sample
	move.l	#talksampleend-talksample,d0	; length of sample
	moveq.l	#3,d1		; play as positioned
	move.w	#$7FFF,d2		; overule all 
	moveq.l	#0,d3		; not realy neseasy with
	moveq.l	#0,d4		; position for ambient.
	bsr	new_sound		; and lets register it.
.nst3k:
	tst.b	sndtst4key(a6)
	beq.s	.nst4k
	lea	shootsample,a0	; address to sample
	move.l	#shootsampleend-shootsample,d0	; length of sample
	moveq.l	#4,d1		; play as positioned
	move.w	#$3000,d2		; average 
	moveq.l	#0,d3		; not realy neseasy with
	moveq.l	#0,d4		; position for ambient.
	bsr	new_sound		; and lets register it.
.nst4k:

	endc

	lea		all_map_key(a6),a5
	lea		all_map_on,a4
	jsr		toggle_option

	lea		turbulence_key(a6),a5
	lea		turbulence_on,a4
	jsr		toggle_option

	rts

toggle_option:
	tst.b		(a5)
	beq.s		.nmk
	not.b		(a4)
.wlp:	tst.b		(a5)
	bne.s		.wlp
.nmk:	rts

save_snapshot:

	pushall

	move.w		height,d0
	mulu.w		screen_w,d0
	move.l		d0,snap_pixels
	mulu.l		#3,d0
	add.l		#18,d0
	move.l		d0,snap_size

	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		.err
	move.l		d0,snap_handle
	move.l		d0,a1
	
	lea		tga_header,a2
	move.w		screen_w,d0
	ror.w		#8,d0
	move.w		d0,12(a2)
	move.w		height,d0
	ror.w		#8,d0
	move.w		d0,14(a2)

	cpstruct	18,d0,a2,a1

;	move.w		#(18/2)-1,d0
;.hdr:	move.w		(a2)+,(a1)+
;	dbra		d0,.hdr
	
	move.l		ScreenPhy,a0

	move.l		snap_pixels,d4
.all:	move.w		(a0)+,d0
	bfextu		d0{16:08},d1
	bfextu		d0{21:08},d2
	bfextu		d0{27:08},d3
	and.b		#%11111000,d1
	and.b		#%11111100,d2
	and.b		#%11111000,d3
	move.b		d3,(a1)+
	move.b		d2,(a1)+
	move.b		d1,(a1)+
	subq.l		#1,d4
	bne.s		.all

	push.w		#0
	pea		snap_name
	push.w		#60
	trap		#1
	addq.l		#8,sp
	move.l		d0,d7
	bmi.s		.ferr

	push.l		snap_handle
	push.l		snap_size
	push.w		d7
	push.w		#64
	trap		#1
	lea		12(sp),sp
	
	push.w		d7
	push.w		#62
	trap		#1
	addq.l		#4,sp
	
*****
* New snap name
*****
	addq.b	#1,snap_name+7
	cmp.b	#'9',snap_name+7
	ble.s	.nodecadd
	addq.b	#1,snap_name+6
	move.b	#'0',snap_name+7
.nodecadd:

	
.ferr:

	move.l		snap_handle,d0
	bsr		deallocate_chunk

.err:	popall
	rts

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
	add.l		#4<<16,pho
.nr:	tst.b		drop_key(a6)
	beq.s		.nd
	sub.l		#4<<16,pho
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
	add.l		d0,accumulated_dy
	add.w		#sinres/4,d1
	and.w		#sinres-1,d1
	move.w		(sine.l,d1.w*2),d3
	ext.l		d3
	muls.l		d3,d3:d2
	move.w		d3,d2
	swap		d2
	add.l		d2,accumulated_dx
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
init_turbulence:
*-------------------------------------------------------*
	lea		r_turb,a1
	lea		sine,a0
	bsr		make_turb
	lea		sine,a0
	bsr		make_turb
	rts

*-------------------------------------------------------*
make_turb:
*-------------------------------------------------------*
	move.w		#turbres-1,d0
.make:	move.w		(a0),d1
	asr.w		#2,d1
	move.w		d1,(a1)+
	lea		(sinres/turbres)*2(a0),a0
	dbra		d0,.make
	rts

*-------------------------------------------------------*
load_demo:
*-------------------------------------------------------*
	move.l		#6,ticks
	lea		ascii_demo,a0
	bsr		load_resource
	clr.l		demo_ptr
	clr.l		demo_pos
	tst.l		d0
	beq		.no_demo
	move.l		a6,demo_ptr
	lea		13(a6),a6
	move.l		a6,demo_pos
*-------------------------------------------------------*
.no_demo:
*-------------------------------------------------------*
	rts

ticks:	ds.l		1

*-------------------------------------------------------*
run_demo:
*-------------------------------------------------------*

	subq.l		#1,ticks
	bne		.skip
	move.l		#6,ticks

	pushall
	move.l		demo_pos,d0
	beq.s		.stop
	move.l		d0,a6
	move.b		(a6)+,d1
	move.b		(a6)+,d2
	move.b		(a6)+,d3
	move.b		(a6)+,d4
	cmp.b		#128,d1
	beq.s		.stop
	extb.l		d1
	extb.l		d2
	extb.l		d3
	extb.l		d4
	lsl.w		#8,d3
	add.w		d3,pangle

;	move.w		rangle,d0
;	swap		d0
;	clr.w		d0
;	divu		#360,d0
;	move.w		d0,pangle

	pushall
	bsr		triangulate
	popall

	pushall
	move.l		d1,d0
	mulu.l		#82<<8,d0
	move.w		#$0000,d1
	bsr		move_player
	popall

	move.l		d2,d0
	mulu.l		#82<<8,d0
	move.w		#-$4000,d1
	bsr		move_player

	move.l		a6,demo_pos
.stop:	popall
.skip:	rts

rangle:			ds.l	1

demo_ptr:		ds.l	1
demo_pos:		ds.l	1

ascii_demo:		dc.b	'demo1',0
			even

*-------------------------------------------------------*
*	Main program modules				*
*-------------------------------------------------------*

	include		memory.s	; memory manager
	include		timing.s	; timing routines
	include		dsplib.s	; dsp interface
	include		video.s		; display/video code
	include		ikbd.s		; ikbd routines
	include		sys.s		; system calls
	include		cpu.s		; cpu specific code
	ifd		povmesh
	include		povmesh.s
	endc

*-------------------------------------------------------*
*	WAD & resource management			*
*-------------------------------------------------------*

	include		io.s		; WAD access
	include		textures.s	; texture building
	include		cache.s		; resource cacheing

*-------------------------------------------------------*
*	3D engine					*
*-------------------------------------------------------*

	include		engine.s	; viewport code
	include		bspd.s		; BSP descent & walls
	include		shards.s	; DSP shard retrieval
	include		sprites.s	; things & sprites
	include		render.s	; wall/floor/sprite code

*-------------------------------------------------------*
*	Game modules					*
*-------------------------------------------------------*

	include		chkmove.s	; player collisions
	include		lighting.s	; lighting effects
	include		levelmap.s	; game map

*-------------------------------------------------------*
*	Audio (sample multiplexer) modules		*
*-------------------------------------------------------*

	ifd		audio
	include		sfx_init.s	; initialisation
	include		sfx_main.s	; channel manager
	include		sfx_calc.s	; calculate sample stream
	include		sfx_cls.s	; audio shutdown
	include		sfx_vbl.s	; audio timer routines
	include		sfx_data.s	; audio data & storage
	include		sfx_bug.s	; debugging routines
	endc

*-------------------------------------------------------*
*	Audio (midi player) modules			*
*-------------------------------------------------------*

	ifd		midi
	include		midi.s		; self-contained midi player
	endc

*-------------------------------------------------------*
*	Data tables & other pre-compiled modules	*
*-------------------------------------------------------*

	include		tables.s	; data tables & incbins

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

tga_header:		incbin	'data\tga.dat'

snap_name:		dc.b	'bmshot00.tga',0
			even

turb_ptr:		dc.l	r_turb

ascii_startup:		dc.b	27,'E',27,'f',13,10
			dc.b	' Doom Environment Simulator v'
			dc.b	'0'+((version/$100)&($F))
			dc.b	'.'
			dc.b	'0'+((version/$10)&($F))
			dc.b	'0'+((version)&($F))
			dc.b	'.alpha',13,10
			dc.b	' Release: Tuesday, 8th July 1997 ',13,10
			dc.b	13,10
			dc.b	'  * Sky y-position & y-scaling fixed.',13,10
			dc.b	0
			even

PressKey:		dc.b	10,13,10,13
			dc.b	"Controls:",10,13
			dc.b	" Cursors: movement    Alt: strafe",10,13
			dc.b	" Shift: run!          Ctrl: shoot (noisy !)",10,13
			dc.b	" Tab: map on/off",10,13
			dc.b	" +/-: screen size     F: full screen",10,13
			dc.b	" 1/2: up/down         3/4: hor/ver resolution",10,13
			dc.b	" 5: timing on/off     6: all-map on/off",10,13
			dc.b	" 7: turbulence on/off",10,13
			dc.b	" *: save screen shot(s)",10,13
			dc.b	10,13,"Press any key to start...",0
			even

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

accumulated_dx:		ds.l	1
accumulated_dy:		ds.l	1

px:			ds.l	1		; player-x
py:			ds.l	1		; player-y

pho:			ds.l	1		; player height offset (for flying)
pangle:			ds.l	1		; player direction
cospangle:		ds.l	1		; Cos[d]
sinpangle:		ds.l	1		; Sin[d]

right_speed:		ds.l	1
front_speed:		ds.l	1

snap_handle:		ds.l	1
snap_size:		ds.l	1
snap_pixels:		ds.l	1

program_quit:		ds.b	1		; exit flag

timer_on:			ds.b	1
	even

string_space:		ds.b	256		; general string space

r_turb:			ds.w	turbres*2

clock:			ds.l	1

super_on:		ds.l	1

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*
bss_end:
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Special system areas				*
*-------------------------------------------------------*

os_ssp_ptr:		ds.l	1

cli:			ds.l	1		; command line pointer

			ds.b	1024
usp_stack:		even

			ds.b	16384
ssp_stack:		even

*-------------------------------------------------------*
bss_all_end:		ds.b	8192
*-------------------------------------------------------*
