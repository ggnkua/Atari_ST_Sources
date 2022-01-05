	include	d:\centinel\both\define.s
	output	d:\centinel\40\main.inc\load.o
	incdir	d:\centinel\40
	include	d:\centinel\both\LOCALMAC.S
	include	d:\centinel\both\GEM.EQU
	include 40\macros.s
	;xref	COL_ADR,COL_NOR,COL_LAB,COL_FCT,COL_REG,COL_CHG,COL_BKPT,COL_ERR_L,ATTRIBUTE,COL_MENU,COL_DSP
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
	xref	BASE_PAGE,SAVE_OLD_PROS


r_charge_sym::
**********************************************************
** routine qui va charger une liste entiere de symboles **
** de plusieur programmes qui se trouvent en memoire    **
**********************************************************


	CENT_PROS

	move.l	$5a0.w,a0
	
	
.find	tst.l	a0
	beq	.erreur_mem			; pas de cookie symbol
	cmp.l	#'_SYM',(a0)+
	bne.s	.find
	
	

	move.l	#0,nb_symbols


	*- on teste si on doit faire un mfree -*
	
	
	*- il faudra ajouter les symbols d'un programme a charger par ctrl l dans cette liste pour
	*- ne pas les perdre durant une update
	
	
	

	tst.l	buf_label
	beq.s	.vide_b
	move.l	buf_label,-(sp)
	GEM	Mfree
.vide_b
	
	
	tst.l	adr_label
	beq.s	.vide_a
	move.l	adr_label,-(sp)
	GEM	Mfree
	
.vide_a
	
	
	tst.l	hash_table
	beq.s	.vide_h
	move.l	hash_table,-(sp)
	GEM	Mfree
	
.vide_h



	
	move.l	(a0),a0
	



	move.w	(a0)+,d7			; nombre de table de symboles
	beq	.annule
	
	
	
	
	add.l	#2+4+4+4,a0			; on saute le header
	
	
	
	
	
	move.l	a0,a1
	
	addq	#8,a1
	subq.l	#1,d7
	move.l	d7,d6


	*-- calcul de la longueur totale des symbols pour le malloc --*

	moveq	#0,d4
	
.cal_long
	add.l	(a1)+,d4
	add.l	#12,a1	
	dbra	d6,.cal_long
	
	


	
	move.l	a0,a6
	
	
	
	
	
	move.l	#4000*8,-(sp)			; on autorise jusqu'a 4000 symboles
	
	GEM	Malloc
	
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,adr_label
	
	
	
	
	move.l	d4,-(sp)			; on reserve la longueur de la section symbole pour le buffer de symboles
	
	GEM	Malloc
	
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,buf_label
	move.l	d0,a0
	move.w	#-1,(a0)
	
	
	
	
	move.l	d4,-(sp)		
	
	GEM	Malloc
	
	tst.l	d0
	beq	.erreur_mem
	move.l	d0,hash_table

	
	move.l	d7,d4
	
.genere
	move.l	a6,a0
	
	
	move.l	(a0)+,a1			; adresse de depart du prog
	move.l	(a0)+,d6			; dans d1 adresse de depart des symbols
	move.l	(a0)+,d7			; la longeur
	
	addq	#4,a0				; on saute le mot vide
	
	
	move.l	a0,a6				; sauve a0
	move.l	d6,a0				; debut de la table des symbols
	
	
	
	
	
	
	
	
	move.l	#$100000,taille_fichier	; voir si plus interresant apres
	
		
	
	bsr	genere_table_symboles
	
	
	dbra	d4,.genere
	
	
	bsr	tri_symbols
	bsr	genere_hash_table



	;move.l	adr_label,$800000+10
	;
	;move.l	buf_label,$800000+4+10
	;
	;move.l	nb_symbols,$800000+8+10




	move.l	#MES_SYM_LOAD_U,MESSAGE_ADR
	bsr.l	set_all_flags
	
	bsr.l	traite_le_pc			; on affiche la forme du curseur
	
