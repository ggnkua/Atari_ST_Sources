 		**************************************************    
		***               CENTINEL                      ***
		***                                             ***
		***  CCCC EEEE N  N TTTTT IIIII N  N EEEE L     ***
		***  C    E    NN N   T     I   NN N E    L     ***
		***  C    EEE  N NN   T     I   N NN EEE  L     ***
		***  C    E    N NN   T     I   N NN E    L     ***
		***  C    E    N  N   T     I   N  N E    L     ***
		***  CCCC EEEE N  N   T   IIIII N  N EEEE LLLL  ***
		***                                             ***
		***************************************************









;        _/_/_/_/_/                                        \_\_\_\_\_      
;       _/_/_/_/_/           Ronan      CARDAUT             \_\_\_\_\_
;      _/_/_/_/_/                                            \_\_\_\_\_
;     _/_/_/_/_/             Stephane   BARRE                 \_\_\_\_\_
;    _/_/_/_/_/                                                \_\_\_\_\_





; il m'enerve ce make file
; il m'enerve ce make file
; il m'enerve ce make file
; il m'enerve ce make file
; il m'enerve ce make file






debug	macro
	
	ifne	debug_var
	
	pea	.text\@(pc)
	move.w	#9,-(sp)
	;trap	#1
	addq.l	#6,sp
	bra.s	.toto\@
.text\@
	
	dc.b	\1,$d,$a,0
	even
.toto\@

	
	
	movem.l	d0-a6,-(sp)
	move.w	#50000,d7
.vsync\@
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	dbra	d7,.vsync\@
	
	movem.l	(sp)+,d0-a6 


	endif
	
	endm

	


*******************************************
** etat trace                            **
**    =0 on sauve et remet la resolution ** 
**    =1 on ne touche pas                **
**    =2 on restore seulement            **
*******************************************


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

******************************************************
** - Remmettre en fonctionnement la linef detourn‚e **
** - Petit bug lors du rappel de lignes             **
******************************************************
	MC68030
	
	
	mc68881

	include	d:\centinel\both\define.s
	output	d:\centinel\40\cent_bug.o
	incdir	d:\centinel\40
	
	
	include	d:\centinel\both\GEM.EQU
	include	d:\centinel\both\LOCALMAC.S
	
	include 40\macros.s


	xref 	affiche_nombre,affiche_nombre_2,affiche_nombre_zero,nombre
	xref	dessas_one,m
	xref	get_key,GET_CHAINE
	xref	eval,calcule_adresse
	xref	end		;permet de connaitre la longueur du prog
	xref	ACTIVE_WINDOW,AFFICHE,PETIT_MESSAGE
	xref	LOG,MESSAGE_ADR
	xref	COL_ADR,COL_NOR,COL_LAB,COL_FCT,COL_REG,COL_CHG,COL_BKPT,COL_ERR_L,ATTRIBUTE,COL_MENU,COL_DSP
	xref	adresse,EVALUATEUR
	xref	set_all_flags,set_40_flags
	xref	WORK_BUF,DSP_CHARGE_AUTO
	xref	IO_SIZE,ASCII_BUF
	xref	r_load,load,enleve_fonction,prepare_fct_det,trouve_ligne,go1,r_put_history
	


DEBUT::
	bra	start

	dc.b	'Yop.'	
start

	*---------------*
	* MSHRINK
	*---------------*




	move.L	4(sp),a0
	move.l	a0,a5
	move.l	a0,BASE_PAGE
	
	lea	pile_deb,a7
	
	move.l	$2c(a0),P_ENV
	move.l	12(a0),a1	; text
	add.l	20(a0),a1	; +data
	add.l	28(a0),a1	; +bss
	add.l	#256,a1		; + base page
	move.l	a1,LONG_PROG	; = taille programme
	pea	(a1)
	pea	(a0)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bne	fin_tout_cours			; on quitte si pas bon ...





	
	
	*---------------*
	* mise en place d'une BASE_PAGE bidon
	*---------------*
;	lea	BASE_PAGE,a0
;	move.w	#256/4-1,d0
;.CLR	clr.l	(a0)+
;	dbra	d0,.CLR	
;	move.l	#BASE_PAGE,BASE_PAGE	
	*---------------*



	move	#$2f,-(sp)
	trap	#1		;fget DTA
	addq	#2,sp
	move.l	d0,s_dta
	
	
	

	move.l	a5,a0				; on recupere la pile pour la ligne de commande
	lea	128(a0),a0
	

	*---------------*
	* extrait les parametres de la ligne de commande
	* nom fichier dsp, 040
	*---------------*
	xref	TRAITE_LIGNE_DE_COMMANDE
	bsr.l	TRAITE_LIGNE_DE_COMMANDE
	*---------------*


	clr.l	-(sp)				; passage en superviseur
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	
	
	move.l	d0,sauve_la_pile
	lea	autre_pile,a7			; on installe notre pile
	;move.l	d0,a7

	*---------------*
	* v‚rifie si le d‚bugueur
	* est dans le dossier auto
	* et place le flag_res en fonction
	*---------------*
	xref	CHECK_AUTO
	bsr.l	CHECK_AUTO
	
	
	
		
	*---------------*
	* trouve le CENTINEL_PATH
	*---------------*
	move.l	P_ENV,a0	
	xref	CENTINEL_PATH
	xref	SAVE_CENTINEL_PATH
	bsr.l	SAVE_CENTINEL_PATH

	*---------------*
	* trouve le INIT_PATH
	*---------------*
	xref	SAVE_INIT_PATH
	bsr.l	SAVE_INIT_PATH


	;move.l	#$e00000,MEM_HAUTE		; mise en place de la
						; limite memoire haute
	move.l	#system_start,buffer_int+r_text
	move.l	#system_start,buffer_int+r_data
	move.l	#system_start,buffer_int+r_bss

	clr	etat_trace
	


	clr.w	replay_macro
	clr.w	record_macro
	
	clr.l	trap_david
	clr.w	go_david
	clr.l	nb_symbols
	
	
	
	xref	t_buf,buffer_cou_t
	move.l	#t_buf,buffer_cou_t

	clr.w	CMD_L
	clr.l	buf_label
	clr.l	adr_label
	clr.l	hash_table
	
	lea	liste_mfree,a0
	moveq	#49,d0
.clr_l	clr.l	(a0)+
	dbra	d0,.clr_l
	






************************************
** on va detecter le type de proc **
************************************
	
	move.l	$10.w,-(sp)
	move.l	#.ille,$10.w
	move.l	a7,a_pile			; on sauve_la pile
	lea	pile_test,a7
	
	
	dc.w	%0100111001111010		; movec	pcr,d0
	dc.w	$0808
	move.w	#cpu_60,CPU_TYPE
	bra.s	.p_illegal
	
.ille
	move.l	#.illegal,$10.w
	movec	urp,d0				; instruc 68040
	move.w	#cpu_40,CPU_TYPE
	bra.s	.p_illegal
.illegal
	move.l	#.illegal1,$10.w
	movec	usp,d0				; instruc 68030
	move.w	#cpu_30,CPU_TYPE
	bra.s	.p_illegal
.illegal1
	move.w	#cpu_bad,CPU_TYPE
	

.p_illegal
	
	move.l	a_pile,a7
	move.l	(sp)+,$10.w


	cmp.w	#cpu_bad,CPU_TYPE		; on a pas le bon proc
	beq	fin_tout_cours_d





	*---------------*
	* v‚rifie si le d‚bugueur
	* est dans le dossier auto
	*---------------*
	xref	CHECK_AUTO
	bsr.l	CHECK_AUTO
	
	tst.b	flag_res			; on teste si on daoit rendre residant
	beq.s	.ok_res
	
	
	
	lea	$c.w,a0			; on verifie que centinel n'est pas deja en memoire
	add.l	ADR_VBR,a0
	move.l	(a0),a0
	cmp.l	#'inel',-4(a0)
	bne.s	.ok_res
	
	beq	fin_tout_cours_d
.ok_res
	
	sf	RESIDENT1
	
	lea	$c.w,a0			; on verifie que centinel n'est pas deja en memoire
	add.l	ADR_VBR,a0
	move.l	(a0),a0
	cmp.l	#'inel',-4(a0)
	bne.s	.ok_res1
	
	st	RESIDENT1		; a t on une version residente
	
.ok_res1
	
	
	
	
	
	
	;st	flag_res		; ici lorque cette ligne est mise
					; centinel devient resident
					; s'il n'est pas dans le dossier auto....
		
	
	
	*---------------*
	* Lit le CENTINEL.INF au d‚marrage de CENTINEL
	*---------------*
	debug	<'av pref'>
	
	xref	BOOT_PREFS
	bsr.l	BOOT_PREFS
		

	
	;xref	PREF_NAME	
	;xref	READ_PREFS
	;lea	PREF_NAME,a0
	;bsr.l	READ_PREFS


	debug	<'av init vid'>


	*---------------*
	* INIT VIDEO
	*---------------*

	xref	INIT_VIDEO
	bsr.l	INIT_VIDEO	
	
	debug	<'aapres init vid'>
	
	
	
	pea	buf_dta				; installation du buffer dta
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp




	bsr.l	INIT_DEBUG			; initialisation du debugger
	
	
	
	
	move.w	#7,IPL_INT
	move.w	#0,clavier_pourri		; on active le clavier systeme
	
	tst.w	clavier_pourri
	bne.s	.oui
	
	move.w	#$2700,sr
	bra.s	.non
.oui
	move.w	#$2300,sr
	
.non	
	
	
	
	
	move.w	$454,d0
	beq.s	.skip
	move.l	$456.w,a0

	addq	#4,a0				;ATTENTION pour compatibilit‚ TOS !!

.k	tst.l	(a0)+
	beq.s	.found
	subq.l	#1,d0				; cherche empl libre
	bne.s	.k
	bra.s	.skip				; plus de place
	
.found
	move.l	#catch_alt_help,-(a0)
	move.l	a0,s_p_queue
.skip	
	moveq	#0,d0
	move.l	#0,a0

	
	*-- permet l'interruption des programmes --*
	




	bra.s	TRACE			; pour reperer si c'est un detournement centinel
	dc.b	'CENTinel'
	
*************************************
** Le noyau principal du debuggeur **
*************************************

	
	
TRACE::
	
	move.w	#$2700,sr		; on va regarder si on doit utiliser ou non le clavier systeme


	
	btst	#2,$c(a7)		; test erreur d'atc
	beq.s	.pas_mmu_error
	
	*--- que faire ? ---*
	
	nop		
	
	
.pas_mmu_error
	

	
	
	
	tst.w	nb_fct_det	; on teste si on a un detournement de fonction
	beq	.p_fct_de
	cmp.b	#$84,7(sp)	; on test esi c'est un trap, sinon pas de branchement
	blt	.p_fct_de
	cmp.b	#$80+15*4,7(sp)
	bgt	.p_fct_de
	
	move.l	a7,a_pile			; on sauve_la pile
	lea	pile_prog,a7			; on installe notre pile

	movem.l	d0/d1/d2/d7/a0/a1/a2,-(sp)
	move.l	a_pile,a2
	
	lea	table_fct_det,a0
	
	
	moveq	#0,d7
	move.w	nb_fct_det,d7
	
	;move.w	6+6*4(sp),d1	; on a sauve 6 long
	move.w	6(a2),d1	; on a sauve 6 long
.cherche_table	
	move.w	(a0),d0
	lsl	#2,d0
	add.l	#$80,d0
	
	and.w	#$fff,d1
	cmp.w	d0,d1
	bne	.p_excep	; ici on a trouve que le trap correspondant au detournenement


	move.w	2(a0),d0
	and.w	#$1ff,d0
	cmp.w	#$100,d0
	beq	.trap_t_cours		; on a un trap on ne tient pas compte des fonctions
	
	;btst	#5,5*4(sp)
	btst	#5,(a2)
	bne.s	.super1
	move.l	usp,a1
	bra.s	.util
.super1
	;lea	8+6*4(sp),a1
	lea	8(a2),a1

.util
	cmp.w	#$88,d1			; ici on regarde si on a un trap 2
	bne	.p_trap2
	
	; move.l	(sp)			;d0
	; move.l	4(sp)			;d1
	
	
	move.w	2(a0),d0
	and.w	#$1ff,d0
	cmp.w	#$f00,d0		; on a soit de l'aes soit de la vdi
	bne.s	.p_seule
	
	
	cmp.w	#$c8,2(sp)		; a t on d0=c8
	bne.s	.vdi
	btst	#b_aes,2(a0)
	bne	.trap_t_cours
	bra	.p_excep
.vdi
	cmp.w	#$73,(sp)
	bne	.p_excep
	btst	#b_vdi,2(a0)
	bne	.trap_t_cours
	bra	.p_excep
.p_seule
	
	;** arriv‚ ici il faut regarder le tableau pour savoir si on a le num de la fonction
	
	cmp.w	#$c8,2(sp)
	bne	.aes
	btst	#b_aes,2(a0)
	beq	.p_excep		; ici, on a une fct aes
	
	move.l	4(sp),d1
	move.l	d1,a1
	lit_mem.l	a1,d1		; ptr sur la fonction
	tst.b	ERR_MEM
	bne	.p_excep
	move.l	d1,a1
	clr.l	d1
	lit_mem.w	a1,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_excep		; dans d1 le num de la fct
	
	move.w	2(a0),d0
	and.w	#$fff,d0
	cmp.w	d1,d0
	beq	.trap_t_cours
	bra	.p_excep
	
	
	
.aes
	cmp.l	#$73,(sp)
	bne	.p_excep
	btst	#b_vdi,2(a0)		; ici, on a une fct vdi
	beq	.p_excep
	
	
	move.l	4(sp),d1
	move.l	d1,a1
	lit_mem.l	a1,d1		; ptr sur la fonction
	tst.b	ERR_MEM
	bne	.p_excep
	move.l	d1,a1
	clr.l	d1
	lit_mem.w	a1,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_excep		; dans d1 le num de la fct
	
	move.w	2(a0),d0
	and.w	#$fff,d0
	cmp.w	#11,d1
	beq.s	.gfx
	cmp.w	#5,d1
	beq	.esc
	cmp.w	d1,d0
	beq	.trap_t_cours
	bra	.p_excep
.gfx
	btst	#b_gfx,2(a0)
	beq	.p_excep	
	add.l	#10,a1
	clr.l	d1
	lit_mem.w	a1,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_excep		; dans d1 le num de la fct
	cmp.w	d1,d0
	beq	.trap_t_cours
	bra	.p_excep
.esc
	btst	#b_esc,2(a0)
	beq	.p_excep
	add.l	#10,a1
	clr.l	d1
	lit_mem.w	a1,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_excep		; dans d1 le num de la fct
	cmp.w	d1,d0
	beq	.trap_t_cours
	bra	.p_excep
	
	
	
	** ici, on doit recuperer d0 & d1 pour les analyser
	
	
	bra.s	.p_excep
.p_trap2
	cmp.w	(a1),d0
	bne.s	.p_excep
.trap_t_cours	
	
	
	btst	#b_perm,2(a0)	; teste de la permance du breakpoint
	beq.s	.p_perm
	
	
	
	bchg	#b_catch,2(a0)
	bne.s	.p_excep
	
	
.p_perm
	
	
	
	
	move.w	#3,LANCE_A	; nouveau mode pour afficher ce qui s'est passe
	
	
	moveq	#0,d7
	moveq	#0,d1
	move.w	2(a0),d7
	move.w	(a0),d1
	
	btst	#b_perm,2(a0)
	bne.s	.p_enleve
	
	
	bsr.l	enleve_fonction
	
	subq.w	#1,nb_fct_det
	
.p_enleve
	
	lea	MES_FONC_DET_R,a0
	bsr.l	prepare_fct_det
	
	
	;move.w	(a0),d0		; on restaure l'ancien detournement
	;addq.l	#4,a0
	;lsl	#2,d0
	;add.l	ADR_VBR,d0
	;add.l	#$80,d0
	;move.l	d0,a1
	
	
	;move.l	(a0)+,(a1)
	
	
	
	
	
	
	
	
	bra.s	.ok_trap
.p_excep
	addq.l	#8,a0
	dbra	d7,.cherche_table
	; arriv‚ ici, on doit ressauter dans le trap

	;active_mouse


	move.l	a_pile,a2

	lea	table_trap,a0
	clr.l	d0
	;move.b	6*4+7(sp),d0
	move.b	7(a2),d0
	sub.l	#$80,d0
	move.l	(a0,d0),a0
	move.l	a0,s_buf
	move.w	(a2),d0
	bset	#5+8,d0
	move	d0,sr
	movem.l	(sp)+,d0/d2/a0/a1/d1/d7/a2
	
	
	move.l	a_pile,a7
	
	;illegal
	
	jmp	([s_buf])		; saute … l'ancienne routine
	

.ok_trap
	movem.l	(sp)+,d0/d2/a0/a1/d1/d7/a2
	move.l	a_pile,a7
.p_fct_de
	
	
	
	
	move.b	#$12,$fffffc02.w		; on coupe la souris seulment apres le detournement de fonction
						; ceic afin d'eviter les pb clavier	
	
	
	sf	user_int1
	
	tst.b	user_int
	beq.s	.p_u_i				; on reconstruit la pile
	
	sf	user_int
	st	user_int1
	
	move	adr_off,-(sp)			; le format 0
	move.l	adr_retour,-(sp)
	move	adr_sr,-(sp)

.p_u_i

	tst.w	go_david
	beq.s	.p_trap_david

	tst.l	trap_david
	beq.s	.p_trap_david
	clr.w	go_david
	;illegal
	move.l	trap_david,2(sp)
	move.w	#$24,6(sp)
	clr.l	trap_david
.p_trap_david

	
	
	move.l	2(sp),p_c
	move.l	a6,s_a6
	lea	buffer_r,a6
	movem.l	d0-a5,(a6)
	
	
	;vide_cache
	
	
	
	lea	buffer_r+r_a6,a6
	move.l	s_a6,(a6)+			;on est dans l'ordre d0-a7
	movec	usp,d0
	move.l	d0,(a6)+
	clr.l	d0
	move.w	(a7),d0
	move.l	d0,(a6)+			;le sr
	move.w	6(sp),d1
	lsr	#8,d1
	lsr	#4,d1

;*************************************************************
;*** correction de la pile ssp selon le nb d'octet empil‚s ***
;*** cad selon le format                                   ***
;*************************************************************

	cmp.b	#2,d1				;format 2 on ajoute 12 octets
	bne.s	.p_form_2
	move.l	#12,Correction_pile
.p_form_2
	cmp.b	#1,d1
	bne.s	.p_form_1			;format 1, on ajoute 8 octets
	move.l	#8,Correction_pile
.p_form_1
	cmp.b	#0,d1
	bne.s	.p_form_0			;format 0, on ajoute 8 octets
	move.l	#8,Correction_pile
.p_form_0
	cmp.b	#3,d1
	bne.s	.p_form_3			;format 3, on ajoute 12 octets il semble ( fpu )
	move.l	#12,Correction_pile
.p_form_3
	
	cmp.b	#4,d1
	bne.s	.p_form_4			;format 4, on ajoute 16 octets 
	move.l	#16,Correction_pile		; c'est l'exception 68060 (berr)
						; c'est aussi le fpu non implmente
