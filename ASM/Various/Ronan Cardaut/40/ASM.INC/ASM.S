	output	d:\centinel\40\asm.inc\asm.o
	incdir	d:\centinel\40
	include macros.s
	include	d:\centinel\both\define.s


	************************
	** Noyau d'assemblage **
	************************
	MC68030 
	
	
	
DEBUG	MACRO
	

	bra	.SUITE\@
.MES\@	dc.b	\1
	even
	dc.w	0
.SUITE\@
	pea	(a0)
	pea	(a1)
	lea	.MES\@,a0
	lea	erreur,a1
.ccc\@	move.b	(a0)+,(a1)+
	bne.s	.ccc\@

	move.l	(sp)+,a1
	move.l	(sp)+,a0
	moveq	#-1,d0
	
	
	;illegal
	ENDM

	
	
		rsreset			; le tailleq
no_size		rs.b	1
byte		rs.b	1
word		rs.b	1
long		rs.b	1

	
		rsreset			; structure de l'opcode
		
i_name		rs.b	8		; le nom de l'instruction
i_lenght	rs.w	1		; la taille de l'instruction
i_adr_s		rs.l	1		; les modes autoirse en source
i_adr_d		rs.l	1		; les modes autorise en destination
i_op		rs.l	1		; l'opcodde de l'instuction
i_nb_para	rs.w	1		; nb de parametres
i_adr_jump	rs.l	1		; routine qui va generer l'instruction


		rsreset			; stucture de la ligne d'entre
		
bin_pt		rs.l	1		; pointeur sur le precedent
bin_l_op	rs.w	1		; longueur opcode
bin_flags	rs.l	4		; flags divers
bin_code	rs.b	22		; l'opcode


		rsreset			; structure des mode d'adressages
		
long_adr	rs.l	1		; type du mode d(adressage
taille		rs.w	1		; longueur en memoire
mode_adr	rs.l	4		; mode d'adressage
	

	
	
	
	*******************************************************
	*                                                     *
	*                                                     *
	*         Tableau des modes d'adressages              *
	*                                                     *
	*                                                     *
	*    bit 0  : dn                                      *
	*    bit 1  : an                                      *
	*    bit 2  : (an)                                    *
	*    bit 3  : (an)+                                   *
	*    bit 4  : -(an)                                   *
	*    bit 5  : (d16,an)                                *
	*    bit 6  : (d8,an,xn)                              *
	*    bit 7  : (bd,an,xn)                              *
	*    bit 8  : ([bd,an,xn],od)                         *
	*    bit 9  : ([bd,an],xn,od)                         *
	*    bit 10 : (xxx).w                                 *
	*    bit 11 : (xxx).l                                 *
	*    bit 12 : #data                                   *
	*    bit 13 : ccr      on dirait que c'est prevu pour *
	*    bit 14 : sr                                      *
	*    bit 15 : (d16,pc)                                *
	*    bit 16 : (d8,pc,xn)                              *
	*    bit 17 : (bd,pc,xn)                              *
	*    bit 18 : ([bd,pc,xn],od)                         *
	*    bit 19 : ([bd,pc],xn,od)                         *
	*    bit 20 : usp                                     *
	*    bit 21 : registres etendues comme cacr, msp ...  *
	*             je stocke directement la valeur dans    *
	*             mode_adr                                *
	*    bit 22 : les cache du 40                         *
	*    bit 23 : registres avec des : comme d1:d2        *
	*             je stocke le premier en word            *
	*             puis le second                          *
	*    bit 24 : on peut utiliser les extraction de bits *
	*    bit 25 : on aura une liste de movem              *
	*             stock‚e sur un word dans ordre normal   *
	*                                                     *
	*******************************************************
	
	
	
	
	
r_asm::
	
	xref	GET_CHAINE,MES_ASM,MES_ERR_ASM,MES_PUT_OP
	xref	affiche_nombre_zero,nombre,eval
	xref	ATTRIBUTE
	xref	PETIT_MESSAGE,MESSAGE_ADR
	xref	ADR_VBR,TRACE,s_a7,pile_test,COL_ERR_L,ERR_MEM
	
	
	
	xref	ACTIVE_WINDOW
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_disas_68,type(a0)
	bne	.annule
	
	
	move.l	#MES_ASM,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.annule
	move.l	a2,a0				; dans a1 on a le debut de la chaine a exploiter
	
	
	
	; dans a0, on a l'instruction a assembler
	
	
	; on va tout mettre en majuscule
	
	
	
	move.l	a0,a2
.conv
	move.b	(a2)+,d0
	beq.s	.fin_c
	cmp.b	#'a',d0
	blt.s	.conv
	cmp.b	#'z',d0
	bgt.s	.conv
	sub.b	#32,-1(a2)		; on passe en maj
	
	bra.s	.conv
.fin_c
	
	
	; ici la chaine est en majuscule
	; il faut convertir les donnee numeriques
	
	
	lea	temp,a2
	
	
	bsr	convert_nb
	tst.l	d0
	bne	.err
	
	
	
	lea	temp,a0
	
	;illegal
	
	bsr	ass
	
	tst.l	d0
	bne	.err


	lea	binary,a0
	moveq	#0,d1
	move.w	bin_l_op(a0),d1
	
	
	lsr.w	#1,d1
	subq	#1,d1
	
	add.l	#bin_code,a0
	

	lea	temp,a2
.aff
	move.w	(a0)+,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move.l	4(a1),(a2)+
	dbra	d1,.aff


	clr.l	(a2)


	lea	temp,a2
	move.l	a2,MESSAGE_ADR
	
	
	
	lea	temp_cop,a1
	move.l	#MES_PUT_OP,a0
.k	move.b	(a0)+,(a1)+
	bne.s	.k
	subq	#1,a1
.k1
	move.b	(a2)+,(a1)+
	bne.s	.k1
	
	subq	#1,a1
	move.l	#') : ',(a1)+
	clr.b	(a1)
	
	move.l	#temp_cop,a0
	
	
	;bsr.l	GET_CHAINE
	;tst.b	d0
	;beq	.annule
	;move.l	a2,a0				; dans a1 on a le debut de la chaine a exploiter
	
	
	
	;bsr.l	eval
	;tst.b	d2
	;bne	.annule
	
	
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),a1
	
	
	; dans a1 on a l'adresse de destination
	
	lea	binary,a0
	moveq	#0,d0
	move.w	bin_l_op(a0),d0
	lsr.w	#1,d0
	subq	#1,d0
	add.l	#bin_code,a0
	
	; dans d0, on a la longeur de l'opcode
	; dans a0 on a le debut de l'opcode
	
	
	
	
.cop_o
	move.w	(a0)+,d1
	writ_mem.w	d1,a1
	addq	#2,a1
	dbra	d0,.cop_o
	
	
	
	
	
	xref	set_all_flags,traite_le_pc
	
	bsr.l	set_all_flags
	bsr.l	traite_le_pc
	
	
	
	
	
	
	
.annule

	rts
	
	
.err
	move.l	#MES_ERR_ASM,MESSAGE_ADR
	move.l  #erreur,MESSAGE_ADR
	rts
	
	
	******************************************************
	* les messages d'erreurs ne sont pas encore retourne *
	* centinel s'arrete sur un illegal commente          *
	******************************************************
	
	
ass
	
	;lea	chaine,a0			; les deux chaines qui seront plus tarde des pointeur
	lea	binary,a1	
	
	clr.l	(a1)
	clr.l	4(a1)
	clr.l	8(a1)
	clr.l	12(a1)
	clr.l	16(a1)
	clr.l	20(a1)
	clr.l	24(a1)
	clr.l	28(a1)
	clr.l	32(a1)
	
	
	move.l	#chaine,lab
	
	xref	p_c
	move.l	p_c,pc_t			; copie le pc d'assemblage
	
	
	
k	bsr	assemble
	
	lea	chaine,a0
	
	rts
	
	lea	binary,a1	
	add.l	#bin_code,a1
	illegal
	
	tst.l	([$5000.w,a1],1.w)

	
chaine	
	dc.b	'ADD.L (A0,D0),D1',0
	even
lab
	dc.b	0,0,0,0,0
	dc.b	'MOVEM.L D0-D3/D7-A0/A1-A3/A4,(A4)',0
	;dc.b	'TST.L (L',0,0,$50,00,'.W,PC,D7*4)',0
	;dc.b	'TST.L (L',0,0,$50,00,'.L,A4)',0
	dc.b	'TST.L ([L',0,0,$50,00,',A0,D7*4],L',0,0,0,1,'.W)',0
	dc.b	'DBRA D4,L',0,0,0,$89,0
	dc.b	'EORI #L',$0,$0,$56,$78,',CCR',0
	dc.b	'CMP.L #L',$12,0,$56,$78,',D7',0
	;dc.b	'CMP.L (A7,D4),D7',0
	dc.b	'CMP.L (L',0,0,$56,$78,',PC),D7',0
	dc.b	50,0
	even
		
	; dans a0 on a la chaine a assembler
	
	
	
	
assemble
	movem.l	d1-a6,-(sp)		; on ne sauve pas d0 car il faudra renvoyer l'erreur
	
	
	
	
	
	move.l	a1,s_binary
	clr.w	bin_l_op(a1)		; on efface la taille de l'opcode
	clr.w	bf_mode
	
	lea	mode_source,a6
	clr.l	(a6)
	clr.l	4(a6)
	clr.l	8(a6)
	clr.l	12(a6)
	clr.l	16(a6)
	clr.l	20(a6)
	lea	mode_destination,a6
	clr.l	(a6)
	clr.l	4(a6)
	clr.l	8(a6)
	clr.l	12(a6)
	clr.l	16(a6)
	clr.l	20(a6)
	
	
	move.l	a0,a1
	
	bsr	get_instruction		; dans buffer_instruction, on recupere l'instruction.
	tst.l	d0
	bne.s	.erreur
	
	move.w	d1,taille_work
	
	
	bsr	cherche_descripteur	; on va recherche dans le tableau des instruction le descripteur
	tst.l	d0
	bne.s	.erreur	
	
	
	; ici dans a1 on a le pointeur sur le descripteur de l'instruction
	; on a la taille dans d1 
	
	move.l	a0,a2		
	bsr	get_adressing_mode	
	tst.l	d0
	bmi.s	.erreur
	
	
	
	jsr	([i_adr_jump,a1])
	
	
	
	
	
	
	
	
	movem.l	(sp)+,d1-a6
	rts
.erreur
	moveq	#-1,d0			; on crache l'erreur dans d0
	movem.l	(sp)+,d1-a6
	rts
	
	
	
	
	
	
	
get_instruction
	*****************************************************************
	** Routine qui va extraire l'instruction                       **
	** et qui va la complete avec des espaces pour que taille =8   **
	**                                                             **
	** en entr‚e                                                   **
	** ---------                                                   **
	**                                                             **
	**       - la chaine pointee par a1                            **
	**                                                             ** 
	** en retour:                                                  **
	** ----------                                                  **
	**       - l'instuction sans la taille dans buffer_instruction **	
	**       - dans d1 la taille sur laquelle on va trvailler      **
	**                     - no_size  : pas de taille              **
	**                     - byte     : en byte                    **
	**                     - word     : en word                    **
	**                     - long     : en long                    **
	**                                                             **
	**       - d0=0   => tout est ok                               **
	**       - d0<>0  => erreur                                    **
	*****************************************************************
	
	
	
	
	
	movem.l	d2-a6,-(sp)
	
	moveq	#no_size,d1				; pas de taille 
	
	tst.b	(a1)
	beq.s	.erreur
	
	
	
	lea	buffer_instruction,a0
.copie_inst
	move.b	(a1)+,d0			; on copie l'instruction , on arrete sur un point, la fin, ou un espace
	beq.s	.exit
	cmp.b	#' ',d0
	beq.s	.exit
	cmp.b	#'.',d0
	beq.s	.point
	move.b	d0,(a0)+
	bra.s	.copie_inst
.point	
	cmp.b	#'L',(a1)
	bne.s	.p_l
	moveq	#long,d1	
	bra.s	.exit
.p_l
	cmp.b	#'W',(a1)
	bne.s	.p_w
	moveq	#word,d1	
	bra.s	.exit
.p_w
	cmp.b	#'B',(a1)
	bne.s	.p_b
	moveq	#byte,d1	
	bra.s	.exit
.p_b
	cmp.b	#'S',(a1)
	bne.s	.p_b1
	moveq	#byte,d1	
	bra.s	.exit
.p_b1
	
	nop					; on pourra ajouter des tailles
	
.exit

	clr.b	(a0)				; on termine la chaine
	
	
	moveq	#0,d0				; on complete avec des espaces pour avoir une taille de 8
	lea	buffer_instruction,a0
.d	move.b	(a0),d2
	beq.s	.zero
	addq.l	#1,d0
	addq.l	#1,a0
	cmp.b	#8,d0
	beq.s	.fin
	bra.s	.d	
.zero
	moveq	#7,d3
	sub.l	d0,d3
.aj_spc	move.b	#' ',(a0)+
	dbra	d3,.aj_spc
	clr.b	(a0)+

.fin
	moveq	#0,d0				; erreur =0
	movem.l	(sp)+,d2-a6
	rts
.erreur
	moveq	#-1,d0
	movem.l	(sp)+,d2-a6
	rts
	


cherche_descripteur	
	****************************************************************************
	** Routine qui va renvoyer le pointeur sur la description de l'instuction **
	**                                                                        **
	** Entr‚e:                                                                **
	** -------                                                                **
	**           - la chaine buffer_instruction (implicite)                   **
	**                                                                        **
	** Sortie:                                                                **
	** -------                                                                **
	**           - dans a1 le pointeur sur le descripteur                     **
	**           - d0=0   => Ok                                               **
	**           - d0<>0  => instruction non trouvee                          **
	**                                                                        **
	****************************************************************************


	movem.l	d1-a0/a2-a6,-(sp)

	lea	Table_instruction,a0
	
.cherche
	move.l	a0,a2
	lea	buffer_instruction,a1
	cmpm.l	(a1)+,(a0)+
	bne.s	.p_instru
	cmpm.l	(a1)+,(a0)+
	bne.s	.p_instru
	
	sub.l	#8,a0
	bra.s	.exit
	
.p_instru
	move.l	a2,a0
	add.l	#i_adr_jump+4,a0
	cmp.l	#'FIN ',(a0)
	beq.s	.erreur
	bra.s	.cherche





.exit
	move.l	a0,a1
	moveq	#0,d0				; erreur =0
	movem.l	(sp)+,d1-a0/a2-a6
	rts
.erreur
	movem.l	(sp)+,d1-a0/a2-a6

	DEBUG	<'instruction inconnue'>
	
	lea	Err_instruc_not_found,a1
.cop_ch	move.b	(a1)+,(a0)+
	bne.s	.cop_ch
	moveq	#-1,d0
	rts
	

	rts


	
	
get_adressing_mode
	*****************************************************
	** Routine qui va recuperer les modes d'adressages **
	**                                                 **
	** Entr‚e:                                         **
	** -------                                         **
	**           - a2 pointe sur le debut de l'opcode  **
	**           - a1 pointe sur la structure          **
	**                                                 **
	** Sortie:                                         **
	** -------                                         **
	**           - d0=0   ok                           **
	**             d0<>0  erreur                       **
	**                                                 **
	*****************************************************




	movem.l	d1-a6,-(sp)	

	moveq	#0,d7

.zoop
	move.b	(a2)+,d1
	beq	.rien				; rien => pas de registres
	cmp.b	#' ',d1
	bne.s	.zoop
	
	; ici, on pointe apres l'opcode
	
	
	bsr	teste_paranthese
	tst.b	d0
	bmi	.err_paranthese
	
	
	; ici, on a alors une ou eux chaine commencant par a2 et separe par une zero
	
	
	

	addq.l	#1,d7


	lea	mode_source,a0
	bsr	cal_mode_adr

	move.l	i_adr_s(a1),d2
	and.l	long_adr(a0),d2
	beq	.erreur_adressing_mode
	
	move.l	i_adr_s(a1),d2
	btst	#7,bf_mode
	beq.s	.p_ex1
	btst	#24,d2
	beq	.erreur_adressing_mode
	
.p_ex1
	moveq	#1,d5
	btst	#7,bf_mode
	beq.s	.norm	
	moveq	#2,d5			; ici on va suter l'accolade ouverte qui est un zero
.norm
	
	cmp.b	#2,d0
	bne.s	.que_un

.ch_z
	move.b	(a2)+,d0
	cmp.b	#'L',d0			; on recherhe le debut de la prochaine chaine
	bne.s	.cont
	cmp.b	#'.',-2(a2)
	beq.s	.cont			; on un .L
	
	addq.l	#4,a2			; on a un chiffre codage ronan
	bra.s	.ch_z
.cont
	
	
	tst.b	d0
	beq.s	.l1
	bra.s	.ch_z
.l1
	subq.l	#1,d5
	bne.s	.ch_z
	
	
	
	
	addq.l	#1,d7
	
	lea	mode_destination,a0
	bsr	cal_mode_adr
	
	
	move.l	i_adr_d(a1),d2
	and.l	long_adr(a0),d2
	beq	.erreur_adressing_mode

	move.l	i_adr_d(a1),d2
	btst	#7,bf_mode
	bne.s	.p_ex
	btst	#24,d2
	bne	.erreur_adressing_mode
	
.p_ex



.que_un

	cmp.w	#5,i_nb_para(a1)		; regarde si on peut avoir un ou zero parametres
	bne.s	.p_zero_un

	cmp.w	#1,d7
	beq	.ok
	cmp.w	#0,d7
	beq	.ok
	bra	.erreur_para	
	
	
.p_zero_un




	cmp.w	#4,i_nb_para(a1)		; regarde si on la droit a un ou deux parametres
	bne.s	.pas_un_deux

	cmp.w	#1,d7
	beq.s	.ok
	cmp.w	#2,d7
	beq.s	.ok
	bra	.erreur_para


.pas_un_deux


	cmp.w	#3,i_nb_para(a1)
	bne.s	.pas_trois
	
	cmp.w	#2,d7
	bne	.erreur_para
	
	lea	mode_supplementaire,a3
	tst.l	long_adr(a3)
	beq	.erreur_para
	
	bra	.ok
	
	
.pas_trois




	cmp.w	i_nb_para(a1),d7
	bne	.erreur_para



.ok

	movem.l	(sp)+,d1-a6	
	rts
