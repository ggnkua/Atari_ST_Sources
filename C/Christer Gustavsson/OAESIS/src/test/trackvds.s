	XDEF link_in

	XREF h_vdi_call

	TEXT
	
myxgemdos:
	cmp.w		#$c8,d0
	beq		retaddr

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d1,a0
	jsr		h_vdi_call
	movem.l	(sp)+,d0-d7/a0-a6
	
retaddr:
	jmp		link_in;

link_in:
	move.l	$88,retaddr+2;
	move.l	#myxgemdos,$88
	rts;
