; form_xerr. I cannot guarantee the reliability of this code so 
; please check it thoroughly before use.
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  
	
		XREF 	__AESintin
		XREF	__AESaddrin
		XREF	__AESintout
		XREF	@_AESif
		XDEF	_form_xerr
		
		SECTION TEXT

_form_xerr      movem.l	d6-d7/a5,-(a7)
		move.l	$10(a7),d7
		move.l	$14(a7),d6
		movea.l	$18(a7),a5
		move.l	a5,__AESaddrin(a4)
		move.l	d7,d0
		move.w	d0,__AESintin(a4)
		move.l	d6,d0
		move.w	d0,__AESintin+$2(a4)
		move.l	#$01f8,d0
		jsr	@_AESif(pc)
		movem.l	(a7)+,d6-d7/a5
		rts
		
		END