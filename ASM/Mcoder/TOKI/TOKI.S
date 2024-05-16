;
; Planning de Toki (3 premieres semaines)
;
; besoins en graphismes :
;	- la palette se decompose ainsi sur ST :
;		0=couleur transparente
;		1-7=couleurs diverses (avec interruptions)
;		8-14=couleurs Toki(+couleur 15)
;		15=blanc
;	- fin 2eme semaine :
;		- quelques animations de Toki
;	- milieu 3eme semaine :
;		- les 3 premiers ecrans de scrolling
;	- les dessins dans l'ordre d'apparition des sprites
;
; 1ere semaine :
;	+ ecrire scrolling horizontal et vertical avec rafraichissement
;	   de vignettes
; 2eme semaine
;	semaine de travail sur les bases de Toki
;
;	Lundi :
;		- concertation planning general Toki avec Michel
;		- liste des differentes structures utilisees
;	Mardi-Mercredi :
;		- mise au point des structures mises en jeu dans le programme
;		 (animations, sprites, relief, decor)
;		 (faire une liste de tous les parametres necessaires
;		 pour ces structures)
;		- mise au point de ces structures AVEC Michel
;	Jeudi-Vendredi :
;		- les routines gerant les structures d'animations et de sprites
;		- saisir quelques sprites pour debuter et debugger les routines
;		   d'animation (sprites 16 couleurs pour l'instant)
;
; 3eme semaine
;	semaine de travail sur les conflits scrolling/sprites
;
;	Lundi-Mardi :
;		- routines de gestion des collisions
;		   collisions sprites <-> decor
;		   collisions sprites <-> sprites
;	Mercredi-Jeudi :
;		- saisir le premier scrolling de fond
;		- gerer le scrolling par rapport aux coordonnees de Toki
;		- apparition des ennemis en fonction d'un X ou d'un Y
;	Vendredi (journees reservees pour l'editeur de musique) :
;		- planification d'un nouvel editeur de musique ST/Amiga
;		- ecriture des routines d'affichage pour l'editeur
;		   de sons
;
; 4eme semaine :
;	mise au point des routines de base sur ST
;
;	Lundi-Mardi :
;		- routine clavier sur ST
;		- routine d'interruptions de couleurs
;	Mercredi-Jeudi :
;		- routine de sprite pour Toki (8 couleurs+bufferise)
;

; 3eme mois :
;	- 4 premiers tableaux finis
; 4eme mois :
;	- dernier tableau fini
; 5eme mois :
;	- presente+fin de jeu+debugger le jeu
;
; pour les graphistes :
;	- demander les dessins dans l'ordre d'apparition des sprites
;	- la palette se decompose ainsi sur ST :
;		0=couleur transparente
;		1-7=couleurs diverses (avec interruptions)
;		8-14=couleurs Toki(+couleur 15)
;		15=blanc
;
; 0) tests
;
;	- calculer nb maximum sprites par VBL (8 32*32)
;	- verifier tps pris par scrolling (1/2 VBL)
;
; 224*176
;
; 1) animation
;
;	- ecrire reglage de la vitesse d'animation
;	- routine sprite 8 couleurs pour Toki
;	- routine sprite 16 couleurs pour les ennemis
;	- scrolling multidirectionnel 4/4 en vignettes 16*16
;	- sequences d'animation
;	- la partie o— Toki est sur le chariot doit passer en 1 VBL
;
; 2) collisions
;
;	- elements de collision :
;		- decor (relief qui bouge)
;		- relief (inamovible)
;		- ennemis
;		- tirs ennemis
;		- Toki
;		- tirs Toki
;
; 3) divers
;
;	- routines disk/joystick-clavier-souris
;
; 4) utilitaires
;
;	- nouvelle routine de musique+editeur (tps suppose : 3 mois 1j/semaine)
;
; structure du programme :
;
;	- le programme principal est sur VBL !!!
;	- le decruncher est le code principal et attend pour decruncher
;	- Toki est anime a 50 images sur un decor a 25
;

;
; programme de TOKI
;
presente
	jsr	presentation
	jsr	mode_demo
	jmp	presente
