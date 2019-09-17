; appl_getinfo: I cannot guarantee the reliability of this code so 
; please check it thoroughly before use.
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  

		XREF 	__AESintin
		XREF	__AESintout
		XREF	@_AESif
		XDEF	_appl_getinfo
	
		SECTION TEXT
		 	
_appl_getinfo   link	a6,#$0
		movem.l d7/a5/a3,-(a7)
         	move.l  $8(a6),d7
         	movea.l $c(a6),a5
         	movea.l	$10(a6),a3
         	move.l  d7,d0
         	move.w  d0,__AESintin(a4)
         	move.l  #$1e0,d0
         	jsr     @_AESif(pc)
         	move.w	__AESintout+$2(a4),(a5)
         	move.w	__AESintout+$4(a4),(a3)
         	movea.l	$14(a6),a0
         	move.w	__AESintout+$6(a4),(a0)
         	movea.l	$18(a6),a0
         	move.w	__AESintout+$8(a4),(a0)
         	movem.l (a7)+,d7/a5/a3
         	unlk	a6
         	rts

			END
			