.rien
	
	cmp.w	#5,i_nb_para(a1)
	beq.s	.ok_r
	
	cmp.w	i_nb_para(a1),d7
	bne	.erreur_para
	
	cmp.l	#0,i_adr_s(a1)			; on verifie qu'il ne faut pas de parametres
	bne.s	.erreur
	cmp.l	#0,i_adr_d(a1)
	bne.s	.erreur

.ok_r
	moveq	#0,d0
	movem.l	(sp)+,d1-a6
	rts
	
	
.erreur
	
	moveq	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
	
.err_paranthese
	DEBUG	<'paranthese retour erreur'>
	movem.l	(sp)+,d1-a6
	rts

.erreur_adressing_mode
	DEBUG	<'mode d adressage incorrect'>
	movem.l	(sp)+,d1-a6
	rts

.erreur_para
	DEBUG	<'pas le bon nombre de parametres'>
	movem.l	(sp)+,d1-a6
	rts
	
	
	
cal_mode_adr
	***************************************************
	** Routine qui va evaluer les modes d'adressages **
	***************************************************
	
	
	movem.l	d0-a6,-(sp)
	
	
	clr.l	long_adr(a0)			; taille=0 => pas de mode d'adressage
	
	
	bsr	check_movem
	tst.l	d0
	bmi	.erreur
	beq	.exit

	
	bsr	check_bf
	tst.l	d0
	bmi	.erreur
	
	
	
	bsr	check_new_reg
	tst.l	d0		
	bmi	.erreur				; une erreur
	beq	.exit				; on a trouve
	
	
	bsr	check_2_points
	tst.l	d0		
	bmi	.erreur				; une erreur
	beq	.exit				; on a trouve
	
	
	
	;------------------  SR ---------------------------------
	
	
	cmp.w	#'SR',(a2)			; teste 
	bne.s	.kl
	tst.b	2(a2)
	bne	.erreur
	
	move.w	#2,taille(a0)
	move.l	#%100000000000000,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#%111100,mode_adr(a0)
	
	bra	.exit
	
	;------------------  CCR ---------------------------------
.kl
	cmp.w	#'CC',(a2)			; teste 
	bne.s	.kl1
	cmp.w	#'R'<<8,2(a2)
	bne	.erreur
	
	move.w	#2,taille(a0)
	move.l	#%10000000000000,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#%111100,mode_adr(a0)
	
	bra	.exit
.kl1
	;------------------- USP ----------------------------------
	
	cmp.w	#'US',(a2)			; teste 
	bne.s	.kl2
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	
	move.w	#2,taille(a0)
	move.l	#1<<20,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#%111100,mode_adr(a0)
	
	bra	.exit
.kl2
	
	
	;------------------  immediat ---------------------------------
	cmp.w	#'#L',(a2)
	bne.s	.p_chiffre
	
	tst.b	6(a2)
	bne	.erreur
	
	
	move.w	#6,taille(a0)
	move.l	#%1000000000000,long_adr(a0)			; type donnee     bit 0 a un
	clr.w	d0				; registre dde donnee
	move.w	#%111100,d0
	move.w	d0,mode_adr(a0)
	move.l	2(a2),mode_adr+2(a0)		; on stocke la valeur
	
	
	bra	.exit
.p_chiffre
	cmp.b	#'L',(a2)
	bne	.p_chiffre_1
	
	
	cmp.w	#'.W',5(a2)
	beq.s	.word		; on a un truc xxxx.l
	
	tst.b	5(a2)
	beq.s	.ok_mode
	tst.b	7(a2)
	bne	.erreur
	
.ok_mode
	
	
	
	move.w	#6,taille(a0)
	move.l	#%100000000000,long_adr(a0)			; type donnee     bit 0 a un
	clr.w	d0				; registre dde donnee
	move.w	#%111001,d0
	move.w	d0,mode_adr(a0)
	move.l	1(a2),mode_adr+2(a0)		; on stocke la valeur
	
	
	
	bra	.exit
.word				; on a un truc xxxx.w
	move.w	#4,taille(a0)
	move.l	#%10000000000,long_adr(a0)			; type donnee     bit 0 a un
	clr.w	d0				; registre dde donnee
	move.w	#%111000,d0
	move.w	d0,mode_adr(a0)
	move.l	3(a2),mode_adr+2(a0)		; on stocke la valeur
	
	
	
	bra	.exit
.p_chiffre_1
	
	
	;------------------  donnee ---------------------------------
	
	cmp.b	#'D',(a2)
	bne	.p_donnee
	cmp.b	#'0',1(a2)
	blt	.erreur
	cmp.b	#'7',1(a2)
	bgt	.erreur
	tst.b	2(a2)				; si la chaine ne se finie pas
	bne	.exit
	
	move.w	#2,taille(a0)
	move.l	#1,long_adr(a0)			; type donnee     bit 0 a un
	clr.w	d0				; registre dde donnee
	move.b	1(a2),d0
	sub.b	#'0',d0
	move.w	d0,mode_adr(a0)
	
	
	
	bra	.exit
.p_donnee
	;------------------  adresse ---------------------------------

	cmp.b	#'A',(a2)
	bne.s	.p_adr
	cmp.b	#'0',1(a2)
	blt	.erreur
	cmp.b	#'7',1(a2)
	bgt	.erreur
	tst.b	2(a2)
	bne	.exit
	
	move.w	#2,taille(a0)
	move.l	#2,long_adr(a0)			; type adresse		bit 1 a un
	move.w	#%001000,d0			; regisre d'adresse
	
	move.b	1(a2),d1
	sub.b	#'0',d1
	or.b	d1,d0
	
	move.w	d0,mode_adr(a0)
	
	
	bra	.exit
	
	;------------------  indirect ---------------------------------
.p_adr
	cmp.b	#'(',(a2)			; teste du (an)
	bne.s	.p_indi
	cmp.b	#'A',1(a2)
	bne.s	.p_indi
	
	cmp.b	#'0',2(a2)
	blt	.erreur
	cmp.b	#'7',2(a2)
	bgt	.erreur
	
	cmp.b	#')',3(a2)
	bne.s	.p_indi
	
	
	tst.b	4(a2)
	bne	.p_indi
	
	move.w	#2,taille(a0)
	move.l	#4,long_adr(a0)			; type adresse		bit 2 a un
	move.w	#%010000,d0			; regisre d'adresse
	move.b	2(a2),d1
	sub.b	#'0',d1
	or.b	d1,d0
	move.w	d0,mode_adr(a0)
	
	
	bra	.exit
	
	;------------------  postincremente ---------------------------------
.p_indi
	cmp.b	#'(',(a2)			; teste du (an)+
	bne.s	.p_indi_post
	cmp.b	#'A',1(a2)
	bne.s	.p_indi_post
	
	cmp.b	#'0',2(a2)
	blt	.erreur
	cmp.b	#'7',2(a2)
	bgt	.erreur
	
	cmp.w	#')+',3(a2)
	bne.s	.p_indi_post
	
	
	tst.b	5(a2)
	bne.s	.p_indi_post
	
	move.w	#2,taille(a0)
	move.l	#8,long_adr(a0)			; type adresse		bit 3 a un
	move.w	#%011000,d0			; regisre d'adresse
	move.b	2(a2),d1
	sub.b	#'0',d1
	or.b	d1,d0
	move.w	d0,mode_adr(a0)
	
	
	bra	.exit
.p_indi_post
	
	
	;------------------  predecremente ---------------------------------
	
	
	
	cmp.w	#'-(',(a2)			; teste du -(an)
	bne.s	.p_indi_pred
	cmp.b	#'A',2(a2)
	bne.s	.p_indi_pred
	
	cmp.b	#'0',3(a2)
	blt	.erreur
	cmp.b	#'7',3(a2)
	bgt	.erreur
	
	cmp.b	#')',4(a2)
	bne.s	.p_indi_pred
	
	
	tst.b	5(a2)
	bne.s	.p_indi_pred
	
	move.w	#2,taille(a0)
	move.l	#16,long_adr(a0)		; type adresse		bit 4 a un
	move.w	#%100000,d0			; regisre d'adresse
	move.b	3(a2),d1
	sub.b	#'0',d1
	or.b	d1,d0
	move.w	d0,mode_adr(a0)
	
	
	bra	.exit
.p_indi_pred
	
	
	;-------------------- etendu ---------------------------------------
	
	cmp.w	#'([',(a2)		; on va regarder si on a ou non un indirect
	beq.s	.indirect_m
	
	move.w	#0,ADR_PC		; 0 dans l'adressage PC
	
	bsr	etendu
	tst.l	d0
	bmi	.erreur
	cmp.l	#1,d0
	beq	.exit
	
	
	;-------------------- etendu PC ------------------------------------
	
	
	move.w	#1,ADR_PC		; on va travailler en PC relatif
	
	
	bsr	etendu_pc
	tst.l	d0
	bmi	.erreur
	cmp.l	#1,d0
	beq	.exit
	
	
	
	move.w	#0,ADR_PC
	
	
	bra.s	.erreur			; on a epuis‚ tous les mode => erreur
	
	
.indirect_m
	
	*------------------- Etendu avec des crochets en plus ----------------------
	
	
	
	
	
	move.w	#1,ADR_PC		; 0 dans l'adressage PC
	
	bsr	check_indirect_pc
	tst.l	d0
	bmi	.erreur
	cmp.l	#1,d0
	beq	.exit
	
	
	
	*------------------- Etendu avec des crochets en plus ----------------------
	

	move.w	#0,ADR_PC		; on va travailler en PC relatif
	
	
	bsr	check_indirect
	tst.l	d0
	bmi	.erreur
	cmp.l	#1,d0
	beq	.exit
	
	
	
	



	
	bra.s	.erreur
.exit
	
	moveq	#0,d0
	movem.l	(sp)+,d0-a6
	rts
	
.erreur
	moveq	#-1,d0
	movem.l	(sp)+,d0-a6
	rts
	
.erreur_paranthese
	DEBUG	'parantheses_fausses'
	moveq	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
		

.erreur_taille
	bra	erreur_taille
		
	
	
	
check_movem
	************************************************************
	** Routine qui va chercher si on a une liste de registres **
	************************************************************
	
	
	movem.l	d1-a6,-(sp)
	moveq	#0,d0
	
	move.l	a2,a6
	
	
	*-- on commence pas regarder si on a des diviser ---*
	
.again
	move.b	(a2)+,d1
	beq.s	.pas_diago
	cmp.b	#'/',d1
	beq.s	.oui
	bra.s	.again
.pas_diago
	move.l	a6,a2
	
	*-- puis on regarde s'il y des -  ---*
	
	
	move.b	(a2)+,d1		; si on a un moins en premier ce ne peut etre que du predecremente
	beq	.pas_movem
	cmp.b	#'-',d1
	beq	.pas_movem	
.again1
	move.b	(a2)+,d1
	beq	.pas_movem
	cmp.b	#'-',d1
	beq.s	.oui
	bra.s	.again1
.oui
	
	*-- ariv‚ ici on a soit des - soit des /  ---*
	
	;DEBUG	<'liste reg'>
	
	move.l	a6,a2
	moveq	#0,d1			; on clear la liste des registres 
	moveq	#0,d7			; pas de pr‚cdent
	moveq	#-1,d5			; les bits a -1 pour l'insertion dans le champ
	
.decortique
	move.b	(a2)+,d2
	beq	.exit_s
	
	cmp.b	#'D',d2			; on regadrde si on a un registres de donnee
	bne.s	.p_donnee
	cmp.b	#'0',(a2)
	blt	.erreur
	cmp.b	#'7',(a2)
	bgt	.erreur	
	
	tst.b	1(a2)			; si apres, on a pas - ou / ou rien alors erreur
	beq.s	.ok_d
	cmp.b	#'-',1(a2)
	beq.s	.ok_li_d
	cmp.b	#'/',1(a2)
	beq.s	.ok_d
	bra	.erreur
.ok_d
	*--- ici, on a un regitre seul ou la fin d'une liste de registres --*
	tst.l	d7
	bne.s	.liste_r
	*-- registre seul --*
	move.b	(a2),d6
	sub.b	#'0',d6
	bset	d6,d1
	addq	#1,a2
	bra	.decortique
.liste_r
	*-- liste de registre qui se termine --*
	move.b	(a2),d6
	sub.b	#'0',d6
	cmp.b	d7,d6
	blt	.erreur			; le registre destination est plus petit que les autres => erreur	
	moveq	#31,d4
	sub.b	d6,d4
	sub.b	d7,d6
	move.b	d6,d7
	addq.b	#1,d7
	bclr	#31,d7
	bfins	d5,d1{d4:d7}
	clr.l	d7
	addq	#1,a2
	bra	.decortique
.ok_li_d
	*--- ici, on aura une liste de registre
	
	tst.l	d7		; si on a une liste en cours => erreur
	bne	.erreur
	move.b	(a2),d7
	sub.b	#'0',d7
	bset	#31,d7
	addq	#1,a2
	bra	.decortique
	
		




	
	
.p_donnee
	cmp.b	#'A',d2			; on regarde si on a un registre d'adresse
	bne.s	.p_adresse
	cmp.b	#'0',(a2)
	blt	.erreur
	cmp.b	#'7',(a2)
	bgt	.erreur	
	
	tst.b	1(a2)			; si apres, on a pas - ou / ou rien alors erreur
	beq.s	.ok_a
	cmp.b	#'-',1(a2)
	beq.s	.ok_li_a
	cmp.b	#'/',1(a2)
	beq.s	.ok_a
	bra	.erreur
.ok_a
	*--- ici, on a un regitre seul ou la fin d'une liste de registres --*
	tst.l	d7
	bne.s	.liste_a
	*-- registre seul --*
	move.b	(a2),d6
	sub.b	#'0',d6
	addq.b	#8,d6
	bset	d6,d1
	addq	#1,a2
	bra	.decortique
.liste_a
	*-- liste de registre qui se termine --*
	move.b	(a2),d6
	sub.b	#'0',d6
	addq.w	#8,d6
	cmp.b	d7,d6
	blt	.erreur			; le registre destination est plus petit que les autres => erreur	
	moveq	#31,d4
	sub.b	d6,d4
	sub.b	d7,d6
	move.b	d6,d7
	addq.b	#1,d7
	bclr	#31,d7
	bfins	d5,d1{d4:d7}
	clr.l	d7
	addq	#1,a2
	bra	.decortique
.ok_li_a
	*--- ici, on aura une liste de registre
	
	tst.l	d7		; si on a une liste en cours => erreur
	bne	.erreur
	move.b	(a2),d7
	sub.b	#'0',d7
	addq.b	#8,d7
	bset	#31,d7
	addq	#1,a2
	bra	.decortique
	
	
	
	
	
	
	
.p_adresse
	cmp.b	#'/',d2
	bne.s	.p_anti_s
	cmp.b	#'A',(a2)
	beq	.decortique
	cmp.b	#'D',(a2)
	beq	.decortique
	bra	.erreur
.p_anti_s
	cmp.b	#'-',d2
	bne.s	.p_moins
	cmp.b	#'A',(a2)
	beq	.decortique
	cmp.b	#'D',(a2)
	beq	.decortique
	cmp.b	#'0',(a2)
	blt	.erreur
	cmp.b	#'7',(a2)
	ble	.decortique
	bra	.erreur
.p_moins
	cmp.b	#'0',d2
	blt	.erreur
	cmp.b	#'7',d2
	bgt	.erreur
	
	;DEBUG	<'debut de registre'>
	
	bra	.decortique
	
	
.exit_s
	;DEBUG	<'ok liste'>
	move.w	#2,taille(a0)
	move.l	#1<<25,long_adr(a0)	; type donnee     bit 0 a un
	move.w	d1,mode_adr(a0)		; on aura la liste des movem ici commencant par
	
	movem.l	(sp)+,d1-a6
	rts
	
	
.pas_movem
	moveq	#1,d0
	movem.l	(sp)+,d1-a6
	rts
	
	
.erreur
	DEBUG	<'Erreur dans la liste des movem'>
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
	
	
	
check_bf
	**********************************************************
	** Routine qui cva regarder si on a un mode d'adressage **
	** avec des accolades                                   **
	**********************************************************
	
	
	
	movem.l	d1-a6,-(sp)
	
	moveq	#0,d0
	
	tst.w	bf_mode
	bne	.exit
	
	clr	bf_mode
	
.cherche
	move.b	(a2)+,d2
	beq	.exit
	cmp.b	#'{',d2			; recherche de l'accolade ouverte
	beq.s	.ok_first
	cmp.b	#'L',d2			; teste si on a un nombre
	bra	.cherche
	cmp.b	#'.',-2(a2)
	beq.s	.cherche
	addq.l	#4,a2
	bra.s	.cherche	

.ok_first
	bset	#7,bf_mode		; on valide le mode

	clr.b	-1(a2)			; on coupe la chaine pour ne pas perturber la suite
	
	moveq	#1,d1			; on a une accolade ouverte
	move.l	a2,a3
.ch_f
	move.b	(a3)+,d2
	beq.s	.fin_c
	cmp.b	#'L',d2
	bne.s	.cont
	cmp.b	#'.',-2(a3)
	beq.s	.cont
	addq	#4,a3
	bra	.ch_f
.cont
	
	cmp.b	#'(',d2
	beq	.erreur
	cmp.b	#'[',d2
	beq	.erreur
	cmp.b	#']',d2
	beq	.erreur
	cmp.b	#')',d2
	beq	.erreur
	cmp.b	#'}',d2			; si on a une } suivie d'un zero alors ok
	bne.s	.ch_f
	tst.b	(a3)
	bne	.erreur
	
.fin_c
	
	subq	#1,a2
	cmp.b	#':',3(a2)
	beq	.donnee_en_src
	cmp.b	#':',6(a2)		; si pas de donne en src, alors on doit avoir un nombre
	bne	.erreur
	
	; ici on doit avoir un long en source
	
	cmp.b	#'L',1(a2)
	bne	.erreur
	move.l	2(a2),d1
	cmp.l	#31,d1
	bgt	.erreur_nb
	
	bfins	d1,bf_mode{5:5}
	
	cmp.b	#'D',7(a2)
	bne.s	.donnee_dest
	
	cmp.w	#'}'<<8,9(a2)
	bne	.erreur
	
	; ici on a une donne en destination
	
	cmp.b	#'0',8(a2)
	blt	.erreur
	cmp.b	#'7',8(a2)
	bgt	.erreur
	clr.w	d1
	move.b	8(a2),d1
	sub.b	#'0',d1
	bfins	d1,bf_mode{11:5}
	bset	#5,bf_mode+1
	bra	.exit
	
	