.annule
	
	
	REST_PROS

	

	rts


.erreur_mem

	move.l	#MES_ERREUR_LOAD,MESSAGE_ADR
	moveq	#0,d0
	rts
	


r_load_sym::
***************************************************
** routine qui va 'charger' les symbol d'un prog **
** deja en memoire                               **
***************************************************

	
.recom
	move.l	#MES_LOAD_SYM,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.annule
	
	
	move.l 	a2,a1
	
.next
	move.b	(a1)+,d0
	beq.s	.recom
	
	
	cmp.b	#',',d0
	bne.s	.next
	clr.b	-1(a1)
	
	move.l	a2,a0
	xref 	eval
	bsr.l	eval
	tst.l	d2
	bne.s	.recom
	move.l	d1,d5			; adresse de depart du prog
	
	
	move.l	a1,a2
	
.next1
	move.b	(a1)+,d0
	beq.s	.recom
	
	cmp.b	#',',d0
	bne.s	.next1
	clr.b	-1(a1)
	
	
	
	move.l	a1,a0
	xref 	eval
	bsr.l	eval
	tst.l	d2
	bne.s	.recom
	move.l	d1,d4			; la longeur
	
	
	
	
	move.l	a2,a0
	xref 	eval
	bsr.l	eval
	tst.l	d2
	bne.s	.recom
	
	
	move.l	d1,d6
	
	
	; dans d1 adresse de depart des symbols
	
	
	
	
	
	
	CENT_PROS
	
	
	move.l	#4000*8,-(sp)			; on autorise jusqu'a 4000 symboles
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,adr_label
	
	
	
	
	move.l	d4,-(sp)			; on reserve la longueur de la section symbole pour le buffer de symboles
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,buf_label
	move.l	d0,a0
	move.w	#-1,(a0)
	
	
	
	
	move.l	d4,-(sp)		
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem
	move.l	d0,hash_table

	
	
	
	
	
	
	
	
	move.l	d5,a1			; section texte
	move.l	d6,a0			; debut de la table des symbols
	move.l 	d4,d7
	
	
	move.l	#$100000,taille_fichier	; voir si plus interresant apres
		
	
	bsr	genere_table_symboles
	bsr	tri_symbols
	bsr	genere_hash_table
	
	REST_PROS

.annule
	
	
	rts
	
.erreur_mem

	move.l	#MES_ERREUR_LOAD,MESSAGE_ADR
	moveq	#0,d0
	REST_PROS
	rts
	


