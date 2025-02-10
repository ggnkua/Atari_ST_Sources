;rockyone               for MI-3 and MI-9        	         31/01/2025
;								 						
;   
;			Save PP1-3 et MBK
;			*****************
; 
;The resolution of the image "PP1-3" is equal to the number of the file 
;extention.
;                               
; Source: Buf_Ecr       Buffer 32066+160 bytes Image PI1-3 
; But   : Buf_Pic       Buffer 41020 bytes equal $00
;       : Buf_pic+33000 Buffer temporaire cmd0 4010 bytes
;       : buf pic+37010 Buffer temporaire cmd1 4010 byte  
;Format%	= 0	: Sauvegarde format Pic_pac  "PP?"
;			= 1 : Sauvegarde format Stos     "BNK"                              
;                               
;               A0         A1                
;    call( L buf_pic, L buf_ecr, W dummy, W Format%, W dummy%)
;              60         64        68       70       72                              
;.......................................................................... 
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
;           line 4 | 4  9  |       |       |       | 14    |  
;           line 5 | 5  10 |       |       |       | 15    |  
;           line 6 
;           line 7
;           ...
;..........................................................................
;Format des fichiers ."pp1-3" de "Pic-Pac.prg"    
;                                                                   
; +0	L	$06071963	Id stos                                             
; +4    W	0  1  2		BNK r‚solution image
;      		 		PP1-3 r‚solution compression   							                             
; +6	W	0	    	?	                                            
; +8	W	0	    	?	                                            
; +10	W	20 40 40	Number word for a plan line (lsl 4 = width pic)     
; +12	W	40 40 80    	Number of groups of five lines per plan
; +14	w	?   	    	?                                                   
; +16	w	5	    	Number of lines in a blok - aLways 5 pour PP1-3            
; +18	w	3	    	*Compression mode always 3 pour PP1-3              
; +20	L	P0 	    	offset Cmd0                                         
; +24   L	P1 	    	offset Cmd1
; +28   B	?           	5 words	? 			
; +38	W	16 word     	always 16 colors
; +70	B	Literal     
; +P0	B	cmd0        
; +P1  	B	cmd1        
;
;-------------------------------------------;
;	taille d'un fichier compress‚   
;-------------------------------------------;
;		frame	cmd0	cmd1	taille;	
;	mini	    1	   1	500	  502 + entete
;	maxi	32000	4000	500	36502 + entete
;
;..........................................................................
* compression mode
*  PP1-3     Toujours 3
*  MBK       2  (toujours ?)
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
;		a4  incrémentation des lignes dans un block de ligne
;	        a4  adresse de lecture des bytes à compresser
;
;Destination:
;	     a1+70  adresse de sauvegarde litéral
;	        a5  adresse de sauvegarde temporaire des masques  "cmd0"
;	        a6  adresse de sauvegarde temporaire des masques  "cmd1"
;
;param:         A2
;            
; d0		cmd0
; d1		cmd1
; d2		Offset line
; d3		Offset Word  
; nb_plane	nombre de plan dans l'image
; nb_bloc	nonbre de bloc de cinq lignes dans un plan d'image
; nb_word   	nombre de words dans une ligne d'un plan d'image
; nb_line   	nombre de ligne dans un bloc de ligne 
; d4        	comptage des bits de cmd1
; d5		comptage des bits de cmd0
; nb_line   	nonbre de lignes dans un bloc de ligne
; d6		nombre de byte dans un Word
; d7   		valeur dans un octet
;--------------------------------------------------------------------------
	movem.l	(a1),d0-d7

    	move.w	(a0),d0             	; resolution image D‚gas
  	bsr	init_param	

	tst.w	70(sp)			; compression MBK ?
	beq.s   type_picpac

	bsr	param_mbk
	move.l	#$4c696f6e,(a1)+	;ID MBK
	move.l	#$706f7562,(a1)+	;
	move.w	#$6e6b,(a1)+		;	
	clr.l	(a1)+
	move.w	#$8100,(a1)+		; bank_type
	clr.w	(a1)+			; poids de l'image compress‚
	move.w	#2,18(a1)		; mode de compression
	bra.s	format_picpac

type_picpac:
	move.w	#3,18(a1)		; mode de compression
	
