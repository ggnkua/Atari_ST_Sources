c 
	TEXT

	output	d:\centinel\both\aff_font.o
	incdir	d:\centinel\both

	include	d:\centinel\both\define.s
	include	d:\centinel\both\GEM.EQU
	include	SAVEPREF.S
	
	xref	ACTIVE_WINDOW,WINDOW_LIST
	
;**************************************
;	les	touches
;**************************************
	DATA

TABLE_TOUCHES::	;dsp,040
	xref	EDITOR
	xref	LOAD_LOD,LOAD_CLD,LOAD_P56
	xref	adresse,GERE_MENU,EVALUATEUR
	xref	r_scr_g,r_scr_b_v,r_scr_h,r_scr_h_v,r_commu,r_commu_vbr,r_get_object,r_copy,r_vbr
	xref	r_cycle,r_fen_pc,r_eval,r_a,r_put_pc,r_put_pc_fen,r_bkpt,r_ctrl_a,r_skip,r_load,r_scr_b,r_scr_d
	xref	r_go,r_trace,r_trace_tout,r_load
	xref	GERE_MENU,EDITOR
	xref	ROUT_TRACE,RUN,SKIP,RUN_AND_BREAK,CTRLJ,SET_BKPT,CTRL9
	xref	DSP_FILL
	xref	FIN,dsp_adresse
	xref	SETDSPPC
	xref	r_s_bkpt,r_fill,r_bkpt_perm,r_bis,r_watch,r_force_b,r_trace_until
	xref	r_fen_a0,r_fen_a1,r_fen_a2,r_fen_a3,r_fen_a4,r_fen_a5,r_fen_a6,r_fen_a7
	xref	r_fen_d0,r_fen_d1,r_fen_d2,r_fen_d3,r_fen_d4,r_fen_d5,r_fen_d6,r_fen_d7
	xref	S_BKP,SET_BKPT_PERMANENT,TRACE_UNTIL
	xref	r_catch_trap,r_eff_trap
	xref	r_change_d,r_save_binary,r_load_binary,dsp_save_binary
	xref	DSP_FIND,DSP_FIND_AGAIN,DSP_FIND_BACK,DSP_FIND_BACK_AGAIN
	xref	r_get_object_back
	xref	r_get_object_again,r_get_object_again_back
	xref	REFRESH
	xref	STOP_DSP
	xref	FILE_SELECT
	xref	r_nop,r_trace_until_adr_fen
	xref	r_fen_a0_double,r_fen_a1_double,r_fen_a2_double,r_fen_a3_double
	xref	r_fen_a4_double,r_fen_a5_double,r_fen_a6_double,r_fen_a7_double
	xref	r_fen_ssp_double,r_fen_ssp
	xref	RESET,RESET_FROID,r_kill_bkpt,r_reinst_excep
	xref	DISPLAY_HISTORY,DISPLAY_BKPT_LISTE
	xref	intelligent_trace,r_commu_david,r_asm,r_catch_trap_perm
	xref	r_load_sym,macro_menu
	xref	r_update,r_charge_sym,BASE_PAGE,SAVE_OLD_PROS
	
	
	
	dc	$41
	dc.l	macro_menu,macro_menu


	dc	$62			; help
	dc.l	temp_reel,temp_reel

	dc	$23			;H
	dc.l	null,DISPLAY_HISTORY

	dc	$27
	dc.l	null,DISPLAY_BKPT_LISTE	; m

	dc	$42			;F8
	dc.l	FILE_SELECT,FILE_SELECT
	
	dc	$43			;F9
	dc.l	REFRESH,REFRESH

	dc	$012e			;ctrl C
	dc.l	FIN,FIN			


	dc	$0119			; ctrl P
	dc.l	r_update,r_update
	


	*------------------------*
	* controle des sources
	*------------------------*
	dc	$004e			;+
	dc.l	next_source,next_source_40


	*------------------------*
	* fonctions diverses
	*------------------------*
	dc	$0362			;ctrl alt help
	dc.l	STOP_DSP,STOP_DSP


	dc	$12			;E
	dc.l	EVALUATEUR,r_eval		
	dc	$10			;A
	dc.l	dsp_adresse,r_a
	dc	$0210			;A
	dc.l	null,r_asm
	
	
	
	dc	$44			;F10
	dc.l	GERE_MENU,GERE_MENU	
	dc	$0212			;alt E
	dc.l	EDITOR,EDITOR
	
	dc	$0112			;Ctrl E
	dc.l	null,r_reinst_excep
	
	dc	$002c			;W
	dc.l	null,r_watch
	dc.w	$001c			;Enter
	dc.l	null,r_bis
	
	dc	$0353			; ctrl alt del
	dc.l	RESET,RESET	
	dc	$0753			; ctrl alt shift del
	dc.l	RESET_FROID,RESET_FROID	
	
	*------------------------*
	* Trace & co
	*------------------------*
	dc	$0114			;ctrl T
	dc.l	null,r_trace_tout
	dc	$011e			;ctrl Q
	dc.l	null,intelligent_trace
	dc	$0111			;ctrl Z
	dc.l	ROUT_TRACE,r_trace
	dc	$0113			;ctrl R
	dc.l	RUN,r_go
	dc	$13			;R
	dc.l	RUN,r_go
	dc	$0116			;ctrl U
	dc.l	null,r_trace_until_adr_fen
	
	
	dc	$0110			;ctrl A
	dc.l	RUN_AND_BREAK,r_ctrl_a	
	
	dc	$011f			;ctrl S
	dc.l	SKIP,r_skip		
	dc	$0124			;ctrl J
	dc.l	CTRLJ,r_put_pc_fen
	dc	$24			;J
	dc.l	SETDSPPC,r_put_pc
	dc.w	$0121			;ctrl F
	dc.l	null,r_force_b

	dc.w	$14			; T
	dc.l	TRACE_UNTIL,r_trace_until
	
	dc.w	$2f			;V
	dc.l	r_commu,r_commu	
	dc.w	$042f			;Shift V
	dc.l	r_commu_vbr,r_commu_vbr	
	dc.w	$32f			;ctrl alt V
	dc.l	r_vbr,r_vbr
	dc.w	$012f
	dc.l	null,r_commu_david
	

	*------------------------*
	* Breakpoints
	*------------------------*
	dc	$0120			; crtl D
	dc.l	null,r_catch_trap
	dc	$0520			; shift crtl D
	dc.l	null,r_catch_trap_perm
	
	
	dc	$0520
	dc.l	null,r_eff_trap		; Shift crtl d
	dc	$0530			;shift ctrl b
	dc.l	SET_BKPT_PERMANENT,r_bkpt_perm
	dc.w	$0030			;B
	dc.l	S_BKP,r_s_bkpt
	dc	$0130			;ctrl B
	dc.l	SET_BKPT,r_bkpt		
	dc.w	$0125			;ctrl k
	dc.l	null,r_kill_bkpt
	
	*------------------------*
	* op‚rations fenetres
	*------------------------*
	dc	$021f			;alt S
	dc.l	SPLIT_WIN_H,SPLIT_WIN_H			
	dc	$061f			;shitf alt S
	dc.l	SPLIT_WIN_V,SPLIT_WIN_V			
	dc	$0221			; alt F
	dc.l	FUSE_WIN_H,FUSE_WIN_H			
	dc	$0621			; shift alt F
	dc.l	FUSE_WIN_V,FUSE_WIN_V			
	dc	$022e			;alt C
	dc.l	CLOSE_WIN,CLOSE_WIN
	dc	$0231			;alt N
	dc.l	NEW_WIN_DSP,NEW_WIN_40
	dc	$0211			;alt Z
	dc.l	ZOOM,ZOOM
	dc	$0001			;esc
	dc.l	QUIT_ZOOM,QUIT_ZOOM		
	dc	$000f			;tab
	dc.l	CYCLE_W,r_cycle		
	dc	$0216			;alt U
	dc.l	UNLOCK,UNLOCK
	dc	$0226			;alt L
	dc.l	LOCK_WIN,LOCK_WIN


	*------------------------*
	* recherches, copie, remplissage
	*------------------------*
	dc.w	$22						;G
	dc.l	DSP_FIND,r_get_object
	dc.w	$422						;Shift G
	dc.l	DSP_FIND_BACK,r_get_object_back
	dc.w	$31
	dc.l	DSP_FIND_AGAIN,r_get_object_again		; N
	dc.w	$431
	dc.l	DSP_FIND_BACK_AGAIN,r_get_object_again_back	; Shift N
	dc.w	$21			;F
	dc.l	DSP_FILL,r_fill
	dc.w	$2e			;C
	dc.l	r_copy,r_copy
	dc.w	$0331			;ctrl alt N
	dc.l	null,r_nop

		
	*------------------------*
	* les fichiers
	*------------------------*
	dc	$20			; D
	dc.l	r_change_d,r_change_d
	dc	$0220			;alt D
	dc.l	affiche_directory,affiche_directory
	dc	$1f			; S
	dc.l	dsp_save_binary,r_save_binary
	dc.w	$26			; l
	dc.l	LOAD_CLD,r_load_binary
	dc	$0126			;ctrl L
	dc.l	LOAD_LOD,r_load		
	dc	$0526			;ctrl shift L
	dc.l	null,r_load_sym		
	dc	$0118			; Ctrl o
	dc.l	null,r_charge_sym

	


	*------------------------*
	* scrolls dans les fenetres
	*------------------------*
	dc	$050			;
	dc.l	SCROLL_DOWN,r_scr_b	
	dc	$48			;
	dc.l	SCROLL_UP,r_scr_h	
	dc	$4b			;
	dc.l	SCROLL_LEFT,r_scr_g	
	dc	$4d			;
	dc.l	SCROLL_RIGHT,r_scr_d		
	
	dc	$0450			;shif 
	dc.l	SCROLL_DOWN_VITE,r_scr_b_v	
	dc	$0448			;shift 
	dc.l	SCROLL_UP_VITE,r_scr_h_v	
	dc	$044b			;shift 
	dc.l	SCROLL_LEFT_VITE,r_scr_g	
	dc	$044d			;shift 
	dc.l	SCROLL_RIGHT_VITE,r_scr_d		
	

	*------------------------*
	* GOTO 	An
	*------------------------*
	dc	$010a			;ctrl 9
	dc.l	CTRL9,r_fen_pc		
	dc	$010B			;ctrl 0
	dc.l	null,r_fen_a0		
	dc	$0102			;ctrl 1
	dc.l	null,r_fen_a1		
	dc	$0103			;ctrl 2
	dc.l	null,r_fen_a2		
	dc	$0104			;ctrl 3
	dc.l	null,r_fen_a3		
	dc	$0105			;ctrl 4
	dc.l	null,r_fen_a4		
	dc	$0106			;ctrl 5
	dc.l	null,r_fen_a5		
	dc	$0107			;ctrl 6
	dc.l	null,r_fen_a6		
	dc	$0108			;ctrl 7
	dc.l	null,r_fen_a7		
	dc	$0109			;ctrl 8
	dc.l	null,r_fen_ssp		
	
	*------------------------*
	* GOTO 	(An)
	*------------------------*
	;dc	$030a			;alt ctrl 9
	;dc.l	null,r_fen_pc		
	dc	$030B			;alt ctrl 0
	dc.l	null,r_fen_a0_double		
	dc	$0302			;alt ctrl 1
	dc.l	null,r_fen_a1_double		
	dc	$0303			;alt ctrl 2
	dc.l	null,r_fen_a2_double		
	dc	$0304			;alt ctrl 3
	dc.l	null,r_fen_a3_double		
	dc	$0305			;alt ctrl 4
	dc.l	null,r_fen_a4_double		
	dc	$0306			;alt ctrl 5
	dc.l	null,r_fen_a5_double		
	dc	$0307			;alt ctrl 6
	dc.l	null,r_fen_a6_double		
	dc	$0308			;alt ctrl 7
	dc.l	null,r_fen_a7_double		
	dc	$0309			;alt ctrl 8
	dc.l	null,r_fen_ssp_double		
	
	
	*------------------------*
	* GOTO 	Dn
	*------------------------*
	dc	$050b			;shift ctrl 0
	dc.l	null,r_fen_d0		
	dc	$0502			;shift ctrl 1
	dc.l	null,r_fen_d1		
	dc	$0503			;shift ctrl 2
	dc.l	null,r_fen_d2		
	dc	$0504			;shift ctrl 3
	dc.l	null,r_fen_d3		
	dc	$0505			;shift ctrl 4
	dc.l	null,r_fen_d4		
	dc	$0506			;shift ctrl 5
	dc.l	null,r_fen_d5		
	dc	$0507			;shift ctrl 6
	dc.l	null,r_fen_d6		
	dc	$0508			;shift ctrl 7
	dc.l	null,r_fen_d7		
	
	
	
	*-------------------------*
	* changement type fenetre
	*-------------------------*
	dc.w	$214			;alt T
	dc.l	r_type,r_type		

	
	dc	$006d			;1	pav num
	dc.l	r_type,r_type
	dc	$006e			;2	pav num
	dc.l	r_type,r_type
	dc	$006f			;3	pav num
	dc.l	r_type,r_type
	dc	$006a			;4	pav num
	dc.l	r_type,r_type
	dc	$006b			;5	pav num
	dc.l	r_type,r_type
	dc	$006c			;6	pav num
	dc.l	r_type,r_type
	dc	$0067			;7	pav num
	dc.l	r_type,r_type
	dc	$0068			;8	pav num
	dc.l	r_type,r_type
	
	dc	$016d			;ctrl 1	pav num
	dc.l	r_type,r_type
	dc	$016e			;ctrl 2	pav num
	dc.l	r_type,r_type
	dc	$016f			;ctrl 3	pav num
	dc.l	r_type,r_type
	dc	$016a			;ctrl 4	pav num
	dc.l	r_type,r_type
	dc	$016b			;ctrl 5	pav num
	dc.l	r_type,r_type
	dc	$016c			;ctrl 6	pav num
	dc.l	r_type,r_type
	dc	$0167			;ctrl 7	pav num
	dc.l	r_type,r_type
	dc	$0168			;ctrl 8	pav num
	dc.l	r_type,r_type

	dc	$0163
	dc.l	SET_MEM_P,null		;ctrl (
	dc	$0164
	dc.l	SET_MEM_X,null		;ctrl )
	dc	$0165
	dc.l	SET_MEM_Y,null		;ctrl /
	
	
	*-------------------------*
	* D‚placements des fenetres
	*-------------------------*
	dc	$248			;alt 
	dc.l	MOVE_UP,MOVE_UP		
	dc	$250			;alt 
	dc.l	MOVE_DOWN,MOVE_DOWN	
	dc	$24b			;alt 
	dc.l	MOVE_LEFT,MOVE_LEFT	
	dc	$24d			;alt 
	dc.l	MOVE_RIGHT,MOVE_RIGHT	

	
	
	*-------------------------*
	* redimensionnement des fenetres
	*-------------------------*
	dc	$648			;alt shift 
	dc.l	SIZE_Y_DEC,SIZE_Y_DEC
	dc	$650			;alt shift 
	dc.l	SIZE_Y_INC,SIZE_Y_INC
	dc	$64b			;alt shift 
	dc.l	SIZE_X_DEC,SIZE_X_DEC
	dc	$64d			;alt shit 
	dc.l	SIZE_X_INC,SIZE_X_INC
	
	*------------------------*
	* Activation du fenetre 
	* par son num‚ro
	*------------------------*
	dc	$0270
	dc.l	GOTO0,GOTO0		;alt 0
	dc	$026d
	dc.l	GOTO1,GOTO1		;alt 1
	dc	$026e
	dc.l	GOTO2,GOTO2		;alt 2
	dc	$026f
	dc.l	GOTO3,GOTO3		;alt 3
	dc	$026a
	dc.l	GOTO4,GOTO4		;alt 4
	dc	$026b
	dc.l	GOTO5,GOTO5		;alt 5
	dc	$026c
	dc.l	GOTO6,GOTO6		;alt 6
	dc	$0267
	dc.l	GOTO7,GOTO7		;alt 7
	dc	$0268
	dc.l	GOTO8,GOTO8		;alt 8
	dc	$0269
	dc.l	GOTO9,GOTO9		;alt 9

	dc	$0670
	dc.l	GOTO10,GOTO10		;shift alt 0
	dc	$066d
	dc.l	GOTO11,GOTO11		;shift alt 1
	dc	$066e
	dc.l	GOTO12,GOTO12		;shift alt 2
	dc	$066f
	dc.l	GOTO13,GOTO13		;shift alt 3
	dc	$066a
	dc.l	GOTO14,GOTO14		;shift alt 4
	dc	$066b
	dc.l	GOTO15,GOTO15		;shift alt 5
	dc	$066c
	dc.l	GOTO16,GOTO16		;shift alt 6
	dc	$0667
	dc.l	GOTO17,GOTO17		;shift alt 7
	dc	$0668
	dc.l	GOTO18,GOTO18		;shift alt 8
	dc	$0669
	dc.l	GOTO19,GOTO19		;shift alt 9

	dc	$0370
	dc.l	GOTO20,GOTO20		;alt+ctrl 0
	dc	$036d
	dc.l	GOTO21,GOTO21		;alt+ctrl 1
	dc	$036e
	dc.l	GOTO22,GOTO22		;alt+ctrl 2
	dc	$036f
	dc.l	GOTO23,GOTO23		;alt+ctrl 3
	dc	$036a
	dc.l	GOTO24,GOTO24		;alt+ctrl 4
	dc	$036b
	dc.l	GOTO25,GOTO25		;alt+ctrl 5
	dc	$036c
	dc.l	GOTO26,GOTO26		;alt+ctrl 6
	dc	$0367
	dc.l	GOTO27,GOTO27		;alt+ctrl 7
	dc	$0368
	dc.l	GOTO28,GOTO28		;alt+ctrl 8
	dc	$0369
	dc.l	GOTO29,GOTO29		;alt+ctrl 9

		
	
	
	dc	0

	TEXT

