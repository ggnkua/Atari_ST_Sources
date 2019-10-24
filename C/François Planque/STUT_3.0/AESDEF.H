/* 
 * Definitions suppl‚mentaires pour la gestion de l'AES
 *
 * History:
 * --------
 * Created by fplanque
 * Parts taken from ATARI AES 4.0 Release notes
 */

#ifndef AESDEF_H
#define AESDEF_H	0

/*
 * AES 3D Objects definitions:
 *
 * History:
 * --------
 * Taken from ATARI AES 4.0 Release notes
 */
	#define	FL3DMASK		0x0600	/* Mask on 3D-specific bits */
	#define	FL3DNONE		0x0000	/* No 3D */
	#define  FL3DIND		0x0200	/* Indicator */
	#define  FL3DBAK		0x0400	/* Activator */
	#define  FL3DACT		0x0600	/* 3D Background */
	
	#define	LK3DIND		1
	#define	LK3DACT		2
	#define	INDBUTCOL	3
	#define	ACTBUTCOL	4
	#define	BACKGRCOL	5
	#define	AD3DVALUE	6

	
/*
 * Enhanced AES Objects:
 * Defintions personnelles
 *
 * History:
 * --------
 * Created by fplanque
 */
	#define	RELIEF1			0x0200	/* Bit  9 de OB_FLAGS */
	#define	RELIEF2			0x0400	/* Bit 10 de OB_FLAGS */
	#define	MENU_DIS			0x2000	/* Bit 13 de OB_FLAGS */
	#define	PARAM				0x4000	/* Bit 14 de OB_FLAGS */
	#define	OUVRABLE			0x8000	/* Bit 15 de OB_FLAGS */

	#define	USES_SPEC		0x2000	/* Bit 13 de OB_STATE : */
												/* L'objet utilises OB_SPEC */
												/* pour stocker des donn‚es */
												/* importantes; si on fait un */
												/* form_dup, il faut dupliquer */
												/* OB_SPEC (Par exemple la */
												/* TEDINFO d'un TEXT) */
	/*
	 * RESIZE_OBJECT comprend plusieurs traitements selon le type d'objet:
	 * - s'il s'agit d'un TEXT titre de groupe:
	 *   il va falloir l‚gŠrement r‚duire la taille de l'objet:
	 * - s'il s'agit d'une ic“ne, on veut lui donner une taille entiŠre et
	 *   plus ou moins centrer l'image
	 * = BOUTON_CROIX: si l'objet est un BOX: mettre en USERDEF BOUTONCROIX
	 */
	#define	RESIZE_OBJECT	0x4000	/* Bit 14 de OBSTATE */ 
	#define	BOUTON_CROIX	0x4000	/* Bit 14 de OBSTATE */ 


/*
 * AES:menu_bar() definition: 
 */
#define	SHOW_MENU		1			/* Affichage de la barre de menu */
#define	CLEAR_MENU		0			/* EnlŠve le menu */


/*
 * Certaines fonctions faisant des opérations graphiques
 * sur l'‚cran doivent:
 * - soit prendre le contrôle de l'écran
 * - soit considerer que les contrôle a été pris par la fonction pere
 */
#define	TAKE_CTRL		1			/* Prendre le ctrl de l'‚cran */
#define	CTRL_OK			0			/* Le contr“le est d‚j… pris! */


/*
 * Fin du test anti red‚finition:
 */
#endif
 