.donnee_dest
	cmp.b	#'L',7(a2)
	bne	.erreur
	cmp.w	#'}'<<8,12(a2)
	bne	.erreur
	move.l	8(a2),d1
	cmp.l	#32,d1
	bgt	.erreur_nb
	tst.l	d1
	beq	.erreur_nb
	cmp.l	#32,d1
	bne.s	.p_nul1
	moveq	#0,d1
.p_nul1
	
	bfins	d1,bf_mode{11:5}
	
	
	
	
	
	
	
	
	bra	.exit
	
.donnee_en_src
	cmp.b	#'D',1(a2)		; si pas de donne => erreur
	bne	.erreur
	cmp.b	#'0',2(a2)
	blt	.erreur
	cmp.b	#'7',2(a2)
	bgt	.erreur
	clr.w	d3
	move.b	2(a2),d3
	sub.b	#'0',d3			; on a le registre de donnee
	bset	#3,bf_mode
	bfins	d3,bf_mode{5:5}
	
	; testons la destination
	
	
	cmp.b	#'D',4(a2)
	bne.s	.p_long
	; ici on devrait avoir une donne
	cmp.w	#'}'<<8,6(a2)
	bne	.erreur
	cmp.b	#'0',5(a2)
	blt	.erreur
	cmp.b	#'7',5(a2)
	bgt	.erreur
	clr.w	d3
	move.b	5(a2),d3
	sub.b	#'0',d3			; on a le registre de donnee
	bset	#5,bf_mode+1
	bfins	d3,bf_mode{11:5}
	bra.s	.exit
	
.p_long
	cmp.b	#'L',4(a2)
	bne.s	.erreur
	
	cmp.w	#'}'<<8,9(a2)
	bne.s	.erreur	
	
	move.l	5(a2),d1
	cmp.l	#32,d1
	bgt	.erreur_nb
	tst.l	d1
	beq.s	.erreur_nb
	cmp.l	#32,d1
	bne.s	.p_nul
	moveq	#0,d1
.p_nul
	bfins	d1,bf_mode{11:5}
	
	
	
	
	
	
	
	
	
	
.exit
	movem.l	(sp)+,d1-a6
	
	rts
	
	
.erreur
	DEBUG	<'Invalid bitfield data'>
	movem.l	(sp)+,d1-a6
	rts
.erreur_nb
	DEBUG	<'Donnee trop grande'>
	movem.l	(sp)+,d1-a6
	rts
.erreur_mode
	movem.l	(sp)+,d1-a6
	DEBUG	<'Mode d adressage incorrect'>
	rts
	
	
	
	
check_2_points
	****************************************************************
	** routine qui va regarder si on a un adressage du type d0:d1 **
	****************************************************************


	moveq	#0,d0
	cmp.b	#':',2(a2)			; on regarde si on a un :
	bne.s	.p_d_p
	cmp.b	#'D',(a2)
	bne.s	.erreur
	cmp.b	#'D',3(a2)
	bne.s	.erreur
	
	clr.w	d1				; le premier dn
	move.b	1(a2),d1
	cmp.b	#'0',d1
	blt	.erreur
	cmp.b	#'7',d1
	bgt	.erreur
	move.w	#4,taille(a0)
	move.l	#1<<23,long_adr(a0)
	sub.b	#'0',d1
	move.w	d1,mode_adr(a0)
	
	clr.w	d1				; le second dn
	move.b	4(a2),d1
	cmp.b	#'0',d1
	blt	.erreur
	cmp.b	#'7',d1
	bgt	.erreur
	sub.b	#'0',d1
	move.w	d1,mode_adr+2(a0)
	
	bra.s	.exit
	
.p_d_p
	moveq	#1,d0
.exit
	rts
.erreur
	moveq	#-1,d0
	rts
	
	
	
	
	
	
check_new_reg
	**********************************************************
	** Routine qui va regarde si on a de nouveaux registres **
	**********************************************************

	
	moveq	#0,d0
	
	
	; ----------------- les registres de cache du 40 ------
	
	
	;------------------  NC -------------------
	cmp.w	#'NC',(a2)			; teste 
	bne.s	.c
	tst.b	2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<22,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#0,mode_adr(a0)
	bra	.exit
.c
	;------------------  DC -------------------
	cmp.w	#'DC',(a2)			; teste 
	bne.s	.c1
	tst.b	2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<22,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#1,mode_adr(a0)
	bra	.exit
.c1
	;------------------  IC -------------------
	cmp.w	#'IC',(a2)			; teste 
	bne.s	.c2
	tst.b	2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<22,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#2,mode_adr(a0)
	bra	.exit
.c2
	;------------------  BC -------------------
	cmp.w	#'BC',(a2)			; teste 
	bne.s	.c3
	tst.b	2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<22,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#3,mode_adr(a0)
	bra	.exit
.c3
	
	
	; ----------------- les autres registres ------
	
	;------------------  TC -------------------
	cmp.w	#'TC',(a2)			; teste 
	bne.s	.k
	tst.b	2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$003,mode_adr(a0)
	bra	.exit
.k
	
	;------------------- SFC ------------------
	cmp.w	#'SF',(a2)			; teste 
	bne.s	.k1
	cmp.w	#'C'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$000,mode_adr(a0)
	bra	.exit
.k1
	;------------------- DFC ------------------
	cmp.w	#'DF',(a2)			; teste 
	bne.s	.k2
	cmp.w	#'C'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$001,mode_adr(a0)
	bra	.exit
.k2
	;------------------- USP ------------------
	cmp.w	#'US',(a2)			; teste 
	bne.s	.k3
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21+1<<20,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$800,mode_adr(a0)
	bra	.exit
.k3
	;------------------- VBR ------------------
	cmp.w	#'VB',(a2)			; teste 
	bne.s	.k4
	cmp.w	#'R'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$801,mode_adr(a0)
	bra	.exit
.k4
	;------------------- MSP ------------------
	cmp.w	#'MS',(a2)			; teste 
	bne.s	.k5
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$803,mode_adr(a0)
	bra	.exit
.k5
	;------------------- ISP ------------------
	cmp.w	#'IS',(a2)			; teste 
	bne.s	.k6
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$804,mode_adr(a0)
	bra	.exit
.k6
	;------------------- URP ------------------
	cmp.w	#'UR',(a2)			; teste 
	bne.s	.k7
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$806,mode_adr(a0)
	bra	.exit
.k7
	;------------------- SRP ------------------
	cmp.w	#'SR',(a2)			; teste 
	bne.s	.k8
	cmp.w	#'P'<<8,2(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$807,mode_adr(a0)
	bra	.exit
.k8
	;------------------- CACR ------------------
	cmp.w	#'CA',(a2)			; teste 
	bne.s	.k9
	cmp.w	#'CR',2(a2)
	bne.s	.k9
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$002,mode_adr(a0)
	bra	.exit
.k9
	;------------------- CAAR ------------------
	cmp.w	#'CA',(a2)			; teste 
	bne.s	.k10
	cmp.w	#'CR',2(a2)
	bne.s	.k10
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$802,mode_adr(a0)
	bra	.exit
.k10
	;------------------- ITT0 ------------------
	cmp.w	#'IT',(a2)			; teste 
	bne.s	.k11
	cmp.w	#'T0',2(a2)
	bne.s	.k11
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$004,mode_adr(a0)
	bra	.exit
.k11
	;------------------- ITT1 ------------------
	cmp.w	#'IT',(a2)			; teste 
	bne.s	.k12
	cmp.w	#'T1',2(a2)
	bne.s	.k12
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$005,mode_adr(a0)
	bra	.exit
.k12
	;------------------- DTT0 ------------------
	cmp.w	#'DT',(a2)			; teste 
	bne.s	.k13
	cmp.w	#'T0',2(a2)
	bne.s	.k13
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$006,mode_adr(a0)
	bra	.exit
.k13
	;------------------- DTT1 ------------------
	cmp.w	#'DT',(a2)			; teste 
	bne.s	.k14
	cmp.w	#'T1',2(a2)
	bne.s	.k14
	tst.b	4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$007,mode_adr(a0)
	bra	.exit
.k14
	;------------------- MMUSR ------------------
	cmp.w	#'MM',(a2)			; teste 
	bne.s	.k15
	cmp.w	#'US',2(a2)
	bne.s	.k15
	cmp.w	#'R'<<8,4(a2)
	bne	.erreur
	move.w	#2,taille(a0)
	move.l	#1<<21,long_adr(a0)	; type donnee     bit 0 a un
	move.w	#$805,mode_adr(a0)
	bra	.exit
.k15

	moveq	#1,d0			; aucun registre de trouve	
.exit
	rts
	
.erreur
	moveq	#-1,d0
	rts
	
	
	
	
check_indirect
	****************************************************************
	** Routine qui va se charger de gerer les modes avec crochets **
	****************************************************************
	movem.l	d1-a6,-(sp)
	moveq	#0,d0
	moveq	#0,d7			; outer displacement
	clr.w	od
	
	move.l	a2,a6			; sauvegarde de la chaine initiale

	
	
	*--- on commence par copier la chaine en virant les crochets ---*
	
	
	lea	temp_ch,a1
.cont	move.b	(a2)+,d1
	beq.s	.exit_c
	cmp.b	#'[',d1
	beq.s	.cont			; on saute le carctere
	cmp.b	#']',d1
	beq.s	.cont			; idem
	cmp.b	#'L',d1			; teste pour savoir si on a un immediat			
	bne.s	.suiv
	cmp.b	#'.',-2(a2)
	beq.s	.suiv
	move.b	#'L',(a1)+
	move.l	(a2)+,(a1)+
	
	bra.s	.cont	
.suiv
	move.b	d1,(a1)+
	bra.s	.cont
.exit_c
	
	clr.b	(a1)
	*--- ici on a une chaine avec le crochet en moins ---*
	*--- maintenant, on va virer s'il y a le outer displacement ---*
	
	lea	temp_ch,a1
.cherche
	move.b	(a1)+,d1
	beq.s	.exit_d
	cmp.b	#'L',d1
	bne.s	.cherche
	cmp.b	#'.',-2(a1)		; a t on un .l
	beq.s	.cherche
	cmp.b	#'(',-2(a1)		; a t on une ( devant => ce n'est pas le bon 
	beq.s	.suiv1	
	cmp.b	#',',-2(a1)
	bne.s	.cherche
	move.l	(a1),d7			; dans d7, on a le deplacement
	cmp.w	#'.B',4(a1)
	beq	.erreur_adr
	cmp.w	#'.L',4(a1)
	beq.s	.degomme		; on va enlever ce nombre de la chaine
	cmp.w	#'.W',4(a1)
	beq.s	.word
	cmp.b	#')',4(a1)
	bne	.erreur_adr
.word	
	clr.w	d7
	tst.l	d7
	bne	.erreur_nb
	move.l	(a1),d7
	move.w	#1,od
	bra.s	.degomme1
.degomme
	move.w	#2,od
.degomme1
	move.w	#')'<<8,-2(a1)
	bra.s	.exit_d
	
	
.suiv1
	addq.l	#4,a1
	bra.s	.cherche
.exit_d
	
	lea	 temp_ch,a2
	
	move.l	d7,-(sp)
	
	bsr	etendu
	
	move.l	(sp)+,d7
	
	tst.w	d0
	bmi	.erreur
	
	
	
	move.w	mode_adr(a0),d2		; on va tester si on a un (d16,an)
	and.w	#%111000,d2
	cmp.w	#%101000,d2
	bne.s	.normal
	
	
	move.w	#%110,d2
	bfins	d2,mode_adr(a0){10:3}
	move.w	mode_adr+2(a0),mode_adr+4(a0)
	addq	#2,taille(a0)
	
	move.w	#%00000101100000,mode_adr+2(a0)
	
	
.normal
	
	
	
	*-- ici, on a donc le bon mode sans les crochets --*
	*-- 1. on va voir si on a un outer displacement  --*

	move.w	od,d1
	addq.w	#1,d1
	bfins	d1,mode_adr+2(a0){14:2}
	cmp.w	#0,od
	beq.s	.p_d
	cmp.w	#1,od
	bne.s	.lon
	lea	mode_adr(a0),a1
	add	taille(a0),a1
	move	d7,(a1)
	addq	#2,taille(a0)
	bra.s	.sz
.lon
	lea	mode_adr(a0),a1
	add	taille(a0),a1
	move.l	d7,(a1)
	addq	#4,taille(a0)
.sz
	
	*--- hop le od est ok -----*
.p_d
	
	
	
	
	*-- on va rechercher o— se trouve les crochets --*
	


	move.l	a6,a2
.no
	cmp.b	#']',(a2)+
	bne.s	.no
	cmp.b	#')',(a2)
	beq.s	.prein
	cmp.w	#',L',(a2)
	beq.s	.prein

	bset	#2,mode_adr+3(a0)
	move.l	#1<<9,long_adr(a0)
	bra.s	.x
.prein
	move.l	#1<<8,long_adr(a0)
	bclr	#2,mode_adr+3(a0)


	
	
	
	
	
.x
	
	
	
	
	
	
	
	movem.l	(sp)+,d1-a6
	moveq	#1,d0
	rts
	
	
	
.erreur
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
.erreur_adr
	DEBUG	<'erreur d adressage'>
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
.erreur_nb
	DEBUG	<'nb trop grand'>
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts

check_indirect_pc
	*************************************************************************
	** Routine qui va se charger de gerer les modes avec crochets et le pc **
	*************************************************************************
	movem.l	d1-a6,-(sp)
	moveq	#0,d0
	moveq	#0,d7			; outer displacement
	clr.w	od
	
	move.l	a2,a6			; sauvegarde de la chaine initiale
	
	
	*--- on commence par copier la chaine en virant les crochets ---*
	
	
	lea	temp_ch,a1
.cont	move.b	(a2)+,d1
	beq.s	.exit_c
	cmp.b	#'[',d1
	beq.s	.cont			; on saute le carctere
	cmp.b	#']',d1
	beq.s	.cont			; idem
	cmp.b	#'L',d1			; teste pour savoir si on a un immediat			
	bne.s	.suiv
	cmp.b	#'.',-2(a2)
	beq.s	.suiv
	move.b	#'L',(a1)+
	move.l	(a2)+,(a1)+
	
	bra.s	.cont	
.suiv
	move.b	d1,(a1)+
	bra.s	.cont
.exit_c
	
	clr.b	(a1)
	*--- ici on a une chaine avec le crochet en moins ---*
	*--- maintenant, on va virer s'il y a le outer displacement ---*
	
	lea	temp_ch,a1
.cherche
	move.b	(a1)+,d1
	beq.s	.exit_d
	cmp.b	#'L',d1
	bne.s	.cherche
	cmp.b	#'.',-2(a1)		; a t on un .l
	beq.s	.cherche
	cmp.b	#'(',-2(a1)		; a t on une ( devant => ce n'est pas le bon 
	beq.s	.suiv1	
	cmp.b	#',',-2(a1)
	bne.s	.cherche
	move.l	(a1),d7			; dans d7, on a le deplacement
	cmp.w	#'.B',4(a1)
	beq	.erreur_adr
	cmp.w	#'.L',4(a1)
	beq.s	.degomme		; on va enlever ce nombre de la chaine
	cmp.w	#'.W',4(a1)
	beq.s	.word
	cmp.b	#')',4(a1)
	bne	.erreur_adr
.word	
	clr.w	d7
	tst.l	d7
	bne	.erreur_nb
	move.l	(a1),d7
	move.w	#1,od
	bra.s	.degomme1
.degomme
	move.w	#2,od
.degomme1
	move.w	#')'<<8,-2(a1)
	bra.s	.exit_d
	
	
.suiv1
	addq.l	#4,a1
	bra.s	.cherche
.exit_d
	
	lea	 temp_ch,a2
	
	move.l	d7,-(sp)
	
	;DEBUG	'ici'
	
	bsr	etendu_pc
	move.l	(sp)+,d7
	
	tst.w	d0
	beq	.pas_pc
	bmi	.erreur
		
	move.w	mode_adr(a0),d2		; on va tester si on a un (d16,an)
	cmp.w	#%111010,d2
	bne.s	.normal
	
	
	move.w	#%111011,d2
	bfins	d2,mode_adr(a0){10:6}
	move.w	mode_adr+2(a0),mode_adr+4(a0)
	addq	#2,taille(a0)
	
	move.w	#%00000101100000,mode_adr+2(a0)
	
	
.normal
	
	
	
	*-- ici, on a donc le bon mode sans les crochets --*
	*-- 1. on va voir si on a un outer displacement  --*

	move.w	od,d1
	addq.w	#1,d1
	bfins	d1,mode_adr+2(a0){14:2}
	cmp.w	#0,od
	beq.s	.p_d
	cmp.w	#1,od
	bne.s	.lon
	lea	mode_adr(a0),a1
	add	taille(a0),a1
	move	d7,(a1)
	addq	#2,taille(a0)
	bra.s	.sz
.lon
	lea	mode_adr(a0),a1
	add	taille(a0),a1
	move.l	d7,(a1)
	addq	#4,taille(a0)
.sz
	
	*--- hop le od est ok -----*
.p_d
	
	;DEBUG	<'e'>
	
	
	
	*-- on va rechercher o— se trouve les crochets --*
	


	move.l	a6,a2
.no
	cmp.b	#']',(a2)+
	bne.s	.no
	cmp.b	#')',(a2)
	beq.s	.prein
	cmp.w	#',L',(a2)
	beq.s	.prein

	bset	#2,mode_adr+3(a0)
	move.l	#1<<19,long_adr(a0)	
	bra.s	.x
.prein
	move.l	#1<<18,long_adr(a0)	
	bclr	#2,mode_adr+3(a0)


	
	
	
	
	
.x
	
	
	
	
	
	
	
	movem.l	(sp)+,d1-a6
	moveq	#1,d0
	rts
.pas_pc
	movem.l	(sp)+,d1-a6
	moveq	#0,d0
	rts
	
	
	
.erreur
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
.erreur_adr
	DEBUG	<'erreur d adressage'>
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
.erreur_nb
	DEBUG	<'nb trop grand'>
	movem.l	(sp)+,d1-a6
	moveq	#-1,d0
	rts
	
	
