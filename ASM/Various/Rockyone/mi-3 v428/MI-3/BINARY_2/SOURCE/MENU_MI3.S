;rockyone			 pour MI-3	    		 02/03/2017
;
;correction				  			 28.02.2018
;
;				Menu On / Off
;				-------------
;
;Buf_menu   Buffer contenant les data du menu haut et bas
;
; buf_ecr   Adresse buffer image pour Off
;	    0 pour ON
;	
; Haut%   = 0 quand le menu est en bas
;	  = 1 quand le menu est en haut
;
; ON_OFF% = 0 pour off
;	  = 1 pour on 
;						  d1        d2
;	call Art_cycle( L buf_menu ,L buf_ecr, W haut% ,W on_off%)
;	----------------------------------------------------------
;
;
;
; Buffer menu: avec ses 2 lignes de s‚paration
; 
; MENU ON    ___________________________  Ligne 182|364 visible si menu bas 
;	    |
;           |      ---haut de l'‚cran---|
;line 3/6   | |----|----|---------|--   | Mis dans le buffer par le basic
;           | | FR | GB |         |     |      
;line 13/26 | |----|----|------------   |	
;	    |___bas de l'‚cran___	|		
;					|
;            ___________________________| Ligne 17|34 visible si menu haut
;					  
; Nb nombre de ligne recouverte si menu haut 18|35 ( l'erreur ! )
;'''''''''''''''''''''''''''''''''''''''''''''''''
;					  
; MANU OFF   ___________________________ 
; 
;				      --Mis dans le buffer par 68k
;             |----|----|---------|--   |       
;             | FR | GB |         |     |  Premiere et derniŠre ligne ‚cran
;             |----|----|------------   |    du menu non recopiŠ dans cette 
;				      ---    partie du buffer
;            ___________________________    
;      
;
; Le d‚placement et de deux lignes en haute r‚solution !
;
;------------------------------------------------------------------------
;a3	buffer menu         
;a4	buffer image pour menu_off          
;a4=a3	pour menu_on                
		                       
		movem.l	d0-d7/a0-a6,-(a7)
		movem.l	64(sp),a3-a4             
		movea.l	$44e,a5		    ; ecran             
                                                    
		moveq.l	#17,d5                          
		movem.w	72(sp),d1-d2                        
	                                                        	
		tst.b	d2                              
		beq.s	menu_off                    
;----------------------------------------MENU ON--------------------------
;a3 a4 sources                                       
;a5 a6 ‚cran                                        
                                               
		moveq.l	#39,d6		    ; 40 LW par ligne 
            	tst.b	d1                              
	    	beq.s	on_bas                          
;.......................................
                
	    	lea.l	19*160(a3),a3       ; pointe fin zone menu on    
	    	lea.l	160(a5),a5	    ; fin premiere ligne de l'ecran      
	                                                    
		cmpi.b	#2,$44c		    ; haute resolution ?        
		bne.s	loop_h                                  
			                                          
		lea.l	-80(a3),a3	    ; fin premiere ligne haute resol
		lea.l	-80(a5),a5	    ;    "	 "     "     "
            	moveq.l	#19,d6		    ;    "       "     "     "
	                                                        
loop_h:		movea.l	a3,a4		    ;                     
		movea.l	a5,a6		    ; ‚cran                         
		bsr.s	vsync		    ; + move d6,d7              
                                                            
h_ligne:	move.l	-(a4),-(a6)         ; affiche un ligne du menu                    
		dbra.w	d7,h_ligne                              
                                                            
		lea.l	160(a5),a5	    ; ‚cran                     
		addi.w	#40,d6		    ; +1 ligne, +2 en haute r‚sol
                                                                
	    	dbra.w	d5,loop_h                                   
                                                                
		bra.s	end_prg                                     
;--------------------------------------- ON BAS -----------------------
on_bas:		lea.l	32000-160(a5),a5                            
                                                        
loop_b:		movea.l	a3,a4		    ; source	            
		movea.l	a5,a6		    ; ‚cran                 
		bsr.s	vsync		    ; + move d6,d7          
	                                                            	                                            
b_ligne:	move.l	(a4)+,(a6)+                 
		dbra.w	d7,b_ligne                          
			                                        	
		lea.l	-160(a5),a5	    ; ‚cran                     
		addi.w	#40,d6		    ; + 1 ligne                    
		dbra.w	d5,loop_b                               
;-------------------------------------------------------------------------
end_prg: 	movem.l	(a7)+,d0-d7/a0-a6                           
		rts                                             
;-------------------------------------------------------------------------
vsync:		move.w	d6,d7		    ; Pour les 4 fonctions
    		move.w	#37,-(sp)	    ; Vsync
	    	trap	#14		    ; Xbios
		addq.l	#2,sp           
		rts                     
;---------------------------------------- MENU OFF------------------------
menu_off:	lea.l	3040(a3),a3	; pointe buffer zone menu_off
	        move.w	#679,d6		; 17 ou 34 lignes 
		moveq.l	#18,d5	        
	    	tst.b	d1              ; quelle sens ?
		bne.s	haut_off        
;........................................ OFF BAS ........................
  		lea.l	29120(a5),a5	; pointe ecran ligne 182 ou 364
		movea.l	a5,a6           ; screen
		movea.l	a3,a1           ; menu off
		bsr	copy_menu	; a5 to a1

		lea.l	29120(a4),a4	; buffer image
off_bas:	moveq.l	#39,d3	        ; 40 long word
		bsr.s	vsync		; + move d6,d7    #679
                    
bas_pic:	move.l	(a4)+,(a6)+	; restaure 1 ou 2 ligne image
		dbra.w	d3,bas_pic
                    
	    	subq.b	#1,d5           ; compteur ligne
    		beq.s	end_prg

	        movea.l	a3,a1
		movea.l	a6,a0           ; pointe to next line
move_bas:	move.l	(a1)+,(a0)+	; menu une ligne plus bas
		dbra.w	d7,move_bas	
		
		subi.w	#40,d6
		bra.s	off_bas         
;........................................ OFF HAUT ........................
haut_off:	lea.l	160(a5),a5	; ‚cran
		movea.l	a3,a1
		bsr.s	copy_menu	
		movea.l	a1,a3	
                              
    		lea.l	2880(a4),a4	; buffer image
;	                		 
		cmpi.b	#2,$44c
	    	bne.s	off_haut

    		moveq.l	#17,d5 		
		suba.w	#80,a3
	    	suba.w	#80,a4
    		suba.w	#80,a5
		sub.w	#40,d6		;***
                
off_haut:	moveq.l	#39,d3
		bsr	vsync		; + move d6,d7
                                        
pic_haut:	move.l	-(a4),-(a5)	; restore 1 ou 2 ligne d'image
		dbra.w	d3,pic_haut	
	                                
		subq.b	#1,d5
		beq.s	end_haut	; for high resol
                                        
		movea.l	a3,a1
		movea.l	a5,a0
move_haut:	move.l	-(a1),-(a0)	; menu un ligne plus haut
		dbra.w	d7,move_haut
		
		subi.w	#40,d6		; -1 ligne, -2 haute Résol
  		bra.s	off_haut
                                
end_haut:	cmpi.b	#2,$44c		; high resol ?
		bne	end_prg             
                
		moveq.l	#19,d7          ; premiere ligne ‚cran         
high_rez:	move.l	-(a4),-(a5)     ; haute r‚solution        
	    	dbra.w	d7,high_rez                             
    		bra 	end_prg                                     
;---------------------------------------------- copy_menu --------------
;
; copy 17 lignes du menu qui est a l'ecran dans la zone MENU OFF
; pas bessoin de la premiŠre ligne du menu Haut
;  "	"	"    deniŠre ligne du menu bas

copy_menu:  	move.l	#679,d3		;17 lignes de 40 word  -1 pour dbra	
copy_lw:	move.l	(a5)+,(a1)+
		dbra.w	d3,copy_lw
		rts
;-------------------------------------------------------------------------
            end
;-------------------------------------------------------------------------