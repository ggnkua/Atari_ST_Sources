	include	d:\centinel\both\define.s
	output	d:\centinel\40\main.inc\aff_reg.o
	incdir	d:\centinel\40
	include	d:\centinel\both\LOCALMAC.S
	include 40\macros.s
	xref	COL_ADR,COL_NOR,COL_LAB,COL_FCT,COL_REG,COL_CHG,COL_BKPT,COL_ERR_L,ATTRIBUTE,COL_MENU,COL_DSP
	xref	bkpt,m,TRACE,nombre,affiche_nombre_zero
	xref	dessas_one,affiche_nombre_2,num_func
	xref	ADR_VBR
	xref	ERR_MEM,p_c,get_function_trap
	xref	adr_label,nb_symbols,hash_table,excep,fonction_type,s_a7,LIGNE_BRA,type_excep
	xref	FLAG_EV,is_break,dessas_one_bk,s_buf,pile_test,eval_bkpt,calcule_adresse,ASCII_BUF,forme_curseur
	xref	buffer_r,buffer_r_anc,affiche_nombre,CPU_TYPE,buffer_int,buffer_int_anc,COL_PC,chaine_ascii	



	MC68881



affiche_fen_reg
*******************************************
** affichage de la fenetre des registres **
*******************************************


GEN_FEN_REG::
	xref	ASCII_BUF	
	movem.l	d0-a6,-(sp)

	move	#25+10+10,max_ligne(a0)
	move	#80+14,max_col(a0)


	lea	buffer_r,a6
	lea	buffer_r_anc,a5
	move.l	#ASCII_BUF,a0
	moveq	#0,d7


	*-----------------------------
	*--- on commence par les an/dn
	*-----------------------------

.traite_les_registres_an_dn						; affichage des dn
	
	bsr	affiche_dn
	bsr	affiche_an
	
	addq.l	#4,a6
	addq.l	#4,a5
	
	move.w	#$000d,(a0)+
	addq.l	#1,d7
	cmp.b	#8,d7
	bne	.traite_les_registres_an_dn
	
	
	
	
	*-----------------------------
	*--- Affichage du sr
	*-----------------------------
	
	
	bsr	affiche_sr
	
	
	
	
	
	*--------------------
	*--- Affichage du ssp
	*--------------------
	
	bsr	affiche_ssp
	
	
	*-------------------
	*--- Affichage du pc
	*-------------------
	

	bsr	affiche_pc
	
	
	*------------------------------
	*--- Affichage du msp, isp, ...
	*------------------------------

	move.w	#$000d,(a0)+
	bsr	affiche_msp...
	move.w	#$000d,(a0)+

	*---------------------------
	*--- il reste la routine fpu
	*---------------------------
	
	
	
	
	
	
	
	
	
	ifne	FPU_PRES			; ici on affiche les registres du fpu
	
	
	move	COL_CHG,ATTRIBUTE	; affichage du msp
	
	copy	<'             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'>,a0
	move.w	#$000d,(a0)+
	
	copy	<'ÄÄÄÄÄÄÄÄÄÄÄÄÄ´ '>,a0
	move	COL_ADR,ATTRIBUTE 
	copy	<'FPU Registers'>,a0
	move	COL_CHG,ATTRIBUTE
	copy	<' ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ '>,a0
	move.w	#$000d,(a0)+
	
	
	copy	<'             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'>,a0
	move.w	#$000d,(a0)+
	
	move	COL_NOR,ATTRIBUTE
	
	
	
	
	
	
	
	bsr	fpu_aff
	endc
	
	
	
	*----------------------------
	*--- Affichage des bo dessins 
	*----------------------------
	
	
	move	COL_CHG,ATTRIBUTE	; affichage du msp
	
	copy	<'    ÚÄÄÄÄÄÄÄÄÄÄ¿                        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'>,a0
	move.w	#$000d,(a0)+
	
	copy	<'ÄÄÄÄ´ '>,a0
	move	COL_ADR,ATTRIBUTE 
	copy	<'Internal'>,a0
	move	COL_CHG,ATTRIBUTE
	copy	<' ÃÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ '>,a0
	move	COL_ADR,ATTRIBUTE 
	copy	<'MMU Registers'>,a0
	move	COL_CHG,ATTRIBUTE
	copy	<' ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'>,a0
	move.w	#$000d,(a0)+
	
	
	copy	<'    ÀÄÄÄÄÄÄÄÄÄÄÙ    Ÿ                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'>,a0
	move.w	#$000d,(a0)+
	
	move	COL_NOR,ATTRIBUTE
	
	
	*------------------------------------------
	*--- Affichage des registres supl‚mentaires
	*------------------------------------------
	
	
	bsr	affiche_reg_supp		; va afiicher les registres internes
	
	
	
	
	
	
	
	
	move	#$8000,(a0)

	movem.l	(sp)+,d0-a6
	
	rts


affiche_reg_supp
****************************************************
** routine qui va afficher les registres internes **
****************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	
	
	cmp.w	#cpu_30,CPU_TYPE	; on regarde si on a un 030
	
	bne	p_030
	
	move.w	#0,d0
	bsr	affiche_internal
	
	


	*----------------------
	*--- affichage du mmusr
	*----------------------
	
	lea	buffer_r+r_mmusr,a6		; affichage du mmusr
	lea	buffer_r_anc+r_mmusr,a5
	copy	<'    MMUSR='>,a0
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm
	move	COL_CHG,ATTRIBUTE
.norm
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move.w	d1,(a0)+
	bra.s	.c
.d	

	bsr	mmusr_030
	
	move.w	#$000d,(a0)+
	
	move.w	#1,d0
	bsr	affiche_internal
	

	*--------------------------
	*--- Affichage du sfc & dfc
	*------------------------


	lea	buffer_r+r_sfc,a6		; affichage du sfc
	lea	buffer_r_anc+r_sfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1
	move	COL_CHG,ATTRIBUTE
.norm1	copy	<'    SFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1
	move.w	d1,(a0)+
	bra.s	.c1
.d1	
	move	COL_NOR,ATTRIBUTE
	
	lea	buffer_r+r_dfc,a6		; affichage du dfc
	lea	buffer_r_anc+r_dfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1b
	move	COL_CHG,ATTRIBUTE
.norm1b	copy	<'  DFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1b	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1b
	move.w	d1,(a0)+
	bra.s	.c1b
.d1b	move.w	#$000d,(a0)+
	
	
	
	move.w	#2,d0
	bsr	affiche_internal
	
	*--------------------
	*--- Affichage du crp
	*--------------------


	lea	buffer_r+r_crp,a6		; affichage du crp
	lea	buffer_r_anc+r_crp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm2
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm2
.p_norm2
	move	COL_CHG,ATTRIBUTE
.norm2	copy	<'    CRP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c2	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d2
	move.w	d1,(a0)+
	bra.s	.c2
.d2	
	move.l	4(a6),d0				; deuxieme partie
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c2b	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d2b
	move.w	d1,(a0)+
	bra.s	.c2b
.d2b	
	bsr	mmu_rp_030

	move.w	#$000d,(a0)+
	
	
	move.w	#3,d0
	bsr	affiche_internal
	
	*--------------------
	*--- Affichage du srp
	*--------------------


	lea	buffer_r+r_srp,a6		; affichage du srp
	lea	buffer_r_anc+r_srp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm3
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm3
.p_norm3
	move	COL_CHG,ATTRIBUTE
.norm3	copy	<'    SRP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c3	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d3
	move.w	d1,(a0)+
	bra.s	.c3
