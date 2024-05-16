	opt	l2
	opt	P=68030
	opt	o+
	XREF	Objects

	TEXT
	 ;#[ Equates:
STRUCT_SIZE	equ	22+8

VANISH	EQU	1
NO_MOVE	EQU	0

BACKGRND	EQU	1
CPU_TIME	EQU	1
CLEAR_SCREEN	EQU	1
MUSIC	EQU	0 (!)
FRAME_COUNT	EQU	1
PCMSAMPLE	EQU	0
CLIPPING	EQU	1
MULS	EQU	1

TRAME_COLORS	EQU	1
VBL_COUNT	EQU	$464
NB_LINES	EQU	200
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
	lea	Screen_list,a0
	movem.l	(a0),d0-d5
	move.l	d0,d6
	movem.l	d1-d6,(a0)
	movep	4*(NB_SCREEN-2)(a0),d5
	move.l	d5,$ffff8200.w
.Vs\@:	tst	VBL_COUNT.w
	beq.s	.Vs\@
	clr	VBL_COUNT.w
	ENDM
	 ;#] Macros:
	 ;#[ Initializations:
Start:	move.l	4(a7),a3	base page
	move.l	$c(a3),d0	text len
	add.l	$14(a3),d0	data len
	add.l	$1c(a3),d0	bss len
	add.l	#$100,d0	basepage

	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr	-(a7)
	move	#$4a,-(a7)
	trap	#1	shrink memory
	lea	12(a7),a7

	pea	Mystack
	move	#$20,-(a7)
	trap	#1
	move.l	d0,Sys_stack

	IFNE	BACKGRND
	lea	Background-64,a0
	lea	32064(a0),a1
	move	#333,d0
.Convert:	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a7)

	movem.l	-48(a1),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-48(a0)

	movem.l	(a7)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a1)
	dbf	d0,.Convert
	ENDC

	sub.l	a0,a0
	movec	a0,VBR
.MC68030:	move	#%1000100000001,d0
	movec	d0,CACR
	IFNE	MUSIC
	jsr	Set_music
	ENDC

	IFNE	PCMSAMPLE
	jsr	InitPCM
	ENDC

	jsr	Initpoly(pc)
	IFEQ	MULS
	jsr	Create_muls_table(pc)
	ENDC
	lea	Objects,a0
	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,a1
	move.l	a1,Current_curve
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
	 ;#[ Save Contex:
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
	clr.b	$ffff8262.w
	clr.b	$ffff820d.w

	move.l	$ffff8200.w,d0
	move.l	d0,Sys_screen
	lsl	#8,d0
	and.l	#$00ffff00,d0

Set_screens:	lea	Screen_list,a0
	move.l	d0,(a0)+		;Current_screen
	move.l	#Screen2,d0
	add.l	#256,d0
	clr.b	d0
	rept	NB_SCREEN-2
	move.l	d0,(a0)+
	add.l	#32000,d0
	endr
	move.l	d0,(a0)

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
	 ;#[ Main:
Main:	move.l	usp,a0
	move.l	a0,-(a7)

Repeat:
	IFNE	CLEAR_SCREEN
Set_cls0:	jsr	MC68030_cls
	ENDC
	jsr	Calcproj(pc)
	move.l	Current_anim,a3	;lire la prochaine animation
	move.l	(a3)+,d0		;adresse de l'objet
	bne.s	Cont_anim		;c'est la derniŠre image
	move.l	(a3),a3		;Return image boucle
	move.l	(a3)+,d0

Cont_anim:	move.l	a3,Current_anim
	move.l	d0,a2
	lea	Project,a1
	jsr	Calcobj(pc)
	move.l	(a2),a2
	jsr	Traceobj(pc)
	SWITCH_SCREEN
	addq	#1,Frame_counter
		;#[ Keyboard Manager:
	move.l	Current_object(pc),a0
	cmp	#400,Dist
	bhi	.Next_object
	cmp	#40,Dist
	bls	.Next_object
	move.b	Current_key(pc),d0
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
	seq	Cpu_time_flag
	beq	Repeat
	ENDC
	move	STRUCT_SIZE-2(a0),Cptwaiting
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
	move	#160,Obsx
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
	lea	-STRUCT_SIZE(a0),a0
	bra.s	.Set_object
.Next_object:	lea	STRUCT_SIZE(a0),a0
	tst.l	(a0)
	bne.s	.Set_object
	lea	Objects,a0
.Set_object:	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,a1
	tst.b	Mouse_flag
	bne.s	.Mouse_active
	move.l	a1,Current_curve
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
	move	#160,Obsx
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
.Cheat:	move.l	Latch_keys(pc),d0
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
	 ;#] Main:
	 ;#[ Restore Contex:
Restore:	move	#$2700,sr
	move.l	Sys_vbl,$70.w
	move.l	Sys_ikbd,$118.w
	move.l	Sys_zero,$14.w
	move.b	#8,$fffffc02.w
	move.b	Sys_mfp+1,$fffffa07.w
	move.b	Sys_mfp+3,$fffffa09.w

Sound_off:	lea	$ffff8800.w,a0
	moveq	#$a,d0
.Loop:	move.b	d0,(a0)
	sf	2(a0)
	dbf	d0,.Loop
	move.b	#7,(a0)
	st	2(a0)

.Synchronize:	move.b	$ffff8209.w,d0
	moveq	#$7f,d1
.Wait_sync:	cmp.b	$ffff8209.w,d0
	dbne	d1,.Wait_sync
	bne.s	.Synchronize

	move.b	Sys_rez,$ffff8262.w
	movem.l	Sys_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	Sys_screen,$ffff8200.w

	move.l	$44e.w,Work_screen
Set_cls1:	jsr	MC68030_cls

	stop	#$2300

	move.l	Sys_stack,-(a7)	
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7

	clr	-(a7)
	trap	#1
	 ;#] Restore Contex:
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
	move	STRUCT_SIZE-2(a0),Cptwaiting
	addq.b	#1,Mouse_offset
	ext	d0
	add	d0,Rotz
	bra	.End_of_ikbd_rout
.Not_first_mouse_parameter:
	clr.b	Mouse_offset
	ext	d0
	add	d0,Rotx
	bra	.End_of_ikbd_rout

.Ikbd_event:	move.b	d0,Current_key

.Release:	cmpi	#$fb,d0
	bgt.s	.End_of_ikbd_rout
	cmpi	#$f8,d0
	blt.s	.End_of_ikbd_rout
	clr	Vrotx
	clr	Vroty
	clr	Vrotz
	clr	Roty
	move.l	#Null_curve,Current_curve
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

;	clr.b	$fffffa1b.w
;	move.b	#199-10,$fffffa21.w
;	move.b	#8,$fffffa1b.w

	movem.l	d0-d7/a0-a3/a6,-(a7)
	btst	#0,VBL_COUNT+1.w
	beq.s	.Same_color
	move	$ffff825e.w,d0
	and	#$777,d0
	addq	#1,d0
	move	d0,$ffff825e.w
.Same_color:
	IFNE	FRAME_COUNT
	subq	#1,Vbl_counter
	bgt.s	.Not_all_frames
	move	#FRAMES_FREQ,Vbl_counter
	move	Frame_counter,Nb_frames
	clr	Frame_counter
.Not_all_frames:move.l	Work_screen(pc),a0
	addq	#2,a0
	move	Nb_frames,d0
	tst.b	Cpu_time_flag
	beq	Skip_display
	jsr	Zeroa99(pc,d0*4)

	lea	160*10(a0),a0
	move	Vrotx,d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	lea	160*10(a0),a0
	move	Vroty,d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	lea	160*10(a0),a0
	move	Vrotz,d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	bra	Skip_display
