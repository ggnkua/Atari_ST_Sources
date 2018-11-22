;Rockyone			pour MI-3 MI-9			  9/07/2016
;
; Delection of the long word reserved,it can be used	 	13/09/2017
; Modified to reduce the read buffer,				11.78.2018
; before it was 128,118 bytes in medium resolution
;
;	OPEN BMP WINDOWS corresponding to a ST color and resolution
;	-----------------------------------------------------------
;
; Temp	    read buffer  32000 bytes
; But	    buffer	 32034 bytes
; Handle    The file is already open by MI-3 or MI-9
;
;                           	    a3/a4 , a5/a6, fhandle
;         	Call	BMP_Open( L temp, L But, W handle )
;
; Return	low d0 		-2 erreur header
;
;-------------------------------------------------------------------------
; FORMAT
;+  0 W	$424D  BM
;+  2 L	Size file			
;+  6 L	Reserved 			can be used !
;+ 10 L	Offset for image		
;+ 14 L	size header
;+ 18 L width of the image in pixel	160 or 320
;+ 22 L	height of image in pixel	200 or 400
;+ 26 W Number of plan			1 alway
;+ 28 W Numbre of bits per pixel	4= 16 color, 1 =2 color
;+ 30 L compression			0
;+ 34 L size of image aera		
;+ 38 L bits per meter
;+ 42 L buts per meter
;+ 46 L	color number			2 or 16
;+ 50 L	number of important color	2 or 16
;+ 54 B Color V,B,R,+ one byte nul	Number color * 4
;+ Offset de l'image  			Data image
;------------------------------------------------------------------------
; used d0-d6/a0-a5
; free d7/a3 
		movem.l d1-d7/a0-a6,-(a7) 
		move.w	68(sp),fhandle

	        move.l #-2,erreur		;R. bad file
	
		
;........................................TEST FILE...................
;a0/a3 buffer read file
;a1/a6  
*
*		move.l	#80,seek_offset		; for read header
*		bsr 	fread			; read file in A3
*		ble	error			        ; <
* 80 bytes are loaded into the PRG because of the images 640*400
*****************************************************************
;a0/a3 buffer read file
;a1/a6 

		move.l	60(sp),a3       ;   image source		
		cmpi.w	#'BM',(a3) 
		bne	error

		lea.l	header(pc),a6
        
		moveq.l	#3,d1		; 4 type file
test_header:	lea.l	18(a3),a0	; Source point to pic width
		movea.l a6,a1

		moveq.l	#2,d2		; test 3 long word
test_lw:	cmpm.l	(a0)+,(a1)+
		beq.s	ok_test
	
other:		adda.w  #16,a6		; next file format
		dbra.w	d1,test_header	; end type of file ? 
        	bra	error		;R. bad file

ok_test:	dbra.w	d2,test_lw
		tst.l	(a0)		; 30(a3) packed ?
		bne	error
 
	        move.l  64(sp),a5       ; buffer destination 
	        move.w  (a1)+,(a5)+     ; image resolution
        	movea.l	a5,a6

        	move.w  (a1),d6        	; a1 typ_file 

;.......................................PALETTE...........................

		lea.l	color(pc),a0	; Table of values rvb 
		lea.l	57(a3),a2	; point to  "0" of first "VBR0"

		move.b	46(a3),d1	; Number of color 
		subq.b	#1,d1		; -1 for dbra
	
		moveq.l	#0,d2		; registre for read V,B,R
read_pal:	moveq.l	#0,d3		; Tampon R+V+B
		moveq.l	#2,d4			 
read_vbr:	move.b	-(a2),d2	; read	 r...v...b
		lsr.b	#4,d2		
		move.b	0(a0,d2.w),d2	
		lsl.w	#4,d3 
		add.b	d2,d3		; Add r+v+b
		dbra.w	d4,read_vbr

		move.w	d3,(a5)+	; save color  
		addq.l	#7,a2		; null byte next color
		dbra.w	d1,read_pal	

		lea.l	32(a6),a5
;............................................................................
		adda.l	#14,a3		; 10(a3) offset for image data
		moveq.l	#0,d0
		moveq.l	#3,d1
read_offset:	lsl.l	#8,d0
		move.b	-(a3),d0		; offset for image data
		dbra.w	d1,read_offset
		
fseek:		move.w	#0,-(sp)		; seek mode	
		move.w	fhandle,-(sp)
		move.l	d0,-(sp)        	; offset for image data 54
		move.w	#$42,-(sp)		; Fseek
		trap	#1
		add.l	#10,sp
		tst.l	d0              	; error ?
    		bmi	error			

		move.l	#-4,erreur
       		bsr	fread			; read 32000 bytes to a3
        	ble	error

;						; in heigh resol
		lea.l	32000-80(a5),a6		; But, end Last line 
		lea.l	80(a5),a5		: But, end first line

;..........................................................................

		cmpi.b	#2,d6		; (type file) High resol  ?
		beq	Haute_resol

		moveq.l	#0,d5

		lea.l	-80(a6),a6	; Start last line, low & medium 
		lea.l	80(a5),a5
		tst.b	d6		; Low resolution ?
		bne.s	moyenne_resol	; No typ 3 or 4
* 			    low_resol	; typ = 0

;.......................................LOW RESOLUTION....................

line:		lea.l	160(a6),a2	; end of a line But