etendu_pc
	*********************************************
	** Routine qui va travailler comme etendue **
	** mais avec le pc relatif                 **
	*********************************************

	movem.l	d1-a6,-(sp)


	move.l	a2,a6
	lea	temp_ch1,a1
.ch
	move.w	(a6),d0
	move.w	d0,d1
	lsr.l	#8,d1
	cmp.b	#'L',d1
	bne.s	.cont
	cmp.b	#'.',-1(a6)
	beq.s	.cont
	move.b	#'L',(a1)+
	addq.l	#1,a6
	move.l	(a6)+,(a1)+
	bra.s	.ch
.cont
	
	tst.b	d0
	beq.s	.exit
	cmp.w	#'PC',d0
	beq.s	.pc
	addq.l	#1,a6
	move.w	d0,(a1)
	add.l	#1,a1
	bra.s	.ch
	
	
	
.pc				; ici, on a le pc
	move.w	#'A0',(a1)+
	addq.l	#2,a6
.cop	move.b	(a6)+,(a1)+
	bne.s	.cop
			
	
	
	move.l	#temp_ch1,a2
	bsr	etendu
	movem.l	(sp)+,d1-a6
	rts

	
	


.exit
	moveq	#0,d0			; pas de pc
	movem.l	(sp)+,d1-a6

	rts


	
	
etendu
	******************************************
	** Routine qui va tester le mode etendu **
	******************************************


	moveq	#0,d5
	
	cmp.w	#'(L',(a2)			; teste du (xxx
	beq.s	.ok_nb
.pas_nb_word
	cmp.w	#'(A',(a2)			; pas de nombre au debut
	bne	.p_ici
	move.w	#-6,d7
	bset	#4,d5				; pas de deplacement
	moveq	#0,d3				; le base dep a zero
	bra	.k
.p_ici
	cmp.w	#'(D',(a2)			; pas de nombre au debut
	bne	.p_reste
	move.w	#-9,d7
	moveq	#0,d3
	bset	#7,d5				; le base dep a zero
	bset	#8,d5
	bra	.p_adr1
.ok_nb
	moveq	#0,d7
	cmp.w	#'.W',6(a2)
	bne.s	.norm
	moveq	#2,d7
.norm
	

	
	move.l	2(a2),d3			; le base dep dans d3
	
	cmp.w	#'.L',6(a2)
	beq	.long_adr

	
	cmp.w	#')'<<8,9(a2,d7)			; premier mode dans l'ordre
	beq.s	.pre
	
	cmp.w	#')'<<8,6(a2,d7)
	bne	.p_pre
.pre
	
	
	cmp.w	#'PC',7(a2,d7)
	beq	.p_reste
	
	cmp.w	#',A',6(a2,d7)
	bne	.erreur
	

	cmp.b	#'0',8(a2,d7)
	blt	.erreur
	cmp.b	#'7',8(a2,d7)
	bgt	.erreur
	
	
	move.l	2(a2),d6
	clr.w	d6
	tst.l	d6
	;bne	.pas_nb_word
	bne	.erreur_taille
	
	
	move.w	#4,taille(a0)
	
	tst.w	ADR_PC
	beq.s	.n_pc
	move.w	#%111010,d0			; regisre pour pc relatif
	move.l	#%1000000000000000,long_adr(a0)		; type adresse		bit 4 a un
	bra.s	.n_pc1
.n_pc
	move.l	#%100000,long_adr(a0)		; type adresse		bit 4 a un
	move.w	#%101000,d0			; regisre d'adresse
.n_pc1
	move.b	8(a2,d7),d1
	sub.b	#'0',d1
	or.b	d1,d0
	move.w	d0,mode_adr(a0)
	move.l	2(a2),d7
	move.w	d7,mode_adr+2(a0)		; stocker le deplacement
	
	bra	.exit
	
.long_adr
	cmp.w	#',A',8(a2)
	bne.s	.sortie_
	cmp.w	#')'<<8,11(a2)
	bne.s	.sortie_
	
	
	cmp.b	#'0',10(a2)
	blt	.erreur
	cmp.b	#'7',10(a2)
	bgt	.erreur	
	
	move.w	#8,taille(a0)
	
	tst.w	ADR_PC
	beq.s	.n_pc0
	move.w	#%111011,d0			; regisre pour pc relatif
	move.l	#%110000000000000000,long_adr(a0)		; type adresse		bit 4 a un
	bra.s	.n_pc01
.n_pc0
	move.l	#%11000000,long_adr(a0)		; type adresse		bit 4 a un
	move.w	#%110000,d0			; regisre d'adresse
.n_pc01
	move.b	10(a2),d1
	sub.b	#'0',d1
	or.b	d1,d0
	move.w	d0,mode_adr(a0)
	move.l	2(a2),d7
	move.l	d7,mode_adr+4(a0)		; stocker le deplacement
	move.w	#%0000000101110000,mode_adr+2(a0)
	
	
	
	
	bra	.exit
	
	
	
	
	
	
	
.sortie_
	
.p_pre
	

	
	cmp.w	#'.B',6(a2)			; teste de la taille en byte
	bne.s	.p_byte
	moveq	#2,d7
	move.l	2(a2),d6
	and.b	#$ff,d6
	tst.l	d6
	bne	.erreur_taille
.p_byte
	cmp.w	#'.W',6(a2)			; teste de la taille en word
	bne.s	.p_word
	move.l	2(a2),d6
	moveq	#2,d7
	clr.w	d6
	tst.l	d6
	bne	.erreur_taille
.p_word
	cmp.w	#'.L',6(a2)			; juste pour la correction du deplacement
	bne.s	.p_long
	moveq	#2,d7
.p_long
	
	cmp.b	#')',6(a2,d7)			; on a seulement un nombre
	bne.s	.p_ke_nb
	
	bset	#6,d5				; is=1 index suppress
	bset	#7,d5				; bd=1 base reg supprime
	addq.w	#2,taille(a0)
	
	
	bra	.p_byte1
	
	
.p_ke_nb
	
	
	cmp.w	#',A',6(a2,d7)			; cherche la ,A
	beq	.ya_adr
	
	cmp.w	#'PC',7(a2,d7)
	beq	.p_reste
	
	
	cmp.w	#',D',6(a2,d7)			; cherche le Dn autement
	bne	.erreur
	bset	#7,d5	
	subq.l	#3,d7			; base reg supprime
	bra.s	.p_adr1
.ya_adr



.k
	
	
	cmp.b	#',',9(a2,d7)
	bne	.erreur
.g1
	cmp.b	#'0',8(a2,d7)			; prend le num du A
	blt	.erreur
	cmp.b	#'7',8(a2,d7)
	bgt	.erreur
	
	
	clr.l	d6
	move.b	8(a2,d7),d6			; dans d6 le num du reg d'adr
	
	
	; on va commencer a remplir le regitres de destination
	
	
	
	cmp.b	#'A',10(a2,d7)
	bne.s	.p_adr1
	bset	#15,d5				; pour le an bit 15 a un
	bra.s	.ok_adr
.p_adr1
	cmp.b	#'D',10(a2,d7)			; teste de A ou D apres si non erreur
	beq	.ok_adr
	bclr	#15,d5				; pour le dn  bit 15 a 0
	bra	.erreur
.ok_adr
	
	cmp.b	#'0',11(a2,d7)			; prend le num du A ou D
	blt	.erreur
	cmp.b	#'7',11(a2,d7)
	bgt	.erreur
	
	clr.l	d4
	move.b	11(a2,d7),d4
	sub.b	#'0',d4
	

	lsl.l	#8,d4
	lsl.l	#7-3,d4
		
	or.w	d4,d5				; met le num du registre dans d5
	
	
	cmp.w	#'.W',12(a2,d7)	
	bne.s	.p_w
	bclr	#11,d5				: word  bit 11 a zero
	addq.l	#2,d7
	bra	.p_l
.p_w
	cmp.w	#'.L',12(a2,d7)	
	bne.s	.p_l
	bset	#11,d5				; long nit 11 a un
	addq.l	#2,d7
.p_l
	
	cmp.w	#')'<<8,12(a2,d7)		
	bne.s	.p_f				; pas d'extention  scale a 1 => bit a zero
	bclr	#10,d5				; et en word par defaut		
	bclr	#9,d5		
	bclr	#11,d5

	bra.s	.ok_ext
.p_f



	
	cmp.b	#'*',12(a2,d7)			; pas de facteur d'echelle
	bne.s	.ok_ext
	
	cmp.b	#')',14(a2,d7)
	bne	.erreur_scale
		
	cmp.w	#'*1',12(a2,d7)
	bne.s	.p_m_1
	bclr	#10,d5				; scale a un => bit a zero
	bclr	#9,d5
	addq.l	#2,d7
	bra.s	.ok_ext
.p_m_1
	cmp.w	#'*2',12(a2,d7)
	bne.s	.p_m_2
	bclr	#10,d5				; scale a 2 
	bset	#9,d5
	addq.l	#2,d7
	bra.s	.ok_ext
.p_m_2
	cmp.w	#'*4',12(a2,d7)
	bne.s	.p_m_4
	bset	#10,d5				; scale a 4
	bclr	#9,d5
	addq.l	#2,d7
	bra.s	.ok_ext
.p_m_4
	cmp.w	#'*8',12(a2,d7)
	bne.s	.p_m_8
	bset	#10,d5				; scale a 4
	bset	#9,d5
	addq.l	#2,d7
	bra.s	.ok_ext
.p_m_8
	
	bra	.erreur_scale				; rien de bon derriere
.ok_ext
	
	cmp.b	#')',12(a2,d7)
	bne	.erreur
	
	
	
	
	; dans d5 tout est ok    pour le byte
	; dans d6 on le num du an
	; dans d3 le base deplacment
	
	
	
	
	move.w	#4,taille(a0)			; c'est du byte
	
	btst	#4,d5
	bne.s	.suiva_w
	
	;move.w	#4,taille(a0)			; c'est du byte
	
	move.w	d5,mode_adr+2(a0)
	move.l	d3,d4
	and.b	#$00,d4
	tst.l	d4
	bne.s	.p_byte1
	tst.b	d3
	beq.s	.zero
	move.b	d3,mode_adr+3(a0)
	bra.s	.suiva_b
.zero						; deplacement nul
	bset	#4,d5
	or.w	d5,mode_adr+2(a0)
	bra.s	.suiva_b


.p_byte1	
	move.l	d3,d4				; c'est du word
	clr.w	d4
	tst.l	d4
	bne.s	.p_word1
	addq.w	#2,taille(a0)
	move.w	d3,mode_adr+4(a0)
	bset	#5,d5				; bd= word
	
	
	bra.s	.suiva_w
.p_word1
	addq.w	#4,taille(a0)			; c'est du long
	move.l	d3,mode_adr+4(a0)
	bset	#5,d5				; bd= long
	bset	#4,d5				; bd= long
.suiva_w
	bset	#8,d5				; mode etendu dans d5
	


	move.w	d5,mode_adr+2(a0)

	
.suiva_b
	
	
	tst.w	ADR_PC
	beq.s	.n_pc2
	move.w	#%111011,d0
	move.l	#%11000000000000000,long_adr(a0)		; deux types possibles
	bra.s	.n_pc3
.n_pc2
	move.w	#%110000,d0			; regisre d'adresse
	move.l	#%11000000,long_adr(a0)		; deux types possibles
	or.b	d6,d0
.n_pc3
	
	move.w	d0,mode_adr(a0)
	
	
	bra.s	.exit
.p_reste

	moveq	#0,d0
	rts


.exit
	moveq	#1,d0
	rts

.erreur
	moveq	#-1,d0
	rts
	
	
	
	
.erreur_paranthese
	DEBUG	'parantheses_fausses'
	moveq	#-1,d0
	rts
		

.erreur_taille
	DEBUG	'erreur_taille'
	moveq	#-1,d0
	rts

.erreur_scale
	DEBUG	'erreur_echelle'
	moveq	#-1,d0
	rts
		


	
	
	
teste_paranthese
	*****************************************************
	** Sous routine de get_adressing_mode              **
	** cette routine va permettre de verifer           **
	** que les parantheses et crochets sont bien place **
	*****************************************************



	movem.l	d1-a6,-(sp)
	
	moveq	#0,d0
	moveq	#0,d2			; nb paranthese
	moveq	#0,d3			; nb crochet
	moveq	#1,d4			; une donnee
	
.cherche
	move.b	(a2)+,d1
	beq	.quitte
	cmp.b	#'L',d1
	bne.s	.p_chif			; pas_chiffre
	cmp.b	#'.',-2(a2)
	beq.s	.p_chif		; on un .L
	addq.l	#4,a2
	bra.s	.cherche
.p_chif
	
	
	cmp.b	#',',d1
	bne.s	.p_vir			;  c'est le premier opcode, si le paranthese =0 et que l'on a une virgule 
	tst.b	d2
	beq.s	.premier_mode
	
	
.p_vir
	cmp.b	#'(',d1
	bne.s	.p_par_o
	addq.l	#1,d2
.p_par_o
	cmp.b	#'[',d1
	bne.s	.p_cro_o
	tst.b	d2			; y a til une paranthese avant ?
	beq	.erreur
	addq.l	#1,d3
.p_cro_o
	cmp.b	#']',d1
	bne.s	.p_cro_f
	tst.b	d2			; est t on dans une paranthese
	beq	.erreur
	tst.b	d3
	beq	.erreur			; y a t il un crochet avant
	subq.l	#1,d3
.p_cro_f	
	
	cmp.b	#')',d1
	bne.s	.p_par_f
	tst.b	d3			; plus de crochet ?
	bne	.erreur
	tst.b	d2
	beq	.erreur			; y a t il une paranthese
	subq.l	#1,d2
.p_par_f	
	bra.s	.cherche
	
.premier_mode
	tst.b	d2
	bne	.erreur
	tst.b	d3
	bne	.erreur
	
; on commence le second opcode

	addq.l	#1,d4			; 2 donnees

	moveq	#0,d0
	moveq	#0,d2			; nb paranthese
	moveq	#0,d3			; nb crochet
	
	clr.b	-1(a2)
	
.cherche1
	move.b	(a2)+,d1
	beq	.quitte
	
	
	cmp.b	#'L',d1
	bne.s	.p_chif1		; pas_chiffre
	cmp.b	#'.',-2(a2)
	beq.s	.p_chif1		; on un .L
	addq.l	#4,a2
	bra.s	.cherche1
.p_chif1
	
	
	cmp.b	#',',d1
	bne.s	.p_vir1			;  c'est le premier opcode, si le paranthese =0 et que l'on a une virgule 
	tst.b	d2
	;beq.s	.erreur_t_op
	beq.s	.troisieme_op
	
.p_vir1
	
	
	cmp.b	#'(',d1
	bne.s	.p_par_o1
	addq.l	#1,d2
.p_par_o1
	cmp.b	#'[',d1
	bne.s	.p_cro_o1
	tst.b	d2			; y a til une paranthese avant ?
	beq	.erreur
	addq.l	#1,d3
.p_cro_o1
	cmp.b	#']',d1
	bne.s	.p_cro_f1
	tst.b	d2			; est t on dans une paranthese
	beq	.erreur
	tst.b	d3
	beq	.erreur			; y a t il un crochet avant
	subq.l	#1,d3
.p_cro_f1
	
	cmp.b	#')',d1
	bne.s	.p_par_f1
	tst.b	d3			; plus de crochet ?
	bne.s	.erreur
	tst.b	d2
	beq.s	.erreur			; y a t il une paranthese
	subq.l	#1,d2
.p_par_f1
	bra.s	.cherche1
	
	tst.b	d2
	bne.s	.erreur
	tst.b	d3
	bne.s	.erreur
	
	
	
.troisieme_op
	
	lea	mode_supplementaire,a0
	bsr	cal_mode_adr
	tst.l	d0
	bmi	.erreur_adr
	
	
	clr.b	-1(a2)			; on met un zero par la sepration des chaines
	
	
.quitte
	tst.b	d2
	bne.s	.erreur
	tst.b	d3
	bne.s	.erreur
	move	d4,d0
	movem.l	(sp)+,d1-a6
	rts
	
.erreur
	DEBUG	'parantheses_fausses'
	moveq	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
	
.erreur_t_op
	DEBUG	'trop_operateurs'
	moveq	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
.erreur_adr
	DEBUG	<'Mauvais mode d adressage'>
	moveq	#-1,d0
	movem.l	(sp)+,d1-a6
	rts

	
	
	
direct
	*************************************************************
	** routine qui va secharger d'assembler les opcodes direct **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
         
        
        movem.l	d1-a6,-(sp)
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d1
        add.w	d1,bin_l_op(a2)
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts

exg
	*************************************************************
	** routine qui va secharger d'assembler les opcodes exg    **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
         
        
        movem.l	d1-a6,-(sp)
        
        cmp.w	#0,taille_work			; si pas de taille, on a un long
	bne	.p_correc
	move.w	#3,taille_work
.p_correc

        
        clr.l	d1
	move.w	taille_work,d1
	
        move.l	s_binary,a2
       
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d1
        add.w	d1,bin_l_op(a2)
       
       
       	lea	mode_source,a1
       	lea	mode_destination,a3
      	cmp.l	#2,long_adr(a1)			; an en source
       	bne.s	.p_a_s
       	cmp.l	#2,long_adr(a3)			; dn en destination
       	beq.s	.a_d 	
	
	move.w	mode_adr(a1),d1			; on a dn,an
	and.w	#7,d1		
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a3),d1
	and.w	#7,d1		
	bfins	d1,bin_code(a2){4:3}

	move.w	#%10001,d1
	bfins	d1,bin_code(a2){8:5}
	bra	.exit
	
.a_d

	move.w	mode_adr(a3),d1			; on a dn,dn
	and.w	#7,d1		
	bfins	d1,bin_code(a2){4:3}
	move.w	mode_adr(a1),d1		
	and.w	#7,d1		
	bfins	d1,bin_code(a2){13:3}
	move.w	#%1001,d1
	bfins	d1,bin_code(a2){8:5}
	bra.s	.exit
	
.p_a_s	
	cmp.l	#2,long_adr(a3)
	beq.S	.p_a_d

	move.w	mode_adr(a3),d1			; on a dn,dn
	and.w	#7,d1		
	bfins	d1,bin_code(a2){4:3}
	move.w	mode_adr(a1),d1		
	and.w	#7,d1		
	bfins	d1,bin_code(a2){13:3}
	move.w	#%1000,d1
	bfins	d1,bin_code(a2){8:5}
	bra.s	.exit
