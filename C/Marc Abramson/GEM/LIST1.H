/*	Un squelette pour vos applications	*/
/*  graphique sous gem					*/
/*										*/
/*	header du programme					*/
/*	a inclure dans tout fichier			*/
/*  faisant appel au corps				*/
/*										*/
/* AUTEUR: Marc Abramson 1993			*/
/* LANGAGE: PURE C						*/
/*--------------------------------------*/

/*======================*/
/* definition des types	*/
/*======================*/

/* types construits pour l'identification de la machine	*/
/* -----------------------------------------------------*/
typedef struct
{	
	long 	ident;
	long	valeur;
}	t_cookie;


typedef enum 
{
	ST,
	STE,
	TT,
	FALCON_030,
	AUTRE_MACHINE
}	t_machine;	

typedef enum
{
	PG_ST,
	PG_STE,
	PG_TT,
	PG_FALCON_030,
	AUTRE_PG,
}	t_proc_graphique;

typedef enum
{	
	PROC_68000,
	PROC_68030,
	AUTRE_PROCESSEUR,
}	t_cpu;

typedef struct
{
	t_machine			la_machine;
	t_proc_graphique	proc_graphique;
	t_cpu				le_cpu;	
	int					version_aes;
	int					version_tos;								
}	t_ident_hard_soft;


/* types construits pour la recup‚ration du contexte graphique	*/
/* -------------------------------------------------------------*/
typedef int t_rgb[3];	/* rgb est un tableau de 3 entier	*/

typedef struct
{
	int	vdi_handle;		/* numero de la station de travail virtuelle	*/
						/* associee a l'‚cran			*/
	int	largeur;		/* largeur de l'ecran	*/
	int hauteur;		/* hauteur de l'ecran	*/
	int palette;			/* 	0: pas de palette	= NEAR TRUE COLOR ou TRUE_COLOR	)*/
							/* 	1 : une palette		*/						
	long	nb_coul;		/* nombre de couleurs  dans la palette ou dans le systeme*/
	long	nb_pinceaux_ecran;	/* nombre de feutres disponibles simultanements	*/
	void	*phys;			/* adresse physique de l'‚cran	*/
	void	*log;			/* adresse logique de l'‚cran	*/

/* les informations suivantes sont pour usage interne du programme	*/
/* et ne doivent donc theoriquement jamais	etre lues ni modifiees	*/
/* par l'utilisateur pour ses propres applications					*/

	t_rgb	*les_pinceaux;		/* pointeur vers la sauvegarde des feutres	*/
	int		nb_bit_coul[3];		/* nombre de bit par couleur	*/
	int		masque_coul[3];		/* masque pour les couleurs		*/
	int		mode;				/* mode graphique d'origine ou	*/
								/* resolution d'origine			*/
	unsigned long	taille;		/* taille d'un ecran	*/								
}	t_carac_ecran	;


/*====================================*/
/* definition des interfaces (C ANSI) */
/*====================================*/
long get_cookie(char *);
t_ident_hard_soft identifier_hard_soft(void);
t_carac_ecran	get_carac_ecran(t_ident_hard_soft *);
void GetPixelCompo(t_carac_ecran *,int,int,t_rgb);
void recuperer_pinceaux(t_carac_ecran *);
void reinstaller_contexte_graphique(t_carac_ecran 	*,
  									t_ident_hard_soft	*);

void tout_fermer(int);