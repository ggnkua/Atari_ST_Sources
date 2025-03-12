;
;
;
;
;
; T3D.S
; new general 3d routines
;
; most of these routines need to be renamed!
;
;
;
;
;
;
;
;
;
;
;
;
;
; LIST OF CALLS SUPPORTED:
;
; t3d_init		kicks in the dsp routine
; t3d_reinit		kicks out the dsp routine
; t3d_reset		reinstalls the "factory presets"
;
; t3d_start_calculation	sends viewpoint + tells DSP to calc and send
;
; t3d_cam_2_view	converts splinecam output to viewpoint
;
; t3d_send_clipping	sends clipping info
;
;
;
;
;

		opt	inconce			;ignore mult includes
		include	system\shared.s
		include	system\screens.s
		include	system\cam.s
		include	system\new_os3.s


; -------------------------------------------------------------------------
; 3D system macros:

NOSORT		equ	0
SORT		equ	1


; initobject ()
initobj	macro
objectcounter	set	0
		endm

; defobj (name,shapex,y,z,misc)

		rsreset
objshape	rs.l	1
objx		rs.l	1
objy		rs.l	1
objz		rs.l	1
objr1		rs.l	1
objr2		rs.l	1
objr3		rs.l	1
objmisc		rs.l	1
objsize		rs.b	1

defobj	macro
\1		set	objectcounter
objectcounter	set	objectcounter+1
		dc.l	\2			;shape
		dc.l	\3,\4,\5		;x,y,z position
		dc.l	\6,\7,\8		;rotation
		dc.l	\9			;misc
		endm



; initdrawlist ()
initdl	macro
drawlistcounter	set	0
		endm

; defdl (name,length,sortflag)

defdl	macro
\1		set	drawlistcounter
drawlistcounter	set	drawlistcounter+1
		dc.l	\2,\3			;length, sortflag
		endm



; load in 3d prog,
; send 1/over table
;--------------------------------------------------------------
t3d_init:
		init_dsp
		init_dsp_routine t3d_dsp_routine,$210.w
		jsr	t3d_sendoneover
		rts
;--------------------------------------------------------------
t3d_deinit:
		wait_transmit
		move.l	#"RTS",$ffffa204.w
		rts

;--------------------------------------------------------------
t3d_reset:
		;reinstall factory presets
		rts

;--------------------------------------------------------------
t3d_start_calculation:
		bsr	t3d_send_viewpoint
		bsr	t3d_makematrixlight		;must be done first
		bsr	t3d_makematrixobject

		 wait_transmit
		move.l	#"CAL",$ffffa204.w
		rts


;--------------------------------------------------------------
; general routine, converts output from the camera routine
; to that of the 3d system
;

t3d_cam_2_view:
		lea	cam_general,a6
t3d_cam_2_view_general:
		lea	cam_output_values(a6),a0
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_x
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_y
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,viewer_z
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_x
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_y
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,rotation_z
		move.w	(a0)+,d0
		ext.l	d0
		asl.l	#2,d0
		move.l	d0,viewer_distance

t3d_copy_lightrot:
		movem.l	rotation_x,d0/d1/d2
		movem.l	d0/d1/d2,lightrot_x
		rts

;--------------------------------------------------------------
x_min			dc.w	-192
x_max			dc.w	190
y_min			dc.w	-50
y_max			dc.w	+50
c_persp			dc.w	25

shade_multiplier	dc.l	50
shade_add		dc.l	-$100000

;--------------------------------------------------------------
t3d_send_clipping:
		lea	$ffffa204.w,a0
		 wait_transmit
		move.l	#"CLI",(a0)	
		lea	x_min(pc),a1
		moveq	#5-1,d0
.sendit:
		move.w	(a1)+,d1
		ext.l	d1
		 wait_transmit
		move.l	d1,(a0)	
		dbf	d0,.sendit

		 wait_transmit			;now do the shading values
		move.l	(a1)+,(a0)	
		 wait_transmit
		move.l	(a1)+,(a0)	
		rts

