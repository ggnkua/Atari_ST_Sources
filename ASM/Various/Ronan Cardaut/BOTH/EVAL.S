	
	xref	READ_FLOAT
	
	
	include	d:\CENTINEL\BOTH\DEFINE.S
	output	d:\centinel\both\eval.o
	incdir	d:\centinel\40
	include	macros.s

	xref	pile_test,s_a7,ERR_MEM,ADR_VBR,TRACE,COL_NOR,COL_ERR_L,ATTRIBUTE
**************************************
** Nouvelle version de l'‚valuateur **
**************************************


	MC68881

**************************
** d‚finition des types **
**************************


*----- Les longeurs possibles -----*

	rsreset
	rs.b	1
byte	rs.b	1
word	rs.b	1
long	rs.b	1
double	rs.b	1
all	rs.b	1
dword	rs.b	1	; word dsp
dlong	rs.b	1	; double word dsp
dextend rs.b	1	; dsp a ou b
	rs.b	1	; on saute le 9
dab	rs.b	1	; dsp reg ab
dba	rs.b	1	; dsp reg ba

dspx	rs.b	1	; memoire x dsp
dspy	rs.b	1	; memoire y dsp
dspp	rs.b	1	; memoire p dsp
dspl	rs.b	1	; memoire xy dsp

float	rs.b	1	; le flottant

*----- Les type d'‚l‚ments de la liste -----*

	rsreset
	rs.b	1
reg	rs.b	1		; registre
nb	rs.b	1		; nombre
op	rs.b	1		; op‚rateur
label	rs.b	1		; label
tout	rs.b	1		; tout type possible
rien	rs.b	1		; aucun type possible
dernier	rs.b	1
par_o	rs.b	1		; paranthŠses ouvertes
par_f	rs.b	1		; paranthŠses ferm‚es
acc_o	rs.b	1		; accolades ouvertes
acc_f	rs.b	1		; accolades ferm‚es
op_mem	rs.b	1		; operateur memoire pour les ecritue dedans
	
*----- Les types de registres -----*

	rsreset
	rs.b	1
x68	rs.b	1
dsp	rs.b	1
int	rs.b	1		; c'est le type interne
undef	rs.b	1		; c'est le type ambigu
constante	rs.b	1	; pour les constantes

*----- Les deplacement dans la table pour les registres ambigu -----*

	rsreset
dep_pc	rs.b	1
dep_sr	rs.b	1
dep_a0	rs.b	1
dep_a1	rs.b	1
dep_a2	rs.b	1


*** rmq le type label se ramŠne au type nombre apres convertion ***



eval::
******************************************
** la proc‚dure principale              **
******************************************
** Entr‚e :                             **
**    - a0 contient la chaine … ‚valuer **
** Sorite :                             **
**    - d0.d1 contient le r‚sultat      **
**    - d2 <>  0 : erreur               **
**      d2  = 0 : ok evaluation         **
******************************************
 	xref	adr_label,buf_label,nb_symbols,buffer_r,DSP_REG,buffer_int


	move.w	#0,const
	move.l	#list,liste_const
	clr.w	const_e	

	movem.l	d3-a6,-(sp)
	

	*** on va copier la pointeur de pile actif dans sp ***
	
	move.l	buffer_r+r_sr,d0
	btst	#5+8,d0
	beq.s	.user
	move.l	buffer_r+r_ssp,buffer_r+r_a7
	bra.s	.super
.user
	move.l	buffer_r+r_usp,buffer_r+r_a7
.super
	move.l	buffer_r+r_a7,sp_save


	move.b	#0,erreur			; pas d'erreur
	
	move.l	#buffer_r,adr_reg_68x		; copie de la base de registres
	move.l	#DSP_REG,adr_reg_dsp
	move.l	#buffer_int,adr_reg_int

	move.l	#yopiii,adr_cst
	
*---- tester la chaine vide ----*
	
	tst.b	(a0)
	bne.s	.p_chaine_vide
	move.b	#1,erreur
	bra	.exit
.p_chaine_vide
	
	bsr	prepare_chaine			; d‚composition
	tst.b	erreur
	bne	.exit
	
	lea	point_chaine,a0			; teste de la coh‚rence
	bsr	teste_coherence			; de la chaine form‚e
	tst.b	erreur
	bne.s	.exit
	
	
	lea	point_chaine,a0			; ‚valuation de la chaine
	bsr	evalue_chaine
	tst.b	erreur
	bne.s	.exit
	
	
*---- dans d0.d1 on a le r‚sultat ----*

	lea	buffer_int,a6
	move.l	d0,r_e(a6)
	move.l	d1,r_e+4(a6)


	;*---- ici on copie la pile la pile sp dans le contenu voulu -----*

	move.l	buffer_r+r_a7,d4		; le pointeur sp n'a pas chang‚
	cmp.l	sp_save,d4
	beq.s	.p_ch


	move.l	buffer_r+r_sr,d4
	btst	#5+8,d4
	beq.s	.user1
	move.l	buffer_r+r_a7,buffer_r+r_ssp
	bra.s	.super1
.user1
	move.l	buffer_r+r_a7,buffer_r+r_usp
.super1
	bra.s	.exit
.p_ch
	move.l	buffer_r+r_sr,d4
	btst	#5+8,d4
	beq.s	.user12
	move.l	buffer_r+r_ssp,buffer_r+r_a7
	bra.s	.super12
.user12
	move.l	buffer_r+r_usp,buffer_r+r_a7
.super12
	
	
.exit
	clr.l	d2
	move.b	erreur,d2


	
	
	movem.l	(sp)+,d3-a6
	rts
	
evalue_chaine
****************************************
** routine qui va ‚valuer la chaine   **
**                                    **
** Entr‚e :                           **
**   - a0 pointeur de chaine          **
** sortie :                           **
**   - resultat dans d0.d1            **
****************************************
	movem.l	d2-a6,-(sp)
	move.l	a0,a5
.debut
	
	move.l	a0,a6
.essais
	move.l	(a0)+,a1
	cmp.b	#dernier,(a1)		; fin de chaine
	beq	.exit		
	cmp.b	#par_f,(a1)
	beq	.exit
	cmp.b	#acc_f,(a1)
	beq	.exit
*--- on peut avoir un op‚rateur pour commencer ---*
	
	cmp.b	#par_o,(a1)
	bne.s	.p_par_o
	bsr	adr_parantheses
	move.l	a6,a0			; ---- EN TEST ----
	bra	.debut
.p_par_o
	cmp.b	#acc_o,(a1)
	bne.s	.p_acc_o
	bsr	adr_accolades
	move.l	a6,a0			; ---- EN TEST ----
	bra	.debut
.p_acc_o
	
	cmp.b	#op,(a1)		; teste si operateur
	bne.s	.p_operateur
	move.b	1(a1),d7		; taille ?
	move.l	3(a1),a1
	jsr	(a1)
	bra	.debut
.p_operateur

*--- recherche de la priorit‚ de l'op‚rateur associ‚ ---*
	clr.l	d0
	move.l	a0,a2
.cherche_op
	move.l	(a2)+,a1
	cmp.b	#dernier,(a1)
	beq.s	.exit
	cmp.b	#par_f,(a1)
	beq.s	.exit
	cmp.b	#acc_f,(a1)
	beq.s	.exit
	cmp.b	#op,(a1)
	bne.s	.cherche_op
	move.b	2(a1),d0		; priorite dans d0
	
	
.cherche_op_suiv
	clr.l	d1
	move.l	(a2)+,a3
	cmp.b	#dernier,(a3)
	beq.s	.term_op
	cmp.b	#par_f,(a3)
	beq.s	.term_op
	cmp.b	#acc_f,(a1)
	beq.s	.exit
	cmp.b	#op,(a3)
	beq.s	.op_f
	cmp.b	#acc_o,(a3)
	bne.s	.acc_o
	move.b	#10,d1			; tres haute priorite
	bra.s	.saute
.acc_o	cmp.b	#par_o,(a3)
	bne.s	.cherche_op_suiv
	move.b	#10,d1			; tres haute priorite
	bra.s	.saute
.op_f	
	move.b	2(a3),d1		; priorite dans d1
	bra.s	.saute
.term_op
	clr.l	d1
.saute
	cmp.b	d0,d1
	ble.s	.p_rappelle
	addq.l	#4,a0
	
	;move.l	a6,a0
	bra	.essais
	
	;bsr	evalue_chaine
	
	
	bra.s	.suite_o
.p_rappelle
	
	
	move.b	1(a1),d7		; taille ?
	move.l	3(a1),a1
	jsr	(a1)
.suite_o
	
	move.l	a6,a0
	bra	.debut
	
.exit
*--- on va ‚valuer le seul ‚l‚ment sui va rester dans la liste ---*

	move.l	(a5),a1
	move.l	(a5),a2
	bsr	convert_type		; recupŠre le r‚sultat dans d0.d1
	



	movem.l	(sp)+,d2-a6
	rts

	
prepare_chaine
*************************************************************
** routine qui va identifer les ‚l‚ments de la chaine      **
** … ‚valuer et qui va construire une liste les contenants **
**   - la chaine se trouve dans a0                         **
**   - en retour, on a la liste dans liste_chaine          **
**                et celle des pointeurs dans point_chaine **
*************************************************************

	movem.l	d0-a6,-(sp)
	
	*--- cette routine va mettre un 0 devant tout les ! ---*
	*--- dans le but de feinter l'evaluateur            ---*
	
	lea	temp_chaine,a1
	
	
	move.b	(a0)+,d0
	cmp.b	#'-',d0
	bne.s	.p_m_p
	move.w	#'0-',(a1)+		; remplace un -xx par un !xx
	bra.s	.olp
.p_m_p
	subq.l	#1,a0			; on recale au debut de la cahine
	
	
	
	
.olp	cmp.w	#'=-',(a0)
	bne.s	.ps_d
	move.w	#'=0',(a1)+
	addq	#1,a0
.ps_d
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq.s	.exit
	cmp.b	#'!',d0
	bne.s	.norm
	move.b	#'0',(a1)+
.norm
	move.b	d0,(a1)+
	bra.s	.olp
	
.exit
	clr.b	(a1)
	*--- fin de la routine ---*

	lea	temp_chaine,a0
	
	lea	liste_chaine,a1
	lea	point_chaine,a2
	
	bsr	verifie_paranthese	; va v‚rifier s'il y a le nb de paranthŠses qu'il faut
	tst.b	erreur
	bne	.xit


	lea	temp_chaine,a0
	bsr	convert_mem_dsp
	
	
	lea	temp_chaine,a0
	
	lea	liste_chaine,a1
	lea	point_chaine,a2

	
.decomposition
	tst.b	(a0)			; on arrive au bout
	beq	.fin_convertion
	move.b	(a0),d1
	cmp.b	#'(',d1
	bne.s	.p_par_o
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	beq.s	.ao
	bra	.erreur
.ao
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#par_o,(a1)+		; copie du type
	move.b	#long,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.decomposition
.p_par_o
	cmp.b	#')',d1
	bne.s	.p_par_f
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	bne.s	.ao1
	move.l	#long,d0		; par defaut c'est un long
	bra.s	.aoo1			; on saute les .l .b .w
.ao1
	addq.l	#2,a0
.aoo1
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#par_f,(a1)+		; copie du type
	move.b	d0,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.decomposition