null
	rts




temp_reel

	bsr	set_all_flags
	bsr	AFFICHE

	rts

*------------------------------------------------------------------------------
* affiche le directory courant dans une fenetre zoom‚e
*------------------------------------------------------------------------------
affiche_directory
	
	CENT_PROS
	
	
	move.l	ZOOM_WINDOW,d0
	beq.s	GO_DIRECTORY
	bsr	QUIT_ZOOM	
GO_DIRECTORY
	xref	ACTIVE_WINDOW,SAVE_ACTIVE
	move.l	ACTIVE_WINDOW,SAVE_ACTIVE

	*------------------*
	* recherche une fenetre libre
	*------------------*
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.SCAN	tst.l	(a0)+
	bne.s	.SCAN
	subq	#4,a0
	
	move.l	a0,d0
	sub.l	#WINDOW_LIST,d0
	asr.l	#2,d0		;no du slot

	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a1
	move.l	a1,(a0)
	move.l	a1,ACTIVE_WINDOW
	move	#T_INFO,type(a1)
	
	bsr	ZOOM
	
	
	bsr	CLS_SCREEN
	
	bsr	GEN_DIR

	move.l	ACTIVE_WINDOW,a0				
	bsr	TITRE		
	bsr	CORP
	bsr	BOTTOM

	xref	get_key
.WAIT	
	bsr	get_key
	cmp.b	#1,d0
	bne.s	.WAIT

	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre
	bsr	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW
	
	REST_PROS
	rts
	


GEN_DIR
	*-----------------*
	* je ne change pas la DTA
	* car c'est celle de STEPH en place...
	*-----------------*
	xref	buf_dta
	pea	buf_dta
	GEM	Fsetdta	


	lea	ASCII_BUF,a6
	
	*-----------------*
	* le chemin courant
	*-----------------*
	
	move	COL_NOR,ATTRIBUTE
	bsr	CURRENT

	bsr	REPS		
		
	move	#$8000,(a6)+
	
	REST_PROS
	rts


*------------------------------------------------------------------------------
* affiche les repertoires
* et les autres fichiers puisque ya bug ..
*------------------------------------------------------------------------------
REPS
	move	#$10,-(sp)	;dir
	pea	.name
	GEM	Fsfirst
	tst.l	d0
	bmi.s	.FIN
	
	bra.s	.FILE
.LOOP
	GEM	Fsnext	
	tst.l	d0
	bmi.s	.FIN
	
.FILE
	move	COL_NOR,ATTRIBUTE

	move.b	buf_dta+21,d0
	cmp	#$10,d0
	bne.s	.NODIR
	move	COL_ADR,ATTRIBUTE
	move.b	ATTRIBUTE,(a6)+
	move.b	#'',(a6)+
.NODIR
	move.l	a6,a5
	add	#(12+2)*2,a5
	lea	buf_dta+30,a0
	col_cpy	a0,a6
	move	#' ',d0

.FILL	cmp.l	a5,a6
	bge.s	.OK0	
	move	d0,(a6)+
	bra.S	.FILL

.OK0	
	move.l	buf_dta+26,d0
	move	COL_REG,ATTRIBUTE
	bsr	AFF_DEC
	
	move	#$d,(a6)+
	
	bra.s	.LOOP			
.FIN	rts
	
.name	dc.b	'*.*',0
	
AFF_DEC::
;le nb ds d0
;on le met en (a6)+

	move	#8-1,d7
	move.l	#10000000,d3
	moveq	#0,d2
	move	ATTRIBUTE,d4
LOOP
	divul.l	d3,d1:d0
	divu.l	#10,d3
	tst	d0
	bne.s	.OK0
	tst	d2
	bne.s	.OK0
	move	#' ',(a6)+
	bra.s	.NXT		
	
.OK0
	st	d2
	add.b	#'0',d0
	move.b	d0,d4
	move	d4,(a6)+
		
.NXT	move.l	d1,d0
	dbra	d7,LOOP
	rts
					

	
*------------------------------------------------------------------------------
* affiche le chemin courant 
*------------------------------------------------------------------------------
CURRENT
	GEM	Dgetdrv
	move	d0,d1
	add.b	#'A',d0
	
	move.b	ATTRIBUTE,(a6)+
	move.b	d0,(a6)+

	move.b	ATTRIBUTE,(a6)+
	move.b	#':',(a6)+
		
	addq	#1,d1		;attention ca commence … 0
	move	d1,-(sp)
	pea	WORK_BUF
	GEM	Dgetpath
	
	lea	WORK_BUF,a0
	tst.b	(a0)	
	bne.s	.NOADDSLASH
	move.b	ATTRIBUTE,(a6)+
	move.b	#'\',(a6)+
.NOADDSLASH
	col_cpy	a0,a6

	move	#$d,(a6)+
	
	rts
*------------------------------------------------------------------------------
			
	
	
	
	
	
	
	
	
			




*------------------------------------------------------------------------------
* next source
* passe une fenetre de source au source suivant
*------------------------------------------------------------------------------
next_source
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	cmp	#T_DSP_SRC,d0
	bne.s	.FIN

	*----------------------*	
	* recherche le source actuel
	*----------------------*	

	move.l	Src_adr(a0),d0
	sub.l	#DSP_SOURCE_TABLE,d0
	divu	#Size_src,d0	

	*---------------------------*
	* ds d0 on a le no du source courant
	*---------------------------*
	
	addq	#1,d0		;passe au suivant
	cmp	DSP_NB_SOURCES,d0
	blt	.OK0
	clr	d0
