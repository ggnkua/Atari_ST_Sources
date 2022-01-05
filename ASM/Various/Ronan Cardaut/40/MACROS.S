
lit_mem	macro
**********************************
** lit_mem.t	an,dn           **
** macro qui va lire la memoire **
** en .t dans a6 et placer le   **
** contenu dans dn            	**
**********************************

	
	move.b	#0,ERR_MEM
	
	move	COL_NOR,ATTRIBUTE
	movem.l	a5-a6,-(sp)
	
	move.l	a7,s_a7
	lea	pile_test,a7
	
	move.l	\1,a6
	
	lea	$8,a5	
	add.l	ADR_VBR,a5
	move.l	#.TEST_ADR\@,(a5)		; on detourne buserr
	
				
	
	
	;cmp.l	#$f1800000-1,a6
	cmp.l	#$f0000000-1,a6
	bhi.s	.INT_ADR\@
	
	
	move.\0	(a6),\2				; la lecture memoire
	
.ERR_\@
	move.l	#TRACE,(a5)			; on restore les exeptions
	
	move.l	s_a7,a7	
	
	movem.l	(sp)+,a5-a6
	bra.s	.FIN_MCR\@

.TEST_ADR\@
	move.b	#ADR_BUS_L,ERR_MEM		; on a une adresse qui
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'****',\2
	bra.s	.ERR_\@
.INT_ADR\@
	move.b	#ADR_INT_L,ERR_MEM		; on a une adresse qui
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'----',\2
	bra.s	.ERR_\@


.FIN_MCR\@


	endm




lit_mem_io 		macro
**********************************
** lit_mem.t	an,dn           **
** macro qui va lire la memoire **
** en .t dans a6 et placer le   **
** contenu dans dn            	**
**********************************

	
	move.b	#0,ERR_MEM
	
	move	COL_NOR,ATTRIBUTE
	movem.l	a5-a6,-(sp)
	
	move.l	a7,s_a7
	lea	pile_test,a7
	
	move.l	\1,a6
	
	lea	$8,a5	
	add.l	ADR_VBR,a5
	move.l	#.TEST_ADR\@,(a5)		; on detourne buserr
	
				
	
	
	move.\0	(a6),\2				; la lecture memoire
	
.ERR_\@
	move.l	#TRACE,(a5)			; on restore les exeptions
	
	move.l	s_a7,a7	
	
	movem.l	(sp)+,a5-a6
	bra.s	.FIN_MCR\@

.TEST_ADR\@
	move.b	#ADR_BUS_L,ERR_MEM		; on a une adresse qui
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'****',\2
	bra.s	.ERR_\@
.FIN_MCR\@


	endm


writ_mem	macro
**************************************
** la meme mais en ecriture memoire **
** \1 le registre    \2 l'adr       **
**************************************
	move.b	#0,ERR_MEM
	
	movem.l	a5-a6,-(sp)
	
	move.l	a7,s_a7
	lea	pile_test,a7
	
	move.l	\2,a6
	
	lea	$8,a5	
	add.l	ADR_VBR,a5
	
	move.l	#.TEST_ADR\@,(a5)		; on detourne buserr
	
	
	cmp.l	#$ffff0000-1,a6
	bhi.s	.INT_ADR\@
	
	
	move.\0	\1,(a6)				; la lecture memoire
	
.ERR_\@
	move.l	#TRACE,(a5)			; on restore les exeptions
	
	move.l	s_a7,a7	
	
	movem.l	(sp)+,a5-a6
	bra.s	.FIN_MCR\@



.TEST_ADR\@
	move.b	#ADR_BUS_L,ERR_MEM		; on a une adresse qui
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'****',\1
	bra.s	.ERR_\@
.INT_ADR\@
	move.b	#ADR_INT_L,ERR_MEM		; on a une adresse qui
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'----',\1
	bra.s	.ERR_\@


.FIN_MCR\@


	endm

writ_mem_io	macro
**************************************
** la meme mais en ecriture memoire **
** \1 le registre    \2 l'adr       **
**************************************
	move.b	#0,ERR_MEM
	
	movem.l	a5-a6,-(sp)
	
	move.l	a7,s_a7
	lea	pile_test,a7
	
	move.l	\2,a6
	
	lea	$8,a5	
	add.l	ADR_VBR,a5
	
	move.l	#.TEST_ADR\@,(a5)		; on detourne buserr
	
	
	
	
	move.\0	\1,(a6)				; la lecture memoire
	
.ERR_\@
	move.l	#TRACE,(a5)			; on restore les exeptions
	
	move.l	s_a7,a7	
	
	movem.l	(sp)+,a5-a6
	bra.s	.FIN_MCR\@

.TEST_ADR\@
	st	ERR_MEM
	move	COL_ERR_L,ATTRIBUTE		; genere un bus error
	move.l	#'****',\1
	bra.s	.ERR_\@
.FIN_MCR\@


	endm


demo_mode?	macro
********************************
** macro qui va afficher demo **
** si on est en demo          **
********************************
	ifne	DEMO_MODE
	
	
	move.l	#MES_DEMO,MESSAGE_ADR
	rts
	
	
	
	else
	
	endm
	
vide_cache	macro
************************************
** macro qui va nettoyer le cache **
************************************
	cmp.w	#cpu_30,CPU_TYPE
	bne.s	.aaa\@
	
	move.l	d6,s_d6
	movec	cacr,d6				; nettoyage du cache
	ori.w	#$0808,d6
	movec	d6,cacr
	move.l	s_d6,d6
	bra.s	.rty\@
.aaa\@
	dc.w	$f4d8
	; cinva	   bc

.rty\@
	endm


active_mouse	macro
****************************************
** routine qui va r‚activer la souris **
****************************************
	move.b	#8,$fffffc02.w
	endm
	
	
car	macro
******************************************
** Routine qui va afficher un caractere **
** avec le attribute                    **
******************************************
	move	ATTRIBUTE,(\2)
	or	#\1,(\2)+	
	endm
	
	