.p_form_4


	cmp.b	#7,d1
	bne.s	.p_form_7
	bclr	#5,$c(a7)			; clear le ct
	;bclr	#6,$c(a7)			; clear le cu
	;bclr	#7,$c(a7)			; clear le cp
	move.l	#30*2,Correction_pile
.p_form_7
	cmp.b	#9,d1
	bne.s	.p_form_9			;format 9, on ajoute 20 octets
	move.l	#10*2,Correction_pile
.p_form_9
	cmp.b	#$a,d1
	bne.s	.p_form_a			;format a, on ajoute 16*2 octets
	;move.l	a_p_c,p_c			;en plus on recupere l'ancien pc
	move.l	#16*2,Correction_pile
.p_form_a
	cmp.b	#$b,d1
	bne.s	.p_form_b			;format b, on ajoute 46*2 octets
	move.l	#46*2,Correction_pile
	
.p_form_b
	
	
	
	lea	buffer_r,a6
	move.l	p_c,r_pc(a6)			;le pc
	
	
	movec	isp,d0
	move.l	d0,r_isp(a6)
	add.l	Correction_pile,d0
	move.l	d0,r_ssp(a6)			;le ssp	on va tester la longeur de l'empilement pour compenser la pile
	
	movec	msp,d0
	move.l	d0,r_msp(a6)
	
	movec	vbr,d0
	move.l	d0,r_vrb(a6)
	
	movec	usp,d0
	move.l	d0,r_usp(a6)



	move.l	buffer_r+r_sr,d0
	btst	#5+8,d0
	beq.s	.user
	move.l	buffer_r+r_ssp,buffer_r+r_a7
	bra.s	.super
.user
	move.l	buffer_r+r_usp,buffer_r+r_a7
.super
	

	
	cmp.w	#cpu_30,CPU_TYPE		; si on a un 68030
	bne.s	.p_030
	
	
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	movec	caar,d0
	move.l	d0,r_caar(a6)
	
	moveq	#0,d0
	move.w	#$3111,d0			; active les caches
	movec	d0,cacr
	
	pmove	tc,r_tc(a6)
	pmove	crp,r_crp(a6)
	pmove	srp,r_srp(a6)
	pmove	tt0,r_tt0(a6)
	pmove	tt1,r_tt1(a6)
	pmove	mmusr,r_mmusr+2(a6)
	
.p_030

	cmp.w	#cpu_40,CPU_TYPE		; si on a un 68040
	bne.s	.p_040
	
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	
	dc.w	$f4d8
	;cinv 	bc
	nop
	move.l	#$80008000,d0			; active les caches
	movec	d0,cacr
	nop

	
	dc.l	$4e7a0805			;movec	mmusr,d0
	move.l	d0,r_mmusr(a6)
	dc.l	$4e7a0003			;movec	tc,d0
	move.l	d0,r_tc(a6)
	dc.l	$4e7a0806			;movec	urp,d0
	move.l	d0,r_crp(a6)
	dc.l	$4e7a0807			;movec	srp,d0
	move.l	d0,r_srp(a6)
	dc.l	$4e7a0004			;movec	itt0,d0
	move.l	d0,r_ittr0(a6)
	dc.l	$4e7a0005			;movec	itt1,d0
	move.l	d0,r_ittr1(a6)
	dc.l	$4e7a0006			;movec	dtt0,d0
	move.l	d0,r_dttr0(a6)
	dc.l	$4e7a0007			;movec	dtt1,d0
	move.l	d0,r_dttr1(a6)
	

.p_040

	******************************************
	** sauvegarde des registres pour le 060 **
	******************************************

	cmp.w	#cpu_60,CPU_TYPE
	bne.s	.p_060
	
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	
	dc.w	$f4d8
	;cinv 	bc
	nop
	move.l	#$80008000,d0			; active les caches
	movec	d0,cacr
	nop

	
	;dc.l	$4e7a0805			;movec	mmusr,d0
	;move.l	d0,r_mmusr(a6)
	
	
	dc.l	$4e7a0003			;movec	tc,d0
	move.l	d0,r_tc(a6)
	dc.l	$4e7a0806			;movec	urp,d0
	move.l	d0,r_crp(a6)
	dc.l	$4e7a0807			;movec	srp,d0
	move.l	d0,r_srp(a6)
	dc.l	$4e7a0004			;movec	itt0,d0
	move.l	d0,r_ittr0(a6)
	dc.l	$4e7a0005			;movec	itt1,d0
	move.l	d0,r_ittr1(a6)
	dc.l	$4e7a0006			;movec	dtt0,d0
	move.l	d0,r_dttr0(a6)
	dc.l	$4e7a0007			;movec	dtt1,d0
	move.l	d0,r_dttr1(a6)
	dc.l	$4e7a0008			;movec	buscr,d0
	move.l	d0,r_buscr(a6)
	dc.l	$4e7a0808			;movec	pcr,d0
	move.l	d0,r_pcr(a6)
	
	
	
	
.p_060


	clr.l	d0
	movec	dfc,d0
	move.l	d0,r_dfc(a6)
	clr.l	d0
	movec	sfc,d0
	move.l	d0,r_sfc(a6)
	
.fpu	
	ifne FPU_PRES				;sauvegarde des registres du fpu

	lea	buffer_fpu,a6
	fsave	-(a6)
	move.l	a6,s_fpu
	
	lea	buffer_r,a6
	
	
	fmove.l	fpsr,r_fpsr(a6)
	fmove.l	fpcr,r_fpcr(a6)
	fmove.l	fpiar,r_fpiar(a6)
	fmove.l	fpiar,r_fpiar(a6)

	lea	r_fp0+buffer_r,a6
	
	
	fmove.x	fp0,(a6)
	lea	12(a6),a6
	fmove.x	fp1,(a6)
	lea	12(a6),a6
	fmove.x	fp2,(a6)
	lea	12(a6),a6
	fmove.x	fp3,(a6)
	lea	12(a6),a6
	fmove.x	fp4,(a6)
	lea	12(a6),a6
	fmove.x	fp5,(a6)
	lea	12(a6),a6
	fmove.x	fp6,(a6)
	lea	12(a6),a6
	fmove.x	fp7,(a6)
	lea	12(a6),a6
	
	

	endc


	vide_cache

	xref	tempo,tempo1			; les 2 vaiable pour la repetition 
						; clavier
	;sf	tempo
	;sf	tempo1

	
	
	
****************************
** installation des piles **
****************************


	move.l	a7,a_pile			; on sauve_la pile
	lea	pile_prog,a7			; on installe notre pile

	*- place le debugeur sur l'ipl interne -*

	moveq	#0,d1
	move.w	IPL_INT,d1
	lsl	#8,d1
	
	move.w	sr,d0
	and.w	#%1111100011111111,d0		
	or.w	d1,d0
	move.w	d0,sr


	
	bsr	verifie_excep			; on regarde le type d'execption
						; pour l'affichage du nom
		
	tst.b	user_int1
	beq.s	.p_int1
	sf	user_int1
	move.l	#MES_USER_INT,MESSAGE_ADR
	
		
.p_int1
				
				
				
						; exemple : traced
	
	
	
************************
*** on teste le bkpt ***
************************
	;cmp.w	#3,LANCE_A
	;beq	.p_bkpt1
	
	tst.l	perm_bkpt
	beq.s	.norm				; on doit remttre l'exception en place
	move.l	perm_bkpt,a4
	move.w	type_ex,(a4)	
	move.l	#0,perm_bkpt			; on ne replace pas le bkpt en sortant
	cmp.w	#2,LANCE_A			; si on a un bkpt apres une exception
	bne.s	.n
	bra	.norm
.n
	tst.w	etat_trace			; si on est en mode trace
	bne	.suivant
.norm
	clr.w	bkpt_p
	move.l	p_c,a4				; on regarde s'il est dans la liste
	
	move.l	a_pile,a6
	cmp.b	#$C,7(a6)
	beq.s	.dec_pc
	cmp.b	#$10,7(a6)
	beq.s	.dec_pc

	;move.b	7(a6),d0

	subq.l	#2,a4				; ici, on decale le pc
	
.dec_pc	
	
	
	
	bsr.l	is_break
	tst.w	bkpt
	bne	.liste
	
	
	move.l	p_c,a4				; on teste un eventuel bkpt parametrique
	bsr.l	is_break
	tst.w	bkpt
	beq	.p_liste
	move.w	#1,bkpt_p
	move.w	2(a1),d1
	btst	#0,d1
	beq	.p_liste			; si pas parametre, on quitte
	
	
	
.liste
	
	
	
	move.w	2(a1),d1			; on r‚cupŠre les flags
	btst	#0,d1
	beq.s	.p_eval				; on a la chaine a ‚valuer
	
	move.l	#0,d0
	lea	eval_bkpt,a0
	move.w	bkpt,d0
	subq.l	#1,d0
	mulu	#256,d0
	
	add.l	d0,a0
	bsr.l	eval		
	
	*--- on affecte & ee sr & le pc ---*
	
	
	lea	buffer_r,a6		
	move.l	a_pile,a0
	move.l	r_sr(a6),d0
	move.w	d0,(a0)			; retablit le sr en cas de modifs
	
	
	*----------------------------------*
	
	tst.b	d2				; si erreur, on arrete le bkpt
	bne	.ok_bkpt_ev			; est consid‚r‚ comme valide
	cmp.l	#1,d1
	beq	.ok_bkpt_ev
	bra.s	.p_ok_bkpt
.p_eval
	move	2(a1),d1
	btst	#1,d1				; si pas permanant on valide
	beq	.ok_bkpt

	*--- on a le bkpt permanant ---*
.perm_eval
	move.l	a4,perm_bkpt			; adr du bkpt a remettre
	move.w	(a4),type_ex
	
	cmp.w	#2,LANCE_A			; si on a un bkpt apres une exception
	beq.s	.ert
	
	nop
	cmp.w	#1,etat_trace			; si on trace on ignore le bkpt
	beq	.oui_trace
.ert
	
	
	bra	.bkpt_p



.p_ok_bkpt				
	;move	2(a1),d1			; on teste la permanence sui l'emporte
	;btst	#1,d1			
	;bne	.perm_eval
	

	
	
	move.l	a4,perm_bkpt			; adr du bkpt a remettre
	move.w	(a4),type_ex
	cmp.w	#1,etat_trace
	beq	.oui_trace			; on arrive apres un trace
	
	*--- but : relancer la machine la machine pour une instruction puis ---*
	*--- replacer le mode go                                            ---*
	
	

	
	move.w	(a1),(a4)			; on replace l'instruction
	
	
	jsr	dessas_one_bk
	bsr.l	is_break
	tst.w	bkpt
	beq.s	.p_b
	bsr	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr	teste_fin			; l'exception termine t elle le prg ?
	bsr	gestion_exeptions		; correction de la pile en fonction du format
	;bsr	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	Restore_reg			; restauration des registre
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	subq.l	#2,2(a7)			; on corrige le pc
	bclr	#7,(a7)				; enleve le trace
	move.w	#0,etat_trace
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	rte
	
.p_b
	
	
	bsr	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr	teste_fin			; l'exception termine t elle le prg ?
	bsr	gestion_exeptions		; correction de la pile en fonction du format
	bsr	gestion_des_ins_exep		; teste du trap et autre pour simuler le trace
	bsr.l	Restore_reg			; restauration des registre
	
	
	
	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	#TRACE_EXCEP,(a0)		; on va vectoriser un trace_exceptionnel
	move.l	(sp)+,a0
	bsr.l	sauve_anc_reg
	move.l	a_pile,a7
	subq.l	#2,2(a7)			; on corrige le pc
	bset	#7,(a7)				; replace le trace
	move.l	#MES_TRACED,MESSAGE_ADR
	move.w	#0,etat_trace
	sf	user_int
	sf	flag_w
	vide_cache
	active_mouse
	rte
.oui_trace
	*--- ici on est dans le cas ou l'evaluation a ete nulle ---*
	*--- on doit faire comme si il y avait pas de bkpt      ---*
	bra	.suivant
.ok_bkpt_ev
	move	2(a1),d1
	btst	#1,d1				; si pas permanant on valide
	bne	.perm_eval			; si permanant on ignore l'expression
	
	
	

	
.ok_bkpt	
	move.l	a4,d0				; adr du bkpt
	move.l	#0,a1
	bsr.l	break_point
.bkpt_p
	tst.w	bkpt_p				; si bpkt parametre alors pas de correction pc
	bne.s	.pas_pc
	
	move.l	a_pile,a6
	cmp.b	#$C,7(a6)
	beq.s	.pas_pc
	cmp.b	#$10,7(a6)
	beq.s	.pas_pc
	subq.l	#2,p_c
.pas_pc
	lea	buffer_r+r_pc,a6
	move.l	p_c,(a6)			;on modifie le pc dans la liste des regs
	move.l	a_pile,a6
	move.l	p_c,2(a6)			;on modifie aussi dans le rte la pile
	move.l	p_c,d0	
	
	
	move.l	#BK_REACH,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR
	
	cmp.w	#1,LANCE_A
	bne.s	.lpo
	move.l	#MES_RB,MESSAGE_ADR		; ctrl a tout bete
	bra.s	.et
.lpo	cmp.w	#2,LANCE_A
	bne.s	*+12
	move.l	#MES_EMUL,MESSAGE_ADR		; un ctrl z sur une exception
.et
	
	bra.s	.p_trap
	
.p_liste
	move.l	a_pile,a6
	clr.l	d0
	move.w	6(a6),d0
	and.w	#$fff,d0
	
	
	cmp.w	#3,LANCE_A
	beq	.suivant
	
	
	
	cmp.w	#$80,d0				; on regarde s'il y a un trap
	blt.s	.p_trap
	cmp.w	#$80+15*4,d0
	bgt	.p_trap

	move.w	d0,a0				; auquel cas on recale le pc
	add.l	ADR_VBR,a0			; sur le trap
	move.l	#TRACE,d1
	cmp.l	(a0),d1
	bne.s	.p_trap
	move.l	a_pile,a6
	subq.l	#2,2(a6)
	lea	buffer_r+r_pc,a6
	subq.l	#2,(a6)
	subq.l	#2,p_c
.p_trap
.suivant


	tst.w	save_instruc
	beq.s	.p_pexec_first
	
	
	cmp.w	#cpu_40,CPU_TYPE
	bne.s	.p_0401
	
	move.l	buffer_r_anc+r_cacr,buffer_r+r_cacr	; on recopie les registres du cache
.p_0401
	
	
	
	
	lea	buffer_r,a6
	moveq	#14,d0
.zero_r	move.l	#0,(a6)+
	dbra	d0,.zero_r

	move.l	p_c,a0
	move.l	p_c,buffer_r+r_pc
	move.w	save_instruc+2,(a0)		; on remet l'instruct d'avant
	move.l	#MES_LOAD_OK+1,MESSAGE_ADR
	move.w	#0,save_instruc
	clr.w	LANCE_A
.p_pexec_first



	*----- ici on va tester si on avait un bkpt permanant
	*----- sur le pc si oui on le remet
	*----- on placera le flag en cas de ctrl a
	
	
	
	
	tst.l	bkpt_flag			; si un bkpt paremetre + ctrl a on remet la non permanace
	beq.s	.p_touche
	clr.l	bkpt_flag
	move.l	p_c,a4
	bsr.l	is_break		; on a forcement un ...
	
	move.w	2(a1),d1
	bclr	#1,d1				; on r‚cupŠre les flags
	move.w	d1,2(a1)			; on r‚cupŠre les flags
	
.p_touche
	
	
	
	
	
	
	
.p_bkpt1
	
	cmp.w	#3,LANCE_A			; on regarde si la fonction etait un trap detoun‚
	bne.s	.p_fct_det	
	subq.l	#2,p_c
	lea	buffer_r+r_pc,a6
	move.l	p_c,(a6)			;on modifie le pc dans la liste des regs
	move.l	a_pile,a6
	move.l	p_c,2(a6)			;on modifie aussi dans le rte la pile
	move.l	#MES_FONC_DET_R,MESSAGE_ADR	
.p_fct_det
	
	
	
	
*******************************************
** on teste si on doit retablir la video **
*******************************************
	tst.b	COMMU		; si on est en commutation d'‚cran
	bne.s	.pas_vid	; on ne force pas la vid‚o


	tst.w	etat_trace			; si on a trace alors
	bne.s	.r111				; on ne touche pas a la rsolution
	
	xref	VIDEO_COU,SAVE_VIDEO,SET_VIDEO,CENTINEL_VIDEO
	lea	VIDEO_COU,a0		
	bsr.l	SAVE_VIDEO
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
.r111
	cmp.w	#2,etat_trace			; on peut reforcer l'installation de la resol
	bne.s	.eeeee
	
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
	
	
.eeeee
	

.pas_vid


	;lea	CENTINEL_VIDEO,a0
	;bsr.l	SET_VIDEO
	
	
recommence::
	


	sf	tempo
	sf	tempo1


	bsr	traite_le_pc			; on affiche la forme du curseur
	bsr.l	set_all_flags			; on force l'affichage de toutes les fenetres

	
***********************************************
** on arrive a la routine de gestion clavier **
***********************************************
.gestion_clavier
	xref	TABLE_TOUCHES
	
	
	
		
	
	jsr	AFFICHE				; on affiche les fenetres
	clr.w	LANCE_A				; mise a zero du flag crtl a
	
	
	tst.b	flag_res			; on teste si on daoit rendre residant
	beq.s	.normal
	cmp.b	#$38,$fffffc02.w
	beq.s	.normal
	
	
	
	clr.w	CHARGE_AUTO			; au cas o—...
	sf	flag_res
	bra	fin_residant	
.normal
	clr.b	flag_res
	
	tst.w	CHARGE_AUTO			; on teste si on a un
	beq.s	.p_c_a				; chargement automaique
	bsr.l	r_load
	tst	d0
	beq	.chg_auto
	;bra	.chg_auto	
	clr	CHARGE_AUTO			; on teste si on a un
.p_c_a

	



	jsr	get_key				; on recupere la touche
	
	

	cmp.w	#$62b,d0			; Shift Alt #  make residant
	bne.s	.p_fin1
	tst.l	ADR_CHARGE
	bne	.gestion_clavier
	tst.w	RESIDENT1			; teste la residence
	beq	fin_residant	

	move.l	#MES_CENT_RESI,MESSAGE_ADR
	bsr.l	set_all_flags
	bra	.gestion_clavier
.p_fin1
	cmp.w	#$12e,d0			; ctrl C     Quit
	bne.s	.p_fin
	tst.w	RESIDENT			; teste la residence
	bne.s	.resid
	tst.l	ADR_CHARGE		; a t on fait ctrl c dans le prog a executer
	beq	fin
	
	bsr.l	clear_bkpt_liste		; on vire les bkpt ‚ventuels
	
	
	clr.w	-(sp)
	trap	#1
.resid
	move.l	#MES_REALLY_QUIT,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	move.l	#MES_SPACE,MESSAGE_ADR
	cmp.w	#$15,d0
	beq.s	.quit_resi
	cmp.w	#$18,d0
	bne	.gestion_clavier
.quit_resi
	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO	
	
	bsr.l	clear_bkpt_liste		; on vire les bkpt ‚ventuels
	
	active_mouse
	
	clr.w	-(sp)
	trap	#1
.p_fin

	lea	TABLE_TOUCHES,a0		; si on est dans une fenetre dsp
