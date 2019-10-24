/*
 * Def_Arbo.h
 *
 * Parametres arborescence par defaut et constantes repr‚sentant
 * les differentes fonctions possibles de chaque constituant d'une
 * page arbo
 *
 * History:
 * --------
 * Created by fplanque
 */

#ifndef	DEF_ARBO_H
#define	DEF_ARBO_H

/*
 * Parametres par DEFAUT d'un "dossier" arbo:
 */
	#define		ARBOPAGES_W		13		/* Taille grille en elt */
	#define		ARBOPAGES_H		40
	#define		ARBOIN_POSX		6		/* Position elt IN */
	#define		ARBOIN_POSY		0
/*
 * Constantes pour la cr‚ation d'un nouveau "dossier arbo":
 */
	#define		DEF_NBOBJ_TREE	50		/* Nbre d'objets possibles */
												/* en + de ceux existants … */
												/* l'ouverture de la premiŠre */
												/* fenˆtre sur le DATADIR concern‚ */
/*
 * Constantes suppl‚mentaires pour l'affichage des dossiers ARBO:
 */
	#define		DEF_NBIBL_TREE	50		/* Nbre d'iconblocks possibles */
												/* en + de ceux existants … */
												/* l'ouverture de la premiŠre */
												/* fenˆtre sur le DATADIR concern‚ */
	#define		AICON_OFFY		3		/* Offset des ic“nes ds la fenˆtre */
	#define		AICON_OFFX		3
	#define		WA_BORDER		5		/* Fenˆtre arbo : taille des bords … l'int‚rieur de l'objet */
	#define		WA_OUTLINE		4		/* Taille de l'outline … l'ext‚reieur */


/*
 * Identification des elements dans l'ARBO_MAP: 
 *
 * Definitions standard: 
 */
	#define		IN_NORTH			0x0080	/* Entr‚e Nord */
	#define		IN_WEST			0x0040	/* Entr‚e Ouest */
	#define		IN_EAST			0x0010	/* Entr‚e Est */
	#define		OUT_WEST			0x0004	/* Sortie Ouest */
	#define		OUT_SOUTH		0x0002	/* Sortie Sud */
	#define		OUT_EAST			0x0001	/* Sortie Est */

	#define		CT_ARBO			0x8000	/* Cell type : Arbo */
	#define		CT_INOUT			0x4000	/* Cell type : In or Out */
/*
 * Liens, objets, etc: 
 */
	#define		IDELT_IN			(CT_INOUT|OUT_SOUTH)	/* Point d'entree */
	#define		IDLINK_FETS		(IN_EAST|OUT_SOUTH)	/* Lien */
	#define		IDLINK_FETWS	0x0016	/* Lien */
	#define		IDLINK_FNTWSE	0x0087	/* Lien */
	#define		IDLINK_FWTSE	0x0043	/* Lien */
	#define		IDLINK_FWTS		(IN_WEST|OUT_SOUTH)	/* Lien */
	#define		IDLINK_FNTWS	0x0086	/* Lien */
	#define		IDLINK_FNTS		0x0082	/* Lien */
	#define		IDLINK_FNTSE	0x0083	/* Lien */
	#define		IDLINK_FNTW		0x0084	/* Lien */
	#define		IDLINK_FETW		0x0014	/* Lien */
	#define		IDLINK_FNTWE	0x0085	/* Lien */
	#define		IDLINK_FWTE		0x0041	/* Lien */
	#define		IDLINK_FNTE		0x0081	/* Lien */
	#define		NB_LINKTYPES	13			/* Nbre de liens diff‚rents */
	
	#define		IDPAGE_STD		(CT_ARBO|IN_NORTH|OUT_SOUTH)		/* Page arbo standard */


/* 
 * Fonctions ARBO: 
 *
 * Notes:
 * ------
 * Le num‚ro attribu‚ … une fonction ne doit jamais changer d'une
 * version … l'autre du logiciel, faute de quoi les fichiers ne
 * pourraient plus ˆtre relus.
 */
	#define		FS_IN				0		/* Fonction de structure: IN */
												/* Il n'y a que 0 qui marche bouhhh */
												/* Sinon le RSC AES d‚conne! */

	#define		FA_MENU			11		/* Menu / Page simple */
	#define		FA_ECRI_MSG		21		/* Ecriture d'un message */
	#define		FA_LECT_MSG		22		/* Lecture d'un message */
	#define		FA_DISP_TEXT	25		/* Lecture d'un texte */
	#define		FA_ID				31		/* Identification du connect‚ */
	#define		FA_NEW_ACCOUNT	32		/* Cr‚ation d'un compte */
	#define		FA_LIST			42		/* Liste de messages */
	#define		FA_DIRECTORY	43		/* Annuaire */
	#define		FA_FILESEL		50		/* S‚lection d'un fichier */
	#define		FA_DOWNLOAD		60		/* Download */
	#define		NB_FNCTARBO		10		/* Nombre de fonctions arbo */


