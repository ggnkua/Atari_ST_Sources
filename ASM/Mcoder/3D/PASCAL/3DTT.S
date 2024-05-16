	opt	l2
	opt	P=68030
	opt	o+
	XREF	Objects

	TEXT
	 ;#[ Equates:
STRUCT_SIZE	EQU	22+8

VANISH	EQU	1
NO_MOVE	EQU	0

BACKGRND	EQU	0
CPU_TIME	EQU	1
CLEAR_SCREEN	EQU	1
FRAME_COUNT	EQU	1
CLIPPING	EQU	1

TRAME_COLORS	EQU	1
VBL_COUNT	EQU	$464
REZ	EQU	0
NB_LINES	EQU	200
SCREEN_WIDTH	EQU	160
MAX_VERTICES	EQU	8
FRAMES_FREQ	EQU	60
MAX_POINTS	EQU	100
CLIPSIZE	EQU	4096
MUS_NB	EQU	1
OBSERV	EQU	1

NB_SCREEN	EQU	6
	 ;#] Equates:
	 ;#[ Macros:
SWITCH_SCREEN	MACRO
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#$557,$ffff8240.w
.Skip_cpu:
	ENDC
.Vs\@:	tst	VBL_COUNT.w
	beq.s	.Vs\@
	clr	VBL_COUNT.w
	lea	Screen_list,a0
	movem.l	(a0),d0-d5
	move.l	d0,d6
	movem.l	d1-d6,(a0)
	movep	4*(NB_SCREEN-2)(a0),d5
	move.l	d5,$ffff8200.w
	addq	#1,Frame_counter
	ENDM
	 ;#] Macros:
	 ;#[ Initializations:
Start:	move.l	(4,a7),a1
	move.l	(12,a1),d0
	add.l	(20,a1),d0
	add.l	(28,a1),d0
	add.l	#$100,d0

	move.l	d0,-(a7)
	pea	(a1)
	clr	-(a7)
	move	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	pea	Mystack
	move	#$20,-(a7)
	trap	#1
	move.l	d0,Sys_stack

	IFNE	BACKGRND
	lea	Background-64,a0
	lea	(32064,a0),a1
	move	#333,d0
.Convert:	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a7)

	movem.l	-48(a1),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-48(a0)

	movem.l	(a7)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a1)
	dbf	d0,.Convert
	ENDC

	movec	VBR,d0
	move.l	d0,Old_VBR
	movec	CACR,d0
	move.l	d0,Old_CACR
	moveq	#0,d0
	movec	d0,VBR
.MC68030:	move	#%1000100000001,d0
	movec	d0,CACR
	jsr	Init_color_trame
	jsr	Init_polygone
	lea	Objects,a0
	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,a1
	move.l	a1,Current_curve_pointer
	move.l	a1,Start_curve
	move.l	(a0)+,End_curve
	IFNE	NO_MOVE
	addq	#8,a0
	ELSEIF
	move.l	(a0)+,Vrotx & Vroty
	move.l	(a0)+,Vrotz & Vdist
	ENDC
	move.l	(a0)+,Rotx & Roty
	move.l	(a0)+,Rotz & Dist
	move	(a0),Cptwaiting
	 ;#] Initializations:
	 ;#[ Main:
		;#[ Save Contex:
Set_screens:	clr	-(a7)
	move.l	#(NB_SCREEN-1)*32000+$ff,-(a7)
	move	#$44,-(a7)
	trap	#1
	addq	#8,a7
	move.l	d0,Mxalloc_space
	bpl.s	.ST_ram_available
	clr	-(a7)
	trap	#1
.ST_ram_available:
	move.l	$ffff8200.w,d1
	move.l	d1,Sys_screen
	lsl	#8,d1
	and.l	#$00ffff00,d1
	lea	Screen_list,a0
	move.l	d1,(a0)+		;Current_screen
	add.l	#$ff,d0
	clr.b	d0
	REPT	NB_SCREEN-2
	move.l	d0,(a0)+
	add.l	#32000,d0
	ENDR
	move.l	d0,(a0)
	move.l	$14.w,Sys_zero
	move.l	#Zero_divide,$14.w
	move.l	$118.w,Sys_ikbd
	move.l	#Ikbd_irr,$118.w

	move.b	$ffff8262.w,Sys_rez
.Synchronize:	move.b	$ffff8209.w,d0
	moveq	#$7f,d1
.Wait_sync:	cmp.b	$ffff8209.w,d0
	dbne	d1,.Wait_sync
	bne.s	.Synchronize
	move.b	#REZ,$ffff8262.w
	clr.b	$ffff820d.w

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,Sys_palette
	movem.l	Palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	;move.b	#$12,$fffffc02.w
	move.l	$fffffa06.w,Sys_mfp
	clr.b	$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.l	$70.w,Sys_vbl
	move.l	#New_vbl,$70.w
		;#] Save Contex:
Main:	move.l	usp,a0
	pea	(a0)

Repeat:
	IFNE	CLEAR_SCREEN
Set_cls0:	jsr	MC68030_cls
	ENDC
	jsr	Calcproj
	move.l	Current_anim,a3	;lire la prochaine animation
	move.l	(a3)+,d0		;adresse de l'objet
	bne.s	Cont_anim		;c'est la derniŠre image
	move.l	(a3),a3		;Return image boucle
	move.l	(a3)+,d0

Cont_anim:	move.l	a3,Current_anim
	move.l	d0,a2
	lea	Project,a1
	jsr	Calcobj
	move.l	(a2),a2
	jsr	Traceobj
	SWITCH_SCREEN
		;#[ Keyboard Manager:
	move.l	(Current_object.w,pc),a0
	move	Dist,d0
	cmp2	(Zoom_range.w,pc),d0
	bcc	.Next_object
	move.b	(Current_key.w,pc),d0
	ble	Repeat
	IFNE	CPU_TIME
	cmp.b	#$10,d0
	bne.s	.Pause
	clr.b	Current_key
	lea	Objects,a0
	bra	.Set_object
.Pause:	cmp.b	#$39,d0
	bne.s	.PF1
.Wait_release:	cmp.b	#$39,Current_key
	beq.s	.Wait_release
.Wait_state:	cmp.b	#$39,Current_key
	bne.s	.Wait_state
	clr.b	Current_key
	bra	Repeat
.PF1:	cmp.b	#$3b,d0
	bne.s	.Not_PF1
	not.b	Cpu_time_flag
	clr.b	Current_key
	bra	Repeat
.Not_PF1:
	ENDC
	move	(STRUCT_SIZE-2.w,a0),Cptwaiting
.Plus:	cmp.b	#$4e,d0
	bne.s	.Minus
	subq	#4,Dist
	bra	Repeat