.ch	move.w	(a0)+,d1			; alors, on ajoute 4 a la liste
	beq	.gestion_clavier		; dans laquelle on cherche 
	cmp.w	d0,d1				; l'adresse de la routine a laquelle
	bne	.p_ok				; sauter
	move.l	ACTIVE_WINDOW,a1
	cmp	#T_dernier,type(a1)
	bgt	.ok00
	xref	ACTIF_DSP
	tst	ACTIF_DSP
	;beq	.gestion_clavier
	addq	#4,a0
.ok00
	move.l	a0,s_a0
	jsr	([a0])
	move.l	s_a0,anc_touche
	
.chg_auto
	tst.l	ADR_CHARGE		; pas de prg en mem => pas de pexec
	beq	.gestion_clavier
	tst.w	prog_launch		; on regarde si on execute le prg => pas de pexec
	beq	.gestion_clavier
	
	*--- on arrive ici avant d'executer le programme a deboguer ---*
	
	move.l	ADR_CHARGE,a0		; met un trap #0 pour prendre la main
	move.w	256(a0),save_instruc+2
	st	save_instruc		; positionne le flag
	move.w	#$4e40,256(a0)
	;move.w	EXEP_ARRET,256(a0)
	
	
	lea	256(a0),a1
	move.l	a1,p_c
	move.l	a1,buffer_r+r_pc
	
	sf	prog_launch
	
	move.w	#1,etat_trace
	clr.w	LANCE_A				; mise a zero du flag crtl a
	
	
	move.l	a7,s_pile_pexec
	lea	pile_pexec,a7
	
	
	move.l	ADR_CHARGE,a0
	clr.l	-(sp)
	pea	(a0)
	clr.l	-(sp)
	;move.w	#4,-(sp)		; free
	move.w	#6,-(sp)		; just go and free
	GEM	Pexec			; on lance le prg a deboger
	
	
	
	tst.w	clavier_pourri
	bne.s	.ouf

	
	move.w	#$2700,sr
	bra.s	.lop
.ouf

	
	move.w	#$2300,sr
	
.lop
	
	move.b	#$12,$fffffc02.w
	
	move.l	s_pile_pexec,a7
	
	;illegal
	
	bsr.l	clear_bkpt_liste		; on met a zero la liste des bkpt
	
	
	
	
	*--- on libŠre la memoire des symbols si besoin ---*
	
	
	
	tst.l	adr_label
	beq.s	.p_mfree1
	move.l	adr_label,-(sp)
	GEM	Mfree
.p_mfree1
	tst.l	buf_label
	beq.s	.p_mfree2
	move.l	buf_label,-(sp)
	GEM	Mfree
.p_mfree2
	tst.l	hash_table
	beq.s	.ap_mfree3
	move.l	hash_table,-(sp)
	GEM	Mfree
.ap_mfree3
	
	
	clr.l	ADR_CHARGE		; on autorise a recharger un autre prog

	
	
	move.l	#MES_PROG_END,MESSAGE_ADR
	
	
	
	lea	buffer_r,a6
	moveq	#14,d0
.zeror	move.l	#0,(a6)+
	dbra	d0,.zeror


	move.l	#$e00030,buffer_r+r_pc
	move.l	#$e00030,p_c
	
	bsr.l	sauve_anc_reg

	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO
	
	
	;illegal
	
	bsr.l	set_all_flags
	
	bra	recommence
	
.p_ok
	addq.l	#8,a0
	bra	.ch
	

.null	dc.w	0

*************************************************************
** Les routines qui sont exc‚cuter en fonction des touches **
*************************************************************
	
	;include 40\main.inc\r_total.s




teste_fin::
********************************************
** routine qui regarde si le prog se fini **
********************************************
	
	rts
	tst.w	excep
	beq.s	.p_excep
	cmp.w	#1,type_excep
	bne.s	.p_excep
	cmp.w	#0,num_func			; pterm (0)
	bne.s	.p_excep
	move.l	#fin,(sp)
.p_excep
	cmp.w	#$4c,num_func
	bne.s	.p_excep1			; pterm (4c)
	move.l	#fin,(sp)
.p_excep1
	cmp.w	#$31,num_func			; ptermres
	bne.s	.p_excep2
	move.l	#fin,(sp)
.p_excep2

	rts


forme_bra::
*********************************************************
** routine qui va voir si il y a un branchement ou non **
*********************************************************
	movem.l	d0-a6,-(sp)	
	
	move.b	#3,forme_curseur		; la fleche horizontale
	move.l	p_c,a0

	move.l	a0,a4

	bsr	is_break
	tst.w	bkpt
	beq	.p_bkpt
	
	move.w	(a1),d0			; instruction initiale
	bra	.p_err	
	
.p_bkpt					; instruction normale




	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	beq.s	.p_err
	move.b	#3,forme_curseur
	rts
.p_err
	move.w	d0,d1
	and.w	#%1111000000000000,d0		; test du bcc
	cmp.w	#%0110000000000000,d0
	beq.s	.branch
	move.w	d1,d0
	and.w	#%1111000011111000,d0		; test du bdcc
	cmp.w	#%0101000011001000,d0
	beq.s	.branch
	move.w	d1,d0
	and.w	#%1111111111000000,d0		; test du jmp
	cmp.w	#%0100111011000000,d0
	beq.s	.branch_jcc
	move.w	d1,d0
	and.w	#%1111111111000000,d0		; test du jsr
	cmp.w	#%0100111010000000,d0
	beq.s	.branch_jcc
	
	move.w	d1,d0				; test du fbcc
	and.w	#%1111111110000000,d0
	cmp.w	#%1111001010000000,d0
	beq	.branch
	
	move.w	d1,d0				; test du fdbcc
	and.w	#%1111111111111000,d0
	cmp.w	#%1111001001001000,d0
	beq	.branch
	
	
	
	
	
	bra.s	.p_branch

	
.branch	
	lea	buffer_r,a6
	move.l	r_sr(a6),d0			; on fait une copie du sr
	move.l	r_pc(a6),d1			; un copie du pc
	bsr	test_branchement
.p_branch
	movem.l	(sp)+,d0-a6	
	rts


.branch_jcc		
	lea	buffer_r,a6
	
	
	move.l	p_c,a4
	
	bsr.l	dessas_one_bk
	lea	s_buf,a1
	bsr.l	calcule_adresse
	
	move.l	p_c,d0
	cmp.l	d0,d1
	blt	.monte
	bgt	.descend
	move.b	#'~',forme_curseur		; bra	 infini
	bra.s	.x
.monte
	move.b	#1,forme_curseur
	bra.s	.x

.descend
	move.b	#2,forme_curseur
	
.x
	
	movem.l	(sp)+,d0-a6
	rts	




traite_le_pc::
****************************************************
** Routine qui va voir s'il faut reafficher le pc **
** dans la fenetre courante                       **
****************************************************
	movem.l	d0-a6,-(sp)	

	bsr	forme_bra			; test la forme du curseur pc
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_disas_68,type(a0)
	bne.s	.traite_encore_le_pc

	move.l	p_c,d0
	cmp.l	adr_fin(a0),d0
	bge.s	.scr
	cmp.l	adr_debut(a0),d0
	bge.s	.suite_aff
	
.scr
	move.l	d0,a4
	move.l	a4,adr_debut(a0)
.suite_aff
	movem.l	(sp)+,d0-a6	
	
	
	bsr	traite_le_pc_source
	
	rts
.traite_encore_le_pc
****************************************************
** on v‚rifie que le pc est au moins visible ds une fenetre de disas
** sinon on en remet une de force : la plus proche
****************************************************


	*----------------------*
	* le pc est il ds une fenetre de dessas
	*----------------------*

	move.l	p_c,d0
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP0	move.l	(a0)+,a1
	cmp	#T_disas_68,type(a1)
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
	move.l	#$7fffffff,d2		;distance … 0
	
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP	move.l	(a0)+,a1
	cmp	#T_disas_68,type(a1)
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

	


	
.FOUND	bra	.suite_aff
	
					


traite_le_pc_source::
****************************************************
** Routine qui va voir s'il faut reafficher le pc **
** dans la fenetre courante                       **
****************************************************
	movem.l	d0-a6,-(sp)	

	bsr	forme_bra			; test la forme du curseur pc
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	;bne.s	.suite_aff
	bne.s	.traite_encore_le_pc_source

	move.l	p_c,d0
	
	bsr.l	trouve_ligne
	; dans d0 on a le num de ligne le plus proche
	
	
	move.l	Src_adr(a0),a1
	
	move	Hauteur(a0),d7
	subq	#3,d7
	add	Line_nb(a0),d7
	
	
	cmp.w	d7,d0		; nb ligne max
	bge.s	.scr
	cmp.w	Line_nb(a0),d0		; ligne de debut
	bge.s	.suite_aff
	
.scr
	move.w	d0,Line_nb(a0)		; on place la l'adresse de la fenetre … la ligne courante
.suite_aff
	movem.l	(sp)+,d0-a6	
	
	rts
.traite_encore_le_pc_source
****************************************************
** on v‚rifie que le pc est au moins visible ds une fenetre de disas
** sinon on en remet une de force : la plus proche
****************************************************


	*----------------------*
	* le pc est il ds une fenetre de dessas
	*----------------------*

	move.l	p_c,d0
	lea	WINDOW_LIST,a2
	move	#32-1,d7
.LOOP0	move.l	(a2)+,a1
	move.l	a1,a0
	cmp	#T_M40_SRC,type(a0)
	bne.s	.NEXT0	
	
	move.l	p_c,d0
	bsr.l	trouve_ligne
	move.l	Src_adr(a0),a1
	move	Hauteur(a0),d6
	subq	#3,d6
	add	Line_nb(a0),d6
	
	cmp.w	d6,d0		; nb ligne max
	bge.s	.NEXT0
	cmp.w	Line_nb(a0),d0		; ligne de debut
	blt.s	.NEXT0
	bra.s	.FOUND			;le Pc est dans cette fenetre
.NEXT0	dbra	d7,.LOOP0
	
	*----------------------*
	* le PC n'est pas ds une fenetre de desas...
	* on prend la plus proche en adresse
	*----------------------*
	
	;illegal
	
	sub.l	a2,a2			;ptr fenetre … 0
	move.l	#$7fff,d2		;distance … 0
	
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP	move.l	(a0)+,a1
	cmp	#T_M40_SRC,type(a1)
	bne.s	.NEXT	
	
	move.l	a0,a3
	move.l	a1,a0
	move.l	p_c,d0
	bsr.l	trouve_ligne
	move.l	a3,a0
	
	
	
	move.w	Line_nb(a1),d3
	sub	d0,d3
	bpl.s	.POS
	neg	d3
.POS	cmp	d2,d3
	bgt	.SUP
	move	d3,d2
	move.l	a1,a2
.SUP	
	
	
	move	Hauteur(a1),d3
	subq	#3,d3
	add	Line_nb(a1),d3
	
	
	sub	d0,d3
	bpl	.POS2
	neg	d3
.POS2	cmp	d2,d3
	bgt	.SUP2
	move	d3,d2
	move.l	a1,a2
.SUP2
.NEXT	dbra	d7,.LOOP
	
	
	tst.l	a2
	beq.s	.FOUND	
	*----------------------*
	* dans a2 on a la fenetre choisie
	*----------------------*
	
	move.w	d0,Line_nb(a2)

	


	
.FOUND	bra	.suite_aff
	




get_function_trap::	
************************************
** gestion du nom des execptions  **
** - on place a 1 le flag excep   **
** - on place le num de la func   **
**   dans num_func                **
** - on place le type de trace    **
**   dans type_excep              **
************************************
	movem.l	a0/d0/d1/a5/a6,-(sp)
	move.w	#0,excep	
	
	move.l	p_c,a5				;on test s'il y a un trap
	lit_mem.w	a5,d0
	tst.b	ERR_MEM
	bne.s	.p_trap
	
	cmp.w	#$4e41,(a5)
	beq.s	.excep
	cmp.w	#$4e42,(a5)
	beq.s	.excep
	cmp.w	#$4e4d,(a5)
	beq.s	.excep
	cmp.w	#$4e4e,(a5)
	bne.s	.p_trap
.excep
	cmp.w	#$4e42,(a5)
	beq	.aes_vdi

	
	lea	buffer_r,a6
	move.l	r_sr(a6),d0
	btst	#13,d0
	beq.s	.p_super
	move.l	r_ssp(a6),a0			; on est en superviseur
	bra.s	.super
.p_super
	move.l	r_usp(a6),a0			; on est en utilisateur
.super
	move.w	(a5),d0
	and.w	#$f,d0
	move.w	d0,type_excep
	lea	table_num_max_ex,a5
	move.w	(a5,d0.w*2),d1
	move.w	(a0),d0				; on recupere le numero de la fonction
	cmp.w	d0,d1
	blt.s	.p_trap
	move.w	d0,num_func
	move.w	#1,excep			; flag excep a un
	
	
	
.p_trap
	
	movem.l	(sp)+,d1/d0/a5/a6/a0
	rts
	
	
.aes_vdi
	cmp.w	#$c8,buffer_r+r_d0+2	; aes
	bne	.p_aes
	*--- fonction aes ---*
	
	move.l	buffer_r+r_d1,a5
	lit_mem.l	a5,d1		; ptr sur la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	move.l	d1,a5
	clr.l	d1
	lit_mem.w	a5,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	
	lea	table_num_max_ex+2*2,a6	; pointe sur le nb de fct aes
	clr.l	d0
	move.w	(a6),d0
	cmp.w	d1,d0
	blt	.p_trap			; le nb est trop grand
	
	move.w	#2,type_excep
	move.w	d1,num_func
	move.w	#1,excep			; flag excep a un
	
	bra	.p_trap
	
	
.p_aes
	cmp.w	#$73,buffer_r+r_d0+2	; vdi
	bne	.p_trap
	*--- fonction vdi ---*
	
	
	move.l	buffer_r+r_d1,a5
	lit_mem.l	a5,d1		; ptr sur la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	move.l	d1,a5
	clr.l	d1
	lit_mem.w	a5,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	
	lea	table_num_max_ex+2*16,a6
	clr.l	d0			; pointe sur le nb de fct vdi
	move.w	(a6),d0
	cmp.w	d1,d0
	blt	.p_trap			; le nb est trop grand
	
	
	*--- teste si on a les fonctions graphiques de bases ---*
	
	cmp.w	#11,d1		; teste si on a des focntions graphique de base
	bne	.p_fct_gfx
	;move.l	buffer_r+r_d1,a5
	add.l	#10,a5		; pointe sur ctrl[5]
	clr.l	d1
	lit_mem.w	a5,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	lea	table_num_max_ex+2*17,a6
	clr.l	d0			; pointe sur le nb de fct vdi
	move.w	(a6),d0
	cmp.w	d1,d0
	blt	.p_trap			; le nb est trop grand
	move.w	#17,type_excep
	move.w	d1,num_func
	move.w	#1,excep			; flag excep a un
	bra	.p_trap
.p_fct_gfx
	*--- teste si on a les fonctions escapes ---*
	
	cmp.w	#5,d1		; teste si on a des focntions graphique de base
	bne	.p_fct_esc
	;move.l	buffer_r+r_d1,a5
	add.l	#10,a5		; pointe sur ctrl[5]
	clr.l	d1
	lit_mem.w	a5,d1		; nb de la fonction
	tst.b	ERR_MEM
	bne	.p_trap
	lea	table_num_max_ex+2*18,a6
	clr.l	d0			; pointe sur le nb de fct vdi
	move.w	(a6),d0
	cmp.w	d1,d0
	blt	.p_trap			; le nb est trop grand
	move.w	#18,type_excep
	move.w	d1,num_func
	move.w	#1,excep			; flag excep a un
	bra	.p_trap
.p_fct_esc
	
	
	
	move.w	#16,type_excep
	move.w	d1,num_func
	move.w	#1,excep			; flag excep a un
	
	
	
	movem.l	(sp)+,d1/d0/a5/a6/a0
	rts
	
	
gestion_des_ins_exep::
********************************************************
** routine qui va permttre de trace de trap et autres **
********************************************************	

	;cmp.w	#cpu_30,CPU_TYPE		; sur le 040 ce marchera aussi
	;beq.s	.030
	;rts
.030

	move.l	a_pile,a6
	move.l	2(a6),a0		
	
	lit_mem.w	a0,d0
	tst.b	ERR_MEM
	beq.s	.p_err11
	rts
.p_err11
	
	
	move.w	d0,d1
	and.w	#$fff0,d0
	cmp.w	#$4e40,d0			; test d'un trap
	beq	.exeption
	move.w	(a0),d0
	lsr	#8,d0
	lsr	#4,d0
	and.w	#$f,d0
	cmp.w	#$f,d0				; test d'une line f
	bne.s	.p_line_f
	move.l	a0,a4
	bsr.l	dessas_one
	lea	m,a4
	cmp.b	#'D',1(a4)
	bne.s	.p_line_f
	cmp.b	#'C',3(a4)
	beq	.exeption
.p_line_f
	move.w	d1,d0
	and.w	#$f000,d0
	cmp.w	#$a000,d0			; test d'une line a
	beq	.exeption
	move.w	d1,d0
	cmp.w	#%0100111001110110,d0		; test du trapv
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111010,d0		; test du trapcc		petit pb avec sf
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111011,d0		; test du trapcc		petit pb avec sf
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111000011111111,d0
	cmp.w	#%0101000011111100,d0		; test du trapcc		petit pb avec sf
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111000111111000,d0
	cmp.w	#%1111000001111000,d0		; test du cptrapcc
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111000101000000,d0
	cmp.w	#%0100000100000000,d0		; test du chk
	beq	.exeption
	move.w	d1,d0
	and.w	#%1111100111000000,d0
	cmp.w	#%0000000011000000,d0		; test du chk2
	bne	.p_exeption
	lea	2(a0),a1
	lit_mem.w	a1,d0			; suite du chk2
	btst	#11,d0
	bne.s	.exeption
	bra	.p_exeption
.exeption
	move.l	a0,d0				; ou bkpt sur l'instruction a tracer
	move.l	a0,a4				; on verifie qu'il n'y a pas de bkpt sur
	cmp.l	#$e00000,a4
	blt.s	.p_rom
	cmp.l	#$f00000,a4
	bgt.s	.p_rom
	
	*--- ici on prevoit un trace until pour la rom ---*
	
	cmp.w	#$4e41,d1
	beq	.lance1
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
	
	
	bsr	is_break			; l'instruc courante
	tst.w	bkpt
	beq.s	.p_trouve2
	move	2(a1),d0
	tst.w	d0
	
	bne.s	.p_trouve2			; si perma on fait comme s'il y en avait pas
	
	
	bra.s	.lance


	*--- on va regarder l'instruction suivante ---*


