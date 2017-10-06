 


        bra debut
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       STOS BASIC LOADER / RUNTIME / GEM VERSION
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


even
; place pour le nom du fichier
name:     ds.b 16
	even
;-----------------------------> Adaptation aux differentes ROMS
; 1- MEGA ST
adapt:    dc.w $0102
          dc.l $2740
          dc.l $e4f
          dc.l $c76
          dc.l $26e6
          dc.l $27a8
          dc.l $e22
          dc.l $e8a
; 2- 520/1040 V 1.0
          dc.w $0100
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 3- 520/1040 V 1.1
          dc.w $0101
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 4- ROMS 1.4
	dc.w $0104
          dc.l $2882            ;adresses souris
          dc.l $e6b             ;adresse joystick
          dc.l $c92             ;buffer clavier
          dc.l $2828            ;table VDI 1
          dc.l $28ea            ;table VDI 2
          dc.l $e3e             ;vecteur inter souris
          dc.l $ea6             ;depart d'un son
; 5- ROMS 1.6
	dc.w $0106
          dc.l $28c2            ;adresses souris
          dc.l $eab             ;adresse joystick
          dc.l $cd2             ;buffer clavier
          dc.l $2868            ;table VDI 1
          dc.l $292a            ;table VDI 2
          dc.l $e7e             ;vecteur inter souris
          dc.l $ee6             ;depart d'un son
; 6- ROMS 1.62
	dc.w $0162
          dc.l $28c2            ;adresses souris
          dc.l $eab             ;adresse joystick
          dc.l $cd2             ;buffer clavier
          dc.l $2868            ;table VDI 1
          dc.l $292a            ;table VDI 2
          dc.l $e7e             ;vecteur inter souris
          dc.l $ee6             ;depart d'un son
; 7- Vide
          dc.w $ffff
          dc.l 0,0,0,0,0,0,0
; 8- Vide
	  dc.w $ffff
	  dc.l 0,0,0,0,0,0,0
NbAdapt:  equ 8

; table des 26 extensions possibles
extend:   ds.l 26          ;adresses d'entree des routines
	  ds.l 26
dta:      ds.b 50
adfin:    dc.l 0              ;adresse de chargement du prochain fichier
image:    dc.l 0
mode:     dc.w 0
handle:   dc.w 0
comline:  dc.l 0              ;Adresse command line
datas:    ds.b 152

curseur:  dc.b 27,"f",0
; Noms de fichier
path:     dc.b "\STOS",0
oldpath:  ds.b 64
newpath:  ds.b 64
pic1:     dc.b "PIC.PI1",0
pic2:     dc.b "PIC.PI3",0
name1:    dc.b "SPRIT???.BIN",0
name2:    dc.b "WINDO???.BIN",0
name3:    dc.b "FLOAT???.BIN",0
name4:    dc.b "MUSIC???.BIN",0
name5:    dc.b "BASIC???.BIN",0
namext:   dc.b "*.EX"
numbext:  dc.b 0,0

         even
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;         CHARGEMENT
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prend le nom demande dans la page de base
debut:  
        clr.l comline
        move.l 4(a7),a0
        lea 128(a0),a0          ;Longueur command line
        tst.b (a0)              ;Nulle?
        beq.s PasCom
        addq.l #1,a0
        move.l a0,comline         ;Stocke pour le basic
PasCom:
; Sauve les donnees ecran
          move.w #3,-(sp)       ;cherche l'adresse LOGIQUE
          trap #14
          addq.l #2,sp
          move.l d0,image
          pea getpal
          move #38,-(sp)        ;recopie la palette / adapte a l'ordinateur
          trap #14
          addq.l #6,sp
          lea datas+32,a6
          move.w #4,-(sp)
          trap #14              ; get res
          addq.l #2,sp
          move d0,mode
          lea adapt+2,a5
          move.l 12(a5),a0              ;table VDI 1
          moveq #$5a/2-1,d0