.d3		
	move.l	4(a6),d0				; deuxieme partie
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c3b	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d3b
	move.w	d1,(a0)+
	bra.s	.c3b
.d3b	
	bsr	mmu_rp_030

	move.w	#$000d,(a0)+
	
	
	
	
	move.w	#4,d0
	bsr	affiche_internal
	
	*-------------------
	*--- Affichage du tc
	*-------------------


	lea	buffer_r+r_tc,a6		; affichage du tc
	lea	buffer_r_anc+r_tc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm4
	move	COL_CHG,ATTRIBUTE
.norm4	copy	<'    TC ='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c4	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d4
	move.w	d1,(a0)+
	bra.s	.c4
.d4	
	bsr	mmu_tcr_030
	
	move.w	#$000d,(a0)+
	
	move.w	#5,d0
	bsr	affiche_internal
	
	*--------------------
	*--- Affichage du tt0
	*--------------------


	lea	buffer_r+r_tt0,a6		; affichage du tt0
	lea	buffer_r_anc+r_tt0,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm5
	move	COL_CHG,ATTRIBUTE
.norm5	copy	<'    TT0='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c5	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d5
	move.w	d1,(a0)+
	bra.s	.c5
.d5	
	bsr	mmu_tt_030
	move.w	#$000d,(a0)+
	
	
	move.w	#6,d0
	bsr	affiche_internal
	
	*--------------------
	*--- Affichage du tt1
	*--------------------


	lea	buffer_r+r_tt1,a6		; affichage du tt1
	lea	buffer_r_anc+r_tt1,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm6
	move	COL_CHG,ATTRIBUTE
.norm6	copy	<'    TT1='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c6	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d6
	move.w	d1,(a0)+
	bra.s	.c6
.d6	
	bsr	mmu_tt_030
	move.w	#$000d,(a0)+
	
	
	move.w	#7,d0				; le I7
	bsr	affiche_internal
	move	COL_CHG,ATTRIBUTE
	copy	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',a0
	move	COL_NOR,ATTRIBUTE
	
	move.w	#$000d,(a0)+
	
	
	
	
	move.w	#8,d0				; le E poid fort
	bsr	affiche_internal
	
	
	*---------------------
	*--- Affichage du cacr
	*---------------------


	lea	buffer_r+r_cacr,a6		; affichage du cacr
	lea	buffer_r_anc+r_cacr,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm7
	move	COL_CHG,ATTRIBUTE
.norm7	copy	<'    CACR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c7	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d7
	move.w	d1,(a0)+
	bra.s	.c7
.d7
	bsr	mmu_cacr_030
	move.w	#$000d,(a0)+
	
	
	
	
	move.w	#9,d0				; le E poid faible
	bsr	affiche_internal
	
	
	*---------------------
	*--- Affichage du caar
	*---------------------


	lea	buffer_r+r_caar,a6		; affichage du caar
	lea	buffer_r_anc+r_caar,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm8
	move	COL_CHG,ATTRIBUTE
.norm8	copy	<'    CAAR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c8	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d8
	move.w	d1,(a0)+
	bra.s	.c8
.d8
	move.w	#$000d,(a0)+
	
	
	
	
	
	
	
	
	move.w	#$000d,(a0)+
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts



p_030
******************************************************
** si on vient ici c'est q'on a soit un 40 ou un 60 **
******************************************************


	cmp.w	#cpu_40,CPU_TYPE
	bne	p_040
	*--- ici c'est un 040 ---*
	
	
	
	move.w	#0,d0
	bsr	affiche_internal
	
	



	*----------------------
	*--- affichage du mmusr
	*----------------------
	
	lea	buffer_r+r_mmusr,a6		; affichage du mmusr
	lea	buffer_r_anc+r_mmusr,a5
	copy	<'    MMUSR='>,a0
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm
	move	COL_CHG,ATTRIBUTE
.norm
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move.w	d1,(a0)+
	bra.s	.c
.d	

	bsr	mmusr_040
	
	move.w	#$000d,(a0)+
	
	move.w	#1,d0
	bsr	affiche_internal
	
	*--------------------------
	*--- Affichage du sfc & dfc
	*--------------------------


	lea	buffer_r+r_sfc,a6		; affichage du sfc
	lea	buffer_r_anc+r_sfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1
	move	COL_CHG,ATTRIBUTE
.norm1	copy	<'    SFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1
	move.w	d1,(a0)+
	bra.s	.c1
.d1	
	move	COL_NOR,ATTRIBUTE

	lea	buffer_r+r_dfc,a6		; affichage du dfc
	lea	buffer_r_anc+r_dfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1b
	move	COL_CHG,ATTRIBUTE
.norm1b	copy	<'  DFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1b	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1b
	move.w	d1,(a0)+
	bra.s	.c1b
.d1b	move.w	#$000d,(a0)+
	
	
	
	move.w	#2,d0
	bsr	affiche_internal
	
	
	
	*--------------------
	*--- Affichage du urp
	*--------------------


	lea	buffer_r+r_crp,a6		; affichage du crp
	lea	buffer_r_anc+r_crp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm2
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm2
.p_norm2
	move	COL_CHG,ATTRIBUTE
.norm2	copy	<'    URP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c2	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d2
	move.w	d1,(a0)+
	bra.s	.c2
.d2	
	move.w	#$000d,(a0)+
	
	
	move.w	#3,d0
	bsr	affiche_internal
	
	*--------------------
	*--- Affichage du srp
	*--------------------


	lea	buffer_r+r_srp,a6		; affichage du srp
	lea	buffer_r_anc+r_srp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm3
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm3
.p_norm3
	move	COL_CHG,ATTRIBUTE
.norm3	copy	<'    SRP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c3	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d3
	move.w	d1,(a0)+
	bra.s	.c3
.d3		
	move.w	#$000d,(a0)+
	
	
	move.w	#4,d0
	bsr	affiche_internal
	
	
	*-------------------
	*--- Affichage du tc
	*-------------------


	lea	buffer_r+r_tc,a6		; affichage du tc
	lea	buffer_r_anc+r_tc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm4
	move	COL_CHG,ATTRIBUTE
.norm4	copy	<'    TC ='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c4	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d4
	move.w	d1,(a0)+
	bra.s	.c4
.d4	
	bsr	mmu_tcr_040
	
	move.w	#$000d,(a0)+
	
	move.w	#5,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du dttr0
	*---------------------


	lea	buffer_r+r_dttr0,a6		; affichage du dttr0
	lea	buffer_r_anc+r_dttr0,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm5
	move	COL_CHG,ATTRIBUTE
.norm5	copy	<'    DTTR0='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c5	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d5
	move.w	d1,(a0)+
	bra.s	.c5
.d5	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#6,d0
	bsr	affiche_internal
	
	
	*---------------------
	*--- Affichage du dttr1
	*---------------------


	lea	buffer_r+r_dttr1,a6		; affichage du dttr1
	lea	buffer_r_anc+r_dttr1,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm6
	move	COL_CHG,ATTRIBUTE
.norm6	copy	<'    DTTR1='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c6	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d6
	move.w	d1,(a0)+
	bra.s	.c6
.d6
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#7,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du ittr0
	*---------------------


	lea	buffer_r+r_ittr0,a6		; affichage du ittr0
	lea	buffer_r_anc+r_ittr0,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm7
	move	COL_CHG,ATTRIBUTE
.norm7	copy	<'    ITTR0='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c7	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d7
	move.w	d1,(a0)+
	bra.s	.c7
