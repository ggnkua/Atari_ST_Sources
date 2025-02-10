;rockyone			for MI-3 and MI-9	        29-09-2017
;suppression test resolution					14.07.2018
;modif appel							10.01.2021
;
;		OPEN STOS PP1-3 ( PIC_PAC.PRG)
;
;The resolution of the image is equal to the number of the file extention.
;
;
;Source Image  PP1-3
;BUT	Buffer 32034 bytes
;Rez%	number of the file extention -1
;
;		CALL pp_open( L Source, L but, dummy%, rez%, dummy% )
;				60	 64	68	70
; Return in low d0 	error	-2 bad file
;				
;
; The image planes, are compressed one after the other.
; Each planes is divided into blocks of five lines that are compressed
; vertically bytes after bytes.
;........................................................................
;
; +0	L	$06071963	id stos
; +4    W	$0  $1  $2  Compression mode  	; This is not the 
;		 	4   2   1	As number a plan    ; resolution byte 
;		 		   							; of the image
; +6	W	$0000		alway ?	 
; +8	W	$0000		alway ?	 
; +10	W	$14 $28	$28	word by plane of a line   20 40 40  (lsl 4
;							      = width pic )
; +12	W	$28 $28 $50	bloks of lines by  plane  40 40 80
; +14	w	 ?   		?
; +16	w	$05			number of lines in a blok - aLways 5 ? - 
; +18	w	$03			? -compression mode = number plane-1
; +20	L	P0 			offset cmd0
; +24   L	P1 			offset cmd1
; +28   B	?           5 words	? 			
; +38	W	16 word 	always 16 colors
; +70	B	Literal
; +P0	B	cmd0
; +P1  	B	cmd1
;-------------------------------------------------------------------------
	movem.l	d1-d7/a0-a6,-(sp)

	movem.l	60(sp),a0-a1
	moveq.l	#-2,d0			;R. bad file

    cmpi.l	#$06071963,(a0)	; id  stos packed
	bne	error
    move.w  4(a0),d1		; compression mode 0,1,2 
	cmpi.b	#3,d1
	bpl	error				; >2

*	tst.w	6(a0)
*	bne	error
*	tst.w	8(a0)
*	bne	error
;...............................................
	move.w	70(sp),(a1)+	; image resolution
	lea.l	38(a0),a2	
	moveq.l	#7,d0			; 16 colors
colors:		
	move.l	(a2)+,(a1)+
	dbra.w	d0,colors
;................................................ 
;d1 compresson mode					+4   	0 1 2
;d3 offset word
;d4 byte by line 					+10
;d5 number  word by plane of line   +10
;d6 number byte by word				=2
;d7 number lines by block  alway 	5 ???
 
	moveq.l	#4,d0			
	lsr.b	d1,d0				; 4,2,1 plan compression
	move.b	d0,nb_plane
	move.w	d0,d3			;		4  2  1
	lsl.b	#1,d3			; offset word	8  4  2
	subq.b	#2,d3					6  2  0

	move.w	10(a0),d4		; 20  40 40
	mulu.w	d0,d4		 	; 80  80 40
	lsl.w	#1,d4	 	        ;160 160 80 byte by line

;a0 a2 a3 a4 Source
;a1 a5 a6    But
;d0	     Mask0 
;d1	     Mask1
;d2	     For test
;a2 points already 70(a0)			; adr literal

	moveq.l	#0,d2
	movea.l	a0,a3
	movea.l	a0,a4
    adda.l	20(a0),a3		; adr cmd0
    adda.l	24(a0),a4		; adr cmd1	
	move.w	#$80,d0			; mask0
	move.b	(a4),d2
	andi.b	#$80,d2	
	beq.s	not_and
	
	addq.l	#1,a3
not_and:	move.w	#$40,d1			; mask1
		
all_plane:	
	movea.l	a1,a5			; start planes
	move.w	12(a0),nb_block		; 40,40,80 blocks by plane

block_line:	
	move.w	10(a0),d5		; 20,40,40 words by line 

word_plan:	
	moveq.l	#2,d6			; 2 bytes by word 
deux_byte:	
	move.w	16(a0),d7		; number line by block
	movea.l	a5,a6		

line_block:	
	move.b	(a3),d2			; cmd0
	and.b	d0,d2			;    ( z=1 if resultat =0 )
	beq.s	recopy			  
	addq.l	#1,a2

recopy:		
	move.b	(a2),(a6)		; save byte
	lsr.b	#1,d0			; 
	bhi.s	next_line		; >0
	
	move.b	#$80,d0
	move.b (a4),d2			; cmd1
	and.b	d1,d2                   
	beq.s	masq1
	
	addq.l	#1,a3			; pointer cmd0

masq1:
	lsr.b	#1,d1			; mask1 
	bhi.s	next_line		; >0
	
	move.b	#$80,d1			;
	addq.l	#1,a4			; pointer cmd1

next_line:	
	subq.w	#1,d7			; line -1
	beq.s	next_byte		
	
	adda.w	d4,a6			; next line of a blok
	bra.s	line_block		; >0

next_byte:	
	addq.l	#1,a5
	subq.b	#1,d6	
	bhi.s	deux_byte		; >0
		
next_word:	
	adda.w	d3,a5			; next word of a plane
	subq.w	#1,d5			; end of a blok ?
	bhi.s	word_plan		; >0 next colun of a blok	
		
	lea.l	1(a6,d3.w),a5

next_block:	
	subq.w	#1,nb_block			;blok_line,-1
	bhi.s	block_line			; >0
		
	addq.l	#2,a1				; point next plane
	subq.b	#1,nb_plane
	bhi.s	all_plane			; >0

;...............................................
	moveq.l	#0,d0				; error if < 0
error:		
	movem.l	(sp)+,d1-d7/a0-a6	
	rts
;...............................................
nb_block:	dc.w	0
nb_plane:	dc.b	0

    END
