*


	pea	musoff(pc)
	move.w	#$26,-(sp)
	trap	#14			; Supexec - stop music
	addq.w	#6,sp

	pea	$4C0000
	trap	#1			; Terminate


musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timers

	

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	move	#$2300,sr
	rts

oldtima	DC.L 0