t3d_makematrixobject:
		movem.l	rotation_x,d0/d1/d2
		move.l	#"MAT",d7
		bra.s	t3d_domatrix
t3d_makematrixlight:
		movem.l	lightrot_x,d0/d1/d2
		move.l	#"LIG",d7
; expansion to allow fading using the unit_vector?

t3d_domatrix:
		and.l	#$1fff,d0
		and.l	#$1fff,d1
		and.l	#$1fff,d2
		lea	costable,a0
		lea	sinetable,a1
		 wait_transmit
		move.l	d7,$ffffa204.w
		moveq	#0,d7
		move.w	(a0,d0.w*2),d7
		bsr.s	.sendinfo
		move.w	(a1,d0.w*2),d7
		bsr.s	.sendinfo
		move.w	(a0,d1.w*2),d7
		bsr.s	.sendinfo
		move.w	(a1,d1.w*2),d7
		bsr.s	.sendinfo
		move.w	(a0,d2.w*2),d7
		bsr.s	.sendinfo
		move.w	(a1,d2.w*2),d7
		bsr.s	.sendinfo
		rts
.sendinfo:
		ext.l	d7
		asl.l	#8,d7
		 wait_transmit
		move.l	d7,$ffffa204.w
		rts










;
;
;
;		true colour drawing routines
;
;
;
;



;--------------------------------------------------------------
t3d_draw_screen_tc:
		move.l	logic,a0
		move.w	pixelsperline,d0
		asr.w	d0
		add.w	d0,d0
		move.w	bytesperline,d1
		move.w	lines,d2
		asr	d2
		mulu	d2,d1
		add.w	d0,a0
		add.l	d1,a0

		;add.l	#(pixels/2)*2+bytesperline*(lines/2),a0
		move.l	a0,screen_centre

		move.l	#$0009,d0
		movec	d0,cacr
t3d_handleloopfull:
		lea	$ffffa206.w,a1
		lea	$ffffa202.w,a2
		move.w	bytesperline,d7
		ext.l	d7
		move.l	screen_centre,a4
		moveq	#0,d0
		moveq	#0,d2
t3d_handleloop
		 wait_transmit
		move.l	#"GET",$ffffa204.w
.wr2:
		wait_receive
		 move.w	(a1),d0
		 bmi done
		 jmp .polylist(pc,d0.w*4)
.polylist:
		bra.w	t3d_get_flat		;0
		bra.w	t3d_get_flat		;1
		bra.w	t3d_get_gouraud		;2
		bra.w	t3d_get_texmap		;3
		bra.w	t3d_get_texmap_offsets	;4
		bra.w	t3d_get_flare		;5
		bra.w	t3d_get_shademap_offsets	;6
;-----------------------------------------------------------
t3d_get_flat:
		 wait_receive
		 move.w	(a1),d6			;get top_height
		 muls.w	d7,d6
		 lea	(a4,d6.l),a0

		 wait_receive
		 move.w	(a1),d1
		 subq.w	#1,d1			;poly height
		 blt	dontdo

		 wait_receive
		 move.w	(a1),d5			;d4 - colour
		 moveq #0,d4
		 ;move.w	d5,d4
		 ;swap	d4
		 ;move.w	d5,d4
.printpoly2:
		  move.w (a1),d2
		  lea	(a0,d2.w*2),a3
		  moveq	#0,d5
		  move.w (a1),d3
		  asr.w	#3,d3
		  ;bcc.s	.next3
		  ;move.w d4,(a3)+
.next3	  	;subq.w #1,d3
		  bmi.s	.next2
.pp2:		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		  dbra	d3,.pp2
.next2		  add.l d7,a0
		 dbf	d1,.printpoly2
		bra	t3d_handleloop

t3d_get_gouraud:
		bra	t3d_handleloop

;-----------------------------------------------------------
t3d_get_texmap:
		 wait_receive
		 move.w	(a1),d6			;get top_height
		 muls.w	d7,d6
		 lea	(a4,d6.l),a0
		 move.w	(a1),d1
		 subq.w	#1,d1
		 bmi.s	.dontdo
