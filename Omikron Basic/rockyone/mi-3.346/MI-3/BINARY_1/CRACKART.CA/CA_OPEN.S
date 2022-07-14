;rockyone		pour MI-3 et Mi-9             modifi‚ le 07.06.2016
;
;
;		OPEN CRAK_ART 	: CA1 CA2 CA3
;
:
; Source	buffer contenant tous le fichier CA
; Destination	buffer de 32034 octet
;
;
;		CALL Ca_Open( L Source, L Destination )
;		--------------------------------------
;
;
; Return dans Low d0	-2 erreur format image
;
; Return dans destination l'image au format Degas
; 
;Format CrakArt 
;	+0 1 mot "CA"
;	+2 1 octet compression : 0 non compress‚, 1 compress‚
;	+3 1 octet r‚solution  : 0 1 2
;	+4 16 mots de couleur en basse r‚solution
;	    4 mots de couleur en moyenne r‚solution
;	    pas de palette en haute r‚solution
;
;	+4  : high resol...
;	+8  : medium resol...
;	+36 : low resol...
;
;	...	1 byte esc 
;		1 byte delta 
;		1 byte offset line
;-------------------------------------------------------------------------
; Dekomprimierung von CRACK ART Bildern (CA?)
; Copyright ½ Detlef R”ttger 04.03.1990

; GFA-Aufruf: ~C:CA_DECOMPRESS%( l:Quelle, l:Ziel )

*                TEXT
;a0 source
;a1 destination

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1  		

		move.w	#-2,d0			;R. bad file
		cmp.w	#$4341,(a0)+		; "CA" ?
		bne	error			;

*		moveq.l	#0,d0
		move.b	(a0)+,d0		; byte compression
		lea.l	34(a1),a2		 

;........................................copy_palette...................
		moveq.l	#0,d6
		move.b	(a0)+,d6		;  0 1 2 r‚solution image
		move.w	d6,(a1)+

		moveq.l	#8,d7
		lsr.b	d6,d7	
		lsr.b	d6,d7  			;  8 2 0 long word
		beq.s	high_pal

color:		move.l	(a0)+,(a1)+
		subq.b	#1,d7  	
		bhi.s	color
		bra.s	ok_pal

high_pal:	move.l	#$fff0000,(a1)


ok_pal:		movea.l	a2,a1

		tst.b	d0			; image compress‚ ?
		bne.s	depack			; oui

;.......................................image non compres‚..............
		move.w	#7999,d0
normal:		move.l	(a0)+,(a1)+
		dbra.w	d0,normal	
		bra.s	end_prg

;------------------------------------------------------------------------

depack:		movea.l	a1,a2	
		lea.l	32000(a1),a3		;end destination
		moveq.l	#0,d0
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a0)+,d7		; ESC
		move.b	(a0)+,d6		; DELTA

		move.w	(a0)+,d0		; Offset
		andi.w	#$7fff,d0
		movea.l	d0,a5

		move.b	d6,d1		 	;DELTA en Long word
		lsl.w	#8,d1
		move.b	d6,d1
		move.w	d1,d2
		swap	d1
		move.w	d2,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5

		movea.l	a3,a6         		; remplir cible avec Delta
		move.w	#1599,d0
delta:		movem.l	d1-d5,-(a6)
		dbra.w	d0,delta

		move.l	a5,d0		; Offset line
		subq.w	#1,d0		
		bmi.s	end_prg

main:		moveq.l #0,d1
		move.b	(a0)+,d1	; lire un octet
		cmp.b	d7,d1		; ESC ?
		beq.s	esccode

writeone:	move.b	d1,(a2)		; Si aucun ESC, r‚‚crire le meme
		adda.l	a5,a2		;+ offset line
		cmpa.l	a3,a2		; End destination
		blt.s	main		; if <

		addq.l    #1,a1
		movea.l   a1,a2
		dbra.w    d0,main

end_prg:	moveq.l	#0,d0
error:		movem.l   (sp)+,d1-d7/a0-a6
		rts

; Hier wurde ein ESC gefunden

esccode:	move.b    (a0)+,d1      ; deuxiŠme octet
		cmp.b     d7,d1		; ESC ?
		beq.s     writeone      ; 

		tst.b     d1            
		bne.s     code1

		moveq.l #0,d2		; ESC 00 ANZAHL-1 BYTE
		move.b    (a0)+,d2      ; Anzahl 3-255 ist bedeutet 4-256
		move.b    (a0)+,d1      ; gleiche Bytes

loop0:		move.b    d1,(a2)
		adda.l    a5,a2		;+ offset line
		cmpa.l    a3,a2		; end of a line
		blt.s     drin0		; >=

		addq.l    #1,a1
		movea.l   a1,a2
		subq.w    #1,d0         ; Ueberschlag gemacht
		bmi.s     end_prg

drin0:		dbra.w    d2,loop0
		bra.s     main

code1:		cmpi.b    #1,d1        
		bne.s     code2

		moveq.l #0,d2		; ESC 01 MULT REST-1 BYTE
		moveq.l	#0,d3
		move.b	(a0)+,d3	; Multiplikator
		lsl.w	#8,d3
		move.b	(a0)+,d2	; Anzahl 1-256
		add.w	d3,d2
		move.b	(a0)+,d1	; komprimiertes Byte
loop1:		move.b	d1,(a2)
		adda.l	a5,a2
		cmpa.l	a3,a2
		blt.s	drin1

		addq.l	#1,a1
		movea.l	a1,a2
		subq.w	#1,d0		; Ueberschlag gemacht
		bmi.s	end_prg

drin1:		dbra.w	d2,loop1
		bra.s	main

code2:		cmpi.b	#2,d1		; SAME
		bne.s	multiple	; Komprimiert 3<n<=256

		moveq.l	#0,d3
		move.b	(a0)+,d3	; Multiplikator
		beq.s	end_prg		; Code d'abandon ESC 02 00

		lsl.w	#8,d3
		moveq.l	#0,d2		; ESC 02 MULT REST-1
		move.b	(a0)+,d2	; nombre 1-256
		add.w	d3,d2
loop2:		adda.l	a5,a2		; DELTAs 'schreiben'
		cmpa.l	a3,a2
		blt.s	drin2

		addq.l  #1,a1
		movea.l a1,a2
		subq.w	#1,d0		; Ueberschlag gemacht
		bmi.s	end_prg

drin2:		dbra.w	d2,loop2
		bra	main

multiple:	moveq.l #0,d2		; ESC nombre-1 BYTE
		move.b	(a0)+,d2	; Byte
loop3:		move.b	d2,(a2)
		adda.l	a5,a2
		cmpa.l	a3,a2
		blt.s	drin3

		addq.l	#1,a1
		movea.l	a1,a2
		subq.w 	#1,d0		; Ueberschlag gemacht
		bmi	end_prg

drin3:		dbra.w	d1,loop3
		bra	main

                END
;*************************************************************************