load::
********************************************
** charge un fichier executable et reloge **
** genere la table de symboles et la      **
** base page                              **
********************************************


	CENT_PROS
		
	move.w	#$2300,sr	
	
	move.l	#0,nb_symbols
	clr.w	CHARGE_AUTO
	
	
	*--- on commence par lire l'en tete du fichier
	
	move.w	#0,-(sp)		; un fopen
	pea	name
	GEM	Fopen
	tst.l	d0
	bmi	.erreur
	move.w	d0,d7
	
	
	
	lea	WORK_BUF,a0		; on lit 40 octects
	pea	(a0)
	move.l	#40,-(sp)
	move.w	d7,-(sp)
	GEM	Fread
	
	move	#2,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)	
	GEM	Fseek		;va … la fin
	move.l	d0,d6
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut
	
	
	; dans d6, on a la taille du programme
	
	move.l	d6,d4
	
	move.w	d7,-(sp)		; on ferme le fichier
	GEM	Fclose
	
	
	*--- on teste si c'est un executable ---*
	
	
	lea	WORK_BUF,a0		; on lit 40 octects
	cmp.w	#$601a,(a0)
	bne	.p_exec
	
	
	
	*--- on regarde s'il y a des symboles ---*
	
	
	
	
	
	move.l	a0,a1
	add.l	#$1c,a0
	add.l	2(a1),a0
	add.l	6(a1),a0
	move.l	14(a1),d7			; longeur de la section si non nulle on genere la table
	beq	.p_symbole
	
	
	
	move.l	#4000*8,-(sp)			; on autorise jusqu'a 4000 symboles
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,adr_label
	
	
	move.l	d7,-(sp)			; on reserve la longueur de la section symbole pour le buffer de symboles
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,buf_label
	move.l	d0,a0
	move.w	#-1,(a0)
	
	
	
	
	
	;lsr.l	#2,d7			; on divise par 8 pour avoir a peu pres le nb de symbols
	; on doit remulptiplier par 8    4*2 long
	
	
	move.l	d7,-(sp)		
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem
	move.l	d0,hash_table


	*--- in va generer le numero de lignes mais sans connaitre l'adresse du programme  ---*
	*--- il faudra donc la rajouter apres...                                           ---*


	lea	WORK_BUF,a0		; on lit 40 octects
	move.l	a0,a1
	move.l	#0,a0
	add.l	#$1c,a0
	add.l	2(a1),a0
	add.l	6(a1),a0
	move.l	14(a1),d5			; longeur de la section si non nulle on genere la table
	move.l	a0,d6
	move.l	d4,d3		; long du prog
	sub.l	d6,d3		; long de la fin du prog sans data et text
			
	

	move.w	#0,-(sp)		; un fopen
	pea	name
	GEM	Fopen
	tst.l	d0
	bmi	.erreur
	move.w	d0,d7
	
	
	move	#0,-(sp)
	move	d7,-(sp)
	move.l	d6,-(sp)
	GEM	Fseek		;se place au debut des symbols
	
	
	move.l	d3,-(sp)			; on reserve la longueur de la section symbole pour le buffer de symboles
	GEM	Malloc
	tst.l	d0
	beq	.erreur_mem			; pas assez de mem
	move.l	d0,s_m_temp
	
	
	
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	move.w	d7,-(sp)
	GEM	Fread
	
	move.w	d7,-(sp)		; on ferme le fichier
	GEM	Fclose
	
	
	;move.l	buf_label,a0
	move.l	s_m_temp,a0
	


	; dans a0 le debut des symbols
	bsr	numero_de_lignes
	

	move.l	s_m_temp,-(sp)
	GEM	Mfree


	
.p_symbole
	*--- on fait un pexec pour la cr‚ation de la base page ---*

	
	REST_PROS
	
		
	
	;pea	.null			; chaine env
	clr.l	-(sp)
	tst.w	CMD_L
	beq.s	.p_cmd_l		; ligne de commande
	pea	Com_line
	bra.s	.suite			
.p_cmd_l
	pea	.null
.suite	
	move.l	WORK_BUF+22,-(sp)
	;pea	0.w			; name
	move.w	#7,-(sp)		; cr‚e un base page
	GEM	Pexec
	
	CENT_PROS
	
	
	
	tst.l	d0
	bmi	.erreur

	
	move.l	d0,ADR_CHARGE		; on charge le fichier
	
	
	
	
	move.w	#0,-(sp)
	pea	name
	GEM	Fopen
	tst.l	d0
	bmi	.erreur
	
	move.l	ADR_CHARGE,a0
	add.l	#256-$1c,a0
	pea	(a0)
	move.l	#10000000,-(sp)
	move.w	d0,d7
	move.w	d0,-(sp)
	GEM	Fread
	move.l	d0,taille_fichier
	
	
	move.w	d7,-(sp)
	GEM	Fclose
	
	bsr.l	flush_k_sys
	
	
	move.l	ADR_CHARGE,fichier		; adr de la base page.
	
	bsr	genere_base_page
	

	move.l	fichier,a4
	
	add.l	#256,a4
	move.l	a4,p_c
	
	
	*--- on va restester les symbole encore une fois ---*
	
	move.l	ADR_CHARGE,a1
	add.l	#256-$1c,a1
	move.l	a1,a0
	add.l	#$1c,a0
	move.l	a0,buffer_int+r_text
	add.l	2(a1),a0
	move.l	a0,buffer_int+r_data
	add.l	6(a1),a0
	move.l	a0,buffer_int+r_bss
	move.l	14(a1),d7			; longeur de la section si non nulle on genere la table
	beq	.p_sym
	move.l	a4,a1
	
	
	bsr	genere_table_symboles
	bsr	tri_symbols
	bsr	genere_hash_table
