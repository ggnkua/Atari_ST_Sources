;
;  Affichage d'une cha�ne par la fonction GEMDOS Cconws
;  GFA-Assembler     STROUT.ASM
;

gemdos         = 1

cconin         = 1
cconws         = 9

               .TEXT 
               pea        affichage     ;Fonction d'affichage de la cha�ne
               move.w     #cconws,-(sp) ;(La cha�ne doit �tre termin�e
               trap       #gemdos       ;par un octet nul)
               addq.l     #6,sp

               move.w     #cconin,-(sp) ;Attend appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;Quitte le programme
               trap       #gemdos

               .DATA 
affichage:     .DC.b 27,'Affichage en vid�o inverse?',27,'q'
               .DC.b 'Pas de probl�me avec GEMDOS!',0

               .END 
