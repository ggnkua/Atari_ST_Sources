
	MC68881

START
	output	d:\centinel\dsp\dsp_bug.o
	incdir	d:\centinel\dsp

	include	d:\centinel\both\define.s
	include	d:\Centinel\both\GEM.EQU
	include	d:\Centinel\both\XBIOS.EQU
	include	d:\Centinel\both\localma2.s

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
demo_mode?	macro
********************************
** macro qui va afficher demo **
** si on est en demo          **
********************************
	ifne	DEMO_MODE
	
	
	xref	MES_DEMO	
	move.l	#MES_DEMO,MESSAGE_ADR
	rts
	
	
	
	else
	
	endm
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; On r‚cupere la ligne de commande
;------------------------------------------------------------------------------


	


	*---------------*
	* MSHRINK
	*---------------*

	move.L	4(sp),a0
	move.l	12(a0),a1
	add.l	20(a0),a1
	add.l	28(a0),a1
	pea	256(a1)
	pea	(a0)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp



	move.l	4(sp),a0	; on recupere la ligne de commande
	lea	128(a0),a0
	

	xref	SAVE_CENTINEL_PATH
	bsr.l	SAVE_CENTINEL_PATH
	
	bsr	TRAITE_LIGNE_DE_COMMANDE
	
	
	jsr	INITS

	
	xref	pile_prog
	lea	pile_prog,a7
	
	move	#$2700,sr

	xref	CENTINEL_VIDEO
	lea	CENTINEL_VIDEO,a0
	bsr.l	SET_VIDEO

	bsr	INIT_COOKY


;------------------------------------------------------------------------------
; doit on charger un fichier DSP au d‚marrage ??
;------------------------------------------------------------------------------
	cmp	#1,DSP_CHARGE_AUTO
	beq.s	.LOD
	cmp	#2,DSP_CHARGE_AUTO
	beq.s	.CLD
	bra.S	.OK_AUTO
	xref	AUTO_LOAD_LOD
.LOD	bsr	AUTO_LOAD_LOD
	bra.S	.OK_AUTO
	xref	AUTO_LOAD_CLD
.CLD	bsr	AUTO_LOAD_CLD
	bra	.OK_AUTO
	


.OK_AUTO
;------------------------------------------------------------------------------

	
;**************************************
;* routine principale du debugeur  ****
;**************************************
MAIN	
	*-----------------*	
	* v‚rifie qu'il reste au minimum
	* un processeur actif
	*-----------------*	
	xref	ACTIF_DSP
	tst	ACTIF_DSP
	bne.s	.OK_ACTIF
	xref	ACTIF_40
	tst	ACTIF_40
	bne.s	.OK_ACTIF
	nop	
.OK_ACTIF

	xref	AFFICHE,TABLE_TOUCHES
	jsr	AFFICHE

TOUCHE	
	xref	get_key
	jsr	get_key		
	lea	TABLE_TOUCHES,a0
.LOOP	cmp	(a0)+,d0
	beq.s	.FOUND
	addq	#8,a0
	tst	(a0)
	beq	TOUCHE
	bra.s	.LOOP
.FOUND	jsr	([a0])
	bra	MAIN
OLD_TOUCHE	dc.l	0





;------------------------------------------------------------------------------
;dsp_save_binary
;routine qui va faire la sauvegarde en binaire **
;------------------------------------------------------------------------------
dsp_save_binary::
		l_clear
file		rs.l	1
RAM_type	rs	1
adr		rs.l	1
longueur	rs.l	1	
buff_recep	rs.l	1024
		l_reserve	a6


.encore
	move.l	#MES_S_BINARY,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.annule
	
	move.l	a2,file(a6)		;nom fichier
	

	move.l	a2,a0			; cherche s'il y a un virgule
.SCAN	move.b	(a0)+,d0
	beq	.encore
	cmp.b	#',',d0
	bne.s	.SCAN
.ok1	clr.b	-1(a0)

	move	(a0)+,d0
	moveq	#MEM_P,d1	
	cmp	#'p:',d0
	beq	.OK2
	cmp	#'P:',d0
	beq	.OK2
	moveq	#MEM_X,d1	
	cmp	#'x:',d0
	beq	.OK2
	cmp	#'X:',d0
	beq	.OK2
	moveq	#MEM_Y,d1	
	cmp	#'y:',d0
	beq	.OK2
	cmp	#'Y:',d0
	beq	.OK2
	bra	.encore
.OK2	
	move	d1,RAM_type(a6)

	move.l	a0,a1
.SCAN1	move.b	(a1)+,d0
	beq	.encore
	cmp.b	#',',d0
	bne.s	.SCAN1
	clr.b	-1(a1)

	bsr.l	eval
	tst.b	d2
	bne	.encore
	
	move.l	d1,adr(a6)
	
	move.l	a1,a0
	bsr.l	eval
	tst.b	d2
	bne	.encore
	move.l	d1,longueur(a6)
	
	
	clr	-(sp)	
	move.l	file(a6),-(sp)
	GEM	Fcreate
	move.l	d0,d7		;handle
	
				
	
	move.l	longueur(a6),d2
.one_loop
	envl	#'CMD'
	move	RAM_type(a6),d0
	add	#DSP_PDUMP,d0
	envl	d0
	envl	adr(a6)
	envl	#1024
	
	lea	buff_recep(a6),a0
	move.l	a0,a1
	move	#1024-1,d1
.recep	recl	(a1)+
	dbra	d1,.recep
	move.l	#1024*4,d3
	cmp.l	d3,d2
	bge.s	.OK0
	move.l	d2,d3
.OK0	
	lsl.l	#2,d3
	pea	(a0)
	move.l	d3,-(sp)
	move	d7,-(sp)
	GEM	Fwrite
	
	sub.l	#1024,d2
	bmi.s	.fclose
	beq.s	.fclose
	bra	.one_loop
	
	
	
.fclose	
	move	d7,-(sp)
	GEM	Fclose

	bra.s	.fin
.annule
	move.l	#MES_SPACE,MESSAGE_ADR
.fin	bsr.l	set_all_flags
	l_free	a6
	rts
;------------------------------------------------------------------------------
	

;------------------------------------------------------------------------------
; INIT_COOKY:
;	place un cooky DBUG et un pointeur sur plein d'infos
;------------------------------------------------------------------------------
INIT_COOKY::
	xref	CENTINEL_INFO
	
	move.l	$5a0.w,a0
	moveq	#0,d1	
.AGAIN	tst.l	(a0)
	beq.S	.FIN
	addq	#8,a0
	addq	#1,d1	
	bra.S	.AGAIN

.FIN	move.l	4(a0),d0	
	cmp.l	d0,d1
	bge.s	.ERREUR
	move.l	#'DBUG',(a0)+
	move.l	#CENTINEL_INFO,(a0)+
	clr.l	(a0)+
	move.l	d0,(a0)+
.ERREUR
	rts
	


REFRESH::
	xref	set_all_flags
	bsr.l	set_all_flags
	rts
	


;------------------------------------------------------------------------------
; ceci est l'exeption g‚n‚r‚e par le DSP ( ‚mul‚e sur 56001 )
; attention:	il faut remover les BKP avant de faire le check
;		car ce dernier enleve le BKP temporaire.
;------------------------------------------------------------------------------
DSP_WAKE_UP::
	movem.l	d0-a6,-(sp)
	
	
	ifne	(DSP=DSP56301)

	or.l	#$20,HCTR		;place HF2
	nop
	nop
	and.l	#$ffffffff-$20,HCTR	;et on l'enleve
	endc

	
	bsr	REC_REGISTERS		;recoit l'etat DSP

	st	ACTIF_DSP		;le DSP est reveill‚

	bsr.l	set_all_flags		;un gros redraw
	
	bsr	REMOVE_BKP		;si ils ‚taient mis => on les enleve

	bsr	CHECK_BKP		;corrections diverses et mises … jour BKP
	
	bsr	PC_IN_WINDOW		;recale la fenetre si besoin

	*------------------*
	* gestion du trace_until
	*------------------*
	cmp.l	#1,DSP_EXEPTION		;exeption trace ?
	bne.s	.NO_UNTIL			
	move	TRACE_UNTIL_FLAG,d0
	beq.s	.NO_UNTIL		;trace until en route ?
	cmp	#1,d0
	bne.s	.OK0
	bsr	UNTIL_PC
	bra.s	.FIN_UNTIL
.OK0	cmp	#2,d0
	bne.s	.OK1
	bsr	UNTIL_LINE
.OK1	bra.s	.FIN_UNTIL
.NO_UNTIL
	clr	TRACE_UNTIL_FLAG
.FIN_UNTIL


	movem.l	(sp)+,d0-a6
	rte

;------------------------------------------------------------------------------
; pour halter le DSP par une HOST CMD
;------------------------------------------------------------------------------
STOP_DSP::
	tst	ACTIF_DSP
	bne.s	.FIN
	
	move.b	#$80+$1e/2,$ffffa201.w		;HC d‚clench‚e
.WW	tst.b	$ffffa201.w	
	bmi.s	.WW		;attendre qu'elle arrive
	;clr	ACTIF_DSP

.FIN	rts