.p_sym

	
	
	
	move.w	#$2700,sr
	
	
	
	move.l	ADR_CHARGE,a0		; la relocation
	add.l	#256-$1c,a0
	tst.w	$1a(a0)
	bne.s	.p_reloc
	bsr	reloc
.p_reloc

	*--- effacement de la section bss

	move.l	ADR_CHARGE,a1
	add.l	#256-$1c,a1
	move.l	a1,a0
	add.l	#$1c,a0
	move.l	10(a1),d0	; longeur de la section bss
	move.l	buffer_int+r_bss,a0  ;debut de la bss
	
	tst.l	d0
	beq.s	.p_bss
	lsr.l	#2,d0
.eff_bss
	clr.l	(a0)+
	subq.l	#1,d0
	bpl.s	.eff_bss
.p_bss
	




	bsr	reloge_line_nb	
	
	REST_PROS
		
.quit_all
	moveq	#-1,d0
	rts


	





	*---- une erreur de chargement ---*

.erreur
	tst.l	ADR_CHARGE
	beq.s	.p_mfree
	move.l	ADR_CHARGE,-(sp)
	GEM	Mfree
	clr.l	ADR_CHARGE
.p_mfree

	tst.l	adr_label
	beq.s	.p_mfree1
	move.l	adr_label,-(sp)
	GEM	Mfree
	clr.l	adr_label
.p_mfree1
	tst.l	buf_label
	beq.s	.p_mfree2
	move.l	buf_label,-(sp)
	GEM	Mfree
	clr.l	buf_label
.p_mfree2
	tst.l	hash_table
	beq.s	.p_mfree3
	move.l	hash_table,-(sp)
	GEM	Mfree
	clr.l	hash_table
.p_mfree3

	move.l	#MES_ERREUR_LOAD,MESSAGE_ADR
	moveq	#0,d0
	bsr.l	flush_k_sys
	move.w	#$2700,sr
	
	REST_PROS
	
	rts
	

	*---- une erreur de memoire ---*

.erreur_mem
	
	
	tst.l	ADR_CHARGE
	beq.s	.ap_mfree
	move.l	ADR_CHARGE,-(sp)
	GEM	Mfree
	clr.l	ADR_CHARGE
.ap_mfree

	tst.l	adr_label
	beq.s	.ap_mfree1
	move.l	adr_label,-(sp)
	GEM	Mfree
	clr.l	adr_label
.ap_mfree1
	tst.l	buf_label
	beq.s	.ap_mfree2
	move.l	buf_label,-(sp)
	GEM	Mfree
	clr.l	buf_label
.ap_mfree2
	tst.l	hash_table
	beq.s	.ap_mfree3
	move.l	hash_table,-(sp)
	GEM	Mfree
	clr.l	hash_table
.ap_mfree3

	move.l	#MES_ERREUR_LOAD,MESSAGE_ADR
	moveq	#0,d0
	bsr.l	flush_k_sys
	move.w	#$2700,sr
	REST_PROS
	rts
	
	
	
	*--- le fichier n'est pas executable ---*
	
	
.p_exec
	move.l	#MES_PAS_EXEC,MESSAGE_ADR
	moveq	#0,d0
	move.w	#$2700,sr
	REST_PROS
	rts
	
.null
	dc.w	0
	



;------------------------------------------------------------------------------
;reloge_line_nb
; arrive ici on a l'adresse de la base page du prog 
; on va donc reloger les adresses des no de ligne 
; en ajoutant adr_charge+256 … chaque
;------------------------------------------------------------------------------
reloge_line_nb
	;xref	M40_SOURCE_TABLE
	lea	M40_SOURCE_TABLE,a0
	
	move	M40_NB_SOURCES,d6
	subq	#1,d6
	bmi.s	.FIN			