.d7	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#8,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du ittr1
	*---------------------


	lea	buffer_r+r_ittr1,a6		; affichage du ittr1
	lea	buffer_r_anc+r_ittr1,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm8
	move	COL_CHG,ATTRIBUTE
.norm8	copy	<'    ITTR1='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c8	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d8
	move.w	d1,(a0)+
	bra.s	.c8
.d8	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#9,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du cacr
	*---------------------


	lea	buffer_r+r_cacr,a6		; affichage du cacr
	lea	buffer_r_anc+r_cacr,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm9
	move	COL_CHG,ATTRIBUTE
.norm9	copy	<'    CACR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c9	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d9
	move.w	d1,(a0)+
	bra.s	.c9
.d9	
	bsr	mmu_cacr_040
	move.w	#$000d,(a0)+
	
	
.saute_this
	move.w	#$000d,(a0)+
	movem.l	(sp)+,d0-d7/a1-a6
	rts


**************************
** ici on aura un 060 ! **
** plus tard ...        **
**************************
p_040



	move.w	#0,d0
	bsr	affiche_internal
	
	


	*-------------------
	*--- Affichage du tc
	*-------------------


	lea	buffer_r+r_tc,a6		; affichage du tc
	lea	buffer_r_anc+r_tc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm4
	move	COL_CHG,ATTRIBUTE
.norm4	copy	<' TC ='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c4	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d4
	move.w	d1,(a0)+
	bra.s	.c4
.d4	
	bsr	mmu_tcr_060
	
	move.w	#$000d,(a0)+
	
	move.w	#1,d0
	bsr	affiche_internal
	
	*--------------------------
	*--- Affichage du sfc & dfc
	*--------------------------


	lea	buffer_r+r_sfc,a6		; affichage du sfc
	lea	buffer_r_anc+r_sfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1
	move	COL_CHG,ATTRIBUTE
.norm1	copy	<' SFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1
	move.w	d1,(a0)+
	bra.s	.c1
.d1	
	move	COL_NOR,ATTRIBUTE

	lea	buffer_r+r_dfc,a6		; affichage du dfc
	lea	buffer_r_anc+r_dfc,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm1b
	move	COL_CHG,ATTRIBUTE
.norm1b	copy	<'  DFC='>,a0
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1b	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1b
	move.w	d1,(a0)+
	bra.s	.c1b
.d1b	move.w	#$000d,(a0)+
	
	
	
	move.w	#2,d0
	bsr	affiche_internal
	
	
	
	*--------------------
	*--- Affichage du urp
	*--------------------


	lea	buffer_r+r_crp,a6		; affichage du crp
	lea	buffer_r_anc+r_crp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm2
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm2
.p_norm2
	move	COL_CHG,ATTRIBUTE
.norm2	copy	<' URP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c2	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d2
	move.w	d1,(a0)+
	bra.s	.c2
.d2	
	;move.w	#$000d,(a0)+
	
	
	;move.w	#2,d0
	;bsr	affiche_internal
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	
	
	
	*--------------------
	*--- Affichage du srp
	*--------------------


	lea	buffer_r+r_srp,a6		; affichage du srp
	lea	buffer_r_anc+r_srp,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	bne.s	.p_norm3
	move.l	4(a6),d0
	cmp.l	4(a5),d0
	beq.s	.norm3
.p_norm3
	move	COL_CHG,ATTRIBUTE
.norm3	copy	<'SRP='>,a0
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c3	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d3
	move.w	d1,(a0)+
	bra.s	.c3
.d3		
	move.w	#$000d,(a0)+
	
	
	
	
	move.w	#3,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du dttr0
	*---------------------


	lea	buffer_r+r_dttr0,a6		; affichage du dttr0
	lea	buffer_r_anc+r_dttr0,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm5
	move	COL_CHG,ATTRIBUTE
.norm5	copy	<' DTTR0='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c5	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d5
	move.w	d1,(a0)+
	bra.s	.c5
.d5	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#4,d0
	bsr	affiche_internal
	
	
	*---------------------
	*--- Affichage du dttr1
	*---------------------


	lea	buffer_r+r_dttr1,a6		; affichage du dttr1
	lea	buffer_r_anc+r_dttr1,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm6
	move	COL_CHG,ATTRIBUTE
.norm6	copy	<' DTTR1='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c6	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d6
	move.w	d1,(a0)+
	bra.s	.c6
.d6
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#5,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du ittr0
	*---------------------


	lea	buffer_r+r_ittr0,a6		; affichage du ittr0
	lea	buffer_r_anc+r_ittr0,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm7
	move	COL_CHG,ATTRIBUTE
.norm7	copy	<' ITTR0='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c7	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d7
	move.w	d1,(a0)+
	bra.s	.c7
.d7	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#6,d0
	bsr	affiche_internal
	
	*---------------------
	*--- Affichage du ittr1
	*---------------------


	lea	buffer_r+r_ittr1,a6		; affichage du ittr1
	lea	buffer_r_anc+r_ittr1,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm8
	move	COL_CHG,ATTRIBUTE
.norm8	copy	<' ITTR1='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c8	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d8
	move.w	d1,(a0)+
	bra.s	.c8
.d8	
	bsr	mmu_tt_040
	move.w	#$000d,(a0)+
	
	
	move.w	#7,d0
	bsr	affiche_internal
	
	
	move	COL_CHG,ATTRIBUTE
	copy	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',a0
	move	COL_NOR,ATTRIBUTE
	move.w	#$000d,(a0)+
	
	
	
	
	
	move.w	#8,d0
	bsr	affiche_internal
	
	
	*---------------------
	*--- Affichage du cacr
	*---------------------


	lea	buffer_r+r_cacr,a6		; affichage du cacr
	lea	buffer_r_anc+r_cacr,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm9
	move	COL_CHG,ATTRIBUTE
.norm9	copy	<' CACR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c9	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d9
	move.w	d1,(a0)+
	bra.s	.c9
.d9	
	bsr	mmu_cacr_060
	move.w	#$000d,(a0)+
	
	
	
	move.w	#9,d0
	bsr	affiche_internal
	
	
	
	*---------------------
	*--- Affichage du pcr
	*---------------------


	lea	buffer_r+r_pcr,a6		; affichage du pcr
	lea	buffer_r_anc+r_pcr,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm10
	move	COL_CHG,ATTRIBUTE
.norm10	copy	<' PCR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c10	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d10
	move.w	d1,(a0)+
	bra.s	.c10
.d10	
	bsr	pcr_060
	move.w	#$000d,(a0)+
	
	
	
	
	move	COL_CHG,ATTRIBUTE
	copy	<'                    Ÿ'>,a0			; trait verti
	move.w	COL_NOR,ATTRIBUTE
	
	
	
	

	*---------------------
	*--- Affichage du buscr
	*---------------------


	lea	buffer_r+r_buscr,a6		; affichage du pcr
	lea	buffer_r_anc+r_buscr,a5
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm11
	move	COL_CHG,ATTRIBUTE
.norm11	copy	<' BUSCR='>,a0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c11	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d11
	move.w	d1,(a0)+
	bra.s	.c11
.d11
	bsr	buscr_060
	move.w	#$000d,(a0)+
	
	
	
	
	
	move	COL_CHG,ATTRIBUTE
	copy	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ',a0
	copy	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',a0
	move.w	COL_NOR,ATTRIBUTE
	
	
	
	
.saute_this
	move.w	#$000d,(a0)+
	movem.l	(sp)+,d0-d7/a1-a6
	rts



