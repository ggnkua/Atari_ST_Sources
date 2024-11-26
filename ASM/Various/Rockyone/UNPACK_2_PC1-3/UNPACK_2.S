;								
; Source Unpack.s of Gt_Turbo 
;
; Modified by Rockyone for  uncompress PC1-3 only 320*200 640*200 640*400 
; 
; save palette, unpack data image, save color cycle if there are any	
:
; Source	address buffer image source
; Destination	address buffer 32066 bytes minimum
; File_size	file size to decompress
;
; return in d0	#-2 bad file
;		#0  if not color cycle.
;		#>0 if there is color cycle ( = number of byte in the image
;		       source before color cycles ) 
;		 	
;
;  In basic Omikron:  
;		call unpak_2( L source, L destination, file_size )	
;		if Lpeek(reserved(0))>-1 then
;		      color_cyle% = (Lpeek(reserved(0)))>0
;		endif
;
;--------------------------------------------------------------------------
; free d6 d7 a4		          
		movem.l d1-d7/a0-a6,-(sp) 
		movem.l	60(sp),a0-a1	; source and destination

		cmpi.b	#$80,(a0)
		bne	error		; bad file !

		move.w	(a0)+,(a1)
		clr.b	(a1)+		; clear compression byte 
		move.b	(a1)+,d1	; Image resolution

		moveq.l	#7,d0		
copy_color:	move.l	(a0)+,(a1)+	
		dbra.w	d0,copy_color	

		lea.l	32000(a1),a5	; End of the destination

depackt:	moveq.l	#3,d2		         
		lsr.b	d1,d2		; Number of plans -1
		move.b	d2,d3		         
		lsl.b	#1,d3		 
		moveq.l	#1,d4 		; Offset for next byte

All_lines: 	movea.l	a1,a3		; First plane of a line
		move.w	d2,d1		; Reset the number of plans
		lea.l	160(a3),a6	; End of a line

plans_line: 	movea.l	a3,a2 		 

Recup_code: 	moveq.l	#0,d0 
		move.b 	(a0)+,d0 
		bmi.s 	Repete_code 	; <

Copy_code:	move.b 	(a0)+,(a2) 
		adda.w	d4,a2           ; offest for next byte
		eor.b 	d3,d4 		;   7/1  3/1   1/1 
		dbra.w	d0,Copy_code 
		bra.s	End_line 

Repete_code: 	neg.b 	d0 		; +
		move.b	(a0)+,d5
Recopy_code:	move.b 	d5,(a2) 
		adda.w 	d4,a2 
		eor.b 	d3,d4 
		dbra.w 	d0,Recopy_code 

End_line: 	cmpa.l	a2,a6           ; End of a plane of a line ?
		bhi.s 	Recup_code 	; >

		addq.l	#2,a3		; next plan
		dbra.w 	d1,plans_line  

		movea.l	a6,a1		; next line
		cmpa.l	a1,a5		
		bhi.s	All_lines	
;................................copy color cycles.................

		move.l	a0,d0
		sub.l	60(sp),d0	; number of bytes read	

		move.w	68(sp),d1	; file size PC1-3
		ext.l	d1		; Word > 32767  it's negative 
		andi.l	#$ffff,d1	

		sub.l	d0,d1		; number of remaining bytes
		beq.s	end_degas	; 0 = eof file, not color cycle 
		cmpi.l	#32,d1		; Color Cycle ?
		beq.s	copy_cycle
		bra.s	error

copy_cycle:	move.b	(a0)+,(a5)+	; ( Even or odd adresse Source )
		subq.b	#1,d1
		bhi.s	copy_cycle

end_degas:	movem.l (sp)+,d1-d7/a0-a6 
		rts
error:		moveq.l	#-2,d0
		bra.s	end_degas 
		end


