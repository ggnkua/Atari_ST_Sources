;-------------------------------------------------------------------------
;      " DEGAS Elite Packer by Nucleus/HMD for Synthetic Arts III! "
;(PC1 only)
; compactage par comparaison sur 3 octets
;-------------------------------------------------------------------------
; Modifi‚ pour sauvegarde PC1-3
;
; Rockyone			pour MI-3 & Mi-9		05/09/2017
; modified							05.04.2018
;								23.05.2021
;
; SOURCE	Buffer image format degas
; BUT		Buffer 34160 octets ( 160 octets pour la conversion )
; PACK		$0 pas de compression   PI1-3
;		$1 pour compress‚	PC1-3
; CYCLE	      	$0 ne sauvegarde pas les cycle de couleurs
;		$1 sauvegarde les cycle de couleurs. 
:
;               	60        64     68       70  
;	Call Pc_save( L source, L but, W pack%, W cycle% )
;
; Retour dans low  D0  la taille du fichier
;-------------------------------------------------------------------------
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1		;address source/destination
		move.w	68(sp),d0		; compresion ?
		lsl.b	#7,d0			; =$0 or $80
		move.b	d0,(a1)+	
		addq.l	#1,a0	
		move.b	(a0),(a1)+	
		move.b	(a0)+,rezol

		moveq.l	#7,d1
copy_color:	move.l	(a0)+,(a1)+
		dbf.w	d1,copy_color

		tst.b	d0
		bne.s	pack_degas
;-----------------------------------------------SAVE PI1-3-----------------
		move.w	#7999,d1
copy_pic:	move.l	(a0)+,(a1)+
		dbra.w	d1,copy_pic
;--------------------------------------------------------------------------
color_cycle:	tst.w	70(sp)			; save cycle ?
		beq.s	not_cycle
		moveq.l	#31,d1
copy_cycle:	move.b	(a0)+,(a1)+		; A1 adresse pair ou impair
		dbf.w	d1,copy_cycle		

not_cycle:	move.l	a1,d0			
		sub.l	64(sp),d0		; file size
		movem.l	(sp)+,d1-d7/a0-a6	
		rts		
param:		dc.w	3,19,40,8,200,160	
		dc.w	1,39,80,4,200,160	
		dc.w	0,0,80,2,400,80
	even
rezol:		dc.b	0
;-----------------------------------------------SAVE PC1-3-----------------
;a0 a4 	source
;a1	destination
;a2 a3  buffer 160 bytes for convert line 

;a6	param
; d2 d7 nb_plan
; d3 d1 nb word par ligne
; d4 nb byte par ligne
; d5 nb octets entre de word d'un plan d'image
; d6 nb line par image

pack_degas:	movea.l	a1,a2	
		adda.l	#33966,a2		; =a1+34000
		moveq.l	#0,d1
		move.b	rezol,d1
		mulu.w	#12,d1
		lea.l	param(pc,d1),a6
*		adda.w	d1,a6	
		movem.w	(a6)+,d2-d6	; (a6) offset for the next line		

ConvertLine:	subq.w	#1,d6			; lignes -1
		bmi.s	color_cycle

		cmpi.b	#2,rezol		; High resolution ?
		bne.s	not_hight		; no
		movea.l	a0,a2
		bra.s	not_tri		
;.......................................low and medium resolution only....	
not_hight	movea.l	a0,a4
		movea.l	a2,a3			; start buffer 160 octet
		move.w	d2,d7			;  3  1   plans 
tri_plane:	move.w	d3,d1			; 19 39   words
tri_byte:	move.w	(a4),(a3)+
		adda.l	d5,a4			;  8  4	  offset word
		dbra.w	d1,tri_byte
		lea.l	-158(a4),a4 		; next plan 
		dbra.w	d7,tri_plane
;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

not_tri:	movea.l	a2,a3		 	; start firts plan  
		lea.l	0(a2,d4.w),a4		; end first plan
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
; d1 L/B	some de cmt / octet lu
; d4 		offset line
; d7 		number of plan per ligne 
;................................................

NextLine:	subq.b	#1,d7		; plan ligne -1
		bmi.s	ConvertLine	; go to next line
		adda.w	d4,a4		; fin d'un plan de ligne

NewCode:	move.l	a3,a5		; Start adr
		move.b	(a3)+,d0
		cmp.l	a3,a4
		beq.s	CodeCOPY

Same_code:	cmp.b	(a3)+,d0
		bne.s	not_same
		cmp.l	a3,a4
		bne.s	Same_code
		bra.s	save_repeat
	
not_same:	move.l	a3,d1
		sub.l	a5,d1
		cmpi.w	#2,d1		; comparaison sur 3 bytes
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

Same2:		cmp.l	a3,a4
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

		cmp.l	a3,a4
		bne.s	NewCode
		bra.s	NextLine

CodeREPEAT1:	subq.l	#1,a3
save_repeat:	move.l	a3,d1
		sub.l	a5,d1
		subq.w	#1,d1			; Nb pattern-1
		neg.b	d1
		move.b	d1,(a1)+		; nb repeat
		move.b	d0,(a1)+		; pattern
		cmp.l	a3,a4
		bne.s	NewCode
		bra.s	NextLine
;--------------------------------------------------------------------------
* d2	  3   1  0     plan
* d3	 19  39  0     word par plan
* d4	 40  80  80    octet par plan
* d5	  8   4   2    offset word
* d6	200 200 400    nombre de ligne
*(a6)   160 160  80    offset line
*	even	
*param:		dc.w	3,19,40,8,200,160	
*		dc.w	1,39,80,4,200,160	
*		dc.w	0,0,80,2,400,80
*	even
*resol:		dc.b	0

		end
;************************************************************************