/*
 * Fonctions PAGES-ECRAN:
 */
	#define		FE_FOND			1000	/* Fond de page */
	#define		FE_CHGREC		1100	/* Changement d'{Enregistrement|Message} */
	#define		FE_CHGPAGE		1110	/* Changement de page */
	#define		FE_LOGINDENIED	1200	/* L'identification est refus‚e */

	#define		FEI_CMD			5000	/* Ligne de commande */
	#define		FEI_PUBPRIV		5100	/* public ou priv‚? */

	#define		FEI_USERNAME	6100	/* Saisie du Login/Username/Pseudo */
	#define		FEI_FIRSTNAME	6110	/* Saisie du pr‚nom ou nom complet */
	#define		FEI_LASTNAME	6111	/* Saisie du nom */
	#define		FEI_PASSWORD	6120	/* Saisie du mot de passe */

	#define		FEI_OFFICE		6200	/* Demande fonction */

	#define		FEI_ADDRESS1	6300		/* Saisie adresse */
	#define		FEI_ADDRESS2	6301		/* Saisie adresse */
	#define		FEI_ZIP			6310		/* Saisie Code Postal */
	#define		FEI_TOWN			6320		/* Saisie Ville */
	#define		FEI_STATE		6330		/* Saisie Etat */
	#define		FEI_COUNTRY		6340		/* Saisie Pays */

	#define		FEI_PHONE		6400		/* T‚l‚phone */
	#define		FEI_FAX			6410		/* FAX */
	#define		FEI_MODEM		6420		/* Tel accŠs t‚l‚info */

	#define		FEI_DEST			7020		/* Saisie Destinataire */
	#define		FEI_TITLE		7100		/* Saisie Titre */
	#define		FEI_TEXT			7110		/* Saisie Texte */

      
/* 
 * Fonctions DATA: Bases de donnees & texte:
 */
	#define		FB_RUB			 1000		/* Rubrique concern‚e par op‚rations de la page */
	#define		FB_DIRECTORY	 2000		/* Annuaire (des BALS/Comptes Users) */
	
	#define		FT_FIRST			 9999		/* PremiŠre fonction texte, jamais utilis‚e, c juste une r‚f‚rence */
	#define		FT_TEXT			10000		/* Texte … afficher */
   
/* 
 * Fonctions liens-arbo 
 *
 * Purpose:
 * --------
 * Sert pour identifier les fonctions dans la page arbo
 */
	
	#define		FL_FIRST			1		/* PremiŠre page */
	#define		FL_FIN			2		/* Page appell‚e par Cnx/Fin */

	#define		FL_SOMM			11		/* Sommaire */
	#define		FL_GUIDE			12		/* Guide */
	#define		FL_ANNUL			13		/* Annulation */
	#define		FL_CORREC		14		/* Correction */
	#define		FL_RETOUR		15		/* Retour */
	#define		FL_SUITE			16		/* Suite */
	#define		FL_REPET			17		/* R‚p‚tition */
	#define		FL_ENVOI			18		/* Envoi */

	#define		FL_NEXT			20		/* Prochaine page (Chgt auto) */
	#define		FL_WATCH			40		/* Visualisation du Record s‚lectionn‚ */
	#define		FL_DOWNLOAD		50		/* t‚l‚chargement du fichier s‚lectionn‚ */

	#define		FL_NOFILE		1100	/* Pas de fichier … t‚l‚charger */
	#define		FL_NOEXIST		1110	/* Fichier demand‚ n'existe pas */


/*	#define		NB_FNCTLINK		10		/* Nombre de fonctions liens */
	                        
	                        
/* 
 * Lines styles:
 *
 * Suggest:
 * --------
 * Double usage … proscrire!
 */
	#define     LSTYL_NOWAY		0		/* Impossible de dropper l…! */
	#define		LSTYL_OK			1		/* Position correcte */
	#define		LSTYL_REPLACE	2		/* Remplacement? */
	#define		LSTYL_WRONG		3		/* Position erronnee */
	#define		LSTYL_WRONGREP	5		/* Remplacement sur une position erronn‚e */
                           
/* 
 * Drag_arboicon RESULT: 
 *
 * Purpose:
 * --------
 * A la suite d'un drag&drop d'une icone arbo, indique si celle-ci
 * a ete droppee sur une case vide ou bien une case deja occupee:
 */
	#define		POS_FREE_1		-1
	#define		POS_REPLACE_2	-2
	#define		POS_ISOLATED_3	-3
	#define		POS_WRONGREP_4	-4
	
/*
 * Type d'‚dition:                                               
 * Utilis‚ en interne par edit_ArboParList() 
 * pour savoir quel type de params on ‚dite
 */
	enum
	{
		EDIT_PECRAN,	/* Edition des pages ‚cran */
		EDIT_OUTPUTS,	/* Edition des champs de sortie */
		EDIT_SAISIES,	/* Param des champs de saisie */
		EDIT_LIENS,		/* Edition des liens arbo */
		EDIT_DATA,		/* Edition des donn‚es */
		EDIT_KEYWORDS	/* Edition des mots clefs */ 
	};


/*
 * Types de filtres pour les champs de saisie
 */
	#define		FILTER_NONE			0		
	#define		FILTER_NUMERIC		10
	#define		FILTER_NAME_NOSPC	50
	#define		FILTER_NAME_SPACE	52
	#define		FILTER_USERNAME	100
	#define		FILTER_PASSWORD	105
	#define		FILTER_ADDRESS		110
	#define		FILTER_PHONE		120



#endif /* #ifndef	DEF_ARBO_H */	