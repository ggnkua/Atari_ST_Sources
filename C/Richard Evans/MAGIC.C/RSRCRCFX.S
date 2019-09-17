; rsrc_rcfix. I cannot guarantee the reliability of this code so 
; please check it thoroughly before use.
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  

		XREF	__AESaddrin
		XREF	__AESintout
		XREF	@_AESif
		XDEF	_rsrc_rcfix
		
		SECTION TEXT

_rsrc_rcfix     movem.l	a5,-(a7)
		movea.l	$8(a7),a5
		move.l	a5,__AESaddrin(a4)
		move.l	#$01a4,d0
		jsr	@_AESif(pc)
		movem.l	(a7)+,a5
		rts
		
		END