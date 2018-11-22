; ROCKY.ONE		pour	MI-3 MI9			26/04/2016
; Info:								30.03.2018
; pour rester compatible avec la premiŠre version MI-1 de 1996,je laisse  
; le premier block de 16 bytes , bien qu'il ne soit pas toujours utilis‚.
;  - cela ne change rien au nombre de pointeur -
; Donc, correction de la taille maximum.
; 
;				OPEN Mi-3 
;				--------
;
; Source	buffer(fife_size)  maximum 36072 avec 4 cyles de couleur
; But	 	buffer 32066 octets
; Anime		buffer 34 octets
; Op%		0 open, 1 save
;
;  	open Call  Mi_3_open(L Source,L but,L anime,W op%)
;  	save Call  Mi_3_open(L but,L source,L anime,W op%)
;	--------------------------------------------------
;	
; Return dans low d0	-2 not Mi1 ou format  modifi‚   
;			-3 not erreur mais ancien format sans r‚solution   
;	    	        1 cycle couleur actif( sauf ancien format ) ou 0
;            hight d0 	resolution image ( sauf ancien format )
;			
; Return dans Anime	Sauf pour ancien format
;			32 bytes animation format Degas Elite
;            		+ 1 word time animation pour viewer
;	     		+ 1 word largeur image 
;	 		+ 1 word hauteur image  
;
;return dans  Destination  l'image au forrmat Degas
;
; Warning: la r‚solution ne peut pas ‚tre test‚ pour l'ancien format !
;         
;------------------------------------------------------------------------
; A0 Buffer mi1 
;	+0   1 word         	$ffff   valeur de l'ancien format
;	---------------------------------------------------------		
; 	+0   1 word		$ff00   Nouveau format
;				  |||
;				  |||-- 0 - 4 nombre de cycle de couleur
;				  ||--- resolution 0 - 2
;				  |---- < $f taille image personalis‚
;						
; 1 cycle de couleur		
; 	+   2	 1 byte    -  left color (start)
;	+   3    1 byte    -  right color  (end)
;	+   4    1 byte	   -  sens  0 1 2
;	+   5    1 byte    -  vbl  0 - 128 ( 128 - byte )  			  
;				
; 2 cycle de couleur
; 	+   6	 1 byte    -  left color (start)
;	+   7    1 byte    -  right color  (end)
;	+   8    1 byte	   -  sens  0 1 2
;	+   9    1 byte    -  vbl  0 - 128 ( 128 - byte )  			  
;
; 3 cycle de couleur
; 4 cycle de couleur
;
; - - - - - - - - - - - valeur sans cycle de couleur( new format) - - -
;
;	+   0    1 word         $ffff … $ff00
;   	+   2 	 1 word	   	time pour viewer
;	+   4    1 word		largeur image
;	+   6	 1 word		hauteur image
;    	+   8   16 word		couleur palette					
;    	+  40 2000 word        	d‚but des pointers
;    	+4040 8004 long word 	d‚but des datas image
;	           les 4 premier Long word ne sont pas toujours utilis‚ !
;Dans ce cas , les pointeurs commence avec la valeur 16 au lieu de 0
;                    
;
; taille minimum  4056 bytes ( sans cycle de couleur )
; taille maximum 36072 bytes ( avec quatre cycles de couleur et premier
;                              block de 16 bytes … zero inutilis‚ )
;------------------------------------------------------------------------	
;a0 source
;a1 destination
;a2 Anime
;d0 hight toujours la resolution de l'image ( sauf ancien format)
;d0 low   code erreur ou cycle actif
;d3 cycle
;d6 code erreur>> dans low do
;....
;------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)	 
		movem.l	60(sp),a0-a2		;source/destination/anime
		move.w	72(sp),d0
		tst.b	d0
		bne	save_mi1

;.......................................OPEN............................
		movea.l	a2,a3
		moveq.l	#0,D0

* Initialise le buffer Anime si non prepar‚
*	move.l	#$10001,16(a2)		; directions des cycles: inactif	
*	move.l	#$10001,20(a2)		;  "     "    "     "	  