Zeroa99:	incbin	Zeroa99.bin
	rts
Skip_display:
	ENDC

	IFNE	MUSIC
	jsr	Play_music
	ENDC

	IFNE	VANISH
	tst.b	Cptwaiting
	bgt.s	.Noincdist
;	move	Vdist(pc),d0
;	add	d0,Dist
	addq	#8,Dist
	bra.s	.End_vbl
.Noincdist:	subq	#1,Cptwaiting
	ENDC

.End_vbl:	movem.l	(a7)+,d0-d7/a0-a3/a6
	rte
	 ;#] VBL Manager:
	 ;#[ Draw Object:
		;#[ Compute line:
*****************************************************************
*routine d'affichage de polygones convexes
*avec CLIPPING et tramage
*	- calcul des droites dans une table
*	- remplissage par movem.l
*	- tramage 16 couleurs
*	- CLIPPING automatique en x
*
* a6 -> adresse des datas	(des points projetes)
* d6 -> nombre de points	(du polygone)
* d7 -> couleurs * 8	(attention)
*****************************************************************

;------------- d‚finition des registres -------------------------

Min_y	EQUR	d6	;r‚serv‚s dans tous le calcul
Max_y	EQUR	d7
Ptrtable	EQUR	a0	;pointeur table des Min_x-Max_x
Ecran	EQUR	a1	;adresse ecran

;------------- registres pour calcul lignes ---------------------

Xa	EQUR	d0	;extremit‚s de la droite
Ya	EQUR	d1
Xb	EQUR	d2
Yb	EQUR	d3


Ptrsegment	EQUR	a6	;pointeur sur segment
Copptrsegment	EQUR	a0	;copie pointeur sur segment

Jmpline	EQUR	a3	;adresse routine de droite
Return	EQUR	a1	;adresse de Return droite

Ptry	EQUR	a2	;pointeur tabley
Dx	EQUR	d4
Regdata	EQUR	d5

Jmp	EQUR	a5	;adresse debut du saut
			;pour calcul des points


;-------------- calcul et CLIPPING d'une ligne verticale ---------------
	IFEQ	1
		;#[ Fast line:
	rept	NB_LINES
	move	Xa,(Ptry)+	;mise en place 2 nouveaux points
	endr
Returnvert:	jmp	(Return)	;ligne verticale invisible
Vertline:	cmp	#NB_LINES,Ya	;CLIPPING
	bcs.s	.Yasupzero
	bge.s	Returnvert
	moveq	#0,Ya
.Yasupzero:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	Returnvert
	move	#NB_LINES-1,Yb
.Ybinfmax:	cmp	Max_y,Yb	;tester maximum
	ble.s	.Pasmaximum
	move	Yb,Max_y
.Pasmaximum:	cmp	Min_y,Ya	;tester minimum
	bge.s	.Pasminimum
	move	Ya,Min_y
.Pasminimum:	sub	Ya,Yb	;Yb=Dy
	add	Ya,Ya
	add	Ya,Ptry	;debut table

	add	Yb,Yb	;Dy*2
	neg	Yb
	jmp	Returnvert-2(pc,Yb)

Calcreturn	;fin du calcul des points
	jmp	(Return)

;Lastx:	dc.w	0
;-------------- d‚but calcul des points d'une ligne -----------------

Calcline:	lea	Tableymax(pc),Ptry
	cmp	Ya,Yb	;c'est un ligne montante ?
	beq.s	Calcreturn	;ligne horizontale -> fin

	bge.s	.Yb_sup_Ya

	exg	Xa,Xb	;‚change les points
	exg	Ya,Yb
	lea	2*NB_LINES(Ptry),Ptry ;c'est une ligne montante

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
	bcs.s	.Yasup0
	bge.s	Calcreturn	;ligne invisible
	MULS	Xb,Ya	;CLIPPING
	asr.l	#4,Ya	;divise par 16
	sub	Ya,Xa	;addition … Xa
	moveq	#0,Ya	;Ya=0
	move	Yb,Regdata	;nombre de ligne=Yb
.Yasup0:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	Calcreturn
	move	#NB_LINES-1,Yb ;moins de lignes
	move	Yb,Regdata
	sub	Ya,Regdata	;calcul Dy
.Ybinfmax:


;------------ mise a jour des maximums et minimum ----------

	cmp	Max_y,Yb	;tester maximum
	ble.s	.Pasmaximum
	move	Yb,Max_y

.Pasmaximum:	cmp	Min_y,Ya	;tester minimum
	bge.s	.Pasminimum
	move	Ya,Min_y

.Pasminimum	add	Ya,Ya	 ;adresse tableau lignes
	add	Ya,Ptry

	add	Regdata,Regdata  ;Offset pour le saut
	add	Regdata,Regdata
	neg	Regdata

	swap	Xb
	swap	Xa
	asr.l	#4,Xb

	move	Xb,Xa
	beq.s	Intenger_line	;coef de pente entier
	swap	Xa
	swap	Xb

	addq	#4,Xa

	jmp	(Jmpline,Regdata)


;---------- cas d'une ligne … coefficient entier -----------

Intenger_line:	swap	Xa
	swap	Xb
	add	#.Int_line2-.Int_line1,Regdata
	jmp	.Int_line1(pc,Regdata)
.Int_line1:
	rept	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	add	Xb,Xa	;calcul avec coef entier
	endr
.Int_line2:
	move	Xa,(Ptry)	;plot dernier point
	jmp	(Return)	;fin de calcul

;-------------- cas d'une droite coeficient fractionnaire ----

	rept	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	addx.l	Xb,Xa	;ajout pente
	endr

Ajmpline:	move	Xa,(Ptry)	;stocke dernier points
	jmp	(Return)	;fin calcul
		;#] Fast line:
	ELSEIF
		;#[ Fine line:
	rept	NB_LINES
	move	Xa,(Ptry)+	;mise en place nouveau points
	endr
Affvert:
Returnvert:	jmp	(Return)

Vertline:	; clipping
	cmp	#NB_LINES,Ya
	bcs.s	.Yasup0
	bge.s	Returnvert
	moveq	#0,Ya
.Yasup0:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	Returnvert
	move	#NB_LINES-1,Yb
.Ybinfmax:	cmp	Min_y,Ya		;tester minimum
	bge.s	.Pasminimum
	move	Ya,Min_y
.Pasminimum:	cmp	Max_y,Yb		;tester maximum
	ble.s	.Pasmaximum
	move	Yb,Max_y
.Pasmaximum:	sub	Ya,Yb
	add	Ya,Ya
	add	Ya,Ptry
	add	Yb,Yb
	neg	Yb
	jmp	Affvert-2(pc,Yb)
CalcReturn:	jmp	(Return)
				;fin du calcul des points

;-------------- d‚but calcul d'une ligne -------------------------

Calcline:	lea	Tableymax(pc),Ptry

	cmp	Ya,Yb
	beq.s	CalcReturn		;ligne horizontale
	bge.s	.YbsupYa
	exg	Xa,Xb		;echange les points
	exg	Ya,Yb
	lea	NB_LINES*2(Ptry),Ptry	;c'est une ligne montante
.YbsupYa:
	sub	Xa,Xb		;dx
	beq.s	Vertline
	move	Yb,Regdata
	sub	Ya,Regdata		;dy
	move	Xb,Dx
	ext.l	Xb		;calcul de la pente
	asl.l	#8-2,Xb		;dx*256

	divs	Regdata,Xb		;divise par dy
	bvc.s	.Nodeborde
	asr.l	#6,Xb
	divs	Regdata,Xb