.p_trouve2
	move.w	(a4),d0			; on v‚rifie que le
	and.w	#$fff0,d0		; trap est un trap systeme
	cmp.w	#$4e40,d0		; sinon on ne trace pas
	bne.s	.p_trouve1
	clr.l	d0
	move.w	(a4),d0
	and.w	#$f,d0
	lsl.w	#2,d0
	;add.w	#$80,d0
	;move.l	d0,a0
	;add.l	ADR_VBR,a0
	
	lea	table_trap,a0
	move.l	(a0,d0),a0
	
	
	
	cmp.l	#TRACE,(a0)
	bne.s	.p_trouve1
	;move.w	#1,etat_trace

	pea	(a0)
	move.w	#1,etat_trace		; on ne touche pas le resol
	cmp.w	#0,voir_ctrl_a
	beq.s	.p_voir1
	lea	VIDEO_COU,a0		; ici on va installer l'ecran logique.
	bsr.l	SET_VIDEO
	move.w	#0,etat_trace
	move.w	#2,etat_trace		; va reforcer l'install_video sans sauve
.p_voir1
	move.l	(sp)+,a0


.lance
	move.w	#0,LANCE_A
	;demo_mode?
	
	move.l	#go1,(sp)		; modification de l'adr de retour
	rts	
	;endc			; on lance sans trace
.p_trouve1
	move.l	2(a6),a0		
	move.l	a0,a4
	
	bsr.l	dessas_one_bk
	move.l	a4,a0	
	move.l	a0,d0
	move.l	a0,a4
	
	bsr	is_break
	tst.w	bkpt
	bne.s	.ok1
	
	
	
	
	
	move.l	a4,d0			; place un bkpt
	move.l	#0,a1
	bsr	break_point	
.ok1	
	
	
	
	;pea	(a0)
	;move.w	#1,etat_trace		; on ne touche pas le resol
	;cmp.w	#0,voir_ctrl_a
	;beq.s	.p_voir
	;lea	VIDEO_COU,a0		; ici on va installer l'ecran logique.
	;bsr.l	SET_VIDEO
	;move.w	#0,etat_trace
	;move.w	#2,etat_trace		; va reforcer l'install_video sans sauve
.p_voir
	;move.l	(sp)+,a0

	
	move.w	#1,etat_trace
	move.w	#2,LANCE_A
	;demo_mode?
	move.l	#go1,(sp)		; modif de l'adr de retour
	;endc 
	rts				; on lance sans trace

.p_exeption
	rts
	
	
	*--- routine de trace until ---*
	
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
	
	
	bsr	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr	teste_fin			; l'exception termine t elle le prg ?
	bsr	gestion_exeptions		; correction de la pile en fonction du format
	bsr.l	Restore_reg			; restauration des registre
	
	
	
	move.w	#2,etat_trace

	bsr.l	sauve_anc_reg

	
	move.l	a_pile,a7
	bset	#7,(a7)				; replace le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	pea	(a0)
	move.l	#$24,a0				;
	add.l	ADR_VBR,a0			;
	move.l	TRACE,(a0)
	move.l	(sp)+,a0
	
	
	

	sf	user_int
	sf	flag_w


	vide_cache
	active_mouse
	rte



.TRACE_PC				; routine de trace avec le pc
	move.l	d0,-(sp)
	move.l	adr_t_until,d0
	cmp.l	6(sp),d0
	bne.s	.p_encore
	move.l	(sp)+,d0
	
	bra	TRACE
.p_encore
	move.l	(sp)+,d0
	bset	#7,(a7)

	sf	user_int
	sf	flag_w
	
	vide_cache
	active_mouse
	rte



.lance1
	*--- pn va faire le vrai trap ---*
	
	
	
	
	move.l	a_pile,a6
	move.l	2(a6),a0		
	move.l	a0,trap_david
	addq.l	#2,trap_david
	lit_mem.w	a0,d0
	lea	.emul,a1
	move.w	d0,(a1)				; fabrique le trap
	
	;lea	.modif,a1
	;move.l	a0,2(a1)			; met le bon jmp	
	;nop	
	vide_cache
	
	bsr	get_function_trap		; recupere le nb du trap s'il y en a un
	bsr	teste_fin			; l'exception termine t elle le prg ?
	bsr	gestion_exeptions		; correction de la pile en fonction du format
	bsr.l	Restore_reg			; restauration des registre
	
	
	
	move.w	#2,etat_trace

	bsr.l	sauve_anc_reg

	
	
	
	move.l	a_pile,a7
	bclr	#7,(a7)				; enleve le trace

	move.l	#MES_TRACED,MESSAGE_ADR


	;pea	(a0)
	;move.l	#$24,a0				;
	;add.l	ADR_VBR,a0			;
	;move.l	adr_trace,(a0)		; on va vectoriser un trace_exceptionnel
	;move.l	(sp)+,a0
		
	move.l	#.emul1,2(a7)		; on pointe sur le trap
	
	

	sf	user_int
	sf	flag_w



	vide_cache
	active_mouse


	move.l	trap_david,a0


	rte


.emul1

	nop
.emul	
	
	trap	#1
	
	
	
	nop
	nop
	
	st	go_david
	trap	#0
	
	
	
	
	
	
	
	
	
***************************************
** traitement des exeptions          **
** correction de la pile en fonction **
** du format d'empilage              **
***************************************
gestion_exeptions::
	move.l	a_pile,a6
	move.w	6(a6),d0		; on gere le retour de erreur de bus
	move.w	d0,d1
	and.w	#%1111000000000000,d1
	lsr.w	#8,d1
	lsr.w	#4,d1
	cmp.b	#$a,d1			; format court
	bne.s	.normal1
	move.l	(a6),d2
	move.l	4(a6),d3
	add.l	#16*2,a6
	move.l	d3,-(a6)
	move.l	d2,-(a6)
	move.l	a6,a_pile		;**** on sauve la pile  car elle a chang‚e ****
	bclr	#15,d0			; on met un format 0
	bclr	#14,d0			; puis on fait croire
	bclr	#13,d0			; … un trap	#0
	bclr	#12,d0			
	move.w	d0,6(a6)
	move.b	#$80,7(a6)
	move.l	#8,Correction_pile	; on a alors un format 0
	bra.s	.normal
.normal1
	cmp.b	#$b,d1			; format long
	bne.s	.normal
	move.l	(a6),d2
	move.l	4(a6),d3
	add.l	#46*2,a6
	move.l	d3,-(a6)
	move.l	d2,-(a6)
	move.l	a6,a_pile		;**** on sauve la pile  car elle a chang‚e ****
	bclr	#15,d0			; on met un format 0
	bclr	#14,d0			; puis on fait croire
	bclr	#13,d0			; … un trap	#0
	bclr	#12,d0			
	move.w	d0,6(a6)
	move.b	#$80,7(a6)
	
	move.l	#8,Correction_pile	; on a alors un format 0

.normal	
	;cmp.b	#7,d1			; format 68040
	;bne.s	.normal2
	;move.l	(a6),d2
	;move.l	4(a6),d3
	;add.l	#30*2,a6
	;move.l	d3,-(a6)
	;move.l	d2,-(a6)
	;move.l	a6,a_pile		;**** on sauve la pile  car elle a chang‚e ****
	;bclr	#15,d0			; on met un format 0
	;bclr	#14,d0			; puis on fait croire
	;bclr	#13,d0			; … un trap	#0
	;bclr	#12,d0			
	;move.w	d0,6(a6)
	;move.b	#$80,7(a6)
.normal2
	rts
	
	
	
TRACE_EXCEP::
***********************************************************
** routine de trace qui va replacer le bkpt correctement **
*********************************************************
	move.w	#$2700,sr
	
	vide_cache
	active_mouse
	
	pea	(a4)
	move.l	perm_bkpt,a4
	move.w	type_ex,(a4)
	move.l	#0,perm_bkpt			; on ne replace pas le bkpt en sortant
	move.l	#$24,a4			
	add.l	ADR_VBR,a4			
	move.l	#TRACE,(a4)			; on va revectoriser le trace
	move.l	(sp)+,a4
	
	bclr	#7,(a7)				; enleve le trace
	;bset	#5,(a7)
	sf	user_int
	sf	flag_w
	
	
	rte	
	


rec_history::
*********************************
** ici, on va sauver l'history **
*********************************

	movem.l	d0-a6,-(sp)

	lea	point_history,a0
	moveq	#7,d0
.look	move.l	(a0)+,a1
	tst.l	(a1)
	beq.s	.slot_vide
	dbra	d0,.look
		
	*--- ici tout est plein
	*--- on va devoir scroller de 1 vers le haut
	
	lea	point_history,a0
	
	moveq	#6,d0			; on scroll tout vers le haut
	move.l	(a0),d1
.scroll	move.l	4(a0),(a0)+
	dbra	d0,.scroll
	
	move.l	d1,(a0)
	move.l	d1,a0
	
	bra.s	.next_l
	
.slot_vide
	subq.l	#4,a0
	move.l	(a0),a0
.next_l
	
	lea	buffer_r+r_d0,a6
	
	
	
	move.w	COL_REG,ATTRIBUTE
	
	move.w	#' ',(a0)+
	
	move.w	ATTRIBUTE,d7
	move.b	#'D',d7
	move.w	d7,(a0)+
	move.b	#' ',d7
	move.w	d7,(a0)+
	move.w	d7,(a0)+
	move.w	d7,(a0)+
	
	moveq	#7,d7			; copie des dn
.copii	move.l	(a6)+,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move.w	ATTRIBUTE,d6
.copi	move.b	(a1)+,d6
	beq.s	.s
	move.w	d6,(a0)+
	bra.s	.copi
.s
	move.b	#' ',d6
	move.w	d6,(a0)+
	
	dbra	d7,.copii
	
	
	move.w	#$000d,(a0)+
	
	
	move.w	#' ',(a0)+
	move.w	#' ',(a0)+
	move.w	#' ',(a0)+
	
	
	
	move.w	COL_ADR,ATTRIBUTE
	
	move.w	ATTRIBUTE,d7
	move.b	#'A',d7
	move.w	d7,(a0)+
	move.b	#' ',d7
	move.w	d7,(a0)+
	move.w	d7,(a0)+
	move.w	d7,(a0)+
	
	moveq	#7,d7			; copie des an
.copii1	move.l	(a6)+,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move.w	ATTRIBUTE,d6
.copi1	move.b	(a1)+,d6
	beq.s	.s1
	move.w	d6,(a0)+
	bra.s	.copi1
.s1
	move.b	#' ',d6
	move.w	d6,(a0)+
	
	dbra	d7,.copii1
	
	
	move.w	#$000d,(a0)+
	
	
	move.w	COL_FCT,ATTRIBUTE
	move.w	ATTRIBUTE,d7	;le SR
	
	copy	<'   SR='>,a0
	
	move.l	buffer_r+r_sr,d0
	bsr.l	affiche_nombre_zero
	lea	nombre+4,a6
.y	move.b	(a6)+,d7
	beq.s	.s2
	move.w	d7,(a0)+
	bra.s	.y
.s2
	
	
	
	move.w	COL_DSP,ATTRIBUTE
	move.w	ATTRIBUTE,d7	;le SR
	
	copy	<'  SSP='>,a0
	
	move.l	buffer_r+r_ssp,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a6
.y0	move.b	(a6)+,d7
	beq.s	.s20
	move.w	d7,(a0)+
	bra.s	.y0
.s20
	
	move.w	COL_MENU,ATTRIBUTE
	move.w	ATTRIBUTE,d7	;le SR
	
	
	copy	<'      PC='>,a0
	
	move.l	buffer_r+r_pc,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a6
.y1	move.b	(a6)+,d7
	beq.s	.s21
	move.w	d7,(a0)+
	bra.s	.y1
.s21
	
	xref	COL_PC
	move.w	COL_PC,ATTRIBUTE
	
	copy	<'       '>,a0
	
	
	move.l	p_c,a4
	bsr.l	dessas_one
	lea	m,a1
	

.kl	move.b	(a1)+,(a0)+
	bne.s	.kl
	
	
	
	
	subq.l	#1,a0
	move.w	#$000d,(a0)+
	
	move.w	COL_NOR,ATTRIBUTE
	
	
	move.w	#$000d,(a0)+
	move	#$8000,(a0)+		
	

	*--- ici , on va ajouter la liste des registres en reel (pas ascii) a restaurer ---*
	
	
	lea	buffer_r+r_d0,a6
	
	move.w	#15,d0
	
.cop_reg
	move.l	(a6)+,(a0)+
	dbra	d0,.cop_reg


	move.l	buffer_r+r_sr,(a0)+
	move.l	buffer_r+r_pc,(a0)+
	move.l	buffer_r+r_ssp,(a0)+


	
	
	
	movem.l	(sp)+,d0-a6

	rts




;------------------------------------------------------------------------------
; recopie de l'History ligne par ligne ds le ASCII BUF
;------------------------------------------------------------------------------
GEN_HISTORY::
	movem.l	d0-a6,-(sp)

	lea	ASCII_BUF,a6
	
	move.w	COL_NOR,ATTRIBUTE
	copy	<'       0        1        2        3        4        5        6        7'>,a6
	move.w	#$000d,(a6)+
	
	
	lea	point_history,a0
	move.l	a1,a2
	move	#8-1,d7
.LOOP_INSTRUCTION
	move.l	(a0)+,a1
	
	move.w	ATTRIBUTE,(a6)
	move.b	#'8',1(a6)
	sub.b	d7,1(a6)
	addq	#2,a6	
	move.w	ATTRIBUTE,(a6)
	move.b	#'.',1(a6)
	addq	#2,a6	
	
	
	
.LOOP	move	(a1)+,d0
	bmi.s	.NEXT
	move	d0,(a6)+
	bra.s	.LOOP
.NEXT
	dbra	d7,.LOOP_INSTRUCTION
.FIN	

	lea	save_history,a1
	



	move	#$8000,(a6)+

	movem.l	(sp)+,d0-a6
	rts


*------------------------------------------------------------------------------
* DISPLAY_HISTORY::
* on zoom la premiere fenetre dispo
*------------------------------------------------------------------------------
DISPLAY_HISTORY::
	xref	ZOOM_WINDOW,QUIT_ZOOM,ZOOM
	xref	WINDOW_LIST,BUFFER_WINDOW
	xref	GEN_DIVERS
	xref	TITRE,CORP,BOTTOM,CLOSE_WIN


	movem.l	d0-a6,-(sp)

	move.l	ZOOM_WINDOW,d0
	beq.s	GO_DIRECTORY
	bsr.l	QUIT_ZOOM	
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
	
	move	#40,max_ligne(a1)
	move	#80+14,max_col(a1)


	bsr.l	ZOOM
	

	move.l	ACTIVE_WINDOW,a0				
	move	#40,max_ligne(a0)
	move	#80+14,max_col(a0)

	
	
	
	bsr.l	GEN_HISTORY

	xref	CLS_SCREEN
	bsr.l	CLS_SCREEN

	move.l	ACTIVE_WINDOW,a0				
	
	bsr.l	TITRE		
	bsr.l	CORP
	bsr.l	BOTTOM

	xref	get_key
.WAIT	
	bsr.l	get_key
	cmp.b	#1,d0
	beq.S	.EXITED
	cmp.b	#$23,d0
	beq.s	.put_history

	bra.s	.WAIT
	
	
	
	bne.s	.WAIT

.EXITED
	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre
	bsr.l	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW

	movem.l	(sp)+,d0-a6
	
	rts	



.put_history
	bsr.l	r_put_history
	bra	.EXITED






;------------------------------------------------------------------------------
; recopie des bkpt ligne par ligne ds le ASCII BUF
;------------------------------------------------------------------------------
GEN_BKPT_LISTE::
	movem.l	d0-a6,-(sp)

	lea	ASCII_BUF,a6
	
	move.w	COL_NOR,ATTRIBUTE
	copy	<" Liste des points d'arret">,a6
	move.w	#$000d,(a6)+
	move	#$000d,(a6)+
	
	moveq	#0,d4			; compteur pour le point de l'expresion	
	moveq	#1,d3
	
	lea	liste_break,a0
.again	move.l	(a0)+,d0
	beq	.fin
	move.l	d0,d1
	
	
	
	move.l	d3,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a1
	move.w	COL_DSP,d7
	move.b	#'[',d7
	move.w	d7,(a6)+
	move.b	(a1)+,d7
	move.w	d7,(a6)+
	move.b	(a1)+,d7
	move.w	d7,(a6)+
	move.b	#']',d7
	move.w	d7,(a6)+
	
	
	copy	<' '>,a6
	
	
	move.l	d1,d0
	bsr.l	affiche_nombre_zero
	lea	nombre,a1
	move.w	COL_ADR,d7
.cop	move.b	(a1)+,d7
	beq.s	.next
	move.w	d7,(a6)+
	bra.s	.cop
.next
	addq.l	#2,a0
	move.w	(a0)+,d0		; les flags
	


	move.l	d1,a4			; ici l'instruction
	
	bsr	dessas_one_bk
	
	lea	s_buf,a5
	
	
	move.w	#" ",(a6)+
	move.w	#" ",(a6)+
	move.w	#" ",(a6)+
	
	
.cop_instr
	move.b	(a5)+,(a6)+
	bne.s	.cop_instr
	
	subq.l	#1,a6





		
	move.w	COL_BKPT,ATTRIBUTE	; la permanance
	btst	#1,d0
	beq.s	.p_perm
	copy	<'   Perm. '>,a6
	bra.s	.perm
.p_perm
	copy	<'   Normal'>,a6
.perm
	move.w	COL_NOR,ATTRIBUTE
	
	
	
	
	
	
	
	
	
	btst	#0,d0
	beq.s	.p_eval
	
	copy	<'    '>,a6
	lea	eval_bkpt,a4
	add.l	d4,a4
	move.w	COL_NOR,d7
.lo	move.b	(a4)+,d7
	beq.s	.p_eval
	move	d7,(a6)+
	bra.s	.lo
	
.p_eval
	
	
	
	
	add.l	#256,d4
	move	#$000d,(a6)+
	move	#$000d,(a6)+
	addq.l	#1,d3	
	
	bra	.again	
	
	
	
	
	
.fin
	move	#$8000,(a6)+

	movem.l	(sp)+,d0-a6
	rts


*------------------------------------------------------------------------------
* DISPLAY_BKPT ::
* on zoom la premiere fenetre dispo
*------------------------------------------------------------------------------
DISPLAY_BKPT_LISTE::
	xref	ZOOM_WINDOW,QUIT_ZOOM,ZOOM
	xref	WINDOW_LIST,BUFFER_WINDOW
	xref	GEN_DIVERS
	xref	TITRE,CORP,BOTTOM,CLOSE_WIN


	movem.l	d0-a6,-(sp)

	move.l	ZOOM_WINDOW,d0
	beq.s	GO_DIRECTORY1
	bsr.l	QUIT_ZOOM	
GO_DIRECTORY1
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
	
	bsr.l	ZOOM
	

	move.l	ACTIVE_WINDOW,a0				
	
	
	
	
	bsr.l	GEN_BKPT_LISTE

	xref	CLS_SCREEN
	bsr.l	CLS_SCREEN

	move.l	ACTIVE_WINDOW,a0				
	
	bsr.l	TITRE		
	bsr.l	CORP
	bsr.l	BOTTOM

	xref	get_key
.WAIT	
	bsr.l	get_key
	cmp.b	#1,d0
	bne.s	.WAIT

	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre
	bsr.l	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW

	movem.l	(sp)+,d0-a6
	
	rts	


	
	
	
****************************
** Les routines de scroll **
****************************
	
	include 40\main.inc\scroll.s
		
	
	
	
