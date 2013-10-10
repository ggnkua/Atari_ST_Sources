;
; Demo de l'utilisation du timer du MFP
; Assembleur     TIMER_A.ASM
;


gemdos         = 1
bios           = 13
xbios          = 14
console        = 2
bconout        = 3
cursconf       = 21
xbtimer        = 31


               .TEXT 

; Arrˆt clignotement curseur:

               move.w     #3,-(sp)      ;Fonction: non clignotant
               move.w     #cursconf,-(sp)
               trap       #xbios
               addq.l     #4,sp

; Installer la Routine d'interruption dans le timer A (0).
; Fr‚quence: 48 Hz. Obtenue par le diviseur … 200 (7)
; et le registre de donn‚es 256 (=0).

               pea        routine       ;Adresse de la routine d'interruption
               clr.w      -(sp)         ;Le registre de donn‚es est 0=256
               move.w     #7,-(sp)      ;Registre de contr“le avec diviseur
               clr.w      -(sp)         ;0 pour le timer A
               move.w     #xbtimer,-(sp)
               trap       #xbios
               adda.l     #12,sp

; Boucle d'attente

               moveq.l    #100,d0       ;suffit pour 10 bonnes secondes
outer:         moveq.l    #-1,d1
inner:         dbra       d1,inner
               dbra       d0,outer

; Arrˆter … nouveau le timer

               pea        routine
               clr.w      -(sp)         ;Registre donn‚es
               clr.w      -(sp)         ;Registre de contr“le (0 = arrˆt)
               clr.w      -(sp)         ;0 pour le timer A
               move.w     #xbtimer,-(sp)
               trap       #xbios
               adda.l     #12,sp

               move.w     #2,-(sp)      ;Le curseur doit recommencer … clignoter
               move.w     #cursconf,-(sp)
               trap       #xbios
               addq.l     #4,sp

               clr.w      -(sp)         ;Fin du programme
               trap       #gemdos


routine:       
; Intervention de l'interruption:

               movem.l    d0-d7/a0-a6,-(sp)       ;Sauve qui peut!

               clr.w      d0
               movea.l    pointer,a0    ;Pointeur sur le caractŠre suivant
               move.b     (a0),d0       ;Aller chercher caractŠre
               beq        finish        ;Nul? Alors nous avons termin‚...

               move.w     d0,-(sp)      ;sinon afficher le caractŠre
               move.w     #console,-(sp)
               move.w     #bconout,-(sp)
               trap       #bios
               addq.l     #6,sp

               addq.l     #1,pointer

finish:        movem.l    (sp)+,d0-d7/a0-a6       ;Reconstitue le registre
               bclr       #5,$fffffa0f  ;Effacer l'interruption en service
               rte                      ;End of Exception


               .DATA 

affichage:     .DC.b 'ceci est un message important',13,10,10,10
               .DC.b "le timer a du mfp de l'atari st est beaucoup",13,10
               .DC.b 'plus facile … utiliser que ce que croient',13,10
               .DC.b 'la plupart des gens                             '
               .DC.b 13,10,10,10,'         strictement confidentiel ',13,10
               .DC.b '         ========================== ',13,10,10,10,10,0

pointer:       .DC.l affichage

               .END 
