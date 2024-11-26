;-------------------------------------------------------------------------
;      " DEGAS Elite Packer by Nucleus/HMD for Synthetic Arts III! "
;(PC1 only)
; compactage par comparaison sur 3 octets
;-------------------------------------------------------------------------
; Modified by Rockyone to save  PC1, PC2, PC3			05.09.2017
;
;
; SOURCE	Address buffer image format degas uncompressed 32034 or
;		 32066 bytes
; BUT		Addres buffer 34160 bytes. ( 160 bytes for conversion )
;
; CYCLE	      	$0 do not save color cylces
;		$1 save colors cycles
:
;               		60        64      70  
;		Call Pc_save( L source, L but,  W cycle% )
;
; Return file size in low d0  
;
;Caution : The weight of the compressed file may be greater than that of
;the uncompressed file !
;-------------------------------------------------------------------------
;used d0-d7/a0-a6
;
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1		;address source/destination

		move.b	#$80,(a1)+		; flag compression
		addq.l	#1,a0	
		move.b	(a0),(a1)+		; resolution
		move.b	(a0)+,resol

		moveq.l	#7,d1			; 16 colors
copy_color:	move.l	(a0)+,(a1)+
		dbf.w	d1,copy_color


; a0 a4 	source
; a1		destination
; a2 a3  	buffer of 160 bytes to convert a line 
; a6		param
; d2 d7 	number of plans			  	 4   2    1
; d3 d1 	number of word per line		 	20  40   40
; d4 	 	number of bytes per ligne		160 160  80
; d5 	 	offset between two words in a plane	  8   4   2  
; d6 	 	numer of lines per image		200 200 400

pack_degas:	movea.l	a1,a2	
		adda.l	#33966,a2		; =a1+34000
		moveq.l	#0,d1
		move.b	resol,d1
		mulu.w	#12,d1
		lea.l	param(pc),a6
		adda.w	d1,a6	
		movem.w	(a6)+,d2-d6	; (a6)= offset for the next line		

ConvertLine:	subq.w	#1,d6			; lines -1
		bmi	color_cycle		; end of the image source ?

		cmpi.b	#2,resol		; High resolution ?
		bne.s	not_hight		; no

		movea.l	a0,a2
		bra.s	not_tri		
;.......................................low and medium resolution only....	
not_hight	movea.l	a0,a4
		movea.l	a2,a3			; start buffer 160 octet
		move.w	d2,d7			; number plan-1
tri_plane:	move.w	d3,d1			; number words-1
tri_byte:	move.w	(a4),(a3)+
		adda.l	d5,a4			;  8 or 4   offset word
		dbra.w	d1,tri_byte

		lea.l	-158(a4),a4 		; next plan 
		dbra.w	d7,tri_plane
;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

not_tri:	movea.l	a2,a3		 	; start first plan / line 
		lea.l	0(a2,d4.w),a4		; end first plan / line
		adda.w	(a6),a0			; next line
		move.w	d2,d7
		bra.s	NewCode

; A1 		destination
; A2		convert line
; A3 		Start plans in buffer a2
; A4 		end of a plan in  buffer  a2
; A5 		copy a3 for calculate byte of control
;
; d0 B		number bytes per plan of a line
; d1 L/B	some de cmt / bytes read
; d4 		offset line
; d7 		number of plan per ligne 
;................................................

NextLine:	subq.b	#1,d7			; plan ligne -1
		bmi.s	ConvertLine		; go to next line

		adda.w	d4,a4			; end of a line plan
NewCode:	move.l	a3,a5			; Start adr
		move.b	(a3)+,d0
		cmp.l	a3,a4			; end of a line plan ?
		beq.s	CodeCOPY

Same_code:	cmp.b	(a3)+,d0
		bne.s	not_same

		cmp.l	a3,a4			; end of a line plan ?
		bne.s	Same_code

		bra.s	save_repeat
	
not_same:	move.l	a3,d1
		sub.l	a5,d1
		cmpi.w	#2,d1			; comparaison sur 3 bytes
		bne.s	CodeREPEAT1

		cmp.l	a3,a4
		beq.s	CodeCOPY

		move.b	-1(a3),d0
NotSameLoop:	move.b	(a3)+,d1
		cmp.b	d0,d1
		beq.s	Same2

		move.b	d1,d0
		cmp.l	a3,a4
		bne.s	NotSameLoop

CodeCOPY_1:	bra.s	CodeCOPY

Same2:		cmp.l	a3,a4			; end of a line plan ?
		beq.s	CodeCOPY

		cmp.b	(a3),d0
		bne.s	NotSameLoop

		subq.l	#2,a3
CodeCOPY:	move.l	a3,d1
		sub.l	a5,d1
		subq.w	#1,d1
		move.b	d1,(a1)+
copy:		move.b	(a5)+,(a1)+
		dbf.w	d1,copy

		cmp.l	a3,a4			; end of a line plan ?
		bne.s	NewCode
		bra.s	NextLine

CodeREPEAT1:	subq.l	#1,a3
save_repeat:	move.l	a3,d1
		sub.l	a5,d1
		subq.w	#1,d1			; pattern-1
		neg.b	d1
		move.b	d1,(a1)+		; repeat
		move.b	d0,(a1)+		; pattern

		cmp.l	a3,a4			; end of a line plan ?
		bne.s	NewCode
		bra.s	NextLine
;--------------------------------------------------------------------------
color_cycle:	tst.w	68(sp)			; save cycle ?
		beq.s	not_cycle

		moveq.l	#31,d1
copy_cycle:	move.b	(a0)+,(a1)+		; A1 odd or even address
		dbf.w	d1,copy_cycle		

not_cycle:	move.l	a1,d0			
		sub.l	64(sp),d0		; returns file size in d0
		movem.l	(sp)+,d1-d7/a0-a6	
		rts		
;--------------------------------------------------------------------------
* d2	  3   1   0     plan-1
* d3	 19  39   0     word-1
* d4	 40  80  80	bytes
* d5	  8   4   2     offset word
* d6	200 200 400     number of line
*(a6)   160 160  80     offset line
	even	
param:		dc.w	3,19,40,8,200,160	
		dc.w	1,39,80,4,200,160	
		dc.w	0,0,80,2,400,80
resol:		dc.b	0

		end
;************************************************************************