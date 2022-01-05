
save_binary::
******************************************************
** routine qui va sauver un fichier contenu dans a1 **
** commencant a l'adresse a0 sur une taille ds d1   **
******************************************************

	move.w	#$2300,sr

	movem.l	d0-d3/a0-a3,-(sp)
	bsr	flush_k_sys	
	movem.l	(sp)+,d0-d3/a0-a3

	move.l	a1,a5
	move.l	a0,a6			; adr de debut
	move.l	d1,d7			; nb d'octects
	


	move.w	#0,-(sp)		; on tente une ouverture
	pea	(a1)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			; handle dans d0
	bmi	.no_exist
	
	move.w	d0,-(sp)		; ouverture ok
	move.w	#$3e,-(sp)		; le fichier existe deja
	trap	#1			; on va demander si on veut ecraser
	addq.l	#4,sp
	
	
	; ici on va demander si on veut ou non ecraser le ficheir deja existant.
	
	
	move	#$2700,sr
	
	move.l	#MES_EXIST,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	
	sf	tempo1
	sf	tempo
	
	bsr.l	get_key
	
	cmp.b	#$15,d0
	beq.s	.no_exist
	cmp.b	#$18,d0
	beq.s	.no_exist
	
	bra	.error_exist
	
	
.no_exist
	move	#$2300,sr
	
	movem.l	d0-d3/a0-a3,-(sp)
	bsr	flush_k_sys	
	movem.l	(sp)+,d0-d3/a0-a3
	
	
	move.w	#0,-(sp)		; attribut
	pea	(a1)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			; handle dans d0
	bmi	.error
	move.l	d0,d6
	
	move.l	#MES_WRITING,MESSAGE_ADR
	bsr.l	PETIT_MESSAGE
	
	
	;illegal
	
	
	pea	(a6)
	move.l	d7,-(sp)
	move.w	d6,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0			; handle dans d0
	bmi	.error
	
	
	
	move.w	d6,-(sp)		; le fclose
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
	
	
	move.l	#MES_OK,MESSAGE_ADR
	
	bsr	flush_k_sys	
	move.w	#$2700,sr

	sf	tempo1
	sf	tempo
	
	rts
	
	
.error
	move.l	#MES_ERR_WRIT,MESSAGE_ADR
	move.w	#$2700,sr
	
	sf	tempo1
	sf	tempo
	
	rts

.error_exist
	move.l	#MES_SPACE,MESSAGE_ADR
	move.w	#$2700,sr
	sf	tempo1
	sf	tempo
	
	
	rts
