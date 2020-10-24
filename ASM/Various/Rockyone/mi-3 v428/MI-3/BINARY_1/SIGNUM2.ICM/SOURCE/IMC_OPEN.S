;rockyone							12.08.2019
;
;
;
;			Depack files of Signume 
;			    IMC to PI3
;
;
;Return -2 in d0 if bad file
;
; +0 	Lw	Id file 	'bimc'
; +4	Lw	version ?	$0002
; +8 	Lw	File size -8
; +12	W	Width of the image in pixels
; +14	W	Heiht of the image in pixels
; +16 	W	$28 = #40  Always ?
; +18	W	$19 = #25  Always ?
; +20	L	longueur du bloc de control
; +24	L	offset adress data image compressed
; +28	W	$ffff or $0000 .  or $xxxx ?   EOR with the words
; +30   ?	?
; +40	?D	address of control bytes
; + offset_adr	address of data image compresed
;--------------------------------------------------------------------------
; d7 			Equal alays 80
; a0 a3			Buffer source
; a1 a2 -10(a4) -14(a4) Buffer destination 

	movem.l	d1-d7/a0-a6,-(sp)	
    	movem.l 60(sp),a0-a1	        ; buffer : source and detination

;.......................................
	moveq.l	#-4,d0
	cmp.l	#'bimc',(a0)+		; Id file ?
	bne.s	error
	cmp.l	#'0002',(a0)+		; Version ? 
	bne.s	error
;........................................

	lea.l	2(a1),a2		; The destination buffer must be
	move.l	#32032/8-1,d5		; clean.
cls:	clr.l	(a2)+
	clr.l	(a2)+ 
	dbra.w	d5,cls
;........................................

	move.w	#2,(a1)+		; Write resolution
	move.l	#$fff0000,(a1)		; Write two colors
*	adda.l	#32,a1			 
;........................................

	lea.l	32(a1),a2		; Start of the destination image
	moveq.l	#80,d7			; Offset for next line  

	lea.l	32046(a0),a4		; buffer of work. 46 bytes
*	link	a4,#-46              


	move.w	8(a0),-2(a4)		; 40 always 
	move.w	10(a0),-4(a4)		; 25 always 
	move.w	20(a0),-6(a4)		; $FFFF or $0000 or $xxxx? 
	lea.l   32(a0),a6
	movea.l	a6,a5
	adda.l	12(a0),a5		; Offset address ??
	move.l	a2,-10(a4)		; Backup for revers bits image

	moveq.l	#8,d6
	moveq.l	#0,d5
	move.w	-4(a4),d4       	;  25
	bra.s	next_block

db_0:	bsr.s	L2AFB8           
	bcc.s	c_0          
	bsr.s	L2AE82                  
c_0:	add.l	#80*16,a2   		; +16 lines
next_block:
	dbra.w	d4,db_0		

	tst.w	-6(a4)			; masq for eor
	bne	revers_bits

;.................................................	
_end:	moveq.l	#0,d0			; Return error equal zero
*	unlk    a4
error:	movem.l (sp)+,d1-d7/a0-a6
	rts
;.................................................
L2AE82:	move.l	a2,-14(a4)
	move.w	-2(a4),d3           	; #40
	bra.s	br_1

db_1:	bsr.s	L2AFB8
	bcc.s	c_01
	bsr.s	L2AEA8
c_01:	addq.l	#2,-14(a4)
br_1:	dbra.w	d3,db_1
	rts
;.......................................
L2AFB8:	dbra.w	d5,db_5          
	moveq.l	#7,d5
	move.b	(a6)+,d6
db_5:	add.b	d6,d6               
	rts

L2AF42:	move.b	(a5)+,d1
	beq.s	r_08
	moveq	#7,d0
db_08:	add.b	d1,d1
	bcc.s	c_08
	move.b	(a5)+,(a0)
c_08:	addq.l	#2,a0
	dbra.w	d0,db_08
r_08:	rts
;................................d3
L2AEA8:	movem.l	d3/a3,-(a7)
	moveq	#0,d3
	bsr.s	L2AFB8
	bcc.s	c_02
	addq.w	#2,d3
