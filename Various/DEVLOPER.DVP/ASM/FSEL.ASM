;
; consulter les fichiers par la boŒte de s‚lection
; Assembleur                 FSEL.ASM
;

               .INCLUDE 'GEM_INEX.ASM'

gemdos         = 1
crawcin        = 7
cconws         = 9
dgetdrv        = $19
dgetpath       = $47


               .TEXT 

main:          jsr        gem_init

               pea        affichage     ;Appel fonction
               pea        default       ;(avec les paramŠtres comme en C
               pea        masque        ;:mais dans l'ordre inverse)
               jsr        nomfich
               adda.l     #12,sp        ;Ici aussi: correction de la pile

               tst.w      d0            ;Erreur?
               beq.s      error

               pea        affichage
               bra.s      go_on

error:         pea        err_text

go_on:         move.w     #cconws,-(sp) ;Afficher message
               trap       #gemdos       ;(R‚sultat ou
               addq.l     #6,sp         ;message d'erreur)

               move.w     #crawcin,-(sp)
               trap       #gemdos
               addq.l     #2,sp

               jsr        gem_exit

               clr.w      -(sp)
               trap       #gemdos



nomfich:       

; Ce sous-programme appelle la boŒte de s‚lection des fichiers. Les
; paramŠtres suivants doivent ˆtre pos‚s sur la pile:
;    long   Pointeur sur une chaŒne dans laquelle on ‚crira
;           le nom complet du fichier
;    long   Pointeur sur le nom de fichier par d‚faut (13 octets
;           minimum)
;    long   Pointeur sur le masque de fichier par d‚faut (par ex. *.*)
; Toutes les chaŒnes se terminent par un octet nul.
; Valeur de fonction dans d0: 0 -> Cliqu‚ sur Quitte ou erreur
;                             1 -> Tout va bien


               link       a6,#0         ;a6 comme base des paramŠtres
               movem.l    d1-d7/a0-a5,-(sp)
               movea.l    16(a6),a2     ;Destination de l'affichage (1er ParamŠtre)

; Demander quel est le premier lecteur

               move.w     #dgetdrv,-(sp)
               trap       #gemdos
               addq.l     #2,sp
               addi.b     #'A',d0       ;R‚sultat de la fonction -> lettre
               move.b     d0,(a2)
               move.b     #':',1(a2)    ;Deux points aprŠs le lecteur

; Demander le chemin du lecteur courant

               clr.w      -(sp)         ;Lecteur courant
               pea        2(a2)
               move.w     #dgetpath,-(sp)
               trap       #gemdos
               addq.l     #8,sp

; \ et ajouter le masque

               clr.w      d1            ;Passer la longueur de la chaŒne
fsel_lp:       tst.b      0(a2,d1.w)    ;Octet nul?
               beq.s      fsel_le
               addq.w     #1,d1
               bra.s      fsel_lp

fsel_le:       move.b     #'\',0(a2,d1.w)

               clr.w      d2
               movea.l    8(a6),a3      ;Pointeur sur le masque
fsel_l2:       move.b     0(a3,d2.w),1(a2,d1.w)
               beq.s      fsel_e2
               addq.w     #1,d1
               addq.w     #1,d2
               bra.s      fsel_l2

fsel_e2:       
; Appel du fichier GEM de la boŒte de s‚lection des fichiers

               move.w     #90,control   ;Opcode de la fonction
               clr.w      control+2
               move.w     #2,control+4
               move.w     #2,control+6
               clr.w      control+8

               move.l     a2,addr_in    ;Chemin pr‚s‚lectionn‚
               move.l     12(a6),addr_in+4        ;et nom de fichier par d‚faut

               jsr        aes

               tst.w      int_out+2     ;Cliqu‚ Quitte au lieu de OK?
               bne.s      fsel_na
               clr.w      d0            ;alors terminer sur une erreur
               bra        fsel_q
fsel_na:       movea.l    12(a6),a3
               tst.b      (a3)          ;A-t-on s‚lectionn‚ un nom de fichier?
               bne.s      fsel_l3
               clr.w      d0            ;non, alors voir ci-dessus
               bra        fsel_q

; Nous devons maintenant int‚grer le nom du fichier … celui du
; chemin:

fsel_l3:       tst.b      (a2)+         ;Rechercher fin du nom de chemin
               bne.s      fsel_l3
fsel_l4:       cmpi.b     #'\',-(a2)    ;Rechercher le backslash
               bne.s      fsel_l4

               addq.l     #1,a2         ;Laisser le backslash

fsel_l5:       move.b     (a3)+,(a2)+   ;Copier le nom du fichier
               bne.s      fsel_l5

               move.w     #1,d0         ;Valeur de la fonction: tout est OK

fsel_q:        movem.l    (sp)+,d1-d7/a0-a5
               unlk       a6
               rts        


; Les segments DATA et BSS sont n‚cessaires au programme
; principal seulement et non au sous-programme "nom de fichier"

               .DATA 

masque:        .DC.b '*.*',0

default:       .DC.l 0,0,0,0

err_text:      .DC.b 'S‚lection invalide!',0

               .BSS 

affichage:     .DS.b 64

               .END 