.OK0	
	mulu	#Size_src,d0
	lea	(DSP_SOURCE_TABLE,d0.l),a1
	
	move.l	a1,Src_adr(a0)	;!!	
	
	;move.l	ligne_ptr(a1),ptr_tab_ligne(a0)
	move.l	nb_ligne(a1),max_ligne(a0)
	move	#1,Line_nb(a0)
	st	flag_aff(a0)	
	
.FIN	rts

next_source_40
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	cmp	#T_M40_SRC,d0
	bne.s	.FIN

	*----------------------*	
	* recherche le source actuel
	*----------------------*	

	move.l	Src_adr(a0),d0
	sub.l	#M40_SOURCE_TABLE,d0
	divu	#Size_src,d0	

	*---------------------------*
	* ds d0 on a le no du source courant
	*---------------------------*
	
	addq	#1,d0		;passe au suivant
	cmp	M40_NB_SOURCES,d0
	blt	.OK0
	clr	d0
.OK0	
	mulu	#Size_src,d0
	lea	(M40_SOURCE_TABLE,d0.l),a1
	
	move.l	a1,Src_adr(a0)	;!!	
	
	;move.l	ligne_ptr(a1),ptr_tab_ligne(a0)
	move.l	nb_ligne(a1),max_ligne(a0)
	move	#1,Line_nb(a0)
	st	flag_aff(a0)	
	
.FIN	rts


*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* d‚zoome une fenetre zoom‚e 
*------------------------------------------------------------------------------
QUIT_ZOOM::
	move.l	ZOOM_WINDOW,d0
	beq.s	.ACTIVE
	
.COUPE
	move.l	d0,a0
	clr.l	ZOOM_WINDOW
	move	ZOOM_X1,W_X1(a0)
	move	ZOOM_Y1,W_Y1(a0)
	move	ZOOM_Largeur,Largeur(a0)
	move	ZOOM_Hauteur,Hauteur(a0)
	bsr	CLS_SCREEN
	bsr	set_all_flags
.ACTIVE
	rts
		
*------------------------------------------------------------------------------
* ZOOM d'une fenetre
* et d‚zoome (flip-flap)
*------------------------------------------------------------------------------
ZOOM::
	move.l	ZOOM_WINDOW,d0
	beq.s	.ACTIVE
.COUPE
	move.l	d0,a0
	clr.l	ZOOM_WINDOW
	move	ZOOM_X1,W_X1(a0)
	move	ZOOM_Y1,W_Y1(a0)
	move	ZOOM_Largeur,Largeur(a0)
	move	ZOOM_Hauteur,Hauteur(a0)

	bsr	CLS_SCREEN
	
	bsr	set_all_flags
	bra.s	.FIN
		
	
.ACTIVE	
	move.l	ACTIVE_WINDOW,a0
	move.l	a0,ZOOM_WINDOW
	move	W_X1(a0),ZOOM_X1
	move	W_Y1(a0),ZOOM_Y1
	move	Largeur(a0),ZOOM_Largeur
	move	Hauteur(a0),ZOOM_Hauteur
	
	clr	W_X1(a0)
	move	#1,W_Y1(a0)
	move	RESO_X,Largeur(a0)
	move	RESO_Y,d0
	subq	#2,d0
	move	d0,Hauteur(a0)
	st	flag_aff(a0)
.FIN	rts
	

*------------------------------------------------------------------------------
	
	
*------------------------------------------------------------------------------
* Routines pour activer directement une fenetre
* alt + num  de 0 … 9
* alt+shift  de 10 … 19
* alt+ctrl   de 20 … 29
*------------------------------------------------------------------------------
GOTO0	move	#0,d0
	bra	GOTO
GOTO1	move	#4,d0
	bra	GOTO
GOTO2	move	#8,d0
	bra	GOTO
GOTO3	move	#12,d0
	bra	GOTO
GOTO4	move	#16,d0
	bra	GOTO
GOTO5	move	#20,d0
	bra	GOTO
GOTO6	move	#24,d0
	bra	GOTO
GOTO7	move	#28,d0
	bra	GOTO
GOTO8	move	#32,d0
	bra	GOTO
GOTO9	move	#36,d0
	bra.s	GOTO
GOTO10	move	#40,d0
	bra.s	GOTO
GOTO11	move	#44,d0
	bra.s	GOTO
GOTO12	move	#48,d0
	bra.s	GOTO
GOTO13	move	#52,d0
	bra.s	GOTO
GOTO14	move	#56,d0
	bra.s	GOTO
GOTO15	move	#60,d0
	bra.s	GOTO
GOTO16	move	#64,d0
	bra.s	GOTO
GOTO17	move	#68,d0
	bra.s	GOTO
GOTO18	move	#72,d0
	bra.s	GOTO
GOTO19	move	#76,d0
	bra.s	GOTO
GOTO20	move	#80,d0
	bra.s	GOTO
GOTO21	move	#84,d0
	bra.s	GOTO
GOTO22	move	#88,d0
	bra.s	GOTO
GOTO23	move	#92,d0
	bra.s	GOTO
GOTO24	move	#96,d0
	bra.s	GOTO
GOTO25	move	#100,d0
	bra.s	GOTO
GOTO26	move	#104,d0
	bra.s	GOTO
GOTO27	move	#108,d0
	bra.s	GOTO
GOTO28	move	#112,d0
	bra.s	GOTO
GOTO29	move	#116,d0
	;bra.s	GOTO
	
GOTO	
	move.l	(WINDOW_LIST,d0.w),d1
	beq.s	.open
	move.l	d1,d0
	move.l	ACTIVE_WINDOW,a0
	st	flag_aff(a0)
	move.l	d0,ACTIVE_WINDOW
	move.l	d0,a0
	st	flag_aff(a0)
	rts
.open
	*--------------*
	* on a essay‚ d'activer une fenetre inexistante
	* on la cr‚e...
	*--------------*
	lsr	#2,d0
	bsr.l	NEW_WINDOW
	tst.l	a1
	beq.s	.RIEN
	move.l	ACTIVE_WINDOW,a2
	move	type(a2),type(a1)
	clr.l	ptr_expr(a1)
	move	mem_type(a2),mem_type(a1)
	move.l	adr_debut(a2),adr_debut(a1)
	clr.l	start_col(a1)
	st	flag_aff(a1)
	st	flag_aff(a2)
	clr.l	max_ligne(a1)
	move	#4,Tab_Value(a1)
	
	move.l	a1,ACTIVE_WINDOW	;la nvlle fenetre est active
.RIEN
	rts
	



*------------------------------------------------------------------------------
* SET MEM DSP
* passe la fenetre DSP pour le nvx type de m‚moire 
*------------------------------------------------------------------------------
SET_MEM_P
	move.l	ACTIVE_WINDOW,a0
	cmp	#T_H24,type(a0)
	beq.s	.OK
	cmp	#T_HEXASCII24,type(a0)
	beq.s	.OK
	cmp	#T_FRAC24,type(a0)
	bne.s	.FIN
	*--------------*
	* type non valide
	*--------------*
.OK	move	#MEM_P,mem_type(a0)
	st	flag_aff(a0)
.FIN	rts

SET_MEM_X
	move.l	ACTIVE_WINDOW,a0
	cmp	#T_H24,type(a0)
	beq.s	.OK
	cmp	#T_HEXASCII24,type(a0)
	beq.s	.OK
	cmp	#T_FRAC24,type(a0)
	bne.s	.FIN
	*--------------*
	* type non valide
	*--------------*
.OK	move	#MEM_X,mem_type(a0)
	st	flag_aff(a0)
.FIN	rts

SET_MEM_Y
	move.l	ACTIVE_WINDOW,a0
	cmp	#T_H24,type(a0)
	beq.s	.OK
	cmp	#T_HEXASCII24,type(a0)
	beq.s	.OK
	cmp	#T_FRAC24,type(a0)
	bne.s	.FIN
	*--------------*
	* type non valide
	*--------------*
.OK	move	#MEM_Y,mem_type(a0)
	st	flag_aff(a0)
.FIN	rts
	



*------------------------------------------------------------------------------
* UNLOCK de la fenetre active
*------------------------------------------------------------------------------
UNLOCK
	lea	WINDOW_LIST,a0
	move	#31,d7
	move.l	ACTIVE_WINDOW,d0
.LOOP	cmp.l	(a0)+,d0
	beq.s	.OK00
	dbra	d7,.LOOP	
	bra	.FIN
.OK00	move.l	-(a0),a0
	clr.l	ptr_expr(a0)
	bsr	set_all_flags
.FIN	rts
	


*------------------------------------------------------------------------------
* LOCK WIN : saisie de l'expression
* et affectation ds le buffer expression
*------------------------------------------------------------------------------
LOCK_WIN
	
	xref	GET_CHAINE
	
	move.l	#MES_LOCK,a0
	bsr	GET_CHAINE
	tst.b	d0
	beq.s	.FIN

	move.l	a2,a0		;a2 = chaine utile
	bsr.l	eval			
	tst.b	d2
	bne	LOCK_WIN
	
	move.l	a2,a3	

	
	xref	WINDOW_LIST
	lea	WINDOW_LIST,a0
	move	#31,d7
	move.l	ACTIVE_WINDOW,d0
.LOOP	cmp.l	(a0)+,d0
	beq.s	.OK00
	dbra	d7,.LOOP	
.OK00
	move.l	-(a0),a1	
	sub.l	#WINDOW_LIST,a0
	
	move.l	a0,d0
	lsr.l	#2,d0
	lsl.l	#8,d0

	;xref	BUFFER_EXPR
	lea	(BUFFER_EXPR.l,d0.l),a0
	move.l	a0,ptr_expr(a1)
	
.COP	move.b	(a2)+,(a0)+
	bne.s	.COP
	

	*----------------------*
	* affiche l'expression
	*----------------------*
	xref	convert_inv
	moveq	#0,d0
	move.l	a3,a0
	bsr	convert_inv	;a0 =ptr chaine
	move.l	a3,MESSAGE_ADR
	bsr	PETIT_MESSAGE
	move.l	a3,MESSAGE_ADR

	bsr	set_all_flags
	
.FIN	rts
	
	



*------------------------------------------------------------------------------
* ouverture d'une nouvelle fenetre
*------------------------------------------------------------------------------
NEW_WIN_DSP
	tst.l	ZOOM_WINDOW		;interdit quand on est en zoom
	bne.s	.FIN
	moveq	#-1,d0		
	bsr.l	NEW_WINDOW
	tst.l	a1
	beq.s	.RIEN
	move.l	ACTIVE_WINDOW,a2

	move	type(a2),type(a1)
	clr.l	ptr_expr(a1)
	move	mem_type(a2),mem_type(a1)
	move.l	adr_debut(a2),adr_debut(a1)
	move	nb_colonnes(a2),nb_colonnes(a1)
	clr.l	start_col(a1)
	st	flag_aff(a1)
	st	flag_aff(a2)
	move.l	Src_adr(a2),Src_adr(a1)
	move	#1,Line_nb(a1)
	move.l	max_ligne(a2),max_ligne(a1)
	move	Tab_Value(a2),Tab_Value(a1)
			
	clr.l	Tab_adr_debut(a1)
	clr.l	Tab_adr_debut+4(a1)

	
	move.l	a1,ACTIVE_WINDOW	;la nvlle fenetre est active
	
.RIEN	
.FIN	rts
	
	*-----------------*
	
NEW_WIN_40
	tst.l	ZOOM_WINDOW		;interdit quand on est en zoom
	bne.s	.FIN

	moveq	#-1,d0		
	bsr.l	NEW_WINDOW
	tst.l	a1
	beq.s	.RIEN
	move.l	ACTIVE_WINDOW,a2

	move	type(a2),type(a1)
	clr.l	ptr_expr(a1)
	clr	mem_type(a1)
	move.l	adr_debut(a2),adr_debut(a1)
	move	nb_colonnes(a2),nb_colonnes(a1)
	clr.l	start_col(a1)
	st	flag_aff(a1)
	st	flag_aff(a2)
	move.l	Src_adr(a2),Src_adr(a1)
	move	#1,Line_nb(a1)
	move.l	max_ligne(a2),max_ligne(a1)
	move	Tab_Value(a2),Tab_Value(a1)
			
	clr.l	Tab_adr_debut(a1)
	clr.l	Tab_adr_debut+4(a1)


	move.l	a1,ACTIVE_WINDOW	;la nvlle fenetre est active