*************************
** Routine qui termine **
*************************
fin
	bsr	clear_bkpt_liste		; on vire les bkpt ‚ventuels
	
	xref	OLD_VIDEO
	;tst.w	RESIDENT
	;bne	exit_res
	move.l	s_p_cla,a0
	move.l	s_cla,(a0)
	
	move.l	s_p_queue,a0
	clr.l	(a0)
	
	
	tst.w	nb_fct_det		; teste si on a des fonctions detournee
	beq.s	.p_fct_det
	
	moveq	#15,d0
	lea	table_trap,a0
	lea	$80,a1
	add.l	ADR_VBR,a1
.res	move.l	(a0)+,(a1)+
	dbra	d0,.res
	
	
	;move.w	nb_fct_det,d7
	;subq.l	#1,d7
	;lea	table_fct_det,a0
	;moveq	#0,d0
.rest	;move.w	(a0),d0
	;addq.l	#4,a0
	;lsl	#2,d0
	;add.l	ADR_VBR,d0
	;add.l	#$80,d0
	;move.l	d0,a1
	;move.l	(a0)+,(a1)
	;dbra	d7,.rest
.p_fct_det
	
	
	move.l	buffer_r+r_vrb,d0	; on regarde si le vbr est decale
	cmp.l	ANC_VBR,d0		; si oui on demande a l'utilisateur de choisir si il veut le replacer
	beq.s	.normal
	
	
.der	move.l	#MES_VBR_R,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	move.l	#MES_SPACE,MESSAGE_ADR
	cmp.w	#$15,d0
	beq.s	.replace_vbr
	cmp.w	#$18,d0
	beq.s	.replace_vbr
	cmp.b	#$31,d0
	beq.s	.normal
	bra.s	.der



.replace_vbr
	move.l	ANC_VBR,d0
	movec	d0,VBR
	
.normal
	
	
	bsr	restore_excep
	lea	OLD_VIDEO,a0
	bsr.l	SET_VIDEO	
	
	
	
	
	sf	user_int
	move.w	#$2300,sr

	bsr	mfree_steph
	
	
	



	xref	MFREE_DIVERS	
	bsr.l	MFREE_DIVERS	
		
	
	;move.l	s_dta,-(sp)
	;move	#$1a,-(sp)
	;trap	#1		;met ma DTA
	;addq	#6,sp
	
	
	
	
	
	
	vide_cache
	active_mouse
	
fin_tout_cours_d
	
	move.l	sauve_la_pile,-(sp)		; on repasse en utilisateur
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	

fin_tout_cours
	bsr	flush_k_sys	
	
	clr.w	-(sp)
	trap	#1


	; on ne peut pas sortir lorsque l'on est resident


;exit_res					; la sortie losrque l'on est resident
;	sf	user_int
;	lea	OLD_VIDEO,a0
;	bsr.l	SET_VIDEO	
;	
;	
;	
;.m	move.b	$fffffc00.w,d0
;	btst	#7,d0
;	beq.S	.m
;	
;	vide_cache
;	active_mouse
;	
;	move.l	sauve_la_pile,-(sp)		; on repasse en utilisateur
;	move.w	#32,-(sp)
;	trap	#1
;	addq.l	#6,sp
;	
;	bsr	flush_k_sys	
;	
;	clr.w	-(sp)
;	trap	#1


fin_residant

	xref	VIDEO_COU
	st	RESIDENT
	move.l	#MES_TRACED,MESSAGE_ADR
	move.w	#0,etat_trace			; qui force la resolution

	lea	VIDEO_COU,a0
	bsr.l	SET_VIDEO	
	
	bsr	mfree_steph
	
	
	
	
	vide_cache
	active_mouse
	
	move.l	sauve_la_pile,-(sp)		; on repasse en utilisateur
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	sf	user_int
	
	
	;move.l	s_dta,-(sp)
	;move	#$1a,-(sp)
	;trap	#1		;met ma DTA
	;addq	#6,sp
	
	
	bsr	flush_k_sys	
	
	move.w	#0,-(sp)
	move.l	LONG_PROG,-(sp)
	move.w	#$31,-(sp)
	trap	#1



mfree_steph
	;tst.l	ADR_CHARGE
	;beq.s	.p_mfree
	;move.l	ADR_CHARGE,-(sp)
	;GEM	Mfree
;.p_mfree
	tst.l	adr_label
	beq.s	.p_mfree1
	move.l	adr_label,-(sp)
	GEM	Mfree
.p_mfree1
	tst.l	buf_label
	beq.s	.p_mfree2
	move.l	buf_label,-(sp)
	GEM	Mfree
.p_mfree2
	tst.l	hash_table
	beq.s	.ap_mfree3
	move.l	hash_table,-(sp)
	GEM	Mfree
.ap_mfree3


	lea	liste_mfree,a6
.ch_liste
	move.l	(a6)+,d0
	beq.s	.fin_mfree
	move.l	d0,-(sp)
	GEM	Mfree
	bra.s	.ch_liste
.fin_mfree
	rts	


catch_excep
***************************************************
** Routine qui va detourne les exception voulues **
***************************************************
	lea	$8,a0
	add.l	ADR_VBR,a0
	lea	table_autori,a1
	lea	table_sauve,a2
	move.l	#TRACE,d0
	moveq	#61,d1			; on detourne 62 veteurs (64 sauf 0&1)

.det	tst.b	(a1)+
	beq.s	.p_det
	move.l	(a0),(a2)+
	move.l	d0,(a0)+
	bra.s	.sui
.p_det
	tst.l	(a0)+			; on n'y touche pas
.sui	dbra	d1,.det


	lea	table_trap,a0		; on remplie la table de detournement
	moveq	#15,d0
	lea	$80.w,a2
	add.l	ADR_VBR,a2
.cop_t	move.l	(a2)+,(a0)+
	dbra	d0,.cop_t	
	


	rts

restore_excep
*******************************************
** routine qui va restorer les exception **
*******************************************
	
	lea	$8,a0
	add.l	ADR_VBR,a0
	lea	table_autori,a1
	lea	table_sauve,a2
	move.l	#TRACE,d0
	moveq	#61,d1			; on restore 62 veteurs (64 sauf 0&1)

.det	tst.b	(a1)+
	beq.s	.p_det
	move.l	(a2)+,(a0)+
	bra.s	.sui
.p_det
	tst.l	(a0)+			; on n'y touche pas
	tst.l	(a2)+			; on n'y touche pas
.sui	dbra	d1,.det
	
	
	
	rts





put_pc::
***************************************************
** Routine qui va mettre la fentre a une adresse **
***************************************************
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_M40_SRC,type(a0)
	bne.s	.p_source
.erreur1
	move.l	#MES_PC_LIGNE,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.annule

	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne.s	.erreur1
	
	tst.w	d1
	beq.s	.erreur
	
	move.l	ACTIVE_WINDOW,a0
	move.l	Src_adr(a0),a1
	move.w	nb_ligne(a1),d0
	cmp.w	d0,d1
	bgt.s	.erreur1
	
	move.l	ptr_conv(a1),a1
	move.l	(a1,d1.w*4),d0
	cmp.l	#-1,d0
	beq.s	.erreur1		; la ligne n'est pas valable
	
	
	move.l	d0,p_c
	
	move.w	d1,Line_nb(a0)
	
	move.l	#MES_OK,a0
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	bsr.l	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR
	rts
	


.p_source


.erreur

	move.l	#MES_PC,a0
	jsr	GET_CHAINE
	tst.b	d0
	beq	.annule


	move.l	a2,a0
	Jsr	eval
	tst.b	d2
	bne.s	.erreur
	
	
	bclr	#0,d1
	
	move.l	d1,a1
	lit_mem.w	a1,d0
	tst.w	ERR_MEM
	bne	.erreur


	
	move.l	d1,p_c
	
	move.l	#MES_OK,a0
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	jsr	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR
.annule

	rts



	

verifie_excep
*******************************************************
** on regarde l'exception qui a declanch‚ l'exeption **
*******************************************************
	move.l	a_pile,a6
	move.w	6(a6),d0
	and.w	#$fff,d0
	cmp.w	#$8,d0				; bus
	bne.s	*+12
	move.l	#MES_BUS,MESSAGE_ADR		
	cmp.w	#$c,d0				; adress
	bne.s	*+12
	move.l	#MES_ADR,MESSAGE_ADR
	cmp.w	#$14,d0				; div 0
	bne.s	*+12		
	move.l	#MES_DIV,MESSAGE_ADR
	cmp.w	#$10,d0				; illegal 
	bne.s	*+12
	move.l	#MES_ILL,MESSAGE_ADR
	cmp.w	#$20,d0				; privilege viol
	bne.s	*+12
	move.l	#MES_PRIV,MESSAGE_ADR
	cmp.w	#$28,d0				; line a
	bne.s	*+12
	move.l	#MES_LINEA,MESSAGE_ADR
	cmp.w	#$2c,d0				; line f
	bne.s	*+12
	move.l	#MES_LINEF,MESSAGE_ADR
	cmp.w	#$30,d0				; reserved
	bne.s	*+12
	move.l	#MES_RESER,MESSAGE_ADR
	cmp.w	#$34,d0				; def pour le 30
	bne.s	*+12
	move.l	#MES_DEF_030,MESSAGE_ADR
	cmp.w	#$38,d0				; format error
	bne.s	*+12
	move.l	#MES_FORM_E,MESSAGE_ADR
	
	****** exception non implementees *******
	
	cmp.w	#$3c,d0				; exept non imple
	blt.s	.p_exp
	cmp.w	#$5c,d0
	bgt	.p_exp
	move.l	#MES_UNINI,MESSAGE_ADR
.p_exp
	cmp.w	#$60,d0				; spurious interrupt
	bne.s	*+12
	move.l	#MES_SPUR,MESSAGE_ADR
	


	****** execption trap #n ******
	
	cmp.w	#$80,d0				; on regarde s'il y a un trap
	blt.s	.p_trap
	cmp.w	#$80+15*4,d0
	bgt	.p_trap
	move.l	#MES_TRAP,MESSAGE_ADR
	sub.b	#$80,d0
	lsr.b	#2,d0
	jsr	affiche_nombre_2
	lea	nombre,a0
	move.b	1(a0),d0
	move.b	d0,MES_TRAP+7
	
.p_trap
	
	****** exeption du copro *******
	
	
	cmp.w	#$c0,d0				; fp bra
	bne.s	*+12
	move.l	#MES_FP_BRA,MESSAGE_ADR
	cmp.w	#$c4,d0				; fp inexact calcul
	bne.s	*+12
	move.l	#MES_FP_INEX,MESSAGE_ADR
	cmp.w	#$c8,d0				; fp div zero
	bne.s	*+12
	move.l	#MES_FP_DIV_Z,MESSAGE_ADR
	cmp.w	#$cc,d0				; fp underflow
	bne.s	*+12
	move.l	#MES_FP_UNDER,MESSAGE_ADR
	cmp.w	#$d0,d0				; fp operand error 
	bne.s	*+12
	move.l	#MES_FP_OP_ERR,MESSAGE_ADR
	cmp.w	#$d4,d0				; fp overflow
	bne.s	*+12
	move.l	#MES_FP_OVER,MESSAGE_ADR
	cmp.w	#$d8,d0				; fp sig nan 
	bne.s	*+12
	move.l	#MES_FP_SIG_NAN,MESSAGE_ADR
	cmp.w	#$dc,d0				; fp unimplemented data type
	bne.s	*+12
	move.l	#MES_FP_UNIMPL,MESSAGE_ADR
	
	
	******* exception mmu ********
	
	
	cmp.w	#$e0,d0				; mmu cnf error
	bne.s	*+12
	move.l	#MMU_CNF_ERROR,MESSAGE_ADR
	


	rts
	
	DATA	
	
	ifne	(LANGUAGE=FRANCAIS)
	
	*------- FRANCAIS -------*
	
MES_BUS
	dc.b	'Erreur de bus',0
	even
MES_ADR
	dc.b	"Erreur d'adresse",0
	even
MES_ILL::
	dc.b	'Exception ill‚gale',0
	even
MES_PRIV
	dc.b	'Violation de privilŠge',0
	even
MES_LINEA
	dc.b	'Exeption line A',0
	even
MES_LINEF
	dc.b	'Exeption line F',0
	even
MES_SPUR
	dc.b	'Spurious interrupt',0
	even
MES_TRAP
	dc.b	'Trap #$0',0
	even
MES_DIV	
	dc.b	'Division par z‚ro',0
	even
MES_RESER
	dc.b	'Exeption r‚serv‚e',0
	even
MES_DEF_030
	dc.b	'Exeption 68030 seulement',0
	even
MES_FORM_E
	dc.b	'Erreur de format',0
	even
MES_UNINI
	dc.b	'Exception non initialis‚e',0
	even
MES_FP_BRA
	dc.b	'FP branchement sur une mauvaise Condition',0
	even
MES_FP_INEX
	dc.b	'FP resultat inexact',0
	even
MES_FP_DIV_Z
	dc.b	'FP Division par zero',0
	even
MES_FP_UNDER
	dc.b	'FP Vide',0
	even
MES_FP_OP_ERR
	dc.b	"FP erreur d'op‚rande",0
	even
MES_FP_OVER
	dc.b	'FP Remplit',0
	even
MES_FP_SIG_NAN
	dc.b	'FP NAN signal‚',0
	even
MES_FP_UNIMPL
	dc.b	'FP type de donn‚e non impl‚ment‚',0
	even
	
MMU_CNF_ERROR
	dc.b	'Erreur de configuration mmu',0
	even
	
	endc
	
	
	
	*------- ANGLAIS -------*
	

	ifne	(LANGUAGE=ANGLAIS)
MES_BUS
	dc.b	'Bus error',0
	even
MES_ADR
	dc.b	'Adress error',0
	even
MES_ILL::
	dc.b	'Illegal exception',0
	even
MES_PRIV
	dc.b	'Privilege violation',0
	even
MES_LINEA
	dc.b	'Line A exeption',0
	even
MES_LINEF
	dc.b	'Line F exeption',0
	even
MES_SPUR
	dc.b	'Spurious interrupt',0
	even


MES_TRAP
	dc.b	'Trap #$0',0
	even
MES_DIV	
	dc.b	'Division by zero',0
	even
MES_RESER
	dc.b	'Reseved exeption',0
	even
MES_DEF_030
	dc.b	'Only 68030 exeption',0
	even
MES_FORM_E
	dc.b	'Format error',0
	even
MES_UNINI
	dc.b	'Unitialized exception',0
	even
MES_FP_BRA
	dc.b	'FP branch or Set on Unordered Condition',0
	even
MES_FP_INEX
	dc.b	'FP inexact Result',0
	even
MES_FP_DIV_Z
	dc.b	'FP Divide by zero',0
	even
MES_FP_UNDER
	dc.b	'FP Underflow',0
	even
MES_FP_OP_ERR
	dc.b	'FP Operand error',0
	even
MES_FP_OVER
	dc.b	'FP Overflow',0
	even
MES_FP_SIG_NAN
	dc.b	'FP Signaling NAN',0
	even
MES_FP_UNIMPL
	dc.b	'FP unimplemented data type',0
	even
MMU_CNF_ERROR
	dc.b	'MMU configuration error',0
	even
	endc	
	
	TEXT
	
devie_vbr
*****************************************************
** routine qui va revectoriser le vbr sur l'ancien **
*****************************************************
	
	
	move.l	a0,s_a01
	move.l	d0,s_d0
	clr.l	d0
	move.l	#0,a0
	move.w	6(sp),d0
	and.w	#$fff,d0
	move.l	d0,a0
	move.l	(a0),a0
	add.l	ANC_VBR1,a0		; on ajoute l'ancin vbr
	pea	(a0)
	move.l	s_a01,a0
	move.l	s_d0,d0
	rts



**********************************************
** les routine de l'affichage des registres **
**********************************************

	;include 40\main.inc\aff_reg.s
		

*************************************************
** les routine de l'affichage du d‚sassemblage **
*************************************************
	
	;include 40\main.inc\aff_desa.s


****************************************
** les routine de l'affichage du dump **
****************************************
	
	;include 40\main.inc\aff_dump.s
	

is_break::
************************************************
** routine qui va tester s'il y a un bkpt     **
**                                            **
** Entr‚e :                                   **
**    - a4 adresse de la recherche            **
** Sortie :                                   **
**    - a1 : pointe sur les attributs du bkpt **
**    - bkpt = 0 pas de bkpt                  ** 
**           <> 0  contient le nb du bkpt     **
************************************************

	movem.l	d0-a0/a2-a6,-(sp)


	*------ tester a4 ------------*
	moveq	#0,d0
	
	tst.l	a4			; a4 peut valoir 0 dans ce cas pas de bkpt
	beq.s	.ok			; pas de bkpt on quitte
	

	lea	liste_break,a1		; on cherche si y a un bkpt
.cherche
	addq.l	#1,d0
	cmp.b	MAX_BK,d0
	beq.s	.p_liste
	cmp.l	(a1)+,a4
	beq.s	.ok
	add.l	#4,a1
	bra.s	.cherche
	
.p_liste
	moveq	#0,d0
.ok					
	move.w	d0,bkpt

	
	
	movem.l	(sp)+,d0-a0/a2-a6
	rts


clear_bkpt_liste::
**********************************************
** routine qui va effacer la liste des bkpt **
**********************************************
	
	lea	liste_break,a2		; on cherche si y a un bkpt
	moveq	#0,d0
	clr.l	d7
	move.b	MAX_BK,d7
	tst.b	d7
	beq.s	.fin
	subq	#1,d7
.eff
	move.l	(a2)+,d0
	move.l	d0,a4
	bsr	is_break
	tst.w	bkpt
	beq.s	.s
	move.l	#0,a1
	bsr	break_point
.s
	addq.l	#4,a2
	dbra	d7,.eff
.fin
	rts

clear_bkpt_liste_old
**********************************************
** routine qui va effacer la liste des bkpt **
**********************************************
	
	lea	liste_break,a1		; on cherche si y a un bkpt
	moveq	#0,d0
	move.b	MAX_BK,d0
	tst.b	d0
	beq.s	.fin
	subq	#1,d0
.eff
	clr.l	(a1)+
	clr.l	(a1)+
	dbra	d0,.eff
.fin
	rts


break_point::
*****************************************************
** Gestion des break points                        **
**                                                 **
** Entr‚e :                                        **
**   - d0 adr du bkpt                              **
**   - a1 adr de la chaine ( d0 ) n'est pas valide **
**       =0 ignore                                 **
** Sortie :                                        **
**   - d0 = 0 ok pour le break                     **
**        <>0 erreur                               **
*****************************************************
	
	
	movem.l	d1-a6,-(sp)
	sf	FLAG_EV				; on efface les flags
	sf	FLAG_EX
	sf	FLAG_PE
	
	move.w	EXEP_ARRET,EXEP_COU
	
	
	ifeq	DEMO_MODE

	
	tst.l	a1				; a1<>0 on a une chaine … analyser
	beq	.p_de_chaine
	move.l	a1,a2
	
	
	cmp.b	#',',(a2)
	bne.s	.y_nb				; l'adresse sera celle de la fenetre
	
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_disas_68,type(a0)
	bne	.imp_put_bkpt_1
	move.l	adr_debut(a0),d0		; adresse du bkpt dans d0
	addq.l	#1,a2
	bra.s	.suiv
.y_nb
	*--- on recupere l'adresse ---*
	lea	temp,a0
