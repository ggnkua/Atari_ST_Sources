;
; APXconv
; 
; February 15, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; convert.s



		section	text

check_filetype:

		move.l	source_adr,a0		;hicolour
		cmp.l	#"Word",(a0)+			
		bne.s	.not_hicol
		cmp.l	#"PerP",(a0)+
		bne.s	.not_hicol
		cmp.l	#"ixel",(a0)
		bne.s	.not_hicol

		move.l	#hicol_text,d0
		bsr.w	cconws
		
		bsr.w	convert_hicol_to_targa
		bra.w	convert_done


.not_hicol:	move.l	source_adr,a0		;bitplane
		cmp.l	#"8Pla",(a0)+
		bne.s	.not_planes
		cmp.l	#"neMa",(a0)+
		bne.s	.not_planes
		cmp.l	#"sked",(a0)
		bne.s	.not_planes

		move.l	#planes_text,d0
		bsr.w	cconws
				
		bsr.w	convert_planes_to_iff
		bra.w	convert_done


.not_planes:	move.l	source_adr,a0		;chunky
		cmp.l	#"Byte",(a0)+
		bne.s	.unknown_filetype
		cmp.l	#"PerP",(a0)+
		bne.s	.unknown_filetype
		cmp.l	#"ixel",(a0)
		bne.s	.unknown_filetype

		move.l	#chunky_text,d0
		bsr.w	cconws

		bsr.w	convert_chunky_to_iff
		bra.w	convert_done


.unknown_filetype:
		move.l	#unknown_text,exit_text_adr
		bra.w	pterm		
		

convert_done:




		section	text