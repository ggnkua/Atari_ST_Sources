;rockyone		     for MI-3  MI-9			13.05.2018
;modif for image 640*400					11.06.2018
;
;			Open  BMP 24 bits PI1-3
;			-----------------------
;
;		
; temp		Read buffer  38400 + 96 bytes for color index 
; but:		Comversion buffer  32034 image PI1-3
; handle	The file is already open by MI-3 or MI-9
; Typ		Resolution for image 640*400
;		
;
;				 
;				 a3/a4, a5/a6,fhandle		
;		Call S24_Open( L temp, L but, W handle, W typ )
;		-------------------------------------------
;
; Return in low d0	-2 bad file 
; 
;
; reduced format	resol 0	       resol 1 		 
; large format					  	resol 0,1,2
;
; header 	    	    54		    54              54		
; palette	     	     0		     0 		     0		
; data image   		192000		384000		768000
; size file    		192054		384054		768054 
;
; +0  W	'BM' 	Id 
; +2  L  ?	file size      ( bad value with a converter !!!! )
; +6  L  ?	reserved
; +10 L	54	offest for image 
; +14 L	24	size of header 
; +18 L	 ?	image width
; +22 L	 ?	image height
; +26 W  1  	number plan		
; +28 W 24 	number bits per color 
; +30 L  0 	never compressed 
; +34 L	 ?	size of the image data	Not registerd by Steem emulator
; +38 L	$232e0000 x pixel per meter	"	"	"	"
; +42 L	$232e0000 y pixel per metre	"	"	"	"		
; +46 L	0				"	"	"	"
; +50 L 1	number colors 		"	"	"	"

;-------------------------------------------------------------------------
 
		movem.l	d1-d7/a0-a6,-(sp) 
		move.w	68(sp),fhandle

		move.l	#-2,ereur		;R. bad file

;...............................................TEST FILE.................
;a3 buffer read file
;a4
;a5 destination
;a6 a5+32000


*		move.l	#80,seek_offset		; for read header
*		bsr 	fread			; read file in A3
*		ble	error			; <
* 80 bytes are loaded into the PRG because of the images 640*400
*****************************************************************

		move.l	60(sp),a3		
		cmpi.w	#'BM',(a3) 
		bne	error

		cmpi.l	#$01001800,26(a3)	;plan ?  bits par pixel ?
		bne	error		

			
		lea.l	header(PC),a1		
		moveq.l	#2,d6			; test 3 image format
test_header:	lea.l	18(a3),a0		
		movea.l	a1,a2
		moveq.l	#1,d2			; test 2 long word
test_lw:	cmpm.l	(a0)+,(a2)+		; width, height
		beq.s	ok_test		
other:		adda.w	#8,a1
		dbra.w	d6,test_header
ok_test:	dbra.w	d2,test_lw
		
		tst.b	d6
		bmi	error			; d6 = image resolution
		
;...............................................For image 640*400........
		move.l	#0,jump_pixel		; reset 2 variables
		move.w	70(sp),d0	
		cmpi.b	#2,d0			; force resolution ?
		beq.s	ok_resol		; No

		move.w	#1920,jump_line		
		move.w	d0,d6			; new resolution (0 or 1)
		bne.s	ok_resol
		move.w	#3,jump_pixel		; only in low resolution
ok_resol:
;.........................................................................

		adda.l	#14,a3			; 10(a3)
		moveq.l	#0,d0
		moveq.l	#3,d1
read_byte:	lsl.l	#8,d0
		move.b	-(a3),d0		; offset for image data
		dbra.w	d1,read_byte

fseek:		move.w	#0,-(sp)		; seek mode	
		move.w	fhandle,-(sp)
		move.l	d0,-(sp)
		move.w	#$42,-(sp)		; Fseek
		trap	#1
		add.l	#10,sp
		tst.l	d0
		bmi	error			

		move.l	#38400,seek_offset

		movem.l	60(sp),a4-a5		; buffer address
		adda.l	#38400,a4		; End of the read buffer
;						; Start of the color index

		movea.l	a4,a0			; Initializes the buffer 
		moveq.l	#16,d0			; for VGR = 0
loop:		move.b	#$1,(a0)
		addq.l	#6,a0
		dbra.w	d0,loop

		move.w	d6,(a5)+		; BMP resolution
		move.b	d6,rezol
		moveq.l	#0,d7			; Color index counter

		cmpi.b	#2,d6		; Hight resolution ?
		beq	hight_resol	; Yes. Not sure in this resolution
		bra.s	low_medium	; even conting the color use.

;......................................sub routine........................
;offset 0  1  2  3  4  5
;  a1:  00 bb vv rr 00 ii	 (00ii = color index for data image )
;  d7:  number of color saved

color_index:	movea.l	a4,a1		; adress color in the read buffer
		move.b	d7,d6		; number of color registred

		moveq.l	#0,d5	
		move.b	(a3)+,d5	; read B
		lsl.l	#8,d5
		move.b	(a3)+,d5	; read G
		lsl.l	#8,d5
		move.b	(a3)+,d5	; read R
	
