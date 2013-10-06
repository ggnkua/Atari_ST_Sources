;
; Travail sur deux Çcrans logiques (graphisme sans scintillement)
; Assembleur                           MULTISCR.ASM
;

gemdos         = 1
xbios          = 14
logbase        = 3
setscreen      = 5
cconws         = 9
vsync          = 37


               .TEXT 

               .DC.w $a00a              ;DÇsactive le pointeur de la souris
               pea        clrscr        ;Efface l'Çcran
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #logbase,-(sp)          ;Lire l'adresse de l'Çcran
               trap       #xbios
               addq.l     #2,sp
               movea.l    d0,a6
               move.l     d0,savescr    ;et stocker

               move.l     #freemem,d0   ;Effacer 2äme Çcran
               addi.l     #256,d0       ;doit commencer au bord de la page mÇmoire
               andi.l     #$ffffff00,d0
               movea.l    d0,a4

               lea.l      (a4),a3
               move.w     #32000/4-1,d0 ;Efface l'Çcran
clrloop:       clr.l      (a3)+
               dbra       d0,clrloop

; Les caractäres dÇfinis Ö partir de char_pt doivent àtre recopiÇs et
; dÇcalÇs horizontalement:

               lea.l      char_pt,a0    ;Copie caractäre d'origine
               lea.l      characters,a1
               move.w     #16*8-1,d0
loop1:         move.b     (a0)+,(a1)+
               dbra       d0,loop1

               moveq.l    #7-1,d0       ;Forme 7 variations
               lea.l      characters,a0 ;Ligne 'Original'
loop2:         moveq.l    #16-1,d2      ;16 lignes de pixels par caractäre
loop3:         moveq.l    #8-1,d1       ;8 octets par ligne de pixels
loop4:         move.b     0(a0,d1.w),0(a1,d1.w)
               dbra       d1,loop4

; DÇcalage de cette nouvelle ligne d'un pixel Ö gauche

               andi.b     #%11101111,ccr          ;Effacer l'octet x
               roxr       (a1)          ;DÇcaler octets vers la droite
               roxr       2(a1)         ;Reports dans l'octet x
               roxr       4(a1)
               roxr       6(a1)

               addq.l     #8,a0         ;Ligne de pixels suivante
               addq.l     #8,a1
               dbra       d2,loop3
               dbra       d0,loop2

; Indication des Çcrans physique et logique:

               move.w     #-1,-(sp)     ;Ne pas modifier la rÇsolution
               pea        (a4)          ;physique
               pea        (a6)          ;logique
               move.w     #setscreen,-(sp)
               trap       #xbios
               adda.l     #12,sp

; Afficher texte:

               move.w     #20,d2        ;CoordonnÇes x et y de dÇbut

mainloop:      lea.l      (a6),a5
               lea.l      characters,a0

; d2*80 est l'offset pour ligne / x*80 correspond Ö (x*4+1)*16

               clr.l      d3
               move.w     d2,d3
               asl.w      #2,d3         ;*4
               add.w      d2,d3         ;+1
               asl.w      #4,d3         ;*16
               adda.l     d3,a5         ;Adresse de la ligne de l'Çcran

; Variation horizontale: d2 mod 8 (=d2 and 7)

               move.w     d2,d3
               andi.w     #7,d3

; *128 est l'offset du tableau character:

               asl.w      #7,d3         ;*128
               adda.l     d3,a0         ;Adresse du jeu de characters

; Colonne: d2 div 8

               move.w     d2,d3
               asr.w      #3,d3
               adda.l     d3,a5         ;Adresse dans Video-RAM

; êcriture des caractäres:

               moveq.l    #16-1,d1      ;16 lignes de pixels
lop0:          moveq.l    #8-1,d0
lop1:          move.b     0(a0,d0.w),0(a5,d0.w)
               dbra       d0,lop1
               adda.l     #80,a5        ;Ligne Çcran suivante
               addq.l     #8,a0         ;Ligne character suivante
               dbra       d1,lop0

; Commutation des Çcrans:

               exg.l      a4,a6
               move.w     #-1,-(sp)     ;Ne pas changer de rÇsolution
               pea        (a4)          ;physique
               pea        (a6)          ;logique
               move.w     #setscreen,-(sp)
               trap       #xbios
               adda.l     #12,sp

               move.w     #vsync,-(sp)  ;Attendre le recul de l'image
               trap       #xbios
               addq.l     #2,sp

               addq.w     #1,d2         ;Position suivante
               cmpi.w     #300,d2       ;Fin?
               ble        mainloop

               move.w     #7,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #-1,-(sp)     ;Ne pas changer de rÇsolution
               move.l     savescr,-(sp) ;Restituer l'ancien Çtat
               move.l     savescr,-(sp)
               move.w     #setscreen,-(sp)
               trap       #xbios
               adda.l     #12,sp


               .DC.w $a00a              ;RÇactiver le pointeur de la souris
               clr.w      -(sp)
               trap       #gemdos


               .DATA 

clrscr:        .DC.b 27,'E',0

char_pt:       .DC.b 0,0,0,0,0,0,0,0
               .DC.b 0,0,0,0,0,0,0,0
               .DC.b 0,102,0,56,56,0,24,0         ;Codes Çcran pour
               .DC.b 0,102,0,56,56,0,24,0         ;La chaåne 'Hallo!'
               .DC.b 0,102,0,24,24,0,24,0
               .DC.b 0,102,60,24,24,60,24,0
               .DC.b 0,126,62,24,24,126,24,0
               .DC.b 0,126,6,24,24,102,24,0
               .DC.b 0,102,62,24,24,102,24,0
               .DC.b 0,102,126,24,24,102,24,0
               .DC.b 0,102,102,24,24,102,0,0
               .DC.b 0,102,102,24,24,102,0,0
               .DC.b 0,102,126,60,60,126,24,0
               .DC.b 0,102,62,60,60,60,24,0
               .DC.b 0,0,0,0,0,0,0,0
               .DC.b 0,0,0,0,0,0,0,0


               .BSS 

savescr:       .DS.l 1

freemem:       .DS.b 32256              ;De la place pour le 2äme Çcran

; Place pour 8 lettres de 12 octets
; dans 8 orientations horizontales:

characters:    .DS.b 8*16*8

               .END 