sv1:      move.w (a0)+,(a6)+            ;recopie...
          dbra d0,sv1
          move.l 16(a5),a0              ;table VDI 2
          moveq #$18/2-1,d0
sv2:      move.w (a0)+,(a6)+            ;recopie...
          dbra d0,sv2
          move.l 0(a5),a0               ;coordonnees de la souris
          move.l (a0),(a6)+
; installe le dta          
          move.l #finprg,adfin
          bsr setdta
; ouvre le folder
          clr.w -(sp)
          pea oldpath
          move.w #$47,-(sp)
          trap #1             ;getdir
          addq.l #8,sp
          tst.w d0
          bne erreur2
          lea oldpath,a0
          lea newpath,a1
load0:    move.b (a0)+,(a1)+  ;recopie le chemin
          bne.s load0
          lea oldpath,a0
          tst.b (a0)          ;ratrappe les bugs du TOS!
          bne.s load1
          move.b #"\",(a0)+
          clr.b (a0)
load1:    subq.l #1,a1
          lea path,a0
load2:    move.b (a0)+,(a1)+  ;additionne le nom
          bne.s load2
          lea newpath,a0
          bsr chdir
          bne erreur
;charge l'image
          cmp #2,mode
          beq.s load3
          lea pic1,a0
          bra.s load4
load3:    lea pic2,a0
load4:    bsr sfirst
          bne PasPic
          bsr open
          move.l image,a0       ;charge l'image en $70000
          sub.l #$8000,a0     
          move.l #32034,d0
          bsr readbis
          bsr close

; Une image! Prepare l'ecran
          dc.w $a00a                    ;enleve la souris
          tst mode
          beq sv3
          cmp #2,mode
          beq sv3
          move.w #0,-(sp)               ;passe en basse res s'il le faut!
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)
          trap #14
          add.l #12,sp
sv3:      lea curseur,a0                ;arrete le curseur
          bsr print

; Copie l'image en l'ouvrant
          move.l image,-(sp)
          sub.l #$7ffe,(sp)
          move.w #6,-(sp)       ;set palette
          trap #14
          addq.l #6,sp

          moveq #1,d6
Ouvre1:   move.l image,a2
          move.l a2,a3
          add.l #15840,a2
          add.l #16000,a3
          move.l a2,a0
          move.l a3,a1
          sub.l #32768-34,a0
          sub.l #32768-34,a1
          moveq #99,d7
          addq #1,d6
          cmp #100,d6
          bhi TrpLoad
          moveq #50,d5
Ouvre2:   add.w d6,d5
          cmp.w #100,d5
          bcs.s Ouvre4
          sub.w #100,d5
          movem.l a0-a3,-(sp)
          moveq #9,d0
Ouvre3:   move.l (a0)+,(a2)+
          move.l (a0)+,(a2)+
          move.l (a0)+,(a2)+
          move.l (a0)+,(a2)+
          move.l (a1)+,(a3)+
          move.l (a1)+,(a3)+
          move.l (a1)+,(a3)+
          move.l (a1)+,(a3)+
          dbra d0,Ouvre3
          movem.l (sp)+,a0-a3
          sub.l #160,a2
          add.l #160,a3
Ouvre4:   sub.l #160,a0
          add.l #160,a1
          dbra d7,Ouvre2
          bra Ouvre1      

; Pas d'image sur la disquette: enleve la souris
PasPic:   dc.w $a00a
          lea Curseur,a0
          bsr Print
        
; charge et appelle les trappes
TrpLoad:  lea name1,a0        ;sprites
          bsr exec
          lea adapt+2,a3
          jsr (a0)            ;installe les trappes  
          move.l a0,adfin     ;poke l'adresse REELE de fin
          lea name2,a0        ;windows
          bsr exec
          lea adapt+2,a3
          jsr (a0)
          move.l a0,adfin
; Charge le float s'il est la!
          lea name3,a0
          bsr execla
          bne FlPaLa
          lea adapt+2,a3
          jsr (a0)            ;ne ramene pas d'adresse!
