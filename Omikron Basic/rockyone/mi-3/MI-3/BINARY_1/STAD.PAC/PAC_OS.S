**************************************************************************
; rockyone			pour MI-3 MI-9  	        28/07/2015  
;      						 
; Ajout resol et palette					19/02/2017
; Optimisation du code
; Voir modif dans save_pac
;
;			
;
;			  
;		open save STAD  FILE.PAC only in high resolution 		  	  
;	 
;		    		  
;		open	Call Pac_Os( L Source, L but,  0 )	
;		save 	Call Pac_Os( L but, L source,  1 )		  	  
;
; Return  	
;	in Low d0  	 0  not erreur
;			-2  if the buffer head is not a valid file STAD
;			or File size
;	in high d0      R‚solution only for open
;*************************************************************************

		movem.l	d1-d7/a0-a6,-(a7)
		movem.l	60(sp),a0-a1
		tst.w	68(sp)
		bne	save_pac

;-------------------------------------- OPEN PAC to PI3 -------------------

		move.w	#2,(a1)+	; write resol
		move.l	#$fff0000,(a1)	;       2 colors 
		lea.l	32(a1),a1	

		lea	32000(a1),a4	; - end of a column (400 line)
;					;   verticale
;					; - Fin ‚cran horyzontale 

		move.l	(a0)+,d7	; read ID PAC
        	move.b  (a0)+,d0  	;      id_byte      
        	move.b  (a0)+,d1 	;      pack_byte
        	move.b	(a0)+,d2 	;      special_byte
	

       		cmpi.l	#"pM85",d7
        	beq.s     horyzontale

		cmpi.l	#"pM86",d7
		beq.s	verticale

		moveq.l	#-2,d0		;Oops! this not a valid file
		bra.s	error
;-------------------------------------------------------------------------
;			 vertical depactage		
;-------------------------------------------------------------------------
verticale:	movea.l a1,a3		; start colomn, first line
		move.b	#80,d3		; 80 column

en_colonne: 	moveq.l	#0,d5           ; reset cpt
		move.b	(a0)+,d4  	; 
		cmp.b	d0,d4		; compared with id_byte
		beq.s	id_byte     	

		cmp.b	d2,d4     	; compared with special_byte
		beq.s	special_byte  	;

*oterwise				;
		move.b	d4,(a1)		; ( no repeat ) d5 = 0
		bra.s	copy_data

id_byte:	move.b	d1,d4     	; repeat pack_byte
		move.b	(a0)+,d5  	; number of repetition
		bra.s	repeat_data

special_byte:   move.b	(a0)+,d4   	; repeat byte 
		move.b	(a0)+,d5	; number of repetition

repeat_data: 	move.b	d4,(a1)
copy_data:	lea.l	80(a1),a1	; next line
		cmpa.l	a1,a4		; end of a column ?
		bne.s	continu		; no so different 
		subq.b	#1,d3		; decrement counter column
		beq.s	end_open
		addq.w	#1,a3		; incremented column
		movea.l	a3,a1		; screen next column
		addq.w	#1,a4		; end of the next column
continu:    	dbra.w	d5,repeat_data
		bra.s	en_colonne	; read a new command byte
							
;--------------------------------------------------------------------------
;			horyzontal depactage
;--------------------------------------------------------------------------
horyzontale:	moveq.l	#0,d5
		move.b	(a0)+,d4  	; read a byte
		cmp.b	d0,d4     	; compared with a id_byte
		beq.s	l_id_byte	; if equal

		cmp.b	d2,d4		; compared with special_byte
		beq.s	l_special_byte	; if equal

*othrewise:				; copien just once ( d5=0 )
		move.b	d4,(a1)+  	; copy and increments
		cmpa.l	a1,a4		; fine scren
		beq.s	end_open  	;
		bra.s	horyzontale    

l_id_byte:	move.b	d1,d4     	; retype Pack_byte
		move.b	(a0)+,d5	; number of repetition
		bra.s	recopy_data  	
 
l_special_byte:	move.b	(a0)+,d4  	; byte copy
		move.b	(a0)+,d5  	; number of repetition

recopy_data:	move.b	d4,(a1)+  	; copy and increments
		cmpa.l	a1,a4		; fine screen  -1 ?
		beq.s   end_open	; yes

		dbra.w	d5,recopy_data
		bra.s	horyzontale

end_open: 	moveq.l	#0,d0		; not_erreur
end_save:
error:		movem.l	(a7)+,d1-d7/a0-a6
		rts
		
***************************************************************************
;rockyone			POUR MI-3 MI-9 			29/06/2016
;
; source  buffer image format PI3
; but 	  buffer 32512 octet
;
;	         call pac_save( L source, L but )
;
;
; return size file in d0
;.........................................................................
; Ajout  Bra.s no_spe	entre ****				18/xx/2016
; Optimisation du code						18/02/2017
; Source et But invers‚ dans le basic				
; La flŠme de tous reprendre. Donc ...
;--------------------------------------------------------------------------

