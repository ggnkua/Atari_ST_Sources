;rockyone			pour MI-9			10/05/2017
;
;
;			CHAGAL 	"file.ESM"  height resolution
;				640*400	only
;
; OP% 0 open	return 	-1 bad resolution
;			-2 bad file
; OP% 1 save    return	File size
;	I reduced the size of the file header to 14 bytes. 
;	This does not disrupt Chagal.prg
;		
;			call Esm_os( L source, L but, W op%)
;-------------------------------------------------------------------------
; +0 		TMC
; +3		$0
; +4	w	?	size header 812
; +6	w	?	width image in pixel
; +8	w	?	heigth image in pixel
; +10	w	?	number of plan 
; +12	w	?	1 = monochrome, $8 = ?, $18 = ?
; +14 to 28 ?
; +28   w	?	with image in pixel
; +32	w	?	Heigth image in pixel
;'''''''''''''''''''''''''''''''''''''''''''
; modified format by Mi-3 or Mi-9
; +4	w	$E	size header reduced
; +14		?	image data uncompressed    
;--------------------------------------------------------------------------
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		tst.w	68(sp)
		beq.s	open_esm

save_esm:	exg.l	a0,a1
		move.l	#$544d5300,(a1)+	; tag chagall
		move.w	#$E,(a1)+		; size header
		move.l	#$02800190,(a1)+	; width and hight image
		move.l	#$00010001,(a1)+	; plan and  monochrome
		move.l	#32014,d0		;R. size file esm
		lea.l	34(a0),a0
		bra.s	copy_pic
;.........................................................................

open_esm:	moveq.l	#-2,d0			;R. bad file
		cmpi.l	#$544d5300,(a0)		; tag chagall
		bne.s	end_prg
		move.w	4(a0),d1		; size header
		cmpi.l	#$02800190,6(a0)        ; size pic 640*400
		bne.s	end_prg

		moveq.l	#0,d0			;R. no error
		adda.w	d1,a0			; jump the header
		move.w	#2,(a1)+		; r‚solution
		move.l	#$FFF0000,(a1)		; 2 colors
		lea.l	32(a1),a1

copy_pic:	move.w	#7999,d1
copy:		move.l	(a0)+,(a1)+
		dbra.w	d1,copy
;........................................................................
	
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

		end

;-------------------------------------------------------------------------