.p_a_d
	move.w	mode_adr(a1),d1			; on a dn,an
	and.w	#7,d1		
	bfins	d1,bin_code(a2){4:3}
	move.w	mode_adr(a3),d1
	and.w	#7,d1		
	bfins	d1,bin_code(a2){13:3}

	move.w	#%10001,d1
	bfins	d1,bin_code(a2){8:5}
	
	

.exit
	moveq	#0,d0
	movem.l	(sp)+,d1-a6
	rts
	


negx
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "negx" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
        
        movem.l	d1-a6,-(sp)
        
        cmp.w	#0,taille_work			; si pas de taille, on a un word
	bne	.p_correc
	move.w	#2,taille_work
.p_correc

        
        clr.l	d1
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        
        tst.l	d1
        beq.s	.erreur
        subq.l	#1,d1
        
        
        
        
        
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
        
        
        lea	mode_source,a1
	bsr	insere_adr
        
        bfins	d1,bin_code(a2){8:2}
        
        ;cmp.w	#2,taille(a1)
        ;beq.s	.exit

	;DEBUG	<'Extended opcode'>
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
	
.erreur
	bra	erreur_taille
	
mvsr
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "mvsr" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
        movem.l	d1-a6,-(sp)
        clr.l	d1
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
        
        
        lea	mode_source,a1
	bsr	insere_adr
        
        ;cmp.w	#2,taille(a1)
        ;beq.s	.exit
	;DEBUG	<'Extended opcode'>


.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
	
.erreur
	bra	erreur_taille
	
	
	
add
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "add"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
        
        movem.l	d1-a6,-(sp)
        
        cmp.w	#0,taille_work			; si pas de taille, on a un word
	bne	.p_correc
	move.w	#2,taille_work
.p_correc

        
        clr.l	d1
	move.w	taille_work,d1

   
   
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

        lea	mode_source,a1
        cmp.l	#1,long_adr(a1)			; pas de dn en source
        bne.s	.p_d_s
        lea	mode_destination,a1		; a t on dn en destination
	cmp.l	#1,long_adr(a1)
	beq.s	.p_d_s
	cmp.l	#2,long_adr(a1)
	beq.s	.p_d_s				; a t on an en destination
	
	subq.w	#1,d1				; dn en source
	bset	#2,d1
	
        lea	mode_source,a1
	bfins	d1,bin_code(a2){7:3}
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}
	
        lea	mode_destination,a1
	bsr	insere_adr
	bra	.exit
.p_d_s
	lea	mode_destination,a1
        cmp.l	#2,long_adr(a1)			; pas de an en destination ?
       	bne.s	.p_a_d
	
	and.w	#1,d1
	lsl.l	#2,d1
	or.w	#%11,d1				; on a soit 111 dans d3 ou 011 dans d3
	
	
	bfins	d1,bin_code(a2){7:3}
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}
	
        lea	mode_source,a1

	

	bsr	insere_adr
	
	
	
	bra.s	.exit
.p_a_d
	
	
	lea	mode_destination,a1
	subq.w	#1,d1				; dn en destination
	bclr	#2,d1
	
	bfins	d1,bin_code(a2){7:3}
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}
	
        lea	mode_source,a1
	bsr	insere_adr

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        
        
        rts
	
	
	
	
.erreur
	bra	erreur_taille
	
	
	
insere_adr
	***************************************************
	** Routine qui va inserer le mode d'adressage    ** 
	**                                               **
	** Entree:                                       **
	** -------                                       **
	**         - a1 pointe sur source ou destination **
	**         - a2 pointe sur la structure          ** 
	**                                               **
	** Sortie:                                       **
	** -------                                       **
        **         - rien                                **
        **                                               **
        ***************************************************
        
       	movem.l	d0-a6,-(sp) 
       
       
       	move.w	bin_code(a2),d1
       	and.b	#%11000000,d1
        or.w	mode_adr(a1),d1
	;or.w	bin_code(a2),d1
	move.w	d1,bin_code(a2)
	
	lea	bin_code(a2),a5
	add.w	bin_l_op(a2),a5				; on se place juste apres l'opcode
	

	clr.l	d1
	move.w	taille_work,d1


        cmp.w	#2,taille(a1)				; a t on un mode etendu?
        beq	.exit

	
	
	cmp.l	#%1000000000000,long_adr(a1)		; a t on de l immediat
	bne.s	.p_imm
	
	
	cmp.w	#1,d1
	bne.s	.p_byte					; taille en .b
	move.l	mode_adr+2(a1),d2
	and.b	#0,d2
	tst.l	d2
	bne	.erreur_taille
	move.l	mode_adr+2(a1),d2
	move.w	d2,(a5)
	sub	#2,taille(a1)
	bra	.exit
.p_byte
	cmp.w	#2,d1
	bne.s	.p_word					; taille en .w
	move.l	mode_adr+2(a1),d2
	and.w	#0,d2
	tst.l	d2
	bne.s	.erreur_taille
	move.l	mode_adr+2(a1),d2
	move.w	d2,(a5)
	sub	#2,taille(a1)
	bra	.exit
.p_word
	cmp.w	#3,d1
	bne.s	.p_long					; taille en .l

	move.l	mode_adr+2(a1),d2
	move.l	d2,(a5)
	bra	.exit
.p_long
	bra	.exit
	
	; ici on a pas un immediat
.p_imm



	clr.l	d3
	move.w	taille(a1),d3
	beq.s	.exit
	
	
	
	subq.w	#1,d3
	move.l	a5,a4
	lea	mode_adr+2(a1),a3
.cop	move.b	(a3)+,(a4)+
	dbra	d3,.cop
	
	
	
	



.exit

        clr.l	d3
	move.w	taille(a1),d3
	add	d3,bin_l_op(a2)			; on ajoute a la longueur de l'opcode
	subq	#2,bin_l_op(a2)
	
	
	
        
        
       	movem.l	(sp)+,d0-a6 
        rts	
        
.erreur_taille
        
        DEBUG	<'erreur taille'>
        movem.l	(sp)+,d0-a6 
        rts	
        	
insere_adr_move_dest
	***************************************************
	** Routine qui va inserer le mode d'adressage    ** 
	**                                               **
	** Entree:                                       **
	** -------                                       **
	**         - a1 pointe sur source ou destination **
	**         - a2 pointe sur la structure          ** 
	**                                               **
	** Sortie:                                       **
	** -------                                       **
        **         - rien                                **
        **                                               **
        ***************************************************
        
       	movem.l	d0-a6,-(sp) 
       
       
       	move.w	bin_code(a2),d1
       	
       	and.w	#%1111000000111111,d1
        
        move.w	mode_adr(a1),d3
        
        move.w	d3,d2
        lsr.w	#3,d2
        and.w	#%111,d2
        
        and.w	#%111,d3
        lsl.w	#3,d3
        or.w	d3,d2
        move.w	d2,d3
        
        lsl.w	#6,d3
        or.w	d3,d1
        
        
	;or.w	bin_code(a2),d1
	move.w	d1,bin_code(a2)
	
	lea	bin_code(a2),a5
	add.w	bin_l_op(a2),a5				; on se place juste apres l'opcode
	

	clr.l	d1
	move.w	taille_work,d1

        cmp.w	#2,taille(a1)				; a t on un mode etendu?
        beq	.exit

	
	
	cmp.l	#%1000000000000,long_adr(a1)		; a t on de l immediat
	bne.s	.p_imm
	
	
	cmp.w	#1,d1
	bne.s	.p_byte					; taille en .b
	move.l	mode_adr+2(a1),d2
	and.b	#0,d2
	tst.l	d2
	bne	.erreur_taille
	move.l	mode_adr+2(a1),d2
	move.w	d2,(a5)
	sub	#2,taille(a1)
	bra	.exit
.p_byte
	cmp.w	#2,d1
	bne.s	.p_word					; taille en .w
	move.l	mode_adr+2(a1),d2
	and.w	#0,d2
	tst.l	d2
	bne.s	.erreur_taille
	move.l	mode_adr+2(a1),d2
	move.w	d2,(a5)
	sub	#2,taille(a1)
	bra	.exit
.p_word
	cmp.w	#3,d1
	bne.s	.p_long					; taille en .l

	move.l	mode_adr+2(a1),d2
	move.l	d2,(a5)
	bra	.exit
.p_long
	bra	.exit
	
	; ici on a pas un immediat
.p_imm



	clr.l	d3
	move.w	taille(a1),d3
	subq.w	#1,d3
	move.l	a5,a4
	lea	mode_adr+2(a1),a3
.cop	move.b	(a3)+,(a4)+
	dbra	d3,.cop
	
	
	
	



.exit

        clr.l	d3
	move.w	taille(a1),d3
	add	d3,bin_l_op(a2)			; on ajoute a la longueur de l'opcode
	subq	#2,bin_l_op(a2)
	
        
        
       	movem.l	(sp)+,d0-a6 
        rts	
        
.erreur_taille
        
        DEBUG	<'erreur taille'>
        movem.l	(sp)+,d0-a6 
        rts	


	
bcc
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bcc"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'BCC'>


	cmp.w	#0,taille_work
	bne.s	.pa
	move.w	#2,taille_work
.pa

        
        movem.l	d1-a6,-(sp)
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	;DEBUG	<'test'>
	
	cmp.w	#1,taille_work
	bne.s	.p_byte
	
	*-- ici d‚placment en byte --*	
	
	lea	mode_source,a0
	move.l	mode_adr+2(a0),d2
	move.l	d2,d3
	move.l	pc_t,d4
	
	
	sub.l	d4,d3
	subq.l	#2,d3
	move.l 	d3,d4
	move.l	d4,d3


	
	
	tst.b	d3				; le deplacement ne peut pas valoir zero en byte
	beq	.erreur_disp_n
	clr.b	d3
	cmp.l	#$ffffff00,d3
	beq.s	.ok
	tst.l	d3
	bne	.erreur_disp
.ok
	move.b	d4,bin_code+1(a2)
	
	
	bra.s	.exit
	
.p_byte
	cmp.w	#2,taille_work
	bne.s	.p_word
	
	*-- ici d‚placment en word --*	
	
	
	
	add	#2,bin_l_op(a2)			; on ajoute 2 a la longueur pour le deplacement
	lea	mode_source,a0
	move.l	mode_adr+2(a0),d2
	move.l	d2,d3
	move.l	pc_t,d4
	
	sub.l	d4,d3
	
	subq.l	#2,d3
	
	
	move.l 	d3,d4
	move.l	d4,d3


	clr.w	d3
	cmp.l	#$ffff0000,d3
	beq.s	.ok1
	tst.l	d3
	bne.s	.erreur_disp
.ok1
	move.w	d4,bin_code+2(a2)
	bra.s	.exit
	
.p_word
	*-- ici d‚placment en long --*	
	add	#4,bin_l_op(a2)			; on ajoute 2 a la longueur pour le deplacement
	lea	mode_source,a0
	move.l	mode_adr+2(a0),d2
	move.l	pc_t,d4
	
	
	sub.l	d4,d2
	
	addq.l	#6,d2
	
	
	move.l	d2,bin_code+2(a2)
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
	
.erreur_disp
	DEBUG	<'d‚placement trop grand'>
	movem.l	(sp)+,d1-a6
        rts
	
	
.erreur_disp_n
	DEBUG	<'d‚placement nul impossible en byte'>
	movem.l	(sp)+,d1-a6
        rts
	
scc
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bcc"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'SCC'>

        movem.l	d1-a6,-(sp)
        
        cmp.w	#2,taille_work
        beq.s	.erreur
        cmp.w	#3,taille_work
        beq.s	.erreur
        
        
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	
	
	
	
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_disp
	DEBUG	<'d‚placement trop grand'>
	movem.l	(sp)+,d1-a6
        rts
	

dbcc
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "dbcc"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'DBCC'>

   
        movem.l	d1-a6,-(sp)
   	cmp.w	#1,taille_work			; pas de byte
   	beq	.erreur
   	cmp.w	#3,taille_work			; pas de long
   	beq.s	.erreur
   
        
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	lea	mode_source,a0
	move.w	mode_adr(a0),d2
	and.w	#%111,d2
	or.w	#%11001000,d2			: pour completer l'instruction
	
	or	d2,bin_code(a2)
	
	add	#2,bin_l_op(a2)			; on ajoute 2 a la longueur pour le deplacement
	
	lea	mode_destination,a0
	move.l	mode_adr+2(a0),d2
	move.l	d2,d3
	
	;DEBUG	<'test'>
	
	
	move.l	pc_t,d4
	sub.l	d4,d3

	subq.l	#2,d3
	
	move.l 	d3,d4
	move.l	d4,d3
	clr.w	d3
	cmp.l	#$ffff0000,d3
	beq.s	.ok
	tst.l	d3
	bne.s	.erreur_disp
	
.ok
	
	
	
	
	move.w	d4,bin_code+2(a2)
	
	
	*--- ici, j'ai le deplacement ---*
	
	
	
	
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_disp
	DEBUG	<'d‚placement trop grand'>
	movem.l	(sp)+,d1-a6
        rts

ori
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "ori"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'ORI type'>
        movem.l	d1-a6,-(sp)


	cmp.w	#0,taille_work			; si pas de taille, on a un word
	bne	.p_correc
	move.w	#2,taille_work
.p_correc

        
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	
	lea	mode_destination,a3
	cmp.l	#%10000000000000,long_adr(a3)		; a t on un ccr en destination ?
	bne.s	.p_ccr
	cmp.w	#2,taille_work
	bne	.erreur
	lea	mode_source,a3
	move.l	mode_adr+2(a3),d3
	clr.w	d3
	tst.l	d3
	bne	.erreur
	move.l	mode_adr+2(a3),d3
	move.w	d3,bin_code+2(a2)
	clr.b	bin_code+2(a2)
	move.w	#%111100,d0
	bfins	d0,bin_code(a2){10:6}
	

	bra	.exit
.p_ccr
	lea	mode_destination,a3
	cmp.l	#%100000000000000,long_adr(a3)		; a t on un sr en destination ?
	bne.s	.p_sr
	bset	#6,bin_code+1(a2)
	cmp.w	#2,taille_work
	bne	.erreur
	lea	mode_source,a3
	move.l	mode_adr+2(a3),d3
	clr.w	d3
	tst.l	d3
	bne	.erreur
	move.l	mode_adr+2(a3),d3
	move.w	d3,bin_code+2(a2)
	

	move.w	#%111100,d0
	
	bfins	d0,bin_code(a2){10:6}

	bra	.exit

.p_sr
	
	
	
	
	
	lea	mode_source,a0
	move.l	mode_adr+2(a0),d0
	move.l	d0,d1
	

	cmp.w	#1,taille_work
	bne.s	.p_byte


	clr.b	d1
	tst.l	d1
	bne.s	.erreur
	move.w	d0,bin_code+2(a0)
	addq.w	#2,bin_l_op(a2)			; ajout de 2 a la longueur
	bra.s	.x
.p_byte
	cmp.w	#2,taille_work
	bne.s	.p_word
	move.l	d0,d1
	clr.w	d1
	tst.l	d1
	bne.s	.erreur
	move.w	d0,bin_code+2(a2)
	addq.w	#2,bin_l_op(a2)			; ajout de 2 a la longueur
	bra.s	.x
.p_word
	
	cmp.w	#3,taille_work
	bne.s	.erreur
	move.l	d0,bin_code+2(a2)
	addq.w	#4,bin_l_op(a2)			; ajout de 4 a la longueur
	
	
	
	
	
	
.x
	
	
	move.w	taille_work,d1
	subq	#1,d1
	bfins	d1,bin_code(a2){8:2}
	
	lea	mode_destination,a1
	bsr	insere_adr

	
	
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
        moveq	#-1,d0
	bsr	erreur_taille
	
	

cmp2
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "cmp2" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'CMP2'>
        movem.l	d1-a6,-(sp)

   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        
	move.w	taille_work,d1
        move.l	s_binary,a2
        
        
       	move.w	i_op(a1),bin_code(a2)
       
       	move.w	taille_work,d3
       	subq	#1,d3
       	bfins	d3,bin_code(a2){5:2}
       
       	move.w	i_op+2(a1),bin_code+2(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	bsr	insere_adr

	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donne
	bset	#7,bin_code+2(a2)
.donne
	move.w	mode_adr(a1),d3
	and.w	#%111,d3
	bfins	d3,bin_code+2(a2){1:3}

	
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille


movep
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "movep"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'movep'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        
	
	cmp.w	#1,taille_work
	beq	.erreur
	
	move.w	taille_work,d1
        move.l	s_binary,a2
        
        
       	move.w	i_op(a1),bin_code(a2)
       	move.w	i_lenght(a1),d2
       	add	d2,bin_l_op(a2)
       
       
	lea	mode_source,a1
	cmp.l	#%1,long_adr(a1)
	beq.s	.donne				; on a une adresse en source

	move.w	mode_adr+2(a1),d6		; le deplacement
	move.w	d6,bin_code+2(a2)
	
	move.w	mode_adr(a1),d5
	and.w	#%111,d5


	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)			; si on a pas une donne est destination => erreur
	bne	.erreur_adr
	
	
	; ici on regarde en source
	
	
	move.w	mode_adr(a1),d4
	and.w	#%111,d4
	
	
	move.w	d6,bin_code+2(a2)
	bfins	d4,bin_code(a2){4:3}
	bfins	d5,bin_code(a2){13:3}
	move.w	taille_work,d1
	subq	#2,d1
	move.w	#%100,d2
	add	d1,d2
	bfins	d2,bin_code(a2){7:3}
	
	
	
	
	bra.s	.exit
	
	
	
.donne
	move.w	mode_adr,d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){4:3}
	
	lea	mode_destination,a1
	move.l	long_adr(a1),d1
	and.l	#%100100,d1
	tst.l	d1
	beq.s	.erreur_adr
	
	move.w	mode_adr+2(a1),d6		; le deplacement
	move.w	d6,bin_code+2(a2)
	
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	
	move.w	taille_work,d1
	subq	#2,d1
	move.w	#%110,d2
	add	d1,d2
	bfins	d2,bin_code(a2){7:3}
	
	
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille

.erreur_adr
	DEBUG	<'erreur adressing mode'>
	movem.l	(sp)+,d1-a6
        rts

