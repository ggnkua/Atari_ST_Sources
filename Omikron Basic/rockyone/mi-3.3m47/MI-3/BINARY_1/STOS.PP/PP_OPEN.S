;rockyone		for MI-3 and MI-9			29-09-2017
;suppression test resolution									14.07.2018
;modif appel													10.01.2021
;modif infos													24.11.2024
;réafectation des registres                                     20.11.2024
;revision du code                                               26.11.2024
;ajout ouverture fichier STOS ".MBK"                            26.12.2024
;control 							01.02.2025									28.01.2025
;                                                               
;			OPEN "PP1-3"  PIC_PAC.PRG / MI-3M.PRG
;                       OPEN "MBK"    STOS.PRG    / MI-3M.PRG        
;The resolution of the image is equal to the number of the file extention.
;
;
;Source 	Image  PP1-3
;BUT		Buffer 32034 bytes
;Rez%		number of the file extention -1
;                       A0        A1
;		CALL pp_open( L Source, L but, dummy%, rez%, dummy% )
;						60	 	64		68		70	72
;
; Return in low d0 	error	-2 bad file
;				
;
; The image planes, are compressed one after the other.
; Each planes is divided into blocks of five lines that are compressed
; vertically bytes after bytes.
;........................................................................
;-------------------------------------------;
;           PIC PACK FORMAT
;-------------------------------------------;
; +0	L	$06071963	id stos
; +4    W	$0  $1  $2  	pic_pac always $1
; +6	W	$0000		alway ?	 
; +8	W	$0000		alway ?	 
; +10	W	$14 $28	$28	word by plane of a line   20 40 40 
; +12	W	$28 $28 $50	bloks of lines by  plane  40 40 80
; +14	w	 ?   		?                         20
; +16	w	number of lines in a blok              5  5  5
; +18	w	compression mode                       3  3  3
; +20	L	P0 			offset cmd0
; +24   L	P1 			offset cmd1                     
; +28   B	?           5 words	? 			        
; +38	W	16 word 	always 16 colors            
; +70	B	Literal                                 
; +P0	B	cmd0                                    
; +P1  	B	cmd1                                    
;-------------------------------------------;
;                MBK FORMAT
;-------------------------------------------;
;             	Id MBK:   "Lionpoubnk"
; +0    L   	$4c696f6e   "Lion"
; +4    L   	$706f7562   "poub"
; +8    W   	$6e6b       "nk"
; +10   W   	$0000   ?  
; +12   W     	$0000	?
; +14   W   	$8100   Bank_type
; +16   W   	Poids de l'image compréssée avec ou sans 
;           	les 18 octets de l'entête.
;           	image_data= andi.W #$ff00, 16(a0)
; +18	L	$06071963	Id STOS/PICPACK
; +22   W	resolution image            0  1  2 Only MBK & MI-3
; +24   w   	x_offset (mots)                                 
; +26   X   	y_offset (pixel)                                   
; +28	W	word by plane of a line    20   40   40 
; +30	W	nombre de ligne dans un bloc     
; +32	w	$80C4   		?                      
; +34	w	nombre de bloc de lignes   
; +36	w	$3 Pic_Pac, $2 MBK & MI-3  
; +38	L	offset cmd0
; +42   L	offset cmd1
; +46   B	5 words	? 			
; +56	W	16 word 	always 16 colors
; +78	B	Literal
; +P0	B	cmd0
; +P1  	B	cmd1
;-------------------------------------------------------------------------
	movem.l	d1-d7/a0-a6,-(sp)

	movem.l	60(sp),a0-a1
	subq.w	#1,70(sp)		; r‚solution PP1-3

	moveq.l	#-2,d0			; bad file

	cmpi.l	#$06071963,(a0) 	; id  stos packed
	beq.s   file_picpack
 
	cmpi.l  #$06071963,18(a0)	; id  stos packed  
	bne	error
	
	cmpi.b  #$81,14(a0)		; Type de "bank" de fichier "MBK" 
	bne	error			; 
    
	adda.l  #18,a0
	move.w	4(a0),70(sp)     	; r‚solution de l'image ".MBK"

file_picpack:
	move.w  4(a0),d1		;  r‚solution compression ?
	cmpi.b	#3,d1
	bpl	error			; >2


*	tst.w	6(a0)
*	bne	error
*	tst.w	8(a0)
*	bne	error
;...............................................
	move.w	70(sp),(a1)+		; image resolution
	lea.l	38(a0),a2		; poinTe palette Degas
	
	moveq.l	#7,d0			; 16 colors
colors:		
	move.l	(a2)+,(a1)+
	dbra.w	d0,colors