;------------------------------------------------------------------------------
; Si on atteint la valeur sp‚cifi‚e pour le PC
; c'est fini
; sinon on relance
;------------------------------------------------------------------------------
UNTIL_PC
	move.l	DSP_REG+REG_PC,d0
	cmp.l	UNTIL_EXPR,d0
	beq.s	.CLR
	
	clr	ACTIF_DSP
	bsr	SEND_BKP	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
	rts
	
.CLR	
	clr	TRACE_UNTIL_FLAG		
	rts
	
;------------------------------------------------------------------------------
; on relance tant que l'expression n'est pas VRAIE
;------------------------------------------------------------------------------
UNTIL_EXP
	lea	UNTIL_EXPR,a0
	bsr.l	eval
	tst.l	d1
	beq.s	.CONTINUE
	clr	TRACE_UNTIL_FLAG		
	rts
.CONTINUE
	clr	ACTIF_DSP
	bsr	SEND_BKP	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
	rts
		
;------------------------------------------------------------------------------
; on relance tant qu'on atteint pas une ligne du source
;------------------------------------------------------------------------------
UNTIL_LINE
	move.l	DSP_REG+REG_PC,d0
	move.l	UNTIL_EXPR,a1
			
	move.l	ptr_conv(a1),a2
	move	nb_ligne(a1),d7
.SCAN	cmp.l	(a2)+,d0
	beq.s	.CLR
	dbra	d7,.SCAN
	
	
.CONTINUE
	clr	ACTIF_DSP
	bsr	SEND_BKP	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
	rts

.CLR	clr	ACTIF_DSP
	move.l	#MES_TRACED,MESSAGE_ADR
	bsr.l	set_dsp_flags
	rts


;------------------------------------------------------------------------------
TRACE_UNTIL::

	xref	MES_UNTIL,MES_EXP

	tst	ACTIF_DSP
	beq	.FIN	
	
.i	move.l	#MES_UNTIL,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	bsr.l	get_key
	
	cmp.b	#1,d0
	beq	.FIN

	cmp.b	#$12,d0			; E
	beq	.expression
	
	cmp.b	#$19,d0
	bne.s	.i


	*-------------------*
	* trace jusqu'… une valeur imm‚diate
	*-------------------*
.immediat
	move.l	#MES_PC,a0		; on trace jusqu'… un pc donn‚
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.FIN
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne	.expression

	*-------------------*
	* trace until PC=
	*-------------------*
	move.l	d1,UNTIL_EXPR
	clr	ACTIF_DSP
	move	#1,TRACE_UNTIL_FLAG

	bsr.l	set_all_flags
	
	bsr	SEND_BKP	
	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
	
.FIN	rts
	


	*-------------------*
	* trace jusqu'… une expression
	*-------------------*
.expression
	move.l	#MES_EXP,a0		; on trace jusqu'… un pc donn‚
	bsr.l	GET_CHAINE
	tst.b	d0
	beq.s	.FIN
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	bne	.expression
	
	lea	UNTIL_EXPR,a1
.COP	move.b	(a0)+,(a1)+
	bne.s	.COP	
	

	clr	ACTIF_DSP
	move	#2,TRACE_UNTIL_FLAG

	bsr.l	set_all_flags
	
	bsr	SEND_BKP	
	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
	
	rts
	
;------------------------------------------------------------------------------
; execute une instruction en trace
;------------------------------------------------------------------------------
ROUT_TRACE::		
	tst	ACTIF_DSP
	beq	.FIN	

	move.l	ACTIVE_WINDOW,a0
	cmp	#T_DSP_SRC,type(a0)
	beq	SOURCE_TRACE

	*---------------------*
	* execute une instruction en trace
	* sans remettre les BKPT
	*---------------------*

	move.l	#MES_TRACED,MESSAGE_ADR
 	clr	ACTIF_DSP

;place tt les FLAGS

	xref	set_dsp_flags	
	bsr.l	set_dsp_flags	; on fait un redraw meme si le trace est tres court
				;car sinon ca manque ds dsp_bug
	clr	ACTIF_DSP

	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
.FIN	rts

;------------------------------------------------------------------------------
; Lance le programme
;------------------------------------------------------------------------------
RUN::
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	

	bsr	SEND_BKP

	move.l	#MES_RUN,MESSAGE_ADR
	bsr.l	set_dsp_flags
	
	clr	ACTIF_DSP	;DSP lanc‚ !!
	envl	#'CMD'
	envl	#DSP_RUN
	bsr	SEND_REGISTERS
.FIN	rts

	endc

;------------------------------------------------------------------------------
; lance une instruction...
; pose un BKP sur l'instruction suivante
; et Lance le programme
;------------------------------------------------------------------------------
RUN_AND_BREAK::	
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	

	xref	P_COUNT,DESAS_ONE,ACTIVE_WINDOW
	xref	ASCII_BUF,MASK_BUF
	
	move.l	ACTIVE_WINDOW,a0
	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_DSP_SRC,type(a0)
	beq	SOURCE_RUN_AND_BREAK
	cmp.w	#T_disas,type(a0)
	bne	.FIN

	;bsr.l	set_dsp_flags		;on le skippe car la pause est courte

	envl	#'CMD'
	envl	#DSP_PDUMP
	move.l	DSP_REG+REG_PC,d0
	move.l	d0,P_COUNT
	envl	d0
	envl	#2
	lea	WORK_BUF,a0
	recl	(a0)+
	recl	(a0)+
	subq	#8,a0
	lea	ASCII_BUF,a6	
	bsr	DESAS_ONE

	*--------------------*
	* on doit poser un BKP Temporaire en P_COUNT
	*--------------------*
	move.l	P_COUNT,d0

.PUT	move	#8,d1		;bkp Temporaire
	swap	d1
	move	#3,d1		;SWI
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT

.RUN
	bsr	SEND_BKP
	clr	ACTIF_DSP	;DSP lanc‚ !!
	move.l	#MES_RB,MESSAGE_ADR
	bsr.l	set_dsp_flags
	
	envl	#'CMD'
	envl	#DSP_RUN
	bsr	SEND_REGISTERS

	
.FIN	
	rts

	endc

;------------------------------------------------------------------------------
; on place un BKP sur la ligne suivante
; et on lance
;------------------------------------------------------------------------------
SOURCE_RUN_AND_BREAK
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	

	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a2
	move	nb_ligne(a1),d7
	*--------------------*
	* recherche la ligne apres le PC
	*--------------------*
	move.l	DSP_REG+REG_PC,d0
.SCAN0	cmp.l	(a2)+,d0
	blt.s	.F0
	subq	#1,d7
	bne.s	.SCAN0
	bra	.FIN	
.F0	move.l	-(a2),d0		;adresse du break

.PUT	move	#8,d1		;bkp Temporaire
	swap	d1
	move	#3,d1		;SWI
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT

	bsr	SEND_BKP
	clr	ACTIF_DSP	;DSP lanc‚ !!
 	move.l	#MES_RB,MESSAGE_ADR
	bsr.l	set_dsp_flags
	
	envl	#'CMD'
	envl	#DSP_RUN
	bsr	SEND_REGISTERS

.FIN	rts

	endc

;------------------------------------------------------------------------------
; on fait un run until le prochain no ligne qui sort
;------------------------------------------------------------------------------
SOURCE_TRACE
	tst	ACTIF_DSP
	beq.s	.FIN	

	move.l	Src_adr(a0),UNTIL_EXPR
	move	#3,TRACE_UNTIL_FLAG
	
	xref	set_dsp_flags	;ne pas faire de redraw car il va y en avoir un
	bsr.l	set_dsp_flags	; apres le trace qui est court.
	clr	ACTIF_DSP

	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
.FIN	rts

	
		

				
	
;------------------------------------------------------------------------------
; recherche en RAM DSP
;------------------------------------------------------------------------------
DSP_FIND_AGAIN::
	tst	FIND_VALUE
	beq	DSP_FIND
	moveq	#0,d7
	move	FIND_VALUE+2,d7
	move.l	FIND_VALUE+4,d6
	move.l	ACTIVE_WINDOW,a0
	addq.l	#1,adr_debut(a0)
	bra	SOURCE

FIND_VALUE	ds.w	4
;------------------------------------------------------------------------------
; recherche en RAM DSP
;------------------------------------------------------------------------------
DSP_FIND::
	lea	MES_GET,a0
	bsr.l	GET_CHAINE	
	
	tst.b	d0
	beq	FIN_FIND
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	beq	.HEX
	move.l	(a0),d1
	lsr.l	#8,d1
.HEX	move.l	d1,d6
	and.l	#$ffffff,d6
	move.l	d6,FIND_VALUE+4
	
				
.RAM	lea	MES_RAM,a0
	bsr.l	GET_CHAINE	
	
	tst.b	d0
	beq	.RAM

	move.b	(a2),d0
	
	cmp.b	#'P',d0
	beq.s	.RAMP	
	cmp.b	#'p',d0
	beq.s	.RAMP	
	cmp.b	#'X',d0
	beq.s	.RAMX	
	cmp.b	#'x',d0
	beq.s	.RAMX	
	cmp.b	#'Y',d0
	beq.s	.RAMY	
	cmp.b	#'y',d0
	beq.s	.RAMY	
	bra.s	.RAM
.RAMX	moveq	#1,d7
	bra.S	SOURCE
.RAMY	moveq	#2,d7
	bra.S	SOURCE
