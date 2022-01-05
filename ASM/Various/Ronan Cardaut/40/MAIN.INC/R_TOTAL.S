	TEXT
	
	include	d:\centinel\both\define.s
	output	d:\centinel\40\main.inc\r_total.o
	incdir	d:\centinel\40
	include	d:\centinel\both\LOCALMAC.S
	include	d:\centinel\both\GEM.EQU
	xref	COL_ADR,COL_NOR,COL_LAB,COL_FCT,COL_REG,COL_CHG,COL_BKPT,COL_ERR_L,ATTRIBUTE,COL_MENU,COL_DSP
	xref	bkpt,m,TRACE,nombre,affiche_nombre_zero
	xref	dessas_one,affiche_nombre_2,num_func
	xref	ADR_VBR
	xref	ERR_MEM,p_c,get_function_trap
	xref	adr_label,nb_symbols,hash_table,excep,fonction_type,s_a7,LIGNE_BRA,type_excep
	xref	FLAG_EV,is_break,dessas_one_bk,s_buf,pile_test,eval_bkpt,calcule_adresse,ASCII_BUF,forme_curseur
	xref	buffer_r,buffer_r_anc,affiche_nombre,CPU_TYPE,buffer_int,buffer_int_anc,COL_PC,chaine_ascii	
	xref	ADR_CHARGE

	xref	MES_ERREUR_LOAD,MESSAGE_ADR,WORK_BUF,ADR_CHARGE,buf_label,buf_nom,taille_fichier,fichier
	xref	MES_SYM_LOAD_U,MES_TRI,MES_PAS_EXEC,flush_k_sys,buf_dta,PETIT_MESSAGE,MES_LOAD_SYM
	xref	set_all_flags,GET_CHAINE,name,traite_le_pc,CHARGE_AUTO,CMD_L,Com_line
	xref	adr_trace,ACTIVE_WINDOW
	
	xref	buffer_cou_t,LANCE_A,t_buf,COL_ERR,COL_NOR,restore_reg,rec_history,etat_trace,COL_NOR
	xref	adr_t_until,anc_touche,replay_macro,record_macro,s_a0,get_key
	xref	break_point,a_pile,s_d6,flag_w,gestion_exeptions,teste_fin,recommence,sauve_anc_reg,perm_bkpt
	xref	type_ex,gestion_des_ins_exep,table_fct_det,nb_fct_det,forme_bra,MES_NOP_ERR,MES_BAD_PC,bkpt_flag
	xref	Restore_reg,voir_ctrl_a,user_int,temp,MES_TRACED,MES_NOP,MES_IMP_040,set_40_flags,tempo,a_p_c
	xref	table_autori,MES_MACRO,MES_RB,MES_OK,MES_REINST_EXCEP,EVALUATEUR,adresse,put_pc
	xref	MES_KILL_BKPT,BKPT_IMP,MES_BKPT_USER,temp1,MES_OK_KILL_BKPT,MES_SPACE,MES,MES_BKPT_USER_LINE,eval
	xref	MES_PC,MES_EXP,clear_bkpt_liste,MES_UNTIL,MES_SKIPPED,s_a6,pile_prog,MES_SKIPED,RESIDENT,MES_CENT_RESI
	xref	MES_LOAD,COMMU,tempo1,load,MES_PROG_EXIST,MES_LOAD_OK,prog_launch,WINDOW_LIST,MES_COM
	
	
	
	
	
	xref	MES_VBR_SHIFT,MES_VBR_UNSHIFT,MES_VBR_CAN_UNSHIFT,MES_FONC_DET,MES_INCONNU,table_au_t,MES_FONC_DET_D
	xref	table_trap,MES_DET,MES_DET_PERM,MES_UPDATED,MES_EFF_TRAP,MES_PUT_HIS,table_num_max_ex
	xref	MESS_ERREUR_PATH,ANC_VBR,VBR_FLAG,MES_S_BINARY,MES_PLUS_MEM,MES_ERREUR_PATH,MES_DIRECTORY,MES_LOAD_B
	xref	MES_CMD_LINE,SAVE_VIDEO,TRACE_EXCEP,vbr_deviation,point_history,fonction_name,MES_INTOUV
	xref	save_binary,liste_mfree,ANC_VBR1,MES_OPT_BIN,BASE_PAGE,SAVE_OLD_PROS



******************************************************************
** ici on defint les bit qui serviront au detournement de l'aes **
** et de la vdi                                                 **
******************************************************************

b_aes	equ	15		; bit pour l'aes
b_vdi	equ	14		; bit pour la vdi
b_esc	equ	13		; bit pour les fct esc (vdi)
b_gfx	equ	12		; bit pour les fct gfx (vdi)
b_perm	equ	11		; dit si le detounemnt est permanent
b_catch	equ	10		; dit si on doit ou non catcher la fonction

	include 40\macros.s



macro_menu::
****************************************************
** La routine qui va gerer les macro instructions **
** Idee de Rodolphe ;)                            **
****************************************************

	
	move.w	record_macro,d7			; sauve l'etat avant la routine
	clr.w	record_macro			; on arrete le record si on rentre dans cette routine
	
	move.l	#MES_MACRO,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	bsr.l	get_key
	cmp.b	#1,d0
	beq	.annule



	cmp.b	#$12,d0				; on a le E
	bne.s	.pas_eng
	st	record_macro
	clr.w	replay_macro
.pas_eng
	cmp.b	#$24,d0				; on a le J
	bne.s	.pas_play
	
	
	cmp.l	#t_buf,buffer_cou_t		; rien n'a ete enregistre
	beq.s	.annule
	
	
	move.l	buffer_cou_t,a0			; attention a si on enregistrait ou non
	tst.w	d7
	beq.s	.p_r
	clr.l	-4(a0)				; on efface la dernier touche cad le F7
	bra.s	.kl
.p_r
	clr.l	(a0)
.kl

	move.l	#t_buf,buffer_cou_t		; on remet le buffer a zero
	
	st	replay_macro
	clr.w	record_macro
.pas_play
	cmp.b	#$1f,d0				; on a le S
	bne.s	.pas_stop
	
	clr.w	record_macro
	clr.w	replay_macro
	
.pas_stop
	cmp.b	#$13,d0				; on a le R
	bne.s	.pas_reset
	
	move.l	#t_buf,buffer_cou_t
	move.l	buffer_cou_t,a0
	clr.l	(a0)
	
	clr.w	record_macro
.pas_reset
	rts
	
.annule
	move.l	d7,record_macro
	rts


r_trace_until_adr_fen::
**********************************************************
** routine qui va tracer jusqu'a ce que le pc arrive    **
** a l'adresse de la fenetre courante                   **
** en fait on utilise un ctrl a modifie pour l'occasion **
**********************************************************
	
	
	demo_mode?
	
	move.l	s_a0,anc_touche

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	cmp.l	p_c,a4			; si pc= windows alors opn ignore
	bne.s	.p_ex
	
	rts
.p_ex
.source
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne.s	.p_source
	
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.w	Line_nb(a0),d0
	move.l	(a3,d0.w*4),d1
	cmp.l	#-1,d1
	bne.s	.okk
	rts
.okk
	move.l	d1,adr_debut(a0)
	move.l	d1,a4
	cmp.l	p_c,a4
	bne.s	.p_source
	rts
.p_source
	
	move.w	#1,LANCE_A
	move.l	#MES_RB,MESSAGE_ADR
	
	
	cmp.l	#$e00000,a4
	blt.s	.p_rom
	cmp.l	#$f00000,a4
	bgt.s	.p_rom
	
	
	*--- ici on prevoit un trace until pour la rom ---*
	
	move.w	#0,LANCE_A
	move.l	a4,adr_t_until
	move.l	#.TRACE_PC,adr_trace
	bra	.trace
.p_rom
	cmp.l	#$fa0000,a4
	blt.s	.p_cartouche
	cmp.l	#$fc0000,a4
	bgt.s	.p_cartouche
	
	*--- ici on prevoit un trace until pour la rom ---*
	
	move.l	a4,adr_t_until
	move.l	#.TRACE_PC,adr_trace
	bra	.trace
.p_cartouche
	
	
	
	
	
	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt11
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt11
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
.p_bkpt11
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a4
	move.l	a4,a0
	
	
	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	bne.s	.err111
	move.l	p_c,d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err11
.err111
	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err11
	
	
	*----- il faudra si on tombe sur un break point
	*----- parametre le remettre en suite
	
	
	
	bsr.l	is_break
	tst.w	bkpt
	bne.s	.ok2
	
	move.l	a4,d0				; on place le bkpt
	move.l	#0,a1
	bsr.l	break_point	
	move.l	#go,-(sp)
	rts

.ok2	
	move.w	2(a1),d0
	cmp.b	#0,d0				; pas de bkpt parametre
	beq.s	.p_bkpt_para
	btst	#1,d0
	bne.s	.p_bkpt_para			; on a deja un permanaent
	bset	#1,d0
	move.w	d0,2(a1)
	
	move.l	a4,bkpt_flag 

.p_bkpt_para

	move.l	#go,-(sp)
	rts

.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	move.l	p_c,a4
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err11
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err11	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?
	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
.p_bkpt


	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	
	
	move.w	#1,etat_trace		; on ne touche pas le resol
	cmp.w	#0,voir_ctrl_a
	beq.s	.p_voir
	lea	VIDEO_COU,a0		; ici on va installer l'ecran logique.
	bsr.l	SET_VIDEO
	move.w	#0,etat_trace
	move.w	#2,etat_trace		; va reforcer l'install_video sans sauve
.p_voir

	bsr.l	sauve_anc_reg

	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	

	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse
	

	rte



.TRACE_PC				; routine de trace avec le pc
	move.w	#$2700,sr
	move.l	d0,-(sp)
	move.l	adr_t_until,d0
	cmp.l	6(sp),d0
	bne.s	.p_encore
	move.l	(sp)+,d0
	bra.l	TRACE
.p_encore
	move.l	(sp)+,d0
	bset	#7,(a7)
	
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse

	rte
	
	endc


r_nop::
*********************************************
** Routine qui va mettre un nop s*ur le pc **
*********************************************


	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_disas_68,type(a0)		; si c'est le type registre alor on sort
	bne	.t
	move.l	adr_debut(a0),a0
	move.w	#$4e71,d0
	writ_mem.w	d0,a0
	tst.b	ERR_MEM
	beq.s	.p_err
	bsr.l	forme_bra
	bsr.l	set_all_flags
	move.l	#MES_NOP_ERR,MESSAGE_ADR
	rts
.p_err
	bsr.l	forme_bra
	bsr.l	set_all_flags
	move.l	#MES_NOP,MESSAGE_ADR
.t
	rts

r_trace::
*************************************************************
** routine que se charger de tracer l'instruction courante **
*************************************************************

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne	.p_source
	
	
	*--- on va faire un trace dans la fentre source ---*
	*--- en fait, on va faire un trace until        ---*
	
	lea	temp,a6
	
	move.b	#'(',(a6)+
	move.l	#'(PC<',(a6)+
	move.b	#'$',(a6)+
	move.l	p_c,d0
	bsr.l	affiche_nombre
	lea	nombre,a1
.t	move.b	(a1)+,(a6)+
	bne.s	.t	
	subq.l	#1,a6
	move.l	#')|(P',(a6)+
	move.l	#'C>=$',(a6)+
	
	
	
	
	
	bsr	trouve_ligne
	bsr	trouve_ligne_suivante
	
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	(a3,d0.w*4),d0
	
	
	
	
	bsr.l	affiche_nombre
	lea	nombre,a1
.t1	move.b	(a1)+,(a6)+
	bne.s	.t1	
	subq.l	#1,a6
	
	move.w	#'))',(a6)+
	
	move.l	#'&(PC',(a6)+
	move.l	#'<DAT',(a6)+
	move.w	#'A)',(a6)+
	
	move.l	#'&(PC',(a6)+
	move.l	#'>=TE',(a6)+
	move.w	#'XT',(a6)+
	move.b	#')',(a6)+
	
	lea	temp,a6
	
	bra.l	trace_until_exp
	
	
	
	
	
	


.p_source

	addq	#4,sp
	move.l	s_a0,anc_touche
	