word_p:		move.b	#$f,d5		; 16 pixel per word
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
read_byte:	move.b	(a3)+,d6	; read, 2 pixel per byte
bit_0:		btst.b	#4,d6		; Pixel 15,13,11,9,7,5,3,1
		beq.s	bit_1
		bset.b	d5,d0		; plan 0
bit_1:		btst.b	#5,d6
		beq.s	bit_2
		bset.b	d5,d1		; plan 1
bit_2:		btst.b	#6,d6
		beq.s	bit_3
		bset.b	d5,d2		; plan 2
bit_3:		btst	#7,d6
		beq.s	bit_4
		bset.b	d5,d3		; plan 3
bit_4:		subq.b	#1,d5		;Pixel 14,12,10,8,6,4,2,0 
		btst.b	#0,d6
		beq.s	bit_5
		bset.b	d5,d0		; plan 0
bit_5:		btst.b	#1,d6
		beq.s	bit_6
		bset.b	d5,d1		; plan 1
bit_6:		btst.b	#2,d6
		beq.s	bit_7
		bset.b	d5,d2		; plan 2
bit_7:		btst.b	#3,d6
		beq.s	next	
		bset.b	d5,d3		; plan 3
next:		subq.b	#1,d5		;  here,=  -2 at each loop  
		bpl.s	read_byte	; >= 0			

		move.w	d0,(a6)+
		move.w	d1,(a6)+
		move.w	d2,(a6)+
		move.w	d3,(a6)+

		cmpa.l	a6,a2		; end of a ligne ?
		bhi.s	word_p		; > no

		cmp.l	a5,a6		; but equal end first line ?
		beq	end_prg

		lea.l	-320(a6),a6	; previous line
		bra.s	line
	
;.......................................MEDIUM RSOLUTION.................
;d7 rempllac‚ par d3

moyenne_resol:	lea.l 32000(a3),a4
        
        	subq.b	#3,d6			; type file 3 o 4
		mulu.w	#320,d6	        	; As double lines type 4

mline:		lea.l	160(a6),a2		; end of a line But        

mword_p:	move.b	#$f,d5			; 16 pixel 2 plans
		moveq.l	#0,d0
		moveq.l	#0,d1
mread_byte:	move.b	(a3)+,d3		; read 2 pixel per byte
mbit_0:		btst.b	#4,d3			; Pixel 15,13,11,9,7,5,3,1
		beq.s	mbit_1
		bset.b	d5,d0			; plan 0
mbit_1:		btst.b	#5,d3
		beq.s	mbit_4
		bset.b	d5,d1			; plan 1
mbit_4:		subq.b	#1,d5			; Pixel 14,12,10,8,6,4,2,0	
		btst.b	#0,d3
		beq.s	mbit_5
		bset.b	d5,d0			; plan 0
mbit_5:		btst.b	#1,d3
		beq.s	mnext
		bset.b	d5,d1			; plan 1
mnext:		subq.b	#1,d5			
		bpl.s	mread_byte		; >=0			

		move.w	d0,(a6)+	; plan 0
		move.w	d1,(a6)+	; plan 1

		cmpa.l	a6,a2		; end of a ligne ?	
		bhi.s	mword_p		; > no

		cmp.l	a5,a6		; but equal end first line ? 
		beq.s	end_prg

		adda.w	d6,a3		; + 320 for type file 4

	        cmp.l   a3,a4		; end read buffer ?
	        bhi.s   next_line	; no

	        bsr.s   fread		; read 32000 byte
	        ble     error

next_line	lea.l	-320(a6),a6	; previous line
		bra.s	mline
;......................................sub routine........................
fread:		move.l	64(sp),a3 		; read buffer
		pea.l	(a3)
		move.l	#32000,-(sp)
		move.w	fhandle,-(sp) 
		move.w	#$3f,-(sp) 	
		trap	#1
		add.l	#12,sp
		tst.l	d0
		rts
;.......................................HIGH RSOLUTION...................
haute_resol:	
line_h:		lea.l	80(a6),a2	; end of a line But
data_h:		move.l	(a3)+,(a6)+
		cmpa.l	a6,a2		; end of a ligne ?	
		bhi.s	data_h		; > no
		cmp.l	a5,a6		; but equal end first line ? 
		beq.s	end_prg

		lea.l	-160(a6),a6	; previous line
		bra.s 	line_h	
;-------------------------------------------------------------------------
end_prg:	move.l	#0,erreur 	;	 Negativ = error
error:		move.w	fhandle,-(sp)	
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		
	    	move.l	erreur,d0		; error if negativ
      		movem.l	(sp)+,d1-d7/a0-a6
		rts		
;-------------------------------------------------------------------------
fhandle         dc.w    $0
erreur          dc.l    $0
header:
;		Width, Height, Plaa, Byte per pixel
;		Image resolution, Type file	

Low:	dc.l	$40010000,$c8000000,$01000400	
	dc.w	$0,$0			
Medium:	dc.l	$80020000,$c8000000,$01000400	;  Positive-Image...
	dc.w	$1,$3				;  ...unlined screen lines 
	dc.l	$80020000,$90010000,$01000400	;  Windows and  MI-3  
	dc.w	$1,$4
High: 	dc.l	$80020000,$90010000,$01000100
	dc.w	$2,$2
;........................................................................
; couleur: table de conversion 
;                0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
color:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
	

	end
;*************************************************************************
