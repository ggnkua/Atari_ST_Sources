;Rockyone			pour MI-3 MI-9			  9/07/2016
;
;Delection of the long word reserved,it can be used	 	13/09/2017
;
;
;			OPEN BMP WINDOWS 16 couleurs maximum
;			------------------------------------
;
; Source	BMP file corresponding to a ST resolution
; But		32034 bytes
;
;     		Call	BMP_Open( L Source, L But )
;
; Return	low d0 		-2 erreur header
;		high d0 	 resol image   ( si Low d0 >-2 )
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
		movem.l	60(sp),a5-a6
		movea.l	a5,a2

		moveq.l	#-2,d0			;R. bad file
		cmp.w	#'BM',(a5)		
		bne	error
;........................................Test Type file...................
		lea.l	header(pc),a4
		movea.l	a4,a0

		moveq.l	#3,d3			; 4 type file
new_test:	
		lea.l	18(a5),a2		; Source point to pic width
		moveq.l	#2,d1			; test 3 long word

test_typ:	cmpm.l	(a4)+,(a2)+
		beq.s	ok_long_word
	
next_format:	lea.l	16(a0),a0		; next file format
		movea.l	a0,a4
		dbra.w	d3,new_test		; end type of file ? 
		bra	error			;R. bad file

ok_long_word:	dbra.w	d1,test_typ
		tst.l	(a2)			; packed ?
		bne	error

;........................................TEST RESOLUTION Image / Ecran....
;A5 = Source
;A2 = Source+30
;A4 point to resol
;a0 point to file width

		
ok_resol:	move.w	(a4)+,(a6)+		; resol image
		lea.l	32032-80(a6),a1		; last line high resol

;.......................................PALETTE...........................
;A4 point to type_file
		moveq.l	#0,d1
		move.b	46(a5),d1		; Number of color 
		subq.b	#1,d1			; -1 for dbra
		lea.l	color(pc),a0		; Table of values rvb

		lea.l	57(a5),a2		; point to  "0" of "VBR0"	

		moveq.l	#0,d2			; registre for read V,B,R
read_pal:	moveq.l	#0,d3			; Tampon R+V+B
		moveq.l	#2,d4			 
read_vbr:	move.b	-(a2),d2		; read	 r...v...b
		lsr.b	#4,d2		
		move.b	0(a0,d2.w),d2	
		lsl.w	#4,d3 
		add.b	d2,d3			; Add r+v+b
		dbra.w	d4,read_vbr

		move.w	d3,(a6)+		; save color  
		addq.l	#7,a2			; null byte next color
		dbra.w	d1,read_pal	

		movea.l	a1,a6			;But end bufer -80 byte
	
;..........................................................................
*	subq.l	#4,a5
		move.w	#200,d4			; number of line
		moveq.l	#0,d6	
		move.b	10(a5),d6		; offset image
		adda.w	d6,a5			; data image BMP

		move.w	(a4),d6			; Type file
		cmpi.b	#2,d6			; High resol  ?
		beq	Haute_resol

		moveq.l	#0,d5
		lea.l	-80(a6),a6		; Start last line 
		tst.b	d6			; Low resolution ?
		bne.s	moyenne_resol		; No typ 3 or 4
* 			low_resol		; typ = 0

;.......................................LOW RESOLUTION....................
;d7 remplacÇ par d6

line:		lea.l	160(a6),a2		; end of a line But
word_p:		move.b	#$f,d5			; 16 pixel per word
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
read_byte:	move.b	(a5)+,d6		; read, 2 pixel per byte
bit_0:		btst.b	#4,d6			; Pixel 15,13,11,9,7,5,3,1
		beq.s	bit_1
		bset.b	d5,d0			; plan 0
bit_1:		btst.b	#5,d6
		beq.s	bit_2
		bset.b	d5,d1			; plan 1
bit_2:		btst.b	#6,d6
		beq.s	bit_3
		bset.b	d5,d2			; plan 2
bit_3:		btst	#7,d6
		beq.s	bit_4
		bset.b	d5,d3			; plan 3
bit_4:		subq.b	#1,d5			;Pixel 14,12,10,8,6,4,2,0 
		btst.b	#0,d6
		beq.s	bit_5
		bset.b	d5,d0			; plan 0
bit_5:		btst.b	#1,d6
		beq.s	bit_6
		bset.b	d5,d1			; plan 1
bit_6:		btst.b	#2,d6
		beq.s	bit_7
		bset.b	d5,d2			; plan 2
bit_7:		btst.b	#3,d6
		beq.s	next	
		bset.b	d5,d3			; plan 3
next:		subq.b	#1,d5			;  here,=  -2 at each loop  
		bpl.s	read_byte		; >= 0			
		move.w	d0,(a6)+
		move.w	d1,(a6)+
		move.w	d2,(a6)+
		move.w	d3,(a6)+
		cmpa.l	a6,a2			; end of a ligne ?
		bhi.s	word_p			; > no
		subq.w	#1,d4			; end line
		beq.s	end_prg		
		lea.l	-320(a6),a6		; previous line
		bra.s	line

;.......................................MEDIUM RêSOLUTION.................
;d7 rempllacÇ par d3

moyenne_resol:	subq.b	#3,d6			; type file 3 o 4
		mulu.w	#320,d6	        	; As double lines type 4
mline:		lea.l	160(a6),a2		; end of a line But
mword_p:	move.b	#$f,d5			; 16 pixel 2 plans
		moveq.l	#0,d0
		moveq.l	#0,d1
mread_byte:	move.b	(a5)+,d3		; read 2 pixel per byte
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
		move.w	d0,(a6)+
		move.w	d1,(a6)+
		cmpa.l	a6,a2			; en of a line ?
		bhi.s	mword_p			; > no
		subq.w	#1,d4			; end lines
		beq.s	end_prg		
		adda.w	d6,a5			; + 320 for type file 4
		lea.l	-320(a6),a6		; previous line
		bra.s	mline
;.......................................HIGH RêSOLUTION...................
haute_resol:	lsl.w	#1,d4			; 400 line
line_h:		moveq.l	#19,d2			;  80 bytes per line
data_h:		move.l	(a5)+,(a6)+
		dbra.w	d2,data_h
		subq.w	#1,d4
		beq.s	end_prg
		lea.l	-160(a6),a6		; previous line
		bra.s 	line_h	
;-------------------------------------------------------------------------
end_prg:	moveq.l	#0,d0			; Negativ = error
error:		swap d0
		move.w	rez,d0			; Image resolution  
		swap d0				
		movem.l (a7)+,d1-d7/a0-a6 
		rts 
;-------------------------------------------------------------------------
header:
;		Width, Height, Byte per pixel, Plan 
;		Image resolution, Type file	

Low:	dc.l	$40010000,$c8000000,$01000400	
	dc.w	$0,$0			
Medium:	dc.l	$80020000,$c8000000,$01000400	;  Positive-Image...
	dc.w	$1,$3				;  ...unlined screen lines 
	dc.l	$80020000,$90010000,$01000400	;  Windows and  MI-3  
	dc.w	$1,$4
High: 	dc.l	$80020000,$90010000,$01000100
	dc.w	$2,$2
rez:	dc.w	$0


;........................................................................
; couleur: table de conversion 
;                0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
color:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
	

	end
;*************************************************************************
