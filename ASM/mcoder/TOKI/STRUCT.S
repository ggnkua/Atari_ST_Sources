;
;	nouvelle gestion des animations pour Toki
;	structure des animations :
;
;	.W	num‚ro du sprite 1 … afficher
;	.W	num‚ro du sprite 2 … afficher
;	.B	dX=deplacement en X par rapport … position precedente
;	.B	dY=deplacement en Y par rapport … position precedente
;
;		delta anim pour deplacement
;	.B	rien
;	.B	haut
;	.B	haut droite
;	.B	droite
;	.B	bas droite
;	.B	bas
;	.B	bas gauche
;	.B	gauche
;	.B	haut gauche
;	.B	les memes + fire
;
;	num‚ros d'anim donnent :
;		.W	num‚ro du sprite … afficher
;		.B	d‚calage en X
;		.B	d‚calage en Y
;
;	1) si animation en cours pas finie -> 3) (mort ou gain)
;	2) test deplacement
;	    (deplacement de Toki suivant le decor)
;	3) animation en fonction du deplacement
;
; gestion de Toki :
;	X=X gauche
;	Y=Y bas
;
;	l'affichage des sprites se fait par rapport … ces coordonn‚es
;