choice_color	macro
	move.w	COL_REG,ATTRIBUTE
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	btst	#\1,d0
	beq.s	.a\@
	
	move.w	COL_CHG,ATTRIBUTE
	btst	#\1,d1
	beq.s	.a\@
	move.w	COL_NOR,ATTRIBUTE
	
	
.a\@
	endm
	
	
	
	
mmu_cacr_030
******************************
** Affichage du cacr du 030 **
******************************
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	
	copy	<'    '>,a0
	
	choice_color	13
	copy	'WA',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	12
	copy	'DBE',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	11
	copy	'CD',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	10
	copy	'CED',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	9
	copy	'FD',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	8
	copy	'ED',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	4
	copy	'IBE',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	3
	copy	'CI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	2
	copy	'CEI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	1
	copy	'FI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	0
	copy	'EI',a0
	move.w	COL_NOR,ATTRIBUTE
	
	rts




mmu_cacr_040
******************************
** Affichage du cacr du 040 **
******************************
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	
	copy	<'   '>,a0
	
	choice_color	31
	copy	'DE',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	15
	copy	'IE',a0
	move.w	COL_NOR,ATTRIBUTE
	
	rts


mmu_cacr_060
******************************
** Affichage du cacr du 060 **
******************************
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	
	copy	<'   '>,a0
	
	choice_color	31
	copy	'EDC',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	30
	copy	'NAD',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	29	
	copy	'ESB',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	28	
	copy	'DPI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	27	
	copy	'FOC',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	23	
	copy	'EBC',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	22	
	copy	'CACB',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0

	choice_color	21	
	copy	'CUBC',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	15
	copy	'EIC',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	14
	copy	'NAI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	choice_color	13
	copy	'FIC',a0
	
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts


mmusr_030
*********************************************
** Routine qui va afficher le sr de la mmu **
** a0 pointeur sur la sortie               **
** a5 pointeur sur ancien mmu              **
** a6 pointeur sur mmu                     **
*********************************************
	
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	
	copy	<'              '>,a0
	
	choice_color	15
	car	'B',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	14
	car	'L',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	13
	car	'S',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	11
	car	'W',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	10
	car	'I',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	9
	car	'M',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	6
	car	'T',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	bfextu	d0{29:3},d0
	bfextu	d1{29:3},d1
	cmp.b	d0,d1
	beq.s	.p_c
	move.w	COL_CHG,ATTRIBUTE
.p_c
	
	
	add.w	#'0',d0
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
		
		
		
	move	COL_NOR,ATTRIBUTE
	
	
	rts

mmusr_040
*********************************************
** Routine qui va afficher le sr de la mmu **
** a0 pointeur sur la sortie               **
** a5 pointeur sur ancien mmu              **
** a6 pointeur sur mmu                     **
*********************************************
	
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	
	copy	<'  '>,a0
	
	choice_color	11
	car	'B',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	10
	car	'G',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	9
	car	'U',a0
	car	'1',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	8
	car	'U',a0
	car	'0',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	7
	car	'S',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	4
	car	'M',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	2
	car	'W',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	1
	car	'T',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	choice_color	0
	car	'R',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	copy	<'CM='>,a0
		
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	bfextu	d0{25:2},d0
	bfextu	d1{25:2},d1
	cmp.b	d0,d1
	beq.s	.norm
	move.w	COL_CHG,ATTRIBUTE	
.norm
	add.b	#'0',d0
	move.w	ATTRIBUTE,(a0)
	or	d0,(a0)+
	
	move	COL_NOR,ATTRIBUTE
	
	
	
	move.l	(a6),d0		; nouveau
	move.l	(a5),d1		; ancien
	
	bfextu	d0{0:20},d0	; on a la physical adresse
	bfextu	d1{0:20},d1
	
	
	
	move	COL_NOR,ATTRIBUTE
	
	
	
	
	rts



mmu_rp_030
**********************************
** Affiche le srp et crp du 030 **
**********************************


	move.l	4(a6),d0
	move.l	4(a5),d1
	
	;bfextu	d0{0:28},d0
	;bfextu	d1{0:28},d1
	
	move.w	COL_NOR,ATTRIBUTE
	
	car	<' '>,a0
	car	<' '>,a0
	car	<' '>,a0
	car	<' '>,a0
	
	;car	'$',a0
	
	;cmp.l	d0,d1
	;beq.s	.p_c
	;move.w	COL_CHG,ATTRIBUTE
.p_c
	;jsr	affiche_nombre
	;lea	nombre,a1
	;move	ATTRIBUTE,d1
.c4	;move.b	(a1)+,d1
	;tst.b	-1(a1)
	;beq.s	.d4
	;move.w	d1,(a0)+
	;bra.s	.c4
.d4	
	;move.w	COL_CHG,ATTRIBUTE
	;car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	copy	<'L/U='>,a0
	move.l	(a6),d0
	move.l	(a5),d1
	bfextu	d0{0:1},d0
	bfextu	d1{0:1},d1
	cmp.l	d0,d1
	beq.s	.p_c1
	move.w	COL_CHG,ATTRIBUTE
.p_c1
	add.b	#'0',d0
	move	ATTRIBUTE,(a0)	
	or	d0,(a0)+
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	copy	<'LIM='>,a0
	move.l	(a6),d0
	move.l	(a5),d1
	bfextu	d0{1:15},d0
	bfextu	d1{1:15},d1
	cmp.l	d0,d1
	beq.s	.p_c2
	move.w	COL_CHG,ATTRIBUTE
.p_c2
	jsr	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c41	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d41
	move.w	d1,(a0)+
	bra.s	.c41
.d41
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	copy	<'DT='>,a0
	move.l	(a6),d0
	move.l	(a5),d1
	bfextu	d0{30:2},d0
	bfextu	d1{30:2},d1
	cmp.l	d0,d1
	beq.s	.p_c3
	move.w	COL_CHG,ATTRIBUTE
.p_c3
	lea	tab12,a1
	lsl	#2,d0
	add.l	d0,a1
	
	
	rept	4
	move.w	ATTRIBUTE,d0
	move.b	(a1)+,d0
	move.w	d0,(a0)+
	endr
	
	
	
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	rts
	
	DATA

tab12
	dc.l	'INV '
	dc.l	'PGD '
	dc.l	'V 4B'
	dc.l	'V 8B'

	TEXT

copy_tcr	macro

	move.l	(a6),d0
	move.l	(a5),d1
	
	bfextu	d0{\2:4},d0
	bfextu	d1{\2:4},d1
	
	move	COL_NOR,ATTRIBUTE
	
	copy	\1,a0
	
	cmp.b	d0,d1
	beq.s	.nor\@
	move	COL_CHG,ATTRIBUTE
.nor\@
	
	
	jsr	affiche_nombre
	lea	nombre,a1
	move.b	(a1),d0
	
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	
	
	
	endm
	
	
	


mmu_tcr_030
****************************
** affichage du tc du 030 **
****************************
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'            '>,a0
	
	
	choice_color	31
	car	'E',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	25
	copy	'SRE',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	24
	copy	'FCL',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'PS=',a0
	bfextu	d0{9:3},d0
	bfextu	d1{9:3},d1
	cmp.b	d0,d1
	beq.s	.p_c
	move.w	COL_CHG,ATTRIBUTE
.p_c
	lea	tab123,a1
	lsl	#2,d0
	add	d0,a1
	move.w	ATTRIBUTE,d0
	rept	4
	move.b	(a1)+,d0
	move	d0,(a0)+
	endr
	
	
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tcr	'IS=',12
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tcr	'TIA=',16
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tcr	'TIB=',20
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tcr	'TIC=',24
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tcr	'TID=',28
	move.w	COL_CHG,ATTRIBUTE
	
	
	
	
	rts

	DATA

