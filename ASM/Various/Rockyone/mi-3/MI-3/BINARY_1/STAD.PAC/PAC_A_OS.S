****************************************************************************
; rockyone			pour MI-3 MI-9  	        17.11.2018
;      						 
;
;		Arabesque	files ABM <=6400*400
;		Stad    	files PAC  = 640*400
;		
;		idendic compression, but different header
;		-----------------------------------------
;		
;	Open :	Call pac_os( L Source, L But, Op% )
;	save :  call pac_os( L But, L Source, Op% ) 
:
;	Op% 	0 to unpack
;		1 for packed in Stad format
;		2 for packed in Arabesque format "9a"
;
;	But     32034 byte for unpack  - my buffer is not empty -
;		32512 byte for packed  - my buffer is empty -
;
; Rerturn in low d0 :  	0  error-free loading
; 			-1 bad file
;			-2 image too big
;			Or file size for backup
;
;Warning: For the decompression of the ABM files, i did not make a mask
;   	  for the last byte of the lines because is was not useful for
;	  MI-3 and MI-9.
;   
;--------------------------------------------------------------------------
; Format 	  PAC		
;
; +0		'PM85'	/ 'PM86	
; +4		id_byte	
; +5		id_pac
; +6		special byte
; +7		data
;........................................................................
; Format	ABM     horizontal compression, 2 header !
;
; +0		'ESO8'	Id ABM
; +4		'9A"	Id format
; +6		?	pixel image width
; +8		?	number of lines
; +10		1       Nombre de plan		
; +12		?	image block size    = File size - 14
; +14		?	id_byte		
; +15		?	id_pac		
; +16		?	special byte	
; +17		?	compressed image data
;
; +0		'ESO8'	Id ABM
; +4		'8B'	Id format
; +6		?	pixel image width
; +8		?	number of lines
; +10		?	size of the first image block	; Total =
; +12		?	size of the second image block	;  file size - 18
; +14		?	size of the third image block	;
; +16		?	size of the fourth image block	;
; +18		?	id_byte		
; +19		?	id_pac		
; +20		?	sp‚cial byte	
; +21		?	compressed image date	
;--------------------------------------------------------------------------
;
;Open : used d0-d6 / a0-a4
;Save : used d0-d7 / a0-a4

		movem.l	d1-d7/a0-a6,-(a7)
		movem.l	60(sp),a0-a1
	
		tst.w	68(sp)		; open or save ?
		bne	backup
			
		move.l	(a0)+,d3	; read id file

		cmpi.l	#"ESO8",d3	; id file ABM ?
		beq.s	file_abm

		cmpi.l	#"pM86",d3	; id file PAC vertical ?
		beq	vertical
		
		moveq.l	#0,d5		; for file 640 * 400
		moveq.l	#0,d6		;  "    "   "     "
		cmpi.l #"pM85",d3	; id file PAC horyzontal ?
		beq.s	suite
		bne	bad_file	
				
;..................................................Read header ABM

file_abm:	lea.l	10(a0),a2	; address d' id_byte

		move.w	(a0)+,d3	; File format   
		cmpi.w	#'9a',d3	;	?
		beq.s	largeur		;
;					;
		cmpi.w	#'8b',d3	;	?
		bne	bad_file	;

		addq.l	#4,a2		; address of id_byte

largeur:	moveq.l	#0,d5
		move.w	(a0)+,d5	; image width in pixels
		subi.w	#640,d5		; > 640 ?
		bgt	too_big	

		neg.w	d5		
		divu.w	#8,d5		
		bclr.b	#0,d5		; image width in bytes

		move.w	(a0)+,d6	; hauteur
		subi.w	#400,d6		; > 400 ?
		bgt.s	too_big		 

		mulu.w	#80,d6		; d6 <= 0

; number of plan and size block image useless

		movea.l	a2,a0		; adresse of id_byte

;--------------------------------------------------------------------------
;				horyzontal depactage
;--------------------------------------------------------------------------

suite:		bsr.s	unpack_init

		lea.l	80(a1),a2	; end of a screen in bytes
		movea.l a2,a3		; end of an image line in bytes
		suba.w	d5,a3		; d5 is >= 0 
		adda.w	d6,a4		; d6 is <= 0 (a4 = a1 + 32000-d6)
 

horyzontal:	moveq.l	#0,d5		; clear the repeat counter
		move.b	(a0)+,d4  	; read a byte
		cmp.b	d0,d4     	; compared with a id_byte
		beq.s	l_id_byte	; if equal

		cmp.b	d2,d4		; compared with special_byte
		beq.s	l_special_byte	; if equal

othrewise:	bra.s	recopy_data	; copy just once - d5=0 -
*		move.b	d4,(a1)+  	; copy and increments
*		cmpa.l	a1,a3
*		bne.s	horyzontal
*		bra.s	finish_a_line