.LOOP_UN_SOURCE
	
	
	move.l	ptr_conv(a0),a1
	move	nb_ligne(a0),d7
	beq	.FIN
	;subq	#1,d7
	
	
	move.l	ADR_CHARGE,d0
	add.l	#256,d0	

.d	
	tst.l	(a1)		; on cherche le premier nb de ligne non nul
	bne.s	.ok_n
	move.l	#-1,(a1)+
	subq	#1,d7
	bra.s	.d
.ok_n
	tst.l	-(a1)		; on recupere donc le premier nb de ligne non nul
	move.l	d0,(a1)+


.RELOGE
	cmp.l	#-1,(a1)
	;tst.l	(a1)
	bne.s	.p_n		; si nulle, on copie l'ancienne adr
	move.l	#-1,(a1)+
	bra.s	.s
.p_n				; nouvelle valeur a prendre
	add.l	d0,(a1)+
.s
	dbra	d7,.RELOGE

	add	#Size_src,a0

	dbra	d6,.LOOP_UN_SOURCE

.FIN
	rts



reloc
************************************
** routine qui va reloger le prog **
************************************
	include 40\main.inc\reloc.s



genere_base_page
*******************************************
** routine de generation de la base page **
*******************************************
	
	move.l	ADR_CHARGE,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	#256-$1c,a2		; pointe sur text -$1c
	add.l	#256,a1			; pointe sur text
	
	addq.l	#8,a0
	
	;move.l	a0,(a0)+
	;move.l	$42e,(a0)+
	
	move.l	a1,(a0)+		; text
	move.l	2(a2),(a0)+		; long text
	add.l	2(a2),a1
	move.l	a1,(a0)+		; data
	move.l	6(a2),(a0)+		; long data
	add.l	6(a2),a1
	move.l	a1,(a0)+		;bss
	move.l	10(a2),(a0)+		; long bss
	
	;move.l	#buf_dta,(a0)+		; pf dta
	;move.l	#0,(a0)+	; pt sur parent base base

	rts
	
	
numero_de_lignes
*********************************************************
** Routine qui va generer le table de numero de lignes **
*********************************************************
	
	; dans a0, on la taille du fichier
	
	clr.w	M40_NB_SOURCES
	
	movem.l	d0-a6,-(sp)
	
	moveq	#0,d6
	
	
	;move.l	taille_fichier,d0
	move.l	a0,d0
	;add.l	ADR_CHARGE,d0
	add.l	d3,d0
	move.l	d0,a4			; c'est la fin du fichier
	
	
.cherche_l
	cmp.l	#$3f1,(a0)		; on recherche un line puis 0003 pour 
	beq.s	.p_etre			; voir si on a ubn num de lignes
	cmp.l	a0,d0
	beq	.fin_s
	addq.l	#1,a0
	bra.s	.cherche_l
.p_etre
	cmp.l	#'LINE',12(a0)
	beq.s	.ok_line
	cmp.l	a0,d0
	beq	.fin_s
	addq.l	#1,a0
	bra.s	.cherche_l
.ok_line
	
		
	add.l	#16,a0			; on pointe sur le nom du fichier
	move.l	(a0)+,d0		; trouve le nombre de long pour le nom
	lea	WORK_BUF,a1
	subq.l	#1,d0
.cop_f	move.l	(a0)+,(a1)+
	dbra	d0,.cop_f
	
	move.l	a0,a1			; dans a1, on a le debut des num de lignes
	
	; a0 pointe sur la premiere ligne
	; d0 pointe sur la fin du fichier
	
	
	lea	WORK_BUF,a0
	

	;xref	M40_load_source		; on charge le source
	bsr.l	M40_load_source

	*-----------------------*
	* r‚cupere le pointeur sur la table des lignes
	*-----------------------*
	
	
	
	move	M40_NB_SOURCES,d0
	subq	#1,d0
	bpl.s	.OK0
	illegal				; je met un illegal pour vouir si ca plante
					; on l'enleve des que c'est d‚bugu‚