.printpoly:
		  wait_receive
		  move.w (a1),d2
		  lea (a0,d2.w*2),a3	
		  move.w (a1),d3
		  subq.w #1,d3
		  bmi.s	.next
		  wait_receive
.pp	   	move.w (a1),(a3)+
		  dbra	d3,.pp
.next	  	add.l d7,a0
		 dbf	d1,.printpoly
.dontdo		bra	t3d_handleloop

;-----------------------------------------------------------
t3d_get_shademap_offsets:
		;lea	shademap_buffer,a2
		move.l	t3d_shademap_table,a2

		bra.s	t3d_get_offsets_general
t3d_get_texmap_offsets:
		;lea	texmap_256,a2
		move.l	t3d_shademap_table,a2


t3d_get_offsets_general:
		 wait_receive
		 move.w	(a1),d6			;get top_height
		 muls.w	d7,d6
		 lea	(a4,d6.l),a0
		 move.w	(a1),d1			;get height
		 subq.w	#1,d1
		 bmi.s	.dontdo
.printpoly:
		  wait_receive
		  move.w (a1),d2
		  lea (a0,d2.w*4),a3	
		  wait_receive
		  move.w (a1),d3
		  subq.w #1,d3
		  bmi.s	.next
		  moveq #0,d0
		  wait_receive
.pp	   	   move.w (a1),d0
		   move.l (a2,d0.l*2),(a3)+
		   ;move.w (a2,d0.l*2),d0
		   ;move.w d0,(a3)+
		   ;move.w d0,(a3)+
		  dbra	d3,.pp

.next	  	add.l d7,a0
		dbf	d1,.printpoly
.dontdo		bra	t3d_handleloop

;-----------------------------------------------------------
t3d_get_flare:
		 wait_receive
		 move.w	(a1),d4			;get x
		 wait_receive
		 move.w	(a1),d5			;get y
		 wait_receive
		 move.w	(a1),d6			;get z
		 move.l	a4,a0

		cmp.w #-192+13,d4
		blt.s	.no
		cmp.w #-50+13,d5
		blt.s	.no
		cmp.w #+192-13,d4
		bgt.s	.no
		cmp.w #+50-13,d5
		bgt.s	.no
		ext.l	d4

		muls BytesPerLine,d5
		add.l d4,d4
		add.l d4,d5
		add.l d5,a0
		 ;bsr t3d_draw_flare2
.no		bra.w	t3d_handleloopfull

done:
		move.l	#$1919,d0
		movec	d0,cacr
		rts
dontdo		illegal










;--------------------basic i/o routines------------------------
t3d_max_width=384

t3d_sendoneover
		lea	$ffffa204.w,a6
		 wait_transmit
		moveq	#0,d0
.sendy:
		move.l	#$7fffff,d1
		tst.w	d0
		beq	.skipdiv
		divu.l	d0,d1
.skipdiv
		 wait_transmit
		move.l	d1,(a6)
		addq.l	#1,d0
		cmp.w	#t3d_max_width,d0
		bne.s	.sendy
		rts

;--------------------------------------------------------------
t3d_send_scene:
		 wait_transmit
		move.l	#"OBJ",$ffffa204.w

		move.l	(a0)+,d0
		 wait_transmit
		move.l	d0,$ffffa204.w
		subq.l	#1,d0
.sendpoints:
		 wait_transmit		; not time-critical!
		move.l	(a0)+,$ffffa204.w
		dbf	d0,.sendpoints
		rts

;--------------------------------------------------------------
; a0 = texture
; d0 = "slot"
t3d_send_texmap:
		 wait_transmit
		move.l	#"TEX",$ffffa204.w
		move.l	#64*64,d0
		 wait_transmit
		move.l	d0,$ffffa204.w
		subq.l	#1,d0
.sendpoints:
		 wait_transmit		; not time-critical!
		move.w	(a0)+,$ffffa206.w
		dbf	d0,.sendpoints
		rts