.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	
	move.l	p_c,a4
	
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err
	move.l	#MES_BAD_PC,MESSAGE_ADR
	bra.l	recommence
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?

	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
	
	
	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
	
	
	
	
	;bsr	Restore_reg

	;pea	(a0)
	;move.l	#$24,a0			
	;add.l	ADR_VBR,a0		
	;move.l	#TRACE_EXCEP,(a0)	; on va vectoriser un trace_exceptionnel
	;move.l	(sp)+,a0
	;bsr	sauve_anc_reg
	;move.l	a_pile,a7
	;bset	#7,(a7)			; place le trace pour un coup
	;sf	user_int
	;sf	flag_w
	;vide_cache
	;active_mouse
	
	;rte
	
	
	
.p_bkpt



	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	bsr.l	sauve_anc_reg
	
	
	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR

	move.w	#1,etat_trace



	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse



	rte


intelligent_trace::
*************************************************************
** routine que se charger de tracer l'instruction courante **
*************************************************************

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne.s	.p_source
	
	
	*--- on va faire un trace dans la fentre source ---*
	*--- en fait, on va faire un trace until        ---*
	
	lea	temp,a6
	
	move.l	#'(PC<',(a6)+
	move.b	#'$',(a6)+
	move.l	p_c,d0
	bsr.l	affiche_nombre
	lea	nombre,a1
.t	move.b	(a1)+,(a6)+
	bne.s	.t	
	subq.l	#1,a6
	move.l	#')|(P',(a6)+
	move.l	#'C>=$',(a6)+
	
	
	
	
	
	bsr	trouve_ligne
	bsr	trouve_ligne_suivante
	
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	(a3,d0.w*4),d0
	
	
	
	
	bsr.l	affiche_nombre
	lea	nombre,a1
.t1	move.b	(a1)+,(a6)+
	bne.s	.t1	
	subq.l	#1,a6
	
	move.b	#')',(a6)+
	
	lea	temp,a6
	
	bra.l	trace_until_exp
	
	
	
	
	
	
	


.p_source

	addq	#4,sp
	move.l	s_a0,anc_touche
	
	move.l	p_c,a4
	bsr.l	dessas_one
	lea	m,a4
	cmp.b	#'B',1(a4)
	bne.s	.p_bsr
	cmp.b	#'S',3(a4)
	beq	r_ctrl_a
.p_bsr
	cmp.b	#'J',1(a4)
	bne.s	.p_jsr
	cmp.b	#'S',3(a4)
	beq	r_ctrl_a
.p_jsr
	

.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	
	move.l	p_c,a4
	
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err
	move.l	#MES_BAD_PC,MESSAGE_ADR
	bra.l	recommence
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?

	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
	
	
	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
	
	
	
	
	;bsr	Restore_reg

	;pea	(a0)
	;move.l	#$24,a0			
	;add.l	ADR_VBR,a0		
	;move.l	#TRACE_EXCEP,(a0)	; on va vectoriser un trace_exceptionnel
	;move.l	(sp)+,a0
	;bsr	sauve_anc_reg
	;move.l	a_pile,a7
	;bset	#7,(a7)			; place le trace pour un coup
	;sf	user_int
	;sf	flag_w
	;vide_cache
	;active_mouse
	
	;rte
	
	
	
.p_bkpt



	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	bsr.l	sauve_anc_reg
	
	
	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR

	move.w	#1,etat_trace


	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse

	rte


r_trace_tout::
*************************************************************
** routine que se charger de tracer l'instruction courante **
** ici, on va tracer aussi les exceptions ...              ** 
*************************************************************
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne.s	.p_source
	
	rts				; si on a un source, on ne fait rien
.p_source

	cmp.w	#cpu_30,CPU_TYPE	; sur 040 on va rien faire pour l'instant
	beq	.030
	
	move.l	p_c,a0			; si on n'a pas de trap 
	lit_mem.w	a0,d0		; on peut sauter … la routine 030 normal
	move.w	d0,d1
	and.w	#$fff0,d0
	cmp.w	#$4e40,d0
	beq	.trap
	
	
	
	
	
	
	move.w	d1,d0
	and.w	#$f000,d0
	cmp.w	#$a000,d0			; test d'une line a
	bne.s	.suite
	move.w	#$28,d0
	bra	.installe_bkpt
.suite
	
	move.l	p_c,a4				; line f ?
	bsr.l	dessas_one
	lea	m,a4
	cmp.b	#'D',1(a4)
	bne.s	.suite_0
	cmp.b	#'C',3(a4)
	bne.s	.suite_0
	move.w	#$2c,d0
	bra	.installe_bkpt
.suite_0
	
	move.w	d1,d0
	cmp.w	#%0100111001110110,d0		; test du trapv
	bne.s	.suite1
	move.w	#$1c,d0
	bra	.installe_bkpt
.suite1
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111010,d0		; test du trapcc		petit pb avec sf
	bne.s	.suite2
	move.w	#$1c,d0
	bra	.installe_bkpt
.suite2
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111011,d0		; test du trapcc		petit pb avec sf
	bne.s	.suite3
	move.w	#$1c,d0
	bra	.installe_bkpt
.suite3
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111100,d0		; test du trapcc		petit pb avec sf
	bne.s	.suite4
	move.w	#$1c,d0
	bra	.installe_bkpt
.suite4
	move.w	d1,d0
	and.w	#%1111000111111000,d0
	cmp.w	#%1111000001111000,d0		; test du cptrapcc
	bne.s	.suite5
	move.w	#$1c,d0
	bra	.installe_bkpt
.suite5
	move.w	d1,d0
	and.w	#%1111000101000000,d0
	cmp.w	#%0100000100000000,d0		; test du chk
	bne.s	.suite6
	move.w	#$18,d0
	bra	.installe_bkpt
.suite6
	move.w	d1,d0
	and.w	#%1111100111000000,d0
	cmp.w	#%0000000011000000,d0		; test du chk2
	bne	.suite_7
	lea	2(a0),a1
	lit_mem.w	a1,d0			; suite du chk2
	btst	#11,d0
	bne.s	.suite_7
	move.w	#$18,d0
	bra	.installe_bkpt

.suite_7

	bra.s	.030					; on trace normalement
.trap
	move.w	d1,d0
	and.w	#$f,d0
	lsl.w	#2,d0
	add.w	#$80,d0
.installe_bkpt
	move.l	ADR_VBR,a0
	add.w	d0,a0
	move.l	(a0),d0
	tst.w	ERR_MEM
	bne.s	.erreur
	move.l	#0,a1
	bsr.l	break_point
	tst.w	d0
	bne.s	.erreur
	move.w	#2,LANCE_A
	move.l	#go,-(sp)
	
	
	rts
	
.erreur
	move.l	#MES_IMP_040,MESSAGE_ADR	; si on pointe en ROM => pas de bkpt

	rts
.030
	


	addq	#4,sp
	move.l	s_a0,anc_touche
	

.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	
	move.l	p_c,a4
	
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err
	move.l	#MES_BAD_PC,MESSAGE_ADR
	bra.l	recommence
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?

	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
	
	
	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
.p_bkpt


	; on va tester si l'instruc est un bkpt

	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt1
	
	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
.p_bkpt1
	
	
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	bsr.l	sauve_anc_reg
	
	move.l	a_pile,a7
	;bclr	#7,(a7)				; replace le trace
	;bset	#6,(a7)				; replace le trace
	bset	#7,(a7)				; replace le trace



	move.l	#MES_TRACED,MESSAGE_ADR

	move.w	#1,etat_trace


	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse

	rte

r_reinst_excep::
*************************************
** rinstalle toutes les exceptions **
*************************************

	move.l	#MES_REINST_EXCEP,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	cmp.w	#$15,d0
	beq.s	.oui
	cmp.w	#$18,d0
	bne	.annule
	
.oui

	lea	$8,a0
	add.l	ADR_VBR,a0
	lea	table_autori,a1
	move.l	#TRACE,d0
	moveq	#61,d1			; on detourne 62 veteurs (64 sauf 0&1)

.det	tst.b	(a1)+
	beq.s	.p_det
	move.l	d0,(a0)+
	bra.s	.sui
.p_det
	tst.l	(a0)+			; on n'y touche pas
.sui	dbra	d1,.det

	bsr.l	set_40_flags
	move.l	#MES_OK,MESSAGE_ADR
.annule
	rts


r_cycle::
***********************************				; Tab cycle window
** routine qui cycle les fentres **
***********************************
	xref	CYCLE_W
	jsr	CYCLE_W		

	rts

test_source
************************************************
** convertion de l'adr fen en ligne du source **
** la plus proche                             **
************************************************
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	rts
.source
	move.l	adr_debut(a0),d0
	bsr	trouve_ligne
	
.d
	move	d0,Line_nb(a0)
	rts

	
test_source_old
************************************************
** convertion de l'adr fen en ligne du source **
************************************************
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	rts
.source
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	adr_debut(a0),d2
	move.w	nb_ligne(a1),d1
	moveq	#0,d0
.ll	addq.l	#1,d0
	cmp.l	(a3,d0.l*4),d2
	beq.s	.d
	dbra	d1,.ll
	rts
.d
	move	d0,Line_nb(a0)
	rts
	

r_fen_pc::
*******************************************			; ctrl 9  fen=pc
** routine qui va mettre la fentre au pc **
*******************************************
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	move.l	p_c,adr_debut(a0)
	bsr	test_source
	;bsr.l	traite_le_pc
	bsr.l	set_40_flags

.i
	rts