.OK0
	mulu	#Size_src,d0

	;xref	M40_SOURCE_TABLE
	lea	(M40_SOURCE_TABLE,d0.l),a0
	move.l	ptr_conv(a0),a5
	move	nb_ligne(a0),d7
	subq	#1,d7
	
	*-----------------------*
	* aux inits toute la table vaut -1.l
	*-----------------------*
.CLR	move.l	#-1,(a5)+
	dbra	d7,.CLR		
	
	move.l	ptr_conv(a0),a5
	move	nb_ligne(a0),d7
	ext.l	d7
	
	
	; dans a1 on a e format nb ligne / adr du prog
	
	
.gen_l	
	cmp.l	#$3f1,(a1)		; on regarde si on a un nouveau source
	bne.s	.p_hunk
	cmp.l	#'LINE',12(a1)
	bne.s	.p_hunk

	nop				; ici on doit charger un deuxieme source...
	move.l	a1,a0
	;illegal
	bra.s	.ok_line		; on saute pour le chargement du second source
	illegal
.p_hunk
	
	;illegal
	
	move.l	(a1)+,d0		; num de la ligne
	move.l	(a1)+,d1		; dep / deb du programme
	
	cmp.l	d7,d0
	bgt	.SKIP			; si le no de ligne est trop grand, on ne le fait pas

	
	move.l	d1,(a5,d0.l*4)
.SKIP	
	
	
	cmp.l	a1,a4
	bgt.s	.gen_l
	
	
	
.fin_s	
	
	movem.l	(sp)+,d0-a6
	rts
	
	
	
genere_table_symboles	
*****************************************
** marche sans le <--- line debug ---> ** 
*****************************************
** generation de la table des symboles **
** a0 debut des symbols                **
** a1 debut de la section text         **
** d7 longueur de la section           **
*****************************************
	movem.l	d0-a6,-(sp)
					; on commence par recuperer le nom au max 22 car
	moveq	#0,d5			;nombre de symboles
	move.l	d7,d0
	
	
	
	move.l	adr_label,a4
	move.l	buf_label,a5
	
	
	move.l	nb_symbols,d4
	lsl.l	#3,d4
	add.l	d4,a4
	
	
.fin_buf				; cherche la fin de la table des symbols
	cmp.w	#-1,(a5)
	beq.s	.trouve
	addq	#1,a5
	bra.s	.fin_buf
.trouve
		
	;subq.w	#2,a5			; on pointe sur la fin du buffer
	
	
	
	
	move.l	a0,a3
	add.l	d0,a3
.p	lea	buf_nom,a2
	
	
	addq.l	#1,d5
	
	clr.b	d7			; pas de nom long
	clr.b	d6			; deplacement sur 16bit
	
	
	
	move.w	8(a0),d0		; recupŠre le type
	
	
	cmp.w	#$0280,d0
	beq	.invalide
	cmp.w	#$02c0,d0
	beq	.invalide
	cmp.w	#$0000,d0
	beq	.invalide
	
	
	
	
	cmp.b	#$48,d0
	beq.s	.nom_long
	
	
	and.w	#$f00,d0
	lsr.w	#8,d0
	
	cmp.w	#1,d0			; a t on un equ
	bne.s	.p_16_b
	st	d6
.p_16_b
	cmp.w	#4,d0
	bne.s	.p_16_b1
	st	d6
.p_16_b1
	cmp.w	#2,d0
	bne.s	.p_16_b2
	st	d6
.p_16_b2
	
	
	
	
	
	
	move.l	(a0),(a2)+
	move.l	4(a0),(a2)+
	bra.s	.p_n_l
.nom_long
	
	move.l	(a0),(a2)+
	move.l	4(a0),(a2)+
	
	
	move.l	14(a0),(a2)+
	move.l	18(a0),(a2)+
	move.l	22(a0),(a2)+
	move.w	26(a0),(a2)+		; ici, on a le nom en entier
	st	d7