FlPaLa:   lea name4,a0        ;music
          bsr exec
          lea adapt+2,a3
          jsr (a0)
          move.l a0,adfin
; charge et appelle les extensions, poke les adresses
          clr d7
          lea extend,a6
load5:    move.b d7,numbext
          add.b #65,numbext
          lea namext,a0
          bsr sfirst
          bne.s load6
          lea namext,a0
          bsr exec
          movem.l a6/d6/d7,-(sp)
          lea adapt+2,a3
          jsr (a0)
          move.l a0,adfin
          movem.l (sp)+,a6/d6/d7
          move d7,d6
          lsl #2,d6
          move.l a1,0(a6,d6.w)          ;poke l'adresse de debut
load6:    addq #1,d7
          cmp #26,d7
          bcs.s load5

; charge le basic
          lea name5,a0
          bsr exec
; remet directory precedent
          move.l a0,-(sp)
          lea oldpath,a0
          bsr chdir
          move.l (sp)+,a6
; efface l'ecran, passe en moyenne si couleur
          move #37,-(sp)        ;Synchronise
          trap #14
          addq.l #2,sp
          move.l image,a0
          move.w #7999,d0
load7:    clr.l (a0)+
          dbra d0,load7
          cmp #2,mode
          beq.s load8
          move.w #1,-(sp)
          move.l #-1,-(sp)
          move.l #-1,-(sp)
          move.w #5,-(sp)
          trap #14
          add #12,sp

; appel du basic
load8:    lea extend,a0                 ;adresse de la table extention
          lea name,a1                   ;adresse du nom du fichier!
          lea oldpath,a2                ;ancien directory
          lea adapt+2,a3                ;adresse des adresses
          moveq #1,d0                   ;RUNTIME!
          jsr (a6)                      ;branche au basic!
          bra erreur2

; erreur dans le chargement---> retour au GEM
erreur:   bsr close
          lea oldpath,a0
          bsr chdir

; erreur de chargement ou revient du basic
erreur2:  move.w mode,-(sp)
          move.l image,-(sp)
          move.l image,-(sp)
          move.w #5,-(sp)
          trap #14
          add #12,sp
          lea datas+32,a6
          lea adapt+2,a5
          move.l 12(a5),a0      ;table VDI 1
          moveq #$5a/2-1,d0
lv1:      move.w (a6)+,(a0)+
          dbra d0,lv1
          move.l 16(a5),a0      ;table VDI 2
          moveq #$18/2-1,d0
lv2:      move.w (a6)+,(a0)+
          dbra d0,lv2
          move.l 0(a5),a0       ;adresse souris
          move.l (a6)+,(a5)     ;coords de la souris
          pea datas
          move #6,-(sp)
          trap #14
          addq.l #6,sp
          move.w #37,-(sp)
          trap #14
          addq.l #2,sp
; RETOUR!
          clr.w -(sp)
          trap #1 

; -superviseur- SAUVE LA PALETTE et ADAPTE A L'ORDINATEUR
; installe aussi la fausse trappe FLOAT!
getpal:   lea $ff8240,a0
          lea datas,a1
          moveq #15,d0
gp1:      move.w (a0)+,(a1)+
          dbra d0,gp1
; Adapte ST/STE
	  move.l $8,d1
	  move.l #Ste,$8
	  move.l sp,d2
	  move.w $FC0002,d0
FinSte:	  move.l d2,sp
	  move.l d1,$8
          lea adapt(pc),a0
          moveq #NbAdapt-1,d1
adapt1:   cmp.w (a0)+,d0
          beq.s adapt2
          add.w #28,a0
          dbra d1,adapt1
          lea adapt+2(pc),a0        ;par defaut: ROM du mega ST
adapt2:   lea adapt+2(pc),a2
          moveq #6,d0
adapt3:   move.l (a0)+,(a2)+    ;recopie en ADAPT+2
          dbra d0,adapt3
