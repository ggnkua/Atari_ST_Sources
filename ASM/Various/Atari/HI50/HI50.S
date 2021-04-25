
*  Make hi rez screen bios handle 50 lines of 8x8 characters
*
*	
* author:
*		j d eisenstein
*
* date:
*		15-aug-85
*

LINEA_INIT	equ	$A000
GET_REZ		equ	4		; extended bios resolution inquiry


hi50:

	lea	stack,sp	

	move.w	#GET_REZ,-(sp)		; get screen resolution
	trap	#14
	addq.w	#2,sp

	cmp.w	#2,d0			; only execute if already in hi rez
	bne	exit


	dc.w	LINEA_INIT		; get the important pointers

	move.l	04(a1),a1		; a1 -> 8x8 font header

	move.l	72(a1),-$0A(a0)		; v_off_ad <- 8x8 offset table addr
	move.l	76(a1),-$16(a0)		; v_fnt_ad <- 8x8 font data addr

	move.w	#008,-$2E(a0)		; v_cel_ht <- 8    8x8 cell height
	move.w	#049,-$2A(a0)		; v_cel_my <- 49   maximum cell "Y"
	move.w	#640,-$28(a0)		; v_cel_wr <- 640  offset to cell Y+1

exit:
	clr.w	-(sp)			; back to the os
	trap	#1


	ds.l	$10
stack:	ds.l	$01			; stack em up an blow em out

	end


