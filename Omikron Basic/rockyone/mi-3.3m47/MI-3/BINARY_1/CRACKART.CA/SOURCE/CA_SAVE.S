;rockyone			pour MI-3			26/06/2016
;
;	-----------------------------------------------------
;	SAVE IMAGE	CRACK_ART	CA1,CA2,CA3
;			GRAFIX_ART	GRX basse r‚solution
;
;
; Source		Buffer file type DEGAS PI1-3
; Destination		Buffer
; OP%			0	uncompressed alway for GRX
;			1	compressed
;
;	call ca_save( L source, L destination, op%)
;
; Return in do the file size
;	-----------------------------------------------------
; rockyone 
; Modif 27/03/2016
;	Ajout dans Buffer_Destination:
;	- entete "CA" 
;	- byte_compression = 1 compress‚, 0 non compress‚
;	- Byte_resolution = 0 1 2 
;	- Palette          32 8 0 bytes
;	- Sauvegarde image non compress‚
;	- Retourne dans d0 la taille complete du fichier
;			  	
; Omikron	ca_save( l Source, L Destination,compresion%)
;
; Warning	file_size= lpeek(reserved(0))' pour Crack_Art 
;		file_size=20224 '              pour Grafix_Art
;
;a0 ecran
;a1 Buffer_Destination = 32512 octets minimum
;compression% 1 = compress‚, 0 = non compresss‚
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
        movem.l 60(sp),a0-a1   	; adresse destination 
	move.w	68(sp),d0

	move.w	#$4341,(a1)+	; save identifiant Crak Art "CA"
	move.b	d0,(a1)+	; save flag compression
	move.b	1(a0),(a1)+	; save r‚solution
*	move.b	$44c,(a1)+	; save r‚solution ‚cran