.RIEN	
.FIN	rts
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* coupe la fenetre en deux horizontalement
*------------------------------------------------------------------------------
SPLIT_WIN_H
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#6,Hauteur(a0)
	blt	.FIN
	
	*-----------------*
	* recherche un slot libre
	*-----------------*
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP0	move.l	(a1)+,d0
	beq.s	.OK
	dbra	d7,.LOOP0
	bra	.FIN		;plus de slot libre
.OK	
	subq	#4,a1
	move.l	a1,d0
	sub.l	#WINDOW_LIST,d0
	lsr.l	#2,d0
	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a2	;ptr new WIN
	move.l	a2,(a1)			;place Win
	


	*-----------------*
	* on cree un double de la fenetre
	*-----------------*
	move	type(a0),type(a2)
	clr.l	ptr_expr(a2)
	move	mem_type(a0),mem_type(a2)
	move.l	adr_debut(a0),adr_debut(a2)
	clr.l	start_col(a2)
	clr.l	max_ligne(a2)	
	st	flag_aff(a2)
	st	flag_aff(a0)
	move	W_X1(a0),W_X1(a2)	;horiz= meme X1 meme Largeur
	move	Largeur(a0),Largeur(a2)

	moveq	#0,d1
	move	Hauteur(a0),d0
	asr	d0		;d0=nouvelle hauteur
	addx	d1,d1
	add	d0,d1		;ancienne hauteur arrondie

	move	d1,Hauteur(a0)
	move	d0,Hauteur(a2)
	add	W_Y1(a0),d1
	move	d1,W_Y1(a2)

	move.l	a2,ACTIVE_WINDOW
	
	
.FIN
	rts
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* coupe la fenetre en deux verticalement
*------------------------------------------------------------------------------
SPLIT_WIN_V
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#8,Largeur(a0)
	blt	.FIN
	
	*-----------------*
	* recherche un slot libre
	*-----------------*
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP0	move.l	(a1)+,d0
	beq.s	.OK
	dbra	d7,.LOOP0
	bra	.FIN		;plus de slot libre
.OK	
	subq	#4,a1
	move.l	a1,d0
	sub.l	#WINDOW_LIST,d0
	lsr.l	#2,d0
	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a2	;ptr new WIN
	move.l	a2,(a1)			;place Win
	


	*-----------------*
	* on cree un double de la fenetre
	*-----------------*
	move	type(a0),type(a2)
	clr.l	ptr_expr(a2)
	move	mem_type(a0),mem_type(a2)
	move.l	adr_debut(a0),adr_debut(a2)
	clr.l	start_col(a2)
	clr.l	max_ligne(a2)	
	st	flag_aff(a2)
	st	flag_aff(a0)



	move	W_Y1(a0),W_Y1(a2)	;vert= meme Y1 meme Hauteur
	move	Hauteur(a0),Hauteur(a2)

	moveq	#0,d1
	move	Largeur(a0),d0
	asr	d0		;d0=nouvelle hauteur
	addx	d1,d1
	add	d0,d1		;ancienne hauteur arrondie

	move	d1,Largeur(a0)
	move	d0,Largeur(a2)
	add	W_X1(a0),d1
	move	d1,W_X1(a2)
	
	
	move.l	a2,ACTIVE_WINDOW
.FIN
	rts
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* fusionne la fenetre active avec celle qui est dessous ou dessus
* les fenetres doivent etre de meme largeur et avoir une arrete en commun
*------------------------------------------------------------------------------
FUSE_WIN_H
	move.l	ACTIVE_WINDOW,a0
	*-----------------*
	* recherche la fenetre imm‚diatement en dessous
	* de meme largeur
	*-----------------*
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	add	Hauteur(a0),d1
	swap	d0
	move	d1,d0
	move	Largeur(a0),d1	
	
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP0	move.l	(a1)+,d2
	beq.s	.NXT
	move.l	d2,a2
	cmp.l	W_X1(a2),d0
	bne.s	.NXT
	cmp	Largeur(a2),d1
	beq.s	.OK
.NXT	dbra	d7,.LOOP0
	
	*-----------------*
	* pas de fenetre qui correspond
	* ->on recherche la fenetre imm‚diatement au dessus
	*-----------------*
	
	move.l	W_X1(a0),d0
	move	Largeur(a0),d1
	
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP1	move.l	(a1)+,d2
	beq.s	.NXT1
	move.l	d2,a2
	cmp	Largeur(a2),d1
	bne.s	.NXT1

	move.l	W_X1(a2),d2
	add	Hauteur(a2),d2
	cmp.l	d2,d0
	beq.s	.OK1
.NXT1	dbra	d7,.LOOP1
	bra.S	.FIN
.OK1
	move	W_X1(a2),W_X1(a0)
	move	W_Y1(a2),W_Y1(a0)
	
	
.OK	move	Hauteur(a2),d0
	add	d0,Hauteur(a0)
	clr.l	ptr_expr(a2)
	clr.l	-(a1)		;d‚gage la fenetre
	st	flag_aff(a0)	

.FIN	rts
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* fusionne la fenetre active avec celle qui est … gauche ou … droite
* les hauteurs doivent etre ‚gales !!!
*------------------------------------------------------------------------------
FUSE_WIN_V
	move.l	ACTIVE_WINDOW,a0
	
	*-----------------*
	* recherche la fenetre imm‚diatement … droite
	*-----------------*
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	add	Largeur(a0),d0
	swap	d0
	move	d1,d0
	move	Hauteur(a0),d1	
	
	
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP0	move.l	(a1)+,d2
	beq.s	.NXT
	move.l	d2,a2
	cmp.l	W_X1(a2),d0
	bne.s	.NXT
	cmp	Hauteur(a2),d1
	beq.s	.OK
.NXT	dbra	d7,.LOOP0
	
	*-----------------*
	* pas de fenetre qui correspond
	* on recherche la fenetre imm‚diatement a gauche
	*-----------------*

	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	swap	d0
	move	d1,d0
	move	Hauteur(a0),d1
	
	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP1	move.l	(a1)+,d2
	beq.s	.NXT1
	move.l	d2,a2

	cmp	Hauteur(a2),d1
	bne.s	.NXT1
	move	W_X1(a2),d2
	add	Largeur(a2),d2
	swap	d2
	move	W_Y1(a2),d2
	cmp.l	d0,d2
	beq.s	.OK1
.NXT1	dbra	d7,.LOOP1
	bra.s	.FIN
.OK1
	move	W_X1(a2),W_X1(a0)	
	move	W_Y1(a2),W_Y1(a0)
	
	
.OK	move	Largeur(a2),d0
	add	d0,Largeur(a0)
	clr.l	-(a1)		;d‚gage la fenetre
	st	flag_aff(a0)	

.FIN	rts
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* fermeture d'une fenetre
*------------------------------------------------------------------------------
CLOSE_WIN::
	tst.l	ZOOM_WINDOW		;interdit quand on est en zoom
	bne	.FIN

	xref	WINDOW_LIST
	*---------------*
	* d'abord on compte le
	* nombre de fenetres
	*---------------*
	lea	WINDOW_LIST,a0
	move	#31,d7
	moveq	#0,d0
	moveq	#0,d1
.CNT	tst.l	(a0)+
	sne	d2
	asr	d2
	addx	d1,d0
	dbra	d7,.CNT

	cmp	#1,d0
	ble	.FIN		;si il ne reste qu'une fenetre...	
				; on la garde !!!!!

	move.l	ACTIVE_WINDOW,d0
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	cmp.l	(a0)+,d0
	dbeq	d7,.LOOP
	tst	d7
	bmi.s	.FIN		;existe pas ?? -> bug bug
.OK	clr.l	-(a0)
	addq	#4,a0
.OK0	tst.l	(a0)+
	dbne	d7,.OK0
	tst	d7
	bpl.s	.OK01
	lea	WINDOW_LIST,a0
	move	#31,d7
	bra.s	.OK0	
.OK01
	move.l	-(a0),ACTIVE_WINDOW
	tst.l	ZOOM_WINDOW
	beq.s	.SETF
	clr.l	ZOOM_WINDOW
.SETF	bsr	set_all_flags
	bsr	CLS_SCREEN	
.FIN
	rts
	

;------------------------------------------------------------------------------
;affiche une ligne de texte avec choix des coordonn‚es
;------------------------------------------------------------------------------
	cnop	0,16
AFF_XY::
	xref	VIDEO_SYSTEME
	cmp.l	#"_S3V",VIDEO_SYSTEME
	beq	AFF_XY_TC

	xref	TAB_X,TAB_Y,LOG
; a0=ligne … afficher (terminee par 0)
	movem.l	d0-a6,-(sp)
	lea	LINE,a0
	move	(a0)+,d6	;X
	move	(a0)+,d7	;Y
	move.l	LOG,a3
	add.l	(TAB_Y.l,d7.w*4),a3
.CAR	
	move.w	(a0)+,d1
	bmi	.FIN
.NO_INV	
	move.l	a3,a2
	add.w	(TAB_X.l,d6.w*2),a2
	move	d1,d2
	and	#$ff,d1
	ifeq	(size_font=8)
	add.l	d1,d1		;*2 pour la fonte de 16 car d1.w*16 n'existe pas
	endc
	lsr.w	#8,d2
	lea	(FONT.l,d1.w*8),a1
	
	ifeq	(size_font=8)
	moveq	#16-1,d5
	else
	moveq	#8-1,d5
	endc			;hauteur de la lettre

	btst	#6,d2
	bne.s	.OKINV
	and	#$f,d2
	move	(TAB_AFF,d2.w*2),d2
	jsr	(TAB_AFF,pc,d2)
	addq	#1,d6
	bra	.CAR
.OKINV	and	#$f,d2
	move	(TAB_AFF_INV,d2.w*2),d2
	jsr	(TAB_AFF_INV,pc,d2)
	addq	#1,d6
	bra	.CAR
.FIN	movem.l	(sp)+,d0-a6
	rts

DRAW_S3
	include	AFF_TC.S

;------------------------------------------------------------------------------
	include	TABAFF.S
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; affiche une fenetre titre, contenu, bas
;------------------------------------------------------------------------------
EXPAND_WINDOW::
	movem.l	d0-a6,-(sp)
;*** on affiche une fenetre...
	move	type(a0),d0
	cmp	#T_dernier,d0
	ble.s	.M40
	cmp	#T_dsp_dernier,d0
	ble.s	.DSP
	bra	.FIN
.DSP	move	COL_DSP,COL_FEN
	tst	ACTIF_DSP
	bne.s	.OK	
	bra	EXPAND_INACTIVE		
.M40
	move	COL_40,COL_FEN
	tst	ACTIF_40
	bne.s	.OK	
	bra	EXPAND_INACTIVE		

.OK	jsr	([TAB_GEN.l,d0.w*4])
	bsr	TITRE		
	bsr	CORP
	bsr	BOTTOM
.FIN	movem.l	(sp)+,d0-a6
	rts
EXPAND_INACTIVE	
	*------------------*
	* le proc concern‚
	* n'est pas dispo...
	*------------------*
	move	#rouge*256,COL_FEN	
	
	lea	ASCII_BUF,a6
	move	#' ',d1
	move	#10000-1,d7
.COP	move	d1,(a6)+
	dbra	d7,.COP
			
	bsr	TITRE		
	bsr	CORP_VIDE
	bsr	BOTTOM
