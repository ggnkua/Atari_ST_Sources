/*
 * Arbo_Output.h
 *
 * Fonctions CHAMP de SORTIE/OUTPUT:
 * psenser … update le .C d'init et set_DisplayFields()
 */
	#define		FO_COMMENT		  10	/* Commentaire de la page */
	#define		FO_DATACOMMENT	  12	/* Commentaire de la dbase ouverte */
	#define		FO_TEXTCOMMENT	  13	/* Commentaire du texte ouvert */
	#define		FO_RECNUMBER	 100	/* No du record ds base (arbitraire) */
	#define		FO_PAGENUMBER	 110	/* No de la page */
	#define		FO_CREATEDATE	 200	/* Date de cr‚ation */
	#define		FO_PUBPRIV		 220	/* Public/priv‚ */
	#define		FO_PATH			 500	/* Chemin d'accŠs courant */		
	#define		FO_NBFILES		 505	/* Nbre de fichiers ds dir courant */
	#define		FO_FILENAME		 510	/* Nom de fichier */
	#define		FO_FILEATTRIB	 515	/* Attributs du fichier */
	#define		FO_FILEDATE		 520	/* Date de maj du fichier */
	#define		FO_FILESIZE		 522	/* Taille du fichier */
	#define		FO_USERNAME		6100	/* USER Login/Username/Pseudo */
	#define		FO_FIRSTNAME	6110	/* 1STN pr‚nom */
	#define		FO_LASTNAME		6111	/* LSTN nom */
	#define		FO_TITLE			7000	/* MTIT Aff du titre */
	#define		FO_TEXT			7100	/* MTXT Affichage du texte */
	#define		FO_DSTA			7500	/* DSTA Adresse destination */
	#define		FO_MPSE			7600	/* MPSE Pseudo Auteur */

/*
 * Formats CHAMP de SORTIE/OUTPUT:
 * penser … updater le .C d'init
 */
	#define	FMT_STANDARD			0	/* Format g‚n‚rique standard */

	#define	FMT_NUMBER_LEFT		0	/* Justification … gauche */
	#define	FMT_NUMBER_RIGHT	1000	/* Justification … droite */
	#define	FMT_NUMBER_ZEROS	1010	/* … droite avec des z‚ros devant */

	#define	FMT_DATE_STD		 	0	/* Fri Mar 24 23:00:00 1995 */
	#define	FMT_DATE_JmAAHMS	 110	/* 24 Mar 1995 23:00:00 */
	#define	FMT_DATE_JmAHMS	 111	/* 24 Mar 95 23:00:00 */
	#define	FMT_DATE_JMAAHMS	 120	/* 24.03.1995 23:00:00 */
	#define	FMT_DATE_JMAHMS	 121	/* 24.03.95 23:00:00 */
	#define	FMT_DATE_JMHMS		 122	/* 24/03 23:00:00 */
	#define	FMT_DATE_JJMAHMS	 131	/* Fri 24.03.95 23:00:00 */
	#define	FMT_DATE_JJMHMS	 132	/* Fri 24/03 23:00:00 */
	#define	FMT_DATE_HMS		 140	/* 23:00:00 */
	#define	FMT_DATE_HMSP		 141	/* 11:00:00 PM */
	#define	FMT_DATE_HMP		 142	/* 11:00 PM */
	#define	FMT_DATE_H 			 145	/* 23h */

	#define	FMT_FILESIZE_OCTETS		0
	#define	FMT_FILESIZE_KOCTETS	 110
	