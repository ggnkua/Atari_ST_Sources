;Signum! image decompressoion code for PureC
;code taken from Imagic demo -> denisdem.prg
;size of unpacked data is always 32000 bytes (st high resolution)
;dis-assembled and modified by Lonny Pursell
;-------------------------------------------------------------------------------------
;rockyone		Adapted for MI-3 and Mi-9		14.08.2019
;
;
;			Unpack Signum2's ".IMC" file 
;			      IMC in PI3
;
;
; buf_pic	32046 bytes	Whatever the size of the IMC file
; buf_ecr	32034 bytes	For the image PI3
;
;			Call ( L buf_pic, L buf_ecr )
;			*****************************
;Return -2 in d0 if bad file
;
; +0 	L	Id file 			'bimc'
; +4	L	version ?			'0002'
; +8 	L	File size -8
; +12	W	Width of the image in pixels	640 pixel
; +14	W	Heiht of the image in pixels	200 pixel
; +16 	W	Alway				$28 = #40  Always 
; +18	W	Alway				$19 = #25  Always 
; +20	L	longueur du bloc de control
; +24	L	Offset adress data image compressed
; +28	W	Mask for "eor" with the words
; +30   ?	?
; +40	?	Address of control bytes  ? 
; +40+offset_adr	Address of data image compresed ?
;--------------------------------------------------------------------------
; d7 			Equal alays 80
; a0 a3			Buffer source
; a1 a2 -10(a4) -14(a4) Buffer destination 

	movem.l	d1-d7/a0-a6,-(sp)	
    	movem.l 60(sp),a0-a1	        ; buffers source and detination

;.......................................
	moveq.l	#-4,d0
	cmp.l	#'bimc',(a0)+		; Id file ?
	bne.s	error
	cmp.l	#'0002',(a0)+		; Version ? 
	bne.s	error
;........................................

	lea.l	2(a1),a2		; The destination buffer must be
	move.l	#32032/8-1,d5		; clean !
cls:	clr.l	(a2)+
	clr.l	(a2)+ 
	dbra.w	d5,cls
;........................................

	move.w	#2,(a1)+		; Write resolution
	move.l	#$fff0000,(a1)		; Write two colors

;........................................

	lea.l	32(a1),a2		; Start of the destination image
	moveq.l	#80,d7			; Offset for next line  

*	link	a4,#-46   
	lea.l	32046(a0),a4		; Buffer of work. 46 bytes
;					; To -46, 32 bytes for the data 
;					; convesion.

	move.l	#$190027,-4(a4)		:  -2(a4)=25,  -2(a4)=40
	move.l	a2,-10(a4)		; Backup for revers bits image.
	move.w	20(a0),-6(a4)		; Mask

	movea.l	12(a0),a5		; Offset for the address of ??
	lea.l	32(a0),a6
	adda.l	a6,a5	

	moveq.l	#8,d6
	moveq.l	#0,d5
;.......................................................d4 here only
		move.w	-4(a4),d4       	; 25		
		subq.l	#1,d4			; -1 for dbra

loop_0:		bsr.s	set_carry        	; 1    
		bcc.s	c_0          		; yes		
		bsr.s	L2AE82      
            
c_0:		add.l	#80*16,a2   		; +16 lines
		dbra.w	d4,loop_0		; 16 * 25 = 400  
;...................................................................

		tst.w	-6(a4)			; Masq > 0 ?
		bne	revers_bits		; yes

;------------------------------------------------------------------------------
_end:	moveq.l	#0,d0			; good file
*	unlk    a4
error:	movem.l (sp)+,d1-d7/a0-a6
	rts
;--------------------------------------------------------------------------

next_line:
L2AE82:		move.l	a2,-14(a4)
		move.w	-2(a4),d3      	; #39
loop_1:		bsr.s	set_carry
		bcc.s	c_01
		bsr.s	L2AEA8

c_01:		addq.l	#2,-14(a4)	; next column of the destination
		dbra.w	d3,loop_1			
		rts

;......................................Set the CCR bit "Carry" ( bit 0 )
; d5-d6 only here
set_carry:	dbra.w	d5,loop_2 		; Only if d5 >-1
		moveq.l	#7,d5			; Reset d5
		move.b	(a6)+,d6		; Read contol byte
loop_2:		add.b	d6,d6          		; =1 si retenue … zero. 
		rts				;    ex: $ff+1	
;......................................
L2AF42:		move.b	(a5)+,d1
		beq.s	r_08

		moveq	#7,d0