.FIN	movem.l	(sp)+,d0-a6
	rts
	


CORP_VIDE
	move	Largeur(a0),d7
	subq	#3,d7		
	bmi	.FIN		;largeur<3 =>header corrompu...
	lea	LINE+4,a6
	move.b	COL_FEN,(a6)+
	move.b	#'Ÿ',d0		
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA0
	move.b	#'º',d0
.OKA0	move.b	d0,(a6)+

.FILLX	move	#' ',(a6)+
	dbra	d7,.FILLX

.DRAW	move.b	COL_FEN,(a6)+
	move.b	#'Ÿ',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA1
	move.b	#'º',d0
.OKA1	move.b	d0,(a6)+
	move	#$8000,(a6)+
	
	move	Hauteur(a0),d0
	subq	#2,d0
	move	d0,-(sp)
.LOOP	bsr	AFF_XY
	addq	#1,LINE+2
	subq	#1,(sp)
	bne.s	.LOOP
	addq	#2,sp
.FIN	rts	
	
;------------------------------------------------------------------------------
CORP::
	lea	ASCII_BUF,a1

;premierement on peut sauter X lignes	
	move	start_ligne(a0),d6
	subq	#1,d6
	bmi.s	.NOJL
.L009	move	(a1)+,d0	
	bmi	.END_BUF
	cmp.b	#$d,d0
	beq.s	.OK009
	bra.s	.L009
.OK009	dbra	d6,.L009
.NOJL	
	
	move	Hauteur(a0),d6
	add	W_Y1(a0),d6
	subq	#1,d6		;Ycou>Ymax ? =>FIN
.LINE	cmp	LINE+2,d6
	ble	.FIN
	move	Largeur(a0),d7
	subq	#3,d7		
	bmi	.FIN		;largeur<3 =>header corrompu...
	lea	LINE+4,a6
	move.b	COL_FEN,(a6)+
	move.b	#'Ÿ',d0		
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA0
	move.b	#'º',d0
.OKA0	move.b	d0,(a6)+
;ici on peut sauter X colonnes...
	move	start_col(a0),d1
	subq	#1,d1
	bmi.s	.LOOP
.L008	move	(a1)+,d2
	bmi	.FILLX
	cmp.b	#$d,d2
	beq	.FILLX		;ya qu'un CR sur la lgne...
	cmp.b	#9,d2	
	beq	.JMPTAB		; la c'est chiant !!!!
	dbra	d1,.L008


.LOOP	move	(a1)+,d0
	bmi	.END_BUF	;0 = fin de chaine
	btst	#13,d0
	bne.S	.OK		;affichage binaire
	cmp.b	#$d,d0		
	beq.s	.FILLX		;CR = idem
	cmp.b	#$a,d0
	beq.s	.LOOP		;LF est ignor‚
	cmp.b	#9,d0
	beq.s	.TAB		;TAB
.OK	move	d0,(a6)+
	dbra	d7,.LOOP
;pointe la fin de la ligne source
.SC0	move	(a1)+,d0
	bmi.s	.END_BUF
	cmp.b	#$d,d0
	bne.s	.SC0
	bra.s	.DRAW		
.FILLX	move	#' ',(a6)+
	dbra	d7,.FILLX

.DRAW	move.b	COL_FEN,(a6)+
	move.b	#'Ÿ',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA1
	move.b	#'º',d0
.OKA1	move.b	d0,(a6)+
	move	#$8000,(a6)+
	bsr	AFF_XY
	addq	#1,LINE+2
	tst	-2(a1)
	bpl	.LINE
	subq	#2,a1		;on a atteint la fin du source 
	bra	.LINE		;recale tjrs le ponteur sur ce marqueur 
.FIN	rts	
		
.END_BUF	
	;clr	ScrollD_flag(a0)
	subq	#2,a1
	tst	d7
	bmi	.DRAW	
	
	bra	.FILLX
	
.TAB	
	lea	TAB_LIST,a5
	move	Largeur(a0),d4
	sub	d7,d4
	sub	#4+6,d4			
.SEA	move	(a5)+,d3
	cmp	d3,d4
	bgt.s	.SEA
	sub	d4,d3
	subq	#1,d3
	bmi	.LOOP
.F	move	#' ',(a6)+
	subq	#1,d7
	bmi.s	.SC0
	dbra	d3,.F
	bra	.LOOP
.JMPTAB					;on saute d1 colonnes et ya un tab !!!
	lea	TAB_LIST,a5
	move	start_col(a0),d4
	sub	d1,d4
	sub	#1+6,d4
.SEA1	move	(a5)+,d3
	cmp	d3,d4
	bgt.s	.SEA1
	sub	d4,d3
	subq	#1,d3
	bmi	.L008
.F1	subq	#1,d1
	bmi	.LOOP
	dbra	d3,.F1
	bra	.LOOP
;**************************************
BOTTOM::	
	xref	WINDOW_LIST

	lea	LINE+4,a6
	
	move	Largeur(a0),d7	;d7=X dernier CAR
	add	d4,d7
	subq	#1,d7		;garde un car … la fin


	*----------------------*
	* place le coin bas gauche
	*----------------------*
	move	COL_FEN,d0	
	move.b	#'À',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA0
	move.b	#'È',d0
.OKA0	move	d0,(a6)+
	addq	#1,d4
	cmp	d4,d7
	beq	.FINX


	*----------------------*
	* v‚rifie si on a un dump DSP
	* place le type de m‚moire si OK
	*----------------------*
	move	type(a0),d0
	cmp	#13,d0
	beq.S	.SETM
	cmp	#14,d0
	beq.S	.SETM
	cmp	#15,d0
	bne.S	.EXPR

.SETM	move	mem_type(a0),d0			
	move	COL_FEN,d1
	move.b	#'P',d1
	cmp	#MEM_P,d0
	beq.S	.SAVE
	move.b	#'X',d1
	cmp	#MEM_X,d0
	beq.S	.SAVE
	move.b	#'Y',d1
	cmp	#MEM_Y,d0
	bne.S	.EXPR

.SAVE	
	move	d1,(a6)+
	addq	#1,d4
	cmp	d4,d7
	beq.s	.FINX
	move.b	#':',d1
	move	d1,(a6)+
	addq	#1,d4
	cmp	d4,d7
	beq.s	.FINX		;P: X: ou Y:
	
	



	*----------------------*
	* place un tiret
	*----------------------*
			
.EXPR	move.l	ptr_expr(a0),a1
	tst.l	a1
	beq.S	.FILLX

	move.b	COL_FEN,(a6)+
	move.b	#'Ä',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.S	.OKA02
	move.b	#'Í',d0	
.OKA02	move.b	d0,(a6)+	
	addq	#1,d4
	cmp	d4,d7
	beq.s	.FINX


	*----------------------*
	* L'expression
	*----------------------*
	move	COL_BKPT,d0
	move.b	#'[',d0
	move	d0,(a6)+
	addq	#1,d4
	cmp.b	d4,d7
	beq.s	.FINX		
	
.LOOP1	move.b	(a1)+,d0
	beq.s	.OK2
	addq	#1,d4	;X
	move	d0,(a6)+
	cmp.b	d4,d7
	bne	.LOOP1
	bra.s	.FINX		
	
.OK2	move.b	#']',d0
	move	d0,(a6)+
	addq	#1,d4
	cmp.b	d4,d7
	beq.s	.FINX		

	*----------------------*
	* complete la ligne avec le tiret
	*----------------------*
.FILLX	move	COL_FEN,d0
	move.b	#'Ä',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.S	.OKA1
	move.b	#'Í',d0	
.OKA1	move	d0,(a6)+
	addq	#1,d4
	cmp	d4,d7
	bne.s	.OKA1
.FINX	move	COL_FEN,d0
	move.b	#'Ù',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA2
	move.b	#'¼',d0
.OKA2	move	d0,(a6)+
	move	#$8000,(a6)+
	move.l	a0,a1
	bsr	AFF_XY
	rts

;**************************************
TITRE::
	xref	WINDOW_LIST


	move	type(a0),d0
	move.l	(TAB_TITRE.l,d0.w*4),a1
	cmp	#T_DSP_SRC,d0
	beq.s	.SRC
	cmp	#T_M40_SRC,d0
	beq.s	.SRC
	bra.s	.NOSRC
.SRC	
	move.l	Src_adr(a0),a1
	move.l	ptr_name(a1),a1	
	
.NOSRC
	lea	LINE,a6
	move	W_X1(a0),d4
	move	d4,(a6)+
	move	W_Y1(a0),(a6)+
	
	move	Largeur(a0),d7	;d7=X dernier CAR
	add	d4,d7
	subq	#1,d7		;garde un car … la fin


	*----------------------*
	* place le coin haut gauche
	*----------------------*
	move	COL_FEN,d0	
	move.b	#'Ú',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA0
	move.b	#'É',d0
.OKA0	move	d0,(a6)+
	addq	#1,d4
	cmp	d4,d7
	beq	.FINX

	*----------------------*
	* place le no de fenetre
	*----------------------*
	move.l	a0,d0
	sub.l	#BUFFER_WINDOW,d0
	divu	#Size_win,d0	;no fenetre

	ext.l	d0
	divu	#10,d0
	move	d0,d1
	beq.s	.SEC		;vire un leading zero
	add.b	#'0',d1
	move.b	COL_FEN,(a6)+
	move.b	d1,(a6)+
	addq	#1,d4
	cmp	d4,d7
	beq	.FINX
.SEC	
	swap	d0
	move	d0,d1
	add.b	#'0',d1
	move.b	COL_FEN,(a6)+
	move.b	d1,(a6)+

	addq	#1,d4
	cmp	d4,d7
	beq	.FINX


	*----------------------*
	* place un tiret
	*----------------------*
			
	move.b	COL_FEN,(a6)+
	move.b	#'Ä',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.S	.OKA01
	move.b	#'Í',d0	
.OKA01	move.b	d0,(a6)+	
	addq	#1,d4
	cmp	d4,d7
	beq	.FINX
	

	*----------------------*
	* Le nom de la fenetre
	*----------------------*
	move	COL_FEN,d0
.LOOP	move.b	(a1)+,d0
	beq.s	.FILLX		;0
	cmp.b	#$d,d0		
	beq.s	.FILLX		;CR
	cmp.b	#$a,d0
	beq.s	.FILLX		;LF
.OK	addq	#1,d4		;X
	move	d0,(a6)+
.FG	cmp.b	d4,d7
	bne	.LOOP
	bra.s	.FINX		


	*----------------------*
	* complete la ligne avec le tiret
	*----------------------*
.FILLX	move	COL_FEN,d0
	move.b	#'Ä',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.S	.OKA1
	move.b	#'Í',d0	
.OKA1	move	d0,(a6)+
	addq	#1,d4
	cmp	d4,d7
	bne.s	.OKA1
.FINX	move	COL_FEN,d0
	move.b	#'¿',d0
	cmp.l	ACTIVE_WINDOW,a0
	bne.s	.OKA2
	move.b	#'»',d0
.OKA2	move	d0,(a6)+
	move	#$8000,(a6)+
	move.l	a0,a1
	bsr	AFF_XY

	addq	#1,LINE+2	;passe … la ligne
	rts
;**************************************


;**************************************
CYCLE_W::


	*--------------------*
	* recherche la fenetre active
	* dans la liste
	*--------------------*
	lea	WINDOW_LIST,a0
	move.l	ACTIVE_WINDOW,a1
	move	#31,d7
.SEARCH	cmp.l	(a0)+,a1
	beq.s	.OK0
	dbra	d7,.SEARCH
	bra	.FIN		;la fenetre active n'est pas ds la liste => BUG
.OK0	
	
.SC	tst.l	(a0)+
	bne.s	.FOUND
	dbra	d7,.SC
	lea	WINDOW_LIST,a0
	move	#31,d7