.cop	move.b	(a2)+,d0
	tst.b	d0
	beq.s	.x
	cmp.b	#',',d0
	beq.s	.x
	move.b	d0,(a0)+
	bra.s	.cop
.x
	clr.b	(a0)
	lea	temp,a0
	
	bsr.l	eval
	tst.b	d2
	bne	.p_de_chaine
	xref	convert_inv
	bsr.l	convert_inv
	move.l	d1,d0
	
	
	*------------------ ne plus toucher a d0 qui contient l'adr du bkpt -----*
	
.suiv

	tst.b	(a2)
	beq	.p_de_chaine			; fin de chaine, on quitte


	*------------------ a3 va contenir la chaine a evaluer ----*

	move.l	a2,a3		
	move.b	(a2)+,d1
	tst.b	d1
	beq	.p_de_chaine			; fin de chaine, on quitte
	cmp.b	#',',d1				; la chaine d'‚valuation est vide
	beq.s	.p_eval
	st	FLAG_EV				; dans a2 on aura la chaine qui pointe sur l'expression
.avance	move.b	(a2)+,d1
	tst.b	d1
	beq	.p_de_chaine
	cmp.b	#',',d1
	bne.s	.avance


.p_eval
	tst.b	(a2)				; teste de la permanence
	beq	.p_de_chaine			; fin de chaine, on quitte
	move.b	(a2)+,d1
	tst.b	d1
	beq	.p_de_chaine			; fin de chaine, on quitte
	cmp.b	#',',d1
	beq.s	.p_perma
	
	cmp.b	#'0',d1
	bne.s	.p_z
	sf	FLAG_PE
	addq.l	#1,a2
	bra.s	.p_perma
.p_z
	cmp.b	#'1',d1
	bne.s	.p_u
	st	FLAG_PE
	addq.l	#1,a2
	bra.s	.p_perma
.p_u
	bra	.imp_put_bkpt_1			; erreur si pas 0 ou 1
	
.p_perma
	tst.b	(a2)				; teste du num de l'exeption
	beq	.p_de_chaine
	move.b	(a2)+,d1
	tst.b	d1
	beq	.p_de_chaine
	cmp.b	#',',d1
	beq	.p_excep
	
	*--- pour l'instant on ignore cette option ---*
	
.p_virg
	cmp.b	#',',-(a2)
	bne.s	.p_virg
	
	addq.l	#1,a2
	
	move.l	d0,d7				; sauvegarde de d0
	
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne	.imp_put_bkpt_1
	
	
	cmp.l	#3,d1				; ici, on fait la comparaison avec les
	bne.s	.su1				; exception autoris‚e
	move.w	#$6001,EXEP_COU
	bra.s	.ok_excep	
.su1
	cmp.l	#4,d1				; illegal
	bne.s	.su2
	move.w	#$4afc,EXEP_COU
	bra.s	.ok_excep
.su2	
	

	
	cmp.l	#32,d1				; trap	#0
	blt	.imp_put_bkpt_1
	cmp.l	#47,d1				; trap	#15
	bgt	.imp_put_bkpt_1	
	*--- ici l'exception est entre 32 et 47
	*--- il faut voir si elle est dans table autori
	*--- sinon erreur
	
	move.l	d1,d2
	lea	table_autori,a4
	sub.l	#3,d2

	
.avan	add.l	#1,a4
	dbra	d2,.avan
	
	
	tst.b	(a4)				; a t on le droit
	beq	.imp_put_bkpt_1

	sub.l	#32,d1
	move.l	#$4e40,d2
	add.l	d1,d2
	move.w	d2,EXEP_COU
	
.ok_excep
	
	
	move.l	d7,d0				; restauration de d0
	
	
.p_excep
		

	endc
	
	
	
.p_de_chaine
	move.l	d0,a4
	move.l	a4,a5
	
	bsr	is_break			; on regarde s'il existe deja
	move.l	a1,a0
	tst.w	bkpt				; dans ce cas on le vire
	bne	.exist
	
	lea	liste_break,a0			; sinon on va installer le bkpt
	move.w	#0,bkpt
	moveq	#0,d0				; dans un endroit libre
.cherche
	addq.w	#1,bkpt
	addq.l	#1,d0
	cmp.b	MAX_BK,d0	
	beq	.fin_liste			; trop de bkpt
	tst.l	(a0)
	bne	.occupe
	
	
	
	;cmp.l	#$e00000,a4
	;bge	.imp_put_bkpt
	
	
	move.l	a0,a1
	
	lit_mem.w	a4,d7			; on lit la donn‚e en m‚moire avec
	tst.b	ERR_MEM				; teste de validit‚
	bne	.imp_put_bkpt
	move.l	a4,(a0)+			; on stocke l'adr
	move.w	d7,(a0)+			; on stocke la donne
	
	move.w	EXEP_COU,d7			; l'exception qui va servir pour ce bkpt
	
	;move.w	EXEP_ARRET,d7			; on ‚crit l'execption correspondante
	writ_mem.w	d7,a4
	tst.b	ERR_MEM
	bne	.imp_put_bkpt
	
	
	move.w	#0,d7
	
	tst.b	FLAG_EV				; flag evaluateur
	beq.s	.p_eva
	bset	#0,d7
	lea	eval_bkpt,a4
	moveq	#0,d6
	move.w	bkpt,d6
	subq.l	#1,d6
	mulu	#256,d6
	add.l	d6,a4				; pointe sur la ligne corresspondante
.copi	move.b	(a3)+,d6
	tst.b	d6
	beq.s	.xx
	cmp.b	#',',d6
	beq.s	.xx
	move.b	d6,(a4)+
	bra.s	.copi
.xx
	clr.b	(a4)
	
.p_eva
	tst.b	FLAG_PE				; flag permanence
	beq.s	.p_ev
	bset	#1,d7
.p_ev

	
	move.w	d7,(a0)				; on stocke les flags
	
	move.l	#BK_PUT,a0
	bsr	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR
	
	
	move.l	BKPT_VECT,a0
	add.l	ADR_VBR,a0
	move.l	#TRACE,(a0)
	
	
	moveq	#0,d0				; ok
	bra.s	.fin_r
.occupe
	cmp.l	(a0)+,a4
	beq.s	.exist				; le bkpt existe deja
	addq.l	#4,a0
	bra	.cherche
.exist
	clr.l	-4(a0)
	move.w	(a0)+,(a4)			; on enleve pas la peine de tester, c'est valide
	clr.l	-2(a0)
	move.l	#0,perm_bkpt
	
	move.l	#BK_KILLED,a0
	bsr	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR
	moveq	#0,d0				; ok
.fin_r	
	movem.l	(sp)+,d1-a6
	rts	

.imp_put_bkpt
	clr.l	(a1)+				; on vire le bkpt
	clr.l	(a1)+				; s'il avit commencer … s'installer
	move.l	#BKPT_IMP,MESSAGE_ADR
	moveq	#-1,d0				; erreur
	move.l	#0,bkpt
	bra.s	.fin_r
.imp_put_bkpt_1
	move.l	#BKPT_IMP,MESSAGE_ADR
	moveq	#-1,d0				; erreur
	move.l	#0,bkpt
	bra.s	.fin_r
.fin_liste					; trop de bkpt
	move.l	#TROP_BK,MESSAGE_ADR
	moveq	#-1,d0				; erreur
	move.l	#0,bkpt
	bra.s	.fin_r


	;endc

prepare_chaine_bkpt::
********************************************
** on prepare la chaine avec le nume bkpt **
** d0 num du bkpt a0 adr de fin de mess   **
********************************************
	lea	BKPT_M,a1
	lea	BUF_BKPT,a2
.o	move.b	(a1)+,(a2)+
	tst.b	(a1)
	bne.s	.o
	move.w	bkpt,d0
	and.l	#$ff,d0
	bsr.l	affiche_nombre_2
	lea	nombre,a1
	cmp.b	#'0',(a1)
	bne.s	.p_z
	addq.l	#1,a1
.p_z
.c2	move.b	(a1)+,(a2)+
	tst.b	(a1)
	bne.s	.c2
	move.b	#' ',(a2)+
.i	move.b	(a0)+,(a2)+
	tst.b	(a0)
	bne.s	.i
	rts	

	DATA
	ifne	(LANGUAGE=FRANCAIS)

	*------ FRANCAIS ------*

TROP_BK	dc.b	'Trop de Breakpoints',0
	even
BKPT_M
	dc.b	'Breakpoint #$',0
	even
BK_KILLED::
	dc.b	'Enlev‚         ',0
	even
BK_PUT::	dc.b	'mis            ',0
	even
BK_REACH::
	dc.b	'atteint        ',0
	even
BKPT_IMP::
	dc.b	'Impossible de placer le bkpt',0
	even
	endc

	*------ ANGLAIS ------*
	ifne	(LANGUAGE=ANGLAIS)
TROP_BK	dc.b	'Too many Breakpoints',0
	even
BKPT_M
	dc.b	'Breakpoint #$',0
	even
BK_KILLED::
	dc.b	'killed         ',0
	even
BK_PUT::	dc.b	'put            ',0
	even
BK_REACH::
	dc.b	'reached        ',0
	even
BKPT_IMP::
	dc.b	'Impossible to put the bkpt',0
	even
	endc	
	TEXT

dessas_one_bk::
********************************************
** routine qui desassemble une            **
** instruction en tenant compte des bk pt **
********************************************
	movem.l	a0/a1/a5/d0/d1/d7,-(sp)
	lea	s_buf,a0
	
	bsr	is_break
	tst.w	bkpt
	beq.s	.p_trouve
	
	move.l	a4,a5
	
	move.w	(a4),d7				; dans d7, on a le type d'exeption
	move.w	(a1)+,(a4)			; pas la peine de tester c'est valide
		
.p_trouve
	bsr.l	dessas_one
	lea	m,a1
.co	move.b	(a1)+,(a0)+
	bne.s	.co
	subq.l	#1,a0
	clr.l	(a0)
	
	
	tst.w	bkpt
	beq.s	.p_bkpt				; faire attention a d1 a ne pas le cracher
	move.w	d7,(a5)				; on remplace le meme type d'exception
.p_bkpt
	movem.l	(sp)+,a0/a1/a5/d0/d1/d7
	rts


test_branchement
****************************************************
** routine qui va se charger de trouver la fleche **
** qui correspond au branchement donne            **
** d0=sr d1=adr_pc                                **
****************************************************
	move.l	d1,a0
	
	move.l	a0,a4
	bsr	is_break
	tst.w	bkpt
	beq	.p_bkpt
	move.w	(a0),d6			; on sauve l'ancien bkpt
	move.w	(a1),(a0)		; on remet en place l'instruction
.p_bkpt					; instruction normale
	move.w	(a0),d1				; l'opcode
.bkp
	
	
	move.w	d1,d2
	and.w	#%1111000000000000,d1
	cmp.w	#%0110000000000000,d1
	beq.s	.bcc
	move.w	d2,d1
	and.w	#%1111000011111000,d1
	cmp.w	#%0101000011001000,d1
	beq	.dbcc
	
	move.w	d2,d1
	and.w	#%1111111110000000,d1
	cmp.w	#%1111001010000000,d1
	beq	.fbcc
	
	move.w	d2,d1
	and.w	#%1111111111111000,d1
	cmp.w	#%1111001001001000,d1
	beq	.fdbcc
	
	
	
	
	
	nop
	nop
.bcc
	clr.w	d3
	move.w	#%0110,d3			; opcode du bcc
	lsl.w	#4,d3
	lsr.w	#8,d2
	and.w	#%1111,d2
	cmp.b	#1,d2
	bne.s	.norm
	moveq	#0,d2
.norm
	or.b	d2,d3				; copie de la condition
	lsl.w	#8,d3
	move.b	#2,d3				; deplacement pour le test on saute un 2 octect
	lea	.prog,a1
	move.w	d3,(a1)
	moveq	#0,d7
	
	vide_cache
	
	nop
	nop
	nop
	
	
	move	d0,ccr
.prog
	nop					; ici, on va automodifier
	st	d7
	bra	.st

.fbcc
	move.w	d2,d1
	and.w	#%111111,d1	
	
	
	lea	.prog2,a1
	move.w	(a1),d3
	and.w	#%1111111111000000,d3
	or.w	d1,d3
	move.w	d3,(a1)
	moveq	#0,d7
	
	
	vide_cache
	
	nop
	nop
	nop
	
	
	fmove	buffer_r+r_fpsr,fpsr
	move.l	.prog2,$800000
.prog2
	fbge	.klo
	st	d7
.klo	bra	.st

.fdbcc

	;illegal

	move.w	2(a0),d1
	and.w	#%111111,d1	
	
	
	lea	.prog3,a1
	move.w	2(a1),d3
	and.w	#%1111111111000000,d3
	or.w	d1,d3
	move.w	d3,2(a1)
	moveq	#0,d7
	
	
	vide_cache
	
	nop
	nop
	nop
	
	fmove	buffer_r+r_fpsr,fpsr
	move.l	.prog3,$800008
	
.prog3
	fdbgt	d0,.klo1
	st	d7
.klo1	bra	.st




.dbcc
	clr.w	d3
	move.w	#%0101,d3			; opcode du bcc
	lsl.w	#4,d3
	lsr.w	#8,d2
	and.w	#%1111,d2
	cmp.b	#0,d2
	bne.s	.norm1
	moveq	#1,d2
.norm1
	or.b	d2,d3				; copie de la condition
	lsl.w	#8,d3
	or.w	#%11001000,d3			; on complete l'opcode
	lea	.prog1,a1
	move.w	d3,(a1)
	moveq	#0,d7
	move.w	d0,d1
	move.w	#4,d0
	
	
	vide_cache
	nop
	nop
	nop
	
	move	d1,ccr
.prog1
	nop					; ici, on va automodifier
	dc.w	$0004				; ici c'est la taille du dbra
	st	d7
	
	
.st
	tst.b	d7
	beq.s	.branch
	move.b	#3,forme_curseur
	bra	.p_branch
.branch
	move.b	#'*',forme_curseur
	
	move.w	(a0),d1
	move.w	d1,d2
	and.w	#%1111000011111000,d1		; on a 1 dbra
	cmp.w	#%0101000011001000,d1
	bne.s	.p_dbra

	and.w	#%111,d2
	lea	buffer_r,a6
	move.l	(a6,d2*4),d0
	tst.w	d0
	bne	.16bit				; on va cacculer l'adresse du dbra en utilisaant la
	move.b	#3,forme_curseur		; routine du bra
	bra	.p_branch





.p_dbra			
	move.w	(a0),d1
	move.w	d1,d2
	and.w	#%1111111111111000,d1		; on a un fdbcc
	cmp.w	#%1111001001001000,d1
	bne.s	.p_fdbcc
	

	and.w	#%111,d2
	lea	buffer_r,a6
	move.l	(a6,d2*4),d0
	tst.w	d0
	bne	.ici				; on va cacculer l'adresse du dbra en utilisaant la
	move.b	#3,forme_curseur		; routine du bra
	bra	.p_branch
.ici


	move.l	a0,d2
	clr.l	d1
	move.w	4(a0),d1
	btst	#15,d1
	beq.s	.posi12
	neg.w	d1
	sub.l	d1,d2
	add.l	#2,d2
	bra.s	.f
.posi12
	add.l	d1,d2
	sub.l	#2,d2
	bra.s	.f


.p_fdbcc






	move.w	(a0),d1
	and.w	#%1111111110000000,d1
	cmp.w	#%1111001010000000,d1
	bne	.p_fbcc
	btst	#6,d0
	bne	.32bits
	bra	.16bit

.p_fbcc
	
	clr.l	d1				; on a un brachement on cherche le sens
	move.b	1(a0),d1
	tst.b	d1
	beq.s	.16bit
	cmp.b	#$ff,d1
	beq.s	.32bits
	move.l	a0,d2				; branchement 8 bits
	btst	#7,d1
	beq.s	.posi
	neg.b	d1
	sub.l	d1,d2
	bra.s	.f
.posi
	add.l	d1,d2
	bra.s	.f
.16bit						; branchement 16 bits
	move.l	a0,d2
	clr.l	d1
	move.w	2(a0),d1
	btst	#15,d1
	beq.s	.posi1
	neg.w	d1
	sub.l	d1,d2
	bra.s	.f
.posi1
	add.l	d1,d2
	bra.s	.f
.32bits
	move.l	a0,d2
	move.l	2(a0),d1
	btst	#31,d1
	beq.s	.posi2
	neg.l	d1
	sub.l	d1,d2
	bra.s	.f
.posi2
	add.l	d1,d2
.f
	add.l	#2,d2
	cmp.l	a0,d2
	bne.s	.diff
	move.b	#'~',forme_curseur
	bra.s	.p_branch
.diff
	blt.s	.ptit
	move.b	#2,forme_curseur
	bra.s	.p_branch
.ptit
	move.b	#1,forme_curseur


.p_branch
	;move.b	#1,forme_curseur


; *** on restore le bkpt 


	move.l	a0,a4
	bsr	is_break
	tst.w	bkpt
	beq	.p_bkpt1
	move.w	d6,(a0)		; on sauve l'ancien bkpt
.p_bkpt1


	rts
	
	
	
	
******************************************
** on inclut les routines de chargement **
******************************************
	
	;include 40\main.inc\load.s


*************************************
** ici on insere le numero interne **
** pour eviter toute diffusion     **
*************************************

	dc.l	'M.A.'
	dc.l	nom

************************************************
** routine qui va se mettre avant la routine  **
** clavier et qui va donc regarder l'etat des **
** touche shift alt help                      **
************************************************	

rout_ikbd
	sf	flag_user_dsp
	sf	flag_user_b
	cmp.b	#$62,d0			;touche help ?
	bne.s	.pas_ok

	cmp.b	#$c,([touches_mortes_adr])
	beq.s	.STOP_DSP
	cmp.b	#$a,([touches_mortes_adr])
	beq.s	.STOP_40
	bra.S	.pas_ok
.STOP_DSP
	st	flag_user_dsp
.STOP_40
	
	st	flag_user_b

	xref 	etat_touche
	clr.l	etat_touche

	move.b	#$62+$80,d0	; on relache artificiellement la touche
	clr.b	([touches_mortes_adr])	;adresse DOLMEN

.pas_ok
	
	
	move.l	s_cla,-(sp)
	rts





catch_alt_help
********************************************************
** routine qui se place en queue vbl et qui surveille **
** l'etat de la touche alt_help                       **
********************************************************
	
	
	tst.b	user_int		; ne se declenche pas dans le debogueur
	bne	.normal
	
	
	
	tst.b	flag_user_dsp
	beq.s	.NO_DSP
	xref	STOP_DSP	
	bsr.l	STOP_DSP	
	sf	flag_user_dsp


.NO_DSP	tst.b	flag_user_b
	beq.s	.normal
	
	
	;move.l	a6,-(sp)
	;lea	buffer_fpu,a6
	;fsave	-(a6)
	;lea	buffer_fpu,a6
	;move.l	(a6),d0
	;illegal
	;cmp.b	#$38,1(a6)
	;beq.s	.pas_encore
.norm_copro
	;move.l	(sp)+,a6
	
	
	
	
	sf	flag_user_b
	
	
	st	user_int		; on valide le flag utilisateur
	
	
	move.l	74(sp),adr_retour	
	move.l	#TRACE,74(sp)		; on place le trace a la place de l'adresse de retour
	move	72(sp),adr_sr
	move	78(sp),adr_off	
	bset	#5,72(sp)
	bclr	#7,72(sp)
	
	
	