game
	jsr	init_screen
	jsr	init_toki
main_loop:
	jsr	get_clavier
	jsr	anime_sprites_decor
	jsr	anime_sprites_ennemis
	jsr	anime_sprite_toki
	jsr	anime_tirs
	jsr	test_collisions
	jsr	affiche_divers
	jsr	affiche_screen
	jsr	affiche_sprites
	jmp	main_loop
fin_du_jeu
	jsr	high_scores
	jmp	presente

affiche_divers:
;
; affichage des divers indicateurs … l'ecran :
;
;	- score
;	- bonus (petits bonus affiches en bas)
;	- time
;	- energie de l'ennemi
;	
	rts
get_clavier
;
; test des touches :
;	- changement de volume
;	- coupe musique
;	- coupe bruit
;	- pause (pas … pas ou non)
;	- cheat code
;
	rts
affiche_sprites
;
; 1) affichage des sprites de decor
; 2) affichage des tirs ennemis
; 3) affichage des sprites ennemis
; 4) affichage des tirs de Toki
; 5) affichage du sprite de Toki
; 6) affichage des bonus de Toki : grolles,casque,lunettes sous l'eau
;
	rts
anime_sprites_decor
;
;	gestion des differents decors amovibles
;
;	1) ennemis immobiles (rarement mobiles) :
;		- blastums
;		- piques
;	2) bonus :
;		- pomme
;		- casque
;		- tennis
;		- piece
;		- tirs
;		- time
;		- cle
;		- 1st up
;		- fraise
;		- lunettes
;		- banane
;	3) decors sans collision :
;		- poids
;		- bulles (sous l'eau)
;	4) decors avec collision :
;		- balan‡oire
;		- corde
;		- cristaux (explosent puis se reforment)
;		- rochers mobiles
;		- herse (dernier tableau)
;		- rebord qui s'effrite
;		- flameche (2 types)
;		- chariot
;
	rts
anime_sprite_toki
;
;	nouvelle gestion des animations
;	structure des animations :
;
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
;	1) si animation en cours pas finie -> 3) (mort ou gain)
;	2) test deplacement
;	    (deplacement de Toki suivant le decor)
;	3) animation en fonction du deplacement
;
;	tests de collisions :
;
;	1) Toki <-> tirs ennemis
;	2) Toki <-> relief
;	3) Toki <-> decor
;	4) Toki <-> ennemis
;
; attention !
;	quand Toki saute sur un ennemi, il le tue
;
	rts
anime_tirs
;
;	1) deplacement des tirs de Toki
;	2) deplacement des tirs ennemis
;
	rts
test_collisions
;
;	1) tirs Toki <-> relief
;	2) tirs Toki <-> decor
;	3) tirs Toki <-> ennemis
;	4) ennemis <-> decor
;	5) ennemis <-> tirs ennemis
;	6) ennemis <-> relief
;	7) tirs ennemis <-> decor
;	8) tirs ennemis <-> relief
;
; attention !
;	- les objets comme les rochers mobiles sont traverses
;	   par les tirs
;
	rts
init_screen
;
;	1) recopie toutes les vignettes dans les 4 ecrans
;	2) recopie l'ecran
;
	rts
affiche_screen
;
;	1) teste si on doit scroller l'ecran
;		- on definit des couloirs de scrolling
;	2) rafraichit les vignettes apparues
;	3) recopie l'ecran
;
	rts
anime_sprites_ennemis
;
;	1) gestion des sprites normaux
;	2) gestion des big monstres
;
;	3) apparition d'un ennemi en fonction d'un X ou d'un Y
;	4) deplacement des ennemis suivant le decor
;	5) intelligence des ennemis
;
	rts
init_toki
;
;	1) initialisation de la position de Toki
;	2) affichage de Toki … l'ecran
;
	rts
presentation
;
; … rajouter … la fin du jeu
;
	rts
mode_demo
;
; … rajouter … la fin du jeu
;
; (on memorise quelques actions au joystick)
;
	rts
high_scores
;
; mettre avec une petite anim
; le cheat code doit etre dans cet ecran
;
	rts
