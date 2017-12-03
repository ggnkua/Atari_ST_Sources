;
;  Exemple de crÇation d'un fichier sous GEMDOS
;  Assembleur      FICHIERS.ASM
;

gemdos         = 1

crawcin        = 7
cconws         = 9
fcreate        = $3c
fclose         = $3e
fwrite         = $40

               .TEXT 

               move.w     #1,-(sp)      ;Attribut "lecture seule"
               pea        nomfich
               move.w     #fcreate,-(sp)          ;CrÇation du fichier
               trap       #gemdos
               addq.l     #8,sp

               tst.w      d0            ;d0 nÇgatif?
               bmi.s      error         ;alors message d'erreur
               move.w     d0,handle     ;sinon le stocker dans "handle"
               pea        debut         ;êcrire ligne texte
               move.l     #fini-debut,-(sp)       ;Longueur
               move.w     d0,-(sp)      ;Identificateur du fichier
               move.w     #fwrite,-(sp)
               trap       #gemdos
               adda.l     #12,sp

               move.w     handle,-(sp)  ;Fermeture du fichier
               move.w     #fclose,-(sp)
               trap       #gemdos
               addq.l     #4,sp

fin:           clr.w      -(sp)         ;Fin du programme
               trap       #gemdos

error:         pea        errtext       ;Affichage du message d'erreur
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     #crawcin,-(sp)          ;Attend appui touche
               trap       #gemdos
               addq.l     #2,sp

               bra.s      fin

               .DATA 

nomfich:       .DC.b 'READ.ME',0

debut:         .DC.b 'Voici le texte qui entre dans le fichier'
fini:          
errtext:       .DC.b "Erreur Ö l'ouverture du fichier",13,10,0

               .BSS 

handle:        .DS.w 1

               .END 