l_id_byte:	move.b	d1,d4     	; retype Pack_byte
		move.b	(a0)+,d5	; number of repetition
		bra.s	recopy_data  	
 
l_special_byte:	move.b	(a0)+,d4  	; byte copy
		move.b	(a0)+,d5  	; Number of repetition

recopy_data:	move.b	d4,(a1)+  	; Copy and increments
		cmpa.l	a1,a3		; End of an image line ? <=80 bytes
		beq.s	finish_a_line	; Come back to next_data if d5 >= 0
next_data:	dbra.w	d5,recopy_data

		bra.s	horyzontal

;.......................................
finish_a_line:	cmpa.l	a1,a2		; end of a line of 80 bytes ?
		beq.s	new_line
		move.b	#$0,(a1)+
		bra.s	finish_a_line

new_line:	adda.w	#80,a3
		adda.w	#80,a2

next_line:	tst.w	d5
		bgt.s	next_data	; if >=0 continue to copy

		cmpa.l	a1,a4		; end of the unpack ? 
		bhi.s	horyzontal	; > 

		suba.w	d6,a4		; d6 is <= 0
clr_lines:	cmpa.l	a1,a4
		ble.s	end_open	
		move.b	#$0,(a1)+
		bra.s	clr_lines
;........................................................................			
end_open: 	moveq.l	#0,d0		; not_erreur
end_save:
end_error:	movem.l	(a7)+,d1-d7/a0-a6
		RTS

bad_file:	moveq.l	#-2,d0		
		bra.s	end_error
too_big:	moveq.l	#-4,d0
		bra.s	end_error
;--------------------------------------------------------------------------
unpack_init:	move.b	(a0)+,d0	; id_byte
		move.b	(a0)+,d1	; id_pac
		move.b	(a0)+,d2	; sp‚cial byte

		move.w	#2,(a1)+	; write resol
		move.l	#$fff0000,(a1)	; write 2 colors 
		lea.l	32(a1),a1	; Start of the image in the 
;					; destination buffer
		movea.l a1,a3		; Start colomn, first line
		move.b	#80,d3		; 80 column
		lea.l	32000(a1),a4	; End of the destination buffer
		RTS
;-------------------------------------------------------------------------
;			 	vertical depactage		
;-------------------------------------------------------------------------
; free:	d6-d7 / a2, a5-a6
;------------------------
;
; a0 		source
; a1 a3 a4 	but
; d0 d1 d2
; d3		80 column
; d4		read byte image
; d5		number of repeat 
;
;..........................................................................

vertical:	bsr.s 	unpack_init

read_new_cmd: 	moveq.l	#0,d5           ; Clear the repeat counter
		move.b	(a0)+,d4  	 
		cmp.b	d0,d4		; Compared with id_byte
		beq.s	id_byte     	

		cmp.b	d2,d4     	; Compared with special_byte
		beq.s	special_byte  	;

oterwise:	bra.s	repeat_data	; Copy just once - d5=0 -

id_byte:	move.b	d1,d4     	; Pack_byte
		bra.s	read_counter	; ...and recopy pack_byte

special_byte:   move.b	(a0)+,d4   	; byte to repeat  
read_counter:	move.b	(a0)+,d5	; Number of repetition

repeat_data: 	move.b	d4,(a1)
copy_data:	lea.l	80(a1),a1	; Next line
		cmpa.l	a1,a4		; End of a column ?
		bgt.s	continued	; >  a1+400 lines is always bigger! 

		subq.b	#1,d3		; Decrement counter column
		beq.s	end_open
		
		suba.w	#31999,a1	; next column

continued:    	dbra.w	d5,repeat_data
		bra.s	read_new_cmd	; Read a new command byte
;--------------------------------------------------------------------------						
;
;			BACKUP FORMAT STAD OR ARABESQUE
;
;--------------------------------------------------------------------------

backup:		exg.l	a0,a1
		lea.l	34(a0),a0		; jump resol and palette
		
;.........................................................................
; Counting and sorting identical data  - 0 to 255 -

		movea.l	a0,a2
		lea.l	32000(a1),a3		; to keep the buffer clean
		move.l	#32000-1,d0		; end  image -1 for dbra

loop_1:		moveq.l #0,d1
		move.b	(a2)+,d1
		lsl.w	#1,d1			;  to ave an even address
		addq.w	#1,0(a3,d1.w)
		dbra.w	d0,loop_1

;.........................................................................
; Research: id_byte, pack_byte, special_byte

		move.w	#255,d0			; loop counter only

		movem.l	(a1),d1-d7		; al equal to zero

*		moveq.l	#0,d1			; nb_pack
		move.l	#32000,d2		; nb_spe
