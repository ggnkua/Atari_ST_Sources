;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;chargement et extraction des infos d'un .LOD
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


	output	d:\centinel\dsp\load_lod.o
	include	d:\centinel\both\define.s
	include	d:\Centinel\both\GEM.EQU

;------------------------------------------------------------------------------
; chargement de .LOD
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
LOAD_LOD::
	xref	WORK_BUF,ASCII_BUF
	xref	dsp_name
	xref	ACTIF_DSP
	tst	ACTIF_DSP
	bne.S	.ACT
	rts
.ACT
	lea	.txt,a0
	lea	.mask,a1
	lea	dsp_name,a2
	
	xref	FILE_SELECTOR	
	bsr.l	FILE_SELECTOR	
	
	tst	d0
	beq	GO_FILE
	rts
	
		
.mask	dc.b	'*.*',0
	ifne	(LANGUAGE=FRANCAIS)
.txt	dc.b	'choisissez un fichier LOD',0
	endc
	
	ifne	(LANGUAGE=ANGLAIS)
.txt	dc.b	'select a LOD file',0
	endc
		

AUTO_LOAD_LOD::

GO_FILE
	*----------------------------------*
	* v‚rifie si il existe
	*----------------------------------*
	move	#0,-(sp)
	move.l	#dsp_name,-(sp)
	GEM	Fopen
	tst.l	d0
	bmi	ERREUR_FILE
	move	d0,-(sp)
	GEM	Fclose

	*----------------------------------*
	*libere l'ancien buffer de symboles
	*----------------------------------*
	xref	SYMBOLS_PTR
	move.l	SYMBOLS_PTR,d0
	beq.s	.NOFREE
	move.l	d0,-(sp)
	GEM	Mfree				
	clr.l	SYMBOLS_PTR	

.NOFREE
	*----------------------------------*
	* reserve une place tampon temporaire pour 1000 symbols
	*----------------------------------*
	
	move.l	#26*1000,-(sp)			;max 1000 symboles
	GEM	Malloc
	move.l	d0,-(sp)	

	
	*----------------------------------*
	* conversion du .LOD
	* et extraction des symbols
	*----------------------------------*
	lea	dsp_name,a0
	lea	WORK_BUF,a1
.C0	move.b	(a0)+,(a1)+
	bne.S	.C0		;copie le nom du fichier

	move	#$2300,sr
	lea	WORK_BUF,a0
	move.l	(sp),a1
	xref	READ_LOD
	bsr	READ_LOD
	
	*----------------------------------*
	* Met le nom du fichier ds les symbols
	*----------------------------------*
	move.l	(sp),a1
	
	move.l	(a1),d0
	addq.l	#1,(a1)+
	mulu	#26,d0
	add.l	d0,a1
	move	#'P'*256,(a1)+	;programme
	clr.l	(a1)+		;adresse 0
	lea	dsp_name,a0
.C	move.b	(a0)+,(a1)+
	bne.s	.C
	
	add.l	#26,d0		;taille des symbols
	move.l	d0,d7	
	
	*----------------------------------*
	* fait le Malloc definitif 
	* recopie dedans le buffer temporaire
	* libere le buffer temporaire
	*----------------------------------*
	
	move.l	d0,-(sp)
	GEM	Malloc
	move.l	d0,SYMBOLS_PTR
	move.l	d0,a1
	move.l	(sp),a0
	
	asr.l	d7
	subq	#1,d7
.COP	move	(a0)+,(a1)+
	dbra	d7,.COP
	
	GEM	Mfree			
	
	*----------------------------------*

	moveq	#0,d5
	move	#$2700,sr
	lea	WORK_BUF,a0
	move.l	(a0)+,d7	;nb de commandes
	beq	.LOADED
	subq	#1,d7
.CMD	
	envl	#'CMD'
	move.l	(a0)+,d0
	cmp.l	#'MEMX',d0
	beq.s	.MEMX
	cmp.l	#'MEMY',d0
	beq.s	.MEMY
.MEMP	envl	#DSP_P2DSP
	bra.s	.GO
.MEMX	envl	#DSP_X2DSP
	bra.s	.GO
.MEMY	envl	#DSP_Y2DSP
.GO	envl	(a0)+		;debut
	move.l	(a0)+,d6	;nombre
	beq.s	.FIMEM
	envl	d6
	add.l	d6,d5
	subq	#1,d6	
.SEND	envl	(a0)+
	dbra	d6,.SEND		
.FIMEM	dbra	d7,.CMD		
	

.LOADED		
	*---------------------*
	* place le nom du fichier en message
	*---------------------*

	xref	MES_LOAD_OK
	move.l	#MES_LOAD_OK,MESSAGE_ADR
	lea	MES_LOAD_OK,a0
.K12	tst.b	(a0)+
	bne.s	.K12
	subq.l	#1,a0
	move.b	#'$',(a0)+

	
	;la taille du fichier est ds d0
	move.l	d5,d0
	xref	TAB_CONV
	lea	TAB_CONV,a1
		
	
	move	#8-1,d7
	moveq	#0,d2
.LOOPNUM
	rol.l	#4,d0
	move	d0,d1	
	and	#$f,d1
	bne.s	.OK10
	tst	d2
	bne.s	.OK10
	bra.s	.jmp	
.OK10	move	(a1,d1),(a0)+
	st	d2
.jmp	dbra	d7,.LOOPNUM	
	

	
	ifne	(LANGUAGE=ANGLAIS)
	move.l	#' wor',(a0)+
	move.l	#"ds (",(a0)+
	move.b	#"'",(a0)+
	endc
	ifne	(LANGUAGE=FRANCAIS)
	move.l	#' mot',(a0)+
	move.l	#"s ('",(a0)+
	endc
	lea	dsp_name,a1
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

	
	


	move	#$2700,sr
	*------------------*
	* toutes les fenetres disass … 0
	*------------------*
	moveq	#0,d0
	xref	WINDOW_LIST
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP000
	move.l	(a0)+,a1
	cmp	#T_disas,type(a1)
	bne.s	.OK0
	move.l	d0,adr_debut(a1)
.OK0	dbra	d7,.LOOP000

	*---------------------*
	* message + redraw
	*---------------------*
	xref	set_dsp_flags
	bsr.l	set_dsp_flags



	rts
ERREUR_FILE	
	xref	MES_FILE_NOT_FOUND,MESSAGE_ADR
	move.l	#MES_FILE_NOT_FOUND,MESSAGE_ADR
	bsr.l	set_dsp_flags
	rts
