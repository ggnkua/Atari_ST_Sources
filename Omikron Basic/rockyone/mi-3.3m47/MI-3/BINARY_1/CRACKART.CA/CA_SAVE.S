;rockyone		  pour MI-3 et Mi-9		        26/06/2016
;modifi‚ 							22.01.2018
;inversion buffer						10.01.2021
;
;		SAVE IMAGE	CRACK_ART	CA1,CA2,CA3
;		 		GRAFIX_ART	GRX basse r‚solution
;			  	
; source	 buffer image PI1-3
; but		 Buffer  32512 octets minimum
; op% 		1 = compress‚, 0 = non compresss‚;
;
; 		ca_save( L Source, L Destination, dummy%, dummy%, op%)
; 		------------------------------------------------------	
;		
; Return in do the file size
;-------------------------------------------------------------------------
;
; CRACK ART Kompressionsroutine fr Bilddaten (CA?)
; Copyright ½ Detlef R”ttger 04.03.1990
; Codes de compression
; Byte                   = octet non compress‚
; ESC ESC                = un octet ESC
; ESC nombre-1 octet     = Nombre d'octet ‚gaux
; ESC 0 nombre-1 octet   = Nombre de meme octet (n”tig, si Nombre-1=ESC)
; ESC 1 Mult Rest-1 Byte = 256 * Mult + Rest meme octet
; ESC 2 Mult Rest-1      = 256 * Mult + Rest meme DELTA Bytes
; ESC 2 0                = Fin

; Komprimiertes Image:
; ESC.b DELTA.b OFFSET.w Komprimierte_Bilddaten... ESC 2 0

		movem.l d1-d7/a0-a6,-(sp) 
		  
	        movem.l 60(sp),a0-a1   	
		move.w	72(sp),d0
		andi.b	#1,d0

		move.w	#$4341,(a0)+	; save identifiant Crak Art "CA"
		move.b	d0,(a0)+	; save flag compression
		move.b	1(a1),(a0)+	; save r‚solution

;................................ calcul la taille de la palette..........		
		move.b	1(a1),d1	; resol source    0 1 2 
		lsl.b	d1,d1		;                 0 2 8
		addq.b	#1,d1		;                 1 3 9
		moveq.l	#64,d2
		lsr.b	d1,d2		; taille palette en octet 32 8 0
		move.b	d2,tail_pal	; Ajout dans d0 en quitant
;........................................

		tst.b	d2		; sauver palette ?
		beq.s	no_pal          ; pas de palette en haute r‚sol.

		lsr.b	#1,d2		; 16 ou 4 couleurs … copier
		subq.b	#1,d2		; -1 pour dbra
		lea.l	2(a1),a3
copy_palette:	move.w (a3)+,(a0)+
		dbra.w	d2,copy_palette

no_pal:		lea.l	34(a1),a1
		movem.l	a0-a1,60(sp)	; sauve adresse des data image
		lea.l	32000(a1),a2	; fin image source

		cmp.b	#1,d0		; compression ?
		beq.s	compresse	; oui

;................................image non compress‚.....................	
normal:		move.l	(a1)+,(a0)+
		cmpa.l	a1,a2
		bhi.s	normal
		move.l	#32000,d4
		bra	endprg

;................................image compress‚..........................
;                                       ; comptage des data identique
compresse: 	movea.l a1,a5           ; source
compt_data:    	moveq.l	#0,d2
		move.b  (a5)+,d2        ; Octet source
		add.w   d2,d2		; *2 pour avoir une adresse pair
		addq.w  #1,0(a0,d2.w)   ; Nombre r‚p‚tition d'un octet 
		cmpa.l	a5,a2
		bhi.s	compt_data

;...............................
;Trouver l'octet le plus rare en commencant par la fin de sorte que
; la probabilit‚e que l'octet ESC coincidera avec le Nombre est rare
; (ESC 0 Nombre-1 octet) est le moin plausible
;---------------------------------------; Recherche minimum
*		moveq.l	#0,d2
                lea.l	512(a0),a5      
                move.w	#32500,d1       ; Minimum 
                move.w	#252,d0         ; Bytes 0,1,2 Codes reserv‚
minimum:        move.w	-(a5),d2
                cmp.w	d1,d2      	; Minimum ?
                bge.s	nextmin         ; >=

                move.w	d0,d3           
                move.w	d2,d1           ; Valeur minimum ?
                beq.s	minend    	; Yes
nextmin:        dbra    d0,minimum

minend:         addq.w  #3,d3           ; Esc Bytem  >= 3
                move.w  d3,d7           ; 
;.......................................; recheche maximum
                movea.l a0,a5           
                move.w  #-1,d1          
                move.w  #255,d0         
maximum:        move.w  (a5)+,d2
                cmp.w   d1,d2           
                ble.s   nextmax         
;                                       
                move.w  d0,d3           
                move.w  d2,d1           
nextmax:        dbra    d0,maximum

                neg.w   d3
                addi.w  #255,d3         ; DELTA Byte
                move.w  d3,d6           ; 


;.........................................Algorithme de compression....
*		movea.l 64(sp),a1       ; Source
*               lea.l	32000(a1),a2    ; Fin source

                move.w	#32000,d4       ; Vergleichsl„nge
                lea.l	offset(pc),a6   ; Offset liste