*		moveq.l	#0,d3			; reading register
*		moveq.l	#0,d4			; id_bit
*		moveq.l	#0,d5			; pack_byte
*		moveq.l	#0,d6			; special_byte
*		moveq.l	#0,d7			; index value

loop_2:		move.w	(a3)+,d3
		cmp.w	d3,d1		; Search for the most used value  
		bpl.s	no_pack			; d3<=d2   positive
		move.w	d3,d1			; nb_pack
		move.w	d7,d5			; pack_byte 

		bra.s	no_spe	

no_pack:	cmp.w	d3,d2		; Search for the least used value
		bmi.s	no_spe			; d3>d2    negative
		move.w	d3,d2			; nb_spe
		move.w	d6,d4			; id_byte
		move.w	d7,d6			; special_byte
no_spe:		addq.w	#1,d7
		dbra.w	d0,loop_2
;..........................................................................

		lea.l	32000(a0),a2		; end of buffer source

		movea.l	a1,a3
		
		cmpi.w	#1,68(sp)		; Backup format ?
		beq.s	format_PAC
;............................................... ARABESQUE header
		move.l	#'ESO8',(a3)+		; id ABM 
		move.w	#'9a',(a3)+		; id format
		move.l	#$02800190,(a3)+	; 640 400
		move.w	#1,(a3)+		; Number of plans
		movea.l	a3,a4
		addq.l	#2,a3			; Reserved for file size 
		bra.s	next_part
		
format_PAC:	move.l	#'pM85',(a3)+		; Horizontal header of STAD

;--------------------------------------------------------------------------
;			  COMPRESSION HORYZONTAL
;--------------------------------------------------------------------------

next_part:	move.b	d4,(a3)+		; write id_byte
		move.b  d5,(a3)+		;       id_pack
		move.b	d6,(a3)+		;       id_special

		movem.l	(a1),d1-d3		; All equal to zero

boucle_1:       move.b	(a0),d1			; Read 3 bytes image
		move.b	1(a0),d2
		move.b	2(a0),d3

		cmp.b	d1,d2      		; 2 equal byte ? 
		bne.s	unique_data		; <>

		cmp.b	d1,d5			; equal to pack_bytes ?
		beq.s	pack_id_byte		; yes
    
		cmp.b	d2,d3			; 3 equal byte ?
		beq.s	pack_spec_byte		; yes

		bra.s	unique_data		; can be equal to...

;...........................................ID_BYTE
pack_id_byte:	move.b	d4,(a3)			; save id_byt
		addq.l	#1,a0			; increment buffer SOURCE

boucle_2:	cmp.b	(a0),d5			; equal to pack_byte ?
		bne.s	fin_bl_2		; non

		cmpi.b	#255,1(a3)		; complete block ?
		beq.s	fin_bl_2		; yes

		cmpa.l	a2,a0     		; end buffer SOURCE ?
		bge.s	fin_bl_2		; yes

		addq.l	#1,a0			
		addq.b	#1,1(a3)		; increment repeat number

		bra.s	boucle_2
fin_bl_2: 	addq.l	#2,a3			; increment buffer BUT
		bra.s	end_source

;...........................................SPECIAL_BYTE
pack_spec_byte:	move.b	d6,(a3)   		; save special_byte 
		move.b	d1,1(a3)  		; save data byte 
		addq.l	#1,a0			; increment buffer SOURCE
boucle_3:	cmp.b	(a0),d1
		bne.s	fin_bl_3	

		cmpa.l	a2,a0     		; End of the  image ?
		bge.s	fin_bl_3		; >

		cmpi.b	#255,2(a3)		; complete block ?
		beq.s	fin_bl_3

		addq.l	#1,a0		; increment the buffer SOURCE
		addq.b	#1,2(a3)	; increment the repeat counter
		bra.s	boucle_3

fin_bl_3: 	addq.l	#3,a3		; increment the buffer BUT
		bra.s	end_source

;...........................................DATA UNIQUE

unique_data: 	cmp.b	d1,d4			; equal to id_byte ?
		beq.s	pack_spec_byte

		cmp.b	d1,d6			; equal to special_byte ?
		beq.s	pack_spec_byte

		move.b	(a0)+,(a3)+		; copy byte unique
;...............................................

end_source:	cmpa.l	a2,a0			;  ?
		bpl.s	fini			; yes

		bra.s	boucle_1
;...............................................
fini:  		suba.l	a1,a3     		
		move.l	a3,d0			; Return file size

		cmpi.w	#1,68(sp)		; backup format ?
		beq	end_save		; end format STAD

		move.w	d0,(a4)
		subi.w	#14,(a4)
		bra	end_save		; end format ARABESQUE

		END
;------------------------------------------------------------------------