;........................................ test Version
		move.w	(a0)+,d7
		moveq.l	#-3,d6		;R.image sans r‚solution
		cmpi.w	#$ffff,d7	; Ancien format ?
		beq.s	copy_pal	; oui

		moveq.l	#-2,d6		;R. format inconu ou  chang‚
		cmpi.w	#$ff00,d7
		bmi.s	end_prg			
		cmpi.w	#$ff24,d7
		bhi.s	end_prg

;....................................... r‚solution

		move.b	d7,d1		
		lsr.b	#4,d1		
		andi.b	#$f,d1
		move.b	d1,d0		; resolution image

		moveq.l	#0,d6		;R. pas d'erreur
	
;....................................... test nombre de cycle

		move.b	d7,d1		; resolution et cycle
		andi.b	#$f,d7		; combien de cycle ?
		beq.s	not_cycle	; 0 
		moveq.l	#1,d6		; R.  cycle active
	
;....................................... save cycle format degas elite
;a0     source
;a2 a3  anime

		subq.b	#1,d7		;-1 for dbra
cycle_color:	move.b	(a0)+,1(a2)	; premiŠre couleur d'un cycle
		move.b	(a0)+,9(a2)	; DerniŠre couleur d'un cycle 
		move.b	(a0)+,17(a2)	; Direction d'un cycle
		move.b	(a0)+,25(a2)	; Nombre de Vbl d'un cycle 
		adda.w	#2,a2
		subq.b	#1,d7
		bpl.s	cycle_color

not_cycle:	lea.l	32(a3),a2
 		move.w	(a0)+,(a2)+	; time pour viewer 
		move.w	(a0)+,(a2)+	; largeur image
		move.w	(a0)+,(a2)	; hauteur image

;test largeur et hauteur inutile


copy_pal:	move.w	d0,(a1)+	; write resolution
		bsr.s	copy_palette

;........................................depact image...............
;a0 a2 a3 source
;a1       destination

		lea.l	4000(a0),a3	; d‚but des datas image
		lea.l	32000(a1),a4
depack:		movea.l	a3,a2		; d‚but des data image
		adda.w	(a0)+,a2	; d‚calage index‚ au pointeur
		move.l	(a2)+,(a1)+	; copie data image
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		cmpa.l	a1,a4		; dernier blocs ?
		bhi.s	depack		; > 

end_prg:	swap	d0
		move.w	d6,d0
		
end_save:	movem.l	(sp)+,d1-d7/a0-a6
		rts

copy_palette:	moveq.l	#7,d7		; 16 couleurs									
copy_color:	move.l	(a0)+,(a1)+
		dbra.w	d7,copy_color
		rts
		
;-------------------------------------------------------------------------
;ROCKY.ONE			pour MI-3			26/06/2016	
;				*********
;
;		save format mi1,mi2,mi3
;
;futher improvements to do but it works :))
;for now,i woud not load the personalized image.
;yet the test width / height has to do.
;
;
;Source		buffer format DEGAS	 
;Destination 	buffer  36072 octets ( mazimum file size )
;
;		CALL Mi1_save( L screen_address, L Buffer_pic,L Anime)
;
;		size_file = LOW(lpeek(reserved(0)))
;		
; Anime:	
; 		+0	32 word data cycle rotation (format degas elite)
;		+32     number of repetition for wiever
;		+34	width image
;		+36	hight image
;
;		To save space (not required):
;		-Save only the cycles that have values, even if the 
;		 cycle is not active.
;		-And indicate in the file header the number of cycles,
; 		 even if the cycle is not active.
;		
;--------------------------------------------------------------
;A0  screen address
;A1  buffer_pic address
;
;	Header 	1 word    $ff00   Header + resolution + number cycle
;		             ||...Number color cycle 0 to 4
;			     |....Image resolution 0 to 2
;
;	cycle 1						if used
;	  	1 byte	left color     0-F   		as degas elite
;	  	1 byte 	right color    0-F   		as degas elite
;	  	1 byte	rotation cycle 0 1 2 		as degas elite	
;	  	1 byte	vbl 0-128 	     		as degas elite
;	cycle 2						if used
;	cycle 3						if used
;	cycle 4						if used
;
;		1 word 	time animation for viewer	alway
;	        1 word	width				alway
;		1 word	height				alway
;	  	16 word 	color			alway
;	      2000 word 	pointers		always !
;	      8004 Long word 	maximum data image
;	     ( les 4 prenier Long word ne sont pas toujours utilis‚ )
;
;File size,  36072 bytes  maximum 
;	      4040 bytes  minimum				
;--------------------------------------------------------------
* 		movem.l d1-d7/a0-a6,-(sp)
*		movem.l	60(sp),a0-a2	

