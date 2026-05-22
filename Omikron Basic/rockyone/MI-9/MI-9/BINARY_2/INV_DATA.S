;rockyone			pour MI-3 et MI-9		22/04/2017
;
;
;			INVERSE VALEUR DATA HAUTE RESOLUTION
;		
;			call inv_data( L source, limit%)
;
;limit%  partie de l'‚cran non recouvert par le menu
; pour MI-3, le menu est d‚sactiv‚ limit% = 32000
;-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	64(sp),a0
		move.w	68(sp),d0

		movea.l	a0,a1
		lea.l	32000(a0),a2
		
loop:		eori.l	#$ffffffff,(a1)+
		cmpa.l	a1,a2
		bhi.s	loop

		move.l	$44e,a1			; adresse ‚cran
		lea.l	0(a1,d0.w),a2

on_screen:	move.l	(a0)+,(a1)+
		cmpa.l	a1,a2
		bhi.s	on_screen
;........................................................................
	
end_prg:	movem.l (sp)+,d0-d7/a0-a6
		rts

		end

;-------------------------------------------------------------------------