;................................................ 
; d1     	4(a0)  resolution compression	    0 1 2
; d2 	        Offset ligne dans un plan d'image
; d3		Offset Word dans un plan d'image    6 2 0
; nb_plane	nombre de plan dans l'image
; nb_block	nonbre de bloc de cinq lignes dans un plan d'image
; d4	 10(a0) nombre de words dans une ligne d'un plan d'image
; d5	 16(a0) nonbre de lignes dans un bloc de ligne.  alway 5 ? 
; d6            number byte by word  alway 2

 
	moveq.l	#4,d0			
	lsr.b	d1,d0			; 
	move.b	d0,nb_plane		;  4|  2|  1| nombre de plan
	move.w	d0,d3			;  4|  2|  1|
	lsl.b	#1,d3			;  8|  4|  2|
	subq.b	#2,d3			;  6|  2|  0| offset Word
	move.w	10(a0),d2		; 20| 40| 40| word par lignes
	mulu.w	d0,d2		 	; 80| 80| 40|
	lsl.w	#1,d2           	;160|160| 80| byte by line

;a0 a2 a3 a4 	Source
;a1 a5 a6    	But
; d0		cmd0%
; d1		cmd1%
; d7	     	For test
; a2 		points already 70(a0)	; adr literal

	moveq.l	#0,d7
	movea.l	a0,a3
	movea.l	a0,a4
    	adda.l	20(a0),a3		; adr cmd0
    	adda.l	24(a0),a4		; adr cmd1	
	move.w	#$80,d0		    	; mask0
	move.b	(a4),d7         	; Lire le premier octet de cmd1
	andi.b	#$80,d7	        	; si resultat = 0, Bit Z=1
	beq.s	not_and         	; yes 	

	addq.l	#1,a3           ; incrementer l'adressage des commandes
;				;  

not_and:	
    	move.w	#$40,d1	    		; Init mask1 
		
all_plane:	
	movea.l	a1,a5			; start planes
	move.w	12(a0),nb_block		; 40,40,80 blocks by plane

all_blocks_lines:	
	move.w	10(a0),d4		; 20,40,40 words by line 

;-------------------------------------------;
; Décompression des cinq lignes             ;   
;-------------------------------------------;     	

words_plan:	
	moveq.l	#2,d6		; 2 bytes by word 

deux_byte:	
	move.w	16(a0),d5	; number line by block
	movea.l	a5,a6		

lines_block:	
	move.b	(a3),d7		; cmd0
*	beq.s   recopy		; fonctionnel, mais est_ce plus rapide 	? 
	and.b	d0,d7		; z=1 si resultat=0     
	beq.s	recopy		; si z=1
  
	addq.l	#1,a2       	; pointer l'octet suivant 

       
recopy:		
	move.b	(a2),(a6)	; save byte image décompressé
	ror.b	#1,d0       	; $40 $20 $10 $8 $4 $2 $1 $80...
	bhi.s	next_line	; >0 (<> $80)
	
	move.b (a4),d7		; cmd1
*	beq.s   masq1		; fonctionnel, mais est-ce plus rapide ?
	and.b	d1,d7       	;         
	beq.s	masq1		;si z=1
	
	addq.l	#1,a3		; cmd0 incrementer l'adresse des commandes 
                                        
masq1:                    
	ror.b	#1,d1                           
	bhi.s	next_line	; >0 (<> $80)     
	                                        
	addq.l	#1,a4		; cmd1 incrementer l'adresse des commandes 

next_line:	
	subq.w	#1,d5			; line -1
	beq.s	next_byte		; 

	adda.w	d2,a6			; Next line in a block
	bra.s	lines_block		; >0

next_byte:	
	addq.l	#1,a5           ; Pointe sur le deuxième byte d'un word
	subq.b	#1,d6	        ; Bytes by word
	bhi.s	deux_byte	; >0
		
*next_word:	
	adda.w	d3,a5		; Prochaine colonne de word dans le plan 
	subq.w	#1,d4		; End of a word on the line ?
	bhi.s	words_plan	; >0 next colun of a block_line	
;                                           
;-------------------------------------------; 
*next_block_line:			
	lea.l	1(a6,d3.w),a5
	subq.w	#1,nb_block		; blocks-1
	bhi.s	all_blocks_lines	; >0 next five lines

*next_plane: 		
	addq.l	#2,a1			; point next plane
	subq.b	#1,nb_plane
	bhi.s	all_plane		; >0                                         
;-------------------------------------------; 
	moveq.l	#0,d0			; error if < 0
*	suba.l	a0,a4
*	move.l	a4,d0			; nombre d'octets lus
error:		
	movem.l	(sp)+,d1-d7/a0-a6	
	rts
;                                           
;-------------------------------------------; 	
nb_block:	dc.w	0
nb_plane:	dc.b	0

    END