save_mi1:	exg.l	a0,a1

		movea.l	a1,a6		; to calulate the file size
		addq.l	#2,a1		; after the header	

;a0  source
;a1  destination
;a2  anime
;........................................

		moveq.l	#3,d0		; test : 4 cycle value
		moveq.l	#0,d7		; number of saved cycle
		moveq.l	#0,d3

test_cycle:	move.b	9(a2),d3	;  end color
		sub.b	1(a2),d3	;  start color
		beq.s	next_cycle	;  not save this cycle

		move.b	1(a2),(a1)+	; write left color
		move.b	9(a2),(a1)+	; write right color
		move.b	17(a2),(a1)+	; write direction 0 - 2
		move.b	25(a2),(a1)+	; write speed 0 - 128
		addq.b	#1,d7		; number of saving cycles

next_cycle:	addq.l	#2,a2		;  next cycle
		dbra.w	d0,test_cycle

		move.w	24(a2),(a1)+	; write time  for wiever
		move.w	26(a2),(a1)+	; write width image
		move.w	28(a2),(a1)+	; write height image

;........................................
		move.b	#$ff,(a6)	; write  header
		move.b	1(a0),d2	; screen resolution
		lsl.b	#4,d2
		add.b	d7,d2		; add number of saving cycle
		move.b	d2,1(a6)	; write resolution a
;					; and number cycle

		addq.l	#2,a0
		bsr.s	copy_palette

;........................................PACKT IMAGE
;a0 source
;a1 a2 a3 destination	
;a5 a6 to calculate the file size
	
		movea.l	a1,a2		; d‚but des pointeurs
		lea.l	4000(a1),a3	; d‚but des data image
		movea.l	a3,a5		; if the pic if united

*		moveq.l	#0,d0		; the block to be compared
		moveq.l	#0,d1 		; counter of blocks saved	
		moveq.l	#0,d2		; "        "       "  for dbra

		lea.l	32000(a0),a4
;........................................
Lire_bloc:	moveq.l	#0,d3		; new pointer, address  0
 		movea.l	a3,a1  		; early data picture

BLoc_1:		move.l	(a0),d0		; Read the first block
		cmp.l	(a1),d0
		bne.s	differant	; Differing first block
		
      		move.l	4(a0),d0	; Read the second block
		cmp.l	4(a1),d0
		bne.s 	differant	; Second differing block

		move.l	8(a0),d0
		cmp.l	8(a1),d0
		bne.s 	differant	; Flanker differing blog

		move.l	12(a0),d0
		cmp.l	12(a1),d0
		bne.s 	differant	; Four differing block

		lea.l	16(a0),a0	; Point to the next blok 
;					; of four groupe

		bra.s	save_adr	; Four identical block :
;					; Only save address
;.......................................
differant:	lea.l	16(a1),a1	; Pointe with the nest group	
	
		addi.w	#16,d3		; Calculating the group poiter
	
		dbra.w	d2,bloc_1	; End of the saved group ?
;					; Yes : >>> save new group
;........................................
Save_groupe:	move.l	(a0)+,(a1)+	; Save data picture
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+	; Points to the next group 
;					; of four blocks
		addq.w	#1,d1		; Counter saved group
		movea.l	a1,a5
;........................................
Save_adr:	move.w	d1,d2		; Number of saved group
		move.w	d3,(a2)+	; Save block pointer

		cmpa.l	a0,a4
		bhi.s	lire_bloc
;........................................

		suba.l	a6,a5
		move.l	a5,d0		; Return file size in d0
		bra	end_save

		end
;------------------------------------------------------------------------