c_02:	bsr.s	L2AFB8
	bcc.s	c_03
	addq.w	#1,d3
c_03:	cmpi.w	#3,d3
	beq.s	L2AF20
	bsr	clear_work
	lea.l 	-46(a4),a3
	bsr.s	L2AFB8
	bcc.s	c_04
	movea.l	a3,a0
	bsr.s	L2AF42
c_04:	addq.l	#1,a3
	bsr.s	L2AFB8
	bcc.s	c_05
	movea.l	a3,a0
	bsr.s	L2AF42
c_05:	lea.l 	15(a3),a3
	bsr.s	L2AFB8
	bcc.s	c_06
	movea.l	a3,a0
	bsr.s	L2AF42
c_06:	addq.l	#1,a3
	bsr.s	L2AFB8
	bcc.s	c_07
	movea.l	a3,a0
	bsr.s	L2AF42
c_07:	cmpi.w	#1,d3
	beq.s	be_3

	cmpi.w	#2,d3
	beq.s	be_4
	bra.s	br_24

be_3:	lea.l 	-46(a4),a0
	move.w	(a0)+,d0
	moveq	#14,d2
db_3:	move.w	(a0),d1
	eor.w	d1,d0
	move.w	d0,(a0)+
	dbra.w	d2,db_3

	bra.s	br_24

be_4:	lea.l 	-46(a4),a0
	move.l	(a0)+,d0
	moveq.l	#6,d2
db_4:	move.l	(a0),d1
	eor.l	d1,d0
	move.l	d0,(a0)+
	dbra.w	d2,db_4

	bra.s	br_24

L2AF20:	lea.l 	-46(a4),a0
	moveq.l	#7,d0
db_2:	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	dbra.w	d0,db_2

br_24:	lea.l 	-46(a4),a0       
	movea.l	-14(a4),a1       
	moveq.l	#3,d0 		   4
*	move.l	d7,d1		
;				; Recopy 16 word
write_W:
	move.w	(a0)+,(a1)         
	adda.l	d7,a1              Next line    
	move.w	(a0)+,(a1)
	adda.l	d7,a1
	move.w	(a0)+,(a1)
	adda.l	d7,a1
	move.w	(a0)+,(a1)
	adda.l	d7,a1
	dbra.w	d0,write_W

	movem.l	(a7)+,d3/a3
	rts

clear_work:
	lea.l 	-46(a4),a0	
	clr.l	(a0)+   -46
	clr.l	(a0)+   -42
	clr.l	(a0)+   -38
	clr.l	(a0)+   -34
	clr.l	(a0)+   -30
	clr.l	(a0)+   -26
	clr.l	(a0)+   -22
	clr.l	(a0)+   -18
	rts
;--------------------------------------------------------------------------
;			reverse the bits
;..........................................................................
revers_bits
	movea.l	-10(a4),a3		; Start image destination
    	clr.l	d0
    	move.b	-6(a4),d0      		; Mask 
    	bsr.s	L2AFE8			; Start line 0

*    	movea.l	-10(a4),a2
    	adda.w	d7,a3       		; skip a line
    	clr.l	d0
    	move.b	-5(a4),d0		
    	bsr.s	L2AFE8			; Start line 1

    	bra 	_end
;..................................
L2AFE8:	movea.l	a3,a2
	move.w	d0,d1
	lsl.w	#8,d1			; $ff00 or $0000  or $xxxx 
	or.w	d1,d0
	move.w	-4(a4),d1		; 25
	asl.w	#3,d1
	bra.s	_bl_1

L_d1:	movea.l	a2,a1
	lea.l	160(a1),a2
*	adda.w	d7,a2			; next line +80 bytes
*	adda.w	d7,a2			; next line +80 bytes
	move.w	-2(a4),d2		; 40 
	bra.s	_bl_2

l_d2:	eor.w	d0,(a1)+
_bl_2	dbra.w	d2,l_d2 		 ; 40 words
_bl_1:	dbra.w	d1,L_d1        		 
	rts

	end
;-------------------------------------------------------------------------




