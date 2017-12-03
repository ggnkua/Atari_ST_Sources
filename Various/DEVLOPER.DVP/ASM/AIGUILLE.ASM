;
; Aiguiller une entr‚e au clavier vers un fichier
; Assembleur     AIGUILLE.ASM
;

gemdos         = 1

cconin         = 1
crawcin        = 7
cconws         = 9
fopen          = $3d
fclose         = $3e
fdup           = $45
fforce         = $46

               .TEXT 

               clr.w      -(sp)         ;Ouvre un fichier en lecture
               pea        filename
               move.w     #fopen,-(sp)
               trap       #gemdos
               addq.l     #8,sp

               tst.w      d0            ;Erreur … l'ouverture?
               bmi.s      error         ;Alors le signaler...
               move.w     d0,handle     ;Sinon stocker la valeur dans "handle"

               clr.w      -(sp)         ;0 l'identificateur standard d'entr‚e
               move.w     #fdup,-(sp)   ;et se duplique par Fdup
               trap       #gemdos
               addq.l     #4,sp
               move.w     d0,non_std    ;Le r‚sultat est un handle non standard

               move.w     handle,-(sp)  ;Aiguillage: l'entr‚e standard (clavier)
               clr.w      -(sp)         ;est dirig‚e vers un fichier
               move.w     #fforce,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               bsr.s      entree        ;Sous-programme d'entr‚e

               pea        string        ;Affichage pour contr“le
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               move.w     non_std,-(sp) ;Nouvel aiguillage de
               clr.w      -(sp)         ;l'entr‚e standard (vers
               move.w     #fforce,-(sp) ;l'ancienne entr‚e standard)
               trap       #gemdos
               addq.l     #6,sp

               move.w     handle,-(sp)  ;Fermer le fichier
               move.w     #fclose,-(sp)
               trap       #gemdos
               addq.l     #4,sp

fin:           move.w     #crawcin,-(sp)          ;Attendre appui touche
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;Quitter le programme
               trap       #gemdos

error:         pea        errtext       ;Affichage message d'erreur
               move.w     #cconws,-(sp)
               trap       #gemdos
               addq.l     #6,sp

               bra.s      fin

entree:        lea.l      string,a3     ;Routine d'entr‚e d'une ligne
               clr.w      d3            ;d3 est l'index du caractŠre suivant

loop:          move.w     #cconin,-(sp) ;Lire le caractŠre du p‚riph‚rique
               trap       #gemdos       ;standard d'entr‚e
               addq.l     #2,sp

               cmpi.b     #13,d0        ;Return appuy‚?
               beq.s      finish        ;Alors nous avons termin‚

               move.b     d0,0(a3,d3.w) ;Sinon ‚crire caractŠre dans chaŒne
               addi.w     #1,d3         ;et incr‚menter l'index
               bra.s      loop

finish:        clr.b      0(a3,d3.w)    ;Terminer la chaŒne par un octet nul
               rts        

               .DATA 

filename:      .DC.b 'AIGUILLE.DOC',0
errtext:       .DC.b 'Fichier introuvable!',0

               .BSS 

handle:        .DS.w 1
non_std:       .DS.w 1
string:        .DS.b 80

               .END 