format_picpac:	
	move.l  #$06071963,(a1)		; ID STOS/PICPACK
    	move.w  (a0),4(a1)        	; r‚sol image, inutilis‚ par PIC_PAC.PRG 
*    	clr.l	6(a1)
    	move.w  4(a2),10(a1)		; nb_word
    	move.w  2(a2),12(a1)		; nb_bloc
*    	clr.w   14(a1)          
    	move.w  6(a2),16(a1)		; 5 lignes par bloc
*   	move.w  #3,18(a1)       	; Mode de compression
		
	movea.l	a1,a5
	adda.l	#33000,a5   	; Cmd0 buffer temporaire 4000+10 bytes
	movea.l	a1,a6
	adda.l	#37010,a6  	 ; Cmd1 buffer temporaire 4000+10 bytes
    	move.l  a5,20(a1)       ; Sauve adresse pour calcul taille buffer 
    	move.l  a6,24(a1)	; Sauve adresse pour calcul taille buffer 	
;...........................................
;   Copie de la palette
;...........................................
	lea.l   2(a0),a0            ; a0 pointe sur la palette Degas
	lea.l   38(a1),a1           ; A1 pointe sut la palette Stos
	moveq.l #7,d1               ; Palette de 16 couleurs
copy_palette:
	move.l  (a0)+,(a1)+
	dbra.w   d1,copy_palette   

;-------------------------------------------;
;   A0 pointe sur data imaga Degas    
;   A1 pointe sur data literaux compr‚ss‚
;-------------------------------------------;

	move.l	#$0,d0			; initialisation de CMD0
	move.l	#$0,d1			; initialisation de CMD1
	moveq.l	#7,d4			; pour les bits de cmd1
	moveq.l	#7,d5			; pour les bits de cmd0
	move.b	(a0),(a1)+	
;-------------------------------------------;
; incrémentation des plans d'image
;-------------------------------------------;
all_plane:
	subq.w	#1,nb_plane
	bmi.s	fin_pic

	movea.l a0,a3               ; D‚but d'un plan d'image
	move.w	2(a2),nb_bloc 	    ; nombre de bloc de lines 
*	move.w  bloc_nb,nb_bloc    
;-------------------------------------------;
; incrémentation des bloks de cinq lignes
;-------------------------------------------;
all_blocks_lines:
	subq.w	#1,nb_bloc
	bmi.s	next_plane	

	move.w	4(a2),nb_word       	; nb_word by line plane
* 	move.w	word_nb,nb_word                                 
;-------------------------------------------;
; compression des cinq lignes                
;-------------------------------------------;                           
colonnes:    
	subq.w	#1,nb_word		; colonnes-1
	bmi.s	next_bloc_line	
       
	moveq.l #2,d6               	; 2 bytes by word
    
deux_bytes:   
	subq.w	#1,d6
	bmi.s	next_word 
                                    
	move.w	6(a2),nb_line	; nombre de ligne dans un bloc_de_lignes  
	movea.l a3,a4           ; (a4) pour lire les octets
                                                   
lines_block:  
	subq.w	#1,nb_line
	bmi.s	second_byte
	
    	move.b  (a4),d7         ; Lire un byte
*	move.b	#$00,(a4)	; pour verifier la lecture
	
    	cmp.b  -1(a1),d7        ; Comparer avec le dernier octet sauvegardé
    	beq.s   skip_save       ; Si identique, sauter la sauvegarde
                                        
    	move.b  d7,(a1)+        ; Sauvegarder l'octet dans le buffer
    	bset.b  d5,d0           ; Activer un bit dans Cmd0
 
skip_save:
	subq.b	#1,d5
	bpl.s	skip_save_cmd0

    	cmp.b	(a5),d0		; Comparer Cmd0 avec la dernière sauvegarde
    	beq.s   init_cmd0       ; Idendiques, sauter la sauvegarde

    	addq.l  #1,a5            ; Incrémenter le pointeur du buffer Cmd0
	move.b d0,(a5)		 ; Sauvegarder Cmd0 dans le buffer
	bset.b d4,d1             ; Activer un bit dans Cmd1

init_cmd0:
	clr.b	d0
    	moveq.l #7,d5             ; Réinitialise D5 pour un nouveau cycle de Cmd0
	subq.b	#1,d4
	bpl.s	skip_save_cmd1

