/* D‚finition des constantes et fonctions du fichier objet 'rscinsto.o' */
/* B.M. 02.09.93	*/

/* codes d'erreur g‚n‚raux renvoy‚s par les fonctions */

#define		AMALLOCERR	-1		/* Erreur d'allocation */
#define		AFNOTF			-2		/* Fichier inexistant */
#define		AOPERR			-3		/* Erreur d'ouverture de fichier */
#define		ARDERR			-4		/* Erreur de lecture */
#define		AWRERR			-5		/* Erreur d'‚criture */
#define		ADSKFULL		-6		/* Disque plein */

/* Fonction add_icns seule */

#define		ADDI_MGERR			-21	/* Impossible de merger un fichier RSC */
#define		ADDI_TMNICN			-22	/* Trop d'ic^ones dans le fichier RSC destination (format RSC 1.00 limit‚ … 198 ic^ones 32*32) */
#define		ADDI_DSKFULL		-23	/* Disque plein */

/* Fonction copy_file seule */

#define		CPYF_DIRERR			-32	/* Impossible de cr‚er un dossier */

typedef struct {			/* Structure d'association */
	char icon_name[20];	/* Nom de l'ic“ne dans le fichier ICONES.RSC */
	char file_name[20];	/* Nom du fichier … associer … l'ic“ne */
	char alias[20];			/* Nom … donner … l'ic“ne dans la fenˆtre */
	int type;						/* 0=Fichier, 1=Dossier */
} IC_ASS;



extern	int add_icns( char *rsc_src1, char *rsc_src2, char *rsc_dst,
											char *newdesk_src, char *newdesk_dst, IC_ASS *ass_table );

/*
int add_icns( char *rsc_src1, char *rsc_src2, char *rsc_dst,
							char *newdesk_src, char *newdesk_dst, IC_ASS *ass_table );

	rsc_src1		:	localisation du fichier RSC de base (DESKICON.RSC)
	rsc_src2		:	localisation du fichier RSC … rajouter (ICONES.RSC)
	rsc_dst			:	localisation du fichier RSC final
	newdesk_src	:	localisation du newdesk.inf source
	newdesk_dst	:	localisation du newdesk.inf destination
	ass_table 	: Tableau de structures IC_ASS
	
	Charge rsc_src1, m‚morise le type de fichier (mono. ou coul.),
	Charge rsc_src2 (ICONES.RSC),
	Charge newdesk.inf (source),
	Parcourt le tableau de structures IC_ASS :
		Cherche dans rsc_src2 l'ic“ne de nom icon_name
			Si trouve, cr‚e une entr‚e dans newdesk.inf selon le .type de l'objet,
			avec le nom .file_name et l'alias .alias,
	La premiŠre entr‚e nulle du tableau met fin … la recherche,
	Sauve le fichier newdesk.inf (destination),
	Sauve le nouveau fichier ressource dans rsc_dst.
*/


extern	int copy_file( char *file_src, char *file_dst );
/*
int copy_file( char *file_src, char *file_dst )

	file_src: Fichier source
	file_dst:	Fichier destination
	
	Cr‚e les directories sp‚cifi‚s dans file_dst et qui n'existent pas 
	et copie le fichier source dans le chemin destination.
*/
	

extern	int	nd_add_wind( char *newd, char *filter, int wx, int wy, int ww, int wh );
/*
int	nd_add_wind( char *newd, char *filter, int wx, int wy, int ww, int wh )

	newd:			Fichier Newdesk.inf
	filter:		Chemin et filtre de la fenˆtre … cr‚er( ex: D:\FOO\*.BAR )
	wx, wy, ww, wh:	Coordonn‚es en caractŠres de la fenˆtre … cr‚er
	
	Cr‚e une fenˆtre dans le NEWDESK.INF s'il reste de la place
	(ie: Si il y a moins de 7 fenˆtres ouvertes d‚finies dedans)
*/
