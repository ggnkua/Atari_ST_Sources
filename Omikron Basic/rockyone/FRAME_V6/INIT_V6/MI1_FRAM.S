
; ROCKY.ONE			pour FRAME V4.PRG		01/10/2016
; 
;			OPEN Mi-3 ancien et nouveau format
;			basse r‚solution uniquement
;			---------------------------------
;
; Source	buffer(fife_size)
; Screen 	buffer 32066 octets
; 
;
;  		Call  Mi_3_open(L Source,L Screen)
;		--------------------------------------------------
;	
; Return dans low d0	-2 no Mi1 ou format  modifi‚   
;			-1 erreur resolution ( sauf ancien format)
;			-3 no erreur mais ancien format sans r‚solution   
;	                hight d0 resolution image 
;			
;
; Warning: La r‚solution n'est pas test‚ pour l'ancien format !
;	   normalement il n'y a que des image basse r‚solution
;         
;------------------------------------------------------------------------
; A0 Buffer mi1 
;	+0   1 word         	$ffff   valeur de l'ancien format
;	-------------------------------------------------------		
; 	+0   1 word		$ff00   Nouveau format
;				  |||
;				  |||-- 0 - 4 nombre de cycle de couleur
;				  ||--- resolution 0 - 2
;				  |---- < $f taille image personalis‚
;						
; 1 cycle de couleur		
; a0	+   2	 1 byte    -  left color (start)
;	+   3    1 byte    -  right color  (end)
;	+   4    1 byte	   -  sens  0 1 2
;	+   5    1 byte    -  vbl  0 - 128 ( 128 - byte )  			  
;				
; 2 cycle de couleur
; a0	+   6	 1 byte    -  left color (start)
;	+   7    1 byte    -  right color  (end)
;	+   8    1 byte	   -  sens  0 1 2
;	+   9    1 byte    -  vbl  0 - 128 ( 128 - byte )  			  
;
; 3 cycle de couleur
; 4 cycle de couleur
;
; - - - - - - - - - - - valeur sans cycle de couleur( new format) - - -
;
;a0	+   0    1 word         $ffff … $ff00
;   	+   2 	 1 word	   	time pour viewer
;	+   4    1 word		largeur image
;	+   6	 1 word		hauteur image
;    	+   8   16 word		couleur palette					
;    	+  40 2000 word        	d‚but des pointer
;    	+4040 8000 long word    d‚btut des data image
;
; taille minimum  4056 bytes ( sans cycle de couleur )
; taille maximum 36056 bytes ( avec quatre cycles de couleur )
;------------------------------------------------------------------------	
;a0 source
;a1 destination
;d0 low  resolution de l'image ( sauf ancien format)
;d0 high   code erreur ou 0
;d7 resolution image
;....

	movem.l	d1-d7/a0-a6,-(a7)	 
	movem.l	60(a7),a0-a1		;source/destination

;........................................ test Version
	moveq.l	#-3,d0			;R.image sans r‚solution

	moveq.l	#0,d7
	move.w	(a0)+,d7		;header MI1-3

	cmpi.w	#$ffff,d7		; Ancien format ?
	beq.s	copy_pal		; oui

	moveq.l	#-2,d0			;R. format inconu ou chang‚

	cmpi.w	#$ff00,d7
	bmi.s	end_prg			

	cmpi.w	#$ff24,d7
	bhi.s	end_prg			 	
;
;....................................... test r‚solution
;
	moveq.l	#-1,d0			;R. erreur r‚solution 
	move.l	d7,d1			; Header
	lsr.l	#4,d7			; Resol et cycle in order
	andi.l	#$f,d7			;R. resol pour form_alert
	bne.s	end_prg			; resol > 0
;	
;....................................... test nombre de cycle
;
	andi.l	#$f,d1			; combien de cycle ?
	beq.s	not_cycle		; 0 

	lsl.b	#2,d1
	adda.l	d1,a0			; passe cycle

not_cycle:
	addq.l	#6,a0			;passe: time wiever,lageur,hauteur


;........................................copie palette
copy_pal:	
	moveq.l	#0,d0			;R. pas d'erreur

	movea.l	#$ff8240,a3
	moveq.l	#7,d6			; 16 couleurs									
color:	move.l	(a0)+,(a3)+
	dbra.w	d6,color

;........................................depact image...............
;a0 a2 a3 source
;a1       destination

	lea.l	4000(a0),a3		; d‚but des datas image
	move.l	#1999,d1		; 10 blocks par ligne 10*200=2000

depack:	movea.l	a3,a2			; d‚but des data image
	adda.w	(a0)+,a2		; d‚calage index‚ au pointeur
	move.l	(a2)+,(a1)+		; copie data image
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbf.w	d1,depack		; dernier blocs ?

end_prg:
	swap	d0
	move.w	d7,d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts
	end
;-------------------------------------------------------------------------