tab123
	dc.b	'256b'
	dc.b	'512b'
	dc.b	'1 Kb'
	dc.b	'2 Kb'
	dc.b	'4 Kb'
	dc.b	'8 Kb'
	dc.b	'16Kb'
	dc.b	'32Kb'

	TEXT

mmu_tcr_040
****************************
** affichage du tc du 040 **
****************************
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'    '>,a0
	
	
	choice_color	15
	car	'E',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	14
	car	'P',a0
	
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts

pcr_060

************************************
** contenu du registre pcr du 060 **
************************************

	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'    '>,a0
	
	
	choice_color	7
	copy	'EDEBUG',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	1
	copy	'DFP',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	0	
	copy	'ESS',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	move.w	COL_NOR,ATTRIBUTE
	
	
	bfextu	d0{31:16},d2	; identificateur
	bfextu	d0{15:8},d3	; revision number	
	
	copy	'ID=',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	move.w	COL_NOR,ATTRIBUTE
	copy	<'REV num='>,a0
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts

buscr_060

**************************************
** contenu du registre buscr du 060 **
**************************************

	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'  '>,a0
	
	
	choice_color	31
	car	'L',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	30
	copy	'SL',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	
	choice_color	29
	copy	'LE',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	28
	copy	'SLE',a0
	
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts
mmu_tcr_060
****************************
** affichage du tc du 040 **
****************************
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'    '>,a0
	
	
	choice_color	15
	car	'E',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	14
	car	'P',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	13	
	copy	'NAD',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	12	
	copy	'NAI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	11	
	copy	'FO',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	10
	copy	'FI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'DCO=',a0
	bfextu	d0{9:2},d0
	bfextu	d1{9:2},d1
	cmp.b	d0,d1
	beq.s	.p_c
	move.w	COL_CHG,ATTRIBUTE
.p_c
	car	'0',a0
	add.b	d0,-1(a0)
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'DUO=',a0
	bfextu	d0{7:2},d0
	bfextu	d1{7:2},d1
	cmp.b	d0,d1
	beq.s	.p_c1
	move.w	COL_CHG,ATTRIBUTE
.p_c1
	car	'0',a0
	add.b	d0,-1(a0)
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	
	choice_color	5
	copy	'DWO',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'DCI=',a0
	bfextu	d0{4:2},d0
	bfextu	d1{4:2},d1
	cmp.b	d0,d1
	beq.s	.p_c2
	move.w	COL_CHG,ATTRIBUTE
.p_c2
	car	'0',a0
	add.b	d0,-1(a0)
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'DUI=',a0
	bfextu	d0{2:2},d0
	bfextu	d1{2:2},d1
	cmp.b	d0,d1
	beq.s	.p_c3
	move.w	COL_CHG,ATTRIBUTE
.p_c3
	car	'0',a0
	add.b	d0,-1(a0)
	
	
	
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts

mmu_tt_040
****************************
** affichage du tc du 040 **
****************************
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	
	copy	<'  '>,a0
	
	
	choice_color	15
	car	'E',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	9
	copy	'U1',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	8
	copy	'U0',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	2
	car	'W',a0
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'SF=',a0
	bfextu	d0{17:2},d0
	bfextu	d1{17:2},d1
	cmp.b	d0,d1
	beq.s	.p_c
	move.w	COL_CHG,ATTRIBUTE
.p_c
	add.b	#'0',d0
	move.w	ATTRIBUTE,(a0)
	or	d0,(a0)+
	
	move.l	(a6),d0
	move.l	(a5),d1
	
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	move.w	COL_NOR,ATTRIBUTE
	copy	'CM=',a0
	bfextu	d0{25:2},d0
	bfextu	d1{25:2},d1
	cmp.b	d0,d1
	beq.s	.p_c1
	move.w	COL_CHG,ATTRIBUTE
.p_c1
	add.b	#'0',d0
	move.w	ATTRIBUTE,(a0)
	or	d0,(a0)+
	
	move.w	COL_NOR,ATTRIBUTE
	
	rts

copy_tt	macro

	move.l	(a6),d0
	move.l	(a5),d1
	
	bfextu	d0{\2:3},d0
	bfextu	d1{\2:3},d1
	
	move	COL_NOR,ATTRIBUTE
	
	copy	\1,a0
	
	cmp.b	d0,d1
	beq.s	.nor\@
	move	COL_CHG,ATTRIBUTE
.nor\@
	
	
	jsr	affiche_nombre
	lea	nombre,a1
	move.b	(a1),d0
	
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	
	
	
	endm
	

mmu_tt_030
************************************
** affiche les reg de translation **
************************************

	move.l	(a6),d0
	move.l	(a5),d1

	copy	<'            '>,a0
	
	
	choice_color	15
	car	'E',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	10
	copy	'CI',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	choice_color	9
	copy	'R/W',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	

	choice_color	8
	copy	'RWM',a0
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tt	'FCB=',25
	move.w	COL_CHG,ATTRIBUTE
	car	'/',a0
	
	copy_tt	'FCM=',29
	move.w	COL_CHG,ATTRIBUTE
	



	rts


affiche_internal
******************************************
** routine qui va afficher In avec n=d0 **
******************************************
	
	move.w	d0,d7
	
	lea	buffer_int+r_i0,a6
	lea	buffer_int_anc+r_i0,a5
	move	COL_NOR,ATTRIBUTE
	move.l	(a6,d0.w*4),d1
	cmp.l	(a5,d0.w*4),d1
	beq.s	.norm
	move	COL_CHG,ATTRIBUTE
.norm
	cmp.b	#8,d0
	beq.s	.efort	
	cmp.b	#9,d0
	beq.s	.efaible	
	
	copy	'I0=',a0
	add.b	d0,-3(a0)
	bra.s	.suite
.efort
	move.l	36(a6),d0
	cmp.l	36(a5),d0
	beq.s	.norm1
	move	COL_CHG,ATTRIBUTE
.norm1	copy	<' E='>,a0
	bra.s	.suite
.efaible
	move.l	32(a6),d0
	cmp.l	32(a5),d0
	beq.s	.norm2
	move	COL_CHG,ATTRIBUTE
.norm2	copy	<'   '>,a0
.suite
	
	move.l	d1,d0
	
	jsr	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move.w	d1,(a0)+
	bra.s	.c
.d
	
	*-------------------------------
	*--- affichage ascii avec filtre 
	*-------------------------------
	
	move	COL_REG,ATTRIBUTE
	car	<' '>,a0
	move.w	ATTRIBUTE,(a0)
	move.w	ATTRIBUTE,2(a0)
	move.w	ATTRIBUTE,4(a0)
	move.w	ATTRIBUTE,6(a0)
	movep.l	d0,1(a0)
	move.w	#3,d1
.tst	move.b	1(a0,d1*2),d0
	tst.b	d0
	bne.s	.z
	move.b	#'.',d0
.z	cmp.b	#$a,d0
	bne.s	.z1
	move.b	#'.',d0
.z1	cmp.b	#$d,d0
	bne.s	.z2
	move.b	#'.',d0
.z2	cmp.b	#$9,d0
	bne.s	.z3
	move.b	#'.',d0