.normal
	rts

.pas_encore
	*   le copro n'a pas encore fini *
	
	
	illegal
	
	move.l	(sp)+,a6
	rts



INIT_DEBUG
	xref	HOST_BUF,TEMP_BUF
	move.l	#'CTK',HOST_BUF
	move.l	#'CTK',TEMP_BUF
**********************************************************
** ROUTINE QUI VA SE CHARGER D'INITIALISER LE DEBUGUEUR **
**********************************************************
	
	
	
	lea	prog_a_tester,a4
	move.l	a4,anc_a4
	move.l	a4,adr_a4
	move.l	a4,p_c
	move.l	a4,a_p_c
	
	move.l	(sp)+,RET_DEB

	*---------------------*
	* sauve qqes registres
	*---------------------*

	lea	buffer_r,a6
	move.l	p_c,r_pc(a6)
	move.l	#$300,r_sr(a6)
	;movec	usp,d0
	;move.l	d0,r_usp(a6)
	movec	isp,d0
	
	move.l	d0,r_ssp(a6)
	movec	msp,d0
	move.l	d0,r_msp(a6)
	movec	isp,d0
	
	sub.l	#12,d0			; pour compenser l'empilage
	
	move.l	d0,r_isp(a6)
	movec	usp,d0
	move.l	d0,r_usp(a6)
	move.l	d0,r_a7(a6)
	
	cmp.w	#cpu_30,CPU_TYPE	; 68030
	bne.s	.p_030	
	
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	movec	caar,d0
	move.l	d0,r_caar(a6)
	
	
	pmove	tc,r_tc(a6)
	pmove	crp,r_crp(a6)			
	pmove	srp,r_srp(a6)
	pmove	tt0,r_tt0(a6)
	pmove	tt1,r_tt1(a6)
	pmove	mmusr,r_mmusr+2(a6)
.p_030
	cmp.w	#cpu_40,CPU_TYPE		; 68040
	bne.s	.p_040
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	

	dc.l	$4e7a0805			;movec	mmusr,d0
	move.l	d0,r_mmusr(a6)
	dc.l	$4e7a0003			;movec	tc,d0
	move.l	d0,r_tc(a6)
	dc.l	$4e7a0806			;movec	urp,d0
	move.l	d0,r_crp(a6)
	dc.l	$4e7a0807			;movec	srp,d0
	move.l	d0,r_srp(a6)
	dc.l	$4e7a0004			;movec	itt0,d0
	move.l	d0,r_ittr0(a6)
	dc.l	$4e7a0005			;movec	itt1,d0
	move.l	d0,r_ittr1(a6)
	dc.l	$4e7a0006			;movec	dtt0,d0
	move.l	d0,r_dttr0(a6)
	dc.l	$4e7a0007			;movec	dtt1,d0
	move.l	d0,r_dttr1(a6)
	
.p_040
	
	
	
	cmp.w	#cpu_60,CPU_TYPE
	bne.s	.p_060
	
	
	movec	cacr,d0
	move.l	d0,r_cacr(a6)
	
	dc.w	$f4d8
	;cinv 	bc
	nop
	move.l	#$80008000,d0			; active les caches
	movec	d0,cacr
	nop

	
	;dc.l	$4e7a0805			;movec	mmusr,d0
	;move.l	d0,r_mmusr(a6)
	
	
	dc.l	$4e7a0003			;movec	tc,d0
	move.l	d0,r_tc(a6)
	dc.l	$4e7a0806			;movec	urp,d0
	move.l	d0,r_crp(a6)
	dc.l	$4e7a0807			;movec	srp,d0
	move.l	d0,r_srp(a6)
	dc.l	$4e7a0004			;movec	itt0,d0
	move.l	d0,r_ittr0(a6)
	dc.l	$4e7a0005			;movec	itt1,d0
	move.l	d0,r_ittr1(a6)
	dc.l	$4e7a0006			;movec	dtt0,d0
	move.l	d0,r_dttr0(a6)
	dc.l	$4e7a0007			;movec	dtt1,d0
	move.l	d0,r_dttr1(a6)
	dc.l	$4e7a0008			;movec	buscr,d0
	move.l	d0,r_buscr(a6)
	dc.l	$4e7a0808			;movec	pcr,d0
	move.l	d0,r_pcr(a6)
.p_060
	
	
	clr.l	d0
	movec	dfc,d0
	move.l	d0,r_dfc(a6)
	clr.l	d0
	movec	sfc,d0
	move.l	d0,r_sfc(a6)
	
	*---------------------*
	* registres internes *
	lea	buffer_int,a6
	lea	r_i0(a6),a6
	rept	8
	clr.l	(a6)+
	endr
	
	*---------------------*
	* clavier
	*---------------------*
	move.l	#0,perm_bkpt		; on ne replace pas le bkpt en sortant

	clr.l	anc_touche
	
	
	clr.l	ADR_CHARGE
	
	
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move.l	d0,a0
	subq.l	#4,a0
	move.l	a0,s_p_cla
	pea	(a0)

	*---------------------*
	* VBR & CO
	*---------------------*

	clr.l	d0
	movec	vbr,d0			; mise en place des expections + vbr
	move.l	d0,ADR_VBR		
	move.l	d0,ANC_VBR
	
	
	move.l	#$80,BKPT_VECT
	
	lea	prog_a_tester,a1
	move.l	a1,a0
	add.l	#$1c,a0
	add.l	2(a1),a0
	add.l	6(a1),a0
	move.l	14(a1),d0		; longeur de la section
	add.l	#$1c,a1



	;---------------- on pourra changer ici et mettre dsp a la place ---------------------



	ifeq	PHENIX


	*---------------------*
	* inits DSP
	*---------------------*

	xref	load_dsp_prog	
	jsr	load_dsp_prog
	
	
	
	*---------------------*
	* init du trap #4
	*---------------------*
	xref	DSP_WAKE_UP
	move.l	#DSP_WAKE_UP,$90.w


	endc

;------------------------------------------------------------------------------
; doit on charger un fichier DSP au d‚marrage ??
;------------------------------------------------------------------------------
	cmp	#1,DSP_CHARGE_AUTO
	beq.s	.LOD
	cmp	#2,DSP_CHARGE_AUTO
	beq.s	.CLD
	bra.S	.OK_AUTO
	xref	AUTO_LOAD_LOD
.LOD	bsr.l	AUTO_LOAD_LOD
	bra.S	.OK_AUTO
	xref	AUTO_LOAD_CLD
.CLD	bsr.l	AUTO_LOAD_CLD
	bra	.OK_AUTO
	
.OK_AUTO
	clr	DSP_CHARGE_AUTO
;------------------------------------------------------------------------------
	


	ifeq	PHENIX
	
	bsr	flush_k_sys
	
	endc
	
	
	move.w	#$2700,sr
	*---------------------*
	* recherche le cookye ikbd
	* pour avoir l'adresse des 
	* touches mortes
	*---------------------*
	move.l	#$1187,touches_mortes_adr

	move.l	#'IKBD',d0
	move.l	$5a0.w,a0
	tst.l	a0
	beq	.LA_SUITE	;pas de cooky jar !! ou la la c'est grave !!
.youpz
	move.l	(a0),d1
	beq	.LA_SUITE		;vid‚ le cooky jar !
	cmp.l	d1,d0
	beq.s	.OKOL		;trouv‚ !!
	lea	8(a0),a0
	bra.s	.youpz
.OKOL	move.l	4(a0),a0
	move.l	28(a0),a0		;ptr infos
	
	lea	6(a0),a0		;ikbd_deadkeys !!!
	move.l	a0,touches_mortes_adr	;l'adresse des touches mortes
	


.LA_SUITE
	move.l	(sp)+,a0
	move.l	(a0),s_cla		; mets en place la routine clavier
	move.l	#rout_ikbd,(a0)


	


	*---------------------*
	* recherche la premiere 
	* fenetre de desas et met
	* sont adresse ds le PC
	*---------------------*
	
	xref	WINDOW_LIST
	lea	WINDOW_LIST,a2
	move	#31,d7
.SC	move.l	(a2)+,a3
	cmp	#T_disas_68,type(a3)
	beq.s	.OK0
	dbra	d7,.SC
	lea	$e00030,a4
	bra	.FIN00
.OK0	move.l	adr_debut(a3),a4
	
.FIN00	
	
	lea	save_history,a0		; effacement de la table d'history
	clr.l	(a0)
	clr.l	600(a0)
	clr.l	600*2(a0)
	clr.l	600*3(a0)
	clr.l	600*4(a0)
	clr.l	600*5(a0)
	clr.l	600*6(a0)
	clr.l	600*7(a0)
	
	
	
	
	lea	prog_a_tester,a4
	move.l	a4,-(sp)
	move.w	#$2024,-(sp)
	move.l	a4,-(sp)
	move	VARIABLE_PROTEC,d0
	ext.l	d0
	
	
	;add.l	d0,RET_DEB
	
	
	
	move.w	#$300,-(sp)		; on met le trace

	
	
	move.l	BASE_VECT_DISK,a0	; sauvegarde des vecteurs disks
	lea	REF_DISK,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	

	
	xref	chaine_encore
	clr.b	(chaine_encore)

	bsr	catch_excep
		
	move.l	RET_DEB,-(sp)		;adresse de retour
	
	
	;move.l	BKPT_VECT,a0		; put le bkpt en place
	;add.l	ADR_VBR,a0
	;move.l	#TRACE,(a0)

	move.l	#vbr_deviation,a0
	
	lea	table_autori,a1
	
	
	move.l	#TRACE,(a0)+
	move.l	#TRACE,(a0)+
	
	move.l	#254,d0
.copie
	tst.b	(a1)+
	bne.s	.p_dev
	move.l	#devie_vbr,(a0)+
	bra.s	.dev
	
.p_dev
	move.l	#TRACE,(a0)+
	
.dev
	dbra	d0,.copie



	sf	prog_launch
	move.l	#0,save_instruc	

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	
	;add.l	#10,(sp)		;protec
	
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6


	ifne	FPU_PRES

	lea	buffer_r+r_fp0,a6
	
	fmove.x	fp0,(a6)
	lea	12(a6),a6
	fmove.x	fp1,(a6)
	lea	12(a6),a6
	fmove.x	fp2,(a6)
	lea	12(a6),a6
	fmove.x	fp3,(a6)
	lea	12(a6),a6
	fmove.x	fp4,(a6)
	lea	12(a6),a6
	fmove.x	fp5,(a6)
	lea	12(a6),a6
	fmove.x	fp6,(a6)
	lea	12(a6),a6
	fmove.x	fp7,(a6)
	lea	12(a6),a6
	
	
	
	
	fmove.l	fpsr,buffer_r+r_fpsr
	fmove.l	fpcr,buffer_r+r_fpcr
	fmove.l	fpiar,buffer_r+r_fpiar
	
	
	
	
	move.l	d0,a6
 
 	
 	endc
 
	bsr.l	sauve_anc_reg
	
	sf	user_int
	sf	flag_w
	
	
	;move.l	(sp),RET_DEB
	;
	;illegal
	
	RTS


	dc.l	'YOPI'


*************************
** la routine de reset **
*************************

RESET::
	jmp	$e00030				; le reset classique
RESET_FROID::
	clr.l	$420.w				; le reset … froid
	clr.l	$51a.w
	clr.l	$43a.w
	jmp	$e00030
	
RESET_TOTAL::					; le reset mechant qui efface tout.
	
	move.w	#$2700,sr
	cmp.w	#cpu_30,CPU_TYPE
	bne.s	.aaa
	
	
	lea	8.w,a0
	lea	.FAIT_RESET(pc),a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a0)
	movem.l	32(a1),d0-d7
	movem.l	d0-d7,32(a0)
	movem.l	64(a1),d0-d7
	movem.l	d0-d7,64(a0)
	jmp	10+8(a0)
	 
.FAIT_RESET
	dc.l	12
	move.l	4.w,a0
	jmp	(a0)
	dc.l	0
	dc.l	0
	
	;reset
	
	lea	$1000,a7
	lea	.yop(pc),a1

	pmove.l	$12,tc
	pmove.l	$12,tt0
	pmove.l	$12,tt1
	
	moveq	#0,d0
	movec	d0,vbr
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
.EFF_TOUT
	movem.l	d0-d7,(a1)
	lea	32(a1),a1
	bra.s	.EFF_TOUT	
.yop


.aaa	move.l	$4.w,a0
	jmp	(a0)


Restore_reg::
**************************************************
** routine qui va restaurer les registres sauve **
**************************************************
	
	ifne	FPU_PRES
	
	lea	buffer_r,a6
	
	lea	r_fp0+buffer_r,a6
	
	
	
	fmove.x	(a6),fp0
	lea	12(a6),a6
	fmove.x	(a6),fp1
	lea	12(a6),a6
	fmove.x	(a6),fp2
	lea	12(a6),a6
	fmove.x	(a6),fp3
	lea	12(a6),a6
	fmove.x	(a6),fp4
	lea	12(a6),a6
	fmove.x	(a6),fp5
	lea	12(a6),a6
	fmove.x	(a6),fp6
	lea	12(a6),a6
	fmove.x	(a6),fp7
	lea	12(a6),a6
	
	;fmovem.x	(a6),fp0-fp7
	
	fmove.l	buffer_r+r_fpiar,fpiar
	fmove.l	buffer_r+r_fpcr,fpcr
	fmove.L	buffer_r+r_fpsr,fpsr

	move.l	s_fpu,a6
	frestore	(a6)+

	endc
	
	lea	buffer_r,a6
	move.l	a_pile,a5
	
	move.l	r_sr(a6),d0			; on remet le sr
	move.w	d0,(a5)
	
	
	move.l	r_pc(a6),2(a5)
	;move.l	r_pc(a6),a_p_c
	move.l	r_usp(a6),a0
	movec	a0,usp
	move.l	#$24,a0
	
	move.l	r_vrb(a6),d0
	move.l	d0,ADR_VBR
	add.l	ADR_VBR,a0
	move.l	#TRACE,(a0)
	move.l	ADR_VBR,d0
	
	movec	d0,vbr

	
	move.l	r_msp(a6),d0		; on restaure le point msp
	movec	d0,msp	
	
	
	move.l	r_ssp(a6),d0
	sub.l	Correction_pile,d0
	
	
	*--- on va restaurer le pointeur de pile AVEC SON CONTENU
	*--- s'il a chang‚
	
	cmp.l	a_pile,d0
	beq.s	.p_change
	
	;illegal
	
	move.l	d0,a1
	move.l	a_pile,a0
	move.l	Correction_pile,d1
	subq.l	#1,d1
	
.cop_pile
	move.b	(a0)+,(a1)+
	dbra	d1,.cop_pile
	move.l	d0,a_pile
	
.p_change
	
	;movec	d0,isp
	
	
	
	
	cmp.w	#cpu_30,CPU_TYPE		; si on a un 68030
	bne.s	.p_030
	move.l	r_caar(a6),d0
	movec	d0,caar
	move.l	r_cacr(a6),d0
	movec	d0,cacr

	pmove r_tt1(a6),tt1
	pmove r_tt0(a6),tt0
	
	
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
	
	
	pmove r_crp(a6),crp
	pmove r_tc(a6),tc
	pflusha



.p_030
	cmp.w	#cpu_40,CPU_TYPE		; si on a un 68040
	bne.s	.p_040
	move.l	r_cacr(a6),d0
	movec	d0,cacr

.p_040




	clr.l	d0
	move.l	r_dfc(a6),d0
	movec	d0,dfc
	clr.l	d0
	move.l	r_sfc(a6),d0
	movec	d0,sfc
	




	movem.l	(a6),d0-a6

	rts


sauve_anc_reg::
*****************************************************
** routine qui va sauver les anciens registre pour **
** voir s'il y a u du changement                   **
*****************************************************
	movem.l	d0/a0-a1,-(sp)
	lea	buffer_r,a0
	lea	buffer_r_anc,a1

	move.w	#199,d0
.j	move.l	(a0)+,(a1)+
	dbra	d0,.j
	
	
	lea	buffer_int,a0
	lea	buffer_int_anc,a1

	move.w	#199,d0
.j1	move.l	(a0)+,(a1)+
	dbra	d0,.j1
	

	movem.l	(sp)+,d0/a0-a1
	rts




flush_k_sys::
****************************************************
** routine systŠme qui va vider le buffer clavier **
****************************************************
.check_k
	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13
	addq.l	#4,sp

	tst.b	d0
	beq.s	.exit		; pas de caractŠre => buffer vide

	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp

	bra.s	.check_k


.exit

	rts


	xref	prog_a_tester
*************************************
** le programme que l'on va tracer **
*************************************
	;include	40\main.inc\test.s
	
	
********************************************************
** fichier contenant les routines de save_load binary **
********************************************************
	include	40\main.inc\saveload.s
	
	DATA


***********************************
** le nom du programme a charger **
***********************************

		dc.w	0
name::		dcb.b	256,0
		even


***************************************
** on inclut les liste de conversion **
***************************************
	include	both\tab_car.s
	
	

******************************************
** fichier qui va contenir la liste des **
** nom de fonctions                     **
******************************************
	include 40\main.inc\fonction.s



*****************
** flag divers **
*****************
voir_ctrl_a::	dc.w	1		; 0 on ne voit pas l'ecran logique en ctrl a
					; 1 on voit l'ecran logique en ctrl a	

RESIDENT::	dc.w	0		;Centinel est-il r‚sident ?
RESIDENT1::	dc.w	0		;Centinel est-il r‚sident ?
VBR_FLAG::	dc.w	0		; si 1 le vbb est decale

CHARGE_AUTO::	dc.w	0		; chargement auto
COMMU::		dc.w	0		; commutation d'ecrans
LANCE_A::		dc.w	0		; 3 type de crtl a
EXEP_ARRET::
		;dc.w	$6001		; excep 3
		;dc.w	$4afc		; excep 4
		
		dc.w	$4e40		; excep 32

VARIABLE_PROTEC	dc	(7614/2)-10

BASE_VECT_DISK::	dc.l	$472

*******************************
** les petit messages du bas **
*******************************

	ifne	(LANGUAGE=FRANCAIS)
	
	*------ FRANCAIS -----*

MES_UPDATED::	dc.b	'Registres mis a jour',0
		even
MES_ERR_ASM::	dc.b	"Erreur d'assemblage",0		
		even
MES_PUT_OP::	dc.b	"Adresse de l'opcode (",0		
		even
MES_ASM::	dc.b	'Instruction a assembler : ',0
		even

MES_TRACED::	dc.b	'Trac‚',0
		even
MES_SKIPED::	dc.b	'Pass‚',0
		even
MES_RB::	dc.b	'Lanc‚ et stopp‚',0
		even
MES_JMP::	dc.b	'Saute',0
		even
MES_EMUL::	dc.b	'Exception trace emul‚e',0
		even
MES_PC::		dc.b	'PC=',0
		even
MES_PC_LIGNE::	dc.b	'PC(ligne)=',0
		even
MES_OK::	dc.b	'Operation effectu‚e',0
		even
MES_LOAD1::	dc.b	'Fichier … charger : ',0
		even
