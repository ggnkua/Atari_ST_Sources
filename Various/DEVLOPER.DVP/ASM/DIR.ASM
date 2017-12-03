;
;  Affichage du r‚pertoire courant
;  Assembler  DIR.ASM
;

lectseul       = 1

gemdos         = 1

crawcin        = 7
cconws         = 9
fsetdta        = $1a
fsfirst        = $4e
fsnext         = $4f

               .TEXT 

               pea        dta_tmp       ;Fixer l'adresse du tampon DTA
               move.w     #fsetdta,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #lectseul,-(sp)         ;Appel Fsfirst (rechercher les
               pea        masque        ;fichiers normaux et en lecture seule)
               move.w     #fsfirst,-(sp)
               trap       #gemdos
               addq.l     #8,sp

               tst.w      d0            ;Erreur?
               bmi.s      error         ;Oui, alors il n'y a pas de fichier
               bsr.s      affichage     ;Sinon, afficher nom du fichier

loop:          move.w     #fsnext,-(sp) ;Chercher d'autres noms
               trap       #gemdos
               addq.l     #2,sp
               tst.w      d0            ;Erreur?
               bmi.s      touche        ;Alors quitter
               bsr.s      affichage     ;Sinon, afficher le nom...
               bra.s      loop          ;... et continuer

error:         pea        err_text      ;Afficher message d'erreur
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

touche:        move.w     #crawcin,-(sp)          ;Attendre appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;Fin du programme
               trap       #gemdos

affichage:     pea        nom           ;Affichage du nom trouv‚
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               pea        crlf          ;Envoyer un saut de page
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp
               rts        

               .DATA 

err_text:      .DC.b 'Aucun fichier trouv‚!',0
masque:        .DC.b '*.*',0
crlf:          .DC.b 13,10,0

               .BSS 

dta_tmp:       .DS.b 21
attribut:      .DS.b 1
heure:         .DS.w 1
date:          .DS.w 1
taille:        .DS.l 1
nom:           .DS.b 14

               .END 



