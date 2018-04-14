;rockyone		for MI-3  MI-9				27/08/2017
;
;			Save PI1-3 to  BMP
;			------------------
;
; 	 	resol 0		resol 1		resol 2 
; header 	   54		   54              54		
; palette	   64		   64		   64		
; pixel  	32000	        64000*2		32000		
;   		
; In medium resoluuion,the lines are doubled to maintain the wight/heigh
; ratio.
; 
; Source:	buffer image format PI1-3  32034 or 32066 bytes
; But: 		buffer 32000 bytes  To comvert the image
; Handle	Handle of the destination file.
;		In MI-3 and MI-9,the file is already open 
;
;		Call bmp_save( L Source, L But, W Handle )
;		---------------------------------------------
;-------------------------------------------------------------------------
; used	d0-d7, a2-a6
; free d7/a0-a1

		movem.l	d0-d7/a0-a6,-(sp) 
		movem.l	64(sp),a5-a6
		move.w	(a5)+,d6		; image resolution 'alvay

		lea.l	header(PC),a4
		move.w	d6,d1 
		mulu.w	#18,d1
		adda.w	d1,a4 

		move.w	#'BM',(a6)+		;+0 Id
		move.l	(a4)+,(a6)+		;+2 file size 
		move.l	#$4d492d39,(a6)+	;+6 reserved
		move.l	#$76000000,(a6)+	;+10 offest for image 
		move.l	#$28000000,(a6)+	;+14 size of header 
		move.l	(a4)+,(a6)+		;+18 image width
		move.l	(a4)+,(a6)+		;+22 image height
		move.w	#$100,(a6)+ 		;+26 number plan - always 1 -
		move.w	(a4)+,(a6)+		;+28 number bits per color
		move.l	#0,(a6)+		;+30 compression
		move.l	(a4)+,(a6)+		;+34 size of the image aera
		move.l	#$232E0000,(a6)+ 	;+38 pixel per meter
		move.l	#$232E0000,(a6)+ 	;+42
		move.l	#$10000000,(a6)+	;+48; number colors 
		move.l	#$10000000,(a6)+ 	;+52
;				
;...............................................PALETTE...................
;A5 = Source+2
;A6 = But+56

		lea.l	bmp_color(PC),a4
		moveq.l	#$F,d1			; 16 colors
		moveq.l	#0,d2 
		moveq.l	#0,d3 
color:		move.w	(a5)+,d7		; Read color RVB
		moveq.l	#2,d5 
r_v_b:		move.b	d7,d3 
		lsr.w 	#4,d7 			
		andi.b	#$f,d3
		move.b	0(a4,d3.w),d2 		; Conversion B..V..R
		move.b	d2,d3 
		lsl.b	#4,d3 
		add.b	d2,d3 
		move.b	d3,(a6)+		; Save values B..V..R
		dbra.w	d5,r_v_b
		addq.l	#1,a6 			; ..+ one byte null
		dbra.w	d1,color

		move.l	#118,fsize
		move.w	72(sp),handle
		bsr	fwrite 			; save header + palette

		move.l	#32000,fsize		; size buffer
		cmpi.b	#2,d6			; hight resol ? 
		beq	high_resol 

;.......................................SAVE LOW and MEDIUM RESOLUTION............
;A5 = Source+34
;a6 = But+0 after fwrite
;d0-d3 word plan
;d4 number line
;d5 number pixel
;d6 resolution
;d7 2 pixel bmp

; 160\8 =80 word =320 pixel
; 160\4 =40 word =640 pixel
; d0-d3 1111 1111 1111 1111
; bit   FEDC BA98 7654 3210
; pixel 0123 4567 89AB CDEF

low_med:	move.w	#200,d4	
		lea.l	32000-160(a5),a5	; last line Source
		lea.l	32000(a6),a4		; end buffer But