.Minus:	cmp.b	#$4a,d0
	bne.s	.Backspace
	addq	#4,Dist
	bra	Repeat
.Backspace:	cmp.b	#$E,d0
	bne.s	.Next_obj
	move	#SCREEN_WIDTH,Obsx
	move	#NB_LINES/2,Obsy
	bra.s	.Set_object
.Next_obj:	cmp.b	#$64,d0
	bne.s	.Previous_obj
	clr.b	Current_key
	bra.s	.Next_object
.Previous_obj:	cmp.b	#$63,d0
	bne.s	.Left_arrow
	clr.b	Current_key
	cmp.l	#Objects,a0
	beq	Repeat
	lea	(-STRUCT_SIZE,a0),a0
	bra.s	.Set_object
.Next_object:	lea	(STRUCT_SIZE,a0),a0
	tst.l	(a0)
	bne.s	.Set_object
	lea	Objects,a0
.Set_object:	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,a1
	tst.b	Mouse_flag
	bne.s	.Mouse_active
	move.l	a1,Current_curve_pointer
	move.l	a1,Start_curve
	move.l	(a0),End_curve
.Mouse_active:	addq	#4,a0
	IFNE	NO_MOVE
.Bck_spc:	cmp.b	#$E,d0
	bne.s	.No_move
	move.l	(a0)+,Vrotx	;& Vroty
	move.l	(a0)+,Vrotz	;& Vdist
	bra.s	.Set_rot
.No_move:	addq	#8,a0
	clr.l	Vrotx
	clr.l	Vrotz
	ELSEIF
	move.l	(a0)+,Vrotx	;& Vroty
	move.l	(a0)+,Vrotz	;& Vdist
	ENDC
.Set_rot:	move.l	(a0)+,Rotx	;& Roty
	move.l	(a0)+,Rotz	;& Dist
	move	(a0),Cptwaiting
	bra	Repeat
.Left_arrow:	cmp.b	#$4B,d0
	bne.s	.Right_arrow
	subq	#1,Vrotz
	bra	Repeat
.Right_arrow:	cmp.b	#$4D,d0
	bne.s	.Up_arrow
	addq	#1,Vrotz
	bra	Repeat
.Up_arrow:	cmp.b	#$48,d0
	bne.s	.Down_arrow
	addq	#1,Vroty
	bra	Repeat
.Down_arrow:	cmp.b	#$50,d0
	bne.s	.Insert
	subq	#1,Vroty
	bra	Repeat
.Insert:	cmp.b	#$52,d0
	bne.s	.Clr_home
	subq	#1,Vrotx
	bra	Repeat
.Clr_home:	cmp.b	#$47,d0
	bne.s	.Move_1
	addq	#1,Vrotx
	bra	Repeat

.Move_1:	cmp.b	#$6d,d0
	bne.s	.Move_2
	addq.b	#OBSERV,Obsx
	subq.b	#OBSERV,Obsy
	bra	Repeat
.Move_2:	cmp.b	#$6e,d0
	bne.s	.Move_3
	subq.b	#OBSERV,Obsy
	bra	Repeat
.Move_3:	cmp.b	#$6f,d0
	bne.s	.Move_4
	subq.b	#OBSERV,Obsx
	subq.b	#OBSERV,Obsy
	bra	Repeat
.Move_4:	cmp.b	#$6a,d0
	bne.s	.Move_5
	addq.b	#OBSERV,Obsx
	bra	Repeat
.Move_5:	cmp.b	#$6b,d0
	bne.s	.Move_6
	move	#SCREEN_WIDTH,Obsx
	move	#NB_LINES/2,Obsy
	bra	Repeat
.Move_6:	cmp.b	#$6c,d0
	bne.s	.Move_7
	subq.b	#OBSERV,Obsx
	bra	Repeat
.Move_7:	cmp.b	#$67,d0
	bne.s	.Move_8
	addq.b	#OBSERV,Obsx
	addq.b	#OBSERV,Obsy
	bra	Repeat
.Move_8:	cmp.b	#$68,d0
	bne.s	.Move_9
	addq.b	#OBSERV,Obsy
	bra	Repeat
.Move_9:	cmp.b	#$69,d0
	bne.s	.Cheat
	subq.b	#OBSERV,Obsx
	addq.b	#OBSERV,Obsy
	bra	Repeat
.Cheat:	move.l	(Latch_keys.w,pc),d0
	cmp.l	#$381d2a11,d0
	beq.s	Quit
	rol.l	#8,d0
	move.l	d0,Latch_keys
	clr.b	Current_key
	bra	Repeat
Latch_keys:	ds.b	3
Current_key:	ds.b	1
Quit:	move.l	(a7)+,a0
	move.l	a0,usp
		;#] Keyboard Manager:
		;#[ Restore Contex:
Restore:
	move.l	Sys_vbl,$70.w
	move.l	Sys_ikbd,$118.w
	move.l	Sys_zero,$14.w
	move.b	#8,$fffffc02.w
	move.b	Sys_mfp+1,$fffffa07.w
	move.b	Sys_mfp+3,$fffffa09.w

Sound_off:	lea	$ffff8800.w,a0
	moveq	#$a,d0
.Loop:	move.b	d0,(a0)
	sf	(2.w,a0)
	dbf	d0,.Loop
	move.b	#7,(a0)
	st	(2.w,a0)

.Synchronize:	move.b	$ffff8209.w,d0
	moveq	#$7f,d1
.Wait_sync:	cmp.b	$ffff8209.w,d0
	dbne	d1,.Wait_sync
	bne.s	.Synchronize

	move.b	Sys_rez,$ffff8262.w
	movem.l	Sys_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	Sys_screen,$ffff8200.w

	move.l	Old_CACR,d0
	movec	d0,CACR
	move.l	Old_VBR,d0
	movec	d0,VBR

	moveq	#0,d0
	move	#7999,d1
	move.l	$44e.w,a0
.Cls:	move.l	d0,(a0)+
	dbf	d1,.Cls	

	move.l	Sys_stack,-(a7)	
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	(Mxalloc_space.w,pc),-(a7)
	move	#$49,-(a7)
	trap	#1
	addq	#6,a7
	clr	-(a7)
	trap	#1
		;#] Restore Contex:
		;#[ Main local DATA:
Zoom_range:		dc.w	400,30
Old_CACR:		ds.l	1
Old_VBR:		ds.l	1
Mxalloc_space:		ds.l	1
Screen_list:		ds.l	NB_SCREEN-1
Work_screen:		ds.l	1
		;#] Main local DATA:
	 ;#] Main:
	 ;#[ Ikbd Manager:
Ikbd_irr:	movem.l	d0/a0,-(a7)
.Start_ikbd_manager:
	moveq	#0,d0
	move.b	$fffffc00.w,d0
	bpl	.End_of_ikbd_rout
	btst	#0,d0
	beq	.No_ikbd_event
	move.b	$fffffc02.w,d0
	tst.b	Mouse_offset
	beq.s	.Ikbd_event

.Mouse_event:	cmpi.b	#1,Mouse_offset
	bne.s	.Not_first_mouse_parameter
	move.l	Current_object,a0
	move	(STRUCT_SIZE-2.w,a0),Cptwaiting
	addq.b	#1,Mouse_offset
	ext	d0
	add	d0,Rotz
	bra	.End_of_ikbd_rout
.Not_first_mouse_parameter:
	clr.b	Mouse_offset
	ext	d0
	add	d0,Rotx
	bra.s	.End_of_ikbd_rout

.Ikbd_event:	move.b	d0,Current_key

.Release:	cmpi	#$fb,d0
	bgt.s	.End_of_ikbd_rout
	cmpi	#$f8,d0
	blt.s	.End_of_ikbd_rout
	clr.l	Vrotx
	clr	Vrotz
	clr	Roty
	move.l	#Null_curve,Current_curve_pointer
	move.l	#Null_curve,Start_curve
	move.l	#Null_curve+6,End_curve
	move.b	#1,Mouse_offset
	and	#3,d0
	sne	Mouse_flag
	subq	#1,d0
	bne.s	.Left_button
	move.b	#$4A,Current_key
	bra.s	.End_of_ikbd_rout
.Left_button:	subq	#1,d0
	bne.s	.End_of_ikbd_rout
	move.b	#$4E,Current_key
	bra.s	.End_of_ikbd_rout

.No_ikbd_event:
	btst	#5,d0
	beq.s	.End_of_ikbd_rout
	tst.b	$fffffc02.w
.End_of_ikbd_rout:
	btst	#4,$fffffa01.w
	beq	.Start_ikbd_manager
	movem.l	(a7)+,d0/a0
	bclr	#6,$fffffa11.w
	rte
Mouse_offset:	ds.b	1
	even
	 ;#] Ikbd Manager:
	 ;#[ Zero Divide handling:
Zero_divide:	rte
	 ;#] Zero Divide handling:
	 ;#[ VBL Manager:
New_vbl:	addq	#1,VBL_COUNT.w

	clr	$ffff8240.w

	movem.l	d0-d7/a0-a3/a6,-(a7)
	btst	#0,VBL_COUNT+1.w
	beq.s	.Same_color
	move	$ffff825e.w,d0
	addq	#1,d0
	moveq	#$f,d1
	and	d0,d1
	moveq	#-$10,d0
	and	$ffff825e.w,d0
	add	d1,d0
	move	d0,$ffff825e.w
.Same_color:
	IFNE	FRAME_COUNT
	subq	#1,Vbl_counter
	bgt.s	.Not_all_frames
	move	#FRAMES_FREQ,Vbl_counter
	move	Frame_counter,Nb_frames
	clr	Frame_counter
.Not_all_frames:
	move.l	(Work_screen.w,pc),a0
	move	Nb_frames,d0
	tst.b	Cpu_time_flag
	beq	Skip_display
	jsr	(Zero_to_99+2.w,pc,d0*4)

	lea	(SCREEN_WIDTH*10,a0),a0
	move	Vrotx,d0
	and	#$fc,d0
	jsr	(Zero_to_99+2.w,pc,d0)

	lea	(SCREEN_WIDTH*10,a0),a0
	move	Vroty,d0
	and	#$fc,d0
	jsr	(Zero_to_99+2.w,pc,d0)

	lea	(SCREEN_WIDTH*10,a0),a0
	move	Vrotz,d0
	and	#$fc,d0
	jsr	(Zero_to_99+2.w,pc,d0)

	bra	Skip_display
Zero_to_99:	incbin	Zeroa99.bin
	rts
Skip_display:
	ENDC

	IFNE	VANISH
	tst.b	Cptwaiting
	bgt.s	.Noincdist
;	move	(Vdist.w,pc),d0
;	add	d0,Dist
	addq	#8,Dist
	bra.s	.End_vbl
.Noincdist:	subq	#1,Cptwaiting
	ENDC

.End_vbl:	movem.l	(a7)+,d0-d7/a0-a3/a6
	rte
		;#[ VBL DATA:
Cpu_time_flag:		ds.b	1
		even
Frame_counter:		ds.w	1
Vbl_counter:		ds.w	1
Cptwaiting:		ds.w	1
Nb_frames:		ds.w	1
		;#] VBL DATA:
	 ;#] VBL Manager:
	 ;#[ Draw Object:
		;#[ Vertices handling:
Hide_facette:	lea	16(a2),a2
Traceobj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#$700,$ffff8240.w
.Skip_cpu:
	ENDC
	move	(a2)+,d0
	bmi	Ffacettes
Rfacette2:	lea	(Project,pc),a1

	move.l	(a1,d0),d0	;Xa/Ya
	move	(a2)+,d1
	move.l	(a1,d1),d1	;Xb/Yb
	move	(a2)+,d2
	move.l	(a1,d2),d2	;Xc/Yc

	move	d1,d5
	sub	d0,d5	;Xb-Xa
	move	d2,d6
	sub	d1,d6	;Xc-Xb

	swap	d0
	swap	d1
	swap	d2

	move	d0,d3
	sub	d1,d3	;Ya-Yb
	move	d2,d4
	sub	d1,d4	;Yc-Yb

	move	d5,d7
	eor	d4,d7
	bmi.s	.F1inf
.F1sup:	move	d6,d7	;determinant
	eor	d3,d7
	bmi.s	.Pcalcul
	bra.s	.Show
.F1inf:	move	d6,d7
	eor	d3,d7
	bmi.s	Hide_facette
.Pcalcul:	MULS	d4,d5
	MULS	d3,d6
	add.l	d5,d6
	bmi.s	Hide_facette

.Show:	lea	(Segments,pc),a4
	move.l	a4,a6
	movem.l	d0/d1/d2,(a4)
	lea	(12,a4),a4

	moveq	#3,d6
	move.l	a2,a3
	REPT	4
	move	(a3)+,d0
	bmi.s	.Frpoint
	move.l	(a1,d0),d1	;26
	swap	d1
	move.l	d1,(a4)+
	addq	#1,d6
	ENDR

	move	(a3)+,d0
	bmi.s	.Frpoint
	move.l	(a1,d0),d1
	swap	d1
	move.l	d1,(a4)
	addq	#1,d6

