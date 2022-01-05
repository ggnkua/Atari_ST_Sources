;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;chargement et extraction des infos d'un .P56
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


	output	d:\centinel\dsp\load_p56.o
	include	d:\centinel\both\define.s
	include	d:\Centinel\both\GEM.EQU



;------------------------------------------------------------------------------
; chargement de .P56
; et chargement automatique au d‚marrage
;------------------------------------------------------------------------------
LOAD_P56::
	xref	dsp_name
	xref	ACTIF_DSP
	tst	ACTIF_DSP
	bne.S	.ACT		;d‚gage si le DSP n'est pas la
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
	
		
.mask	dc.b	'*.P56',0
	ifne	(LANGUAGE=FRANCAIS)
.txt	dc.b	'choisissez un fichier P56',0
	endc
	
	ifne	(LANGUAGE=ANGLAIS)
.txt	dc.b	'select a P56 file',0
	endc
		

AUTO_LOAD_P56::

GO_FILE
	move	#0,-(sp)
	pea	dsp_name
	GEM	Fopen
	move.l	d0,d7
	bmi	.ERREUR
	
	
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
	

	move	d7,-(sp)
	GEM	Fclose
	
	move.l	a6,a0
	move.l	d6,d7
	divu	#3,d7	

	
.CMD	
	envl	#'CMD'
	move.l	(a0),d0
	lsr.l	#8,d0	
	addq	#3,a0
	
	cmp.l	#'MEMX',d0
	beq.s	.MEMX
	cmp.l	#'MEMY',d0
	beq.s	.MEMY
.MEMP	envl	#DSP_P2DSP
	bra.s	.GO
.MEMX	envl	#DSP_X2DSP
	bra.s	.GO
.MEMY	envl	#DSP_Y2DSP
.GO	move.l	(a0),d0
	lsr.l	#8,d0	
	addq	#3,a0

	envl	d0		;debut

	move.l	(a0),d6
	lsr.l	#8,d6
	addq	#3,a0		;nombre
	beq.s	.FIMEM
	envl	d6
	add.l	d6,d5
	subq	#1,d6	
.SEND	move.l	(a0),d0
	lsr.l	#8,d0	
	addq	#3,a0

	envl	d0		;debut
	subq	#1,d7
	dbra	d6,.SEND		
.FIMEM	
	subq	#3,d7
	bne	.CMD
		

.ERREUR	rts


