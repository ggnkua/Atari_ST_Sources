;
;  Affichage d'une chaåne par la fonction GEMDOS Cconws
;  Assembleur     	STROUT.S
;

gemdos         = 1

cconin         = 1
cconws         = 9


               SECTION TEXT
                
               pea        affichage     ;Fonction d'affichage de la chaåne
               move.w     #cconws,-(sp) ;(La chaåne doit àtre terminÇe
               trap       #gemdos       ;par un octet nul)
               addq.l     #6,sp

               move.w     #cconin,-(sp) ;Attend appui touche...
               trap       #gemdos
               addq.l     #2,sp

               clr.w      -(sp)         ;Quitte le programme
               trap       #gemdos


               SECTION DATA
                
affichage:     DC.b 27,'p','Affichage en vidÇo inverse?',27,'q'
               DC.b 'Pas de probläme avec GEMDOS!',0

               END 