.Frpoint:	lea	(10,a2),a2
	move	(a2)+,d7	;Get color
	pea	(a2)
	jsr	Polygone
	move.l	(a7)+,a2
	move.l	(a2)+,d0	;Null pointer?
	beq.s	No_child_object
	bsr.s	Draw_child_object
No_child_object:
	move	(a2)+,d0	;Last?
	bpl	Rfacette2
Ffacettes:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	clr	$ffff8240.w
.Skip_cpu:
	ENDC
	rts
		;#] Vertices handling:
		;#[ Child vertices:
Draw_child_object:
	pea	(a2)
	lea	(-4*MAX_POINTS,a7),a7
	move.l	d0,a2

	move.l	a7,a1
	move.l	Previous_curve_pointer,Current_curve_pointer
	jsr	Calcobj
	move.l	(a2),a2
	move	(a2)+,d0
	bmi	.End_child_object

.Child_object:	lea	(Segments,pc),a4
	move.l	a4,a6

	move.l	(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	REPT	2
	move	(a2)+,d0
	move.l	(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	ENDR

	moveq	#3,d6
	move.l	a2,a3
	REPT	MAX_VERTICES-3
	move	(a3)+,d0
	bmi.s	.Last_vertex
	move.l	(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	addq	#1,d6
	ENDR

.Last_vertex:	lea	(10,a2),a2
	move	(a2)+,d7
	pea	(a2)
	jsr	Polygone
	move.l	(a7)+,a2
	move.l	(a2)+,d0
	beq.s	.End_child_object
	bsr	Draw_child_object
.End_child_object:
	move	(a2)+,d0
	bpl	.Child_object
	lea	4*MAX_POINTS(a7),a7
	move.l	(a7)+,a2
	rts
		;#] Child vertices:
		;#[ Anti-Vertices:
Antifacette:	rts
		;#] Anti-Vertices:
		;#[ 14 MULS Matrix:
Calcproj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#7,$ffff8240.w
.Skip_cpu:
	ENDC

NXTANG	MACRO
	move	(\1.w,pc),d0	;rot
	add	(\2.w,pc),d0
	and	#$3ff,d0
	move	d0,\2
	;add	d0,d0
	;add	d0,d0
	movem	(a0,d0*4),\3
	ENDM

; sx=sin/cos angle x,sy=sin/cos angle y,sz=sin/cos angle z
; l14=angle rot x,l16=angle rot y,l3c=angle rot z
; Rotx,Roty,Rotz=angles courants


sx	EQUR	d2
cx	EQUR	d3
sy	EQUR	d4
cy	EQUR	d5
sz	EQUR	d6
cz	EQUR	d7


;
; changement d'angle de rotation
;

	lea	(Sincos,pc),a0
	NXTANG	Vrotx,Rotx,sx/cx	;sx
	NXTANG	Vroty,Roty,sy/cy	;sy
	NXTANG	Vrotz,Rotz,sz/cz	;sz
;
; calcule la matrice de projection
;
	lea	(Matrix,pc),a0

	move	cy,d0
	MULS	cz,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+

	move	sy,(a0)+

	move	cy,d0
	MULS	sz,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a0)+

	move	sx,d1
	MULS	sz,d1
	move	cx,d0
	MULS	sy,d0
	add.l	d0,d0
	swap	d0
	MULS	cz,d0
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+

	move	cx,d0
	MULS	cy,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$10

	move	sx,d1
	MULS	cz,d1
	move	cx,d0
	MULS	sy,d0
	add.l	d0,d0
	swap	d0
	MULS	sz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$14

	move	cx,d1
	MULS	sz,d1
	move	sx,d0
	MULS	sy,d0
	add.l	d0,d0
	swap	d0
	MULS	cz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$18

	move	sx,d0
	MULS	cy,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a0)+	;$1c

	move	cx,d1
	MULS	cz,d1
	move	sx,d0
	MULS	sy,d0
	add.l	d0,d0
	swap	d0
	MULS	sz,d0
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+

	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu2
	clr	$ffff8240.w
.Skip_cpu2:
	ENDC
	rts
		;#] 14 MULS Matrix:
		;#[ MULS Rotate:
Calcobj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#$70,$ffff8240.w
.Skip_cpu:
	ENDC

	lea	(Matrix,pc),a6
	move	(a2)+,d5

; occupes :	d0/d1/d2/d3/d4/d6/d7
;	a1/a2/a4/a6
; libres :	d5
;	a0/a3/a5 translation x,y,z

	move.l	(Current_curve_pointer.w,pc),a4
	move.l	a4,Previous_curve_pointer
	move	(Obsx.w,pc),d4
	ext.l	d4
	lsl.l	#3,d4
	move.l	d4,a0
	move	(Obsy.w,pc),a3
	move	(Obsz.w,pc),a5
	sub	(Dist.w,pc),a5
	add	(a4)+,a0
	add	(a4)+,a3
	add	(a4)+,a5
	cmp.l	(End_curve.w,pc),a4
	bcs.s	.Cont_curve
	move.l	(Start_curve.w,pc),a4
.Cont_curve:	move.l	a4,Current_curve_pointer

	moveq	#-8,d4
Rotate:	move.l	a6,a4
	movem	(a2)+,d1/d2/d3

	move	d1,d6
	MULS	(a4)+,d6	;x
	move	d2,d7
	MULS	(a4)+,d7
	add.l	d7,d6
	move	d3,d7
	MULS	(a4)+,d7
	add.l	d7,d6

	move	d1,d7
	MULS	(a4)+,d7	;y
	move	d2,d0
	MULS	(a4)+,d0
	add.l	d0,d7
	move	d3,d0
	MULS	(a4)+,d0
	add.l	d0,d7

	MULS	(a4)+,d1	;z
	MULS	(a4)+,d2
	add.l	d2,d1
	MULS	(a4)+,d3
	add.l	d3,d1
	swap	d1

	add	a5,d1
	asr.l	#5,d6
	asr.l	#8,d7
	add.l	a0,d6
	add.l	a3,d7

	DIVS	d1,d6
	DIVS	d1,d7

	and	d4,d6
	add	#NB_LINES/2,d7

	move	d7,(a1)+
	move	d6,(a1)+
	dbf	d5,Rotate

	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu2
	clr	$ffff8240.w
.Skip_cpu2:
	ENDC
	rts
		;#] MULS Rotate:
		;#[ Compute line:
;------------- d‚finition des registres -------------------------

Min_y	EQUR	d6	;r‚serv‚s dans tous le calcul
Max_y	EQUR	d7
Ptrtable	EQUR	a0	;pointeur table des Min_x-Max_x
Screen	EQUR	a1	;adresse ecran

;------------- registres pour calcul lignes ---------------------

Xa	EQUR	d0	;extremit‚s de la droite
Ya	EQUR	d1
Xb	EQUR	d2
Yb	EQUR	d3

Ptrsegment	EQUR	a6	;pointeur sur segment
Copptrsegment	EQUR	a0	;copie pointeur sur segment

Jmpline	EQUR	a3	;adresse routine de droite
Return	EQUR	a1	;adresse de retour droite

Ptry	EQUR	a2	;pointeur tabley
Dx	EQUR	d4
Regdata	EQUR	d5

Jmp	EQUR	a5	;adresse debut du saut
			;pour calcul des points


;-------------- calcul et CLIPPING d'une ligne verticale ---------------
	IFNE	0
		;#[ Fast line:
	CNOP	4,0
	REPT	NB_LINES
	move.l	Xa,(Ptry)+	;mise en place 2 nouveaux points
	ENDR
Returnvert:	jmp	(Return)	;ligne verticale invisible
Vertline:	cmp	#NB_LINES,Ya	;CLIPPING
	bcs.s	.Ya_sup_0
	bge.s	Returnvert
	moveq	#0,Ya
.Ya_sup_0:	cmp	#NB_LINES,Yb
	bcs.s	.Yb_inf_max
	blt.s	Returnvert
	move	#NB_LINES-1,Yb
.Yb_inf_max:	cmp	Max_y,Yb	;tester maximum
	ble.s	.Not_max
	move	Yb,Max_y
.Not_max:	cmp	Min_y,Ya	;tester minimum
	bge.s	.Not_min
	move	Ya,Min_y
.Not_min:	sub	Ya,Yb	;Yb=Dy
	add	Ya,Ya
	add	Ya,Ptry	;debut table
	move	Xa,Xb
	swap	Xa
	move	Xb,Xa
	lsr	Yb
	bcc.s	.Even
	move	Xa,(Ptry)+
.Even:	neg	Yb
	jmp	(Returnvert-2+2.w,pc,Yb*2)

Calcreturn:	;fin du calcul des points
	jmp	(Return)

;Lastx:	dc.w	0
;-------------- d‚but calcul des points d'une ligne -----------------

Calcline:	lea	(Tableymax,pc),Ptry
	cmp	Ya,Yb	;c'est un ligne montante ?
	beq.s	Calcreturn	;ligne horizontale -> fin

	bge.s	.Yb_sup_Ya

	exg	Xa,Xb	;‚change les points
	exg	Ya,Yb
	lea	(2*NB_LINES,Ptry),Ptry ;c'est une ligne montante

.Yb_sup_Ya:	;move	Xb,Lastx
	sub	Xa,Xb	;Dx
	beq.s	Vertline	;c'est une ligne verticale
	move	Yb,Regdata	;pr‚pare calcul du Dy
	sub	Ya,Regdata	;Dy
	ext.l	Xb	;calcul de la pente
	asl.l	#4,Xb	;Dx*16 (et *8)
	DIVS	Regdata,Xb	;divise par Dy
	ext.l	Xb	;extention du r‚sultat
	cmp	#NB_LINES,Ya	;CLIPPING haut
	bcs.s	.Ya_sup_0
	bge.s	Calcreturn	;ligne invisible
	MULS	Xb,Ya	;CLIPPING
	asr.l	#4,Ya	;divise par 16
	sub	Ya,Xa	;addition … Xa
	moveq	#0,Ya	;Ya=0
	move	Yb,Regdata	;nombre de ligne=Yb
.Ya_sup_0:	cmp	#NB_LINES,Yb
	bcs.s	.Yb_inf_max
	blt.s	Calcreturn
	move	#NB_LINES-1,Yb ;moins de lignes
	move	Yb,Regdata
	sub	Ya,Regdata	;calcul Dy
.Yb_inf_max:

;------------ mise a jour des maximums et minimum ----------
	cmp	Max_y,Yb	;tester maximum
	ble.s	.Not_max
	move	Yb,Max_y

.Not_max:	cmp	Min_y,Ya	;tester minimum
	bge.s	.Not_min
	move	Ya,Min_y

.Not_min	add	Ya,Ya	 ;adresse tableau lignes
	add	Ya,Ptry

	neg	Regdata

	swap	Xb
	swap	Xa
	asr.l	#4,Xb

	move	Xb,Xa
	swap	Xa
	swap	Xb
	beq.s	.Intenger_line	;coef de pente entier

	addq	#4,Xa
	jmp	(.Float_line+2.w,pc,Regdata*4);+2 for GenST

.Intenger_line:
	jmp	(.Int_line+2.w,pc,Regdata*4)	;+2 for GenST
		;#] Fast line:
	ELSEIF
		;#[ Fine line:
	CNOP	4,0
	REPT	NB_LINES
	move.l	Xa,(Ptry)+	;mise en place nouveau points
	ENDR
Vert_line:
Returnvert:	jmp	(Return)

Vertline:	cmp	#NB_LINES,Ya
	bcs.s	.Ya_sup_0
	bge.s	Returnvert
	moveq	#0,Ya
.Ya_sup_0:	cmp	#NB_LINES,Yb
	bcs.s	.Yb_inf_max
	blt.s	Returnvert
	move	#NB_LINES-1,Yb
.Yb_inf_max:	cmp	Min_y,Ya		;tester minimum
	bge.s	.Not_min
	move	Ya,Min_y
.Not_min:	cmp	Max_y,Yb		;tester maximum
	ble.s	.Not_max
	move	Yb,Max_y
.Not_max:	sub	Ya,Yb
	add	Ya,Ya
	add	Ya,Ptry
	move	Xa,Xb
	swap	Xa
	move	Xb,Xa
	lsr	Yb
	bcc.s	.Even
	move	Xa,(Ptry)+
.Even:	neg	Yb
	jmp	(Vert_line-2+2.w,pc,Yb*2)
CalcReturn:	jmp	(Return)
				;fin du calcul des points

;-------------- d‚but calcul d'une ligne -------------------------
Calcline:	lea	(Tableymax,pc),Ptry

	cmp	Ya,Yb
	beq.s	CalcReturn		;ligne horizontale
	bge.s	.Yb_sup_Ya
	exg	Xa,Xb		;echange les points
	exg	Ya,Yb
	lea	(NB_LINES*2,Ptry),Ptry	;c'est une ligne montante

.Yb_sup_Ya:	sub	Xa,Xb		;dx
	beq.s	Vertline
	move	Yb,Regdata
	sub	Ya,Regdata		;dy
	move	Xb,Dx
	ext.l	Xb		;calcul de la pente
	asl.l	#8-2,Xb		;dx*256

	divs	Regdata,Xb		;divise par dy
	bvc.s	.No_overflow
	asr.l	#6,Xb
	divs	Regdata,Xb
	swap	Xb
	clr	Xb
	bra.s	.Skipex

.No_overflow:	ext.l	Xb

	asl.l	#8,Xb		;recuperation virgule 1/256eme
	asl.l	#2,Xb
.Skipex:	cmp	#NB_LINES,Ya
	bcs.s	.Ya_sup_0
	bge.s	CalcReturn
	MULS	Dx,Ya
	divs	Regdata,Ya
	sub	Ya,Xa
	moveq	#0,Ya
	move	Yb,Regdata
.Ya_sup_0:	cmp	#NB_LINES,Yb
	bcs.s	.Yb_inf_max
	blt.s	CalcReturn
	move	#NB_LINES-1,Yb
	move	Yb,Regdata
	sub	Ya,Regdata	;dy
.Yb_inf_max:
;------------ mise a jour des maximums et minimum ----------

	cmp	Min_y,Ya		;tester minimum
	bcc.s	.Not_min
	move	Ya,Min_y
.Not_min:	cmp	Max_y,Yb		;tester maximum

	bls.s	.Not_max
	move	Yb,Max_y
.Not_max:	add	Ya,Ya		;adresse tableau lignes
	add	Ya,Ptry
	neg	Regdata

	swap	Xa
	move	Xb,Xa
	swap	Xa	;poids fort = virgule*4
	swap	Xb	;poids faible = partie entiere*4
	beq.s	.Intenger_line
	addq	#2,Xa	;x+1/2
	jmp	(.Float_line+2.w,pc,Regdata*4)	;+2 for GenST

.Intenger_line:
	jmp	(.Int_line+2.w,pc,Regdata*4)	;+2 for GenST
		;#] Fine line:
	ENDC
		;#[ Line Towers:
	CNOP	4,0
.Float_tower:	REPT	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	addx.l	Xb,Xa	;ajout pente
	ENDR
.Float_line:	move	Xa,(Ptry)	;stocke dernier points
	jmp	(Return)	;fin calcul

	CNOP	4,0
.Int_tower:	REPT	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	add	Xb,Xa	;calcul avec coef entier
	ENDR
.Int_line:
Ajmpline:	move	Xa,(Ptry)	;plot dernier point
	jmp	(Return)	;fin de calcul
		;#] Line Towers:

Reg1	EQUR	d0
Reg2	EQUR	d1
Reg3	EQUR	d2
X1	EQUR	d3
Left_offset	EQUR	d4
X0	EQUR	d5
Right_offset	EQUR	d6

Reg4	EQUR	a2
Ptrtable2	EQUR	a2

Reg5	EQUR	a3
Reg6	EQUR	a4

REPLINE	MACRO
	lea	(.\@,pc),Return
	movem	(Ptrsegment),Xa/Ya/Xb/Yb	;lecture des points
	addq	#4,Ptrsegment		;passe droite suivante
	jmp	(Jmp)
	nop
	nop
.\@:
	ENDM

Polygone:	move	Min_y,Xa

	swap	Max_y	;mise … l'ecart du nombre de
			;points et couleur

	clr	Max_y	;Max_y=0
	move	#NB_LINES,Min_y	;Min_y=y maximum

	move.l	Ptrsegment,Copptrsegment
	lea	(Calcline,pc),Jmp	;adresse du calcul de droite
	lea	(Ajmpline,pc),Jmpline
	add	Xa,Xa
	neg	Xa
	jmp	(.End_tower+16+2.w,pc,Xa*8)	;+2 for GenST
	CNOP	4,0
	REPT	MAX_VERTICES-1
	REPLINE
	ENDR
.End_tower:
	move	(Ptrsegment)+,Xa	;derniŠre droite
	move	(Ptrsegment),Ya
	move	(Copptrsegment)+,Xb
	move	(Copptrsegment),Yb
	lea	(Drawpoly16,pc),Return
	jmp	(Jmp)
		;#] Compute line:
		;#[ Four planes polygone:
No_polygone:	rts
Drawpoly16:	sub	Min_y,Max_y	;calcul hauteur du polygone
	ble.s	No_polygone	;si non affich‚ alors fin
	swap	Max_y	;lecture de la couleur
	tst	Max_y
	bmi	Drawoneplane

	add	Max_y,Max_y
	bmi	Drawtrame16

	lea	(Tableymax,pc),Ptrtable
	movem.l	(Colors_code.l,Max_y),Reg1/Reg2

	swap	Max_y
	add	Min_y,Min_y
	add	Min_y,Ptrtable

	move.l	(Work_screen.w,pc),a6
	add	(Muls160.l,Min_y),a6

	lea	Mlimit,a5
	move	a5,usp
	lea	(2*NB_LINES,Ptrtable),a5

Fill_loop:	moveq	#-8,X0
	and	(a5)+,X0
	move.l	usp,Screen
	add	X0,Screen
	move.l	(Screen)+,X0
	move	(Screen),Left_offset

	moveq	#-8,X1
	and	(Ptrtable)+,X1
	move.l	usp,Screen
	add	X1,Screen
	move.l	(Screen)+,X1
	move	(Screen),Right_offset

	move.l	a6,Screen
	add	Left_offset,Screen

	sub	Right_offset,Left_offset
	bge	.Short_line

	move.l	-(Screen),Right_offset
	eor.l	Reg1,Right_offset
	and.l	X0,Right_offset
	eor.l	Right_offset,(Screen)+

	move.l	(Screen),Right_offset
	eor.l	Reg2,Right_offset
	and.l	X0,Right_offset
	eor.l	Right_offset,(Screen)+

	asr	#1,Left_offset
	jmp	(.Four_planes_fill_tower+4+2.w,pc,Left_offset)
	CNOP	4,0
	REPT	SCREEN_WIDTH/8
	move.l	Reg1,(Screen)+
	move.l	Reg2,(Screen)+
	ENDR
.Four_planes_fill_tower:
	move.l	(Screen),Right_offset
	eor.l	Reg1,Right_offset
	and.l	X1,Right_offset
	eor.l	Reg1,Right_offset
	move.l	Right_offset,(Screen)+
                                  
	move.l	(Screen),Right_offset
	eor.l	Reg2,Right_offset    
	and.l	X1,Right_offset      
	eor.l	Reg2,Right_offset    
	move.l	Right_offset,(Screen)+ 
	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Fill_loop
	rts

.Short_line:	bne.s	.Lsuiv		;a enlever
	eor.l	X1,X0
	move.l	-(Screen),Left_offset	;perte 2 cycles
	eor.l	Reg1,Left_offset
	and.l	X0,Left_offset
	eor.l	Left_offset,(Screen)+
	move.l	(Screen),Left_offset
	eor.l	Reg2,Left_offset
	and.l	X0,Left_offset
	eor.l	Left_offset,(Screen)
.Lsuiv:	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Fill_loop
	rts
		;#] Four planes polygone:
		;#[ Four planes tramed polygone:
Drawtrame16:	lea	(Tableymax,pc),Ptrtable
	move.b	Max_y,Reg1
	lsl	#8,Reg1
	move.b	Max_y,Reg1
	move	Reg1,Reg2
	swap	Reg1
	move	Reg2,Reg1
	move.l	Reg1,Reg2
	not.l	Reg2

	swap	Max_y
	add	Min_y,Min_y
	add	Min_y,Ptrtable

	move.l	(Work_screen.w,pc),a6
	add	(Muls160.l,Min_y),a6

	lea	Mlimit,a5
	move	a5,usp
	lea	(2*NB_LINES,Ptrtable),a5

.Fill_loop:	exg	Reg1,Reg2
	moveq	#-8,X0
	and	(a5)+,X0
	move.l	usp,Screen
	add	X0,Screen
	move.l	(Screen)+,X0
	move	(Screen),Left_offset

	moveq	#-8,X1
	and	(Ptrtable)+,X1
	move.l	usp,Screen
	add	X1,Screen
	move.l	(Screen)+,X1
	move	(Screen),Right_offset

	move.l	a6,Screen
	add	Left_offset,Screen

	sub	Right_offset,Left_offset
	bge	.Short_line

	move.l	-(Screen),Right_offset
	eor.l	Reg1,Right_offset
	and.l	X0,Right_offset
	eor.l	Right_offset,(Screen)+

	move.l	(Screen),Right_offset
	eor.l	Reg2,Right_offset
	and.l	X0,Right_offset
	eor.l	Right_offset,(Screen)+

	asr	#1,Left_offset
	jmp	(.Four_planes_fill_tower+4+2.w,pc,Left_offset)
	CNOP	4,0
	REPT	SCREEN_WIDTH/8
	move.l	Reg1,(Screen)+
	move.l	Reg2,(Screen)+
	ENDR
.Four_planes_fill_tower:
	move.l	(Screen),Right_offset
	eor.l	Reg1,Right_offset
	and.l	X1,Right_offset
	eor.l	Reg1,Right_offset
	move.l	Right_offset,(Screen)+
                                  
	move.l	(Screen),Right_offset
	eor.l	Reg2,Right_offset    
	and.l	X1,Right_offset      
	eor.l	Reg2,Right_offset    
	move.l	Right_offset,(Screen)+ 
	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,.Fill_loop
	rts

.Short_line:	bne.s	.Lsuiv		;a enlever
	eor.l	X1,X0
	move.l	-(Screen),Left_offset	;perte 2 cycles
	eor.l	Reg1,Left_offset
	and.l	X0,Left_offset
	eor.l	Left_offset,(Screen)+
	move.l	(Screen),Left_offset
	eor.l	Reg2,Left_offset
	and.l	X0,Left_offset
	eor.l	Left_offset,(Screen)
.Lsuiv:	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,.Fill_loop
	rts
		;#] Four planes tramed polygone:
		;#[ One plane polygone:
Drawoneplane:	lea	(Tableymax,pc),Ptrtable	;adresse table
	add	Min_y,Min_y
	add	Min_y,Ptrtable		;pointe table des x
	lea	(2*NB_LINES,Ptrtable),Ptrtable2

	move.l	(Work_screen.w,pc),a6
	add	(Muls160pl.l,Min_y),a6	;pointe ligne ecran
	moveq	#$f,Reg2		;decalage plan no
	and	Max_y,Reg2
	add	Reg2,a6

	add	Max_y,Max_y
	bvc	Oneplanetrame		;un plan tram‚
	swap	Max_y		;recupere nombre de lignes
	moveq	#-1,Reg1		;pattern $ffff
	lea	Mlimit+2,a5		;table CLIPPING x

Dlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	(a5,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	(a5,X1),X1

	sub	X0,X1
	bge.s	.Onelong1

	move.l	a6,Screen
	add	X0,Screen
	swap	X0
	not	X0
	or	X0,(Screen)
	asr	#1,X1
	jmp	(.One_plane_fill_tower+4+2.w,pc,X1)

.Onelong1:	bne.s	.Lsuiv1
	eor.l	X0,X1		;gain 2 swap
	swap	X1
	or	X1,(a6,X0)
.Lsuiv1:	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Dlrep1
	rts

n	SET	16-SCREEN_WIDTH
	CNOP	4,0
	REPT	SCREEN_WIDTH/8-2
	move	Reg1,(n.w,Screen)
n	SET	n+8
	ENDR
.One_plane_fill_tower:
	add	X1,X1
	add	X1,Screen
	swap	X1
	or	X1,(Screen)
	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Dlrep1
	rts
		;#] One plane polygone:
		;#[ One plane tramed polygone:
Oneplanetrame:	swap	Max_y		;recupere nombre de lignes
	move.l	#$bbbbeeee,Reg1
	btst	#1,Min_y
	beq.s	Even_trame
	swap	Reg1

Even_trame:	lea	Mlimit+2,a5	;table CLIPPING x

Edlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	(a5,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	(a5,X1),X1
	move.l	a6,Screen
	add	X0,Screen

	sub	X0,X1
	bge.s	.Eonelong1

	swap	X0
	not	X0
	move	(Screen),Reg2
	eor	Reg1,Reg2
	and	X0,Reg2
	eor	Reg2,(Screen)
	asr	#1,X1
	jmp	(.One_tramed_plane_fill_tower+4+2.w,pc,X1) ;+2 for GenST

.Eonelong1:	bne.s	.Elsuiv1
	not.l	X0
	and.l	X1,X0
	swap	X0
	move	(Screen),X1
	eor	Reg1,X1
	and	X0,X1
	eor	X1,(Screen)

.Elsuiv1:	swap	Reg1
	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Edlrep1
	rts

n	SET	16-SCREEN_WIDTH
	CNOP	4,0
	REPT	SCREEN_WIDTH/8-2
	move	Reg1,n(Screen)
n	SET	n+8
	ENDR
.One_tramed_plane_fill_tower:
	add	X1,X1
	add	X1,Screen
	swap	X1
	move	(Screen),X0
	eor	Reg1,X0
	and	X1,X0
	eor	X0,(Screen)
	swap	Reg1
	lea	(SCREEN_WIDTH,a6),a6
	dbf	Max_y,Edlrep1
	rts
		;#] One plane tramed polygone:
		;#[ Clipping Init:
Tableymax:
Init_polygone:	lea	Llimit,a0	;table limites gauches
	moveq	#-1,d1
	move	#CLIPSIZE-1,d0	;taille limite gauche

.Rrlimit:	move.l	d1,(a0)+	;remplissage
	clr.l	(a0)+	;Offset=0
	dbf	d0,.Rrlimit	;dernier ?

	moveq	#0,d0	;compteur pixel
	moveq	#0,d2
	moveq	#0,d3
	clr	d1	;masque droit
	swap	d1
.Rclimit:	move	d1,(a0)+	;stocke trame1
	move	d1,(a0)+	;2 fois

	move	d3,(a0)+	;stocke Offset
	move	d2,(a0)+

	lsr.l	#1,d1	;decalage masque

	bne.s	.2
	move	#$ffff,d1	;mise en place masque
	addq	#8,d3	;decalage Offset 4
	addq	#8,d2	;decalage Offset 8

.2:	addq	#1,d0	;un pixel de plus
	cmp	#319,d0	;pixel 319 ?
	ble.s	.Rclimit	;non, continuer

	move	#CLIPSIZE-1,d0
.Rllimit:	clr.l	(a0)+	;init limite droite
	move.l	#$00980098,(a0)+
	dbf	d0,.Rllimit
	rts
		;#] Clipping Init:
		;#[ Trame Init:
Init_color_trame:
	lea	Color_trame_table,a0
	moveq	#15,d0
.Loop0:	moveq	#15,d1
.Loop1:	move	d0,d2
	move	d1,d3
	


	dbf	d1,.Loop1
	dbf	d0,.Loop0
	rts
		;#] Trame Init:
Ftableymax:	ds.b	4*NB_LINES-(Ftableymax-Tableymax)
		;#[ Draw local DATA:
		CNOP	4,0
Current_object:	ds.l	1
Current_curve_pointer:	ds.l	1
Current_anim:		ds.l	1
Previous_curve_pointer:	ds.l	1

Project:		ds.l	4*MAX_POINTS
Segments:		ds.l	4*MAX_POINTS

Start_curve:		ds.l	1
End_curve:		ds.l	1

Null_curve:		ds.w	3
End_null:
Obsx:		ds.w	1
Obsy:		ds.w	1
Obsz:		ds.w	1
Vrotx:		ds.w	1	;Consecutive
Vroty:		ds.w	1
Vrotz:		ds.w	1	;Consecutive
Vdist:		ds.w	1
Rotx:		ds.w	1	;Consecutive
Roty:		ds.w	1
Rotz:		ds.w	1	;Consecutive
Dist:		ds.w	1
Matrix:		ds.w	9
		even
		;#[ Miscellaneous tables:
	CNOP	4,0


Colors_code:	dc.l	$00000000,$00000000
	dc.l	$ffff0000,$00000000
	dc.l	$0000ffff,$00000000
	dc.l	$ffffffff,$00000000
	dc.l	$00000000,$ffff0000
	dc.l	$ffff0000,$ffff0000
	dc.l	$0000ffff,$ffff0000
	dc.l	$ffffffff,$ffff0000
	dc.l	$00000000,$0000ffff
	dc.l	$ffff0000,$0000ffff
	dc.l	$0000ffff,$0000ffff
	dc.l	$ffffffff,$0000ffff
	dc.l	$00000000,$ffffffff
	dc.l	$ffff0000,$ffffffff
	dc.l	$0000ffff,$ffffffff
	dc.l	$ffffffff,$ffffffff

	CNOP	4,0
Muls160:
n	SET	4
	REPT	NB_LINES
	dc.w	n
n	SET	n+SCREEN_WIDTH
	ENDR

	CNOP	4,0
Muls160pl:
n	SET	0
	REPT	NB_LINES
	dc.w	n
n	SET	n+SCREEN_WIDTH
	ENDR

		;#] Miscellaneous tables:
		;#[ Trigonometric Tables:
Sincos:	incbin	Sincos.bin
		;#] Trigonometric Tables:
		;#[ Colors:
Palette:
	IFNE	TRAME_COLORS
	dc.w	$000,$047
.Blue0:	dc.w	$023,$034,$045,$056
.Red0:	dc.w	$510,$720,$740,$760
.BlueBis:	dc.w	$013,$024,$035,$046
	dc.w	$444,$777
	ELSEIF
.Red1:	dc.w	$000,$400,$500,$600,$700
.Green1:	dc.w	$332,$443,$554,$665,$776
.Blue1:	dc.w	$233,$344,$455,$566,$677
.Flash1:	dc.w	$777
	ENDC
		;#] Colors:
		;#] Draw local DATA:
	 ;#] Draw Object:
	 ;#[ CLS Header:
MC68030_cls:	move.l	Work_screen,a6
	lea	(SCREEN_WIDTH*NB_LINES.l,a6),a6
	moveq	#0,d1
	moveq	#0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d1,d5
	move.l	d2,d6
	move.l	d1,d7
	move.l	d2,a0
	move.l	d1,a1
	move.l	d2,a2
	move.l	d1,a3
	move.l	d2,a4
	IFNE	BACKGRND
	moveq	#21,d0
	lea	Background-64,a5
	jmp	.End_tower-15*8
	CNOP	4,0
.Clear_screen:
	REPT	31
	movem.l	(a5)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,-(a6)
	ENDR
	ELSEIF
	moveq	#10,d0
	jmp	.End_tower-36*4
	CNOP	4,0
.Clear_screen:
	REPT	63
	movem.l	d1-d7/a0-a4,-(a6)
	ENDR
	ENDC
.End_tower:	dbf	d0,.Clear_screen
	IFNE	BACKGRND
	movem.l	(a5)+,d1-d7/a0
	ENDC
	movem.l	d1-d7/a0,-(a6)
	rts
	IFNE	BACKGRND
	ds.l	16
Background:	incbin	backgrnd.img
	ds.l	16
	ENDC
	 ;#] CLS Header:
	 ;#[ BSS Section:
		BSS
Mouse_flag:		ds.b	1
		CNOP	4,0
Sys_stack:		ds.l	1
Sys_rez:		ds.w	1
Sys_vbl:		ds.l	1
Sys_mfp		ds.l	1
Sys_zero:		ds.l	1
Sys_ikbd:		ds.l	1
Sys_screen:		ds.l	1
Sys_palette:		ds.w	16
Color_trame_table:	ds.l	2*256
;----------- table de CLIPPING en x ---------------------
Llimit:		ds.l	CLIPSIZE*2
Tlimit:		ds.l	SCREEN_WIDTH*2
Mlimit:		ds.l	SCREEN_WIDTH*2
Rlimit:		ds.l	CLIPSIZE*2

Top_of_stack:		ds.l	1000
Mystack:
	 ;#] BSS Section:

