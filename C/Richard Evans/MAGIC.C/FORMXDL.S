; form_xdial, replaces form_dial, and should be compatible with non 
; Magic TOS's. I cannot guarantee the reliability of this code so 
; please check it thoroughly before use.
; If there are errors, please correct them and send me a copy if possible
; Richard Evans 07/08/94  

		XREF 	__AESintin
		XREF	__AESaddrin
		XREF	__AESintout
		XREF	@_AESif
		XDEF	_form_xdial

		SECTION TEXT

_form_xdial	link      a6,#$0
       		movem.l   d4-d7/a5,-(a7)
       		move.l    $8(a6),d7
       		move.l    $c(a6),d6
       		move.l    $10(a6),d5
       		move.l    $14(a6),d4
       		move.l    d7,d0
       		move.w    d0,__AESintin(a4)
       		move.l    d6,d0
       		move.w    d0,__AESintin+$2(a4)
       		move.l    d5,d0
       		move.w    d0,__AESintin+$4(a4)
       		move.l    d4,d0
       		move.w    d0,__AESintin+$6(a4)
       		move.l    $18(a6),d0
       		move.w    d0,__AESintin+$8(a4)
       		move.l    $1c(a6),d0
       		move.w    d0,__AESintin+$a(a4)
       		move.l    $20(a6),d0
       		move.w    d0,__AESintin+$c(a4)
       		move.l    $24(a6),d0
       		move.w    d0,__AESintin+$e(a4)
       		move.l    $28(a6),d0
       		move.w    d0,__AESintin+$10(a4)
       		movea.l	  $2C(a6),a5
       		move.l	  a5,__AESaddrin(a4)
       		move.l	  #$0,__AESaddrin+$4(a4)
       		moveq     #$52,d0
       		add.l     d0,d0
       		jsr       @_AESif(pc)
       		movem.l   (a7)+,d4-d7/a5
       		unlk      a6
       		rts	
       	
       		END