*	addq.l	#1,a6
	move.b	d1,(a6)+

init_cmd1:
	clr.b	d1
	moveq.l	#7,d4

skip_save_cmd1:
skip_save_cmd0: 
;-------------------------------------------------------------------
next_line:               
	adda.w	d2,a4		; prochaine ligne
	bra.s	lines_block	;  r‚p‚ter pour toutes les lignes
                                           
second_byte:  
	addq.l   #1,a3		; A3 points to the second byte of a word         
	bra.s	deux_bytes	; deuxiŠme octets d'une colonne       
              
next_word:      
	adda.l  d3,a3		; +offset_word	               
	bra.s   colonnes	      
;-------------------------------------------; 
                                                                
next_bloc_line:	     
	suba.w	d2,a4			; -offset_line
	lea.l	1(a4,d3.w),a3		; prochain bloc de lignes			 
	bra.s	all_blocks_lines	; >0 next five lines
                                           
next_plane:                                
	addq.l	#2,a0			; next plane       
	bra	all_plane		            

;-------------------------------------------;
;   recopy des commandes cmd0 et cmd1 
;-------------------------------------------;
fin_pic:
    move.l  60(sp),a0
	move.w	70(sp),d1          	; compr‚ssion pp1-3 ou bnk ?
	beq.s	suite
	bsr.s	param_mbk		; restituer les parametres
suite:
	mulu.w	#18,d1
;...............................
    	move.l  20(a0,d1.w),a3		; adresse buffer temporaire cmd0
    	suba.l  a3,a5
    	move.l  a5,d0			; nombre d'octets … recopier
    	bsr.s   recopy_cmd
	move.l	a2,20(a0,d1.w)    	; offset cmd0
;............................... 
	move.l  24(a0,d1.w),a3		; adresse buffer temporaiore cmd1
    	suba.l  a3,a6
	subq.l	#1,a6
*   	*************
    	move.l  a6,d0			; nombre d'octets … recopier
   	bsr.s   recopy_cmd
	move.l	a2,24(a0,d1.w)		; offset cmd1
;...............................

    	suba.l  a0,a1
    	move.l  a1,d0           	; taille du fichier   	

	tst.w 	d1                  	; compréssion pp1-3 ou bnk ?
	beq.s	fin_pp
	move.w	d0,16(a0)       
;-------------------------------------------;
;-------------------------------------------;
fin_pp:		
 	movem.l	(sp)+,d1-d7/a0-a6	; Restaurer les registres 
	rts				; Retour
;-------------------------------------------;
; recopy cmd0 et cmd1
;-------------------------------------------;	
recopy_cmd:
	movea.l	a1,a2
	suba.l	a0,a2
	suba.w  d1,a2		; pour MBK
;   *************
recopy_cmds:
    	move.b  (a3)+,(a1)+
    	dbra.w	d0,recopy_cmds
    	rts
;----------------------------------------------------
; initialisation celon la résolution de l'image degas
;----------------------------------------------------  
init_param:
    	mulu.w  #12,d0		; offset param celon la r‚solution image
    	lea.l   param(pc,d0.w),a2
	move.w  (a2),nb_plane		; nombre de plan dans l'image
*	move.w	2(a2),bloc_nb
*	move.w	4(a2),word_nb
*	move.w	6(a2),nb_line	   	; nombre de ligne dans un bloc
	move.w  8(a2),d3		; offset_word	                         
	move.w  10(a2),d2		; offset_line
    	rts
param_mbk:
    	move.w  2(a2),d4
    	move.w  6(a2),d5
    	move.w  d5,2(a2)
    	move.w  d4,6(a2)
	rts    
;---------------------------------------------------------------- 
;		nb_plane,nb_bloc,nb_word,nb_line,offset_word,offset_line
param:		dc.w	4,40,20,5,6,160
		dc.w	2,40,40,5,2,160
		dc.w	1,80,40,5,0,80
nb_plane	dc.w	0
nb_bloc:	dc.w	0
nb_word:	dc.w   	0
nb_line		dc.w	0
*bloc_nb	dc.w    0
*word_nb    	dc.w    0
    end   
