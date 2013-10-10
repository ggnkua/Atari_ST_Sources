
CHOICE OF GODS: les sources.
============================

A mon humble avis, il est stupide de prot‚ger une d‚mo. D'une part c'est du
temps perdu puisqu'en deux temps trois mouvements la Ultimate Ripper vous
offre ce que vous voulez sur un plateau, d'autre part ce ne sont que des
d‚mos, auxquelles, dans l'absolu, je n'attache pas la moindre importance.

Voil… donc les sources de la C.O.G. Utilisez les comme bon vous semble.
De toute maniŠre, elles ne contiennent rien d'extraordinaire. Le tout est
de savoir utiliser convenablement ce que l'on a … sa disposition, et palier
le manque de puissance par des ruses de sioux!

Autant vous le dire tout de suite: je ne me suis pas amus‚ … commenter les
sources ( ou alors trŠs peu ) ou … les modifier en quoi que ce soit.  Nous
vous les livrons en gros tels qu'ils existent sur nos propres disks.

Ne vous attendez donc pas … quelque chose de trŠs propre... Je suis plutot
un sp‚cialiste du code bord‚lique.

Je n'ai pas mis absolument TOUT pour une raison simple: il y a des sources
que je ne retrouve pas! Par exemple je ne retrouve pas le source de
"AMBITION". En fait, je crois que je ne l'ai jamais eu. ( C'est Elric qui
l'a cod‚. )

Quelques points cependant n‚cessitent peut etre des explications:

- le d‚tournement des bombes. Ex:

	MOVE.L	#FIN,$8.W
	MOVE.L	#FIN,$C.W
	MOVE.L	#FIN,$10.W
	MOVE.L	#FIN,$14.W
	MOVE.L	#FIN,$18.W
	MOVE.L	#FIN,$1C.W
	MOVE.L	#FIN,$20.W

    Ca ne sert qu'… rendre la main en cas de plantage. Je pr‚fŠre pr‚ciser,
 j'ai vu pas mal de types qui ne connaissaient pas cette astuce. ( qui com-
 -mence … dater, pourtant. )
 
- la proc‚dure FIN en question. Ex:

FIN	MOVE.L	4.W,A0
	JMP	(A0)

   A l'adresse 4.W se trouve l'adresse de la routine RESET.
 Mais alors.. Euh? Il fait un reset, le bougre! Ben vi. Nous, on code
 avec Genst r‚sident. Qui r‚siste au reset. C'est bien pratique en cas
 de plantage g‚n‚ral, et surtout ‡a m'‚vite d'avoir … sauver la VBL, le
 Timer, les couleurs et tout le reste, il fait ‡a tout seul et ‡a 
 m'arrange parce que je suis un flemmard.

 Maintenant c'est dommage pour ceux qui n'ont PAS Genst r‚sident, parce que
 ‡a va leur planter dans les doigts au moindre faux mouvement. Il ne vous
 reste plus qu'… refaire une routine FIN...

- le code en g‚n‚ral:
  Je l'ai dit et je le r‚pŠte, les ‚crans contenus dans la C.O.G sont 
  vieux. Et certains n'ont pas ‚t‚ retouch‚s depuis leur naissance il y a
  plus d'un an. Ne vous ‚tonnez donc pas si vous trouvez des bouts de code
  non optimis‚s du genre ADDA.L D0,A0, LSL #2,D0, MOVE.L #1,D0 ou autres
  d‚lires de coder tourment‚... ce n'est pas important de toute fa‡on.
  Rappelons les paroles de ce cher Einstein:
  
             "Imagination is more important than knowledge."
             
  Meme sans connaitre les codes des instructions 68000 par coeur, il suffit
  de r‚fl‚chir pour trouver LA ruse qui va vous propulser vers les plus
  hautes marches de la gloire!
  
  
  
  
  
  Bref.
  
  
  
  
  
  En cas je probleme on peut me joindre sur RTEL en bal Zappy.
  Je r‚pondrai peut etre.
  Si j'ai le temps. ( J'en manque beaucoup... )
  
  
  Hop, zou.
  
                                             Zappy/Holocaust.
                                             
                                             