.RAMP	moveq	#0,d7				

SOURCE	
	st	FIND_VALUE
	move	d7,FIND_VALUE+2
	add.l	#DSP_PDUMP,d7

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),d0

.NEXT_BLOCK
	cmp.b	#$01,$fffffc02.w
	beq	.ABORT
	
	*----------------------*
	* recoit un block et recherche dedans
	*----------------------*
	lea	WORK_BUF,a1
	envl	#'CMD'
	envl	d7
	envl	d0
	envl	#1024
	move	#1024-1,d5			
	
.REC	recl	(a1)+
	dbra	d5,.REC	
	
	lea	WORK_BUF,a1
	move	#1024-1,d5
.LOOP0
	cmp.l	(a1)+,d6
	beq.s	.FOUND
	dbra	d5,.LOOP0
	
	
	*----------------------*
	* affiche l'adresse en cours
	*----------------------*

	lea	MES_INCREASE+18,a0
	add.l	#100,d2
	move.l	d0,d3
	lsl.l	#8,d3
	move	#6-1,d5
.NUM0	rol.l	#4,d3
	move.b	d3,d4
	and	#$f,d4
	xref	TAB_CONV
	move.b	(TAB_CONV.l,d4.w),(a0)+
	dbra	d5,.NUM0
	
	move.l	#MES_INCREASE,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE		

	add.l	#1024,d0
	bra	.NEXT_BLOCK
			
.FOUND	
	sub.l	#WORK_BUF,a1
	move.l	a1,d1
	lsr.l	#2,d1
	add.l	d1,d0
	subq.l	#1,d0
	move.l	d0,adr_debut(a0)
	move.l	#MES_FOUND,MESSAGE_ADR
	bsr.l	set_dsp_flags
	bra.S	FIN_FIND
.ABORT	move.l	#MES_ABORT,MESSAGE_ADR	
FIN_FIND
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
DSP_FIND_BACK_AGAIN::
	tst	FIND_VALUE
	beq	DSP_FIND
	moveq	#0,d7
	move	FIND_VALUE+2,d7
	move.l	FIND_VALUE+4,d6
	bra	SOURCE0

DSP_FIND_BACK::	
	lea	MES_GET,a0
	bsr.l	GET_CHAINE	
	
	tst.b	d0
	beq	FIN_FIND0
	move.l	a2,a0
	bsr.l	eval
	tst.b	d2
	beq	.HEX
	move.l	(a0),d1
	lsr.l	#8,d1
.HEX	move.l	d1,d6
	and.l	#$ffffff,d6
	move.l	d6,FIND_VALUE+4
	
				
.RAM	lea	MES_RAM,a0
	bsr.l	GET_CHAINE	
	
	tst.b	d0
	beq	.RAM

	move.b	(a2),d0
	
	cmp.b	#'P',d0
	beq.s	.RAMP	
	cmp.b	#'p',d0
	beq.s	.RAMP	
	cmp.b	#'X',d0
	beq.s	.RAMX	
	cmp.b	#'x',d0
	beq.s	.RAMX	
	cmp.b	#'Y',d0
	beq.s	.RAMY	
	cmp.b	#'y',d0
	beq.s	.RAMY	
	bra.s	.RAM
.RAMX	moveq	#1,d7
	bra.S	SOURCE0
.RAMY	moveq	#2,d7
	bra.S	SOURCE0
.RAMP	moveq	#0,d7				

SOURCE0
	st	FIND_VALUE
	move	d7,FIND_VALUE+2
	add.l	#DSP_PDUMP,d7

	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),d0

.NEXT_BLOCK
	cmp.b	#$01,$fffffc02.w
	beq	.ABORT
	
	sub.l	#1024,d0		;… l'envers	
	*----------------------*
	* recoit un block et recherche dedans
	*----------------------*
	lea	WORK_BUF,a1
	envl	#'CMD'
	envl	d7
	envl	d0
	envl	#1024
	move	#1024-1,d5			
	
.REC	recl	(a1)+
	dbra	d5,.REC	
	
	move	#1024-1,d5
.LOOP0
	cmp.l	-(a1),d6
	beq.s	.FOUND
	dbra	d5,.LOOP0
	
	
	*----------------------*
	* affiche l'adresse en cours
	*----------------------*

	lea	MES_INCREASE+18,a0
	add.l	#100,d2
	move.l	d0,d3
	lsl.l	#8,d3
	move	#6-1,d5
.NUM0	rol.l	#4,d3
	move.b	d3,d4
	and	#$f,d4
	xref	TAB_CONV
	move.b	(TAB_CONV.l,d4.w),(a0)+
	dbra	d5,.NUM0
	
	move.l	#MES_INCREASE,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE		

	;add.l	#1024,d0
	bra	.NEXT_BLOCK
			
.FOUND	
	sub.l	#WORK_BUF,a1
	move.l	a1,d1
	lsr.l	#2,d1
	add.l	d1,d0
	move.l	d0,adr_debut(a0)
	move.l	#MES_FOUND,MESSAGE_ADR
	bsr.l	set_dsp_flags
	bra.S	FIN_FIND0
.ABORT	move.l	#MES_ABORT,MESSAGE_ADR	
FIN_FIND0
	rts


	
;------------------------------------------------------------------------------
; grosse routine qui charge un source apres avoir Malloc‚
; la RAM pour le source et la table des lignes correspondante
; complete la structure source … la place courante 
; passe a la prochaine place ( NB_SOURCES+1 )
;------------------------------------------------------------------------------
;in:
;	a0	nom du source
;------------------------------------------------------------------------------
; voila la structure en RAM
;	char *ptr_ligne[max_ligne+1]
;	char *name[256]
;	char source[size_src]
;
;
;
dsp_load_source::
	movem.l	d0-a6,-(sp)
	
	move	DSP_NB_SOURCES,d0
	cmp	#max_src,d0
	bge	.fin
	
	move.l	a0,-(sp)
	
	mulu	#Size_src,d0
	lea	(DSP_SOURCE_TABLE,d0.l),a1

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
	bsr.l	INIT_TAB_LIGNE
		
	addq	#1,DSP_NB_SOURCES
			
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
	rts


	
;------------------------------------------------------------------------------
;TRAITE_LIGNE_DE_COMMANDE
; parcours la ligne de commande et saute aux routines appropri‚es si n‚c‚ssaire
;------------------------------------------------------------------------------
;IN*
;	a0	pointe sur la ligne de commande
;
;OUT*
;	rien	
;------------------------------------------------------------------------------
TRAITE_LIGNE_DE_COMMANDE::
	movem.l	d0-a6,-(sp)
	
	moveq	#0,d7
	move.b	(a0)+,d7
	beq	.FIN
	move.l	a0,a1
	
	*-----------------*
	* recherche d'une sous chaine 
	* ds la lige de commande
	*-----------------*
	
.SCAN	tst	d7
	bmi	.FIN
	tst.b	(a1)
	beq.S	.FIN
	move.l	a1,a0
.SC0	move.b	(a1)+,d0
	beq.S	.F0
	cmp.b	#' ',d0
	beq.s	.F0
	dbra	d7,.SC0

.FIN	movem.l	(sp)+,d0-a6
	rts

.F0	move.l	a1,a2
	clr.b	-(a1)
	move.l	-(a1),d0
	move	#4-1,d6
.COP	cmp.b	#'.',(a1)+
	beq.s	.EXT
	lsl.l	#8,d0
	move.b	#' ',d0
	dbra	d6,.COP
.EXT	subq	#1,d7
	move.l	a2,a1
	*-----------*
	* converti en MAJUSCULE
	*-----------*
	move	#4-1,d6
.CONV	cmp.b	#'a',d0
	blt	.INF
	cmp.b	#'z',d0
	bgt	.INF
	add.b	#'A'-'a',d0
.INF	ror.l	#8,d0
	dbra	d6,.CONV	
		

	*---------------*
	* saute … la bonne routine selon l'estension
	*---------------*
	;a0 pointe sur le d‚but de la chaine
	;a1 sur la fin (zero compris)
		
	cmp.l	#'.LOD',d0
	beq.s	.LOD
	cmp.l	#'.CLD',d0
	beq.s	.CLD
	cmp.l	#'.ASM',d0
	beq.s	.ASM
	cmp.l	#'.S  ',d0
	beq.s	.S40
	
	*------------------------*
	* tout le reste est potentiellement
	* executable
	*------------------------*
.PRG
	xref	name
	lea	name,a3
.COP2	move.b	(a0)+,(a3)+
	cmp.l	a1,a0
	blt.s	.COP2
	xref	CHARGE_AUTO
	st	CHARGE_AUTO			
	bra	.SCAN



.S40
	*------------------------*
	* un source 68040....
	*------------------------*
	xref	M40_load_source
	bsr.l	M40_load_source
	bra	.SCAN


	*------------------------*
	* on a detect‚ un .LOD
	*------------------------*

.LOD					;recupere le nom du .LOD
	lea	dsp_name,a3
.COP0	move.b	(a0)+,(a3)+
	cmp.l	a1,a0
	blt.s	.COP0
	move	#1,DSP_CHARGE_AUTO	; mise a .LOD du flag de chargement
	bra	.SCAN
	*------------------------*
	* on a detect‚ un .ASM
	*------------------------*
