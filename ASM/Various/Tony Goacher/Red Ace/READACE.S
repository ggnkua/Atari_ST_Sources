

START_PROGRAM  
		opt		d+,c-,o+


TIM200		equ	$4bc		*200 Hz timer ( word only )

SDOOR_CHAR	equ	143		*single door char

SCREENA 	equ	$78000

SCREENB 	equ	$70000


DEBUG		equ	0	;controls jet_pack
;				keyboard on/off
JOYCNT		equ	1	;1=joystick,0=keyboard

SHOW_COLL	equ	0	*Show man,1=yes

NUM_SPR		equ	15	*Number sprites processed


LKEY		equ	$4b	*Weapon sel left (Cursor left)
RKEY		equ	$4d	*Weapon sel right (Cursor right)

DO_SAM		MACRO
		movem.l d0-d7/a0-a6,-(sp)
		movea.l	#\1,a0	;sample addr
		move.w	#\2,d0	;sample length
		move.w	#\3,d1	;freq0=3,1=4,2=5
		jsr	SAM_SET
		movem.l (sp)+,d0-d7/a0-a6
		ENDM

DO_SOUND	MACRO
		move.w	#\2,d0		;priority level
		lea	SG1_PRIOR(pc),a6
		cmp.w	(a6),d0
		bge	no_dosound\@
		pea	\1(pc)		;sound table address
		move.w	#32,-(sp)
		trap	#14
		addq.l	#6,sp
		move.w	#-1,d0
		bra	exit_dosound\@
no_dosound\@
		clr.w	d0
exit_dosound\@
		ENDM


**********************************************************************************************
**********************************************************************************************
**********************************************************************************************

STARTPRG	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		
		lea	$6f000,a7	* KKKK: to make it run on 512k machines

		move.w	#$600,$484.w
		jsr	INIT_MFP
	
START
		jsr	sam_load	* loads in all samples
		jsr	act_vbi		* install VBL routines
		jsr	joyinit		* re-vector kbd
		andi.b	#$8,$484.w	* click off/rpt off/No ^G

K_NEW_GAME				* LOOPS HERE AFTER LOOSING ALL LIVES OR COMPLETING GAME
		move.w	#1,STOP_VBI	* <<<< use screen A only
		jsr	init_var	* initialise all variables	
		jsr	set_sp		* initialise sprite table
		jsr	load_title

		jsr	open_level	* load 1st level
		jsr	load_level	*       "
		jsr	close_rf	*       "
		jsr	vbb_load	* load end-of-level baddie 
		jsr	load_32x32	* load BB
		
		pea	NULL_PALL 	* make screen black
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp
		move.w	#$25,-(a7)
		trap	#14
		addq.l	#2,a7
		
		
*********************************************************************************************		
*********************************************************
*	Status bar setup				*
*	By GAH on 9/9/88				*
*	Two days before th'birthday Tony!!!!		*
*********************************************************

STATUS_SET
	move.l		#SCREENA,a0			*Scr addr
	move.l		#STAT_CHR,a3			*Char table
	move.l		#STATUS_TAB,a2			*Shape of display
	clr.l		d1
	clr.l		d2

STATUS_PUT
	move.w		(a2)+,d1			*Xpos
	move.w		(a2)+,d2			*Ypos
	move.w		(a2)+,d3			*Char
	cmpi.w		#$ff,d3
	beq		stat_drawn

	asl.w		#7,d3				*128
	lea		0(a3,d3.w),a1			*Address of data
	jsr		plot_char
	bra		status_put

STATUS_TAB
	
*	Upper line
	dc.w		00,160,31,16,160,32,32,160,33
	dc.w		48,160,34,64,160,46,80,160,47
	dc.w		96,160,31,112,160,35,128,160,36,144,160,37
	dc.w		160,160,38,176,160,39,192,160,40,208,160,34
	dc.w		224,160,46,240,160,47,256,160,31,272,160,41
	dc.w		288,160,42,304,160,34

*	Bottom line
	dc.w		0,176,43,16,176,44,32,176,44,48,176,45
	dc.w		64,176,48,80,176,49,96,176,9,112,176,50
	dc.w		128,176,13,144,176,13,160,176,13,176,176,13
	dc.w		192,176,13,208,176,13,224,176,48,240,176,49
	dc.w		256,176,8,272,176,8,288,176,8,304,176,8		* KKKK (last .w was 13)
	dc.w		0,0,255					*Term


STAT_DRAWN

***********************************************************************************************

	jsr		copy_ab			*Copy scra -> scrb
	jsr		init_pnt		*Initialise weapon pointer
	jsr		full_power		*Put power meter in

			
		moveq	#0,d0			*Room 0

DO_RM
		jsr	get_rmaddr
		jsr	room_draw

		clr.w	STOP_VBI
		jsr	set_palette
		move.w	#1,CYCLE		*Start colour 9 cycle


AGAIN						* MAIN IN-GAME LOOP HERE ***************
		
		
*******************************************************************************************
		                                
; ***************************************************************
; * Red Ace game initial animation..........................	*
; * Opens door in room 0,level 0				*
; ***************************************************************
		
OPEN_FIRSTD
		tst.w		FIRSTD_STAT		* Has door been openend??
		bne		not_firstd		* Yes it has
		
		tst.w		LEVD_STAT		* Door in action??
		bne		not_firstd		* Yes it is
	
		move.w		#14,LEVD_INC
		move.w		#-2,LEVD_DIR
		move.w		#1,LEVD_STAT
		move.w		#32,NEWX
		move.w		#49,NEWY
		 
		move.w		#2,LEVD_SUBDSTAT	* Say set new coords
		move.w		#$1eb0,LEVD_OFF		* Set offset
		move.w		#-1,FIRSTD_STAT
		bra		not_firstd
FIRSTD_STAT
		dc.w		0			* Flags first door opened

NOT_FIRSTD

***********************************************************************************************

		movea.l	#DRAW,a1		* wait for VBI end
		btst.b	#0,1(a1)
		beq	again

		tst.w	LEVD_STAT		*Sublevel door??
		bne	no_redace
		
***********************************************************************************************

MAN_MOVE

MMOV_SPD		equ	1


	tst.w		STAT_DIS
	beq		no_stdis
	jmp		gofor_stat

NO_STDIS

	tst.w		CHEAT
	bne		do_mamov

	tst.w		SHIELD
	bne		do_mamov

	tst.w		DIE			*Dying
	bne		man_done

DO_MAMOV
	tst.w		CHEAT			*Dont bother with death if cheating
	bne		not_ded2

	tst.w		DEAD_COUNT
	beq		not_ded
	subq.w		#1,DEAD_COUNT
	
	tst.w		TEMP_DIE
	bne		yep_ded
	bra		man_done

NOT_DED
	tst.w		TEMP_DIE
	beq		not_ded2

YEP_DED
	move.w		#4,DEAD_COUNT
	clr.w		TEMP_DIE
	bra		man_move

NOT_DED2

	movea.l		#MAN_STAT,a0
	movea.l		#SP_TABLE+26,a3

	move.w		JOYSTICK,JOY_HOLD

	btst.b		#0,(a0)			*Collision
	bne		proc_coll

	clr.w		d0
	or.w		HI_HIT,d0
	or.w		LEFT_HIT,d0
	or.w		RIGHT_HIT,d0
	tst.w		d0
	bne		no_ccs

	clr.w		COLL_STAT

NO_CCS

	btst.b		#2,(a0)
	bne		do_duck


	btst.b		#5,1(a0)		*Jumpin?
	bne		jumping

	btst.b		#4,1(a0)		*Facing
	bne		facing

	btst.b		#0,(a0)			*Collision
	bne		SORT_MAN

	
WALKING
	btst.b		#2,JOYSTICK+1		*left
	bne		walk_l

	btst.b		#3,JOYSTICK+1		*Right
	bne		walk_r

DONE_SS
	btst.b		#6,1(a0)		*Falling
	bne		sort_man


	btst.b		#0,JOYSTICK+1		*Up?
	beq		SORT_MAN

	tst.w		JP_FLEV			*Any fuel
	beq		init_jump		************INIT JUMP*********

	bset.b		#7,1(a0)		*Say jetpack

	bra		SORT_MAN

WALK_L
	btst.b		#3,1(a0)		*Last a right
	bne		set_face

	tst.w		LEFT_HIT
	bne		set_coll

	andi.w		#$fff3,(a0)		*Clear L/R
	ori.w		#4,(a0)			*Say left
	
	btst.b		#6,1(a0)		*Falling
	bne		done_ss

	subq.w		#MMOV_SPD,(a3)
	bra		done_ss

WALK_R
	btst.b		#2,1(a0)
	bne		set_face

	tst.w		RIGHT_HIT
	bne		set_coll

	andi.w		#$fff3,(a0)
	ori.w		#$8,(a0)		*Clear left & say R

	btst.b		#6,1(a0)
	bne		done_ss

	addq.w		#MMOV_SPD,(a3)
	bra		done_ss

SET_FACE
	move.w		MAN_STAT,MS_HOLD	*Save dir for later
	ori.w		#$10,(a0)			*Say facing
	move.w		#5,FACE_TIM		*Facing timer

FACING
	subq.w		#1,FACE_TIM
	bne		SORT_MAN

	move.w		MS_HOLD,d0
	andi.w		#$c,d0			*All but L/R
	eori.w		#$c,d0			*Swap bits
	andi.w		#$ffe3,(a0)		*Kill face & L/R
	or.w		d0,(a0)

	bra		SORT_MAN

SET_COLL
	bsr		init_coll
		
SORT_MAN

	btst.b		#6,1(a0)
	bne		do_fall


	btst.b		#4,1(a0)		*Facing
	bne		do_face


	btst.b		#7,1(a0)		*Jet packin'
	bne		do_jp
	
WALK_ANI

	tst.w		LOW_HIT
	bne		no_fall

	bset.b		#6,1(a0)
	bra		do_fall

NO_FALL
	move.w		MAN_WANI,d0		*Offset into either table

	cmpi.w		#0,d0
	beq		set_1d
	cmpi.w		#48,d0
	beq		set_1d

	move.l		#1,G_OFF
	bra		done_1d

SET_1D
	clr.l		G_OFF

DONE_1D


	btst.b		#2,1(a0)		*Left
	bne		set_wl

SET_WR
	move.l		#WR_TAB,a1
	move.l		#MAN_GRPH+12416,d2	*Collision char
	move.l		#MAN_GRPH+512,d3	*Firing char
	bra		set_walk

SET_WL
	move.l		#WL_TAB,a1
	move.l		#MAN_GRPH+8192,d3	*Fire char
	move.l		#MAN_GRPH+12672,d2	*Collision char

SET_WALK
	lea		0(a1,d0.w),a1		*Offset into table

	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1)+,56(a3)
	move.l		(a1)+,82(a3)

	move.w		(a3),d0			*Man xpos
	move.w		2(a3),d1		*Man ypos

	move.w		d0,52(a3)
	move.w		d1,28(a3)
	addi.w		#16,d0
	addi.w		#16,d1
	move.w		d0,26(a3)
	move.w		d0,78(a3)
	move.w		d1,54(a3)
	move.w		d1,80(a3)

	btst.b		#1,JOY_HOLD+1		*Down
	bne		init_duck

	btst.b		#0,(a0)			*Collision
	beq		no_wcoll

	move.l		d2,4(a3)
	addi.l		#128,d2
	move.l		d2,30(a3)

NO_WCOLL
	tst.w		SHOOTIN			*Any flames
	beq		no_wfire

	move.l		d3,4(a3)
	addi.l		#128,d3
	move.l		d3,30(a3)
	
	addq.w		#1,FIRE_TIM
	cmpi.w		#6,FIRE_TIM
	bne		no_wfire
	clr.w		FIRE_TIM
	clr.w		SHOOTIN

NO_WFIRE
	andi.w		#$c,JOY_HOLD		*Left or Right?
	beq		man_done

	addq.w		#1,MAN_WANTIM
	cmpi.w		#6,MAN_WANTIM		*Animation time
	blt		man_done

	clr.w		MAN_WANTIM
	addi.w		#16,MAN_WANI
	cmpi.w		#96,MAN_WANI
	bne		man_done

	clr.w		MAN_WANI
	bra		man_done

INIT_DUCK
	bset.b		#2,(a0)

DO_DUCK
	move.l		#6,G_OFF
	btst.b		#2,1(a0)		*Left
	bne		duk_l

DUK_R
	movea.l		#DUK_RT,a1
	tst.w		SHOOTIN
	beq		don_duk

	movea.l		#DUK_RST,a1
	bra		don_duk

DUK_L
	movea.l		#DUK_LT,a1
	tst.w		SHOOTIN
	beq		don_duk
	movea.l		#DUK_LST,a1

DON_DUK
	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1)+,56(a3)
	move.l		(a1),82(a3)

	tst.w		SHOOTIN
	beq		no_kdsh

	addq.w		#1,DSH_TIM
	cmp.w		#6,DSH_TIM
	bne		no_kdsh

	clr.w		SHOOTIN
	clr.w		DSH_TIM

NO_KDSH
	btst.b		#1,JOY_HOLD+1		*Down
	bne		man_done
	bclr.b		#2,(a0)			*No more duck
	bra		man_done

DEAD_COUNT
	dc.w		0

DSH_TIM
	dc.w		0


DUK_RT
	DC.L		MAN_GRPH+13440,MAN_GRPH+13568
	DC.L		MAN_GRPH+13696,MAN_GRPH+13824

DUK_RST
	DC.L		MAN_GRPH+12928,MAN_GRPH+13056
	DC.L		MAN_GRPH+13184,MAN_GRPH+13312

DUK_LT
	DC.L		MAN_GRPH+14976,MAN_GRPH+15104
	DC.L		MAN_GRPH+15232,MAN_GRPH+15360

DUK_LST
	DC.L		MAN_GRPH+14464,MAN_GRPH+14592
	DC.L		MAN_GRPH+14720,MAN_GRPH+14848


MAN_STAT
	dc.w		0

FACE_TIM
	dc.w		0

COLL_TIM
	dc.w		0

MAN_WANTIM
	dc.w		0
MAN_WANI
	dc.w		0
MS_HOLD
	dc.w		0
JOY_HOLD
	dc.w		0
SHOOTIN
	dc.w		0

FIRE_TIM
	dc.w		0



WR_TAB
	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+768
	dc.l		MAN_GRPH+896

	dc.l		MAN_GRPH,MAN_GRPH+128,MAN_GRPH+1024
	dc.l		MAN_GRPH+1152

	dc.l		MAN_GRPH,MAN_GRPH+128,MAN_GRPH+1280
	dc.l		MAN_GRPH+1408

	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+1536
	dc.l		MAN_GRPH+1664

	dc.l		MAN_GRPH,MAN_GRPH+128,MAN_GRPH+1792
	dc.l		MAN_GRPH+1920

	dc.l		MAN_GRPH,MAN_GRPH+128,MAN_GRPH+2048
	dc.l		MAN_GRPH+2176

WL_TAB
	dc.l		MAN_GRPH+7936,MAN_GRPH+8064,MAN_GRPH+8448
	dc.l		MAN_GRPH+8576

	dc.l		MAN_GRPH+7680,MAN_GRPH+7808,MAN_GRPH+8704
	dc.l		MAN_GRPH+8832

	dc.l		MAN_GRPH+7680,MAN_GRPH+7808,MAN_GRPH+8960
	dc.l		MAN_GRPH+9088

	dc.l		MAN_GRPH+7936,MAN_GRPH+8064,MAN_GRPH+9216
	dc.l		MAN_GRPH+9344

	dc.l		MAN_GRPH+7680,MAN_GRPH+7808,MAN_GRPH+9472
	dc.l		MAN_GRPH+9600

	dc.l		MAN_GRPH+7680,MAN_GRPH+7808,MAN_GRPH+9728
	dc.l		MAN_GRPH+9856

FALL_LFTTAB
	dc.l		MAN_GRPH+7936,MAN_GRPH+10624,MAN_GRPH+11520

FALL_RGTTAB
	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+3456

JPR_HOVT
	dc.l		MAN_GRPH+2944,MAN_GRPH+384,MAN_GRPH+3456
	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+3456

JPR_HOVST
	dc.l		MAN_GRPH+3200,MAN_GRPH+640,MAN_GRPH+3456
	dc.l		MAN_GRPH+512,MAN_GRPH+640,MAN_GRPH+3456

JPR_DOWT
	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+3456
	dc.l		MAN_GRPH+256,MAN_GRPH+384,MAN_GRPH+3456

JPR_DOWST
	dc.l		MAN_GRPH+512,MAN_GRPH+640,MAN_GRPH+3456
	dc.l		MAN_GRPH+512,MAN_GRPH+640,MAN_GRPH+3456

JPR_MOVT
	dc.l		MAN_GRPH+3072,MAN_GRPH+384,MAN_GRPH+3328
	dc.l		MAN_GRPH+2944,MAN_GRPH+384,MAN_GRPH+3328

JPR_MOVST
	dc.l		MAN_GRPH+3200,MAN_GRPH+640,MAN_GRPH+3328
	dc.l		MAN_GRPH+3200,MAN_GRPH+640,MAN_GRPH+3328
	
JPR_UPT
	dc.l		MAN_GRPH+3072,MAN_GRPH+384,MAN_GRPH+3456
	dc.l		MAN_GRPH+2944,MAN_GRPH+384,MAN_GRPH+3456

JPR_UPST
	dc.l		MAN_GRPH+3200,MAN_GRPH+640,MAN_GRPH+3456
	dc.l		MAN_GRPH+3200,MAN_GRPH+640,MAN_GRPH+3456

JPR_HCOLT
	dc.l		MAN_GRPH+12416,MAN_GRPH+12544,MAN_GRPH+3456

JPR_VCOLT
	dc.l		MAN_GRPH+11648,MAN_GRPH+11776,MAN_GRPH+11904


JPL_HOVT
	dc.l		MAN_GRPH+7936,MAN_GRPH+10752,MAN_GRPH+11520
	DC.L		MAN_GRPH+7936,MAN_GRPH+10624,MAN_GRPH+11520

JPL_HOVST
	DC.L		MAN_GRPH+8192,MAN_GRPH+10496,MAN_GRPH+11520
	DC.L		MAN_GRPH+8192,MAN_GRPH+8320,MAN_GRPH+11520

JPL_DOWT
	DC.L		MAN_GRPH+7936,MAN_GRPH+10624,MAN_GRPH+11520
	DC.L		MAN_GRPH+7936,MAN_GRPH+10624,MAN_GRPH+11520

JPL_DOWST
	DC.L		MAN_GRPH+8192,MAN_GRPH+8320,MAN_GRPH+11520
	DC.L		MAN_GRPH+8192,MAN_GRPH+8320,MAN_GRPH+11520

JPL_MOVT
	DC.L		MAN_GRPH+7936,MAN_GRPH+10880,MAN_GRPH+11392
	DC.L		MAN_GRPH+7936,MAN_GRPH+10752,MAN_GRPH+11392

JPL_MOVST
	DC.L		MAN_GRPH+8192,MAN_GRPH+10496,MAN_GRPH+11392
	DC.L		MAN_GRPH+8192,MAN_GRPH+10496,MAN_GRPH+11392

JPL_UPT
	DC.L		MAN_GRPH+7936,MAN_GRPH+10880,MAN_GRPH+11520
	DC.L		MAN_GRPH+7936,MAN_GRPH+10752,MAN_GRPH+11520

JPL_UPST
	DC.L		MAN_GRPH+8192,MAN_GRPH+10496,MAN_GRPH+11520
	DC.L		MAN_GRPH+8192,MAN_GRPH+10496,MAN_GRPH+11520

JPL_HCOLT
	DC.L		MAN_GRPH+12672,MAN_GRPH+12800,MAN_GRPH+11520

JPL_VCOLT
	DC.L		MAN_GRPH+12032,MAN_GRPH+12160,MAN_GRPH+12288

JP_ANITIM
	dc.w		0


FAL_STIM
	dc.w		0		*Fall display flames time

JP_TIM
	dc.w		0

JP_INC
	dc.l		0
JPCOLL_TIM
	dc.w		0

JUMP_STAGE
	dc.w		0

JUMP_STAT
	dc.w		0

JUMP_ANG
	DC.W		0
JMP_SHT
	dc.w		0		*Jmp shootin timer


JS1R_T
	dc.l		MAN_GRPH+13440,MAN_GRPH+13568
	dc.l		MAN_GRPH+13696,MAN_GRPH+13824

JS2R_T
	dc.l		MAN_GRPH+256,MAN_GRPH+384
	dc.l		MAN_GRPH+13952,MAN_GRPH+14080

JS3R_T
	dc.l		MAN_GRPH+256,MAN_GRPH+384
	dc.l		MAN_GRPH+13952,MAN_GRPH+14080

JS4R_T
	dc.l		MAN_GRPH+256,MAN_GRPH+384
	dc.l		MAN_GRPH+13952,MAN_GRPH+14080

JS5R_T
	dc.l		MAN_GRPH+256,MAN_GRPH+384
	dc.l		MAN_GRPH+14208,MAN_GRPH+14336

JS6R_T
	dc.l		MAN_GRPH+256,MAN_GRPH+384
	dc.l		MAN_GRPH+14208,MAN_GRPH+14336

JS7R_T
	dc.l		MAN_GRPH+13440,MAN_GRPH+13568
	DC.L		MAN_GRPH+13696,MAN_GRPH+13824


JS1L_T
	DC.L		MAN_GRPH+14976,MAN_GRPH+15104
	DC.L		MAN_GRPH+15232,MAN_GRPH+15360

JS2L_T
	DC.L		MAN_GRPH+7936,MAN_GRPH+8064
	DC.L		MAN_GRPH+15488,MAN_GRPH+15616

JS3L_T
	DC.L		MAN_GRPH+7936,MAN_GRPH+8064
	DC.L		MAN_GRPH+15488,MAN_GRPH+15616

JS4L_T
	DC.L		MAN_GRPH+7936,MAN_GRPH+8064
	DC.L		MAN_GRPH+15488,MAN_GRPH+15616

JS5L_T
	DC.L		MAN_GRPH+7936,MAN_GRPH+8064
	DC.L		MAN_GRPH+15744,MAN_GRPH+15872

JS6L_T
	DC.L		MAN_GRPH+7936,MAN_GRPH+8064
	DC.L		MAN_GRPH+15744,MAN_GRPH+15872

JS7L_T
	DC.L		MAN_GRPH+14976,MAN_GRPH+15104
	DC.L		MAN_GRPH+15232,MAN_GRPH+15360

JMP_HCOLR
	DC.L		MAN_GRPH+12416,MAN_GRPH+12544
	DC.L		MAN_GRPH+13952,MAN_GRPH+14080
JMP_HCOLL
	DC.L		MAN_GRPH+12672,MAN_GRPH+12800
	DC.L		MAN_GRPH+15488,MAN_GRPH+15616
JMP_VCOLR
	DC.L		MAN_GRPH+13440,MAN_GRPH+13568
	DC.L		MAN_GRPH+13696,MAN_GRPH+13824
JMP_VCOLL
	DC.L		MAN_GRPH+14976,MAN_GRPH+15104
	DC.L		MAN_GRPH+15232,MAN_GRPH+15360


COLL_STAT
	dc.w		0


INIT_JUMP
	tst.w		LOW_HIT
	bne		no_nojump
	bset.b		#6,1(a0)		*Set fall
	bra		man_done

NO_NOJUMP
	DO_SAM		HUP,HUP_LEN,0

	clr.w		JUMP_STAGE
	bset.b		#5,1(a0)		*Say jumpin'

	move.w		JOY_HOLD,d0		*Last joystick
	andi.w		#$c,d0			*Left/right
	move.w		d0,JUMP_STAT		*<>0 if horizontal jmp


JUMPING
	clr.l	 	G_OFF
	move.w		JUMP_STAT,d1
	
	move.w		JUMP_STAGE,d0
	cmpi.w		#16,d0
	ble		js1			*Crouch 1

	cmpi.w		#32,d0
	ble		js2			*Up 1

	cmpi.w		#48,d0
	ble		js3			*Up 2

	cmpi.w		#64,d0
	ble		js4			*Horizontal

	cmpi.w		#80,d0
	ble		js5			*Down 1

	cmpi.w		#96,d0
	ble		js6			*Down 2

	cmpi.w		#112,d0
	ble		js7			*Crouch 2/land

KILL_JUMP
	bclr.b		#5,1(a0)
	clr.w		MAN_WANI
	bra		man_done

JS1
	clr.w		SHOOTIN			*No flames when 
						*crouched
	move.l		#5,G_OFF		*Set offset
	btst.b		#2,1(a0)		*Left
	bne		js1l

JS1R
	movea.l		#JS1R_T,a1
	bra		put_jump
JS1L
	movea.l		#JS1L_T,a1
	bra		put_jump

JS2
	btst.b		#2,1(a0)		*Left
	bne		js2l

JS2R

	tst.w		RIGHT_HIT
	bne		jmp_ch	************************
	tst.w		HI_HIT
	bne		jmp_cv	************************

	tst.w		d1			*Any hor
	beq		noh2r

	addq.w		#1,(a3)
NOH2R
	subq.w		#1,2(a3)
	
	movea.l		#JS2R_T,a1
	bra		put_jump
		
JS2L
	tst.w		LEFT_HIT
	bne		jmp_ch	************************
	tst.w		HI_HIT
	bne		jmp_cv	************************

	tst.w		d1
	beq		noh2l

	subq.w		#1,(a3)
NOH2L
	subq.w		#1,2(a3)
	
	movea.l		#JS2L_T,a1
	bra		put_jump

JS3
	btst.b		#2,1(a0)
	bne		js3l

JS3R
	tst.w		RIGHT_HIT
	bne		jmp_ch		*******************
	tst.w		HI_HIT
	bne		jmp_cv		*********************

	tst.w		d1
	beq		noh3r

	addq.w		#1,(a3)
NOH3R
	move.w		JUMP_ANG,d0
	sub.w		d0,2(a3)
	eori.w		#1,JUMP_ANG
	movea.l		#JS3R_T,a1
	bra		put_jump

JS3L
	tst.w		LEFT_HIT
	bne		jmp_ch		*******************
	tst.w		HI_HIT
	bne		jmp_cv		*********************

	tst.w		d1
	beq		noh3l

	subq.w		#1,(a3)
NOH3L
	move.w		JUMP_ANG,d0
	sub.w		d0,2(a3)
	eori.w		#1,JUMP_ANG
	movea.l		#JS3L_T,a1
	bra		put_jump

JS4
	btst.b		#2,1(a0)
	bne		js4l

JS4R
	
	tst.w		RIGHT_HIT
	bne		jmp_ch		*******************

	tst.w		d1
	beq		noh4r

	addq.w		#1,(a3)
NOH4R
	movea.l		#JS4R_T,a1
	bra		put_jump

JMP_CH		
*	Set horizontal jump collision
	btst.b		#2,1(a0)		*Left
	bne		jcoll_l

	movea.l		#JMP_HCOLR,a1
	bra		set_jmpc

JCOLL_L
	movea.l		#JMP_HCOLL,a1
	bra		set_jmpc

JMP_CV
	btst.b		#2,1(a0)
	bne		jcoll_vl

	movea.l		#JMP_VCOLR,a1
	bra		set_jmpc

JCOLL_VL
	movea.l		#JMP_VCOLL,a1

SET_JMPC
	bsr		init_coll

	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1)+,56(a3)
	move.l		(a1),82(a3)
	
NC1
	bclr.b		#5,1(a0)

	bra		man_done


PROC_COLL
	addq.w		#1,COLL_TIM
	cmp.w		#10,COLL_TIM
	bne		man_done
	bclr.b		#0,(a0)
	clr.w		COLL_TIM
	bra		man_done

JS4L
	tst.w		LEFT_HIT
	bne		jmp_ch		*******************

	tst.w		d1
	beq		noh4l
	subq.w		#1,(a3)
NOH4L
	movea.l		#JS4L_T,a1
	bra		put_jump

JS5
	btst.b		#2,1(a0)
	bne		js5l

JS5R
	tst.w		RIGHT_HIT
	bne		jmp_ch
	tst.w		LOW_HIT
	bne		init_land

	
	move.w		JUMP_ANG,d0
	add.w		d0,2(a3)
	eori.w		#1,JUMP_ANG
	
	tst.w		d1
	beq		noh4r

	movea.l		#JS5R_T,a1
	addq.w		#1,(a3)

	bra		put_jump

JS5L
	tst.w		LEFT_HIT
	bne		jmp_ch
	tst.w		LOW_HIT
	bne		init_land


	move.w		JUMP_ANG,d0
	add.w		d0,2(a3)
	eori.w		#1,JUMP_ANG

	tst.w		d1
	beq		noh4l

	movea.l		#JS5L_T,a1
	subq.w		#1,(a3)

	bra		put_jump

JS6
	btst.b		#2,1(a0)
	bne		js6l

JS6R
	tst.w		RIGHT_HIT
	bne		jmp_ch		**************
	tst.w		LOW_HIT
	bne		init_land

	
	addq.w		#1,2(a3)
	tst.w		d1
	beq		noh4r

	movea.l		#JS6R_T,a1
	addq.w		#1,(a3)
	bra		put_jump


JS6L
	tst.w		LEFT_HIT
	bne		jmp_ch		**************
	tst.w		LOW_HIT
	bne		init_land

	addq.w		#1,2(a3)

	tst.w		d1
	beq		noh4l

	subq.w		#1,(a3)
	movea.l		#JS6L_T,a1
	bra		put_jump

JS7
	clr.w		SHOOTIN		*No crouch flames

	move.l		#5,G_OFF
	tst.w		LOW_HIT
	beq		kill_jump

	btst.b		#2,1(a0)
	bne		js7l

JS7R
	movea.l		#JS7R_T,a1
	bra		put_jump

JS7L
	movea.l		#JS7L_T,a1
	
PUT_JUMP
	addq.w		#1,JUMP_STAGE

	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1)+,56(a3)
	move.l		(a1),82(a3)

	move.w		(a3),d0
	move.w		2(a3),d1
	
	move.w		d0,52(a3)
	move.w		d1,28(a3)

	addi.w		#16,d0
	addi.w		#16,d1

	move.w		d0,26(a3)
	move.w		d0,78(a3)
	move.w		d1,54(a3)
	move.w		d1,80(a3)

	tst.w		SHOOTIN
	beq		man_done

	btst.b		#2,1(a0)
	bne		jshool

	move.l		#MAN_GRPH+512,4(a3)
	move.l		#MAN_GRPH+640,30(a3)
	bra		jshooti

JSHOOL
	move.l		#MAN_GRPH+8192,4(a3)
	move.l		#MAN_GRPH+8320,30(a3)

JSHOOTI
	addq.w		#1,JMP_SHT
	cmp.w		#6,JMP_SHT
	bne		man_done
	clr.w		SHOOTIN
	clr.w		JMP_SHT
	bra		man_done

INIT_LAND
	move.w		#97,JUMP_STAGE
	bra		js7



DO_FALL
	tst.w		JP_FLEV			*ANy fuel
	beq		no_outfall

	btst.b		#0,JOY_HOLD+1		*Up
	beq		no_outfall

*Start jetpack
	bclr.b		#6,1(a0)
	bset.b		#7,1(a0)
	bra		sort_man

NO_OUTFALL

	clr.l		G_OFF

	tst.w		LOW_HIT			*Bottom coll
	bne		end_fall		
	
	******************			* KKKK
	cmp.w		#3,LEVEL_NUM		* final level?
	bne.s		NOF_1			* nope
	cmp.w		#20,ROOM_IN		* FBB room?
	bne.s		NOF_1			* no Sir	
	cmp.w		#$31,2(a3)		* Y coord when standing on start pos. ridge?
	beq.s		NOF_yok			* yes, check x then
	cmp.w		#$78,2(a3)		* Y coord when standing on bottom ground?
	bne.s		NOF_1			* no, out of here
	btst.b		#5,FBB_STAT+1		* final door already open?
	bne.s		NOF_1			* yes, falling is allowed!
	bra.s		NOF_nofall		* no, don't "fall"
NOF_yok	
	cmp.w		#$F8,(a3)		* minimum valid X?
	blt.s		NOF_1			* no, further to the left
NOF_nofall
	bclr.b		#6,1(a0)		* say: not falling
	move.w		#1,LOW_HIT		* say: stand on ground
	bra		man_done		* 
	
	******************

NOF_1
	addq.w		#1,2(a3)

	btst.b		#4,1(a0)		*Facing
	bne		do_face

	clr.l		82(a3)			*Clear 4th sprite

	btst.b		#2,1(a0)		*Left
	bne		fall_lft

FALL_RGT
	movea.l		#FALL_RGTTAB,a1
	move.l		#MAN_GRPH+512,d2	*Shoot LHS
	move.l		#MAN_GRPH+640,d3	*Shoot RHS
	bra		set_fall

FALL_LFT
	movea.l		#FALL_LFTTAB,a1
	move.l		#MAN_GRPH+8192,d2	*Shoot LHS
	move.l		#MAN_GRPH+8320,d3	*SHoot RHS

SET_FALL
	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1)+,56(a3)

	tst.w		SHOOTIN
	beq		no_shoot

	move.l		d2,4(a3)
	move.l		d3,30(a3)

	addq.w		#1,FAL_STIM
	cmp.w		#6,FAL_STIM
	bne		no_shoot

	clr.w		SHOOTIN
	clr.w		FAL_STIM

NO_SHOOT
	
	move.w		(a3),d0
	move.w		2(a3),d1
	addi.w		#8,d0
	move.w		d0,52(a3)
	addi.w		#8,d0
	move.w		d0,26(a3)
	move.w		d1,28(a3)
	addi.w		#16,d1
	move.w		d1,54(a3)
	bra		man_done

END_FALL
	bclr.b		#6,1(a0)		*Clear fall flag

	bset.b		#5,1(a0)		*Say jumpin'
	move.w		#97,JUMP_STAGE
	bra		man_done

DO_JP
	clr.l		G_OFF
	tst.w		JP_FLEV				*ANy fuel
	beq		kill_jp


	move.w		#1,JP_USE			*Say usin'
	

	btst.b		#0,JOY_HOLD+1			*Up
	bne		jp_up

	btst.b		#1,JOY_HOLD+1			*Down
	bne		jp_down

	bra		place_jp

JP_UP
	tst.w		HI_HIT
	bne		place_jp

	subq.w		#1,2(a3)

	bra		place_jp

JP_DOWN
	
	tst.w		LOW_HIT
	bne		kill_jp			******************
	addq.w		#1,2(a3)

PLACE_JP
	btst.b		#2,1(a0)
	bne		jpl

JPR

	tst.w		RIGHT_HIT
	bne		jpr_coll

	tst.w		HI_HIT
	bne		jpr_vcoll

	move.w		JOY_HOLD,d0
	andi.w		#9,d0			*Up/right
	bne		jpr_mov

	btst.b		#1,JOY_HOLD+1		*Down
	bne		jpr_down

JPR_HOV
	
	tst.w		VOLC			*ANy noize
	bne		no_hrn

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bclr.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a06,d0
	movep.w		d0,0(a6)

NO_HRN

	move.l		#JPR_HOVT,d1		*Normal hover
	move.l		#JPR_HOVST,d2		*Shootin hover
	bra		put_jp

KILL_JP
	clr.w		JP_USE
	bclr.b		#7,1(a0)

		
	tst.w		VOLC			*ANy noize
	bne		man_done

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bset.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a00,d0
	movep.w		d0,0(a6)

	bra		man_done



JPR_DOWN
	clr.w		JP_USE
	move.l		#JPR_DOWT,d1		*Normal down
	move.l		#JPR_DOWST,d2		*Shootin down
	clr.l		JP_INC			*No animation


	tst.w		VOLC			*ANy noize
	bne		put_jp

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bset.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a00,d0
	movep.w		d0,0(a6)
	bra		put_jp


JPR_MOV

	tst.w		VOLC			*ANy noize
	bne		no_jprn

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bclr.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a09,d0
	movep.w		d0,0(a6)
NO_JPRN
	btst.b		#3,JOY_HOLD+1		*Right
	beq		jpr_uponly

	move.l		#JPR_MOVT,d1		*Normal move
	move.l		#JPR_MOVST,d2		*Shootin move
	bra		put_jp
JPR_UPONLY
	move.l		#JPR_UPT,d1
	move.l		#JPR_UPST,d2
	bra		put_jp


JPR_COLL
	bsr		init_coll

	move.l		#JPR_HCOLT,d3		*Coll table
	bra		jpr_hov

JPR_VCOLL
	bsr		init_coll
	move.l		#JPR_VCOLT,d3
	bra		jpr_hov


JPL

	tst.w		LEFT_HIT
	bne		jpl_coll

	tst.w		HI_HIT
	bne		jpl_vcoll

	move.w		JOY_HOLD,d0
	andi.w		#5,d0			*Up/left
	bne		jpl_mov

	btst.b		#1,JOY_HOLD+1		*Down
	bne		jpl_down


JPL_HOV
	move.l		#JPL_HOVT,d1		*Normal hover
	move.l		#JPL_HOVST,d2		*Shootin hover

	tst.w		VOLC			*ANy noize
	bne		put_jp

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bclr.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a06,d0
	movep.w		d0,0(a6)

	bra		put_jp

JPL_DOWN
	clr.w		JP_USE
	move.l		#JPL_DOWT,d1		*Normal down
	move.l		#JPL_DOWST,d2		*Shootin down
	clr.l		JP_INC			*No animation
		
	tst.w		VOLC			*ANy noize
	bne		no_hld

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bset.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a00,d0
	movep.w		d0,0(a6)

NO_HLD

	bra		put_jp

JPL_MOV

	tst.w		VOLC			*ANy noize
	bne		no_jpln

	lea		$ffff8800.w,a6
	move.w		#$61f,d0			*Low freq
	movep.w		d0,0(a6)

	clr.w		d0
	bclr.b		#5,REG_7
	move.b		REG_7,d0
	ori.w		#$700,d0
	movep.w		d0,0(a6)
	
	move.w		#$a09,d0
	movep.w		d0,0(a6)

NO_JPLN
	btst.b		#2,JOY_HOLD+1		*Right
	beq		jpl_uponly

	move.l		#JPL_MOVT,d1		*Normal move
	move.l		#JPL_MOVST,d2		*Shootin move
	bra		put_jp
JPL_UPONLY
	move.l		#JPL_UPT,d1
	move.l		#JPL_UPST,d2
	bra		put_jp


JPL_COLL
	bsr		init_coll
	move.l		#JPL_HCOLT,d3		*Coll table
	bra		jpl_hov

JPL_VCOLL
	bsr		init_coll
	move.l		#JPL_VCOLT,d3
	bra		jpl_hov


PUT_JP
	tst.w		SHOOTIN
	beq		jp_ns

	move.l		d2,a1

	addq.w		#1,JP_TIM
	cmp.w		#6,JP_TIM
	bne		do_pjp

	clr.w		SHOOTIN
	clr.w		JP_TIM
	bra		do_pjp

JP_NS
	add.l		JP_INC,d1
	move.l		d1,a1

	btst.b		#0,(a0)			*Coll
	beq		no_jpc

	movea.l		d3,a1

NO_JPC

	tst.w		JP_ANITIM
	bne		do_pjsub
	move.w		#3,JP_ANITIM
	eori.l		#12,JP_INC		*Animate JP

DO_PJSUB
	subq.w		#1,JP_ANITIM

DO_PJP
	move.l		(a1)+,4(a3)
	move.l		(a1)+,30(a3)
	move.l		(a1),56(a3)
	clr.l		82(a3)

SET_XYJP
	move.w		(a3),d0
	move.w		2(a3),d1

	move.w		d1,28(a3)
	addi.w		#16,d1
	move.w		d1,54(a3)

	addq.w		#8,d0
	move.w		d0,52(a3)
	addq.w		#8,d0
	move.w		d0,26(a3)
	bra		man_done


INIT_COLL
	tst.w		COLL_STAT
	bne		nocoll
	bset.b		#0,(a0)
	bset.b		#1,COLL_STAT
	clr.l		JP_INC	
	DO_SAM		ARGH,ARGH_LEN,1
NOCOLL
	rts



SET_MAN
;A4=Addr of 4 word character table
;Order UL UR LL LR
	lea.l	26(a3),a5		   ;xpos sprite 1
	moveq	#3,d1

MANSET_LOOP
	movea.l	#man_grph,a6
	clr.l	d0
	move.w	(a4)+,d0
	lsl.l	#7,d0		   ;	      ;128
	adda.l	d0,a6
	move.l	a6,4(a5)
	lea.l	26(a5),a5
	dbf.w	d1,manset_loop
	rts


DO_FACE
	move.l		#MAN_GRPH+2304,4(a3)
	move.l		#MAN_GRPH+2432,30(a3)
	move.l		#MAN_GRPH+2560,56(a3)
	move.l		#MAN_GRPH+2688,82(a3)

	move.w		(a3),d0			*Man xpos
	move.w		2(a3),d1		*Man ypos

	move.w		d0,52(a3)
	move.w		d1,28(a3)
	addi.w		#16,d0
	addi.w		#16,d1			*Duplicate of
	move.w		d0,26(a3)		*coords just in case
	move.w		d0,78(a3)
	move.w		d1,54(a3)
	move.w		d1,80(a3)

MAN_DONE
	btst.b		#0,IMMUNE+1		*Flash RA??
	beq		no_raf
	movea.l		#SP_TABLE+26,a3
	clr.l		4(a3)
	clr.l		30(a3)
	clr.l		56(a3)
	clr.l		82(a3)
NO_RAF	

********************************************************************************************

*****************************************************************
*	Single Beastie collision detection			*
*	By GAH on 13/7/88					*
*	Word at sprite table offset 24 format:-----		*
*	b0-b4 = Beastie number					*
*	b5 = Not used						*
*	b6 = gravity takes effect				*
*	b7 = Animation direction				*
*	b8-b11 = Movement U/D/L/R				*
*	b12-b15 = Collision U/D/L/R				*
*****************************************************************


SBEAST_COLL
	tst.w		VBB			*Very big beastie
	bne		no_sbc

	move.l		#SP_TABLE+208,a3
	move.w		SBEA_MASK,d7		*Current # beasts
	tst.w		d7
	beq		no_sbc			*None there!!!
	subq.w		#1,d7			*Correct for dbf

CHK_BCOLL
	tst.l		4(a3)			*Active
	beq		next_cbc

	move.w		24(a3),d0		*Status
	andi.w		#$f00,d0		*Any movement
	beq		next_cbc


	tst.w		SC_NO
	bne		sbc_scb

	tst.l		20(a3)
	beq		next_cbc
	movea.l		20(a3),a6
	bra		setted

SBC_SCB
	tst.l		16(a3)
	beq		next_cbc
	movea.l		16(a3),a6

SETTED
*Now only collide in movement direction

	btst.b		#2,24(a3)
	bne		lc_chk
	btst.b		#3,24(a3)
	bne		rc_chk

DO_HCHK
	btst.b		#0,24(a3)
	bne		uc_chk
	btst.b		#1,24(a3)
	bne		dc_chk
	bra		next_cbc

RC_CHK
	bclr.b		#7,24(a3)		*Clear R coll bit
	movea.l		a6,a0
	lea		16(a0),a0		*32 Pix right
	clr.w		d4			*Clear coll flag
	bsr		do_check
	lea		1120(a0),a0		*7 lines down
	bsr		do_check
	lea		160(a0),a0		*1  down
	bsr		do_check
	lea		1120(a0),a0
	bsr		do_check

	tst.w		d4
	beq		do_hchk
	andi.w		#$f3ff,24(a3)
	ori.w		#$8400,24(a3)		*change to left

	tst.w		CIRCLE
	beq		do_hchk
	bset.b		#5,25(a3)
	
	bra		do_hchk

DO_CHECK	
*	a0=address to check from,d4=$100 ( .w)  if collision found
*	destroys d0-d3

	movem.w		(a0),d0-d3
	and.w		d3,d2
	tst.w		d2		*Upper 2 bits set??
	bne		cont_chk
	rts

CONT_CHK
	and.w		d2,d0
	and.w		d2,d1		*Mask out unwanted lwr bits
	or.w		d0,d1
	not.w		d1		*Set those under suspect
	and.w		d2,d1

	tst.w		d1
	bne		hit_set
	rts

HIT_SET
	or.w		#$1000,d4
	rts

LC_CHK
	bclr.b		#6,24(a3)		*Clear L coll bit
	clr.w		d4
	movea.l		a6,a0
	lea		-8(a0),a0		*back 16 pixels
	bsr		do_check
	lea		1120(a0),a0
	bsr		do_check
	lea		160(a0),a0
	bsr		do_check
	lea		1120(a0),a0
	bsr		do_check
	tst.w		d4
	beq		do_hchk
	andi.w		#$f3ff,24(a3)
	ori.w		#$4800,24(a3)

	tst.w		CIRCLE
	beq		do_hchk
	bset.b		#5,25(a3)

	bra		do_hchk

UC_CHK
	bclr.b		#4,24(a3)		*Clear U coll bit
	movea.l		a6,a0
	lea		-960(a0),a0		*6 lines up
	clr.w		d4
	bsr		do_check
	lea		-160(a0),a0
	bsr		do_check
	lea		8(a0),a0
	bsr		do_check
	tst.w		d4
	beq		next_cbc
	andi.w		#$fcff,24(a3)
	ori.w		#$1200,24(a3)

	tst.w		CIRCLE
	beq		next_cbc
	bset.b		#5,25(a3)

	bra		next_cbc

DC_CHK
	bclr.b		#5,24(a3)		*Clear D coll bit
	movea.l		a6,a0
	lea		2560(a0),a0		*16 lines down
	btst.b		#6,25(a3)		*Any gravity??
	bne		do_gravchk
	lea		960(a0),a0		*No,down 6 more
	

DO_GRAVCHK
	clr.w		d4
	bsr		do_check
	lea		160(a0),a0
	bsr		do_check
	lea		8(a0),a0
	bsr		do_check
	lea		152(a0),a0
	bsr		do_check
	lea		8(a0),a0
	bsr		do_check

	tst.w		d4
	beq		next_cbc
	btst.b		#6,25(a3)
	bne		some_grav

	andi.w		#$fcff,24(a3)
	ori.w		#$2100,24(a3)

	tst.w		CIRCLE
	beq		next_cbc
	bset.b		#5,25(a3)

	bra		next_cbc
SOME_GRAV
	or.w		#$2020,24(a3)		*Gravity/just set dcoll

NEXT_CBC
	lea		26(a3),a3
	dbf		d7,chk_bcoll
NO_SBC

	
********************************************************************************************

*****************************************************************
*	Man collision routine	Mk.IIb				*
*	By GAH on 14/10/88					*
*****************************************************************

MAN_COLL
	tst.w		SC_NO
	bne		cb

	movea.l		#SCREENA,a6
	bra		got_csa
CB
	movea.l		#SCREENB,a6

GOT_CSA

	clr.l		LOW_HIT
	clr.l		RIGHT_HIT

	movea.l		#SP_TABLE+26,a5

	moveq		#0,d0		
	moveq		#0,d1		

	move.w		(a5),d0		* Red Ace X pos
	move.w		2(a5),d1	* Red Ace Y pos
	addi.w		#9,d0

******Calculate bit we is lookin fur************

	move.w		d0,d6
	not.w		d6
	andi.w		#$f,d6
	moveq.w		#1,d7
	asl.w		d6,d7		*--->d7= LHS bit to look for
	andi.l		#$f,d7
	move.w		d7,d6
	not.w		d6
	andi.l		#$f,d6		*--->d6= RHS bit to look for
	

******Now calculate address of upper lines********

	asl.w		#1,d1
	move.w		d1,d2
	asl.w		#2,d1
	add.w		d2,d1
	asl.w		#4,d1

	move.w		d0,d2
	andi.w		#$fff0,d0
	lsr.w		#1,d0
	add.w		d1,d0


*******Now check for upper collision**********

	lea		0(a6,d0.l),a0
	lea		-160(a0),a0		*Up one line


	movem.w		(a0)+,d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d7,d3
	beq		no_ulcoll

	bset.b		#0,HI_HIT+1

NO_ULCOLL

	
	movem.w		(a0),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d6,d3
	beq		no_ulcolr

	bset.b		#0,HI_HIT+1

NO_ULCOLR
********Use last ADDR to get lower collision************
	
	lea		5272(a0),a0

	movem.w		(a0),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d7,d3
	beq		no_llcoll

	bset.b		#0,LOW_HIT+1

NO_LLCOLL

	
	movem.w		8(a0),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d6,d3
	beq		no_llcolr

	bset.b		#0,LOW_HIT+1

NO_LLCOLR
	lea		160(a0),a0

	movem.w		(a0),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d7,d3
	beq		no_llcoll2

	bset.b		#0,LOW_HIT+1

NO_LLCOLL2

	
	movem.w		8(a0),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d6,d3
	beq		no_llcolr2

	bset.b		#0,LOW_HIT+1

NO_LLCOLR2

******Now do horizontal checks*************
	clr.l		d4
	clr.l		d0
	move.w		(a5),d0
	move.w		2(a5),d1
	subq.w		#1,d0
	move.w		d0,d4
	move.w		d1,d5
	addi.w		#34,d4

******Calculate bit we is lookin fur************

	move.w		d0,d6
	not.w		d6
	andi.w		#$f,d6
	moveq.w		#1,d7
	asl.w		d6,d7		*--->d7= LHS bit to look for
	andi.l		#$f,d7

	move.w		d4,d2
	not.w		d2
	andi.w		#$f,d2
	moveq.w		#1,d6
	asl.w		d2,d6
	andi.w		#$f,d6		*--->d6 = RHS


******Now calculate address of upper lines********

	asl.w		#1,d1
	move.w		d1,d2
	asl.w		#2,d1
	add.w		d2,d1
	asl.w		#4,d1

	move.w		d0,d2
	andi.w		#$fff0,d0
	lsr.w		#1,d0
	add.w		d1,d0


	asl.w		#1,d5
	move.w		d5,d2
	asl.w		#2,d5
	add.w		d2,d5
	asl.w		#4,d5

	move.w		d4,d2
	andi.w		#$fff0,d4
	lsr.w		#1,d4
	add.w		d5,d4

******Now see if collision for 16 lines********


	lea		0(a6,d0.l),a1
	lea		0(a6,d4.l),a2		*RHS
	move.w		#15,d4			*Conter
CLOOP1
	movem.w		(a1),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d7,d3
	beq		no_lcoll

	bset.b		#0,LEFT_HIT+1
NO_LCOLL

	movem.w		(a2),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d6,d3
	beq		no_rcoll

	bset.b		#0,RIGHT_HIT+1
NO_RCOLL
	
	lea		160(a1),a1
	lea		160(a2),a2
	dbf.w		d4,cloop1


	clr.l		d0
	move.w		(a5),d0
	move.w		2(a5),d1
	addi.w		#16,d1
	addq.w		#8,d0

******Calculate bit we is lookin fur************

	move.w		d0,d6
	not.w		d6
	andi.w		#$f,d6
	moveq.w		#1,d7
	asl.w		d6,d7		*--->d7= LHS bit to look for
	andi.l		#$f,d7
	move.w		d7,d6
	not.w		d6
	andi.l		#$f,d6		*--->d6= RHS bit to look for

******Now calculate address of upper lines********

	asl.w		#1,d1
	move.w		d1,d2
	asl.w		#2,d1
	add.w		d2,d1
	asl.w		#4,d1

	move.w		d0,d2
	andi.w		#$fff0,d0
	lsr.w		#1,d0
	add.w		d1,d0

******Now see if collision for 16 lines********

	moveq		#14,d4
	lea		0(a6,d0.l),a1		*LHS
	lea		8(a1),a2		*RHS

CLOOP2
	movem.w		(a1),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d7,d3
	beq		no_lcollb

	bset.b		#0,LEFT_HIT+1
NO_LCOLLB

	movem.w		(a2),d0-d3

	or.w		d0,d1
	not.w		d1
	and.w		d2,d3
	and.w		d1,d3
	btst.l		d6,d3
	beq		no_rcollb

	bset.b		#0,RIGHT_HIT+1
NO_RCOLLB
	
	lea		160(a1),a1
	lea		160(a2),a2
	dbf.w		d4,cloop2
	bra		done_coll

LOW_HIT
	dc.w		0
HI_HIT
	dc.w		0
RIGHT_HIT
	dc.w		0
LEFT_HIT
	dc.w		0



DONE_COLL

*********************************************************************************************


NO_REDACE
		tst.w	LEVD_STAT
		beq	do_spera	;No sprite erase whilst doors
		tst.w	LEVD_ERCNT
		beq	done_spera
		subq.w	#1,LEVD_ERCNT	; 1 less cycle to go
DO_SPERA
		move.l	#sp_table,a6
		lea.l	NUM_SPR*26(a6),a6
		move.w	#NUM_SPR,d0	;num sprites
		clr.l	WHICH_PROC	;Default to normal
		tst.w	BB_STAT		; Any BB there??
		beq	ERLOOP
		move.l	#19,WHICH_PROC	; DO BB sprites
ERLOOP
		lea	SP_PROCTAB(pc,d0.w),a0
		adda.l	WHICH_PROC,a0	; Which do we want
		tst.b	(a0)		; Process this sprite??
		beq	next_era	; Don't process it
		jsr	get_sc
		cmpa.l	#0,a5
		beq	next_era
		jsr	clearsprite
NEXT_ERA
		lea	-26(a6),a6
		dbf	d0,erloop
		bra	done_spera
		
SP_PROCTAB
		dc.b	0,1,1,1,1,1,0,0,1,1,1,1,0,0,0,0,0,0,0	;Norm
		dc.b	0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0	;BB

		EVEN
WHICH_PROC
		dc.l	0



DONE_SPERA

***********************************************************************************************

*********************************************************
*	Very big beastie processor			*
*	By GAH on 21/10/88				*
*********************************************************

AN_TIM			equ	10
VBB_PMIN		equ	20		* KKKK Vbb pwr lev (was: 12)


VBB_PROC
	move.w		LEVEL_NUM,d0
	asl.w		d0
	move.w		d0,d1
	lea.l		WHICH_R(pc),a0		*Table of which rooms per 
						*level VBB is in
	lea		0(a0,d0.w),a0
	move.w		ROOM_IN,d0
	cmp.w		(a0),d0			*Are we in this room
	bne		no_pbb
	
	move.w		#1,VBB			*Say BB there


	tst.w		VBB_TMR
	beq		do_vbb
	subq.w		#1,VBB_TMR

DO_VBB
	tst.w		VBB_DIE			*Is it xplodin
	bne		do_vbbdie

	tst.w		VBB_PWR
	bpl		not_dyet

	move.w		#1,VBB_DIE		*Say initialise dying
	move.w		#AN_TIM,VBB_SPD
	bra		do_vbbdie
NOT_DYET

	move.w		VBB_PWR,d0
	cmpi.w		#2*VBB_PMIN/3,d0
	bge		spd_3

	cmpi.w		#VBB_PMIN/3,d0
	bge		spd_2

	move.w		#AN_TIM+4,VBB_SPD
	bra		don_spd

SPD_2
	move.w		#AN_TIM+2,VBB_SPD
	bra		don_spd

SPD_3
	move.w		#AN_TIM,VBB_SPD

DON_SPD

	move.l		#VBB_SOFF,a0		*Offsets of VBB into
						*screen for each level

	lea		0(a0,d1.w),a0
	move.w		(a0),d0			*d0=offs into scr
	move.w		d0,TMP_OFF		*Save scr offset
	
	tst.w		SC_NO
	bne		sbbsa

	movea.l		#SCREENA,a0
	bset.b		#0,VBB_SN+1		*Say which screen
	bra		find_vbbdat


SBBSA
	movea.l		#SCREENB,a0
	bset.b		#1,VBB_SN+1

FIND_VBBDAT
	move.w		LEVEL_NUM,d1
	lea		0(a0,d0.w),a0		*a0=address in screen

	move.w		VBB_INC,d0
	asl.w		#3,d1			*Level x 8
	asl.w		d0			*Incarn x 2

	add.w		d0,d1

	lea.l		VBB_DATOFF(pc),a1
	lea		0(a1,d1.w),a1		*a1=address of offset into
						*beastie picture

	move.w		(a1),d1
	movea.l		#VBB_HOLD,a1		*Addr of vbb piccy
	lea		0(a1,d1.w),a1		*=final addr

	moveq.w		#1,d7			*does 3 char/pass

VBB_PLOOP

	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1

RES_BAK
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4

	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1

	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1
	movem.l		(a1),d0-d6/a2-a4
	movem.l		d0-d6/a2-a4,(a0)		*1 full line
	lea		160(a0),a0
	lea		160(a1),a1

	dbf.w		d7,vbb_ploop

	tst.w		BAK_RES
	bne		drawn_xp

	tst.w		VBB_DIE
	bne		drawn_xp

	cmp.w		#3,VBB_SN			*Both screens?
	bne		vbb_bull

	tst.w		VBB_TMR
	bne		vbb_bull

	move.w		VBB_SPD,VBB_TMR

	clr.w		VBB_SN

VBB_INCRPT
	clr.w		d0
	move.w		VBB_PNT,d0
	move.w		LEVEL_NUM,d1

	asl.w		#2,d1				* x 4
	lea.l		INC_TAB(pc),a0
	lea		0(a0,d1.w),a0		*a0 points to
						*table of incarn table
						*addresses

	movea.l		(a0),a0			*a0 holds correct incarn addr
	lea		0(a0,d0.w),a0
	move.b		(a0),d0
	subq.w		#1,d0			*correct 1->0 etc.

	move.w		d0,VBB_INC
	cmp.w		#$fe,d0			*End of table
	bne		gvbb_bull
	clr.w		VBB_PNT
	bra		vbb_incrpt
GVBB_BULL
	addq.w		#1,VBB_PNT
	bra		vbb_bull

DO_VBBDIE
	
	btst.b		#3,VBB_DIE+1		*Already dead
	beq		no_dedvbb

	moveq		#5,d0			*Set final incarn
	clr.w		d7
	
	bra		ded_vbb	


NO_DEDVBB
	btst.b		#0,VBB_DIE+1		*Init die?
	beq		no_init

	clr.w		VBB_XPPNT		*CLear incarn point
	move.w		LEVEL_NUM,d0
	asl.w		d0
	lea.l		VBB_SOFF(pc),a0	
	lea		0(a0,d0.w),a0		*Get addr of sc offset
	move.w		(a0),d1
	move.w		d1,OFF_HOLD		*Save for Ron

	asl.w		#3,d0
	lea.l		VBB_XPTAB(pc),a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d0			*Offset into hold screen
	
	movea.l		#VBB_HOLD,a1
	lea		0(a1,d0.w),a1
	move.w		#1,d7
	bra		g_vbbsc

NO_INIT
	btst.b		#1,VBB_DIE+1		*Clearance
	bne		clear_uppr

DON_CLRUP
	clr.w		BAK_RES
	clr.w		d7
	move.w		LEVEL_NUM,d0
	asl.w		#2,d0			* x 4
	lea.l		XP_SRTTAB(pc),a0
	lea		0(a0,d0.w),a0
	movea.l		(a0),a0			* A0 = start of table

	move.w		VBB_XPPNT,d0
	asl.w		d0
	lea		0(a0,d0.w),a0		
	move.w		(a0),d0			* d0 = incarn #


	cmpi.w		#-1,d0
	beq		end_exp

DED_VBB
	asl.w		d0
	lea.l		VBB_XPTAB(pc),a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d0			* d0 = offs into vbb hold
	
	movea.l		#VBB_HOLD,a1
	lea		0(a1,d0.w),a1		* a1 = addr

	move.w		OFF_HOLD,d1
	addi.w		#7680,d1



G_VBBSC
	tst.w		SC_NO
	bne		vbb_xb

	movea.l		#SCREENA,a0
	lea		0(a0,d1.w),a0
	bset.b		#0,VBB_SCNO+1
	bra		vbb_ploop

VBB_XB
	movea.l		#SCREENB,a0
	lea		0(a0,d1.w),a0
	bset.b		#1,VBB_SCNO+1
	bra		vbb_ploop

DRAWN_XP
	cmpi.w		#3,VBB_SCNO
	bne		vbb_bull

	tst.w		VBB_TMR
	bne		vbb_bull

	clr.w		VBB_SCNO
	move.w		#AN_TIM,VBB_TMR

	btst.b		#1,VBB_DIE+1		*Clear top
	bne		st_ani

	btst.b		#0,VBB_DIE+1		*Init
	beq		st_ani

	bset.b		#1,VBB_DIE+1		*Say clear
	bclr.b		#0,VBB_DIE+1
	addq.w		#1,VBB_XPPNT
	bra		vbb_bull

ST_ANI
	bclr.b		#1,VBB_DIE+1		*Clr clear
	bset.b		#2,VBB_DIE+1
	

	addq.w		#1,VBB_XPPNT	

	btst.b		#3,VBB_DIE+1		*have we done
	bne		vbb_bull		*yes,no sample

	move.w		VBB_XPPNT,d0
	lea		VBB_XPSAMT(pc,d0.w),a0
	tst.b		(a0)
	beq		vbb_bull
	DO_SAM		EXPLOS,EXPLOS_LEN,0

	bra		vbb_bull

VBB_XPSAMT
	dc.b		1,0,0,1,1,0

END_EXP
*	TOTALLY DEAD
	clr.w		VOLC			*Clear for JP use
	move.w		#8,VBB_DIE		*Say dead
	move.l		#$50000,d0
	jsr		add_scor		* 5000 pts
	
	bra		no_pbb	

VBB_DOORT
	dc.w		0,3,2,15,4,63

CLEAR_UPPR
	moveq.w		#1,d7
	move.w		LEVEL_NUM,d0
	asl.w		#1,d0

	movea.l		#VBB_HOLD+15400,a1	*Always th'same

	lea		VBB_SOFF(pc),a0
	lea		0(a0,d0.w),a0		
	move.w		(a0),d1			*d1 = scr offset
	move.w		#1,BAK_RES		*Say restore bkgrnd


	tst.w		SC_NO
	bne		vbb_rbkb

	movea.l		#SCREENA,a0
	lea		0(a0,d1.w),a0
	bset.b		#0,VBB_SCNO+1
	bra		vbb_ploop
VBB_RBKB
	movea.l		#SCREENB,a0
	lea		0(a0,d1.w),a0
	bset.b		#1,VBB_SCNO+1
	bra		vbb_ploop

VBB_SPD
	dc.w		AN_TIM		*ANimation reset value

VBB_PWR
	dc.w		0

TMP_OFF
	dc.w		0		*Temp hld for scr offset
VBB_XPPNT
	dc.w		0		*Pointer in die table
BAK_RES
	dc.w		0		* 1 = restore bakgrnd

VBB_DIE
	dc.w		0		*Die status

OFF_HOLD
	dc.w		0		*Offset into screen
XP_RESOFF
	dc.l		3520,3520,12456,3520
*	offset into screen for bakgrnd reset


VBB_XPTAB

	dc.w		15360,15400,15440,15480
	dc.w		23120,23160,-1,0	

	dc.w		15360,15400,15440,15480
	dc.w		23120,23160,-1,0	

	dc.w		15360,15400,15440,15480
	dc.w		23120,23160,-1,0	

	dc.w		15360,15400,15440,15480
	dc.w		23120,23160,-1,0	*0 makes tab 16 long	

VBB_SCNO
	dc.w		0			*Which screen we drwn

XP_SRTTAB
	dc.l		XP1,XP2,XP3

XP1
	dc.w		0,1,2,3,2,3,4,5,4,5,-1
XP2
	dc.w		0,1,2,3,2,3,2,3,4,5,4,5,-1
XP3
	dc.w		0,1,2,3,2,3,2,3,4,5,4,5,-1
	
VBB_LOAD
	move.w		#VBB_PMIN,VBB_PWR
	move.w		LEVEL_NUM,d0
	asl.w		#4,d0			* KKKK  was: asl.w #3,d0 -> healthier VBBs!	
	add.w		d0,VBB_PWR

	move.w		LEVEL_NUM,d0
	addi.w		#48,d0
	move.b		d0,VBB_FIL+7
	lea.l		VBB_FIL(pc),a0
	jsr		sam_open

LOAD_FBB
	move.w		#0,-(sp)		*Relative from start
	move.w		SAM_HANDLE,-(sp)
	move.l		#34,-(sp)		*34 bytes in
	move.w		#$42,-(sp)		*LSEEK
	trap		#1
	lea		10(sp),sp

	move.w		#32768,d0		*length
	movea.l		#VBB_HOLD,a0
	jsr		sam_read
	jsr		sam_close
	
*	movea.l	#AXP_FILE,a0			*   FBB Arm-Animation laden ...
*	jsr	sam_open			*   ... auch wenn bei Level 4 ...
*	move.l	#ARM_XPLEN,d0			*   ... begonnen wird
*	movea.l	#ARM_XPDAT,a0			* 
*	jsr	sam_read			* 
*	jsr	sam_close			* 

	rts

SET_BBB
	move.w		VBB_INC,d0
	asl.w		#2,d0			* x 4
	move.w		LEVEL_NUM,d1
	asl.w		#4,d1			* x 16
	add.w		d1,d0
	lea.l		VBB_XYTAB(pc),a0
	lea		0(a0,d0.w),a0
	move.l		(a0),d0

	lea		BBB_NOZ1(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABB
	lea		BBB_NOZ2(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABC
	rts

BBB_NOZ1
	DC.W		6,6
	dc.w		4,15,-1,2,15
	dc.w		1,$5E8,-16,1,40
	dc.w		9
	dc.w		6,$600
	dc.w		9,9
BBB_NOZ2
	dc.w		5,15,-1,2,15
	dc.w		2,$5E8,$FFA0,1,40
	dc.w		9
	DC.W		9
	DS.W		100


VBB_FIL
	dc.b		'ENDLEVL0.PI1'

VBB_INC
	dc.w		0			* Vbb incarnation

VBB_SN
	dc.w		0			* Which screens

WHICH_R
	dc.w		28,29,2,255		* VBB room # for 4 levs

VBB_SOFF
	dc.w		368,368,9144,0		* KKKK: third number was 9304 (1 line too low)
						* Offset to top LHS of VBB in screen destination

VBB_DATOFF
	dc.w		0,40,80,120
	dc.w		0,40,80,120
	dc.w		0,40,80,120
	dc.w		0,40,80,120

VBB_XYTAB
	dc.w		$95,$28,$9d,$24,$a0,$1e,$a2,$16	*lev 0

	dc.w		$9c,$2b,$9d,$30,$9c,$33,$9e,$34 *lev 1

	dc.w		$69,$64,$69,$64,$69,$64,$69,$64 *lev 2

	dc.w		0,0,0,0,0,0,0,0,0,0,0


*Offsets into beastie data screen for each incarnation		
	
	
VBB_PNT
	dc.w		0		*Pointer into incarn table

INC_T0
	dc.b		1,2,3,2,1,2,3,2,1,2,3,4,3,2,3,4,3,2,3,2,$ff

INC_T1
	dc.b		1,2,3,4,3,2,1,2,3,4,3,2,3,4,3,4,3,4,3,2,$ff

INC_T2
	dc.b		1,2,3,4,3,2,1,2,3,4,3,2,3,4,3,4,3,4,3,2,$ff
	EVEN

INC_TAB
	dc.l		INC_T0,INC_T1,INC_T2,INC_T2 	*last just in case


VBB_TMR
	dc.w		0

VBB_YBD
	dc.w		0			*YPOS change timer


VBB
	dc.w		0			*<>0 = VBB there
VBBB_DIR
	dc.w		0			* <>0 = hor bullet

VBB_CCOORDS				
*COllision table
	dc.w		$69,$29,$88,$60
	dc.w		$69,$1e,$8a,$60
	dc.w		$69,$16,$8c,$60
	dc.w		$69,$0d,$8e,$60
******LVL1
	dc.w		$69,$29,$88,$60
	dc.w		$69,$1e,$8a,$60
	dc.w		$69,$16,$8c,$60
	dc.w		$69,$0d,$8e,$60
******LVL2
	dc.w		$38,$46,$77,$98
	dc.w		$38,$46,$77,$98
	dc.w		$38,$46,$77,$98
	dc.w		$38,$46,$77,$98

BULL_DIR
* VBB bullet increments
	dc.w	6,0			*Bullet 0
	dc.w	6,1
	dc.w	4,-1
	dc.w	5,1			*Bullet 1



VBB_BULL
	movea.l		#SP_TABLE+208,a3
	move.w		#3,d7			*Number of bullets
	clr.w		d6			*Offset in bullet inc table
PROC_VBBB
	tst.w		VBB_DIE	
	bne		vbb_go			*No more bullets
	move.l		4(a3),d0
	cmpi.l		#BLANK_SPRIT,d0		*Is it already running??
	bne		vbb_go			*Yes it is
	bsr		set_bbb			*Initialise it
	move.l		#BB_BULL,4(a3)
	move.l		d0,(a3)			*Set X,Y initital position
VBB_GO
	move.l		4(a3),d0
	cmpi.l		#BLANK_SPRIT,d0		*Is it switched off
	beq		nxt_vbbb

	lea		BULL_DIR(pc,d6.w),a0	*Get bullet direction
	move.l		(a3),d0
	add.l		(a0),d0			*Set new position
	move.l		d0,(a3)

	move.w		LEVEL_NUM,d0
	asl.w		#3,d0			*Pointer in bull limit tab
	lea		VBBULL_LIM(pc,d0.w),a0
	
	move.w		(a0)+,d0		* Minimum X
	cmp.w		(a3),d0
	bge		end_bbb
	
	move.w		(a0)+,d0		* Max X
	cmp.w		(a3),d0
	ble		end_bbb

	move.w		(a0)+,d0		* Min Y
	cmp.w		2(a3),d0
	bge		end_bbb

	move.w		(a0),d0			* Max Y
	cmp.w		2(a3),d0
	ble		end_bbb

	
	move.w		SP_TABLE+26,d0
	move.w		SP_TABLE+28,d1
	addq.w		#4,d0
	subq.w		#4,d1


	move.w		(a3),d2
	move.w		2(a3),d3

	cmp.w		d0,d2
	ble		nxt_vbbb
	addi.w		#20,d0
	cmp.w		d0,d2
	bge		nxt_vbbb

	cmp.w		d1,d3
	ble		nxt_vbbb
	add.w		#24,d1
	cmp.w		d1,d3
	bge		nxt_vbbb

	move.w		#1,DIE
	move.l		#BLANK_SPRIT,4(a3)
	bra		nxt_vbbb

VBBULL_LIM
* VBB bullet range limits for each level
* 0  Min X   .w
* 2  Max X   .w
* 4  Min Y   .w
* 6  Max Y   .w

	dc.w	6,298,10,90		*Level 0
	dc.w	6,298,10,71		*Level 1
	dc.w	6,310,48,138		*Level 2

END_BBB
	move.l		#BLANK_SPRIT,4(a3)

NXT_VBBB
	addq.w		#4,d6		*Next bullet dir entry
	lea		26(a3),a3
	dbf.w		d7,proc_vbbb

NO_PBB

*******************************************************************************************

*****************************************************************
*	Fucking big beastie mover ( FBBM ) 			*
*	By GAH on 18/11/88					*
*****************************************************************
	opt		c-

HXP_TIME		equ	8		*Head explos tim
FBB_XP			equ	$40		*Coll XPOS check
DOOR_ANSPD		equ	800		*Door animation speed


FBB_ANSPD		equ	4

	cmpi.w		#3,LEVEL_NUM		* right level?
	bne		no_fbb
	
	cmpi.w		#20,ROOM_IN		* right room?
	bne		no_fbb

	btst.b		#0,FBB_STAT+1		* Initialised??
	bne		go_fbb			* yes
	
* KKKK
* if not already inited, draw neccessary parts of FBB first
* possible situations:
* 1.) FBB completely intact
* 2.) arm explosion in progress
* 3.) arms exploded, head ok
* 4.) head explosion in progress
* 5.) FBB totally dead

	bset.b		#0,FBB_STAT+1		* say: FBB initialised
	clr.w		FBB_TIM			*
	clr.w		FBB_HP			* reset head position
	
fbb_drbot:					* always draw bottom
	movea.l		#VBB_HOLD+23040,a5	* draw bottom part
	movea.l		#SCREENA+16800,a6	*        "
	bsr		fbb_draw		*        "

	movea.l		#VBB_HOLD+23040,a5	* same for screen B
	movea.l		#SCREENB+16800,a6	*        "
	bsr		fbb_draw		*        "
	
fbb_drlftarm:					* always draw left arms
	movea.l		#SCREENA+9120,a6	* draw left arms
	movea.l		#VBB_HOLD,a5		*         "
	moveq.w		#2,d7			*         "
	bsr		fbb_xparm		*         "
	
	movea.l		#SCREENB+9120,a6	* same for screen B
	movea.l		#VBB_HOLD,a5		*        "
	move.w		#2,d7			*        "
	bsr		fbb_xparm		*        "

fbb_ini0:
	btst.b		#1,FBB_STAT+1		* Totally dead?
	beq		fbb_ini1		* no
	bsr		fbb_drxparm		* yes, draw destroyed right arms
	bsr		fbb_drxphead		* and draw destroyed head
	bclr.b		#4,FBB_STAT+1		* Clear door for open
	bclr.b		#5,FBB_STAT+1		* Clear door finished
	bra		no_fbb
	
fbb_ini1:	
	btst.b		#1,FBB_DIE+1		* right arms completely exploded? (also if head explosion in progress)
	beq.s		fbb_ini2		* no
	bsr		fbb_drxparm		* yes, draw destroyed right arms

fbb_ini2:
	bra		go_fbb			* everything drawn, branch to further FBB processing
	

fbb_drxparm
	movea.l		#SCREENA+9144,a6	* draw destroyed right arms
	movea.l		#ARM_XPDAT+34+128,a5	*              "
	move.w		#3,d7			*              "
	bsr		fbb_xparm		*              "
	
	movea.l		#SCREENB+9144,a6	* same for screen B
	movea.l		#ARM_XPDAT+34+128,a5	*        "
	move.w		#3,d7			*        "
	bsr		fbb_xparm		*	 "
	rts

fbb_drxphead
	movea.l		#VBB_HOLD+23152,a5	*Exp'd head
	movea.l		#SCREENA+1448,a6
	bsr		fhead_draw

	movea.l		#VBB_HOLD+23152,a5	*Exp'd head
	movea.l		#SCREENB+1448,a6
	bsr		fhead_draw
	rts
	
	
	
GO_FBB
	btst.b		#1,FBB_STAT+1		* Totally dead?
	bne		no_fbb			* yes

DO_FBB
	btst.b		#3,FBB_STAT+1		* Hed explod .. no arms
	bne		fbb_head		* yes

	btst.b		#0,FBB_DIE+1		* Doing arm exp?
	bne		doin_fbbaxp		* yes

	move.w		FBB_INC,d0		
	lea		FBB_INCTAB(pc),a0
	lea		0(a0,d0.w),a0
	movea.l		(a0),a5			*Addr of this inc data

	tst.w		SC_NO
	bne		fbb_sarmb

	movea.l		#SCREENA+9120,a6
	bset.b		#0,FBB_SCR+1
	bra		draw_arms

FBB_SARMB
	movea.l		#SCREENB+9120,a6
	bset.b		#1,FBB_SCR+1

DRAW_ARMS
	move.w		FBB_DIE,d0
	andi.w		#3,d0
	beq		not_expin
	moveq.w		#2,d7			*3 chars
	bsr		fbb_xparm		*only draw half
	bra		no_fbbd
NOT_EXPIN
	bsr		fbb_draw
	bra		no_fbbd

DOIN_FBBAXP
	tst.w		SC_NO
	bne		era_ab
	
	btst.b		#6,FBB_STAT+1		*Erase arm A
	bne		done_eraa

	ori.w		#$40,FBB_STAT
	movea.l		#SCREENA+7576,a2
	bra		do_el
ERA_AB
	btst.b		#7,FBB_STAT+1
	bne		done_eraa		*done arm erase
	
	movea.l		#SCREENB+7576,a2
	ori.w		#$80,FBB_STAT

DO_EL
	clr.w		d0
	clr.w		d7
	clr.w		d5
	movea.l		#VBB_HOLD+13760,a1	*Blank bkgrnd panel
	move.w		#4,d6			*4 chars down
	bsr		mult_put

DONE_ERAA
	btst.b		#1,FBB_DIE+1		*Arms exploded?
	beq		no_axp

	move.w		#26,FBB_XPINC
	bra		do_fbbaxp

NO_AXP
	
	btst.b		#0,FBB_DIE+1
	beq		no_fbbd

DO_FBBAXP

	tst.w		SC_NO
	bne		fb_dieb

	movea.l		#SCREENA+9144,a6
	movea.l		#ARM_XPDAT+34,a5
	bset.b		#0,FBB_SCR+1
	bra		do_armxp

FBB_PWR
	dc.w		150			* KKKK  was: 100

ARM_XPTAB

	dc.w		1,2,1,2,1,2,3,1,2,3,1,2,3,2,1
	dc.w		2,1,2,1,2,3,2,1,2,3,4,5

ARM_XPOFF
	dc.w		0,32,64,96,128
FBB_DRXPOS
	dc.w		0			*Doos xpos
FBB_DRYPOS
	dc.w		0			*Door ypos
FBB_XDOORTM
	dc.l		0			*Door timer

FB_DIEB
	movea.l		#SCREENB+9144,a6
	movea.l		#ARM_XPDAT+34,a5
	bset.b		#1,FBB_SCR+1

DO_ARMXP
	move.w		FBB_XPINC,d0

	asl.w		#1,d0			* x 2
	lea		ARM_XPTAB(pc),a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d0			* d0 = xp incarn #
	subq.w		#1,d0			* 0 = least #,not 1

	asl.w		#1,d0
	lea		ARM_XPOFF(pc,d0.w),a0
	move.w		(a0),d0			* d0 = offset into sourc scr
	lea		0(a5,d0.w),a5
	moveq		#4,d7			* 5 chars
	bsr		fbb_xparm

NO_FBBD
	cmpi.w		#3,FBB_SCR		*Done animation
	bne		fbb_head

	clr.w		FBB_SCR

	tst.w		FBB_TIM			*Animation timer
	beq		res_a
	subq.w		#1,FBB_TIM
	bra		fbb_head

FBB_XPSAMT
	dc.b		1,0,0,1,0,1,1,1,0,0,0,1,0,0,1,1
	dc.b		0,0,1,0,0,0,1,0,1,0,1,1

RES_A

	btst.b		#2,FBB_DIE+1		*Hed explod?
	beq		no_hedexp
	bset.b		#3,FBB_STAT+1

NO_HEDEXP
	move.w		#FBB_ANSPD,FBB_TIM	*Reset timer

	btst.b		#0,FBB_DIE+1
	beq		no_fbbexp
	
	addq.w		#1,FBB_XPINC

	btst.b		#1,FBB_DIE+1
	bne		no_fbbarmsam		*EXP'd so no sample

	move.w		FBB_XPINC,d0
	lea		FBB_XPSAMT(pc),a0
	lea		0(a0,d0.w),a0
	tst.b		(a0)
	beq		no_fbbarmsam
	DO_SAM		EXPLOS,EXPLOS_LEN,0

NO_FBBARMSAM	

	cmp.w		#27,FBB_XPINC
	bne		fbb_head
	bset.b		#1,FBB_DIE+1
	bclr.b		#0,FBB_DIE+1
	bra		fbb_head

NO_FBBEXP
	
	cmpi.w		#8,FBB_INC		*Reset animation pntr
	bne		no_resfbb

	clr.w		FBB_INC

	cmp.w		#20,FBB_PWR
	bgt		fbb_head

	cmp.w		#0,FBB_PWR
	bgt		not_totd
	
	move.w		FBB_DIE,d0
	andi.w		#12,d0			*hed exp'in or tot ded
	bne  		fbb_head

	clr.w		FBB_HXP
	clr.w		FBB_HXPTIM
	ori.w		#4,FBB_DIE
	clr.w		FBB_MOUTH		*Clear screen count
	clr.w		VOLC			*For jet pack
	move.l		#$100000,d0		*100000 pts!!
	jsr		add_scor

	bra		fbb_head		*exp head


NOT_TOTD
	ori.w		#1,FBB_DIE
	bra		fbb_head

HXP_OFF
	dc.w		112,7792,15472,23152

FBB_HXP
	dc.w		0		*Head exp inarn pointer

FBB_HXPTIM
	dc.w		0		*Head exp timer

NO_RESFBB
	btst.b		#3,FBB_DIE+1		*Totally dead
	bne		fbb_head

	addq.w		#4,FBB_INC		*Next animation

FBB_HEAD
	btst.b		#3,FBB_DIE+1		*Already ded?
	bne		all_done
	btst.b		#2,FBB_DIE+1		*Do head
	beq		no_hxp

	tst.w		FBB_HXPTIM
	beq		do_hxp
	subq.w		#1,FBB_HXPTIM
	bra		fbb_bull
	
ALL_DONE
	moveq.w		#4,d0			*Hxp incarn 4
	bra		put_4

DO_HXP

	move.w		FBB_HXP,d0		*exp stage
	lea		FBB_XPSAMT(pc),a0
	lea		0(a0,d0.w),a0
	tst.b		(a0)
	beq		no_fbbhxpsam
	DO_SAM		EXPLOS,EXPLOS_LEN,0
NO_FBBHXPSAM
	move.w		FBB_HXP,d0		*Restore pointer
	asl.w		#1,d0
	movea.l		#ARM_XPTAB,a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d0			*incarn num
PUT_4
	subq.w		#1,d0
	asl.w		#1,d0
	movea.l		#HXP_OFF,a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d0			*source offset

	tst.w		SC_NO
	bne		hxpb

	movea.l		#SCREENA+1448,a6
	bset.b		#0,FBB_MOUTH+1
	bra		d_hxp
HXPB
	movea.l		#SCREENB+1448,a6
	bset.b		#1,FBB_MOUTH+1

D_HXP
	movea.l		#VBB_HOLD,a5
	lea		0(a5,d0.w),a5

	bsr		fhead_draw

	cmpi.w		#3,FBB_MOUTH
	bne		fbb_bull

	clr.w		FBB_MOUTH
	move.w		#HXP_TIME,FBB_HXPTIM
	addq.w		#1,FBB_HXP
	cmpi.w		#26,FBB_HXP
	bne		fbb_bull
	bclr.b		#2,FBB_DIE+1
	bset.b		#3,FBB_DIE+1
	bset.b		#1,FBB_STAT+1		*Say total death
	bra		fbb_bull


NO_HXP
	move.w		SP_TABLE+28,d0		*Red Ace YPOS

	cmpi.w		#48,d0
	ble		hed1

	cmpi.w		#96,d0
	ble		hed2

	move.w		#8,FBB_HP		*sequence :- 4,8,12
	bra		go_head

HED1
	move.w		#0,FBB_HP
	bra		go_head

HED2
	move.w		#4,FBB_HP
GO_HEAD

	btst.b		#0,FBB_STAT+1		*Init?
	bne		do_fbbh

	clr.w		FBB_MOUTH

	move.w		FBB_HP,d0
	move.w		d0,FBB_LSTH		*Make different


	lea		HHEAD_ADR(pc),a5
	lea		0(a5,d0.w),a5
	movea.l		(a5),a5

	move.l		a5,T_FBBHLD		*Save addr temp

	movea.l		#SCREENA+1448,a6
	bsr		hhead_draw		*Draw half head

	movea.l		T_FBBHLD,a5
	movea.l		#SCREENB+1448,a6
	bsr		hhead_draw

	move.w		FBB_HP,d0
	lea		CLOSM_ADR(pc),a5	*Close mouth table
	lea		0(a5,d0.w),a5
	movea.l		(a5),a5
	move.l		a5,T_FBBHLD
	movea.l		#SCREENA+1472,a6
	bsr		hhead_draw2

	movea.l		#SCREENB+1472,a6
	movea.l		T_FBBHLD,a5
	bsr		hhead_draw2

	bset.b		#0,FBB_STAT+1
	bra		fbb_bull

DO_FBBH

	btst.b		#2,FBB_STAT+1		*Mouth open
	bne		mouth_op

MOUTH_SHUT
	move.w		FBB_HP,d0
	cmp.w		FBB_LSTH,d0		*New head position
	beq		fbb_bull

	lea		HHEAD_ADR(pc),a5
	lea		0(a5,d0.w),a5
	movea.l		(a5),a5

	tst.w		SC_NO
	bne		hedb

	movea.l		#SCREENA+1448,a6
	bset.b		#0,FBB_MOUTH+1
	bra		got_hscr

HEDB
	movea.l		#SCREENB+1448,a6
	bset.b		#1,FBB_MOUTH+1

GOT_HSCR
	move.l		a6,T_FBBHLD
	movem.l		d0/a6,-(sp)
	
	bsr		hhead_draw

	movem.l		(sp)+,d0/a6
	lea		CLOSM_ADR(pc),a5
	lea		0(a5,d0.w),a5
	movea.l		(a5),a5
	lea		24(a6),a6

	bsr		hhead_draw2

	cmpi.w		#3,FBB_MOUTH
	bne		fbb_bull
	move.w		FBB_HP,FBB_LSTH
	clr.w		FBB_MOUTH
	bra		fbb_bull

MOUTH_OP
	cmpi.w		#3,FBB_MOUTH
	beq		tim_mop
	
	tst.w		SC_NO
	bne		mop_a

	movea.l		#SCREENA+1448,a6
	bset.b		#0,FBB_MOUTH+1
	bra		h2

MOP_A
	movea.l		#SCREENB+1448,a6
	bset.b		#1,FBB_MOUTH+1
	
H2
	move.w		FBB_HP,d0
	lea		FHEAD_ADR(pc),a5
	lea		0(a5,d0.w),a5
	movea.l		(a5),a5
	bsr		fhead_draw

	cmp.w		#3,FBB_MOUTH
	bne		fbb_bull

	
	move.w		FBB_HP,FBB_LSTH
	move.w		#6,FBB_MOPT
	bra		fbb_bull
TIM_MOP
	subq.w		#1,FBB_MOPT
	bne		fbb_bull
	clr.w		FBB_MOUTH
	bclr.b		#2,FBB_STAT+1		*Clear mouth open
	move.w		#-1,FBB_LSTH		*Say draw head
	bra		fbb_bull

FBB_DIE
	dc.w		0

FBB_LSTH
	dc.w		0

FBB_MOUTH
	dc.w		0

FBB_HP
	dc.w		0

FBB_INC
	dc.w		0

FBB_SCR
	dc.w		0
FBB_INCTAB
	dc.l		VBB_HOLD,VBB_HOLD+7680,VBB_HOLD+15360

FBB_STAT
	dc.w		0

T_FBBHLD
	dc.l		0

FBB_TIM
	dc.w		0

CLOSM_ADR
	dc.l		VBB_HOLD+23104,VBB_HOLD+23120,VBB_HOLD+23136

HHEAD_ADR
	dc.l		VBB_HOLD+64,VBB_HOLD+7744,VBB_HOLD+15424
FHEAD_ADR
	dc.l		VBB_HOLD+64,VBB_HOLD+7744,VBB_HOLD+15424
	
FBB_MOPT
	dc.w		0

FBB_XPINC
	dc.w		0

FBB_XPARM
* a5 = source
* a6 = dest
* plots a 4 by 5 character square

AXP_LOOP
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6

	movem.l		(a5),d0-d6/a0
	movem.l		d0-d6/a0,(a6)
	lea		160(a5),a5
	lea		160(a6),a6

	dbf.w		d7,AXP_LOOP
	rts


FBB_DRAW
*a5=source
*a6=dest

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	movem.l		(a5)+,d0-d7/a0-a4
	movem.l		d0-d7/a0-a4,(a6)
	movem.l		(a5),d0-d2
	movem.l		d0-d2,52(a6)
	lea		160(a6),a6
	lea		108(a5),a5

	rts

FHEAD_DRAW
*a5=source
*a6=dest

	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d7/a0-a4
	movem.l		d0-d7/a0-a3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
*	movem.l		(a5),d0-d7/a0-a4
*	movem.l		d0-d7/a0-a3,(a6)
*	lea		160(a5),a5
*	lea		160(a6),a6
	rts

HHEAD_DRAW
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	movem.l		(a5),d0-d7
	movem.l		d0-d7,(a6)
	lea		160(a6),a6
	lea		160(a5),a5
	rts

HHEAD_DRAW2
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	movem.l		(a5),d0-d3
	movem.l		d0-d3,(a6)
	lea		160(a5),a5
	lea		160(a6),a6
	rts

FBB_HIT
* IN :- d0=xpos d1=ypos
* OUT :- d0 <>0 is a hit
	
	cmpi.w		#$30,d1
	ble		hed_shot
	cmpi.w		#$70,d1
	bgt		bot_shot

	btst.b		#1,FBB_DIE+1		*Arms exploded
	bne		arms_ded

	cmpi.w		#$70,d0
	bgt		no_fbbhit
	rts
ARMS_DED
	cmpi.w		#$48,d0
	bgt		no_fbbhit
	rts
HED_SHOT
	cmpi.w		#$60,d0
	bgt		no_fbbhit
	rts
BOT_SHOT
	cmpi.w		#$78,d0
	bgt		no_fbbhit
	rts
NO_FBBHIT
	clr.w		d0
	rts

FBB_BULL
	lea		FBB_DIRT(pc),a2		*Dir table
	movea.l		#SP_TABLE+208,a3
	move.w		#3,d7

FBB_BL
	
	move.l		4(a3),d0
	cmpi.l		#BLANK_SPRIT,d0
	bne		no_binit

	clr.l		(a3)			*Put to coords 0,0

	btst.b		#2,FBB_DIE+1
	bne		no_fbul
	btst.b		#3,FBB_DIE+1
	bne		no_fbul

	tst.w		FBB_NXTB
	bne		d_fbbt

	move.w		#12,FBB_NXTB

	tst.w		SAM_TABLE+6		; If sample,no noize
	bne		but_sam_play

	movea.l		#BBB_NOZ1,a0
	jsr		noize_init
	move.l		a0,SON_TABB
	movea.l		#BBB_NOZ2,a0
	jsr		noize_init
	move.l		a0,SON_TABC

BUT_SAM_PLAY
	move.w		SP_TABLE+28,d0		*Man ypos
	lea		FP_TAB(pc),a0		*Fire init posns/dirs

	move.w		#8,d6

FIND_FP
	cmp.w		(a0),d0
	ble		found_fp
	lea		6(a0),a0
	dbf.w		d6,find_fp

FP_ERR
	bra		fp_err

FP_TAB
	dc.w		0,6,-2
	dc.w		20,6,-1
	dc.w		40,6,0
	dc.w		60,6,1
	dc.w		80,6,2
	dc.w		100,6,3
	dc.w		120,6,4
	dc.w		140,6,5
	dc.w		160,6,6

FBB_DIRT
	dc.l		0,0,0,0,0,0,0,0,0

FIR_POST
	dc.w		$44,$1f,$4a,$25,$4a,$25

FBB_NXTB
	dc.w		0
	

FOUND_FP
	move.l		2(a0),(a2)		*Set incs
	move.l		#BB_BULL,4(a3)
	bset.b		#2,FBB_STAT+1
	
	move.w		FBB_HP,d0
	lea		FIR_POST(pc),a0		*Firing position
	lea		0(a0,d0.w),a0
	move.l		(a0),(a3)		*Set posn
	move.w		TIM200,d0		*Random
	move.w		d0,d1			*Save for later
	andi.w		#16,d0			*Do something??
	beq		no_binit		
	andi.w		#8,d1			*Up down on nowt
	beq		fbb_down
FBB_UP						*Subtaract 8 from YPOS
	sub.w		#8,2(a3)
	bra		no_binit
FBB_DOWN
	add.w		#8,2(a3)
	bra		no_binit

D_FBBT
	subq.w		#1,FBB_NXTB
	bra		nxt_fbbb
NO_BINIT
	move.l		(a2),d0
	add.l		d0,(a3)
NO_FBUL
	cmp.w		#0,2(a3)
	ble		k_fbbb

	cmp.w		#160,2(a3)
	bge		k_fbbb

	cmp.w		#311,(a3)
	bge		k_fbbb

	move.w		SP_TABLE+26,d0
	move.w		SP_TABLE+28,d1
	addq.w		#4,d0
	subq.w		#4,d1


	move.w		(a3),d2
	move.w		2(a3),d3

	cmp.w		d0,d2
	ble		nxt_fbbb
	addi.w		#20,d0
	cmp.w		d0,d2
	bge		nxt_fbbb

	cmp.w		d1,d3
	ble		nxt_fbbb
	add.w		#24,d1
	cmp.w		d1,d3
	bge		nxt_fbbb

	move.w		#1,DIE
	move.l		#BLANK,4(a3)
	bra		nxt_fbbb

K_FBBB
	move.l		#BLANK_SPRIT,4(a3)

NXT_FBBB
	lea		26(a3),a3
	lea		4(a2),a2
	dbf.w		d7,fbb_bl

NO_FBB
	btst.b		#1,FBB_STAT+1		*Total death??
	beq		no_lasd			*Not totally dead
	btst.b		#5,FBB_STAT+1		* Door already open
	bne		no_lasd			* Yes,forget it
	cmp.w		#80,SP_TABLE+28		*RA Ypos
	bge		no_lasd			*to screen clash

	cmpi.w		#20,ROOM_IN
	bne		no_lasd

	move.w		#256,FBB_DRXPOS		*Set up door xpos
	move.w		#144,FBB_DRYPOS		*Set YPOS
DO_XFBB
	move.l		#DOOR_ANSPD,FBB_XDOORTM
	moveq.l		#0,d1			*Clear bits 16-31 d1
	move.l		d1,d2			*Same for d2
	move.w		FBB_DRXPOS,d1		*Set up XPOS
	move.w		FBB_DRYPOS,d2		*Get Y position
	movea.l		#BAK_CHARS+(8*128),a1	*Char address
	movea.l		#SCREENA,a0
	jsr		plot_char
	movea.l		#SCREENB,a0		*Second screen
	jsr		plot_char
	add.w		#16,d1			*Next position along
	move.w		d1,FBB_DRXPOS		
	cmpi.w		#304,d1			*Finished??
	bne		do_xfbb
	bset.b		#5,FBB_STAT+1		*Say done
NO_LASD


**********************************************************************************************


EXP_TIMER	equ	2
NO_EXPTIM	equ	EXP_TIMER*5

LAS_PWR		equ	4
**********************************************************************
*  Laser routine:-An auto stop horizontal line draw		     *
**********************************************************************


LASER
	movea.l		#JOYSTICK,a0
	movea.l		#MAN_STAT,a1
	movea.l		#SP_TABLE,a3

	lea		LASER_STAT(pc),a6
	move.w		(a6),d0
	andi.w		#$3,d0				;collision
	bne		laser_check

	btst.b		#2,1(a6)			;erase it
	bne		erase_lase

	btst.b		#3,1(a6)
	bne		laser_explos

	lea		WEAPONS(pc),a5		;weapon availabilty
	btst.b		#0,3(a5)			;laser available??
	beq		DONE_LASER

	btst.b		#7,1(a0)			;fire pressed
	beq		DONE_LASER
	
	tst.w		DIE			* alive?
	bne		DONE_LASER		* nope

	movea.l		#FIRING,a5
	tst.w		(a5)
	bne		done_laser

	btst.b		#4,1(a1)		;facingI??
	bne		DONE_LASER

	btst.b		#1,(a1) 		;facingII??
	bne		DONE_LASER

	move.w		#-1,(a5)		;set firing
	bset.b		#0,DOSH+1		*Do icon bit
	bset.b		#0,FIRING+1

	movea.l		#LASER_NOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABA

	ori.w		#4,DOOR_DELAY		*Ensure no erase cockups
						*when doors moving

	lea		SHOOTIN(pc),a5
	or.w		#1,(a5)

	moveq.l		#0,d1
	move.w		#EXP_TIMER,18(a6)	;explosion timer
	move.w		26(a3),d0		;XPOS of man
	move.w		28(a3),d1		;YPOS
	add.l		G_OFF,d1		;gun offset
	addq.w		#3,d1			;centralize exp
	move.w		d1,14(a6)
	addq.w		#8,d1			;correct&align
	
	btst.b		#2,1(a1)		;left?
	bne		set_las_left

SET_LAS_RIGHT
	addi.w		#33,d0			;lots to the right
	bra		init_las

SET_LAS_LEFT
	sub.w		#1,d0
	ori.w		#$100,16(a6)		;set left flag

INIT_LAS
	move.w		d0,10(a6)		;set start xpos

	lea		SC_NO(pc),a5
	btst.b		#0,1(a5)
	bne		SET_SCRB
	move.l		#SCREENA,d7
	bra		set_bases

SET_SCRB
	move.l		#SCREENB,d7

SET_BASES	

	moveq.l 	#0,d2			;calculate address
	move.w		d1,d2		
	asl.l		#1,d2			;*2
	move.l		d2,d3
	asl.l		#2,d2
	add.l		d3,d2
	asl.l		#4,d2

	moveq.l 	#0,d3
	move.w		d0,d3			;transfer XPOS
	move.l		d3,d4			;???
	and.l		#$fffffff0,d3
	lsr.l		#1,d3
	add.l		d2,d3

	add.l		d7,d3			;d7=current base adr
	move.l		d3,a2			;a2=screen address

	ori.w		#1,(a6) 		;set laser goin' bit
	moveq.l 	#4,d2
	and.w		(a1),d2 		;left
	or.w		d2,(a6) 		;set lasr dir bit
	move.l		#0,2(a6)		;kill wrd count
	
	move.l		a2,6(a6)		;save screen addr


DO_LSHOOT

	lea		laser_stat(pc),a6
	lea		laser_cache(pc),a5
	
	btst.b		#2,1(a6)
	bne		las_left

LAS_RIGHT
	move.w		d0,d2
	andi.w		#$f,d2
	move.w		d2,d4			;save for posterity??
	not.b		d2			;bit to set down to b0
	andi.b		#$f,d2

	move.w		d2,d3			;which bit
	add.w		d0,d3			;add XPOS
	cmpi.w		#319,d3
	blt		no_alter

	move.w		#-1,2(a6)		;set end of line
	move.w		d3,12(a6)		;set end xpos
	ori.w		#$200+NO_EXPTIM,16(a6)		;set no exp flag+cntr
*						to next laser shot

NO_ALTER
	movem.w 	(a2),d3-d6
	movem.w 	d3-d6,(a5)		;save cache
	lea		8(a5),a5
	addq.w		#4,4(a6)		;increment #word count

* Lets see if there is any colour 12 in there??
	and.w		d5,d6			;upper bits d3/d2
	beq		no_alterii		;both not set,<>12

	or.w		d3,d4			;are d0/d1 set??
	not.w		d4
	and.w		d6,d4			;yes then forget it
	beq		no_alterii

* D6 now holds pixel positions which contain colour 12


	move.w		#$f,d5			;find first bit in d6

BFIND_LOOPR
	btst.l		d5,d4
	bne		found_it
	dbmi.w		d5,bfind_loopr
*	An error has occured if we get here but ignore it anyhow
FOUND_IT

	move.w		d0,d7
	andi.w		#$ff0,d7		;mask off b0-b3
	move.w		d5,d3
	not.w		d3
	andi.w		#$f,d3
	add.w		d3,d7
	subi.w		#16,d7			;correct XPOS
	move.w		d7,12(a6)

	andi.w		#$100,16(a6)		;kill no exp flag+cntr
	ori.w		#4,16(a6)		;set exp incarn

	move.w		#-1,2(a6)		;set end flag
*	D5=bit number set
	moveq.l 	#0,d3
	bset.l		d5,d3
	asl.w		#1,d3
	subq.w		#1,d3
	not.w		d3
	bra		put_laserr

NO_ALTERII
	moveq.l 	#0,d3
	bset.l		d2,d3
	asl.w		#1,d3
	subq.w		#1,d3			;set all of them bits

PUT_LASERR
	move.w		d3,d2
	not.w		d2			;create mask


	or.w		d3,(a2) 		;clr 1st wrd bits
	or.w		d3,2(a2)		;set wrd 2 bits
	and.w		d2,4(a2)		;set wrd 3 bits
	and.w		d2,6(a2)		;clr wrd 4 bits

	adda.l		#8,a2			;next thingies
	add.w		#16,d0			;next xpos

	andi.w		#$fff0,d0		;done silly bits so
*				     do words only now
	cmpi.w		#0,2(a6)		;end??
	beq		las_right
	asl.w		(a6)			;set checker
	bra		done_laser



LAS_LEFT
	move.w		d0,d2
	andi.w		#$f,d2

	move.w		d0,d3			;which bit
	sub.w		d2,d3			;add XPOS
	bgt		no_alterl1

	move.w		#-1,2(a6)		;set end of line
	move.w		d0,d3			;set end xpos
	move.w		d3,12(a6)		;tidy up last XPOS
	ori.w		#$200+NO_EXPTIM,16(a6)		;set no exp flg+cntr


NO_ALTERL1
	movem.w 	(a2),d3-d6
	movem.w 	d3-d6,(a5)		;save cache
	lea		8(a5),a5
	addq.w		#4,4(a6)		;increment #word count

* Lets see if there is any colour 12 in there??
	and.w		d5,d6			;upper bits d3/d2
	beq		no_alterl2		;both not set,<>12

	or.w		d3,d4			;are d0/d1 set??
	not.w		d4
	and.w		d6,d4			;yes then forget it
	beq		no_alterl2

* D6 now holds pixel positions which contain colour 12


	move.w		#$0,d5			;find first bit in d6
	move.w		#$f,d3			;d3=counter


BFIND_LOOPL
	btst.l		d5,d4
	bne		found_it2
	addq.w		#1,d5
	dbmi.w		d3,bfind_loopl
*	An error has occured if we get here but ignore it anyhow
FOUND_IT2

	move.w		d0,d7
	andi.w		#$ff0,d7		;mask off b0-b3
	move.w		d5,d3
	not.w		d3
	andi.w		#$f,d3
	add.w		d3,d7
	move.w		d7,12(a6)

	andi.w		#$100,16(a6)		;kill no exp flg+cntr
	ori.w		#4,16(a6)		;set exp incarn

	move.w		#-1,2(a6)		;set end flag
*	D5=bit number set
	moveq.l 	#0,d3
	bset.l		d5,d3
	asl.w		#1,d3
	subq.w		#1,d3
	not.w		d3
	bra		put_laserl

NO_ALTERL2
	moveq.l 	#0,d3
	tst.w		d2
	beq		put_laserl
	not.w		d2
	andi.w		#$f,d2
	bset.l		d2,d3
	asl.w		#1,d3
	subq.w		#1,d3


PUT_LASERL
	not.w		d3
	move.w		d3,d2
	not.w		d2			;create mask


	or.w		d3,(a2) 		;clr 1st wrd bits
	or.w		d3,2(a2)		;set wrd 2 bits
	and.w		d2,4(a2)		;set wrd 3 bits
	and.w		d2,6(a2)		;clr wrd 4 bits

	suba.l		#8,a2			;next thingies
	sub.w		#16,d0			;next xpos

	andi.w		#$fff0,d0		;done silly bits so
*				   		do words only now
	cmpi.w		#0,2(a6)		;end??
	beq		las_left
	asl.w		(a6)			;set checker
	bra		done_laser

ERASE_LASE
	asl.w		(a6)
	move.w		4(a6),d0		;laser length
	move.l		6(a6),a2		;laser addr
	
	movea.l		#FIRING,a3			;firing?
	clr.w		(a3)
		
	lea		laser_cache(pc),a3	;laser backgr stor
	subq.w		#1,d0			;allow for DBF exe.
	btst.b		#0,16(a6)
	bne		eraze_leftst

ERA_LAZ_LOOP
	move.w		(a3)+,(a2)+
	dbf		d0,ERA_LAZ_LOOP
	bra		done_laser
ERAZE_LEFTST
	addq.w		#1,d0
	lsr.w		#2,d0
	subq.w		#1,d0
ERAZE_LEFT
	move.w		(a3)+,(a2)+
	move.w		(a3)+,(a2)+
	move.w		(a3)+,(a2)+
	move.w		(a3)+,(a2)+

	lea		-16(a2),a2		* take it back
	dbf		d0,eraze_left
	bra		done_laser
	
G_OFF
	dc.l		0			*Gun offset

LASER_STAT
	dc.w		0			;status d0=active
*						d2=dirn,1=left
LASER_END
	dc.w		0			;<>0 then end
LASER_LEN
	dc.w		0			;lase length *16 pix
LASER_ADDR
	dc.l		0
LASER_STX
	dc.w		0			;laser start posn
LASER_FINX
	dc.w		0			;aser end posn
LASER_YPOS
	dc.w		0
LASER_EXPINCARN
	dc.w		0			;laser exp stats
LASER_TIM
	dc.w		0			;laser animation timer
*	offset=18

LASER_CACHE
	ds.w		160			;laser cache

LASER_EXPLOS
	btst.b		#1,16(a6)		;no exp??
	bne		no_las_exp
	subq.w		#1,18(a6)
	move.w		18(a6),d0		;laser timer
	bne		done_laser
	move.w		#EXP_TIMER,18(a6)
	
	clr.l		d0
	move.b		17(a6),d0		;exp incarn
	bpl		no_done_laser
	asl.w		(a6)
	bra		done_laser

NO_DONE_LASER

	movea.l		#SP_TABLE,a3
	lea		laser_exptab(pc),a5	;laser exp data

	btst.b		#0,16(a6)			;left exp
	bne		laser_exp
	add.w		#4,d0			;offset into right exp
	bra		laser_exp

	
LASER_EXP
	move.w		12(a6),d1
	move.w		d1,130(a3)		;set exp xpos
	move.w		14(a6),132(a3)		;set ypos
	andi.w		#7,d0			;mask out dir bit
	asl.w		#7,d0			;*128
	add.l		a5,d0
	move.l		d0,134(a3)		;set data addr
	subq.b		#1,17(a6)		;decrement incarn cnt
	cmpi.b		#0,17(a6) 
	bpl		done_laser
* explosion now at blank data
KILL_LAS_EXP
	clr.w		16(a6)			;kill flags
	clr.l		(a6)
	move.l		#BLANK_SPRIT,4(a6)
	bra		done_laser

LASER_EXPTAB


	include		wall_exp.s		* dc.b only


NO_LAS_EXP
	subq.b		#1,17(a6)
	bne		done_laser
	bra		kill_las_exp
LASER_NOZ
	dc.w		$0000,$0100,$0042,$0001,$0100	*Set freq
	dc.w		$0006,$0801			*Set tone
	dc.w		$0007,$000a,$0002,$0001,$0100,$0000	*set env
	dc.w		$0003,$0010,$0000,$0001,$0038	*Set vol
	dc.w		$0009
	dc.w		$0003,$0004,$ffff,$0001,$0004
	dc.w		$0009
	dc.w		$0006,$0100
	dc.w		$0009,$0009

SB_EXPNOZ
	dc.w		$0008,$0010,$0002,$0001,$001f	*Set noize
	dc.w		$0006,$0420			*Set noz ch 3
	dc.w		$0005,$000f,$ffff,$0002,$000f	*set Vol ch 3
	dc.w		$0009
	dc.w		$0006,$2400			*Kill ch3
	dc.w		$0005,$0000,$0000,$0001,$0001	*VOLC=0
	dc.w		$0009,$0009			*End of sound

LASER_CHECK
	move.w		26(a3),d0			*Man XPOS
	move.w		14(a6),d1			*Laser YPOS
	addq.w		#4,d1				*Offset********

	tst.w		BBRUN
	bne		T2_BB				*32x32 bb
	
	btst.b		#0,FBB_STAT+1			*FBB init'ed?
	bne		lt_fbb

	tst.w		VBB
	bne		l_vbbchk

	lea		208(a3),a3			*pnt to beast

	move.w		SBEA_MASK,d7			
	subq.w		#1,d7				*Number loops


	btst.b		#0,16(a6)			*Laser dir
	bne		sbx_leftl

SBX_RIGHT
	add.w		#32,d0				*Shift XPOS to RHS

SBXR_LOOP
	tst.l		4(a3)				*Owt there
	beq		no_rhit

	move.w		24(a3),d2		
	andi.w		#$1f,d2				*Get Beast#
	cmpi.w		#$1f,d2
	beq		no_rhit

	cmp.w		(a3),d0				*Compare xpos
	bgt		no_rhit				*Man>beast

	move.w		LASER_FINX,d2
	cmp.w		(a3),d2
	blt		no_rhit

	move.w		2(a3),d2			*Beast YPOS
	
	cmp.w		d2,d1				
	blt		no_rhit

	add.w		#16,d2				*To bottom of beast
	cmp.w		d2,d1
	bgt		no_rhit

	move.l		#SB_XPLOS,4(a3)			*Set exp addr

	andi.w		#$ff60,24(a3)			*zero beast#
							*and set animation up
	ori.w		#$1f,24(a3)			*Set exp# = 31

	move.w		d7,d6
	asl.w		d6
	move.l		#TIM_TAB,a5
	lea		0(a5,d6.w),a5			*Timer position
	
	andi.b		#$f8,(a5)			*Zero incarn

	movea.l		#SB_EXPNOZ,a0			*Exp noise
	jsr		noize_init
	move.l		a0,SON_TABC


NO_RHIT
	lea		26(a3),a3
	dbf.w		d7,sbxr_loop
	bra		done_bexp
LT_FBB
	moveq.w		#1,d0				*Low Xpos
					* to ensure hit
	bsr		fbb_hit
	tst.w		d0
	beq		done_bexp

	movea.l		#SB_EXPNOZ,a0			*Exp noise
	jsr		noize_init
	move.l		a0,SON_TABC
	subi.w		#LAS_PWR,FBB_PWR
	bra		done_bexp

SBX_LEFTL
	tst.l		4(a3)				*Owt there
	beq		no_lhit

	move.w		24(a3),d2		
	andi.w		#$1f,d2				*Get Beast#
	cmpi.w		#$1f,d2
	beq		no_lhit


	cmp.w		(a3),d0				*Compare xpos
	blt		no_lhit				*Man>beast

	move.w		LASER_FINX,d2
	cmp.w		(a3),d2
	bgt		no_lhit

	move.w		2(a3),d2			*Beast YPOS
	
	cmp.w		d2,d1				
	blt		no_lhit

	add.w		#16,d2				*To bottom of beast
	cmp.w		d2,d1
	bgt		no_lhit

	move.l		#SB_XPLOS,4(a3)			*Set exp addr

	andi.w		#$ff60,24(a3)			*zero beast#
*			and set animation up
	ori.w		#$1f,24(a3)			*Set exp# = 31

	move.w		d7,d6
	asl.w		d6
	move.l		#TIM_TAB,a5
	lea		0(a5,d6.w),a5			*Timer position
	
	andi.b		#$f8,(a5)			*Zero incarn

	movea.l		#SB_EXPNOZ,a0			*Exp noise
	jsr		noize_init
	move.l		a0,SON_TABC

NO_LHIT
	lea		26(a3),a3
	dbf.w		d7,sbx_leftl
	bra		done_bexp
T2_BB
	tst.w		BBMOV			*0=it is now dead
	beq		done_bexp
	movea.l		#SP_TABLE+208,a3
	
	move.w		(a3),d2				*BB xpos
	move.w		2(a3),d3			*BB ypos

	btst.b		#0,16(a6)			*Laser dir
	bne		bblchkl

BBLCHKR
	add.w		#32,d0
	cmp.w		d0,d2
	ble		done_bexp

	cmp.w		d3,d1
	ble		done_bexp
	addi.w		#32,d3
	cmp.w		d3,d1
	bge		done_bexp

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	sub.w		#LAS_PWR,BB_PWR
	bra		done_bexp

L_VBBCHK
	tst.w		VBB_DIE
	bne		done_bexp

	move.w		LEVEL_NUM,d3
	move.w		VBB_INC,d2
	asl.w		#3,d2
	asl.w		#5,d3
	add.w		d2,d3
	movea.l		#VBB_CCOORDS,a0
	lea		0(a0,d3.w),a0

	move.w		(a0),d2
	move.w		2(a0),d3

	cmp.w		d3,d1
	blt		done_bexp

	btst.b		#0,16(a6)		* 1 = left
	bne		vbb_lcl

	cmp.w		d0,d2
	blt		done_bexp
	bra		vbb_lhit

VBB_LCL
	cmp.w		d0,d2
	bgt		done_bexp
VBB_LHIT
	move.w		6(a0),d3
	cmp.w		d3,d1
	bgt		done_bexp

	subi.w		#LAS_PWR,VBB_PWR
	bra		done_bexp	

BBLCHKL
	cmp.w		d0,d2
	bge		done_bexp

	cmp.w		d3,d1
	ble		done_bexp
	addi.w		#32,d3
	cmp.w		d3,d1
	bge		done_bexp

	add.w		#23,d2
	move.w		d2,104(a3)			*Set exp sprite
	
	subq.w		#8,d1				*Ypos exp
	move.w		d1,106(a3)

	clr.w		BX_ANITIM
	clr.w		BX_INC
	bset.b		#4,BULLET+1

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	sub.w		#LAS_PWR,BB_PWR

DONE_BEXP

	asl.w		(a6)


DONE_LASER

******************************************************************************************

*************************************************
*       Default bullet processor                *
*       by GAH on 9/9/88                        *
*       Format of BULLET.w                      *
*       d0-d1   :Incarnation bits               *
*       d2      :<>0=Bullet moving              *
*       d3      :<>0=Bullet moving left         *       
*************************************************
BULL_PWR                equ     2

BULL_PROC
        movea.l         #SP_TABLE,a3
        btst.b          #4,BULLET+1                     *Exploding
        bne             exp_bull
        tst.w           BULLET
        bne             go_bullet                       *Already there

        btst.b          #2,WEAPONS+3            *Selected???
        beq             no_bull

        btst.b          #7,JOYSTICK+1           *Fire pressed?
        beq             no_bull
        
        tst.w		DIE			* dying?
        bne		no_bull			* don't fire then

	move.l		134(a3),d0		*Get bullet source addr
	cmp.l		#BLANK_SPRIT,d0
	bne		no_bull			*Not avbl yet

	move.w		MAN_STAT,d0
	andi.w		#$210,d0
	bne		no_bull			*Facing

        
        movea.l         #BULL_NOZ,a0
        jsr             noize_init              *Make noizes
        move.l          a0,SON_TABA

        clr.w           B_DIST                  *Distance travelled
        move.w          #-1,FIRING              
        move.w          #1,SHOOTIN              *Put flames

        move.w          26(a3),d0               *Man Xpos
        move.w          28(a3),d1               *Man Ypos
        
        add.l           G_OFF,d1               *Crouch offset
        addi.w          #10,d1

        btst.b          #2,MAN_STAT+1           *Facing??
        bne             init_bulft

        addi.w          #24,d0                  *Right offset
        bra             init_bull

INIT_BULFT
        cmpi.w		#8,d0
	ble		not_subl		*Dont subtract,RA at limit

	subi.w          #8,d0
NOT_SUBL
        bset.b          #3,BULLET+1             *Set dir

INIT_BULL
        ori.w           #4,BULLET               *Say moving
        move.w          d0,130(a3)              *Set xpos
        move.w          d1,132(a3)              *Say Ypos
        move.l          #MAN_GRPH+7552,134(a3)  *Set bull ( Ch# 59)

GO_BULLET
	tst.w           BBRUN                   *Big beasties
        bne             bb_cchk
DONE_BBCCHK
        btst.b          #3,BULLET+1             *Left?
        bne             mblft

MBRGT
        moveq.w         #8,d1                   *Col collision offset

        addq.w          #6,130(a3)
        move.w          130(a3),d0
        cmpi.w          #310,d0                 *Xpos offscreen
        bge             end_bull

        bra             bull_coll

BULL_NOZ
        dc.w            $0000,$0130,$0008,$0001,$0030
        dc.w            $0006,$0801		*TA one,NA off
        dc.w            $0007,$0008,$0008,$0001,$0100,$0008
        dc.w            $0003,$0010,$0000,$0001,$0018
        dc.w            $0009
        dc.w            $0003,$0004,$ffff,$0001,$0004
        dc.w            $0009
        dc.w            $0006,$0900		*Tone/Noise A off
        dc.w            $0009,$0009


BULLET
        dc.w            0

BX_ANITIM
        dc.w            0
BX_INC  
        dc.w            0               *Bullet exp incarn

MBLFT
        moveq.w         #0,d1                   *Collision offset

        move.w          130(a3),d0              *Get xpos
        cmpi.w          #7,d0
        ble             end_bull
	subq.w          #6,130(a3)
       
BULL_COLL
        addq.w          #1,B_DIST
        move.w          B_DIST,d2
        cmp.w           B_RANGE,d2              *Far enough??
        bge             end_bull

	btst.b		#0,FBB_STAT+1		*FBB init'ed
	bne		fbb_bchk

	tst.w		VBB_DIE
	bne		no_ign			*If vbb not ded

	tst.w		VBB
	bne		vbb_bchk

NO_IGN

        moveq.w         #1,d6                   *Count
        tst.l           146(a3)
        beq             do_12b
        movea.l         146(a3),a1

CHK_AGAIN
        
        lea             0(a1,d1.w),a1           *Which words
        movem.w         (a1)+,d2-d5             *Get screen

        or.w            d2,d3
        not.w           d3
        and.w           d4,d5
        and.w           d3,d5
        
        bne             end_bull

DO_12B
        
        tst.l           150(a3)
        beq             done_12c
        movea.l         150(a3),a1              *Other buffer
        dbf.w           d6,chk_again

DONE_12C
	tst.w		VBB			*End of level VBB
	bne		vbb_bchk

	tst.w		BB_THERE		* BB??
	bne		no_bull			* Forget it
        
        move.w          SBEA_MASK,d7
        subq.w          #1,d7                   *Get # beasts
        move.w          132(a3),d1              *Bullet ypos
        
        lea             208(a3),a2              *a2=addr beast tab

BCOLL_CHK
        tst.w           4(a2)                   *Owt there
        beq             no_bht

        move.w          24(a2),d2               
        andi.w          #$1f,d2                 *Get beast#
        cmpi.w          #$1f,d2                 *Already explodin'
        beq             no_bht

        move.w          (a2),d2                 *Xpos
        addq.w          #2,d2                   *Make it excitin'
        
        cmp.w           d2,d0
        blt             no_bht

        addi.w          #$c,d2
        cmp.w           d2,d0
        bgt             no_bht

        move.w          2(a2),d2                *Get Ypos
        cmp.w           d2,d1
        blt             no_bht

        addi.w          #$c,d2
        cmp.w           d2,d1
        bgt             no_bht

        move.w          d7,d6                   *Get beast sp posn
        asl.w           #1,d6
        movea.l         #TIM_TAB,a1
        lea             0(a1,d6.w),a1           *Get incarn place
        andi.w          #$f800,(a1)             *Clear incarn

        andi.w          #$ff60,24(a2)           *CLear Beast#
        ori.w           #$1f,24(a2)             *Set exp
        move.l          #SB_XPLOS,4(a2)         *Set explosion

        movea.l         #SB_EXPNOZ,a0
        jsr             noize_init
        move.l          a0,SON_TABC
        bra             end_bull

FBB_BCHK
	move.w		130(a3),d0
	move.w		132(a3),d1
	bsr		fbb_hit
	tst.w		d0
	beq		no_bull
	subq.w		#BULL_PWR,FBB_PWR
	bra		bull_ishit

VBB_BCHK
	tst.w		VBB_DIE
	bne		no_bull

	move.w		LEVEL_NUM,d0
	asl.w		#5,d0
	move.w		VBB_INC,d1
	asl.w		#3,d1
	add.w		d1,d0
	movea.l		#VBB_CCOORDS,a0		*Coord check table
	lea		0(a0,d0.w),a0

	move.w		(a0),d0			*VBB xpos1
	move.w		2(a0),d1		*VBB ypos 1
	
	move.w		130(a3),d2		*BULL xpos
	move.w		132(a3),d3		*BULL ypos

	cmp.w		d0,d2
	blt		no_bull

	cmp.w		d1,d3
	blt		no_bull

	move.w		4(a0),d0
	move.w		6(a0),d1		*VBB X/Y pos 2

	cmp.w		d0,d2
	bgt		no_bull

	cmp.w		d1,d3
	bgt		no_bull
        subq.w          #BULL_PWR,VBB_PWR

BULL_ISHIT
        bset.b          #4,BULLET+1
        move.l          #SB_EXPNOZ,a0
        jsr             noize_init
        move.l          a0,SON_TABC
        clr.w           BX_ANITIM    
        clr.w   	BX_INC
	bra		exp_bull


BB_CCHK
	tst.w		BBMOV			*Already dead perhaps??
	beq		done_bbcchk		*Yes it was
        movea.l         #SP_TABLE+208,a2

        move.w          (a2),d0
        move.w          2(a2),d1                *BB xpos/ypos
        subq.w          #6,d0
        subq.w          #6,d1

        move.w          130(a3),d2
        move.w          132(a3),d3

        cmp.w           d0,d2
        ble             done_bbcchk
        addi.w          #24,d0
        cmp.w           d0,d2
        bge             done_bbcchk

        cmp.w           d1,d3
        ble             done_bbcchk
        addi.w          #36,d1
        cmp.w           d1,d3
        bge             done_bbcchk

        bset.b          #4,BULLET+1
        move.l          #SB_EXPNOZ,a0
        jsr             noize_init
        move.l          a0,SON_TABC
        subq.w          #BULL_PWR,BB_PWR
        
        move.w          #0,BX_ANITIM    
        move.w          #0,BX_INC

EXP_BULL
        tst.w           BX_ANITIM
        beq             do_bxani
        subq.w          #1,BX_ANITIM
        bra             no_bull

DO_BXANI
        move.w          #1,BX_ANITIM
        clr.l           d0
        move.w          BX_INC,d0
        move.w          d0,d1
        add.l           #SB_XPLOS,d0
        move.l          d0,134(a3)

        add.w           #128,d1
        cmp.w           #512,d1
        beq             end_bull

        move.w          d1,BX_INC
        bra             no_bull

B_RANGE
        dc.w            48                      *Max travel dist
B_DIST
        dc.w            0                       *Dist so far

NO_BHT
        lea             26(a2),a2
        dbf.w           d7,bcoll_chk

        bra             no_bull
END_BULL
        move.l		#BLANK_SPRIT,134(a3)
        clr.w           BULLET
        clr.w           FIRING

NO_BULL
        
***********************************************************************************************

*********************************************************
*	32 x 32 beastie processor			*
*	By GAH on 3/4/89				*
*********************************************************

BB_INCSPD	equ	8		*Animation speed
BB_MOVSPD	equ	1		*Movement speed
BBB_SPEED	equ	5		*Bullet speed

MOVEBB
	tst.w		BBMOV
	beq		no_movebb		* Any 32x32 there

	movea.l 	#SP_TABLE+208,a3
	
	tst.w		BB_STAT 		* Initialised??
	bne		go_bbmov		* yes

	move.w		#-1,BBRUN

	move.w		LEVEL_NUM,d0		* Get level number
	addq.w		#1,d0
	moveq		#10,d1
	mulu.w		d1,d0
	move.w		d0,BB_PWR		* Number of shots to kill
	move.w		BB_PWR,BB_LAST_PWR				
	clr.w		BB_INC			* Incarn -> 0
	clr.w		BB_MOVTIM
	move.w		BB_YPOS,BB_YHOLD	* Prserve position integrity
	move.w		#1,BB_STAT		* Say init'ed & clear rest
TRY_AGIN
	move.w		TIM200,d0		* Random beast
	andi.w		#3,d0
	cmpi.w		#3,d0
	beq		try_agin		* Only in range 0-2

	moveq		#10,d1
	asl.w		d1,d0			* Beast# x 1024
	move.w		d0,BB_DATOFF		* Offs in font
	bsr		hovver_q
	bra		start_path	

**************************

HOVVER_Q					* See if hovver
	move.w		BB_YPOS,d0		* Initial Y position
	move.w		SP_TABLE+28,d1		* Man YPOS
	cmpi.w		#$36,d0			* YPOS in upper section	
	blt		bb_uppr
	
	cmpi.w		#$31,d1			* Is BB in upper section
	ble		no_bbmov		* Yes,make it hovver
	bra		choose_bbp
NO_BBMOV
	movea.l 	#HOVVER_PTH,a0
	bset.b		#1,BB_STAT+1		*Say hovverin'
	bra		set_path

BB_UPPR
	cmpi.w		#$59,d1			* Is man in lower section
	bge		no_bbmov		* Yes,make BB hover
	
CHOOSE_BBP

	move.w		TIM200,d0
	andi.w		#$f,d0			*Movement path
	asl.w		#2,d0
	lea		BB_PATHLIS(pc,d0.w),a0
	move.l		(a0),a0 		*Get addr of 1st element
	bclr.b		#1,BB_STAT+1		*Clear hovver flag
SET_PATH
	move.l		a0,BB_PATHRES		*Set path pointer reset
	move.l		(a0)+,BB_PLEN		*Element len & XINC
	move.w		(a0)+,BB_YINC
	move.l		a0,BB_PATHADR		*Save current posn
	rts

*****************************************************************

START_PATH
	clr.w		BB_INCTIM		*Reset animation timer
	move.w		SP_TABLE+26,d0		*Man XPOS
	cmpi.w		#160,d0			* Look at BB XPOS
	bge		bb_mr			*Move it to the right
	move.w		#-1,BB_HDIR		* Set HOR dir
	move.w		#260,BB_XPOS
	move.l		#BIGTAB,a0		*Beastie data root addr
	move.w		BB_DATOFF,d0		*Which beastie we using
	lea.l		0(a0,d0.w),a0
	move.l		a0,BB_FLIPSAVE		*Save for restore
	move.w		#$ffff,BB_FACING	*Say facing left
	bra		go_bbmov

BB_PATHLIS
	dc.l	PATH0,PATH1,PATH2,PATH3,PATH4
	dc.l	PATH0,PATH1,PATH2,PATH3,PATH4
	dc.l	PATH0,PATH1,PATH2,PATH3,PATH4
	dc.l	PATH0,PATH1,PATH2,PATH3,PATH4


PATH0
	dc.w	20,1,1,20,0,-1,20,1,0,-1
PATH1
	dc.w	20,0,1,20,1,0,20,0,-1,20,1,0,-1
PATH2
	dc.w	20,1,1,20,1,-1,-1
PATH3
	dc.w	10,1,0,10,0,1,10,1,0,10,0,1,10,1,0,10,0,-1
	dc.w	10,1,0,10,0,-1,-1
PATH4
	dc.w	10,1,2,10,1,-2,-1
HOVVER_PTH
	dc.w		2,0,0,2,0,1
	dc.w		2,0,0,2,0,-1,-1 
BB_FIRNOZ
	dc.w		$1,$8f0,$85,$1,$ff
	dc.w		$4,$f,$0,$1,$10
	dc.w		$6,$2
	dc.w		$9
	dc.w		$4,$f,-1,$3,$f
	dc.w		9
	dc.w		$6,$200
	dc.w		9,9

BBRUN
	dc.w		0			*<>0 if bb has been


BB_MR
	move.w		#16,BB_XPOS
	move.w		#1,BB_HDIR		*Set move to right
	move.l		#BIGTAB,a0		*Beastie data root addr
	move.w		BB_DATOFF,d0		*Which beastie we using
	lea.l		0(a0,d0.w),a0
	move.w		#127,d5			*Number of lines to flip
	move.l		a0,BB_FLIPSAVE		*Save for restore
	bsr		next_lin		*Flip sprite
	clr.w		BB_FACING		*Say facing right
	bra		go_bbmov

NEXT_LIN
	not.w		BB_FACING		*Change facing direction
	move.w		#127,d5			*Line count			
DO_FLIP
	clr.l		d2			*Clear assembly register
	move.l		d2,d3			*Clear assmbly reggy
	moveq.w		#31,d7			*Number of bits to flip
	movem.l		(a0),d0-d1		*Get data to flip
FLIPLOOP
	move.w		d7,d6			*Inver bit number
	not.w		d6
	andi.w		#31,d6
	asl.l		#1,d0			*See if set??
	bcs		set_bd0
	bclr.l		d6,d2			*Clear in assembly
	bra		do_d1
SET_BD0
	bset.l		d6,d2
DO_D1
	asl.l		#1,d1			*See if source set
	bcs		set_bd1
	bclr.l		d6,d3
	bra		next_bit
SET_BD1
	bset.l		d6,d3
NEXT_BIT
	dbra		d7,fliploop
	swap		d2
	swap		d3
	movem.l		d2-d3,(a0)		*Save back out
	lea.l		8(a0),a0		*Next line
	dbra		d5,do_flip
	movea.l		BB_FLIPSAVE,a0		*Restore data pointer		
	bsr		put_bb
	rts

GO_BBMOV
	btst.b		#3,BB_STAT+1		*Totally dead
	bne		bb_bullet
	
	tst.w		BB_INCTIM		*Anim. timer up??
	beq		do_bbinc
	subq.w		#1,BB_INCTIM		*No,dec timer
	bra		move_bb

PUT_BB
* a0=addr of first char in font, a3=addr to put it
	btst.b		#2,BB_STAT+1		*<>0 if dying
	bne		do_left
	tst.w		BB_FACING
	bpl		bb_right
DO_LEFT
	move.l		a0,4(a3)
	lea		128(a0),a0
	move.l		a0,30(a3)
	lea		128(a0),a0
	move.l		a0,56(a3)
	lea		128(a0),a0
	move.l		a0,82(a3)
	rts
BB_RIGHT
	move.l		a0,30(a3)
	lea		128(a0),a0
	move.l		a0,4(a3)
	lea		128(a0),a0
	move.l		a0,82(a3)
	lea		128(a0),a0
	move.l		a0,56(a3)
	rts

LOAD_32x32
* Load in 32x32 beastie from font
	movem.l 	d0-d7/a0-a6,-(sp)
	lea		BB_FIL(pc),a0		
	bsr		sam_open

	clr.l		d0
	move.w		LEVEL_NUM,d0
	mulu.w		#3072,d0		* Offset for beastie

	move.w		#0,-(sp)		*Rel from start
	move.w		SAM_HANDLE,-(sp)
	move.l		d0,-(sp)		*Offset
	move.w		#$42,-(sp)
	trap		#1
	add.l		#10,sp
	
	move.w		#3072,d0
	movea.l 	#BIGTAB,a0
	bsr		sam_read
	bsr		sam_close
	movem.l 	(sp)+,d0-d7/a0-a6
	rts

BB_FIL
	dc.b		'MON_N_XP.FNT',0
	EVEN

DO_BBINC
	move.w		#BB_INCSPD,BB_INCTIM	*Reset animation timer

	btst.b		#2,BB_STAT+1		*Explodin'
	bne		bb_dying
	
	tst.w		BB_PWR
	bge		not_dying
	bra		EXP_BB

NOT_DYING
	move.w		BB_PWR,d0
	cmp.w		BB_LAST_PWR,d0		*Has it gone down
	beq		not_down
	move.w		#BB_MOVSPD*10,BB_MOVTIM	* Set mov. timer high
	move.w		BB_PWR,BB_LAST_PWR	*Set new level
NOT_DOWN
	move.w		BB_DATOFF,d0
	eori.w		#512,BB_INC
	add.w		BB_INC,d0
	move.l		#BIGTAB,a0
	lea		0(a0,d0.w),a0
	bsr		put_bb

MOVE_BB
	tst.w		BB_MOVTIM		*Movement timer
	beq		do_bbmov
	subq.w		#1,BB_MOVTIM
	bra		bb_bullet

BB_DYING
	movea.l		#BB_EXPGPX,a0
	move.w		BB_INC,d0
	lea		0(a0,d0.w),a0
	bsr		put_bb
	addi.w		#512,d0
	move.w		d0,BB_INC
	cmpi.w		#2560,d0
	bne		bb_bullet		*End of explosion??
	bset.b		#3,BB_STAT+1		*Say totally dead
	move.l		#$10000,d0		*1000 points
	jsr		add_scor
	clr.w		VOLC			*So JP can sound
	move.w		BB_HDIR,d0
	cmpi.w		#0,d0			* Was it  moving right
	bmi		not_mr			* No
	movea.l		BB_FLIPSAVE,a0		* Get restore addr
	bsr		next_lin		* Restore beastie to left
NOT_MR
	clr.l		4(a3)			* CLEAR BB
	clr.l		30(a3)
	clr.l		56(a3)
	clr.l		82(a3)
	
	bra		bb_bullet		
	

DO_BBMOV
	
	btst.b		#1,BB_STAT+1		* Hovvering
	beq		still_hovver		* No,carry on
*****NOW SEE IF WE CAN STOP HOVVERING*********
	tst.w		BB_YDIR			* Still restoring??
	bne		still_hovver
	move.w		BB_YPOS,d1		* Initial Y position
	move.w		SP_TABLE+28,d0		* Man YPOS
	addi.w		#16,d0			* Make RA central
	cmp.w		d1,d0
	ble		still_hovver		* RA is higher
	addi.w		#32,d1			* Bottom of BB
	cmp.w		d1,d0
	bge		still_hovver
	bsr		hovver_q		* Set new path

STILL_HOVVER
	move.w		#BB_MOVSPD,BB_MOVTIM

	move.w		BB_STAT,d0
	andi.w		#12,d0		* Dead or exploding	
	bne		exp_bb		* Don't move it

	tst.w		BB_YDIR		* Need to restore YPOS??
	beq		no_restore
	move.w		BB_YPOS,d0
	add.w		BB_YDIR,d0
	move.w		d0,BB_YPOS	* Save new position
	cmp.w		BB_YHOLD,d0	* Are we done yet
	bne		chk_postres
	clr.w		BB_YDIR		* Kill restore
	bra		chk_postres
	
NO_RESTORE
	tst.w		BB_PLEN 		*0=end of element
	beq		new_bbpath
	
	tst.w		BB_HDIR
	bmi		bb_lft
	
	move.w		BB_XINC,d0
	add.w		d0,BB_XPOS
	bra		chk_bbpos

NEW_BBPATH
	move.l		BB_PATHADR,a0
RES_BPATH
	move.w		(a0)+,BB_PLEN
	bmi		res_bbp 		*-ve=end of path
	move.l		(a0)+,BB_XINC
	move.l		a0,BB_PATHADR
	bra		move_bb
RES_BBP
	move.l		BB_PATHRES,a0
	bra		res_bpath


BB_LFT
	move.w		BB_XINC,d0
	sub.w		d0,BB_XPOS
	
CHK_BBPOS
	
	move.w		BB_YINC,d0
	add.w		d0,BB_YPOS
	subq.w		#1,BB_PLEN

CHK_POSTRES
	move.w		BB_XPOS,d0
	move.w		BB_YPOS,d1
	
	move.w		d0,d2
	move.w		d1,d3			*Save original coords

	move.w		d0,(a3)
	move.w		d0,52(a3)
	move.w		d1,2(a3)
	move.w		d1,28(a3) 
	addi.w		#16,d0
	addi.w		#16,d1
	move.w		d0,26(a3)
	move.w		d0,78(a3)
	move.w		d1,54(a3)
	move.w		d1,80(a3)

	move.w		-182(a3),d0		*RED ACE xpos
	move.w		-180(a3),d1		*RED ACE ypos
	addq.w		#6,d0
	addq.w		#6,d1

	movem.w 	d0/d2,-(sp)		*Save for ron
	
	cmp.w		d2,d0
	blt		nxt_bbhchk
	addi.w		#24,d2
	cmp.w		d2,d0
	blt		bb_vchk

NXT_BBHCHK
	movem.w 	(sp),d0/d2
	addi.w		#24,d0
	cmp.w		d2,d0
	blt		end_bbcoll
	addi.w		#24,d2
	cmp.w		d2,d0
	blt		bb_vchk

END_BBCOLL
	movem.w 	(sp)+,d0-d1		*Reset stack
	bra		bb_bullet

BB_VCHK
	movem.w 	(sp)+,d0/d2
	movem.w 	d1/d3,-(sp)
	
	cmp.w		d3,d1
	blt		nxt_bbvchk
	addi.w		#24,d3
	cmp.w		d3,d1
	blt		bb_mhit
	bra		end_bbcoll

NXT_BBVCHK
	movem.w 	(sp),d1/d3
	addi.w		#24,d1
	cmp.w		d3,d1
	blt		end_bbcoll
	addi.w		#24,d3
	cmp.w		d3,d1
	bgt		end_bbcoll
BB_MHIT
	move.w		#-1,DIE
	bra		end_bbcoll

EXP_BB	
	btst.b		#2,BB_STAT+1	*EXP initialised??
	bne		no_movebb 
	DO_SAM		EXPLOS,EXPLOS_LEN,0
	bset.b		#2,BB_STAT+1
	clr.w		BB_INC
	bra		no_movebb

BB_MOVTIM
	dc.w		0		*BB movement timer

BB_FACING
	dc.w		0		*BB direction -ve=left,+ve right

BB_YDIR
	dc.w		0		* BB restore direction

BB_YHOLD
	dc.w		0		* BB starting YPOS

BLADR
	dc.l		0		*Addr in level of BB char 200

DIE_BB
	dc.w		0		*<>0 if BB xplodin

BB_LAST_PWR
	dc.w		0		*BB previous power level

BB_STAT
	dc.w		0		*BB status

BB_PWR
	dc.w		0		*BB strength

BB_FLIPSAVE	
	dc.l		0		*Save addr for flipped 32x32 restore


BB_XPOS
	dc.w		0
BB_YPOS
	dc.w		0

BB_PLEN
	dc.w		0		*Path element length

BB_XINC
	dc.w		0		

BB_YINC
	dc.w		0

BB_HDIR
	dc.w		0		*Which direction

BB_DATOFF
	dc.w		0		*Offset into bb font

BBMOV
	dc.w		0		*<>0 if BB in service

BB_INC
	dc.w		0		*BB  incarnation

BB_INCTIM
	dc.w		0		*BB animation timer
	

BB_PATHADR
	dc.l		0		*Current pointer addr in path

BB_PATHRES
	dc.l		0		*Path pointer reset addr

BBULL_XINC
	dc.w		0		*BB bullet x increment

BB_THERE
	dc.w		0		*Prevents SB drawing

BB_OFFTAB			*BB bullet offset & type table
*	X offset
*	Y offset
*	Bullet offset
*	dc.w	0

	dc.w		-1,1,0,0
	dc.w		-1,18,0,0
	dc.w		24,6,0,0
	dc.w		0,18,128,0
	dc.w		16,1,0,0
	dc.w		-4,18,128,0
	dc.w		-8,18,128,0
	dc.w		18,0,128,0
	dc.w		-5,-4,0,0
	dc.w		18,-3,128,0
	dc.w		32,19,0,0
	dc.w		0,19,128,0

BBBUL_GPHX
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$1FF0,$1FF0,$1FF0,$0000
	DC.W $3FF8,$3FF8,$2008,$0000,$7FFC,$610C,$4104,$1930
	DC.W $3FF8,$3FF8,$2008,$0000,$1FF0,$1FF0,$1FF0,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $03C0,$03C0,$03C0,$0000,$0420,$07E0,$0420,$0240
	DC.W $0990,$0FF0,$0810,$0420,$0BD0,$0E70,$0810,$0080
	DC.W $0BD0,$0E70,$0810,$0180,$0990,$0FF0,$0810,$0420
	DC.W $0420,$07E0,$0420,$0240,$03C0,$03C0,$03C0,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	
BB_BULLET
	btst.b		#2,BB_STAT+1		*Explodin'?
	bne		cont_bbbull

	move.w		BB_XPOS,d0
	tst.w		BB_HDIR
	bmi		chk_bbl
	cmpi.w		#272,d0
	blt		cont_bbbull
	move.w		BB_HDIR,d0
	eor.w		#$ffff,d0
	move.w		d0,BB_HDIR		*Invert beastie direction
	movea.l		BB_FLIPSAVE,a0		*Beastie data restore
	bsr		next_lin
	bsr		hovver_q		*Need to hovver?	
	bra		set_restore
CHK_BBL
	cmpi.w		#20,d0			*LHS end of travel
	bgt		cont_bbbull
	move.w		BB_HDIR,d0
	eor.w		#$ffff,d0
	move.w		d0,BB_HDIR		*Invert beastie direction
	movea.l		BB_FLIPSAVE,a0
	bsr		next_lin
	bsr		hovver_q
SET_RESTORE
	move.w		BB_YPOS,d0		* Get current YPOS
	cmp.w		BB_YHOLD,d0		* Compare with Y start
	beq		cont_bbbull		* Same,continue
	ble		res_y_up		* Needs to go down
	move.w		#-1,BB_YDIR		* Set up
	bra		cont_bbbull
RES_Y_UP
	move.w		#1,BB_YDIR

CONT_BBBULL
	btst.b		#1,BB_STAT+1		*Hovvering?
	bne		no_movebb

	lea		-52(a3),a3		*char 208-26
	
	move.l		4(a3),d0
	cmp.l		#BLANK_SPRIT,d0		*Already firing
	bne		go_bbb

	btst.b		#3,BB_STAT+1
	beq		ok_bbfire		*Dead so no firin

	clr.w		BBMOV			*Stop it
	clr.w		BB_STAT
	move.l		BLADR,a0		*Adr of BB marker
	move.w		#71,(a0)		*Set to blank
	
	clr.l		4(a3)
	clr.l		30(a3)
	clr.l		56(a3)
	clr.l		82(a3)
	bra		no_movebb

OK_BBFIRE
	btst.b		#2,BB_STAT+1		*Explodin
	bne		no_movebb

	move.w		BB_YPOS,d1
	move.w		BB_XPOS,d0
	move.w		RM_BEAST,d2
	asl.w		#3,d2
	move.w		LEVEL_NUM,d3
	mulu.w		#24,d3
	add.w		d3,d2
	lea		BB_OFFTAB(pc),a0
	lea		0(a0,d2.w),a0
	add.w		(a0),d0
	add.w		2(a0),d1
	move.w		d0,(a3)
	move.w		d1,2(a3)

	move.w		-128(a3),d4		*Red ace ypos
	cmp.w		d4,d1
	ble		no_movebb
	addi.w		#24,d4
	cmp.w		d4,d1
	bge		no_movebb
	
	move.w		-130(a3),d4		* RA xpos	
	tst.w		BB_FACING		* -ve=left,0=right
	bge		BBUL_RIGHT
***Moving left	
	cmp.w		BB_XPOS,d4
	bge		no_movebb		* RA to the right,forget it
	bra		do_bbb
BBUL_RIGHT
	cmp.w		BB_XPOS,d4
	ble		no_movebb		* RA to the left,forget it
DO_BBB		
	
	lea		BBBUL_GPHX(pc),a1
	move.w		4(a0),d2		*Off into bbtab
	lea		0(a1,d2.w),a1
	move.l		a1,4(a3)
	
	tst.w		BB_FACING		*Which dir??
	bge		bbb_right
	move.w		#-1*BBB_SPEED,BBULL_XINC *Set left
	bra		done_bbb_dir
BBB_RIGHT
	move.w		#BBB_SPEED,BBULL_XINC	*Set right
DONE_BBB_DIR
	movea.l		#BB_FIRNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABB

GO_BBB
	move.w		(a3),d0 		*BBull xpos	
	add.w		BBULL_XINC,d0
	move.w		d0,(a3)
	move.w		2(a3),d1
	
	cmpi.w		#5,d0
	ble		end_bbull
	cmpi.w		#299,d0
	bge		end_bbull		*Within screen limits

	move.w		SP_TABLE+26,d2		*Red ace xpos
	move.w		SP_TABLE+28,d3		*Red ace ypos

	addq.w		#7,d2
	addq.w		#7,d3

	addq.w		#7,d0
	addq.w		#7,d1

	cmp.w		d2,d0			*Check for RA/BB collision
	ble		no_movebb
	addi.w		#20,d2
	cmp.w		d2,d0
	bge		no_movebb

	cmp.w		d3,d1
	ble		no_movebb
	addi.w		#20,d3
	cmp.w		d3,d1
	bge		no_movebb

	
	move.w		#1,DIE
END_BBULL
	move.l		#BLANK_SPRIT,4(a3)
	
		
NO_MOVEBB


********************************************************************************************+	
*********************************************************
*	Big Fuck Off bullet processor			*
*	By GAH on 21/9/88				*
*	Stat= BFO_STAT					*
*	d0=BFO moving					*
*	d1=1=left,0=right				*
*********************************************************

BFO_PWR			equ	7
	movea.l		#SP_TABLE+130,a3

	btst.b		#2,BFO_STAT+1
	bne		BFO_EXP

	tst.w		BFO_STAT
	bne		mov_bfo			*Already goin'

	btst.b		#3,WEAPONS+3		*Available??
	beq		done_bfo

	btst.b		#7,JOYSTICK+1
	beq		done_bfo
	
	tst.w		DIE			* alive?
	bne		done_bfo		* nope

	move.w		MAN_STAT,d2
	andi.w		#$0210,d2		*Facing
	bne		done_bfo
	
	lea		BFO_NOZ(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA

	move.w		#1,SHOOTIN		*Put flames
	move.w		#1,FIRING
	move.w		#1,BFO_STAT
	bset.b		#0,DOSH+1		*DO icon

	move.w		SP_TABLE+26,d0		*Man Xpos
	move.w		SP_TABLE+28,d1		*Man Ypos
	add.l		G_OFF,d1		*Ypos offset
	addq.w		#5,d1

	btst.b		#2,MAN_STAT+1		*Left
	bne		init_bfol

	addi.w		#26,d0			*Firin' right
	bra		init_bfo

INIT_BFOL
	cmpi.w		#12,d0
	ble		no_subfo
	subi.w		#12,d0
NO_SUBFO
	bset.b		#1,BFO_STAT+1

INIT_BFO
	move.w		d0,(a3)
	move.w		d1,2(a3)		*Set xpos/ypos

MOV_BFO
	btst.b		#1,BFO_STAT+1
	bne		bfo_l

BFO_R
	move.w		(a3),d0
	addq.w		#8,d0			*Fast mov
	cmpi.w		#304,d0
	bgt		end_bfo
	bra		bfo_coll

BFO_L
	move.w		(a3),d0
	subq.w		#8,d0
	cmp.w		#0,d0
	blt		end_bfo		

BFO_COLL
	move.w		d0,(a3)

	eori.l		#128,BFO_CINC
	move.l		#BFO_CHAR,d2
	add.l		BFO_CINC,d2
	move.l		d2,4(a3)

	tst.w		VBB_DIE
	bne		not_2

	tst.w		VBB
	bne		vbb_bfochk

NOT_2
	btst.b		#1,FBB_STAT+1
	bne		not_fbb

	btst.b		#0,FBB_STAT+1		*FBB initialised
	beq		not_fbb
	
	move.w		(a3),d0
	move.w		2(a3),d1
	bsr		fbb_hit

	tst.w		d0
	beq		not_fbb

	bset.b		#2,BFO_STAT+1
	move.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	subq.w		#BFO_PWR,FBB_PWR
	move.l		#BLANK_SPRIT,4(a3)
	move.l		(a3),182(a3)
	move.w		#0,BX_ANITIM
	move.w		#0,BX_INC
	bra		bfo_exp

NOT_FBB

	tst.l		16(a3)			*Last screenA there??
	beq		do_bfob

	movea.l		16(a3),a1
	lea		1280(a1),a1

	movem.w		(a1)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		end_bfo

	movem.w		(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		end_bfo

DO_BFOB

	tst.l		20(a3)			*Last screenA there??
	beq		done_bfoc

	movea.l		20(a3),a1
	lea		1280(a1),a1

	movem.w		(a1)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		end_bfo

	movem.w		(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		end_bfo

DONE_BFOC
	tst.w		BBRUN
	bne		bb_bfoc

	move.w		SBEA_MASK,d7
	subq.w		#1,d7			*Correct for dbf
	move.w		2(a3),d1		*Re-get ypos
	movea.l		#SP_TABLE+208,a2

BFO_SBC
	tst.w		4(a2)
	beq		no_bfoht		*Nowt there

	move.w		(a2),d2			*Get xpos
	addq.w		#2,d2			*Excitement
	cmp.w		d2,d0
	ble		no_bfoht

	addi.w		#$c,d2
	cmp.w		d2,d0
	bge		no_bfoht

	move.w		2(a2),d2
	subq.w		#8,d2
	cmp.w		d2,d1
	ble		no_bfoht
	addi.w		#23,d2
	cmp.w		d2,d1
	bge		no_bfoht

	move.w		24(a2),d2
	andi.w		#$1f,d2
	cmpi.w		#$1f,d2			*Already explodin'??
	beq		no_bfoht

	move.w		d7,d6
	movea.l		#TIM_TAB,a1
	asl.w		#1,d6
	lea		0(a1,d6.w),a1
	andi.w		#$f800,(a1)
	andi.w		#$ff60,24(a2)		*Clear beast#
	ori.w		#$1f,24(a2)		*Set exp

	move.l		#SB_XPLOS,4(a2)
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

NO_BFOHT
	lea		26(a2),a2
	dbf.w		d7,bfo_sbc
	bra		done_bfo

VBB_BFOCHK
	tst.w		VBB_DIE
	bne		done_bfo

	move.w		LEVEL_NUM,d0
	asl.w		#5,d0
	move.w		VBB_INC,d1
	asl.w		#3,d1
	add.w		d1,d0
	movea.l		#VBB_CCOORDS,a0
	lea		0(a0,d0.w),a0
	
	move.w		(a0),d0
	move.w		2(a0),d1

	move.w		(a3),d2
	move.w		2(a3),d3

	cmp.w		d0,d2
	blt		done_bfo

	cmp.w		d1,d3
	blt		done_bfo

	move.w		4(a0),d0
	move.w		6(a0),d1

	cmp.w		d0,d2
	bgt		done_bfo
	cmp.w		d1,d3
	bgt		done_bfo


	bset.b		#2,BFO_STAT+1
	move.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	subq.w		#BFO_PWR,VBB_PWR

	move.l		#BLANK_SPRIT,4(a3)
	move.l		(a3),182(a3)
	move.w		#0,BX_ANITIM
	move.w		#0,BX_INC
	bra		bfo_exp

BB_BFOC
	tst.w		BBMOV			*Already dead??
	beq		done_bfo		*Yes
	movea.l		#SP_TABLE+208,a2

	move.w		(a2),d0			*BB xpos
	move.w		2(a2),d1
	sub.w		#10,d1
	sub.w		#10,d0

	move.w		(a3),d2
	move.w		2(a3),d3


	cmp.w		d0,d2
	ble		done_bfo
	addi.w		#30,d0
	cmp.w		d0,d2
	bge		done_bfo

	cmp.w		d1,d3
	ble		done_bfo
	addi.w		#40,d1
	cmp.w		d1,d3
	bge		done_bfo

	bset.b		#2,BFO_STAT+1
	move.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	subq.w		#BFO_PWR,BB_PWR

	move.l		#BLANK_SPRIT,4(a3)
	move.l		(a3),182(a3)
	move.w		#0,BX_ANITIM
	move.w		#0,BX_INC

BFO_EXP
	tst.w		BX_ANITIM
	beq		do_bfoexp
	subq.w		#1,BX_ANITIM
	bra		done_bfo

DO_BFOEXP
	move.w		#1,BX_ANITIM
	clr.l		d0
	move.w		BX_INC,d0
	move.w		d0,d1
	add.l		#SB_XPLOS,d0
	move.l		d0,186(a3)
	
	add.w		#128,d1
	cmp.w		#512,d1
	beq		end_bfobb
	move.w		d1,BX_INC
	bra		done_bfo

BFO_CINC
	dc.l		0
BFO_STAT
	dc.w		0

BFO_NOZ
	dc.w		0,$a0,$10,1,$20
	dc.w		3,$10,0,2,$12
	dc.w		6,$0801			*Noise A off,tone A on
	dc.w		7,$a,2,1,$18,$10
	dc.w		9
	dc.w		3,5,-1,1,5
	dc.w		9
	dc.w		6,$0900			*Tone/noise A off
	dc.w		9,9

END_BFOBB
	move.l		#BLANK_SPRIT,186(a3)
END_BFO
	move.l		#BLANK_SPRIT,4(a3)
	clr.w		BFO_STAT
	clr.w		FIRING
DONE_BFO

*************************************************************************************************

*********************************************************
*		Missile launcher code			*
*		By GAH on 25/9/88			*
*********************************************************

MISS_INCT		equ	2
MISS_PWR		equ	6

	tst.w		LEVD_STAT		*Level door in process
	bne		done_miss
	
	btst.b		#0,MISS_P+1			*Pause?
	bne		done_miss

	btst.b		#1,MISS_P+1
	bne		kill_miss


	movea.l		#SP_TABLE+130,a3
	
	tst.w		MISS_STAT		*Movin
	bne		do_miss

	btst.b		#6,WEAPONS+3		*There??
	beq		done_miss

	btst.b		#7,JOYSTICK+1
	beq		show_miss

	tst.w		DIE			* alive?
	bne		done_miss		* nope

	move.w		#1,MISS_STAT
	clr.w		MISS_TIM
	move.w		#1,SHOOTIN		*SHow flames
	move.w		#1,FIRING
	bset.b		#0,DOSH+1

	lea		MISS_NOZ(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA

	move.w		SP_TABLE+26,d0		*Man xpos

	btst.b		#2,MAN_STAT+1
	bne		in_ml

*	Init missile right

	move.w		#256,MISS_CH		*Missile char offset
	addi.w		#32,d0
	bra		cont_mi

IN_ML
	clr.w		MISS_CH
	subi.w		#16,d0
	ori.w		#2,MISS_STAT

CONT_MI
	move.w		d0,(a3)
	move.w		SP_TABLE+28,d0		*MAn ypos
	add.l		G_OFF,d0		*Gun offset
	addq.w		#5,d0
	move.w		d0,2(a3)		*Set ypos

DO_MISS
	btst.b		#2,MISS_STAT		*Explode?
	bne		exp_miss	

	tst.w		MISS_TIM
	beq		do_minc
	subq.w		#1,MISS_TIM
	bra		no_minc

DO_MINC
	move.w		#MISS_INCT,MISS_TIM
	eori.w		#128,MISS_CH		*char incarn
	clr.l		d0
	move.w		MISS_CH,d0
	addi.l		#MISS_CHAR,d0
	move.l		d0,4(a3)

NO_MINC
	btst.b		#1,MISS_STAT+1		*Left??
	bne		miss_left

	move.w		(a3),d0
	addq.w		#4,d0
	cmp.w		#304,d0
	bge		kill_miss

	move.w		d0,(a3)
	bra		chk_miss

MISS_LEFT
	move.w		(a3),d0
	subq.w		#4,d0
	cmp.w		#4,d0
	ble		kill_miss
	move.w		d0,(a3)
	bra		chk_miss
CHK_MISS

*******	first do colour 12 collision	**********


	tst.w		VBB_DIE
	bne		not_4

	tst.w		VBB
	bne		done_mcb

NOT_4
	tst.l		16(a3)			*Last sca
	beq		do_mcb

	movea.l		16(a3),a1
	lea		1600(a1),a1		*8 lin down

	movem.w		(a1)+,d2-d5
	
	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		init_mxp

	movem.w		(a1),d2-d5
	
	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		init_mxp

DO_MCB
	tst.l		20(a3)			*Last sca
	beq		done_mcb

	movea.l		20(a3),a1
	lea		1600(a1),a1		*8 lin down

	movem.w		(a1)+,d2-d5
	
	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		init_mxp

	movem.w		(a1),d2-d5
	
	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		init_mxp

	
DONE_MCB

	move.w		(a3),d0			*M xpos
	move.w		2(a3),d1		*M ypos

	tst.w		BBRUN
	bne		ch_mbb

	tst.w		VBB
	bne		m_vbbchk

	move.w		SBEA_MASK,d7
	subq.w		#1,d7
	movea.l		#SP_TABLE+208,a1

*	Check collision with single b's

BMC_CHK
	tst.w		4(a1)			*Owt??
	beq		no_mht

	move.w		24(a1),d2
	andi.w		#$1f,d2
	cmpi.w		#$1f,d2
	beq		no_mht			*Already explodin

	move.w		(a1),d2			*Beastie xpos
	addq.w		#2,d2
	cmp.w		d2,d0
	blt		no_mht

	addi.w		#12,d2
	cmp.w		d2,d0
	bgt		no_mht

	move.w		2(a1),d2		*SB ypos
	subq.w		#8,d2

	cmp.w		d2,d1
	blt		no_mht
	addi.w		#20,d2
	cmp.w		d2,d1
	bgt		no_mht


	move.w		d7,d6
	asl.w		#1,d6
	movea.l		#TIM_TAB,a0
	lea		0(a0,d6.w),a0
	andi.w		#$f800,(a0)
	andi.w		#$ff60,24(a1)
	ori.w		#$1f,24(a1)

HITTED_FBB
	move.l		#SB_XPLOS,4(a2)
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC
	bra		init_mxp

NO_MHT
	lea		26(a1),a1
	dbf.w		d7,BMC_CHK

*	Check for collision with sngle doors

	move.w		SINGLE_DOORS,d7
	tst.w		d7
	beq		done_miss
	subq.w		#1,d7
	movea.l		#SDOOR_TAB,a1
DO_MDOR
	cmpi.w		#0,2(a1)			*Already?
	ble		no_mdh

	move.w		(a1),d2
	andi.w		#$1ff,d2			*Xpos
	move.w		d2,d4				*Save xpos
	cmp.w		d2,d0
	blt		no_mdh
	addi.w		#12,d2
	cmp.w		d2,d0
	bgt		no_mdh

	move.w		2(a1),d3			*Get ypos

	move.w		d3,d5				*SAve ypos
	subi.w		#16,d3
	cmp.w		d3,d1
	blt		no_mdh
	addi.w		#30,d3
	cmp.w		d3,d1
	bgt		no_mdh

	andi.w		#$1ff,(a1)			*Kill flags
	move.w		#-1,2(a1)
	movea.l		4(a1),a1
	move.w		#202,(a1)			*Say no door
	
	move.w		d4,DXP_XPOS
	move.w		d5,DXP_YPOS			*Set exp coords
	move.w		#1,DOOR_XP
	move.w		#1,MISS_P			*Pause missile
	move.l		#BLANK,4(a3)
	
	DO_SAM		EXPLOS,EXPLOS_LEN,0

	bra		done_miss


NO_MDH
	lea		8(a1),a1
	dbf.w		d7,do_mdor
	bra		done_miss

M_VBBCHK
	tst.w		VBB_DIE
	bne		done_miss

	move.w		LEVEL_NUM,d0
	asl.w		#5,d0
	move.w		VBB_INC,d1
	asl.w		#3,d1
	add.w		d1,d0
	movea.l		#VBB_CCOORDS,a0
	lea		0(a0,d0.w),a0

	move.w		(a0),d0			*Vbb xpos
	move.w		2(a0),d1		*VBB ypos

	move.w		(a3),d2
	move.w		2(a3),d3

	cmp.w		d0,d2
	blt		done_miss

	cmp.w		d1,d3
	blt		done_miss

	move.w		4(a0),d0
	move.w		6(a0),d1

	cmp.w		d0,d2
	bgt		done_miss

	cmp.w		d1,d3
	bgt		done_miss


	subi.w		#MISS_PWR,VBB_PWR

	bra		init_mxp	


CH_MBB
	tst.w		BBMOV				*Already dead
	beq		done_miss
	tst.w		DIE_BB				*Already dyin'
	bne		done_miss

	movea.l		#SP_TABLE+208,a2		*BB addr
	move.w		(a2),d2				*BB xpos
	move.w		2(a2),d3			*BB ypos

	subq.w		#6,d2
	subq.w		#6,d3

	cmp.w		d2,d0
	blt		done_miss
	addi.w		#28,d2

	cmp.w		d2,d0
	bgt		done_miss

	cmp.w		d3,d1
	blt		done_miss
	addi.w		#36,d3
	cmp.w		d3,d1
	bgt		done_miss

	subi.w		#MISS_PWR,BB_PWR

INIT_MXP
	btst.b		#0,FBB_STAT+1		*FBB init'ed
	beq		no_fbbhitt
	move.w		(a3),d0
	move.w		2(a3),d1
	bsr		fbb_hit
	tst.w		d0
	beq		no_fbbhitt
	subi.w		#MISS_PWR,FBB_PWR
NO_FBBHITT
	bset.b		#2,MISS_STAT		*Say explodin
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	clr.w		MX_ANITIM
	clr.w		MX_INC
EXP_MISS
	tst.w		MX_ANITIM
	beq		go_mexp
	subq.w		#1,MX_ANITIM
	bra		done_miss

GO_MEXP
	move.w		#1,MX_ANITIM
	clr.l		d2
	move.w		MX_INC,d2
	move.w		d2,d3
	addi.l		#SB_XPLOS,d2
	move.l		d2,4(a3)

	addi.w		#128,d3
	cmp.w		#640,d3
	beq		kill_miss

	move.w		d3,MX_INC
	bra		done_miss
KILL_MISS
	move.l		#BLANK_SPRIT,4(a3)
	clr.w		MISS_STAT
	clr.w		FIRING
	clr.w		MISS_P
	bra		done_miss	


SHOW_MISS
	move.w		MAN_STAT,d0
	andi.w		#$210,d0
	bne		no_shwm
	
	move.w		SP_TABLE+26,d0		*Xpos
	move.w		SP_TABLE+28,d1		*Ypos
	addq.w		#5,d1
	add.l		G_OFF,d1

	btst.b		#2,MAN_STAT+1
	bne		shw_ml

*	Show missile right

	addi.w		#27,d0
	cmpi.w		#304,d0
	bgt		no_shwm
	move.l		#MISS_CHAR+640,d2
	bra		ps_miss

SHW_ML
	subi.w		#11,d0
	cmpi.w		#0,d0
	blt		no_shwm
	move.l		#MISS_CHAR+512,d2

PS_MISS
	move.w		d0,(a3)
	move.w		d1,2(a3)
	move.l		d2,4(a3)	
	bra		done_miss

MISS_NOZ
	dc.w		6,$0108		*Tone A off,noise A on
	dc.w		3,$10,0,1,$40
	dc.w		7,$a,2,1,$40,0
	dc.w		8,0,1,1,$1f
	dc.w		9
	dc.w		3,5,-1,1,5
	dc.w		9
	dc.w		6,$900		*Tone A off,noise A off
	dc.w		9,9

MISS_STAT
	dc.w		0
MISS_CH
	dc.w		0
MISS_TIM
	dc.w		0
MX_ANITIM
	dc.w		0
MX_INC	
	dc.w		0
MISS_P
	dc.w		0
BLANK
	ds.b		128

NO_SHWM
	move.l		#BLANK_SPRIT,4(a3)
MDOR_CHK

DONE_MISS

************************************************************************************************+

*********************************************************
*	Sparker ground code				*
*	By GAH on 30/9/88				*
*********************************************************

GROUNDER
	tst.w		LEVD_STAT		*Level door in progress
	beq		go4_grnd
	move.l		#BLANK_SPRIT,SP_TABLE+134
	bra		done_grnd
GO4_GRND
	movea.l		#SP_TABLE+130,a3

	tst.w		GRND_P
	bne		grnd_wait

	tst.w		GRND_STAT
	bne		go_grnd

	btst.b		#7,WEAPONS+3
	beq		done_grnd

	btst.b		#7,JOYSTICK+1
	beq		show_grnd		******> show eventually
	
	tst.w		DIE			* alive?
	bne		done_grnd		* nope

	move.w		MAN_STAT,d0
	andi.w		#$210,d0
	bne		done_grnd		*Facing

	lea		GRND_NOZ1(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA

	move.w		#1,GRND_STAT
	move.w		#-1,FIRING
	move.w		#1,SHOOTIN
	bset.b		#0,DOSH+1		*Icons

	move.w		SP_TABLE+26,d0		*Man xpos
	move.w		SP_TABLE+28,d1		*MAn ypos

	add.l		G_OFF,d1
	addi.w		#6,d1			*Correct vertical

	btst.b		#2,MAN_STAT+1		*Left
	bne 		init_gl

	addi.w		#24,d0
	bra		init_grnd

INIT_GL
	subi.w		#8,d0
	ori.w		#8,GRND_STAT		*Say left

INIT_GRND
	move.w		d0,(a3)
	move.w		d1,2(a3)


GO_GRND
	btst.b		#4,GRND_STAT+1		*Explodin
	bne		explod_grnd

	btst.b		#1,GRND_STAT+1		*Movin up??
	bne		chk_grnd

	move.l		#GRND_CHAR,4(a3)

	btst.b		#3,GRND_STAT+1		*Left
	bne		grnd_lft

GRND_RGT
	move.w		(a3),d0			*Xpos
	addi.w		#2,d0
	cmpi.w		#304,d0
	bgt		end_grnd
	move.w		d0,(a3)
	bra		chk_grnd

GRND_LFT
	move.w		(a3),d0
	subq.w		#2,d0
	cmpi.w		#2,d0
	blt		end_grnd
	move.w		d0,(a3)

CHK_GRND		
	tst.l		16(a3)
	beq		do_grnb

	movea.l		16(a3),a1		*Last scr addr
	lea		1280(a1),a2

	movem.w		(a2)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp

	movem.w		(a2),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp
*	

	lea		-160(a1),a1

	movem.w		(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp

	movem.w		-160(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp


DO_GRNB
	tst.w		20(a3)
	beq		no_gbchk

	movea.l		20(a3),a1		*Last scr addr
	lea		1280(a1),a2

	movem.w		(a2)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp

	movem.w		(a2),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp


	lea		-160(a1),a1

	movem.w		(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp

	movem.w		-160(a1),d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		int_gxp

NO_GBCHK
	btst.b		#1,GRND_STAT+1			*UP?
	bne		grnd_up

	movea.l		#SPARK_TAB,a0
	andi.w		#$fe,d0			*Mask out odd posn

GCHK_L
	tst.w		(a0)
	beq		done_grnd		*Nowt there

	move.w		(a0),d1
	andi.w		#$f000,d1		*Explod or clear
	bne		nxt_gchk

	move.w		(a0),d1
	andi.w		#$1ff,d1		*Mask out control

	cmp.w		d0,d1
	bne		nxt_gchk

	move.w		d0,(a3)			*Put altered? xpos
	ori.w		#2,GRND_STAT
	move.w		2(a0),GRND_VPOS		*Get sparker ypos

	move.l		a0,GRND_HADR		*Save xpos addr for exp


	bra		grnd_up

INT_GXP
	*	initialise explosion
	move.w		#16,GRND_STAT
	clr.l		GRND_XPI
	clr.w		GRND_TIM
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	lea		KILL_NOZA(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA		*Switch 'A' off


EXPLOD_GRND
	tst.w		GRND_TIM
	beq		do_grnxp
	subq.w		#1,GRND_TIM
	bra		done_grnd

DO_GRNXP
	move.l		#SB_XPLOS,d0
	add.l		GRND_XPI,d0
	move.l		d0,4(a3)
	move.w		#5,GRND_TIM
	addi.l		#128,GRND_XPI
	cmpi.l		#640,GRND_XPI
	bne		done_grnd
	bra		end_grnd

NXT_GCHK
	lea		12(a0),a0
	bra		gchk_l

GRND_UP
	move.w		2(a3),d0		*Get ypos
	subq.w		#1,d0
	move.w		d0,2(a3)

	btst.b		#2,GRND_STAT+1		*Opening?
	bne		do_open

	move.w		GRND_VPOS,d1		*SParker ypos
	sub.w		d1,d0
	cmpi.w		#25,d0
	bgt		done_grnd

	ori.w		#4,GRND_STAT
	clr.l		GRND_INC
	clr.w		GRND_TIM


DO_OPEN
	cmpi.l		#384,GRND_INC		*Fully open
	beq		stop_it

	tst.w		GRND_TIM
	beq		proc_open
	subq.w		#1,GRND_TIM
	bra		done_grnd

GRND_STAT
	dc.w		0
GRND_TIM
	dc.w		0
GRND_VPOS
	dc.w		0
GRND_HADR
	dc.l		0
GRND_INC
	dc.l		0
GRND_P
	dc.w		0
GRND_XPI
	dc.l		0

GRND_NOZ1
	dc.w		0,$3f5,0,1,60
	dc.w		3,16,0,$2,$211		*Long time
	dc.w		6,$0801			*Was 1
	dc.w		7,10,0,1,16,$40
	dc.w		9
	dc.w		3,5,-1,1,5
	dc.w		9
	dc.w		6,$0900			*was 100
	dc.w		9,9


GRND_NOZ3
	dc.w		0,$222,0,16,16
	dc.w		3,16,0,2,$fc
	dc.w		6,$0801			* Was 1
	dc.w		7,12,0,16,16,$44
	dc.w		9
KILL_NOZA
	dc.w		3,5,-1,1,5
	dc.w		9
	dc.w		6,$0900			* was 1
	dc.w		9,9


PROC_OPEN
	move.w		#5,GRND_TIM
	
	move.l		#GRND_CHAR+128,d0
	add.l		GRND_INC,d0
	move.l		d0,4(a3)

	addi.l		#128,GRND_INC

STOP_IT
	move.w		GRND_VPOS,d0
	addi.w		#10,d0
	move.w		2(a3),d1
	cmp.w		d0,d1
	bne		done_grnd

	movea.l		GRND_HADR,a0
	ori.w		#$1000,(a0)		*Say do exp
	move.w		#10,GRND_P
	move.l		#BLANK,4(a3)
	andi.w		#$fffc,SPK_STAT		*Say no screens

	lea		GRND_NOZ3(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA

	bra		done_grnd

SHOW_GRND
	move.w		MAN_STAT,d0
	move.w		d0,d2			*Save for later
	andi.w		#$210,d0		* Facing
	bne		no_shwg

	move.w		SP_TABLE+26,d0
	move.w		SP_TABLE+28,d1
	addq.w		#7,d1
	add.l		G_OFF,d1

	btst.l		#2,d2			*Left
	bne		shwgl

	addi.w		#30,d0
	cmpi.w		#304,d0
	bge		no_shwg
	bra		psg

SHWGL
	subi.w		#14,d0
	cmpi.w		#1,d0
	ble		no_shwg

PSG
	move.w		d0,(a3)
	move.w		d1,2(a3)
	move.l		#GRND_CHAR,4(a3)
	bra		done_grnd

NO_SHWG
	move.l		#BLANK_SPRIT,4(a3)
	bra		done_grnd


GRND_WAIT
	subq.w		#1,GRND_P
	bne		done_grnd
	
END_GRND
	clr.w		GRND_STAT
	move.l		#BLANK_SPRIT,4(a3)
	clr.w		FIRING
	move.l		#$ff8800,a0
	move.w		#$800,d0
	movep.w		d0,0(a0)
	clr.w		VOL_ITA
DONE_GRND

*********************************************************************************************

*******Door explosions
**********************************************************
*	Door explosions					*
*	By GAH on 25/9/88				*
*********************************************************

	btst.b		#0,DOOR_XP+1		*Init??
	bne		init_dxp

	btst.b		#1,DOOR_XP+1		*Going?
	bne		do_doorxp
	bra		done_dxp

DXP_XPOS
	dc.w		0
DXP_YPOS
	dc.w		0
DOOR_XP
	dc.w		0
DXP_TIM
	dc.w		0
DXP_OFFS
	dc.l		0
DXP_INC
	dc.l		0

INIT_DXP
	clr.l		d0
	clr.l		d1
	clr.l		d2
	move.w		DXP_XPOS,d0
	move.w		DXP_YPOS,d1		*Set by missile
	subi.w		#16,d0
	subi.w		#16,d1
	

	asr.w		#1,d0
	move.w		d1,d2
	asl.w		#7,d1
	asl.w		#5,d2

	add.l		d2,d1
	add.l		d1,d0
	move.l		d0,DXP_OFFS
	move.w		#2,DOOR_XP
	clr.w		DXP_TIM
	clr.l		DXP_INC

	
DO_DOORXP
	tst.w		DXP_TIM
	beq		go_dxp
	subq.w		#1,DXP_TIM
	bra		done_dxp

GO_DXP
	tst.w		SC_NO
	bne		xpdb

	move.l		#SCREENA,d0
	bset.b		#2,DOOR_XP+1		*Say one done
	bra		got_scn

XPDB
	move.l		#SCREENB,d0
	bset.b		#3,DOOR_XP+1		*say two done

GOT_SCN
	movea.l		DXP_OFFS,a0
	adda.l		d0,a0			*a0=addr of top lhs
	
	lea		8(a0),a1
	lea		8(a1),a2		*next to char right
	
	movea.l		#DXP_CHAR,a3		*addr data
	adda.l		DXP_INC,a3

	lea		128(a3),a4
	lea		128(a4),a5

	moveq		#2,d7			*3 cahrs down

DXP_LOOP1
	moveq		#15,d6			*15 lines/char
DXP_LOOP2
	movem.l		(a3)+,d0-d1
	movem.l		(a4)+,d2-d3
	movem.l		(a5)+,d4-d5

	move.l		d0,(a0)+
	move.l		d1,(a0)+
	move.l		d2,(a1)+
	move.l		d3,(a1)+
	move.l		d4,(a2)+
	move.l		d5,(a2)+

	lea		152(a0),a0
	lea		152(a1),a1
	lea		152(a2),a2
	dbf.w		d6,dxp_loop2

	lea		256(a3),a3
	lea		256(a4),a4
	lea		256(a5),a5		*next char
	dbf.w		d7,dxp_loop1

	move.w		DOOR_XP,d0
	andi.w		#$c,d0			
	cmpi.w		#$c,d0			*Both done
	bne		done_dxp		*no
	move.w		#6,DXP_TIM
	move.w		#2,DOOR_XP

	add.l		#1152,DXP_INC
	cmpi.l		#5760,DXP_INC
	bne		done_dxp

	clr.w		DOOR_XP
	move.w		#2,MISS_P
	move.l		#$20000,d0
	jsr		add_scor

DONE_DXP

**********************************************************************************************
*******SParker
*********************************************************
*	Sparker processor				*
*	By GAH on 27/9/88				*
*	SPARK_TAB defined in ROOM_PRO.S			*
*	Table format:-					*
*	dc.w		XPOS/d15=dead,d14=explodin	*
*	dc.w		YPOS				*
*	dc.l		Addr of xpos in room table	*
*			set d15 xpos to kill sprkr	*
*	dc.w		Explosion status		*
*********************************************************

SPK_FLASH	equ	$ff		*Sparker flash limiter


DO_SPARK
	tst.w		IMMUNE		*If flashing,no sparkers
	bne		no_sparks
	movea.l		#SPARK_TAB,a3
	
	tst.w		SPK_ANITIM
	beq		do_spkani
	subq.w		#1,SPK_ANITIM
	bra		no_sparks

DO_SPKANI


	tst.w		(a3)
	beq		done_sparks		*xpos=0=end of table

	btst.b		#4,(a3)
	bne		init_sxp

CONT_SXP

	moveq		#0,d0
	moveq		#0,d1

	move.w		(a3),d0			*Xpos
	andi.w		#$1ff,d0		*Mask out
	move.w		2(a3),d1		*Ypos

	move.l		d1,d2

	asr.w		#1,d0
	asl.w		#5,d1
	asl.w		#7,d2
	
	add.w		d1,d2
	add.w		d2,d0			*d0=offset from screen start

	tst.w		SC_NO			*Which screen
	bne		spk_b

	movea.l		#SCREENA,a0
	bset.b		#0,SPK_STAT+1		*Say one done
	bra		put_spkr

INIT_SXP
	clr.w		8(a3)
	ori.b		#32,(a3)		*	Set clear

	bra		cont_sxp


SPK_B
	movea.l		#SCREENB,a0
	bset.b		#1,SPK_STAT+1		*Say two done

PUT_SPKR
	lea		0(a0,d0.l),a0		*A0=scr addr
	
	lea		5120(a0),a1		*32 lines down

	btst.b		#6,(a3)			*Exploding
	bne		exp_spk

	movea.l		#DXP_CHAR+5760,a2	*Char start
	adda.l		SPK_INC,a2
	move.w		#-1,d7			*Say sparking

	btst.b		#5,(a3)			*Clear
	bne		set_blspk
*	Flash it

	tst.w		SPK_SHOW
	beq		no_spkclr

	andi.w		#SPK_FLASH,10(a3)		*Mask timer
	subq.w		#1,10(a3)
	bne		decide

	eori.w		#$8000,(a3)		*Change show/not
	move.w		TIM200,d0
	mulu.w		#$1234,d0
	ori.w		#$10,d0
	move.w		d0,10(a3)

DECIDE
	btst.b		#7,(a3)
	beq		no_spkclr		* 0=show


SET_BLSPK
	movea.l		#DXP_CHAR+7680,a2	*No spark
	moveq		#0,d7			*Say no spark

NO_SPKCLR
	tst.w		d7			*Sparkin'
	beq		no_mcchk

	move.w		(a3),d0			*Spk Xpos
	andi.w		#$1ff,d0
	move.w		d0,d2			*Save xpos
	move.w		SP_TABLE+26,d1		*Man xpos

	cmp.w		d1,d0
	blt		other_s

	addi.w		#32,d1
	cmp.w		d1,d0
	bgt		other_s
	bra		spk_die

OTHER_S
	move.w		SP_TABLE+26,d1
	addi.w		#16,d2
	cmp.w		d1,d2
	blt		no_mcchk
	addi.w		#32,d1
	cmp.w		d1,d2
	bgt		no_mcchk

SPK_DIE
	move.w		2(a3),d0		*Spk Ypos
	move.w		SP_TABLE+28,d1		*Man Ypos
	addi.w		#64,d0
	cmp.w		d0,d1
	bge		no_mcchk

	move.w		#1,DIE
	
NO_MCCHK



	lea		256(a2),a4
	moveq		#7,d7			*8 lots of 4

PSPK_LOOP
	move.w		d7,-(sp)

	movem.l		(a2)+,d0-d7

	move.l		d0,(a0)
	move.l		d1,4(a0)
	move.l		d2,160(a0)
	move.l		d3,164(a0)
	move.l		d4,320(a0)
	move.l		d5,324(a0)
	move.l		d6,480(a0)
	move.l		d7,484(a0)


	movem.l		(a4)+,d0-d7

	move.l		d0,(a1)
	move.l		d1,4(a1)
	move.l		d2,160(a1)
	move.l		d3,164(a1)
	move.l		d4,320(a1)
	move.l		d5,324(a1)
	move.l		d6,480(a1)
	move.l		d7,484(a1)

	lea		640(a0),a0
	lea		640(a1),a1

	move.w		(sp)+,d7
	dbf.w		d7,pspk_loop

	move.w		SPK_STAT,d0
	andi.w		#3,d0			*All done
	cmpi.w		#3,d0
	bne		nxt_spk

	btst.b		#5,(a3)		*Clearing?
	beq		nxt_spk
	btst.b		#4,(a3)		*Init exp
	beq		nxt_spk

	bclr.b		#5,(a3)
	bset.b		#6,(a3)		*Say explodin
	bclr.b		#4,(a3)		*No more init

NXT_SPK
	lea		12(a3),a3
	bra		do_spkani

EXP_SPK
	lea		2080(a0),a0		*13 lines down
	moveq		#0,d0
	movea.l		#DXP_CHAR+6784,a2
	move.b		9(a3),d0		*Incarn
	asl.w		#7,d0
	lea		0(a2,d0.w),a2
	moveq		#15,d7

SXP_XPL
	movem.l		(a2)+,d0-d1
	
	move.l		d0,(a0)
	move.l		d1,4(a0)
	lea		160(a0),a0
	dbf.w		d7,sxp_xpl

	move.w		SPK_STAT,d0
	andi.w		#3,d0			*All done
	cmpi.w		#3,d0
	bne		nxt_spk

	addi.b		#1,9(a3)		*Incarn
	cmpi.b		#4,9(a3)		*End flash
	bne		thru_sxp

	cmpi.b		#24,8(a3)		*24 flashes
	beq		strt_exp

	addq.b		#1,8(a3)
	clr.b		9(a3)			*Reset flash
	bra		thru_sxp
STRT_EXP
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

THRU_SXP
	cmpi.b		#7,9(a3)		*End of exp
	bne		nxt_spk

	andi.w		#$8fff,(a3)		*CLear all bits

********** Reset no sparker timer to zero here

	bra		nxt_spk
	
SPK_STAT
	dc.w		0	
SPK_ANITIM
	dc.w		0
SPK_INC
	dc.l		0
SPK_PAUSE
	dc.w		0			*<>0 then no sparkin'
SPK_SHOW
	dc.w		1			*set to <>0 for no sparkin
	
SPK_PSTAT
	dc.w		0			*clear to spark


DONE_SPARKS
	move.w		SPK_STAT,d0
	andi.w		#3,d0
	cmpi.w		#3,d0
	bne		no_sparks

	move.w		#3,SPK_ANITIM
	andi.w		#$fffc,SPK_STAT
	eori.l		#512,SPK_INC
NO_SPARKS

***********************************************************************************************

******Background animation
*********************************************************
*	Background animator				*
*	By GAH 5/10/88					*
*	All graphics in bi-directional,5 incarnation	*
*	16x16 pixel blocks				*
*********************************************************

BKANI
	tst.l		TEL_OFF			*Owt there?
	beq		no_tani

	tst.w		SC_NO
	bne		telb

	movea.l		#SCREENA,a0
	bset.b		#0,TEL_STAT+1
	bra		got_tadr

TELB
	movea.l		#SCREENB,a0
	bset.b		#1,TEL_STAT+1

GOT_TADR
	move.l		#DXP_CHAR+8832,a1	*Offset to TV in bckgrnd

	move.l		TEL_INC,d0		*Incaation
	adda.l		d0,a1

	add.l		TEL_OFF,a0		*Offset into screen
	moveq		#15,d7

TEL_LOOP
	move.l		(a1)+,(a0)+
	move.l		(a1)+,(a0)+
	lea		152(a0),a0
	dbf.w		d7,tel_loop

	move.w		TEL_STAT,d1
	andi.w		#3,d1
	cmpi.w		#3,d1
	bne		no_tani			*Not done both yet

	andi.w		#$fffc,TEL_STAT		*Clear which done

	btst.b		#2,TEL_STAT+1		*Incarn down?
	bne		tel_incd

	addi.l		#128,d0
	cmpi.l		#640,d0
	bne		no_rest

	move.w		#512,d0			*Set back one
	bset.b		#2,TEL_STAT+1		*Change dir
	bra		no_rest

TEL_STAT
	dc.w		0			*Back ani status

TEL_INC
	dc.l		0			*Offset into font

TEL_OFF
	dc.l		0			*Offset into screen
						*Set by room draw



TEL_INCD
	subi.l		#128,d0
	cmpi.l		#-128,d0
	bne		no_rest

	moveq		#0,d0
	bclr.b		#2,TEL_STAT+1		*Change dir

NO_REST
	move.l		d0,TEL_INC

NO_TANI
		
******************************************************************************************

*****************************************************************
* Final room processor						*
* Places bomb in generator,places alarm sample and runs final	*
* sequence.							*
* By GAH on 30/9/90						*
*****************************************************************

SAM_DELAY	EQU	22			*Sample repeat delay


FINAL_ROOM
	cmpi.w		#3,LEVEL_NUM
	bne		forg_final		*Not level 4
	cmpi.w		#25,ROOM_IN
	bne		forg_final		*Not final room

	btst.b		#0,FINAL_STAT+1		*Bomb in place??
	bne		bomb_in

	movea.l		#SP_TABLE+26,a3		*Red ace sprite 0

	cmp.w		#$ee,(a3)
	bgt		forg_final
	cmp.w		#$45,(a3)
	blt		forg_final
	cmp.w		#$30,2(a3)
	blt		forg_final
* Now put bomb into generator
	movea.l		#VBB_HOLD+$3282,a4	*Source
	movea.l		#SCREENA+$4640,a6	*Desta
	movea.l		#SCREENB+$4640,a5	*Dest b
	move.w		#47,d7			*Scan line counter
PUT_BOMB
	movem.l		(a4),d0-d6/a0
	movem.l		d0-d6/a0,(a5)
	movem.l		d0-d6/a0,(a6)
	lea.l		160(a5),a5
	lea.l		160(a6),a6
	lea.l		160(a4),a4
	dbf.w		d7,put_bomb
	
	bset.b		#0,FINAL_STAT+1		*Say bomb in place
	move.l		#SAM_DELAY,FINAL_TMR	*Set sample play timer
BOMB_IN
	tst.l		FINAL_TMR
	beq		do_finsam
	subq.l		#1,FINAL_TMR
	bra		chk_findoor
DO_FINSAM
	move.l		#SAM_DELAY,FINAL_TMR

	DO_SAM		DYING_SAM,DYING_LEN,1

CHK_FINDOOR
	btst.b		#1,FINAL_STAT+1		*Is door fully processed??
	beq		forg_final
	clr.w		CYCLE
	movea.l		#CHARPALETTE,a0
	movea.l		#FADEPALETTE,a1
	movem.l		(a0),d0-d7		*Get entire palette
	movem.l		d0-d7,(a1)
WAIT_FOREVER
	movea.l		#GEN_NOZOFF,a0
	jsr		noize_init
	move.l		a0,SON_TABA
********Asteroid destoryed,Fade to grey
	movea.l		#FADEPALETTE,a0
	move.w		#16,d7			*Counter
	moveq.w		#0,d6			*End flag to 0
FADE_LOOP
	move.w		(a0),d0
	move.w		d0,d1			*For later
	andi.w		#$f00,d0		*Any msb
	beq		no_msbcol
	subi.w		#$100,d1
	moveq.w		#1,d6
NO_MSBCOL
	move.w		d1,d0
	andi.w		#$f0,d0			*Any middle bits
	beq		no_midbit
	subi.w		#$10,d1
	moveq.w		#1,d6			*Say more yet
NO_MIDBIT
	move.w		d1,d0
	andi.w		#$f,d0			*Any LSB
	beq		no_lsbcol
	subi.w		#1,d1
	moveq.w		#1,d6
NO_LSBCOL
	move.w		d1,(a0)+
	dbf.w		d7,fade_loop
	movem.l		d6/a0,-(sp)		*Save for end check

	
	pea		FADEPALETTE(pc)
	move.w		#6,-(sp)
	trap	#14
	addq.l		#6,sp	
	movem.l		(sp)+,d6/a0
	
	move.w		TIM200,d0		*TImer
	add.w		#50,d0
WAIT_DOWNCOL
	cmp.w		TIM200,d0
	bne		wait_downcol

	tst.w		d6
	bne		wait_forever

WAIT_FINAL
	move.l		#SCREENA,d0
	move.w		#-1,-(sp)		*Dont change res
	move.l		d0,-(sp)
	move.l		d0,-(sp)
	move.w		#5,-(sp)
	trap		#14
	lea		12(a7),a7			*Chnage to screen A

LOAD_ZZ
	move.l		#$80000,d0		*Long delay
WAIT_ZZ
	subq.l		#1,d0
	bne		wait_zz

	movea.l		#ASTABAK_FIL,a0		*Background file
	jsr		sam_open

	move.w		#0,-(sp)		*Relative from start
	move.w		SAM_HANDLE,-(sp)
	move.l		#2,-(sp)		*2 bytes in
	move.w		#$42,-(sp)		*LSEEK
	trap		#1
	add.l		#10,sp

	move.w		#32,d0
	movea.l		#FADEPALETTE,a0
	jsr		sam_read

	move.w		#32032,d0		*length
	movea.l		#SCREENA,a0
	jsr		sam_read
	jsr		sam_close

	movea.l		#ASTANI_FIL,a0		*Background file
	jsr		sam_open
	
	move.w		#0,-(sp)		*Relative from start
	move.w		SAM_HANDLE,-(sp)
	move.l		#34,-(sp)		*34 bytes in
	move.w		#$42,-(sp)		*LSEEK
	trap		#1
	add.l		#10,sp

	move.w		#32032,d0		*length
	movea.l		#VBB_HOLD,a0
	jsr		sam_read
	jsr		sam_close
	
	pea		FADEPALETTE(pc)		*Set asteroid palette
	move.w		#6,-(sp)
	trap		#14
	addq.l		#6,sp	

	move.l		#$3d,FINSHP_X
	move.l		#$40,FINSHP_Y

WAIT_AWHILE
	movea.l		#SCREENA,a0		*Screen start
	movea.l		#FINSHP_DAT,a1		*Sprite data
	move.l		FINSHP_X,d0
	andi.w		#1,d0			*Which sprite for flicker
	asl.w		#8,d0			*sprite 0 or 2
	lea		0(a1,d0.w),a1
	movea.l		#CACHE,a2		*cache addr
	movea.l		FINSHP_X,a3
	movea.l		FINSHP_Y,a4
	jsr		plotsprite
	move.l		a5,FINSHP_LAST

	movea.l		#SCREENA,a0		*Screen start
	movea.l		#FINSHP_DAT+128,a1	*Sprite data
	movea.l		#CACHE+256,a2		*cache addr
	movea.l		FINSHP_X,a3
	adda.l		#16,a3
	movea.l		FINSHP_Y,a4
	jsr		plotsprite
	move.l		a5,FINSHP_LAST+4


	move.w		#37,-(sp)
	trap		#14
	addq.l		#2,sp			*Wait Vsync

	cmpi.l		#$97,FINSHP_X		*At asteroid??
	bne		not_atast
	move.w		TIM200,d0
	addi.w		#100,d0
WAIT_ATAST
	cmp.w		TIM200,d0
	bne		wait_atast
NOT_ATAST
	movea.l		#CACHE+256,a2
	movea.l		FINSHP_LAST+4,a5
	jsr		clearsprite


	movea.l		#CACHE,a2
	movea.l		FINSHP_LAST,a5
	jsr		clearsprite
	
	addi.l		#1,FINSHP_X
	cmpi.l		#288,FINSHP_X
	bne		wait_awhile

	move.l		#0,FINAL_TMR		*Rest timer	
	clr.w		AST_CNTR		*animation counter
	clr.w		AST_NOZCNT		*Noize timer

ANIMATE_AST
	move.w		TIM200,d2
	tst.l		FINAL_TMR		*Time up??
	beq		go_astan
	subi.l		#1,FINAL_TMR
	
	tst.w		AST_NOZCNT
	beq		do_astnoz
	subi.w		#1,AST_NOZCNT
	bra		ANIMATE_AST
DO_ASTNOZ
	move.w		TIM200,d0
	mulu.w		d2,d0			*Semi random
	
	move.w		d0,AST_NOZCNT		*Reset timer
	DO_SAM		EXPLOS,EXPLOS_LEN,0
	bra		animate_ast
GO_ASTAN
	move.l		#$8000,FINAL_TMR	*Reset timer
	movea.l		#SCREENA+$2838,a0	*Dest addr
	movea.l		#VBB_HOLD,a1		*Source addr
	move.l		#AST_ANIOFF,a2		*Offset addr table
	move.w		AST_CNTR,d0
	lea		0(a2,d0.w),a2		*get offset addr
	adda.l		(a2),a1			*Source addr
	move.w		#63,d7			*Number of lines
PUT_ASTEXP
	movem.l		(a1),d0-d6/a2		*Get 4 x 16 pixels
	movem.l		d0-d6/a2,(a0)		
	movem.l		32(a1),d0-d3		*Get 2 x 16 pixels
	movem.l		d0-d3,32(a0)
	lea		160(a1),a1
	lea		160(a0),a0
	dbf.w		d7,put_astexp
	
	
	addi.w		#4,AST_CNTR		*Next offset
	cmpi.w		#52,AST_CNTR		*Finished
	bne		animate_ast
END_ALL
	move.l		#$A0000,d0
ea_wait	
	subq.l		#1,d0
	bne.s		ea_wait
	pea		ENDTEXT(pc)		*
	move.w		#9,-(a7)
	trap		#1
	addq.l		#6,a7
	jsr		init_mus		* play tune
	clr.w		JOYSTICK
ENDWAIT
	btst.b          #7,JOYSTICK+1 
	beq.s		ENDWAIT
	jmp		K_NEW_GAME
	

ENDTEXT
	dc.b		ESC,'Y',32+2,32,ESC,'b',8
	dc.b		'  Congratulations! You are victorious!',0
	EVEN

AST_ANIOFF
	dc.l		0,10240,20480
	dc.l		10240,20480
	dc.l		56,10296,20536
	dc.l		10296,20536
	dc.l		112,10352,20592

AST_CNTR
	dc.w		0			*Offset table pointer
		
	
	bra		wait_awhile

AST_NOZCNT
	dc.w		0

FINAL_TMR
	dc.l		0
FINAL_STAT
	dc.w		0			*Final status 
FADEPALETTE
	DS.B		38			*For faed palette

FINSHP_DAT
	include		'FINSHP.S'		* dc.b data only
FINSHP_X
	dc.l		0
FINSHP_Y
	dc.l		0
FINSHP_LAST
	ds.b		8		

BLOW_NOIZE
	dc.w		0,$300,-9,1,100
	dc.w		3,$10,0,1,100
	dc.w		7,10,1,1,100,$60
	dc.w		6,3
	dc.w		9
	dc.w		6,$300
	dc.w		9,9

GEN_NOZOFF
	dc.w		6,$100
	dc.w		3,$0,0,1,1
	dc.w		9
	dc.w		6,$100
	dc.w		9,9,9,9

ASTABAK_FIL
	dc.b		'ASTABAK.PI1',0
	even
ASTANI_FIL
	dc.b		'ASTABOOM.PI1',0
	even
AST_XPADR
	dc.l		0		*Asteroid explosion source addr


FORG_FINAL


***********************************************************************************************
*****Icon pickup
*****************************************************************
*	Icon Pickup						*
*	By GAH on 16/10/88					*
*****************************************************************

ICNP
	tst.w		PICK_STAT		*Already?
	bne		do_pick

	tst.w		RM_ITOF			*Any icons?
	beq		done_pick

	move.w		SP_TABLE+26,d0
	move.w		SP_TABLE+28,d1

	addi.w		#16,d0
	addi.w		#16,d1			*d0/d1=center red ace

	move.w		RM_ITOF,d7
	subq.w		#1,d7			*Correct for dbf
	movea.l		#RM_ICONT,a1

PICK_LOP


	move.w		(a1),d2			*ICON xpos
	tst.w		d2
	beq		no_ip			*ALready picked

	cmp.w		d2,d0
	blt		no_ip

	addi.w		#16,d2

	cmp.w		d2,d0
	bgt		no_ip

	move.w		2(a1),d2		*ICON ypos

	cmp.w		d2,d1
	blt		no_ip

	addi.w		#16,d2
	cmp.w		d2,d1
	bgt		no_ip

	lea		ICN_PCKNOZ(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABB

*********************************
	move.w		6(a1),ICN_OFF		*Hold screen offset
	move.l		a1,ICN_HLADR		*Hold icon tab addr
	movea.l		8(a1),a2		*Addr of table addr
	move.w		#166,(a2)		*Set blank in room table

	bra		do_pick

ICN_PCKNOZ
	dc.w		1,400,10,1,3
	dc.w		4,10,0,1,3
	dc.w		6,$1002			*B noise off
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,10,0,1,3
	dc.w		9

	dc.w		1,400,10,1,3
	dc.w		4,9,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,9,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,8,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,8,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,7,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,7,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,6,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,6,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,5,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,5,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,4,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,4,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,3,-1,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,3,1,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,2,0,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,2,0,1,3
	dc.w		9
	dc.w		1,400,10,1,3
	dc.w		4,1,0,1,3
	dc.w		9
	dc.w		1,700,-10,1,3
	dc.w		4,1,0,1,3
	dc.w		9

	dc.w		6,$1200
	dc.w		4,15,-1,0,15		*Turn VOlc=0
	dc.w		9,9	


NO_IP
	lea		16(a1),a1
	dbf.w		d7,pick_lop
	bra		done_pick

DO_PICK

	tst.w		SC_NO
	bne		pick_b

	bset.b		#0,PICK_STAT+1
	movea.l		#SCREENA,a0
	bra		picked

ICN_HLADR
	dc.l		0

PICK_STAT
	dc.w		0
RM_ITOF
	dc.w		0		*offset into table
RM_ICONT
	ds.w		40		* 10 icons / screen
ICN_OFF
	dc.w		0


PICK_B
	bset.b		#1,PICK_STAT+1
	movea.l		#SCREENB,a0

PICKED
	move.w		ICN_OFF,d0		*Offset into screen

	lea		0(a0,d0.w),a0
	movea.l		#STAT_CHR+1664,a2	*Blank icon
	moveq		#15,d7

PICKUP
	move.l		(a2)+,(a0)+
	move.l		(a2)+,(a0)
	lea		156(a0),a0
	dbf.w		d7,pickup

	cmp.w		#3,PICK_STAT		*Drawn both??
	bne		done_pick

	clr.w		PICK_STAT
	movea.l		ICN_HLADR,a1
	clr.w		(a1)			*Zap xpos

	
*********Process icon pickup*******************

	move.w		4(a1),d0		*Get icon #
	move.w		d0,d6

	cmpi.w		#0,d0
	beq		more_fuel

	cmpi.w		#11,d0			*Power up
	beq		more_power

	cmpi.w		#7,d0
	beq		extra_man

	cmpi.w		#34,d0			*Nuke char 1
	blt		no_nuke

	cmpi.w		#39,d0			*Nuke char 6
	bgt		no_nuke
	bra		do_nuke

NO_NUKE

*******Get icon details from table

	movea.l		#WEP_DET,a0
	asl.w		#4,d0			* icon# x 16
	lea		0(a0,d0.w),a0

	moveq.w		#6,d7
	movea.l		#WEP_TAB,a1

****First see if there is already one in the table

WEA_ALR
	move.l		(a1),d0
	bclr.l		#31,d0			*Mask out used bit
	cmp.l		(a0),d0
	beq		put_inwt

	lea		16(a1),a1
	dbf.w		d7,wea_alr

***Not already there so find a free position in table

	movea.l		#WEP_TAB,a1
	moveq.w		#6,d7

UNU_L
	tst.l		(a1)
	beq		got_nw
	lea		16(a1),a1
	dbf.w		d7,unu_l

*****SOmething has gone HORRIBLY WRONG if it gets here!!!!****

	bra		done_pick

GOT_NW
	move.l		(a0)+,(a1)+		*Set WEAPONS mask
	eori.w		#7,d7			*Invert XPOS
	subq.w		#1,d7			*D7= position

	cmp.w		WEP_XP,d7		*Same position
	bne		no_wsame

	move.l		-4(a1),WEAPONS		*Set gun
	ori.l		#$80000000,-4(a1)


NO_WSAME
	asl.w		#3,d7			* xpos x 8

	add.w		#28216,d7
	move.w		d7,(a1)+		*offset into screen

	move.w		(a0),(a1)+		*Number to next icon
	move.w		(a0)+,(a1)+		*reset ' '   '    '
	
	move.w		(a0)+,(a1)+		*Max # icons
	move.l		(a0),(a1)		*Root icon addr

	move.l		(a0),a0			*a0 = addr of data
	bra		draw_icon

PUT_INWT
	eori.w		#7,d7
	subq.w		#1,d7			*d7 = xpos
	asl.w		#3,d7
	addi.w		#28216,d7		*d7 = scr offset

	cmpi.w		#1,d6
	beq		mor_miss
	cmpi.w		#3,d6
	beq		mor_miss

	move.w		4(a0),d5

	add.w		d5,6(a1) 		*Add to existin
	move.w		6(a0),d5
	add.w		d5,10(a1)
	movea.l		8(a0),a0		*Full icon addr data
	lea		12(a1),a1		*shift a1 on for
						*shield test
	bra		draw_icon

MOR_MISS
	addq.w		#1,6(a1)		*Special case
	bra		done_pick		*Only one icon

DRAW_ICON

****A0.l = data address
****d7.w = offset into screen

	movea.l		#SCREENA,a2
	movea.l		#SCREENB,a3

	lea		0(a2,d7.w),a2
	lea		0(a3,d7.w),a3
	moveq		#15,d7

DI_L
	move.l		(a0),(a2)+
	move.l		4(a0),(a2)
	move.l		(a0)+,(a3)+
	move.l		(a0)+,(a3)

	lea		156(a2),a2
	lea		156(a3),a3
	dbf.w		d7,di_l
	
	move.w		-10(a1),d0			*Get weapon type
	cmpi.w		#$100,d0		*Shield??
	bne		done_pick
	
	addq.w		#4,SHIELD

	move.w		-8(a1),SHLD_SC		*Shield offset screen
	lea		-12(a1),a1
	move.l		a1,SHLD_WADR		*Shield wep tab posn

	bra		done_pick

DO_NUKE
	subi.w		#34,d0
	bset.b		d0,NUKE_GOT+1
	move.w		d0,d1
	asl.w		#2,d0			* x 4
	asl.w		#1,d1
	add.w		d1,d0			* x 6
	movea.l		#FILL_NUKE,a0
	lea		0(a0,d0.w),a0
	lea		NUKE_GOFF(pc,d1.w),a1
	move.w		(a1),(a0)		* Set got offset
	
*************NUKE PICKUP NOISE HERE********************
	bra		done_pick
NUKE_GOFF
	dc.w		$3200,$3210,$3220
	dc.w		$4600,$4610,$4620

*	Source offset for nuke got bits
NUKE_GOT
	dc.w		0


MORE_FUEL
	move.w		#1,ADD_FUEL		*Signal to jp_fuel
	bra		done_pick

MORE_POWER					*Power up icon
	move.w		#MAX_RAPWR,LIFE_LEV
	jsr		full_power
	bra		done_pick


EXTRA_MAN
	addq.w		#1,NUM_LIVE
	move.w		NUM_LIVE,d7

	cmpi.w		#3,d7
	bgt		done_pick		* 3 = max display

	asl.w		#3,d7
	addi.w		#28288,d7
	movea.l		#STAT_CHR+1024,a0
	bra		draw_icon

WEP_DET

*	FUEL

	dc.l	0
	dc.w	0,0
	dc.l	STAT_CHR+1152
	dc.l	0

*	MISSILE

	dc.l	$40
	dc.w	5,1
	dc.l	BAK_CHARS+20096
	dc.l	0

*	GRENADE

	dc.l	$20
	dc.w	3,4
	dc.l	STAT_CHR+2944
	dc.l	0

*	GROUNDER
	
	dc.l	$80
	dc.w	5,1
	dc.l	BAK_CHARS+20352
	dc.l	0

*	BULLET

	dc.l	4
	dc.w	0,0
	dc.l	STAT_CHR
	dc.l	0

*	SHIELD
	dc.l	$100
	dc.w	1,4
	dc.l	BAK_CHARS+20608
	dc.l	0

*	BFO

	dc.l	$8
	dc.w	10,4
	dc.l	STAT_CHR+512
	dc.l	0	
	
*	LIFE

	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

*	LASER
	
	dc.l	1
	dc.w	10,4
	dc.l	STAT_CHR+1920
	dc.l	0

*	SMART

	dc.l	$10
	dc.w	1,4
	dc.l	STAT_CHR+3456
	dc.l	0
	
DONE_PICK
	
***********************************************************************************************

*******Beastie door movements************
DO_SDPUT
		move.w	SINGLE_DOORS,d7		*# sing doors
		move.l	#SDOOR_TAB,a6
		tst.w	d7
		beq	done_dput
		subq.w	#1,d7
PUT_SDOORS
		move.w	(a6),d0			*xpos & stat
		andi.w 	#$6000,d0		*Needs putting
		beq	no_dput

		btst.b	#6,(a6)
		beq	second			*Clear one of two 
		bclr.b	#6,(a6)
		bra	cont_d

SECOND
		bclr.b	#5,(a6)

CONT_D
		moveq	#0,d1
		move.l	d1,d2
		move.l	#0,d0

		move.w	(a6),d1
		move.w	2(a6),d2		*Ypos
		andi.w	#$1ff,d1		*Clear non xpos bits
		
		move.b	(a6),d0			*Door stat
		andi.b	#$6,d0
		asl.l	#6,d0			*x 128,pre shft x 2

		movea.l	#SDOOR_DAT,a1
		adda.l	d0,a1

		btst.b	#0,SC_NO+1
		bne	set_scb
		movea.l	#SCREENA,a0
		bra	do_dput1
SET_SCB
		movea.l	#SCREENB,a0
DO_DPUT1
		jsr	plot_char
NO_DPUT
		lea	8(a6),a6
		dbf.w	d7,put_sdoors
DONE_DPUT

*********************************************************************************

		
		clr.l	WHICH_PROC	; Default to normal
		tst.w	BB_STAT
		beq	norm_sproc
		move.l	#19,WHICH_PROC
NORM_SPROC

		moveq	#0,d0		;sprite count
		move.l	#sp_table,a6

NEXT
		lea	SP_PROCTAB(pc),a0
		lea	0(a0,d0.w),a0	; Point to process flag table
		adda.l	WHICH_PROC,a0	; Which sprite process table
		tst.b	(a0)
		beq	calc_next	; Dont process this one

		lea     0.w,a3
		lea 	0.w,a4
		move.w	(a6),a3 	;xpos
		move.w	2(a6),a4	;ypos
		bsr	get_sc

		move.l	4(a6),a1
		cmpa.w	#0,a1
		bne	put_blit		****WAS CALC_NEXT
		movea.l	#BLANK_SPRIT,a1		*****
		move.l	a1,4(a6)		*****
PUT_BLIT					*****
		jsr	plotsprite
ss
		lea	sc_no(pc),a1
		btst.b	#0,1(a1)
		bne	put_c1
		move.l	a5,20(a6)
		bra	calc_next

PUT_C1
		move.l	a5,16(a6)

CALC_NEXT
		lea	26(a6),a6
		addq.w	#1,d0
		move.w	#NUM_SPR,d1
		addq.w	#1,d1		**So do all
		cmp.w	d0,d1
		bne	next		

DONE_CPUT
		lea	draw(pc),a1
		clr.w	(a1)

		lea	sc_chan(pc),a1
		move.w	#1,(a1)

		jsr	room_change	***************


;DEBUGGING if DEBUG=1 then keyboard controls jet_pack on/off

		IFNE	DEBUG
		move.b	key_timer,d1
		beq	do_key
		subq.b	#1,key_timer
		bra	no_chan
DO_KEY


		move.b	KEY_CODE,d0
		cmpi.b	#$39,d0
		bne	weap_chan

		move.l	#man_stat,a0
		eori.w	#$120,(a0)	;jet pack fuel
		move.b	#$ff,key_timer
	
		bra	no_chan
WEAP_CHAN
NO_CHAN
		ENDC

*********************************************************************************************

********************************************************* 
*	Single beastie mover				*
*	By GAH on 14/07/88				*
*	For status word ,see SB_COLL.S			*
*********************************************************

ANI16_TIM		equ	5
TIM2_CIRC		equ	400		*8 seconds to circ
	
	tst.w		LEVD_STAT		*Sublevel door??
	beq		go_sbmov
	clr.l		SP_TABLE+212
	clr.l		SP_TABLE+238
	clr.l		SP_TABLE+264
	clr.l		SP_TABLE+290
	bra		no_sbmov
GO_SBMOV
	tst.w		BB_THERE		*Big beastie??
	bne		no_sbmov

	tst.w		VBB			*Very big beastie
	bne		no_sbmov

	btst.b		#0,FBB_STAT+1		*FBB??
	bne		no_sbmov
		
*	Beastie animation time
	movea.l 	#SP_TABLE+208,a3
	tst.w		SBEA_MASK		*Any there
	beq		no_sbmov
	move.w		SBEA_MASK,d7
	subq.w		#1,d7

MOVE_SB
	move.l		4(a3),d0		****
	cmpi.l		#BLANK_SPRIT,d0		****
*	tst.l		4(a3)			*Owt there?
	beq		no_ani16

	move.w		24(a3),d3		*Beastie number
	andi.w		#$1f,d3
	cmpi.w		#$1f,d3
	beq		done_sb			*EXPLOSION

	btst.b		#6,25(a3)		*Subject to grav?
	beq		no_grav

	btst.b		#5,24(a3)		*On the floor
	bne		done_sb
	addq.w		#1,2(a3)
	cmpi.w		#148,2(a3)		*Off bottom
	bne		done_sb
	move.l		#BLANK_SPRIT,4(a3)	*Erase slinky
	subq.w		#1,NUM_THERE		*Decrement count
	bra		no_ani16

CIRCLE_TAB
	dc.b		4,4,6,4,4,4,2,4,2,4,2,2,6,2,2
	dc.b		2,2,$a,2,2,8,2,8,2,8,8,8,$a,8,8
	dc.b		8,8,9,8,8,8,1,8,1,8,1,1,9,1,1
	dc.b		1,1,5,1,1,4,1,4,1,4,4,4,5,4,4

CIRCLE
	dc.w		0

HOME
	dc.w		0

NO_GRAV
	tst.w		SB_SPD
	bne		done_sb

DO_CIRCM
	tst.w		CIRCLE
	beq		no_circ

	cmpi.w		#7,d3
	beq		no_circ

	cmpi.w		#8,d3			*EYES?????
	beq		no_circ

	btst.b		#5,25(a3)		*Overall collision??
	bne		no_circ
	move.w		CIRCLE,d0
	lea		CIRCLE_TAB(pc,d0.w),a0
	andi.w		#$f0ff,24(a3)
	move.b		(a0),d0
	or.b		d0,24(a3)
	bra		no_circ2

NO_CIRC
	tst.w		CIRC_TIM		*Circle avbl?
	bne		no_circ2		*NO

	move.w		TIM200,d0
	andi.w		#$03,d0
	cmpi.w		#$03,d0
	bne		no_circ2

	move.w		#1,CIRCLE
	move.w		#TIM2_CIRC,CIRC_TIM	*Not avbl yet

NO_CIRC2
	
	btst.b		#0,24(a3)
	bne		sb_up

	btst.b		#1,24(a3)
	bne		sb_down

SB_HOR
	btst.b		#2,24(a3)
	bne		sb_left

	btst.b		#3,24(a3)
	bne		sb_right

	bra		done_sb

SB_UP
	btst.b		#4,24(a3)
	bne		sb_hor		*Any collision?

	cmpi.w		#16,2(a3)
	ble		eye_test2		******Right at th'top

	subq.w		#1,2(a3)
	bra		sb_hor

SB_DOWN
	btst.b		#5,24(a3)
	bne		sb_hor
	
	cmpi.w		#144,2(a3)	*Right at th'bottom
	bge		eye_test2

	addq.w		#1,2(a3)
	bra		sb_hor

EYE_TEST2
	cmpi.w		#8,d3		*Up/down beastie eye??
	bne		sb_hor
	eori.b		#$3,24(a3)	*Reverse dir
	andi.b		#$f3,24(a3)
	bra		sb_hor

SB_LEFT
	btst.b		#6,24(a3)
	bne		done_sb

	cmpi.w		#24,(a3)
	ble		eye_test1

	subq.w		#1,(a3)
	bra		done_sb


ANI_16
	dc.w		1
SB_SPD
	dc.w		0		*Movement timer
SB_RESPD
	dc.w		0		*Mov timer reset value

CIRC_TIM
	dc.w		0
* Time to next circle availability

EYE_TEST1
	cmpi.w		#7,d3		*Hor eye??
	bne		done_sb
	eori.b		#$c,24(a3)	*toggle dir
	andi.b		#$fc,24(a3)
	bra		done_sb

SB_RIGHT
	btst.b		#7,24(a3)
	bne		done_sb

	cmpi.w		#304,(a3)
	bge		eye_test1

	addq.w		#1,(a3)

DONE_SB						

*************************************************
*	Check for man hits			*
*************************************************

	move.w		SP_TABLE+26,d0			*Man Xpos
	subi.w		#10,d0

	move.w		24(a3),d1
	andi.w		#$1f,d1
	cmpi.w		#$1f,d1
	beq		no_mhit

	move.w		(a3),d1

	cmp.w		d0,d1
	blt		no_mhit

	addi.w		#32,d0
	cmp.w		d0,d1
	bgt		no_mhit

	move.w		SP_TABLE+28,d0			*Man Ypos
	subi.w		#10,d0
	move.w		2(a3),d1			*Beast Ypos

	cmp.w		d0,d1
	blt		no_mhit

	add.w		#32,d0
	cmp.w		d0,d1
	bgt		no_mhit
	
;	tst.w		SHIELD
;	beq		no_nodie

	move.w		24(a3),d0
	andi.w		#$1f,d0
	cmpi.w		#$1f,d0
	beq		nog2

	andi.w		#$ff60,24(a3)
	ori.w		#$1f,24(a3)
	move.l		#SB_XPLOS,4(a3)
	
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC
	move.w		d7,d6
	asl.w		d6
	movea.l		#TIM_TAB,a0
	lea		0(a0,d6.w),a0
	clr.w		(a0)			*Reset incarn

	bra		expd_mhit

NO_NODIE
	move.l		#BLANK_SPRIT,4(a3)	*Clear beastie
	
EXPD_MHIT
	move.w		#-1,DIE
	bne		nog2		

NO_MHIT

**************************************************

	move.w		d7,d6
	asl.w		d6			*Right place in tab
	lea		TIM_TAB+1(pc,d6.w),a0	   *Movmnt tim table
	tst.b		(a0)
	beq		newdir
	subq.b		#1,(a0)			*Dec timer
	bra		no_newdir

TIM_TAB
	dc.w		1,1,1,1,1,1,1,1,1,1,1,1

NEWDIR
	cmp.w		#$1f,d3
	beq		no_newdir

	cmpi.w		#7,d3			*Eye??
	beq		eye_newdirh

	cmpi.w		#8,d3			*Eye??
	beq		eye_newdirv

	andi.w		#$f0ff,24(a3)	*Clear old dir flags

	tst.w		HOME			*Homein??
	beq		no_home

	move.w		(a3),d0			*Beast Xpos
	move.w		2(a3),d1		*Beast Ypos

	move.w		SP_TABLE+26,d2		*Man Xpos
	move.w		SP_TABLE+28,d5		*Man Ypos

	move.w		TIM200,d4		*Random
	andi.w		#$1f,d4
	ori.w		#8,d4			*Default hom pos
	add.w		d4,d2			*Offset to random home pnt

	move.w		TIM200,d4
	asr.w		#4,d4
	andi.w		#$1f,d4
	ori.w		#8,d4			*Default hom pos
	add.w		d4,d5			*Off rand hom pos

	clr.w		d4			*d4=dir mask

	cmp.w		d0,d2			*Comp XPOS
	blt		hom_l
	bgt		hom_r

VER_HOME
	cmp.w		#4,d3			*Slinky
	beq		set_dist

	cmp.w		d1,d5			*Comp YPOS
	blt		hom_v
	bgt		hom_d

SET_DIST	
	cmp.w		d0,d1			*From home dir
	ble		used1
	bra		set_hdir
USED1
	move.b		d1,d0
SET_HDIR
	move.w		24(a3),d1
	lsr.w		#4,d1			*Match coll with mov bits
	andi.w		#$f00,d1	
	eor.w		d1,d4			*Kill mov in coll dir

	or.w		d4,24(a3)		*Set dir bits
	or.b		d0,(a0)			*Set timer
	bra		no_newdir

HOM_L
	ori.w		#$400,d4
	sub.w		d2,d0			*d0=distance apart
	bra		ver_home

HOM_R
	ori.w		#$800,d4
	sub.w		d0,d2
	move.w		d2,d0			*"   "         "
	bra		set_dist

HOM_V
	ori.w		#$100,d4
	sub.w		d5,d1
	bra		set_dist		*d1=distance apart

HOM_D
	or.w		#$200,d4
	sub.w		d1,d5
	move.w		d5,d1
	bra		set_dist
	
NO_HOME

	move.w		TIM200,d0
	move.w		d0,d2
	btst.b		#6,25(a3)
	bne		sethorm		*Gravity??

	andi.w		#$f0,d0

	cmpi.w		#$50,d0
	ble		setupm

	cmpi.w		#$a0,d0
	ble		sethorm

	bset.b		#1,24(a3)	*Set down movement
	bra		sethorm

SETUPM
	bset.b		#0,24(a3)	*Set up move
SETHORM
	andi.w		#$f,d2

	cmpi.w		#$5,d2
	ble		setlefm	

	cmpi.w		#$a,d2
	ble		settedm

	bset.b		#3,24(a3)	*Set right
	bra		settedm

EYE_NEWDIRV
	andi.b		#$f3,24(a3)	*Kill hor movement
	move.b		24(a3),d4	*Movement
	andi.b		#3,d4
	bne		no_newdir	
	ori.b		#1,24(a3)	*set mov up
	bra		no_newdir

EYE_NEWDIRH
	andi.b		#$fc,24(a3)
	move.b		24(a3),d4
	andi.b		#$c,d4		*Any movement
	bne		no_newdir
	ori.b		#$4,24(a3)	*set move down
	bra		no_newdir

SETLEFM
	bset.b		#2,24(a3)

SETTEDM	

	move.w		$4bc,d0
	and.w		#$7e,d0 	*Next dir change time
	move.b		d0,(a0)

NO_NEWDIR


*	Now do the actual beastie incarnations

	tst.w		ANI_16
	bne		no_ani16	*Animation timer

	subq.l		#1,a0		*Back 1 byte
	move.b		(a0),d0		*Get incarn number
	andi.l		#3,d0		*Isolate incarn

	btst.b		#7,25(a3)	*Incarn up or down
	beq		anib_up		*Default

ANIB_DOWN
	cmp.w		#$1f,d3		*Beast exp??
	bne		no_bexp
	move.l		#BLANK_SPRIT,4(a3)	*Kill beastie
	subq.w		#1,NUM_THERE	*Dec beast#
	clr.w		(a0)		*reset timer
	move.l		#$500,d0
	jsr		add_scor
	bra		nog2

NO_BEXP
	subq.w		#1,d0
	beq		c_ani_dir	*Change dir if =0
	bra		no_res16

ANIB_UP
	addq.w		#1,d0
	cmpi.w		#3,d0		*Last incarn??
	blt		no_res16

C_ANI_DIR
	eori.b		#$80,25(a3)	*Change dir flag

NO_RES16
	andi.b		#$f8,(a0)	*Kill curent B#
	or.b		d0,(a0)
	move.w		24(a3),d1
	andi.l		#$1f,d1		*Get beastie number

*Now process slinky

	cmpi.w		#4,d1		*Slinky
	bne		no_spec

	btst.b		#5,24(a3)	*On the floor??
	beq		k_slnk		*No,kill animation

	andi.b		#$7f,25(a3)	*Kill bi-directional animation
	
	cmpi.b		#3,d0
	bne		no_res_slnk	*Reset slinky animation??

	andi.b		#$f8,(a0)	*Do it!!

NO_RES_SLNK

	btst.b		#2,24(a3)	*Slinky left??
	bne		lef_slnk

	btst.b		#3,24(a3)	*Slinky right
	bne		rig_slnk

K_SLNK
	moveq.w		#0,d0		*Kill animation
	andi.w		#$f8ff,(a0)
	bra		no_spec

LEF_SLNK
	btst.b		#6,24(a3)	*Collision
	bne		k_slnk

	cmpi.w		#24,(a3)	*Off limits??
	ble		k_slnk
	moveq.w		#4,d1		*Set right beastie
	
	cmpi.w		#3,d0
	bne		no_spec		*Not correct incarn
	sub.w		#10,(a3)
	bra		no_spec

RIG_SLNK
	btst.b		#7,24(a3)	*Collision
	bne		k_slnk

	cmpi.w		#304,(a3)	*Off limits
	bge		k_slnk
	move.w		#18,d1		*Set right beastie
	cmpi.w		#3,d0
	bne		no_spec

	add.w		#10,(a3)

NO_SPEC

	asl.w		#7,d0		*Incarn x 128
	cmpi.l		#$1f,d1		*Explosion????
	bne		no_sexpch
	move.l		#SB_XPLOS,d1
	bra		put_sbdata

NO_SEXPCH	
	moveq		#9,d2		*Char x 128 x 4
	asl.l		d2,d1
	add.l		d0,d1
	move.l		#SB_TABLE,d0

PUT_SBDATA
	add.l		d0,d1
	move.l		d1,4(a3)

NO_ANI16
	btst.b		#6,25(a3)		*Gravity??
	beq		nog2
	bset.b		#9,24(a3)
NOG2

	lea		26(a3),a3
	dbf		d7,move_sb
	
	subq.w		#1,SB_SPD
	bpl		no_respd
	move.w		SB_RESPD,SB_SPD

NO_RESPD	
	subq.w		#1,ANI_16
	bpl		no_sbmova
	move.w		#ANI16_TIM,ANI_16

NO_SBMOVA

	tst.w		CIRCLE
	beq		no_sbmovb
	addq.w		#1,CIRCLE
	cmpi.w		#$3d,CIRCLE
	bne		no_sbmovb
	clr.w		CIRCLE
	
	movea.l		#SP_TABLE+208+25,a3	*Status byte #2
	moveq		#7,d7
	
NO_CSET
	bclr.b		#5,(a3)			*Clr overall coll
	lea		26(a3),a3
	dbf.w		d7,no_cset

NO_SBMOVB
	tst.w		CIRC_TIM
	beq		no_sbmov

	subq.w		#1,CIRC_TIM


NO_SBMOV
     
***********************************************************************************************
*******************process single doors*****************


*********************************************************
*	SINGLE door processor				*
*                                                       *
*********************************************************
DOOR_TIM	equ	$a

SDOORS

	clr.w		FIN_DOOR		*Zero no-doors
	cmp.w		#0,SINGLE_DOORS		*owt there??
	beq		done_door

	tst.w		DOOR_DELAY
	beq		do_sdoors
	subq.w		#1,DOOR_DELAY
	bra		done_door

DO_SDOORS
	move.w		#DOOR_TIM,DOOR_DELAY		*reset timer
	move.w		SINGLE_DOORS,d7		*Single door count
	subq.w		#1,d7	
	move.w		SBEA_MASK,d6		*Max # avbl
	sub.w		NUM_THERE,d6		*Current onscreen
	bgt		NO_NEWD
	move.w		#$ffff,FIN_DOOR
NO_NEWD
	
	clr.w		DO_DSET			*Clear new door flg

*	d6=number of doors available
	move.l		#SDOOR_TAB,a6

ACT_DOOR
	cmp.w		#0,2(a6)
	ble		next_door

	btst.b		#4,(a6)			*Door active?
	bne		proc_sdoor

	tst.w		DO_DSET
	bne		next_door		*new door this time

	tst.w		d6			*owt to put
	beq		next_door

	tst.w		FIN_DOOR
	bne		next_door

	subq.w		#1,d6
	bne		mor_dor
	move.w		#$ffff,FIN_DOOR
MOR_DOR
*	NEW DOOR
	and.w		#$1ff,(a6)		*kill flags
	or.w		#$7000,(a6)		*set flags

	move.w		#-1,DO_DSET
	tst.w		LEVD_STAT		*Not if level door
	bne		no_onemore		*Lev door activ
	addq.w		#1,NUM_THERE
NO_ONEMORE	
*	Set coords of single beastie here****************
*********************************************************

	bra		next_door

PROC_SDOOR
	move.w		(a6),d5
	and.w		#$6000,d5		*fully drawn??
	bne		next_door

	move.b		(a6),d5
	and.b		#$6,d5			*get char#
	asr.b		#1,d5
	btst.b		#7,(a6)			*<>0=closing
	bne		clos_door

	addq.b		#1,d5
	cmpi.b		#4,d5
	bne		no_ddir

	and.b		#1,(a6)			*kill flags
	or.b		#$f6,(a6)		*active/clos/sca,b&ch3

* Now place single beastie

	move.l		#SP_TABLE+208,a3
	move.w		SBEA_MASK,d0		*Max number beasties

P_BLOOP
*	tst.l		4(a3)			*Sprite there??
	move.l		4(a3),d1		*****
	cmpi.l		#BLANK_SPRIT,d1		*****
	beq		found_sbp

	lea		26(a3),a3
	dbf.w		d0,p_bloop
	bra		next_door

FOUND_SBP
	tst.w		EYE_THERE		*Any eyes
	bne		no_puteye

	move.w		TIM200,d0
	cmpi.w		#$200,d0
	bgt		no_puteye
	andi.w		#1,d0
	beq		i1
	moveq		#7,d0
	move.w		d0,EYE_THERE
	bra		goteye
I1
	moveq		#8,d0
	move.w		d0,EYE_THERE
	bra		goteye

NO_PUTEYE
	move.l		ROOMB,d0

GOTEYE
	move.w		d0,d1			*Save b#
	moveq		#9,d6
	asl.l		d6,d0			*x128x4
	add.l		#SB_TABLE,d0
	move.l		d0,4(a3)		*Set address
	move.w		TIM200,d0
	and.w		#$0f00,d0
	move.w		d0,24(a3)		*Set mov flags
	or.w		d1,24(a3)		*Set beast number
	
	cmpi.w		#4,d1			*Slinky??
	bne		no_slink
	bset.b		#6,25(a3)		*Set gravity
	andi.w		#$f0ff,24(a3)		*Kill movement
NO_SLINK
**Now do coords
	move.w		(a6),d0
	andi.w		#$1ff,d0
	move.w		d0,(a3)			*Set Xpos

	move.w		2(a6),2(a3)		*set Ypos

	bra		next_door

CLOS_DOOR
	subq.b		#1,d5
	bpl		no_cddir
	and.b		#1,(a6)
	bra		next_door
NO_CDDIR
	or.b		#$70,d5			*keep close flag

NO_DDIR
	and.b		#1,(a6)
	asl.b		#1,d5
	or.b		d5,(a6)
	or.b		#$70,(a6)		*set flags

NEXT_DOOR
	lea		8(a6),a6
	dbf.w		d7,ACT_DOOR
	bra		done_door


SINGLE_DOORS
	dc.w		0			*# single doors
	
SBEA_MASK
	dc.w		4			*# beasts avbl

BTYPE
	dc.l		15			*Beasties available



DOOR_DELAY
	dc.w		0			*door counter

DO_DSET
	dc.w		0		*one door only/cycle

FIN_DOOR
	dc.w		0		*0=Need more openeings

NUM_THERE
	dc.w		0		*Number 16x16s 

EYE_THERE
	dc.w		0		*<>0 if eye in room

SDOOR_TAB
	ds.b		240

ROOMB
	dc.l		0		*Beast type this room


DONE_DOOR

*********************************************************************************************	
		
*********************************************************
*	Smart Bomb bits					*
*	By GAH on 21/9/88				*
*********************************************************

SMRT_PWR		equ	13

SMART
	movea.l		#SP_TABLE+130,a3

	tst.w		SMART_STAT
	bne		go_smart

	btst.b		#4,WEAPONS+3
	beq		done_smart

	btst.b		#7,JOYSTICK+1
	beq		done_smart
	
	tst.w		DIE			* alive?
	bne		done_smart		* nope

	move.w		MAN_STAT,d2
	andi.w		#$210,d2			*Facing??
	bne		done_smart

	clr.w		SMART_INC			*Countdown incarn
	clr.w		SEXP_INC			*EXp incarn
	clr.w		SMART_TIM			*Timer

	move.l		SP_TABLE+26,(a3)		*Set xpos/ypos
	addi.l		#$00100010,(a3)			*Mid of man
	move.w		#16,SMART_RES			*Timer speed
	move.b		#1,SMART_STAT			*Say doin'

	bset.b		#0,DOSH+1			*Icons
	bset.b		#0,FIRING+1


GO_SMART
	tst.w		SMART_TIM
	beq		do_smart
	subq.w		#1,SMART_TIM
	bra		done_smart

DO_SMART
	move.w		SMART_RES,SMART_TIM		*Reset timer
	btst.b		#1,SMART_STAT			*Explodin'
	bne		smrt_xpld

	lea		SMAR_NOZ(pc),a0
	bsr		noize_init
	move.l		a0,SON_TABA
	

	moveq		#0,d0
	move.w		SMART_INC,d0
	move.w		d0,d1
	add.l		#SMART_CHAR,d0
	move.l		d0,4(a3)			*Set char

	addi.w		#128,d1
	move.w		d1,SMART_INC
	cmp.w		#640,d1
	bne		done_smart

	movea.l		#SB_EXPNOZ,a0
	bsr		noize_init
	move.l		a0,SON_TABC

	bset.b		#1,SMART_STAT			*Say explodin'
	move.w		#2,SMART_RES
	move.w		#0,SMART_TIM

	btst.b		#0,FBB_STAT+1
	bne		smrt_fbb

	tst.w		VBB
	bne		smrt_vbb

	tst.w		BBRUN				*Big b
	bne		smt_bb

	move.w		SBEA_MASK,d7
	subq.w		#1,d7
	movea.l		#SP_TABLE+208,a0

SMART_EM
	tst.w		4(a0)				*Owt there??
	beq		nxt_smt

	move.w		d7,d6
	asl.w		#1,d6
	movea.l		#TIM_TAB,a1
	lea		0(a1,d6.w),a1

	andi.w		#$f800,(a1)
	andi.w		#$ff60,24(a0)			*Kill b#
	ori.w		#$1f,24(a0)			*Set exp
	move.l		#SB_XPLOS,4(a0)

NXT_SMT
	lea		26(a0),a0
	dbf.w		d7,SMART_EM
	bra		smrt_xpld

SMRT_VBB
	subi.w		#SMRT_PWR,VBB_PWR
	bra		smrt_xpld

SMRT_FBB
	subi.w		#SMRT_PWR,FBB_PWR
	bra		smrt_xpld

SMT_BB
	subi.w		#SMRT_PWR,BB_PWR

SMRT_XPLD
	moveq		#0,d0
	move.w		SEXP_INC,d0
	move.w		d0,d1
	
	addi.l		#SB_XPLOS,d0
	move.l		d0,4(a3)

	addi.w		#128,d1
	cmp.w		#640,d1
	beq		kill_smart

	move.w		d1,SEXP_INC
	move.w		(a3),d0			*Smart xpos

	move.w		SP_TABLE+26,d2		*Man xpos

	subi.w		#10,d2

	cmp.w		d2,d0
	ble		done_smart
	addi.w		#42,d2
	cmp.w		d2,d0
	bge		done_smart

	move.w		SP_TABLE+28,d2
	move.w		2(a3),d0

	addi.w		#10,d2

	cmp.w		d2,d0
	ble		done_smart
	addi.w		#42,d2
	cmp.w		d2,d0
	bge		done_smart

	move.w		#1,DIE
	bra		done_smart

SMAR_NOZ
	dc.w		$0,$40a,0,1,$f
	dc.w		3,$10,0,1,$f
	dc.w		6,1
	dc.w		7,$a,-2,1,$10,$30
	dc.w		9
	dc.w		3,5,-1,1,5
	dc.w		9
	dc.w		6,$100
	dc.w		9,9

SMART_STAT
	dc.w		0			*Smart bomb status
SMART_TIM
	dc.w		0			*Timer
SMART_RES
	dc.w		0			*Reset value
SEXP_INC
	dc.w		0			*Exp incarn
SMART_INC
	dc.w		0			*Cntdwn satge incarn

KILL_SMART
	move.l		#BLANK_SPRIT,4(a3)
	clr.w		SMART_STAT
	clr.w		FIRING

DONE_SMART
	
**********************************************************************************************


*********************************************************
*	Grenade launcher code 				*
*	By GAH on 23/9/88				*
*********************************************************

	
GREN_PWR		equ	3

GRENADE
	movea.l		#SP_TABLE+130,a3

	tst.w		LEVD_STAT
	beq		go4_gren	*Levdoor in progress
	move.l		#BLANK_SPRIT,SP_TABLE+134
	bra		done_gren
GO4_GREN
	tst.w		GREN_STAT
	bne		do_gren

	btst.b		#5,WEAPONS+3
	beq		done_gren

	btst.b		#7,JOYSTICK+1
	beq		show_gren		*Put on end
	
	tst.w		DIE
	bne		done_gren

	move.w		MAN_STAT,d2
	andi.w		#$210,d2		*Facing??
	bne		show_gren

	move.w		#0,GREN_DIST		*Distance limiter
	move.w		#0,GREN_XP		*Explos char
	move.w		#0,GREN_EXP		*Explos stage
	move.w		#1,GREN_STAT		*Gren active
	move.w		#1,SHOOTIN
	move.w		#0,GRN_BBH
	move.w		#1,FIRING
	bset.b		#0,DOSH+1

	lea		GREN_NOZ(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA

	btst.b		#2,MAN_STAT+1
	bne		gren_l

	move.w		SP_TABLE+26,d0
	addi.w		#32,d0
	bra		cont_gi

GREN_L
	move.w		SP_TABLE+26,d0
	subi.w		#16,d0
	ori.w		#2,GREN_STAT		*Say left

CONT_GI

	move.w		d0,(a3)
	move.w		SP_TABLE+28,d0		*Ypos
	sub.w		G_OFF,d0		*Gun offset
	addq.w		#2,d0
	move.w		d0,2(a3)

DO_GREN
	btst.b		#2,GREN_STAT+1		*Explodin'
	bne		do_gexp

	btst.b		#1,GREN_STAT+1		*Left
	bne		gren_lft

	move.w		(a3),d0
	addq.w		#2,d0
	cmp.w		#304,d0
	bge		exp_gren

	move.w		d0,(a3)
	move.l		#GREN_CHAR+128,4(a3)
	bra		chk_gren

GREN_LFT
	move.w		(a3),d0
	subq.w		#2,d0
	cmp.w		#15,d0
	ble		exp_gren
	move.w		d0,(A3)
	move.l		#GREN_CHAR,4(a3)

CHK_GREN

	tst.w		VBB_DIE
	bne		not_3

	tst.w		VBB
	bne		no_gsb

NOT_3
	tst.l		16(a3)
	beq		do_gsb

	movea.l		16(a3),a1
	lea		1280(a1),a1

	movem.w		(a1)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		exp_gren

	movem.w		(a1),d2-d5


	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		exp_gren

DO_GSB
	
	tst.w		20(a3)
	beq		no_gsb

	movea.l		20(a3),a1
	lea		1280(a1),a1

	movem.w		(a1)+,d2-d5

	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		exp_gren

	movem.w		(a1),d2-d5


	or.w		d2,d3
	not.w		d3
	and.w		d4,d5
	and.w		d3,d5
	bne		exp_gren

NO_GSB
	btst.b		#7,JOYSTICK+1
	bne		done_gren
	
	
	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC


	lea		KILL_NOZA(pc),a0
	jsr		noize_init
	move.l		a0,SON_TABA


EXP_GREN
	ori.w		#4,GREN_STAT
	subi.w		#10,(a3)
	subi.w		#10,2(a3)

	cmp.w		#0,(a3)
	bge		no_goverx			*Out of range
	clr.w		(a3)
NO_GOVERX
	cmp.w		#0,2(a3)
	bge		no_govery
	clr.w		2(a3)
NO_GOVERY

	move.w		(a3),G_LSX
	move.w		2(a3),G_LSY		*Save gren coords


DO_GEXP
	btst.b		#0,FBB_STAT+1
	bne		chk_gfbb

	tst.w		VBB
	bne		vbb_gchk

	tst.w		BBRUN			*Big b
	bne		grn_bb

	move.w		SBEA_MASK,d7
	subq.w		#1,d7
	movea.l		#SP_TABLE+208,a0
GREN_SB
	tst.w		4(a0)
	beq		no_gsbh

	move.w		G_LSX,d0
	move.w		G_LSY,d1

	move.w		24(a0),d2
	andi.w		#$1f,d2
	cmpi.w		#$1f,d2
	beq		no_gsbh

	move.w		(a0),d2			*B xpos
	addi.w		#8,d2			*Make coord. SB central

	cmp.w		d0,d2
	ble		no_gsbh

	addi.w		#32,d0
	cmp.w		d0,d2
	bge		no_gsbh

	move.w		2(a0),d2		*B ypos
	addi.w		#8,d2			*Make coord SB central

	cmp.w		d1,d2
	ble		no_gsbh
	addi.w		#32,d1
	cmp.w		d1,d2
	bge		no_gsbh

	move.w		d7,d6
	asl.w		#1,d6
	movea.l		#TIM_TAB,a1
	lea		0(a1,d6.w),a1
	andi.w		#$f800,(a1)
	andi.w		#$ff60,24(a0)
	ori.w		#$1f,24(a0)

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

NO_GSBH
	lea		26(a0),a0
	dbf.w		d7,GREN_SB
	bra		don_gchk

VBB_GCHK
	tst.w		VBB_DIE
	bne		don_gchk

	tst.w		GRN_BBH
	bne		don_gchk

	move.w		LEVEL_NUM,d0
	asl.w		#5,d0
	move.w		VBB_INC,d1
	asl.w		#3,d1
	add.w		d1,d0
	movea.l		#VBB_CCOORDS,a0
	lea		0(a0,d0.w),a0

	move.w		(a0),d0
	move.w		2(a0),d1
	
	move.w		G_LSX,d2
	move.w		G_LSY,d3
	

	cmp.w		d0,d2
	blt		not_tlh
	cmp.w		d1,d3
	blt		not_tlh

	move.w		4(a0),d0
	move.w		6(a0),d1

	cmp.w		d0,d2
	bgt		not_tlh
	cmp.w		d1,d3
	bgt		not_tlh
	bra		g_vbbhit

NOT_TLH
	addi.w		#32,d2
	addi.w		#32,d3
	
	move.w		(a0),d0
	move.w		2(a0),d1

	cmp.w		d0,d2
	blt		don_gchk

	cmp.w		d1,d3
	blt		don_gchk

	move.w		4(a0),d0
	move.w		6(a0),d1

	cmp.w		d0,d2
	bgt		don_gchk
	cmp.w		d1,d3
	bgt		don_gchk

G_VBBHIT

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	subi.w		#GREN_PWR,VBB_PWR
	move.w		#1,GRN_BBH	
	bra		don_gchk

CHK_GFBB
	tst.w		GRN_BBH
	bne		don_gchk

	move.w		G_LSX,d0
	move.w		G_LSY,d1
	bsr		fbb_hit
	tst.w		d0
	beq		don_gchk 

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

	subi.w		#GREN_PWR,FBB_PWR
	move.w		#1,GRN_BBH		*Once per grenade	
	bra		don_gchk


GRN_BB
	tst.w		BBMOV
	beq		don_gchk		*Already dead
	tst.w		DIE_BB
	bne		don_gchk

	tst.w		GRN_BBH			*Hit once?
	bne		don_gchk

	move.w		SP_TABLE+208,d2
	move.w		SP_TABLE+210,d3

	move.w		G_LSX,d0
	move.w		G_LSY,d1
	addi.w		#32,d0
	addi.w		#32,d1

	cmp.w		d0,d2
	bge		don_gchk
	addi.w		#32,d2
	cmp.w		d0,d2
	ble		don_gchk

	cmp.w		d1,d3
	bge		don_gchk
	addi.w		#32,d3
	cmp.w		d1,d3
	ble		don_gchk

	subi.w		#GREN_PWR,BB_PWR
	
	move.w		#1,GRN_BBH

	movea.l		#SB_EXPNOZ,a0
	jsr		noize_init
	move.l		a0,SON_TABC

DON_GCHK
	clr.l		d0
	move.w		GREN_XP,d0
	move.w		d0,d1
	addi.l		#SB_XPLOS,d0
	move.l		d0,4(a3)

	addi.w		#128,d1
	cmp.w		#512,d1
	beq		next_gexp
	move.w		d1,GREN_XP
	bra		done_gren

NEXT_GEXP
	move.w		#0,GREN_XP
	addq.w		#4,GREN_EXP
	move.w		GREN_EXP,d0
	movea.l		#EXPOS,a0
	lea		0(a0,d0.w),a0
	move.w		(a0),d1
	add.w		d1,(a3)
	cmpi.w		#304,(a3)
	ble		no_ov2			*No exp at far RHS
	move.w		#304,(a3)
NO_OV2
	move.w		2(a0),d1
	add.w		d1,2(a3)
	cmp.w		#16,d0
	bne		done_gren

END_GREN
	move.w		#0,GREN_STAT
	move.l		#BLANK_SPRIT,4(a3)
	clr.w		FIRING

	bra		done_gren

SHOW_GREN
	move.w		MAN_STAT,d2
	andi.w		#$210,d2
	bne		no_showg

	move.w		SP_TABLE+26,d0
	move.w		SP_TABLE+28,d1
	add.l		G_OFF,d1
	addq.w		#2,d1

	btst.b		#2,MAN_STAT+1
	bne		shw_gl

	add.w		#25,d0
	cmpi.w		#304,d0
	bgt		no_showg
	move.l		#GREN_CHAR+128,d2
	bra		putsg

SHW_GL
	sub.w		#9,d0
	cmpi.w		#0,d0
	blt		no_showg
	move.l		#GREN_CHAR,d2
PUTSG
	move.w		d0,(a3)
	move.w		d1,2(a3)
  	move.l		d2,4(a3)
	bra		done_gren


GRN_BBH
	dc.w		0
GREN_STAT
	dc.w		0
GREN_XP
	dc.w		0
GREN_EXP
	dc.w		0
GREN_DIST
	dc.w		0
EXPOS
	dc.w		0,0,14,0,-14,14,14,0
GREN_DLIM
	dc.w		100
G_LSX	
	dc.w		0
G_LSY
	dc.w		0

GREN_NOZ
	dc.w		0,$70,3,2,$50
	dc.w		3,10,0,2,$50
	dc.w		6,$0801			*was 0001
	dc.w		9
	dc.w		6,$0900			*Was 0100
	dc.w		9,9
NO_SHOWG
	move.l		#BLANK_SPRIT,4(a3)
DONE_GREN

********************************************************************************************	

*****************************************************************
*	Score routines						*
*	By GAH on 5/10/88					*
*****************************************************************

**********  Mainline score routine  *****************
SCORE
	move.l		SCOR_CMP,d0
	cmp.l		SCOR_DIS,d0
	beq		no_score

	movea.l		#SCREENA+28800,a1		*Root addr

	move.b		SCOR_CMP,d0
	move.b		SCOR_DIS,d1
	andi.w		#$f,d0
	andi.b		#$f,d1
	cmp.b		d0,d1
	beq		no_mill

	bsr		put_sr

NO_MILL
	lea		8(a1),a1

	move.b		SCOR_CMP+1,d0
	move.b		SCOR_DIS+1,d1

	andi.w		#$f0,d0
	andi.w		#$f0,d1

	cmp.b		d0,d1
	beq		no_hth
	bsr		put_sl

NO_HTH
	move.b		SCOR_CMP+1,d0
	move.b		SCOR_DIS+1,d1
	andi.w		#$f,d0
	andi.w		#$f,d1
	cmp.b		d0,d1

	beq		no_tth
	bsr		put_sr

NO_TTH
	lea		8(a1),a1

	move.b		SCOR_CMP+2,d0
	move.b		SCOR_DIS+2,d1

	andi.w		#$f0,d0
	andi.w		#$f0,d1
	cmp.w		d0,d1
	beq		no_th

	bsr		put_sl

NO_TH
	move.b		SCOR_CMP+2,d0
	move.b		SCOR_DIS+2,d1

	andi.w		#$f,d0
	andi.w		#$f,d1

	cmp.b		d0,d1
	beq		no_h

	bsr		put_sr

NO_H
	lea		8(a1),a1

	move.b		SCOR_CMP+3,d0
	move.b		SCOR_DIS+3,d1

	andi.w		#$f0,d0
	andi.w		#$f0,d1

	cmp.b		d0,d1
	beq		done_score

	bsr		put_sl
	bra		done_score

PUT_SL
	
*	Assumes d0=number to be put
*	A1=Starting addr
	move.w		d2,-(sp)
	lea		-160(a1),a0
	asl.w		#3,d0		*Effectively x 128

	movea.l		#NUMBERS,a2
	lea		24(a2,d0.w),a2	* + 3 lines down
	moveq		#8,d7		*Line count

PUT_SLOOP
	move.w		d7,-(sp)		*Save line cnt
	
	movem.w		(a0),d0-d3
	move.w		#$ff,d4			*Clear LHS mask

	and.w		d4,d0
	and.w		d4,d1
	and.w		d4,d2
	and.w		d4,d3

	movem.w		(a2)+,d4-d7		*Get data
	andi.w		#$ff00,d4		*Mask out RHS
	andi.w		#$ff00,d5
	andi.w		#$ff00,d6
	andi.w		#$ff00,d7

	or.w		d4,d0
	or.w		d5,d1
	or.w		d6,d2
	or.w		d7,d3

	move.w		d0,(a0)+
	move.w		d1,(a0)+
	move.w		d2,(a0)+
	move.w		d3,(a0)+

	lea		152(a0),a0		*Next down
	
	move.w		(sp)+,d7		*Restore line cnt
	dbf.w		d7,put_sloop
	move.w		(sp)+,d2
	rts


PUT_SR
	
*	Assumes d0=number to be put
*	A1=Starting addr
	move.w		d2,-(sp)
	lea		-160(a1),a0
	asl.w		#7,d0		*Effectively x 128

	movea.l		#NUMBERS,a2
	lea		24(a2,d0.w),a2	*+ 4 lines down
	moveq		#8,d7		*Line count

PUT_SROOP
	move.w		d7,-(sp)		*Save line cnt
	
	movem.w		(a0),d0-d3
	move.w		#$ff00,d4			*Clear RHS mask

	and.w		d4,d0
	and.w		d4,d1
	and.w		d4,d2
	and.w		d4,d3

	movem.w		(a2)+,d4-d7		*Get data
	andi.w		#$ff,d4		*Mask out LHS
	andi.w		#$ff,d5
	andi.w		#$ff,d6
	andi.w		#$ff,d7

	or.w		d4,d0
	or.w		d5,d1
	or.w		d6,d2
	or.w		d7,d3

	move.w		d0,(a0)+
	move.w		d1,(a0)+
	move.w		d2,(a0)+
	move.w		d3,(a0)+

	lea		152(a0),a0		*Next down
	
	move.w		(sp)+,d7		*Restore line cnt
	dbf.w		d7,put_sroop
	move.w		(sp)+,d2
	rts

	

ADD_SCOR

*	d0=BCD of score increment

	movem.l		a0/a1,-(sp)
	move.l		d0,SCOR_ADD		*Predecrement only
						*so use mem addr

	movea.l		#SCOR_ADD+4,a0
	movea.l		#SCOR_CMP+4,a1

	abcd.b		-(a0),-(a1)
	abcd.b		-(a0),-(a1)
	abcd.b		-(a0),-(a1)
	abcd.b		-(a0),-(a1)

	movem.l		(sp)+,a0/a1

	rts

NUMBERS
	include		num_char.s	* dc.b data only

SCOR_ADD
	dc.l		0		*Temp store for score increment

SCOR_CMP
	dc.l		0		*New score held here

SCOR_DIS
	dc.l		0		*Value of currently displayed
					*score  ( BCD)

DONE_SCORE
	move.l		SCOR_CMP,SCOR_DIS

	movea.l		#SCREENB+28640,a2
	movea.l		#SCREENA+28640,a1
	moveq		#8,d7

SCO_COPY

	move.l		(a1)+,(a2)+
	move.l		(a1)+,(a2)+	
	move.l		(a1)+,(a2)+
	move.l		(a1)+,(a2)+	
	move.l		(a1)+,(a2)+
	move.l		(a1)+,(a2)+	
	move.l		(a1)+,(a2)+
	move.l		(a1)+,(a2)+	
	lea		128(a1),a1
	lea		128(a2),a2
	dbf.w		d7,sco_copy

NO_SCORE

*****************************************************************************************
*****************************************************************
*	Jet pack icon control					*
*	By GAH on 6/10/88					*
*****************************************************************

JP_FINT			equ	10000

FUEL_CONS
	tst.w		ADD_FUEL		*<>0=re-fuel
	bne		pick_fuel

	tst.w		JP_USE			*JP in use??
	beq		no_jpcons

	tst.w		JP_FLEV			*Any fuel
	beq		no_jpcons

	tst.w		cheat			* cheating?
	bne.s		jp_nofuelsub		* yes, infinite fuel
	subq.w		#1,JP_FLEV		* no

jp_nofuelsub
	move.w		JP_FLEV,d0

	tst.w		d0
	beq		jp_empty

	cmpi.w		#JP_FINT,d0
	ble		jp_thrd			*1 third

	cmpi.w		#JP_FINT*2,d0
	ble		jp_2thrd		*2 thirds

JP_FULL
	btst.b		#3,JP_FSTAT+1		*Already drawn
	bne		no_jpcons

FILL_ER
	move.w		#8,JP_FSTAT		*Say drawn

	movea.l		#STAT_CHR+1152,a0	*Icon data addr
	bra		put_jpf

JP_2THRD
	btst.b		#2,JP_FSTAT+1
	bne		no_jpcons

	move.w		#4,JP_FSTAT
	movea.l		#STAT_CHR+1280,a0
	bra		put_jpf

JP_THRD
	btst.b		#1,JP_FSTAT+1
	bne		no_jpcons

	move.w		#2,JP_FSTAT
	movea.l		#STAT_CHR+1408,a0
	bra		put_jpf

JP_EMPTY
	btst.b		#0,JP_FSTAT+1
	bne		no_jpcons

	move.w		#1,JP_FSTAT
	movea.l		#STAT_CHR+1536,a0

PUT_JPF
	movea.l		#SCREENA+28208,a1
	movea.l		#SCREENB+28208,a2
	moveq		#15,d7

JP_FPLOOP
	movem.l		(a0)+,d0-d1
	move.l		d0,(a1)+
	move.l		d1,(a1)
	move.l		d0,(a2)+
	move.l		d1,(a2)
	lea		156(a1),a1
	lea		156(a2),a2
	dbf.w		d7,jp_fploop
	bra		no_jpcons

PICK_FUEL
	move.w		#JP_FINT*3,JP_FLEV
	clr.w		ADD_FUEL

*****	Set jet pack active here

	bra		fill_er

JP_FLEV
	dc.w		JP_FINT*3	*JP_FINT*3
JP_FSTAT
	dc.w		8		*Full up

ADD_FUEL
	dc.w		0		*<>0 = fill her up

JP_USE
	dc.w		0		*<>0 = using JP

NO_JPCONS

**********************************************************************************************

*********************************************************
*	Shield code					*
*	By GAH on 20/10/88				*
*********************************************************

SHLD
	tst.w		SHIELD
	beq		no_shield

	tst.w		DIE
	beq		no_shield

	clr.w		DIE
	move.w		#1,TEMP_DIE
	
	subq.w		#1,SHIELD

	beq		end_shield

	move.w		SHIELD,d0

	not.w		d0
	andi.w		#$3,d0
	asl.w		#7,d0
	movea.l		#STAT_CHR,a0		*Strongest shield
	lea		0(a0,d0.w),a0

GOT_SHINC
	movea.l		#SCREENA,a1
	movea.l		#SCREENB,a2
	moveq		#15,d7

	move.w		SHLD_SC,d0
	lea		0(a1,d0.w),a1
	lea		0(a2,d0.w),a2

SH_LOOP
	move.l		(a0),(a1)+
	move.l		4(a0),(a1)

	move.l		(a0)+,(a2)+
	move.l		(a0)+,(a2)

	lea		156(a1),a1
	lea		156(a2),a2

	dbf.w		d7,sh_loop
	bra		no_shield

SHLD_SC
	dc.w		0			*Offs into screen
SHLD_WADR
	dc.l		0			*Addr of shield
						*in table
SHIELD
	dc.w		0

END_SHIELD
	
	move.l		SHLD_WADR,a0		*Wep tab posn shield
	clr.l		(a0)

	move.l		#STAT_CHR+1664,a0	*Blank icon
	bra		got_shinc

NO_SHIELD

*********************************************************************************************

	
*********************************************************
*	Man dying routines				*
*	By GAH on 11/9/88  ( Happy Birthday etc.....)	*
*********************************************************

DIE_LEN			equ	3
IM_LEN			equ	200
MAX_RAPWR		equ	48		* RA power level


DYING
	tst.w		CHEAT
	beq		no_cheat
	tst.w		DIE
	beq		done_die
	clr.w		DIE
	move.w		#1,TEMP_DIE
	bra		done_die

NO_CHEAT

	tst.w		IMMUNE			*Immune??
	beq		no_im
	tst.w		DIE
	beq		no_hitim
	move.w		#1,TEMP_DIE
	clr.w		DIE
NO_HITIM
	subq.w		#1,IMMUNE
	btst.b		#0,IMMUNE+1		*Flash state??
	beq		no_im


	cmpi.w		#IM_LEN-10,IMMUNE
	bge		no_im

	movea.l		#SP_TABLE,a3
	clr.l		4(a3)
	clr.l		30(a3)
	clr.l		56(a3)
	clr.l		82(a3)
	clr.l		108(a3)
NO_IM
	
	tst.w		DIE			*Anything
	beq		done_die

	subq.w		#2,LIFE_LEV
	move.w		LIFE_LEV,d2		*Current life level
	cmp.w		#0,d2			*Totally dead
	blt		go_for_dead		*Dead now

	clr.w		DIE

	cmp.w		#16,d2			*In final sector??
	bge		full_lo			*Low is full up
	move.w		d2,d1			*Set power for plot

	moveq		#8,d0			*Offset from far LHS
	bsr		put_pwr			*Plot low sector
	
	moveq		#0,d1			*Middle power=0
	moveq		#16,d0			*Middle offset
	bsr		put_pwr

	moveq		#0,d1			*Middle power=0
	moveq		#24,d0			*Middle offset
	bsr		put_pwr
	bra		done_die		*Finished

FULL_LO
	moveq		#16,d1			*Set full low
	moveq		#8,d0			*Offset
	bsr		put_pwr

	cmp.w		#32,d2			*See if middle rabge
	bge		full_mid		*Middle is at full power

	move.w		d2,d1			*To power index
	subi.w		#16,d1			*Get to correct range
	moveq		#16,d0			*Correct offset
	bsr		put_pwr

	clr.w		d1			*Clear third sector
	moveq		#24,d0			*3rd offset
	bsr		put_pwr
	bra		done_die		*Finished

FULL_MID
	moveq		#16,d1
	moveq		#16,d0			*Full power,2nd offset
	bsr		put_pwr

	move.w		d2,d1
	subi.w		#32,d1			*Into correct range
	moveq		#24,d0
	bsr		put_pwr
	bra		done_die

LIFE_LEV
	dc.w		MAX_RAPWR		*Initial power


PUT_PWR
* INPUTS	d1=power level 0--15
*		d0=offset 4/8/12
	movea.l		#SCREENA+$7940,a0
	movea.l		#SCREENB+$7940,a1
	lea		0(a0,d0.w),a0
	lea		0(a1,d0.w),a1		*Add in offsets
	asl.w		#2,d1			*x4 for table
	
	lea		MASK_TAB(pc,d1.w),a2	*Get table addr
	move.l		(a2),d7			*Get mask
	moveq		#3,d3			*Number of lines
PWR_PUTLOOP
	moveq		#-1,d0
	move.l		d0,d1
	and.l		d7,d0
	and.l		d7,d1
	movem.l		d0-d1,(a0)
	movem.l		d0-d1,(a1)
	lea		160(a0),a0
	lea		160(a1),a1
	dbf.w		d3,pwr_putloop
	rts


MASK_TAB
** Mask table for power putting
	dc.l		%00000000000000000000000000000000
	dc.l		%10000000000000001000000000000000
	dc.l		%11000000000000001100000000000000
	dc.l		%11100000000000001110000000000000
	dc.l		%11110000000000001111000000000000
	dc.l		%11111000000000001111100000000000
	dc.l		%11111100000000001111110000000000
	dc.l		%11111110000000001111111000000000
	dc.l		%11111111000000001111111100000000
	dc.l		%11111111100000001111111110000000
	dc.l		%11111111110000001111111111000000
	dc.l		%11111111111000001111111111100000
	dc.l		%11111111111100001111111111110000
	dc.l		%11111111111110001111111111111000
	dc.l		%11111111111111001111111111111100
	dc.l		%11111111111111101111111111111110
	dc.l		%11111111111111111111111111111111
	dc.l		%11111111111111111111111111111111

PWR_CHAR


	DC.W $FFFF,$FFFF,$0000,$FFFF,$FFFF,$8000,$7FFF,$FFFF

	DC.W $CD53,$8D53,$4000,$FFFF,$D555,$9555,$4000,$FFFF

	DC.W $CD53,$8D53,$4000,$FFFF,$DEB5,$9EB5,$4000,$FFFF

	DC.W $C000,$BFFF,$7FFF,$FFFF,$FFFF,$FFFF,$0000,$FFFF

FULLP_CHAR

	DC.W $FFFF,$FFFF,$0000,$FFFF,$FFFF,$0000,$FFFF,$FFFF

	DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

	DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

	DC.W $0000,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0000,$FFFF

ENDP_CHAR


	DC.W $F000,$F000,$0000,$F000,$F000,$1000,$E000,$F000

	DC.W $F000,$F000,$2000,$F000,$F000,$F000,$2000,$F000

	DC.W $F000,$F000,$2000,$F000,$F000,$F000,$2000,$F000

	DC.W $1000,$F000,$E000,$F000,$F000,$F000,$0000,$F000



; *******************************************************
; * Plot part of power meter				*
; * A0=addr of data					*
; * d0=screen offset					*
; *******************************************************

PLOT_POWERLIN
	movea.l		#SCREENA+$7800,a1		; Dest 1
	movea.l		#SCREENB+$7800,a2		; dest 2
	lea.l		0(a1,d0.w),a1
	lea.l		0(a2,d0.w),a2
	moveq		#7,d7				; Line counter
PLOT_PWR
	movem.l		(a0)+,d0-d1			; Get 16 pix
	movem.l		d0-d1,(a1)
	movem.l		d0-d1,(a2)
	lea		160(a1),a1
	lea		160(a2),a2
	dbf.w		d7,plot_pwr
	rts			

; *******************************************************
; * Plot fully charged power meter			*
; *******************************************************

FULL_POWER
	moveq		#0,d0			* Set offset to 0
	movea.l		#PWR_CHAR,a0
	bsr		plot_powerlin
	
	moveq		#8,d0
	movea.l		#FULLP_CHAR,a0
	bsr		plot_powerlin
	
	moveq		#16,d0
	movea.l		#FULLP_CHAR,a0
	bsr		plot_powerlin
	
	moveq		#24,d0
	movea.l		#FULLP_CHAR,a0
	bsr		plot_powerlin
	
	moveq		#32,d0
	movea.l		#ENDP_CHAR,a0
	bsr		plot_powerlin
	move.w		#MAX_RAPWR,LIFE_LEV
	rts
	

GO_FOR_DEAD

	tst.w		SAM_TABLE+6		*Sample playing
	bne		no_dsplay		*Yes,leave it 
	DO_SAM		DYING_SAM,DYING_LEN,1
NO_DSPLAY

	move.l		#SP_TABLE,a3

	tst.w		DIE_STAT		*=0 if to be init
	bne		do_die

*Initialise dying bits

	clr.l		4(a3)			*Kill jetpack
	clr.w		DIE_CNT			*#Times to flash
	ori.w		#1,DIE_STAT		*Display flash 1
	move.w		#DIE_LEN,DIE_TIM	*Set length

	move.w		26(a3),d0
	move.w		28(a3),d1

	move.w		d0,78(a3)
	addi.w		#16,d0
	move.w		d0,52(a3)
	move.w		d0,104(a3)

	move.w		d1,54(a3)
	addi.w		#16,d1
	move.w		d1,80(a3)
	move.w		d1,106(a3)


DO_DIE
	move.w		DIE_STAT,d0

	btst.l		#0,d0
	bne		flash_1

	btst.l		#1,d0
	bne		flash_2

	btst.l		#2,d0
	bne		flash_3

	btst.l		#3,d0
	bne		flash_3a

	btst.l		#4,d0
	bne		flash_4

	btst.l		#5,d0
	bne		flash_5

	bra		done_die

TEMP_DIE
	dc.w		0

FOOT_TAB
	dc.l		0
DIE_STAT
	dc.w		0
DIE_TIM
	dc.w		0
DIE_CNT
	dc.w		0
DIE
	dc.w		0
IMMUNE
	dc.w		0

F1
	dc.w		29,30,31,32
F2
	dc.w		33,34,35,36
F3
	dc.w		37,38,39,40
F3A
	dc.w		41,42,43,44
	

FLASH_1

	lea		f1(pc),a4			*Table1
	jsr		set_man
	
	tst.w		DIE_TIM
	bne		dec_dt
	
	move.w		#2,DIE_STAT
	move.w		#DIE_LEN,DIE_TIM
	bra		done_die

FLASH_2
	lea		f2(pc),a4
	jsr		set_man

	tst.w		DIE_TIM
	bne		dec_dt

	move.w		#1,DIE_STAT
	move.w		#DIE_LEN,DIE_TIM

	addq.w		#1,DIE_CNT
	cmp.w		#10,DIE_CNT		*# times to flash
	bne		done_die

	move.w		#4,DIE_STAT		*Next one
	move.w		#DIE_LEN,DIE_TIM
	bra		done_die

FLASH_3
	lea		F3(pc),a4
	jsr		set_man

	tst.w		DIE_TIM
	bne		dec_dt

	move.w		#DIE_LEN,DIE_TIM
	move.w		#8,DIE_STAT
	bra		done_die

FLASH_3A
	lea		F3A(pc),a4
	jsr		set_man

	tst.w		DIE_TIM
	bne		dec_dt
	
	move.w		#DIE_LEN,DIE_TIM
	move.w		#$10,DIE_STAT
	bra		done_die

FLASH_4
	cmpi.w		#DIE_LEN,DIE_TIM		*1st time round
	bne		dont_adj

	move.l		#MAN_GRPH+5760,30(a3)		
	move.l		#MAN_GRPH+5888,56(a3)
	move.l		#MAN_GRPH+6016,82(a3)
	clr.l		108(a3)				*Clear bot right
	add.w		#8,78(a3)			*Central feet

DONT_ADJ
	tst.w		DIE_TIM
	bne		dec_dt

	move.w		#DIE_LEN,DIE_TIM
	move.w		#$20,DIE_STAT
	move.l		#48,FOOT_TAB			*1st feet in line
	bra		done_die

FLASH_5
	tst.w		DIE_TIM
	bne		dec_dt

	clr.l		30(a3)
	clr.l		56(a3)				*Clr UL & UR

	
	move.l		FOOT_TAB,d0
	asl.l		#7,d0				*Char * 128
	move.l		#MAN_GRPH,d1
	add.l		d0,d1
	move.l		d1,82(a3)			*Put feet

	tst.w		LOW_HIT				*Bot coll
	bne		no_drp
	addq.w		#1,80(a3)
NO_DRP
	addq.l		#1,FOOT_TAB
	cmpi.l		#59,FOOT_TAB			*End of feet
	beq		end_die
	
	move.w		#DIE_LEN,DIE_TIM
	bra		done_die

END_DIE
	tst.w		NUM_LIVE
	beq		end_game


	moveq		#29,d7
	movea.l		#SDOOR_TAB,a0

CL_SD
	clr.l		(a0)+
	clr.l		(a0)+
	dbf.w		d7,cl_sd

	movea.l		#STAT_CHR+1664,a1
	movea.l		#SCREENA,a0
	moveq		#0,d1
	move.w		NUM_LIVE,d1
	cmpi.w		#3,d1
	bgt		too_much			*Only show 3

	asl.w		#4,d1				* x 16
	add.w		#256,d1				*Xpos
	move.l		#176,d2				*Ypos

	bsr		plot_char
	movea.l		#SCREENB,a0
	bsr		plot_char


TOO_MUCH
	subq.w		#1,NUM_LIVE
	bsr		full_power
	clr.w		NUM_THERE
	
	clr.w		RM_ITOF			* KKKK: reset room icon count, else icon count will be increased when respawning
	clr.w		DOOR_XP			* KKKK: stop SB door exp

	move.l		SP_TABLE+26,-(sp)
	bsr		set_sp
	move.l		(sp)+,SP_TABLE+26	

	move.w		ROOM_IN,d0		*Which room
	bsr		get_rmaddr
	bsr		room_draw
	
	tst.w		BB_STAT			* any BB there while dying?
	beq.s		die_nobb
	tst.w		BB_FACING		* was BB facing right
	bmi.s		die_nobb		* no, dont reflip
	movea.l		BB_FLIPSAVE,a0
	jsr		next_lin		* flip back
die_nobb
	clr.w		DIE
	clr.w		BB_STAT			* Reset BB
	clr.w		BB_YDIR			* KKKK: reset BB Y movement (else BBs may rise to the ceiling of the room and get stuck there)
	clr.w		DIE_BB
	bclr.b		#0,FBB_STAT+1		* KKKK: reset FBB init flag


	moveq		#11,d7
	movea.l		#TIM_TAB,a0

CLR_TIM
	clr.w		(a0)+
	dbf.w		d7,clr_tim


	move.w		#$100,MAN_STAT
	clr.w		LASER_STAT
	clr.w		BULLET
	clr.w		DIE_STAT

	move.w		#IM_LEN,IMMUNE
	jmp		again

NUM_LIVE
	dc.w		3

END_GAME	

	move.w		#1,STOP_VBI		* use screen A only
	clr.w		CYCLE			* stop color cycling
	
	move.w		#4,dc_waitval
	bsr		dim_colors
	
	movea.l		#SCREENA,a0
	move.w		#999,d0
clsloop
	REPT 8
	clr.l		(a0)+
	ENDR
	dbf		d0,clsloop
	
	pea		DEAD_STR(pc)
	move.w		#9,-(a7)
	trap		#1
	addq.l		#6,a7

	lea		TEXTPAL(pc),a0
	move.w		#4,dc_waitval
	bsr		blend_colors
	clr.w		JOYSTICK
waitdead
	btst.b          #7,JOYSTICK+1 
	beq.s		waitdead

	jmp		K_NEW_GAME		* 

DEAD_STR:
	dc.b    27,'Y',32+10,32,27,'b',15
	dc.b    '    You have failed in your mission',$d,$a,$d,$a
	dc.b    '       Press button to try again',0
	EVEN

TEXTPAL:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$777

dim_colors:     movem.l D0-A2,-(A7)         * dim_colors: Blendet die Farben des Bildschirms zu schwarz aus
                lea     $FFFF8240.w,A1      * UrsprÅngliche Palette sichern
                lea     dc_pal(PC),A2       *              "
                lea     dc_temppal(PC),A0   * nur indirekt mit Palette arbeiten
                moveq   #15,D0              * alte Palette sichern
dc_palcop:      move.w  (A1)+,D1            *         "
                and.w   #$0777,D1           * nicht relevante Bits ausmaskieren!
                move.w  D1,(A0)+            * sichern
                move.w  D1,(A2)+            *    "
                dbra    D0,dc_palcop        *    "
                lea     dc_pal(PC),A2       * A2 zeigt jetzt auf Beginn der alten Farben
                moveq   #6,D5               * In 7 DurchlÑufen ausblenden
dc_nextdim:     lea     dc_temppal(PC),A1   *
                moveq   #0,D4               * D4 = ZÑhler fÅr Farbnummer (0-15)
dc_nextcol:     move.w  #$0F00,D2           * D2 = Maske zum Isolieren der RGB Komponenten
                move.w  #$1000,D6           * D6 = Wert der von Farbe subtrahiert wird
                moveq   #2,D3               * 3 DurchlÑufe fÅr die 3 RGB Komponenten jeder Farbe
dc_nextrgb:     move.w  (A1),D1             * Farbe aus Register holen
                move.w  0(A2,D4.w),D0       * Enstsprechende alte Farbe zum Vergleich holen
                and.w   D2,D1               * eine RGB Komponente isolieren
                and.w   D2,D0               *              "
                lsr.w   #4,D2               * Maske schon fÅr nÑchste Farbe schieben
                lsr.w   #4,D6               * Subtraktionswert ebenso schieben
                tst.w   D1                  * RGB Komponente schon Null?
                beq.s   dc_nodim            * ja, nix machen
                move.w  D3,D7               * ursprÅnglichen RGB-Wert (0-7) ganz nach rechts..
                lsl.w   #2,D7               * .. schieben, um ihn als Index in die Blendmatrix ..
                lsr.w   D7,D0               * .. verwenden zu kînnen
                lea     blendmatrix(PC),A0  * muss der Farbwert in diesem Durchlauf vermindert ..
                btst    D5,0(A0,D0.w)       * .. werden?
                beq.s   dc_nodim            * wenn Bit auf Null, dann nicht
                sub.w   D6,(A1)             * ja, RGB Wert abschwÑchen
dc_nodim:       dbra    D3,dc_nextrgb       * nÑchsten RGB Wert betrachten
                addq.l  #2,A1               * nÑchste Farbe aus Farbpalette
                addq.w  #2,D4               *
                cmp.w   #32,D4              * Schon alle Farben durch?
                bne.s   dc_nextcol          * nein, weiter
                bsr.s   dc_waitvbl          * nach jedem Durchlauf etwas warten
                lea     dc_temppal(PC),A0   * write new colors into shifter
                bsr.s   setpalette         *             "
                dbra    D5,dc_nextdim       * nÑchster Durchlauf
                movem.l (A7)+,D0-A2         *
                rts                         *
dc_waitvbl:     move.w	dc_waitval,D3	            * wait value in D3
dcwv_0:         move.l  $0466.w,D2
dcwv_1:         cmp.l   $0466.w,D2
                beq.s   dcwv_1
                dbra    D3,dcwv_0
                rts

blendmatrix:    DC.B %0                     * Matrix, die festlegt, wann eine Farbe mit einem ..
                DC.B %1000                  * .. bestimmtem RGB-Wert (0-7) verringert wird ..
                DC.B %10010                 * .. (um gleichmÑûigeres Ausblenden zu erreichen)
                DC.B %10101                 *                     "
                DC.B %1010101               *                     "
                DC.B %1011011               *                     "
                DC.B %1110111               *                     "
                DC.B %1111111               *                     "
dc_pal:         DS.W 16                     * Platz fÅr alte Farbtabelle
dc_temppal:     DS.W 16                     * room for temporary palette
dc_waitval:	DC.W 2

setpalette:     movem.l D0/A1,-(A7)
                lea     $FFFF8240.w,A1      * sets palette pointed to by A0
                moveq   #7,D0
spal_loop:      move.l  (A0)+,(A1)+
                dbra    D0,spal_loop
                movem.l (A7)+,D0/A1
                lea     -32(A0),A0          * restore A0
                rts
                
blend_colors:   movem.l D0-A2,-(A7)         * Blendet eine Farbpalette (Adresse der Palette in A0) sanft ein
                movea.l A0,A2               * save palette address
                moveq   #15,D0              * for STE palettes clear highest ..
bc_bitclr:      andi.w  #$0777,(A0)+        * .. RGB bit in target palette first
                dbra    D0,bc_bitclr        *              "
                lea     $FFFF8240.w,A0      * copy current palette
                lea     dc_temppal(PC),A1   *          "
bc_palcop:      moveq   #15,D0              *          "
                move.w  (A0)+,D1            *          "
                and.w   #$0777,D1           * mask out invalid RGB bit 3
                move.w  D1,(A1)+            *          "
                movea.l A2,A0               * get back target palette
                moveq   #6,D5               * Einblenden in 7 DurchlÑufen
                lea     dc_temppal(PC),A1   *
bc_nextblend:   moveq   #15,D4              * 16 Farben bearbeiten
bc_nextcol:     move.w  #$0F00,D2           * Maske fÅr Isolierung der RGB Komponenten initialisieren
                move.w  #$1000,D6           * Wert zum Addieren auf die RGB Komponenten initialisieren
                moveq   #2,D3               * 3 DurchlÑufe fÅr R G und B
bc_nextrgb:     move.w  (A0),D0             * Farbe aus neuer Palette holen
                move.w  (A1),D1             * letztes Farbregister holen
                and.w   D2,D0               * nur je eine Farbkomponente betrachten
                and.w   D2,D1               *            "
                lsr.w   #4,D2               * RGB Maske auf nÑchste Komponente schieben
                lsr.w   #4,D6               * Additionswert um ein Nibble erniedrigen
                cmp.w   D0,D1               * endgÅltiger Farbwert schon erreicht?
                bge.s   bc_noplus           * ja
                add.w   D6,(A1)             * nein, Wert um 1 erhîhen
bc_noplus:      dbra    D3,bc_nextrgb       * nÑchster RGB Wert
                addq.l  #2,A1               * fÅr nÑchste Farbe erhîhen
                addq.l  #2,A0               *            "
                dbra    D4,bc_nextcol       * nÑchste Farbe bearbeiten
                lea     -32(A0),A0          * get back start of palette
                lea     -32(A1),A1          * get back start of temp palette
                exg     A0,A1               *
                bsr     setpalette         * set new colors (pointed to by A0)
                exg     A0,A1               *
                bsr     dc_waitvbl          * ein wenig verzîgern
                dbra    D5,bc_nextblend     * nÑchste Runde
                movem.l (A7)+,D0-A2
                rts


*********

DEC_DT
	subq.w		#1,DIE_TIM

DONE_DIE	
	
******************************************************************************************


GOFOR_STAT
*********************************************************
*	Status screen drawer				*
*	By GAH 25/11/88					*
*                                                       *
*********************************************************


STATUS_SDRAW

	tst.w		STAT_DIS		*Already??
	bne		wait	***************************

	move.b		KEY_CODE,d0
	cmpi.b		#$2e,d0			*C for cheat
	bne		no_cheatog
	clr.b		key_code
	eori.w		#1,CHEAT
	clr.w		IMMUNE			* KKKK: solves problems when pressing "c" while Red Ace sprite is flickering (after respawn)
NO_CHEATOG

	cmpi.b		#$1c,d0			*RETURN
	bne		no_statd

INIT_STATD
	move.w		#-1,CUR_WEAP		*Make sure it drawn

	bset.b		#0,STAT_DIS+1
	clr.b		KEY_CODE
	move.w		#1,STOP_VBI		* Display only screen A
	move.w		#1,SC_CHAN		* KKKK: force screen switch to screen A (else doesn't always show stat screen in 60Hz mode)

	movea.l		#SCREENA,a1

	movea.l		#SCR_BUFF,a0		*Buffer current screen

	move.w		#160,LIN_CNT

COPY_SC
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0

	subq.w		#1,LIN_CNT
	bne		copy_sc

	move.w		#576,LIN_CNT
	movea.l		#SCREENA,a0		*Clear screen

ERA_SCR
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	subq.w		#1,LIN_CNT
	bne		era_scr

	lea		MULT_TAB(pc),a0		*Multiple single line

MULTIPLE
	move.w		(a0)+,d0		*Xpos
	cmpi.w		#-1,d0
	beq		end_stat_plot
	move.w		(a0)+,d1		*Ypos

	move.w		d1,d2
	asl.w		#7,d1
	asl.w		#5,d2
	add.w		d1,d2

	asr.w		#1,d0
	add.w		d2,d0
	
	movea.l		#SCREENA,a2
	lea		0(a2,d0.w),a2		*Dest addr

	move.w		(a0)+,d7		*X count
	move.w		(a0)+,d6		*Y count
	move.w		(a0)+,d0		*Source offset
	move.w		(a0)+,d5		*Source addn
	movea.l		#STAT_GPHX,a1
	bsr		mult_put
	bra		multiple


MULT_PUT
*a2=dest
*d0=source offset
*d7=x count
*d6=y count N.B. Cannot have multiple count.X or Y ONLY.
*d5=source offset addition
*a1=source data root address
	movem.l		d6-d7/a1-a2,-(sp)
	lea		0(a1,d0.w),a1

	tst.w		d7
	bne		hor_mult

*	Vertical offset
	move.w		d6,d7			*Set vert count
	move.w		#2560,d6		*set offset
	bra		do_mult

HOR_MULT
	move.w		#8,d6			*Hor offset
	
DO_MULT
	bsr		stat_plot
	lea		0(a2,d6.w),a2		*dest
	lea		0(a1,d5.w),a1		*source
	subq.w		#1,d7			*count
	bne		do_mult
	movem.l		(sp)+,d6-d7/a1-a2
	rts



END_STAT_PLOT
	movea.l		#FILL_NUKE,a0		*Nuke table
*	picked up offset ( default =0,i.e not picked)
*	not got offset	 ( default IF not picked!!)
	move.w		#5,d7			* 6 of 'em!!
DRAW_NUKE
	tst.w		(a0)			*Picked up?
	bne		got

	move.w		2(a0),d0		*offset in sourc scr
	bra		put_nuke		*Not got

GOT
	move.w		(a0),d0			*got it

PUT_NUKE
	movea.l		#STAT_GPHX,a1
	lea		0(a1,d0.w),a1		*Source addr

	
	move.w		4(a0),d0			*dest offset
	movea.l		#SCREENA,a2
	lea		0(a2,d0.w),a2
	bsr		stat_plot

	lea		8(a1),a1
	lea		8(a2),a2		* 32 x 32,next char posn

	bsr		stat_plot

	lea		2552(a1),a1
	lea		2552(a2),a2
	bsr		stat_plot

	lea		8(a1),a1
	lea		8(a2),a2
	bsr		stat_plot

	lea		6(a0),a0		*next check
	dbf.w		d7,draw_nuke

WAIT
	move.w		#600,d0
WAIT_L
	movem.l		d1-d7/a0-a6,-(sp)
  	movem.l		(sp)+,d1-d7/a0-a6
	dbf.w		d0,wait_l
	
	move.l		WEAPONS,d0
	cmp.w		CUR_WEAP,d0		*Has it changed?
	beq		done_weapdis
	
	movea.l		#WEAP_STAT,a0		*Posn table
	move.w		#6,d7			*8 weapons in all

FIND_WEAP
	move.w		(a0),d1			*Weapon wask
	and.w		d0,d1
	bne		found_w			*Thats it!!
	
	lea		10(a0),a0
	dbf.w		d7,find_weap
*	a0 now points to blank weapon posn data

FOUND_W
	btst.b		#0,WEAPONS+2		*Shield?
	beq		no_shit
	lea		10(a0),a0		*Point to shield
NO_SHIT
	
	lea		2(a0),a0		*Piccy source offs

	movea.l		#SCREENA+18000,a2	*Picture upper
	move.w		(a0)+,d0		*Source offset
	moveq.w		#2,d7			*two chars
	clr.w		d6			*No vert
	moveq.w		#8,d5			*Change every char
	movea.l		#STAT_GPHX,a1
	bsr		mult_put


	lea		2560(a2),a2		*16 down dest
	add.w		#2560,d0		*16 down source
	movea.l		#STAT_GPHX,a1
	bsr		mult_put

	movea.l		#SCREENA+18016,a2	*Weapon name
	move.w		(a0)+,d0
	moveq.w		#4,d7
	movea.l		#STAT_GPHX,a1
	bsr		mult_put


	movea.l		#SCREENA+18048,a2	*Text 1
	move.w		(a0)+,d0
	moveq.w		#2,d7
	movea.l		#STAT_GPHX,a1
	bsr		mult_put

	movea.l		#SCREENA+20608,a2	*text 2
	move.w		(a0)+,d0
	movea.l		#STAT_GPHX,a1
	bsr		mult_put

	move.w		WEAPONS+2,CUR_WEAP


************SHOW WEAPON STRENGTH**********

	movea.l		#WEP_TAB,a0
	move.w		WEP_XP,d0
	asl.w		#4,d0
	lea		0(a0,d0.w),a0

	move.w		6(a0),d1	*hold
	move.w		10(a0),d2	*stren
	move.w		8(a0),d3	*reset

	mulu.w		d3,d2
	sub.w		d1,d3
	sub.w		d3,d2

	move.w		d2,d0
	tst.w		d0		******
	bpl		no_signfuk	*Is ok,can continue
	clr.l		d0
NO_SIGNFUK

	btst.b		#0,WEAPONS+2		*Display shield
	beq		nota_shi
	move.w		SHIELD,d0

NOTA_SHI

	bsr		conv_bcd

* d2 now holds BCD of weapon strength

	movea.l		#SCREENA+21240,a1

	move.w		d2,d0
	andi.w		#$f,d0
	bsr		put_sr

	move.w		d2,d0
	andi.w		#$f0,d0
	bsr		put_sl

	lea		-8(a1),a1

	move.w		d2,d0
	asr.w		#8,d0
	andi.w		#$f,d0
	bsr		put_sr

	move.w		d2,d0
	asr.w		#8,d0
	andi.w		#$f0,d0
	bsr		put_sl

****NOW DISPLAY FUEL LEVEL******

	move.w		JP_FLEV,d0
	asr.w		#1,d0			*Divide by 2
	bsr		conv_bcd

	movea.l		#SCREENA+10936,a1

	move.w		d2,d0
	andi.w		#$f,d0
	bsr		put_sr

	move.w		d2,d0
	andi.w		#$f0,d0
	bsr		put_sl

	lea		-8(a1),a1

	move.w		d2,d0
	asr.w		#8,d0
	andi.w		#$f,d0
	bsr		put_sr

	move.w		d2,d0
	asr.w		#8,d0
	andi.w		#$f0,d0
	bsr		put_sl


DONE_WEAPDIS
	bset.b		#0,DRAW+1		*No stick at AGAIN

	move.b		KEY_CODE,d0
	cmpi.b		#$1c,d0
	bne		no_statd

	movea.l		#SCREENA,a0

	movea.l		#SCR_BUFF,a1		*Buffer of last

	move.w		#160,LIN_CNT

RESTORE_SC
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0
	movem.l		(a1)+,d0-d7/a2-a3	*10 long words
	movem.l		d0-d7/a2-a3,(a0)
	lea		40(a0),a0

	subq.w		#1,LIN_CNT
	bne		restore_sc

	clr.b		KEY_CODE
	clr.w		STAT_DIS
	clr.w		STOP_VBI
	bra		no_statd
	
***************************************************************

NO_STATD
	bra		no_stat2

STAT_PLOT
	movem.l		d0-d1/d7/a1-a2,-(sp)
	move.w		#15,d7

SP_LOOP
	movem.l		(a1),d0-d1
	movem.l		d0-d1,(a2)
	lea		160(a1),a1
	lea		160(a2),a2
	dbf.w		d7,sp_loop

	movem.l		(sp)+,d0-d1/d7/a1-a2
	rts

CUR_WEAP
	dc.w		-1		*weapons we currently showin'


LIN_CNT
	dc.w		0

STAT_DIS
	dc.w		0		*'Ave we drawn it yet
	
FILL_NUKE
*	Got offset
*	Not got offset
*	Destination offset

	dc.w		0,2560,5200
	dc.w		0,2576,5216
	dc.w		0,2592,5232

	dc.w		0,7680,10320
	dc.w		0,7696,10336
	dc.w		0,7712,10352

MULT_TAB
*		Xpos
*		Ypos	LHS or TOP depending upon direction
*		X count
*		Y count
*		Source offset
*		Source increment

	dc.w	0,0,0,10,12928,0		*LHS dark blanks
	dc.w	16,0,0,10,12944,0		*LHS sprockets
	dc.w	288,0,0,10,12952,0		*RHS sprockets
	dc.w	304,0,0,10,12928,0		*RHS dark blank
	dc.w	32,0,16,0,12936,0		*Top white blank
	dc.w	32,144,16,0,12936,0		*Bottom white blank
	dc.w	128,16,2,0,12912,0		*Computofax gren blanks
	dc.w	224,128,2,0,28192,0		*Shot count bkgrnd
	dc.w	96,64,2,0,2640,0		*Fuel count bkgrnd

	

	dc.w	32,16,6,0,10352,8		*Computofax txt
	dc.w	32,32,6,0,48,8			*Acme rocket txt
	dc.w	32,48,4,0,2608,8		*JP top line
	dc.w	32,64,4,0,5168,8		*JP middle
	dc.w	32,80,6,0,7728,8		*JP bottom

	dc.w	32,96,6,0,96,8			*Acme blaster txt
	dc.w	32,112,6,0,2656,8		*Blaster gpx top line
	dc.w	32,128,6,0,5216,8		*Blaster gpx bot line

	dc.w	160,16,6,0,0,8			*Destructor pod txt
	
	dc.w	128,32,2,0,144,8		*'TECH SPEC' JP
	dc.w	128,96,2,0,144,8		*'TECH SPEC' Blaster
	dc.w	256,16,2,0,144,8		*'TECH SPEC' Pod
	dc.w	256,96,2,0,144,8		*'TECH SPEC' Module

	dc.w	160,96,6,0,23040,8		*'DEFENCE MODULE SPEC'

	dc.w	128,48,2,0,2704,8		*JP txt 1
	dc.w	128,64,2,0,5264,8		*JP txt 2
	dc.w	128,80,2,0,7776,8		*JP dark txt
	

	dc.w	128,112,2,0,7792,8		*Blaster txt1
	dc.w	128,128,2,0,7808,8		*Blaster txt2

	dc.w	256,32,2,0,7824,8		*Nuke txt1
	dc.w	256,48,2,0,7792,8		*Nuke txt2
	dc.w	256,64,2,0,7808,8		*Nuke txt3
	dc.w	256,80,2,0,7776,8		*Nuke txt4 dark

	dc.w	96,48,2,0,5200,8		*'FUEL UNITS'

	dc.w	192,128,2,0,28176,8		*'SHOTS'

	dc.w		-1			*End of table	

WEAP_STAT
*	Weapon readout data
*	.w	Weapon mask
*	.w	Picture source offset
*	.w	Name source offset
*	.w	Tech spec 1 text
*	.w	Tech spec 2 text

	dc.w	1,10320,10288,2704,5264		*LASER
	dc.w	4,25696,28208,5264,7824		*Bullet
	dc.w	8,10336,12848,7824,7808		*BFO
	dc.w   16,20576,23088,7808,7792		*Smart bomb
	dc.w   32,15456,17968,7792,2704		*Grenade
	dc.w   64,20560,20528,2704,5264		*Missile
	dc.w  128,15440,15408,5264,7824		*Grounder
	dc.w	0,25600,25616,28192,28192	*None selected
	dc.w	0,25680,25648,7808,2704		*Shield

CONV_BCD
* d0 = number to be converted
* result ends up in d2

	movea.l		#HOLD_TA,a0
	clr.w		d7			*# shifts
	moveq.w		#3,d6			*# cycles
	clr.w		d5			*Tbale offset
	clr.w		d2
BCD_LOP
	move.w		d0,d1			*Get value
	asr.w		d7,d1
	andi.w		#$f,d1
	asl.w		#1,d1
	add.w		d5,d1			*Use offset

	movea.l		#HEX_BCD,a1
	lea		0(a1,d1.w),a1
	move.w		(a1),(a0)+		*Set

	addq.w		#4,d7
	addi.w		#32,d5
	dbf.w		d6,bcd_lop

	movea.l		#HOLD_TA,a0
	clr.w		d4			*Used in carry

	move.b		6(a0),d3	*highest so use this for carry
	move.b		1(a0),d0
	move.b		3(a0),d1	*1st and 2nd lower digits

	abcd		d1,d0
	abcd		d4,d3		*add and do carry

	move.b		5(a0),d1
	abcd		d1,d0
	abcd		d4,d3

	move.b		7(a0),d1
	abcd		d1,d0
	abcd		d4,d3

	move.b		d0,d2
	move.b		d3,6(a0)	*Set new highest&new low

	move.b		2(a0),d0	*Highbyte not set in first
	move.b		4(a0),d1
	abcd		d1,d0
	move.b		6(a0),d1
	abcd		d1,d0
	mulu.w		#256,d0
	add.w		d0,d2
	rts

HOLD_TA
	dc.w		0,0,0,0


HEX_BCD
	dc.w		$0,1,2,3,4,5,6,7,8,9,$10,$11,$12,$13,$14,$15

	dc.w		$0,$16,$32,$48,$64,$80,$96,$112,$128,$144
	dc.w		$160,$176,$192,$208,$224,$240

	dc.w		0,$256,$512,$768,$1024,$1280,$1536,$1792
	dc.w		$2048,$2304,$2560,$2816,$3072,$3328
	dc.w		$3584,$3840

	dc.w		0,$4096,$8192

	
NO_STAT2

*******************************************************************************************

*********************************************************
*	Weapon changover				*
*	By GAH on 15/10/88				*
*********************************************************
	
	tst.w		WEP_CHTIM
	bne		no_wchan

	move.w		#$3,WEP_CHTIM

	tst.w		FIRING
	bne		no_wchan


	tst.b		KEY_CODE
	beq		no_wchan
	
	clr.l		d2
	move.w		WEP_XP,d2		*Hold onto last Xpos
	clr.l		d0
	move.b		KEY_CODE,d0
	
	cmpi.b		#LKEY,d0			
	beq		wep_l

	cmpi.b		#RKEY,d0			
	beq		wep_r

	clr.b		KEY_CODE
	bra		no_wchan

*	Initialise pointer to bullet icon and clear	*
*	lower eight lines				*

INIT_PNT
	movea.l		#SCREENA+30720,a0
	movea.l		#SCREENB+30720,a1

	move.w		#319,d7			*Long word count

EL_BOTT
	clr.l		(a0)+
	clr.l		(a1)+
	dbf.w		d7,el_bott

	movea.l		#POINT_DAT,a6
	movea.l		#SCREENA+30776,a0
	movea.l		#SCREENB+30776,a1
	moveq.w		#7,d7

IN_PLOOP
	move.l		(a6),(a0)+
	move.l		4(a6),(a0)
	move.l		(a6)+,(a1)+
	move.l		(a6)+,(a1)
	lea		156(a1),a1
	lea		156(a0),a0
	dbf.w		d7,in_ploop
	clr.w		WEP_XP
	rts

WEP_L
	clr.b		KEY_CODE
	move.w		d2,d0
	subq.w		#1,d0
*	cmpi.w		#-1,d0
*	bne		do_wepc
	bpl		do_wepc			* KKKK

	moveq.w		#6,d0
	bra		do_wepc

WEP_R
	clr.b		KEY_CODE
	move.w		d2,d0
	addq.w		#1,d0
	cmpi.w		#7,d0
	bne		do_wepc
	clr.w		d0

DO_WEPC

*********
*	Here, d0.w=Xpos of new icon
*	      d2.w=Xpos of old icon
********

	clr.l		SP_TABLE+134		*BYE BYE old weapon

	move.w		d2,d3
	asl.w		#4,d3			* x 16
	movea.l		#WEP_TAB,a1
	lea		0(a1,d3.w),a1		*Get addr of last weapon
	bclr.b		#7,(a1)			*Kill last usage

	move.w		d0,WEP_XP		*Save new xpos

	clr.l		d1
	move.w		d0,d1

	asl.w		#4,d1			* x 16 

*	d1.w=table offset

	movea.l		#WEP_TAB,a1
	lea		0(a1,d1.w),a1

*	A1=addr of new position in weapons table WEP_TAB

	asl.w		#3,d2			* d2 x 8
	
	add.l		#30776,d2		*Offset
	movea.l		#SCREENA,a2

	lea		0(a2,d2.l),a2
	movea.l		#SCREENB,a3
	lea		0(a3,d2.l),a3

	moveq		#7,d7			*line count

	move.l		d0,d1			*d1=new xpos
	asl.w		#3,d1
	movea.l		#SCREENA+30776,a4
	lea		0(a4,d1.w),a4
	movea.l		#SCREENB+30776,a5
	lea		0(a5,d1.w),a5
	movea.l		#POINT_DAT,a6

PUWS_LOP
	clr.l		(a2)+
	clr.l		(a2)
	clr.l		(a3)+
	clr.l		(a3)

	move.l		(a6),(a4)+
	move.l		4(a6),(a4)

	move.l		(a6)+,(a5)+
	move.l		(a6)+,(a5)

	lea		156(a2),a2
	lea		156(a3),a3
	lea		156(a4),a4
	lea		156(a5),a5

	dbf.w		d7,puws_lop

	clr.l		d1
	or.l		(a1),d1
	move.l		d1,WEAPONS
	move.l		a1,WTAB_ADR		*Save address of
						*current weapon table
	tst.l		(a1)			*Is a weapon#
						*already there??
	beq		no_wchan		*No,then no set

	bset.b		#7,(a1)			*Say in use

	bra		no_wchan

WEP_TAB
	dc.l		$80000004		*Bullet
	dc.w		0			*Dummy
	dc.w		9999			*Number of shots(const)
	ds.l		2			*Next 2 dummy

WEP_TAB2
	ds.l		80

TO_DEFAULT
	dc.w		0

WEP_XP
	dc.w		0			*Weapons selected
WEP_CHTIM
	dc.w		0			*Timer to next select


DOSH
	dc.w		0			*<>0 = decrement
						*weapons count

WTAB_ADR
	dc.l		0			*Address of current
						*Weapons table


POINT_DAT
	DC.W $0180,$0180,$0000,$0000,$03C0,$03C0,$0000,$0000

	DC.W $07E0,$0660,$0000,$0000,$0FF0,$0C30,$0000,$0000

	DC.W $1FF8,$1818,$0000,$0000,$3FFC,$3E7C,$0000,$0000

	DC.W $7FFE,$7E7E,$0000,$0000,$FFFF,$FE7F,$0000,$0000


NO_WCHAN
	subq.w		#1,WEP_CHTIM

	tst.w		DOSH
	beq		no_pw

	clr.w		DOSH

	tst.w		WEP_XP		
	beq		no_pw		*Bullet unlimited

	movea.l		WTAB_ADR,a1
	addq.l		#6,a1
	
	tst.w		-4(a1)		*Anything actually there??
	bne		go_gw
	bclr.b		#7,-6(a1)	*Clear flag
	clr.w		WEP_XP		*Select  bullet*****
	move.l		#4,WEAPONS	*******
	move.l		#WEP_TAB,WTAB_ADR	*Set 1st addr	
	bra		no_pw

GO_GW

	subq.w		#1,(a1)		*Decrement number to next icon
	bne		no_pw		*<>0 so dont bother

	subq.w		#1,4(a1)	*Next icon down
	beq		end_w		*Its dead

	move.w		2(a1),(a1)	*Reset 

	clr.l		d0
	move.w		4(a1),d0	*Get icon number
	subq.w		#1,d0

	cmpi.w		#3,d0		*3 is maximum strength that
					*can be displayed
	ble		ok_w
	clr.w		d0		* icon 0 = max
	bra		pro_w

OK_W
	eori.w		#3,d0		*Turn it roun'
PRO_W

	asl.w		#7,d0		* x 128
	
	add.l		6(a1),d0		*Addr of root icon
	
SET_IP
	movea.l		d0,a2			*a2 = data addr
	movea.l		#SCREENA,a3
	movea.l		#SCREENB,a4
	move.w		-2(a1),d0		*Offset into screen

	lea		0(a3,d0.w),a3
	lea		0(a4,d0.w),a4
	bra		st_iput
END_W
	move.l		#STAT_CHR+1664,d0	*Blank icon
	clr.l		WEAPONS
	clr.l		-6(a1)			*Say nowt there
	clr.l		SP_TABLE+134		*Kill bullet
	move.w		#-1,TO_DEFAULT		*Say to default 
	bra		set_ip

ST_IPUT
	moveq		#15,d7			*Line count

PUT_ICN
	move.l		(a2),(a3)+
	move.l		4(a2),(a3)
	move.l		(a2)+,(a4)+
	move.l		(a2)+,(a4)
	
	lea		156(a3),a3
	lea		156(a4),a4
	dbf.w		d7,PUT_ICN

NO_PW
	tst.w		TO_DEFAULT		*Need to go to bullet??
	beq		no_defaul
	tst.w		FIRING
	bne		no_defaul		*Not finised yet
	clr.w		TO_DEFAULT
	move.w		WEP_XP,d0		*Last position
	asl.w		#3,d0			*x8 for offset
	add.w		#56,d0			*Shift to table start
	movea.l		#BLANK_SPRIT,a0		*Set zero data
	jsr		plot_powerlin
	moveq		#56,d0			*Set bank start data
	movea.l		#POINT_DAT,a0		*Pointer start
	jsr		plot_powerlin
	clr.w		WEP_XP
	move.l		#4,WEAPONS		*Clear pointer,set default
	move.l		#WEP_TAB,WTAB_ADR	*Set current table addr
	bset.b		#7,WEP_TAB		*Say in use
NO_DEFAUL

***********************************************************************************************



*********************************************************************************************

*********************************************************
*	Sublevel door processor				*
*	By GAH on 7/6/89				*
*********************************************************


PROC_SUBD
	tst.w		LEVD_STAT		*Door in process
	bne		no_subd

	tst.w		LEVD_SUBDTIM		*Time yet?
	beq		do_subd
	subq.w		#1,LEVD_SUBDTIM
	bra		no_subd

DO_SUBD
	move.w		LEVEL_NUM,d0
	moveq		#72,d1
	mulu.w		d1,d0
	lea		SUBD_TAB(pc,d0.w),a0
	move.l		#SP_TABLE+26,a1
	move.w		(a1),d0			*Red ace Xpos
	move.w		2(a1),d1		*Red ace Ypos
	moveq		#3,d7			*4 subdoors/level
	move.w		ROOM_IN,d3
*If level 4 and room 25 and bomb in then check for final door
	cmpi.w		#25,ROOM_IN
	bne		check_subd		*Not room 25
	cmpi.w		#3,LEVEL_NUM		*Level 4??
	bne		check_subd
	btst.b		#0,FINAL_STAT+1		*Bomb in??
	beq		check_subd
	addq.w		#1,d7			*1 more door to check
	bra		check_subd

SUBD_TAB
*	Door Xpos		0
*	Door Ypos		2
*	Door screen offset	4
*	Exit direction		6

*		1
*		|
*	      4-*-2
*		|
*		3
*	New room Xpos		8
*	New room Ypos		10
*	New room door offset	12
*	Room number		14
*	Nuke number minimum	16

	dc.w	32,120,19376,3,32,49,7696,5,0		*Room 5  lev 0
	dc.w	32,49,7696,1,32,120,19376,10,0		*Room 10 lev 0
	dc.w	256,120,19328,3,256,49,7968,17,1  	*Room 17 lev 0
	dc.w	256,49,7968,1,256,120,19328,22,1  	*Room 22 lev 0
	
	dc.w	256,120,19328,3,256,50,7968,7,3 	*Room 7 lev 1
	dc.w	256,49,7968,1,256,121,19328,12,3  	*Room 12 lev 1
	dc.w	32,120,19376,3,32,49,7696,15,7		*Room 15 lev 1
	dc.w	32,49,7696,1,32,121,19376,20,7		*Room 20 lev 1

	dc.w	0,0,0,0,0,0,0,0,0			*No subdoors lev 2
	dc.w	0,0,0,0,0,0,0,0,0			*No subdoors lev 2
	dc.w	0,0,0,0,0,0,0,0,0			*No subdoors lev 2
	dc.w	0,0,0,0,0,0,0,0,0			*No subdoors lev 2

	dc.w	256,49,7968,1,256,121,19328,14,31	*Room 14 lev 3
	dc.w	256,120,19328,3,256,50,7968,9,31	*Room 9 lev 3
	dc.w	96,120,19248,3,96,50,7888,5,63		*Room 5 lev 3
	dc.w	96,49,7888,1,96,121,19248,10,63		*Room 10 lev 3

	dc.w	257,120,19328,1,256,120,19328,25,63	*Final room door

LEVD_SUBDSTAT
	dc.w		0		

LEVD_SUBDTIM
	dc.w		0

NEWX
	dc.w		0		*Xpos of R.A in new room
NEWY
	dc.w		0		*Ypos of R.A in new room

LEVD_NXTRM
	dc.w		0		*Which direction is new room
					*0/1/2/3=u/d/l/r
NEWOFF
	dc.w		0		*Offset of door in new room

CHECK_SUBD
	cmp.w		14(a0),d3
	bne		next_subd	*Not this room
	cmp.w		(a0),d0		*Xpos
	bne		next_subd

	cmp.w		2(a0),d1	*Ypos
	bne		next_subd

	move.w		NUKE_GOT,d3	*Nuke status
	cmp.w		16(a0),d3	*Sufficeint nuclear capability
	blt		next_subd	*No deterrent       * >>>>
	
**Door has been hit

************DOOR NOIZE HERE*********
	move.w		#2,LEVD_INC
	move.w		#2,LEVD_DIR
	move.w		#1,LEVD_STAT
	move.w		#1,LEVD_SUBDSTAT
	move.w		4(a0),LEVD_OFF
	move.w		6(a0),LEVD_NXTRM
	move.w		8(a0),NEWX
	move.w		10(a0),NEWY	*New RA posn
	move.w		12(a0),NEWOFF
	move.w		#4,LEVD_DFER	*Defer movement for 4 frames
	move.l		#BLANK_SPRIT,SP_TABLE+134	*Kill missile
	
	movea.l		#SP_TABLE+130,a0	* Set all coords to 0
	clr.l		d0
	moveq		#9,d7
ALL_TO_00
	move.l		d0,(a0)
	lea		26(a0),a0
	dbf.w		d7,all_to_00

	bra		no_subd

NEXT_SUBD
	lea		18(a0),a0
	dbf.w		d7,check_subd

NO_SUBD

**********************************************************************************************
*****************************************************************
*	Level door processor.					*
*	It just either opens or close them level doors!!	*
*	By GAH 3/2/89						*
*****************************************************************
DOOR_DEL	equ	16			*Animation speed	

PROC_LD
	tst.w		LEVD_STAT
	beq		no_ld

	tst.w		LEVD_DFER		*Time up yet
	beq		go_ld
	subq.w		#1,LEVD_DFER
	movea.l		#SP_TABLE,a6
	moveq		#15,d7			*Number of sprites to kill
PUT_TO_B2
	move.l		#BLANK_SPRIT,4(A6)	*Kill all sprites
	lea		26(a6),a6
	dbf.w		d7,put_to_b2
	bra		no_ld
GO_LD
	btst.b		#1,LEVD_STAT+1		*Noise on??
	bne		ld_timer
	bset.b		#1,LEVD_STAT+1		*Say init done
	
	movea.l		#DOR_NOZA,a0
	jsr		noize_init
	move.l		a0,SON_TABA
	movea.l		#DOR_NOZB,a0
	jsr		noize_init
	move.l		a0,SON_TABB	
LD_TIMER	
	movea.l		#SP_TABLE+26,a3
	move.w		#3,LEVD_ERCNT
	moveq		#13,d7
	movea.l		a3,a6		
PUT_TO_BL
	move.l		#BLANK_SPRIT,4(A6)	*Kill all sprites
	lea		26(a6),a6
	dbf.w		d7,put_to_bl
	

	clr.l		16(a3)
	clr.l		20(a3)
	clr.l		42(a3)
	clr.l		46(a3)
	clr.l		68(a3)
	clr.l		72(a3)
	clr.l		94(a3)
	clr.l		98(a3)

	tst.w		LEVD_TIM		*Animation timer
	beq		go_levd
	subq.w		#1,LEVD_TIM
	bra		no_ld

ENLEV_LOD
	dc.w		0			*Timer to load
						*V/FBB
LEVD_STAT
	dc.w		0			*<>0=going

LEVD_OFF
	dc.w		0			*Offset of door
						*into screen
LEVD_INC
	dc.w		0			*Door incarnation
						*0/2/4/6/8/10/12/14

LEVD_DIR
	dc.w		0			*Opening -2
						*Closing  2
LEVD_TIM
	dc.w		0			*Animation timer

LEVD_DFER
	dc.w		0			*Levdoor defer

LEVD_ERCNT
	dc.w		0			*Time to stop sprite erase

DOR_NOZA
	dc.w		$0000,$0800,$fff6,$0001,$0050
	dc.w		$0006,$3e01		*Was 0001
	dc.w		$0003,$0008,$0000,$0001,$0080
	dc.w		$0009
	dc.w		$0000,$ffff,$0012,$0001,$0028
	dc.w		$0003,$0008,$0000,$0001,$0040
	dc.w		$0009
	dc.w		$0006,$3f00		*Was 0100
	dc.w		$0009,$0009

DOR_NOZB
	
	dc.w		$0001,$0820,$fff6,$0001,$0050
	dc.w		$0006,$3c02		*Was 0002
	dc.w		$0004,$0008,$0000,$0001,$0080
	dc.w		$0009
	dc.w		$0001,$ffff,$0012,$0001,$0028
	dc.w		$0004,$0008,$0000,$0001,$0040
	dc.w		$0009
	dc.w		$0006,$3f00		*Was 0200
	dc.w		$0009,$0009


*Plot a level door
*a2=source addr
*a0/a1=screen destination addr

PLOT_LEVDOOR
	movem.l		d0-d3/d7,-(sp)
	moveq		#31,d7
LD_DOORLOOP
	movem.l		(a2),d0-d3
	movem.l		d0-d3,(a0)
	movem.l		d0-d3,(a1)
	lea		160(a0),a0
	lea		160(a1),a1
	lea		160(a2),a2
	dbf.w		d7,ld_doorloop
	movem.l		(sp)+,d0-d3/d7
	rts


LEVD_SRC
	dc.w	15472,15488,15504,20592,20608
	dc.w	20624,25712,25728,25744		*Offset into STAT_ADR


GO_LEVD
	move.w		#DOOR_DEL,LEVD_TIM

	move.l		#SCREENA,a0
	move.l		#SCREENB,a1
	move.w		LEVD_OFF,d0
	lea		0(a0,d0.w),a0
	lea		0(a1,d0.w),a1
	

	move.w		LEVD_INC,d0
	lea		LEVD_SRC(pc,d0.w),a2
	move.w		(a2),d0
	movea.l		#STAT_GPHX,a2
	lea		0(a2,d0.w),a2		*Source

	bsr		plot_levdoor
	move.w		LEVD_DIR,d0		*Open/close
	add.w		d0,LEVD_INC
	bmi		end_ld
	cmpi.w		#16,LEVD_INC
	bne		no_ld
END_LD
	clr.w		LEVD_TIM
	clr.w		LEVD_STAT
* If was final door,abort to asteroid final sequence
	cmpi.w		#3,LEVEL_NUM
	bne		not_fdoor
	cmpi.w		#25,ROOM_IN
	bne		not_fdoor
	bset.b		#1,FINAL_STAT+1		*Say final door shut
	bra		no_ld
NOT_FDOOR
	tst.w		LEVD_DIR
	bpl		no_nl
	tst.w		LEVD_NXTRM
	bne		no_nl
	move.w		#2,ENLEV_LOD		*Say to load V/FBB	
NO_NL
	btst.b		#0,LEVD_SUBDSTAT+1	*Sublev door closed
	bne		subd_closed
	btst.b		#1,LEVD_SUBDSTAT+1	*Set R.A. xpos
	beq		no_ld
	move.w		NEWX,SP_TABLE+26
	move.w		NEWY,SP_TABLE+28
	clr.w		LEVD_SUBDSTAT
	clr.w		LEVD_NXTRM
	move.w		#500,LEVD_SUBDTIM	*Delay next for 10 sec
	bra		no_ld
SUBD_CLOSED
	move.w		#1,LEVD_STAT
	move.w		#2,LEVD_SUBDSTAT	*Next stage
	move.w		NEWOFF,LEVD_OFF
	move.w		#14,LEVD_INC
	move.w		#-2,LEVD_DIR
	move.w		LEVD_NXTRM,d0
	cmp.w		#1,d0
	bne		notup
	bsr		room_up
	bra		no_ld
NOTUP
	cmp.w		#2,d0
	bne		notright
	bsr		room_right
	bra		no_ld
NOTRIGHT
	cmp.w		#3,d0
	bne		notdown
	bsr		room_down
	bra		no_ld
NOTDOWN
	cmp.w		#4,d0
	bne		no_ld
	bsr		room_left
	bra		no_ld
ERROR
	bra		error	

NO_LD

*********************************************************************************************

*********************************************************
*	Level changer					*
*	By GAH on 21/10/88				*
*********************************************************

DOORNOZ_LEN		equ	9600

NEW_LEV
	tst.w		LEVD_STAT		*Door in process?
	bne		no_nxtlev		*YES

	tst.w		LEVD_CHAN
	bne		chan_room		*Doors closed

	move.w		LEVEL_NUM,d2
	asl.w		#4,d2
	lea		EXIT_TAB(pc),a0
	lea		0(a0,d2.w),a0
	move.w		(a0),d0			*Ex room#
	cmp.w		ROOM_IN,d0
	bne		no_nxtlev
	
	move.l		SP_TABLE+26,d0
	cmp.l		2(a0),d0		*At exit coords
	bne		no_nxtlev
	
	move.w		NUKE_GOT,d0
	cmp.w		6(a0),d0		*Got all nuke??
	bne		no_nxtlev		* >>>>-------

	move.w		#1,LEVD_STAT		*Set door
	move.w		8(a0),LEVD_OFF		*Where onscreen
	move.w		#2,LEVD_INC		*Which to start
	move.w		#2,LEVD_DIR		*Closing
	move.w		#1,LEVD_CHAN		*Say change in progress

************DO DOOR NOIZE HERE*************

	bra		no_nxtlev


CHAN_ROOM

	move.w		LEVEL_NUM,PRE_LEVEL		*remember last lev#

	addq.w		#1,LEVEL_NUM

	bsr		load_32x32

	clr.w		BLNK_ICN			*go icons

	move.w		LEVEL_NUM,d2
	asl.w		#3,d2
	lea		ENTRY_TAB(pc),a0
	lea		0(a0,d2.w),a0		*addr of entry coords
	move.l		(a0),SP_TABLE+26	
	move.w		6(a0),ENTRY_RM		*get entry room #

	move.w		4(a0),LEVD_OFF
	move.w		#14,LEVD_INC
	move.w		#-2,LEVD_DIR
	move.w		#1,LEVD_STAT

	clr.w		VBB
	clr.w		VBB_DIE
	bra		rom_pr

PRE_LEVEL
	dc.w		0		*Holds highest level so far

LEVD_CHAN
	dc.w		0		*1=changing room

EXIT_TAB		*Exit coordinates for all levels
*	0	ROOM#	.w
*	2	XPOS	.w
*	4	YPOS	.w
*	6	NUKE	.w
*	8	DOOR_OFF.w
*	10
*	12
*	14

	dc.w	28,256,120,1,19328,0,0,0		*level 0
	dc.w	29,256,120,7,19328,0,0,0		*level 1
	dc.w	02,256,24,15,3968,0,0,0			*level 2
	dc.w	00,$00,$00,0,00000,0,0,0		*level 3
	

ENTRY_TAB
*	0	Xpos		.w
*	2	Ypos		.w
*	4	DoorOff		.w
*	6	Room#		.w
	dc.w		0,0,0,0			*Shouldnt get here
						*as its lev 0
	dc.w		224,25,4112,3		*xpos,ypos,0,rm#:lvl1
	dc.w		32,121,19376,25				:lvl2
	dc.w		256,121,19488,27
ENTRY_RM
	dc.w		0

ROM_PR
	
*Clear sparker table
	clr.l		SPKT_OFF		*Clear offset
	movea.l		#SPARK_TAB,a2
	moveq		#9,d7

CLR_SPK2
	clr.l		(a2)+
	clr.l		(a2)+
	clr.w		(a2)+
	dbf.w		d7,clr_spk2

	clr.l		TEL_OFF
	clr.l		TEL_INC
	clr.w		TEL_STAT
	clr.w		RM_ITOF		*Icon table pointer
DON_ELOD
	jsr		open_level
	jsr		load_level
	jsr		close_rf


	move.w		LEVEL_NUM,d0		* KKKK
	cmpi.w		#3,d0
	bne		not_end
	
	movea.l		#FBB_FILE,a0
	jsr		sam_open
	jsr		load_fbb
	bra		no_vflod

NOT_END
	jsr		VBB_LOAD
NO_VFLOD

		
	cmpi.w	#3,LEVEL_NUM
	bne	no_lfbbarm
	
	movea.l	#AXP_FILE,a0
	jsr	sam_open
	move.l	#ARM_XPLEN,d0
	movea.l	#ARM_XPDAT,a0
	jsr	sam_read
	jsr	sam_close

NO_LFBBARM
	move.w		ENTRY_RM,d0
	jsr		get_rmaddr
	bsr		room_draw		*a0 set,draw it!!
	
	move.l		#SP_TABLE,a3		*Corrupted by Rd

	clr.w		BBMOV			*Say no bb this rom
	clr.l		SP_TABLE+134		*clear bullet
	move.l		#LASER_STAT,a2
	clr.w		(a2)


***Clear all sprites
	move.l		#SP_TABLE,a2
	moveq		#15,d7			*Sprite count
SP_KLOOP2
	move.l		#0,16(a2)
	move.l		#0,20(a2)
	move.l		#0,4(a2)
	lea		26(a2),a2
	dbf		d7,sp_kloop2

	clr.w		NUM_THERE			*# Beasties

	movea.l		#TIM_TAB,a2			*Beast mov tim tab
	moveq		#11,d7				*12 timers

KIL_TIMTAB2
	move.w		TIM200,d0
	mulu.w		#$1234,d0
	andi.w		#$7f,d0
	ori.w		#$10,d0
	move.w		d0,(a2)+
	dbf.w		d7,kil_timtab2

	clr.w		EYE_THERE		*No eyes yet
	clr.w		SMART_STAT		*No smart bombs
	clr.w		MISS_STAT
	clr.w		MISS_P			*No missiles
	clr.w		GREN_STAT		*No grenade
	clr.w		GRND_STAT		*No grounder
	clr.w		LASER_STAT	
	clr.w		BULLET
	clr.w		BFO_STAT	
	clr.w		VBB_XPPNT		*Clear xplos exp

*	Clear dead doors table
	clr.l		DDOOR_POS
	moveq		#9,d7			*Spaces in door table
	movea.l		#DDOOR_TAB,a2
CL_DDT2
	clr.l		(a2)+
	dbf.w		d7,CL_DDT2
	clr.w		LEVD_CHAN		*Not changing room

GET_AGAIN2
	move.w		TIM200,d0		*Random
	andi.l		#$1f,d0			*32 beasties max

	cmpi.w		#7,d0			*Eye #1
	beq		get_again
	cmpi.w		#8,d0			*Eye #2
	beq		get_again
	cmpi.w		#18,d0
	beq		get_again		*Slinky 2
	
	cmp.l		BTYPE,d0		*Within allowed range
	bgt		get_again2
	
	move.l		d0,ROOMB		*Set beastie for this room

NO_NXTLEV

*********************************************************************************************

		jmp	again

**********************************************************************************************

GET_SC
		lea	sc_no(PC),a1
		btst.b	#0,1(a1)
		bne	screen1
		movea.l 8(a6),a2
		movea.l 20(a6),a5
		movea.l #SCREENA,a0
		rts

SCREEN1
		movea.l 12(a6),a2
		movea.l 16(a6),a5
		movea.l #SCREENB,a0
		rts


GET_SC2
		lea	sc_no(PC),a1
		btst.b	#0,1(a1)
		bne	scrn1a
		movea.l 12(a6),a2
		movea.l 16(a6),a5
		movea.l #SCREENB,a0
		rts

SCRN1A
		movea.l 8(a6),a2
		movea.l 20(a6),a5
		movea.l #SCREENA,a0
		rts


CHEAT		dc.w	0		* <>0 = cheat mode

DRAW		dc.w	1

SC_NO		dc.w	0

SC_CHAN 	dc.w	0

FIRING		dc.w	0		;<>0 if firearm active

GUN_OFFSET	dc.w	0	;Ypos offset to gun barrel

KEY_TIMER
		dc.w	0
WEAPONS
		dc.l	4


******************************************************************************************+

; Bung processor into supervisor and alter VBI queue so
; that it now executes code with  label  VBI


ACT_VBI:

;first set to low res.

	move.w	#0,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	pea	set_vbi(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
goback

	rts

set_vbi
	movea.l	$456.w,a0
	lea	vbi(pc),a1
	moveq	#8,d0
get_vector
	cmpi.w	#0,(a0)
	bne	next_vec
	move.l	a1,(a0)
	bra	goback
next_vec
	addq.l	#8,a0
	dbf.w	d0,get_vector
	bra	goback

*******************************************************************************************

* call joyinit then all joystick 1 data appears in 'stick' *

joyinit	
	pea 	data(pc)
	move.w 	#1,-(sp)
	move.w 	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	move.l	#keyint,$118.w
	rts

data	dc.b $14,$12

keyint	btst.b	#7,$fffc00
	beq	no_key
wait_buf
	btst.b	#0,$fffc00
	beq.s	wait_buf
	move.l 	d0,-(sp)
	move.b 	$fffc02,d0	* KKKK:
	cmp.b 	#255,d0		* Joystick paket header?
	bne.s 	check		* no, check if key or paket byte
	move.b 	d0,status	* paket header!
	bra 	done		* out
check	tst.b 	status		* last byte was paket header?
	beq.s 	iskey		* no, -> key pressed
	move.b 	d0,joystick+1	* save stick data byte
	clr.b 	status		* clear paket flag
	bra.s	done
iskey	btst	#7,d0		* key released?
	bne.s	done		* yes, don't register
	move.b	d0,key_code	* no, pressed -> save
done	move.l	(sp)+,d0
no_key	bclr.b	#6,$fffa11
	rte

status		dc.b	0	;used by interrupt to read joystick data
joystick	dc.w 	0 	;joystick data byte
key_code	dc.b	0	;keycode if key is pressed
		EVEN

**********************************************************************************************
* VBI routines *
*              *

CYC_SPD		equ	4

VBI
		movem.l d0-d7/a0-a6,-(sp)

		move.w	CYCLE(pc),d0		* which color
		tst.w	d0			* perform color cycling?
		beq	no_cyc			* no	

		tst.w	CYC_TIM
		beq	do_cyc
		subq.w	#1,CYC_TIM
		bra	no_cyc

DO_CYC
		move.w	#CYC_SPD,CYC_TIM

		move.w	CYC_COL(pc),d0
		andi.w	#$7,d0
		move.w  d0,d2

		btst.b	#0,CYCLE+1		*Cycle RED
		beq	not_red
		moveq	#8,d1
		asl.w	d1,d0
NOT_RED
		move.w	d0,$ffff8250.w		*Colour 9
		add.w	CYC_ADD(pc),d2
		tst.w	d2
		bmi	res_cyc
		cmpi.w	#8,d2
		beq	res_cyc
		move.w	d2,CYC_COL
		bra	no_cyc
RES_CYC
		not.w	CYC_ADD
		addq.w	#1,CYC_ADD
		
NO_CYC						
		lea	sc_chan(pc),a0		*
		cmpi.w	#1,(a0)			* switch screens?
		bne	sonic_vbi		* no
		clr.w	(a0)			

		tst.w	STOP_VBI		* switch screen?
		bne	screen1a		* no, only screen A active
		lea	sc_no(pc),a0		* yes...
		eori.w	#1,(a0)			* toggle screen number
		tst.w	(a0)
		beq	screen1a
		move.l	#SCREENB,d0
		bra	put_it
screen1a
		move.l	#SCREENA,d0
put_it
		move.l	d0,$44e.w
		swap	d0
		move.b	d0,$ffff8201.w
		swap	d0
		asr.w	#8,d0			* Get LSB upperbyte-> lower
		move.b	d0,$ffff8203.w

		lea	draw(pc),a0		* 
		eori.w	#1,(a0)			* 

SONIC_VBI
* d1/d7/a1/a2 are not use directly by VBI but by SON_SET
*when the VBI BSR's there during a soundgen update

	lea	 	$ffff8800.w,a2

	tst.w		VOL_ITA 		*Any volume
	beq		no_freqa		*No, then next SG

	subq.w		#1,VOL_TIA
	bne		no_vola

	move.w		VOL_RTA,VOL_TIA 	*Reset timer

	move.w		VOLA,d0 		*Get volume level
	add.w		VOL_INA,d0		*Add volume increment
	move.w		d0,VOLA 		*Store new value

	andi.w		#$1f,d0
	ori.w		#$800,d0		*Register 8
	movep.w 	d0,0(a2)
	subq.w		#1,VOL_ITA
	bne		no_vola

	move.l		SON_TABA,a0		*Get table addr
	bsr		noize_init
	move.l		a0,SON_TABA

NO_VOLA

	tst.w		FREQ_ITA		*Any freq
	beq		no_freqa

	subq.w		#1,FREQ_TIA		*Dec timer
	bne		no_freqa

	move.w		FREQ_RTA,FREQ_TIA	*Reset timer

	move.w		FREQA,d0		*Get freq value
	add.w		FREQ_INA,d0		*Add increment
	move.w		d0,FREQA		*Store new
	
	andi.w		#$ff,d0 		*Lower byte
	movep.w 	d0,0(a2)		*Register 0

	move.b		FREQA,d0		*High byte
	ori.w		#$100,d0		*Register 1
	movep.w 	d0,0(a2)

	subq.w		#1,FREQ_ITA		*1 less iteration

NO_FREQA


	tst.w		VOL_ITB 		*Any volume
	beq		no_freqb		*No, then next SG

	subq.w		#1,VOL_TIB
	bne		no_volb

	move.w		VOL_RTB,VOL_TIB 	*Reset timer

	move.w		VOLB,d0 		*Get volume level
	add.w		VOL_INB,d0		*Add volume increment
	move.w		d0,VOLB 		*Store new value

	andi.w		#$1f,d0
	ori.w		#$900,d0		*Register 9
	movep.w 	d0,0(a2)
	subq.w		#1,VOL_ITB
	bne		no_volb

	move.l		SON_TABB,a0		*Get table addr
	bsr		noize_init
	move.l		a0,SON_TABB

NO_VOLB

	tst.w		FREQ_ITB		*Any freq
	beq		no_freqb

	subq.w		#1,FREQ_TIB		*Dec timer
	bne		no_freqb

	move.w		FREQ_RTB,FREQ_TIB	*Reset timer

	move.w		FREQB,d0		*Get freq value
	add.w		FREQ_INB,d0		*Add increment
	move.w		d0,FREQB		*Store new
	
	andi.w		#$ff,d0 		*Lower byte
	ori.w		#$200,d0
	movep.w 	d0,0(a2)		*Register 2

	move.b		FREQB,d0		*High byte
	ori.w		#$100,d0		*Register 3
	movep.w 	d0,0(a2)

	subq.w		#1,FREQ_ITB		*1 less iteration

NO_FREQB

	tst.w		VOL_ITC 		*Any volume
	beq		no_freqc		*No, then next SG

	subq.w		#1,VOL_TIC
	bne		no_volc

	move.w		VOL_RTC,VOL_TIC 	*Reset timer

	move.w		VOLC,d0 		*Get volume level
	add.w		VOL_INC,d0		*Add volume increment
	move.w		d0,VOLC 		*Store new value

	andi.w		#$1f,d0
	ori.w		#$a00,d0		*Register 10
	movep.w 	d0,0(a2)
	subq.w		#1,VOL_ITC
	bne		no_volc

	move.l		SON_TABC,a0		*Get table addr
	bsr		noize_init
	move.l		a0,SON_TABC

NO_VOLC

	tst.w		FREQ_ITC		*Any freq
	beq		no_freqc

	subq.w		#1,FREQ_TIC		*Dec timer
	bne		no_freqc

	move.w		FREQ_RTC,FREQ_TIC	*Reset timer

	move.w		FREQC,d0		*Get freq value
	add.w		FREQ_INC,d0		*Add increment
	move.w		d0,FREQC		*Store new
	
	andi.w		#$ff,d0 		*Lower byte
	ori.w		#$400,d0
	movep.w 	d0,0(a2)		*Register 4

	move.b		FREQC,d0		*High byte
	ori.w		#$100,d0		*Register 5
	movep.w 	d0,0(a2)

	subq.w		#1,FREQ_ITC		*1 less iteration

NO_FREQC



	tst.w		NOZ_ITM 		*Any noize freq?
	beq		no_noz
	subq.w		#1,NOZ_TIM
	bne		no_noz

	move.w		NOZ_RES,NOZ_TIM 	*Reset

	move.w		NOZ_FREQ,d0
	add.w		NOZ_INC,d0
	move.w		d0,NOZ_FREQ		*Store new freq

	andi.w		#$1f,d0
	ori.w		#$600,d0		*Register 6
	movep.w 	d0,0(a2)

NO_NOZ

	tst.w		ENV_ITA 		*Any env freq??
	beq		no_env

	subq.w		#1,ENV_TIM
	bne		no_env
	
	move.w		ENV_RES,ENV_TIm 	*Reset timer
	
	move.w		ENV_FRQ,d0		*16 bit freq value
	add.w		ENV_INC,d0		*Add increment
	move.w		d0,ENV_FRQ		*Store new value

	andi.w		#$ff,d0 		*Get low byte
	ori.w		#$b00,d0		*Register 11
	movep.w 	d0,0(a2)

	move.w		#$c00,d0		*Register 12
	or.b		ENV_FRQ,d0		*High byte
	movep.w 	d0,0(a2)

	subq.w		#1,ENV_ITA

NO_ENV						* KKKK
	tst.l		MUS_ADR			* play tune?
	beq.s		VBI_RET			* no
	move.l		MUS_ADR,a0		* yes
	jsr		8(a0)			* play!

VBI_RET
	movem.l (sp)+,d0-d7/a0-a6
	rts


STOP_VBI
	dc.w		0			*<>0 then only SCREENA is active

CYCLE
	dc.w		0
*0=no cycle
*1=colour 9 red cycle
*2=colour 9 blue cycle

CYC_COL
	dc.w		0	

CYC_TIM
	dc.w		0

CYC_ADD
	dc.w		1

				
***********************************************************************************************		

SAM_SET

	lea	SAM_TABLE(pc),a1
	ori.b	#1,6(a1)		;samplay flag

	move.l	a0,(a1) 	;sample address
	move.w	d0,4(a1)		;sample length
	
	move.w	#$7b,d1 	;default 5Khz
SET_INT
	move.b	d1,$fffffa1f.w	*Timer data
	bset.b	#5,$fffffa13.w

                lea  	$ffff8800.w,a0	     ;base address of chip
                move.b  #0,0(a0)             ;channel 'a'
                move.b  #0,2(a0)
                move.b  #1,0(a0)
                move.b  #0,2(a0)
                move.b  #2,0(a0)             ;channel 'b'
                move.b  #0,2(a0)
                move.b  #3,0(a0)
                move.b  #0,2(a0)
                move.b  #4,0(a0)             ;channel 'c'
                move.b  #0,2(a0)
                move.b  #5,0(a0)
                move.b  #0,2(a0)
                move.b  #7,0(a0)             ;set up channel mixing  
                move.b  #$ff,2(a0)      ;& port 'a' i/o
                move.b  #8,0(a0)                ;set all volumes to zero
                move.b  #0,2(a0)
                move.b  #9,0(a0)
                move.b  #0,2(a0)
                move.b  #10,0(a0)
                move.b  #0,2(a0)

		clr.w	VOL_ITA
		clr.w	VOL_ITB
		clr.w	VOL_ITC
		clr.w	NOZ_ITM
		clr.w	ENV_ITA
NO_SAM
	rts			;cumbak!!!

INT

	movem.l d4/d5/d7/a0/a1/a3/a4,-(a7)
	lea	SAM_TABLE(pc),a0	;sample variabs adr
	tst.l	(a0)
	bne	go_sam
	bra	TIMA_RET

GO_SAM
	lea	SND_OUT(pc),a3	;lookup table
	movea.l (a0),a1 	;a1=sample addr
	lea	$ffff8800.w,a4	;sound gen ctl reggy

	move.b	(a1),d7 	;d7=sampled data
	and.w	#$ff,d7 	;mask out crap
	add.b	#$80,d7 	;complement it
	lsl.w	#3,d7		;2* long word offset

	move.w	2(a3,d7.w),d5	;data #1
	move.w	4(a3,d7.w),d4	;data #2

	movep.w d5,0(a4)
	movep.w d4,0(a4)
	
	addq.l	#1,(a0) 	;next byte in sam tab
	subq.w	#1,4(a0)	;decrement count
	beq	kill_sam	;end of sample??

TIMA_RET
	movem.l (sp)+,d4/d5/d7/a0/a1/a3/a4
	bclr.b	#5,$fffffa0f.w
	bclr.b	#5,$fffffa0b.w
	rte			;cumback

KILL_SAM
	clr.l	(a0)
	clr.w	6(a0)		;kill playing flag
	move.w	#$073f,d4		; All SGs off
	movep.w	d4,0(a4)		*kill PSG
	movem.l (a7)+,d4/d5/d7/a0/a1/a3/a4
	bclr.b	#5,$fffffa0f.w	;Blank Interupt in service flg
	bclr.b	#5,$fffffa0b.w
	bclr.b	#5,$fffffa13.w
	rte

SAM_TABLE
	dc.l	0		;sample addr
	dc.w	0		;sample length
	dc.w	0		;sample status
;<>0=sample running


SAM_SPEEDTAB
	dc.w	$cd,$9a,$7b,$66


HUP_LEN		equ	640
ARGH_LEN	equ	1248
EXPLOS_LEN	equ	4440
ARM_XPLEN	EQU	12834		*FBB ARM EXP DATA LEN,was 12834
RELOAD_LEN	equ	1472
BLOW_LEN	equ	3792
DYING_LEN	equ	6550


SAM_LOAD

	lea	ARGH_FILE(pc),a0
	bsr	SAM_OPEN
	move.l	#argh_len,D0
	lea	ARGH(pc),a0		;mem address
	bsr	SAM_READ
	bsr	SAM_CLOSE
	

	lea	DYING_FILE(pc),a0
	bsr	SAM_OPEN
	move.l	#DYING_LEN,D0
	lea	DYING_SAM(pc),a0		;mem address
	bsr	SAM_READ
	bsr	SAM_CLOSE
	

;	lea	BLOW_FILE(pc),a0
;	bsr	SAM_OPEN
;	move.l	#BLOW_LEN,D0
;	lea	BLOW_SAM(pc),a0		;mem address
;	bsr	SAM_READ
;	bsr	SAM_CLOSE


	lea	HUP_FILE(pc),a0
	bsr	SAM_OPEN
	move.l	#hup_len,D0
	lea	HUP(pc),a0		;mem address
	bsr	SAM_READ
	bsr	SAM_CLOSE


	lea	EXPLOS_FIL(pc),a0
	bsr	SAM_OPEN
	move.l	#explos_len,D0
	movea.l	#EXPLOS,a0		;mem address
	bsr	SAM_READ
	bsr	SAM_CLOSE

	rts

SAM_OPEN
	move.w	#2,-(sp)
	move.l	a0,-(sp)		;a0=filename addr
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	lea	SAM_HANDLE(pc),a0
	move.w	d0,(a0)
	rts

SAM_READ

	move.l	a0,-(sp)		;file buffer
	move.l	d0,-(sp)		;file length
	lea	SAM_HANDLE(pc),a0
	move.w	(a0),-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp
	rts

SAM_CLOSE
	lea	SAM_HANDLE(pc),a0
	move.w	(a0),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

SET_PNTR
;sets file pointer to data part of a DEGAS file

	move.w	#0,-(sp)
	lea	HANDLE(pc),a0
	move.w	(a0),-(sp)
	move.l	#34,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	adda.l	#10,sp
	rts	

SAM_HANDLE
	dc.w	0

ARGH_FILE	
	dc.b	'ARGH.SAM',0
	EVEN
HUP_FILE
	dc.b	'HUP.SAM',0
	EVEN

EXPLOS_FIL
	dc.b	'EXPLOS.SAM',0
	EVEN


FBB_FILE
	dc.b	'FBB.PI1',0
	EVEN
BIGBOT_FIL
	dc.b	'BIGBOTS.FNT',0
	EVEN

AXP_FILE
	dc.b	'ARMXP.PI1',0
	EVEN
BLOW_FILE
	dc.b	'GUNABLOW.SAM',0
	EVEN

REL_FILE
	dc.b	'RELOAD.SAM',0
	EVEN
DYING_FILE
	dc.b	'DYING.SAM',0
	EVEN

ARGH
	ds.b	ARGH_LEN

HUP
	ds.b	HUP_LEN

DYING_SAM
	ds.b	DYING_LEN


	include   sam_look.s		;sam lookup table; dc.b only


**********************************************************************************************

SET_PALETTE
	pea	CHARPALETTE(PC)
	move.w	#$06,-(SP)
	TRAP	#$0E				;Set-Palette
	addq.l	#$06,SP
	rts


CHARPALETTE
	dc.w $0000,$0770,$0400,$0600,$0235,$0222,$0357,$0000
	dc.w $0340,$0740,$0221,$0444,$0666,$0333,$0555,$0777
	dc.l	0				; Just in case 
	
********************************************************************************************
;
;ST Sprite Routines 16*16 Character set compatable
;
;note at the moment this is not position independent code
;


PLOTSPRITE
;		this routine will plot a sprite onto the screen
;		after having first saved the background into safe
;		memory provided on entry by the calling code
;
;demo entry params
;A0.l	points to screen start address
;A1.l	points to start of sprite data
;A2.l	points to start of background cache
;A3.w	contains the XPOS of the sprite
;A4.w	contains the YPOS of the sprite
;
;routine returns in A5 the absolute address of the top left
;of the sprite screen address must be passed to the clear routine
;in A5  NOTE in the final version may calculate this from XPOS, YPOS


		movem.l	d0-d6/a0-a4/a6,-(a7)	;save regs
		
				
		moveq.l	#0,d1
		move.w	a4,d1		;move.w	YPOS,d1		
		bpl.s	ps_yok		* <<<<
		moveq	#0,d1		* <<<<
ps_yok					* <<<<
		asl.l	#1,d1		;YPOS*2
		move.l	d1,d2
		asl.l	#2,d1		;YPOS*8
		add.l	d2,d1		;YPOS*10
		asl.l	#4,d1		;YPOS*160

		moveq.l	#0,d0
		move.w	a3,d0		;move.w	XPOS,d0		
		bpl.s	ps_xok		* <<<<
		moveq	#0,d0		* <<<<
ps_xok					* <<<<
		move.l	d0,d2
		moveq	#16,d5
		and.l	#$f,d2		;pixels to shift
		sub.l	d2,d5
		and.l	#$fffffff0,d0
		lsr.l	#1,d0		;XPOS/2
		add.l	d1,d0		;offset
		add.l	d0,a0		;add offset to base screen address

put_last
		move.l	a0,a5

		moveq	#15,d6		;cache background into safe
saveback:	movem.l	(a0),d0-d3	;memory
 		movem.l	d0-d3,(a2)
		lea.l	160(a0),a0
		lea	16(a2),a2
		dbf.w	d6,saveback
		
		lea.l	-2544(a0),a0	;now plot the sprite

		moveq	#15,d6
nextline	moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		move.w	(a1)+,d0	;bit plane 0
		move.w	(a1)+,d1	;bit plane 1
		move.w	(a1)+,d2	;bit plane 2
		move.w	(a1)+,d3	;bit plane 3
		
		lsl.l	d5,d0		;shift all bit planes
		lsl.l	d5,d1
		lsl.l	d5,d2
		lsl.l	d5,d3
		
		move.l	d0,d4		;create mask for a line
		or.l	d1,d4
		or.l	d2,d4
		or.l	d3,d4
		not.l	d4		;mask is in d4
		
		and.w	d4,-(a0)	;now map data onto the screen
		or.w	d3,(a0)
		swap.w	d3
		and.w	d4,-(a0)
		or.w	d2,(a0)
		swap.w	d2
		and.w	d4,-(a0)
		or.w	d1,(a0)
		swap.w	d1
		and.w	d4,-(a0)
		or.w	d0,(a0)
		swap.w	d0
		swap.w	d4
		and.w	d4,-(a0)
		or.w	d3,(a0)
		and.w	d4,-(a0)
		or.w	d2,(a0)
		and.w	d4,-(a0)
		or.w	d1,(a0)
		and.w	d4,-(a0)
		or.w	d0,(a0)

		lea.l	176(a0),a0	;set up for next line
		dbf.w	d6,nextline
		
;
;now exit the plot routine
;
		movem.l	(a7)+,d0-d6/a0-a4/a6	;restore registers
		rts
		
;
CLEARSPRITE:
;	routine to clear out a sprite by copying cache over it
;
	movem.l	d0-d3/d6/a2/a5,-(a7)
	
	moveq.l	#15,d6		;16 lines to copy
clrloop	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a5)
	lea.l	160(a5),a5
	dbf.w	d6,clrloop
	
	movem.l	(a7)+,d0-d3/d6/a2/a5
	rts

SCRN_POS:
	dc.l	$00000000

***********************************************************************************************
* SP_SET.S

set_sp
		move.l	#sp_table,a6
		move.l	#cache,a2
		move.l	#man_grph,a1
		move.w	#NUM_SPR,d0			*# to initialise
set_loop
		move.w	#0,(a6)
		move.w	#0,2(a6)
	
		move.l	#0,4(a6)
		move.l	a2,8(a6)
		lea	256(a2),a2
		move.l	a2,12(a6)
		lea	256(a2),a2
		move.l	#0,16(a6)
		move.l	#0,20(a6)
		adda.l	#26,a6
		dbf	d0,set_loop

******   Set up RED ACE position ***************		
		move.l	#SP_TABLE,a6
		move.w	#$30,26(a6)
		move.w	#$30,28(a6)

		clr.w	BBMOV		*Stop Big beastie
		rts

**********************************************************************************************

SP_TABLE
	
			dc.w	0	;xpos		* Offset 0
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos		* Offset 26
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos		* Offset 52
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos		* Offset 78
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos		* Offset 104
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos		* Offset 130
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status		
			dc.w	0	;xpos		* Offset 156
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos		* Offset 182
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos		* Offset 208
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos		* Offset 234
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos		* Offset 260
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos		* Offset 286
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
	
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
	
		
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
			dc.w	0	;status
			dc.w	0	;xpos
			dc.w	0	;ypos
			dc.l	0	;dat-addr
			dc.l	0	;cache1
			dc.l	0	;cache2
			dc.l	0	;last1
			dc.l	0	;last2
		        dc.w	0	;status
		
**********************************************************************************************		
*********************************************************************
*  DOSOUND setter upper:....D0.w=priority
*			    D1.w=sound register/b0=SG1/b1=SG2/b2=SG3
*			    A6.l=address of lookup table
*********************************************************************

SET_SOUND
		movem.l		d1-d7/a0-a6,-(sp)	;save reggies
		lea		SOUND_STAT(pc),a5
		
		and.w		(a5),d1			;owt playing??
		beq		do_it			;nope
		move.w		d1,d2
		
		lsr.w		#1,d2			;/2
		lsl.w		#1,d2			;*2
		cmp.w		2(a5,d2.w),d0		;priority
		ble		do_it			;lower prior
		move.w		#0,d0			;unsucc flg
		movem.l		(sp)+,d1-d7/a0-a6
		rts
		
DO_IT
		or.w		d1,(a5)			;set play flg
		move.l		a6,-(sp)		;table addr
		move.w		#32,-(sp)		;DOSOUND
		trap		#14
		addq.l		#6,sp
		move.w		#-1,d0			;success flg
		movem.l		(sp)+,d1-d7/a0-a6
		rts
		
SOUND_STAT
		dc.w	0
PSG1
		dc.w	0		*PSG1  status
PSG2
		dc.w	0
PSG3
		dc.w	0
		
***********************************************************************************************

FILL_SCREEN	
	opt	d+

	lea	file1(pc),a5
	move.l	#$58000,d5
	bsr	do_sfill
	lea	file2(pc),a5
	move.l	#$5fd00,d5
	bsr	do_sfill
	lea	file3(pc),a5
	move.l	#$67a00,d5
	bsr	do_sfill
	rts

DO_SFILL
	bsr	open
	bsr	set_pntr
	bsr	read
	bsr	close
	rts

open
	move.w	#2,-(sp)
	move.l	a5,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	lea	handle(pc),a0
	move.w	d0,(a0)
	rts
file1
	dc.b	'dumpa.pi1'
	EVEN
file2
	dc.b	'dumpb.pi1'
	even
file3
	dc.b	'dumpc.pi1'
	even
handle
	ds.w	1
read
	move.l	d5,-(sp)
	move.l	#32000,-(sp)
	lea	handle(pc),a0
	move.w	(a0),-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp
	rts

close
	lea	handle(pc),a0
	move.w	(a0),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

**********************************************************************************************
* ROOM_MOV.S
* Room changing routines

ROOM_CHANGE
	clr.l		d0
	lea		SP_TABLE(pc),a3
	move.l		ROOM_ADDR,a4		*Room header addr

	move.w		26(a3),d0		*XPOS
	cmpi.w		#3,d0
	ble		room_left
	cmpi.w		#284,d0
	bge		room_right
	move.w		28(a3),d0
	cmpi.w		#2,d0
	ble		room_up
	cmpi.w		#127,d0
	bge		room_down
	bra		room_done

ROOM_LEFT
	move.w		4(a4),d0
	bsr		get_rmaddr
	cmp.l		#-1,a0
	beq		room_done
	move.w		#280,HLD_X
	move.w		SP_TABLE+28,HLD_Y
	bra		put_room

HLD_X
	dc.w		0
HLD_Y
	dc.w		0
RMADR_HLD
	dc.l		0

ROOM_RIGHT
	move.w		8(a4),d0
	bsr		get_rmaddr
	cmp.l		#-1,a0
	beq		room_done
	move.w		#5,HLD_X
	move.w		SP_TABLE+28,HLD_Y
	bra		put_room
ROOM_DOWN
	move.w		10(a4),d0
	bsr		get_rmaddr
	cmp.l		#-1,a0
	beq		room_done
	move.w		#8,HLD_Y
	move.w		SP_TABLE+26,HLD_X
	bra		put_room
ROOM_UP
	move.w		6(a4),d0
	bsr		get_rmaddr
	cmp.l		#-1,a0
	beq		room_done
	move.w		#126,HLD_Y
	move.w		SP_TABLE+26,HLD_X

PUT_ROOM
	move.l		a0,RMADR_HLD
************************************************************
*	movem.l		d0-d7/a0-a6,-(sp)	*Preseve for after reload

*	include		reload.s
*	movem.l		(sp)+,d0-d7/a0-a6
*************************************************************

*Clear sparker table

	move.w		HLD_X,SP_TABLE+26
	move.w		HLD_Y,SP_TABLE+28

	clr.l		SPKT_OFF		*Clear offset
	movea.l		#SPARK_TAB,a2
	moveq		#9,d7

CLR_SPK
	clr.l		(a2)+
	clr.l		(a2)+
	clr.w		(a2)+
	dbf.w		d7,clr_spk

	clr.w		FIRING		*Say no weapons
	clr.l		TEL_OFF
	clr.l		TEL_INC
	clr.w		TEL_STAT
	clr.w		RM_ITOF		*Icon table pointer
	andi.w		#$2,FBB_STAT	*Clear all fbb except dead

	tst.w		BB_STAT			* any 32x32 in last room
	beq		dont_restore
	tst.w		BB_FACING		* Was 32x32 facing right
	bmi		dont_restore		* No,dont reflip
	movea.l		BB_FLIPSAVE,a0
	jsr		next_lin		* Flip BB
DONT_RESTORE

	clr.w		DIE_BB
	clr.w		BB_STAT			* Reset big beastie
	clr.w		BB_YDIR			* KKKK: reset BB Y movement (else BBs may raise to the ceiling of the room and get stuck there)
	clr.w		DOOR_XP			* Stop SB door exp
	clr.w		BB_THERE		* Enable SB draw
	movea.l		RMADR_HLD,a0		* Get room addr
**********************************************************************
	bsr		room_draw		* a0 set,draw it!!
**********************************************************************

	move.l		#SP_TABLE,a3		*Corrupted by Rd

CLR_LAST
	clr.l		SP_TABLE+134			*clear bullet
	move.l		#LASER_STAT,a2
	clr.w		(a2)

	clr.w		BBRUN			*No BB till set

***Clear all sprites
	move.l		#SP_TABLE,a2
	moveq		#15,d7			*Sprite count
SP_KLOOP
	move.l		#0,16(a2)
	move.l		#0,20(a2)
	move.l		#BLANK_SPRIT,4(a2)
	lea		26(a2),a2
	dbf		d7,sp_kloop


	movea.l		#TIM_TAB,a2			*Beast mov tim tab
	moveq		#11,d7				*12 timers

KIL_TIMTAB
	move.w		TIM200,d0
	mulu.w		#$1234,d0
	andi.w		#$7f,d0
	ori.w		#$10,d0
	move.w		d0,(a2)+
	dbf.w		d7,kil_timtab

	clr.w		EYE_THERE		*No eyes yet
	clr.w		SMART_STAT		*No smart bombs
	clr.w		MISS_STAT
	clr.w		MISS_P			*No missiles
	clr.w		GREN_STAT		*No grenade
	clr.w		GRND_STAT		*No grounder
	clr.w		VBB			*No VBB there
	clr.w		BFO_STAT
	clr.w		LASER_STAT
	clr.w		BULLET
*	Clear dead doors table
	clr.l		DDOOR_POS
	moveq		#9,d7			*Spaces in door table
	movea.l		#DDOOR_TAB,a2
CL_DDT
	clr.l		(a2)+
	dbf.w		d7,CL_DDT

	move.w		#0,NUM_THERE			*# Beasties

GET_AGAIN
	move.w		TIM200,d0		*Random
	andi.l		#$1f,d0			*32 beasties max

	cmpi.w		#7,d0			*Eye #1
	beq		get_again
	cmpi.w		#8,d0			*Eye #2
	beq		get_again
	cmpi.w		#18,d0
	beq		get_again		*Slinky 2
	
	cmp.l		BTYPE,d0		*Within allowed range
	bgt		get_again
	

STORE_B
	move.l		d0,ROOMB		*Set beastie for this room
	
ROOM_DONE
	rts

********************************************************************************************

SDOOR_DAT
		include   sdoors.s		* dc.b only

**********************************************************************************************
*****************************************************************
*Red Ace Room Processor routines	v0.5			*
*By GAH on 7 Jun 88						*
*****************************************************************
	opt		d+

POW_ICN			equ	167	*Powerup icon
REC_LEN 		equ	6
BB_CHAR			equ	200	*BB start position
SPARKER			equ	151
DED_SING		equ	202
TEL_CHR			equ	97
LOW_ICN			equ	156
HI_ICN			equ	165
HI_NUKE			equ	195
LO_NUKE			equ	190
EXIT_DOOR		equ	100	*These are set into RM_BEAST
ENTRY_DOOR		equ	101 	*Not recognised as characters



OPEN_LEVEL		

* Opens level file number specified as 3 ascii digits
*	at LEV_NUM	e.g. 00 30 30 30 =Room# 000
*	and returns an error message if unable to open it


	movea.l 	#LEV_NAME+11,a1 	*Lev name extension
	

OPEN_IT
	move.b		#$30,(a1)		* ZERO lev #
	move.w		LEVEL_NUM,d0
	add.b		d0,(a1)			*Now we talkin'
	
	lea		-14(a1),a1		*Filename start

	clr.w		-(sp)			*READ ONLY
	pea		LEV_NAME(pc)
	move.w		#$3d,-(sp)
	trap		#1			*OPEN
	addq.l		#8,sp

	tst.w		d0			*Error
	bmi		open_err		*Yes,say what and why	

	move.w		d0,LEV_HANDLE		*Save handle #
	rts

LEV_NAME
	dc.b		'LEVEL___.000',0
	EVEN



LEV_HANDLE
	dc.w		0

LEV_NUM
	dc.b		'0000'

LEVEL_NUM
	dc.w		0			


OPEN_ERR
	move.l		#ERR_MESS+14,a2 	*Ext of err message
	moveq		#2,d0			*Count
	
COPY_FNAME
	move.l		(a1)+,(a2)+
	dbf		d0,copy_fname

	pea		ERR_MESS(pc)
	move.w		#9,-(sp)
	trap		#1			*Say message
	addq.l		#6,sp

OPERR_LOOP
	bra		operr_loop

ERR_MESS
	dc.b		$d,$a,'Cannot load		',0



*******************************************************************
*	Level number filename increment 			  *
*******************************************************************

ROOMLEV_INC
	
	addq.w		#1,LEVEL_NUM

	rts


*****************************************************************
*  Actual room file loader					*
*****************************************************************


LOAD_LEVEL
	moveq.l 	#1,d0				*# Records
	move.l		#TEMP_REC,d1			*Address
	bsr		read_rec

	moveq.l 	#0,d0
	move.w		TEMP_REC,d0			*Next avbl
	move.l		#LEVEL_DATA,d1
	subq.l		#1,d0				*# To load
	
	bsr		read_rec

	rts

READ_REC	*	d0=#Records  d1=buffer addr
	move.l		d1,-(sp)
	mulu.w		#6,d0
	move.l		d0,-(sp)			*#  Bytes
	move.w		LEV_HANDLE,-(sp)
	move.w		#$3f,-(sp)			*Read
	trap		#1
	lea		12(sp),sp

	tst.l		d0
	bmi		open_err
	
	rts

*****************************************************************
*	Close a file						*
*****************************************************************


CLOSE_RF
	move.w		LEV_HANDLE,-(sp)
	move.w		#$3e,-(sp)
	trap		#1
	addq.l		#4,sp

	rts


*****************************************************************
*	PLOT  a character					*
*	A0=Screen address					*
*	A1.L = Character address				*
*	d1.L = Xpos						*
*	d2.L = Ypos						*
*****************************************************************


PLOT_CHAR
	movem.l 	d1-d3/d7/a0-a1,-(sp)

	asr.l		#1,d1		* Xpos /2	
	move.l		d2,d3		*Temp Ypos save
	asl.l		#7,d3		* 128 *
	asl.l		#5,d2		* 32  *
	add.l		d2,d3
	add.l		d1,d3

	add.l		d3,a0		*Screen addr

	moveq		#15,d7		* Count

PL_CH
	move.l		(a1)+,(a0)+
	move.l		(a1)+,(a0)+
	lea		152(a0),a0
	dbf		d7,pl_ch
	movem.l 	(sp)+,d1-d3/d7/a0-a1
	rts
	


******************************************************************
*  GIVEN ROOM NUMBER ID D0.W,returns address of this rooms data  *
*  field in A0.L.  Maximum room# = 255,A0.L=$FFFFFFFF if not	 *
* found 							 *
******************************************************************


GET_RMADDR
	moveq.w 	#0,d1		*Start room number
	move.l		#LEVEL_DATA,a0
	
FIND_ROOM
	cmp.w		d0,d1
	beq		found_room
	moveq		#0,d2
	move.w		(a0),d2 	*No chars in this room
	mulu.w		#6,d2		*1 record = 6 bytes
	adda.l		d2,a0
	addq.w		#1,d1
	cmpi.w		#256,d1
	bne		find_room

ROOM_ERROR
	movea.l 	#$ffffffff,a0
	rts
FOUND_ROOM
	move.w		d0,ROOM_IN	*Save room#
	rts


*****************************************************************
*	SCREEN CLEAR...D7.L=Num lines to clear on both screens	*
*****************************************************************

SCR_CLR
	movem.l 	a0/a1,-(sp)
	movea.l 	#SCREENA,a0
	movea.l 	#SCREENB,a1
	mulu.w		#40,d7			*40 long words
	subq.w		#1,d7

CLR_LOP
	move.l		#0,(a0)+
	move.l		#0,(a1)+
	dbf.w		d7,clr_lop
	movem.l 	(sp)+,a0/a1
	rts


*****************************************************************
*	SCREEN COPY...Copies screen A to screen B		*
*****************************************************************


COPY_AB
	move.l		#SCREENA,a1
	move.l		#SCREENB,a2
	move.w		#8000,d6

SC_COPY
	move.l		(a1)+,(a2)+
	dbf.w		d6,sc_copy
	rts


*****************************************************************
*	ROOM DRAWER....Address of room data table passed in	*
*	A0.L and room is drawn in screen A then transferred	*
*	to screen B						*
*****************************************************************


ROOM_DRAW
	moveq		#0,d0
	move.l		d0,SP_TABLE+182
	move.l		d0,SP_TABLE+208
	move.l		d0,SP_TABLE+234
	move.l		d0,SP_TABLE+260
	move.l		d0,SP_TABLE+286		*Clear X,Y coords
	
	move.w		#3,LEVD_ERCNT
	move.w		CYCLE,-(sp)		*Preserve colour cycle
	clr.w		BBMOV
	clr.l		DDOOR_POS		*No dead doors ( yet!!)
 	clr.w		CYCLE
	move.l		a0,-(sp)		*Save it
	pea		NULL_PALL(pc)
	move.w		#6,-(sp)
	trap		#14
	addq.l		#6,sp
	move.l		(sp)+,a0		*Bring it back

	move.l		#SDOOR_TAB,a6
	moveq		#60,d0
KILL_SD
	move.l		#0,(a6)+
	dbf		d0,kill_sd
	move.w		#0,SINGLE_DOORS 	*kill # sdoors

	move.l		a0,ROOM_ADDR		*Temp storage
	move.b		3(a0),RM_BEAST+1	*Set beastie
	move.w		4(a0),LEFT_DOR		*Set left
	move.w		6(a0),UPPER_DOR 	*Set upper
	move.w		8(a0),RIGHT_DOR 	*Set right
	move.w		10(a0),LOWER_DOR	*Set lower


	move.l		#160,d7 		*# line to blank
	bsr		scr_clr

	move.w		(a0),d7 		*Number of chars
	moveq.l 	#0,d0
	subq.w		#3,d7			*Skip room header
	move.b		2(a0),d0		*Background char
	asl.l		#7,d0			* 128 *
	move.l		#BAK_CHARS,a1		*Background chars
	add.l		d0,a1
	move.l		#SCREENA,a0		*Start SCR addr

SET_BACKCH
	move.l		#304,d1 		*Xpos start
	move.l		#144,d2 		*Ypos start
	move.l		d1,d3			*Xpos reset store
	moveq		#19,d4			*CounterX
	moveq		#9,d5			*Counter Y
OUTER_P
	bsr		plot_char
	sub.w		#16,d1			*New Xpos
	dbf		d4,outer_p
	move.w		d3,d1			*Reset Xpos			
	moveq		#19,d4			*Reset count
	sub.w		#16,d2			*New Ypos
	dbf		d5,OUTER_P		*Next vert


******D7.W=NUMBER CHARS THIS ROOM
	move.l		ROOM_ADDR,a6
	lea		12(a6),a6		*Skip header
	move.l		#SCREENA,a0	

PLACE_RM
	moveq.l 	#0,d3			*Clear it
	move.w		(a6)+,d1		*Xpos
	move.w		(a6)+,d2		*Ypos
	move.w		(a6)+,d3		*Char number#
	move.l		d3,d4
	andi.w		#$7fff,d4		*Rid X-RAY
	cmp.w		#BB_CHAR,d4
	beq		set_bllim		*BB left lim
NO_DOOR
	cmpi.w		#DED_SING,d4 		*Dead sing door
	beq		set_dedd
	cmpi.w		#SPARKER,d4		*Sparker
	beq		set_spark

	cmpi.w		#LOW_ICN,d4
	blt		no_icn

	cmpi.w		#HI_ICN,d4
	ble		do_icn
NO_ICN
	cmpi.w		#POW_ICN,d4	*Powerup
	beq		put_icons

	cmpi.w		#LO_NUKE,d4
	blt		not_anuk

	cmpi.w		#HI_NUKE,d4
	ble		do_icn


NOT_ANUK

	cmpi.w		#TEL_CHR,d4
	bne		done_setspk

	movem.l		d1-d3,-(sp)	*Save for post calculation use
	asr.l		#1,d1		* Xpos /2	
	move.l		d2,d3		*Temp Ypos save
	asl.l		#7,d3		* 128 *
	asl.l		#5,d2		* 32  *
	add.l		d2,d3
	add.l		d1,d3
	move.l		d3,TEL_OFF	*Save offset
	movem.l		(sp)+,d1-d3	*Restore coordinates
	

DONE_SETSPK

	asl.l		#7,d4		* multiplicate by 128
	move.l		#BAK_CHARS,a1	
	add.l		d4,a1
	btst.l		#15,d3			*X-RAY???
	beq		itsa_sprite
	bsr		plot_char
	bra		putted_char

ITSA_SPRITE
	move.l		#CACHE,a2		*Put it somewhere
	move.w		d1,a3			*Xpos
	move.w		d2,a4			*Ypos
	jsr		plotsprite

PUTTED_CHAR
	andi.w		#$7fff,d3		*Mask of char flag
	cmpi.w		#SDOOR_CHAR,d3		*Single Bdoor
	bne		no_door1

	moveq.l 	#0,d6
	move.w		SINGLE_DOORS,d6 	*d6=num sing doors
	asl.w		#3,d6			* x 8 bytes
	move.l		#SDOOR_TAB,a5
	adda.l		d6,a5

	move.w		d1,(a5) 		*door xpos
	move.w		d2,2(a5)		*door ypos
	addq.w		#1,SINGLE_DOORS
	move.l		a6,d1
	subq.l		#2,d1			*Address of char in tab
	move.l		d1,4(a5)
	clr.l		d1			*Clear for plotchar

	bra		no_door1

SET_DEDD
	movea.l 	#DDOOR_TAB,a2
	adda.l		DDOOR_POS,a2		*Posn within table
	move.w		d1,(a2)+		*Save xpos
	move.w		d2,(a2)			*Save ypos
	addq.l		#4,DDOOR_POS
	bra		no_door1
	
DDOOR_POS
	dc.l		0
BLNK_ICN
	dc.w		0		*<>0 if show fuel only


DDOOR_TAB
	ds.l		10


SET_SPARK			
*	Initialise sparker table

	movea.l		#SPARK_TAB,a2
	adda.l		SPKT_OFF,a2		*Pointer
	move.w		d1,(a2)+
	move.w		d2,(a2)+		*xpos/ypos
	move.l		a6,d5
	subq.l		#8,d5			*Point to xpos addr
	move.l		d5,(a2)

	add.l		#12,SPKT_OFF		*Inc pointer
	andi.w		#$7ff,d1		*Kill ded spkt flag
	bra		done_setspk

SPKT_OFF
	dc.l		0			*Pointer in spark table
SPARK_TAB
	ds.b		120			*ten sparkers


SET_BLLIM
	move.w		RM_BEAST,d0
	cmpi.w		#EXIT_DOOR,d0			*Is it lev exit door
	beq		do_setlevd
	cmpi.w		#ENTRY_DOOR,d0			*Is it entry door
	bne		do_setbllim

DO_SETLEVD
	btst.b		#0,LEVD_SUBDSTAT+1	*Should door be init closed?
	bne		no_door
	bsr		door_status		*See if open or shut
	move.w		LEVEL_NUM,d6
	cmpi.w		#3,d6			*Level 4??
	bne		no_final		*Not final door
	move.w		ROOM_IN,d6
	cmpi.w		#25,d6			*Final room
	bne		no_final
	moveq		#100,d0			*Make door open
NO_FINAL
	asr.w		#1,d1			*/2
	mulu.w		#160,d2			* x 160
	add.w		d2,d1
	movem.l		a0-a2,-(sp)
	movea.l		#STAT_GPHX,a2
	lea		15472(a2),a2
	cmpi.w		#ENTRY_DOOR,d0		*Set to open door
	bne		not_entry
	lea		10256(a2),a2		*Set to closed door
NOT_ENTRY
	movea.l		#SCREENA,a0
	movea.l		#SCREENB,a1
	lea		0(a0,d1.w),a0
	lea		0(a1,d1.w),a1
	jsr		plot_levdoor
	movem.l		(sp)+,a0-a2
	bra		no_door1


DO_SETBLLIM
	move.w		d1,BB_XPOS		*Save xpos
	move.w		d2,BB_YPOS
	move.w		#1,BBMOV
	move.l		a6,BLADR		*Save addr of marker
	subq.l		#2,BLADR		*Correct for (a6)+
	move.w		#1,BB_THERE		*Prevent SB drawing

NO_DOOR1
	dbf		d7,place_rm
*	Draw dead doors

	movea.l 	#DDOOR_TAB,a0

P_DDOOR
	tst.w		(a0)			*xpos=0=end of tab
	beq		no_mordd

	clr.l		d0
	clr.l		d1

	move.w		(a0)+,d0		*Xpos
	move.w		(a0)+,d1
	subi.w		#16,d0
	subi.w		#16,d1
	move.l		d1,d2

	asl.w		#5,d1
	asl.w		#7,d2
	add.l		d1,d2

	asr.w		#1,d0
	add.l		d2,d0			*D0=offset

	move.l		a0,-(sp)		*Save pointer
	movea.l 	#SCREENA,a0
	adda.l		d0,a0			*a0=addr of top lhs
	
	lea		8(a0),a1
	lea		8(a1),a2		*next to char right
	
	movea.l 	#DXP_CHAR+4608,a3	     *addr data

	lea		128(a3),a4
	lea		128(a4),a5

	moveq		#2,d7			*3 cahrs down

DXP_LOOP3
	moveq		#15,d6			*15 lines/char
DXP_LOOP4
	movem.l 	(a3)+,d0-d1
	movem.l 	(a4)+,d2-d3
	movem.l 	(a5)+,d4-d5

	move.l		d0,(a0)+
	move.l		d1,(a0)+
	move.l		d2,(a1)+
	move.l		d3,(a1)+
	move.l		d4,(a2)+
	move.l		d5,(a2)+

	lea		152(a0),a0
	lea		152(a1),a1
	lea		152(a2),a2
	dbf.w		d6,dxp_loop4

	lea		256(a3),a3
	lea		256(a4),a4
	lea		256(a5),a5		*next char
	dbf.w		d7,dxp_loop3

	movea.l 	 (sp)+,a0

	bra		p_ddoor

NO_MORDD
	cmpi.w		#3,LEVEL_NUM		*Level 4??
	bne		no_fbbdoor		*Not level 4
	cmpi.w		#20,ROOM_IN		*Fbb room??
	bne		no_fbbdoor
	btst.b		#1,FBB_STAT+1		*FBB totally dead
	beq		no_fbbdoor
	bset.b		#4,FBB_STAT+1
	move.l		#256,d1			*Set door xpos
	move.l		#144,d2			*Set door ypos
DO_FBBDOOR
	movea.l		#BAK_CHARS+(8*128),a1	*Set bakground addr
	movea.l		#SCREENA,a0		*Screen 1
	jsr		plot_char
	add.l		#16,d1
	cmpi.w		#304,d1			*Done yet??
	bne		do_fbbdoor
	bset.b		#5,FBB_STAT+1		*Say door open

NO_FBBDOOR
	cmpi.w		#3,LEVEL_NUM
	bne		no_finrm		*Not final room level
	cmpi.w		#25,ROOM_IN		*Final room
	bne		no_finrm

*First load it in
	movea.l		#AXP_FILE,a0		* stores generator animation
	jsr		sam_open
	move.l		#32066,d0		*Length to load
	movea.l		#VBB_HOLD,a0
	jsr		sam_read
	jsr		sam_close
	move.w		#112,d7			*Scan line counter
	movea.l		#VBB_HOLD+$3222,a6	*Fin room source
	movea.l		#SCREENA+$1e20,a5	*Destination addr
COPY_FINRM
	movem.l		(a6)+,d0-d3/a0-a3	*Get 4x16 bytes
	movem.l		d0-d3/a0-a3,(a5)
	lea.l		32(a5),a5		*Next block
	movem.l		(a6)+,d0-d3/a0-a3	*Get 4x16 bytes
	movem.l		d0-d3/a0-a3,(a5)
	lea.l		32(a5),a5		*Next block
	movem.l		(a6),d0-d3/a0-a3	*Get 4x16
	movem.l		d0-d3/a0-a3,(a5)
	lea.l		96(a5),a5		*Next line down dest
	lea.l		96(a6),a6		*Next line down source
	dbf.w		d7,COPY_FINRM
	
* Now block up hole
	movea.l		#SCREENA,a0
	lea		0.w,a4			*Ypos
	lea		256.w,a3
	movea.l		#CACHE,a2
	movea.l		#BAK_CHARS+(19*128),a1		*Set source
FILL_DOOR
	jsr		plotsprite
	lea		16(a3),a3
	cmpa.l		#304,a3
	bne		fill_door
NO_FINRM
		

	clr.l		SPKT_OFF		*Clear offset for next
						*room draw
	bsr		copy_AB 		*SCR A -> SCR B
	
	jsr		SET_PALETTE

	move.w		(sp)+,CYCLE		*Restore colour 9 cycle
	rts



DO_ICN
****Set up icon table for this room	****
*Table format
*	.w	XPOS						0
*	.w	YPOS						2
*	.w	ICON     Chr156 = icon 				4
*	.w	OFFSET INTO SCREEN				6
*	.l	Address of char type in room data file		8
*	.l	spare						12



	tst.w		BLNK_ICN
	beq		put_icons

	cmp.w		#156,d4			*Fuel
	beq		put_icons

	move.w		#166,d4			*Blank it
	bra		no_icn

PUT_ICONS

	movem.l		d1-d4,-(sp)		*Save 'em

	movea.l		#RM_ICONT,a1		*Icon table
	move.w		RM_ITOF,d0
	asl.w		#4,d0			* x 16

	lea		0(a1,d0.w),a1

	move.w		d1,(a1)+		*Save Xpos
	move.w		d2,(a1)+		*Save Ypos
	subi.w		#LOW_ICN,d4		*Relative icon #
	move.w		d4,(a1)+

	move.w		d2,d3
	asr.w		#1,d1
	asl.w		#5,d2
	asl.w		#7,d3
	add.w		d2,d3
	add.w		d3,d1
	move.w		d1,(a1)+		*Save screen offset
	
	move.l		a6,d4
	subq.l		#2,d4
	move.l		d4,(a1)			*Save table char addr


	addq.w		#1,RM_ITOF
	movem.l		(sp)+,d1-d4
	bra		not_anuk


NULL_PALL
	dc.w		$0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

ROOM_ADDR
	dc.l		0	*Room header address

RM_BEAST
	dc.w		0	*Room special word

LEFT_DOR
	dc.w		0	*Left door exit

RIGHT_DOR
	dc.w		0	*Right door exit

UPPER_DOR
	dc.w		0	*Upper door exit

LOWER_DOR
	dc.w		0	*Lower door exit
ROOM_IN
	dc.w		0

DOOR_STATUS
* See if sub level door should be open or shut depending upon
* nuke status
****INPUTS    d0=current door...100=open,101=shut
****OUTPUTS   new d0 if necessary
	movem.l		d3-d7/a0,-(sp)
	move.w		#72,d4			*4x18 bytes
	move.w		LEVEL_NUM,d3
	mulu.w		d4,d3			*Get subdoor table offset
	movea.l		#SUBD_TAB,a0
	lea		0(a0,d3.w),a0		*Get 1st entry
	moveq.w		#3,d7			*4 doors per level
FIND_SUBD
	move.w		ROOM_IN,d5
	move.w		14(a0),d6		*Door room
	cmp.w		d5,d6
	bne		not_subd		*Not in right room
	cmp.w		(a0),d1			*Same XPOS??
	bne		not_subd
	cmp.w		2(a0),d2		*Same YPOS
	bne		not_subd
*Door has been found,now is it open or shut
	move.w		#EXIT_DOOR,d0		*Default open
	move.w		16(a0),d5
	move.w		NUKE_GOT,d6		*Current nuke status
	cmp.w		d5,d6
	bge		subd_xit		*Door is open  >>>>------
	addq.w		#1,d0			*Make door shut
SUBD_XIT
	movem.l		(sp)+,d3-d7/a0
	rts
NOT_SUBD
	lea		18(a0),a0		*Next entry
	dbf.w		d7,find_subd
	bra		subd_xit
	
*************************************************************************************************
	
*****************************************************************
*	Sound processor setter upper				*
*	By GAH on 3 Aug 88					*
*       A0=Address of data table				*
*****************************************************************

NOIZE_INIT
*	A0=Address of sound data table
*
		
	movem.l		d0/d1/d2/d7/a1/a2,-(sp)
	clr.l		d0

	clr.w		d7			*Clear end of table marker
	lea	 	$ffff8800.w,a2		*Sound chip addr

NOYZE_LOOP
	movea.l 	#FUNC_TAB,a1		*Function table
	clr.l		d0
	move.w		(a0)+,d0		*Function number
	asl.w		#2,d0
	add.l		d0,a1
	move.l		(a1),a1 		
	jsr		(a1)
	tst.w		d7			*Finished this section
	beq		noyze_loop
	
	movem.l		(sp)+,d0/d1/d2/d7/a1/a2
	rts

SFRA
* Set frequency adjust 'A'

	move.w		4(a0),FREQ_RTA		*Set timer reset value
	tst.w		(a0)+			*If -ve then ignore
	bmi		no_fachan
	move.w		-2(a0),FREQA		*Freq 
NO_FACHAN
 	move.w		(a0)+,FREQ_INA		* increment
	move.l		(a0)+,FREQ_TIA		*Timer & #iteration
	rts


SFRB
* Set frequency adjust 'B'

	move.w		4(a0),FREQ_RTB		*Set timer reset value
	tst.w		(a0)+			*If -ve then leave
	bmi		no_fbchan
	move.w		-2(a0),FREQB		*Freq & increment
NO_FBCHAN
	move.w		(a0)+,FREQ_INB	
	move.l		(a0)+,FREQ_TIB		*Timer & #iteration
	rts


SFRC
* Set frequency adjust 'C'

	move.w		4(a0),FREQ_RTC		*Set timer reset value
	tst.w		(a0)+			*If -ve then leave
	bmi		no_fcchan
	move.w		-2(a0),FREQC		*Freq & increment
NO_FCCHAN
	move.w		(a0)+,FREQ_INC	
	move.l		(a0)+,FREQ_TIC		*Timer & #iteration
	rts


SVOA
* Set volume adjust 'A'

	move.w		4(a0),VOL_RTA		*Volume timer reset
	move.l		(a0)+,VOLA		*Vol lev & increment
	move.l		(a0)+,VOL_TIA		*Timer & #iteration
	rts


SVOB
* Set volume adjust 'B'

	move.w		4(a0),VOL_RTB		*Volume timer reset
	move.l		(a0)+,VOLB		*Vol lev & increment
	move.l		(a0)+,VOL_TIB		*Timer & #iteration
	rts


SVOC
* Set volume adjust 'C'

	move.w		4(a0),VOL_RTC		*Volume timer reset
	move.l		(a0)+,VOLC		*Vol lev & increment
	move.l		(a0)+,VOL_TIC		*Timer & #iteration
	rts

SET_REG7
* Set which tone,which noize etc.
* Upper byte=bits to clear
* Lower byte=bits to set

	move.w		#$700,d0
	move.b		(a0)+,d2		*Bits to set ( off)
	move.b		(a0)+,d1		*Bits to clear ( on)

	or.b		REG_7,d0		*Current mask
	not.b		d1
	and.b		d1,d0
	or.b		d2,d0

	move.b		d0,REG_7
	movep.w 	d0,0(a2)		*Set register 7
	rts

SET_ENV
	move.w		4(a0),ENV_RES		*Set timer reset value
	move.w		(a0)+,d0		*Envelope number
	or.w		#$d00,d0		*Set register 13
	movep.w 	d0,0(a2)
	
	move.l		(a0)+,ENV_INC		*inc & timer
	move.l		(a0)+,ENV_ITA		*#iter & freq
	rts

SET_NOIZE
	move.w		4(a0),NOZ_RES		*Noz timer reset
	move.l		(a0)+,NOZ_FREQ		*Freq & increment
	move.l		(a0)+,NOZ_TIM		*Timer & # iteration
	rts


END_TAB
	moveq.w 	#$7,d7
	rts

FUNC_TAB
	dc.l	SFRA,SFRB,SFRC			*Freq set  0/1/2
	dc.l	SVOA,SVOB,SVOC			*Vol set  3/4/5
	dc.l	SET_REG7			*Which tone/noise 6
	dc.l	SET_ENV 			*Envelope  7
	dc.l	SET_NOIZE			*White noz 8
	dc.l	END_TAB 			*End of this list 9

****** Now all them mega variables as required *********

SON_TABA
		dc.l	0	*Current position in table 'A'
SON_TABB	
		dc.l	0	*    "      "     "   "    'B'
SON_TABC
		dc.l	0	*    "      "     "   "    'C'

REG_7		
		dc.b	$ff	*Readable reg 7 value
		EVEN

FREQA		dc.w	0	*Frequency gen 'A'
FREQ_INA	dc.w	0	*Frequency 'A' increment
FREQ_TIA	dc.w	0	*Frequency 'A' timer
FREQ_ITA	dc.w	0	*Frequency 'A' # iterations
FREQ_RTA	dc.w	0	*Timer reset value


FREQB		dc.w	0	*Frequency gen 'B'
FREQ_INB	dc.w	0	*Frequency 'B' increment
FREQ_TIB	dc.w	0	*Frequency 'B' timer
FREQ_ITB	dc.w	0	*Frequency 'B' # iterations
FREQ_RTB	dc.w	0	*Timer reset value


FREQC		dc.w	0	*Frequency gen 'C'
FREQ_INC	dc.w	0	*Frequency 'C' increment
FREQ_TIC	dc.w	0	*Frequency 'C' timer
FREQ_ITC	dc.w	0	*Frequency 'C' # iterations
FREQ_RTC	dc.w	0	*Timer reset value


VOLA		dc.w	0	*Volume level 'A'
VOL_INA 	dc.w	0	*Volume 'A' increment
VOL_TIA 	dc.w	0	*Volume 'A' timer
VOL_ITA 	dc.w	0	*Volume 'A' # iterations
VOL_RTA 	dc.w	0	*Timer reset value


VOLB		dc.w	0	*Volume level 'B'
VOL_INB 	dc.w	0	*Volume 'B' increment
VOL_TIB 	dc.w	0	*Volume 'B' timer
VOL_ITB 	dc.w	0	*Volume 'B' # iterations
VOL_RTB 	dc.w	0	*Timer reset value


VOLC		dc.w	0	*Volume level 'C'
VOL_INC 	dc.w	0	*Volume 'C' increment
VOL_TIC 	dc.w	0	*Volume 'C' timer
VOL_ITC 	dc.w	0	*Volume 'C' # iterations
VOL_RTC 	dc.w	0	*Timer reset value


ENV_INC 	dc.w	0	*Envleope frequency increment
ENV_TIM 	dc.w	0	*Envelope timer
ENV_ITA 	dc.w	0	*  # iterations
ENV_FRQ 	dc.w	0	* Envelope frequency
ENV_RES 	dc.w	0	* Envelope timer reset value

NOZ_FREQ	dc.w	0	* Noize frequency
NOZ_INC 	dc.w	0	* Noize frequency increment
NOZ_TIM 	dc.w	0	* Noize timer
NOZ_ITM 	dc.w	0	* Noize # iterations
NOZ_RES 	dc.w	0	* Noize timer reset value


***********************************************************************************************


*********************************************************
*	Title load and wait for disk two		*
*	By GAH on 21/10/88 10 mins before closing time  *
*	when all my mates are pissin' off down the pub  *
*	and I cant fuckin' go!!!!!			*
*********************************************************
	opt		c-

FAD_TIM			equ	1
COLOR			equ	15		*Text color
FIN_COL			equ	$777		*Final text colour
						*fade up
ESC			equ	27


LOAD_TITLE


ST_AGN
	move.l		#NULL_PALL,-(sp)
	move.w		#6,-(sp)
	trap		#14
	addq.l		#6,sp

	move.w		#-1,-(sp)
	move.l		#SCREENA,-(sp)
	move.l		#SCREENA,-(sp)
	move.w		#5,-(sp)
	trap		#14
	lea		12(sp),sp

	move.w		#1,STOP_VBI		* display screen A only
	
	tst.l		MUS_ADR			* music already running?
	bne		mus_there		* yes
	jsr		init_mus		* no, initialise music

mus_there	
	tst.w		FIRST_CALL		* executed for the first time?
	beq.s		ST_NO1ST		* no
	clr.w		TXT_PNT			* yes, start with text credits
	clr.w		FIRST_CALL		* clear flag
	bra.s		ST_2
ST_NO1ST
	move.w		#4,TXT_PNT
ST_2	
	clr.w		DIS_STAT		*display status


GPX_GSET
	move.w		TXT_PNT,d0
	asl.w		#2,d0
	lea		TEXT_ADDR,a0
	lea		0(a0,d0.w),a0
	move.l		(a0),a0			*a0=text addr
	move.w		(a0)+,d0		*Set display time
	move.w		d0,DIS_STAT


	btst.l		#14,d0			*Graphix
	beq		no_graphix
	move.l		d0,-(sp)		 
	
	move.l		#NULL_PALL,-(sp)	* set black screen
	move.w		#6,-(sp)
	trap		#14
	addq.l		#6,sp

	
	move.l		#TITLE_FIL,a0		* load title pic
	jsr		sam_open

	move.l		#32768,d0
	movea.l		#SCREENA-34,a0

	jsr		sam_read
	jsr		sam_close

	move.l		#TITLE_PALL,a0
	move.w		#2,dc_waitval
	jsr		blend_colors

	move.l		(sp)+,d0
	andi.w		#$ff,d0
	move.w		d0,DIS_HLD

	addq.w		#1,TXT_PNT
	
	tst.w		DIS_HLD
	beq		gpx_gset

	move.w		DIS_HLD,DIS_TIM
	bsr		pc_wait

	bra		gpx_gset

NO_GRAPHIX
	andi.w		#$ff,d0
	move.w		d0,DIS_HLD
	move.l		a0,-(sp)
	move.w		#9,-(sp)
	trap		#1
	addq.l		#6,sp


UP_PAL
	btst.b		#5,DIS_STAT
	bne		don_fad
	
	btst.b		#7,DIS_STAT		*End
	bne		end_gphx

	move.w		#FAD_TIM,DIS_TIM
	bsr		pc_wait

	move.w		TXT_COL,d0
	cmpi.w		#FIN_COL,d0
	beq		don_fup
	addi.w		#$111,d0
	move.w		d0,TXT_COL
	move.w		d0,-(sp)
	move.w		#COLOR,-(sp)
	move.w		#7,-(sp)
	trap		#14
	addq.l		#6,sp
	bra		up_pal

DON_FUP

	move.w		DIS_HLD,DIS_TIM
	bsr		pc_wait


DWN_PAL
	move.w		#FAD_TIM,DIS_TIM
	bsr		pc_wait

	move.w		TXT_COL,d0
	tst.w		d0
	beq		don_fad
	subi.w		#$111,d0

	move.w		d0,TXT_COL
	move.w		d0,-(sp)
	move.w		#COLOR,-(sp)
	move.w		#7,-(sp)
	trap		#14
	addq.l		#6,sp

	bra		dwn_pal

DON_FAD
	addq.w		#1,TXT_PNT
	bra		gpx_gset


END_GPHX

**********SET GRAPHIX HERE************

	addq.w		#1,TXT_PNT		*Not done by previous
	move.w		#1,CYCLE		* Cycle red color in title pic + text
	clr.w		JOYSTICK
W_NXTD

	btst.b          #7,JOYSTICK+1 
	beq.s		w_nxtd
	bra		done_title

PC_WAIT

	move.w		#37,-(sp)
	trap		#14
	addq.l		#2,sp
	subq.w		#1,DIS_TIM
	bne		pc_wait
	rts

PUT_GPHX
*	a0=source addr
*	a1=dest addr
*	d7=# lines

GPX_LOP
	movem.l		(a0)+,d0-d5/a2-a5
	movem.l		d0-d5/a2-a5,(a1)
	lea		40(a1),a1
	movem.l		(a0)+,d0-d5/a2-a5
	movem.l		d0-d5/a2-a5,(a1)
	lea		40(a1),a1
	movem.l		(a0)+,d0-d5/a2-a5
	movem.l		d0-d5/a2-a5,(a1)
	lea		40(a1),a1
	movem.l		(a0)+,d0-d5/a2-a5
	movem.l		d0-d5/a2-a5,(a1)
	lea		40(a1),a1
	dbf.w		d7,gpx_lop
	rts

CLR_SCR
	movea.l		#SCREENA,a2
	move.w		#8000,d7
EL_LOOPO
	clr.l		(a2)+
	dbf.w		d7,el_loopo
	rts


TEXT_1
	dc.w		150
	dc.b		ESC,'b',COLOR			*Txt col
	dc.b		ESC,'f'				*Cursor off
	dc.b		ESC,'E'				*Home/clear
	dc.b		ESC,'Y',38,52,'A'		*Lin 6 col 20
	dc.b		ESC,'Y',41,34			*Lin 9 col 2
	dc.b		'Tony Goacher and Barry S. Armstrong'
	dc.b		ESC,'Y',44,47			*Lin12 col 15
	dc.b		'Production.'
	dc.b		ESC,'Y',47,44			*Lin 16 col 12
	dc.b		'Copyright ',189,' 1988.',0
	EVEN

TEXT_2
	dc.w		150
	dc.b		ESC,'E'				*Home clear
	dc.b		ESC,'Y',42,41			*12,9
	dc.b		'Code : Tony Goacher.'
	dc.b		ESC,'Y',45,41			*Lin 16 col 12
	dc.b		'Copyright ',189,' 1988.',0
	EVEN

TEXT_3
	dc.w		150
	dc.b		ESC,'E'
	dc.b		ESC,'Y',42,36			*12,4
	dc.b		'Graphics : Barry S. Armstrong'
	dc.b		ESC,'Y',45,36			*Lin 16 col 12
	dc.b		'Copyright ',189,' 1988.',0
	EVEN 

TEXT_5
	dc.w		190
	dc.b		ESC,'E'
	dc.b		ESC,'Y',32+8,32
	dc.b		'     Muzak by Antichrist.',$d,$a,$d,$a
	dc.b		'     Ripped by Grazey of PHF.',$d,$a,$d,$a,$d,$a
	dc.b		'     Bugfixing and additional code',$d,$a,$d,$a
	dc.b		'     by Klapauzius of Atari Legend.',0

TEXT_4
	dc.w		$2000
	dc.b		ESC,'E',0			*Clear & end
	EVEN

TEXT_6
	dc.w		$8030				*  
	dc.b		ESC,'Y',32+23,32+7,ESC,'b',8
	dc.b		'Press fire button to play',0
	EVEN

TEXT_8
	dc.w		$4000				* "Loads" title pic


TEXT_ADDR
	dc.l		TEXT_1,TEXT_2,TEXT_3,TEXT_5
	dc.l		TEXT_4,TEXT_8,TEXT_6
	
DIS_STAT
	dc.w		0

TXT_COL
	dc.w		0

TITLE_PALL
	dc.w		$000,$762,$753,$642,$531,$730,$700
	dc.w		$600,$000,$400,$200,$111,$222,$333
	dc.w		$555,$777

DIS_HLD
	dc.w		0

DIS_TIM
	dc.w		0


TXT_PNT
	dc.w		0

FIRST_CALL
	dc.w		1

DONE_TITLE
	clr.w		CYCLE		* stop color cycling	

	jsr		stop_mus	* stop title music	
	
SECOND_DISK
	move.w		#1,DISK_2

DON_TIT
	rts

	

SHUT_UP:	
	dc.w 		$0800,$0900,$0A00
NOT_RTE:
	rte
OLD_TIMA:
	ds.l		1


DISK_2
	dc.w		0		* <>0 if 2nd disk

TITLE_FIL
	dc.b		'title.pi1',0
	EVEN

TIT_PALL
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0700,$0700
	dc.w $0500,$0700,$0700,$0000,$0000,$0000,$0000,$0000
	
	
*********************************************************************************************
*********************************************************************************************
* routine for (re)initialising all variables,
* so a new game can be started
* after all lives have been lost
**********************************************************************************************

INIT_VAR


	clr.w	FIRSTD_STAT
	clr.w	DEAD_COUNT
	clr.w	DSH_TIM
	clr.w	MAN_STAT
	clr.w	FACE_TIM
	clr.w	COLL_TIM
	clr.w	MAN_WANTIM
	clr.w	MAN_WANI
	clr.w	MS_HOLD
	clr.w	JOY_HOLD
	clr.w	SHOOTIN
	clr.w	FIRE_TIM
	clr.w	JP_ANITIM
	clr.w	FAL_STIM
	clr.w	JP_TIM
	clr.l	JP_INC
	clr.w	JPCOLL_TIM
	clr.w	JUMP_STAGE
	clr.w	JUMP_STAT
	clr.w	JUMP_ANG
	clr.w	JMP_SHT
	clr.w	COLL_STAT
	
	move.w	#1,LOW_HIT		* stand on ground after leaving initial door
	clr.w	HI_HIT
	clr.w	RIGHT_HIT
	clr.w	LEFT_HIT
	
	clr.l	WHICH_PROC
	
	move.w	#10,VBB_SPD
	clr.w	VBB_PWR
	clr.w	TMP_OFF
	clr.w	VBB_XPPNT
	clr.w	BAK_RES
	clr.w	VBB_DIE
	clr.w	OFF_HOLD
	clr.w	VBB_SCNO
	clr.w	VBB_INC
	clr.w	VBB_SN
	clr.w	VBB_PNT
	clr.w	VBB_TMR
	clr.w	VBB_YBD
	clr.w	VBB
	clr.w	VBBB_DIR
	
	move.w	#150,FBB_PWR
	clr.w	FBB_DRXPOS
	clr.w	FBB_DRYPOS
	clr.l	FBB_XDOORTM
	clr.w	FBB_HXP
	clr.w	FBB_HXPTIM
	clr.w	FBB_DIE
	clr.w	FBB_LSTH
	clr.w	FBB_MOUTH
	clr.w	FBB_HP
	clr.w	FBB_INC
	clr.w	FBB_SCR
	clr.w	FBB_STAT
	clr.l	T_FBBHLD
	clr.w	FBB_TIM
	clr.w	FBB_MOPT
	clr.w	FBB_XPINC
	moveq	#8,d0
	lea	FBB_DIRT,A0
vi_loop1	
	clr.l	(a0)+
	dbf	d0,vi_loop1
	clr.w	FBB_NXTB
	
	clr.l	G_OFF
	clr.w	LASER_STAT
	clr.w	LASER_END
	clr.w	LASER_LEN
	clr.l	LASER_ADDR
	clr.w	LASER_STX
	clr.w	LASER_FINX
	clr.w	LASER_YPOS
	clr.w	LASER_EXPINCARN
	clr.w	LASER_TIM
	
	clr.w	BULLET
	clr.w	BX_ANITIM
	clr.w	BX_INC
	move.w	#48,B_RANGE
	clr.w	B_DIST
	
	clr.w	BBRUN
	clr.w	BB_MOVTIM
	clr.w	BB_FACING
	clr.w	BB_YDIR
	clr.w	BB_YHOLD
	clr.l	BLADR
	clr.w	DIE_BB
	clr.w	BB_LAST_PWR
	clr.w	BB_STAT
	clr.w	BB_PWR
	clr.l	BB_FLIPSAVE
	clr.w	BB_XPOS
	clr.w	BB_YPOS
	clr.w	BB_PLEN
	clr.w	BB_XINC
	clr.w	BB_YINC
	clr.w	BB_HDIR
	clr.w	BB_DATOFF
	clr.w	BBMOV
	clr.w	BB_INC
	clr.w	BB_INCTIM
	clr.l	BB_PATHADR
	clr.l	BB_PATHRES
	clr.w	BBULL_XINC
	clr.w	BB_THERE
	
	clr.l	BFO_CINC
	clr.w	BFO_STAT
	
	clr.w	MISS_STAT
	clr.w	MISS_CH
	clr.w	MISS_TIM
	clr.w	MX_ANITIM
	clr.w	MX_INC
	clr.w	MISS_P
	lea	BLANK,A0
	moveq	#31,d0
vi_loop2	
	clr.l	(a0)+
	dbf	d0,vi_loop2
	
	clr.w	GRND_STAT
	clr.w	GRND_TIM
	clr.w	GRND_VPOS
	clr.l	GRND_HADR
	clr.l	GRND_INC
	clr.w	GRND_P
	clr.l	GRND_XPI
	
	clr.w	DXP_XPOS
	clr.w	DXP_YPOS
	clr.w	DOOR_XP
	clr.w	DXP_TIM
	clr.l	DXP_OFFS
	clr.l	DXP_INC
	
	clr.w	SPK_STAT
	clr.w	SPK_ANITIM
	clr.l	SPK_INC
	clr.w	SPK_PAUSE
	move.w	#1,SPK_SHOW
	clr.w	SPK_PSTAT
	
	clr.w	TEL_STAT
	clr.l	TEL_INC
	clr.l	TEL_OFF
	
	clr.w	AST_CNTR
	clr.w	AST_NOZCNT
	clr.l	FINAL_TMR
	clr.w	FINAL_STAT
	clr.l	FINSHP_X
	clr.l	FINSHP_Y
	clr.l	FINSHP_LAST
	clr.l	FINSHP_LAST+4
	clr.l	AST_XPADR
	
	clr.l	ICN_HLADR
	clr.w	PICK_STAT
	clr.w	RM_ITOF
	clr.w	ICN_OFF
	clr.w	NUKE_GOT			
	
	clr.w	CIRCLE
	clr.w	HOME
	move.w	#1,ANI_16
	clr.w	SB_SPD
	clr.w	SB_RESPD
	clr.w	CIRC_TIM
	moveq	#11,d0
	lea	TIM_TAB,A0
vi_loop3	
	clr.w	(a0)+
	dbf	d0,vi_loop3
	
	clr.w	SINGLE_DOORS
	move.w	#4,SBEA_MASK
	move.l	#15,BTYPE
	clr.w	DOOR_DELAY
	clr.w	DO_DSET
	clr.w	FIN_DOOR
	clr.w	NUM_THERE
	clr.w	EYE_THERE
	clr.l	ROOMB
	
	clr.w	SMART_STAT
	clr.w	SMART_TIM
	clr.w	SMART_RES
	clr.w	SEXP_INC
	clr.w	SMART_INC
	
	clr.w	GRN_BBH
	clr.w	GREN_STAT
	clr.w	GREN_XP
	clr.w	GREN_EXP
	clr.w	GREN_DIST
	move.w	#100,GREN_DLIM
	clr.w	G_LSX
	clr.w	G_LSY
	
	clr.l	SCOR_ADD
	clr.l	SCOR_CMP
	clr.l	SCOR_DIS
	
	move.w	#30000,JP_FLEV
	move.w	#8,JP_FSTAT
	clr.w	ADD_FUEL
	clr.w	JP_USE
	
	clr.w	SHLD_SC
	clr.l	SHLD_WADR
	clr.w	SHIELD
	
	move.w	#MAX_RAPWR,LIFE_LEV
	clr.w	TEMP_DIE
	clr.l	FOOT_TAB
	clr.w	DIE_STAT
	clr.w	DIE_TIM
	clr.w	DIE_CNT
	clr.w	DIE
	clr.w	IMMUNE
	move.w	#3,NUM_LIVE		
	
	move.w	#-1,CUR_WEAP
	clr.w	LIN_CNT
	clr.w	STAT_DIS
	clr.l	HOLD_TA
	clr.l	HOLD_TA+4
	
	lea	WEP_TAB,A0
	move.l	#$80000004,(a0)+		*
	clr.w	(a0)+
	move.w	#9999,(a0)+
	moveq	#81,d0
vi_loop4
	clr.l	(a0)+
	dbf	d0,vi_loop4
	clr.w	TO_DEFAULT
	clr.w	WEP_XP
	clr.w	WEP_CHTIM
	clr.w	DOSH
	clr.l	WTAB_ADR
	
	clr.w	LEVD_SUBDSTAT
	clr.w	LEVD_SUBDTIM
	clr.w	NEWX
	clr.w	NEWY
	clr.w	LEVD_NXTRM
	clr.w	NEWOFF
	
	clr.w	ENLEV_LOD
	clr.w	LEVD_STAT
	clr.w	LEVD_OFF
	clr.w	LEVD_INC
	clr.w	LEVD_DIR
	clr.w	LEVD_TIM
	clr.w	LEVD_DFER
	clr.w	LEVD_ERCNT
	
	clr.w	PRE_LEVEL
	clr.w	LEVD_CHAN
	clr.w	ENTRY_RM
	
	move.w	#1,DRAW
	clr.w	SC_NO
	clr.w	SC_CHAN
	clr.w	FIRING
	clr.w	GUN_OFFSET
	clr.w	KEY_TIMER
	move.l	#4,WEAPONS
	
	clr.b	status
	clr.w	joystick
	clr.b	key_code
	
	move.w	#1,STOP_VBI
	clr.w	CYCLE
	clr.w	CYC_COL
	clr.w	CYC_TIM
	move.w	#1,CYC_ADD
	
	clr.l	SAM_TABLE
	clr.l	SAM_TABLE+4
	clr.w	SAM_HANDLE
	
	clr.l	SCRN_POS
	
	lea	SP_TABLE,A0
	lea	SET_SOUND,A1
vi_loop5	
	clr.w	(a0)+
	cmp.l	a1,a0
	bne.s	vi_loop5
	
	clr.w	SOUND_STAT
	clr.w	PSG1
	clr.w	PSG2
	clr.w	PSG3
	
	clr.w	HLD_X
	clr.w	HLD_Y
	clr.l	RMADR_HLD
	
	clr.w	LEV_HANDLE
	move.l	#'0000',LEV_NUM
	clr.w	LEVEL_NUM			*
	
	clr.l	DDOOR_POS
	clr.w	BLNK_ICN
	clr.l	SPKT_OFF
	clr.l	ROOM_ADDR
	clr.w	RM_BEAST
	clr.w	LEFT_DOR
	clr.w	RIGHT_DOR
	clr.w	UPPER_DOR
	clr.w	LOWER_DOR
	clr.w	ROOM_IN
	
	clr.l	SON_TABA
	clr.l	SON_TABB
	clr.l	SON_TABC
	lea	FREQA,A0
	lea	LOAD_TITLE,A1
vi_loop6	
	clr.w	(a0)+
	cmp.l	a1,a0
	bne.s	vi_loop6

	clr.w	DIS_STAT
	clr.w	TXT_COL
	clr.w	DIS_HLD
	clr.w	DIS_TIM
	clr.w	TXT_PNT
	
	clr.w	XXXX
	
	clr.l	SAM_TABLE
	
	rts
	
*********************************************************************************************
init_mus
	move		sr,-(a7)
	ori.w		#$700,sr
	move.l		$134.w,OLD_TIMA		* set Timer A to rte
	move.l		#NOT_RTE,$134.w		*         "
	move		(a7)+,sr
	
	moveq		#1,d0			*
	jsr		TITLE_MUS		* initialise SNDH player
	move.l		#TITLE_MUS,MUS_ADR	* activate music in VBL routine
	rts

stop_mus
	clr.l		MUS_ADR		* stop VBL music
	jsr		TITLE_MUS+4	* disable SNDH routines
	lea		SHUT_UP(pc),a0	* disable chip sound
	lea		$ffff8800.w,a1	*        "
	moveq		#2,d0		*        "
SU_LOOP					*        "
	move.b		(a0)+,(a1)	*        "
	move.b		(a0)+,2(a1)	*        "
	dbf		d0,SU_LOOP	*        "
	move		sr,-(a7)	* reinstate Timer A ...
	ori.w		#$700,sr	* .. sample routines
	move.l		OLD_TIMA,$134.w	*        "
	bset.b		#5,$fffffa07.w	* enable Timer A
	bclr.b		#5,$fffffa13.w	* mask it
	move		(a7)+,sr	*
	rts		

*******************************************************************************************
	
INIT_MFP
		bclr.b	#5,$fffffa07.w
		bclr.b	#5,$fffffa13.w
		move.l	#INT,$134.w
		move.b	#$cd,$fffffa1f.w
		move.b	#1,$fffffa19.w
		clr.l	SAM_TABLE
		bset.b	#5,$fffffa07.w
		rts
	
	
***********************************************************************************************

		dc.b	'Red Ace Serial No.0.5'
		dc.b	'Copyright T.Goacher & B.Armstrong 1988'
		dc.b    'Bugfixes etc.: Klapauzius 2004'
		even

*************************************************************************************************
TITLE_MUS	
		incbin MELODY.SND
		EVEN
MUS_ADR		dc.l    0

TEMP_REC
		ds.b	6
LEVEL_DATA
		ds.b	34000
MAN_GRPH
		incbin	blaster6.fnt
BAK_CHARS
		incbin	playfld4.fnt
SB_TABLE
		incbin	robots.fnt
SB_XPLOS
		include	exp.s		* from here on, all "includes" are data only...

STAT_CHR
		include	icons.s

BIGTAB
		ds.b	3100
BB_BULL
		include	bb_bull.s
BFO_CHAR
		include	bfo_char.s
MISS_CHAR
		include	missiles.s


SMART_CHAR
		include	tmb_char.s
GREN_CHAR
		include	gren_chr.s
DXP_CHAR
		include	back_ani.s
GRND_CHAR
		include	grnd_chr.s
BB_EXPGPX
		include	bb_exp.s


SCR_BUFF
		ds.b	25600		*Buffer for status display


VBB_HOLD
		ds.b	32768		*Very big beastie data

CACHE
		ds.l	2048

STAT_ADR
		incbin	stat_scr.pi1

XXXX		dc.w	0

STAT_GPHX	equ	STAT_ADR+34

EXPLOS
		ds.b	EXPLOS_LEN
BLANK_SPRIT
		ds.b	256
ARM_XPDAT
		ds.b	12834
ZEND
		even