.SC2	tst.l	(a0)+
	bne.s	.FOUND
	dbra	d7,.SC2
	bra	.FIN		;on trouve la fenetre active, mais pas la suivante...
	
	

.FOUND	st	flag_aff(a1)
	move.l	-(a0),a1
	move.l	a1,ACTIVE_WINDOW
	st	flag_aff(a1)
	tst.l	ZOOM_WINDOW	;pas de cycling en zoom
	beq	.FIN		;ya un zoom

	move.l	ZOOM_WINDOW,a0
	move	ZOOM_X1,W_X1(a0)
	move	ZOOM_Y1,W_Y1(a0)
	move	ZOOM_Largeur,Largeur(a0)
	move	ZOOM_Hauteur,Hauteur(a0)	;restaure ancienne fenetre
	

	move.l	a1,a0				;installe nvlle fenetre
	move.l	a0,ZOOM_WINDOW
	move	W_X1(a0),ZOOM_X1
	move	W_Y1(a0),ZOOM_Y1
	move	Largeur(a0),ZOOM_Largeur
	move	Hauteur(a0),ZOOM_Hauteur
	
	clr	W_X1(a0)
	move	#1,W_Y1(a0)
	move	RESO_X,Largeur(a0)
	move	RESO_Y,d0
	subq	#2,d0
	move	d0,Hauteur(a0)
	bsr.l	set_all_flags

.FIN	rts
;**************************************
SCROLL_DOWN::
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_DOWN.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_DOWN_VITE::
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_DOWN_VITE.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_UP:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_UP.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_UP_VITE:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_UP_VITE.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_LEFT:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_LEFT.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_LEFT_VITE:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_LEFT_VITE.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_RIGHT:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_RIGHT.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************
SCROLL_RIGHT_VITE:: 
	movem.l	a0/d0,-(sp)
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	jsr	([TAB_SCROLL_RIGHT_VITE.l,d0.w*4])
	bsr.l	set_all_flags
	bsr	AFFICHE
	movem.l	(sp)+,a0/d0
	rts
;**************************************


;------------------------------------------------------------------------------
r_type
	move	d0,-(sp)
		
	*------------------*
	* sauve l'adr debut … sa place
	*------------------*
	move.l	ACTIVE_WINDOW,a0
	move.w	type(a0),d0
	cmp	#T_dernier,d0
	bge.s	.DSP0
	move.l	adr_debut(a0),Tab_adr_debut(a0)
	bra.S	.OK0
.DSP0	move.l	adr_debut(a0),Tab_adr_debut+4(a0)
.OK0
	*------------------*

	move	(sp)+,d0
	lea	tab_type_68,a1
	cmp	#$ff,d0
	ble.s	.MC68
	lea	tab_type_dsp,a1
.MC68	sub	#$67,d0
	and	#$ff,d0

	moveq	#0,d1
	jsr	([a1,d0.w*4])

	*------------------*
	* doit on remettre le adr_debut sauv‚ ?
	* si d1==0 oui
	*------------------*
	tst	d1
	bne.s	.OK1
	





	*------------------*
	* r‚cupere le nouveau adr debut
	*------------------*
	move.w	type(a0),d0
	cmp	#T_dernier,d0
	bge.s	.DSP1
	move.l	Tab_adr_debut(a0),adr_debut(a0)
	bra.s	.OK1
.DSP1	move.l	Tab_adr_debut+4(a0),adr_debut(a0)
.OK1
	st	flag_aff(a0)
	*------------------*

	rts
	
		
	
	*------------------*
	* les tables sont ordonn‚es ds l'ordre 
	* des codes scans
	*------------------*
tab_type_68	dc.l	r_type_7_68,r_type_8_68,r_type_9_68,r_type_4_68,r_type_5_68,r_type_6_68,r_type_1_68,r_type_2_68,r_type_3_68
tab_type_dsp	dc.l	r_type_7_dsp,r_type_8_dsp,r_type_9_dsp,r_type_4_dsp,r_type_5_dsp,r_type_6_dsp,r_type_1_dsp,r_type_2_dsp,r_type_3_dsp


	*------------------*
	
r_type_1_68	;----------------------registres 68
	;move.l	ACTIVE_WINDOW,a0
	move	#T_reg_68,type(a0)
	rts

r_type_2_68	;----------------------disas 68
	move	#T_disas_68,type(a0)
	rts
r_type_3_68	;----------------------hexdump 16
	move	#T_H16,type(a0)
	rts
r_type_4_68	;----------------------hexasciidump 16
	move	#T_HEXASCII16,type(a0)
	rts
r_type_5_68	;----------------------ascii dump
	move	#T_ASCII,type(a0)
	rts
r_type_6_68	;----------------------ascii dump
	;move	#T_INFO,type(a0)
	;st	d1
	rts
r_type_7_68	;----------------------I/O
	move	#T_IO,type(a0)
	rts
r_type_9_68	;----------------------ascii dump
	rts
r_type_1_dsp	;----------------------reg DSP
	move	#T_reg,type(a0)
	rts
r_type_2_dsp	;----------------------disass DSP
	move	#T_disas,type(a0)
	rts
r_type_3_dsp	;----------------------Hexa 24
	move	#T_H24,type(a0)
	rts
r_type_4_dsp	;----------------------Hexascii 24
	move	#MEM_X,mem_type(a0)
	move	#T_HEXASCII24,type(a0)
	rts
r_type_5_dsp	;----------------------Frac 24
	move	#MEM_X,mem_type(a0)
	move	#T_FRAC24,type(a0)
	rts
r_type_6_dsp	;----------------------HEXA 48
	move	#T_H48,type(a0)
	st	flag_aff(a0)
	rts
r_type_7_dsp	;----------------------Stack DUMP
	move	#T_SS,type(a0)
	rts
r_type_9_dsp	;----------------------Stack DUMP
	rts
	
;------------------------------------------------------------------------------
r_type_8_dsp	;----------------------Source
	xref	DSP_SOURCE_TABLE
	xref	DSP_NB_SOURCES
	tst	DSP_NB_SOURCES
	beq.s	.FIN

	move	#T_DSP_SRC,type(a0)
	move.l	#DSP_SOURCE_TABLE,Src_adr(a0)
	move	#1,Line_nb(a0)
	move.l	DSP_SOURCE_TABLE+nb_ligne,max_ligne(a0)	;maxligne+maxcol
.FIN	rts

;------------------------------------------------------------------------------
r_type_8_68	;----------------------Source
	xref	M40_SOURCE_TABLE
	xref	M40_NB_SOURCES
	tst	M40_NB_SOURCES
	beq.s	.FIN
	move	#T_M40_SRC,type(a0)
	move.l	#M40_SOURCE_TABLE,Src_adr(a0)
	move	#1,Line_nb(a0)
	move.l	M40_SOURCE_TABLE+nb_ligne,max_ligne(a0)	;maxligne+maxcol
.FIN	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	
*--------------------------------------
* Cherche la premiere fenetre du meme type
* Si elle existe
* recopie   dans la fenetre active
*--------------------------------------
* IN:	
*	d0	type de fenetre
* OUT:		
*	a1	ptr sur cette la premiere fenetre du mm type
*		0 si yen a pas !
*--------------------------------------
FIND_SAME
	*-------------------*
	* on va chercher
	* les 3 types compatibles
	* entre eux au max
	* ex: les dumps
	*-------------------*


.GO_ON
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	move.l	(a0)+,a1
	cmp	type(a1),d0
	beq.s	.FOUND
	cmp	type(a1),d1
	beq.s	.FOUND
	cmp	type(a1),d2
	beq.s	.FOUND
	dbra	d7,.LOOP
	bra.s	.ERREUR
.FOUND	move.l	a1,a0
	move.l	ACTIVE_WINDOW,a1
	
	clr.l	ptr_expr(a1)
	move	mem_type(a0),mem_type(a1)
	move.l	adr_debut(a0),adr_debut(a1)
	clr.l	start_col(a1)
	clr.l	max_ligne(a1)
	rts
		
.ERREUR
	move.l	ACTIVE_WINDOW,a1
	move	d0,type(a1)
	clr.l	ptr_expr(a1)
	clr.l	start_col(a1)
	clr.l	max_ligne(a1)
	
	sub.l	a0,a0
	rts
		


******************************************
** routine qui va afficher les fenetres	**
******************************************
AFFICHE::	
	movem.l	d0-a6,-(sp)
	
	move.b	#$13,$fffffc02.w
	
	
	bsr	UPDATE_ADRESSE_FENETRE		;recopie l'adresse debut ds le slot r‚serv‚ … son type
	
	bsr	EVAL_W_REG
	xref	DRAW_MENU	
	bsr	DRAW_MENU
	
	bsr	PETIT_MESSAGE

	move.l	ZOOM_WINDOW,d0
	beq.S	.NORMAL
	*---------------*
	* une seule fenetre en zoom
	*---------------*
	move.l	d0,a0
	bsr	EXPAND_WINDOW
	bra.s	.FIN
.NORMAL


	lea	WINDOW_LIST,a1
	move	#31,d7
.LOOP	move.l	(a1)+,d0
	beq.s	.OK0
	move.l	d0,a0
	tst	flag_aff(a0)
	beq.S	.OK0	
	bsr	EXPAND_WINDOW
	clr	flag_aff(a0)
.OK0	dbra	d7,.LOOP

.FIN	
	move.b	#$11,$fffffc02.w
	move.b	#$12,$fffffc02.w
	movem.l	(sp)+,d0-a6
	rts
;**************************************	
EVAL_W_REG
	xref	buffer_int

	*---------------*
	* affecte les registres Wxx
	*---------------*

	lea	buffer_int,a6
	move.l	r_e(a6),-(sp)
	

	lea	WINDOW_LIST,a0
	lea	buffer_int+r_w0,a1	;wxx
	move	#31,d7
.LOOP	move.l	(a0)+,d0
	beq.S	.CLR
	move.l	d0,a2
	move.l	adr_debut(a2),(a1)+
	bra.S	.OK0
.CLR	clr.l	(a1)+
.OK0	dbra	d7,.LOOP
	
	*---------------*
	* r‚evalue en cas de 
	* locking de fenetre
	*---------------*
	xref	eval
LOCK00
	lea	BUFFER_EXPR,a0
	lea	buffer_int+r_w0,a1	;wxx
	lea	WINDOW_LIST,a2
		
	
	move	#31,d7
.LOOP	move.l	(a2),d0
	beq.S	.OK0			;slot libre

	movE.l	d0,a3
	tst.l	ptr_expr(a3)
	beq.s	.OK0			;pas d'expression
	
	tst.b	(a0)			;ya une expression, mais elle est nulle
	beq.s	.OK0
	bsr.l	eval
	tst.b	d2
	bne.s	.OK0		;erreur
	move.l	d1,(a1)
	move.l	(a2),a3
	move.l	d1,adr_debut(a3)	;remet l'adresse de debut
	
.OK0	add	#256,a0
	addq	#4,a1
	addq	#4,a2	
	dbra	d7,.LOOP
		


	lea	buffer_int,a6
	move.l	(sp)+,r_e(a6)
	

	rts
	
;------------------------------------------------------------------------------
; on recopie adr_Debut ds la table des adresses de la structure window
; … sa place, of course
;------------------------------------------------------------------------------
UPDATE_ADRESSE_FENETRE
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	
	move.l	(a0)+,d0
	beq.s	.NXT
	move.l	d0,a1
	move.l	adr_debut(a1),d1
	move	type(a1),d0
	cmp	#T_dernier,d0
	bge.s	.dsp
	move.l	d1,Tab_adr_debut(a1)
	bra.s	.ok
.dsp	move.l	d1,Tab_adr_debut+4(a1)
.ok
.NXT	dbra	d7,.LOOP
	rts
;------------------------------------------------------------------------------
			
				
	