r_fen_a0::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a0(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_a0_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a0(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_a1::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a1(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts


r_fen_a1_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a1(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts


r_fen_a2::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a2(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_a2_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a2(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts


r_fen_a3::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a3(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	
	rts
	
r_fen_a3_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a3(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

	
r_fen_a4::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a4(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts
	
r_fen_a4_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a4(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

	
r_fen_a5::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a5(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts
	
r_fen_a5_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a5(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

	
r_fen_a6::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a6(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_a6_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a6(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

	

r_fen_a7::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_a7(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_a7_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_a7(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_ssp::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_ssp(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_ssp_double::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq	.i
	lea	buffer_r,a6
	move.l	r_ssp(a6),a6
	lit_mem.l	a6,d0		; pour la double inderection
	tst.b	ERR_MEM
	bne.s	.i
	move.l	d0,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts


r_fen_d0::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d0(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_d1::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d1(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_d2::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d2(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_d3::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d3(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	
	rts
r_fen_d4::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d4(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts
	
r_fen_d5::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d5(a6),adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts
	
r_fen_d6::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d6(a6),adr_debut(a0)
	bsr.l	traite_le_pc
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts

r_fen_d7::
*******************************************
** routine qui va mettre la fentre au an **
*******************************************
	pea	(a6)
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.i
	lea	buffer_r,a6
	move.l	r_d7(a6),adr_debut(a0)
	bsr.l	traite_le_pc
	bsr	test_source
	bsr.l	set_40_flags
.i
	move.l	(sp)+,a6
	rts
	
	
r_watch::
***************************************************
** routine que va pointer la fenetre … l'adresse **
** point‚e par l'instruction                     **
***************************************************
	movem.l	d0-a6,-(sp)
	
	tst.b	flag_w
	beq.s	.next
	sf	flag_w
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.rien
	move.l	.save,adr_debut(a0)		; restoration de la position de depart
	bsr	test_source
	bsr.l	set_40_flags
	bra.s	.rien
.next

	move.l	p_c,a4
	bsr.l	dessas_one_bk	
	lea	s_buf,a1
	bsr.l	calcule_adresse
	tst.b	d0
	beq.s	.rien
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.rien
	move.l	adr_debut(a0),.save		; sauvegarde de la position actuelle
	move.l	d1,adr_debut(a0)
	bsr	test_source
	bsr.l	set_40_flags
	st	flag_w
.rien
	movem.l	(sp)+,d0-a6

	rts

.save
	ds.l	1

r_force_b::
***************************************************************
** Routine qui va forcer le branchement … l'adresse suivante **
***************************************************************
	movem.l	d0-a6,-(sp)
	
	
	
	move.l	p_c,a0				; on test si on a un branchement
	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	bne.s	.rien
.p_err
	move.w	d0,d1
	and.w	#%1111000000000000,d0		; test du bcc
	cmp.w	#%0110000000000000,d0
	bne.s	.rien				; si non => sortie
	move.l	p_c,a4
	bsr.l	dessas_one_bk	
	lea	s_buf,a1
	bsr.l	calcule_adresse
	tst.b	d0
	beq.s	.rien
	move.l	d1,p_c
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_reg_68,type(a0)
	beq.s	.rien
	move.l	d1,adr_debut(a0)
	lea	buffer_r,a6
	move.l	d1,r_pc(a6)
	move.l	d1,a_p_c
	bsr	test_source
	bsr.l	traite_le_pc
	bsr.l	set_40_flags
.rien
	movem.l	(sp)+,d0-a6
	rts
	
r_eval::
*****************************************			; E evaluateur
** routine qui va appeler l'evaluateur **
*****************************************
	movem.l	d0/a6/a0,-(sp)
	move.l	p_c,a_p_c
	jsr	EVALUATEUR
	lea	buffer_r,a6
	move.l	a_pile,a0
	move.l	r_sr(a6),d0
	move.w	d0,(a0)			; retablit le sr en cas de modifs
	move.l	r_pc(a6),p_c
	move.l	p_c,a0
	cmp.l	a_p_c,a0		; retablit le pc
	beq.s	.lemmings		
	bsr	test_source
	bsr.l	traite_le_pc
	;bsr.l	set_all_flags		; deja dans EVALUATEUR
	movem.l	(sp)+,a6/a0/d0
	rts
.lemmings
	bsr.l	forme_bra
	;bsr.l	set_all_flags
	movem.l	(sp)+,a6/a0/d0
	rts




r_get_object::
**************************************
** routine qui va chercher un objet **
**************************************



	xref	get_object
	xref	chaine_encore
	
	clr.b	(chaine_encore)
	
	jsr	get_object
	bsr.l	forme_bra
	bsr	test_source
	bsr.l	set_40_flags
	sf	tempo
	rts
	

r_get_object_back::
**************************************
** routine qui va chercher un objet **
**************************************



	xref	get_object_back
	xref	chaine_encore
	
	clr.b	(chaine_encore)
	
	jsr	get_object_back
	bsr.l	forme_bra
	bsr	test_source
	bsr.l	set_40_flags
	sf	tempo
	rts
	

r_get_object_again::
**************************************
** routine qui va chercher un objet **
**************************************



	xref	get_object
	xref	chaine_encore
	
	jsr	get_object
	bsr.l	forme_bra
	bsr	test_source
	bsr.l	set_40_flags
	sf	tempo
	rts
	

r_get_object_again_back::
**************************************
** routine qui va chercher un objet **
**************************************



	xref	get_object_back
	xref	chaine_encore
	
	jsr	get_object_back
	bsr.l	forme_bra
	bsr	test_source
	bsr.l	set_40_flags
	sf	tempo
	rts
	



r_a::
*********************************************************	A adresse
** routine qui va mettre la fen cou a l'adresse voulue **
*********************************************************
	jsr	adresse
	bsr.l	forme_bra
	bsr.l	set_40_flags
	rts
r_put_pc::
*************************************************		J put PC
** routine qui mettre le pc a la valeur voulue **
*************************************************
	bsr.l	put_pc
	lea	buffer_r,a1
	move.l	p_c,r_pc(a1)
	bsr.l	traite_le_pc
	bsr.l	set_40_flags
	rts
r_put_pc_fen::
******************************************************		ctrl j pc=fen
** routine qui va mettre le pc a l'adr de la fentre **
******************************************************
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq	.source
	
	cmp.w	#T_disas_68,type(a0)
	bne	.t
	
	move.l	adr_debut(a0),a1
	lit_mem.w	a1,d0
	tst.w	ERR_MEM
	bne.s	.t
	
	
	move.l	adr_debut(a0),p_c
	lea	buffer_r,a0
	move.l	p_c,r_pc(a0)
	bsr.l	traite_le_pc
	bsr.l	set_40_flags
.t
	rts
	
	
.source
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	clr.l	d0
	move	Line_nb(a0),d0			; nb de la ligne
.suiv_l
	move.l	(a1,d0.l*4),a2			; adr correspondante
	cmp.l	#-1,a2
	bne.s	.valide
	
	addq.l	#1,d0
	cmp.l	max_ligne(a0),d0
	beq.s	.p_valide			; on est a la fin du source
	
	bra.s	.suiv_l
	
.valide
	
	move.w	d0,Line_nb(a0)
	move.l	a2,p_c
	lea	buffer_r,a0
	move.l	p_c,r_pc(a0)
	bsr.l	traite_le_pc
	bsr.l	set_40_flags

.p_valide

	rts
	

r_bkpt::
******************************************			crtl b put bkpt
** routine qui va mettre/virer les bkpt **
******************************************	
	demo_mode?

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	cmp.w	#T_disas_68,(a0)
	bne.s	.u
	
	
	move.l	adr_debut(a0),d0
	move.l	#0,a1
	bsr.l	break_point
	bsr.l	set_40_flags
.u
	rts


.source
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	clr.l	d0
	move	Line_nb(a0),d0			; nb de la ligne
	move.l	(a1,d0.l*4),a1			; adr correspondante
	cmp.l	#-1,a1
	beq.s	.p_valide			; valide?
	move.l	a1,d0
	move.l	#0,a1
	bsr.l	break_point
	bsr.l	set_40_flags


	rts

.p_valide

	move.l	#BKPT_IMP,MESSAGE_ADR


	rts

	endc


r_kill_bkpt::
**************************************************
** routine qui va effacer tous les break points **
**************************************************

	move.l	#MES_KILL_BKPT,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	cmp.w	#$15,d0
	beq.s	.oui
	cmp.w	#$18,d0
	bne	.non
	
.oui
	bsr.l	clear_bkpt_liste
	move.l	#MES_OK_KILL_BKPT,MESSAGE_ADR
	bsr.l	set_40_flags
	rts

	
	
.non
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_40_flags
	rts

r_bkpt_perm::
**********************************************
** routine qui va placer automatiquement un **
** bkpt permanant                           **
**********************************************
	demo_mode?
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	cmp.w	#T_disas_68,(a0)
	bne.s	.u
	lea	temp1,a0
	move.w	#',,',(a0)+			; on ajoute ,,1 pour la permanance
	move.b	#'1',(a0)+
	clr.b	(a0)
	
	lea 	temp1,a1
	bsr.l	break_point
	
	bsr.l	set_40_flags
.u
	rts

.source
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	clr.l	d0
	move	Line_nb(a0),d0			; nb de la ligne
	move.l	(a1,d0.l*4),a1			; adr correspondante
	cmp.l	#-1,a1
	beq.s	.p_valide			; valide?
	
	move.l	a1,d1
	moveq	#0,d0
	lea	temp1,a0
	xref	convert_inv
	bsr.l	convert_inv			; on convertit en une chaine
.o1	cmp.b	#' ',(a0)+
	bne.s	.o1
	subq.l	#1,a0
	move.w	#',,',(a0)+			; on ajoute ,,1 pour la permanance
	move.b	#'1',(a0)+
	clr.b	(a0)
	
	lea 	temp1,a1
	bsr.l	break_point
	
	bsr.l	set_40_flags


	rts

.p_valide

	move.l	#BKPT_IMP,MESSAGE_ADR


	rts


	endc

r_s_bkpt::
*************************************
** Routine qui va demander …       **
** l'utilisateur d'entrer son bkpt **
*************************************
	demo_mode?






	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne	.p_source
.recom1
	move.l	#MES_BKPT_USER_LINE,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.annule
	move.l	a2,a1				; dans a1 on a le debut de la chaine a exploiter
	

	*--- ici, on va convertir la ligne en adresse

	cmp.b	#',',(a2)	; pas de line donnee, on prend la courante
	bne.s	.suite
	
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	move	Line_nb(a0),d0			; nb de la ligne
	move.l	(a1,d0.w*4),a1
	cmp.l	#-1,a1
	beq.s	.recom1
	
	move.l	a1,d0
	bsr.l	affiche_nombre
	lea	nombre,a0
	lea	WORK_BUF,a1
	move.b	#'$',(a1)+
.copi	move.b	(a0)+,(a1)+
	bne.s	.copi
	subq.l	#1,a1
.copi1	move.b	(a2)+,(a1)+
	bne.s	.copi1
		
	lea	WORK_BUF,a1
	
	bra	.lo
	
.suite
	*--- ici on aura un nb de ligne on va devoir le convertir en adr et l'inserer dans la liste

	move.l	a2,a3
	lea	WORK_BUF,a1
.mp	move.b	(a2)+,d0
	tst.b	d0
	beq.s	.f_c
	cmp.b	#',',d0
	beq.s	.f_c
	move.b	d0,(a1)+
	bra.s	.mp
	
.f_c
	clr.b	(a1)+
	lea	WORK_BUF,a0
	
	
	bsr.l	eval
	tst.b	d2
	bne	.recom1
	
	tst.l	d1
	beq	.recom1
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	nb_ligne(a1),d0
	move.l	ptr_conv(a1),a1
	cmp.l	d0,d1
	bgt	.recom1
	
	
	move.l	(a1,d1.w*4),a1
	cmp.l	#-1,a1
	beq	.recom1
	
	*--- arrive ici, on a une adresse valide
	
	move.l	a1,d0
	bsr.l	affiche_nombre
	lea	nombre,a0
	lea	WORK_BUF,a1
	
	move.b	#'$',(a1)+
.copi2	move.b	(a0)+,(a1)+
	bne.s	.copi2
	subq.l	#1,a1
	move.b	#',',(a1)+
.copi3	move.b	(a2)+,(a1)+
	bne.s	.copi3
		
	lea	WORK_BUF,a1
	
	


.lo
	bsr.l	break_point
	
	tst.b	d0
	bne	.recom1
	bsr.l	set_40_flags
	rts

.p_source
.recom
	
	move.l	#MES_BKPT_USER,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq.s	.annule
	move.l	a2,a1				; dans a1 on a le debut de la chaine a exploiter
	bsr.l	break_point
	tst.b	d0
	bne.s	.recom
	bsr.l	set_40_flags
.annule
	rts
	endc
	
r_ctrl_a::
****************************************************		crtl a bkpt & run
** Routine qui place un bkpt et qui lance le prog **
****************************************************
	
	demo_mode?

	
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq	.source
	
	
	
	
	
	move.l	s_a0,anc_touche
	
	move.w	#1,LANCE_A
	move.l	#MES_RB,MESSAGE_ADR
	
	move.l	p_c,a4
	cmp.l	#$e00000,a4
	blt.s	.p_rom
	cmp.l	#$f00000,a4
	bgt.s	.p_rom
	
	
	*--- ici on prevoit un trace until pour la rom ---*
	
	move.w	#0,LANCE_A
	bsr.l	dessas_one_bk
	move.l	a4,adr_t_until
	move.l	#.TRACE_PC,adr_trace
	bra	.trace
.p_rom
	cmp.l	#$fa0000,a4
	blt.s	.p_cartouche
	cmp.l	#$fc0000,a4
	bgt.s	.p_cartouche
	
	*--- ici on prevoit un trace until pour la rom ---*
	
	bsr.l	dessas_one_bk
	move.l	a4,adr_t_until
	move.l	#.TRACE_PC,adr_trace
	bra	.trace
.p_cartouche
	
	
	
	clr.l	perm_bkpt
	
	
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt11
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt11
	
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
.p_bkpt11
	
	move.l	a4,a5
	bsr.l	dessas_one_bk
	move.l	a4,a0
	
	
	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	bne.s	.err111
	move.l	p_c,d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err11
.err111
	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err11
	
	
	*----- il faudra si on tombe sur un break point
	*----- parametre le remettre en suite
	
	tst.l	perm_bkpt
	beq.s	.rtyu
	
	move.w	(a5),(a1)
	move.w	type_ex,(a5)
	
.rtyu
	
	
	
	bsr.l	is_break			; verifie d'il y a deja un bkpt
	tst.w	bkpt
	bne.s	.oui
	
	
	
	move.l	a4,d0				; on place le bkpt
	move.l	#0,a1
	bsr.l	break_point	
.oui
	move.l	#go,-(sp)
	rts

;.ok2	
	;bra.s	.p_bkpt_para
	
	
	;move.w	2(a1),d0
	;cmp.b	#0,d0				; pas de bkpt parametre
	;beq.s	.p_bkpt_para
	;btst	#1,d0
	;bne.s	.p_bkpt_para			; on a deja un permanaent
	;bset	#1,d0
	;move.w	d0,2(a1)
	
	;move.l	a4,bkpt_flag 

;.p_bkpt_para
	
	move.l	#go,-(sp)
	rts

.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	move.l	p_c,a4
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err11
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err11	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?
	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
.p_bkpt

	;illegal

	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	bsr.l	sauve_anc_reg
	
	
	pea	(a0)
	move.w	#1,etat_trace		; on ne touche pas le resol
	cmp.w	#0,voir_ctrl_a
	beq.s	.p_voir
	lea	VIDEO_COU,a0		; ici on va installer l'ecran logique.
	bsr.l	SET_VIDEO
	move.w	#0,etat_trace
	move.w	#2,etat_trace		; va reforcer l'install_video sans sauve
.p_voir
	move.l	(sp)+,a0


	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	

	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse
	

	rte



.TRACE_PC				; routine de trace avec le pc
	move.w	#$2700,sr
	move.l	d0,-(sp)
	moveq	#0,d0
	move.b	$ffff8201.w,d0
	lsl.l	#8,d0	
	move.b	$ffff8203.w,d0
	lsl.l	#8,d0	
	move.b	$ffff820d.w,d0
	
	not.l	(d0.l)
	
	cmp.b	#$39,$fffffc02.w
	beq	.trace_f
	
	
	move.l	adr_t_until,d0
	cmp.l	6(sp),d0
	bne.s	.p_encore
.trace_f
	move.l	(sp)+,d0
	bra.l	TRACE
.p_encore
	move.l	(sp)+,d0
	bset	#7,(a7)
	
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse

	rte
	
	
.source
	move.l	s_a0,anc_touche
	
	move.w	#1,LANCE_A
	move.l	#MES_RB,MESSAGE_ADR
	
	
	move.l	p_c,a4
	
	
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_bkpt111
	move.w	2(a1),d0
	tst.b	d0				; test des flag : tous … 0 pas de bkpt
	beq.s	.p_bkpt111
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	move.w	(a1),(a4)
.p_bkpt111
	
	
	move.l	a4,d0
	bsr	trouve_ligne
	bsr	trouve_ligne_suivante
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	move.l	(a1,d0.w*4),a0
	move.l	a0,a4
	
	
	
	
	;bsr	dessas_one_bk
	;move.l	a4,a0
	
	
	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	bne.s	.err1112
	move.l	p_c,d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err112
.err1112
	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err112
	
	
	*----- il faudra si on tombe sur un break point
	*----- parametre le remettre en suite
	
	
	
	bsr.l	is_break
	tst.w	bkpt
	bne.s	.ok22
	
	move.l	a4,d0				; on place le bkpt
	move.l	#0,a1
	bsr.l	break_point	
	move.l	#go,-(sp)
	rts

.ok22
	move.w	2(a1),d0
	cmp.b	#0,d0				; pas de bkpt parametre
	beq.s	.p_bkpt_para2
	btst	#1,d0
	bne.s	.p_bkpt_para2			; on a deja un permanaent
	bset	#1,d0
	move.w	d0,2(a1)
	
	move.l	a4,bkpt_flag 

.p_bkpt_para2

	move.l	#go,-(sp)
	rts

	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	move.l	p_c,a4
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err112
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err2
.err112	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err2
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?
	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	


	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	
	
	move.w	#1,etat_trace		; on ne touche pas le resol
	cmp.w	#0,voir_ctrl_a
	beq.s	.p_voir2
	lea	VIDEO_COU,a0		; ici on va installer l'ecran logique.
	bsr.l	SET_VIDEO
	move.w	#0,etat_trace
	move.w	#2,etat_trace		; va reforcer l'install_video sans sauve
.p_voir2

	bsr.l	sauve_anc_reg

	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	

	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse
	

	rte

	
	
	
	endc


r_bis::
*************************************************
** routine qui va repeter la derniere commande **
** effectu‚e                                   **
*************************************************
	move.l	anc_touche,a0
	tst	a0
	beq.S	.p_touche
	move.l	anc_touche,s_a0
	jmp	([a0])
.p_touche
	rts

r_trace_until::
***************************************************
** routine qui trace jusqu'… ce que l'expression **
** donn‚e soit vraie. On aura 2 cas              **
***************************************************
	
	demo_mode?			; est on en demo?
	
	movem.l	d0-a6,-(sp)
	
.i
	move.l	#MES_UNTIL,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	bsr.l	get_key
	cmp.b	#1,d0
	beq	.annule

	cmp.b	#$12,d0			; E
	beq.s	.expression
	
	cmp.b	#$13,d0
	beq.s	.rte
	
	cmp.b	#$19,d0
	bne.s	.i
	
.err
	move.l	#MES_PC,a0		; on trace jusqu'… un pc donn‚
	bsr.l	GET_CHAINE
	tst.b	d0
	beq.s	.annule
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne	.err
	move.l	d1,adr_t_until
	movem.l	(sp)+,d0-a6
	move.l	#.TRACE_PC,adr_trace
	bra	.trace
	
	
	
	
.expression
	move.l	#MES_EXP,a0		; on trace jusqu'… un pc donn‚
	bsr.l	GET_CHAINE
	tst.b	d0
	beq.s	.annule
	move.l	a2,a0
	lea	temp,a2
.cop	move.b	(a0)+,(a2)+
	bne.s	.cop
	move.l	#.TRACE_EXP,adr_trace
	movem.l	(sp)+,d0-a6
	bra	.trace
	

.rte
	lea	.exp,a0
	lea	temp,a2
.cop1	move.b	(a0)+,(a2)+
	bne.s	.cop1
	move.l	#.TRACE_EXP,adr_trace
	movem.l	(sp)+,d0-a6
	bra	.trace
	
.annule
	movem.l	(sp)+,d0-a6
	
	rts

.exp	dc.b	'{pc}.w==4e73',0	
	even

.trace
	
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	move.l	p_c,a4
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err11
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err11	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	rec_history
	bsr.l	teste_fin			; l'exception termine t elle le prg ?
	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
	;move.l	p_c,a4
	;bsr	is_break
	;tst.w	bkpt
	;beq.s	.p_bkpt
	;move.w	2(a1),d0
	;tst.b	d0				; test des flag : tous … 0 pas de bkpt
	;beq.s	.p_bkpt
	;move.l	a4,perm_bkpt
	;move.w	(a4),type_ex
	;move.w	(a1),(a4)
.p_bkpt


	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	Restore_reg			; restauration des registre
	
	move.w	#0,LANCE_A
	move.w	#2,etat_trace

	bsr.l	sauve_anc_reg

	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	
	

	
	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse


	rte




.TRACE_PC				; routine de trace avec le pc
	move.w	#$2700,sr
	move.l	d0,-(sp)
	move.l	adr_t_until,d0
	cmp.l	6(sp),d0
	bne.s	.p_encore
	move.l	(sp)+,d0
	bra.l	TRACE
.p_encore
	move.l	(sp)+,d0
	bset	#7,(a7)

	vide_cache
	active_mouse

	rte

.TRACE_EXP				; routine de trace avec expression
	move.w	#$2700,sr
	move.l	2(sp),p_c
	move.l	a6,s_a6
	lea	buffer_r,a6
	movem.l	d0-a5,(a6)
	lea	buffer_r+r_a6,a6
	move.l	s_a6,(a6)+			;on est dans l'ordre d0-a7
	movec	usp,d0
	move.l	d0,(a6)+
	clr.l	d0
	move.w	(a7),d0
	move.l	d0,(a6)+			;le sr
	movec	isp,d0
	move.w	6(sp),d1
	lsr	#8,d1
	lsr	#4,d1
	move.l	p_c,(a6)+			;le pc
	move.l	d0,(a6)+			;le ssp	on va tester la longeur de l'empilement pour compenser la pile
	
	move.l	a7,a_pile
	lea	pile_prog,a7			; on installe notre pile
	

	lea	temp,a0
	bsr.l	eval
	tst.b	d2
	bne.s	.ok				; erreur, on arrete
	cmp.l	#1,d1
	bne.s	.rien
.ok
	
	
	lea	buffer_r+r_d0,a6
	movem.l	(a6)+,d0-a5
	move.l	buffer_r+r_a6,a6
	
	move.l	a_pile,a7
	bra.l	TRACE

	
	
	
.rien
	lea	buffer_r+r_d0,a6
	movem.l	(a6)+,d0-a5
	move.l	buffer_r+r_a6,a6
	
	
	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	
	move.l	a_pile,a7
	bset	#7,(a7)
	
	sf	user_int
	sf	flag_w
	
	vide_cache
	active_mouse
	
	rte
	
	

	endc
	


trace_until_exp
***************************************************************************************
** routine qui va trace jusqu'a une expression, sert surtout pour le trace en source **
***************************************************************************************

	demo_mode?			; est on en demo?



;.expression
;	move.l	#MES_EXP,a0		; on trace jusqu'… un pc donn‚
;	bsr.l	GET_CHAINE
;	tst.b	d0
;	
;	;beq.s	.annule
;	
;	move.l	a2,a0
;	lea	temp,a2
;.cop	move.b	(a0)+,(a2)+
;	bne.s	.cop
	move.l	#.TRACE_EXP,adr_trace

	;movem.l	(sp)+,d0-a6



.trace
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	move.l	p_c,a4
	lit_mem.w	a4,d0
	tst.b	ERR_MEM
	bne.s	.err11
	move.l	2(a5),d0				; teste la parit‚ du pc
	btst	#0,d0
	beq.s	.p_err
.err11	move.l	#MES_BAD_PC,MESSAGE_ADR
	rts
.p_err
	
	
	bsr.l	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr.l	teste_fin			; l'exception termine t elle le prg ?
	bsr.l	gestion_exeptions		; correction de la pile en fonction du format
	
	
	;move.l	p_c,a4
	;bsr	is_break
	;tst.w	bkpt
	;beq.s	.p_bkpt
	;move.w	2(a1),d0
	;tst.b	d0				; test des flag : tous … 0 pas de bkpt
	;beq.s	.p_bkpt
	;move.l	a4,perm_bkpt
	;move.w	(a4),type_ex
	;move.w	(a1),(a4)
.p_bkpt


	bsr.l	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	rec_history
	bsr.l	Restore_reg			; restauration des registre
	
	move.w	#0,LANCE_A
	move.w	#2,etat_trace

	bsr.l	sauve_anc_reg

	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	
	

	
	sf	user_int
	sf	flag_w

	vide_cache
	active_mouse


	rte

.TRACE_EXP				; routine de trace avec expression
	move.w	#$2700,sr
	move.l	2(sp),p_c
	move.l	a6,s_a6
	lea	buffer_r,a6
	movem.l	d0-a5,(a6)
	lea	buffer_r+r_a6,a6
	move.l	s_a6,(a6)+			;on est dans l'ordre d0-a7
	movec	usp,d0
	move.l	d0,(a6)+
	clr.l	d0
	move.w	(a7),d0
	move.l	d0,(a6)+			;le sr
	movec	isp,d0
	move.w	6(sp),d1
	lsr	#8,d1
	lsr	#4,d1
	move.l	p_c,(a6)+			;le pc
	move.l	d0,(a6)+			;le ssp	on va tester la longeur de l'empilement pour compenser la pile
	
	move.l	a7,a_pile
	lea	pile_prog,a7			; on installe notre pile
	

	lea	temp,a0
	bsr.l	eval
	tst.b	d2
	bne.s	.ok				; erreur, on arrete
	cmp.l	#1,d1
	bne.s	.rien
.ok
	
	
	lea	buffer_r+r_d0,a6
	movem.l	(a6)+,d0-a5
	move.l	buffer_r+r_a6,a6
	
	move.l	a_pile,a7
	bra.l	TRACE

	
	
	
.rien
	lea	buffer_r+r_d0,a6
	movem.l	(a6)+,d0-a5
	move.l	buffer_r+r_a6,a6
	
	
	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	
	
	move.l	a_pile,a7
	bset	#7,(a7)
	sf	user_int
	sf	flag_w
	
	
	vide_cache
	active_mouse
	
	rte
	
	

	endc




	
trouve_ligne::
*****************************************************************************
** routine qui renvoie dans d0 le num de ligne le plus proche en inferieur **
** dans d0 l'adresse a trouver en entree				   **
** dans a0 active_window                                                   **
*****************************************************************************
	movem.l	d1-a6,-(sp)
	
	moveq	#0,d1
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.w	nb_ligne(a1),d2
	subq	#1,d2
	bmi.s	.d	
	
.ll
	addq.L	#1,d1
	move.l	(a3,d1.l*4),d3
	cmp.l	#-1,d3
	beq.s	.inv
	
	cmp.l	d3,d0
	ble.s	.d
	move.w	d1,d4		; ligne valide
.inv

	dbra	d2,.ll
	clr.l	d0
	move.w	d4,d0		; on met la derniere ligne valide
	movem.l	(sp)+,d1-a6
	rts
	
	
	
.d
	cmp.l	d3,d0
	bne.s	.p_eg
	move.w	d1,d0
	tst.w	d0
	bne.s	.z
	move	#1,d0
.z
	movem.l	(sp)+,d1-a6
	rts
.p_eg
	move.w	d4,d0
	tst.w	d0
	bne.s	.z1
	move	#1,d0
.z1
	movem.l	(sp)+,d1-a6
	rts
	
trouve_ligne_suivante
*************************************************
** routine qui trouve la ligne suivante valide **
** parametres comme au dessus                  **
** sauf ligne dans d0 en entree au lieu de adr **
*************************************************
	
	movem.l	d1-a6,-(sp)
	
	move.w	d0,d1
	
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.w	nb_ligne(a1),d2
	cmp.w	d0,d2			; si c'est la derniere ligne
	beq.s	.d

	sub.w	d0,d2		; on prend le nb de ligne qui restent
	sub	#2,d2
	bmi.s	.d		; si le res est negatif on ne touche pas
	
.ll
	addq.w	#1,d1
	move.l	(a3,d1.w*4),d3
	cmp.l	#-1,d3
	bne.s	.d

	dbra	d2,.ll
	
	
	movem.l	(sp)+,d1-a6
	rts
	
	
	
.d
	move.w	d1,d0
	movem.l	(sp)+,d1-a6
	rts
	
	
	
	
	rts
	
r_skip::
***************************************		crtl s skip one
** Routine qui passe une instruction **
***************************************
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	beq.s	.source
	
	
	move.l	p_c,a4
	bsr.l	dessas_one_bk
	move.l	a4,p_c
	lea	buffer_r,a6			; on restore les registres
	move.l	a4,r_pc(a6)	
	move.l	a_pile,a6			; on restore le contexte de la pile
	move.l	a4,2(a6)	
	move.l	#MES_SKIPED,MESSAGE_ADR
	bsr.l	traite_le_pc
	bsr.l	set_40_flags
	rts
	
.source
	move.l	p_c,d0
	move.l	ACTIVE_WINDOW,a0
	bsr	trouve_ligne
	
	bsr	trouve_ligne_suivante
	
	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a3
	move.l	(a3,d0.w*4),p_c
	move.l	p_c,a4
	lea	buffer_r,a6			; on restore les registres
	move.l	a4,r_pc(a6)	
	move.l	a_pile,a6			; on restore le contexte de la pile
	move.l	a4,2(a6)	
	move.l	#MES_SKIPED,MESSAGE_ADR
	bsr.l	traite_le_pc
	bsr.l	set_40_flags
	

.p_valide

	rts
	







r_load::
*************************************		crtl l load
** routine qui charge un programme **
*************************************

	clr.w	CMD_L	
	
	tst.w	CHARGE_AUTO
	bne	.c_a
	
	tst.w	RESIDENT			; teste la residence
	beq.s	.suiv
	move.l	#MES_CENT_RESI,MESSAGE_ADR
	bsr.l	set_all_flags
	rts
.suiv
	tst.l	ADR_CHARGE			; teste si on a deja un prog en memoire
	beq.s	.ok_load
	move.l	#MES_PROG_EXIST,MESSAGE_ADR
	moveq	#-1,d0
	rts
.ok_load
	
	lea	MES_LOAD,a0
	lea	MASK,a1
	lea	name,a2
	
	xref	FILE_SELECTOR	
	bsr.l	FILE_SELECTOR	
	
	tst	d0
	bne	.xit
	
	;lea	name,a0
	
	;illegal
	
	
	lea	MES_CMD_LINE,a0
	jsr	GET_CHAINE
	tst.b	d0
	beq.s	.p_cmd_line
	lea	Com_line+1,a1
	move.w	#0,d1
.kl	move.b	(a2)+,(a1)+
	addq.w	#1,d1
	tst.b	(a2)
	bne.s	.kl
	
	move.b	d1,Com_line		; nb de caractere dans la chaine
	
	clr.b	(a1)
	st	CMD_L
	bra.s	.p_cmd_line	
	
.xit	move.l	#MES_SPACE,MESSAGE_ADR		; teste si on annule
	bsr.l	set_all_flags
	moveq	#-1,d0
	rts
.p_cmd_line
	


.c_a	
	lea	WORK_BUF,a0		; on v‚rifie que le fichier existe
	lea	name,a1			; sinon, on va lui ajouter diverses extentions
.e	move.b	(a1)+,(a0)+		; comme .prg .tos .ttp
	bne.s	.e
	
	lea	WORK_BUF,a0
	bsr	existe_f
	tst.b	d0
	beq	.ok_to_load

	lea	WORK_BUF,a0		; on v‚rifie que le fichier existe
	lea	name,a1			; sinon, on va lui ajouter diverses extentions
.e1	move.b	(a1)+,(a0)+		; comme .prg .tos .ttp
	bne.s	.e1
	subq.l	#1,a0
	move.l	#'.prg',(a0)+
	
	clr.b	(a0)
	
	lea	WORK_BUF,a0
	bsr	existe_f
	tst.b	d0
	beq	.ok_to_load

	lea	WORK_BUF,a0		; on v‚rifie que le fichier existe
	lea	name,a1			; sinon, on va lui ajouter diverses extentions
.e2	move.b	(a1)+,(a0)+		; comme .prg .tos .ttp
	bne.s	.e2
	subq.l	#1,a0
	move.l	#'.tos',(a0)+
	
	clr.b	(a0)
	
	lea	WORK_BUF,a0
	bsr	existe_f
	tst.b	d0
	beq.s	.ok_to_load


	lea	WORK_BUF,a0		; on v‚rifie que le fichier existe
	lea	name,a1			; sinon, on va lui ajouter diverses extentions
.e3	move.b	(a1)+,(a0)+		; comme .prg .tos .ttp
	bne.s	.e3
	subq.l	#1,a0
	move.l	#'.ttp',(a0)+
	
	clr.b	(a0)
	
	lea	WORK_BUF,a0
	bsr	existe_f
	tst.b	d0
	beq.s	.ok_to_load

	lea	WORK_BUF,a0		; on v‚rifie que le fichier existe
	lea	name,a1			; sinon, on va lui ajouter diverses extentions
.e4	move.b	(a1)+,(a0)+		; comme .prg .tos .ttp .app
	bne.s	.e4
	subq.l	#1,a0
	move.l	#'.app',(a0)+
	
	clr.b	(a0)
	
	lea	WORK_BUF,a0
	bsr	existe_f
	tst.b	d0
	beq.s	.ok_to_load


	; ici on aura une erreur de chargement
	sf	tempo1
	st	tempo
	move.l	#MES_ERREUR_LOAD,MESSAGE_ADR
	bsr.l	set_all_flags
	moveq	#-1,d0
	rts

.ok_to_load
	lea	WORK_BUF,a0		; on va recopier le contenu de work buf qui marche dans
	lea	name,a1			; name.
.ee	move.b	(a0)+,(a1)+	
	bne.s	.ee
	
	;lea	name,a1			; name.
	;illegal
	
	
	clr.w	CHARGE_AUTO
	bsr.L	load
	tst.b	d0
	bne.s	.cont1
	sf	tempo1
	st	tempo
	; le message d'erreur sera deja dans message adr
	bsr.l	set_all_flags
	rts
.cont1
	move.l	#MES_LOAD_OK+1,MESSAGE_ADR
	lea	MES_LOAD_OK,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	add.l	d0,a0
	move.b	#'$',(a0)+
	move.l	taille_fichier,d0
	jsr	affiche_nombre
	lea	nombre,a1
.t	move.b	(a1)+,(a0)+
	bne.s	.t	
	subq.l	#1,a0		; on affiche le nom du prog charge


	move.l	#' byt',(a0)+
	move.l	#'es (',(a0)+
	move.b	#"'",(a0)+
	lea	name,a1
.o	tst.b	(a1)+
	bne.s	.o
	subq.l	#1,a1
.o1	cmp.b	#'\',-(a1)
	beq.s	.o11
	tst.b	(a1)
	bne.s	.o1
	
.o11
	addq.l	#1,a1
	
.o2	move.b	(a1)+,(a0)+
	bne.s	.o2
	
	subq.l	#1,a0
	
	move	#"')",(a0)+
	move	#" "*256,(a0)+

	
	sf	tempo
	sf	tempo1


	st	prog_launch

	sf	CHARGE_AUTO
	move.l	fichier,d0
	move.l	usp,a0			; on place la base page dans la pile utilisateur
	move.l	d0,-(a0)
	clr.l	-(a0)
	lea	buffer_r,a6
	move.l	a0,r_a7(a6)
	bsr.l	traite_le_pc
	bsr	traite_hexascii
	bsr.l	set_40_flags
	moveq	#0,d0
	rts

*------------------------------------------------------------------------------
*traite_hexascii
*------------------------------------------------------------------------------
* force une fenetre hexascii a pointer sur le pc
* POUR LES COMMENTAIRES VOIR .TRAITE_encore_le_pc
*------------------------------------------------------------------------------
traite_hexascii
	move.l	p_c,d0
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP0	move.l	(a0)+,a1
	cmp	#T_HEXASCII16,type(a1)
	bne.s	.NEXT0	
	cmp.l	adr_debut(a1),d0
	blt.s	.NEXT0
	cmp.l	adr_fin(a1),d0
	bgt	.NEXT0
	bra.s	.FOUND			;le Pc est dans cette fenetre
.NEXT0	dbra	d7,.LOOP0
	
	*----------------------*
	* le PC n'est pas ds une fenetre de desas...
	* on prend la plus proche en adresse
	*----------------------*
	
	sub.l	a2,a2			;ptr fenetre … 0
	move.l	#$7fffffff,d2		;distance … max
	
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP	move.l	(a0)+,a1
	cmp	#T_HEXASCII16,type(a1)
	bne.s	.NEXT	
	
	move.l	adr_debut(a1),d3
	sub.l	d0,d3
	bpl.s	.POS
	neg.l	d3
.POS	cmp.l	d2,d3
	bgt	.SUP
	move.l	d3,d2
	move.l	a1,a2
.SUP	
	
	move.l	adr_fin(a1),d3
	sub.l	d0,d3
	bpl.s	.POS2
	neg.l	d3
.POS2	cmp.l	d2,d3
	bgt	.SUP2
	move.l	d3,d2
	move.l	a1,a2
.SUP2
.NEXT	dbra	d7,.LOOP

	tst.l	a2
	beq.s	.FOUND	
	
	*----------------------*
	* dans a2 on a la fenetre choisie
	*----------------------*
	
	move.l	d0,adr_debut(a2)

.FOUND	rts
	
	

	



existe_f
; sous routine qui va v‚rifier que le fichier point‚ par a0
; existe bien...
; d0=0 ok
; d0=1 pas trouv‚

	movem.l	d1-a6,-(sp)
	
	CENT_PROS
	
	
	move	#0,-(sp)
	pea	(a0)
	GEM	Fopen
	move.l	d0,d7
	bmi	.fichier_introuvable
	
	move	d7,-(sp)
	GEM	Fclose
	
	moveq	#0,d0
	REST_PROS
	movem.l	(sp)+,d1-a6
	rts
	
	
.fichier_introuvable
	moveq	#-1,d0
	REST_PROS
	movem.l	(sp)+,d1-a6
	rts



r_scr_b::
************************************
** Routine qui scroll vers le bas **
************************************
	xref	SCROLL_DOWN
	jsr	SCROLL_DOWN
	rts

r_scr_d::
***************************************
** Routine qui scroll vers la droite **
***************************************
	xref	SCROLL_RIGHT
	jsr	SCROLL_RIGHT
	rts

r_scr_g::
***************************************
** Routine qui scroll vers la gauche **
***************************************
	xref	SCROLL_LEFT
	jsr	SCROLL_LEFT
	rts

r_scr_b_v::
************************************
** Routine qui scroll vers le bas **
************************************
	xref	SCROLL_DOWN_VITE
	jsr	SCROLL_DOWN_VITE
	rts

r_scr_h::
*************************************
** Routine qui scroll vers le haut **
*************************************
	xref	SCROLL_UP
	jsr	SCROLL_UP
	rts

r_scr_h_v::
*********************************************************
** Routine qui scroll vers le haut plusieurs instructs **
*********************************************************
	xref	SCROLL_UP_VITE
	jsr	SCROLL_UP_VITE
	rts

r_commu::
*************************************				v commute les ecrans
** Routine qui commutte les ecrans **
*************************************
	xref	VIDEO_COU,CENTINEL_VIDEO,SET_VIDEO
	cmp.b	#0,COMMU
	bne.S	.commu
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO
	st	COMMU
	rts
.commu
	sf	COMMU
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
	rts

r_commu_david::
*************************************				v commute les ecrans
** Routine qui commutte les ecrans **
*************************************
	xref	VIDEO_COU,CENTINEL_VIDEO,SET_VIDEO
	cmp.b	#0,COMMU
	bne	.commu
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO
	lea	$44e,a0
	lit_mem.l		a0,d0
	move.b	d0,d1
	lsl.l	#8,d0
	lea	$ffff8201.w,a0
	movep.l	d0,(a0)
	move.b	d1,$ffff820d.w
	
	
	st	COMMU
	rts
.commu
	sf	COMMU
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
	rts

r_commu_vbr::
********************************************		v commute les ecrans
** Routine qui commutte les ecrans        **
** en repassant en IPL externe            **
** il faudra restaurer la routine clavier **
********************************************

	xref	VIDEO_COU,CENTINEL_VIDEO,SET_VIDEO
	cmp.b	#0,COMMU
	bne	.commu
	
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO
	
	
	vide_cache
	active_mouse

	move.l	buffer_r+r_sr,d0
	bset	#13,d0
	move.w	d0,sr
	
	bsr.l	flush_k_sys
	
	
.wait
	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13
	addq.l	#4,sp


	tst.b	d0
	beq.s	.wait		; pas de caractŠre => buffer vide
	

	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	

	cmp.b	#'v',d0
	beq.s	.ok_v
	cmp.b	#'V',d0
	bne.s	.wait
.ok_v
	
	bsr.l	flush_k_sys
	
	
	move.w	#$2700,sr
	move.b	#$12,$fffffc02.w
	
	
	
	lea	VIDEO_COU,a0
	bsr.l	SAVE_VIDEO
	
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
	
	
	rts
.commu
	rts

r_copy::
*************************************************
** routine qui va copier un morceau de memoire **
** sur un autre                                **
*************************************************
	xref	copy

	jsr	copy
	bsr.l	forme_bra
	bsr.l	set_40_flags
	
	rts

r_fill::
*************************************************
** routine qui va remplir la memoire en byte   **
*************************************************
	xref	fill

	jsr	fill
	bsr.l	forme_bra
	bsr.l	set_40_flags
	
	rts


r_vbr::
***********************************
**vbr
** routine qui va decaler le vbr **
***********************************
	
	tst.w	VBR_FLAG
	bne.s	.o
	st	VBR_FLAG
	
	
	move.l	buffer_r+r_vrb,ANC_VBR1		; on sauve l'ancien vbr
	
	move.l	#vbr_deviation,d0
	lea	buffer_r,a6
	move.l	d0,r_vrb(a6)
	
	movec	d0,vbr
	move.l	d0,ADR_VBR
	move.l	#MES_VBR_SHIFT,MESSAGE_ADR
	
	;move.l	BKPT_VECT,a0		; on recale le bkpt
	;move.l	#TRACE,(a0)
	
	bsr.l	set_40_flags
	
	rts

.o
	move.l	ADR_VBR,d0		; on va regarder si un prog a d‚caler le vbr
	cmp.l	buffer_r+r_vrb,d0	; si c'est le cas, on ne replace pas le vbr
	bne.s	.p_egal
	
	move.l	ANC_VBR,d0
	sf	VBR_FLAG
	move.l	ANC_VBR,d0
	lea	buffer_r,a6
	move.l	d0,r_vrb(a6)
	movec	d0,vbr
	move.l	d0,ADR_VBR

	move.l	#MES_VBR_UNSHIFT,MESSAGE_ADR
	bsr.l	set_40_flags
	rts

.p_egal
	move.l	#MES_VBR_CAN_UNSHIFT,MESSAGE_ADR
	bsr.l	set_40_flags
	rts


************************************************
** Routine qui lance le programme directement **
************************************************





r_go::	

	demo_mode?
	

	addq	#4,sp
	move.l	s_a0,anc_touche

	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	
	move.l	(a6),2(a5)
	move.l	(a6),a5
	
	lit_mem.w	a5,d7			; ici on va regarder si on a un illegal
	move.l	p_c,a4				; si oui et que ce n'est pas un bkpt
	bsr.l	is_break			; alors, on saute l'instruction et on lance
	tst.w	bkpt
	bne.s	.p_bbb
	cmp.w	#$4afc,d7
	bne.s	.p_bbb
	addq.l	#2,p_c
	move.l	p_c,buffer_r+r_pc
	move.l	a_pile,a5
	addq.l	#2,2(a5)
	
.p_bbb
	
	
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO
	move.w	#0,etat_trace
;go1	
	bsr.l	get_function_trap
	bsr.l	teste_fin	
	bsr.l	gestion_exeptions


	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq	.p_bkpt
	move.w	2(a1),d0
	btst	#1,d0			; de le bit de permanance
	beq	.p_bkpt
	
	
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	
	move.w	(a1),(a4)


	*---on peut aussi lancer le prg sur une instruction---*
	*---de brachement et ne pas s'arreter si on v‚rifie---*
	*---que le bkpt derriŠre                           ---*


	;bsr	dessas_one_bk
	
	;bsr	is_break		; pas de break derriere instruct
	;tst.w	bkpt
	;beq.s	.p_b
	;bra	.p_bkpt			; s'il y en a un on ne met pas le trace
	
.p_b

	bsr.l	Restore_reg
	bsr.l	rec_history

	pea	(a0)
	move.l	#$24,a0			
	add.l	ADR_VBR,a0		
	move.l	#TRACE_EXCEP,(a0)	; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	bset	#7,(a7)			; place le trace pour un coup
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	
	rte
	
.p_bkpt
	bsr.l	Restore_reg		
	
	
	
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	bclr	#7,(a7)			; enleve le trace
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	rte
	endc


********************************************
** routine a laquelle va sauter le ctrl_a **
** si il en a besoin                      **
********************************************

go	
	;demo_mode?
	
	move.l	s_a0,anc_touche
	lea	buffer_r+r_pc,a6
	move.l	a_pile,a5
	move.l	(a6),2(a5)
	
	move.w	#1,etat_trace			; teste si on doit installer l'ecran logique
	cmp.w	#0,voir_ctrl_a
	beq.s	.p_voir
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO
	move.w	#2,etat_trace
.p_voir

go1::
	move.l	s_a0,anc_touche
	bsr.l	get_function_trap
	bsr.l	teste_fin	
	bsr.l	gestion_exeptions
	
	
	
	move.l	p_c,a4
	bsr.l	is_break
	tst.w	bkpt
	beq	.p_bkpt
	move.w	2(a1),d0
	btst	#1,d0			; de le bit de permanance
	beq	.p_bkpt
	
	
	move.l	a4,perm_bkpt
	move.w	(a4),type_ex
	
	move.w	(a1),(a4)

	
	; *** routine en cas de bkpt parametres ***
	
	bsr.l	Restore_reg
	bsr.l	rec_history

	pea	(a0)
	move.l	#$24,a0			
	add.l	ADR_VBR,a0		
	move.l	#TRACE_EXCEP,(a0)	; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	bset	#7,(a7)			; place le trace pour un coup
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	
	rte
	
	
	
.p_bkpt
	bsr.l	Restore_reg			; ici on remet aussi le trace
	bsr.l	rec_history
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	bclr	#7,(a7)				; enleve le trace
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	
	rte
	
	;endc




r_change_d::
**************************************************
** routine qui va changer le repertoire courant **
**************************************************
	
	
	CENT_PROS
	
	
	lea	MES_DIRECTORY,a0


	jsr	GET_CHAINE
	tst.b	d0
	bne.s	.cont
	
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_all_flags
	rts
.cont
	move.w	#$2300,sr
	
	cmp.b	#':',1(a2)
	bne.s	.p_drv
	
	
	cmp.b	#'a',(a2)
	blt	.p_minus
	
	sub.b	#32,(a2)
	
	
.p_minus
	moveq	#0,d0
	move.b	(a2),d0
	sub.b	#'A',d0
	move.w	d0,-(sp)
	GEM	Dsetdrv
	
.p_drv
	pea	(a2)
	move.w	#$3b,-(sp)			;Dsetpath
	trap	#1
	addq.l	#6,sp
	move.w	#$2700,sr
	
	tst.w	d0
	bne.s	.erreur
		
	move.l	#MES_OK,MESSAGE_ADR
	bsr.l	set_all_flags
	REST_PROS
	rts
	
.erreur
	move.l	#MES_ERREUR_PATH,MESSAGE_ADR
	bsr.l	set_all_flags
	REST_PROS
	rts
	
r_save_binary::
***************************************************
** routine qui va faire la sauvegarde en binaire **
***************************************************
.encore
.j
	CENT_PROS
	
	move.l	#MES_S_BINARY,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.annule

	
	move.l	a2,a0			; cherche s'il y a un virgule
	move.l	a2,a4
.ch	cmp.b	#',',(a0)
	beq.s	.ok1
	tst.b	(a0)+			; non ? => erreur
	bne.s	.ch
	bra.s	.j	
.ok1
	clr.b	(a0)		;a5 point sur le nom
	move.l	a0,a6
	
	addq.l	#1,a0
.ch1	cmp.b	#',',(a0)
	beq.s	.ok2
	tst.b	(a0)+
	bne.s	.ch1
	bra.s	.j	
.ok2
	clr.b	(a0)
	move.l	a0,a5
	move.l	a6,a0
	addq.l	#1,a0
	
	bsr.l	eval
	tst.b	d2
	bne	.j
	
	move.l	d1,d4		; sauvegarde de d1
	
	
	move.l	a5,a0
	addq.l	#1,a0
	tst.b	(a0)
	beq	.j
	bsr.l	eval
	tst.b	d2
	bne	.j
	move.l	d1,d2		; pareil, mais 3eme parametre dans d2
	
	move.l	d4,d1		; restauration de d1
	
	* d1=source d2=longueur a5: adr
	
	move.l	a4,a1
	move.l	d1,a0
	move.l	d2,d1
	
	
	
	bsr.l	save_binary

	bsr.l	set_all_flags
	REST_PROS
	rts	
.annule
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_all_flags
	REST_PROS
	rts
	
	
	
r_load_binary::
************************************
** routine qui va lire en binaire **
************************************
.encore
	CENT_PROS
	
	;ifne	0
	lea	MES_LOAD_B,a0
	lea	MASK,a1
	lea	name,a2
	
	xref	FILE_SELECTOR	
	bsr.l	FILE_SELECTOR	
	
	tst	d0
	bne	.annule	
	
	;endc	

	move.l	#MES_OPT_BIN,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	bne.s	.suite
	lea	name,a2
	bra	.lit
.suite
	move.l	a2,a0
	lea	name,a2

	
;.analyse
	;move.b	(a0)+,d0
	;beq	.lit
	;cmp.b	#',',d0
	;bne.s	.analyse
	; on a une virgule
	;clr.b	-1(a0)		; on met un zero pour recuperer le nom 
	cmp.b	#',',(a0)	; on regarde s'il y a une virgule qui suit
	beq	.p_adr
	
	; ici, on a une adresse de debut
	move.l	a0,a1
.k	move.b	(a1)+,d0
	beq	.adr_seule	; ici on va charger a une adresse fixe une fichier de taille variable
	cmp.b	#',',d0
	bne.s	.k
	
	clr.b	-1(a1)
	
		
	bsr.l	eval
	tst.b	d2
	bne	.encore
	
	move.l	d1,a6		; adr de debut
	
	
	move.l	a1,a0
	bsr.l	eval
	tst.b	d2
	bne	.encore
	move.l	d1,d6
	
	
	move	#0,-(sp)
	pea	(a2)
	GEM	Fopen
	move.l	d0,d7
	bmi	.fichier_introuvable

	move.l	a6,d0

	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
	
		
	move	d7,-(sp)
	GEM	Fclose
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	a6,adr_debut(a0)
	bra	.exit
	
	
	
	
	
	
	
	
	
	
	
.adr_seule			; on va charger a une adresse fixe
	bsr.l	eval
	tst.b	d2
	bne	.encore
	
	move.l	d1,a6
	
	
	move	#0,-(sp)
	pea	(a2)
	GEM	Fopen
	move.l	d0,d7
	bmi	.fichier_introuvable
	*-------------------*
	* Calcul de la taille
	* du fichier....
	* par 2 FSEEK
	*-------------------*

	move	#2,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)	
	GEM	Fseek		;va … la fin

	move.l	d0,d6
		
	
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut
	
	move.l	a6,d0
	
	
	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
	
		
	move	d7,-(sp)
	GEM	Fclose
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	a6,adr_debut(a0)
	bra	.exit
	
	
	
.p_adr				; pas_d'adresse de debut
	addq.l	#1,a0
	bsr.l	eval
	tst.b	d2
	bne	.encore
	
	; dans d1 on a la taille que l'on veut charger
	
	move.l	d1,d6
	
	move	#0,-(sp)
	pea	(a2)
	GEM	Fopen
	move.l	d0,d7
	bmi	.fichier_introuvable
	
	bra.s	.malloc
	


.lit
	; a2 pointe sur le nom
	
	move	#0,-(sp)
	pea	(a2)
	GEM	Fopen
	move.l	d0,d7
	bmi	.fichier_introuvable
	*-------------------*
	* Calcul de la taille
	* du fichier....
	* par 2 FSEEK
	*-------------------*

	move	#2,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)	
	GEM	Fseek		;va … la fin

	move.l	d0,d6
		
	
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut
	

	*-------------------*
	* MALLOC...
	*-------------------*
.malloc
	move.l	d6,-(sp)
	GEM	Malloc		;Malloc(size)
	tst.l	d0
	beq	.plus_de_mem	
	move.l	d0,a6
	

	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
	
		
	move	d7,-(sp)
	GEM	Fclose
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	a6,adr_debut(a0)
	
	lea	liste_mfree,a0
.s	tst.l	(a0)+
	bne.s	.s
	subq.l	#4,a0
	move.l	a6,(a0)			; on sauve l'adresse pour faire un mfree a la fin
	
.exit
	move.l	#MES_OK,MESSAGE_ADR
	bsr.l	set_all_flags
	REST_PROS
	rts
.annule
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_all_flags
	rts
	
.plus_de_mem
	move.l	#MES_PLUS_MEM,MESSAGE_ADR
	bsr.l	set_all_flags
	
	move	d7,-(sp)		; on ferme quand meme le fichier
	GEM	Fclose
	
	REST_PROS
	rts
.fichier_introuvable
	move.l	#MES_INTOUV,MESSAGE_ADR
	bsr.l	set_all_flags
	REST_PROS
	rts
	
	
r_catch_trap_perm::
*****************************************************
** routine qui va detourner les trap en permanance **
*****************************************************
		
	
	move.l	#1<<11,d4			; permanent
	move.l	#MES_DET_PERM,a6
	
	
	
	bra.s	catch_perm

	
	
	
r_catch_trap::
************************************
** routine qui detourner les trap **
************************************

	moveq	#0,d4			; non permanent
	move.l	#MES_DET,a6
	
catch_perm


.encore
	move.l	a6,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.annule
	
	
	;move.w	#$f00,d7		; toutes les fonctions
	move.w	#$100,d7		; toutes les fonctions
	clr.l	d6
	clr.l	d3
		
	move.l	a2,a0
.cherche_v
	move.b	(a0)+,d0
	beq	.p_virgule
	cmp.b	#',',d0
	bne.s	.cherche_v
	
	clr.b	-1(a0)
	move.l	a0,a3		; on va chercher si on a aes ou vdi ecrit
.ch_a_v
	move.b	(a0)+,d0
	beq.s	.p_aes_vdi
	cmp.b	#',',d0
	bne.s	.ch_a_v
	
	cmp.l	#',aes',-1(a0)
	bne.s	.p_a
	bset	#b_aes,d6
.p_a
	cmp.l	#',AES',-1(a0)
	bne.s	.p_a_m
	bset	#b_aes,d6
.p_a_m
	cmp.l	#',vdi',-1(a0)
	bne.s	.p_v
	bset	#b_vdi,d6
.p_v
	cmp.l	#',VDI',-1(a0)
	bne.s	.p_v_m
	bset	#b_vdi,d6
.p_v_m
	clr.b	-1(a0)
	
.ch_s_fct			; on regarde si on a un num de ss_fct
	move.b	(a0)+,d0
	beq.s	.p_aes_vdi
	cmp.b	#',',d0
	bne.s	.ch_s_fct
	clr.b	-1(a0)
	bsr.l	eval
	tst.b	d2	
	bne	.encore
	move.l	d1,d3		; le num de la sous fonction
	
	; ici il faudra regarde le num‚ro de ss fct
	
.p_aes_vdi
	move.l	a3,a0
	bsr.l	eval
	tst.b	d2
	bne	.encore
	move.l	d1,d7		; dans d7 le num de la fonction a detouner
	or.l	d6,d7
	tst.l	d3		; on regarde s'il y a des ss fct
	beq.s	.p_s_fct
	btst	#b_vdi,d7	; forcement une fonction vdi
	beq	.encore
	cmp.w	#5,d1
	bne.s	.k
	bset	#b_esc,d7
	and.w	#$f000,d7
	move.b	d3,d7
	bra.s	.p_s_fct
.k
	cmp.w	#11,d1
	bne.s	.d
	bset	#b_gfx,d7
	and.w	#$f000,d7
	move.b	d3,d7
	bra.s	.p_s_fct
.d
	bra	.encore		; on a pas le num principal qui correspond
	
.p_s_fct
	
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne	.encore		; dans d1 le num du trap
		
	bra.s	.virgule	
	
.p_virgule
	bsr	teste_fonction
	tst.b	d2
	beq.s	.virgule

	move.l	a2,a0
	bsr.l	eval
	tst.b	d2	
	bne	.encore		; dans d1 le num du trap

.virgule
	cmp.b	#1,d1
	blt	.encore
	
	cmp.b	#15,d1
	bgt	.encore
	
	
	cmp.b	#2,d1		; on teste que l'on a ou une vdi ou une aes de valide
	bne.s	.p_t_2
	move.w	d7,d5
	and.w	#%111111111,d5
	cmp.w	#$100,d5
	beq.s	.p_t_2
	move.w	d7,d2
	and.w	#%1100000000000000,d2
	tst.w	d2
	beq	.encore
.p_t_2
	
	; dans d1 le num du trap a detouner
	; si d7<>-1 alors num de la fonction a detouner
	
	
	** c'est ici que je vais mettre les bits correspondants dans d7 **
	
	;bset	#b_vdi,d7
	;bset	#b_esc,d7
	;bset	#b_gfx,d7
	

	;addq.w	#1,nb_fct_det
	;cmp.w	#51,nb_fct_det
	;bne.s	.p_limite
	;move.l	#MES_TROP_FCT,MESSAGE_ADR
	;bsr.l	set_all_flags
	;rts
;.p_limite


	lea	table_trap,a0		; on remplie la table de detournement
	moveq	#15,d0			; en fait, on la met a jour
	lea	$80.w,a2
	add.l	ADR_VBR,a2
.cop_t1	move.l	(a2)+,d2
	cmp.l	#TRACE,d2
	beq.s	.pas_detourne
	move.l	d2,(a0)
.pas_detourne
	addq.l	#4,a0
	dbra	d0,.cop_t1
	



	
	move.w	nb_fct_det,d0
	subq.l	#1,d0
	lea	table_fct_det,a0
	cmp.w	#$ffff,d0
	beq.s	.premiere_fois
.cher_t
	cmp.w	(a0),d1
	bne.s	.p_ici
	move.w	2(a0),d6
	move.w	d7,d5
	and.w	#%1111001111111111,d6
	and.w	#%1111001111111111,d5
	cmp.w	d5,d6
	bne.s	.p_ici
	; on a deja cette fonction dans la liste, on va l'enlever

	bsr	enleve_fonction
	subq.w	#1,nb_fct_det
	
	
	; ici on va afficher que l'on a enlev‚ ce detournement
	
	bra.s	.efface
	
.p_ici
	addq.l	#8,a0		; on se positionne au bon endroit dans la table
	dbra	d0,.cher_t
	
	
	
.premiere_fois
	addq.w	#1,nb_fct_det
	move.w	d1,d0
	move.w	d1,(a0)+		; on stocke le num du trap

	;illegal

	or.w	d4,d7

	move.w	d7,(a0)+		; on stocke le num de la fct 
	lsl	#2,d1
	add.l	#$80,d1
	add.l	ADR_VBR,d1
	move.l	d1,a1
	move.l	(a1),(a0)		; on sauve l'ancienne adresse

	
	;lea	table_trap,a0		; place directement dans le catch exception
	;moveq	#15,d0
	;lea	$80.w,a2
	;add.l	ADR_VBR,a2
.cop_t	;move.l	(a2)+,(a0)+
	;dbra	d0,.cop_t	
	


	move.l	#TRACE,(a1)	
	
	lea	MES_FONC_DET,a0
	
	move.w	d0,d1
	bsr	prepare_fct_det
	
	
	
	
	
	
	move.l	#MES_FONC_DET,MESSAGE_ADR
	bsr.l	set_all_flags

	rts
.annule
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_all_flags
	rts	
	
.efface
	lea	MES_FONC_DET_D,a0
	bsr	prepare_fct_det
	move.l	#MES_FONC_DET_D,MESSAGE_ADR
	bsr.l	set_all_flags
	rts
	
	
enleve_fonction::
; sous routine de r_catch_trap
; qui va enlever un detounement de fonction dans la liste
; d1	num du trap
; d7	num de la fct a detourner
; a0	pointe sur l'adresse a enlever

	movem.l	d0-a6,-(sp)
	
	moveq	#0,d2
	
	lea	table_fct_det,a1	; on va compter combien d'‚l‚ment avant l'adr
.che	cmp.l	a1,a0
	beq.s	.ok_adr
	addq.l	#1,d2
	addq.l	#8,a1
	bra.s	.che
	
.ok_adr
	moveq	#0,d3
	move.w	nb_fct_det,d3
	sub.l	d2,d3		; nb de fois a copier
	subq.l	#1,d3
.degomme
	move.l	8(a0),(a0)
	move.l	12(a0),4(a0)
	addq.l	#8,a0
	dbra	d3,.degomme

	lea	table_fct_det,a1	; verifie s'il reste un detounement
	move.w	nb_fct_det,d3		; correspondant au trap 
	subq.w	#1,d3			; sinon au restaure l'ancien vecteur
.sup
	cmp.w	(a1),d1
	beq.s	.il_reste		; on ne fait rien
	addq.l	#8,a1
	dbra	d3,.sup
	
	move.w	d1,d3			; on restaure l'ancienne adresse
	lsl	#2,d3
	add.l	#$80,d3
	add.l	ADR_VBR,d3
	lea	table_trap,a0
	move.l	(a0,d1.w*4),a0
	move.l	d3,a1
	move.l	a0,(a1)
	
.il_reste
	movem.l	(sp)+,d0-a6
	rts
	
prepare_fct_det::
; sous routine qui va complete le message contenu dans a0
; en affichant le nom du trap et de la fonction s'ils existent
; d1 contient le num du trap
; d7 contienr le num de fct	


***** attention il faudra comparer si le nombre est dans le tableau


	movem.l	d0-a6,-(sp)
	
.ch_d	cmp.b	#':',(a0)+
	bne.s	.ch_d
	move.b	#' ',(a0)+


	cmp.w	#1,d1
	beq.s	.fct
	cmp.w	#2,d1
	beq.s	.fct
	cmp.w	#13,d1
	beq.s	.fct
	cmp.w	#14,d1
	beq.s	.fct
	bra	.pas_fct

	


.fct
	
	btst	#b_aes,d7		; on adresse correctement l'aes/vdi
	beq.s	.p_aes_g
	move.w	#2,d1
.p_aes_g
	btst	#b_vdi,d7		; vdi
	beq.s	.p_vdi_g
	move.w	#16,d1
.p_vdi_g
	btst	#b_esc,d7		; esc /vdi
	beq.s	.p_esc_g
	move.w	#18,d1
.p_esc_g
	btst	#b_gfx,d7		; gfx /vdi
	beq.s	.p_gfx_g		
	move.w	#17,d1
.p_gfx_g
	
	move.w	d7,d6
	and.w	#$1ff,d6
	cmp.w	#$100,d6
	beq.s	.trap_t_cours
	lea	table_num_max_ex,a5
	move.w	(a5,d1.w*2),d4
	cmp.w	d6,d4
	blt.s	.p_nom_fct
	
	lea	fonction_type,a6
	move.l	(a6,d1.w*4),a6
	move.l	(a6,d6.w*4),a6
	
	
	tst.b	(a6)
	beq.s	.p_nom_fct			; si le nom vaut zero
	

.cop2	move.b	(a6)+,(a0)+
	bne.s	.cop2


	bra.s	.quit
	

.p_nom_fct
	; nom de fct inconnu
	
	lea	MES_INCONNU,a1		; ici on a un trap connu, mais une
.cop3	move.b	(a1)+,(a0)+		; fct inconnue
	bne.s	.cop3
	
	subq.l	#1,a0
	
	move.b	#' ',(a0)+
	move.b	#',',(a0)+
	move.b	#' ',(a0)+



.trap_t_cours
	
	
	btst	#b_aes,d7		; on adresse correctement l'aes/vdi
	beq.s	.p_aes_g1
	move.w	#17,d1
.p_aes_g1
	btst	#b_vdi,d7
	beq.s	.p_vdi_g1
	move.w	#16,d1
.p_vdi_g1
	
	lea	fonction_name,a6
	move.l	(a6,d1.w*4),a1
	;lsl.w	#2,d1
	;add.w	d1,a6	
.cop1	move.b	(a1)+,(a0)+
	bne.s	.cop1

	bra.s	.quit

.pas_fct
	lea	MES_INCONNU,a1
.cop	move.b	(a1)+,(a0)+
	bne.s	.cop

.quit

	clr.b	(a0)



	movem.l	(sp)+,d0-a6
	rts


teste_fonction
***************************************
** dans a2 on a la chaine a analyser **
**      d7 num de fct                **
**      d1 num du trap               **
***************************************
	
	movem.l	d0-d1/d3-a6,-(sp)

	move.l	a2,a6		; sauvegarde su poineur pour une autre recherche

	move.w	table_au_t,d0	; dans d0 le nb de fct
	addq.l	#1,d0

	lea	table_num_max_ex,a0	; nb de fct par categorie
	lea	fonction_type,a1	; pointeur dur le debut des tableaux

.cherche	
	subq.w	#1,d0
	beq	.pas_t
	move.w	(a0)+,d1		; nb de fct
	moveq	#0,d4
	move.w	d1,d4			; copie de nb de fct
	tst.b	d1
	bne.s	.ch
	addq.l	#4,a1
	bra.s	.cherche
.ch
	addq.l	#1,d1
	move.l	(a1)+,a3			; pointeur sur la chaine de fct
.ch1
	move.l	(a3)+,a4		; dans a4 le nom de la fonction
	move.l	a2,a5
	
.yes
	move.b	(a5)+,d6		; lettre de comp
	cmp.b	#'Z',d6			; on met tout en minuscule
	bgt.s	.p_case
	cmp.b	#'A',d6
	blt.s	.p_case
	add.b	#32,d6
.p_case
	
	move.b	(a4)+,d7		; lettre dans le tab
	cmp.b	#'Z',d7			; on met tout en minuscule
	bgt.s	.p_case1
	cmp.b	#'A',d7
	blt.s	.p_case1
	add.b	#32,d7
.p_case1
	
	tst.b	d7
	bne.s	.s
	tst.b	d6
	beq.s	.trouve
	bra.s	.no
.s
	tst.b	d6
	bne.s	.s1
	tst.b	d7
	beq.s	.trouve
	bra.s	.no
.s1
	
	
	
	; si d7 et d6 =0 alors ok
	
	cmp.b	d6,d7
	beq.s	.yes

.no
	subq	#1,d1
	bne.s	.ch1
	
	bra.s	.cherche
	
.trouve

	sub.w	d1,d4
	addq.l	#1,d4
	
	moveq	#0,d7
	move	table_au_t,d7
	sub	d0,d7
	
	
	cmp.w	#2,d7
	bne.s	.p_aes
	bset	#b_aes,d4
.p_aes
	cmp.w	#16,d7
	bne.s	.p_vdi
	bset	#b_vdi,d4
	move.w	#2,d7
.p_vdi
	cmp.w	#17,d7
	bne.s	.p_gfx
	bset	#b_vdi,d4
	bset	#b_gfx,d4
	move.w	#2,d7
	
.p_gfx
	cmp.w	#18,d7
	bne.s	.p_esc
	bset	#b_vdi,d4
	bset	#b_esc,d4
	move.w	#2,d7
	
.p_esc
	
	
	
	
	
	xref	WORK_BUF
	lea	WORK_BUF,a0
	move.l	d4,(a0)+
	move.l	d7,(a0)+


	moveq	#0,d2
	movem.l	(sp)+,d0-d1/d3-a6
	
	lea	WORK_BUF,a0
	move.l	(a0)+,d7
	move.l	(a0)+,d1
	

	
	rts

.pas_t

	*----- si on arrive ici, c'est que le nom ne correspond a rien dans la table
	*----- on va alors cherche un nom proche dans la table



	move.l	a6,a2		; on recommence la recherche



	move.w	table_au_t,d0	; dans d0 le nb de fct
	addq.l	#1,d0

	lea	table_num_max_ex,a0	; nb de fct par categorie
	lea	fonction_type,a1	; pointeur dur le debut des tableaux

.cherche1	
	subq.w	#1,d0
	beq	.pas_t1
	move.w	(a0)+,d1		; nb de fct
	moveq	#0,d4
	move.w	d1,d4			; copie de nb de fct
	tst.b	d1
	bne.s	.ch10
	addq.l	#4,a1
	bra.s	.cherche1
.ch10
	addq.l	#1,d1
	move.l	(a1)+,a3			; pointeur sur la chaine de fct
.ch110
	move.l	(a3)+,a4		; dans a4 le nom de la fonction
	move.l	a2,a5
	
.yes1
	move.b	(a5)+,d6		; lettre de comp
	cmp.b	#'Z',d6			; on met tout en minuscule
	bgt.s	.p_case10
	cmp.b	#'A',d6
	blt.s	.p_case10
	add.b	#32,d6
.p_case10
	
	move.b	(a4)+,d7		; lettre dans le tab
	cmp.b	#'Z',d7			; on met tout en minuscule
	bgt.s	.p_case12
	cmp.b	#'A',d7
	blt.s	.p_case12
	add.b	#32,d7
.p_case12
	
	tst.b	d7
	bne.s	.s10
	tst.b	d6
	beq.s	.trouve2
	bra.s	.no1
.s10
	tst.b	d6
	bne.s	.s12
	bra.s	.trouve2
	bra.s	.no1
.s12
	
	
	
	; si d7 et d6 =0 alors ok
	
	cmp.b	d6,d7
	beq.s	.yes1

.no1
	subq	#1,d1
	bne.s	.ch110
	
	bra.s	.cherche1
	
.trouve2

	sub.w	d1,d4
	addq.l	#1,d4
	
	moveq	#0,d7
	move	table_au_t,d7
	sub	d0,d7
	
	
	cmp.w	#2,d7
	bne.s	.p_aes1
	bset	#b_aes,d4
.p_aes1
	cmp.w	#16,d7
	bne.s	.p_vdi1
	bset	#b_vdi,d4
	move.w	#2,d7
.p_vdi1
	cmp.w	#17,d7
	bne.s	.p_gfx1
	bset	#b_vdi,d4
	bset	#b_gfx,d4
	move.w	#2,d7
	
.p_gfx1
	cmp.w	#18,d7
	bne.s	.p_esc1
	bset	#b_vdi,d4
	bset	#b_esc,d4
	move.w	#2,d7
	
.p_esc1
	
	
	
	
	
	xref	WORK_BUF
	lea	WORK_BUF,a0
	move.l	d4,(a0)+
	move.l	d7,(a0)+


	moveq	#0,d2
	movem.l	(sp)+,d0-d1/d3-a6
	
	lea	WORK_BUF,a0
	move.l	(a0)+,d7
	move.l	(a0)+,d1
	

	
	rts











.pas_t1
	moveq	#-1,d2
	movem.l	(sp)+,d0-d1/d3-a6
	rts



r_eff_trap::
*******************************************************
** routine qui va effacer la liste de trap detourn‚s **
*******************************************************


	move.l	#MES_EFF_TRAP,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	
	sf	tempo1
	sf	tempo
	
	bsr.l	get_key
	
	cmp.b	#$15,d0
	beq.s	.yes
	cmp.b	#$18,d0
	beq.s	.yes
	
	bra	.non
	
	
.yes
	
	
	moveq	#49,d0			; on efface le tableau
	lea	table_fct_det,a0
.k	clr.l	(a0)+	
	clr.l	(a0)+	
	dbra	d0,.k


	lea	table_trap,a0		; on restaure les traps
	lea	$80.w,a1
	add.l	ADR_VBR,a1
	moveq	#15,d0
.kol	move.l	(a0)+,(a1)+
	dbra	d0,.kol


	move.w	#0,nb_fct_det

	move.l	#MES_OK,MESSAGE_ADR
	bsr.l	set_all_flags
	


	rts

.non
	move.l	#MES_SPACE,MESSAGE_ADR
	bsr.l	set_all_flags
	rts



r_update::
*****************************************
** routine qui va mettre a jour la mmu **
*****************************************
	
	
	
	lea	buffer_r,a6
	lea	buffer_r_anc,a5
	
	cmp.w	#cpu_30,CPU_TYPE		; si on a un 68030
	bne	.p_030
	move.l	r_caar(a6),d0
	movec	d0,caar
	move.l	d0,r_caar(a5)
	move.l	r_cacr(a6),d0
	movec	d0,cacr
	move.l	d0,r_cacr(a5)

	pmove r_tt1(a6),tt1
	move.l	r_tt1(a6),r_tt1(a5)
	move.l	r_tt1+4(a6),r_tt1+4(a5)
	pmove r_tt0(a6),tt0
	move.l	r_tt0(a6),r_tt0(a5)
	move.l	r_tt0+4(a6),r_tt0+4(a5)
	
	
	pmove	srp,temp
	move.l	temp,d0
	cmp.l	r_srp(a6),d0
	bne.s	.oui	
	move.l	temp+4,d0
	cmp.l	r_srp+4(a6),d0
	beq.s	.non	
.oui
	pmove r_srp(a6),srp
.non
	move.l	r_srp(a6),r_srp(a5)
	
	
	
	
	
	pmove r_crp(a6),crp
	move.l	r_crp(a6),r_crp(a5)
	pmove r_tc(a6),tc
	move.l	r_tc(a6),r_tc(a5)
	pflusha



.p_030
	cmp.w	#cpu_40,CPU_TYPE		; si on a un 68040
	bne.s	.p_040
	move.l	r_cacr(a6),d0
	movec	d0,cacr
	move.l	r_cacr(a6),r_cacr(a5)

.p_040




	clr.l	d0
	move.l	r_dfc(a6),d0
	movec	d0,dfc
	move.l	r_dfc(a6),r_dfc(a5)
	clr.l	d0
	move.l	r_sfc(a6),d0
	movec	d0,sfc
	move.l	r_sfc(a6),r_sfc(a5)
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	bsr.l	set_all_flags
	
	bsr.l	traite_le_pc			; on affiche la forme du curseur
	
	move.l	#MES_UPDATED,MESSAGE_ADR
	
	rts


r_put_history::
************************************************
** routine qui va prendre le num de l'history **
** et qui va remettre les registres a jour    **
************************************************



.encore
	move.l	#MES_PUT_HIS,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.annule

	
	
	
	
	
	move.l	a2,a0
	
	
	
	
	bsr.l	eval
	tst.b	d2
	bne.s	.encore
	

	



	tst.l	d1			; niveau zero n'existe pas
	beq.s	.encore




	cmp.l	#8,d1			; si superieur au niveau 8
	bgt	.encore



	
	lea	point_history,a0
	move	d1,d0
	subq	#1,d0
.look	move.l	(a0)+,a1
	tst.l	(a1)
	beq.s	.encore
	dbra	d0,.look
	
	
	
	*-- dans a1 on a le debut de la ligne d'history voulue --*
	
	
	
.cherche
	cmp.w	#$8000,(a1)+			; on cherche la fin de la ligne => debut des registres
	bne.s	.cherche
	
	
	
	
	
	
	
	
	
	*--- on va sauver quelques registres a voir ---*
	
	
	*--- actuel  d0-a6 sr pc ssp => 4*16+4+4+4 = 76 octets  ---*
	
	
	
	
	
	lea	buffer_r+r_d0,a6
	
	move.w	#15,d0
	
.cop_reg
	move.l	(a1)+,(a6)+
	dbra	d0,.cop_reg


	move.l	(a1)+,buffer_r+r_sr
	move.l	(a1)+,buffer_r+r_pc
	move.l	(a1)+,buffer_r+r_ssp

	move.l	buffer_r+r_pc,p_c

	
	bsr.l	set_all_flags
	bsr.l	traite_le_pc			; on affiche la forme du curseur
	
	
	move.l	#MES_OK,MESSAGE_ADR
	


	rts
	



.annule

	rts



*-------------------------------------------------*






	DATA
MASK	dc.b	'*.*',0	


	BSS
	

	
	TEXT