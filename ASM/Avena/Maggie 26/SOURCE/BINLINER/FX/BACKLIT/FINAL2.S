
;
; FOET.S
;
;
;
;


		format	0-,1-,2-		;output style
		section	text

; 'binmain' will only have been set on pass 1 if assembling from
; BINMAIN.S

		ifd	binmain
;------------------------------------------------------------------
; BINMAIN SECTION
;
;
; here goes a list of routines for init etc.
; they will be called automatically by the main OS
;------------------------------------------------------------------

final0_codestart:
		dc.l	final0_on_loading
		dc.l	final0_on_session
		dc.l	final0_on_sequence
		dc.l	final0_do_frames
		dc.l	final0_on_sequence_end
		dc.l	final0_on_session_end
		dc.l	final0_on_loading_end
		dc.l	final0_testing
		dc.l	final0_message_list

; this is the list of message handling routines
; the names of the messages must be installed in "shared.s"
; data is contained in a0


		else			;{ifd binmain}


;------------------------------------------------------------------
; STANDALONE SECTION
;
;
;
;------------------------------------------------------------------

;------------------------------------------------------------------
; Include the startup/shutdown code here
; this will run stuff automatically and provide
; equivalents of the binmain macros, screen spaces
; etc

		list
; ******* ASSEMBLING AS STANDALONE
		nolist

		opt	xdebug
		output	e:\alone.prg
		include	startup.s
		include	includes.s

codestart:
		dc.l	final0_on_loading
		dc.l	final0_on_session
		dc.l	final0_on_sequence
		dc.l	final0_do_frames
		dc.l	final0_on_sequence_end
		dc.l	final0_on_session_end
		dc.l	final0_on_loading_end
		dc.l	final0_testing
		dc.l	final0_message_list
		endc			;{ifd binmain}
;------------------------------------------------------------------

;
; the main code may use any INCLUDES from the \system\ folder
; that should be well behaved and only assemble once
; "handle messages" is performed by the OS via final0_message_list
; 

final0_on_loading:
		rts

final0_testing:
		rts

final0_on_session:
		;malloc	6+64*64*2
		;move.l	d0,final0_tex_addr
		;loadfile 'gfx\foetus.god',final0_tex_addr
		rts

final0_on_sequence:
		jsr	t3d_reset

		lea	final0_scene,a0
		jsr	t3d_send_scene

		lea	final0_drawlists,a0
		jsr	t3d_send_drawlists

		lea	final0_worldlists,a0
		jsr	t3d_send_worldlists

		;move.l	final0_tex_addr,a0
		;addq.l	#6,a0
		lea	final0_texmap,a0
		jsr	t3d_send_texmap
		rts


final0_do_frames:
		clr.l	$ffff9800.w

		lea	scr_384x100tc,a0
		jsr	scr_set_resolution
		jsr	scr_clearscreens_three

		move.l	#15000,Viewer_Size
		move.w	#15,c_persp
		bsr	t3d_send_clipping
		move.l	#+$2000,Viewer_Y

		bsr	final0_frames
		rts

final0_on_sequence_end:
		rts
final0_on_session_end:
		;mfree	final0_tex_addr
		rts
final0_on_loading_end:
		rts

final0_message_list:	
		dc.l	0

final0_frames:
		jsr	final0_create_frame
		test_if_done
		beq	final0_frames
		rts

		include	system\keys.s

final0_create_frame:
		lea	final0_objects,a0
		jsr	t3d_send_objects

		move.w	mouse_x,d0
		asl.w	#4,d0
		ext.l	d0
		move.l	d0,Rotation_Y

		move.w	mouse_y,d0
		asl.w	#4,d0
		ext.l	d0
		move.l	d0,Rotation_X

		jsr	handle_keyboard

		jsr	t3d_copy_lightrot
		jsr	t3d_send_viewpoint
		jsr	t3d_start_calculation

		move.l	logic,a0
		moveq	#0,d0
		jsr	scr_clearscreen_fast

		jsr	t3d_draw_screen_tc

		jsr	scr_swap_screens_three
		jsr	scr_set_screen
		rts

move_sine:	movem.l	(a0),d0/d1/d2		;pos/spd
		add.l	d1,d0
		and.l	#$1fff,d0
		move.l	d0,(a0)
		move.w	(sinetable.l,d0.w*2),d0
		muls.w	d2,d0
		swap	d0
		ext.l	d0
		rts
;--------------------------------------------------------------

;--------------------------------------------------------------
			section data
;--------------------------------------------------------------
final0_ysine		dc.l	0,6,$2000	;pos, spd, size
final0_xsine		dc.l	0,46,$300	;pos, spd, size

;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------
final0_shape0	equ	0

final0_objects:
		dc.l	16		;final0_objectlistsize	;number of longwords

		initobj
		defobj	final0_obj0,final0_shape0,+0,-$0800,+$000,0,$00,$0,0
		defobj	final0_obj1,final0_shape0,+0,-$0800,-$000,0,$80,$0,0
final0_objectlistsize	equ	(*-final0_objects-4)/4

;--------------------------------------------------------------
final0_drawlists:
		dc.l	1			;only one to send
		initdl
		defdl	final0_list0,1,nosort
		;dc.l	final0_obj0
		;dc.l	final0_obj1

;--------------------------------------------------------------

final0_worldlists:	dc.l	1
			dc.l	0		;final0_list0

;--------------------------------------------------------------
final0_scene:
			include e:\3d\final.ob3
			even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------
			ds.w	256

;--------------------------------------------------------------
		ds.w	100

final0_texmap:		equ	*+6
			incbin	d:\data\_data\_gfx\ntmap5.god

;--------------------------------------------------------------
			section	bss

final0_tex_addr		ds.l	1

			section	text