find_bvr:	cmp.l	(a1),d5
		beq.s	trouver
		addq.l	#6,a1		; pointe on the next color 
		dbra.w	d6,find_bvr

		move.w	d7,-(a1)	; color index in the palette
		move.l	d5,-(a1)	; new color
		cmpi.b	#15,d7
		beq.s	trouver
		addq.l	#1,d7	

trouver:	move.w	4(a1),d6	; pixel color index
		rts

;...................................320*200 AND 640*200...................
low_medium:
		lea.l	32+160(a5),a5		; But  end first line
		lea.l	32000(a5),a6		; But  end Last line+one 

read_m:		bsr.s	fread
		ble	error

line_m:		lea.l	-320(a6),a6
		lea.l	160(a6),a0

byte_m		moveq.l	#15,d4			; 16 pixel by word
		moveq.l	#0,d0			; regitres for the plane
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3

read_pixel:	bsr.s	color_index		; find color index
		beq.s	next_pixel		; index color 0 

Plan_0:		btst.b	#0,d6
		beq.s	plan_1
		bset.b	d4,d0

plan_1:		btst.b	#1,d6
		beq.s	plan_2
		bset.b	d4,d1

plan_2:		tst.b	rezol			; Low resolution ?
		bne.s	next_pixel		; No
		btst.b	#2,d6
		beq.s	plan_3
		bset.b	d4,d2

plan_3:		btst.b	#3,d6		
		beq.s	next_pixel
		bset.b	d4,d3	

next_pixel:	adda.w	jump_pixel,a3	
		dbra.w	d4,read_pixel

		move.w	d0,(a6)+		; plan 1
		move.w	d1,(a6)+		; plan 2

		tst.b	rezol			; low resolution ?
		bne.s	next_line		; no

		move.w	d2,(a6)+		; plan 3
		move.w	d3,(a6)+ 		; plan 4

next_line:	cmpa.l	a6,a0			; en of a line ?
		bhi.s	byte_m			; >

		adda.w	jump_line,a3
		cmpa.l	a3,a4			; end buffer ?
		bhi.s	line_m

		cmpa.l	a5,a6			; screen full ?
		bhi.s	read_m

		bra.s	convert_pal
;......................................sub routine........................
fread:		move.l	64(sp),a3 		; read buffer
		pea.l	(a3)
		move.l	seek_offset,-(sp)
		move.w	fhandle,-(sp) 
		move.w	#$3f,-(sp) 	
		trap	#1
		add.l	#12,sp
		tst.l	d0
		rts
;..............................................640*400....................
hight_resol:	tst.w	(a3)
		bne.s	inv_pal
		move.l	#$fff0000,(a5)
		bra.s	next_pal
inv_pal:	move.l	#$fff,(a5)
next_pal:	

		lea.l	32+80(a5),a5		;But end first line
		lea.l	32000(a5),a6		;But end Last line+one line

read_h		bsr.s	fread			; read 38400 bytes
		bmi.s	error

line_h:		lea.l	-160(a6),a6		; But	 Star of a line
		lea.l	80(a6),a0		; But	 End of a line

byte_h		move.l	#15,d5			; But    16 pixel by word
		moveq.l	#0,d6

pixel_h:	tst.b	(a3)
		beq.s	black_pixel
		bset.b	d5,d6
black_pixel:	addq.l	#3,a3
		dbra.w	d5,pixel_h

		move.w	d6,(a6)+
		cmpa.l	a6,a0			; en of a line ?
		bhi.s	byte_h			; >

		cmpa.l	a3,a4			; end buffer ?
		bhi.s	line_h

		cmpa.l	a5,a6			; screen full ?
		bhi.s	read_h

		bra.s	end_prg
;...............................................CONVERT PALETTE...........
; a4: 00 bb vv rr 00 ii
convert_pal:	move.l	64(sp),a5		; destination
		addq.l	#2,a5
		lea.l	hard_color(PC),a1	; conversion table
		addq.l	#4,a4			; saved color address

		moveq.l	#$f,d1			; 16 colors
		moveq.l	#0,d2
read_pal	moveq.l	#0,d3
		moveq.l	#2,d4 

read_vbr:	move.b	-(a4),d2		; Read color R,G,B
		lsr.b	#4,d2
		move.b	0(a1,d2.w),d2
		lsl.w	#4,d3
		add.b	d2,d3
		dbra.w	d4,read_vbr
		move.w	d3,(a5)+		; Save RVB
		adda.w	#9,a4
		dbra.w	d1,read_pal
;-------------------------------------------------------------------------
end_prg:	move.l	#0,ereur
error:		move.w	fhandle,-(sp)	
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		
		move.l	ereur,d0		; error if negativ
      		movem.l	(sp)+,d1-d7/a0-a6
		rts		
;.........................................................................
header:	dc.l	$80020000,$90010000 	; Low, medium and height   640*400
	dc.l	$80020000,$c8000000	; medium        	   640*200
	dc.l	$40010000,$c8000000	; low 		  	   320*200

hard_color:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
rezol:		dc.b	$0,$0
fhandle:	dc.w	$0
seek_offset:	dc.l	$0
ereur:		dc.l	$0
jump_pixel:	dc.w	$0
jump_line:	dc.w	$0
		END
;*******************************************************************