.z3	move.b	d0,1(a0,d1*2)
	dbra	d1,.tst
	addq.l	#8,a0
	
	
		
	copy	<'    '>,a0
	move	COL_CHG,ATTRIBUTE
	cmp.b	#7,d7
	bne.s	.k
	cmp.w	#cpu_30,CPU_TYPE
	beq.s	.vert
.k
	
	car	'Ÿ',a0			; trait verti
	bra.s	.next
.vert	car	'Ã',a0
.next
	move	COL_NOR,ATTRIBUTE
	
	rts
	

affiche_cont
***********************************************
** routine qui va afficher le contnu de (d1) **
**    en long                                **
***********************************************


	movem.l	d1/a1/a2/d3/d2,-(sp)
	
	moveq	#3,d2				; nb a afficher
	move.l	d1,a1				; affichage de son contenu
	
.again
	clr.l	d1
	lit_mem.b	a1,d1
	tst.b	ERR_MEM				; a-t-on une erreur ?
	beq.s	.p_err
	
	and.l	#$ff,d1
	
	rept 2
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	endr
	bra.s	.suiv0
	
.p_err
	
	move.l	d1,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a2
	rept	2
	clr.w	d3
	move.b	(a2)+,d3
	move	ATTRIBUTE,(a0)
	or	d3,(a0)+
	endr
	

.suiv0

	addq.l	#1,a1
	dbra	d2,.again

	move.w	COL_NOR,ATTRIBUTE



	movem.l	(sp)+,d1/a1/a2/d3/d2
	rts	


affiche_cont_word
***********************************************
** routine qui va afficher le contnu de (d1) **
**    en long                                **
***********************************************


	movem.l	d1/a1/a2/d3/d2,-(sp)
	
	moveq	#1,d2				; nb a afficher
	move.l	d1,a1				; affichage de son contenu
	
.again
	clr.l	d1
	lit_mem.b	a1,d1
	tst.b	ERR_MEM				; a-t-on une erreur ?
	beq.s	.p_err
	
	and.l	#$ff,d1
	
	rept 2
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	endr
	bra.s	.suiv0
	
.p_err
	
	move.l	d1,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a2
	rept	2
	clr.w	d3
	move.b	(a2)+,d3
	move	ATTRIBUTE,(a0)
	or	d3,(a0)+
	endr
	

.suiv0

	addq.l	#1,a1
	dbra	d2,.again

	move.w	COL_NOR,ATTRIBUTE



	movem.l	(sp)+,d1/a1/a2/d3/d2
	rts	


affiche_cont_byte
***********************************************
** routine qui va afficher le contnu de (d1) **
**    en long                                **
***********************************************


	movem.l	d1/a1/a2/d3/d2,-(sp)
	
	move.l	d1,a1				; affichage de son contenu
	
.again
	clr.l	d1
	lit_mem.b	a1,d1
	tst.b	ERR_MEM				; a-t-on une erreur ?
	beq.s	.p_err
	
	and.l	#$ff,d1
	
	rept 2
	move	ATTRIBUTE,(a0)
	or	d1,(a0)+
	endr
	bra.s	.suiv0
	
.p_err
	
	move.l	d1,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a2
	rept	2
	clr.w	d3
	move.b	(a2)+,d3
	move	ATTRIBUTE,(a0)
	or	d3,(a0)+
	endr
	

.suiv0

	addq.l	#1,a1

	move.w	COL_NOR,ATTRIBUTE



	movem.l	(sp)+,d1/a1/a2/d3/d2
	rts	



affiche_sr
**********************************************
** Routine qui va afficher le contenu du sr **
**********************************************

	lea	buffer_r,a6
	lea	buffer_r_anc,a5
	
	move.l	r_sr(a6),d0
	cmp.l	r_sr(a5),d0
	beq.s	.p_norm
	move.w	COL_CHG,ATTRIBUTE