moves
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "moves"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'MOVES'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        
        move.l	s_binary,a2
        
        
       	move.w	i_op(a1),bin_code(a2)
       	move.w	taille_work,d3
       	subq	#1,d3
       	bfins	d3,bin_code(a2){8:2}
       	move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	moveq	#0,d7
	
	lea	mode_source,a1
	move.l	long_adr(a1),d1
	and.l	#%11,d1
	tst.l	d1
	beq.s	.rn_dest
	
	bset	#11,d7
	lea	mode_destination,a3
	move.l	long_adr(a3),d3
	and.l	#%11,d3
	tst.l	d3
	bne.s	.erreur
	
	move.l	long_adr(a1),d1
	cmp.l	#1,d1
	beq.s	.dn_scr
	bset	#15,d7			; registre an  => bit a un
.dn_scr
	move.w	d7,bin_code+2(a2)
	move.w	mode_adr(a1),d7
	bfins	d7,bin_code+2(a2){1:3}
	lea	mode_destination,a1
	bsr	insere_adr
	bra.s	.exit
	
	
	
	
	
.rn_dest				; registe rn en destination
	
	moveq	#0,d7
	
	lea	mode_destination,a1
       	bclr	#11,d7			; ea => dn
	lea	mode_source,a3
	move.l	long_adr(a3),d3
	and.l	#%11,d3
	tst.l	d3
	bne.s	.erreur
	
	move.l	long_adr(a1),d1
	cmp.l	#1,d1
	beq.s	.dn_scr1
	bset	#15,d7			; registre an  => bit a un
.dn_scr1
	move.w	d7,bin_code+2(a2)
	move.w	mode_adr(a1),d7
	bfins	d7,bin_code+2(a2){1:3}
	lea	mode_source,a1
	bsr	insere_adr
	
	
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille

bchg
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bchg" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'BCHG'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#1,taille_work			
.pas_z
        cmp.w	#2,taille_work
       	beq	.erreur
        
        
        
	move.w	taille_work,d1
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee
	
	cmp.w	#3,taille			; si long avec donne => erreur
	beq.s	.erreur
	
	lea	mode_source,a1
	cmp.l	#%1000000000000,long_adr(a1)		; immediat >7  avec donne => erreur
	bne.s	.donnee
		
	cmp.l	#8,mode_adr+2(a1)
	bge	.erreur_nb_byte	
.donnee
	
	
	lea	mode_source,a1
	cmp.l	#%1000000000000,long_adr(a1)
	bne.s	.p_donn
	
	move.w	#%10000,d3
	bfins	d3,bin_code(a2){4:5}
	
	move.l	mode_adr+2(a1),d2
	cmp.l	#256,d2
	bge	.erreur_nb_byte_255
	
	move.w	d2,bin_code+2(a2)
	add.w	#2,bin_l_op(a2)
	bra.s	.suite
	
.p_donn
	move.w	mode_adr(a1),d2
	and.w	#%111,d2
	bfins	d2,bin_code(a2){4:3}
	move.w	#%1,d3
	bfins	d3,bin_code(a2){7:1}
	
	
	
	
.suite
	lea	mode_destination,a1
	bsr	insere_adr
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille

.erreur_nb_byte
	DEBUG	<'erreur byte ente 0 et 7'>
	movem.l	(sp)+,d1-a6
        rts

.erreur_nb_byte_255
	DEBUG	<'erreur byte ente 0 et 255'>
	movem.l	(sp)+,d1-a6
        rts



ext
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "ext " **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'EXT'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        cmp.w	#1,taille_work			; pas de byte
       	beq	.erreur
        
        
        
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	move.w	taille_work,d1
	bfins	d1,bin_code(a2){7:3}
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	or.w	d1,bin_code(a2)
	
.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille


extb
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "extb" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'EXTb'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#3,taille_work			
.pas_z
        cmp.w	#3,taille_work			; pas de byte
       	beq	.ok
       	bra.s	.erreur
.ok
        
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	move.w	taille_work,d1
	bset	#2,d1
	bfins	d1,bin_code(a2){7:3}
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	or.w	d1,bin_code(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille


link
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "link" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'link'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        cmp.w	#1,taille_work			; pas de byte
       	beq.s	.erreur
        
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	move.w	taille_work,d1
	cmp.w	#2,taille_work
	beq.s	.word
	move.w	#%00000001,d1			; pour le long
	addq	#2,bin_l_op(a2)			; +2 a la longueur de l'operateur
	lea	mode_destination,a3
	move.l	mode_adr+2(a3),d2
	bra.s	.long
.word
	move.w	#%11001010,d1			; pour le word
	lea	mode_destination,a3
	move.l	mode_adr+2(a3),d2
	clr.w	d2
	tst.l	d2
	bne.s	.erreur
	move.l	mode_adr+2(a3),d2
	swap	d2				; rearrange d2
.long
	
	bfins	d1,bin_code(a2){5:8}
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	or.w	d1,bin_code(a2)
	move.l	d2,bin_code+2(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille


swap
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "swap" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'swap'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.pas_z
   	move.w	#2,taille_work			
.pas_z
        cmp.w	#2,taille_work			; pas de byte
       	beq.s	.ok
       	bra.s	.erreur
.ok
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	lea	mode_destination,a3
	move.w	mode_adr(a3),d1
	or.w	d1,bin_code(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille

bkpt
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bkpt" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'bkpt'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	beq.s	.ok
       	bra.s	.erreur
.ok
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	lea	mode_source,a3
	move.l	mode_adr+2(a3),d1
	
	cmp.l	#$7,d1
	bgt	.erreur_nb
	
	
	or.w	d1,bin_code(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille

.erreur_nb
	DEBUG	<'erreur nb plu grand que 7'>
	movem.l	(sp)+,d1-a6
        rts

trap
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "trap" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'trap'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	beq.s	.ok
       	bra.s	.erreur
.ok
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	lea	mode_source,a3
	move.l	mode_adr+2(a3),d1
	
	cmp.l	#15,d1
	bgt	.erreur_nb
	
	
	or.w	d1,bin_code(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_nb
	DEBUG	<'erreur nb plu grand que 15'>
	movem.l	(sp)+,d1-a6
        rts


rtd
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "rtd"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'rtd'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	beq.s	.ok
       	bra.s	.erreur
.ok
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	lea	mode_source,a3
	move.l	mode_adr+2(a3),d1
	
	clr.w	d1
	tst.l	d1
	bne.s	.erreur_nb
	
	move.l	mode_adr+2(a3),d1
	
	move.w	d1,bin_code+2(a2)
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_nb
	DEBUG	<'erreur nb plu grand que 15'>
	movem.l	(sp)+,d1-a6
        rts

lea
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "lea"  **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'lea'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : long
   	bne.s	.suiv
   	move.w	#3,taille_work
   	
.suiv
	cmp.w	#3,taille_work			; on doit travailler en long
	beq.s	.ok
       	bra.s	.erreur
.ok
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

	lea	mode_source,a1
	bsr	insere_adr
	

	lea	mode_destination,a3
	move.w	mode_adr(a3),d1
	
	bfins	d1,bin_code(a2){4:3}
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_nb
	DEBUG	<'erreur nb plu grand que 15'>
	movem.l	(sp)+,d1-a6
        rts

quick
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "quick"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'quick'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : long
   	bne.s	.suiv
   	move.w	#2,taille_work
.suiv
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

	lea	mode_destination,a1
	bsr	insere_adr
	

	move.w	taille_work,d1
	subq	#1,d1
	bfins	d1,bin_code(a2){8:2}
	
	

	lea	mode_source,a3
	move.l	mode_adr+2(a3),d1
	cmp.l	#8,d1
	bgt	.erreur_nb
	cmp.l	#8,d1
	bne.s	.p_h
	clr.l	d1			; huit donne zero
.p_h
	
	
	bfins	d1,bin_code(a2){4:3}
	

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_nb
	DEBUG	<'erreur plus grand que 8'>
	movem.l	(sp)+,d1-a6
        rts


quick_mv
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "moveq"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'quick_mv'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : long
   	bne.s	.suiv
   	move.w	#3,taille_work
.suiv
	cmp.w	#3,taille_work
	beq.s	.ok
	bra.s	.erreur	
.ok


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

	lea	mode_destination,a1		; on insere le reg de destination
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){4:3}
	
	

	lea	mode_source,a3
	move.l	mode_adr+2(a3),d1
	cmp.l	#255,d1
	bgt	.erreur_nb
	
	move.b	d1,bin_code+1(a2)

.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_nb
	DEBUG	<'erreur plus grand que 8'>
	movem.l	(sp)+,d1-a6
        rts


sbcd
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "sbcd "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'sbcd'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : byte
   	bne.s	.suiv
   	move.w	#1,taille_work
.suiv
	cmp.w	#1,taille_work
	beq.s	.ok
	bra	.erreur	
.ok


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	


	lea	mode_destination,a1		; on teste si on a du predecremente
	cmp.l	#1,long_adr(a1)
	beq.s	.donne
	lea	mode_source,a3
	cmp.l	#%10000,long_adr(a3)
	bne	.erreur_adr			; pas de registre de donnee => erreur
	
	bset	#3,bin_code+1(a2)
	move.w	mode_adr(a3),d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}

	
	
	bra.s	.exit
.donne
	lea	mode_source,a3
	cmp.l	#1,long_adr(a3)
	bne.s	.erreur_adr			; pas de registre de donnee => erreur
	
	bclr	#3,bin_code+1(a2)
	move.w	mode_adr(a3),d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}








.exit
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
	
subx
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "subx "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'subx'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.suiv
   	move.w	#2,taille_work
.suiv

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	


	lea	mode_destination,a1		; on teste si on a du predecremente
	cmp.l	#1,long_adr(a1)
	beq.s	.donne
	lea	mode_source,a3
	cmp.l	#%10000,long_adr(a3)
	bne	.erreur_adr			; pas de registre de donnee => erreur
	
	bset	#3,bin_code+1(a2)
	move.w	mode_adr(a3),d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}

	
	
	bra.s	.exit
.donne
	lea	mode_source,a3
	cmp.l	#1,long_adr(a3)
	bne.s	.erreur_adr			; pas de registre de donnee => erreur
	
	bclr	#3,bin_code+1(a2)
	move.w	mode_adr(a3),d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}








.exit

	move.w	taille_work,d1
	subq	#1,d1
	
	bfins	d1,bin_code(a2){8:2}
	


        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
	
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
	
cmpm
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "cmpm "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'cmpm'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.suiv
   	move.w	#2,taille_work
.suiv

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	


	lea	mode_destination,a1		; on teste si on a du predecremente
	lea	mode_source,a3
	move.w	mode_adr(a3),d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}
	

	move.w	taille_work,d1
	subq	#1,d1
	
	bfins	d1,bin_code(a2){8:2}
	


        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts

asl
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "asl "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'asl'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.suiv
   	move.w	#2,taille_work
.suiv

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	


	lea	mode_destination,a1		; on teste si on a du predecremente
	tst.l	long_adr(a1)
	beq.s	.un_seul_para
	
	move.w	mode_adr(a1),d1
	or.w	d1,bin_code(a2)
	
	
	
	lea	mode_source,a1
	cmp.l	#1,long_adr(a1)
	bne.s	.p_donne
	; -- ici on a le reg de donne
	
	bset	#5,bin_code+1(a2)
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){4:3}
	
	
	move.w	taille_work,d1
	subq	#1,d1
	bfins	d1,bin_code(a2){8:2}
	
	
	bra	.exit
	
	
.p_donne
	cmp.l	#%1000000000000,long_adr(a1)
	bne	.erreur_adr
	; ici on est en immediat
	
	
	move.l	mode_adr+2(a1),d1
	cmp.l	#8,d1
	bgt	.erreur_nb
	cmp.l	#8,d1
	bne.s	.p_z
	clr.l	d1
.p_z
	bfins	d1,bin_code(a2){4:3}
	
	
	
	move.w	taille_work,d1
	subq	#1,d1
	bfins	d1,bin_code(a2){8:2}
	
	
	
	bra	.exit
	
.un_seul_para
	lea	mode_source,a1

	cmp.l	#1,long_adr(a1)
	beq.s	.erreur_adr
	cmp.l	#%1000000000000,long_adr(a1)
	beq.s	.erreur_adr

	cmp.w	#2,taille_work
	bne.s	.erreur

	;move.w	#%000,d1
	;bfins	d1,bin_code(a2){4:3}
	move.w	#%11,d1
	bfins	d1,bin_code(a2){8:2}
	
	lea	mode_source,a1
	bsr	insere_adr
	
	
	
.exit

        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
	
.erreur_nb
	DEBUG	<'erreur plus grand que 8'>
	movem.l	(sp)+,d1-a6
        rts
	

move
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "move "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'move'>

        movem.l	d1-a6,-(sp)
   
   	

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

	lea	mode_source,a0
	cmp.l	#1<<13,long_adr(a0)		; ccr en source
	beq	.ccr_source
	cmp.l	#1<<14,long_adr(a0)		; sr en source
	beq	.sr_source
	move.l	long_adr(a0),d1
	and.l	#1<<20,d1
	bne	.usp_source
	
	lea	mode_destination,a0
	cmp.l	#1<<13,long_adr(a0)		; ccr en sdestination
	beq	.ccr_destination
	cmp.l	#1<<14,long_adr(a0)		; sr en sdestination
	beq	.sr_destination
	
	move.l	long_adr(a0),d1
	and.l	#1<<20,d1
	bne	.usp_destination
	
	
	move.l	long_adr(a0),d1
	and.l	#1<<21,d1
	bne	.erreur_adr
	
	

	; ici, on a un move_normal
	
	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.suiv
   	move.w	#2,taille_work
.suiv
	
	
	
	lea	mode_source,a1
	bsr	insere_adr
	
	lea	mode_destination,a1
	bsr	insere_adr_move_dest
	
	move.w	taille_work,d1
	cmp.w	#%10,d1
	bne.s	.norm
	move.w	#%11,d1
	bra.s	.suite
.norm
	cmp.w	#%11,d1
	bne.s	.suite
	move.w	#%10,d1
.suite


	
	bfins	d1,bin_code(a2){2:2}
	bra	.exit
	
	





.ccr_source
	
	; ---- on a le ccr en source ----
	
	cmp.w	#1,taille_work
	beq	.erreur
	cmp.w	#3,taille_work
	beq	.erreur
	
	lea	mode_destination,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en destination
	beq	.erreur_adr
	cmp.l	#%1<<12,long_adr(a1)
	bge	.erreur_adr


	move.w	#%0100001011000000,bin_code(a2)
	bsr	insere_adr

	bra	.exit





.sr_source

	; ---- on a le sr en source ----
	
	cmp.w	#1,taille_work
	beq	.erreur
	cmp.w	#3,taille_work
	beq	.erreur
	
	lea	mode_destination,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en destination
	beq	.erreur_adr
	cmp.l	#%1<<12,long_adr(a1)
	bge	.erreur_adr


	move.w	#%0100000011000000,bin_code(a2)
	bsr	insere_adr

	bra	.exit


.usp_source
	; ---- on a le usp en source ----
	
	cmp.w	#0,taille_work
	beq.s	.ok_t
	cmp.w	#3,taille_work
	beq.s	.ok_t
	bra	.erreur
.ok_t
	lea	mode_destination,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en destination
	bne	.erreur_adr


	move.w	#%0100111001101000,bin_code(a2)
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	or.w	d1,bin_code(a2)


	bra	.exit


.ccr_destination
	; ---- on a le ccr en destination ----
	
	cmp.w	#1,taille_work
	beq	.erreur
	cmp.w	#3,taille_work
	beq	.erreur
	
	lea	mode_source,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en source
	beq	.erreur_adr
	cmp.l	#%1<<13,long_adr(a1)
	beq	.erreur_adr
	cmp.l	#%1<<14,long_adr(a1)
	beq	.erreur_adr
	cmp.l	#%1<<20,long_adr(a1)
	beq	.erreur_adr


	move.w	#%0100010011000000,bin_code(a2)
	bsr	insere_adr

	bra	.exit




.sr_destination
	; ---- on a le sr en destination ----
	
	cmp.w	#1,taille_work
	beq	.erreur
	cmp.w	#3,taille_work
	beq	.erreur
	
	lea	mode_source,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en source
	beq	.erreur_adr
	cmp.l	#%1<<13,long_adr(a1)
	beq	.erreur_adr
	cmp.l	#%1<<14,long_adr(a1)
	beq	.erreur_adr
	cmp.l	#%1<<20,long_adr(a1)
	beq	.erreur_adr


	move.w	#%0100011011000000,bin_code(a2)
	bsr	insere_adr

	bra	.exit

.usp_destination

	; ---- on a le usp en destination ----
	
	cmp.w	#0,taille_work
	beq	.ok_s1
	cmp.w	#3,taille_work
	beq.s	.ok_s1
	bra.s	.erreur
.ok_s1
	lea	mode_source,a1
	cmp.l	#%10,long_adr(a1)		; on regarde si le mode est autorise en source
	bne	.erreur_adr

	move.w	#%0100111001100000,bin_code(a2)
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	or.w	d1,bin_code(a2)

	
	
.exit

        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	DEBUG	<'erreur plus grand que 8'>
	movem.l	(sp)+,d1-a6
        rts
	



pack
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "pack "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'pack'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	beq.s	.suiv
	bra	.erreur
.suiv

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	




	lea	mode_source,a1		; on teste si on a du predecremente
	cmp.l	#1,long_adr(a1)
	beq	.donnee_src
	
	; ici on a du predecremente
	
	lea	mode_destination,a3
	cmp.l	#%10000,long_adr(a3)
	bne	.erreur_adr
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a3),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){4:3}
	
	bset	#3,bin_code+1(a2)
	
	
	bra.s	.suite
	
	
.donnee_src
	lea	mode_destination,a3
	cmp.l	#%1,long_adr(a3)
	bne	.erreur_adr
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a3),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){4:3}
	
	
.suite
	lea	mode_supplementaire,a3		; si on n'a pas de l'immediat => erreur
	cmp.l	#1<<12,long_adr(a3)
	bne.s	.erreur_adr
	move.l	mode_adr+2(a3),d1
	clr.w	d1
	tst.l	d1
	bne	.erreur_nb
	move.l	mode_adr+2(a3),d1
	move.w	d1,bin_code+2(a2)
	


        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb
	
cas
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "cas  "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'cas'>

        movem.l	d1-a6,-(sp)
   
   	cmp.w	#0,taille_work			; taille par defaut : word
   	bne.s	.suiv
	move.w	#2,taille_work
