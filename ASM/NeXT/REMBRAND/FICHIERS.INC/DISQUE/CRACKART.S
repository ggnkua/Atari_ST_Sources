;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                           %
;% Format d'une image Crack Art [*.CA?]      %
;%  1 mot d'identification du fichier ('CA') %
;%  1 octet, 0 -> non pack‚; sinon pack‚     %
;%  1 octet, r‚solution (offset:36/12/4)     %
;%  xx mots, palette (selon la r‚solution)   %
;%  xx octets, image (selon drapeau pack‚)   %
;%                                           %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
teste_image_crackart
charge_image_crackart
 move.l #32000,d0
 lea buffer_d‚packing,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_d‚packing

 bsr depacke_crack_art
 move.l buffer_fichier,a0
 addq #4,a0
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette
 move.l buffer_d‚packing,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move #0,offset_r‚siduel
 bsr charge_format_16_couleurs
 lea buffer_d‚packing,a0		Et on ejecte le bloc que l'on avait
 bsr.l libŠre_bloc			utilis‚ pour le d‚packing.
 moveq #0,d0
 rts


depacke_crack_art
 moveq #1,d0
 bsr affiche_formulaire_chargement
 move.l buffer_fichier,a0		Source
 lea 36(a0),a0
 move.l buffer_d‚packing,a1		Destination
 move.l a1,a2
 lea 32000(a1),a3

 moveq #0,d7
 moveq #0,d6
 move.b (a0)+,d7	ESC
 move.b (a0)+,d6	DELTA

 move (a0)+,d0		Offset
 and.l #$7fff,d0
 move.l d0,a5

 move.b d6,d1		DELTA in Langwoerter bringen
 lsl #8,d1
 move.b d6,d1
 move d1,d2
 swap d1
 move d2,d1
 move.l d1,d2
 move.l d1,d3
 move.l d1,d4
 move.l d1,d5

 move.l a3,a6		Ziel mit DELTA fuellen
 move #1599,d0
delta
 movem.l d1-d5,-(a6)
 dbra d0,delta

 move.l a5,d0		Offset
 subq #1,d0		Durchlaeufe
 bmi.s endmain
main
 clr d1
 move.b (a0)+,d1	Erstes Byte holen
 cmp.b d7,d1
 beq.s esccode

writeone
 move.b d1,(a2)		Wenn kein ESC, dann gleich schreiben
 add.l a5,a2
 cmp.l a3,a2
 blt.s main
 addq.l #1,a1
 move.l a1,a2
 dbra d0,main

endmain
 bsr.l ferme_formulaire
 rts

; Hier wurde ein ESC gefunden

esccode
 move.b (a0)+,d1	zweites Byte
 cmp.b d7,d1
 beq.s writeone		ESC schreiben

 tst.b d1		COMP0
 bne.s code1
 clr d2			ESC 00 ANZAHL-1 BYTE
 move.b (a0)+,d2	Anzahl 3-255 ist bedeutet 4-256
 move.b (a0)+,d1	gleiche Bytes
loop0
 move.b d1,(a2)
 add.l a5,a2
 cmp.l a3,a2
 blt.s drin0
 addq.l #1,a1
 move.l a1,a2
 subq #1,d0		Ueberschlag gemacht
 bmi.s endmain
drin0
 dbra d2,loop0
 bra.s main

code1
 cmpi.b #1,d1		COMP1
 bne.s code2
 clr d2			ESC 01 MULT REST-1 BYTE
 clr d3
 move.b (a0)+,d3	Multiplikator
 lsl #8,d3
 move.b (a0)+,d2	Anzahl 1-256
 add d3,d2
 move.b (a0)+,d1	komprimiertes Byte
loop1
 move.b d1,(a2)
 add.l a5,a2
 cmp.l a3,a2
 blt.s drin1
 addq.l #1,a1
 move.l a1,a2
 subq #1,d0		Ueberschlag gemacht
 bmi.s endmain
drin1
 dbra d2,loop1
 bra.s main

code2
 cmpi.b #2,d1		SAME
 bne.s multiple		Komprimiert 3<n<=256
 clr d3
 move.b (a0)+,d3	Multiplikator
 beq.s endmain		Abbruchcode ESC 02 00
 lsl #8,d3
 clr d2			ESC 02 MULT REST-1
 move.b (a0)+,d2	Anzahl 1-256
 add d3,d2
loop2
 add.l a5,a2		DELTAs 'schreiben'
 cmp.l a3,a2
 blt.s drin2
 addq.l #1,a1
 move.l a1,a2
 subq #1,d0		Ueberschlag gemacht
 bmi.s endmain
drin2
 dbra d2,loop2
 bra main

multiple
 clr d2			ESC ANZAHL-1 BYTE
 move.b (a0)+,d2	Byte
loop3
 move.b d2,(a2)
 add.l a5,a2
 cmp.l a3,a2
 blt.s drin3
 addq.l #1,a1
 move.l a1,a2
 subq #1,d0		Ueberschlag gemacht
 bmi endmain
drin3
 dbra d1,loop3
 bra main
