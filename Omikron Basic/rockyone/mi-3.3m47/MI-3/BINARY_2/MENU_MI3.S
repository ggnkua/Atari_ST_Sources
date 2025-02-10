;rockyone			 pour MI-3	    		02/03/2017
;
;correction				  			28.02.2018
;prise en charge des images SPU					11.09.2019
;modif pour raster IFF						19.10.2020
;checked							18.12,2020
;				Menu On / Off
;				-------------
;
; Attention: le d‚placement est de deux lignes en haute r‚solution.
;
; Restor	Buffer palettes SPU pour restoration  		19200 octets
; Display	Buffer paletes SPU affich‚es … l'‚cran		19200 octets
;
; Buf_menu   	Buffer contenant les data du menu haut et bas	2*3040+160
;
; Ecr_buf   	Adresse de l'image pour menu Off= Buf_ecr+34
;
;	    	
; Haut%   	= 0 quand le menu est en bas
;										;	  	= 1 quand le menu est en haut
;
; On_ff% 	= 0 pour off
;	  	= 1 pour on 
;
; Raster%	= -2 pour raster iff  ( 200 lignes et rasters )
;		= -1 pour raster spu  ( 1+199 lignes et rasters )
;		sinon, toujours zero
;				   	          d1     d2	  d3
; call menu( restor, display, buf_menu, Ecr_buf, haut%, on_off%, raster%)
; -------------------------------------------------------------------------
;	      	  64	  68	   72        76	      80     82	      84
;
; Buffer menu "ON" avec ses 2 lignes de s‚paration
; 
; +0         ___________________________  Ligne 182|364 visible si menu bas 
;	    |
;           |      ---haut de l'‚cran---|
;line 3/6   | |----|----|---------|--   | Mis dans le buffer par le basic
;           | | FR | G								B |         |     |      
;line 13/26 | |----|----|------------   |	
;	    |___bas de l'‚cran___	|		
;					|
;            ___________________________| Ligne 17|34 visible si menu haut
;					  
; Warning: nombre de ligne recouverte si menu haut 18 ou 35 
; '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;					  
; MENU OFF   ___________________________ 
; 
;				      '''Mis dans buffer par cette routine.
;             |----|----|---------|--   |       
;             | FR | GB |         |     |  Premiere et derniŠre ligne ‚cran
;             |----|----|------------   |    du menu non recopiŠ dans cette 
;				      '''    partie du buffer
;            ___________________________    
;      
;
; Le d‚placement et de deux lignes en haute r‚solution !
;
;------------------------------------------------------------------------
;a1     buffer pal_restore
;a2	buffer pal_display
;a0     buffer black_pal   19200(a2)
;a3	buffer  menu         
;a4	buffer ecr_buf l'image pour 																		menu_off          
;a4=a3	pour menu_on              
;a5	‚cran
;d3	alway spu flag  

		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	64(sp),a1-a4       
		movea.l	$44e,a5		    	; screen

		movem.w	80(sp),d1-d3                     

		moveq.l #0,d0			;init registre
		moveq.l	#17,d5              	; 18 lignes            

		tst.b	d2                      ; oon off ?        
		beq	menu_off                    
;-------------------------------------------------------------------------
;				MENU ON
;a3 a4 sources                                       
;a5 a6 ‚cran                                        
;-------------------------------------------------------------------------
;		  			; iff	spu	autres ?
		move.w	d3,d0		; -2    -1    	  O
		beq.s	not_raster	;
		lea.l	19200(a2),a0
		addq.w	#2,d0		;  0     1		
		lsl.w	#1,d0		;  0	 2

not_raster:	moveq.l	#40/2-1,d6	; 40 LWords par ligne 
            	tst.b	d1              ; On or Off ?                
	    	beq.s	on_bas                          

;.......................................ON haut...........................
                                   
h_no_spu:    	lea.l	19*160(a3),a3       ; Pointe fin zone menu on    
	    	lea.l	160(a5),a5	    ; Fin premiere ligne de l'ecran      
                     
		cmpi.b	#2,$44c		    ; haute resolution ?        
		bne.s	loop_h                                  
                                         
		lea.l	-80(a3),a3	    	; Fin premiere ligne haute
		lea.l	-80(a5),a5	    	; resolution
            	moveq.l	#20/2-1,d6	    	; 
	                                                       
loop_h:		movea.l	a3,a4		    	; buffer menu                    
		movea.l	a5,a6		    	; ‚cran                         

		bsr	vsync		    	; + move d6,d7 et test d3              
		beq.s	h_ligne_menu    	; not raster