.p_par_f
	cmp.b	#'{',d1
	bne.s	.p_acc_f
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	beq.s	.ao2
	bra	.erreur			; on a un (.l (.w ou (.b erreur
.ao2
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#acc_o,(a1)+		; copie du type
	move.b	#all,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.decomposition
.p_acc_f
	cmp.b	#'}',d1
	bne.s	.p_acc_o
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	bne.s	.ao3
	move.l	#long,d0		; par defaut c'est un long
	bra.s	.aoo3
.ao3
	addq.l	#2,a0
.aoo3
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#acc_f,(a1)+		; copie du type
	move.b	d0,(a1)+		; copie de la taille
	move.l	#0,(a1)+
	move.l	#0,(a1)+		; 2 long pour les 48 bit dsp	
	addq.l	#1,a0
	bra	.decomposition
.p_acc_o
	
	bsr	get_operateur
	tst.b	erreur
	bne	.erreur


; dans a3 l'adresse de l'op‚rateur dans la chaine
; dans a4 l'adresse de la routine … executer
; dans d0 sa longeur si d0=0 pas d'op‚rateur
; dans d1 sa priorit‚
; dans d2 sa longueur ;b .l .w 
	
	
	tst.l	d0
	beq	.p_operateur		; s'il n'y a pas d'operateur
	
	cmp.l	a3,a0	
	bne.s	.quelque_chose_avant
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#op,(a1)+		; copie du type
	move.b	d2,(a1)+		; copie de la taille
	move.b	d1,(a1)+		; priorit‚
	move.l	a4,(a1)+		; l'adresse de la routine … ‚x‚cuter	
	add.l	d0,a0			; on ajoute la taille de l'op‚rateur au pointeur de chaine
	bra	.decomposition

.quelque_chose_avant


*---- correction de a3 pour le cas o— il y des paranthŠses ----*


*------------------ pas a toucher aux  .l .b .w ...  ---------*

	;illegal
.teste
	lea	-2(a3),a6
	bsr	check_size
	tst.b	d0
	beq.s	.lm
	subq.l	#2,a3
	
	
	cmp.b	#'(',-1(a3)			; tester si a3 est valide
	bne.s	.nor
	subq.l	#1,a3
	bra.s	.teste
.nor
	cmp.b	#')',-1(a3)
	bne.s	.nor1
	subq.l	#1,a3
	bra.s	.teste
.nor1
	cmp.b	#'{',-1(a3)			; tester si a3 est valide
	bne.s	.nor2
	subq.l	#1,a3
	bra.s	.teste
.nor2
	cmp.b	#'}',-1(a3)
	bne.s	.nor3
	subq.l	#1,a3
	bra.s	.teste
.nor3
	addq.l	#2,a3
	bra.s	.km


.lm
	
	
	cmp.b	#'(',-1(a3)			; tester si a3 est valide
	bne.s	.anor
	subq.l	#1,a3
	bra.s	.teste
.anor
	cmp.b	#')',-1(a3)
	bne.s	.anor1
	subq.l	#1,a3
	bra.s	.teste
.anor1
	cmp.b	#'{',-1(a3)			; tester si a3 est valide
	bne.s	.anor2
	subq.l	#1,a3
	bra.s	.teste
.anor2
	cmp.b	#'}',-1(a3)
	bne.s	.anor3
	subq.l	#1,a3
	bra.s	.teste
.anor3

.km


; dans a0 on a le pointeur de chaine
; dans a3 on a le pointeur sur l'op‚rateur suivant
	bsr	teste_registres	
; dans a4 on a 0 si pas de registre
;         ou l'adresse des choses … copier, sur un longueur de 3
; a0 est incrementer correctement


	tst.l	a4
	beq.s	.p_registre
	
	move.l	a1,(a2)+
	move.b	#reg,(a1)+		; type registre
	move.b	d0,(a1)+		; longeur
	move.w	(a4),(a1)+		; le deplacement dans la liste
	move.b	2(a4),(a1)+		; le type 68x ou dsp
	bsr	insere_operateur
	tst.b	erreur
	bne	.erreur
	bra	.decomposition
	
.p_registre
; dans a0 on a le pointeur de chaine
; dans a3 on a le pointeur sur l'op‚rateur suivant
	bsr	teste_nombres
; dans	d0.d1 le nombre sur 64 byte troncable delon la taille
; dans 	d2 la taille si d2=0 pas de nombre
; a0 sera incr‚menter correctement
	
	
	tst.l	d2
	beq.s	.p_nombre

		
	move.l	a1,(a2)+
	move.b	#nb,(a1)+
	move.b	d2,(a1)+
	
	cmp.b	#byte,d2		; on compare la taille et on stocke
	bne.s	.p_byte			; le nombre en cons‚quence
	move.b	d1,(a1)+
	bra.s	.fin_nombre
.p_byte
	cmp.b	#word,d2
	bne.s	.p_word
	move.w	d1,(a1)+
	bra.s	.fin_nombre
.p_word
	cmp.b	#long,d2
	bne.s	.p_long
	move.l	d1,(a1)+
	bra.s	.fin_nombre
.p_long
	cmp.b	#double,d2
	bne.s	.p_double
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	bra.s	.fin_nombre
.p_double
	cmp.b	#float,d2
	bne.s	.p_float
	clr.l	(a1)+			; plus tard, pointeur
	fmove.x	fp0,TEMP_FLOAT
	bra.s	.fin_nombre
.p_float


	bra	.erreur
.fin_nombre
	bsr	insere_operateur
	tst.b	erreur
	bne	.erreur
	bra	.decomposition

.p_nombre	
; dans a0 on a le pointeur de chaine
; dans a3 on a le pointeur sur l'op‚rateur suivant
	bsr	teste_labels
; dans a4 l'adresse de label
; si a4=0 pas de label
	
	tst.l	a4
	beq.s	.p_label
	
	
	
	
	
	
	move.l	a1,(a2)+
	move.b	#label,(a1)+		; type
	move.b	d0,(a1)+		; taille
	move.l	a4,(a1)+		; adresse du label
	bsr	insere_operateur
	tst.b	erreur
	bne	.erreur
	bra	.decomposition
.p_label
	move.b	#1,erreur
	
.fin_convertion
	move.l	a1,(a2)+		; pointeur sur la fin de la liste
	move.b	#dernier,(a1)		; on insere le type dernier
	
	
	clr.l	(a2)+			; on met le pointeur … z‚ro
	
	;bsr	teste_validite_chaine
* on va tester si la chaine obtenue est valide pour la grammaire **
* mise en place                                                  **
	
.xit
	
	movem.l	(sp)+,d0-a6
	rts

.erreur
	move.b	#1,erreur
	bra.s	.xit


.p_operateur



	move.l	a0,a3
.o	tst.b	(a3)+		; on cherche la fin de la chaine
	bne.s	.o
	subq.l	#2,a3
	move.l	a3,a6
	subq.l	#1,a6
	bsr	check_size
	tst.b	d0
	beq.s	.lo
	subq.l	#2,a3		; on replace la chaine au bon endroit




.ol	move.b	(a3),d0		; on degomme le derniere paranthŠses
	
	;cmp.b	#'(',d0
	;bne.s	.p_r
	;subq.l	#3,a3
	;bra.s	.ol
.p_r
	cmp.b	#')',d0
	bne.s	.p_r1
	subq.l	#3,a3
	bra.s	.ol
.p_r1
	;cmp.b	#'{',d0
	;bne.s	.p_r2
	;subq.l	#3,a3
	;bra.s	.ol
.p_r2
	cmp.b	#'}',d0
	bne.s	.p_r3
	subq.l	#3,a3
	bra.s	.ol
.p_r3

	addq.l	#3,a3			; si pas de parranthŠse on corrige
	bra	.quelque_chose_avant
	


.lo
	

.aol	move.b	(a3),d0		; on degomme le derniere paranthŠses
	
	cmp.b	#'(',d0
	bne.s	.ap_r
	subq.l	#1,a3
	bra.s	.aol
.ap_r
	cmp.b	#')',d0
	bne.s	.ap_r1
	subq.l	#1,a3
	bra.s	.aol
.ap_r1
	cmp.b	#'{',d0
	bne.s	.ap_r2
	subq.l	#1,a3
	bra.s	.aol
.ap_r2
	cmp.b	#'}',d0
	bne.s	.ap_r3
	subq.l	#1,a3
	bra.s	.aol
.ap_r3
	addq.l	#1,a3
	bra	.quelque_chose_avant
	
	
	bra	.erreur


insere_operateur
*************************************************************
** routine qui va insere l'operateur courant dans la liste **
*************************************************************
	
	
.again
	
	
	move.b	(a0),d1
	cmp.b	#'(',d1
	bne.s	.p_par_o
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	beq.s	.o
	bra	.erreur
.o
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#par_o,(a1)+		; copie du type
	move.b	#long,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.again
.p_par_o
	cmp.b	#')',d1
	bne.s	.p_par_f
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	bne.s	.o1
	move.l	#long,d0
	bra.s	.oo1
.o1	
	addq.l	#2,a0
.oo1
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#par_f,(a1)+		; copie du type
	move.b	d0,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.again
.p_par_f
	cmp.b	#'{',d1
	bne.s	.p_acc_o
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	beq.s	.o2
	bra	.erreur
.o2
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#acc_o,(a1)+		; copie du type
	move.b	#long,(a1)+		; copie de la taille
	addq.l	#1,a0
	bra.s	.again
.p_acc_o
	cmp.b	#'}',d1
	bne.s	.p_acc_f
	
	move.l	a0,a6
	addq.l	#1,a6
	bsr	check_size
	tst.b	d0
	bne.s	.o3
	move.l	#long,d0
	bra.s	.oo3
.o3	addq.l	#2,a0
.oo3
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#acc_f,(a1)+		; copie du type
	move.b	d0,(a1)+		; copie de la taille
	move.l	#0,(a1)+
	move.l	#0,(a1)+		; 2 long pour les 48 bit dsp	
	addq.l	#1,a0
	bra	.again
.p_acc_f
	
	bsr	get_operateur
	tst.b	erreur
	bne	.erreur
	tst.l	d0	
	beq.s	.p_op
	
; dans a3 l'adresse de l'op‚rateur
; dans a4 l'adresse de la routine … executer
; dans d0 sa longeur si d0=0 pas d'op‚rateur
; dans d2 da longeur .b .l .w	
	move.l	a1,(a2)+		; copie du pointeur
	move.b	#op,(a1)+		; copie du type
	move.b	d2,(a1)+		; copie de la taille
	move.b	d1,(a1)+
	move.l	a4,(a1)+		; l'adresse de la routine … ‚x‚cuter	
	clr.b	(a1)+			; fini la chaine
	add.l	d0,a0			; on ajoute la taille de l'op‚rateur au pointeur de chaine
.p_op
	rts

.erreur
	move.b	#1,erreur
	rts


get_operateur
****************************************************************
** routine qui va trouver le prochain op‚rateur dans la liste **
**                                                            **
** entr‚e : a0 la chaine                                      **
**                                                            **
** Sortie :                                                   **
**   dans a3 l'adresse de l'op‚rateur dans la chaine          **
**   dans a4 l'adresse de la routine … ‚x‚cuter               **
**   dans d0 sa longeur si d0=0 pas d'op‚rateur               **
**   dans d1 sa priorite                                      **
**   dans d2 sa longeur ( la taille du .l .w .b )             **
****************************************************************
	movem.l	d3-a2/a5-a6,-(sp)
	
.cont_recherche
	moveq	#0,d0
	tst.b	(a0)
	beq	.fin
	cmp.b	#'(',(a0)
	bne.s	.rt
	addq.l	#1,a0
	move.l	a0,a6
	bsr	check_size	
	tst.b	d0
	beq.s	.l
	bra	.erreur
.l
	
	bra.S	.cont_recherche
.rt
	cmp.b	#')',(a0)
	bne.s	.rt1
	addq.l	#1,a0
	move.l	a0,a6
	bsr	check_size	
	tst.b	d0
	beq.s	.l1
	addq.l	#2,a0
.l1	bra.s	.cont_recherche
.rt1

	cmp.b	#'{',(a0)
	bne.s	.rt2
	addq.l	#1,a0
	move.l	a0,a6
	bsr	check_size	
	tst.b	d0
	beq.s	.l2
	bra	.erreur
.l2
	bra.S	.cont_recherche
.rt2
	cmp.b	#'}',(a0)
	bne.s	.rt3
	addq.l	#1,a0
	move.l	a0,a6
	bsr	check_size	
	tst.b	d0
	beq.s	.l3
	addq.l	#2,a0
.l3	bra.s	.cont_recherche

.rt3
	
	moveq	#0,d0
	move.l	#long,d2		; taille par defaut dans d2
	
	
	lea	liste_operateurs,a1
	move.l	(a0),d1
	lsr.l	#8,d1
	and.l	#$ffffff,d1		; on ne garde que 
	addq.l	#1,a0
.comp0		
	addq.l	#3,d0			; on compare en word
	move.l	(a1),d2
	lsr.l	#8,d2
	and.l	#$ffffff,d2
	cmp.l	d2,d1
	beq	.trouve	
	subq.l	#3,d0			; pas op on enleve deux a la taille
	add.l	#10,a1
	tst.b	(a1)
	bne.s	.comp0
	
	subq.l	#1,a0

	
	lea	liste_operateurs,a1
	move.w	(a0),d1
	addq.l	#1,a0
.comp1			
	addq.l	#2,d0			; on compare en word
	cmp.w	(a1),d1
	beq	.trouve	
	subq.l	#2,d0			; pas op on enleve deux a la taille
	add.l	#10,a1
	tst.b	(a1)
	bne.s	.comp1
	
	subq.l	#1,a0

	lea	liste_operateurs,a1
	move.b	(a0)+,d1
.comp2					; on compare en byte
	addq.l	#1,d0
	cmp.b	(a1),d1
	beq	.trouve	
	subq.l	#1,d0
	add.l	#10,a1
	tst.b	(a1)
	bne.s	.comp2
	
	
	
	
	bra	.cont_recherche		; on continue la recherche dans la liste
		
.trouve
	move.l	#long,d2		; taille par defaut dans d2
	
	move.l	d0,-(sp)
	move.l	a0,a6
	bsr	check_size
	tst.b	d0
	beq.s	.p_taille
	move.l	d0,d2			; on copie la taille
	move.l	(sp)+,d0
	addq.l	#2,d0			; on augmente le pointeur chaine
	bra.s	.opl
.p_taille
	move.l	(sp)+,d0
.opl	
	
	
	subq.l	#1,a0
	move.l	a0,a3			; adr dans la chaine
	move.l	6(a1),a4		; adr de la routine … executer
	clr.l	d3
	move.b	3(a1),d1
	
.fin
	movem.l	(sp)+,d3-a2/a5-a6
	rts
.erreur
	move.b	#1,erreur
	bra.s	.fin
	
	
teste_registres
******************************************************************
** routine qui va regarder s'il y a un registre                 **
**                                                              **
** Entr‚e                                                       **
**   - dans a0 on a le pointeur de chaine                       **
**   - dans a3 on a le pointeur sur l'op‚rateur suivant         **
** Sortie                                                       **
**   -  dans a4 on a 0 si pas de registre                       **
**   -  ou l'adresse des choses … copier, sur une longueur de 3 **
**   -  inc‚ment de a0 de la longeur voulue                     **
**   -  taille du registre dans d0                              **
******************************************************************
	movem.l	d1-d7/a1-a3/a5-a6,-(sp)
	moveq	#0,d6			; ajout possible de a0 si .l .b .w
	
	
	
	lea	liste_registres,a1
	move.l	a3,a6
	subq.l	#2,a6
	bsr	check_size
	move.l	d0,d7
	tst.b	d7		; si 
	bne.s	.p_z
	move.l	#0,d7		; on met en long par defaut
	bra.s	.op
.p_z	subq.l	#2,a3
	moveq	#2,d6		; incr‚ment pour a0
.op	
	move.l	a0,a6
	
	sub.l	a0,a3		; longueur de la chaine a analyser dans a3
	move.l	a3,d0
	subq.l	#1,d0
	move.l	a0,a3
.again
	move.l	#0,a4
	cmp.b	#$ff,(a1)	; fin de la liste
	bne	.suite


	*--- ici, on va tester si la liste continue ---*
	*--- si oui, on continue normalement ---*



	cmp.w	#1,const
	bne	.exit
	cmp.w	#1,const_e			; la condition de sortie sur la deuxieme liste
	bne.s	.norm_c
	clr.w	const_e
	bra	.exit
.norm_c
	move.w	#1,const_e
	move.l	liste_const,a1			; on initialise le debut de la nouvelle liste
.suite



.cherche
	move.l	d0,d1
	move.l	a3,a0
	cmp.b	#9,(a1)		; cherche l'identif de debut reg
	beq.s	.t0
	addq.l	#1,a1
	;cmp.b	#$ff,(a1)	; fin de la liste
	;beq	.exit
	
	
	cmp.b	#$ff,(a1)	; fin de la liste
	bne	.suite1


	*--- ici, on va tester si la liste continue ---*
	*--- si oui, on continue normalement ---*

	cmp.w	#1,const
	bne	.exit
	cmp.w	#1,const_e			; la condition de sortie sur la deuxieme liste
	bne.s	.norm_c1
	clr.w	const_e
	bra	.exit
.norm_c1
	move.w	#1,const_e
	move.l	liste_const,a1			; on initialise le debut de la nouvelle liste
.suite1

	
	
	
	
	
	
	bra.s	.cherche
.t0				; on a une ligne
	move.l	a1,a5
.cf	addq.l	#1,a5		; on cherche le prochain identificateur
	cmp.b	#9,(a5)		; pour avoir la taille du registre
	beq.s	.t1
	cmp.b	#$ff,(a5)
	bne.s	.cf
.t1
	sub.l	a1,a5
	move.l	a5,d4
	subq.l	#6,d4		; -1 en plus pour le dbra
				; on va prendre le min entre d6 et d1
	
	
	
	
	cmp.b	d1,d4
	ble.s	.n_t
	move.b	d4,d1
.n_t	
	
	
	
	addq.l	#1,a1
.t
	move.b	(a0)+,d2
	cmp.b	(a1)+,d2
	bne.s	.cherche
	dbra	d1,.t
	
	
	; si on arrive ici c'est que la comparaison a ‚t‚ bonne
	
	cmp.b	#dsp,2(a1)	; si type dsp on force la taille
	beq.s	.force_taille
	tst.b	d7		; d7<>0 une taille deja fixee
	bne.s	.p_taille
.force_taille
	move.b	3(a1),d7
.p_taille
	
	cmp.b	#undef,2(a1)	; on regarde si le type de registre est ou non d‚fini ; ie pc du 68 ou pc du dsp
	bne.s	.normal
	
	
	lea	buf_undef,a4
	move.l	(a1),(a4)
	
	
	
	xref	ACTIVE_WINDOW
	move.l	ACTIVE_WINDOW,a2
	cmp.w	#T_reg,type(a2)
	bge	.dsp
		
	; met le bon type de proc	ici 68000
	move.b	#x68,2(a4)
	; met le bon deplacement 
	; de registre en fonction du type de proc
	lea	table_excep,a2
	moveq	#0,d0
	move.w	(a1),d0
	lsl	#3,d0
	;addq.l	#2,d0
	move.w	(a2,d0),(a4)
	tst.b	d7
	bne.s	.saute
	move.w	2(a2,d0),d7
	bra.s	.saute

.dsp	; met le bon type de proc	ici dsp
	move.b	#dsp,2(a4)
	; met le bon deplacement 
	; de registre en fonction du type de proc
	lea	table_excep,a2
	moveq	#0,d0
	move.w	(a1),d0
	lsl	#3,d0
	addq.l	#4,d0
	move.w	(a2,d0),(a4)
	move.w	2(a2,d0),d7	la taille est forcee au dsp
	bra.s	.saute
	
	
.normal	
	move.l	a1,a4		; retour de l'identificateur
.saute
	
	add.l	d6,a0
	
	move.l	d7,d0
	
	movem.l	(sp)+,d1-d7/a1-a3/a5-a6
	rts

	
.exit
	move.l	a6,a0
	movem.l	(sp)+,d1-d7/a1-a3/a5-a6
	rts
	
	
	
	
teste_nombres
*********************************************************************
** Routine qui va tester si le nombre est ou non valide            **
**                                                                 **
** Entr‚e :                                                        **
**   - dans a0 on a le pointeur de chaine                          **
**   - dans a3 on a le pointeur sur l'op‚rateur suivant            **
** Sorite :                                                        **
**   -  dans d0.d1 le nombre sur 64 byte troncable delon la taille **
**   -  dans d2 la taille si d2=0 pas de nombre                    **
**   -  a0 sera incr‚ment‚ correctement                            **
*********************************************************************
	
	movem.l	d3-d7/a1-a6,-(sp)

	moveq	#0,d2

	move.l	a3,a5			; pointeur sur la fin de la chaine
	move.l	a3,a6
	subq.l	#2,a6			; pointe 2 avant la fin
	bsr	check_size
	tst.b	d0
	bne.s	.p_z
	move.l	#long,d0		; on met en long par defaut
	bra.s	.op
.p_z	
	subq.l	#2,a3
.op
	move.l	d0,d7	
	


*--- lorsque l'on est ici, on a une chaine avec ---*
*--- ‚venteullement un point au milieu, mais pas … la fin ---*

	moveq	#0,d6		; on a un nombre normal

	cmp.b	#'.',-1(a3)	; si on a un nombre du style xxxxx.
	bne.s	.p_erreur_p	; alors erreur
	moveq	#0,d2
	bra	.erreur
.p_erreur_p

	move.l	a0,a4
.check_point			; on va regarder si on a un point
	cmp.l	a4,a3
	ble.s	.p_point
	cmp.b	#'.',(a4)+
	bne.s	.check_point
.point
	*--- ici, on a peut etre un nombre decimal ---*



	moveq	#3,d6		; pour dire qu'il faudra tester la suite
	move.l	a3,a2		; on sauve dans a2
	move.l	a4,a3		; il y 2 dans d6 comme ca en bas ca teste
	subq.l	#1,a3		; bien pour le 2eme coup
.p_point




	move.l	a0,a6
	move.l	a0,a1
	move.l	a3,a0
		
	
.teste_encore
	
*----- test hexa avec $ -----*
		
	cmp.w	#'-$',(a1)
	beq.s	.hexa1
	cmp.w	#'$-',(a1)
	beq.s	.hexa1
	cmp.w	#'+$',(a1)
	beq.s	.hexa1
	cmp.w	#'$+',(a1)
	beq.s	.hexa1
	cmp.b	#'$',(a1)
	beq.s	.hexa
	bra	.p_hexa
.hexa1	addq.l	#1,a1
.hexa	addq.l	#1,a1
.ok_n
	cmp.l	a1,a0
	beq	.tout_bon
	move.b	(a1)+,d1
	cmp.b	#'0',d1
	blt	.p_nb
	cmp.b	#'9',d1
	bgt	.p_nb
	bra.s	.ok_n
.p_nb
	cmp.b	#'A',d1
	blt	.p_car_ma
	cmp.b	#'F',d1
	bgt	.p_car_ma
	sub.b	#'A',d1
	bra.s	.ok_n
.p_car_ma
	cmp.b	#'a',d1
	blt	.p_car_mi
	cmp.b	#'f',d1
	bgt	.p_car_mi
	sub.b	#'a',d1
	bra.s	.ok_n
.p_car_mi
	bra	.erreur
	
	
*----- test binaire  -----*
.p_hexa	cmp.w	#'-%',(a1)
	beq.s	.bin1
	cmp.w	#'%-',(a1)
	beq.s	.bin1
	cmp.w	#'+%',(a1)
	beq.s	.bin1
	cmp.w	#'%+',(a1)
	beq.s	.bin1
	cmp.b	#'%',(a1)
	beq.s	.bin
	bra	.p_bin
.bin1	addq.l	#1,a1
.bin	addq.l	#1,a1
.ok_bin
	cmp.l	a1,a0
	beq	.tout_bon
	move.b	(a1)+,d1
	cmp.b	#'1',d1
	beq.s	.ok_bin
	cmp.b	#'0',d1
	beq.s	.ok_bin
	bra	.erreur

*----- test decimal -----*
.p_bin
	
	cmp.w	#'-\',(a1)
	beq.s	.deci1
	cmp.w	#'\-',(a1)
	beq.s	.deci1
	cmp.w	#'+\',(a1)
	beq.s	.deci1
	cmp.w	#'\+',(a1)
	beq.s	.deci1
	cmp.b	#'\',(a1)
	beq.s	.deci
	bra.s	.p_deci
.deci1
	addq.l	#1,a1
.deci
	addq.l	#1,a1


	
.ok_deci
	cmp.l	a1,a0
	beq.s	.tout_bon
	move.b	(a1)+,d1
	
	cmp.b	#'0',d1
	blt	.p_nb1
	cmp.b	#'9',d1
	bgt	.p_nb1
	bra.s	.ok_deci
.p_nb1
	bra	.erreur



*----- test de l'hexa sans $ -----*

.p_deci


	cmp.b	#'-',(a1)
	beq.s	.ok_n11
	
	cmp.b	#'+',(a1)
	bne.s	.ok_n1
	
.ok_n11
	addq.l	#1,a1


.ok_n1
	cmp.l	a1,a0
	beq.s	.tout_bon
	move.b	(a1)+,d1
	
	cmp.b	#'0',d1
	blt	.p_nb11
	cmp.b	#'9',d1
	bgt	.p_nb11
	bra.s	.ok_n1
.p_nb11
	cmp.b	#'A',d1
	blt	.p_car_ma1
	cmp.b	#'F',d1
	bgt	.p_car_ma1
	sub.b	#'A',d1
	bra.s	.ok_n1
.p_car_ma1

	cmp.b	#'a',d1
	blt	.p_car_mi1
	cmp.b	#'f',d1
	bgt	.p_car_mi1
	sub.b	#'a',d1
	bra.s	.ok_n1
.p_car_mi1
	bra	.erreur
.tout_bon
	
*----- Le nombre est au bon formant on va le convertir -----*

	

	cmp.l	#3,d6
	bne.s	.nombre_entier
	
	move.l	a3,a1
	addq.l	#1,a1
	
	move.l	a2,a3
	move.l	a3,a0
	subq.l	#1,d6
	bra	.teste_encore
.nombre_entier


	move.l	a6,a1			; pointeur sur la chaine
	
	
	
	
	sub.l	a6,a3		
	move.l	a3,d0
	sub.l	#1,d0			; longueur dans d0 pour dbra
	
	lea	chaine_nombre,a0
.cop	move.b	(a1)+,(a0)+
	dbra	d0,.cop
	clr.b	(a0)
	
	****** attention charger d2
	
	lea	chaine_nombre,a0
	
	
	cmp.l	#2,d6		
	bne.s	.er
	
	bsr.l	READ_FLOAT
	
	
	;illegal
	
	
	;fmove.x	#1.25,fp0
	move.b	#float,d2
	bra	.exit1
	
	
.er
	
	cmp.l	#1,d6			; ici il faudra g‚rer le flottant
	bne.s	.o			; on accepte le .xxxx <=> 0.xxxx
	bra	.erreur
	
	
	
	
.o
	
	
	bsr	convert
	
	
	
	tst.l	d0		
	beq.s	.p_double		; a t on un double long ?
	move.b	#double,d2
	bra.s	.exit1
.p_double
	move.b	d7,d2			; copie de la taille
.exit1
	move.l	a5,a0			; pointeur sur la chaine fin
	movem.l	(sp)+,d3-d7/a1-a6
	rts
.erreur
	move.l	a6,a0
	moveq	#0,d2			; on a une erreur sur le format
	movem.l	(sp)+,d3-d7/a1-a6
	rts


teste_labels
******************************************************************
** routine qui va regarder s'il y a un label                    **
**                                                              **
** Entr‚e                                                       **
**   - dans a0 on a le pointeur de chaine                       **
**   - dans a3 on a le pointeur sur l'op‚rateur suivant         **
** Sortie                                                       **
**   -  dans a4 on a 0 si pas de label                          **
**   -  ou l'adresse du label                                   **
**   -  inc‚ment de a0 de la longeur voulue                     **
**   -  dans d0 on a la longueur                                **
******************************************************************
	xref	adr_label,nb_symbols
	
	movem.l	d1-d7/a1-a3/a5-a6,-(sp)
	
	
	xref	ACTIVE_WINDOW
	move.l	ACTIVE_WINDOW,a2
	cmp.w	#T_reg,type(a2)
	bge	.dsp
	
	
	
	moveq	#0,d4			; incr‚ment possible de a0
	moveq	#0,d5
	
	moveq	#0,d7
	
	move.l	a3,a6
	subq.l	#2,a6			; pointe 2 avant la fin
	bsr	check_size
	move.l	d0,d5
	tst.b	d5
	bne.s	.p_z
	move.l	#long,d5		; on met en long par defaut
	bra.s	.op
.p_z	
	subq.l	#2,a3
	moveq	#2,d4		; increment a0 de 2
.op
	
	
	
	sub.l	a0,a3		
	move.l	a3,d7			; taille du label dans d7
	
	
	
	move.l	a0,a3
	move.l	a0,a5
	
	
	
	move.l	adr_label,a6
	move.l	nb_symbols,d2
	beq.s	.p_adresse
	
.che
	move.l	d7,d6
	move.l	(a6)+,a4		; a4 : adresse du label
	move.l	(a6)+,a2		; a2 1ere lettre du label
	move.l	a3,a5
.che1
	move.b	(a2)+,d0		; lettre du label de reference
	move.b	(a5)+,d1		; lettre a comparer
	
	
	tst.b	d0			; on regarde si les zero arrivent en meme temp
	bne.s	.o
	tst.b	d6
	beq.s	.ok
.o
	subq.l	#1,d6
	cmp.b	d0,d1
	beq.s	.che1
	
	subq.l	#1,d2
	bne.s	.che
	bra.s	.p_adresse
.ok
	add.l	d7,a0
	add.l	d4,a0
	move.l	d5,d0
	bra.s	.exit
.p_adresse
	move.l	#0,a4
	bra.s	.exit

.dsp
	moveq	#0,d4			; incr‚ment possible de a0
	moveq	#0,d5
	
	moveq	#0,d7
	
	move.l	a3,a6
	subq.l	#2,a6			; pointe 2 avant la fin
	bsr	check_size
	move.l	d0,d5
	tst.b	d5
	bne.s	.p_z1
	move.l	#long,d5		; on met en long par defaut
	bra.s	.op1
.p_z1
	subq.l	#2,a3
	moveq	#2,d4		; increment a0 de 2
.op1
	
	
	
	sub.l	a0,a3		
	move.l	a3,d7			; taille du label dans d7
	
	
	
	move.l	a0,a3
	move.l	a0,a5
	
	
	
	xref	SYMBOLS_PTR
		
	move.l	SYMBOLS_PTR,a6
	move.l	(a6)+,d2
	beq.s	.p_adresse1
	
	
.che12
	move.l	d7,d6
	addq.l	#2,a6
	move.l	(a6)+,a4		; a4 : adresse du label
	move.l	(a6)+,a2		; a2 1ere lettre du label
	move.l	a3,a5
.che11
	move.b	(a2)+,d0		; lettre du label de reference
	move.b	(a5)+,d1		; lettre a comparer
	
	
	tst.b	d0			; on regarde si les zero arrivent en meme temp
	bne.s	.o1
	tst.b	d6
	beq.s	.ok1
.o1
	subq.l	#1,d6
	cmp.b	d0,d1
	beq.s	.che11
	
	subq.l	#1,d2
	bne.s	.che12
	bra.s	.p_adresse1
.ok1
	add.l	d7,a0
	add.l	d4,a0
	move.l	d5,d0
	bra.s	.exit
.p_adresse1
	move.l	#0,a4


.exit
	
	movem.l	(sp)+,d1-d7/a1-a3/a5-a6
	rts


verifie_paranthese
*********************************************************
** Routine qui va v‚rifier que le nombre de paranthŠse **
** est le bon                                          **
**                                                     **
** Entr‚e :                                            **
**   - a0 = la chaine a analyser                       **
** Sorite :                                            **
**   - erreur =  0  ok                                 **
**     ereeur <> 0erreur                               **
*********************************************************
	movem.l	d0-a6,-(sp)
	move.b	#0,erreur
	lea	temp_para,a1
.test	move.b	(a0)+,d0
	tst.b	d0
	beq.s	.fin_c
	
	cmp.b	#'(',d0			; on stocke 1 pour les parathŠses
	bne.s	.p_par_o
	move.b	#1,(a1)+
.p_par_o
	cmp.b	#'{',d0
	bne.s	.p_acc_o		; 2 pour les crochets
	move.b	#2,(a1)+
.p_acc_o
	cmp.b	#')',d0			; on regarde si dans la
	bne.s	.p_par_f		; liste on avait une ouverture
	cmp.b	#1,-(a1)		; sinon erreur
	bne.s	.erreur
.p_par_f	
	cmp.b	#'}',d0			; on regarde si dans la
	bne.s	.p_acc_f		; liste on avait une ouverture
	cmp.b	#2,-(a1)		; sinon erreur
	bne.s	.erreur
.p_acc_f	
	bra.s	.test
	
	
.fin_c
	cmp.l	#temp_para,a1		; on regarde si on est a z‚ro avec
	beq.s	.ok_para		; la liste si oui ok sinon erreur
.erreur
	move.b	#1,erreur
.ok_para
	
	movem.l	(sp)+,d0-a6
	rts


check_size
****************************************************
** routine qui va regarder l'extension .l .b .... **
**                                                **
** Entr‚e :                                       **
**   - Chaine … analyser dans a6                  **
** Sortie :                                       **
**   - d0 = 0 pas d'extensio                      ** 
**   - d0 <> 0 contient la taille de l'extension  **
****************************************************
	moveq	#0,d0
	
	
	
	cmp.w	#'.l',(a6)
	bne.s	.p_l
	move.l	#long,d0
	bra	.x
.p_l
	cmp.w	#'.L',(a6)
	bne.s	.p_L
	move.l	#long,d0
	bra	.x
.p_L
	cmp.w	#'.d',(a6)
	bne.s	.p_d
	move.l	#double,d0
	bra	.x
.p_d
	cmp.w	#'.D',(a6)
	bne.s	.p_D
	move.l	#double,d0
	bra	.x
.p_D
	cmp.w	#'.w',(a6)
	bne.s	.p_w
	move.l	#word,d0
	bra	.x
.p_w
	cmp.w	#'.W',(a6)
	bne.s	.p_W
	move.l	#word,d0
	bra	.x
.p_W
	cmp.w	#'.b',(a6)
	bne.s	.p_b
	move.l	#byte,d0
	bra	.x
.p_b
	cmp.w	#'.B',(a6)
	bne.s	.p_B
	move.l	#byte,d0
	bra	.x
.p_B
	cmp.w	#'.x',(a6)
	bne.s	.p_x
	move.l	#dspx,d0
	bra.s	.x
.p_x
	cmp.w	#'.X',(a6)
	bne.s	.p_X
	move.l	#dspx,d0
	bra.s	.x
.p_X
	cmp.w	#'.y',(a6)
	bne.s	.p_y
	move.l	#dspy,d0
	bra.s	.x
.p_y
	cmp.w	#'.Y',(a6)
	bne.s	.p_Y
	move.l	#dspy,d0
	bra.s	.x
.p_Y
	cmp.w	#'.p',(a6)
	bne.s	.p_p
	move.l	#dspp,d0
	bra.s	.x
.p_p
	cmp.w	#'.P',(a6)
	bne.s	.p_P
	move.l	#dspp,d0
	bra.s	.x
.p_P
	cmp.w	#'.m',(a6)
	bne.s	.p_m
	move.l	#dspl,d0
	bra.s	.x
.p_m
	cmp.w	#'.M',(a6)
	bne.s	.p_M
	move.l	#dspl,d0
	bra.s	.x
.p_M



	nop
.x
	rts






adr_plus
***************************************************
** dans a0 on a l'adresse de l'op‚rateur courant **
** il faut donc prendre l'objet avant            **
** l'objet apres faire l'addition et             **
** r‚ins‚rer le r&‚sultat dans la liste          **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	
	moveq	#0,d1		; teste si le signe + est celui du positif
	moveq	#0,d0
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	cmp.b	#op,(a1)
	bne.s	.saute_conv_type
	move.l	(a0),a2
	move.l	#nombre_vide,a1		; pointe sur le nombre 0
	moveq	#1,d7
.saute_conv_type
	
.conv
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	
	add.l	d1,d3		; r‚sultat dans d3
	
	addx.l	d0,d2		; on va ajouter d0&d2 plus l'eventuelle retenue
	
	
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_et
***************************************************
** dans a0 on a l'adresse de l'op‚rateur courant **
** il faut donc prendre l'objet avant            **
** l'objet apres faire le et logique             **
** r‚ins‚rer le r&‚sultat dans la liste          **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	and.l	d1,d3		; r‚sultat dans d3
	and.l	d0,d2
	
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts


adr_ou
***************************************************
** dans a0 on a l'adresse de l'op‚rateur courant **
** il faut donc prendre l'objet avant            **
** l'objet apres faire le ou logique             **
** r‚ins‚rer le r&‚sultat dans la liste          **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	or.l	d1,d3		; r‚sultat dans d3
	or.l	d0,d2
	
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_ou_ex
***************************************************
** dans a0 on a l'adresse de l'op‚rateur courant **
** il faut donc prendre l'objet avant            **
** l'objet apres faire le ou exclu logique       **
** r‚ins‚rer le r&‚sultat dans la liste          **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	eor.l	d1,d3		; r‚sultat dans d3
	eor.l	d0,d2
	

	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_non
***************************************************
** dans a0 on a l'adresse de l'op‚rateur courant **
** il faut donc prendre l'objet avant            **
** l'objet apres faire le non logique            **
** r‚ins‚rer le r&‚sultat dans la liste          **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	d7,d6
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	cmp.b	#double,d6
	bne.s	.lo
	not.l	d2
.lo
	not.l	d3		; r‚sultat dans d3
	
	
	
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_moins
*****************************
** Routine de soustraction **
*****************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2
	
	
	moveq	#0,d1		; teste si le - est celui de la negation
	moveq	#0,d0
	moveq	#2,d7			; nb d'objet … enlever dans la liste
	cmp.b	#op,(a1)
	bne.s	.saute_conv_type
	move.l	(a0),a2
	move.l	#nombre_vide,a1		; pointe sur le nombre 0
	moveq	#1,d7
.saute_conv_type
	
	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3

	
	move.l	d3,d4
	lsl.l	#1,d4
	subx.l	d2,d2
	
	
	sub.l	d3,d1		; r‚sultat dans d3
	
	
	
	
	
	subx.l	d2,d0
	
	
	
	;clr.l	d2
	move.l	d1,d3		; pour le sens
	move.l	d0,d2
	
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0

	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_mult
**********************************
** la routine de multiplication **
**********************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	*-- ici il faudrait faire d2*d0 + d5 +d6 a la fin met le
	*-- resultat tiendrait sur 96 bit !
	
	
	move.l	d3,a3		; sauvegarde de d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	mulu.l	d1,d4:d3
	move.l	d3,a6		; retenue dans d4
	
	move.l	a3,d3
	mulu.l	d0,d5:d3	; retenue dans d5 (inutilis‚)
	
	mulu	d2,d6:d1	; retenue dans d6 (inutilis‚)
	
	
	
	
	move.l	d3,d2
	add.l	d1,d2
	addx.l	d4,d2	; ajoute la retenue
	
	
	
	
	move.l	a6,d3	; met le poid faible
	
	
	
	;mulu.l	d1,d3		; r‚sultat dans d3
	;clr.l	d2
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts


adr_divise
**********************************
** la routine de multiplication **
**********************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	tst.l	d2		; si on divise par un nombre > 32 bit => erreur
	bne.s	.erreur
	
	cmp.l	#0,d3		; attention a la dision par zero !
	beq.s	.erreur
	
	
	move.l	d3,d2
	move.l	#0,d3
	divu.l	d2,d3:d0
	divu.l	d2,d3:d1
	clr.l	d2
	
	move.l	d0,d2
	move.l	d1,d3
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts
	
.erreur
	clr.l	d2
	clr.l	d3

	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	subq.l	#4,a0
	move.b	#1,erreur
	movem.l	(sp)+,d0-d7/a1-a6
	rts
	

adr_affecte
***************************************************
** affectation a un registre ou une case m‚moire **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	clr.l	d7
	move.l	(a1),a1		; pointe dans la liste
	cmp.b	#op_mem,(a1)
	bne.s	.p_mem
	move.b	1(a1),d7	; taille dans d7 <>0
	move.l	2(a1),a6	; valeur dans a6
	move.l	(a2),a1
	
.p_mem
	
	
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	tst.b	d7
	beq	.normal_aff
	
	
	
	cmp.b	#dspx,d7
	bne.s	.p_dspx
	envl	#'CMD'
	envl	#DSP_X2DSP
	envl	a6		;ADR_DEBUT
	envl	#1
	envl	d3
	bra	.ex
.p_dspx
	cmp.b	#dspy,d7
	bne.s	.p_dspy
	envl	#'CMD'
	envl	#DSP_Y2DSP
	envl	a6		;ADR_DEBUT
	envl	#1
	envl	d3
	bra	.ex
.p_dspy
	cmp.b	#dspp,d7
	bne.s	.p_dspp
	envl	#'CMD'
	envl	#DSP_P2DSP
	envl	a6		;ADR_DEBUT
	envl	#1
	envl	d3
	bra	.ex
.p_dspp
	cmp.b	#dspl,d7
	bne	.p_dspl
	
	move.l	d2,d4
	lsl.l	#8,d4
	move.l	d3,d5
	move.l	d3,d0
	and.l	#$ffffff,d0
	rol.l	#8,d5
	and	#$ff,d5
	or	d5,d4

	envl	#'CMD'
	envl	#DSP_X2DSP
	envl	a6		;ADR_DEBUT
	envl	#1
	envl	d4
	envl	#'CMD'
	envl	#DSP_Y2DSP
	envl	a6		;ADR_DEBUT
	envl	#1
	envl	d0
	bra	.ex
.p_dspl
	tst.w	AUTO_IO
	bne	.OUI
	
	cmp.b	#long,d7
	bne	.p_l
	writ_mem.l	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_l
	cmp.b	#word,d7
	bne	.p_w
	writ_mem.w	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_w	
	cmp.b	#byte,d7
	bne	.p_b
	writ_mem.b	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_b
	
	bra	.NON
.OUI
	cmp.b	#long,d7
	bne.s	.p_l1
	writ_mem_io.l	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_l1
	cmp.b	#word,d7
	bne.s	.p_w1
	writ_mem_io.w	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_w1
	cmp.b	#byte,d7
	bne.s	.p_b1
	writ_mem_io.b	d3,a6
	tst.b	ERR_MEM
	bne	.erreur
	bra	.ex
.p_b1
.NON
	
.normal_aff
	cmp.b	#x68,4(a1)
	beq.s	.o_68
	cmp.b	#dsp,4(a1)
	beq.s	.o_dsp
	
	cmp.b	#constante,4(a1)
	bne.s	.p_cst
	move.l	adr_cst,a3
	bra.s	.next
.p_cst
	
	move.l	adr_reg_int,a3	; type interne
	bra.s	.next
.o_68
	move.l	adr_reg_68x,a3
	bra.s	.next
.o_dsp
	move.l	adr_reg_dsp,a3
.next
	clr.l	d0
	move.w	2(a1),d0
	add.l	d0,a3		; on pointe au bon endroit

	cmp.b	#dextend,1(a1)
	bne.s	.p_dsp_e
	move.l	d3,d4
	and.l	#$ffffff,d4
	move.l	d4,(a3)
	sub.l	#4,a3
	move.l	d2,d0
	and.l	#$ffff,d0
	lsl.l	#8,d0
	move.l	d3,d4
	swap	d4
	lsr.l	#8,d4
	and.l	#$ffffff,d4
	move.b	d4,d0
	move.l	d0,(a3)
	
	subq.l	#4,a3
	move.l	d2,d0
	swap	d2
	and.l	#$ffffff,d2
	move.l	d2,(a3)
	bra	.ex
.p_dsp_e
	cmp.b	#dlong,1(a1)
	bne.s	.p_dsp_l
	move.l	d3,d4
	and.l	#$ffffff,d4
	move.l	d4,(a3)
	sub.l	#4,a3
	move.l	d2,d0
	and.l	#$ffff,d0
	lsl.l	#8,d0
	move.l	d3,d4
	swap	d4
	lsr.l	#8,d4
	and.l	#$ffffff,d4
	move.b	d4,d0
	move.l	d0,(a3)
	bra	.ex
.p_dsp_l
	cmp.b	#dab,1(a1)
	bne.s	.p_dab
	move.l	d3,d4
	and.l	#$ffffff,d3
	move.l	d3,(a3)
	move.l	adr_reg_dsp,a3
	add.l	#REG_A1,a3
	and.l	#$ffff,d2
	lsl.l	#8,d2
	swap	d4
	lsr.l	#8,d4
	move.b	d4,d2
	move.l	d2,(a3)
	bra	.ex
.p_dab
	cmp.b	#dba,1(a1)
	bne.s	.p_dba
	move.l	d3,d4
	and.l	#$ffffff,d3
	move.l	d3,(a3)
	move.l	adr_reg_dsp,a3
	add.l	#REG_B1,a3
	and.l	#$ffff,d2
	lsl.l	#8,d2
	swap	d4
	lsr.l	#8,d4
	move.b	d4,d2
	move.l	d2,(a3)
	bra	.ex
.p_dba


	cmp.b	#float,1(a1)
	bne.s	.p_float

	cmp.b	#1,nbfloat2		; on teste si la seconde operande est flottante
	bne.s	.p_flt	

	fmove.x	float2,fp0
	fmove.x	fp0,(a3)
	
	bra.s	.ex

.p_flt

	fmove.s	d3,fp0
	fmove.x	fp0,(a3)
	;move.l	d2,(a3)
	;move.l	d3,4(a3)
	bra.s	.ex
	
	
	
.p_float


	cmp.b	#double,1(a1)
	bne.s	.p_double
	move.l	d2,(a3)
	move.l	d3,4(a3)
	bra.s	.ex
.p_double
	cmp.b	#long,1(a1)
	bne.s	.p_long
	move.l	d3,(a3)
	bra.s	.ex
.p_long
	cmp.b	#dword,1(a1)
	bne.s	.p_dsp_w
	and.l	#$ffffff,d3
	move.l	d3,(a3)
	bra.s	.ex
.p_dsp_w
	cmp.b	#word,1(a1)
	bne.s	.p_word
	move.w	d3,2(a3)
	bra.s	.ex
.p_word
	cmp.b	#byte,1(a1)
	bne.s	.p_byte
	move.b	d3,3(a3)
	bra.s	.ex
.p_byte
	illegal			; erreur
.ex
	
	moveq	#2,d7
	bsr	inser_liste		; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts

.erreur
	move.b	#1,erreur
	bra.s	.ex


adr_parantheses
************************************************
** routine qui prend en charge les paranthŠse **
** en ‚valuant la chaine par morceaux         **
************************************************
	movem.l	d0-d7/a1-a6,-(sp)

	bsr	evalue_chaine
	
	subq.l	#4,a0
	move.l	a0,a1
	
	move.l	4(a1),(a1)		; on copie le r‚sultat
	
	add.l	#12,a1
.copie	move.l	(a1)+,d0
	beq.s	.quit
	move.l	d0,-12(a1)
	bra.s	.copie
.quit	
		
	movem.l	(sp)+,d0-d7/a1-a6
	rts


adr_accolades
**************************************
** routine qui va lire la m‚moire   **
**************************************
	movem.l	d0-d7/a1-a6,-(sp)


	bsr	evalue_chaine
	
	
	
	move.l	4(a0),a1
	move.b	1(a1),d0		; taille dans d0
	
	
	
	subq.l	#4,a0
	move.l	a0,a1
	
	move.l	8(a1),(a1)		; on copie le r‚sultat
	
	
	;*-----  dans a1 on aura l'adresse m‚moire … lire -----*
	
	
	move.l	12(a0),a2
	cmp.b	#op,(a2)
	bne.s	.nor
	cmp.l	#adr_affecte,3(a2)
	bne.s	.nor
	move.l	(a1),a2
	move.l	4(a1),a3
	
	movem.l	d0/a1/a2,-(sp)
	move.l	a3,a1
	move.l	a3,a2
	bsr	convert_type
	movem.l	(sp)+,d0/a1/a2
	
	move.l	d1,2(a2)
	
	
	
	;move.l	2(a3),2(a2)
	
	
	
	
	;move.b	#long,1(a2)
	move.b	d0,1(a2)
	move.b	#op_mem,(a2)
	bra	.suite
	
.nor
	
	move.l	4(a1),a2			; pointe sur l'objet
	
	; on doit faire un convert type sur a2
	movem.l	d0/a1,-(sp)
	move.l	a2,a1
	bsr	convert_type
	move.l	d3,a3
	movem.l	(sp)+,d0/a1
	
	move.l	(a1),a2
	
	;illegal
	
	
	tst.w	AUTO_IO
	bne	.OUI
	
	
	cmp.b	#long,d0
	bne	.p_l
	lit_mem.l	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.l	d1,2(a2)
	bra	.k
.p_l
	cmp.b	#word,d0
	bne	.p_w
	lit_mem.w	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.w	d1,2(a2)
	bra	.k
.p_w
	cmp.b	#byte,d0
	bne	.p_b
	lit_mem.b	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.b	d1,2(a2)
	bra	.k
.p_b
	bra	.NON
.OUI
	
	cmp.b	#long,d0
	bne	.p_l1
	lit_mem_io.l	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.l	d1,2(a2)
	bra	.k
.p_l1
	cmp.b	#word,d0
	bne	.p_w1
	lit_mem_io.w	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.w	d1,2(a2)
	bra	.k
.p_w1
	cmp.b	#byte,d0
	bne	.p_b1
	lit_mem_io.b	a3,d1
	tst.b	ERR_MEM
	bne	.erreur
	move.b	d1,2(a2)
	bra	.k
.p_b1
	
.NON
	
	cmp.b	#dspx,d0
	bne.s	.p_x
	envl	#'CMD'
	envl	#DSP_XDUMP
	envl	a3
	envl	#1
	recl	2(a2)
	move.l	#long,d0
	bra	.k
.p_x
	cmp.b	#dspy,d0
	bne.s	.p_y
	envl	#'CMD'
	envl	#DSP_YDUMP
	envl	a3
	envl	#1
	recl	2(a2)
	move.l	#long,d0
	bra	.k
.p_y
	cmp.b	#dspp,d0
	bne.s	.p_p
	envl	#'CMD'
	envl	#DSP_PDUMP
	envl	a3
	envl	#1
	recl	2(a2)
	move.l	#long,d0
	bra	.k
.p_p
	cmp.b	#dspl,d0
	bne	.p_ld
	xref	WORK_BUF
	lea	WORK_BUF,a6
	envl	#'CMD'
	envl	#DSP_XDUMP
	envl	a3
	envl	#1
	recl	(a6)
	envl	#'CMD'
	envl	#DSP_YDUMP
	envl	a3
	envl	#1
	recl	4(a6)
	move.l	(a6),d1
	and.l	#$ffffff,d1
	move.l	d1,3(a2)
	move.l	4(a6),d1
	and.l	#$ffffff,d1
	or.l	d1,6(a2)
	move.l	#double,d0
	bra	.k
.p_ld
	
	
	
	nop
	
	
	
.k
	move.b	#nb,(a2)
	move.b	d0,1(a2)		; copie de la	taille
	move.l	a2,(a1)
.suite	

	
	
	add.l	#12,a1
	
	
.copie	move.l	(a1)+,d0
	beq.s	.quit
	
	move.l	d0,-12(a1)
	bra.s	.copie
.quit	
		
	movem.l	(sp)+,d0-d7/a1-a6
	rts
.erreur
	move.b	#1,erreur
	bra	.k
	
	
adr_egal_egal
*******************************************************
** routine qui va tester l'‚galit‚ entre deux objets **
*******************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	cmp.l	d0,d2
	bne.s	.p_e
	cmp.l	d1,d3
	bne.s	.p_e
	
	
	moveq	#1,d3		; oui c'est egal   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non different => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_different
*********************************************************
** routine qui va tester l'in‚galit‚ entre deux objets **
*********************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	cmp.l	d1,d3
	bne.s	.egal
	
	cmp.l	d0,d2
	beq.s	.p_e
	
.egal
	moveq	#1,d3		; oui c'est differenr   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non c'est egal => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_inf_strict
**********************************************************
** routine qui va tester l'inf strict entre deux objets **
**********************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	
	cmp.l	d2,d0		; branche si plus grand ou egal
	bgt.s	.p_e

	cmp.l	d2,d0		; branche si plus grand ou egal
	blt.s	.egal


	
	cmp.l	d3,d1		; branche si plus grand ou egal
	bge.s	.p_e
	
.egal
	moveq	#1,d3		; oui c'est differenr   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non c'est egal => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts


adr_inf_egal
***************************************************
** routine qui va tester l'inf entre deux objets **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	

	cmp.l	d2,d0		; branche si plus grand ou egal
	bgt.s	.p_e

	cmp.l	d2,d0		; branche si plus grand ou egal
	blt.s	.egal



	
	cmp.l	d3,d1		; branche si plus grand ou egal
	bgt.s	.p_e
	
.egal
	moveq	#1,d3		; oui c'est differenr   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non c'est egal => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts

adr_sup_strict
**********************************************************
** routine qui va tester l'sup strict entre deux objets **
**********************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	cmp.l	d0,d2
	bgt.s	.p_e
	
	cmp.l	d0,d2
	blt.s	.egal
	
	
	
	cmp.l	d1,d3		; branche si plus grand ou egal
	bge.s	.p_e
	
.egal
	moveq	#1,d3		; oui c'est differenr   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non c'est egal => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts


adr_sup_egal
***************************************************
** routine qui va tester l'sup entre deux objets **
***************************************************
	movem.l	d0-d7/a1-a6,-(sp)
	
	move.l	a0,a1
	subq.l	#4,a1		; a1 pointe sur l'objet avant
	move.l	a0,a2
	addq.l	#4,a2		; a2 pointe sur l'objet apres
	
	move.l	(a1),a1		; pointe dans la liste
	move.l	(a2),a2


	bsr	convert_type	; convertit a1,a2 en nombre d0.d1  d2.d3
	
	
	
	cmp.l	d0,d2		; si d2>d1 alors d1 n'est pas >=d2
	bgt.s	.p_e
	
	cmp.l	d0,d2		; si d2<d1
	blt.s	.egal
	
	
	
	cmp.l	d1,d3		; branche si plus grand ou egal
	bgt.s	.p_e
	
.egal
	moveq	#1,d3		; oui c'est differenr   => 1
	moveq	#0,d2
	bra.s	.ok
	
.p_e
	moveq	#0,d3		; non c'est egal => 0
	moveq	#0,d2
	
.ok
	
	moveq	#2,d7
	bsr	inser_liste	; d2.d3 inser‚s dans la liste en tant que nombre point‚e par a0
	
	subq.l	#4,a0

	
	
	
	
	movem.l	(sp)+,d0-d7/a1-a6
	rts
dummy
***********
** dummy **
***********
	illegal
	rts


teste_coherence
**********************************************
** Routine qui va tester que tous les       **
** ‚l‚ments de la chaine se suivent bien    **
**                                          **
** Entr‚e :                                 **
**   - a0 pointe sue la liste des pointeurs **
** Sortie :                                 **
**   - erreur = 0 pas de pb                 **
**     erreur <> 0 (=2) erreur              **
**********************************************

	movem.l	d0-a6,-(sp)
	

	move.l	a0,a1
	
	*--- teste des op‚rateurs ---*

	move.l	(a0),a2			; regarde si on a un operateur en premiere position
	cmp.b	#op,(a2)		; si oui => erreur
	beq	.erreur





.suiv
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)		; fini ?
	beq.s	.next
	cmp.b	#op,(a2)		; si on a un operateur
	bne.s	.suiv			; on regarde si le suivant en est un
	
	move.l	a2,a6
	move.l	(a0),a2			; alors erreur
	cmp.b	#op,(a2)
	bne	.s_teste		; si le suivant est un - alors ok
	cmp.l	#adr_affecte,3(a6)	; si l'op‚rateur est deja un moins et qu'il y aun op apres => erreur
	bne	.erreur
	cmp.l	#adr_moins,3(a2)	; sinon ok
	bne	.erreur
.s_teste
	cmp.b	#par_f,(a2)		; un paranthŠse ferm‚e aussi
	beq	.erreur
	cmp.b	#acc_f,(a2)		; un crochet ferm‚ aussi
	beq	.erreur
	cmp.b	#dernier,(a2)		; rien aussi
	beq	.erreur
	bra.s	.suiv
.next
	move.l	a1,a0
	
	*--- teste des paranthŠse ouvertes ---*
	
.suiv1
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next1
	cmp.b	#par_o,(a2)
	bne.s	.suiv1	
	
	move.l	(a0),a2			; alors erreur
	cmp.b	#op,(a2)
	bne	.s_teste1		; si le suivant est un - alors ok
	cmp.l	#adr_moins,3(a2)	; sinon ok
	bne	.erreur
.s_teste1
	
	
	cmp.b	#par_f,(a2)
	beq	.erreur	
	cmp.b	#acc_f,(a2)
	beq	.erreur	
	bra.s	.suiv1
.next1
	move.l	a1,a0
	*--- teste des paranthŠse ferm‚es ---*
	
.suiv2
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next2
	cmp.b	#par_f,(a2)
	bne.s	.suiv2	
	move.l	(a0),a2			; recupŠre l'objet suivant
	cmp.b	#par_o,(a2)
	beq	.erreur	
	cmp.b	#acc_o,(a2)
	beq	.erreur	
	cmp.b	#reg,(a2)
	beq	.erreur	
	cmp.b	#label,(a2)
	beq	.erreur	
	cmp.b	#nb,(a2)
	beq	.erreur	
	bra.s	.suiv2
.next2
	move.l	a1,a0
	*--- teste des accolades ferm‚es ---*
	
.suiv3
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next3
	cmp.b	#acc_f,(a2)
	bne.s	.suiv3	
	move.l	(a0),a2			; recupŠre l'objet suivant
	cmp.b	#par_o,(a2)
	beq	.erreur	
	cmp.b	#acc_o,(a2)
	beq	.erreur	
	cmp.b	#reg,(a2)
	beq	.erreur	
	cmp.b	#label,(a2)
	beq	.erreur	
	cmp.b	#nb,(a2)
	beq	.erreur	
	bra.s	.suiv3
.next3
	move.l	a1,a0

	*--- teste des accolades ouvertes ---*
	
.suiv4
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next4
	cmp.b	#acc_o,(a2)
	bne.s	.suiv4	
	
	move.l	(a0),a2			; alors erreur
	cmp.b	#op,(a2)
	bne	.s_teste2		; si le suivant est un - alors ok
	cmp.l	#adr_moins,3(a2)	; sinon ok
	bne	.erreur
.s_teste2

	cmp.b	#par_f,(a2)
	beq	.erreur	
	cmp.b	#acc_f,(a2)
	beq	.erreur	
	bra.s	.suiv4
.next4
	move.l	a1,a0

	*--- teste des nombres ---*
	
.suiv5
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next5
	cmp.b	#nb,(a2)
	bne.s	.suiv5	
	move.l	(a0),a2			; recupŠre l'objet suivant
	cmp.b	#label,(a2)
	beq	.erreur	
	cmp.b	#reg,(a2)
	beq	.erreur	
	cmp.b	#acc_o,(a2)
	beq	.erreur	
	cmp.b	#par_o,(a2)
	beq	.erreur	
	cmp.b	#nb,(a2)
	beq	.erreur	
	bra.s	.suiv5
.next5
	move.l	a1,a0

	*--- teste des registres ---*
	
.suiv6
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next6
	cmp.b	#reg,(a2)
	bne.s	.suiv6	
	move.l	(a0),a2			; recupŠre l'objet suivant
	cmp.b	#label,(a2)
	beq	.erreur	
	cmp.b	#reg,(a2)
	beq	.erreur	
	cmp.b	#acc_o,(a2)
	beq	.erreur	
	cmp.b	#par_o,(a2)
	beq	.erreur	
	cmp.b	#nb,(a2)
	beq	.erreur	
	bra.s	.suiv6
.next6
	move.l	a1,a0

	*--- teste des labels ---*
	
.suiv7
	move.l	(a0)+,a2
	cmp.b	#dernier,(a2)
	beq.s	.next7
	cmp.b	#label,(a2)
	bne.s	.suiv7	
	move.l	(a0),a2			; recupŠre l'objet suivant
	cmp.b	#label,(a2)
	beq	.erreur	
	cmp.b	#reg,(a2)
	beq	.erreur	
	cmp.b	#acc_o,(a2)
	beq	.erreur	
	cmp.b	#par_o,(a2)
	beq	.erreur	
	cmp.b	#nb,(a2)
	beq	.erreur	
	bra.s	.suiv7
.next7



.fin
	movem.l	(sp)+,d0-a6
	rts
	
.erreur
	move.b	#1,erreur
	bra.s	.fin
	
	
convert_type
***********************************************************
** routine qui va convertir les types point‚ par a1 & a2 **
** en nombre d0.d1    et   d2.d3                         **
***********************************************************
	clr.b	nbfloat1
	clr.b	nbfloat2
	
	
	pea	(a3)
	cmp.b	#nb,(a1)	; nombre ?
	bne.s	.p_nb1
	cmp.b	#float,1(a1)
	bne.s	.k
	
	addq.b	#1,nbfloat1
	fmove.x	TEMP_FLOAT,fp0
	fmove.x	fp0,float1
	clr.l	d0
	fmove.s	fp0,d1
	
	
	bra	.second
	
.k
	cmp.b	#double,1(a1)	; en double
	bne.s	.p_double1
	move.l	2(a1),d0
	move.l	6(a1),d1
	bra	.second
.p_double1
	cmp.b	#long,1(a1)	; en long
	bne.s	.p_long1
	clr.l	d0
	move.l	2(a1),d1
	bra	.second
.p_long1
	cmp.b	#word,1(a1)	; en word
	bne.s	.p_word1
	clr.l	d0
	clr.l	d1
	move.w	2(a1),d1	
	ext.l	d1
	bra	.second
.p_word1
	cmp.b	#byte,1(a1)	; en byte
	bne.s	.p_byte1
	clr.l	d0
	clr.l	d1
	move.b	2(a1),d1	; voir si on doit mettre le ext.l
	bra	.second
.p_byte1
.p_nb1
	cmp.b	#label,(a1)		; un label?
	bne.s	.p_label1
	clr.l	d0	
	move.l	2(a1),d1
	bra	.second
.p_label1
	
	cmp.b	#reg,(a1)
	bne	.p_reg1
	cmp.b	#dsp,4(a1)
	beq.s	.dsp1
	cmp.b	#x68,4(a1)
	beq.s	.x681
	
	cmp.b	#constante,4(a1)
	bne.s	.p_cst1
	move.l	adr_cst,a3
	bra.s	.next1
.p_cst1
	
	
	move.l	adr_reg_int,a3		; ici registres internes
	bra.s	.next1
.dsp1
	move.l	adr_reg_dsp,a3		; ici registres dsp
	bra.s	.next1
.x681
	move.l	adr_reg_68x,a3		; ici registres 68000
.next1

	clr.l	d0
	move.w	2(a1),d0
	add.l	d0,a3		; pointe sur le registre
	
	cmp.b	#dextend,1(a1)	; dsp etendu cad a&b
	bne.s	.p_extend1		; d0.d1
	
	move.l	(a3),d1
	and.l	#$ffffff,d1
	move.l	-(a3),d2	
	swap	d2
	lsl.l	#8,d2
	and.l	#$ff000000,d2
	or.l	d2,d1
	move.l	(a3),d2
	lsr.l	#8,d2
	move.l	d2,d0
	and.l	#$ffff,d0
	clr.l	d2
	move.b	-1(a3),d2
	and.l	#$ff,d2
	swap	d2
	or.l	d2,d0
	
	bra	.second	
.p_extend1
	
	cmp.b	#dlong,1(a1)	; dsp double word
	bne.s	.p_dlong1		; d0.d1
	
	move.l	(a3),d1
	and.l	#$ffffff,d1
	move.l	-(a3),d2	
	swap	d2
	lsl.l	#8,d2
	and.l	#$ff000000,d2
	or.l	d2,d1
	move.l	(a3),d2
	lsr.l	#8,d2
	move.l	d2,d0
	and.l	#$ffff,d0
	bra	.second	
.p_dlong1
	
	cmp.b	#dab,1(a1)
	bne.s	.p_dab
	move.l	d1,d4
	move.l	(a3),d1
	and.l	#$ffffff,d1
	move.l	adr_reg_dsp,a3
	add.l	#REG_A1,a3
	move.l	(a3),d0
	and.l	#$ff,d0
	swap	d0
	lsl.l	#8,d0
	or.l	d0,d1
	move.l	(a3),d0
	lsr.l	#8,d0
	bra	.second	
.p_dab
	cmp.b	#dba,1(a1)
	bne.s	.p_dba
	move.l	d1,d4
	move.l	(a3),d1
	and.l	#$ffffff,d1
	move.l	adr_reg_dsp,a3
	add.l	#REG_B1,a3
	move.l	(a3),d0
	and.l	#$ff,d0
	swap	d0
	lsl.l	#8,d0
	or.l	d0,d1
	move.l	(a3),d0
	lsr.l	#8,d0
	bra	.second	
.p_dba
	
	cmp.b	#float,1(a1)
	bne.s	.p_f11
	
	
	addq.b	#1,nbfloat1
	fmove.x	(a3),fp0
	fmove.x	fp0,float1
	
	
	clr.l	d0
	fmove.s	fp0,d1
	
	
	
	bra	.second
.p_f11
	
	
	cmp.b	#double,1(a1)
	bne.s	.p_d1		; d0.d1
	move.l	(a3),d0
	move.l	4(a3),d1

	
	bra	.second
.p_d1
	cmp.b	#long,1(a1)
	bne.s	.p_l1
	move.l	#0,d0
	move.l	(a3),d1
	bra	.second
.p_l1
	
	cmp.b	#dword,1(a1)
	bne.s	.p_dw1
	move.l	#0,d0
	move.l	(a3),d1
	and.l	#$ffffff,d1
	bra	.second
.p_dw1
	
	cmp.b	#word,1(a1)
	bne.s	.p_w1
	move.l	#0,d0
	clr.l	d1
	move.w	2(a3),d1
	ext.l	d1
	bra	.second
.p_w1
	cmp.b	#byte,1(a1)
	bne.s	.p_b1
	move.l	#0,d0
	clr.l	d1
	move.b	3(a3),d1	; voir pour le ext
				
	bra	.second
.p_b1	
	
	
.p_reg1
	illegal				; erreur
.second
	cmp.b	#nb,(a2)	; nombre ?
	bne.s	.p_nb2
	cmp.b	#float,1(a2)
	bne.s	.p_f
	addq.b	#1,nbfloat2
	fmove.x	TEMP_FLOAT,fp0
	fmove.x	fp0,float2
	clr.l	d2
	fmove.s	fp0,d3
	
	bra	.second1
.p_f
	cmp.b	#double,1(a2)	; en double
	bne.s	.p_double2
	move.l	2(a2),d2
	move.l	6(a2),d3
	bra	.second1
.p_double2
	cmp.b	#long,1(a2)	; en long
	bne.s	.p_long2
	clr.l	d2
	move.l	2(a2),d3
	bra	.second1
.p_long2
	cmp.b	#word,1(a2)	; en word
	bne.s	.p_word2
	clr.l	d2
	clr.l	d3
	move.w	2(a2),d3
	bra	.second1
.p_word2
	cmp.b	#byte,1(a2)	; en byte
	bne.s	.p_byte2
	clr.l	d2
	clr.l	d3
	move.b	2(a2),d3
	bra	.second1
.p_byte2
.p_nb2
	cmp.b	#label,(a2)		; un label?
	bne.s	.p_label2
	clr.l	d2
	move.l	2(a2),d3
	bra	.second1
.p_label2
	
	cmp.b	#reg,(a2)
	bne	.p_reg2
	cmp.b	#x68,4(a2)
	beq.s	.x682
	cmp.b	#dsp,4(a2)
	beq.s	.dsp2
	
	cmp.b	#constante,4(a1)
	bne.s	.p_cst2
	move.l	adr_cst,a3
	bra.s	.next2
.p_cst2

	
	
	move.l	adr_reg_int,a3		; ici registres internes
	bra.s	.next2
.dsp2	move.l	adr_reg_dsp,a3		; ici registres dsp
	bra.s	.next2
.x682	move.l	adr_reg_68x,a3		; ici registres 68000
.next2	clr.l	d2
	move.w	2(a2),d2
	add.l	d2,a3		; pointe sur le registre
	
	cmp.b	#dextend,1(a2)
	bne.s	.p_extend2
	
	move.l	(a3),d3
	and.l	#$ffffff,d3
	move.l	-(a3),d4	
	swap	d4
	lsl.l	#8,d4
	and.l	#$ff000000,d4
	or.l	d4,d3
	move.l	(a3),d4
	lsr.l	#8,d4
	move.l	d4,d2
	and.l	#$ffff,d2
	clr.l	d4
	move.b	-1(a3),d4
	and.l	#$ff,d4
	swap	d4
	or.l	d4,d2
	
	bra	.second1	
.p_extend2
	
	cmp.b	#dlong,1(a2)	; dsp double word
	bne.s	.p_dlong2		; d0.d1
	
	move.l	(a3),d3
	and.l	#$ffffff,d3
	move.l	-(a3),d4
	swap	d4
	lsl.l	#8,d4
	and.l	#$ff000000,d4
	or.l	d4,d3
	move.l	(a3),d4
	lsr.l	#8,d4
	move.l	d4,d2
	and.l	#$ffff,d2
	bra	.second1
.p_dlong2
	
	
	
	
	cmp.b	#dab,1(a2)
	bne.s	.p_dab1
	move.l	d2,d4
	move.l	(a3),d3
	and.l	#$ffffff,d3
	move.l	adr_reg_dsp,a3
	add.l	#REG_A1,a3
	move.l	(a3),d2
	and.l	#$ff,d2
	swap	d2
	lsl.l	#8,d2
	or.l	d2,d3
	move.l	(a3),d2
	lsr.l	#8,d2
	bra	.second1	
.p_dab1
	cmp.b	#dba,1(a2)
	bne.s	.p_dba1
	move.l	d3,d4
	move.l	(a3),d3
	and.l	#$ffffff,d3
	move.l	adr_reg_dsp,a3
	add.l	#REG_B1,a3
	move.l	(a3),d2
	and.l	#$ff,d2
	swap	d2
	lsl.l	#8,d2
	or.l	d2,d3
	move.l	(a3),d2
	lsr.l	#8,d2
	bra	.second1	
.p_dba1
	
	
	cmp.b	#float,1(a2)
	bne.s	.p_f112
	
	addq.b	#1,nbfloat2
	fmove.x	(a3),fp0
	fmove.x	fp0,float2
	
	clr.l	d2
	fmove.s	fp0,d3
	
	
	
	
	bra	.second1
.p_f112
	
	
	
	cmp.b	#double,1(a2)
	bne.s	.p_d2
	move.l	(a3),d2
	move.l	4(a3),d3
	bra	.second1
.p_d2
	cmp.b	#long,1(a2)
	bne.s	.p_l2
	move.l	#0,d2
	move.l	(a3),d3
	bra	.second1
.p_l2
	cmp.b	#dword,1(a2)
	bne.s	.p_dw2
	move.l	#0,d2
	move.l	(a3),d3
	and.l	#$ffffff,d3
	bra	.second1
.p_dw2
	cmp.b	#word,1(a2)
	bne.s	.p_w2
	move.l	#0,d2
	clr.l	d3
	move.w	2(a3),d3
	ext.l	d3
	bra	.second1
.p_w2
	cmp.b	#byte,1(a2)
	bne.s	.p_b2
	move.l	#0,d2
	clr.l	d3
	move.b	3(a3),d3
	bra	.second1
.p_b2
	
	
.p_reg2
	illegal				; erreur
	
	
	
.second1
	
	move.l	(sp)+,a3
	rts
	
inser_liste
*************************************************
** Routine qui va inserer d2.d3 dans la liste  **
** point‚e par a0-4 et qui va reduire la liste **
** de d7 objets ceux qui suivent : a0 et a0+4  **
*************************************************
	movem.l	d0-a6,-(sp)
	move.l	a0,a1
	subq.l	#4,a1		; on pointe sur le precedant
	
	move.l	(a1),a2
	move.b	#nb,(a2)+
	move.b	#long,(a2)+
	tst.l	d2
	beq.s	.p_double

	move.b	#double,-1(a2)
	
	move.l	d2,(a2)+
	
.p_double
	move.l	d3,(a2)+

	move.l	a0,a1
	lsl.l	#2,d7
	add.l	d7,a0		; pointe apres l'operateur de doite
.ins_chaine
	move.l	(a0)+,d0
	beq.s	.fin_ins
	move.l	d0,(a1)+
	bra.s	.ins_chaine
.fin_ins
	clr.l	(a1)
	movem.l	(sp)+,d0-a6
	rts



convert_mem_dsp
********************************
** routine qui va changer les **
** x:{} en {}.x  etc          **
********************************

	movem.l	d0-a6,-(sp)
	move.l	a0,a6

.yop
	move.l	a6,a0
.yop1
	clr.l	d7
	
	cmp.w	#'x:',(a0)
	bne.s	.p_x
	cmp.b	#'{',2(a0)
	bne.s	.p_x
	; trouve un x:{
.cop_ch
	move.b	2(a0),d0
	move.b	d0,(a0)
	cmp.b	#'{',d0
	bne.s	.p_ac_o
	addq.l	#1,d7	
.p_ac_o
	cmp.b	#'}',(a0)
	bne.s	.p_ac_f
	subq.l	#1,d7
	bne.s	.p_ac_f
	move.w	#'.x',1(a0)
	bra.s	.yop			; on continue
.p_ac_f	addq.l	#1,a0
	bra.s	.cop_ch
	
.p_x
	cmp.w	#'X:',(a0)
	bne.s	.p_X
	cmp.b	#'{',2(a0)
	bne.s	.p_X
	bra.s	.cop_ch
.p_X
	
	cmp.w	#'y:',(a0)
	bne.s	.p_y
	cmp.b	#'{',2(a0)
	bne.s	.p_y
	; trouve un y:
.cop_ch1
	move.b	2(a0),d0
	move.b	d0,(a0)
	cmp.b	#'{',d0
	bne.s	.p_ac_o1
	addq.l	#1,d7	
.p_ac_o1
	cmp.b	#'}',(a0)
	bne.s	.p_ac_f1
	subq.l	#1,d7
	bne.s	.p_ac_f1
	move.w	#'.y',1(a0)
	bra	.yop			; on continue
.p_ac_f1
	addq.l	#1,a0
	bra.s	.cop_ch1
	
.p_y
	cmp.w	#'Y:',(a0)
	bne.s	.p_Y
	cmp.b	#'{',2(a0)
	bne.s	.p_Y
	bra.s	.cop_ch1
.p_Y
	cmp.w	#'p:',(a0)
	bne.s	.p_p
	cmp.b	#'{',2(a0)
	bne.s	.p_p
	; trouve un p:
.cop_ch2
	move.b	2(a0),d0
	move.b	d0,(a0)
	cmp.b	#'{',d0
	bne.s	.p_ac_o2
	addq.l	#1,d7	
.p_ac_o2
	cmp.b	#'}',(a0)
	bne.s	.p_ac_f2
	subq.l	#1,d7
	bne.s	.p_ac_f2
	move.w	#'.p',1(a0)
	bra	.yop			; on continue
.p_ac_f2
	addq.l	#1,a0
	bra.s	.cop_ch2
	
.p_p
	cmp.w	#'P:',(a0)
	bne.s	.p_P
	cmp.b	#'{',2(a0)
	bne.s	.p_P
	bra.s	.cop_ch2
.p_P
	cmp.w	#'l:',(a0)
	bne.s	.p_l
	cmp.b	#'{',2(a0)
	bne.s	.p_l
	; trouve un l:
.cop_ch3
	move.b	2(a0),d0
	move.b	d0,(a0)
	cmp.b	#'{',d0
	bne.s	.p_ac_o3
	addq.l	#1,d7	
.p_ac_o3
	cmp.b	#'}',(a0)
	bne.s	.p_ac_f3
	subq.l	#1,d7
	bne.s	.p_ac_f3
	move.w	#'.m',1(a0)
	bra	.yop			; on continue
.p_ac_f3
	addq.l	#1,a0
	bra.s	.cop_ch3
	
.p_l
	cmp.w	#'L:',(a0)
	bne.s	.p_L
	cmp.b	#'{',2(a0)
	bne.s	.p_L
	bra.s	.cop_ch3
.p_L
	
	
	
	
	
	
	
	
	
	
	
	tst.b	(a0)+
	bne	.yop1
	
	movem.l	(sp)+,d0-a6
	rts



calcule_adresse::
*********************************************
** Routine qui va calculer l'adresse       **
** de destination derriŠre une instruction **
**                                         **
** Entr‚e                                  **
**   - a1 contient la chaine a analyser    **
** Sortie                                  **
**   - d0 = 0 pas d'adresse … afficher     **
**     d0 = 1 une adresse … afficher       **
**     d0 = 2 deux adresse … afficher      **
**   - la parite haute de d0 contient la   **
**     taille de l'instruction             **
**     2:byte 1:word 0:long 3:double       **
**   - d1 : premiŠre adresse … lire        **
**   - d2 : dexiŠme adresse … lire         **
*********************************************


	

	movem.l	d3-a6,-(sp)		; sauvegarde de registres de l'eval
	lea	buffer_int,a6
	move.l	r_e(a6),-(sp)
	move.l	r_e+4(a6),-(sp)
	
	
	moveq	#0,d0
	moveq	#0,d7			; pas de deplacement pc



	lea	temp_c,a0
.copi	addq.l	#1,a1			;se place sur un nb impair cad les lettre pas l'attrib
	move.b	(a1)+,d1
	move.b	d1,(a0)+
	tst.b	(a1)
	bne.s	.copi
	clr.l	(a0)
	


	lea	temp_c,a0
	move.l	a0,a3
	move.l	a0,a4			; copie de sauvegarde du pointeur chaine
.k	tst.b	(a0)			; sans parametre
	beq	.rien_a_faire
	cmp.b	#' ',(a0)+		; on cherche l'espace apres l'instruction
	bne.s	.k
	move.l	a0,a1

	cmp.b	#'B',-2(a0)		; regarde la taille sur laquelle opere l'instruction
	bne.s	.p_l
	move.l	#$20000,d0
.p_l	
	cmp.b	#'W',-2(a0)
	bne.s	.p_w
	move.l	#$10000,d0
.p_w
	cmp.b	#'X',-2(a0)
	bne.s	.p_x
	move.l	#$30000,d0
.p_x

	lea	temp_c,a6		; ici on va traiter a part le cas du movem.l
	cmp.w	#'M.',4(a6)
	bne.s	.p_movem
.ch_p	cmp.b	#')',(a6)+		; on cherche une )
	bne.s	.ch_p
	cmp.b	#',',(a6)		; si une virgule apres, alors on movem.l (....),registre
	beq.s	.io
	cmp.b	#',',1(a6)	
	bne.s	.az	
.io
	clr.b	(a6)			; on termine la chaine ok
	bra.s	.po
.az					; ici on a movem  registres,(....)
	cmp.b	#'(',-(a6)		; on donne comme chaine (....) et c'est tout
	bne.s	.az			; d'abord la (
.p_vir	cmp.b	#',',-(a6)		; puis la virgule pour le cas ou on a -(..)
	bne.s	.p_vir
	move.l	a6,a0
	move.l	a6,a1
.po	
	move.l	(a6),$426.w
.p_movem



	*---- Routine qui va tester si on a un nombre en adresse ----*

.is_nb
	tst.b	(a1)
	beq	.p_nb
	cmp.b	#'#',(a1)		; si on a une diese on passe au suivant
	bne.s	.p_diese
.cherch	tst	(a1)
	beq.s	.p_diese
	cmp.b	#',',(a1)+
	bne.s	.cherch
.p_diese
	cmp.b	#'$',(a1)		; on a un nb
	beq.s	.oui_nb		
	cmp.b	#'(',(a1)		; si '(' alors, pas de nb
	beq	.p_nb
	cmp.b	#'<',(a1)		; si '<' adressage non autorise
	beq.s	.p_nb
	cmp.b	#' ',(a1)		; si ' ' adressage non autorise
	beq.s	.p_nb
	cmp.b	#0,(a1)			; si 0 adressage non autorise
	beq.s	.p_nb
.oui_nb
	
	move.l	a1,a2
.test	tst.b	(a1)			; nb
	beq.s	.nb
	cmp.l	#'(PC)',(a1)		; on a un mode $xxxx(pc)
	beq.s	.nb
	cmp.b	#',',(a1)
	beq.s	.nb			; nb
	cmp.b	#'(',(a1)+	
	beq	.p_nb			; pas nb de la form xxxx(....)
	bra.s	.test
.nb	
	cmp.l	#'(PC)',(a1)
	bne.s	.p_pc_r
	move.l	#'+000',(a1)		; on change la chaine $xxx(pc) en $xxx+000
.p_pc_r
	move.l	a2,a1
	addq.l	#1,d0
	
	
	
	lea	temp_ch,a6		; prepare temp_ch qui va contenir la chaine a evaluer
.prep_c
	move.b	(a1),d6
	cmp.b	#',',d6
	bne.s	.p_v
	clr.b	d6
.p_v
	addq.l	#1,a1
	move.b	d6,(a6)+
	tst.b	d6
	bne.s	.prep_c
	
	
	
	
	
	
	movem.l	d0/d2/a0/a1,-(sp)
	lea	temp_ch,a0
	bsr.l	eval			; le resultat va dans d1
	tst.b	d2
	beq.s	.ok2
	movem.l	(sp)+,d0/d2/a0/a1
	subq.l	#1,d0			; un nombre en moins
	bra	.p_df
.ok2	movem.l	(sp)+,d0/d2/a0/a1
	move.l	d1,-(sp)		; on stocke d1 sur la pile
.p_df
	move.l	a1,a3
	bra	.is_nb



	*--- ici on n'a pas trouve quelque chose qui soit un nombre
	*--- donc, on va analyser le mode d'adressage


.p_nb

	move.l	a3,a1
.cherche
	tst.b	(a1)
	beq	.sortie
	cmp.b	#',',(a1)
	bne.s	.p
	addq.l	#1,a1
	move.l	a1,a3
	bra	.is_nb
.p
	cmp.b	#'(',(a1)+		; on teste s'il y a des paranthŠse ou crochets
	bne.s	.cherche		; s'il y en a il y a aussi des crochets
					; il y a au moins une paranthŠse
					; a1 point juste au d‚but de la chaine
	addq.l	#1,d0

	
	move.l	a1,a0
	subq.l	#2,a0
	
	
	lea	temp_ch,a6
	
	
	
.convert_ch
	move.b	(a1),d6			; ici c'est qu'on a un momvem d0-d2/d7 par exemple
	;cmp.b	#'/',(a1)
	;bne.s	.error
	;move.l	a3,a1
	;jmp	$e00030
	;bra	.cherche
	
;.error
	cmp.b	#'[',(a1)
	bne.s	.p_crochet_o
	move.b	#'{',d6			; on va remplacer par {
.p_crochet_o
	cmp.b	#']',(a1)
	bne.s	.p_crochet_f
	move.b	#'}',d6			; on va remplacer par }
.p_crochet_f
	cmp.b	#')',(a1)		; fin da la chaine
	bne.s	.p_paranthese_f
	move.b	#0,d6
.p_paranthese_f
	cmp.b	#',',(a1)
	bne.s	.p_virgule
	move.b	#'+',d6
.p_virgule				; pour l'instant on ne touche pas au pc
	cmp.w	#'pc',(a1)
	bne.s	.p_point_pc_min
	addq.l	#2,buffer_r+r_pc
.p_point_pc_min
	cmp.w	#'PC',(a1)
	bne.s	.p_point_pc_maj
	addq.l	#2,buffer_r+r_pc
.p_point_pc_maj

	addq.l	#1,a1
	move.b	d6,(a6)+
	tst.b	d6
	bne.s	.convert_ch




	*---- evaluation de la chaine et correction eventuelles -----*


	movem.l	d0/d2/a0,-(sp)
	lea	temp_ch,a0
	bsr.l	eval			; le resultat va dans d1
	tst.b	d2
	beq.s	.ok
	movem.l	(sp)+,d0/d2/a0
	subq.l	#1,d0			; un nombre en moins
	bra	.p_stk
.ok
	movem.l	(sp)+,d0/d2/a0
	

        *---- on va regarder le pr‚d‚cr‚ment‚ ----*
        
	cmp.b	#'-',(a0)		; on regarde s'il y a du predecrement‚
	bne.s	.p_pre_dec
	move.l	a4,a5			; on teste la taille pour le pr‚d‚cr‚ment‚
.k1	cmp.b	#'.',(a5)+
	bne.s	.k1	
	cmp.b	#'L',(a5)
	bne.s	.p_long
	subq.l	#4,d1	
	bra.s	.p_pre_dec
.p_long
	cmp.b	#'W',(a5)
	bne.s	.p_word
	subq.l	#2,d1	
	bra.s	.p_pre_dec
.p_word
	cmp.b	#'B',(a5)		
	bne.s	.p_byte
	cmp.l	#'(A7)',1(a0)		; cas de a7 on d‚cr‚mete de 2
	bne.s	.p_a7
	subq.l	#1,d1	
.p_a7
	subq.l	#1,d1	
	bra.s	.p_pre_dec
.p_byte
	subq.l	#1,d1			; on d‚cr‚mente de un si pas de taille
.p_pre_dec
	move.l	d1,-(sp)		; on stocke d1 sur la pile
	
	*--- fin de l'evaluation du mode predecremente ---*
	
	


.p_stk
	move.l	a1,a3
	bra	.cherche		; on continue la recherche
	
	
	
	*--- la routine de sortie avec ses mise de registe a 1
	
.sortie
	tst.b	d0
	beq.s	.rien_a_faire
	cmp.b	#1,d0			; une seule valeur
	bne.s	.p_un	
	move.l	(sp)+,d1
	bra.s	.rien_a_faire
.p_un
	move.l	(sp)+,d2		; deux valeurs
	move.l	(sp)+,d1
.rien_a_faire

	lea	buffer_int,a6
	move.l	(sp)+,r_e+4(a6)
	move.l	(sp)+,r_e(a6)
	movem.l	(sp)+,d3-a6
	
	xref	p_c
	move.l	p_c,buffer_r+r_pc


	rts




		include	eval.inc\convert.s 

	DATA

liste_registres
******************************
** d‚finition des registres **
******************************
dcs	macro
	dc.b	\1,\2
	dc.b	(\3)/256
	dc.b	(\3)&255
	dc.b	\4,\5
	endm
	
	
	
	dcs	9,'D0',r_d0,x68,long		; donn‚e 68
	dcs	9,'D1',r_d1,x68,long		
	dcs	9,'D2',r_d2,x68,long
	dcs	9,'D3',r_d3,x68,long
	dcs	9,'D4',r_d4,x68,long
	dcs	9,'D5',r_d5,x68,long
	dcs	9,'D6',r_d6,x68,long
	dcs	9,'D7',r_d7,x68,long
	dcs	9,'d0',r_d0,x68,long
	dcs	9,'d1',r_d1,x68,long
	dcs	9,'d2',r_d2,x68,long
	dcs	9,'d3',r_d3,x68,long
	dcs	9,'d4',r_d4,x68,long
	dcs	9,'d5',r_d5,x68,long
	dcs	9,'d6',r_d6,x68,long
	dcs	9,'d7',r_d7,x68,long
	
	dcs	9,'6A0',r_a0,x68,long		; adresse 68
	dcs	9,'6A1',r_a1,x68,long
	dcs	9,'6A2',r_a2,x68,long
	dcs	9,'A3',r_a3,x68,long
	dcs	9,'A4',r_a4,x68,long
	dcs	9,'A5',r_a5,x68,long
	dcs	9,'A6',r_a6,x68,long
	dcs	9,'A7',r_a7,x68,long
	dcs	9,'6a0',r_a0,x68,long
	dcs	9,'6a1',r_a1,x68,long
	dcs	9,'6a2',r_a2,x68,long
	dcs	9,'a3',r_a3,x68,long
	dcs	9,'a4',r_a4,x68,long
	dcs	9,'a5',r_a5,x68,long
	dcs	9,'a6',r_a6,x68,long
	dcs	9,'a7',r_a7,x68,long
	
	dcs	9,'6sr',r_sr,x68,word
	dcs	9,'6SR',r_sr,x68,word
	
	dcs	9,'ssp',r_ssp,x68,long
	dcs	9,'SSP',r_ssp,x68,long
	
	dcs	9,'msp',r_msp,x68,long
	dcs	9,'MSP',r_msp,x68,long
	
	dcs	9,'usp',r_usp,x68,long
	dcs	9,'USP',r_usp,x68,long
	
	dcs	9,'sp',r_a7,x68,long
	dcs	9,'SP',r_a7,x68,long
	
	
	dcs	9,'6pc',r_pc,x68,long
	dcs	9,'6PC',r_pc,x68,long
	
	dcs	9,'vbr',r_vrb,x68,long
	dcs	9,'VBR',r_vrb,x68,long
	
	dcs	9,'cacr',r_cacr,x68,long
	dcs	9,'CACR',r_cacr,x68,long
	
	dcs	9,'caar',r_caar,x68,long
	dcs	9,'CAAR',r_caar,x68,long
	
	dcs	9,'mmusr',r_mmusr,x68,long
	dcs	9,'MMUSR',r_mmusr,x68,long
	
	dcs	9,'CRP',r_crp,x68,double
	dcs	9,'crp',r_crp,x68,double
	
	dcs	9,'SRP',r_srp,x68,double
	dcs	9,'srp',r_srp,x68,double
	
	dcs	9,'sfc',r_sfc,x68,long
	dcs	9,'SFC',r_sfc,x68,long
	
	dcs	9,'dfc',r_dfc,x68,long
	dcs	9,'DFC',r_dfc,x68,long
	
	dcs	9,'tt0',r_tt0,x68,long
	dcs	9,'TT0',r_tt0,x68,long
	
	dcs	9,'tt1',r_tt1,x68,long
	dcs	9,'TT1',r_tt1,x68,long
	
	dcs	9,'tc',r_tc,x68,long
	dcs	9,'TC',r_tc,x68,long
	
	dcs	9,'dttr0',r_dttr0,x68,long
	dcs	9,'DTTR0',r_dttr0,x68,long
	
	dcs	9,'dttr1',r_dttr1,x68,long
	dcs	9,'DTTR1',r_dttr1,x68,long
	
	dcs	9,'ittr0',r_ittr0,x68,long
	dcs	9,'ITTR0',r_ittr0,x68,long
	
	dcs	9,'ittr1',r_ittr1,x68,long
	dcs	9,'ITTR1',r_ittr1,x68,long
	
	dcs	9,'ittr1',r_ittr1,x68,long
	dcs	9,'ITTR1',r_ittr1,x68,long
	
	dcs	9,'fp0',r_fp0,x68,float
	dcs	9,'fp1',r_fp1,x68,float
	dcs	9,'fp2',r_fp2,x68,float
	dcs	9,'fp3',r_fp3,x68,float
	dcs	9,'fp4',r_fp4,x68,float
	dcs	9,'fp5',r_fp5,x68,float
	dcs	9,'fp6',r_fp6,x68,float
	dcs	9,'fp7',r_fp7,x68,float
	
	dcs	9,'FP0',r_fp0,x68,float
	dcs	9,'FP1',r_fp1,x68,float
	dcs	9,'FP2',r_fp2,x68,float
	dcs	9,'FP3',r_fp3,x68,float
	dcs	9,'FP4',r_fp4,x68,float
	dcs	9,'FP5',r_fp5,x68,float
	dcs	9,'FP6',r_fp6,x68,float
	dcs	9,'FP7',r_fp7,x68,float
	
	
	dcs	9,'FPCR',r_fpcr,x68,long
	dcs	9,'FPSR',r_fpsr,x68,long
	dcs	9,'FPIAR',r_fpiar,x68,long
	
	dcs	9,'fpcr',r_fpcr,x68,long
	dcs	9,'fpsr',r_fpsr,x68,long
	dcs	9,'fpiar',r_fpiar,x68,long
	
	
	*--- les registre internes ---*
	
	
	dcs	9,'I0',r_i0,int,long		; internes
	dcs	9,'I1',r_i1,int,long		
	dcs	9,'I2',r_i2,int,long
	dcs	9,'I3',r_i3,int,long
	dcs	9,'I4',r_i4,int,long
	dcs	9,'I5',r_i5,int,long
	dcs	9,'I6',r_i6,int,long
	dcs	9,'I7',r_i7,int,long
	dcs	9,'i0',r_i0,int,long
	dcs	9,'i1',r_i1,int,long
	dcs	9,'i2',r_i2,int,long
	dcs	9,'i3',r_i3,int,long
	dcs	9,'i4',r_i4,int,long
	dcs	9,'i5',r_i5,int,long
	dcs	9,'i6',r_i6,int,long
	dcs	9,'i7',r_i7,int,long
	
	
	dcs	9,'TEXT',r_text,int,long
	dcs	9,'text',r_text,int,long
	dcs	9,'DATA',r_data,int,long
	dcs	9,'data',r_data,int,long
	dcs	9,'BSS',r_bss,int,long
	dcs	9,'bss',r_bss,int,long
	
	dcs	9,'e',r_e,int,double
	dcs	9,'E',r_e,int,double
	
	
	*--- Les registres DSP ---*
	
	dcs	9,'x0',REG_X0,dsp,dword		; x	dsp
	dcs	9,'X0',REG_X0,dsp,dword
	dcs	9,'x1',REG_X1,dsp,dword
	dcs	9,'X1',REG_X1,dsp,dword
	
	dcs	9,'y0',REG_Y0,dsp,dword		; y	dsp
	dcs	9,'y0',REG_Y0,dsp,dword
	dcs	9,'y1',REG_Y1,dsp,dword
	dcs	9,'y1',REG_Y1,dsp,dword
	
	dcs	9,'r0',REG_R0,dsp,dword		; r	dsp
	dcs	9,'r1',REG_R1,dsp,dword
	dcs	9,'r2',REG_R2,dsp,dword
	dcs	9,'r3',REG_R3,dsp,dword
	dcs	9,'r4',REG_R4,dsp,dword
	dcs	9,'r5',REG_R5,dsp,dword
	dcs	9,'r6',REG_R6,dsp,dword
	dcs	9,'r7',REG_R7,dsp,dword
	dcs	9,'R0',REG_R0,dsp,dword
	dcs	9,'R1',REG_R1,dsp,dword
	dcs	9,'R2',REG_R2,dsp,dword
	dcs	9,'R3',REG_R3,dsp,dword
	dcs	9,'R4',REG_R4,dsp,dword
	dcs	9,'R5',REG_R5,dsp,dword
	dcs	9,'R6',REG_R6,dsp,dword
	dcs	9,'R7',REG_R7,dsp,dword
	
	dcs	9,'n0',REG_N0,dsp,dword		; n	dsp
	dcs	9,'n1',REG_N1,dsp,dword
	dcs	9,'n2',REG_N2,dsp,dword
	dcs	9,'n3',REG_N3,dsp,dword
	dcs	9,'n4',REG_N4,dsp,dword
	dcs	9,'n5',REG_N5,dsp,dword
	dcs	9,'n6',REG_N6,dsp,dword
	dcs	9,'n7',REG_N7,dsp,dword
	dcs	9,'N0',REG_N0,dsp,dword
	dcs	9,'N1',REG_N1,dsp,dword
	dcs	9,'N2',REG_N2,dsp,dword
	dcs	9,'N3',REG_N3,dsp,dword
	dcs	9,'N4',REG_N4,dsp,dword
	dcs	9,'N5',REG_N5,dsp,dword
	dcs	9,'N6',REG_N6,dsp,dword
	dcs	9,'N7',REG_N7,dsp,dword
	
	dcs	9,'m0',REG_M0,dsp,dword		; M	dsp
	dcs	9,'m1',REG_M1,dsp,dword
	dcs	9,'m2',REG_M2,dsp,dword
	dcs	9,'m3',REG_M3,dsp,dword
	dcs	9,'m4',REG_M4,dsp,dword
	dcs	9,'m5',REG_M5,dsp,dword
	dcs	9,'m6',REG_M6,dsp,dword
	dcs	9,'m7',REG_M7,dsp,dword
	dcs	9,'m0',REG_M0,dsp,dword
	dcs	9,'M1',REG_M1,dsp,dword
	dcs	9,'M2',REG_M2,dsp,dword
	dcs	9,'M3',REG_M3,dsp,dword
	dcs	9,'M4',REG_M4,dsp,dword
	dcs	9,'M5',REG_M5,dsp,dword
	dcs	9,'M6',REG_M6,dsp,dword
	dcs	9,'M7',REG_M7,dsp,dword
	
	
	dcs	9,'A',REG_A0,dsp,dextend
	dcs	9,'a',REG_A0,dsp,dextend
	
	dcs	9,'A10',REG_A0,dsp,dlong
	dcs	9,'a10',REG_A0,dsp,dlong
	
	dcs	9,'B',REG_B0,dsp,dextend
	dcs	9,'b',REG_B0,dsp,dextend
	
	dcs	9,'B10',REG_B0,dsp,dlong
	dcs	9,'b10',REG_B0,dsp,dlong
	
	dcs	9,'AB',REG_B1,dsp,dab
	dcs	9,'ab',REG_B1,dsp,dab
	
	dcs	9,'BA',REG_A1,dsp,dba
	dcs	9,'ba',REG_A1,dsp,dba
	
	
	dcs	9,'X',REG_X0,dsp,dlong
	dcs	9,'x',REG_X0,dsp,dlong
	
	dcs	9,'Y',REG_Y0,dsp,dlong
	dcs	9,'y',REG_Y0,dsp,dlong
	
	
	dcs	9,'da0',REG_A0,dsp,dword		; a 	dsp
	dcs	9,'da1',REG_A1,dsp,dword
	dcs	9,'da2',REG_A2,dsp,byte
	dcs	9,'DA0',REG_A0,dsp,dword
	dcs	9,'DA1',REG_A1,dsp,dword
	dcs	9,'DA2',REG_A2,dsp,byte
	
	dcs	9,'b0',REG_B0,dsp,dword		; b 	dsp
	dcs	9,'b1',REG_B1,dsp,dword
	dcs	9,'b2',REG_B2,dsp,byte
	dcs	9,'B0',REG_B0,dsp,dword
	dcs	9,'B1',REG_B1,dsp,dword
	dcs	9,'B2',REG_B2,dsp,byte
	
	
	
	dcs	9,'LA',REG_LA,dsp,dword
	dcs	9,'la',REG_LA,dsp,dword
	
	dcs	9,'LC',REG_LC,dsp,dword
	dcs	9,'lc',REG_LC,dsp,dword
	
	dcs	9,'SSL',REG_SSL,dsp,dword
	dcs	9,'ssl',REG_SSL,dsp,dword
	
	dcs	9,'SSH',REG_SSH,dsp,dword
	dcs	9,'ssh',REG_SSH,dsp,dword
	
	dcs	9,'DPC',REG_PC,dsp,dword
	dcs	9,'dpc',REG_PC,dsp,dword
	

	*---------------------*
	* les adresses des fenetres
	*---------------------*

	dcs	9,'w0',r_w0,int,long
	dcs	9,'w1',r_w1,int,long
	dcs	9,'w2',r_w2,int,long
	dcs	9,'w3',r_w3,int,long
	dcs	9,'w4',r_w4,int,long
	dcs	9,'w5',r_w5,int,long
	dcs	9,'w6',r_w6,int,long
	dcs	9,'w7',r_w7,int,long
	dcs	9,'w8',r_w8,int,long
	dcs	9,'w9',r_w9,int,long
	dcs	9,'w10',r_w10,int,long
	dcs	9,'w11',r_w11,int,long
	dcs	9,'w12',r_w12,int,long
	dcs	9,'w13',r_w13,int,long
	dcs	9,'w14',r_w14,int,long
	dcs	9,'w15',r_w15,int,long
	dcs	9,'w16',r_w16,int,long
	dcs	9,'w17',r_w17,int,long
	dcs	9,'w18',r_w18,int,long
	dcs	9,'w19',r_w19,int,long
	dcs	9,'w20',r_w20,int,long
	dcs	9,'w21',r_w21,int,long
	dcs	9,'w22',r_w22,int,long
	dcs	9,'w23',r_w23,int,long
	dcs	9,'w24',r_w24,int,long
	dcs	9,'w25',r_w25,int,long
	dcs	9,'w26',r_w26,int,long
	dcs	9,'w27',r_w27,int,long
	dcs	9,'w28',r_w28,int,long
	dcs	9,'w29',r_w29,int,long
	dcs	9,'w30',r_w30,int,long
	dcs	9,'w31',r_w31,int,long


	dcs	9,'W0',r_w0,int,long
	dcs	9,'W1',r_w1,int,long
	dcs	9,'W2',r_w2,int,long
	dcs	9,'W3',r_w3,int,long
	dcs	9,'W4',r_w4,int,long
	dcs	9,'W5',r_w5,int,long
	dcs	9,'W6',r_w6,int,long
	dcs	9,'W7',r_w7,int,long
	dcs	9,'W8',r_w8,int,long
	dcs	9,'W9',r_w9,int,long
	dcs	9,'W10',r_w10,int,long
	dcs	9,'W11',r_w11,int,long
	dcs	9,'W12',r_w12,int,long
	dcs	9,'W13',r_w13,int,long
	dcs	9,'W14',r_w14,int,long
	dcs	9,'W15',r_w15,int,long
	dcs	9,'W16',r_w16,int,long
	dcs	9,'W17',r_w17,int,long
	dcs	9,'W18',r_w18,int,long
	dcs	9,'W19',r_w19,int,long
	dcs	9,'W20',r_w20,int,long
	dcs	9,'W21',r_w21,int,long
	dcs	9,'W22',r_w22,int,long
	dcs	9,'W23',r_w23,int,long
	dcs	9,'W24',r_w24,int,long
	dcs	9,'W25',r_w25,int,long
	dcs	9,'W26',r_w26,int,long
	dcs	9,'W27',r_w27,int,long
	dcs	9,'W28',r_w28,int,long
	dcs	9,'W29',r_w29,int,long
	dcs	9,'W30',r_w30,int,long
	dcs	9,'W31',r_w31,int,long

	*---------------------*
	
	
	*--- Les registres ambigus ---*
	
	dcs	9,'A0',dep_a0,undef,long		; adresse 68
	dcs	9,'A1',dep_a1,undef,long
	dcs	9,'A2',dep_a2,undef,long
	dcs	9,'a0',dep_a0,undef,long
	dcs	9,'a1',dep_a1,undef,long
	dcs	9,'a2',dep_a2,undef,long
	dcs	9,'pc',dep_pc,undef,long
	dcs	9,'PC',dep_pc,undef,long
	dcs	9,'sr',dep_sr,undef,long		
	dcs	9,'SR',dep_sr,undef,long
	
	*-----------------------------*
	
	
	
	
	dc.b	$ff,$ff,$ff,$ff
	even



	
list
	
	
	
	*--- Les constantes ---*
	
	
	
	
	
	
	dcs	9,'constante',r_d0,constante,long
	
	
	
	*-----------------------------*
	dc.l	$ffffffff
	
	even
	
	
	
	
	


table_excep
	dc.w	r_pc,long
	dc.w	REG_PC,dword
	dc.w	r_sr,word
	dc.w	REG_SR,dword
	dc.w	r_a0,long
	dc.w	REG_A0,dword
	dc.w	r_a1,long
	dc.w	REG_A1,dword
	dc.w	r_a2,long
	dc.w	REG_A2,byte


liste_operateurs
*******************************
** d‚finition des op‚rateurs **
*******************************
	;dc.b	'symbole (la chaine doit faire 3 espace)',priorite,type … gauche,type … droite	
	
	
	dc.b	'+  ',3,tout,tout	; op‚ simples
	dc.l	adr_plus
	dc.b	'-  ',3,tout,tout
	dc.l	adr_moins
	dc.b	'*  ',4,tout,tout
	dc.l	adr_mult
	dc.b	'/  ',4,tout,tout
	dc.l	adr_divise
	dc.b	'=  ',1,reg,tout
	dc.l	adr_affecte
	dc.b	'<  ',2,tout,tout
	dc.l	adr_inf_strict
	dc.b	'>  ',2,tout,tout
	dc.l	adr_sup_strict
	dc.b	'&  ',2,tout,tout
	dc.l	adr_et
	dc.b	'|  ',2,tout,tout
	dc.l	adr_ou
	dc.b	'^  ',2,tout,tout
	dc.l	adr_ou_ex
	dc.b	'!  ',5,tout,tout
	dc.l	adr_non
	
	dc.b	'<> ',2,tout,tout	; op‚ doubles
	dc.l	adr_different
	dc.b	'<= ',2,tout,tout
	dc.l	adr_inf_egal
	dc.b	'=< ',2,tout,tout
	dc.l	adr_inf_egal
	dc.b	'>= ',2,tout,tout
	dc.l	adr_sup_egal
	dc.b	'=> ',2,tout,tout
	dc.l	adr_sup_egal
	dc.b	'== ',2,tout,tout
	dc.l	adr_egal_egal
	
	dc.l	0

nombre_vide	dc.b	nb,long,0,0,0,0		; stockage de zero en long
		even


chaine
		dc.b	'd0={((1+2)*3)+1}+1',0
		dc.b	'1+2*3+1+2*3+2*3*3',0
		;dc.b	'd0-d7',0
		;dc.b	'd0=d0+1+2*3+1+2*3+2*3*3',0	
		;dc.b	'd0=sr',0
		even

		SECTION DATA





AUTO_IO::	dc.w	0	; autorise ou non les io


	*--- liste des constantes ---*
	
	
	







		SECTION BSS

const		ds.w	1
const_e		ds.w	1
liste_const	ds.l	1

TEMP_FLOAT	ds.l	1

temp_para	ds.b	256	; buffer pour le test de paranthŠse

buf_undef	ds.l	1	; le buffer qui sert si on a un pc ou sr ou a0..a1 soit dsp ou 68

sp_save		ds.l	1

nbfloat1	ds.b	1
nbfloat2	ds.b	1
float1		ds.l	3
float2		ds.l	3

erreur		ds.b	1
		even
temp_chaine	ds.b	300
chaine_nombre	ds.b	200
liste_chaine	ds.b	1000
point_chaine	ds.l	200		; 200 ‚l‚m‚nents

adr_cst		ds.l	1
adr_reg_68x	ds.l	1		; pointeur sur les registres 68000
adr_reg_dsp	ds.l	1		; pointeur sur les registres dsp
adr_reg_int	ds.l	1
temp_ch		ds.b	50		; buffer pour le calcul d'adresse
temp_c		ds.b	50		; buffer pour le calcul d'adresse
yopiii		ds.l	1

