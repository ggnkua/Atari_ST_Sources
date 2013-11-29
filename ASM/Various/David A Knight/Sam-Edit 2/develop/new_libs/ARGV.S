	SECTION	text

argvDetection

	move.l	argvLocation,a0

	cmpi.b	#127,cliLength
	beq	checkForArgv
	
	rts
	
checkForArgv
	
	cmpi.l	#'ARGV',(a0)+
	cmp.b	#'=',(a0)+
	beq	foundARGV
.loop
	move.b	(a0)+,d0
	bne	.loop
	bra	checkForArgv

foundARGV
	move.b	(a0)+,d0
	bne	foundARGV
	
; a0 now points to the programs path and name

.loop
	move.b	(a0)+,d0
	bne	.loop
	
; a0 now points at the command line

	move.l	a0,cli
	
	rts