;		.................................
		move.w	d0,d2
sp_pal:		move.w	#7,d1		    ; Une palette noir
h_black_pal:	move.l	(a0)+,(a2)+
		dbra.w	d1,H_black_pal 	    ;
		dbra.w	d2,sp_pal	    ; ou plus pour SPU
;		.................................
h_ligne_menu:	move.l	-(a4),-(a6)         	; Affiche un ligne du menu
		move.l	-(a4),-(a6)         	; puis 2,3,... sur l'ecran          
		dbra.w	d7,h_ligne_menu                              
                                                            
		lea.l	160(a5),a5	    	; fin prochaine ligne                     
		addi.w	#20,d6		    	; plus une ligne
                                                                
	    	dbra.w	d5,loop_h                                   
                                                                
		bra.s	end_prg          

;.........................................................................
;
;				    ON BAS
;
;.........................................................................

on_bas:		lea.l	32000-160(a5),a5  	; Derniere ligne ecran

		tst.b	d3			; image raster ?
		beq.s	loop_b			; non
;		................................
; 18 lignes                          taille total des raster
; 96 bytes par ligne image.spu		19200 = 96+199*96
; 32 bytes par ligne image.iff		 6400 = 200*32
;
		lea.l	21*32(a0),a0	; fin des palettes noir pour IFF
		lea.l	200*32(a2),a2	; fin Pal_display_bas IFF
		tst.b	d0		; file IFF ? 
		beq.s	loop_b		; oui                        
		lea.l	21*64(a0),a0 	; fin des palettes noir pour SPU
		lea.l	200*64(a2),a2	; fin pal_display_bas SPU
;		.................................

loop_b:		movea.l	a3,a4		    	; source	            
		movea.l	a5,a6		    	; ‚cran                 
		bsr.s	vsync		    	; + move d6,d7         
		beq.s	b_ligne_menu
;		................................

;Remplace les palettes raster
		move.w	d0,d4			; Nombre raster par ligne
b_spu:		moveq.l	#7,d1
b_black:	move.l	-(a0),-(a2)
 		dbra.w	d1,b_black		; remplace une palette
		dbra.w	d4,b_spu		; +2 autre pour SPU 
;		.................................
; d7=6
b_ligne_menu:	move.l	(a4)+,(a6)+            	; aff menu sur ‚cran
		move.l	(a4)+,(a6)+     
		dbra.w	d7,b_ligne_menu                          
			                                        	
		lea.l	-160(a5),a5	    	; ‚cran                     
		addi.w	#20,d6		    	; + 1 ligne                    
		dbra.w	d5,loop_b               ; 18 lignes                
;-------------------------------------------------------------------------
end_prg: 	movem.l	(sp)+,d0-d7/a0-a6                           
		rts                                             
;-------------------------------------------------------------------------
vsync:		movem.l	d0-d2/a0-a2,-(sp)
		move.w	d6,d7		    	; Pour les 4 fonctions
    		move.w	#37,-(sp)	    	; Vsync
	    	trap	#14		    	; Xbios
		addq.l	#2,sp      
		movem.l	(sp)+,d0-d2/a0-a2   
		tst.w	d3  			; Image.spu ?
		rts     
;-------------------------------------------------------------------------                
;				MENU OFF
;-------------------------------------------------------------------------
	 
menu_off:	lea.l	3040(a3),a3	; pointe buffer zone menu_off
		move.l	#680/2-1,d6	; 17 ou 34 lignes celon resolution.

		moveq.l	#2,d0
		add.w	d3,d0
		moveq.l	#18,d5	        ; 18 ligne ecran
	    	tst.b	d1              ; quelle sens ?
		bne.s	haut_off        

;........................................ OFF BAS ........................
  		lea.l	182*160(a5),a5		; ecran ligne 182 ou 364
		movea.l	a5,a6           	

		bsr	copy_menu		; dans zone off

		lea.l	182*160(a4),a4		; buffer image
		tst.w	d3			; image raster ?
		beq.s	off_bas			; non 
;		.................................
;adresse des palettes raster 
		move.w	d0,d1		; 0   1
		lsl.w	#6,d1		; *64
		addi.w	#32,d1
 		mulu.w	#182,d1		; 
		add.w	d1,a2		; adr start Pal_display B

;Ho ! le buffer restor restore bas d‚mare ligne 179 pour le diaporama

		lea.l	179*96(a1),a1	; start pal_b line 179
		lea.l	3*32(a1),a1	; IFF start Line 182  
		tst.b	d0
		beq.s	iff_b
		lea.l	2*96(a1),a1	; SPU start line 182

