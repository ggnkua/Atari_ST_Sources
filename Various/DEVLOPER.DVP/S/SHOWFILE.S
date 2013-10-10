;
; Indique longueur d'un fichier et l'affiche
; Assembleur         	SHOWFILE.S
;

lectseul       = 1

gemdos         = 1

crawcin        = 7
cconws         = 9
fsetdta        = $1a
fopen          = $3d
fclose         = $3e
fread          = $3f
fsfirst        = $4e


               SECTION TEXT 

               pea        dta_puf       ;fixer l'adresse du tampon DTA
               move.w     #fsetdta,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #lectseul,-(sp)         ;Appel Fsfirst (recherche fichiers
               pea        filename      ;normaux et en lecture seule)
               move.w     #fsfirst,-(sp)
               trap       #gemdos
               addq.l     #8,sp

               tst.w      d0            ;Erreur?
               bmi.s      error         ;Alors, afficher...

               clr.w      -(sp)         ;Fichier ouvert en lecture
               pea        filename
               move.w     #fopen,-(sp)
               trap       #gemdos
               addq.l     #8,sp
               move.w     d0,handle

               pea        tampon        ;Charger fichier complet
               move.l     taille,-(sp)  ;Sa longueur a ‚t‚ transmise par Fsfirst
               move.w     handle,-(sp)
               move.w     #fread,-(sp)
               trap       #gemdos
               adda.l     #12,sp

               move.w     handle,-(sp)  ;Fermeture du fichier
               move.w     #fclose,-(sp)
               trap       #gemdos
               addq.l     #4,sp

               pea        tampon        ;Affichage du texte...
               bra.s      print_on

error:         pea        err_text      ;... ou du message d'erreur
print_on:      move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #crawcin,-(sp)          ;Attente appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;et fin du programme
               trap       #gemdos


               SECTION DATA 

err_text:      DC.b 'Fichier introuvable!!',0
filename:      DC.b 'READ.ME',0


               SECTION BSS
                
handle:        DS.w 1

dta_puf:       DS.b 21
attribut:      DS.b 1
heure:         DS.w 1
date:          DS.w 1
taille:        DS.l 1
nom:           DS.b 14

tampon:        DS.b 1000

               END 
