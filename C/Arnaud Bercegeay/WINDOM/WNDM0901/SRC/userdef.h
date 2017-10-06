/*
 *		Windom - Dominque B‚r‚ziat
 *	Type ‚tendus des objets ‚tendus.
 *		compatible avec MyDials
 */

/*
 *	Principe: Si ob_type vaut G_USERDEF c'est une routine
 *  de l'utilisateur , on ne fait rien. Sinon on teste
 *  l'octet de poid fort de ob_type: c'est le type ‚tendu
 *	Selon ces valeurs on attribut la bonne routine et le
 *	ob_type vaut maintenant G_USERDEF.
 *	Pour les ressources externes, RsrcLoad() met en place
 *  les nouveaux objets. Pour les ressources externes, 
 *  RsrcObfix() s'occupe de cela.
 *  Enfin, RsrcFree() libere les ressources occup‚es par
 *  ces nouveaux objets pour les ressources externes.
 *
 *  Ic“nes couleurs et ressources int‚gr‚es:
 *		Elle doivent ˆtre fix‚ par la fonction RsrcFixCicon().
 *  Cette fonction remplace les ic“nes par un G_USERDEF. Et le
 *	type ‚tendu contient G_CICON. A ne pas confomdre avec les
 *	objets pr‚c‚dents
 *
 *	Voir la doc pour les d‚tails sur les types ‚tendus
 */

#ifndef __MYDIAL__

/* Type d'objets ‚tendus */
#define DIALMOVER  0x11
#define DCRBUTTON  0x12
#define UNDERLINE  0x13
#define TITLEBOX   0x14
#define HELPBUT    0x15
#define CIRCLEBUT  0x16
#define POPUPSTRG  0x17
#define KPOPUPSTRG 0x18
#define SLIDEPART  0x19
#define LONGINPUT  0x1A
#define UNDOBUT    0x1F
#define USERDRAW   0xFF	/* R‚serv‚ WinDom */

#define FLAGS11    0x0800  /* Pour les objets accessibles avec la touche UNDO */
#define FLAGS15    0x8000  /* objets … lignes de saisie multiples */

/* Objets non MyDials */
#define ONGLET		0x0010	/* bouton formulaire multiple         */
#define	MENUTITLE	0x000F  /* Pour les menus 	*/
#define XEDIT		0x000E	/* champs editable  */
#define XCICON		0x0D  	/* icone couleur userdef */
#define XBOXLONGTEXT 0x09   /* BOXTEXT avec texte sur plusieurs lignes */
#define XFREESTR 	0x0C 	/* objet G_BUTTON 3D (obspec = free_string) */
#define XTEDINFO 	0x0B 	/* objet G_BOXTEXT & co 3D (obspec = tedinfo) */
#define XBFOBSPEC 	0x0A  	/* objet G_BOXCHAR 3D (obspec = bfobspec) */
#define XSMENU   	0x01  	/* pour remplacer le "G_USERDEF|0x0100" dans menu.c */
#endif

/* type sp‚cial pour routine user_draw */
typedef struct {
		WINDOW *win;
		void (*draw)( WINDOW *, PARMBLK *);
	} USER_DRAW;
