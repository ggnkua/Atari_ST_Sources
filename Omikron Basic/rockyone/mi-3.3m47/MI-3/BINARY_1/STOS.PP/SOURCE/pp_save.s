;rockyone                  for MI-3 and MI-9        	        05/01/2025	 		 17/10/2024
;								 							
;   
;       	  		  Save PP1-3 et MBK
;					  *****************
; 
;The resolution of the image is equal to the number of the file extention.
;                               
; Source: Buf_Ecr       Buffer 32066+160 bytes Image PI1-3 
; But   : Buf_Pic       Buffer 78320 bytes equal $00
;       : Buf_pic+34000 Buffer temporaire cmd0 22.160 bytes
;       : buf pic+56160 Buffer temporaire cmd1 22.160 byte  
;Format%	= 0	: Sauvegarde format Pic_pac  "PP?"
;			= 1 : Sauvegarde format Stos     "BNK"                              
;                               
;               A0         A1                
;    call( L buf_pic, L buf_ecr, W dummy, W Format%, W dummy%)
;              60         64        68       70       72                              
; 
;
; The image planes, are compressed one after the other.
; Each planes is divided into blocks of five lines that are compressed
; vertically bytes after bytes.
;
; Lecture des premiers octets par plan en basse résolution
;		   ________________________________________________
;                  | plan1 | plan2 | plan3 | plan4 | plan1 | ...
;           line 1 | 1  6  |       |       |       | 11 16 |
;           line 2 | 2  7  |       |       |       | 12 17 | 
;           line 3 | 3  8  |       |       |       | 13 ...|
;           line 4 | 4  8  |       |       |       | 14    |  
;           line 5 | 5  10 |       |       |       | 15    |  
;           line 6 
;           line 7
;           ...
;................................................................'.........
;Format des fichiers ."pp1-3" de "Pic-Pac.prg"    
;                                                                   
; +0	L	$06071963	Id stos                                             
; +4    W	0  1  2		Compression mode  	              
;			4  2  1   	as number a plan                      		 		   							                             
; +6	W	0	    	alway ?	                                            
; +8	W	0	    	alway ?	                                            
; +10	W	20 40 40   	Number word for a plan line (lsl 4 = width pic)     
; +12	W	40 40 80    Number of groups of five lines per plan
; +14	w	?   	    ?                                                   
; +16	w	5	    	Number of lines in a blok - aLways 5 ? -            
; +18	w	3	    	Unused, compression mode for this format ?                  
; +20	L	P0 	    	offset Cmd0                                         
; +24   L	P1 	    	offset Cmd1
; +28   B	?           5 words	? 			
; +38	W	16 word     always 16 colors
; +70	B	Literal     
; +P0	B	cmd0        
; +P1  	B	cmd1        
;                           
;..........................................................................


;..........................................................................


;..........................................................................
	movem.l d1-d7/a0-a6,-(sp)
	movem.l 60(sp),a0-a1      
	exg.l   a0,a1                   ; exg   Destination/Source
;       ______________________________    
;       | A0   buffer ".PI?" Degas   |
;       | A1   buffer ".PP?" Pic_Pac |
;       ------------------------------   
;
;Source :      
;	        a0  incrémentation des plans d'image                               
;	        a3  incrémentations des blocks de cinque lignes
;	     	a3  incrémentation des colonnes dans un block de ligne
;			a4  incrémentation des lignes dans un block de ligne
;	        a4  adresse de lecture des bytes à compresser
;
;Destination:
;	     a1+70  adresse de sauvegarde litéral
;	        a5  adresse de sauvegarde temporaire des masques  "cmd0"
;	        a6  adresse de sauvegarde temporaire des masques  "cmd1"
;
;param:     A2
            
; d0		cmd0%
; d1		cmd1%
; d2		Offset line
; d3		Offset Word  
; nb_plane	nombre de plan dans l'image
; nb_bloc	nonbre de bloc de cinq lignes dans un plan d'image
; nb_word   nombre de words dans une ligne d'un plan d'image
; d4        inutilisé
; d5		nonbre de lignes dans un bloc de ligne
; d6		nombre de byte dans un Word
; d7   		valeur dans un octet
;--------------------------------------------------------------------------
	movem.l	(a1),d0-d7
    move.w	(a0),d0   ; resolution image Dégas

  	bsr		init_param	

	tst.w	70(sp)				; 
	beq.s	format_picpac

	move.l	#$4c696f6e,(a1)+	;ID MBK
	move.l	#$706f7562,(a1)+	;
	move.w	#$6e6b,(a1)+		;	
	clr.l	(a1)+
	move.w	#$8100,(a1)+		; bank_type
	clr.w	(a1)+				; poids de l'image compressé

format_picpac:	
    move.l  #$06071963,(a1)		; ID STOS/PICPACK
    move.w  (a0),4(a1)        	; résol image inutilisé par PIC_PAC.PRG 
*    clr.l	6(a1)
    move.w  4(a2),10(a1)		; nb_word
    move.w  2(a2),12(a1)		; nb_block
