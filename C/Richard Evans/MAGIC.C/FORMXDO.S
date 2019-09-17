; form_xdo, replaces form_do, and should be compatible with non 
; Magic TOS's. I cannot guarantee the reliability of this code so 
; please check it thoroughly before use.
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  

		XREF 	__AESintin
		XREF	__AESaddrin
		XREF	__AESintout
		XREF	@_AESif
		XDEF	_form_xdo
	
		SECTION TEXT
		 	
_form_xdo	link		a6,#$0
		movem.l   	d7/a5/a3-a2,-(a7)
         	movea.l   	$8(a6),a5
         	move.l    	$c(a6),d7
         	movea.l	  	$14(a6),a3
         	movea.l		$18(a6),a2
         	move.l    	a5,__AESaddrin(a4)
         	move.l		a3,__AESaddrin+$4(a4)
         	move.l		a2,__AESaddrin+$8(a4)
         	move.l		d7,d0
         	move.w    	d0,__AESintin(a4)
         	moveq     	#$50,d0
         	add.l     	d0,d0
         	jsr       	@_AESif(pc)
         	movea.l		$10(a6),a0
         	move.w		__AESintout+$2(a4),(a0)
         	movem.l   	(a7)+,d7/a5/a3-a2
         	unlk		a6
         	rts

		END
			