;................................ calcul la taille de la palette..........		
*	move.b	$44c,d1		; resolution      0 1 2 (de l'‚cran)
	move.b	1(a0),d1	; resol source    0 1 2 
	lsl.b	d1,d1		;                 0 2 8
	addq.b	#1,d1		;                 1 3 9
	moveq.l	#64,d2
	lsr.b	d1,d2		; taille palette en octet 32 8 0
	move.b	d2,tail_pal	; Ajout dans d0 en quitant
;.........................................................................

	tst.b	d2		; sauver palette ?
	beq.s	no_pal          ; non, pas de palette en haute r‚solution

	lsr.b	#1,d2		; Nombre de couleur … copier 16,4,0
	subq.b	#1,d2		; -1 pour dbra

*	movea.l	#$ff8240,a3 	;palette ‚cran
	lea.l	2(a0),a3
copy_palette
	move.w (a3)+,(a1)+
	dbra.w	d2,copy_palette
no_pal
	lea.l	34(a0),a0
	movem.l	a0-a1,60(sp)
*	move.l	a1,64(sp)	; Destination : d‚but des donn‚e image
	

*	movea.l	60(sp),a0	; D‚but de l'image source

	cmp.b	#1,d0		; compression ?
	beq.s	compresse	; oui

;................................image non compress‚.....................	
	move.l	#8000,d1
normal
	move.l	(a0)+,(a1)+
	dbra.w	d1,normal
	move.l	#32000,d4
	bra	endprg

;................................image compress‚..........................
	move.l	a0,60(sp)	; d‚but des data image source
compresse
	moveq.l	#0,d2
;............................... COMPTAGE DES DATA IMAGE IDENTIQUE

        movea.l a0,a2           ; source
        move.w  #31999,d0       ; 32000 octets par ‚cran
compt_data:          
	moveq.l	#0,d1
	move.b  (a2)+,d1        ; Octet source
	add.w   d1,d1		; *2 pour avoir une adresse pair
	addq.w  #1,0(a1,d1.w)   ; Nombre r‚p‚tition d'un octet dans image
	dbra    d0,compt_data
;...............................
; Das seltenste Byte finden, von hinten suchen, damit die Wahrscheinlichkeit,
; daž das ESC Byte mit dem Anzahl-Z„hler bereinstimmt, geringer wird
;Trouver l'octet le plus rare en commencant par la fin de sorte que
; la probabilit‚e que l'octet ESC coincidera avec le Nombre est rare
; (ESC 0 Nombre-1 octet) est le moin plausible

;---------------------------------------; Recherche 
*                movea.l a1,a2          ; Minimum finden
                lea.l	512(a1),a2      ; an das Ende der Z„hler
                move.w	#32500,d1       ; Minimum vorbelegen
                move.w	#252,d0         ; Bytes 0,1,2 Codes reserv‚
minimum:        
		move.w	-(a2),d2
                cmp.w	d1,d2      	; Minimum ?
                bge.s	nextmin         ; No >=
                move.w	d0,d3           ; compteur
                move.w	d2,d1           ; Valeur minimum ?
                beq.s	minend    	; Yes
nextmin:        
		dbra    d0,minimum
minend:         
		addq.w  #3,d3           ; Esc Byte
                move.w  d3,d7           ; 

                movea.l a1,a2           ; Maximum finden
                move.w  #-1,d1          ; Maximum vorbelegen
                move.w  #255,d0
maximum:        
		move.w  (a2)+,d2
                cmp.w   d1,d2           ; mit bisherigem Maximum vergleichen
                ble.s   nextmax         ; bei gleichh„ufigen Bytes das erste nehmen
;                                         damit ESC und DELTA niemals gleich sein koennen
                move.w  d0,d3           ; Z„hler merken
                move.w  d2,d1           ; neues Maximum merken
nextmax:        
		dbra    d0,maximum
                neg.w   d3
                addi.w  #255,d3         ; DELTA Byte
                move.w  d3,d6           ; 


;.........................................Algorithme de compression....
*		movea.l	60(sp),a0       ; Source
                lea.l	32000(a0),a2    ; Fin source

                move.w	#32000,d4       ; Vergleichsl„nge
                lea.l	offset(pc),a6   ; Offset liste

while:          
		movea.l (a6)+,a5        ; Offset holen
                cmpa.l  #0,a5		;
                beq.s   endwhile        ; Offset=0 ist Abbruchkriterium
                cmpa.l  #-1,a5		; Fin ?
                beq.s   endprg          ; Yes

                movem.l 60(sp),a0/a3    ; Source / destination
                movea.l a0,a1           ; Workadresse
                move.b  d7,(a3)+        ; ESC auf Zielbildschirm merken
                move.b  d6,(a3)+        ; DELTA uebertragen
                move.w  a5,(a3)+        ; Offset
                move.w  #4,d3           ; Taille de l'image compress‚
;                                       ; ESC.b + DELTA.b + Offset.w
                move.l  a5,d0           ; Offset
                subq.w  #1,d0           ; Durchlaufz„hler

mainloop:       
		tst.w   d0
                bmi.s   endcode         ; new Offset
                move.b  (a1),d1         ; erstes Byte holen
                clr.w   d2              ; gleiche Bytes z„hlen
testloop:                               
;					; N„chste Adresse errechnen
                adda.l  a5,a1           ; Offset addieren
                cmpa.l  a2,a1           ; Hinter dem Bildschirmende ?
                blt.s   nextok          ; wenn nicht, dann weiter
                addq.l  #1,a0           ; sonst Quelladresse einen weiter
                movea.l a0,a1           ; und neue Workadresse
                subq.w  #1,d0           ; ein šberschlag
                bmi.s   compress        ; Ende der Kompression anzeigen
nextok:
                cmp.b   (a1),d1
                bne.s   compress        ; Reihe abgebrochen
                addq.w  #1,d2
                bra.s   testloop

endcode:        
		addq.w  #1,d3           ; Code: ESC 2 0  (Endekennung)
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

endwhile:
                cmp.w   #32000,d4
                bge.s   endprg
                move.w  #32000,d4
                lea     shortest(pc),a6		
                move.l  d5,(a6)
                move.l  #-1,4(a6)		
                bra.s   while

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
compress:
                tst.w   d0
                bpl.s   intern
                cmp.b   d6,d1           ; DELTA
                beq.s   endcode

intern:         
		cmp.b   d7,d1
                bne.s   noesc

compesc:        
		addq.w  #1,d3           ; Code: ESC ESC
                cmp.w   d4,d3		; >= ?
                bge     while           ; yes
                move.b  d7,(a3)+
                addq.w  #1,d3
                cmp.w   d4,d3		;
                bge     while		;
                move.b  d7,(a3)+
                dbra    d2,compesc      ; L„nge erh”hen
                bra     mainloop        ; und weiter

noesc:          
		cmp.w   #2,d2
                bgt.s   more            ; Plus de 3 octets ‚gaux
uncomp:         
		addq.w  #1,d3           ; Code: Byte
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                dbra    d2,uncomp
                bra     mainloop

more:           
		cmp.w   #255,d2
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
morenorm:       
		addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d2,(a3)+        ; Anzahl-1
                addq.w  #1,d3
                cmp.w   d4,d3
                bge     while
                move.b  d1,(a3)+        ; Byte
                bra     mainloop

evenmore:       
		cmp.b   d6,d1           ; DELTA ?
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

moredelta:      
		addq.w  #1,d3           ; Code: ESC 2 Mult Rest-1
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

                END