; Fausse trappe FLOAT en trappe 6
          lea FauxFloat(pc),a0
          move.l a0,$98
          rts
; Erreur de bus si sur STE
Ste:	  move.w $E00002,d0
	  bra.s FinSte

; FAUSSE TRAPPE FLOAT!
FauxFloat:
          cmp.b #$0c,d0         ;Ramene toujours 0
          beq.s FxFl1
          moveq #0,d0
          moveq #0,d1
          rte
FxFl1:    move.b #"0",(a0)      ;Ramene toujours la chaine nulle
          move.b #".",1(a0)
          move.b #"0",2(a0)
          clr.b 3(a0)
          rte

; SETDTA
setdta:   move.l a0,-(sp)
          move.l #dta,-(sp)
          move #$1a,-(sp)
          trap #1
          addq.l #6,sp
          move.l (sp)+,a0
          rts

; CHDIR
chdir:    move.l a0,-(sp)
          move.w #$3b,-(sp)
          trap #1
          addq.l #6,sp
          tst d0
          rts

; SFIRST
sfirst:   clr -(sp)
          move.l a0,-(sp)
          move #$4e,-(sp)
          trap #1
          addq.l #8,sp
          move.l #dta+30,a0   ;pointe le nom
          tst d0
          rts

; OPEN
open:     clr -(sp)
          move.l a0,-(sp)
          move.w #$3d,-(sp)
          trap #1
          addq.l #8,sp
          tst.w d0
          bmi erreur
          move d0,handle
          rts

; READ
read:     move.l dta+26,d0
readbis:  move.l a0,-(sp)
          move.l d0,-(sp)
          move.w handle,-(sp)
          move.w #$3f,-(sp)
          trap #1
          add.l #12,sp
          tst.l d0
          bmi erreur
          rts

; CLOSE
close:    move handle,-(sp)
          move #$3e,-(sp)
          trap #1
          addq.l #4,sp
          rts

; PRINT
print:    move.l a0,-(sp)
          move #9,-(sp)
          trap #1
          addq.l #6,sp
          rts

; EXEC normal ---> erreur si fichier pas sur le disque
exec:     bsr execla
          bne erreur
          rts
; EXEC: charge le programme -s'il est la- et le reloge!
execla:   movem.l d1-d3/a1-a3,-(sp)
          bsr setdta
          bsr sfirst
          bne exepala
          move.l adfin,d3     ;verifie la taille memoire!
          add.l dta+26,d3
          add.l #60000,d3
          cmp.l image,d3
          bcc erreur
          bsr open
          move.l adfin,a0
          bsr read
          bsr close 
; reloge le programme!
          move.l adfin,a1
          move.l 2(a1),d0     ;distance a la table
          add.l 6(a1),d0
          and.l #$ffffff,d0
          add #$1c,a1         ;pointe le debut du programme
          move.l a1,a2
          move.l a2,d2        ;d2=debut du programme
          add.l d0,a1
          clr.l d0
          tst.l (a1)
          beq.s exec3
          add.l (a1)+,a2      ;pointe la premiere adresse a reloger !!!
          bra.s exec1
exec0:    move.b (a1)+,d0
          beq.s exec3
          cmp.b #1,d0
          beq.s exec2
          add d0,a2           ;pointe dans le prg
exec1:    add.l d2,(a2)       ;change dans le programme
          bra.s exec0
exec2:    add.w #254,a2       ;si 1 saute 254 octets
          bra.s exec0
; remonte adfin avec la longeur du programme
exec3:    move.l adfin,a0
          move.l a0,d0
          add.l dta+26,d0
          btst #0,d0            ;Rend pair
          beq.s Pair
          addq.l #1,d0
Pair:     move.l d0,adfin
          movem.l (sp)+,d1-d3/a1-a3
          moveq #0,d0
          rts
exepala:  movem.l (sp)+,d1-d3/a1-a3
          moveq #1,d0
          rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

finprg:   equ *