start_line:	lea.l	160(a5),a3		; end of a ligne Source
read_words:	moveq.l	#15,d5			; 16 pixels by word
		move.w	(a5)+,d0		
		move.w	(a5)+,d1		
 		tst.b	d6			; image resolution ?
		bne.s	pixels			; medium
		move.w	(a5)+,d2		; only low resol
		move.w	(a5)+,d3		
pixels:		moveq.l	#0,d7			; for two colors BMP 
;                                               ; Bit 15,13,11,9,7,5,3,1
bit_0		btst.b	d5,d0			; plan 1  
		beq.s	bit_1
		ori.b	#%10000,d7
bit_1:		btst.b	d5,d1			; plan 2  
		beq.s	test_resol
		ori.b	#%100000,d7

test_resol:	tst.b	d6			; low resolution ?
		bne.s	second_quartet		; no
bit_2:		btst.b	d5,d2			; plan 3
		beq.s	bit_3
		ori.b	#%1000000,d7
bit_3:		btst.b	d5,d3			; plan 4   
		beq.s	second_quartet
		ori.b	#%10000000,d7

second_quartet:	subq.b	#1,d5			; bits 14,12,10,8,6,4,2,0

bit_4:		btst.b	d5,d0			; plan 1 
		beq.s	bit_5
		addq.b	#%1,d7
bit_5:		btst.b	d5,d1			; plan 2   
		beq.s	resol_test
		addq.b	#%10,d7
resol_test:	tst.b	d6			; low resolution ?
		bne.s	save_colors		; no
bit_6:		btst.b	d5,d2			; plan 3   
		beq.s	bit_7
		addq.b	#%100,d7
bit_7:		btst.b	d5,d3			; plan 4   
		beq.s	save_colors
		addq.b	#%1000,d7
;...............................................;	

save_colors:	move.b	d7,(a6)+		; color of two pixel
		subq.l	#1,d5			; 13 11 9 7 5 3 1 -1
		bpl.s	pixels			; >=0

		cmpa.l	a5,a3			; end of a line Source ?
		bhi.s	read_words 		; >

		tst.b	d6			; low resol ?
		beq.s	no_save 		; yes
;...					...only in medium resolution
		lea.l	-320(a6),a2 
		moveq	#79,d3 			; (320/4)-1
recopy_line:	move.l	(a2)+,(a6)+ 
		dbra.w	d3,recopy_line
		cmpa.l	a6,a4 			; buffer full ?
		bne.s	no_save			; no
		bsr.s	fwrite 			; save 32000 bytes (4 time )
;...					...
no_save:	subq.b	#1,d4 			; number line -1
		beq.s	end_prg 		; =0

		lea.l	-320(a5),a5		; previous line Source
		bra.s	start_line 
;...............................................HIGHT RESOLUTION............
high_resol:	lea.l	32000-80(a5),a5		; last line Source
		move.w	#400,d4
line_h:		moveq.l	#19,d1 			; 80/4 -1
copy_line:	move.l	(a5)+,(a6)+ 
		dbra.w	d1,copy_line
		subq.w	#1,d4 
		beq.s	end_prg 
		lea.l	-160(a5),a5		; previous line Source
		bra.s	line_h
;.........................................................................
end_prg:	cmpi.b	#1,d6 			; meduim resol ?
      		beq.s	fclose 			; yes
      		bsr.s	fwrite 
fclose:		move.w	handle,-(sp) 
      		move.w	#$3E,-(sp) 	 
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
header:		dc.l	$767d0000,$40010000,$c8000000	; low resol
		dc.w	$0400
		dc.l	$7d00
		dc.l	$76f40100,$80020000,$90010000	; medim resol
		dc.w	$0400
		dc.l	$01f400
		dc.l	$767d0000,$80020000,$90010000	; hight resol
		dc.w	$0100
		dc.l	$7d000000

bmp_color:	dc.b	$0,$2,$4,$6,$8,$A,$C,$E,$1,$3,$5,$7,$9,$B,$D,$F
fsize:		dc.l	$0
handle:		dc.w	$0
		END
;*******************************************************************
