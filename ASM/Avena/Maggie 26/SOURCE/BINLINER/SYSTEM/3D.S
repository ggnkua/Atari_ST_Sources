;
;
;
;
;
; 3D.S
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
;
;
;


start_world:
		bsr	send_viewpoint
		bsr	makematrixlight		;must be done first
		bsr	makematrixobject

		wait_transmit
		move.l	#"CAL",$ffffa204.w
		rts


draw_object:
		move.l	logic,a0
		bsr	handle_object_world
		rts


;--------------------------------------------------------------

reptval equ (384*2/13/4)+1

clearscreen_fast:
		move.l	logic,a6
		add.l	#(lines+object_height-1)/2*bytesperline,a6
		lea	(2*(pixels+object_width)/2)(a6),a6
		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a0
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5

		move.l	#$0001,d0
		movec	d0,cacr

		move.w	#object_height-1,d0
.wipe:		rept	reptval
		movem.l	d1-a5,-(a6)
		endr
		lea	-(bytesperline)+(13*4*reptval)(a6),a6
		dbf	d0,.wipe

		move.l	#$1919,d0
		movec	d0,cacr
		rts

;--------------------------------------------------------------
spin_object:
		jsr	cam_calc

		lea	cam_output_values,a0
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
		movem.l	rotation_x,d0/d1/d2
		movem.l	d0/d1/d2,lightrot_x
		rts

x_min		dc.w	-192
x_max		dc.w	190
y_min		dc.w	-50
y_max		dc.w	+50
c_persp		dc.w	25
shade_multiplier	dc.l	50
shade_add		dc.l	-$100000

send_clipping:
		lea	$ffffa204.w,a0
		 wait_transmit
		move.l	#"CLI",(a0)	
		lea	x_min(pc),a1
		move.w	#5-1,d0
.sendit:
		move.w	(a1)+,d1
		ext.l	d1
		 wait_transmit
		move.l	d1,(a0)	
		dbf	d0,.sendit

		 wait_transmit
		move.l	(a1)+,(a0)	
		 wait_transmit
		move.l	(a1)+,(a0)	
		rts

makematrixobject:
		movem.l	rotation_x,d0/d1/d2
		move.l	#"MAT",d7
		bra.s	domatrix
makematrixlight:
		movem.l	lightrot_x,d0/d1/d2
		move.l	#"LIG",d7
; expansion to allow fading using the unit_vector?

domatrix:
		and.l	#$1fff,d0
		and.l	#$1fff,d1
		and.l	#$1fff,d2
		lea	costable,a0
		lea	sinetable,a1
		jsr	wait_senddsp
		move.l	d7,$ffffa204.w
		moveq	#0,d7
		move.w	(a0,d0.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d0.w*2),d7
		bsr.s	sendinfo
		move.w	(a0,d1.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d1.w*2),d7
		bsr.s	sendinfo
		move.w	(a0,d2.w*2),d7
		bsr.s	sendinfo
		move.w	(a1,d2.w*2),d7
		bsr.s	sendinfo
		rts
sendinfo:
		ext.l	d7
		asl.l	#8,d7
		 wait_transmit
		move.l	d7,$ffffa204.w
		rts










;
;
;
;		true colour routines
;
;
;








;--------------------------------------------------------------
handle_object_world:
		add.l	#(pixels/2)*2+bytesperline*(lines/2),a0
		move.l	a0,screen_centre
		move.l	#$0009,d0
		movec	d0,cacr
handleloopfull:
		lea	$ffffa206.w,a1
		lea	$ffffa202.w,a2
		move.l	#bytesperline,d7
		move.l	screen_centre,a4
		moveq	#0,d0
		moveq	#0,d2
handleloop
		wait_transmit
		move.l	#"GET",$ffffa204.w
.wr2:
		wait_receive
		 move.w	(a1),d0
		 bmi done
		 jmp .polylist(pc,d0.w*4)
.polylist:
		bra.w	get_flat		;0
		bra.w	get_flat		;1
		bra.w	get_gouraud		;2
		bra.w	get_texmap		;3
		bra.w	get_texmap_offsets	;4
		bra.w	get_flare		;5
		bra.w	get_shademap_offsets	;6
;-----------------------------------------------------------
get_flat:
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
.pp2
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		   move.l d4,(a3)+
		  dbra	d3,.pp2
.next2		  add.l d7,a0
		 dbf	d1,.printpoly2
		bra	handleloop

get_gouraud:
		bra	handleloop

;-----------------------------------------------------------
get_texmap:
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
.dontdo		bra	handleloop

;-----------------------------------------------------------
get_shademap_offsets:
		lea	shademap_buffer,a2
		bra.s	get_offsets_general
get_texmap_offsets:
		lea	texmap_256,a2
get_offsets_general:
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
.dontdo		bra	handleloop

;-----------------------------------------------------------
get_flare:
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

		muls #BytesPerLine,d5
		add.l d4,d4
		add.l d4,d5
		add.l d5,a0
		 bsr draw_flare2
