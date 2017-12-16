* routine d'intersection de deux rectangles
* par Golio Junior

	section Text
* definition de la struture des rectangles utilis‚s
	rsreset
X	rs.w 1		* coordonn‚es X du coin haut gauche
Y	rs.w 1		* coordonn‚es Y du mˆme coin
L	rs.w 1		* largeur du rectangle
H	rs.w 1		* hauteur du rectangle
t_rect	equ __RS		* t_rect contient la taille de la structure

	lea rectangle1,a0
	lea rectangle2,a1
	
	bsr intersection
	beq affiche_ninter
	pea txt_inter
	bra prog_s1

affiche_ninter
	pea txt_ninter

prog_s1		* affichage d'un texte
	move.w #9,-(sp)
	trap #1		* Cconws
	addq.l #6,sp

		* attente d'une touche

	move.w #7,-(sp)
	trap #1		* Crawcin
	addq.l #2,sp

	move.w #0,-(a7)
	trap #1

intersection
		* calcul des coordonn‚es des coins du rectangle 2
	move.w (X,a1),d0	* coordonn‚es X du 1er coin
	move.w (Y,a1),d1	* coordonn‚es Y du 1er coin
	move.w d0,d2
	add.w (L,a1),d2	* coordonn‚es X du 2nd coin
	move.w d1,d3
	add.w (H,a1),d3	* coordonn‚es Y du 2nd coin

		* test du premier coin
	cmp.w (X,a0),d0
	bpl second_coin
	cmp.w (Y,a0),d1
	bpl second_coin
	cmp.w (X,a0),d2
	bmi second_coin
	cmp.w (Y,a0),d3
	bmi second_coin
	bra intersection_ok	* le coin est dans le rectangle 2
second_coin		* coin haut droit
		* les tests en Y ne changent pas
		* car tous d‚ja calcul‚s (voir 1er coin)
	move.w (X,a0),d4
	add.w (L,a0),d4
	cmp.w d4,d0
	bpl troisieme_coin
	cmp.w d4,d2
	bmi troisieme_coin
	bra intersection_ok	* le coin est dans le rectangle 2
troisieme_coin		* coin bas gauche
		* les tests en X ne changent pas
		* car tous d‚ja calcul‚s (voir 1er coin)
	move.w (Y,a0),d4
	add.w (Y,a0),d4
	cmp.w d4,d1
	bpl quatrieme_coin
	cmp.w d4,d3
	bmi quatrieme_coin
	bra intersection_ok
quatrieme_coin		* coin bas droit
		* les tests en X ne changent pas
		* car tous d‚ja calcul‚s (voir 2nd coin)
		* les tests en Y ne changent pas
		* car tous d‚ja calcul‚s (voir 3ieme coin)
		* donc pas d'intersection
	move.w #0,d1	* met Z … 1
	rts
intersection_ok
		* il y a une intersection
	move.w #-1,d1	* met Z … 0
	rts

	section Data
rectangle1	dc.w 10,20,100,200
rectangle2	dc.w 50,50,75,75

txt_inter	dc.b "il y a une intersection",13,10,0
txt_ninter	dc.b "il n'y a pas d'intersection",0