******************************************************
** routine qui affiche un message en bas de la page **
******************************************************
PETIT_MESSAGE::
	xref	RESO_X,RESO_Y
	movem.l	d0/d7/a0/a1,-(sp)
	move.l	MESSAGE_ADR,a0
	lea	LINE,a1
	clr	(a1)+
	move.w	RESO_Y,(a1)
	subq	#1,(a1)+
	move	RESO_X,d7
	subq	#1,d7		;pas de test !!!
	move	COL_ADR,d0	
	cmp.w	#16,(a0)
	beq	.MESW
.OK	move.b	(a0)+,d0
	beq.s	.OUT
	move	d0,(a1)+
	dbra	d7,.OK	
	bra.S	.FIN
.OUT	move.b	#' ',d0
.OK2	move	d0,(a1)+
	dbra	d7,.OK2
	bra.s	.FIN
.MESW	addq	#2,a0
.LO	move	(a0)+,d0
	cmp.w	#$8000,d0
	beq.s	.FIN
	move	d0,(a1)+
	dbra	d7,.LO
	
.FIN	move	#$8000,(a1)+
	bsr	AFF_XY
	move.l	#MES_SPACE,MESSAGE_ADR
	movem.l	(sp)+,d0/d7/a0/a1
	rts

NULL_ROUT::
	rts


*------------------------------------------------------------------------------
* efface         
*------------------------------------------------------------------------------
CLS_SCREEN::
	move.l	LOG,a0
	xref	SIZE_SCREEN
	move.l	SIZE_SCREEN,d0
	lsr.l	#2,d0
.CLS	clr.l	(a0)+
	subq.l	#1,d0
	bne.S	.CLS
	rts
	
	
	
	move	RESO_Y,d0
	mulu	#size_font,d0
	moveq	#0,d1
	move	RESO_X,d1
	asl.l	#2,d1
	mulu	d1,d0
	asr.l	#6,d0
	subq	#1,d0
.LOOP	
	rept	16
	clr.l	(a0)+
	endr
	dbra	d0,.LOOP
	rts

CLS_WINDOW::
	move.l	LOG,a0
	move	CLS_Y,d1
	move	CLS_H,d7
	subq	#1,d7
.LOOPY	
	move	CLS_L,d6
	move	CLS_X,d0
	subq	#1,d6
.LOOPX
	move.l	a0,a1				
	add.l	(TAB_Y.l,d1.w*4),a1
	add.w	(TAB_X.l,d0.w*2),a1
	move	#size_font-1,d5
.clr	
	clr.b	(a1)
	clr.b	2(a1)
	clr.b	4(a1)
	clr.b	6(a1)
	add	LSCR,a1
	dbra	d5,.clr
	addq	#1,d0
	dbra	d6,.LOOPX
	addq	#1,d1
	dbra	d7,.LOOPY
	rts

CLS_X	ds	1	
CLS_Y	ds	1	
CLS_L	ds	1	
CLS_H	ds	1	



SIZE_Y_DEC::
	move.l	ACTIVE_WINDOW,a0
	move.l	W_X1(a0),CLS_X
	move.l	Largeur(a0),CLS_L	
	move	Hauteur(a0),d0
	subq	#1,d0
	cmp.w	#2,d0
	ble	.FIN
	move	d0,Hauteur(a0)	
	st	flag_aff(a0)
	bsr	CLS_WINDOW
.FIN	rts



SIZE_X_DEC::
	move.l	ACTIVE_WINDOW,a0
	move.l	W_X1(a0),CLS_X
	move.l	Largeur(a0),CLS_L	
	
	move	Largeur(a0),d0
	subq	#1,d0
	cmp.w	#3,d0
	ble	.FIN
	move	d0,Largeur(a0)	
	st	flag_aff(a0)
	bsr	CLS_WINDOW
.FIN	rts



SIZE_Y_INC::
	move.l	ACTIVE_WINDOW,a0
	move.l	W_X1(a0),CLS_X
	move.l	Largeur(a0),CLS_L	
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d2
	addq	#1,d3
	cmp	RESO_Y,d3
	bge	.FIN
	subq	#1,d3
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	addq	#1,Hauteur(a0)
	st	flag_aff(a0)
	bsr	CLS_WINDOW
.FIN	rts

SIZE_X_INC::	
	move.l	ACTIVE_WINDOW,a0
	move.l	W_X1(a0),CLS_X
	move.l	Largeur(a0),CLS_L	
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d3
	addq	#1,d2
	cmp	RESO_X,d2
	bgt	.FIN
	subq	#1,d2
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	addq	#1,Largeur(a0)
	st	flag_aff(a0)
	bsr	CLS_WINDOW
.FIN	rts



MOVE_UP::		
	move.l	ACTIVE_WINDOW,a0
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,CLS_X
	move	d1,CLS_Y
	subq	#1,d1
	beq.s	.FIN
	move.l	Largeur(a0),CLS_L
	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d2
	subq	#1,d3
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	move	d1,W_Y1(a0)		
	st	flag_aff(a0)
	bsr	CLS_WINDOW
.FIN	rts

MOVE_DOWN::		
	move.l	ACTIVE_WINDOW,a0
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,CLS_X
	move	d1,CLS_Y
	addq	#1,d1
	move	d1,d2
	add	Hauteur(a0),d2
	cmp	RESO_Y,d2
	bge	.FIN
	move.l	Largeur(a0),CLS_L

	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d2
	subq	#1,d3
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	move	d1,W_Y1(a0)		
	st	flag_aff(a0)
	bsr	CLS_WINDOW
		
.FIN	rts
MOVE_LEFT::		
	move.l	ACTIVE_WINDOW,a0
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,CLS_X
	move	d1,CLS_Y
	subq	#1,d0
	bmi.s	.FIN
	move.l	Largeur(a0),CLS_L

	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d2
	subq	#1,d3
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	move	d0,W_X1(a0)		
		
	st	flag_aff(a0)
	bsr	CLS_WINDOW
		
.FIN	rts

MOVE_RIGHT::		
	move.l	ACTIVE_WINDOW,a0
	move	W_X1(a0),d0
	move	W_Y1(a0),d1
	move	d0,CLS_X
	move	d1,CLS_Y
	addq	#1,d0
	move	d0,d2
	add	Largeur(a0),d2
	cmp	RESO_X,d2
	bgt	.FIN
	move.l	Largeur(a0),CLS_L

	move	d0,d2
	move	d1,d3
	add	Largeur(a0),d2
	add	Hauteur(a0),d3
	subq	#1,d2
	subq	#1,d3
	bsr	CHECK_OVERRIDE
	tst.b	d7
	bne.s	.FIN		
	move	d0,W_X1(a0)		
		
	st	flag_aff(a0)
	bsr	CLS_WINDOW
		
.FIN	rts


CHECK_OVERRIDE
;d0=X1 d1=y1 d2=x2 d3,y2
	
	moveq	#0,d7
	lea	WINDOW_LIST,a1
	move	#31,d6
.LOOP	move.l	(a1)+,d4
	beq.s	.OK0
	cmp.l	d4,a0
	beq.s	.OK0
	move.l	d4,a2
	move	W_X1(a2),d4
	move	W_Y1(a2),d5
	cmp	d4,d2	
	blt	.OK0	;x2<x1
	cmp	d5,d3
	blt	.OK0	;y2<y1
	add	Largeur(a2),d4
	add	Hauteur(a2),d5
	subq	#1,d4
	subq	#1,d5
	cmp	d4,d0
	bgt	.OK0	;x1>x2
	cmp	d5,d1
	bgt	.OK0	;y1>y2
	st	d7
.OK0	dbra	d6,.LOOP
	rts
;**************************************	

****************************************************************
** routine qui va positionner tout les flags d'affichages a 1 **
****************************************************************
set_all_flags::
	xref	WINDOW_LIST
	movem.l	d0/d7/a0/a1,-(sp)
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	move.l	(a0)+,d0
	beq.s	.OK0
	move.l	d0,a1
	st	flag_aff(a1)
.OK0	dbra	d7,.LOOP	
	
	movem.l	(sp)+,d0/d7/a0/a1
	rts

set_dsp_flags::
	xref	WINDOW_LIST
	movem.l	d0/d7/a0/a1,-(sp)
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	move.l	(a0)+,d0
	beq.s	.OK0
	move.l	d0,a1
	cmp	#T_reg,type(a1)
	blt	.OK0
	cmp	#T_dsp_dernier,type(a1)
	bgt	.OK0
	st	flag_aff(a1)
.OK0	dbra	d7,.LOOP
	movem.l	(sp)+,d0/d7/a0/a1
	rts

set_40_flags::
******************************************
** Met les flags d'affichage du 40 a un **
******************************************
	xref	WINDOW_LIST
	movem.l	d0/d7/a0/a1,-(sp)
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP	move.l	(a0)+,d0
	beq.s	.OK0
	move.l	d0,a1
	cmp	#T_reg_68,type(a1)
	blt	.OK0
	cmp	#T_dernier,type(a1)
	bgt	.OK0
	st	flag_aff(a1)
.OK0	dbra	d7,.LOOP
	movem.l	(sp)+,d0/d7/a0/a1
	rts



	include	OPEN_WIN.S


	
	SECTION DATA
ACTIF_DSP::	dc	-1
ACTIF_40::	dc	-1



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; LES TABLES DES ROUTINES SELON LE TYPE                           
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
TAB_GEN::	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	xref	GEN_DIVERS,GEN_FEN_REG,GEN_FEN_DISAS,GEN_HEXASCII16,GEN_H16,GEN_ASCII,GEN_DISAS,GEN_SS,GEN_REG,GEN_H24,GEN_H48,GEN_FRAC24,GEN_HEXASCII24,GEN_DSP_SRC,GEN_M40_SRC
	xref	GEN_IO


	dc.l	NULL_ROUT		;reserved
	dc.l	GEN_FEN_REG,GEN_FEN_DISAS,GEN_H16,GEN_HEXASCII16,GEN_ASCII,GEN_DIVERS,GEN_IO,GEN_M40_SRC
	dc.l	NULL_ROUT,NULL_ROUT

	dc.l	GEN_REG,GEN_DISAS,GEN_H24,GEN_HEXASCII24,GEN_FRAC24,GEN_H48,GEN_SS,GEN_DSP_SRC

TAB_GEN_INV::	;genere l'hexa … partir de l'ascii~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	xref	GEN_HEXASCII16_INV,GEN_H16_INV,GEN_REG_INV,GEN_H24_INV,GEN_H48_INV,GEN_FRAC24_INV,GEN_HEXASCII24_INV


	dc.l	NULL_ROUT		;reserved
	dc.l	NULL_ROUT,NULL_ROUT,GEN_H16_INV,GEN_HEXASCII16_INV,NULL_ROUT
	dc.l	NULL_ROUT,NULL_ROUT,NULL_ROUT,NULL_ROUT,NULL_ROUT

	dc.l	GEN_REG_INV,NULL_ROUT,GEN_H24_INV,GEN_HEXASCII24_INV,GEN_FRAC24_INV,GEN_H48_INV,NULL_ROUT,NULL_ROUT

TAB_SCROLL_UP	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_U_REG,SCROLL_U_68_DESA,SCROLL_HA16_UP,SCROLL_HA16_UP,SCROLL_ASCII_UP,SCROLL_U_DISAS,SCROLL_U_DUMP,SCROLL_U_SRC
	xref	SCROLL_IO_UP

	dc.l	NULL_ROUT
	dc.l	SCROLL_U_REG,SCROLL_U_68_DESA,SCROLL_HA16_UP,SCROLL_HA16_UP,SCROLL_ASCII_UP
	dc.l	SCROLL_U_REG,SCROLL_IO_UP,SCROLL_U_SRC,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_U_REG,SCROLL_U_DISAS,SCROLL_U_DUMP,SCROLL_U_DUMP,SCROLL_U_DUMP,SCROLL_U_DUMP,NULL_ROUT,SCROLL_U_SRC


