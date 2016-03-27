;
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

foet_codestart:
		dc.l	foet_on_loading
		dc.l	foet_on_session
		dc.l	foet_on_sequence
		dc.l	foet_do_frames
		dc.l	foet_on_sequence_end
		dc.l	foet_on_session_end
		dc.l	foet_on_loading_end
		dc.l	foet_testing
		dc.l	foet_message_list

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
		dc.l	foet_on_loading
		dc.l	foet_on_session
		dc.l	foet_on_sequence
		dc.l	foet_do_frames
		dc.l	foet_on_sequence_end
		dc.l	foet_on_session_end
		dc.l	foet_on_loading_end
		dc.l	foet_testing
		dc.l	foet_message_list
		endc			;{ifd binmain}
;------------------------------------------------------------------

;
; the main code may use any INCLUDES from the \system\ folder
; that should be well behaved and only assemble once
; "handle messages" is performed by the OS via foet_message_list
; 

foet_on_loading:
		rts

foet_testing:
		rts

foet_on_session:
		malloc	6+64*64*2
		move.l	d0,foet_tex_addr
		loadfile 'gfx\foetus.god',foet_tex_addr
		rts

foet_on_sequence:
		jsr	t3d_reset

		lea	foet_cam_movement,a0
		lea	foet_cam_restart_pos,a1
		jsr	cam_set
		jsr	cam_calc

		lea	foet_scene,a0
		jsr	t3d_send_scene

		lea	foet_drawlists,a0
		jsr	t3d_send_drawlists

		lea	foet_worldlists,a0
		jsr	t3d_send_worldlists

		move.l	foet_tex_addr,a0
		addq.l	#6,a0
		jsr	t3d_send_texmap
		rts


foet_do_frames:
		clr.l	$ffff9800.w

		lea	scr_384x100tc,a0
		jsr	scr_set_resolution
		jsr	scr_clearscreens_three

		;move.l	#25000,Viewer_Size
		;move.w	#150,c_persp
		;bsr	t3d_send_clipping

		bsr	foet_frames
		rts

foet_on_sequence_end:
		rts
foet_on_session_end:
		mfree	foet_tex_addr
		rts
foet_on_loading_end:
		rts

foet_message_list:	
		dc.l	0

foet_frames:
		jsr	foet_create_frame
		test_if_done
		beq	foet_frames
		rts



foet_create_frame:
		lea	foet_objects,a0
		jsr	t3d_send_objects
		;jsr	cam_calc
		;jsr	t3d_cam_2_view

		move.l	#8000,Viewer_Distance

		lea	foet_ysine,a0
		bsr	move_sine
		move.l	d0,Rotation_Y

		lea	foet_xsine,a0
		bsr	move_sine
		move.l	d0,Rotation_x

		;add.l	#20,Rotation_X
		;add.l	#$10,Rotation_Y

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
foet_ysine		dc.l	0,6,$2000	;pos, spd, size
foet_xsine		dc.l	0,46,$300	;pos, spd, size

;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------
foet_shape0	equ	0

foet_objects:
		dc.l	8		;foet_objectlistsize	;number of longwords

		initobj
		defobj	foet_obj0,foet_shape0,+0,-$0800,+0,0,0,0,0
foet_objectlistsize	equ	(*-foet_objects-4)/4

;--------------------------------------------------------------
foet_drawlists:
		dc.l	1			;only one to send
		initdl
		defdl	foet_list0,1,nosort
		dc.l	foet_obj0

;--------------------------------------------------------------

foet_worldlists:	dc.l	1
		dc.l	0	;	foet_list0

;--------------------------------------------------------------
foet_scene:
			include e:\3d\foetus.ob3
			;include e:\3d\sq_sph.ob3
			even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------
			ds.w	256

;--------------------------------------------------------------
foet_cam_movement:
		;	;  x      y     z     down    spin  bank
		dc.w	-$0000,-$0000,+$0000,-$0200,+$0000,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0160,+$0160,+$0000,-$0000
foet_cam_restart_pos:
		dc.w	80
		dc.w	-$0800,-$0000,+$0000,+$0800,+$0600,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,-$0100,-$0200,-$0000,-$0000
		dc.w	80
		dc.w	-$0000,-$0800,+$0000,-$0c00,-$1000,-$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0040,+$0200,+$0000,+$0000
		dc.w	80
		dc.w	-$0000,-$0000,+$0800,-$0200,+$0c00,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0100,-$0100,-$0000,+$0000
		dc.w	-1

		ds.w	100

;--------------------------------------------------------------
			section	bss

foet_tex_addr		ds.l	1


			section	text