.p_n_l
	clr.l	d0
	tst.b	d6
	beq.s	.d
	move.l	10(a0),d0		; ici, on a le decalag/debut en long
	bra.s	.o
.d
	move.w	12(a0),d0		; en cours
.o
	clr.b	(a2)
	
	
	move.l	a1,a2
	add.l	d0,a2			; adresse de symbol



	tst.b	d7
	beq.s	.p_l		
	add.l	#14,a0			; on a un long nom
					; on corrige le pointeur
.p_l
	add.l	#14,a0
	move.l	a2,(a4)+
	move.l	a5,(a4)+
	lea	buf_nom,a2
.cc	move.b	(a2)+,(a5)+
	tst.b	(a2)
	bne.s	.cc
	clr.b	(a5)+
	cmp.l	a3,a0
	blt	.p
.fin	add.l	d5,nb_symbols		; ajoute le nombre de symbols a ceux deja existants
					; pour permettre le chargement de plusieurs tables
	

	clr.l	(a4)+
	clr.l	(a4)+
	
	move.w	#-1,(a5)+
	
	
	movem.l	(sp)+,d0-a6
	rts


.invalide
	add.l	#14,a0
	cmp.l	a3,a0
	blt	.p
	bra.s	.fin
	

genere_hash_table
*********************************
** Generation de la hash table **
** pour la recherche rapide    **
*********************************
	movem.l	d0-a6,-(sp)
	
	
	
	
	*--- on cherche la fin de la table ---*
	
	move.l	adr_label,a6
.ch_fin	tst.l	(a6)+
	tst.l	(a6)+
	bne.s	.ch_fin
	
	
	sub.l	#16,a6
	
	
	
	moveq	#0,d0
	moveq	#0,d2
	;move.l	buffer_int+r_text,d0
	;add.l	buffer_int+r_data,d0
	;add.l	buffer_int+r_bss,d0
	
	move.l	taille_fichier,d0
	
	
	*--- dans d0 on a la taille du prog ---*
	
	move.l	nb_symbols,d1
	
	divu.l	d1,d2:d0
	mulu.l	#10,d0

	;lsl.l	#3,d0		; on mulpt par 8 car on a 2 long a sauter

	lsr.l	#3,d0		; n doit avoir un * de 8
	lsl.l	#3,d0


	*--- dans d0 on a le pas ---*
	
	
	move.l	adr_label,a1
	move.l	hash_table,a0
	clr.l	(a0)+
	clr.l	(a0)+		; on commence par mettre 2 pointeurs nuls
	
.gen_hash
	move.l	(a1),(a0)+
	move.l	a1,(a0)+
	add.l	d0,a1
	
	cmp.l	a1,a6		; on regarde si on est arrive au bout de la table
	bge.s	.gen_hash
	
	clr.l	(a0)+
	clr.l	(a0)+
	

	movem.l	(sp)+,d0-a6
	rts
	
	
	
tri_symbols
***********************************************
** Tri la liste de label par ordre croissant **
***********************************************
	movem.l	d0-a6,-(sp)
	
	xref	petit_message	
	move.l	#MES_TRI,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE			; on attends...
	
	
	move.l	nb_symbols,d6
	subq.l	#2,d6
	tst.l	d6
	bpl.s	.zr
	moveq	#0,d6
.zr
	move.l	d6,d5
	
	move.l	nb_symbols,d7
	cmp.l	#1,d7
	beq	.exit
	
	subq.l	#2,d7
	tst.l	d7
	bpl.s	.loop2
	moveq	#0,d7
.loop2
	move.l	adr_label,a0
.loop1
	move.l	(a0),d0
	cmp.l	8(a0),d0
	ble.s	.ok
	
	*--- sinon on permutte ---*
	move.l	8(a0),d1
	move.l	(a0),8(a0)
	move.l	d1,(a0)
	move.l	12(a0),d1
	move.l	4(a0),12(a0)
	move.l	d1,4(a0)
.ok
	addq.l	#8,a0
	dbra	d6,.loop1
	
	subq.l	#1,d5
	tst.l	d5
	bpl.s	.zr1
	moveq	#0,d5