.ASM	;a0 pointe sur le nom...
	bsr	dsp_load_source
	bra	.SCAN

	*------------------------*
	* on a detect‚ un .CLD
	*------------------------*
.CLD	;recupere le nom du .CLD
	lea	dsp_name,a3
.COP1	move.b	(a0)+,(a3)+
	cmp.l	a1,a0
	blt.s	.COP1
	move	#2,DSP_CHARGE_AUTO	; mise a .LOD du flag de chargement
	bra	.SCAN
;------------------------------------------------------------------------------






	
	
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; gestion de tout ce qui touche au break points
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; breakpoint parametr‚
;------------------------------------------------------------------------------
S_BKP::
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	
	*------------------*
	* demande … l'utilisateur
	* d'entrer son bkp
	*------------------*
.recom
	xref	MES_BKPT_USER
	
	move.l	#MES_BKPT_USER,a0
	bsr.l	GET_CHAINE
	tst.b	d0
	beq	.FIN
	move.l	a2,a0				; dans a0 on a le debut de la chaine a exploiter
	tst.b	(a0)	
	beq	.FIN		;chaine vide
	

	*------------------*
	* extrait 4 pointeurs pours les 4 entr‚es possibles
	* nuls si valeur par d‚faut
	*------------------*
	sub.l	a3,a3
	move.l	a3,a4
	move.l	a3,a5
	move.l	a3,a6		;4 pointeurs nuls
	
	cmp.b	#',',(a0)
	beq.s	.EXPR
	move.l	a0,a3
	
.SCAN0	move.b	(a0),d0
	beq.s	.INSTALLE	
	cmp.b	#',',d0
	beq.S	.EXPR
	addq	#1,a0
	bra.S	.SCAN0
	
.EXPR	;expression
	clr.b	(a0)+

	move.b	(a0),d0
	beq	.INSTALLE	
	cmp.b	#',',d0
	beq.s	.TYPE
	move.l	a0,a4
	
.SCAN1	move.b	(a0),d0
	beq.s	.INSTALLE	
	cmp.b	#',',d0
	beq.S	.TYPE
	addq	#1,a0
	bra.S	.SCAN1
	
	

.TYPE	;0 ou 1
	clr.b	(a0)+

	move.b	(a0),d0
	beq	.INSTALLE	
	cmp.b	#',',d0
	beq.s	.EXEP
	move.l	a0,a5
	
.SCAN2	move.b	(a0),d0
	beq.s	.INSTALLE	
	cmp.b	#',',d0
	beq.S	.TYPE
	addq	#1,a0
	bra.S	.SCAN2

.EXEP	;no exeption
	clr.b	(a0)+

	move.b	(a0),d0
	beq	.INSTALLE	
	cmp.b	#',',d0
	beq.s	.INSTALLE
	move.l	a0,a6

.INSTALLE	

	*------------------*
	* ‚value l'adresse 
	*------------------*
	
	xref	eval
	tst.l	a3
	beq.s	.DEFAULT_ADR
	
	move.l	a3,a0
	bsr.l	eval
	tst	d2
	bne	.recom
	move.l	d1,d3
	bra.S	.OK_ADR	
.DEFAULT_ADR
	move.l	ACTIVE_WINDOW,a0
	move.l	adr_debut(a0),d3
.OK_ADR

	
	*------------------*
	* ‚value l'expression
	*------------------*

	tst.l	a4
	beq.s	.DEFAULT_EXPR
	move.l	a4,a0
	bsr.l	eval
	tst	d2
	bne	.recom
	move.l	a4,d4
	bra.S	.OK_EXPR
.DEFAULT_EXPR
	moveq	#0,d4
.OK_EXPR

	*------------------*
	* ‚value le type ( 0 ou 1 )
	*------------------*
	
	tst.l	a5
	beq.s	.DEFAULT_TYPE
	move.l	a5,a0
	bsr.l	eval
	tst	d2
	bne	.recom
	move.l	d1,d5
	not	d5	
	bra.s	.OK_TYPE
.DEFAULT_TYPE
	moveq	#0,d5
	not	d5	
.OK_TYPE

	*------------------*
	* ‚value l'exeption
	*------------------*
	tst.l	a6
	beq.s	.DEFAULT_EXEP
	move.l	a6,a0
	bsr.l	eval
	tst	d2
	bne	.recom
	move.l	d1,d6
	bra.s	.OK_EXEP
.DEFAULT_EXEP
	moveq	#3,d6
.OK_EXEP

	*------------------*
	* ya plus qu'a installer le BKP
	*------------------*
	move.l	d3,d0
	move.l	d4,d2
	move	d5,d1
	swap	d1
	move	d6,d1
	
	bsr	PUT_BKPT
	
	move.l	ACTIVE_WINDOW,a0
	bsr.l	set_dsp_flags
	;st	flag_aff(a0)
	
.FIN
	rts

	endc

	


;------------------------------------------------------------------------------
; d‚tection des arrets sur BKP et suppression du BKP
; correction PC sur SWI
;------------------------------------------------------------------------------
CHECK_BKP
	*-----------------*
	* v‚rifie si on tombe sur un bkp
	*-----------------*

	move.l	DSP_EXEPTION,d1
	move.l	DSP_REG+REG_PC,d0
	cmp.l	#2,d1
	beq.s	.DEC
	bra.S	.GO 
	
.DEC	subq	#1,d0		;sur SWI, le PC pointe apres le SWI
				;sur III le PC pointe sur le III
.GO	lea	TAB_BKPT,a0
	move	#nb_dsp_bkp-1,d7
.CHECK	tst	(a0)
	beq.s	.OK1
	cmp.l	Adresse(a0),d0
	beq.s	.BREAK	
.OK1	add	#BKP_Long,a0
	dbra	d7,.CHECK
	bra.s	.NOT_A_BKP

	*-----------------*
	* on a atteint un BKP 
	* on affiche un message appropri‚
	*-----------------*
.BREAK	
	move.l	d0,DSP_REG+REG_PC
	move	(a0),d0

	btst	#3,d0		;BKP T(emporaire)
	bne.s	.NO_MES

	btst	#2,d0		;bit P(arametr‚)
	bne	.PARAMETRE

.STOP	
	btst	#1,d0		;BKP Permanent ne s'efface pas
	bne.S	.NOCLR		


	clr	Actif(a0)
.NOCLR
	xref	prepare_chaine_bkpt,BK_REACH,BUF_BKPT,bkpt
	
	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
	move	d0,bkpt
	
	move.l	#BK_REACH,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR
	
.NO_MES
	bclr	#3,Actif+1(a0)	;efface bit Temporaire
	bra	.FIN			

	*-------------------*
	* l'exeption n'est pas un BKP
	* on affiche un message selon le type
	*-------------------*
.NOT_A_BKP
	tst.l	d1
	beq	.STACK_ERROR
	cmp.l	#1,d1
	beq	.TRACE
	cmp.l	#2,d1
	beq	.SWI
	cmp.l	#1,d1
	beq	.ILLEGAL
	bra	.FIN
.STACK_ERROR	
	move.l	#MES_STACK,MESSAGE_ADR
	bra.s	.FIN

.TRACE	move.l	#MES_TRACED,MESSAGE_ADR
	bra.s	.FIN

.SWI	move.l	#MES_SWI,MESSAGE_ADR
	bra.s	.FIN
	
.ILLEGAL
	xref	MES_ILL
	move.l	#MES_ILL,MESSAGE_ADR
	
.FIN
	rts
	
.PARAMETRE
	*-------------------*
	* on v‚rifie la condition
	*-------------------*
	move.l	a0,a1	
	move.l	Ptr_expr(a0),a0
	bsr.l	eval
	move.l	a1,a0
	tst.l	d1
	bne	.STOP
	
	*-------------------*
	* la condition n'est pas bonne
	* on trace une instruction et on relance
	*-------------------*
	
	or.l	#$2000,DSP_REG+REG_SR	;met le bit T
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
 	bsr	REC_REGISTERS		;trace one

 	
	bsr	SEND_BKP
	envl	#'CMD'
	envl	#DSP_RUN	
	bsr	SEND_REGISTERS
 	bsr	REC_REGISTERS		
	bsr	REMOVE_BKP		;RUN


	bra	CHECK_BKP 	
 	
 	
		
	
	
	
	


;------------------------------------------------------------------------------
DSP_FILL::
	tst	ACTIF_DSP
	beq	.FIN	
	
	move.l	#MES_FILL,a0
	bsr.l	GET_CHAINE		; chaine ascii dans a2
	tst.b	d0
	beq	.FIN
	move.l	a2,a0

	*--------------------*
	* premier parametere
	* type de RAM
	*--------------------*
	
	move.b	(a0)+,d0
	addq	#1,a0
	cmp.b	#',',d0
	beq	.RAMP
	
	cmp.b	#'P',d0
	beq.s	.RAMP	
	cmp.b	#'p',d0
	beq.s	.RAMP	
	cmp.b	#'X',d0
	beq.s	.RAMX	
	cmp.b	#'x',d0
	beq.s	.RAMX	
	cmp.b	#'Y',d0
	beq.s	.RAMY	
	cmp.b	#'y',d0
	beq.s	.RAMY	
	cmp.b	#'L',d0
	beq.s	.RAML	
	cmp.b	#'l',d0
	beq.s	.RAML	
	
