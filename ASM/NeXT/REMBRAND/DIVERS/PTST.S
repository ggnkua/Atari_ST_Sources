;
;
; Fonction COULEUR_POINT en mode 320x200x256 couleurs.
; 
; Taille de l'‚cran: 64000 octets
; Taille d'une ligne: 320 octets
;
; En entr‚e: X,Y,Adresse ‚cran
;
; couleur=C:COULEUR(W:x,W:y,L:Adresse)
;
 opt a+,p+
deb
 
* move #160,-(sp)
* move #100,-(sp)
* pea image+1024
* bsr calcule_couleur
* nop
* nop
 
calcule_couleur 
 move.l 4(sp),a0		Adresse … l'‚cran
 move 8(sp),d0 			Y
 mulu #320,d0			Offset vertical
 add.l d0,a0			Adresse verticale
 lea 16(a0),a0			Part de la fin du groupe

 move 10(sp),d1			X
 move d1,d2

 and #%1111,d1			Num‚ro du pixel dans le bloc
 moveq #15,d3
 sub d1,d3			Num‚ro inverse du pixel
 
 and #-1-%1111,d2		Octet pour l'affichage   
 add d2,a0			Adresse de d‚part du bloc

 moveq #0,d0			Commence par clearer le r‚sultat

 moveq #8-1,d7			Il y a 8 plans par pixel
.loop
 move -(a0),d2			Prend le mot suivant
 lsl d0				d‚calle le r‚sultat
 btst d3,d2			teste le D1 iŠme bit
 beq.s .bit_0
 bset #0,d0			Met le bit … 1 dans le r‚sultat
.bit_0 
 dbra d7,.loop
 rts

fin
