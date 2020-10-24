;rockyone			for MI-3 / MI-9		 	 07/08/2017
;								 01.04.2019
;			Public Painter Monochrome v1.1 CMP
;
;	Source	: buffer image format PI3
;	But 	: buffer 32034
; 	op	: 0 for open, 1 for save
;
;			call cmp_open (L source, L but, op) 
;
; Image without color palette 
;+0	B	?	byte of control
;+1	B		$0  = image 640*400
;			$c8 = A4    640*800
;			$60 = A5    640*400
;+2	B	?	data image
;
;
; Image with palette of 16 colors
;+0	B	?	byte of control
;+1	W	$22	flag for color palette
;+2 	B	$0
;+3	B	? 	0 tO 2  resolution before conversion to hight res
;+4	B	?	data palette and image
;
;     -----   OR ------
;
;+0	B	?	byte of control
;+1	W	$22	flag of the color palette
;+2 	B	?	egal to byte de control        
;+4	B	$3	repeat next byte x time -2 
;+5	B       ?       byte to repeat - first data of the palette  -
; the rest is normal
;
;
;-------------------------------------------------------------------------
;utilis‚; d0-d3, a0-a2

	        movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		lea.l	32034(a1),a2

		tst.w	68(sp)		; open or save ?
		bne.s	save_cmp

;	*********************************************************
;	*			OPEN CMP			*
;	*							*
;	*	THE IMAGES 640*800, WILL BE HALF LOADED !       *
;	*	a0  buffer image PI3				*
;	*	a1  buffer destination	- 32034 byte -		*
;	*	call ( l source, l destination, 0 )		*
;	*							*
;	*********************************************************
; I did not find a control byte greter than $78 in the images created by
;Public Painter v0.1, but the value of $FE is accept.
; 

		move.w	#2,(a1)+	; byte resol.
		move.b	(a0)+,d3	; control byte

*		moveq.l	#-4,d0		;R. image trop grande
		cmpi.b	#$22,(a0)+	
*		bgt.s	end_prg		; > $60 $c8 
		bmi.s	no_pal		; < $0
;.......................................
		cmp.b	(a0),d3    
		beq.s	recal    
  
		addq.l	#2,a0
		bra.s	depack

recal:		subq.b	#2,1(a0)
		bra.s	depack

;........................................
no_pal:		move.l	#$FFF0000,(a1)	; creat two colors
		adda.w	#32,a1

depack:		moveq.l	#0,d0		;R. not error

recup_code:	cmp.b	(a0),d3		; control byte ?
		bne.s	literaly	; <>

repeat_code:	addq.l	#1,a0
		moveq.l	#0,d1
		move.b	(a0)+,d1
		move.b	(a0)+,d2
recopy:		move.b	d2,(a1)+
		dbra.w	d1,recopy
		bra.s	end_pic

literaly: 	move.b	(a0)+,(a1)+	

end_pic:	cmpa.l	a1,a2		; end pic ?	
		bhi.s	recup_code	; >0

end_prg:  	movem.l	(sp)+,d1-d7/a0-a6
		rts

;	*********************************************************
;	*			SAVE CMP			*
;	*							*
; 	*	a0= but	    32034 bytes 			*
; 	*	a1= Source image format PI3			*
;	*							*
;	*	call cmp_os( L but, L source,1 )		*
;	* 	Return file size in d0				*
;	*							*
;	*********************************************************				
; used d0-d2/a0-a3
;-----------------
file_size:	suba.l	a3,a0
		move.l	a0,d0		; file size to back up
		bra.s	end_prg

save_cmp:	movea.l	a0,a3		; for the  file size

; 		COUNT AND SORT THE IDENTICAL DATA  - 0 to 255 -
;		-----------------------------------------------
		addq.l	#2,a1
loop:		moveq.l	#0,d1
		move.b	(a1)+,d1
		lsl.w	#1,d1			;  to ave an even address
		addq.w	#1,0(a0,d1.w)
		cmpa.l	a1,a2
		bhi.s	loop

; 		SEARCH THE LAST USED BYTE
;		------------------------
		adda.w	#510,a0
		moveq.l	#0,d0
		move.l	#32000,d1
		move.l	#255,d2		; loop counter 
find:		cmp.w	(a0),d1		; Search for the least used value
		bmi.s	next_byte	; <
		move.w	d2,d0		; control byte
		move.w	(a0),d1
		beq.s	found
next_byte:	subq.l	#2,a0
		dbra.w	d2,find
found:	


; 		COMPRESSION 
;		-----------
;d0= ctrl
		movem.l	60(sp),a0-a1
		addq.l	#2,a1

		move.b	d0,(a0)+	; ctrl byte
		move.b	#$22,(a0)+	; flag palette
		move.w	#02,(a0)+	; resolution

tst_eof:	cmpa.l	a1,a2		; eof source ?
		beq.s	file_size

		moveq.l	#0,d1		; reset counter
		move.b	(a1)+,d2	; read byte
		cmp.b	(a1),d2
		beq.s	same_bytes
	
		cmp.b	d0,d2		; equal ctrl byte ?
		bne.s	save_one_byte	; no

save:		move.b	d0,(a0)+	; ctrl
		move.b	d1,(a0)+	; count
save_one_byte:	move.b	d2,(a0)+	; data
		bra.s	tst_eof

same_bytes:	addq.l	#1,a1
		addq.b	#1,d1		; count +1
		cmp.b	#127,d1		; max ?
		beq.s	save		; =

		cmpa.l	a1,a2		; end source ?
		beq.s	tst_count	; =
		
		cmp.b	(a1),d2		; equal byte ?
		beq.s	same_bytes	; =

tst_count:	cmp.b	#1,d1	
		bhi.s	save		; >=

;.......................................; save two identical byte	
		cmp.b	d0,d2		; equal ctrl byte ?
		bne.s	literal	
		move.b	d0,(a0)+	; ctrl
		move.b	d1,(a0)+	; count  - d1 = 0 - 
		move.b	d2,(a0)+	; data
		bra.s	tst_eof
literal:	move.b	d2,(a0)+	; It reduces the file, but it 
		move.b	d2,(a0)+	; slow down the decompression !!
		bra.s	tst_eof	
		end
****************************************************************************