*    clr.w   14(a1)          
    move.w  #5,16(a1)			; 5 lignes par bloc
    move.w  #3,18(a1)       	; Mode de compression
		
	movea.l	a1,a5
	adda.l	#34320,a5       ; Cmd0 buffer temporaire 22000 bytes
	movea.l	a1,a6
	adda.l	#56320,a6       ; Cmd1 buffer temporaire 22000 bytes
    move.l  a5,20(a1)       ; Sauvegarde adresse pour calcul taille buffer 
    move.l  a6,24(a1)       ; Sauvegarde adresse pour calcul taille buffer 	
;...........................................
;   Copie de la palette
;...........................................
	lea.l   2(a0),a0            ; a0 pointe sur la palette Degas
	lea.l   38(a1),a1           ; A1 pointe sut la palette Stos
	moveq.l #7,d1               ; Palette de 16 couleurs
copy_palette:
	move.l  (a0)+,(a1)+
	dbra    d1,copy_palette   

;   A0 pointe sur data imaga Degas    
;   A1 pointe sur data literaux compréssé
;   
	move.l	#$80,d0				; initialisation de CMD0
	move.l	#$40,d1				; initialisation de CMD1
*	move.b	(a0),(a1)
;-------------------------------------------;
; incrémentation des plans d'image
;-------------------------------------------;
all_plane:
	subq.w	#1,nb_plane
	bmi.s	fin_pic

	movea.l a0,a3               ; Début d'un plan d'image
	move.w	2(a2),nb_bloc 	    ; nombre de bloc de lines 
    
;-------------------------------------------;
; incrémentation des bloks de cinq lignes
;-------------------------------------------;
all_blocks_lines:
	subq.w	#1,nb_bloc
	bmi.s	next_plane	

	move.w	4(a2),nb_word       ; nb_word by line plane                                  
;-------------------------------------------;
; compression des cinq lignes                
;-------------------------------------------;                           
colonnes:    
	subq.w	#1,nb_word			; colonnes-1
	bmi.s	next_bloc_line	
       
	moveq.l #2,d6               ; 2 bytes by word
    
deux_bytes:   
	subq.w	#1,d6
	bmi.s	next_word 
                                    
	move.w	#5,d5               ; nombre de ligne dans un bloc_de_lignes  
	movea.l a3,a4               ; (a4) pour lire les octets
                                                   
lines_block:  
	subq.w	#1,d5
	bmi.s	second_byte

	move.b  (a4),d7             ; Lire un byte
*	move.b	#$ff,(a4)			; utiliser pour tester la lecture des
*							      32000 octets de l'image Degas   
    cmp.b   (a1),d7             ; Comparer avec le dernier octet sauvegardé dans cmd0 (A5)
    beq.s   skip_save

	addq.l	#1,a1
	move.b	d7,(a1)

skip_save:

next_line:               
	adda.w	d2,a4				; prochaine ligne
	bra.s	lines_block			; répéter pour toutes les lignes
                                           
second_byte:  
	addq.l   #1,a3				; A3 points to the second byte of a word         
	bra.s	deux_bytes		    ; deuxiŠme octets d'une colonne       
              
next_word:      
	adda.l  d3,a3				; +offset_word	               
	bra.s   colonnes	      
;-------------------------------------------; 
                                                                
next_bloc_line:	     
	suba.w	d2,a4				; -offset_line
	lea.l	1(a4,d3.w),a3		; prochain bloc de lignes			 
	bra.s	all_blocks_lines	; >0 next five lines
                                           
next_plane:                                
	addq.l	#2,a0			    ; next plane       
	bra.s	all_plane		            

;-------------------------------------------; 
fin_pic:
    move.l  60(sp),a0
	move.w	70(sp),d1
	mulu.w	#18,d1

    move.l  20(a0,d1.w),a3
    suba.l  a3,a5
    move.l  a5,d0
    bsr.s   recopy_cmd
	move.l	a2,20(a0,d1.w)    
 
	move.l  24(a0,d1.w),a3
    suba.l  a3,a6
    move.l  a6,d0
    bsr.s   recopy_cmd
	move.l	a2,24(a0,d1.w)
    
    suba.l  a0,a1
    move.l  a1,d0           ;taille du fichier   
    tst.w	d1
	beq.s	fin_pp
	move.w	d0,16(a0)       

fin_pp:			
	movem.l	(sp)+,d1-d7/a0-a6	; Restaurer les registres et retourner
	rts	
;---------------------------------------------------
recopy_cmd:
	movea.l	a1,a2
	suba.l	a0,a2
	addq.l	#1,a1
recopy_cmds:
    move.b  (a3)+,(a1)+
    dbra.w	d0,recopy_cmds
    rts
 
;----------------------------------------------------
; initialisation celon la résolution de l'image degas
;----------------------------------------------------  
init_param:
    mulu.w  #10,d0				; offset param celon la r‚solution image
    lea.l   param(pc,d0.w),a2
	move.w  (a2),nb_plane		; nombre de plan dans l'image
	move.w	#5,d5		    	; nombre de ligne dans un bloc
	move.w  6(a2),d3		    ; offset_word	                         
	move.w  8(a2),d2		    ; offset_line
    rts
;---------------------------------------------------------------- 
;			nb_plane,nb_bloc,nb_word,offset_word,offset_line
param:		dc.w	4,40,20,6,160
			dc.w	2,40,40,2,160
			dc.w	1,80,40,0,80
nb_plane	dc.w	0
nb_bloc:	dc.w	0
nb_word:	dc.w   	0
    end   
