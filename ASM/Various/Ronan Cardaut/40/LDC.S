START
	*---------------------*
	* scan la chaine d'env
	* pour trouver __HISOFT__
	*---------------------*
	move.l	4(sp),a0
	move.l	$2c(a0),a0
	
.SCAN	cmp.l	#'__HI',(a0)
	beq.s	.FOUND
.TST	move.b	(a0)+,d0
	bne.S	.SCAN	
	tst.b	(a0)
	bne.S	.SCAN
.FIN
	rts		
	

	
.FOUND
	cmp.l	#'SOFT',4(a0)
	bne.s	.TST
	cmp	#'__',8(a0)
	bne.s	.TST
	
	add	#11,a0		;skippe la chaine

	*---------------------*
	* r‚cupere l'adresse de la structure
	* de Devpac
	*---------------------*

	moveq	#0,d0
	move	#8-1,d7
.CONV
	move.b	(a0)+,d1
	sub.b	#'0',d1
	cmp	#$9,d1
	ble.S	.OK
	sub.b	#'A'-'9'-1,d1		
.OK	and	#$f,d1
	lsl.l	#4,d0
	or	d1,d0
	dbra	d7,.CONV	
	
	move.l	d0,a0
	move.l	40(a0),a0		;a0=prg sur programme
	illegal	
			
	
