
	globl	vqt_devinfo, _VDIParBlk, _vdi
	globl	vst_arbpt, vst_arbpt32
	
VDI_blk equ _VDIParBlk

	data
VDI_pb:
	dc.l	VDI_blk
	dc.l	VDI_blk+30
	dc.l	VDI_blk+574
	dc.l	VDI_blk+294
	dc.l	VDI_blk+864

	text

module _vdi
	lea 	_VDIParBlk.l,a0
	move	d0,12(a0)				; handle
	move	d1,(a0)+
	move	d2,4(a0)
	swap	d2
	move	d2,(a0)
	moveq	#115,d0
	move.l	#VDI_pb,d1
	pea	(a2)
	trap	#2		; VDI/AES
	movea.l	(a7)+,a2
	lea 	_VDIParBlk+294.l,a0
	move	(a0)+,d0
	rts
endmod

module vqt_devinfo

	pea	(a1)						; devstr
	pea	(a0)						; devexists
	move	d1,VDI_blk+30.l			; devnum
	move	#248,d1
	moveq	#1,d2
	bsr 	_vdi
	movea.l	(a7)+,a1
	ext.l	d1
	move	568(a0),(a1)
	bne.s	L7186
	addq	#4,a7
	rts

L7186:
	movea.l	(a7)+,a1
	move	-288(a0),d1
	ext.l	d1
	subq.l	#2,a0
	bra.s	L7200

L7196:
	move	(a0)+,d2
	move.b	d2,(a1)+
L7200:
*	dbf	d1,L7196
	subq.l	#1,d1
	cmp.l 	#-1,d1
	bne 	L7196
	rts
endmod

module vst_arbpt

	pea	(a1)
	pea	(a0)
	move	d1,VDI_blk+30.l
	move	#246,d1
	moveq	#1,d2
	bsr 	_vdi
	lea 	568(a0),a0
	movea.l	(a7)+,a1
	move	(a0)+,(a1)
	movea.l	(a7)+,a1
	move	(a0)+,(a1)
	movea.l	4(a7),a1
	move	(a0)+,(a1)
	movea.l	8(a7),a1
	move	(a0),(a1)
	rts
endmod

module vst_arbpt32

	pea	(a1)
	pea	(a0)
	move.l	d1,VDI_blk+30.l
	move	#246,d1
	moveq	#2,d2
	bsr 	_vdi
	subq.l	#2,a0
	move.l	(a0),d0
	lea 	570(a0),a0
	movea.l	(a7)+,a1
	move	(a0)+,(a1)
	movea.l	(a7)+,a1
	move	(a0)+,(a1)
	movea.l	4(a7),a1
	move	(a0)+,(a1)
	movea.l	8(a7),a1
	move	(a0),(a1)
	rts
endmod