save_pac:	exg.l	a0,a1
;		-------------
		lea.l	34(a0),a0	; jump resol and palette
		
; comptage et tri des data identique (de 0 … 255)
		movea.l	a0,a2
		lea.l	32000(a1),a3	; pour garder propre le buffer 
		move.l	#32000-1,d0	; fin image -1 pour dbra

loop_1:		moveq.l #0,d1
		move.b	(a2)+,d1
		lsl.w	#1,d1		; *2 pour avoir une adresse pair
		addq.w	#1,0(a3,d1.w)
		dbra.w	d0,loop_1

; recherche id_byte, pack_byte, special_byte
		move.w	#255,d0		; compteur boucle uniquement 

		movem.l	(a1),d1-d7

*		moveq.l	#0,d1		; nb_pack
		move.l	#32000,d2	; nb_spe
*		moveq.l	#0,d3	
*		moveq.l	#0,d4		; id_bit
*		moveq.l	#0,d5		; pack_byte
*		moveq.l	#0,d6		; special_byte
*		moveq.l	#0,d7		; valeur de l'index

loop_2:		move.w	(a3)+,d3
		cmp.w	d3,d1		; cherche le data le plus utilis‚  
		bpl.s	no_pack		; d3<=d2   positif
		move.w	d3,d1		; nb_pack
		move.w	d7,d5		; pack_byte 
****
		bra.s	no_spe	
****
no_pack:	cmp.w	d3,d2		; cherche 2 datas les moins utilis‚
		bmi.s	no_spe		; d3>d2    n‚gatif
		move.w	d3,d2		; nb_spe
		move.w	d6,d4		; id_byte
		move.w	d7,d6		; special_byte
no_spe:		addq.w	#1,d7
		dbra.w	d0,loop_2
;................................................		
		lea.l	32000(a0),a2		; fin source
		movea.l	a1,a3
		move.l	#'pM85',(a3)+		; horizontal header
		move.b	d4,(a3)+		; id_byte
		move.b  d5,(a3)+		; pack_byte
		move.b	d6,(a3)+		; special_byte
;--------------------------------------------------------------------------
;			  COMPRESSION HORYZONTAL
;--------------------------------------------------------------------------
		moveq.l	#0,d1		
		moveq.l	#0,d2		
		moveq.l #0,d3		
boucle_1:       move.b	(a0),d1		; prendre 3 bytes de donnees
		move.b	1(a0),d2
		move.b	2(a0),d3

		cmp.b	d1,d2      
		bne.s	data_unique

		cmp.b	d1,d5			; pack_bytes ?
		beq.s	pack_id_byte		; oui
    
		cmp.b	d2,d3			; 3 octet ‚gaux ?
		beq.s	pack_spec_byte		; oui

		bra.s	data_unique

;...........................................ID_BYTE
pack_id_byte:	move.b	d4,(a3)			; save id_byt
		addq.l	#1,a0			; source+1

boucle_2:	cmp.b	(a0),d5			; pack_byte ?
		bne.s	fin_bl_2		; non

		cmpi.b	#255,1(a3)		; bloc complet ?
		beq.s	fin_bl_2		; oui

		cmpa.l	a2,a0     		; fin source ?
		bge.s	fin_bl_2		; oui

		addq.l	#1,a0			; pointeur source+1
		addq.b	#1,1(a3)		; n+1  (r‚p‚tition + 1)

		bra.s	boucle_2
fin_bl_2: 	addq.l	#2,a3			; destination +2
		bra.s	end_source

;...........................................SPECIAL_BYTE
pack_spec_byte:	move.b	d6,(a3)   		; save special_byte 
		move.b	d1,1(a3)  		; save data byte 
		addq.l	#1,a0			; source+1
boucle_3:	cmp.b	(a0),d1
		bne.s	fin_bl_3	

		cmpa.l	a2,a0     		; fin image ?
		bge.s	fin_bl_3		; oui

		cmpi.b	#255,2(a3)		; bloc complet ?
		beq.s	fin_bl_3

		addq.l	#1,a0			; source+1
		addq.b	#1,2(a3)		; n+1 (r‚p‚tition +1)
		bra.s	boucle_3

fin_bl_3: 	addq.l	#3,a3			; destination+3
		bra.s	end_source

;...........................................DATA UNIQUE

data_unique: 	cmp.b	d1,d4			; data byte = id_byte ?
		beq.s	pack_spec_byte

		cmp.b	d1,d6			; data byte = special_byte ?
		beq.s	pack_spec_byte

		move.b	(a0)+,(a3)+		; copier byte unique
;...............................................

end_source:	cmpa.l	a2,a0			;  ?
		bpl.s	fini			; oui

		bra.s	boucle_1
;...............................................
fini:  		suba.l	a1,a3     		; longeur fichier
		move.l	a3,d0			; dans d0 pour le basic
		bra	end_save

		END
;------------------------------------------------------------------------
