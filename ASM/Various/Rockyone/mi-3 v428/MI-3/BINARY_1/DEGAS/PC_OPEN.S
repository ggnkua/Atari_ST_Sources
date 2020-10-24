;Rockyone			Pour MI-3 & MI-9		05/08/2017
;								18/12/2017
;add test file size						15.12.2019
;
;Source Gt_Turbo
;			OPEN	DEGAS 	 PC1-3  PI1-3
;			-----------------------------
;
; Destination	buffer 32034 octets
;
;				
;     		Call	Pc_open( L Source, L destination, file_size )
;		-----------------------------------------------------
;
; Return in low d0	-2 bad file
;			Or number of bytes read. Equal 
;			- equal to the file size
;			- or the offset of the color cycles
;			          
;-------------------------------------------------------------------------
; a0 source
; a1 destination
; free d6 d7 a6

		movem.l d1-d7/a0-a6,-(a7) 
		movem.l	60(sp),a0-a1
		move.w	68(sp),d1		; file size
		ext.l	d1
	
		moveq.l	#-2,d0			; code error bad file

		cmp.l	#34000,d1
		bgt.s	error			; >=

		movea.l	a0,a4			; copy address source

		move.b	(a0)+,d2		; compressed ?
		bne.s	next_test		 

		cmp.l	#32034,d1
		beq.s	end_test
		cmp.l	#32066,d1
		beq.s 	end_test

next_test:	cmpi.b	#$80,d2			; Compressed ?
		bne.s	error			; no !!

end_test:	moveq.l	#0,d1
		move.b	(a0)+,d1		; image resolution
		move.w	d1,(a1)+		; Copy resolution

		moveq.l	#7,d0
copy_pal:	move.l	(a0)+,(a1)+
		dbra.w	d0,copy_pal
;........
		lea.l	32000(a1),a5	
		tst.b	d2			; compressed ?
		bne.s	depackt 
;......................................Uncompressed file..................
	
copy:		move.l	(a0)+,(a1)+
		cmpa.l	a1,a5
		bhi.s	copy
;..........................................................................
end_prg:	suba.l	a4,a0		; Number of bytes read 
  		move.l	a0,d0		; end fille or offest cycles color
error:		movem.l (a7)+,d1-d7/a0-a6 
		rts 
;......................................Compressed file.....................
depackt:	moveq.l	#3,d2		         
		lsr.b	d1,d2		; 3 1 0  Nomber of plan-1
		move.b	d2,d3		         
		lsl.b	#1,d3		; 6 2 0  offset byte
		moveq.l	#1,d4 		;

All_lines: 	movea.l	a1,a3 		; First plane of a line
		move.w	d2,d1		; Reset number of plane
		lea.l	160(a3),a6	; End of a line

plans_line: 	movea.l	a3,a2 		; 

Recup_code: 	moveq.l	#0,d0 
		move.b 	(a0)+,d0 
		bmi.s 	Repete_code 	; <0

Copy_code:	move.b 	(a0)+,(a2) 
		adda.w	d4,a2 
		eor.b 	d3,d4 		; offset byte  7/1  3/1   1/1 
		dbra.w	d0,Copy_code 
		bra.s	End_line 

Repete_code: 	neg.b 	d0 		; +
		move.b	(a0)+,d5
Recopy_code:	move.b 	d5,(a2) 
		adda.w 	d4,a2 
		eor.b 	d3,d4 
		dbra.w 	d0,Recopy_code 

End_line: 	cmpa.l	a2,a6           ; End of a plane of a line ?
		bhi.s 	Recup_code 	; >0	

		addq.l	#2,a3		; Next plane of a ligne
		dbra.w 	d1,plans_line   

		movea.l	a6,a1		; point to next line
		cmpa.l	a1,a5
		bhi.s	All_lines	; >0
		bra.s	end_prg

		end
;*************************************************************************