loop_3:		add.b	d1,d1
		bcc.s	c_08

		move.b	(a5)+,(a0)
c_08:		addq.l	#2,a0
		dbra.w	d0,loop_3
r_08:		rts

;......................................d3
L2AEA8:		movem.l	d3/a3,-(sp)
		moveq	#0,d3
		bsr.s	set_carry
		bcc.s	c_02

		addq.w	#2,d3
c_02:		bsr.s	set_carry
		bcc.s	c_03

		addq.w	#1,d3
c_03:		cmpi.w	#3,d3
		beq.s	in_work			; rts here

		lea.l 	-46(a4),a0		; clear buffer of work
		clr.l	(a0)+   -46
		clr.l	(a0)+   -42
		clr.l	(a0)+   -38
		clr.l	(a0)+   -34
		clr.l	(a0)+   -30
		clr.l	(a0)+   -26
		clr.l	(a0)+   -22
		clr.l	(a0)+   -18

		lea.l 	-46(a4),a3
		bsr.s	set_carry
		bcc.s	c_04

		movea.l	a3,a0
		bsr.s	L2AF42

c_04:		addq.l	#1,a3
		bsr.s	set_carry
		bcc.s	c_05

		movea.l	a3,a0
		bsr.s	L2AF42

c_05:		lea.l 	15(a3),a3
		bsr.s	set_carry
		bcc.s	c_06

		movea.l	a3,a0
		bsr.s	L2AF42

c_06:		addq.l	#1,a3
		bsr.s	set_carry	
		bcc.s	c_07		

		movea.l	a3,a0
		bsr.s	L2AF42
;.....................................
c_07:		cmpi.w	#1,d3
		beq.s	op_16_W			; rts here 

		cmpi.w	#2,d3
		beq.s	op_8_LW			; rts here 

		bra.s	out_work		; rts here

;......................................Operation with 16 words
op_16_W:	lea.l 	-46(a4),a0
		move.w	(a0)+,d0
		moveq	#14,d2
loop_4:		move.w	(a0),d1
		eor.w	d1,d0
		move.w	d0,(a0)+
		dbra.w	d2,loop_4

		bra.s	out_work		; rts here

;......................................Operation with 8 long words
op_8_LW:	lea.l 	-46(a4),a0
		move.l	(a0)+,d0
		moveq.l	#6,d2
loop_5:		move.l	(a0),d1
		eor.l	d1,d0
		move.l	d0,(a0)+
		dbra.w	d2,loop_5

		bra.s	out_work		; rst here

;......................................Copy 16 words in buffer of work
in_work:	lea.l 	-46(a4),a0
		moveq.l	#7,d0
loop_6:		move.b	(a5)+,(a0)+	
		move.b	(a5)+,(a0)+
		move.b	(a5)+,(a0)+
		move.b	(a5)+,(a0)+
		dbra.w	d0,loop_6

out_work:	lea.l 	-46(a4),a0       
		movea.l	-14(a4),a1       
		moveq.l	#3,d0 		  
;......................................Copy the 16 Working of destination
copy_Words:	move.w	(a0)+,(a1)      	  
		adda.l	d7,a1              	; Next line    
		move.w	(a0)+,(a1)
		adda.l	d7,a1
		move.w	(a0)+,(a1)
		adda.l	d7,a1
		move.w	(a0)+,(a1)
		adda.l	d7,a1
		dbra.w	d0,copy_Words

		movem.l	(a7)+,d3/a3
		rts

;--------------------------------------------------------------------------
;				reverse the bits
;..........................................................................
revers_bits:	movea.l	-10(a4),a3		; Start image destination
	    	moveq.l	#0,d0
	    	move.b	-6(a4),d0      		; Mask 
	    	bsr.s	revers			; Start line 0

	    	adda.w	d7,a3       		; skip a line
	    	moveq.l	#0,d0
	    	move.b	-5(a4),d0		; Mask
	    	bsr.s	revers			; Start line 1

	    	bra 	_end
;.....................................
revers:		movea.l	a3,a2
		move.w	d0,d1
		lsl.w	#8,d1			  
		or.w	d1,d0
		move.w	-4(a4),d1		;  25
		asl.w	#3,d1			;  200 line
		subq.l	#1,d1			; -1 for debra
d_1:		movea.l	a2,a1
		move.w	-2(a4),d2		; 39 
d_2:		eor.w	d0,(a1)+
		dbra.w	d2,d_2 		 	; 40 words
		lea.l	80(a1),a2		; skip a line
		dbra.w	d1,d_1        		
		rts

		end
;-------------------------------------------------------------------------




