		.globl vdi

		.globl vpb
		
		.globl contrl
		.globl intin
		.globl ptsin
		.globl intout
		.globl ptsout
		.globl stuffptr
			
		
	.text
		
vdi:	move.l	#vpb,d1
	moveq.l	#$73,d0
	trap	#$2
	rts
	
		
; used to move intout[0] and intout[1] into a long.
stuffptr:
	move.l	(a0),(a1)
	rts
	
	
	.data
	
vpb:	.dc.l	contrl, intin, ptsin, intout, ptsout	

	.end		

		