;rockyone		for MI-3  MI-9				26/11/2017
;
;
;
;			Save PI1-3 to  BMP 24 bits
;			--------------------------
;
;  		
; 
; Source:	buffer  32034 or 32066 bytes image format PI1-3 
;
; But: 		buffer  38464 bytes to comvert the image
;
; handle	destination file handle
;		In MI-3 and MI-9,the file is already open 
;
;		Call bmp_save(L Source, L But, W Handle,W typ )
;		-----------------------------------------------
;
;
; 	 	resol 0		resol 1		resol 2 
; header 	   54		   54              54		
; palette	    0		    0		    0		
; data image   192000		384000		768000
; size file    192054		384054		768054 
;
; In medium resolusion,the lines are doubled to maintain the wight/heigh
; ratio.
;-------------------------------------------------------------------------
; used	d0-d7, a2-a6
; free d4/a1-a2

		movem.l	d0-d7/a0-a6,-(sp) 
		movem.l	64(sp),a5-a6
		move.w	(a5)+,d6		; image resolution 'alway

		lea.l	header(PC),a0
		tst.b	d6 
		beq.s	low_header
		adda.w	#16,a0 			

low_header:	move.w	#'BM',(a6)+		;+0 Id
		move.l	(a0)+,(a6)+		;+2 file size 
		move.l	#$4d492d39,(a6)+	;+6 reserved
		move.l	#$36000000,(a6)+	;+10 offest for image 
		move.l	#$28000000,(a6)+	;+14 size of header 
		move.l	(a0)+,(a6)+		;+18 image width
		move.l	(a0)+,(a6)+		;+22 image height
		move.w	#$100,(a6)+ 		;+26 number plan - always 1 -
*		move.w	(a0)+,(a6)+		;+28 number bits per color
		move.w	#$1800,(a6)+		;+28 
		move.l	#0,(a6)+		;+30 compression
		move.l	(a0)+,(a6)+		;+34 size of the image aera
		move.l	#$232E0000,(a6)+ 	;+38 pixel per meter
		move.l	#$232E0000,(a6)+ 	;+42
		move.l	#$0,(a6)+		;+46 
		move.l	#$1,(a6)+ 		;+50 number colors
;				
		move.l	#54,fsize
		move.w	72(sp),handle
		bsr	fwrite 			; save header 

;...............................................PALETTE...................
;A5 = Source+2
;A6 = But+0 always after fwrite

		movea.l	a6,a4
		adda.l	#38400,a4
		lea.l	bmp_color(PC),a0
		moveq.l	#$F,d1			; 16 colors
		moveq.l	#0,d2 
		moveq.l	#0,d3 
color:		move.w	(a5)+,d7		; Read color RGB
		moveq.l	#2,d5 
r_v_b:		move.b	d7,d3 
		lsr.w 	#4,d7 			
		andi.b	#$f,d3
		move.b	0(a0,d3.w),d2 		; Conversion B..G..R
		move.b	d2,d3 
		lsl.b	#4,d3 
		add.b	d2,d3 
		move.b	d3,(a4)+		; Save values B..G..R
		dbra.w	d5,r_v_b
		addq.l	#1,a4 			; ..+ one byte null
		dbra.w	d1,color


;.........................................................................

		move.l	#38400,fsize		; Size buffer data image 
		suba.l	#16*4,a4		; Address : 
;						;  - end of converted data 
;						;  - Start palette

		cmpi.b	#2,d6			; hight resol ? 
		beq.s	high_resol 

;...............................................
;a0   	Source of a line
;a0	Used to double the lines in medium resolution 
;a1
;a2
;a3     Source+34+160	Start second line (for test end source )
;a4   	Buffer+38400   	Star of the palette
;a5   	Source+34 	Start of lines
;a6   	But+0		buffer for to convert line
;d0-d3 	word plan
;d4 	
;d5 	number pixel
;d6 	image resolution
;d7 	value of a pixel 

;  80*8         = 640 * 3 = 1920 * 20 = 38400 * 20 = 768000
; (160*8) shl 1 = 640 * 3 = 1920 * 20 = 38400 * 10 = 384000 * 2 = 768000
; (160*8) shl 2 = 320 * 3 =  960 * 40 = 38400 *  5 = 192000

; word plan    in   d0-d3 1111 1111 1111 1111
; test bit     by   d5    FEDC BA98 7654 3210
; write pixel  in   d7    0123 4567 89AB CDEF

;.......................................SAVE LOW and MEDIUM RESOLUTION....