.RAMX	moveq	#1,d7
	bra.S	.SOURCE
.RAMY	moveq	#2,d7
	bra.S	.SOURCE
.RAML	moveq	#3,d7
	bra.S	.SOURCE
.RAMP	moveq	#0,d7				

.SOURCE
	*--------------------*
	* deuxieme parametere
	* adresse source
	*--------------------*
	cmp.b	#',',(a0)+
	beq.S	.SDEF
	lea	-1(a0),a1	

.SCAN0	move.b	(a0)+,d1
	beq	.FIN
	cmp.b	#',',d1
	bne.s	.SCAN0	
	clr.b	-(a0)
	
	exg	a1,a0
	bsr.l	eval
	tst.l	d2
	bne	.FIN	
	move.l	d1,d6	
	lea	1(a1),a0
	bra.s	.LONGUEUR			
		

.SDEF	move.l	ACTIVE_WINDOW,a1
	move.l	adr_debut(a1),d6
.LONGUEUR
	cmp.b	#',',(a0)+
	beq.S	.SDEF
	lea	-1(a0),a1	

.SCAN1	move.b	(a0)+,d1
	beq	.FIN
	cmp.b	#',',d1
	bne.s	.SCAN1
	clr.b	-(a0)
	
	exg	a1,a0
	bsr.l	eval
	tst.l	d2
	bne	.FIN	
	move.l	d1,d5
	beq	.FIN
	lea	1(a1),a0

.OCTET
	bsr.l	eval
	tst.l	d2
	bne	.FIN	
	move.l	d1,d4		

	add.l	#DSP_P2DSP,d7

	envl	#'CMD'		
	envl	d7		;transfert RAM
	
	envl	d6		;adresse d‚but
	
	envl	d5		;nombre

.SEND	
	envl	d4		;valeur
	subq.l	#1,d5
	bne.s	.SEND		
		
	
	
.FIN
	rts
		

 	
CTRLJ::		xref	MESSAGE_ADR,ACTIVE_WINDOW
	tst	ACTIF_DSP
	beq.s	.FIN	

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_DSP_SRC,type(a0)	;Wactive= desas ?
	beq.S	JUMP_SOURCE			;OK
	cmp.w	#T_disas,type(a0)	;Wactive= desas ?
	bne.S	.FIN			;OK
	
	move.l	adr_debut(a0),DSP_REG+REG_PC


	move.l	#MES_JMP,MESSAGE_ADR
	bsr	PC_IN_WINDOW

	bsr.l	set_dsp_flags
	
.FIN	rts	
;------------------------------------------------------------------------------
JUMP_SOURCE
	tst	ACTIF_DSP
	beq.s	.FIN	

	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	move	Line_nb(a0),d0
	move.l	(a1,d0.w*4),d0
	beq.s	.FIN	
	move.l	d0,DSP_REG+REG_PC
	bsr.l	set_all_flags
.FIN	rts
			
		

;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
SETDSPPC::
; j au clavier...
	tst	ACTIF_DSP
	beq.s	.FIN	

	xref	GET_CHAINE
	xref	eval
	xref	PETIT_MESSAGE
.erreur

	move.l	#MES_PC,a0
	jsr	GET_CHAINE	
	tst.b	d0		;ds a2 on a la chaine saisie
	beq.s	.annule


	move.l	a2,a0
	Jsr	eval
	tst.b	d2
	bne.s	.erreur
	
	
	move.l	d1,DSP_REG+REG_PC
	
	move.l	#MES_OK,a0
	
	move.l	a0,MESSAGE_ADR
	move.l	a0,a2
	jsr	PETIT_MESSAGE
	
	move.l	a2,MESSAGE_ADR
.annule

.FIN	rts






;------------------------------------------------------------------------------
; benne les BKPT au DSP
; ATTENTION: on ne benne pas le BKP sur le PC
;------------------------------------------------------------------------------
SEND_BKP
	btst	#0,DSP_RUN_STATE+1
	bne	.FIN			;ils y sont deja !!
	

	lea	TAB_BKPT,a0
	move	#nb_dsp_bkp-1,d7
.SCAN	tst	Actif(a0)
	beq	.OK0
	
	move.l	Adresse(a0),d0
	cmp.l	DSP_REG+REG_PC,d0
	beq	.OK0

	envl	#'CMD'
	envl	#DSP_PDUMP
	envl	Adresse(a0)
	envl	#1
	recl	Sauve(a0)	;recoit le word concern‚

	envl	#'CMD'
	envl	#DSP_P2DSP
	envl	Adresse(a0)
	envl	#1
	envl	Exeption(a0)	;place l'instruction correspondante
	
.OK0	add	#BKP_Long,a0
	dbra	d7,.SCAN
	
	bset	#0,DSP_RUN_STATE+1	
.FIN	rts
	

;------------------------------------------------------------------------------
; enleve les BKPT du DSP
; saute celui qui ‚tait sur l'ancien PC
; et qui n'a donc pas ‚t‚ mis (ouf!)
;------------------------------------------------------------------------------
REMOVE_BKP
	btst	#0,DSP_RUN_STATE+1
	beq	.FIN			;ils ne sont pas mis !!

	lea	TAB_BKPT,a0
	move.l	OLD_DSP_REG+REG_PC,d0
	move	#nb_dsp_bkp-1,d7
.SCAN	tst	Actif(a0)
	beq.s	.OK0
	cmp.l	Adresse(a0),d0
	beq.s	.OK0	
	
	envl	#'CMD'
	envl	#DSP_P2DSP
	envl	Adresse(a0)
	envl	#1
	envl	Sauve(a0)
.OK0	add	#BKP_Long,a0
	dbra	d7,.SCAN
	
	bclr	#0,DSP_RUN_STATE+1	
.FIN	rts
	


;------------------------------------------------------------------------------
; replace le PC ds la fenetre si besoin
;------------------------------------------------------------------------------
PC_IN_WINDOW	xref	ACTIVE_WINDOW

	move.l	ACTIVE_WINDOW,a1
	
	cmp	#T_disas,type(a1)
	bne.s	.FIN
	
	move.l	DSP_REG+REG_PC,d0
	move.l	adr_debut(a1),d1
	cmp.l	d1,d0
	blt	.update
	cmp.l	adr_fin(a1),d0
	blt	.ok	
.update
	move.l	d0,adr_debut(a1)	
	bsr.l	set_dsp_flags
.ok	
.FIN	rts


;------------------------------------------------------------------------------
; place la fenetre active sur le PC
;------------------------------------------------------------------------------
CTRL9::		xref	ACTIVE_WINDOW
	
	move.l	ACTIVE_WINDOW,a0
	move	type(a0),d0
	cmp	#T_disas,d0
	beq.s	.OK
	cmp	#T_H24,d0
	beq.s	.OK
	cmp	#T_H48,d0
	beq.s	.OK
	cmp	#T_FRAC24,d0
	beq.s	.OK
	cmp	#T_HEXASCII24,d0
	beq.s	.OK
	rts
.OK	move.l	DSP_REG+REG_PC,adr_debut(a0)
	bsr.l	set_dsp_flags
	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; place un break point normal ou le d‚gomme si il existe deja 
;------------------------------------------------------------------------------
SET_BKPT::	xref	ACTIVE_WINDOW
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	

	move.l	ACTIVE_WINDOW,a0
	cmp.w	#T_DSP_SRC,type(a0)	;Wactive= desas ?
	beq	SET_BKP_SOURCE
	cmp.w	#T_disas,type(a0)
	bne	.FIN

	move.l	adr_debut(a0),d0


	lea	TAB_BKPT,a1
	move	#nb_dsp_bkp-1,d7
.LOOP	tst	Actif(a1)
	beq.s	.OK0
	cmp.l	Adresse(a1),d0
	beq.s	.CLR
.OK0	add	#BKP_Long,a1
	dbra	d7,.LOOP
	bra.S	.INSTALLE			
.CLR	clr	Actif(a1)
	bsr.l	set_dsp_flags

	*----------------------*
	* message BKP enlev‚
	*----------------------*
	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
	bsr.l	set_dsp_flags
	xref	prepare_chaine_bkpt,BK_KILLED,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_KILLED,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR

	bra.s	.FIN		

.INSTALLE
	move	#1,d1		;bkp normal
	swap	d1
	move	#4,d1		;par d‚faut exeption no 4 , TRAP
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT
	
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_PUT,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_PUT,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR


.FIN	rts	

	endc
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; place un BKP ds le source
;------------------------------------------------------------------------------
SET_BKP_SOURCE	
	demo_mode?
	
	bsr.l	set_dsp_flags


	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	move	Line_nb(a0),d0
	move.l	(a1,d0.w*4),d0
	
	lea	TAB_BKPT,a1
	move	#nb_dsp_bkp-1,d7
.LOOP	tst	Actif(a1)
	beq.s	.OK0
	cmp.l	Adresse(a1),d0
	beq.s	.CLR
.OK0	add	#BKP_Long,a1
	dbra	d7,.LOOP
	bra.S	.INSTALLE			
.CLR	clr	Actif(a1)

	*----------------------*
	* message BKP enlev‚
	*----------------------*

	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_KILLED,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_KILLED,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR

	bra.s	.FIN		