.no		bra.w	handleloopfull

done:
		move.l	#$1919,d0
		movec	d0,cacr
		rts
dontdo		illegal










;--------------------basic i/o routines------------------------
max_width=384

sendoneover
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
		cmp.w	#max_width,d0
		bne.s .sendy
		rts

;--------------------------------------------------------------
send_object:
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
send_texmap:
		jsr	wait_senddsp
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
wait_senddsp:
		btst	#1,$ffffa202.w
		beq	wait_senddsp
		rts
;--------------------------------------------------------------
wait_receivedsp:
		btst	#0,$ffffa202.w
		beq	wait_receivedsp
		rts

;--------------------------------------------------------------
send_objects:
		lea	$ffffa204.w,a6
		lea	objectlist,a0
		wait_transmit
		move.l	#"OBS",(a6)		;command word
		wait_transmit
		clr.l	(a6)			;offset
		wait_transmit
		move.l	#objectlistsize,(a6)	;number of word
		move.w	#objectlistsize-1,d0
.send		wait_transmit
		move.l	(a0)+,(a6)
		dbf	d0,.send
		rts

;--------------------------------------------------------------
send_drawlists:
		lea	$ffffa204.w,a6
		lea	drawlists,a0
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
		 move.l	(a0)+,(a6)		;sortflag
		 subq.l	#1,d1
.send_object:
		  wait_transmit
		  move.l (a0)+,(a6)		;index of object
		  dbf	d1,.send_object
		dbf	d0,.send_list
		rts

;--------------------------------------------------------------
send_world:
		lea	$ffffa204.w,a6
		lea	worldlist,a0
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
;
;
;
;	motion blur section
;
;
;
;

;--------------------------------------------------------------
calc_whiteout:
		move.w	#3-1,d7
.loop1:
		move.l	a1,a2			;save orig destination
		move.w	#64*64-1,d0
		lea	colour_table,a3
		moveq	#0,d1
.sendpoints:
		move.w	(a0)+,d1
		move.w	(a3,d1.l*2),d2
		move.w	d2,(a1)+
		dbf	d0,.sendpoints
		move.l	a2,a0
		dbf	d7,.loop1
		rts		


;--------------------------------------------------------------
make_texture:
		illegal
		;move.l	pal_address,a0

		 wait_transmit
		move.l	#"TEX",$ffffa204.w
		 wait_transmit
		move.l	#64*64,$ffffa204.w
		lea	texmap_buffer,a1
		lea	$ffffa206.w,a2
		move.w	#64*64-1,d0
		moveq	#0,d1
		 wait_transmit
.sendpoints:
		move.w	(a1)+,d1
		move.w	(a0,d1.l*2),(a2)	;don't do wait
		dbf	d0,.sendpoints
		rts		

tex_calc_envmap:
		lea	texmap_buffer,a0
		move.w	#-32,d7
.row
		move.w	#-32,d6
.col
		move.w	d6,d0
		muls	d0,d0
		move.w	d7,d1
		muls	d1,d1
		add.l	d1,d0
		asr.l	#3,d0
		neg.w	d0
		add.w	#127,d0
		bge.s	.ok
		moveq	#0,d0
.ok
		move.w	d0,(a0)+
		addq.w	#1,d6
		cmp.w	#32,d6
		bne.s	.col
		addq.w	#1,d7
		cmp.w	#32,d7
		bne.s	.row
		rts

;--------------------------------------------------------------
calc_colour_table:
		lea	colour_table,a0
		moveq	#0,d0
.loop:
		move.w	d0,d1
		move.w	d1,d2
		move.w	d2,d3

; now separate into parts:
		and.w	#%1111100000000000,d1
		and.w	#%0000011111100000,d2
		and.w	#%0000000000011111,d3
		asl.w	d3			;0-32

		lsr.w	#5,d2

		lsr.w	#2,d1
		lsr.w	#8,d1

		add.w	d2,d1
		add.w	d3,d1
		move.w	d1,(a0)+

		addq.w	#1,d0
		bne.s	.loop	
		rts

;--------------------------------------------------------------
calc_fade_table:
		lea	colour_table,a0
		MOVEQ	#32-1,D7		;red count
		LEA	Feedback_Table_Red,A1
.CalcLoop1:
		MOVE.W	(A1)+,D1
		MOVEQ	#32-1,D6		;green count
		LEA	Feedback_Table_Green,A2
.CalcLoop2:
		MOVE.W	(A2)+,D2
		OR.W	D1,D2
		MOVEQ	#64-1,D5		;blue count * 2...green bottom not used!
		LEA	Feedback_Table_Blue,A3
.CalcLoop3:
		MOVE.W	(A3)+,D3
		OR.W	D2,D3
		MOVE.W	D3,(A0)+
		DBF	D5,.CalcLoop3
		DBF	D6,.CalcLoop2
		DBF	D7,.CalcLoop1
		RTS

;--------------------------------------------------------------
calc_shademap_buffer:
		pea	(a0)
		bsr	calc_fade_table
		move.l	(a7)+,a0