MES_ERREUR_LOAD::	dc.b	'Erreur de chargement',0
		even
MES_LOAD_OK::	dc.b	10,'Charg‚ en '
		dcb.b	100,0
		even
MES_PROG_EXIST::	dc.b	'Programme d‚j… en m‚moire !',0
		even
MES_BAD_PC::	dc.b	'Mauvaise adress PC',0
		even
MES_SPACE::	dc.b	'                                        ',0
		even
MES_VBR_SHIFT::	dc.b	'VBR d‚cal‚',0
		even
MES_VBR_UNSHIFT::	dc.b	'VBR replac‚',0
		even
MES_VBR_R::	dc.b	'Replacer le VBR ?',0
		even
MES_VBR_CAN_UNSHIFT::
		dc.b	"Le VBR ne peut etre replac‚ (un programme externe l'a chang‚)",0
		even
MES_CENT_RESI::	dc.b	'CENTinel est residant !',0
		even	
MES_BKPT_USER::	dc.b	'met bkpt (adr,exp,0~1,excep) : ',0
		even
MES_BKPT_USER_LINE::
		dc.b	'met bkpt (ligne,exp,0~1,excep) : ',0
		even
MES_KILL_BKPT::	dc.b	'Enlever tous les breakpoints (O/N)?',0
		even
MES_OK_KILL_BKPT::	dc.b	'Breakpoints enlev‚s',0
		even
MES_USER_INT::	dc.b	'interruption utilisateur !',0
		even
MES_DEMO::	dc.b	'Ceci est une version d‚mo !!!!!',0
		even
MES_UNTIL::	dc.b	"Jusqu'… E)xpression P)c R)te",0
		even
MES_EXP::	dc.b	'Expression = ',0
		even
MES_DIRECTORY::	dc.b	'directory courant : ',0
		even
MES_ERREUR_PATH::	dc.b	'Chemin invalide',0
		even
MES_CMD_LINE::	dc.b	'Ligne de commande : ',0
		even
MES_S_BINARY::	dc.b	'Sauve binaire (nom,deb,long) : ',0
		even
MES_EXIST::	dc.b	'Le fichier existe deja. Le remplacer ?',0
		even
MES_WRITING::	dc.b	'Ecritue en cours...',0
		even
MES_ERR_WRIT::	dc.b	"Erreur durant l'ecriture...",0
		even
MES_LOAD_B::	dc.b	'Charger binaire',0
		even
MES_OPT_BIN::	dc.b	'ParamŠtres (deb,long) : ',0
		even
MES_LOAD_SYM::	dc.b	'Chargement des symbols (deb prog,adr sym,longueur) : ',0
		even
MES_DET::	dc.b	'Detourne (trap,fonction,aes|vdi,s_fct) : ',0
		even
MES_DET_PERM::	dc.b	'Detourne en permanence (trap,fonction,aes|vdi,s_fct) : ',0
		even
MES_TROP_FCT::	dc.b	'Trop de fonctions … d‚tourner!',0
		even
MES_FONC_DET::	dc.b	'Fonction d‚tourn‚e : '
		dcb.b	50,32
		dc.b	0
		even
MES_FONC_DET_R::	dc.b	'Fonction atteinte : '
		dcb.b	50,32
		dc.b	0
		even
MES_FONC_DET_D::	dc.b	'Fonction enlev‚e : '
		dcb.b	50,32
		dc.b	0
		even
MES_INCONNU::	dc.b	'inconnue',0
		even
MES_PLUS_MEM::	dc.b	'Pas assez de m‚moire libre!',0
		even
MES_INTOUV::	dc.b	'Fichier non trouv‚!',0
		even
MES_EFF_TRAP::	dc.b	'Effacer tous les trap d‚tourn‚s?',0
		even
MES_PAS_EXEC::	dc.b	'Pas un programme executable!',0
		even
MES_PROG_END::	dc.b	'Programme termin‚',0
		even
MES_TRI::		dc.b	'Tri des symbols...',0
		even
MES_REALLY_QUIT	dc.b	'Vraiment quitter ? (o/n)',0
		even
MES_NOP::	dc.b	'Nop mis',0
		even
MES_NOP_ERR::	dc.b	"Une erreur s'est produite !",0
		even
MES_VEC_CHG::	dc.b	'Vecteurs disk chang‚s. Continuer (O/N) ?',0
		even
MES_REINST_EXCEP::	dc.b	'Red‚tourne toutes les exceptions (O/N) ?',0	
		even
MES_IMP_040::	dc.b	'Impossible de rentrer dans cette exception (en ROM!)',0	
		even
MES_MACRO::	dc.b	'Macro    E)nregister J)ouer S)toper R)eset',0
		even
MES_PUT_HIS::	dc.b	'Quelle ligne restaurer : ',0
		even
MES_SYM_LOAD_U::	dc.b	'Liste de symbols mise a jour',0
		even


		endc		
	*------ ANGLAIS -----*
	ifne	(LANGUAGE=ANGLAIS)


MES_UPDATED::	dc.b	'Registers updated',0
		even
MES_ERR_ASM::	dc.b	"Assembly error",0		
		even
MES_PUT_OP::	dc.b	"Opcode address (",0		
		even
MES_ASM::	dc.b	'Instruction to assemble : ',0
		even

MES_TRACED::	dc.b	'Traced',0
		even
MES_SKIPED::	dc.b	'Skiped',0
		even
MES_RB::	dc.b	'Run and Break',0
		even
MES_JMP::		dc.b	'Jump',0
		even
MES_EMUL::	dc.b	'Exception trace emulated',0
		even
MES_PC::	dc.b	'PC=',0
		even
MES_PC_LIGNE::	dc.b	'PC(line)=',0
		even
MES_OK::		dc.b	'Operation done',0
		even
MES_LOAD1::	dc.b	'File to load : ',0
		even
MES_ERREUR_LOAD::	dc.b	'Loading error',0
		even
MES_LOAD_OK::	dc.b	10,'Loaded in '
		dcb.b	100,0
		even
MES_PROG_EXIST::	dc.b	'File already in memory !',0
		even
MES_BAD_PC::	dc.b	'Bad PC adress',0
		even
MES_SPACE::	dc.b	'                                        ',0
		even
MES_VBR_SHIFT::	dc.b	'VBR shifted',0
		even
MES_VBR_UNSHIFT::	dc.b	'VBR replaced',0
		even
MES_VBR_R::	dc.b	'Replace VBR ?',0
		even
MES_VBR_CAN_UNSHIFT::
		dc.b	'VBR cannot be replaced (an external programm has changed it)',0
		even
MES_CENT_RESI::	dc.b	'CENTinel is resident !',0
		even	
MES_BKPT_USER::	dc.b	'Set bkpt (adr,exp,0~1,excep) : ',0
		even
MES_BKPT_USER_LINE::
		dc.b	'Set bkpt (line,exp,0~1,excep) : ',0
		even
MES_KILL_BKPT::	dc.b	'Kill all breakpoints (Y/N)?',0
		even
MES_OK_KILL_BKPT::	dc.b	'Breakpoints Killed',0
		even
MES_USER_INT::	dc.b	'User break !',0
		even
MES_DEMO::	dc.b	'This is a demo version !!!!!',0
		even
MES_UNTIL::	dc.b	'Until E)xpression P)c R)te',0
		even
MES_EXP::	dc.b	'Expression = ',0
		even
MES_DIRECTORY::	dc.b	'Current directory : ',0
		even
MES_ERREUR_PATH::	dc.b	'Invalid path',0
		even
MES_CMD_LINE::	dc.b	'Command line : ',0
		even
MES_S_BINARY::	dc.b	'Save binary (name,start,long) : ',0
		even
MES_EXIST::	dc.b	'File already exist. Overwrite ?',0
		even
MES_WRITING::	dc.b	'Writing...',0
		even
MES_ERR_WRIT::	dc.b	'Error while writing file...',0
		even
MES_LOAD_B::	dc.b	'Load binary',0
		even
MES_OPT_BIN::	dc.b	'Parameters (start,long) : ',0
		even
MES_LOAD_SYM::	dc.b	'Symbols loading (prog start, symbols adr, length) : ',0
		even
MES_DET::	dc.b	'Catch (trap,function,aes|vdi,s_fct) : ',0
		even
MES_DET_PERM::	dc.b	'Catch permanently (trap,function,aes|vdi,s_fct) : ',0
		even
MES_TROP_FCT::	dc.b	'Too many function to catch!',0
		even
MES_FONC_DET::	dc.b	'Catched function : '
		dcb.b	50,32
		dc.b	0
		even
MES_FONC_DET_R::	dc.b	'Function reached : '
		dcb.b	50,32
		dc.b	0
		even
MES_FONC_DET_D::	dc.b	'Function removed : '
		dcb.b	50,32
		dc.b	0
		even
MES_INCONNU::	dc.b	'unknown',0
		even
MES_PLUS_MEM::	dc.b	'Not enough memory left!',0
		even
MES_INTOUV::	dc.b	'File not found!',0
		even
MES_EFF_TRAP::	dc.b	'Erase all catched trap?',0
		even
MES_PAS_EXEC::	dc.b	'Not an executable prg!',0
		even
MES_PROG_END::	dc.b	'Programm ended',0
		even
MES_TRI::	dc.b	'Sorting symbols...',0
		even
MES_REALLY_QUIT	dc.b	'Really want to quit ? (y/n)',0
		even
MES_NOP::		dc.b	'Nop put',0
		even
MES_NOP_ERR::	dc.b	'An error has occured !',0
		even
MES_VEC_CHG::	dc.b	'disk vectors changed. Continue (Y/N) ?',0
		even
MES_REINST_EXCEP::	dc.b	'Recatch all exceptions (Y/N) ?',0	
		even
MES_IMP_040::	dc.b	"Can't enter in this exception (in ROM!)",0
		even

MES_MACRO::	dc.b	'Macro    E)nregistrer J)ouer S)toper R)eset',0
		even
MES_PUT_HIS::	dc.b	'Which line to restore : ',0
		even

MES_SYM_LOAD_U::	dc.b	'Symbol list updated',0
		even
	endc



*******************************
** l'ipl interne du debogeur **
*******************************

IPL_INT::
	dc.w	7
		
		
*****************************************************************
** la table qui autorise ou non le detournement des exceptions **
*****************************************************************

; le trap 3 n'est plus detourne
; le trap 4 n'est plus detourne

table_autori::		; c'est la table qui dit quoi detourner
		dc.b	2,3,4,0,6,7,0,9,0,0,12,13,14,15,16,17,18,19,20,21,22
		dc.b	23,24,25,0,27,0,29,30,31,32,0,0,0,0,37,38,39,40,41
		dc.b    42,43,44,0,0,47,0,0,0,0,0,0,0,0,56,57,58,59
		dc.b	60,61,62,63,64
		rept	255-64			; user def : on ne touche pas 
		dc.b	0
		endr


		even


***************************************
** pointeurs sur la table d''history **
***************************************

point_history::
		dc.l	save_history
		dc.l	save_history+600
		dc.l	save_history+600*2
		dc.l	save_history+600*3
		dc.l	save_history+600*4
		dc.l	save_history+600*5
		dc.l	save_history+600*6
		dc.l	save_history+600*7


*************************************************************
** la table qui donne le nombre de nom maximals a afficher **
** pour le nom des fonctions                               **
*************************************************************
table_au_t::	dc.w	19		; longur de la table


table_num_max_ex::
		dc.w	0
		dc.w	$137		; gemdos
		dc.w	125		; aes   ( vdi = 16)
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	$c		; bios
		dc.w	$96		; xbios
		dc.w	0
		dc.w	131		; vdi
		dc.w	10		; fct grp vdi
		dc.w	19		; fct escape vdi
	

****************************************************
** La table pointant sur le nom des fonction trap **
****************************************************
fonction_name::
		dc.l	t_rien			;0
		dc.l	Gemdos			;1
		dc.l	f_aes_vdi		;2
		dc.l	t_rien			;3
		dc.l	t_rien			;4
		dc.l	t_rien			;5
		dc.l	t_rien			;6
		dc.l	t_rien			;7
		dc.l	t_rien			;8
		dc.l	t_rien			;9
		dc.l	t_rien			;10
		dc.l	t_rien			;11
		dc.l	t_rien			;12
		dc.l	Bios			;13
		dc.l	Xbios			;14
		dc.l	t_rien			;15
		dc.l	f_vdi			;16		; ajoute une pour les fonctions vdi
		dc.l	f_aes			;17		; ajoute une pour les fonctions vdi
		

t_rien
		dc.l	0
Gemdos		dc.b	'Gemdos',0
		even
f_aes		dc.b	'Aes',0
		even
f_aes_vdi	dc.b	'Vdi/Aes',0
		even
Bios		dc.b	'Bios',0
		even
Xbios		dc.b	'Xbios',0
		even
f_vdi		dc.b	'Vdi',0
		even
	
**********************************
** les variables de limitations **
**********************************
MAX_BK		dc.b	20+1		;nb de bkpt
		even
nb_symbols::	dc.l	0		;nb de symboles

;TAB_CONV 	dc.b	'0123456789ABCDEF'



	SECTION BSS


*********************************************
** variable servant au detournement du vbr **
*********************************************

OLD_PRUN::	ds.l	1

s_a01		ds.l	1
s_d0		ds.l	1
ANC_VBR1::	ds.l	1		; sauvegarde du VBR
table_sauve	ds.l	64		; nombre d'exception a sauver
ADR_VBR::	ds.l	1		; adresse du registre de base vbr
ANC_VBR::		ds.l	1		; adresse de l'ancien vbr

***************************************
** buffer sauvant le message du bkpt **
***************************************


perm_bkpt::	ds.l	1
type_ex::		ds.w	1
FLAG_EX		ds.b	1
FLAG_EV::	ds.b	1
FLAG_PE		ds.b	1
		even
bkpt::		ds.w	1	; nb du bkpt
BUF_BKPT::	ds.b	80	; buffer pour les messages de bkpt
eval_bkpt::	ds.b	256*21		; on multiplie par le nombre de bkpt


*******
s_a7::	ds.l	1		; sauvegarde de a7 lors du test de validite d'adr



******************************
** registres des expections **
****************************** 

BKPT_VECT	ds.l	1
EXEP_COU	ds.w	1		; vecteur pour les bkpt courant


********************
** liste des bkpt **
********************
liste_break	ds.l	2*257
bkpt_flag::	ds.l	1		; dit si le bkpt est parametre pour le ctrl a

**********************************
** petites sauvegardes diverses **
**********************************

	ds.l	$d8		; sauvegarde du contexte du fpu
buffer_fpu	
s_fpu		ds.l	1
prog_launch::	ds.w	1	; dit si le prog va etre lance par le pexec
save_instruc	ds.l	1	; suave le 1ere instruc du prog

CPU_TYPE::	ds.w	1

bkpt_p		ds.w	1	; bkpt parametre
s_p_cla		ds.l	1	; sauve le pointeur clavier
s_d6::		ds.l	1	; sauvegarde de d6 pour le cache
s_cla		ds.l	1
flag_user_b	ds.b	1	; flag pour l'arret user
flag_user_dsp	ds.b	1	; flag pour l'arret user
		even
flag_res::	ds.b	1	; 1 si Centinel est ex‚cut‚ ds dossier auto
		even
adr_trace::	ds.l	1
adr_t_until::	ds.l	1

flag_w::		ds.b	1	; flag qui dit si on doit faire le watch ou non
		even
s_p_queue	ds.l	1
s_a0::		ds.l	1
anc_touche::	ds.l	1	; derniere touche appuy‚e
adr_sr		ds.w	1	; adresse du sr
adr_off		ds.w	1
adr_retour	ds.l	1	; adresse de retour de la vbl
user_int::	ds.b	1	; flag d'interruption utilisateur
		even
user_int1	ds.b	1	; flag d'interruption utilisateur
		even

temp::		ds.b	256	; un petit tempon pour les diverses copies
temp1::		ds.b	256	; un petit tempon pour les diverses copies
	
ERR_MEM::	ds.b	1	; erreur de lecture m‚moire
		even

REF_DISK::	ds.l	4	; buffer pour la sauvegarde des vecterus disks

RET_DEB::	ds.l	1
LONG_PROG	ds.l	1	; longueur du programme pour le ptermres
chaine_ascii::	ds.b	60
s_buf::		ds.l	90
s_a6::		ds.l	1
a_p_c::		ds.l	1
p_c::		ds.l	1	
anc_a4		ds.l	1
fichier::	ds.l	1
adr_a4		ds.l	1
forme_curseur::	ds.b	1
		even
S_LOG		ds.l	1
MEM_HAUTE::	ds.l	1

nb_fct_det::	ds.w	1
table_fct_det::	ds.w	50*4	; on prevoit 50 fct
table_trap::	ds.l	16	; la sauvegarde du trap


liste_mfree::	ds.l	50	; la liste qui va contenir tous les malloc a virer

Com_line::	ds.b	100	; taille pour ligne de commande


LIGNE_BRA::	ds.l	1	; pointeur sur la ligne qui va bracher

Correction_pile	ds.l	1

replay_macro::	ds.w	1	; dit si doit replayer la macro
record_macro::	ds.w	1	; dit si on doit enregister la macro

****************
** Buffer dta **
****************

;current_path::	ds.b	300		; copie du chemin courant

SAVE_OLD_PROS::	ds.l	1
s_dta		ds.l	1
buf_dta::	ds.b	44
chaine_env	ds.b	100

CMD_L::		ds.w	1

*******************************
** sauvegarde pour l'history **
*******************************

save_history	ds.b	600*8		; 4.8 k pour 8 lignes d'histoire...
	

**********************************************
** pile pour le test des registre d'adresse **
**********************************************
		ds.l	100
pile_test::	ds.l	1
a_pile::		ds.l	1		; sauvegarde de l'ancienne pile lors du trace
pile_sup	ds.l	1
******************************
** sauvegarde des registres **
******************************


buffer_r::	ds.l	200
buffer_r_anc::	ds.l	200
buffer_int::	ds.l	200
buffer_int_anc::	ds.l	200



*********************************************
** table des exceptions dans le cas du vbr **
*********************************************

vbr_deviation::	ds.l	4*100		;table des exeptions qui vont etres detournee

********************************************************
** variables servant a afficher le nom des exceptions **
********************************************************

excep::		ds.w	1
num_func::	ds.w	1
type_excep::	ds.w	1
trap_david	ds.l	1
go_david	ds.w	1
******************************************************
** ici les buffers des fenetres ** :: apres symbols **
******************************************************
touches_mortes_adr	ds.l	1
HYP		ds.l	1
etat_trace::	ds.w	1
taille_fichier::	ds.l	1
ADR_CHARGE::	ds.l	1
buf_nom::				; buffer pour les symboles
		ds.b	50
adr_label::	ds.l	1
buf_label::	ds.l	1
hash_table::	ds.l	1


BASE_PAGE::	ds.b	256
P_ENV		ds.l	1	pointeur sur la chaine d'environnement


clavier_pourri::
		ds.w	1


***************
** les piles **
***************

s_pile_pexec	ds.l	1

		ds.b	1000
autre_pile	
		ds.b	1000		; la pile pour le pexec
pile_pexec


		ds.b	1000		; la pile que l'on place pour les init
pile_deb

sauve_la_pile	ds.l	1
		ds.b	4096
pile_prog::	






