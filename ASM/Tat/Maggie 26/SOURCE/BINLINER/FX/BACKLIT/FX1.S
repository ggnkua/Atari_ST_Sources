;
;
; TEMPLATE.S
; code template for routines from the "binliner" demo
;
; this code is either included from the file BINMAIN.S or
; assembled as standalone
;
; change the "fx1_" using s'n'r to the name of the effect
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

fx1_codestart:
		dc.l	fx1_on_loading
		dc.l	fx1_on_session
		dc.l	fx1_on_sequence
		dc.l	fx1_do_frames
		dc.l	fx1_on_sequence_end
		dc.l	fx1_on_session_end
		dc.l	fx1_on_loading_end
		dc.l	fx1_testing
		dc.l	fx1_message_list

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
		dc.l	fx1_on_loading
		dc.l	fx1_on_session
		dc.l	fx1_on_sequence
		dc.l	fx1_do_frames
		dc.l	fx1_on_sequence_end
		dc.l	fx1_on_session_end
		dc.l	fx1_on_loading_end
		dc.l	fx1_testing
		dc.l	fx1_message_list
		endc			;{ifd binmain}
;------------------------------------------------------------------

;
; the main code may use any INCLUDES from the \system\ folder
; that should be well behaved and only assemble once
; "handle messages" is performed by the OS via fx1_message_list
; 

fx1_on_loading:
		rts

fx1_testing:
		rts

fx1_on_session:
		malloc	6+64*64*2
		move.l	d0,fx1_tex_addr
		loadfile '256\plasma.128',fx1_tex_addr

		malloc	2*192*100
		move.l	d0,fx1_backflare_addr
		loadfile 'dat\fx1_1.dat',fx1_backflare_addr
		rts

fx1_on_sequence:
		jsr	t3d_reset

		lea	fx1_camera,a6
		lea	fx1_cam_movement,a0
		jsr	cam_set_general
		jsr	cam_calc_general

		lea	fx1_scene,a0
		jsr	t3d_send_scene

		lea	fx1_drawlists,a0
		jsr	t3d_send_drawlists

		lea	fx1_worldlists,a0
		jsr	t3d_send_worldlists

		move.l	fx1_tex_addr,a0
		lea	fx1_palette,a1
		moveq	#0,d0
		jsr	t3d_send_texmap_palette

		add_vbl	#fx1_move_camera
		rts


fx1_do_frames:
		;clr.l	$ffff9800.w

		lea	scr_384x100tc,a0
		jsr	scr_set_resolution
		jsr	scr_clearscreens_three

		;move.l	#25000,Viewer_Size
		;move.w	#150,c_persp
		;bsr	t3d_send_clipping

		bsr	fx1_frames
		rts

fx1_on_sequence_end:
		sub_vbl	#fx1_move_camera
		rts

fx1_on_session_end:
		mfree	fx1_tex_addr
		mfree	fx1_backflare_addr
		rts
fx1_on_loading_end:
		rts

fx1_message_list:	
		dc.l	0

fx1_frames:
		jsr	fx1_create_frame
		test_if_done
		beq	fx1_frames
		rts



fx1_create_frame:
		move.w	fx1_next_frame,fx1_this_frame



; decide on the texmap to use
;
;
;
		lea	fx1_palette,a1
		move.w	fx1_this_frame,d0
		;asr.w	d0
		add.w	d0,d0
		sub.w	d0,a1

		move.l	fx1_tex_addr,a0
		moveq	#0,d0
		jsr	t3d_send_texmap_palette

		lea	fx1_camera,a6
		jsr	t3d_cam_2_view_general

		lea	fx1_objects,a0
		jsr	t3d_send_objects
		;jsr	cam_calc

		;move.l	#8000,Viewer_Distance
		;add.l	#20,Rotation_X
		;add.l	#76,Rotation_Y

		jsr	t3d_copy_lightrot
		jsr	t3d_send_viewpoint
		jsr	t3d_start_calculation

; first consider the background
; if no light is visible, draw the "dull glow"
; and make the texmap lighter

		jsr	fx1_draw_dull_back

		jsr	fx1_mark_points

		jsr	t3d_draw_screen_tc

; test for colour:
		jsr	fx1_test_points

;
; now draw the lensflare if applicable?
;
		jsr	scr_swap_screens_three
		jsr	scr_set_screen
		rts

;--------------------------------------------------------------
fx1_mark_points:
		move.l	logic,a0
		lea	fx1_point_list,a1
		moveq	#fx1_point_count-1,d0
.mark:		move.l	(a1)+,d1
		move.w	#-1,(a0,d1.l)
		addq.l	#2,a1			;skip the value bit
		dbf	d0,.mark
		rts

;--------------------------------------------------------------
fx1_test_points:
		move.l	logic,a0
		lea	fx1_point_list,a1
		moveq	#fx1_point_count-1,d0
		moveq	#0,d2
