;								
; Source Unpack.s of Gt_Turbo 
; Modified by Rockyone
; 
;			
;
; Unpacks PC1-3 only 320*200 640*200 640*400 
;			
;a0 buffer degas
;a1 destination
;
; free d6 d7 a4		          

		movem.l d0-d7/a0-a6,-(sp) 
		movem.l	64(sp),a0-a1
		move.b	1(a0),d1	    ; Image resolution
		lea.l	34(a0),a0

		lea.l	32000(a1),a5	; End of the destination

depackt:	
        moveq.l	#3,d2		         
		lsr.b	d1,d2		    ; Number of plans -1
		move.b	d2,d3		         
		lsl.b	#1,d3		 
		moveq.l	#1,d4 		    ; Offset for next byte

All_lines: 	
        movea.l	a1,a3 	        ; First plane of a line
		move.w	d2,d1		    ; Reset the number of plans
		lea.l	160(a3),a6	    ; End of a line

plans_line: 	
        movea.l	a3,a2 		 

Recup_code: 	
        moveq.l	#0,d0 
		move.b 	(a0)+,d0 
		bmi.s 	Repete_code 	; <

Copy_code:	
        move.b 	(a0)+,(a2) 
		adda.w	d4,a2           ; offest for next byte
		eor.b 	d3,d4 		    ;   7/1  3/1   1/1 
		dbra.w	d0,Copy_code 
		bra.s	End_line 

Repete_code: 	
        neg.b 	d0 		        ; +
		move.b	(a0)+,d5
Recopy_code:	
        move.b 	d5,(a2) 
		adda.w 	d4,a2 
		eor.b 	d3,d4 
		dbra.w 	d0,Recopy_code 

End_line: 	
        cmpa.l	a2,a6           ; End of a pane of a line ?
		bhi.s 	Recup_code 	    ; >

		addq.l	#2,a3		    ; next plan
		dbra.w 	d1,plans_line  

		movea.l	a6,a1		    ; next line
		cmpa.l	a1,a5		
		bhi.s	All_lines	

		movem.l (sp)+,d0-d7/a0-a6 
		rts 
		end