low_med:	Lea.l	160(a5),a3		; Source End of converssion
		lea.l	32000(a3),a5	        ;        Last line+one
lines_bm:	lea.l	-320(a5),a5		;	 Start of a ligne
		lea.l	160(a5),a0		;	 End of a line
read_words:	moveq.l	#15,d5			; 	 16 pixels by word
		move.w	(a5)+,d0		
		move.w	(a5)+,d1	
		tst.b	d6			; medium  resolution ?
		bne.s	pixels			; yes
		move.w	(a5)+,d2		
		move.w	(a5)+,d3	
	
pixels:		moveq.l	#0,d7			  
bit_0:		btst.b	d5,d0			; plan 1  
		beq.s	bit_1
		addq.b	#%1,d7		
bit_1:		btst.b	d5,d1			; plan 2  
		beq.s	test_resol
		addq.b	#%10,d7		

test_resol:	tst.b	d6			; medium resolution ?
		bne.s	save_color		; yes
bit_2:		btst.b	d5,d2			; plan 3
		beq.s	bit_3
		addq.b	#%100,d7	
bit_3:		btst.b	d5,d3			; plan 4  
		beq.s	save_color 
		addq.b	#%1000,d7	

save_color:	lsl.b	#2,d7
		move.b	0(a4,d7.w),(a6)+	; B color  pixel
		move.b	1(a4,d7.w),(a6)+	; G
		move.b	2(a4,d7.w),(a6)+	; R
		dbra.w	d5,pixels		; end of pixel ?
		cmpa.l	a5,a0			; end of a line Source ?
		bhi.s	read_words 	

		tst.b	d6			; low resol ?
		beq.s	single_line 		; yes

;...    				      ...only in medium resolution
		lea.l	-1920(a6),a0 
		move.w	#479,d7 		; (1920\4)-1
double_line:	move.l	(a0)+,(a6)+ 
		dbra.w	d7,double_line
;...    				      ...

single_line:	cmpa.l	a6,a4 			; buffer full ?
		bhi.s	lines_bm

		bsr.s	fwrite 			; save 38400 bytes 
					
		cmpa.l	a3,a5			; end pic ?
		bhi.s	lines_bm			
		
		bra.s	end_prg
		
;...............................................HIGHT RESOLUTION............

high_resol:	lea.l	80(a5),a3		; Source End of converssion
		lea.l	32000(a3),a5		;  	 Last line+one 
line_h:		lea.l	-160(a5),a5		; 	 Star of a line
		lea.l	80(a5),a0		; 	 End of a line
word_h:		moveq.l	#15,d5			;        16 pixel by word
		move.w	(a5)+,d0
pixel_h		moveq.l	#0,d7
		btst.b	d5,d0
		beq.s	color0
		moveq.l	#4,d7

color0:		move.b	0(a4,d7.w),(a6)+
		move.b	1(a4,d7.w),(a6)+
		move.b	2(a4,d7.w),(a6)+
		dbra.w	d5,pixel_h		; end of pixel  ?
		cmpa.l	a5,a0			; end of a line ?
		bhi.s	word_h			
		cmpa.l	a6,a4			; buffer full   ?
		bhi.s	line_h			

save_h:  	bsr.s 	fwrite			; end source    ? 
		cmpa.l	a3,a5
		bhi.s	line_h			; 20 * 20 line

;....................................................
end_prg:	move.w	handle,-(sp) 
      		move.w	#$3E,-(sp) 		; Fclose	 
      		trap	#1
      		addq.l	#4,sp 
      		movem.l	(sp)+,d0-d7/a0-a6
		rts		
;.........................................................................			 
fwrite:		move.l	72(sp),a6 		; (sp)+4 because bsr
		pea.l	(a6)
		move.l	fsize,-(sp) 
		move.w	handle,-(sp) 
		move.w	#$40,-(sp) 	
		trap	#1
		add.l	#12,sp
		rts 
;.........................................................................
; file size, widht, height
; bits per pixel
; size image aera
		even
header:		dc.l	$36ee0200,$40010000,$c8000000	; low resol
*		dc.w	$1800
		dc.l	$ee0200
		dc.l	$36b80b00,$80020000,$90010000	; medium resol
*		dc.w	$1800
		dc.l	$b80b00
*		dc.l	$36b80b00,$80020000,$90010000	; hight resol
*		dc.w	$1800
*		dc.l	$b80b00

bmp_color:	dc.b	$0,$2,$4,$6,$8,$A,$C,$E,$1,$3,$5,$7,$9,$B,$D,$F
fsize:		dc.l	$0
handle:		dc.w	$0

		END
;*******************************************************************