.suiv

        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_destination,a1
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){7:3}
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	move.w	taille_work,d1
	bfins	d1,bin_code(a2){5:2}
	
	
	lea	mode_supplementaire,a1
	cmp.l	#%1,long_adr(a1)
	beq.s	.erreur_adr
	cmp.l	#%10,long_adr(a1)
	beq.s	.erreur_adr
	cmp.l	#1<<12,long_adr(a1)
	bge.s	.erreur_adr
	
	
	
	bsr	insere_adr
	
	
	
	

        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

movec
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "movec"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'movec'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#1,taille_work			; que du long
	beq	.erreur
	cmp.w	#2,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	cmp.l	#1<<21,long_adr(a1)		; a t on de l'etendu en source
	beq.s	.etend_source
	
	
	bset	#0,bin_code+1(a2)
	
	lea	mode_destination,a1
	cmp.l	#1<<21,long_adr(a1)		; si pas en detination alors erreur
	bne	.erreur_adr
	

	move.w	mode_adr(a1),d1
	
	lea	mode_source,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.ok_d1
	cmp.l	#%10,long_adr(a1)
	bne	.erreur_adr
.ok_d1
	bfins	d1,bin_code+2(a2){4:12}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee1
	bset	#7,bin_code+2(a2)
.donnee1
	bra	.exit
	
	
	
	
	
	
	
	
	
.etend_source
	
	move.w	mode_adr(a1),d1			; recuperation de control register
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.ok_d
	cmp.l	#%10,long_adr(a1)
	bne.s	.erreur_adr
.ok_d
	bfins	d1,bin_code+2(a2){4:12}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee
	bset	#7,bin_code+2(a2)
.donnee
	
	
	
.exit
	

        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

cinv
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "cinv "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'cinv'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code(a2){8:2}
	
	lea	mode_destination,a1
	tst.l	long_adr(a1)
	beq.s	.un_seul_par
	; autre parametre
	
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	
	
	
.un_seul_par

        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb


move16
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "move1"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'move16'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	cmp.l	#%1000,long_adr(a1)
	beq	.post_en_source
	
	; pas de (an)+ en source
	; on peut deja ajouter deux a la taille
	
	addq	#2,bin_l_op(a2)			; on ajoute 2 … la taille
	
	
	cmp.l	#%100,long_adr(a1)
	beq.s	.an_src
	
	move.l	mode_adr+2(a1),d1
	
	cmp.l	#1<<11,long_adr(a1)			; il ne reste plus que www.l en source
	bne	.erreur_adr
	
	lea	mode_destination,a1
	
	cmp.l	#%1000,long_adr(a1)
	beq.s	.dest
	
	bset	#4,bin_code+1(a2)			; positionne le bit qui fait la difference
	
.dest
	bset	#3,bin_code+1(a2)
	
	move.l	d1,bin_code+2(a2)
	
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	bra	.exit
	
	
	
	
	
	
	
	
.an_src
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	lea	mode_destination,a1
	cmp.l	#1<<11,long_adr(a1)
	bne	.erreur_adr
	bfins	d1,bin_code(a2){13:3}
	bset	#4,bin_code+1(a2)
	move.l	mode_adr+2(a1),d1
	move.l	d1,bin_code+2(a2)
	bra	.exit
	
	
	
	
	
	
	
.post_en_source
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	lea	mode_destination,a1
	cmp.l	#%100,long_adr(a1)		; pas le doit au (an) en desti
	beq.s	.erreur_adr
	cmp.l	#%1000,long_adr(a1)
	beq.s	.post_en_dest
	
	
	bfins	d1,bin_code(a2){13:3}
	move.l	mode_adr+2(a1),d1
	move.l	d1,bin_code+2(a2)
	addq	#2,bin_l_op(a2)			; on ajoute 2 … la taille
	
	; aucune correction a apporter car opmode =0
	
	
	
	
	bra.s	.exit
	
.post_en_dest
	bfins	d1,bin_code(a2){13:3}
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	bset	#7,bin_code+2(a2)
	bset	#5,bin_code+1(a2)
	
	
	
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

divs
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "divs "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'divs'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.suite
	move.w	#2,taille_work
.suite
	cmp.w	#1,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	cmp.w	#2,taille_work
	bne.s	.long
	
	; ici, on est en word
	
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	bne	.erreur_adr
	
	
	move.w	mode_adr(a1),d1
	move.w	#%1000000111000000,bin_code(a2)
	bfins	d1,bin_code(a2){4:3}
	
	lea	mode_source,a1
	bsr	insere_adr
	
	bra.s	.exit	
	