iff_b:		lsl.w	#1,d0		;nombre de palette par ligne image
;		.................................

off_bas:	moveq.l	#40/2-1,d2		; 40 long word scren line
		move.w	d0,d4			; nombre de palette 

		bsr.s	vsync		
		beq.s	bas_pic			; image sans raster

;		.................................
; restor une ou trois palettes raster par ligne
b_r_sp:		moveq.l	#3,d1			;
b_restor:	move.l	(a1)+,(a2)+		; 
		move.l	(a1)+,(a2)+		;
		dbra.w	d1,b_restor		; retore une palette
		dbra.w	d4,b_r_sp		; +2 palettes pour SPU
;		.................................
;
; restore une ligne image de 160 bytes  ou 2 lignes de 80 bytes                 
bas_pic:	move.l	(a4)+,(a6)+		; 
		move.l	(a4)+,(a6)+		; buffer to screen
		dbra.w	d2,bas_pic		; compteur long word
                    
	    	subq.b	#1,d5           	; compteur lignes
    		beq	end_prg

	        movea.l	a3,a0			; Buffer menu off
		movea.l	a6,a5           	; Screen
move_bas:	move.l	(a0)+,(a5)+		; Recopy le menu une
		move.l	(a0)+,(a5)+		; ligne plus bas.
		dbra.w	d7,move_bas	
		
		subi.w	#20,d6
		bra.s	off_bas         
;........................................ OFF HAUT ........................
haut_off:	lea.l	160(a5),a5		; ‚cran

		bsr	copy_menu		; dans zone "off"
		movea.l	a0,a3	
                              
    		lea.l	18*160(a4),a4		; buffer image
		cmpi.b	#2,$44c			; Haute resolution ?
	    	bne.s	not_hight		; non

		subq.b	#1,d5			; 17 line en haute resol !
		suba.w	#80,a3
	    	suba.w	#80,a4
    		suba.w	#80,a5
		sub.w	#10,d6			; ***

not_hight:	
		tst.w	d3			; Raster ?
		beq.s	off_haut		; Non
;		.................................
		move.w	d0,d1 
		lsl.w	#6,d1		; 64  0
		addi.w	#32,d1		; 96 32
		mulu.w	#18,d1
		add.w	d1,a1		; fin buffer pal restore
		add.w	d1,a2		; fin buffer pal display							*		lea.l	17*96(a2),a2		; buffer display pal spu
		lsl.w	#1,d0		;  2  0
;		.................................
off_haut:	moveq.l	#40/2-1,d2
		bsr	vsync			
		beq.s	pic_haut		; pas de raster !

		move.w	d0,d4
h_sp:		moveq.l	#3,d1
h_restor:	move.l	-(a1),-(a2)		; palette raster
		move.l	-(a1),-(a2)
		dbra.w	d1,h_restor
		dbra.w	d4,h_sp        		;
                                
pic_haut:	move.l	-(a4),-(a5)		; Restore une ou deux 
		move.l	-(a4),-(a5)		; ligne(s) de l'image
		dbra.w	d2,pic_haut	
	                                
		subq.b	#1,d5
		ble.s	end_haut		; for high resol

       		movea.l	a3,a0			; Buffer menu off
		movea.l	a5,a6			; Screen
move_haut:	move.l	-(a0),-(a6)		; Recopy le menu une 
		move.l	-(a0),-(a6)		; ligne plus haut
		dbra.w	d7,move_haut
			
		subi.w	#20,d6			; -1 ligne, -2 haute Resol.
  		bra.s	off_haut
                                
end_haut:	cmpi.b	#2,$44c			; high resol ?
		bne	end_prg             
         
		moveq.l	#19,d7          	; Premiere ligne ‚cran         
high_rez:	move.l	-(a4),-(a5)     	; en haute r‚solution.        
	    	dbra.w	d7,high_rez                             
    		bra 	end_prg                                     
;---------------------------------------------- copy_menu --------------
;
; Copy 17 lignes du menu visible … l'ecran dans la zone MENU OFF.
; Pas bessoin de la premiŠre ligne du menu Haut.
;  "	"	"    deniŠre ligne du menu bas.
;					 
copy_menu:  	move.l	#680/2-1,d2		; 17 * 40 word  	
		movea.l	a3,a0
copy_lw:	move.l	(a5)+,(a0)+
		move.l	(a5)+,(a0)+
		dbra.w	d2,copy_lw
		rts
;-------------------------------------------------------------------------
            end
;-------------------------------------------------------------------------