.zr1
	move.l	d5,d6
	
	dbra	d7,.loop2


.exit
	movem.l	(sp)+,d0-a6
	rts


;*****************************************
;** LE CHARGEMENT DU SOURCE S'IL EST LA **
;*****************************************


;------------------------------------------------------------------------------
; la meme chose pour le 040
;------------------------------------------------------------------------------
M40_load_source::



	movem.l	d0-a6,-(sp)
	
	CENT_PROS
	
	move	M40_NB_SOURCES,d0
	cmp	#max_src,d0
	bge	.fin
	
	
	
	
	move.l	a0,-(sp)
	
	mulu	#Size_src,d0
	lea	(M40_SOURCE_TABLE,d0.l),a1

	move	#0,-(sp)
	pea	(a0)
	GEM	Fopen
	move.l	d0,d7
	bmi	.ERREUR
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
	move.l	d6,-(sp)
	GEM	Malloc		;Malloc(size)
	tst.l	d0
	beq	.ERREUR	
	move.l	d0,a6

	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
		
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut

	move.l	a6,a0
	move.l	d6,d0
						
	*--------------------*
	* compte le nb de lignes
	*--------------------*

	
	move.l	d6,d5
	moveq	#0,d0
.COMPTE
	move.b	(a0)+,d1
	cmp.b	#$d,d1
	bne.s	.NEXT
.CR	move.b	(a0)+,d1
	cmp.b	#$a,d1
	beq.s	.INC
	subq	#1,a0	
.INC	addq.l	#1,d0
	
.NEXT	subq.l	#1,d5
	bne.s	.COMPTE

	move.l	d0,d5
	addq.l	#2,d5		;place pour le zero et la derniere ligne
	
	lsl.l	#2,d5		;(nb lignes+1)*4
	add.l	d5,d6		;taille n‚c‚ssaire
	add.l	d5,d6		;pour les conversions no_ligne -> adr physique
	addq.l	#2,d6		;+2 pour mettre 0 … la fin	
	


	*--------------------*
	* libere l'ancien buffer
	* malloc un nouveau en tenant compte
	* de la taille des lignes
	*--------------------*
	move.l	a6,-(sp)
	GEM	Mfree
	
		
	add.l	#256,d6
	move.l	d6,-(sp)
	GEM	Malloc
	tst.l	d0
	bmi	.ERREUR
	move.l	d0,ligne_ptr(a1)
	add.l	d5,d0
	move.l	d0,ptr_conv(a1)
	add.l	d5,d0
	move.l	d0,ptr_name(a1)
	add.l	#256,d0			;place pour le nom de fichier
	move.l	d0,ptr(a1)
	
			
	
	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut

	move.l	ptr(a1),-(sp)
	move.l	#-1,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
		
	move	d7,-(sp)
	GEM	Fclose
	
	move.l	a1,a2
	move.l	ptr(a2),a0
	move.l	ligne_ptr(a2),a1
	clr	-2(a1,d6.l)	;symbol de fin de source
	xref	INIT_TAB_LIGNE
	bsr.l	INIT_TAB_LIGNE
		
	addq	#1,M40_NB_SOURCES
			
	move.l	(sp),a0
	move.l	ptr_name(a2),a1

.COP	move.b	(a0)+,(a1)+
	bne.s	.COP
	
	subq	#1,a1
	move.l	#' lin',(a1)+
	move.l	#'e: 0',(a1)+
	clr.b	(a1)+


.ERREUR	
	addq	#4,sp		;on s'en tape du nom de fichier
	moveq	#-1,d0
.fin	movem.l	(sp)+,d0-a6
	
	
	REST_PROS
	
	rts

	BSS
	

s_m_temp	ds.l	1	; adresse du malloc temporaire pour le chargeemnt du line source

M40_NB_SOURCES::	ds	1
M40_SOURCE_TABLE::	ds.b	Size_src*max_src
;------------------------------------------------------------------------------
	TEXT