.mark:		move.l	(a1)+,d1
		move.w	(a1)+,d3
		move.w	(a0,d1.l),d1
		cmp.w	#-1,d1
		bne.s	.dontadd
		add.w	d3,d2
.dontadd:	dbf	d0,.mark
		move.w	d2,fx1_next_frame
		rts

;--------------------------------------------------------------
; the dull lens flare background
; "fx1_this_frame" tells us how "uncovered" the light is
; the more uncovered, the *brighter* the background

fx1_draw_dull_back:
		move.l	fx1_backflare_addr,a0
		lea	fx1_back_palette-16*2,a1
		move.w	fx1_this_frame,d0
		add.w	d0,a1
		add.w	d0,a1

		move.l	logic,a2
		move.w	#192*100/4-1,d0
.copy:
		movem.w	(a0)+,d1/d2/d3/d4
		move.l	(a1,d1.w*2),(a2)+
		move.l	(a1,d2.w*2),(a2)+
		move.l	(a1,d3.w*2),(a2)+
		move.l	(a1,d4.w*2),(a2)+
		dbf	d0,.copy
		rts

;--------------------------------------------------------------
fx1_move_camera:
		lea	fx1_camera,a6
		jsr	cam_calc_general
		rts


;--------------------------------------------------------------
			section data
;--------------------------------------------------------------
fx1_backcolour:		ds.l	1
fx1_this_frame:		ds.w	1	;0=no light, -1=light visible
fx1_next_frame:		ds.w	1	;0=no light, -1=light visible

fx1_point		MACRO
			dc.l	(50+(\1*3))*384*2+(96+(\2*3))*4
			dc.w	(\3)
			ENDM

fx1_point_count		equ	25

fx1_point_list:
			fx1_point	-2,-2,2
			fx1_point	-2,-1,2
			fx1_point	-2,+0,4
			fx1_point	-2,+1,2
			fx1_point	-2,+2,2

			fx1_point	-1,-2,2
			fx1_point	-1,-1,4
			fx1_point	-1,+0,8
			fx1_point	-1,+1,4
			fx1_point	-1,+2,2

			fx1_point	+0,-2,2
			fx1_point	+0,-1,8
			fx1_point	+0,+0,16
			fx1_point	+0,+1,8
			fx1_point	+0,+2,2

			fx1_point	+1,-2,2
			fx1_point	+1,-1,4
			fx1_point	+1,+0,8
			fx1_point	+1,+1,4
			fx1_point	+1,+2,2

			fx1_point	+2,-2,2
			fx1_point	+2,-1,2
			fx1_point	+2,+0,4
			fx1_point	+2,+1,2
			fx1_point	+2,+2,2


;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------
fx1_shape0	equ	0

fx1_objects:
		dc.l	8		;fx1_objectlistsize	;number of longwords

		initobj
		defobj	fx1_obj0,fx1_shape0,+0,-$0800,+0,0,0,0,0
fx1_objectlistsize	equ	(*-fx1_objects-4)/4

;--------------------------------------------------------------
fx1_drawlists:
		dc.l	1			;only one to send
		initdl
		defdl	fx1_list0,1,nosort
		dc.l	fx1_obj0

;--------------------------------------------------------------

fx1_worldlists:	dc.l	1
		dc.l	0	;	fx1_list0

;--------------------------------------------------------------
fx1_scene:
			;include e:\3d\foetus.ob3
			include e:\3d\sq_sph.ob3
			even

;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------
			ds.w	256
fx1_palette:
			incbin	d:\data\binliner\pal\backlit.tru
			;incbin	d:\data\_data\blob.tru

;fx1_backflare		incbin	e:\test\data\fx1_1.dat

			ds.w	256
fx1_back_palette:
			incbin	d:\data\binliner\pal\backlit.tru

;--------------------------------------------------------------
fx1_cam_movement:
		;	;  x      y     z     down    spin  bank
		dc.w	-$0000,-$0000,+$0000,-$0200,+$0000,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0160,+$0160,+$0000,-$0000
fx1_cam_restart_pos:
		dc.w	200
		dc.w	-$0800,-$0000,+$0000,+$0800,+$0600,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,-$0100,-$0200,-$0000,-$0000
		dc.w	200
		dc.w	-$0000,-$0800,+$0000,-$0c00,-$1000,-$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0040,+$0200,+$0000,+$0000
		dc.w	200
		dc.w	-$0000,-$0000,+$0800,-$0200,+$0c00,+$0000,+$1000
		dc.w	-$0000,-$0000,+$0000,+$0100,-$0100,-$0000,+$0000
		dc.w	-1
		dc.l	fx1_cam_restart_pos

		ds.w	100

;--------------------------------------------------------------
			section	bss
fx1_camera		camera_object

fx1_tex_addr		ds.l	1
fx1_backflare_addr	ds.l	1


			section	text