TAB_SCROLL_DOWN	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_D_REG,SCROLL_D_68_DESA,SCROLL_HA16_DOWN,SCROLL_HA16_DOWN,SCROLL_ASCII_DOWN,SCROLL_D_DISAS,SCROLL_D_DUMP,SCROLL_D_SRC
	xref	SCROLL_IO_DOWN


	dc.l	NULL_ROUT
	dc.l	SCROLL_D_REG,SCROLL_D_68_DESA,SCROLL_HA16_DOWN,SCROLL_HA16_DOWN,SCROLL_ASCII_DOWN
	dc.l	SCROLL_D_REG,SCROLL_IO_DOWN,SCROLL_D_SRC,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_D_REG,SCROLL_D_DISAS,SCROLL_D_DUMP,SCROLL_D_DUMP,SCROLL_D_DUMP,SCROLL_D_DUMP,NULL_ROUT,SCROLL_D_SRC

TAB_SCROLL_LEFT		;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_L_REG,SCROLL_L_68_DESA,SCROLL_HA16_L,SCROLL_ASCII_LEFT,SCROLL_L_DUMP,SCROLL_L_SRC
	xref	SCROLL_IO_L


	dc.l	NULL_ROUT
	dc.l	SCROLL_L_REG,SCROLL_L_68_DESA,SCROLL_HA16_L,SCROLL_HA16_L,SCROLL_ASCII_LEFT
	dc.l	NULL_ROUT,SCROLL_IO_L,SCROLL_L_SRC,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_U_REG,SCROLL_U_DISAS,SCROLL_L_DUMP,SCROLL_L_DUMP,SCROLL_L_DUMP,SCROLL_L_DUMP,NULL_ROUT,SCROLL_L_SRC
	
TAB_SCROLL_RIGHT	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	xref	SCROLL_R_REG,SCROLL_R_68_DESA,SCROLL_HA16_R,SCROLL_ASCII_RIGHT,SCROLL_R_DUMP,SCROLL_R_SRC
	xref	SCROLL_IO_R


	dc.l	NULL_ROUT
	dc.l	SCROLL_R_REG,SCROLL_R_68_DESA,SCROLL_HA16_R,SCROLL_HA16_R,SCROLL_ASCII_RIGHT
	dc.l	NULL_ROUT,SCROLL_IO_R,SCROLL_R_SRC,NULL_ROUT
	
	dc.l	NULL_ROUT,SCROLL_R_SRC,SCROLL_D_DISAS,SCROLL_R_DUMP,SCROLL_R_DUMP,SCROLL_R_DUMP,SCROLL_R_DUMP,NULL_ROUT,SCROLL_R_SRC

TAB_SCROLL_DOWN_VITE	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_D_REG_VITE,SCROLL_D_68_DESA_VITE,SCROLL_HA16_DOWN_VITE,SCROLL_D_DUMP_VITE,SCROLL_D_DISAS_VITE,SCROLL_D_SRC_VITE
	xref	SCROLL_IO_DOWN_VITE
	
	
	dc.l	NULL_ROUT
	dc.l	SCROLL_D_REG_VITE,SCROLL_D_68_DESA_VITE,SCROLL_HA16_DOWN_VITE,SCROLL_HA16_DOWN_VITE,NULL_ROUT
	dc.l	NULL_ROUT,SCROLL_IO_DOWN_VITE,SCROLL_D_SRC_VITE,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_D_REG_VITE,SCROLL_D_DISAS_VITE,SCROLL_D_DUMP_VITE,SCROLL_D_DUMP_VITE,SCROLL_D_DUMP_VITE,SCROLL_D_DUMP_VITE,NULL_ROUT,SCROLL_D_SRC_VITE


TAB_SCROLL_UP_VITE	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_U_REG_VITE,SCROLL_U_68_DESA_VITE,SCROLL_HA16_UP_VITE
	xref	SCROLL_U_DUMP_VITE,SCROLL_U_DISAS_VITE,SCROLL_U_SRC_VITE
	xref	SCROLL_IO_UP_VITE

	dc.l	NULL_ROUT
	dc.l	SCROLL_U_REG_VITE,SCROLL_U_68_DESA_VITE,SCROLL_HA16_UP_VITE,SCROLL_HA16_UP_VITE,NULL_ROUT
	dc.l	NULL_ROUT,SCROLL_IO_UP_VITE,SCROLL_U_SRC_VITE,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_U_REG_VITE,SCROLL_U_DISAS_VITE,SCROLL_U_DUMP_VITE,SCROLL_U_DUMP_VITE,SCROLL_U_DUMP_VITE,SCROLL_U_DUMP_VITE,NULL_ROUT,SCROLL_U_SRC_VITE

TAB_SCROLL_LEFT_VITE	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	xref	SCROLL_L_REG_VITE,SCROLL_L_68_DESA,SCROLL_HA16_L,SCROLL_ASCII_LEFT,SCROLL_L_DUMP,SCROLL_L_SRC_VITE


	dc.l	NULL_ROUT
	dc.l	SCROLL_L_REG_VITE,SCROLL_L_68_DESA,SCROLL_HA16_L,SCROLL_HA16_L,SCROLL_ASCII_LEFT
	dc.l	NULL_ROUT,NULL_ROUT,SCROLL_L_SRC_VITE,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_L_REG_VITE,SCROLL_U_DISAS,SCROLL_L_DUMP,SCROLL_L_DUMP,SCROLL_L_DUMP,SCROLL_L_DUMP,NULL_ROUT,SCROLL_L_SRC_VITE
	
TAB_SCROLL_RIGHT_VITE	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	xref	SCROLL_R_REG_VITE,SCROLL_R_68_DESA,SCROLL_HA16_R,SCROLL_ASCII_RIGHT,SCROLL_R_DUMP,SCROLL_R_SRC_VITE


	dc.l	NULL_ROUT
	dc.l	SCROLL_R_REG_VITE,SCROLL_R_68_DESA
	dc.l	SCROLL_HA16_R,SCROLL_HA16_R,SCROLL_ASCII_RIGHT
	dc.l	NULL_ROUT,NULL_ROUT,SCROLL_R_SRC_VITE,NULL_ROUT,NULL_ROUT

	dc.l	SCROLL_R_REG_VITE,SCROLL_D_DISAS,SCROLL_R_DUMP,SCROLL_R_DUMP,SCROLL_R_DUMP,SCROLL_R_DUMP,NULL_ROUT,SCROLL_R_SRC_VITE


;------------------------------------------------------------------------------
;table des titres selon le type
;------------------------------------------------------------------------------
TAB_TITRE	dc.l	0,.reg40,.dis40,.hexa16,.hexascii16,.ascii40,.info,.IO,.source40,0
		dc.l	0,.reg56,.dis56,.d24,.hexascii24,.dfrac,.d48,.ss,.sourcedsp,0,0

		ifne	(LANGUAGE=FRANCAIS)
.reg40		dc.b	'040 registres',0
.dis40		dc.b	'040 d‚sassemblage',0
.hexa16		dc.b	'040 m‚moire hexa',0
.hexascii16	dc.b	'040 m‚moire hexa-ascii',0
.ascii40	dc.b	'040 m‚moire ascii',0
.info		dc.b	'informations',0
.IO		dc.b	'040 entr‚e/sorties',0
.source40	dc.b	'040 source',0

.dis56		dc.b	'DSP d‚sassemblage',0
.ss		dc.b	'DSP pile',0
.reg56		dc.b	'DSP registres',0
.d24		dc.b	'DSP m‚moire 24 bits',0
.d48		dc.b	'DSP m‚moire L',0
.dfrac		dc.b	'DSP m‚moire fractionnel',0
.hexascii24	dc.b	'DSP m‚moire hexa-ascii',0
.sourcedsp	dc.b	'DSP source',0
		even
		endc
		
		ifne	(LANGUAGE=ANGLAIS)
.reg40		dc.b	'040 registers',0
.dis40		dc.b	'040 disassembly',0
.hexa16		dc.b	'040 hexa dump',0
.hexascii16	dc.b	'040 hexa-ascii dump',0
.ascii40	dc.b	'040 ascii',0
.source40	dc.b	'040 source',0
.IO		dc.b	'040 in/out',0
.info		dc.b	'informations',0

.dis56		dc.b	'DSP disassembly',0
.ss		dc.b	'DSP stack',0
.reg56		dc.b	'DSP registers',0
.d24		dc.b	'DSP dump 24',0
.d48		dc.b	'DSP L dump',0
.dfrac		dc.b	'DSP frac 24',0
.hexascii24	dc.b	'DSP hexa-ascii 24',0
.sourcedsp	dc.b	'DSP source',0
		even
		endc
;------------------------------------------------------------------------------

		ifne	(LANGUAGE=FRANCAIS)
MES_ACCUEIL	dc.b	'bienvenue dans CENTinel v0.985 á 1/05/1999 version francaise',0
MES_LOCK	dc.b	"v‚rouiller sur l'expression : ",0
MES_SPACE	dcb.b	78,' '
		even
		dc	0
		endc

		ifne	(LANGUAGE=ANGLAIS)
MES_ACCUEIL	dc.b	'Welcome to CENTinel v0.985 á  1/05/1999 english version ',0
MES_LOCK	dc.b	'expression to lock on : ',0
		even
MES_SPACE	dcb.b	78,' '
		dc	0
		endc


	
;------------------------------------------------------------------------------
TAB_LIST	dc	0,10,18,31,44,80,$7fff	
;largeur de chaque tabulation termin‚ par 7fff
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;la fonte selon la taille
;------------------------------------------------------------------------------
FONT	
	ifeq	(size_font=8)
	incbin	BLUE16.FNT
	endc
	ifeq	(size_font=16)
	incbin	BLUE8.FNT
	endc
;------------------------------------------------------------------------------

MESSAGE_ADR::	dc.l	MES_ACCUEIL


ZOOM_WINDOW::	dc.l	0		;adresse de la fenetre

*************
** couleur **
*************
COL_40::	dc.b	blanc,0
COL_DSP::	dc.b	cyan,0
COL_QUICC::	dc.b	rouge,0
COL_LAB::	dc.b	magenta,0
COL_ADR::	dc.b	jaune,0
COL_NOR::	dc.b	blanc,0
COL_FCT::	dc.b	gris,0
COL_BKPT::	dc.b	bleu,0
COL_CHG::	dc.b	cyanF,0
COL_REG::	dc.b	gris,0
COL_MENU::	dc.b	rouge,0
COL_PC::	dc.b	vert,0
COL_ERR_L::	dc.b	rouge,0
ATTRIBUTE::	dc.w	0

	

	BSS
CENTINEL_INFO::	ds.l	4	;debut,fin,adr_screen,0



ZOOM_X1		ds	1
ZOOM_Y1		ds	1
ZOOM_Largeur	ds	1
ZOOM_Hauteur	ds	1

COL_FEN::	ds	1
COULEUR::	ds	1		
LINE::		ds.w	256+2		;resox max de 256*8 = 2048
INVERSE::	ds	1

BUFFER_WINDOW::	ds	Size_win*32
BUFFER_EXPR::	ds.b	32*256

ASCII_BUF::	ds.w	10000	;pour mettre du texte ( desas...)
MASK_BUF::	ds.b	10000	;pour le mask des datas...

	*------------------*
	* on double les buffers
	* pour la bi-config
	*------------------*


BUFFER_WINDOW_2		ds	Size_win*32
BUFFER_EXPR_2		ds.b	32*256
ZOOM_X1_2		ds	1
ZOOM_Y1_2		ds	1
ZOOM_Largeur_2		ds	1
ZOOM_Hauteur_2		ds	1
ZOOM_WINDOW_2		ds.l	1		

