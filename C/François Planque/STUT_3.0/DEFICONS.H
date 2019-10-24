/*
 * Data images des Ic“nes AES:
 *
 * Purpose:
 * --------
 * Ces structures fournissent des pointeurs sur les bitmaps de
 * certaines icones pour faciliter leur reutilisation
 * Utilis‚ pour cr‚er les directories RAM
 *
 * History:
 * --------
 * 06.08.94: fplanque: ajout‚ positions char:
 */
typedef
	struct
	{
		int	*mask;			/* Ptr sur bitmap masque icône */
		int	*data;         /* Ptr sur bitmap dessin */
		int	icon_y;			/* Position y ds cadre 32*32? */
		int	icon_h;			/* Hauteur du bitmap <=32 */
		int	char_x;			/* Position du cractŠre ds cadre ic“ne */
		int	char_y;
	}
	ICONIMG;

/*
 * Pointeurs d'accès à certaines icônes: 
 */
typedef
	struct						
	{
		ICONIMG	minitel;			/* Minitel */
		ICONIMG	texte;			/* 2 Feuilles de Texte */
		ICONIMG	datas;			/* 3 Intercalaires */
		ICONIMG	image;			/* Pages + Outils de dessin */
		/* Ic“nes suppl‚mentaires */
		ICONIMG	affichages;		/* Pages + Outils de dessin */
		ICONIMG	saisies;			/* Pages + Outils de dessin */
		ICONIMG	params;			/* Pages + Outils de dessin */
		ICONIMG	liens;			/* Pages + Outils de dessin */
		ICONIMG	erreurs;			/* Pages + Outils de dessin */
		ICONIMG	motsclef;		/* Pages + Outils de dessin */
	}
	ICONIMGS;