.INSTALLE
	move	#1,d1		;bkp normal
	swap	d1
	move	#3,d1		;SWI
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT
	
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_PUT,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_PUT,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR


.FIN	rts	

	endc
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; place un break point permanent ou le d‚gomme si il existe deja 
;------------------------------------------------------------------------------
SET_BKPT_PERMANENT::	xref	ACTIVE_WINDOW
	demo_mode?
	
	tst	ACTIF_DSP
	beq	.FIN	

	move.l	ACTIVE_WINDOW,a0
	
	cmp.w	#T_DSP_SRC,type(a0)	;Wactive= desas ?
	beq	SET_BKP_PERM_SOURCE
	cmp.w	#T_disas,type(a0)
	bne	.FIN
	bsr.l	set_dsp_flags

	move.l	adr_debut(a0),d0
	
	lea	TAB_BKPT,a1
	move	#nb_dsp_bkp-1,d7
.LOOP	tst	Actif(a1)
	beq.s	.OK0
	cmp.l	Adresse(a1),d0
	beq.s	.CLR
.OK0	dbra	d7,.LOOP
	bra.S	.INSTALLE			
.CLR	clr	Actif(a1)
	bsr.l	set_dsp_flags

	*----------------------*
	* message BKP enlev‚
	*----------------------*
	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
	xref	prepare_chaine_bkpt,BK_KILLED,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_KILLED,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR

	bra.s	.FIN		

.INSTALLE
	move	#2,d1		;bkp permanent
	swap	d1
	move	#3,d1		;SWI
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT
	
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_PUT,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_PUT,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR

.FIN	rts	

	endc

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; place un BKP permanent sur le source (ou l'enleve)
;------------------------------------------------------------------------------
SET_BKP_PERM_SOURCE
	demo_mode?
	
	bsr.l	set_dsp_flags


	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a1
	move	Line_nb(a0),d0
	move.l	(a1,d0.w*4),d0
	
	lea	TAB_BKPT,a1
	move	#nb_dsp_bkp-1,d7
.LOOP	tst	Actif(a1)
	beq.s	.OK0
	cmp.l	Adresse(a1),d0
	beq.s	.CLR
.OK0	add	#BKP_Long,a1
	dbra	d7,.LOOP
	bra.S	.INSTALLE			
.CLR	clr	Actif(a1)

	*----------------------*
	* message BKP enlev‚
	*----------------------*

	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_KILLED,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_KILLED,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR

	bra.s	.FIN		

.INSTALLE
	move	#2,d1		;bkp permanent
	swap	d1
	move	#3,d1		;SWI
	moveq	#0,d2		;pas d'expression
	bsr	PUT_BKPT
	
	bsr.l	set_dsp_flags

	xref	prepare_chaine_bkpt,BK_PUT,BUF_BKPT,bkpt
	move	d0,bkpt
	move.l	#BK_PUT,a0
	bsr.l	prepare_chaine_bkpt
	move.l	#BUF_BKPT,MESSAGE_ADR


.FIN	rts	

	endc

	




;------------------------------------------------------------------------------
; place un bkp
; ou place le bit Temporaire si c'est un BKP temporaire demand‚
;
;le type de BKP est un champ de bits:
; % 00000000 00000 T E P A
; A:	actif/inactif :obligatoire
; P:	BKP Permanent
; E:	BKP Parametr‚
; T:	BKP Temporaire ( utilis‚ par CTRL A )
;------------------------------------------------------------------------------
PUT_BKPT
;IN:
;	d0.l=	adresse du bkpt	
;	d1.l=	type.w:exeption.w
;	d2.l=	ptr expression
;OUT:	d0.l=	no de bkp
;		-1 si erreur

	tst	ACTIF_DSP
	bne.s	.ACTIF
	moveq	#-1,d0
	rts

.ACTIF
	movem.l	a0/d3/d7,-(sp)

	*---------------------*
	* recherche si l'adresse est d‚ja prise
	*---------------------*
	lea	TAB_BKPT,a0
	move	#nb_dsp_bkp-1,d7
.LOOP	tst	(a0)
	beq.s	.OK0
	cmp.l	4(a0),d0
	beq.s	.INSTALLE	;on ‚crabouille l'ancien BKPT
.OK0	add	#16,a0
	dbra	d7,.LOOP


	*---------------------*
	* recherche un slot libre
	*---------------------*
	lea	TAB_BKPT,a0
	move	#nb_dsp_bkp-1,d7
.LOOP2	tst	(a0)
	beq.s	.INSTALLE
	add	#BKP_Long,a0
	dbra	d7,.LOOP2
	moveq	#-1,d0
	bra.s	.FIN_ERREUR	;plus de bkpt dispo !!!!

.INSTALLE
	move.l	d1,d3
	swap	d3		;d3=type BKP

	tst	(a0)
	beq.s	.NEW_BKP
	cmp	#8,d3		;BKP TEMPORAIRE ?
	bne.s	.NEW_BKP
	or	d3,Actif(a0)	
	bra.S	.ADR	
.NEW_BKP
	move	d3,Actif(a0)
.ADR	move.l	d0,Adresse(a0)
	clr.l	Sauve(a0)
	move.l	(TAB_EXEP,d1.w*4),Exeption(a0)
	
	
	move.l	d2,Ptr_expr(a0)
	tst.l	d2
	beq.s	.OK_EXPR

	move.l	d2,a1
	ext.l	d1
	lsl.l	#8,d1
	lea	(BKPT_EXPR,d1.l),a2
	move.l	a2,Ptr_expr(a0)
	
	;recopie de l'expression
.COP0	move.l	(a1)+,(a2)+
	bne.S	.COP0	
	
.OK_EXPR
	

.FIN
	move	#nb_dsp_bkp-1,d0
	sub	d7,d0
.FIN_ERREUR
	movem.l	(sp)+,a0/d3/d7
	rts
;------------------------------------------------------------------------------
;cette table associe un opcode … chaque execption
;pour le moment, j'ai uniquement SWI... mais il faudrait ajouter III ...
;------------------------------------------------------------------------------
	DATA

		ifne	(DSP=DSP56001)
TAB_EXEP	dc.l	0,0,0,$000006,0		;SWI
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,$000005		;III
		endc

		ifne	(DSP=DSP56301)
TAB_EXEP	dc.l	0,0,$000005,5,$000006		;III+ TRAP
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,0,0,0,0
		dc.l	0,$000005		;III
		endc
		
;------------------------------------------------------------------------------
	TEXT


	
dsp_adresse::
	xref	adresse
	bsr.l	adresse
	bsr.l	set_dsp_flags
	rts




;**************************************
SKIP::
	tst	ACTIF_DSP
	beq	.FIN	
	
	xref	P_COUNT,DESAS_ONE,MESSAGE_ADR,set_dsp_flags
	move.l	ACTIVE_WINDOW,a0
	cmp	#T_DSP_SRC,type(a0)
	beq	SOURCE_SKIP	

	envl	#'CMD'
	envl	#DSP_PDUMP
	envl	DSP_REG+REG_PC
	envl	#2
	lea	WORK_BUF,a0
	recl	(a0)
	recl	4(a0)
	move.l	DSP_REG+REG_PC,P_COUNT
	xref	ASCII_BUF
	lea	ASCII_BUF,a6	
	bsr	DESAS_ONE
	move.l	P_COUNT,DSP_REG+REG_PC
	
	bsr.l	set_dsp_flags
	move.l	#MES_SKIPED,MESSAGE_ADR
.FIN	rts
;------------------------------------------------------------------------------
; passe … la prochaine ligne du source
;------------------------------------------------------------------------------
SOURCE_SKIP
	tst	ACTIF_DSP
	beq.S	.FIN	

	move.l	Src_adr(a0),a1
	move.l	ptr_conv(a1),a2
	move	nb_ligne(a1),d7
	*--------------------*
	* recherche la ligne apres le PC
	*--------------------*
	move.l	DSP_REG+REG_PC,d0
.SCAN0	cmp.l	(a2)+,d0
	blt.s	.F0
	subq	#1,d7
	bne.s	.SCAN0
	bra	.FIN	
.F0	move.l	-(a2),d0		;adresse physique
	move.l	d0,DSP_REG+REG_PC

	bsr.l	set_dsp_flags
	move.l	#MES_SKIPED,MESSAGE_ADR
.FIN	rts
	
	


;------------------------------------------------------------------------------
; initialise un tableau de nb lignes pointeur sur le source
;------------------------------------------------------------------------------
INIT_TAB_LIGNE::
;IN: 
;	a0	le source
;	a1	le ptr sur la table de lignes
;	a2	ptr sur la structure 'source'

	movem.l	d0-d3/a0/a1,-(sp)
	;lea	TAB_LIGNE,a1
	;lea	SOURCE,a0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	clr.l	(a1)+
.NEWLINE
	cmp	d2,d3
	ble.s	.OK0
	move	d3,d2		;d2=max(nb_col,d3)
.OK0
	moveq	#0,d3
	move.l	a0,(a1)+
	addq	#1,d1
.LOOP	
	move.b	(a0)+,d0
	beq.S	.FIN
	cmp.b	#$d,d0
	beq.S	.CR
	cmp.b	#9,d0
	bne.s	.NOTAB
	add	TAB_VALUE,d3
.NOTAB	addq	#1,d3
	bra.S	.LOOP
.CR					
	move.b	(a0)+,d0
	beq.S	.FIN
	cmp.b	#$a,d0
	beq.S	.NEWLINE
	subq	#1,a0
	bra.s	.NEWLINE

	
.FIN	
	clr.l	-(a1)
	move	d1,nb_ligne(a2)
	move	d2,nb_col(a2)

	movem.l	(sp)+,d0-d3/a0/a1
	rts




	




	
;------------------------------------------------------------------------------
; envoie le contexte DSP au DSP
; +retablissement de la RAM (BKPT)
;------------------------------------------------------------------------------
SEND_REGISTERS::
	movem.l	d7/a0-a1,-(sp)

	*-----------------*
	* palce HF0… 1
	*-----------------*

	ifne	(DSP=DSP56001)
	bset	#3,$ffffa200.w
	endc	

	ifne	(DSP=DSP56301)
	or.l	#$20,HCTR		;place HF2
	endc	

	*-----------------*
	* envois des registres de l'AGU
	*-----------------*
	lea	DSP_REG+REG_R0,a0
	move	#8*3-1,d7
.LOOP0	envl	(a0)+
	dbra	d7,.LOOP0

	*-----------------*
	* envois des registres de l'ALU
	*-----------------*
	lea	DSP_REG+REG_A2,a0
	move	#3*2+4-1,d7
.LOOP1	envl	(a0)+
	dbra	d7,.LOOP1

	*-----------------*
	* envois des registres de la PCU
	*-----------------*

	envl	DSP_REG+REG_LA
	envl	DSP_REG+REG_LC

	envl	DSP_REG+REG_SP
	envl	DSP_REG+REG_SSH
	envl	DSP_REG+REG_SSL
	
	*-----------------*
	* remet ds le HOST ce qui ‚tait 
	* coinc‚ dedans...
	*-----------------*
	
	lea	HOST_BUF,a0
.LOOP	move.l	(a0)+,d0
	cmp.l	#'CTK',d0
	beq.s	.FIN
	envl	d0
	bra.s	.LOOP
.FIN
	ifne	(DSP=DSP56001)
	bclr	#3,$ffffa200.w
	endc
	
	ifne	(DSP=DSP56301)
	and.l	#$ffffffff-$20,HCTR		;efface HF2
	endc	

	movem.l	(sp)+,d7/a0-a1
	rts

;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
; reception du contexte DSP
; +retablissement de la RAM (BKPT)
;------------------------------------------------------------------------------
REC_REGISTERS::
	movem.l	d7/a0-a1,-(sp)

	*-----------------*
	* copie des registres 
	*-----------------*
	lea	DSP_REG,a0
	lea	OLD_DSP_REG,a1
	move	#REG_Long-1,d7
.COP	move.l	(a0)+,(a1)+
	dbra	d7,.COP

	*-----------------*
	* on v‚rifie que le DSP nous envoie des trucs
	* et WATCHDOG si le noyau est mort !
	*-----------------*

	ifne	(DSP=DSP56001)

	move	#$7fff,d7
.WAIT	
	btst	#0,$ffffa202.w
	dbne	d7,.WAIT
	tst	d7
	bmi	.LE_NOYAU_EST_MORT
	
	endc
	

	*--------------------*
	* recoit le contenu du port HOST
	*--------------------*
	lea	TEMP_BUF,a0
.REC	recl	d0
	move.l	d0,(a0)+
	cmp.l	#'CTK',d0
	bne.s	.REC
	

	
	recl	DSP_EXEPTION	;exeption ayant caus‚e l'arret


	*-----------------*
	* reception des registres de l'AGU
	*-----------------*
	lea	DSP_REG+REG_R0,a0
	move	#8*3-1,d7
.LOOP0	recl	(a0)+
	dbra	d7,.LOOP0

	*-----------------*
	* reception des registres de l'ALU
	*-----------------*
	lea	DSP_REG+REG_A2,a0
	move	#3*2+4-1,d7
.LOOP1	recl	(a0)+
	dbra	d7,.LOOP1

	*-----------------*
	* reception des registres de la PCU
	*-----------------*
	lea	DSP_REG+REG_LA,a0
	move	#5-1,d7
.LOOP2	recl	(a0)+
	dbra	d7,.LOOP2

	and.l	#$ffffffff-$2000,DSP_REG+REG_SR		;clear bit Trace


	*-----------------*
	* le DSP r‚cupere le contenu de la FIFO HOST
	* et me la renvoie
	*-----------------*

	envl	#'CTK'

	lea	HOST_BUF,a0
.LH	recl	d0
	and.l	#$ffffff,d0
	move.l	d0,(a0)+
	cmp.l	#'CTK',d0
	bne.s	.LH	
	
	*-----------------*
	* je renvoie au DSP ses infos … me r‚‚mettre
	*-----------------*
	lea	TEMP_BUF,a0
.LH0	move.l	(a0)+,d0
	envl	d0
	cmp.l	#'CTK',d0
	bne.s	.LH0
	

.FIN	movem.l	(sp)+,d7/a0-a1
	rts
.LE_NOYAU_EST_MORT
	clr	ACTIF_DSP
	bra.S	.FIN

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------	
; libere les buffers Malloqu‚s … divers endroits
;------------------------------------------------------------------------------	
MFREE_DIVERS::
	move.l	SYMBOLS_PTR,d0
	beq.s	.OK0
	move.l	d0,-(sp)
	GEM	Mfree	
.OK0
	xref	LOG
	move.l	LOG,-(sp)
	move	#$49,-(sp)
	trap	#1		;MFREE de l'‚cran
	addq	#6,sp

	rts
	
;------------------------------------------------------------------------------	



FIN::
	xref	OLD_VIDEO,SET_VIDEO

	lea	OLD_VIDEO,a0
	bsr.l	SET_VIDEO	;restore video

	
	move	#$2300,sr

	move.l	OLD_SSP,-(sp)
	move	#32,-(sp)
	trap	#1
	addq	#6,sp	

	bsr	MFREE_DIVERS

	ifne	0	
	xref	DOLMEN_VIDEO
	tst	DOLMEN_VIDEO
	bne.s	.DOLMEN
.TOS
		

	
	bra	.PTERM
.DOLMEN
	xref	OLD_MODE
	pea	OLD_MODE
	XBIOS	Vwrite

	endc
.PTERM
	xref	flush_k_sys
	bsr.l	flush_k_sys
	


	clr	-(sp)
	trap	#1


	

INITS
	move.l	#'CTK',HOST_BUF
	move.l	#'CTK',TEMP_BUF
	*---------------*
	* SUPERVISEUR
	*---------------*
	xref	pile_prog
	
	;move.l	(sp),PILE
	move.l	(sp),pile_prog
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,OLD_SSP	
	;lea	PILE,sp
	lea	pile_prog,sp
	xref	buffer_r
	movec	MSP,d0
	move.l	d0,buffer_r+r_msp



	*---------------*
	* Lit le CENTINEL.INF au d‚marrage de CENTINEL
	*---------------*
	xref	BOOT_PREFS
	bsr.l	BOOT_PREFS

	;*---------------*
	;* Lit le CENTINEL.INF
	;*---------------*
	;
	;xref	PREF_NAME
	;lea	PREF_NAME,a0
	;xref	READ_PREFS
	;bsr.l	READ_PREFS

	*---------------*
	* INIT VIDEO
	*---------------*

	xref	INIT_VIDEO
	bsr.l	INIT_VIDEO	
	

	
	
	*---------------*
	* charge le noyau DSP
	*---------------*
	
	bsr	load_dsp_prog


	
	ifne	(DSP=DSP56001)
	*---------------------*
	* init du trap #4
	*---------------------*
	move.l	#DSP_WAKE_UP,$90.w
	endc
	
	ifne	(DSP=DSP56301)
	*---------------------*
	* init de la HINT
	*---------------------*
	move.l	#DSP_WAKE_UP,$90.w
	move.l	#DSP_WAKE_UP,$200.w
	endc


	move	#$2700,sr

	rts
	
;------------------------------------------------------------------------------	
load_dsp_prog::
	*-----------------------*
	* charge le P56 avec le xbios sur 56001
	*-----------------------*
	ifne	(DSP=DSP56001)
	move	#$2300,sr		;4ba.w doit tourner..
	move.l	#END_P56,d0
	sub.l	#P56,d0
	divu	#3,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	P56
	move.w	#$6d,-(sp)		;exec_dsp_prog
	trap	#14		
	lea	10(sp),sp	
	endc
	
	
	
	*-----------------------*
	* charge le p56 … la main sur 56301
	*-----------------------*
	ifne	(DSP=DSP56301)
	
READ24	MACRO
	move.l	(\1),\2
	lsr.l	#8,\2
	addq	#3,\1
	ENDM

	;----------------------------------------------------------------------
	; proc‚dure pour r‚seter le 56301 de la carte PREFACE301
	; tous les acces sont en ‚criture long align‚s long
	;
	; 1. activer le RESET par un acces au DSP_CONTROL avec A22=1 
	;	clr.l	 $f0c00000
	;
	; 2.attendre 20 ms
	;
	; 3. couper le DSP RESET en maintenant IRQC par un acces au DSP_CONTROL avec A22=0 et A21=1
	;	clr.l	$f0a00000
	;
	; 4. couper l'IRQC par un acces au DSP_CONTROL avec A22=0 A21=0
	;	clr.l	$f0800000
	;----------------------------------------------------------------------


	clr.l	$f0c00000		;reset on

	move	#$2300,sr
	move.l	$4ba.w,d0
	add.l	#8,d0
.WAIT0	cmp.l	$4ba.w,d0
	bge	.WAIT0
	move	#$2700,sr

	clr.l	$f0a00000		;coupe dsp reset maintien l'IRQ C
	clr.l	$f0800000		;pas de reset ni d'IRQ C


	lea	P56+3,a0		;un seul block
	READ24	a0,d1
	READ24	a0,d0
	envl	d0			;nb words
	envl	d1			;adresse de base

	subq	#1,d0
LOOPSEND
	READ24	a0,d1
	envl	d1
	dbra	d0,LOOPSEND

		
	*-----------------------*
	* le premier acces me fait tjrs un Berr... je d‚tourne
	*-----------------------*

	;illegal
	;movec	vbr,a0
	;move.l	#.OK,8(a0)	
	
	btst	#2,HSTR+3
.OK
	endc
	
	
	*-----------------------*
	* La protection !!!
	* d‚marre ici
	*-----------------------*
	recl	d1
	swap	d1
	recl	d0			;la valeur stock‚e ds le DSP
	move	d0,d1

	move.l	buffer_r+r_msp,d0	;la valeur sur la machine
	eor.l	d0,d1
	
	*-----------------------*
	* calcule le nombre de bits diff‚rents
	* entre 2 longs
	* r‚sultat ds d2
	*-----------------------*
	moveq	#0,d0
	moveq	#0,d2
	move	#31,d7
.LOOP
	add.l	d1,d1
	addx.l	d2,d0
	dbra	d7,.LOOP
	
	*-----------------------*
	ifne	DEMO_MODE
	moveq	#0,d0
	endc
	ifeq	PROTECT_ACTIVE	
	moveq	#0,d0
	endc
	envl	d0			;envoie la diff‚rence au DSP

	recl	d0			;recoit la valeur magique
	ext.l	d0			;qui peut tout planter

	xref	RET_DEB
	lsr.l	d0
	sub.l	d0,RET_DEB		;plante l'adresse de retour si PB

	ifne	(DSP=DSP56301)
	or.l	#$20,HCTR		;place HF2

	move	#$2300,sr
	move.l	$4ba.w,d0
	add.l	#8,d0
.WAIT1	cmp.l	$4ba.w,d0
	bge	.WAIT1
	move	#$2700,sr

	and.l	#$ffffffff-$20,HCTR	;et on l'enleve
	endc
	
	
	bsr	INIT_DSP_REG


	
	
	rts
	
	
	
INIT_DSP_REG	
	*-----------------------*
	* init des registres DSP
	*-----------------------*
	
	lea	DSP_REG+REG_R0,a0
	move	#8-1,d7
.AGU	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#$ffffff,(a0)+
	dbra	d7,.AGU

	lea	DSP_REG+REG_A2,a0
	move	#6+4-1,d7
.ALU	clr.l	(a0)+
	dbra	d7,.ALU
	
	clr.l	(a0)+		;LA
	clr.l	(a0)+		;LC
	
	move.l	#$200,(a0)+	;SR
	clr.l	(a0)+		;PC
	
	clr.l	(a0)+		;SP

	*-----------------------*
	* copie des registres 
	*-----------------------*

	lea	DSP_REG,a0
	lea	OLD_DSP_REG,a1
	move	#REG_Long-1,d7
.COP	move.l	(a0)+,(a1)+
	dbra	d7,.COP

	*-----------------------*
	* efface la table de bkp
	*-----------------------*
	lea	TAB_BKPT,a0
	move	#nb_dsp_bkp*5-1,d7
.CLR	clr.l	(a0)+
	dbra	d7,.CLR
	
	rts
		
	
;------------------------------------------------------------------------------	





	DATA
TRACE_UNTIL_FLAG	dc	0

	ifne	DSP=DSP56001
P56	incbin	DSP.P56
END_P56
	endc
	
	ifne	DSP=DSP56301
P56	incbin	DSP301.P56
END_P56
	endc
	
	

	even
TAB_VALUE	dc	8


		ifne	(LANGUAGE=FRANCAIS)
MES_RUN		dc.b	'DSP Lanc‚',0
MES_TRACED	dc.b	'Trac‚',0
MES_SKIPED	dc.b	'Pass‚',0
MES_RB		dc.b	'Lanc‚ et stopp‚',0
MES_JMP		dc.b	'Saute',0
MES_SPACE	dcb.b	80,' '
MES_PC		dc.b	'DSP PC=',0
MES_OK		dc.b	'Operation effectu‚e',0
MES_LOAD::	dc.b	'Fichier LOD … charger: ',0
		dcb.b	100,0
MES_FILE_NOT_FOUND::	dc.b	'Fichier non trouv‚...',0
MES_FILL	dc.b	'Remplir (mem,s,l,o) : ',0
MES_PREF_WRIT::	dc.b	'Configuration sauv‚e',0
MES_GET		dc.b	'chaine … chercher  : ',0
MES_RAM		dc.b	'memoire(P/X/Y)? ',0
MES_FOUND	dc.b	'trouv‚',0
MES_ABORT	dc.b	'recherche annul‚e',0
MES_INCREASE	dc.b	'ADRESSE EN COURS:$ffffff',0
MES_STACK	dc.b	'Erreur de pile',0
MES_SWI		dc.b	'Interruption logicielle',0
MES_S_BINARY	dc.b	'DSP sauve binaire (fichier,T:deb,long) : ',0
		even
		endc


		ifne	(LANGUAGE=ANGLAIS)
MES_RUN		dc.b	'DSP Runs',0
MES_TRACED	dc.b	'Traced',0
MES_SKIPED	dc.b	'Skiped',0
MES_RB		dc.b	'Run and Break',0
MES_JMP		dc.b	'Jump',0
MES_SPACE	dcb.b	80,' '
MES_PC		dc.b	'DSP PC=',0
MES_OK		dc.b	'Operation done',0
MES_LOAD::	dc.b	'LOD File to load: ',0
		dcb.b	100,0
MES_FILE_NOT_FOUND::	dc.b	'File Not Found...',0
MES_FILL	dc.b	'Fill (M,s,l,o) : ',0
MES_PREF_WRIT::	dc.b	'Configuration file saved',0

MES_GET		dc.b	'string to find: ',0
MES_RAM		dc.b	'memory(P/X/Y)? ',0
MES_FOUND	dc.b	'found',0
MES_ABORT	dc.b	'cancelled',0
MES_INCREASE	dc.b	'CURRENT ADDRESS :$ffffff',0
MES_STACK	dc.b	'Stack Error',0
MES_SWI		dc.b	'Software Interrupt',0
MES_S_BINARY	dc.b	'DSP save binary (file,T:starts,length) : ',0
		even
		endc
		
DSP_CHARGE_AUTO::	dc	0

*------------------------------------------------------------------------------
* pointeur sur la table des symbols
*
* nb_sym.L
*
* mem.W		'X',0 ou 'Y',0 ...
* adr.l		
* ptr_name.l
*------------------------------------------------------------------------------
SYMBOLS_PTR::		dc.l	0
*------------------------------------------------------------------------------



;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	BSS
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------





;------------------------------------------------------------------------------
; quelques variables pour les retours d'exeptions
;------------------------------------------------------------------------------
DSP_EXEPTION	ds.l	1
DSP_RUN_STATE	ds	1	;des flags pour rep‚rer comment on a lanc‚ le DSP
				;(avec ou sans BKP ...)
MESSAGE_TYPE	ds	1	;pour que wake up devine le type de message
;------------------------------------------------------------------------------





;------------------------------------------------------------------------------
; Quelques sauvegardes
;------------------------------------------------------------------------------
OLD_SSP	ds.l	1
;------------------------------------------------------------------------------




;------------------------------------------------------------------------------
; un tableau de structure sur les sources 040 et DSP
;------------------------------------------------------------------------------
DSP_NB_SOURCES::	ds	1
DSP_SOURCE_TABLE::	ds.b	Size_src*max_src
;------------------------------------------------------------------------------




;------------------------------------------------------------------------------
; BREAKPOINTS & CO
;------------------------------------------------------------------------------
BKPT_EXPR	ds.b	256*nb_dsp_bkp
UNTIL_EXPR	ds.b	256
;------------------------------------------------------------------------------



dsp_name::	ds.b	256		;nom de fichier
;------------------------------------------------------------------------------
DSP_REG::	ds.l	REG_Long	;buffer pour les rtegistres DSP
OLD_DSP_REG::	ds.l	REG_Long	;tampon pour les sauvegardes
;------------------------------------------------------------------------------
HOST_BUF::	ds.l	5
TEMP_BUF::	ds.l	5
;------------------------------------------------------------------------------
TAB_BKPT::	ds.l	nb_dsp_bkp*5		;256 BKPT max
WORK_BUF::	ds.b	20000		;pour mettre du binaire etc...
;------------------------------------------------------------------------------