;--------------------------------------------------------------
; a0 = texture
; a1 = palette
; d0 = "slot"

t3d_send_texmap_palette:
		 wait_transmit
		move.l	#"TEX",$ffffa204.w
		move.l	#64*64,d0
		 wait_transmit
		move.l	d0,$ffffa204.w
		subq.l	#1,d0
.sendpoints:
		move.w	(a0)+,d0
		 wait_transmit
		move.w	(a1,d0.w*2),$ffffa206.w
		dbf	d0,.sendpoints
		rts



;--------------------------------------------------------------
; a0 must include the length of the list in longwords!!
;--------------------------------------------------------------
t3d_send_objects:
		lea	$ffffa204.w,a6
		wait_transmit
		move.l	#"OBS",(a6)		;command word
		wait_transmit
		clr.l	(a6)			;offset?

		move.l	(a0)+,d0
		wait_transmit
		move.l	d0,(a6)			;number of lists words?

		subq.l	#1,d0
.send		wait_transmit
		move.l	(a0)+,(a6)
		dbf	d0,.send
		rts

;--------------------------------------------------------------
; a0 = address of list
t3d_send_drawlists:
		lea	$ffffa204.w,a6
		wait_transmit
		move.l	#"DLS",(a6)		;command word
		move.l	(a0)+,d0		;number of lists
		wait_transmit
		move.l	d0,(a6)

		subq.l	#1,d0
.send_list:	 move.l	(a0)+,d1		;number of items in list
		 wait_transmit
		 move.l	d1,(a6)

		 wait_transmit
		 move.l	(a0)+,(a6)		;send sortflag
		 subq.l	#1,d1
.send_object:
		  wait_transmit
		  move.l (a0)+,(a6)		;index of object
		  dbf	d1,.send_object
		dbf	d0,.send_list
		rts

;--------------------------------------------------------------
t3d_send_worldlists:
		lea	$ffffa204.w,a6
		wait_transmit
		move.l	#"WOR",(a6)		;command word
		move.l	(a0)+,d0		;number of lists
		wait_transmit
		move.l	d0,(a6)

		subq.l	#1,d0
.send_list:	 move.l	(a0)+,d1		;number of items in list
		 wait_transmit
		 move.l	d1,(a6)
		dbf	d0,.send_list
		rts


;--------------------------------------------------------------
 
t3d_send_viewpoint:
		LEA	$FFFFA204.W,A1
		 wait_transmit
		MOVE.L	#"VIE",(A1)
		MOVEQ	#3-1,D0			;for view pos
		LEA	viewer_x,A2
.loop:
		MOVE.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop

		LEA	camera_x,A2
		MOVEQ	#3-1,D0			;for view pos
.loop2:
		MOVE.L	(A2)+,D1
		wait_transmit
		MOVE.L	D1,(A1)
		DBF	D0,.loop2
		 wait_transmit
		MOVE.L	Viewer_Size,(A1)
		RTS

;--------------------------------------------------------------
			section data
;--------------------------------------------------------------

rotation_x:		dc.l	$0000
rotation_y:		dc.l	$0000
rotation_z:		dc.l	$0000

lightrot_x:		ds.l	1
lightrot_y:		ds.l	1
lightrot_z:		ds.l	1

viewer_x:		ds.l	1
viewer_y:		ds.l	1
viewer_z:		ds.l	1

camera_x:		dc.l	0
camera_y:		dc.l	0
camera_z:		
viewer_distance:	dc.l	$4000

viewer_size:		dc.l	25000

;--------------------------------------------------------------
;	miscellaneous data
;--------------------------------------------------------------
			cnop	0,4
sinetable:		incbin	d:\data\trailsin.dat
costable:		equ	sinetable+2048*2
			even

;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------
t3d_dsp_routine:
			incbin	d:\dsp\asm\gen_obj.dsp
			even

;--------------------------------------------------------------
			section	bss
screen_centre		ds.l	1
t3d_shademap_table	ds.l	1		;address of shademaps
						;that are installed
			section	text

;--------------------------------------------------------------
