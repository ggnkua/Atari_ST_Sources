;
; Programme d'interruption dans la Queue VBL
; Assembleur       VBLQUEUE.ASM
;


gemdos         = 1
xbios          = 14
cconws         = 9
supexec        = 38
ptermres       = $31

nvbls          = $454
_vblqueue      = $456
_v_bas_ad      = $44e

               .TEXT 

               movea.l    4(sp),a0      ;Calcul du besoin d'espace m‚moire
               move.l     #$100,d6      ;Taille fixe de la basepage
               add.l      12(a0),d6     ;+ Taille du segment TEXT
               add.l      20(a0),d6     ;+ Taille du segment DATA
               add.l      28(a0),d6     ;+ Taille du segment BSS

               pea        init_vbl      ;L'initialisation doit
               move.w     #supexec,-(sp)          ;se faire
               trap       #xbios        ;en mode superviseur
               addq.l     #6,sp

               tst.w      err_flag      ;Initialisation r‚ussie?
               beq.s      keep          ;oui, alors garder r‚sident

               clr.w      -(sp)         ;sinon, terminer normalement
               trap       #gemdos

keep:          clr.w      -(sp)         ;Pas de message d'erreur
               move.l     d6,-(sp)      ;Espace m‚moire n‚cessaire
               move.w     #ptermres,-(sp)         ;garder r‚sident
               trap       #gemdos       ;Fin programme principal

; Installation de la routine interrupt dans la queue VBL:

init_vbl:      move.w     nvbls,d0      ;Nombre maxi des entr‚es de la queue VBL
               lsl.w      #2,d0         ;* 4
               movea.l    _vblqueue,a0  ;Liste des adresses
               clr.w      d1

vbl_search:    tst.l      0(a0,d1.w)    ;Tester l'entr‚e
               beq        vbl_found     ;0, alors l'entr‚e est libre
               addq.w     #4,d1         ;sinon tester le long mot suivant
               cmp.w      d0,d1         ;Fin de la liste?
               bne.s      vbl_search    ;non, continuer recherche

               move.w     #-1,err_flag  ;Stocker erreur
               rts                      ;et retourner au programme principal

vbl_found:     bsr        get_shiftptr
               move.l     #routine,0(a0,d1.w)     ;Entrer adresse
               rts        

get_shiftptr:  
; Donner l'adresse de l'‚tat des touches sp‚ciales:

               cmpi.w     #$100,$fc0002 ;Version du TOS
               ble        ancien_tos
               move.l     $fc0024,shiftptr        ;BlitterTOS: Adresse en ROM
               rts        
ancien_tos:    move.l     #$e1b,shiftptr          ;Sinon adresse fixe
               rts        

; Routine interrupt, appel‚e … chaque VBL … partir de maintenant

routine:       movea.l    shiftptr,a0   ;Consulter les touches sp‚ciales
               move.b     (a0),d0
               andi.b     #%1111,d0     ;Touches sp‚ciales seulement, pas CapsLock
               cmpi.b     #%1011,d0     ;Alternate et les deux touches Shift?
               bne        quit_vbl      ;non, alors continuer le programme principal

; Le programme principal fait une pause … partir d'ici...



               clr.l      d0            ;D‚but ‚cran physique
               move.b     $ffff8201,d0  ;High byte de la vid‚o RAM
               lsl.w      #8,d0         ;* $100
               move.b     $ffff8203,d0  ;+ Mid Byte de la vid‚o RAM
               lsl.w      #8,d0         ;* $100
               move.l     d0,d7         ;Stocker pour besoins ult‚rieurs

               movea.l    d0,a6         ;Sauvegarder ‚cran

               movea.l    _v_bas_ad,a6  ;Sauvegarde ‚cran
               lea.l      buffer,a1
               move.w     #32000/4-1,d0

save_loop:     move.l     (a6)+,(a1)+
               dbra       d0,save_loop

               pea        message       ;Affichage du texte … l'‚cran
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               movea.l    shiftptr,a0   ;Attendre control
wait_loop:     move.b     (a0),d0
               andi.b     #%1111,d0
               cmpi.b     #%100,d0      ;Control?
               bne.s      wait_loop

               movea.l    _v_bas_ad,a6
               lea.l      buffer,a1     ;Restituer l'‚cran
               move.w     #32000/4-1,d0
rest_loop:     move.l     (a1)+,(a6)+
               dbra       d0,rest_loop

quit_vbl:      rts                      ;Fin de la routine de Queue VBL (pas RTE)


               .DATA 

err_flag:      .DC.w 0

message:       .DC.b 27,'E',10,10       ;Effacer ‚cran
               .DC.b '  Votre demande est en cours de traitement.',13,10,10,10
               .DC.b '  Un peu de patience, SVP... ',0

               .BSS 

shiftptr:      .DS.l 1
buffer:        .DS.w 16000              ;Place pour l'‚cran entier

               .END 
