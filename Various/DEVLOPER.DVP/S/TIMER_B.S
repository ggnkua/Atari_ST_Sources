;
; Interruption par trame avec le timer B du MFP
; Assembleur		TIMER_B.S
;

gemdos         = 1
xbios          = 14
xbtimer        = 31
super          = $20
ptermres       = $31

vbl_vec        = $70
couleur0       = $ffff8240
bcontrol       = $fffffa1b              ;Registre de contr“le timer A
bdata          = $fffffa21              ;Registre donn‚es timer B


               SECTION TEXT 

; Installer la routine d'interruption dans le timer B (1).
; Event-Count-Mode (16) --> pas de diviseur.

               movea.l    4(sp),a0      ;Calcul de la m‚moire requise
               move.l     #$100,d6
               add.l      12(a0),d6
               add.l      20(a0),d6
               add.l      28(a0),d6

               clr.l      -(sp)         ;Passage en mode superviseur
               move.w     #super,-(sp)
               trap       #1
               addq.l     #6,sp
               move.l     d0,d7         ;Stockage du SSP

               pea        routine       ;Adresse de la routine d'interruption
               move.w     #50,-(sp)     ;Registre de donn‚es
               move.w     #0,-(sp)      ;Registre de contr“le (Timer encore arrˆt‚)
               move.w     #1,-(sp)      ;1 pour le timer B
               move.w     #xbtimer,-(sp)
               trap       #xbios
               adda.l     #12,sp

               move.l     vbl_vec,jump+2          ;Routine VBL en instruction de saut
               move.l     #new_vbl,vbl_vec        ;Routine VBL rattach‚e

               move.l     d7,-(sp)      ;Retour au mode utilisateur
               move.w     #super,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               clr.w      -(sp)         ;Pas d'erreur
               move.l     d6,-(sp)      ;Longueur du programme
               move.w     #ptermres,-(sp)         ;Garder le programme r‚sident
               trap       #gemdos


; Routine de commutation de couleur:

routine:       move.w     #$f00,couleur0          ;Rouge en couleur de fond
               clr.b      bcontrol      ;Interruption arrˆt‚e
               bclr       #0,$fffffa0f  ;Effacer l'interruption en service
               rte                      ;Fin de l'exception

; Nouvelle routine VBL:

new_vbl:       move.w     #$fff,couleur0          ;Fond de l'‚cran blanc
               move.w     d0,-(sp)      ;Stocker registre
               move.b     direction,d0
               add.b      d0,haut       ;Commutation 1 ligne plus tard
               tst.b      d0            ;D‚placement vers le haut ou vers le bas?
               bmi.s      enhaut
               cmpi.b     #200,haut     ;D‚j… … la ligne 200?
               beq.s      vbl_change    ;Alors changer de sens
               bra.s      vbl_cont
enhaut:        cmpi.b     #50,haut      ;ou retourner tout en haut?
               bne.s      vbl_cont
vbl_change:    eori.b     #$ff,direction          ;Annuler nombre
               addq.b     #1,direction  ;(Compl‚ment … deux)
               subq.w     #1,flag       ;Encore un tour pr le programme principal
vbl_cont:      move.b     haut,bdata    ;Nombre de lignes pour commuter
               move.b     #8,bcontrol   ;Registre de ctrle: timer d‚clench‚ … nouveau
               bset       #0,$ffff8241  ;Prendre cong‚ du MFP
               move.w     (sp)+,d0      ;Retour registre
jump:          jmp        $12345678     ;Retour … la Routine VBL normale


               SECTION DATA 

flag:          DC.w 2
direction:     DC.b 1
haut:          DS.b 50

               END 