;	bvc.s	.Okdeb
;	addq	#7,$ffff8240.w
.Okdeb:	swap	Xb
	clr	Xb
	bra.s	.Skipex

.Nodeborde:	ext.l	Xb

	asl.l	#8,Xb		;recuperation virgule 1/256eme
	asl.l	#2,Xb
.Skipex:	cmp	#NB_LINES,Ya
	bcs.s	.Yasup0
	bge.s	CalcReturn
	MULS	Dx,Ya
	divs	Regdata,Ya
	sub	Ya,Xa
	moveq	#0,Ya
	move	Yb,Regdata
.Yasup0:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	CalcReturn
	move	#NB_LINES-1,Yb
	move	Yb,Regdata
	sub	Ya,Regdata	;dy
.Ybinfmax:
;------------ mise a jour des maximums et minimum ----------

	cmp	Min_y,Ya		;tester minimum
	bcc.s	.Pasminimum
	move	Ya,Min_y
.Pasminimum:	cmp	Max_y,Yb		;tester maximum

	bls.s	.Pasmaximum
	move	Yb,Max_y
.Pasmaximum:	add	Ya,Ya		;adresse tableau lignes
	add	Ya,Ptry
	add	Regdata,Regdata	;offset pour le saut
	add	Regdata,Regdata
	neg	Regdata

	swap	Xa
	move	Xb,Xa
	beq	Lineentier
	add	#.Jmpline2-.Jmpline1,Regdata

	swap	Xa
	swap	Xb	;poids fort = virgule*4
			;poids faible = partie entiere*4
	addq	#2,Xa	;x+1/2

	jmp	.Jmpline1(pc,Regdata)

.Jmpline1:	rept	NB_LINES-1
	move	Xa,(Ptry)+
	addx.l	Xb,Xa
	endr
.Jmpline2:
Ajmpline:	move	Xa,(Ptry)

	jmp	(Return)

;---------- cas d'une ligne … coefficient entier -----------

Lineentier:	swap	Xa
	swap	Xb
	add	#.Lineent3-.Lineent2,Regdata
	jmp	.Lineent2(pc,Regdata)
.Lineent2:	rept	NB_LINES-1
	move	Xa,(Ptry)+
	add	Xb,Xa
	endr
.Lineent3	move	Xa,(Ptry)
	jmp	(Return)
		;#] Fine line:
	ENDC

Reg1	EQUR	d0
Reg2	EQUR	d1
Reg3	EQUR	d2
X1	EQUR	d3
Offgau	EQUR	d4
X0	EQUR	d5
Offdro	EQUR	d6

Reg4	EQUR	a2
Ptrtable2	EQUR	a2

Reg5	EQUR	a3
Reg6	EQUR	a4
X_clip_ptr	EQUR	a5
Lecran	EQUR	a6

REPLINE	MACRO
	lea	.\@(pc),Return
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
	lea	Calcline(pc),Jmp	;adresse du calcul de droite
	lea	Ajmpline(pc),Jmpline
	subq	#1,Xa
	add	Xa,Xa
	neg	Xa
	jmp	.End_tower(pc,Xa*8)
	rept	8-1
	REPLINE
	endr
.End_tower:
	move	(Ptrsegment)+,Xa	;derniŠre droite
	move	(Ptrsegment),Ya
	move	(Copptrsegment)+,Xb
	move	(Copptrsegment),Yb
	lea	Drawpoly16(pc),Return
	jmp	(Jmp)
		;#] Compute line:
		;#[ Four planes polygone:
No_polygone:	rts
Drawpoly16:	sub	Min_y,Max_y	;calcul hauteur du polyg
	ble.s	No_polygone	;si non affich‚ alors fin
	swap	Max_y	;lecture de la couleur
	tst	Max_y
	bmi	Drawoneplane	;routine 1 plan

	add	Max_y,Max_y
	bmi	Drawtrame16	;tramage 16 couleurs

	lea	Tableymax(pc),Ptrtable
	movem.l	Colors_code-Tableymax(Ptrtable,Max_y),Reg1/Reg2

	swap	Max_y
	add	Min_y,Min_y
	add	Min_y,Ptrtable

	lea	Muls160(pc),X_clip_ptr
	move.l	Work_screen(pc),Lecran
	add	0(X_clip_ptr,Min_y),Lecran

	lea	Mlimit,X_clip_ptr
	move	X_clip_ptr,usp
	lea	2*NB_LINES(Ptrtable),X_clip_ptr

Fill_loop:	moveq	#-8,X0
	and	(X_clip_ptr)+,X0
	move.l	usp,Ecran
	add	X0,Ecran
	move.l	(Ecran)+,X0
	move	(Ecran),Offgau

	moveq	#-8,X1
	and	(Ptrtable)+,X1
	move.l	usp,Ecran
	add	X1,Ecran
	move.l	(Ecran)+,X1
	move	(Ecran),Offdro

	move.l	Lecran,Ecran
	add	Offgau,Ecran

	sub	Offdro,Offgau
	bge	.Short_line

	move.l	-(Ecran),Offdro
	eor.l	Reg1,Offdro
	and.l	X0,Offdro
	eor.l	Offdro,(Ecran)+

	move.l	(Ecran),Offdro
	eor.l	Reg2,Offdro
	and.l	X0,Offdro
	eor.l	Offdro,(Ecran)+

	asr	#1,Offgau
	jmp	.Fill_tower+4(pc,Offgau)
	rept	20
	move.l	Reg1,(Ecran)+
	move.l	Reg2,(Ecran)+
	endr
.Fill_tower:	move.l	(Ecran),Offdro
	eor.l	Reg1,Offdro
	and.l	X1,Offdro
	eor.l	Reg1,Offdro
	move.l	Offdro,(Ecran)+
                                  
	move.l	(Ecran),Offdro
	eor.l	Reg2,Offdro    
	and.l	X1,Offdro      
	eor.l	Reg2,Offdro    
	move.l	Offdro,(Ecran)+ 
	lea	160(Lecran),Lecran
	dbf	Max_y,Fill_loop
	rts

.Short_line:	bne.s	.Lsuiv		;a enlever
	eor.l	X1,X0
	move.l	-(Ecran),Offgau	;perte 2 cycles
	eor.l	Reg1,Offgau
	and.l	X0,Offgau
	eor.l	Offgau,(Ecran)+
	move.l	(Ecran),Offgau
	eor.l	Reg2,Offgau
	and.l	X0,Offgau
	eor.l	Offgau,(Ecran)
.Lsuiv:	lea	160(Lecran),Lecran
	dbf	Max_y,Fill_loop
	rts
		;#] Four planes polygone:
		;#[ Four planes tramed polygone:
Drawtrame16:	rts
		;#] Four planes tramed polygone:
		;#[ One plane polygone:
Drawoneplane:	lea	Tableymax(pc),Ptrtable	;adresse table
	add	Min_y,Min_y
	add	Min_y,Ptrtable		;pointe table des x
	lea	2*NB_LINES(Ptrtable),Ptrtable2

	lea	Muls160pl(pc),X_clip_ptr
	move.l	Work_screen(pc),Lecran
	add	0(X_clip_ptr,Min_y),Lecran	;pointe ligne Ecran
	moveq	#$f,Reg2		;decalage plan no
	and	Max_y,Reg2
	add	Reg2,Lecran

	add	Max_y,Max_y
	bvc	Oneplanetrame		;un plan tram‚
	swap	Max_y		;recupere nombre de lignes
	moveq	#-1,Reg1		;pattern $ffff
	lea	Mlimit+2,X_clip_ptr	;table CLIPPING x

Dlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	0(X_clip_ptr,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	0(X_clip_ptr,X1),X1

	sub	X0,X1
	bge.s	.Onelong1

	move.l	Lecran,Ecran
	add	X0,Ecran
	swap	X0
	not	X0
	or	X0,(Ecran)
	asr	#1,X1
	jmp	Fillerplan+4(pc,X1)

.Onelong1:	bne.s	.Lsuiv1
	eor.l	X0,X1		;gain 2 swap
	swap	X1
	or	X1,(Lecran,X0)
.Lsuiv1:	lea	160(Lecran),Lecran
	dbf	Max_y,Dlrep1
	rts

n	set	-18*8
	rept	18
	move	Reg1,n(Ecran)
n	set	n+8
	endr
Fillerplan:	add	X1,X1
	add	X1,Ecran
	swap	X1
	or	X1,(Ecran)
	lea	160(Lecran),Lecran
	dbf	Max_y,Dlrep1
	rts
		;#] One plane polygone:
		;#[ One plane tramed polygone:
Oneplanetrame:	swap	Max_y		;recupere nombre de lignes
	move.l	#$bbbbeeee,Reg1
	btst	#1,Min_y
	beq.s	Even_trame
	swap	Reg1

Even_trame:	lea	Mlimit+2,X_clip_ptr	;table CLIPPING x

Edlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	0(X_clip_ptr,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	0(X_clip_ptr,X1),X1
	move.l	Lecran,Ecran
	add	X0,Ecran

	sub	X0,X1
	bge.s	.Eonelong1

	swap	X0
	not	X0
	move	(Ecran),Reg2
	eor	Reg1,Reg2
	and	X0,Reg2
	eor	Reg2,(Ecran)
	asr	#1,X1
	jmp	.Efillerplan+4(pc,X1)

.Eonelong1:	bne.s	.Elsuiv1
	not.l	X0
	and.l	X1,X0
	swap	X0
	move	(Ecran),X1
	eor	Reg1,X1
	and	X0,X1
	eor	X1,(Ecran)

.Elsuiv1:	swap	Reg1
	lea	160(Lecran),Lecran
	dbf	Max_y,Edlrep1
	rts

n	set	-18*8
	rept	18
	move	Reg1,n(Ecran)
n	set	n+8
	endr

.Efillerplan:	add	X1,X1
	add	X1,Ecran
	swap	X1
	move	(Ecran),X0
	eor	Reg1,X0
	and	X1,X0
	eor	X0,(Ecran)
	swap	Reg1
	lea	160(Lecran),Lecran
	dbf	Max_y,Edlrep1
	rts
		;#] One plane tramed polygone:
		;#[ Miscellaneous tables:
Muls160:
n	set	4
	rept	NB_LINES
	dc.w	n
n	set	n+160
	endr
Muls160pl:	incbin	muls160.bin

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
		;#] Miscellaneous tables:
		;#[ Clipping Init:
Tableymax:
Initpoly:	lea	Llimit,a0	;table limites gauches
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
	IFEQ	MULS
		;#[ Create MULS table:
Create_muls_table:
	lea	Rotate_table,a0
	move	#$ff,d0
	moveq	#-$80,d2
.Loop0:	moveq	#$7f,d1
	moveq	#0,d3
.Loop1:	move	d3,d4
	ext	d4
	MULS	d2,d4
	move	d4,(a0)+
	addq	#2,d3
	dbf	d1,.Loop1
	addq	#1,d2
	dbf	d0,.Loop0
	rts
		;#] Create MULS table:
	ENDC
Ftableymax:	ds.b	4*NB_LINES-(Ftableymax-Tableymax)
	IFNE	MULS
		;#[ 14 MULS Matrix:
Calcproj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#7,$ffff8240.w
.Skip_cpu:
	ENDC

NXTANG	MACRO
	move	\1(pc),d0	;rot
	add	\2(pc),d0
	and	#$3ff,d0
	move	d0,\2
	;add	d0,d0
	;add	d0,d0
	movem	0(a0,d0*4),\3
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

	lea	Sincos(pc),a0
	NXTANG	Vrotx,Rotx,sx/cx	;sx
	NXTANG	Vroty,Roty,sy/cy	;sy
	NXTANG	Vrotz,Rotz,sz/cz	;sz
;
; calcule la matrice de projection
;
	lea	Matrix(pc),a0

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

	lea	Matrix(pc),a6
	move	(a2)+,d5

; occupes :	d0/d1/d2/d3/d4/d6/d7
;	a1/a2/a4/a6
; libres :	d5
;	a0/a3/a5 translation x,y,z

	move.l	Current_curve(pc),a4
	move.l	a4,Old_curve
	move	Obsx(pc),d4
	ext.l	d4
	lsl.l	#3,d4
	move.l	d4,a0
	move	Obsy(pc),a3
	move	Obsz(pc),a5
	sub	Dist(pc),a5
	add	(a4)+,a0
	add	(a4)+,a3
	add	(a4)+,a5
	cmp.l	End_curve(pc),a4
	bcs.s	.Cont_curve
	move.l	Start_curve(pc),a4
.Cont_curve:	move.l	a4,Current_curve
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
	ELSEIF
		;#[ Incremental 3D Matrix:
Calcproj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#7,$ffff8240.w
.Skip_cpu:
	ENDC

Matrix_pointer	EQUR	a0
Trigo_table1	EQUR	a1
Trigo_table2	EQUR	a2

Save1	EQUR	a3
Save2	EQUR	a4
Save3	EQUR	a5
Save4	EQUR	a6
Save5	EQUR	d3
Save6	EQUR	a2 (!)

X_angle	EQUR	d4
Y_angle	EQUR	d5
Z_angle	EQUR	d6
Trigo_mask	EQUR	d7

	lea	Matrix(pc),Matrix_pointer
	lea	Sincos4(pc),Trigo_table1
	lea	$1000(Trigo_table1),Trigo_table2

	move	Vrotx(pc),d0
	add	d0,Rotx
	move	Vroty(pc),d0
	add	d0,Roty
	move	Vrotz(pc),d0
	add	d0,Rotz

	move	Rotx(pc),X_angle
	move	Roty(pc),Y_angle
	move	Rotz(pc),Z_angle
	move	#$3ff*4,Trigo_mask

	move	Y_angle,d0	;y
	move	d0,d1
	add	Z_angle,d1	;y+z
	sub	Z_angle,d0	;y-z
	and	Trigo_mask,d1
	and	Trigo_mask,d0
	move.l	0(Trigo_table1,d0),d0	;s(y-z)|c(y-z)/2
	move.l	0(Trigo_table1,d1),d1	;s(y+z)|c(y+z)/2
	add	d1,d0		;(c(y+z)+c(y-z))/2
	movep	d0,0(Matrix_pointer)

	swap	d0
	swap	d1
	sub	d1,d0		;(s(y+z)-s(y-z))/2
	movep	d0,1(Matrix_pointer)

	move	Y_angle,d0
	and	Trigo_mask,d0
	move	0(Trigo_table1,d0),d0
	add	d0,d0
	neg	d0		;-s(y)
	movep	d0,2(Matrix_pointer)

	move	X_angle,d0	;x+y
	add	Y_angle,d0	;x+y
	move	d0,d1
	add	Z_angle,d0	;x+y+z
	sub	Z_angle,d1	;x+y-z
	and	Trigo_mask,d0
	and	Trigo_mask,d1
	move.l	0(Trigo_table2,d0),d0	;s(x+y+z)/4|c(x+y+z)/4
	move.l	0(Trigo_table2,d1),d1	;s(x+y-z)/4|c(x+y-z)/4
	move.l	d0,Save1
	move.l	d1,Save2

	add	d1,d0	;cos	;c(x+y+z)+c(x+y-z)/4
	swap	d0
	swap	d1
	sub	d1,d0	;sin	;c(x+y+z)+c(x+y-z)|s(x+y+z)-s(x+y-z)/4

	move	X_angle,d1
	sub	Y_angle,d1
	move	d1,d2
	add	Z_angle,d1	;x-y+z
	sub	Z_angle,d2	;x-y-z
	and	Trigo_mask,d1
	and	Trigo_mask,d2
	move.l	0(Trigo_table2,d1),d1	;s(x-y+z)|c(x-y+z)/4
	move.l	0(Trigo_table2,d2),d2	;s(x-y-z)|c(x-y-z)/4
	move.l	d1,Save3
	move.l	d2,Save4

	add	d2,d1	;cos
	swap	d1
	swap	d2
	sub	d2,d1	;sin	;(c(x-y+z)+c(x-y-z))/4|(s(x-y+z)-s(x-y-z))/4

	sub	d1,d0	;sin
	swap	d0
	swap	d1
	sub	d1,d0	;cos

	move	X_angle,d1
	move	d1,d2
	add	Z_angle,d1	;x+z
	sub	Z_angle,d2	;x-z
	and	Trigo_mask,d1
	and	Trigo_mask,d2
	move.l	0(Trigo_table1,d1),d1	;s(x+z)|c(x+z)/2
	move.l	0(Trigo_table1,d2),d2	;s(x-z)|c(x-z)/2
	move.l	d1,Save5
	move.l	d2,Save6

	add	d2,d1	;cos	;(c(x+z)+c(x-z))/2
	swap	d1
	swap	d2
	sub	d2,d1	;sin	;(c(x+z)+c(x-z))/2|(s(x+z)-s(x-z))/2
	add	d0,d1	;cos
	swap	d0
	movep	d1,3(Matrix_pointer)
	swap	d1
	sub	d0,d1	;sin
	movep	d1,4(Matrix_pointer)

	move	X_angle,d0
	move	d0,d1
	add	Y_angle,d0
	sub	Y_angle,d1
	and	Trigo_mask,d0
	and	Trigo_mask,d1
	move	0(Trigo_table1,d0),d0
	add	0(Trigo_table1,d1),d0
	neg	d0
	movep	d0,5(Matrix_pointer)

	move.l	Save1,d1
	move.l	Save2,d0
	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0	;c(x+y-z)-c(x+y+z)/4|s(x+y-z)+s(x+y+z)/4

	move.l	Save3,d1
	move.l	Save4,d2
	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1

	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0
	neg	d0

	move.l	Save5,d1
	move.l	Save6,d2
	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1
	add	d1,d0
	swap	d0
	swap	d1
	sub	d1,d0
	movep	d0,6(Matrix_pointer)
	swap	d0
	movep	d0,7(Matrix_pointer)

	move	X_angle,d0
	add	Y_angle,d0
	sub	Y_angle,X_angle
	and	Trigo_mask,d0
	and	Trigo_mask,X_angle
	move	2(Trigo_table1,d0),d0
	add	2(Trigo_table1,X_angle),d0
	movep	d0,8(Matrix_pointer)

	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu2
	clr	$ffff8240.w
.Skip_cpu2:
	ENDC
	rts
		;#] Incremental 3D Matrix:
		;#[ Incremental Rotate:
ROTATE	MACRO
	move	usp,a4
	movem	(a2)+,d1/d2/d3
	add	#$80,d1
	add	#$80,d2
	add	#$80,d3

	move.b	(a4)+,d1
	move	0(a6,d1),d6
	move.b	(a4)+,d2
	add	0(a6,d2),d6
	move.b	(a4)+,d3
	add	0(a6,d3),d6
	add	a0,d6
	ext.l	d6
	lsl.l	#3,d6

	move.b	(a4)+,d1
	move	0(a6,d1),d7
	move.b	(a4)+,d2
	add	0(a6,d2),d7
	move.b	(a4)+,d3
	add	0(a6,d3),d7
	add	a3,d7
	ext.l	d7

	move.b	(a4)+,d1
	move	0(a6,d1),d1
	move.b	(a4)+,d2
	add	0(a6,d2),d1
	move.b	(a4)+,d3
	add	0(a6,d3),d1
	asr	#8,d1
	add	a5,d1

	DIVS	d1,d6
	DIVS	d1,d7

	and	d4,d6
	add	d0,d7

	move	d7,(a1)+
	move	d6,(a1)+
	ENDM

; registres utilises :
;	a0-a6 sauf a1
;	a2 peut etre libere
;	d1-d7 sauf d4
;
; registres libres :
;	a1,d0,d4
;

; occupes :	d0/d1/d2/d3/d4/d6/d7
;	a1/a2/a4/a6
; libres :	d5
;	a0/a3/a5 translation x,y,z

Calcobj:
	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu
	move	#$70,$ffff8240.w
.Skip_cpu:
	ENDC

	move	Obsx(pc),a0
	move	Obsy(pc),a3
	move	Obsz(pc),a5
	sub	Dist(pc),a5
	moveq	#-8,d4

	lea	Matrix(pc),a6
	move	a6,usp
	move.l	#$fefefefe,d0
	and.l	d0,(a6)+
	and.l	d0,(a6)+
	and.b	d0,(a6)
	moveq	#NB_LINES/2,d0
	lea	Rotate_table+$8000,a6
	move	(a2)+,d5
	asr	d5
	bcc.s	.Second_half
.Rotate:	ROTATE
.Second_half:	ROTATE
	dbf	d5,.Rotate

	IFNE	CPU_TIME
	tst.b	Cpu_time_flag
	beq.s	.Skip_cpu2
	clr	$ffff8240.w
.Skip_cpu2:
	ENDC
	rts
		;#] Incremental Rotate:
	ENDC
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
Rfacette2:	lea	Project(pc),a1

	move.l	0(a1,d0),d0	;Xa/Ya
	move	(a2)+,d1
	move.l	0(a1,d1),d1	;Xb/Yb
	move	(a2)+,d2
	move.l	0(a1,d2),d2	;Xc/Yc

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

.Show:	lea	Segments(pc),a4
	move.l	a4,a6
	movem.l	d0/d1/d2,(a4)
	lea	12(a4),a4

	moveq	#3,d6
	move.l	a2,a3
	rept	4
	move	(a3)+,d0
	bmi.s	.Frpoint
	move.l	0(a1,d0),d1	;26
	swap	d1
	move.l	d1,(a4)+
	addq	#1,d6
	endr

	move	(a3)+,d0
	bmi.s	.Frpoint
	move.l	0(a1,d0),d1
	swap	d1
	move.l	d1,(a4)
	addq	#1,d6

.Frpoint:	lea	10(a2),a2
	move	(a2)+,d7	;Get color
	move.l	a2,-(a7)
	jsr	Polygone(pc)
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
	move.l	a2,-(a7)
	lea	-4*MAX_POINTS(a7),a7
	move.l	d0,a2

	move.l	a7,a1
	move.l	Old_curve(pc),Current_curve
	jsr	Calcobj(pc)
	move.l	(a2),a2
	move	(a2)+,d0
	bmi	.End_child_object

.Child_object:	lea	Segments(pc),a4
	move.l	a4,a6

	move.l	0(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	rept	2
	move	(a2)+,d0
	move.l	0(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	endr

	moveq	#3,d6
	move.l	a2,a3
	rept	5
	move	(a3)+,d0
	bmi.s	.Last_vertex
	move.l	0(a7,d0),d0
	swap	d0
	move.l	d0,(a4)+
	addq	#1,d6
	endr

	;move	(a3),d0
	;bmi.s	.End_child_object
	;move.l	0(a7,d0),d1
	;swap	d1
	;move.l	d1,(a4)
	;addq	#1,d6

.Last_vertex:	lea	10(a2),a2
	move	(a2)+,d7
	move.l	a2,-(a7)
	jsr	Polygone(pc)
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
	 ;#] Draw Object:
	 ;#[ Pseudo DATA Section:
Cpu_time_flag:		ds.b	1
		even
Null_curve:		ds.w	3
End_null:
Project:		ds.l	4*MAX_POINTS
Segments:		ds.l	4*MAX_POINTS
Screen_list:		ds.l	NB_SCREEN-1
Work_screen:		ds.l	1

Current_object:	ds.l	1
Current_curve:		ds.l	1
Current_anim:		ds.l	1
Old_curve:		ds.l	1

Start_curve:		ds.l	1
End_curve:		ds.l	1
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

Frame_counter:		ds.w	1
Vbl_counter:		ds.w	1
Cptwaiting:		ds.w	1
Nb_frames:		ds.w	1
	IFNE	MULS
Matrix:		ds.w	9
	ELSEIF
Matrix:		ds.b	9+2	;Due to MOVEP
	ENDC
		even
		;#[ Trigonometric Tables:
	IFNE	MULS
Sincos:	incbin	Sincos.bin
	ELSEIF
Sincos4:	incbin	Sincos4.bin
Sincos8:	incbin	Sincos8.bin
	ENDC
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
	IFNE	BACKGRND
	ds.l	16
Background:	incbin	backgrnd.img
	ds.l	16
	ENDC
	 ;#] Pseudo DATA Section:
	 ;#[ MAD MAX Music:
	IFNE	MUSIC

Set_music:	LEA	la2e,A0
	moveq	#MUS_NB,d0
	bsr.s	Initmus
	rts


Voicefin:	dc.w	0
Count:	dc.l	0
Endvoice:	dc.l	0

	rsreset

Off22 = 0	;rs.l	1	;ptr courant dans pattern
Off0 = 4	;rs.l	1	;ptr base patterns
Off34 = 8	;rs.l	1	;ptr fin musique

Off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
Offa = 14	;rs.l	1	;ptr base modulation volume
Offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
Off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
Off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

Off38 = 26	;rs.l	1	;incr‚ment pour crescendo

Off8 = 30	;rs.b	1
Off9 = 31	;rs.b	1

Off16 = 32	;rs.b	1
Off17 = 33	;rs.b	1
Off18 = 34	;rs.b	1
Off19 = 35	;rs.b	1
Off1a = 36	;rs.b	1
Off1b = 37	;rs.b	1
Off1c = 38	;rs.b	1
Off1d = 39	;rs.b	1
Off1e = 40	;rs.b	1
Off1f = 41	;rs.b	1
Off21 = 42	;rs.b	1

Off26 = 43	;rs.b	1
Off27 = 44	;rs.b	1
Off28 = 45	;rs.b	1	;15-volume sonore de la voix
Off2a = 46	;rs.b	1	;0,1 ou 2=type de son
Off2b = 47	;rs.b	1
Off2c = 48	;rs.b	1
Off2d = 49	;rs.b	1	;volume sonore calcul‚
Off2e = 50	;rs.b	1
Off3c = 52	;EQU	(__RS+1)&-2

;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;

Initmus:	tst	d0	;musique=0 -> cut mus
	beq	lca
	subq	#1,d0

	lea	PSG_reg(pc),a6
	move.l	a0,l934-PSG_reg(a6)
	move.l	4(a0),a1
	add.l	a0,a1
	move.l	a1,l938-PSG_reg(a6)
	move.l	8(a0),a1
	add.l	a0,a1
	move.l	a1,l93c-PSG_reg(a6)
	move.l	$c(a0),a1
	add.l	a0,a1
	move.l	a1,l91a-PSG_reg(a6)
	move.l	$10(a0),a1
	add.l	a0,a1
	move.l	a1,l916-PSG_reg(a6)
	move.l	$14(a0),a1
	add.l	a0,a1
	move.l	a1,Endvoice
	add	d0,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0
	add	d0,a1
	moveq	#$c,d7
	mulu	(a1)+,d7	;premier pattern
	move	(a1)+,d6
	addq	#1,d6
	mulu	#$c,d6	;dernier pattern
	move	(a1)+,d0
	move.b	d0,l810-PSG_reg(a6)

	moveq	#0,d0
	lea	Voice0(pc),a0
	lea	l7c6(pc),a1
l658:	move.l	a1,Offa(a0)
	clr	Offe(a0)
	clr.b	Off2d(a0)
	clr.b	Off8(a0)
	clr.b	Off9(a0)
	move.l	a1,Off12(a0)
	clr	Off30(a0)
	move.b	#1,Off17(a0)
	move.b	#1,Off18(a0)
	clr.b	Off19(a0)
	clr.b	Off1a(a0)
	clr.b	Off1b(a0)
	clr.b	Off1c(a0)
	clr.b	Off1d(a0)
	clr.b	Off1e(a0)
	clr.b	Off1f(a0)
	move.l	d0,d3
	move.b	d3,Off21(a0)
	add	d3,d3
	add	d3,d3
	move.l	l916(pc),d1
	add.l	d7,d1
	add.l	d3,d1
	move.l	d1,Off0(a0)
	move.l	d1,a3
	move.l	l916(pc),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,Off34(a0)
	move	#$c,Off4(a0)
	moveq	#0,d1
	move.b	(a3)+,d1
	add	d1,d1
	move.l	l91a(pc),a4
	move	(a4,d1),a4
	add.l	l934(pc),a4
	move.l	a4,(a0)
	clr.b	Off26(a0)
	clr.b	Off27(a0)
	move.b	#2,Off2a(a0)
	move.b	(a3)+,Off2c(a0)
	clr.b	Off2b(a0)
	move.b	(a3)+,Off16(a0)
	moveq	#$10,d1
	add.b	(a3),d1
	bcs.s	l712
	moveq	#0,d1
l712:
	move.b	d1,Off28(a0)
	clr.l	Off38(a0)
	lea	Off3c(a0),a0
	addq	#1,d0
	cmp	#3,d0
	bcs	l658
	move.b	#1,l80e-PSG_reg(a6)
	clr	l812-PSG_reg(a6)

	clr.b	$22(a6)
	clr.b	$26(a6)
	clr.b	$2a(a6)
	movem.l	$1c(a6),d0-d3
	movem.l	d0-d3,$ffff8800.w
	rts
lca:	lea	l812(pc),a0
	st	(a0)

Play_music:
l12c:	lea	PSG_reg(pc),a6
	tst.b	l812-PSG_reg(a6)
	beq.s	l160
	tas	l813-PSG_reg(a6)
	bne.s	l15e
	clr.b	$22(a6)
	clr.b	$26(a6)
	clr.b	$2a(a6)
	movem.l	$1c(a6),d0-d3
	movem.l	d0-d3,$ffff8800.w
l15e:	rts
l160:	subq.b	#1,l80e-PSG_reg(a6)
	bne.s	l180
	move.b	l810-PSG_reg(a6),l80e-PSG_reg(a6)
	moveq	#0,d5
	lea	Voice0(pc),a0
	bsr.s	l25c
	lea	Voice1(pc),a0
	bsr.s	l25c
	lea	Voice2(pc),a0
	bsr.s	l25c
l180:	move.b	#$c0,$1e(a6)
	lea	Voice0(pc),a0
	bsr	l39a
	move	d0,6(a6)
	move.b	d0,2(a6)
	move.b	d1,$22(a6)
	lea	Voice1(pc),a0
	bsr	l39a
	move	d0,$e(a6)
	move.b	d0,$a(a6)
	move.b	d1,$26(a6)
	lea	Voice2(pc),a0
	bsr	l39a
	move	d0,$16(a6)
	move.b	d0,$12(a6)
	move.b	d1,$2a(a6)
	movem.l	(a6),d0-d7/a0-a2
	movem.l	d0-d7/a0-a2,$ffff8800.w
l25a:	rts

;
; calcule nouvelle note
;

l25c:	subq.b	#1,Off26(a0)
	bpl.s	l25a
	move.b	Off27(a0),Off26(a0)
	move.l	(a0),a1
l26c:	move.b	(a1)+,d0
	cmp.b	#$ff,d0
	bne.s	l2e2
	move.l	Off0(a0),a1
	add	Off4(a0),a1
	cmp.l	Off34(a0),a1
	bcs.s	l288
	addq	#1,Voicefin
	move	d5,Off4(a0)
	move.l	Off0(a0),a1
l288:	moveq	#0,d1
	move.b	(a1)+,d1
	move.b	(a1)+,Off2c(a0)
	move.b	(a1)+,Off16(a0)
	moveq	#$10,d0
	add.b	(a1)+,d0
	bcc.s	l2b4
	move.b	d0,Off28(a0)	;f0-ff=volume … soustraire
	bra.s	l2c4
l2b4:	add.b	#$10,d0
	bcc.s	l2c4
	move.b	d0,l810-PSG_reg(a6)	;e0-ef=vitesse
l2c4:	add	d1,d1
	move.l	l91a(pc),a1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move.l	a1,(a0)
	add	#$c,Off4(a0)
	bra.s	l26c
l2e2:	cmp.b	#$fe,d0
	bne.s	l2f4
	move.b	(a1)+,d0
	move.b	d0,Off27(a0)
	move.b	d0,Off26(a0)
	bra.s	l26c
l2f4:	cmp.b	#$fd,d0
	bne.s	l308
	move.b	(a1)+,d0
	move.b	d0,Off27(a0)
	move.b	d0,Off26(a0)
	move.l	a1,(a0)
	rts
l308:	move.b	d0,Off8(a0)
	move.b	(a1)+,d1
	move.b	d1,Off9(a0)
	and	#$e0,d1	;d1=Off9&$e0
	beq.s	l31c
	move.b	(a1)+,Off1f(a0)
l31c:	move.l	a1,(a0)
	move.l	d5,Off38(a0)
	tst.b	d0
	bmi.s	l398
	move.b	Off9(a0),d0
	eor.b	d0,d1	;d1=Off9&$1f
	add.b	Off16(a0),d1

	move.l	l93c(pc),a1
	add	d1,d1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move	d5,Offe(a0)
	move.b	(a1)+,d1
	move.b	d1,Off17(a0)
	move.b	d1,Off18(a0)
	moveq	#0,d1
	move.b	(a1)+,d1
	move.b	(a1)+,Off1b(a0)
;	move.b	#$40,Off2e(a0)
	clr.b	Off2e(a0)
	move.b	(a1)+,d2
	move.b	d2,Off1c(a0)
	move.b	d2,Off1d(a0)
	move.b	(a1)+,Off1e(a0)
	move.l	a1,Offa(a0)
	add.b	d0,d0	;test bit 6
	bpl.s	l37a
	move.b	Off1f(a0),d1
l37a:	move.l	l938(pc),a1
	add	d1,d1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move.l	a1,Off12(a0)
	move	d5,Off30(a0)
	move.b	d5,Off1a(a0)
	move.b	d5,Off19(a0)
l398:	rts

;
; calcul de la note … jouer
;

l39a:	moveq	#0,d7
	move	Off30(a0),d6
l3a0:	tst.b	Off1a(a0)
	beq.s	l3ae
	subq.b	#1,Off1a(a0)
	bra	l4c01
l3ae:	move.l	Off12(a0),a1
	add	d6,a1
l3b6:	move.b	(a1)+,d0
	cmp.b	#$e1,d0
	beq	l4c01
	cmp.b	#$e0,d0
	bne.s	l3d8
	moveq	#$3f,d6
	and.b	(a1),d6
	move.l	Off12(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
l3d8:	cmp.b	#$e2,d0
	bne.s	l3ee
	clr	Offe(a0)
	move.b	#1,Off17(a0)
	addq	#1,d6
	bra.s	l3b6
l3ee:	cmp.b	#$e9,d0
	bne.s	l422
	move.b	#$b,$ffff8800.w
	move.b	(a1)+,$ffff8802.w
	move.l	#$0c0c0000,$ffff8800.w
	move.l	#$0d0d0a0a,$ffff8800.w
	addq	#2,d6
	bra.s	l3b6
l422:	cmp.b	#$e7,d0
	bne.s	l44a
	clr	d0
	move.b	(a1),d0
	add	d0,d0
	move.l	l938(pc),a1
	move	(a1,d0),a1
	add.l	l934(pc),a1
	move.l	a1,Off12(a0)
	clr	d6
	bra.s	l3b6
l44a:	cmp.b	#$e8,d0
	bne.s	l45e
	move.b	(a1)+,Off1a(a0)
	addq	#2,d6
	bra	l3a0
l45e:	cmp.b	#$e4,d0
	bne.s	l474
	clr.b	Off2a(a0)
	move.b	(a1)+,d7
	addq	#2,d6
	bra.s	l4ae
l474:	cmp.b	#$e5,d0
	bne.s	l488
	move.b	#1,Off2a(a0)
	addq	#1,d6
	bra	l3b6
l488:	cmp.b	#$e6,d0
	bne.s	l49a
	move.b	#2,Off2a(a0)
	addq	#1,d6
	bra.s	l4ae
l49a:	cmp.b	#$e3,d0
	bne.s	l4b0
	addq	#3,d6
	move.b	(a1)+,Off1b(a0)
	move.b	(a1)+,Off1c(a0)
l4ae:	move.b	(a1)+,d0
l4b0:
	move.b	d0,Off2b(a0)
	addq	#1,d6
l4c01:	move	d6,Off30(a0)

	;modulation volume
	move	Offe(a0),d6
l4c0:	tst.b	Off19(a0)
	beq.s	l4cc
	subq.b	#1,Off19(a0)
	bra.s	l51a
l4cc:	subq.b	#1,Off17(a0)
	bne.s	l51a
	move.b	Off18(a0),Off17(a0)

	move.l	Offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
	cmp.b	#$e0,d0
	bne.s	l512
	moveq	#$3f,d6
	and.b	(a1),d6
	subq	#5,d6
	move.l	Offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
l512:
	cmp.b	#$e8,d0
	bne.s	l4f4
	addq	#2,d6
	move.b	(a1)+,Off19(a0)
	bra.s	l4c0
l4f4:	cmp.b	#$e1,d0
	beq.s	l51a
	move.b	d0,Off2d(a0)
	addq	#1,d6
l51a:	move	d6,Offe(a0)

	clr	d5
	move.b	Off2b(a0),d5
	bmi.s	l528
	add.b	Off8(a0),d5
	add.b	Off2c(a0),d5
l528:
	lea	l94e(pc),a1
	add.b	d5,d5
	move	(a1,d5),d0

	move.b	Off2a(a0),d2	;0,1 ou 2
	beq.s	l57e

	move.b	Off21(a0),d3
	addq	#3,d3

	subq.b	#1,d2
	bne.s	l578
	subq	#3,d3
	move.b	Off2b(a0),d7
	bclr	#7,d7
	bne.s	l578
	add.b	Off8(a0),d7
l578:	bset	d3,$1e(a6)
l57e:	tst.b	d7
	beq.s	l594
	not.b	d7
	and.b	#$1f,d7
	move.b	d7,$1a(a6)
l594:	move.b	Off2e(a0),d6
	tst.b	Off1e(a0)
	beq.s	l5a4
	subq.b	#1,Off1e(a0)
	bra.s	l5fa
l5a4:	clr	d4
	move.b	Off1c(a0),d4
	clr	d1
	move.b	Off1d(a0),d1
	tst.b	d6
	bmi.s	l5ce
	sub.b	Off1b(a0),d1
	bcc.s	l5dc
	tas	d6
	moveq	#0,d1
	bra.s	l5dc
l5ce:	add.b	Off1b(a0),d1
	add.b	d4,d4
	cmp.b	d4,d1
	bcs.s	l5da
	bclr	#7,d6
	move.b	d4,d1
l5da:	lsr.b	#1,d4
l5dc:	move.b	d1,Off1d(a0)
l5e0:	sub	d4,d1
	add.b	#$a0,d5
	bcs.s	l5f8
	moveq	#$18,d4
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
l5f8:	add	d1,d0
l5fa:	eor.b	#1,d6
	move.b	d6,Off2e(a0)
	btst	#5,Off9(a0)
	beq.s	l628
	moveq	#0,d1
	move.b	Off1f(a0),d1
	ext	d1
	swap	d1
	lsr.l	#4,d1	;asr.l #4,d1 corrige bug ???
	add.l	d1,Off38(a0)
	sub	Off38(a0),d0
l628:	move.b	Off2d(a0),d1
	sub.b	Off28(a0),d1
	bpl.s	l634
	moveq	#0,d1
l634:	rts

l94e:	dc.w	$eee,$e17,$d4d,$c8e
	dc.w	$bd9,$b2f,$a8e,$9f7
	dc.w	$967,$8e0,$861,$7e8
	dc.w	$777,$70b,$6a6,$647
	dc.w	$5ec,$597,$547,$4fb
	dc.w	$4b3,$470,$430,$3f4
	dc.w	$3bb,$385,$353,$323
	dc.w	$2f6,$2cb,$2a3,$27d
	dc.w	$259,$238,$218,$1fa
	dc.w	$1dd,$1c2,$1a9,$191
	dc.w	$17b,$165,$151,$13e
	dc.w	$12c,$11c,$10c,$fd
	dc.w	$ee,$e1,$d4,$c8
	dc.w	$bd,$b2,$a8,$9f
	dc.w	$96,$8e,$86,$7e
	dc.w	$77,$70,$6a,$64
	dc.w	$5e,$59,$54,$4f
	dc.w	$4b,$47,$43,$3f
	dc.w	$3b,$38,$35,$32
	dc.w	$2f,$2c,$2a,$27
	dc.w	$25,$23,$21,$1f
	dc.w	$1d,$1c,$1a,$19
	dc.w	$17,$16,$15,$13
	dc.w	$12,$11,$10,$f
l7c6:	dc.b	1,0,0,0,0,0,0,$e1
PSG_reg:	dc.w	0,0,$101,0
	dc.w	$202,0,$303,0
	dc.w	$404,0,$505,0
	dc.w	$606,0,$707,$ffff
	dc.w	$808,0,$909,0
	dc.w	$a0a,0

l80e:	dc.b	4
l810:	dc.b	4
l812:	dc.b	-1
l813:	dc.b	0

Voice0:	ds.b	Off3c
Voice1:	ds.b	Off3c
Voice2:	ds.b	Off3c
l916:	dc.l	0
l91a:	dc.l	0
l934:	dc.l	0
l938:	dc.l	0
l93c:	dc.l	0
la2e:	incbin	atomix.pak
	ENDC

	IFNE	PCMSAMPLE
	;Utilisation du processeur sonore PCM du STE
PCM_STARTA	EQU	$FFFF8903
PCM_STARTB	EQU	$FFFF8905
PCM_STARTC	EQU	$FFFF8907

PCM_ENDA	EQU	$FFFF890F
PCM_ENDB	EQU	$FFFF8911
PCM_ENDC	EQU	$FFFF8913


KHZ_6	EQU	0
KHZ_12	EQU	1
KHZ_25	EQU	2
KHZ_50	EQU	3

PCMMONO	EQU	$A0

PCM_FREQUENCY	EQU	$FFFF8920
PCM_MODE	EQU	$FFFF8900
PCM_VOLUME	EQU	$FFFF8922

;-------- Initialisation du PCM ----------------------------
;
InitPCM:	lea	Sample(PC),A0
	lea	Fsample,A1
	jsr	ConvertPCM(PC)

	move.l	#Sample,D0	;init adresse de depart
	swap	D0
	move.b	D0,PCM_STARTA
	swap	D0
	move.b	D0,PCM_STARTC
	lsr	#8,D0
	move.b	D0,PCM_STARTB

	move.l	#Fsample,D0	;init adresse de fin
	swap	D0
	move.b	D0,PCM_ENDA
	swap	D0
	move.b	D0,PCM_ENDC
	lsr	#8,D0
	move.b	D0,PCM_ENDB
	move.w	#$A1,PCM_FREQUENCY
	move.w	#$3,PCM_MODE
	rts

;------- Convertion au format PCM 8 bits sign‚s -----------
;
;	A0 = adresse de depart
;	D0 = longueur de l'‚chantillon

ConvertPCM:
.Crm:	sub.b	#128,(A0)+
	cmp.l	A0,A1
	bne.s	.Crm
	rts

	dc.l	0
Sample:	incbin	tout.spl
Fsample:
	EVEN

	ENDC
	 ;#] MAD MAX Music:
	 ;#[ CLS Header:
MC68030_cls:	move.l	Work_screen,a6
	lea	160*NB_LINES(a6),a6
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
	jmp	.End_tower-15*8(pc)
	CNOP	4,0
.Clear_screen:
	REPT	31
	movem.l	(a5)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,-(a6)
	ENDR
	ELSEIF
	moveq	#10,d0
	jmp	.End_tower-36*4(pc)
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
	 ;#] CLS Header:
	 ;#[ BSS Section:
		BSS
Mouse_flag:		ds.b	1
		even
Sys_stack:		ds.l	1
Sys_rez:		ds.w	1
Sys_vbl:		ds.l	1
Sys_mfp		ds.l	1
Sys_zero:		ds.l	1
Sys_ikbd:		ds.l	1
Sys_screen:		ds.l	1
Sys_palette:		ds.w	16
	IFEQ	MULS
Rotate_table:		ds.w	$8000
	ENDC
Screen2:		ds.b	256+32000*(NB_SCREEN-1)

;----------- table de CLIPPING en x ---------------------
Llimit:		ds.l	CLIPSIZE*2
Tlimit:		ds.l	160*2
Mlimit:		ds.l	160*2
Rlimit:		ds.l	CLIPSIZE*2

Top_of_stack:		ds.l	1000
Mystack:
	 ;#] BSS Section:

