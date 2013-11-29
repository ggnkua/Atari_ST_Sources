		include	vdi.i
		XDEF	_INSTALL_LUT
		XREF	planes,nbr_color
		XREF	_TOS_DAC
		**********
_INSTALL_LUT
		link	a6,#0
		movem.l	d0-a5,-(sp)
		
		move.w	planes,d0	; nb de plans
		
		cmp	#1,d0
		beq.s	.mono
		cmp	#2,d0
		beq.s	.4_coul
		cmp	#4,d0
		beq.s	.16_coul
		bra	.Multicolor
.4_coul
		lea	_TAB_VTOH_4,a3
		lea	_TAB_HTOV_4,a4
		lea	_TOS_DAC,a2
		move.l	#$00ffffff,(a2)+
		move.l	#$00ff0000,(a2)+
		move.l	#$0000ff00,(a2)+
		move.l	#$00000000,(a2)
		bra.s	.Ok3DColors
.16_coul
		lea	_TAB_VTOH_16,a3
		lea	_TAB_HTOV_16,a4
		bra.s	.Ok3DColors
.mono
		lea	_TAB_VTOH_2,a3
		lea	_TAB_HTOV_2,a4
		lea	_TOS_DAC,a2
		move.l	#$00FFFFFF,(a2)+
		move.l	#$00000000,(a2)
		
		bra.s	.Ok3DColors
.Multicolor
		lea	_TAB_VTOH_256,a3
		lea	_TAB_HTOV_256,a4
.Ok3DColors
		**********
		
		lea	VDI_ORDER,a2
		moveq	#16,d0
.copvtoh		
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		subq	#1,d0
		bgt.s	.copvtoh
		
		lea	IDV_REDRO,a2
		moveq	#16,d0
.cophtov		
		move.l	(a4)+,(a2)+
		move.l	(a4)+,(a2)+
		move.l	(a4)+,(a2)+
		move.l	(a4)+,(a2)+
		subq	#1,d0
		bgt.s	.cophtov
		
		**********
		
		; installation de la palette (VDI)...
		; attention en true color il ne faut pas
		; regler 65536 couleurs !!
		
		move.w	nbr_color,d0
		cmp.w	#256,d0
		ble.s	.okcolnum
		move.w	#256,d0
.okcolnum
		lea	_TOS_DAC,a0
		*lea	intin,a1
		moveq	#0,d1
		moveq	#0,d5
.yocol		
		clr	d2
		move.b	1(a0),d2
		clr	d3
		move.b	2(a0),d3
		clr	d4
		move.b	3(a0),d4
		
		add	d2,d2
		add	d3,d3
		add	d4,d4
		add	d2,d2
		add	d3,d3
		add	d4,d4
		
;		move	#4,_V_CONTROL+_V_SINTIN
		
		move.b	(IDV_REDRO,d1.w),d5
;		move	d5,0*2(a1)
;		
;		move	d2,1*2(a1)
;		move	d3,2*2(a1)
;		move	d4,3*2(a1)
		
		movem.l	d0-d2/a0-a2,-(sp)
		vs_color	d5,d2,d3,d4
		movem.l	(sp)+,d0-d2/a0-a2
		
		addq	#4,a0
		addq	#1,d1
		subq	#1,d0
		bne.s	.yocol
		
		**********
.no_vdi_palette		
		movem.l	(sp)+,d0-a5
		unlk	a6
		rts
		
		**********
		bss
		****
VDI_ORDER:
		ds.b	256
IDV_REDRO:
		ds.b	256

		****
		
		; tables de conversion vdi>hard & hard>vdi
		data
_TAB_VTOH_2:
		dc.b	0,1
_TAB_HTOV_2:
		dc.b	0,1

_TAB_VTOH_4:	
		dc.b	0,3,1,2
_TAB_HTOV_4:	
		dc.b	0,2,3,1

_TAB_VTOH_16:	
		dc.b	0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
_TAB_HTOV_16:	
		dc.b	0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1

_TAB_VTOH_256:	
		dc.b	0,255,1,2,4,6,3,5,7,8,9,10,12,14,11,13
i		SET	16
		REPT	239
		DC.B	i
i		SET	i+1
		ENDR
		dc.b	15

_TAB_HTOV_256:	
		dc.b	0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255
i		SET	16
		REPT	239
		DC.B	i
i		SET	i+1
		ENDR
		dc.b	1

		****
