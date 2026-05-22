;Rockyone			pour MI-3 et MI-9		 8/06/2016
;								18/02/2017
;								21.06.2018
;
;		OPEN SAVE SYNTHETIC ART v1	SRT	moyenne resolution
;		---------------------------
;Op%	0 open	
;	1  save
;
;     	 	open	Call Srt_Open( L Source, L destination, Op% )
;     	 	save	Call Srt_Open( L destination, L source, Op% )
;
;return	low d0 		-2 erreur header
;	
;-------------------------------------------------------------------------
		movem.l d1-d7/a0-a6,-(a7) 
		movem.l	60(sp),a0-a1
		move.w	68(sp),d3
		beq.s	open_srt

;.......................................SAVE..................
		exg.l	a0,a1
		
		lea.l	2(a0),a2
		lea.l	34(a0),a0

		bsr.s	copy_image
		move.l	#'JHSy',(a1)+		; write id SRT
		move.w	#1,(a1)+		; write resol image
		bsr.s	copy_palette

		move.l	#32038,d0		;R. file size
		bra.s	end_prg

;........................................OPEN..................
open_srt:	lea.l	32000(a0),a2

		moveq.l	#-2,d0			;R. flag erreur header
		cmp.l	#'JHSy',(a2)+		;
		bne.s	end_prg			;
	
		move.w	(a2)+,(a1)+		; copie byte resol

		bsr.s	copy_palette
		bsr.s 	copy_image
		moveq.l	#0,d0

;-------------------------------------------------------------------------
end_prg:	movem.l (a7)+,d1-d7/a0-a6 
		rts 
;-------------------------------------------------------------------------
copy_palette:	moveq.l	#7,d1			; 16 couleurs
color:		move.l	(a2)+,(a1)+
		dbra.w	d1,color
		rts

copy_image:	move.w	#7999,d1		; copie image
image:		move.l	(a0)+,(a1)+
		dbra.w	d1,image
		rts

		end
;*************************************************************************