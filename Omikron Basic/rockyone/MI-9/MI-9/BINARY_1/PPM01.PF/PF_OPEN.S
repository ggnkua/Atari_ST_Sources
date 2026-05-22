;rockyone			pour MI-3  MI-9			 01/09/2017
;
;			PROFESSIONAL GRAPHICS v1.2  PF1-3
;
;Source	file.pf?
;But	format Degas 32034 octet
;	
;
;			call PF_OPEN( L Source, L But )
;
;
;
; resolution 0	|resolution 1	|resolution 2	|
; --------------|---------------|---------------|---------------
; +0	$0000 	|	$0001 	|	$0002	| resolution
; +2	$ffff	|	$ffff	|	$ffff	| alway
; +4	$0040	|	$0280	|	$0280	| width
; +6	$00c8	|	$00c8	|	$0190	| height
; +10	$0004	|	$0002	|	$0001	| number plane
; +12  	16 word	|	4 word	|	2 word	| palette color
;
; +42	$0009	| +18	$0000	| +14	$0000	| ?
; +44	$000C	| +20	$0001	| +16	$0001	| ?
; +46	$0000	| +26	$0001	| +20	$0001	| ?
; +48	$0000	| +26	$0000	| +20	$0000	| ?
; +50	$xxxx	| +28	$xxxx	| +22	$xxxx	| Length of image segment
; +52		| +30		| +24		| First commande
;
;Compression plan aprŠs plan
; "xx"  can overlap the plans !
; -----------------------------
;CMD	$00xx to $1Fxx	Copy (CMD andi.w #1FFF)  Word(s)    literaly
;
;	$20xx to $3Fxx  I have not found a matching code
;	$40xx to $5Fxx  "	"	"	"	"
;	$60xx to $7Fxx	"	"	"	"	"
;
;	$80xx to $9Fxx	 Repeat (CMD andi.w #1FFF) time the next word
;
;	$A000 to $BFFF 	 Repeat #$0000, (CMD andi.w #1fff) time
;
;	$C0xx to DFxx	 Next word =  number of time 
;			 Next word =  data to repeat
;
;	$E0xx to FFxx 	 Next word = nomber of time
;	 	  	 Repeat $0000
;-------------------------------------------------------------------------
;utilis‚: d0-d3/a0-a4

	        movem.l	d1-d7/a0-a6,-(SP)
		movem.l	60(sp),a0-a1
		movea.l	a0,a2
		lea.l	34(a1),a3	
		
		move.w	(a0)+,d1	; image resolution	
;.......................................
	
		moveq.l	#-2,d0
		cmpi.w	#$ffff,(a0)+	;tag: professionnal painter v1.2	
		bne.s	error

		mulu.w	#8,d1
		lea.l	param(pc),a4
		adda.w	d1,a4

		moveq.l	#2,d1
test:		cmpm.w	(a4)+,(a0)+	;largeur, hauteur, nb plane
		bne.s	error
		dbra.w	d1,test		

;...............................................DEPACK...................
		move.w	(a2),(a1)+		; 0(a0);resolution
		
		move.w	(a4),d1			; 7,1,0
color_palette:	move.l	(a0)+,(a1)+		; copy color
		dbra.w	d1,color_palette

		move.w	-2(a4),d1		; Number of plan
		move.w	d1,d2			; Ofset between two word of
		lsl.b	#1,d2			; a plane :  8,4,2

		addq.l	#8,a0			; point on +50, +28, +22

		move.w	(a0)+,d3		; Length of image segment.
		lea.l	0(a0,d3.w),a2		; End of the source image,
		subq.l	#1,a2			; <> or = eof file		
;						;------------------
;...............................................
; d0 alway 0 no error
; d1 B number plane -1
; d2 W ofset for next word
; d3 B cmd 
; d4 W size jump or word to repeat

		moveq.l	#0,d0
		subq.b	#1,d1

		movea.l	a3,a1		; start plan
		lea.l	32000(a3),a4	; end_plan
		moveq.l	#0,d3

recup_code:	cmpa.l	a0,a2		; end pic ? ( = or <> eof file )
		bls.s	end_prg		; <=

*		moveq.l	#0,d3
		move.w	(a0)+,d3

		cmpi.l	#$e000,d3	; e000 to ffff 
		bpl.s	w_jump		; >=			 

		cmpi.l	#$c000,d3	; c000 to dfff 
		bpl.s	w_copy
	
		cmpi.l	#$a000,d3	; a000 to bfff 
		bpl.s	b_jump

		cmpi.l	#$8000,d3	; 8000 to 9fff 
		bpl.s	b_copy

*		cmpi.l	#$6000,d3	; 6000 to 7Fff   
*		bpl.s	fin				  
*		cmpi.l	#$4000,d3	; 4000 to 5fff
*		bpl.s	fin
		cmpi.l	#$2000,d3	; 2000 to 3fff
		bmi.s	literaly
;
*fin:		moveq.l	d3,d0
;........................................................................
end_prg:        
error:		movem.l	(sp)+,d1-d7/a0-a6
		rts

;.........................................................................
literaly:	andi.w	#$1fff,d3
copy:		move.w	(a0)+,(a1)
		
		bsr.s	test_plan
		bmi.s	end_prg

		subq.w	#1,d3
		bgt.s	copy		; >0
;........................................

end_plane:	bsr.s	test_2		; End of a plane ?
		bmi.s	end_prg		; End of last plane !
		bra.s	recup_code
;........................................
	
test_plan:	adda.w	d2,a1		; + 8, 4, 2
test_2		cmpa.l	a1,a4
		bge.s	return		; >=0

		addq.l	#2,a3		; next plan
		movea.l	a3,a1
		addq.l	#2,a4
		subq.b	#1,d1		; end if negative
return:		rts

;........................................
w_jump:		move.w	(a0)+,d3	;e0  ff
		moveq.l	#0,d4
		bra.s	recopy

w_copy:		move.w	(a0)+,d3	;c0  df
		bra.s	repeat_data	

b_jump:		andi.w	#$1fff,d3	;a0  bf
		moveq.l	#0,d4
		bra.s	recopy

b_copy:		andi.w	#$1fff,d3	;80 9f

repeat_data:	move.w	(a0)+,d4
recopy:		move.w	d4,(a1)

		bsr.s	test_plan
		bmi.s	end_prg

		subq.l	#1,d3
		bgt.s	recopy		; >0
		bra.s	end_plane

;................................................
; 		largeur, hauteur, plan, number LW-1 for color palette
param:		dc.w	320,200,4,7	
		dc.w	640,200,2,1
		dc.w	640,400,1,0
		end	
;*************************************************************************