.p_norm
	copy	'SR=',a0
	
	move.l	r_sr(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	add.l	#4,a1
	clr	d1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move	d1,(a0)+
	bra.s	.c
.d
	car	<' '>,a0
	bsr	AFFICHE_NOM_ETAT
	car	<' '>,a0
	car	<' '>,a0
	rts


AFFICHE_NOM_ETAT
*************************************
** routine qui va prendre le sr et **
** afficher le nom des bits qui le **
** compose                         **
*************************************
	movem.l	d0-d4,-(sp)
	
	
	lea	buffer_r,a6
	lea	buffer_r_anc,a5
	
	move	COL_REG,ATTRIBUTE
	btst	#0,d0				; test du bit C
	bne.s	.y
	car	'C',a0
	bra.s	.y1
.y
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l	r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{15:1},d1
	bfextu	d2{15:1},d2
	cmp.b	d1,d2
	beq.s	.y2
	move	COL_CHG,ATTRIBUTE
.y2
	
	car	'C',a0
.y1
	
	
	move	COL_REG,ATTRIBUTE
	btst	#1,d0				; test du bit v
	bne.s	.u
	car	'V',a0
	bra.s	.u1
.u
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l  r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{14:1},d1
	bfextu	d2{14:1},d2
	cmp.b	d1,d2
	beq.s	.u2
	move	COL_CHG,ATTRIBUTE
.u2
	
	car	'V',a0
.u1
	
	
	
	move	COL_REG,ATTRIBUTE
	btst	#2,d0				; test du bit Z
	bne.s	.i
	car	'Z',a0
	bra.s	.i1
.i
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l	r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{13:1},d1
	bfextu	d2{13:1},d2
	cmp.b	d1,d2
	beq.s	.i2
	move	COL_CHG,ATTRIBUTE
.i2
	
	car	'Z',a0
.i1
	
	
	
	move	COL_REG,ATTRIBUTE
	btst	#3,d0				; test du bit N
	bne.s	.o
	car	'N',a0
	bra.s	.o1
.o
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l	r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{12:1},d1
	bfextu	d2{12:1},d2
	cmp.b	d1,d2
	beq.s	.o2
	move	COL_CHG,ATTRIBUTE
.o2
	
	car	'N',a0
.o1
	
	
	
	
	move	COL_REG,ATTRIBUTE
	btst	#4,d0				; test du bit X
	bne.s	.p
	car	'X',a0
	bra.s	.p1
.p
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l	r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{12:1},d1
	bfextu	d2{12:1},d2
	cmp.b	d1,d2
	beq.s	.p2
	move	COL_CHG,ATTRIBUTE
.p2
	
	car	'X',a0
.p1
	
	
	move	COL_REG,ATTRIBUTE
	btst	#13,d0				; test du bit S
	bne.s	.q
	car	'S',a0
	bra.s	.q1
.q
	move	COL_NOR,ATTRIBUTE
	move.l	r_sr(a6),d1
	move.l	r_sr(a5),d2
	swap	d1
	swap	d2
	bfextu	d1{2:1},d1
	bfextu	d2{2:1},d2
	cmp.b	d1,d2
	beq.s	.q2
	move	COL_CHG,ATTRIBUTE
.q2
	
	car	'S',a0
.q1
	
	movem.l	(sp)+,d0-d4
	rts



aff_after_an
*****************************************************
** routine qui affiche le contenu des registres an **
** Dans d2 : addr a afficher                       ** 
*****************************************************
	pea	(a5)
	car	<' '>,a0
	
	move	COL_REG,ATTRIBUTE
	
	move.l	d2,a2				; affichage du contenu de an avec gestion des erreurs de bus
	moveq	#2,d3	
	move.l	a2,d0
	btst	#0,d0
	beq.s	.ji		; test de la parite pour un eventuel decalage
	moveq	#1,d3
.ji	lea	chaine_ascii,a3
	move.l	#15,d2		; quantit‚ a afficher
.c3	clr.l	d0
	lit_mem.b	a2,d0
	addq.l	#1,a2
	tst.b	ERR_MEM
	bne.s	.special_b
	move	COL_REG,ATTRIBUTE
	move.w	ATTRIBUTE,(a3)
	or	d0,(a3)+
	bsr.l	affiche_nombre_2
	lea	nombre,a1
	move	ATTRIBUTE,d1
	move.b	(a1)+,d1
	move	d1,(a0)+
	move.b	(a1)+,d1
	move	d1,(a0)+
	subq.l	#1,d3
	bne.s	.za
	car	<' '>,a0
	moveq	#2,d3
.za	dbra	d2,.c3
	bra.s	.ok_adr
	
.special_b
	move	COL_ERR_L,ATTRIBUTE
	and.w	#$ff,d0			; pour eviter les * ou - en trop
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	move	ATTRIBUTE,(a3)
	or	d0,(a3)+
	subq.l	#1,d3
	bne.s	.za1
	car	<' '>,a0
	moveq	#2,d3
.za1	dbra	d2,.c3
	
.ok_adr
	
	move.w	#$8000,(a3)
	
	car	<' '>,a0
	
	move.w	#15,d1				
	lea	chaine_ascii,a3

.plo	move.w	(a3)+,d0
	cmp.b	#0,d0
	beq.s	.i
	cmp.b	#$a,d0
	beq.s	.i
	cmp.b	#$9,d0
	beq.s	.i
	cmp.b	#$d,d0
	beq.s	.i
	move	d0,(a0)+
	bra.s	.piu
	
.i
	move.b	#'.',d0
	move	d0,(a0)+
.piu
	dbra	d1,.plo
	
	move	COL_NOR,ATTRIBUTE
	
	
	move.l	(sp)+,a5
	
	rts

affiche_dn
***********************************************
** Routine qui va affciher dn et son contenu **
***********************************************
	
	
	move	COL_NOR,ATTRIBUTE
	
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.norm
	move	COL_CHG,ATTRIBUTE
	
.norm
	copy	'D0=',a0
	add.b	d7,-3(a0)
	
	move.l	(a6),d0
	jsr	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
	move.w	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move	d1,(a0)+
	bra.s	.c
.d
	
	move	COL_REG,ATTRIBUTE
	
	car	<' '>,a0
	
	clr.w	d1
	
	*-------------------------------------
	*--- on filtre les carcateres speciaux
	*-------------------------------------
	
	move.w	ATTRIBUTE,(a0)
	move.w	ATTRIBUTE,2(a0)
	move.w	ATTRIBUTE,4(a0)
	move.w	ATTRIBUTE,6(a0)
	movep.l	d0,1(a0)
	move.w	#3,d1
.tst	move.b	1(a0,d1*2),d0		; on filtre le 0
	tst.b	d0
	bne.s	.z
	move.b	#'.',d0
.z	cmp.b	#$a,d0			; on filtre le ret char
	bne.s	.z1
	move.b	#'.',d0
.z1	cmp.b	#$d,d0			; on filtre le lf
	bne.s	.z2
	move.b	#'.',d0
.z2	cmp.b	#$9,d0			; on filtre le tab
	bne.s	.z3
	move.b	#'.',d0
.z3	move.b	d0,1(a0,d1*2)
	dbra	d1,.tst
	
	addq.l	#8,a0
	
	
	
	
	move	COL_CHG,ATTRIBUTE	
	;car	'Ÿ',a0			; trait verti
	car	<' '>,a0
	move.w	COL_NOR,ATTRIBUTE
	
	rts

affiche_an
********************************************************
** Routine qui va afficher la valeur des registres an **
********************************************************
	move.l	r_a0(a6),d0
	cmp.l	r_a0(a5),d0
	beq.s	.norm1
	move.w	COL_CHG,ATTRIBUTE
.norm1
	copy	'A0=',a0
	add.b	d7,-3(a0)
	move.l	r_a0(a6),d0
	move.l	d0,d2
	
	jsr	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
	move	ATTRIBUTE,d1
.c1	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1
	move	d1,(a0)+
	bra.s	.c1
.d1
	
	bsr	aff_after_an
	rts
	
affiche_ssp
************************
*** Affichage su ssp ***
************************
	move	COL_NOR,ATTRIBUTE		; affichage du ssp
	
	move.l	r_ssp(a6),d0
	cmp.l	r_ssp(a5),d0
	beq.s	.p_norm3
	move	COL_CHG,ATTRIBUTE
.p_norm3
	copy	'SSP=',a0
	lea	buffer_r,a6
	move.l	r_ssp(a6),d0			; on r‚cupŠre isp
	move.l	d0,d2
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move	d1,(a0)+
	bra.s	.c
.d
	
	bsr	aff_after_an
	move	#$000d,(a0)+
	rts


affiche_pc
**********************************************
** Routine qui va afficher le contenu du pc **
**********************************************
	move	COL_NOR,ATTRIBUTE
	
	lea	buffer_r,a6
	move.l	r_pc(a6),d0
	cmp.l	r_pc(a5),d0
	beq.s	.p_norm5
	
	move	COL_CHG,ATTRIBUTE
.p_norm5
	copy	'PC=',a0
	
	move.l	r_pc(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move	d1,(a0)+
	bra.s	.c
.d
	
	
	
	move	COL_NOR,ATTRIBUTE
	
	copy	<'     '>,a0
	
	move.l	r_pc(a6),a4
	
	
	bsr.l	dessas_one_bk			; on affiche le desassemblage
	lea	s_buf,a1			; de l'instrucrion
	
	move.l	d0,-(sp)			; dans la couleur col_pc
.cc1	tst.b	(a1)
	beq.s	.sor
	move.w	(a1)+,d0
	and.w	#$ff,d0
	move.w	COL_PC,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	or	d0,(a0)+
	bra.s	.cc1
.sor
	move.l	(sp)+,d0
	move.w	COL_NOR,ATTRIBUTE
	
	
	bsr.l	get_function_trap
	tst.w	excep			; teste pour voir s'il y a un nom a mettre
	beq.s	.p_nom
	lea	fonction_type,a6
	move.w	type_excep,d0
	move.l	(a6,d0.w*4),a6
	move.w	num_func,d0
	move.l	(a6,d0.w*4),a6
	tst.b	(a6)
	beq.s	.p_nom			; si le nom vaut zero
	move	COL_FCT,ATTRIBUTE
	move	ATTRIBUTE,(a0)
	or	#' ',(a0)+
	move	ATTRIBUTE,(a0)
	or	#'<',(a0)+

	clr.w	d1
	
.c1	move.b	(a6)+,d1
	tst.b	-1(a6)
	beq.s	.d1
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c1
.d1
	
	
	move	ATTRIBUTE,(a0)
	or	#'>',(a0)+
	move	COL_NOR,ATTRIBUTE
.p_nom
	
	
	
	

	*------------- on va calculer l'adresse de mode d'adressage ---------*


	
	movem.l	d0-d4/a1-a2,-(sp)
	lea	s_buf,a1
	bsr.l	calcule_adresse
	tst.b	d0
	beq	.p_nombre
	
	
	copy	<'    '>,a0
	
	move.l	d0,d4			; affiche de la premiŠre adresse evalu‚e
	move.l	d1,d0
	bsr.l	affiche_nombre
	lea	nombre,a1
	move.w	ATTRIBUTE,d3
.cop	move.b	(a1)+,d3
	tst.b	d3
	beq.s	.suiv
	move	d3,(a0)+
	bra.s	.cop
.suiv
	
	car	'=',a0
	
	
	move.l	d4,d0
	swap	d0
	
	tst.b	d0
	bne.s	.p_long
	bsr	affiche_cont		; proc‚dure qui affiche le contenu d'un registre
	bra.s	.kio
.p_long
	cmp.b	#1,d0
	bne.s	.p_word
	bsr	affiche_cont_word		; proc‚dure qui affiche le contenu d'un registre
	bra.s	.kio
.p_word
	cmp.b	#2,d0
	bne.s	.p_byte
	bsr	affiche_cont_byte		; proc‚dure qui affiche le contenu d'un registre
	bra.s	.kio
.p_byte
	nop
.kio
	
	cmp.b	#2,d4
	bne.s	.p_deux
	
	
	car	<' '>,a0
	car	03,a0
	car	<' '>,a0
	
	move.l	d2,d0
	bsr.l	affiche_nombre
	lea	nombre,a1
	move	ATTRIBUTE,d3
.cop1	move.b	(a1)+,d3
	tst.b	d3
	beq.s	.suiv1
	move	d3,(a0)+
	bra.s	.cop1
.suiv1

	car	'=',a0
	
	move.l	d2,d1
	bsr	affiche_cont

.p_deux
.p_nombre
	movem.l	(sp)+,d0-d4/a1-a2
	
	
	
	
.fty

	rts

affiche_msp...
***********************************************
** Routine qui va afficher le msp isp vbr ...**
***********************************************


	move.w	#$000d,(a0)+
	move	COL_NOR,ATTRIBUTE	; affichage du msp
	
	cmp.l	#cpu_60,CPU_TYPE	; si 60 pas de msp
	beq	.p_msp


	lea	buffer_r,a6
	move.l	r_msp(a6),d0
	cmp.l	r_msp(a5),d0
	beq.s	.p_norm
	move	COL_CHG,ATTRIBUTE
.p_norm
	copy	'MSP=',a0
	move.l	r_msp(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d
	move.w	d1,(a0)+
	bra.s	.c
.d
	
	copy	<'    '>,a0
	


.p_msp
	move	COL_NOR,ATTRIBUTE	; affichage du isp
	
	lea	buffer_r,a6
	move.l	r_isp(a6),d0
	cmp.l	r_isp(a5),d0
	beq.s	.p_norm1
	
	move	COL_CHG,ATTRIBUTE
.p_norm1
	copy	'ISP=',a0
	move.l	r_isp(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c1	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1
	move.w	d1,(a0)+
	bra.s	.c1
.d1
	
	copy	<'    '>,a0
	
	
	move	COL_NOR,ATTRIBUTE	; affichage du usp
	
	lea	buffer_r,a6
	move.l	r_usp(a6),d0
	cmp.l	r_usp(a5),d0
	beq.s	.p_norm2
	move	COL_CHG,ATTRIBUTE
.p_norm2
	copy	'USP=',a0
	move.l	r_usp(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move.w	ATTRIBUTE,d1
.c2	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d2
	move.w	d1,(a0)+
	bra.s	.c2
.d2
	
	copy	<'    '>,a0
	
	
	move	COL_NOR,ATTRIBUTE	; affichage du vbr
	
	lea	buffer_r,a6
	move.l	r_vrb(a6),d0
	cmp.l	r_vrb(a5),d0
	beq.s	.p_norm3
	
	move	COL_CHG,ATTRIBUTE
.p_norm3
	copy	'VBR=',a0
	move.l	r_vrb(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move	ATTRIBUTE,d1
.c3	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d3
	move.w	d1,(a0)+
	bra.s	.c3
.d3
	
	
	
	move.w	#$000d,(a0)+
	
	rts

	
	
	
	ifne	FPU_PRES			; ici on affiche les registres du fpu
fpu_aff
*************************************
** affichage du fpu s'il y en a un **
*************************************
	
	move.w	#7,d5
	lea	buffer_r+r_fp0,a6
	lea	buffer_r_anc+r_fp0,a5
	move.w	#0,d4	
.tyu	
.uio	move.w	COL_NOR,ATTRIBUTE
	
	move.l	(a6),d2
	cmp.l	(a5),d2
	bne.s	.zer
	move.l	4(a6),d2
	cmp.l	4(a5),d2
	bne.s	.zer
	move.l	8(a6),d2
	cmp.l	8(a5),d2
	beq.s	.zer1
	
	
	
.zer
	move.w	COL_CHG,ATTRIBUTE
.zer1
	
	
	
	
	move	ATTRIBUTE,(a0)
	or	#'F',(a0)+
	move	ATTRIBUTE,(a0)
	or	#'P',(a0)+
	move	ATTRIBUTE,(a0)
	or	#'0',(a0)+
	;move.w	#1,d3
	;sub.w	d4,d3
	;move.w	#3,d2
	;sub.w	d5,d2
	;mulu	#2,d2
	;add.b	d3,-1(a0)
	add.b	d4,-1(a0)
	addq.w	#1,d4
	
	move	ATTRIBUTE,(a0)
	or	#'=',(a0)+
	
	
	
	
	move.l	(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c1112	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1112
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c1112
.d1112
	sub.l	#4*2,a0
	move	ATTRIBUTE,(a0)
	or.w	#' ',(a0)+

	move.l	4(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c1113	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1113
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c1113
.d1113
	
	move	ATTRIBUTE,(a0)
	or.w	#' ',(a0)+

	
	move.l	8(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c1114	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d1114
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c1114
.d1114
	

	copy	<'    '>,a0



	fmove.x	(a6),fp0
	move.l	a6,-(sp)
	move.l	a0,a6
	xref	FLOAT_TO_SCI
	bsr.l	FLOAT_TO_SCI
	move.l	a6,a0
	move.l	(sp)+,a6




	
	
	add.l	#12,a6
	add.l	#12,a5







	;dbra	d4,.uio

	move.w	#$000d,(a0)+
	
	dbra	d5,.tyu
	
	move.w	#$000d,(a0)+
	
	
	lea	buffer_r+r_fpiar,a6
	lea	buffer_r_anc+r_fpiar,a5
	move.w	COL_NOR,ATTRIBUTE
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.df
	move.w	COL_CHG,ATTRIBUTE
.df
	copy	<'FPIAR='>,a0
	move.l	(a6),d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c11141	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d11141
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c11141
.d11141
	copy	<'   '>,a0
	
	
	
	
	lea	buffer_r+r_fpsr,a6
	lea	buffer_r_anc+r_fpsr,a5
	move.w	COL_NOR,ATTRIBUTE
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.df1
	move.w	COL_CHG,ATTRIBUTE
.df1
	copy	<'FPSR='>,a0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c11142	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d11142
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c11142
.d11142
	copy	<'   '>,a0
	
	
	
	
	
	lea	buffer_r+r_fpcr,a6
	lea	buffer_r_anc+r_fpcr,a5
	move.w	COL_NOR,ATTRIBUTE
	move.l	(a6),d0
	cmp.l	(a5),d0
	beq.s	.df11
	move.w	COL_CHG,ATTRIBUTE
.df11
	copy	<'FPCR='>,a0
	
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	clr	d1
.c11143	move.b	(a1)+,d1
	tst.b	-1(a1)
	beq.s	.d11143
	move	ATTRIBUTE,(a0)
	or.w	d1,(a0)+
	bra.s	.c11143
.d11143
	
	
	move.w	#$000d,(a0)+
	
	
	
	
	
	rts
	
	endc 
		