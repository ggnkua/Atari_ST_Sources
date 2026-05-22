;rockyone			pour MI-3 MI-9			 22/01/2017
;
;add load image uncompressed					 08.04.2018								 27.03.2018
;
;			OPEN/SAVE PABLO v1.1   .PPP
;			---------------------------
;               This format does not contain a color cycle
;		and does not bytes of resolution
; 
;
;+    0 	33 byte         "PABLO...	Header in ascii
;+   34		 2 byte		$0d,$0a		End string
;+   36 	 ? byte				Size image data+38 in ascii  
;+    ?	 	 2 byte		$0d,$0a		End string
;+    ?		 1 word 	$00,$1d		Flag PPP and PA3		
;+    ?		 1 word				Size image data +38
;+    ?		16 word                 	Color palette
;+    ?		 ? word                 	Words data		
;+    ?	         ? byte	                	Bytes of control
; eof-2		 1 word  			Number of bytes of control
;--------------------------------------------------------------------------
; Res%	0  = PPP 
;	2  = PA3 
; 
;OPEN	The data is reorganiezd in But+33001 for Tny_Open
;	Ppp_Os( L Source, L But+33000, 0 )       yes +33000
;	Tny_Open( L But+33000, L But, L dummy )	 yes +33000
;       The two routine return -2 In low d0  if bad file      
;
;	--------------------------------------------------------
;
;SAVE	Tny_Save( L Source, L But, L dummy ) 
;       Ppp_Os( L But, L But+33000, 1 )       return file size in high d0
;		               
;dummy  est un buffer pour les cycle de couleur pour les image TNY.
;       Inutile ici mais doit exister. 32 octets nul
; 
;--------------------------------------------------------------------------       
   	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a1

	lea.l	header(pc),a3
	moveq.l	#35,d1			; lenght of header -1
	
	tst.w	68(sp)			; open or save ?
	bne.s	save
;..........................................................................
;
;				CONVERT PPP TO TNY
;..........................................................................

	moveq.l	#-2,d0			; R. bad file
test_h:	cmpm.b	(a3)+,(a0)+		; test header
	bne.s	end_prg
	dbra.w	d1,test_h


jump:	cmpi.b	#$0a,(a0)+		; skip file size in ascii
	bne.s	jump

	addq.l	#1,a1
	move.b	(a0)+,(a1)+		; image resolution 

	tst.b	(a0)+			; image compressed ?
	bne.s	convert			; yes

;.........................................................................
	addq.l	#2,a0		; jump file size in hexa

	bsr	palette		; a0 to a1 cpt d3
	movea.l	a0,a6
	move.l	#32000,d6
	bsr	copy_byte	; a6 to a1    d6 to cpt d3
	moveq.l	#2,d0		; flag for basic, image uncompressed
	bra.s	end_prg
;.........................................................................
convert:
   	movea.l	a0,a4
	move.b	(a0)+,d7		; read size data of the image
	lsl.w	#8,d7
	move.b	(a0)+,d7	

	lea.l	-4(a4,d7.w),a4	; point to eof file -2

	move.b	(a4)+,d6	; read number of bytes of control
	lsl.w	#8,d6		;
	move.b	(a4),d6		;	

	sub.w	d6,d7		; Calculating the size of data of image
	subi.w	#38,d7		; Word-38
		
	bsr.s	palette		; a0 to a1 cpt d3

	move.w	d6,(a1)+	; write the number of byte of control

	move.w	d7,d5		; write the number word of image data
	lsr.w	#1,d5		;
	move.w	d5,(a1)+	;
;				; Source a0 point to words image data
; 				; Source a6 point to bytes of control
;				; But    a1   "    "   "   "     "
	lea.l	0(a0,d7.w),a6
	bsr.s   copy_byte	; a6 to a1    d6 to cpt d3
	bsr.s	copy_word	; a0 to a 1   cpt d7

	moveq.l	#0,d0		;R. not error
;..........................................................................

end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts
;..........................................................................
;
;				CONVERT TNY TO PPP
;.........................................................................

save:	addq.l	#1,a0		; tny read to buf+1
	movea.l a1,a4           ; to calculate file size

	move.b	(a0)+,d0
 	cmp.b   #3,d0		; Cycle color in Source ?
	bmi.s   not_cycle	; No ! 
	subi.b	#3,d0
	addq.l  #4,a0		; Jump color cycle
 
not_cycle:    
	lea.l	32(a0),a6	; Source point to number of byte of control

write_header:
	move.b	(a3)+,(a1)+	
	dbra.w	d1,write_header

	move.w	(a6)+,d6	; read the number of byte of control
	move.w	(a6)+,d7	; read the number of word of data
;				; Source a6 point to first bytes of control

	lsl.w	#1,d7		; 
	move.w	d6,d5		; total data +38
	add.w	d7,d5		;
	addi.w	#38,d5		;

	bsr.s 	hex_ascii       ; write total data in ascii
	move.b	#$0d,(a1)+
	move.b	#$0a,(a1)+
	move.b	d0,(a1)+	; write image resolution
	move.b	#$1d,(a1)+	; write byte compressed

	move.b	d5,1(a1)	; write total data
	lsr.w	#8,d5
	move.b	d5,(a1)
	addq.l	#2,a1	

	bsr.s	palette         ; a6 to a1

	lea.l	0(a6,d6.w),a0	; Source a0 point to address word data

	bsr.s   copy_word	; a0 to a1
	bsr.s   copy_byte	; a6 to a1

	move.b  d6,1(a1)	; write number bytes of control
	lsr.w	#8,d6
	move.b	d6,(a1)
	addq.l	#2,a1

	suba.l  a4,a1		; calculat file size
	move.l	a1,d0		; return file size
	
	bra.s   end_prg
;--------------------------------------------------------------------------
palette:	moveq.l	#31,d3		; 16 color
color:		move.b	(a0)+,(a1)+
		dbra.w	d3,color
		rts
;.......................................
copy_word:	subq.b	#1,d7
copy_w:		move.b  (a0)+,(a1)+
		dbra.w  d7,copy_w
		rts  
;.......................................
copy_byte:	move.w	d6,d3
		subq.b	#1,d3
copy_b:       	move.b  (a6)+,(a1)+
		dbra.w  d3,copy_b
		rts            
;......................................

hex_ascii:	moveq.l	#0,d2
		move.w	d5,d1
decimal:	ext.l	d1
		beq.s	ascii	
		divu.w	#10,d1
		swap	d1
		lsl.l	#4,d2
		add.b	d1,d2
		addi.b	#1,d2
		swap	d1
		bra.s	decimal
ascii:		move.b	d2,(a1)
		andi.b	#$f,(a1)
		addi.b	#$2f,(a1)+
		lsr.l	#4,d2
		bne.s	ascii
		rts	
;......................................
header:	dc.b	'PABLO PACKED PICTURE: Groupe CDND ',$0d,$0a
	
	end
;**************************************************************************