; get the first tmap and copy into part 1
		lea	shademap_buffer,a1
		move.w	#64*64-1,d0
.copy		move.w	(a0)+,(a1)+
		dbf	d0,.copy

		lea	shademap_buffer,a0
		lea	64*64*2(a0),a1
		moveq	#15-1,d0
.loop1:
		move.w	d0,-(a7)
		bsr	.fadedown
		move.w	(a7)+,d0
		lea	64*64*2(a0),a0
		lea	64*64*2(a1),a1
		dbf	d0,.loop1
		rts

.fadedown:
		movem.l	a0/a1,-(a7)
		move.w	#64*64-1,d0
		moveq	#0,d1
		lea	colour_table,a2
.loop2:		move.w	(a0)+,d1
		move.w	(a2,d1.l*2),(a1)+
		dbf	d0,.loop2
		movem.l	(a7)+,a0/a1
		rts

;--------------------------------------------------------------
Feed	MACRO
		DC.W	\1*00,\1*00	;,\1*00		;,\1*01;,\1*00
		DC.W	\1*01,\1*02,\1*03,\1*04
		DC.W	\1*05,\1*06,\1*07,\1*08
		DC.W	\1*09,\1*10,\1*11,\1*12
		DC.W	\1*13,\1*14,\1*15,\1*16
		DC.W	\1*17,\1*18,\1*19,\1*20
		DC.W	\1*21,\1*22,\1*23,\1*24
		DC.W	\1*25,\1*26,\1*27,\1*28
		DC.W	\1*29,\1*30
	ENDM

FeedUp	MACRO
		DC.W	\1*02,\1*03,\1*04
		DC.W	\1*05,\1*06,\1*07,\1*08
		DC.W	\1*09,\1*10,\1*11,\1*12
		DC.W	\1*13,\1*14,\1*15,\1*16
		DC.W	\1*17,\1*18,\1*19,\1*20
		DC.W	\1*21,\1*22,\1*23,\1*24
		DC.W	\1*25,\1*26,\1*27,\1*28
		DC.W	\1*29,\1*30,\1*31,\1*31,\1*31
	ENDM

Feedback_Table_Red:
	Feed	$0800
Feedback_Table_Green:
	Feed	$0040
Feedback_Table_Blue:
	Feed	$0001
	Feed	$0001

;--------------------------------------------------------------
draw_flare:
		move.l	logic,a0
		add.l	#BytesPerLine*50+Pixels/2*2,a0
draw_flare2
		lea.l	-BytesPerLine(a0),a1
		lea.l	-BytesPerLine(a0),a2
		lea.l	(a0),a3

		lea	flare,a4
		lea	greys,a5
		lea	colour_table,a6
		moveq	#0,d3
		move.w	(a4)+,d0
		subq.w	#1,d0
.loop1:
		pea	(a0)
		pea	(a1)
		pea	(a2)
		pea	(a3)

		move.w	(a4)+,d1		;counter
		subq.w	#2,d1
		bmi.s	.nope
.loop2:
		move.w	(a4)+,d2		;value

		move.w	(a0),d3
		move.w	(a6,d3.l*2),d3
		add.w	d2,d3
		move.l	(a5,d3.w*2),(a0)+

		move.w	(a1),d3
		move.w	(a6,d3.l*2),d3
		add.w	d2,d3
		move.l	(a5,d3.w*2),(a1)+

		move.w	-4(a2),d3
		move.w	(a6,d3.l*2),d3
		add.w	d2,d3
		move.l	(a5,d3.w*2),-(a2)

		move.w	-4(a3),d3
		move.w	(a6,d3.l*2),d3
		add.w	d2,d3
		move.l	(a5,d3.w*2),-(a3)

		dbf	d1,.loop2
.nope:
		move.l	(a7)+,a3
		move.l	(a7)+,a2
		move.l	(a7)+,a1
		move.l	(a7)+,a0
		lea	BytesPerLine(a0),a0
		lea	-BytesPerLine(a1),a1
		lea	-BytesPerLine(a2),a2
		lea	BytesPerLine(a3),a3
		dbf	d0,.loop1

		rts

flare:		include	d:\data\flare.dat

greys:
o		set	0
		rept	32
		dcb.w	3,o
		dcb.w	3,o+$20
o		set	o+$841   ;fix
		endr
		dcb.w	256,-1

;--------------------------------------------------------------
 
		include	include\cam.s

;--------------------------------------------------------------

send_viewpoint:
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

		;include	d:\source\sl\autopal\autopal.s

		;define_autopal	texture_palette
		;define_autopal	back_palette

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
dsp_routine_object:
			incbin	d:\dsp\asm\gen_obj.dsp
			even


;--------------------------------------------------------------
			cnop	0,4

			section	bss
scan_min		ds.l	1
scan_max		ds.l	1
screen_centre		ds.l	1
shademap_buffer		ds.w	64*64*16
colour_table		ds.w	65536
			section	text

;--------------------------------------------------------------