while:          movea.l (a6)+,a5        ; Offset holen
                cmpa.l  #0,a5		;
                beq.s   endwhile        ; Offset=0 ist Abbruchkriterium

                cmpa.l  #-1,a5		; Fin ?
                beq.s   endprg          ; Yes

*                movem.l 60(sp),a1/a3    ; Source / destination
		movea.l	60(sp),a3	; destination
		movea.l	64(sp),a1	; source
                movea.l a1,a0           ; Workadresse
                move.b  d7,(a3)+        ; ESC auf Zielbildschirm merken
                move.b  d6,(a3)+        ; DELTA uebertragen
                move.w  a5,(a3)+        ; Offset
                move.w  #4,d3           ; Taille de l'image compress‚
;                                       ; ESC.b + DELTA.b + Offset.w
                move.l  a5,d0           ; Offset
                subq.w  #1,d0           ; Durchlaufz„hler
mainloop:       tst.w   d0
                bmi.s   endcode         ; new Offset

                move.b  (a0),d1         ; erstes Byte holen
                clr.w   d2              ; gleiche Bytes z„hlen
testloop:                               
;					; N„chste Adresse errechnen
                adda.l  a5,a0           ; Offset addieren
                cmpa.l  a2,a0           ; Hinter dem Bildschirmende ?
                blt.s   nextok          ; wenn nicht, dann weiter
                addq.l  #1,a1           ; sonst Quelladresse einen weiter
                movea.l a1,a0           ; und neue Workadresse
                subq.w  #1,d0           ; ein šberschlag
                bmi.s   compress        ; Ende der Kompression anzeigen

nextok:		cmp.b   (a0),d1
                bne.s   compress        ; Reihe abgebrochen

                addq.w  #1,d2
                bra.s   testloop

endcode:        addq.w  #1,d3           ; Code: ESC 2 0  (Endekennung)
                cmp.w   d4,d3
                bge.s   while
                move.b  d7,(a3)+        ; ESC
                addq.w  #1,d3
                cmp.w   d4,d3
                bge.s   while
                move.b  #2,(a3)+        ; 2
                addq.w  #1,d3
                cmp.w   d4,d3
                bge.s   while
                clr.b   (a3)+           ; 0

                move.w  d3,d4           ; nouvelle longeur
                move.l  a5,d5           ; Offset
                bra.s   while           ; und weiter

endwhile:       cmp.w   #32000,d4
                bge.s   endprg
                move.w  #32000,d4
                lea     shortest(pc),a6		
                move.l  d5,(a6)
                move.l  #-1,4(a6)		
                bra	while

endprg:     
;					; Dans d0 la taille du fichier    
	moveq.l	#4,d0			;   Taille de l'entete  
	move.b	tail_pal,d1		;   
	add.b	d1,d0			; + Taille de la palette
	add.w	d4,d0			; + Taille des donn‚es image
	movem.l (sp)+,d1-d7/a0-a6
	rts

;........................................compresse..............
; d1.b octet
; d2.w nombre
compress:	tst.w   d0
                bpl.s   intern
                cmp.b   d6,d1           ; DELTA
                beq.s   endcode

intern:         cmp.b   d7,d1
                bne.s   noesc

compesc:        addq.w  #1,d3           ; Code: ESC ESC
                cmp.w   d4,d3		; >= ?
                bge     while           ; yes
                move.b  d7,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3		;
                bge     while		;
                move.b  d7,(a3)+
                dbra    d2,compesc      ; L„nge erh”hen
                bra     mainloop        ; und weiter

noesc:          cmp.w   #2,d2
                bgt.s   more            ; Plus de 3 octets ‚gaux

uncomp:         addq.w  #1,d3           ; Code: Byte
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                dbra    d2,uncomp
                bra     mainloop

more:           cmp.w   #255,d2
                bgt.s   evenmore
                addq.w  #1,d3           ; Code: ESC numero-1 octet
                cmp.w   d4,d3           ; oder: ESC 0 numero-1 octet
                bge     while
                move.b  d7,(a3)+        ; ESC
                cmp.b   d7,d2           ; zuf„llig Anzahl-1 = ESC ?
                bne.s   morenorm
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                clr.b   (a3)+           ; 00
morenorm:       addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d2,(a3)+        ; Anzahl-1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                bra     mainloop

evenmore:       cmp.b   d6,d1           ; DELTA ?
                beq.s   moredelta
                addq.w  #1,d3           ; Code: ESC 1 Mult Rest-1 Byte
                cmp.w   d4,d3
                bge     while
                move.b  d7,(a3)+        ; ESC
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  #1,(a3)+        ; 1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                movea.w d2,a4           ; sichern
                lsr.w   #8,d2           ; div 256
                move.b  d2,(a3)+        ; Mult
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.w  a4,d2
                and.w   #255,d2
                move.b  d2,(a3)+        ; Rest-1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                bra     mainloop

moredelta:      addq.w  #1,d3           ; Code: ESC 2 Mult Rest-1
                cmp.w   d4,d3
                bge     while
                move.b  d7,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  #2,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                movea.w d2,a4           ; sichern
                lsr.w   #8,d2           ; div 256
                move.b  d2,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.w  a4,d2
                and.w   #255,d2
                move.b  d2,(a3)+
                bra     mainloop

*               DATA
                EVEN

offset:         DC.L	160,8,80,1,2,4,320,640,480,0
shortest:       DC.L	0,-1
tail_pal:	dc.b	0
		even
                END