.long

	move.w	#%0100110001000000,bin_code(a2)

	move.w	i_op+2(a1),bin_code+2(a2)

	lea	mode_source,a1
	bsr	insere_adr


	addq	#2,bin_l_op(a2)			; taille de 4
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee_dest
	
	
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	move.w	mode_adr+2(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	bra	.exit
	
.donnee_dest
	
	bclr	#2,bin_code+2(a2)		; on enleve le bit si on a qu'une donnee
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	bfins	d1,bin_code+2(a2){1:3}
			
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb


divu
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "divu "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'divu'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.suite
	move.w	#2,taille_work
.suite
	cmp.w	#1,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	cmp.w	#2,taille_work
	bne.s	.long
	
	; ici, on est en word
	
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	bne	.erreur_adr
	
	
	move.w	mode_adr(a1),d1
	move.w	#%1000000011000000,bin_code(a2)
	bfins	d1,bin_code(a2){4:3}
	
	lea	mode_source,a1
	bsr	insere_adr
	
	bra.s	.exit	
	
.long

	move.w	#%0100110001000000,bin_code(a2)

	move.w	i_op+2(a1),bin_code+2(a2)

	lea	mode_source,a1
	bsr	insere_adr


	addq	#2,bin_l_op(a2)			; taille de 4
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee_dest
	
	
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	move.w	mode_adr+2(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	bra	.exit
	
.donnee_dest
	
	bclr	#2,bin_code+2(a2)		; on enleve le bit si on a qu'une donnee
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	bfins	d1,bin_code+2(a2){1:3}
			
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb


muls
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "muls "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'muls'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.suite
	move.w	#2,taille_work
.suite
	cmp.w	#1,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	cmp.w	#2,taille_work
	bne.s	.long
	
	; ici, on est en word
	
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	bne	.erreur_adr
	
	
	move.w	mode_adr(a1),d1
	move.w	#%1100000111000000,bin_code(a2)
	bfins	d1,bin_code(a2){4:3}
	
	lea	mode_source,a1
	bsr	insere_adr
	
	bra.s	.exit	
	
.long

	move.w	#%0100110000000000,bin_code(a2)

	move.w	i_op+2(a1),bin_code+2(a2)

	lea	mode_source,a1
	bsr	insere_adr


	addq	#2,bin_l_op(a2)			; taille de 4
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee_dest
	
	
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	move.w	mode_adr+2(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	bra	.exit
	
.donnee_dest
	
	bclr	#2,bin_code+2(a2)		; on enleve le bit si on a qu'une donnee
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	bfins	d1,bin_code+2(a2){1:3}
			
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

mulu
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "mulu "**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'mulu'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.suite
	move.w	#2,taille_work
.suite
	cmp.w	#1,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	cmp.w	#2,taille_work
	bne.s	.long
	
	; ici, on est en word
	
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	bne	.erreur_adr
	
	
	move.w	mode_adr(a1),d1
	move.w	#%1100000011000000,bin_code(a2)
	bfins	d1,bin_code(a2){4:3}
	
	lea	mode_source,a1
	bsr	insere_adr
	
	bra.s	.exit	
	
.long

	move.w	#%0100110000000000,bin_code(a2)

	move.w	i_op+2(a1),bin_code+2(a2)

	lea	mode_source,a1
	bsr	insere_adr


	addq	#2,bin_l_op(a2)			; taille de 4
	lea	mode_destination,a1
	cmp.l	#1,long_adr(a1)
	beq.s	.donnee_dest
	
	
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	move.w	mode_adr+2(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	bra	.exit
	
.donnee_dest
	
	bclr	#2,bin_code+2(a2)		; on enleve le bit si on a qu'une donnee
	
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){13:3}
	bfins	d1,bin_code+2(a2){1:3}
			
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb


pflush
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "pflsh"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'pflush'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	and.w	#%111,d1
	bfins	d1,bin_code(a2){13:3}
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

bfchg
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bfchg"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'bfchg'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	bsr	insere_adr
	
	move.w	bf_mode,d1
	btst	#15,d1
	beq.s	.erreur_adr
	bclr	#15,d1
	bfins	d1,bin_code+2(a2){4:12}
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

bfexts
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bfext"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'bfext'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	bsr	insere_adr
	
	move.w	bf_mode,d1
	btst	#15,d1
	beq.s	.erreur_adr
	bclr	#15,d1
	bfins	d1,bin_code+2(a2){4:12}
	
	
	lea	mode_destination,a1
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

bfins
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "bfins"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'bfins'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_destination,a1
	bsr	insere_adr
	
	move.w	bf_mode,d1
	btst	#15,d1
	beq.s	.erreur_adr
	bclr	#15,d1
	bfins	d1,bin_code+2(a2){4:12}
	
	
	lea	mode_source,a1
	move.w	mode_adr(a1),d1
	bfins	d1,bin_code+2(a2){1:3}
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

trapcc
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "trapc"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'trapcc'>

        movem.l	d1-a6,-(sp)
   
	cmp.w	#0,taille_work			; que du long
	bne.s	.suiv
	move.w	#2,taille_work
.suiv
	cmp.w	#1,taille_work
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	
	lea	mode_source,a1
	tst.l	long_adr(a1)
	beq.s	.no_param
	
	cmp.w	#2,taille_work
	bne.s	.long
	
	move.w	#%10,d1
	bfins	d1,bin_code(a2){13:3}
	
	move.l	mode_adr+2(a1),d1
	clr.w	d1
	tst.l	d1
	bne	.erreur_nb
	move.l	mode_adr+2(a1),d1
	move.w	d1,bin_code+2(a2)
	
	
	bra	.exit
	
.long
	move.w	#%11,d1
	bfins	d1,bin_code(a2){13:3}
	move.l	mode_adr+2(a1),d1
	move.l	d1,bin_code+2(a2)
	
	bra	.exit
	
.no_param	
	move.w	#%100,d1
	bfins	d1,bin_code(a2){13:3}
	
	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	bra	erreur_taille
.erreur_adr
	bra	erreur_mode_adr
.erreur_nb
	bra	erreur_nb

cas2
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "cas2" **
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         
	;DEBUG	<'cas2'>

        movem.l	d1-a6,-(sp)
   
        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	
	bra.s	.unimpl	
	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts

.unimpl
	DEBUG	<'Non implement‚'>
	movem.l	(sp)+,d1-a6
        rts


movem
	*************************************************************
	** routine qui va secharger d'assembler les opcodes "movem"**
	**                                                         **
	** Entr‚e:                                                 **
	** -------                                                 **
        **            - a1 pointeur sur la structure               **
        **            - d1 …on a la taille                         **
        **                                                         **
        ** Sortie:                                                 **
        ** -------                                                 **
        **            - d0=0 ok                                    **
        **            - d0<> 0 erreur                              **
        **                                                         **  
        ************************************************************* 
	
         

        movem.l	d1-a6,-(sp)
   
	cmp.w	#1,taille_work		; pas de byte
	beq	.erreur


        move.l	s_binary,a2
       	move.w	i_op(a1),bin_code(a2)
        move.w	i_lenght(a1),d2
        add.w	d2,bin_l_op(a2)
	

	cmp.w	#2,taille_work		; bit pour la taille
	bne.s	.p_w
	bclr	#6,bin_code(a2)
	bra.s	.ww
.p_w
	bset	#6,bin_code+1(a2)
.ww

	lea	mode_source,a1
	cmp.l	#1<<25,long_adr(a1)
	bne.s	.en_dest
	move.w	mode_adr(a1),d0		; liste des reg dans d0
	lea	mode_destination,a1
	cmp.l	#1<<25,long_adr(a1)
	beq.s	.erreur

	bclr	#2,bin_code(a2)	; bit de direction
	
	move.w	d0,bin_code+2(a2)
	
	bsr	insere_adr
	bra	.exit
	




.en_dest
	lea	mode_destination,a1
	move.w	mode_adr(a1),d0	
	lea	mode_source,a1
	cmp.l	#1<<25,long_adr(a1)
	beq.s	.erreur
	
	bset	#2,bin_code(a2)	; bit de direction
	
	move.w	d0,bin_code+2(a2)
	
	bsr	insere_adr

	
.exit
	
        moveq	#0,d0
        movem.l	(sp)+,d1-a6
        rts
.erreur
	
        moveq	#-1,d0
	bsr	erreur_mode_adr
        movem.l	(sp)+,d1-a6
        rts

        
 
convert_nb
	***********************************************
	** routine qui va convertir le xxxx en Lyyyy **
	**                                           **
	** Entr‚e:                                   **
	** -------                                   **
	**            - a0 chaine a convertir        **
	**            - a2 chaine de destination     **
	**                                           **
	** Sortie:                                   **
	** -------                                   **
	**            - d0 = 0 OK                    **
	**            - d0<>0 erreur                 **
	**                                           **
	***********************************************
	
	
	
	move.l	a0,a1

.suiv

	; chaine dans a0
	
	
	
	move.l	a1,a3
	lea	temp_cop,a0
	cmp.b	#'$',(a1)
	bne.s	.p_n
	move.b	(a1)+,(a0)+
	beq.s	.erreur
.ch	move.b	(a1)+,d7
	cmp.b	#' ',d7
	beq.s	.kj
	cmp.b	#',',d7
	beq.s	.kj
	cmp.b	#'(',d7
	beq.s	.kj
	cmp.b	#')',d7
	cmp.b	#'',d7
	beq.s	.kj
	cmp.b	#0,d7
	beq.s	.kj
	
	
	




	move.b	d7,(a0)+
	bra	.ch
.kj
	clr.b	(a0)

	lea	temp_cop,a0
	bsr.l	eval
	tst.l	d2
	bne.s	.erreur
	
	
	
	; si on a un nombre, resultat dans d1

	move.b	#'L',(a2)+
	move.l	d1,(a2)+
	tst.l	d7
	beq.s	.sort
	move.b	d7,(a2)+
	bra.s	.suiv
.p_n
	move.l	a3,a1
	move.b	(a1)+,(a2)+
	bne	.suiv

	



.sort	
	clr.b	(a2)
	moveq	#0,d0
	rts
	
.erreur
	moveq	#-1,d0
	rts



erreur_taille
	****************************************************
	** routine qui renvoie le message d'erreur taille **
	****************************************************
	
	
	DEBUG	<'erreur taille'>
	movem.l	(sp)+,d1-a6
        rts
	
erreur_mode_adr
	*********************************************************
	** routine qui renvoie le message d'erreur d'adressage **
	*********************************************************
	
	DEBUG	<'erreur de mode d adressage'>
	movem.l	(sp)+,d1-a6
        rts

erreur_nb
	************************************************************
	** routine qui renvoie le messqge d'erreur de depassement **
	************************************************************
	DEBUG	<'erreur plus grand que 65535'>
	movem.l	(sp)+,d1-a6
        rts





	SECTION DATA

	
Table_instruction

	dc.b	'ILLEGAL '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	$4afc
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'NOP     '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	$4e71
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'RESET   '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	%0100111001110000
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'RTE     '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	%0100111001110011
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'RTS     '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	%0100111001110101
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'TRAPV   '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	%0100111001110110
	dc.w	0
	dc.w	0
	dc.l	direct
	
	dc.b	'RTR     '
	dc.w	2
	dc.l	0
	dc.l	0
	dc.w	%0100111001110111
	dc.w	0
	dc.w	0
	dc.l	direct
	
	
	dc.b	'EXG     '
	dc.w	2
	dc.l	%11		; dn, an
	dc.l	%11
	dc.w	%1100000100000000
	dc.w	0
	dc.w	2
	dc.l	exg
	
	
	dc.b	'NEGX    '
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100000000000000
	dc.w	0
	dc.w	1
	dc.l	negx
	
	dc.b	'NOT     '
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100011000000000
	dc.w	0
	dc.w	1
	dc.l	negx
	
	dc.b	'CLR     '
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100001000000000
	dc.w	0
	dc.w	1
	dc.l	negx
	
	dc.b	'NEG     '
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100010000000000
	dc.w	0
	dc.w	1
	dc.l	negx
	
	dc.b	'TST     '
	dc.w	2
	dc.l	%11111001111111111111
	dc.l	%0
	dc.w	%0100101000000000
	dc.w	0
	dc.w	1
	dc.l	negx
	
	dc.b	'TAS     '
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100101011000000
	dc.w	0
	dc.w	1
	dc.l	mvsr
	
	dc.b	'JSR     '
	dc.w	2
	dc.l	%11111000111111100100
	dc.l	%0
	dc.w	%0100111010000000
	dc.w	0
	dc.w	1
	dc.l	mvsr
	
	dc.b	'JMP     '
	dc.w	2
	dc.l	%11111000111111100100
	dc.l	%0
	dc.w	%0100111011000000
	dc.w	0
	dc.w	1
	dc.l	mvsr
	
	dc.b	'PEA     '
	dc.w	2
	dc.l	%11111000111111100100
	dc.l	%0
	dc.w	%0100100001000000
	dc.w	0
	dc.w	1
	dc.l	mvsr
	
	dc.b	'NBCD    '				; nbcd en BYTE  attention
	dc.w	2
	dc.l	%111111111101
	dc.l	%0
	dc.w	%0100100000000000
	dc.w	0
	dc.w	1
	dc.l	mvsr
	
	dc.b	'ADD     '
	dc.w	2
	dc.l	%11111001111111111111
	dc.l	%11111000111111111111
	dc.w	%1101000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'AND     '
	dc.w	2
	dc.l	%11111001111111111111
	dc.l	%11111000111111111111
	dc.w	%1100000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'ADDA    '
	dc.w	2
	dc.l	%11111001111111111111
	dc.l	%10
	dc.w	%1101000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	
	dc.b	'SUB     '
	dc.w	2
	dc.l	%11111001111111111111
	dc.l	%11111001111111111111
	dc.w	%1001000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'SUBA    '
	dc.w	2
	dc.l	%11111000111111111111
	dc.l	%10
	dc.w	%1001000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'EOR     '
	dc.w	2
	dc.l	%1
	dc.l	%111111111101
	dc.w	%1011000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'CMP     '
	dc.w	2
	dc.l	%1111101111111111111
	dc.l	%1
	dc.w	%1011000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	dc.b	'CMPA    '
	dc.w	2
	dc.l	%1111101111111111111
	dc.l	%10
	dc.w	%1011000000000000
	dc.w	0
	dc.w	2
	dc.l	add
	
	
	
	; serie des branchements
	
	
	
	dc.b	'BRA     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110000000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BSR     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110000100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BHI     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110001000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BLS     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110001100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BCC     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110010000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BCS     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110010100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BNE     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110011000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BEQ     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110011100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	 
	dc.b	'BVC     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110100000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BVS     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110100100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BPL     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110101000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BMI     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110101100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BGE     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110110000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BLT     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110110100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BGT     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110111000000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	dc.b	'BLE     '
	dc.w	2
	dc.l	%100000000000			; seulement memoire
	dc.l	%0
	dc.w	%0110111100000000
	dc.w	0
	dc.w	1
	dc.l	bcc
	
	
	;serie des debranchements
	
	
	
	;dc.b	'BRA     '
	;dc.w	2
	;dc.l	%1
	;dc.l	%100000000000			; seulement memoire
	;dc.w	%0101000000000000
	;dc.l	bcc
	
	dc.b	'DBRA    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101000100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBF     '			; meme chose que dbra
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101000100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBHI    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101001000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBLS    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101001100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBCC    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101010000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBCS    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101010100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBNE    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101011000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBEQ    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101011100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	 
	dc.b	'DBVC    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101100000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBVS    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101100100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBPL    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101101000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBMI    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101101100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBGE    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101110000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBLT    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101110100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBGT    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101111000000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	dc.b	'DBLE    '
	dc.w	2
	dc.l	%1
	dc.l	%100000000000			; seulement memoire
	dc.w	%0101111100000000
	dc.w	0
	dc.w	2
	dc.l	dbcc
	
	
	;	


	dc.b	'ORI     '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%110111111111101
	dc.w	%0000000000000000
	dc.w	0
	dc.w	2
	dc.l	ori


	dc.b	'ANDI    '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%110111111111101
	dc.w	%0000001000000000
	dc.w	0
	dc.w	2
	dc.l	ori

	dc.b	'SUBI    '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%111111111101
	dc.w	%0000010000000000
	dc.w	0
	dc.w	2
	dc.l	ori

	dc.b	'ADDI    '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%111111111101
	dc.w	%0000011000000000
	dc.w	0
	dc.w	2
	dc.l	ori

	dc.b	'EORI    '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%110111111111101
	dc.w	%0000101000000000
	dc.w	0
	dc.w	2
	dc.l	ori

	dc.b	'CMPI    '
	dc.w	2
	dc.l	%1000000000000
	dc.l	%11111110111111111101
	dc.w	%0000110000000000
	dc.w	0
	dc.w	2
	dc.l	ori


	; ------------ type cmp2
	
	dc.b	'CMP2    '
	dc.w	4
	dc.l	%11111000111111100100
	dc.l	%11
	dc.w	%0000000011000000
	dc.w	%0000000000000000
	dc.w	2
	dc.l	cmp2

	dc.b	'CHK2    '
	dc.w	4
	dc.l	%11111000111111100100
	dc.l	%11
	dc.w	%0000000011000000
	dc.w	%0000100000000000
	dc.w	2
	dc.l	cmp2

	;------- type bchg
	
	dc.b	'BCHG    '
	dc.w	2
	dc.l	%1000000000001			; immediat + donne
	dc.l	%111111111101
	dc.w	%0000000001000000
	dc.w	%0000000000000000
	dc.w	2
	dc.l	bchg
	
	dc.b	'BCLR    '
	dc.w	2
	dc.l	%1000000000001			; immediat + donne
	dc.l	%111111111101
	dc.w	%0000000010000000
	dc.w	0
	dc.w	2
	dc.l	bchg
	
	dc.b	'BSET    '
	dc.w	2
	dc.l	%1000000000001			; immediat + donne
	dc.l	%111111111101
	dc.w	%0000000110000000
	dc.w	0
	dc.w	2
	dc.l	bchg
	
	dc.b	'BTST    '
	dc.w	2
	dc.l	%1000000000001			; immediat + donne
	dc.l	%111111111101
	dc.w	%0000000000000000
	dc.w	0
	dc.w	2
	dc.l	bchg


	;----- serie des scc

	dc.b	'ST      '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101000011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SF      '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101000111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SHI     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101001011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SLS     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101001111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SCC     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101010011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SCS     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101010111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SNE     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101011011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SEQ     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101011111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	 
	dc.b	'SVC     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101100011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SVS     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101100111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SPL     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101101011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SMI     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101101111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SGE     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101110011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SLT     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101110111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SGT     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101111011000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	dc.b	'SLE     '
	dc.w	2
	dc.l	%111111111101			; seulement memoire
	dc.l	%0
	dc.w	%0101111111000000
	dc.w	0
	dc.w	1
	dc.l	scc
	
	
	; -------serie des trapcc
	
	dc.b	'TRAPT   '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101000011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPF   '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101000111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPHI  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101001011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPLS  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101001111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPCC  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101010011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPCS  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101010111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPNE  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101011011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPEQ  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101011111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	 
	dc.b	'TRAPVC  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101100011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPVS  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101100111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPPL  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101101011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPMI  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101101111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPGE  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101110011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPLT  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101110111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPGT  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101111011111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	dc.b	'TRAPLE  '
	dc.w	2
	dc.l	1<<12			; seulement memoire
	dc.l	%0
	dc.w	%0101111111111000
	dc.w	0
	dc.w	5
	dc.l	trapcc
	
	
	
	
	
	;--------- Moves
	
	
	dc.b	'MOVES   '
	dc.w	4
	dc.l	%111111111111			
	dc.l	%111111111111	
	dc.w	%0000111000000000
	dc.w	0
	dc.w	2
	dc.l	moves
	

	;--------- Movep
	
	
	dc.b	'MOVEP   '
	dc.w	4
	dc.l	%100101			
	dc.l	%111111111111	
	dc.w	%0000000000001000
	dc.w	0
	dc.w	2
	dc.l	movep
	
	
	dc.b	'EXT     '
	dc.w	2
	dc.l	%1			
	dc.l	%0	
	dc.w	%0100100000000000
	dc.w	0
	dc.w	1
	dc.l	ext
	
	dc.b	'EXTB    '
	dc.w	2
	dc.l	%1			
	dc.l	%0	
	dc.w	%0100100000000000
	dc.w	0
	dc.w	1
	dc.l	extb
	
	dc.b	'LINK    '
	dc.w	4
	dc.l	%10			
	dc.l	%1000000000000
	dc.w	%0100100000000000
	dc.w	0
	dc.w	2
	dc.l	link
	
	
	dc.b	'SWAP    '
	dc.w	2
	dc.l	%1			
	dc.l	%0
	dc.w	%0100100001000000
	dc.w	0
	dc.w	1
	dc.l	swap
	
	dc.b	'UNLK    '
	dc.w	2
	dc.l	%10			
	dc.l	%0
	dc.w	%0100111001011000
	dc.w	0
	dc.w	1
	dc.l	swap
	
	dc.b	'BKPT    '
	dc.w	2
	dc.l	%1000000000000			
	dc.l	%0
	dc.w	%0100100001001000
	dc.w	0
	dc.w	1
	dc.l	bkpt
	
	
	dc.b	'TRAP    '
	dc.w	2
	dc.l	%1000000000000			
	dc.l	%0
	dc.w	%0100111001000000
	dc.w	0
	dc.w	1
	dc.l	trap
	
	dc.b	'RTD     '
	dc.w	4
	dc.l	%1000000000000			
	dc.l	%0
	dc.w	%0100111001110100
	dc.w	0
	dc.w	1
	dc.l	rtd
	
	
	dc.b	'STOP    '
	dc.w	4
	dc.l	%1000000000000			
	dc.l	%0
	dc.w	%0100111001110010
	dc.w	0
	dc.w	1
	dc.l	rtd
	
	
	dc.b	'LEA     '
	dc.w	2
	dc.l	%11111000111111100100			
	dc.l	%10
	dc.w	%0100000111000000
	dc.w	0
	dc.w	2
	dc.l	lea

	dc.b	'ADDQ    '
	dc.w	2
	dc.l	%1000000000000			
	dc.l	%111111111111
	dc.w	%0101000000000000
	dc.w	0
	dc.w	2
	dc.l	quick
	
	dc.b	'SUBQ    '
	dc.w	2
	dc.l	%1000000000000			
	dc.l	%111111111111
	dc.w	%0101000100000000
	dc.w	0
	dc.w	2
	dc.l	quick

	dc.b	'MOVEQ   '
	dc.w	2
	dc.l	%1000000000000			
	dc.l	%1
	dc.w	%0111000000000000
	dc.w	0
	dc.w	2
	dc.l	quick_mv

	dc.b	'SBCD    '
	dc.w	2
	dc.l	%10001			
	dc.l	%10001
	dc.w	%1000000100000000
	dc.w	0
	dc.w	2
	dc.l	sbcd
	
	dc.b	'ABCD    '
	dc.w	2
	dc.l	%10001			
	dc.l	%10001
	dc.w	%1100000100000000
	dc.w	0
	dc.w	2
	dc.l	sbcd

	dc.b	'SUBX    '
	dc.w	2
	dc.l	%10001			
	dc.l	%10001
	dc.w	%1001000100000000
	dc.w	0
	dc.w	2
	dc.l	subx

	dc.b	'ADDX    '
	dc.w	2
	dc.l	%10001			
	dc.l	%10001
	dc.w	%1101000100000000
	dc.w	0
	dc.w	2
	dc.l	subx

	dc.b	'CMPM    '
	dc.w	2
	dc.l	%1000
	dc.l	%1000
	dc.w	%1011000100001000
	dc.w	0
	dc.w	2
	dc.l	cmpm



	dc.b	'ASL     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110000111000000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'ASR     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110000011000000
	dc.w	0
	dc.w	4
	dc.l	asl

	dc.b	'LSL     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110001111001000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'LSR     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110001011001000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'ROXL    '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110010111010000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'ROXR    '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110010011010000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'ROL     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110011111011000
	dc.w	0
	dc.w	4
	dc.l	asl
	
	dc.b	'ROR     '
	dc.w	2
	dc.l	%1111111111101
	dc.l	%1
	dc.w	%1110011011011000
	dc.w	0
	dc.w	4
	dc.l	asl


	; la famille des moves
	

	dc.b	'MOVE    '
	dc.w	2
	dc.l	%111111111111111111111
	dc.l	%100000110111111111111		;	+sr +ccr +usp
	dc.w	%0000000000000000
	dc.w	0
	dc.w	2
	dc.l	move
	
	dc.b	'MOVEA   '
	dc.w	2
	dc.l	%111111111111111111111
	dc.l	%10				;	+sr +ccr +usp
	dc.w	%0000000000000000
	dc.w	0
	dc.w	2
	dc.l	move

	
	; les instruction a 3 parametres
	
	dc.b	'PACK    '
	dc.w	4
	dc.l	%10001
	dc.l	%10001				
	dc.w	%1000000101000000
	dc.w	0
	dc.w	3
	dc.l	pack

	dc.b	'UNPK    '
	dc.w	4
	dc.l	%10001
	dc.l	%10001				
	dc.w	%1000000110000000
	dc.w	0
	dc.w	3
	dc.l	pack

	dc.b	'CAS     '
	dc.w	4
	dc.l	%1
	dc.l	%1				
	dc.w	%0000100011000000
	dc.w	0
	dc.w	3
	dc.l	cas

	dc.b	'MOVEC   '
	dc.w	4
	dc.l	%1000000000000000000011			; dn +an +reistre etendus
	dc.l	%1000000000000000000011			; dn +an +reistre etendus
	dc.w	%0100111001111010
	dc.w	0
	dc.w	2
	dc.l	movec

	dc.b	'CINVL   '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%100			; dn +an +reistre etendus
	dc.w	%1111010000001000
	dc.w	0
	dc.w	2
	dc.l	cinv

	dc.b	'CINVP   '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%100			; dn +an +reistre etendus
	dc.w	%1111010000010000
	dc.w	0
	dc.w	2
	dc.l	cinv

	dc.b	'CINVA   '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%0			; dn +an +reistre etendus
	dc.w	%1111010000011000
	dc.w	0
	dc.w	1
	dc.l	cinv

	dc.b	'CPUSHL  '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%100			; dn +an +reistre etendus
	dc.w	%1111010000101000
	dc.w	0
	dc.w	2
	dc.l	cinv

	dc.b	'CPUSHP  '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%100			; dn +an +reistre etendus
	dc.w	%1111010000110000
	dc.w	0
	dc.w	2
	dc.l	cinv

	dc.b	'CPUSHA  '
	dc.w	2
	dc.l	%10000000000000000000000			; dn +an +reistre etendus
	dc.l	%0			; dn +an +reistre etendus
	dc.w	%1111010000111000
	dc.w	0
	dc.w	1
	dc.l	cinv

	
	;--------- le move 16 -----------------
	
	dc.b	'MOVE16  '
	dc.w	4
	dc.l	%100000001100			; dn +an +reistre etendus
	dc.l	%100000001100			; dn +an +reistre etendus
	dc.w	%1111011000000000
	dc.w	0
	dc.w	2
	dc.l	move16



	;--------- les routines de division ----------------


	dc.b	'DIVS    '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23+1				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000110000000000		; 2eme para obligatoire
	dc.w	2
	dc.l	divs
	
	dc.b	'DIVSL   '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000100000000000		; 2 eme para obligatoire
	dc.w	2
	dc.l	divs
	
	dc.b	'DIVU    '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23+1				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000010000000000		; 2eme para obligatoire
	dc.w	2
	dc.l	divu
	
	dc.b	'DIVUL   '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000000000000000		; 2 eme para obligatoire
	dc.w	2
	dc.l	divu

	
	; ---------------- les mul
	
	
	dc.b	'MULS    '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23+1				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000110000000000		; 2eme para obligatoire
	dc.w	2
	dc.l	muls
	
	dc.b	'MULU    '
	dc.w	2
	dc.l	%11111001111111111101		
	dc.l	1<<23+1				; dn + les regitres doubles
	dc.w	%0				; on le fait a la main dans la routine
	dc.w	%0000010000000000		; 2eme para obligatoire
	dc.w	2
	dc.l	mulu
	

	;--------- les routines de pflush ----------------


	dc.b	'PFLUSH  '
	dc.w	2
	dc.l	%100		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010100001000
	dc.w	0
	dc.w	1
	dc.l	pflush

	dc.b	'PFLUSHN '
	dc.w	2
	dc.l	%100		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010100000000
	dc.w	0
	dc.w	1
	dc.l	pflush

	dc.b	'PFLUSHA '
	dc.w	2
	dc.l	%0		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010100011000
	dc.w	0
	dc.w	0
	dc.l	pflush

	dc.b	'PFLUSHAN'
	dc.w	2
	dc.l	%0		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010100010000
	dc.w	0
	dc.w	0
	dc.l	pflush

	dc.b	'PTESTR  '
	dc.w	2
	dc.l	%100		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010101101000
	dc.w	0
	dc.w	1
	dc.l	pflush

	dc.b	'PTESTW  '
	dc.w	2
	dc.l	%100		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1111010101001000
	dc.w	0
	dc.w	1
	dc.l	pflush



	; les instruction bf....
	
	dc.b	'BFCHG   '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1110101011000000
	dc.w	%0
	dc.w	1
	dc.l	bfchg

	dc.b	'BFCLR   '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1110110011000000
	dc.w	%0
	dc.w	1
	dc.l	bfchg
	
	dc.b	'BFSET   '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1110111011000000
	dc.w	%0
	dc.w	1
	dc.l	bfchg

	dc.b	'BFTST   '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%0				; dn + les regitres doubles
	dc.w	%1110100011000000
	dc.w	%0
	dc.w	1
	dc.l	bfchg
	
	dc.b	'BFEXTS  '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%1				; dn + les regitres doubles
	dc.w	%1110101111000000
	dc.w	%0
	dc.w	2
	dc.l	bfexts

	dc.b	'BFEXTU  '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%1				; dn + les regitres doubles
	dc.w	%1110100111000000
	dc.w	%0
	dc.w	2
	dc.l	bfexts

	dc.b	'BFFFO   '
	dc.w	4
	dc.l	%111111100101+1<<24		
	dc.l	%1				; dn + les regitres doubles
	dc.w	%1110110111000000
	dc.w	%0
	dc.w	2
	dc.l	bfexts

	dc.b	'BFINS   '
	dc.w	4
	dc.l	%1				; dn + les regitres doubles
	dc.l	%111111100101+1<<24		
	dc.w	%1110111111000000
	dc.w	%0
	dc.w	2
	dc.l	bfins




	dc.b	'CAS2    '			; non impl‚m‚nt‚
	dc.w	2
	dc.l	%11111111111111111111111
	dc.l	%11111111111111111111111
	dc.w	%0
	dc.w	%0
	dc.w	2
	dc.l	cas2

	dc.b	'MOVEM   '			; non impl‚m‚nt‚
	dc.w	4
	dc.l	%11111111111111111111111+1<<25
	dc.l	%11111111111111111111111+1<<25
	dc.w	%0100100010000000
	dc.w	%0
	dc.w	2
	dc.l	movem



	dc.b	'FIN '





Err_instruc_not_found
	dc.b	'Instruction non reconnue',0
	even




	
	
	SECTION BSS

pc_t			ds.l	1		; sauvegarde du pc
od			ds.w	1		; flag pour dire si on a un outer displacement
bf_mode			ds.w	1		; falg pour dire si on a des accolades.
ADR_PC			ds.w	1
taille_work		ds.w	1		; taille sur laquelle travaille l'instruction


erreur			ds.b	50
temp_cop		ds.b	100
temp			ds.b	100
temp_ch			ds.b	50
temp_ch1		ds.b	50
	
mode_source		ds.l	10
mode_destination	ds.l	10
mode_supplementaire	ds.l	10

	
s_binary	ds.l	1
buffer_instruction
		ds.b	50			; buffer pour copier les instructions
binary
		ds.b	100
	

	
