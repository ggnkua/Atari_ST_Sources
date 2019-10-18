/*	Un squelette pour vos applications	*/
/*  graphique sous gem					*/
/*										*/
/* corps du programme					*/
/*										*/
/* AUTEUR: Marc Abramson 1993			*/
/* LANGAGE: PURE C						*/
/*--------------------------------------*/

#include <stddef.h>	/* pour definition de NULL*/
#include <stdlib.h>	/* pour les allocations memoires 		*/
#include <tos.h>		/* pour les appels a Super, Sversion*/
						/* pour phybase, logbase			*/	
						/* et des fonction falcon			*/
#include <aes.h>		/* pour l'appel a APPL_init et APPL_exit	*/

/* avec la nouvelle version de PURE C (1.1), mode.h est inclus dans
TOS.H et il n'est donc pas necessaire d'inclure mode.h				*/
#ifndef VGA_FALCON
	#include <mode.h>
#else
/* sauf pour Vsetscreen (extension de setscreen) qui n'est pas dispo */
/* en Pure C et qu'il faut donc definir alors						*/
	#define VSetscreen(a,b,c,d) (int)xbios(5,a,b,c,d)
#endif	
						
#include <vdi.h>	/* pour les fonctions vdi	*/

#include "list1.h"	/* pour les prototypes des fonctions du fichier	*/
					/* et les types									*/




/*======================================*/
/* definitions des variables globales	*/
/*======================================*/
int   contrl[12];   
int   intin[256];
int   intout[128];
int   ptsin[256];
int   ptsout[128];
int   work_in[11];    
int   work_out[57];   
int  numero_app;		/* numero de l'application AES courante	*/
						/* indispensable pour les accesoires et	*/
						/* pour multitos						*/
/*==============================================*/
/* prototypes des fonctions locales (C_ANSI)	*/
/*==============================================*/
int identifier_tos(void);


/*--------------------------------------------------------
	PROCEDURE 	: get_cookie
	AUTEUR		: M. Abramson
	DATE		: 27/9/1992
	DESCRIPTION: cette procedure renvoie le long mot associe au cookie
				pass‚ en parametre 1, et -1 si il n'y en a pas
	PARAMETRES:	
	ENTREE	: 
			char *: pointeur sur l'identificateur du cookie a rechercher
	RETURN	:
			long	: long mot associe au cookie
--------------------------------------------------------*/
long get_cookie(char *cookie_ident)
{
	long old_stack;

	t_cookie** ptr_tab_cookie=(t_cookie **)0x5a0;	/* pointeur vers  le tableau	*/
														/* des cookie	*/
	t_cookie *tab_cookie;

	long	target	=*(long *)(cookie_ident);		/* on convertit l'identificateur	*/
												/* cible en un long mot					*/

	/* pour lire l'adresse du tableau des cookies, il faut etre en mode	
		superviseur		*/
	if (Super((void *)1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=Super(0L);	/* on passe en mode superviseur	*/
	}
	else
	{	
		old_stack=0;
	}
	tab_cookie=*ptr_tab_cookie;	/* on lit cette adresse			*/
	
	
	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		Super((void *)old_stack);	/*  on y retourne */
	}				
				
	if (tab_cookie==NULL)		/* si le tos <1.6, on n'a pas de cookie jar	*/
		return(-1);				
		
	do		/* on boucle jusqu'a avoir trouve le cookie ou avoir atteint			*/
			/* le dernier element de la cookie jar									*/
	{
		if (tab_cookie	->ident	==target)	/* si le cookie est le cookie recherch‚	*/
		{
			return(tab_cookie	->valeur);	/* on renvoie sa valeur					*/
		}
		else
		{
			/* sinon, on passe au cookie suivant	*/
			tab_cookie++;
		}	
	}	
	while (tab_cookie->ident!=0);	/* la table des cookie est toujours	*/
								/* terminee par un cookie dont l'ident vaut	0	*/

	/* si on n'a pas trouve le cookie	, on renvoie -1 */
	return(-1);
}

/*--------------------------------------------------------
	PROCEDURE 	: identifier_tos
	AUTEUR		: M. Abramson
	DATE		: 03/3/1993
	DESCRIPTION:
	PARAMETRES: aucun	
	ENTREE	: aucun
	RETURN	: int numero de version du tos (en hexa)
--------------------------------------------------------*/
int identifier_tos(void)
{
	int version_tos;
	char		**sysbase=(char **)0x4f2;		/* pointeur vers le debut du
											systeme d'exploitation	*/
	char		*systeme;												
	long old_stack;
	if (Super((void *)1L)==0L)	/* si on est en mode utilisateur	*/
	{		
		old_stack=Super(0L);	/* on passe en mode superviseur	*/

	}
	systeme=*sysbase;			/* debut du systeme d'exploitation	*/

	if (old_stack)				/* si on etait en utilisateur au debut	*/
	{
		Super((void *)old_stack);	/*  on y retourne */
	}				

	version_tos = *(int *)(systeme+2);
	return(version_tos);
}

/*--------------------------------------------------------
	PROCEDURE 	: identifier_hard_soft
	AUTEUR		: M. Abramson
	DATE		: 03/3/1993
	DESCRIPTION:
	PARAMETRES: aucun	
	ENTREE	: aucun
	RETURN	: T_ident_hard identification de la machine
--------------------------------------------------------*/
t_ident_hard_soft identifier_hard_soft(void)
{
	long reponse;
	t_ident_hard_soft	id_locale;

	/* attention, ceci ne marche peut etre qu'avec les dernieres versions	*/
	/* du Pure C*/
	extern AES_pb;
	AESPB *l_aes;
	/* identification de la machine	*/
	reponse=get_cookie("_MCH");
	if (reponse==-1)		/* si il n'y a pas de reponse sur	*/
	{						/* le cookie MCH, on est sur un ST	*/
							/* sans cookie JAR et ses caracteristique	*/
							/* sont donc celles du ST			*/
	}
	else							
	{
		switch ((int)(reponse>>16))	/* seul les 16 bits faibles nous interessent	*/
								/* et un switch se fait toujours sur un entier	*/
		{	
			case	0x0:
				id_locale.la_machine =ST;
				break;
			case	0x1:
				id_locale.la_machine =STE;
				break;
			case 0x2:
				id_locale.la_machine =TT;
				break;
			case 0x3:
				id_locale.la_machine =FALCON_030;
				break;
			default:
				id_locale.la_machine =AUTRE_MACHINE;				
				break;
		}

		/* identification du systeme graphique	*/
		reponse=get_cookie("_VDO");
		if (reponse!=-1)				/* si il y a une reponse	*/
		switch ((int)(reponse>>16))	/* seul les 16 bits faibles nous interessent	*/
									/* et un switch se fait toujours sur un entier	*/
		{	
			case	0x0:
				id_locale.proc_graphique =PG_ST;
				break;
			case	0x1:
				id_locale.proc_graphique =PG_STE;
				break;
			case 0x2:
				id_locale.proc_graphique =PG_TT;
				break;
			case 0x3:
				id_locale.proc_graphique =PG_FALCON_030;
			break;
			default:
				id_locale.proc_graphique =AUTRE_PG;
				break;
		}	

		/* identification du CPU	*/
		reponse=get_cookie("_CPU");
		if (reponse!=-1)				/* si il y a une reponse	*/
		switch ((int)(reponse))		/* seul les 16 bits faibles nous interessent	*/
		{
			case 0: 
				id_locale.le_cpu	=PROC_68000;
				break;
			case 30:
				id_locale.le_cpu	=PROC_68030;
				break;
			default	:
				id_locale.le_cpu	= AUTRE_PROCESSEUR;
				break;
		}
	}			/* fin du if sur la presence d'une cookie jar	*/
	
	/* initialise l'AES pour recuperer son numero	*/
	numero_app= appl_init();
	
	
	/* attention, ceci ne marche vraissemblablement qu'avec	*/
	/* les dernieres versions du pure C						*/
	l_aes=(AESPB *)&AES_pb;
	
	
	id_locale.version_aes=l_aes->global[0];
	id_locale.version_tos=identifier_tos();
	
	return (id_locale);
}



/*--------------------------------------------------------
	PROCEDURE 	: get_carac_ecran
	AUTEUR		: M. Abramson
	DATE		: 20/5/1993
	DESCRIPTION: Cette procedure recupere les parametres de l'ecran 
				courant
	PARAMETRES:	
	ENTREE	: 
	RETURN	:
		t_carac_ecran	: parametre de l'ecran courant
--------------------------------------------------------*/
t_carac_ecran	get_carac_ecran(t_ident_hard_soft *le_hard_soft)
{
	int local_vdi_handle;
	t_carac_ecran	c_ecran;
	int i;
	int nb_bit_plane;	/* nombre de plan de bit total	*/
	int nb_bit_coul;	/* et par couleur				*/
	long nb_coul;		/* nombre de couleur dispo dans */
						/* la palette ou dans le systeme	*/
	int restant;
	
	/* ouverture d'une station de travail virtuelle pour	
		recuperer les parametres d'‚cran	*/
    for (i=1;i<10;work_in[i++]=1);
        work_in[10]=2;
	work_in[0]=Getrez()+2;  /* le numero de la resolution d'ouverture	*/
						/* de la station virtuelle depend de la 	*/
						/* resolution								*/
    v_opnvwk(	work_in,
    			&local_vdi_handle,
    			work_out);

	/* recuperation de la station de travail virtuelle	*/
	c_ecran.vdi_handle 	=local_vdi_handle;
	
	/* recuperation des dimensions de l'ecran	*/
	c_ecran.largeur		=work_out[0]+1;
	c_ecran.hauteur		=work_out[1]+1;
	

	/* recuperation du nb de 'pinceaux' disponibles simultann‚ments */
	c_ecran.nb_pinceaux_ecran	= work_out[13];

	/* recuperation de la taille de la palette	*/
	nb_coul=work_out[39];	

	/* recuperation d'information supplementaires	*/
	vq_extnd(local_vdi_handle,1,work_out);

	/*  test de la presence ou non d'une palette	*/
	c_ecran.palette		=work_out[5];

	/* recuperation du nombre de bit des couleurs	*/	
	nb_bit_plane=work_out[4];
	
	/* recuperation du mode graphique courant			*/
	/* -------------------------------------------------*/
	/* si on est sur un falcon 030									*/
	if (   le_hard_soft->la_machine 	==	FALCON_030)
	{
		/* si on a un processeur graphique de falcon 030, et que on 	*/
		/*	n'est pas avec une carte graphique	true color 24 bits (ou +)*/
		/*  mais dans l'un des modes d'origine du falcon				*/
		if ((le_hard_soft->proc_graphique ==	PG_FALCON_030)
			&& (nb_bit_plane			<=16))	
		{
			c_ecran.mode=Vsetmode(-1);	/* recuperer le mode graphique	*/
										/* d'origine du falcon			*/
			if (nb_coul==0)	/* si on dans un mode falcon avec palette 		*/
							/* etendue										*/										
			{
				nb_coul=262144L;	/* ca, c'est la taille de la palette du falon	*/
							/* je n'ai trouve aucun moyen de le lire dans	*/
							/* une variable systeme ou VDI quelconque et je	*/
							/* me vois donc contraint de le mettre en dur	*/									
			}				
			/* pour avoir la taille de l'ecran , rien de plus simple	*/										
			c_ecran.taille=VgetSize(c_ecran.mode);
		}
		else
		{	/* cas du falcon avec carte graphique true color	*/
			c_ecran.mode=-1;
			c_ecran.taille=(unsigned long)c_ecran.largeur*
							c_ecran.hauteur*nb_bit_plane/8;
		}	
	}		/* fin du cas falcon		*/
	else
	{
		/* calcul de la taille de l'ecran en octet	*/
		c_ecran.taille=(unsigned long)c_ecran.largeur*
						c_ecran.hauteur*nb_bit_plane/8;

		/* sinon, si on est sur une machine connue a ce jour (ST,STE,TT)	*/
		if (le_hard_soft->la_machine !=AUTRE_MACHINE)
		{
			if (c_ecran.palette)	/* si on est dans un mode avec palette	*/
			{
				c_ecran.mode=Getrez();	/* on recupere la resolution		*/
			}
			else			/* sinon, si pas de palette on est sur carte  graphique	*/
			{
				c_ecran.mode=-1;		/* et on l'indique par un -1 indiquant				*/
										/* que l'on n'est pas dans un mode graphique connu	*/
			}
		}		
		else	/* sinon on met un -1 dans le mode pour indiquer le pbm		*/
		{	
			c_ecran.mode =-1;	
		}
	}		
	
	
	
	if (!c_ecran.palette)	/* si il n'y pas de palette	*/
	{						/* le nombre de couleur depend du nombre de plans de bits */
		/* si le nombre de bit plane est superieur a 24,				*/
		/* cela signifie que les bits en trop traitent la transparence	*/
		/* ils n'interviennent donc pas sur le codage de couleur		*/
		if (nb_bit_plane>24) nb_bit_plane=24;

		c_ecran.nb_coul=1<<nb_bit_plane;	/* le nb de couleur est
								2 puissance le nombre de plan	*/
	}
	else
	{
		c_ecran.nb_coul=nb_coul;
	}
	/* on calcule le nombre de bit pour chaque couleur	*/
	nb_bit_coul =nb_bit_plane/3;
	restant = nb_bit_plane-3*nb_bit_coul;	/* nombre de bit restant	*/
	c_ecran.nb_bit_coul[0]=nb_bit_coul;
	c_ecran.nb_bit_coul[1]=nb_bit_coul+restant;	/* les bits restants vont au vert	*/
	c_ecran.nb_bit_coul[2]=nb_bit_coul;
	
	for (i=0;i<3;i++)
	{
		c_ecran.masque_coul[i]=(1<<c_ecran.nb_bit_coul[i])-1;	/* valeur maximale de la couleur	*/
													/* vue le nombre de bits			*/
	}


	c_ecran.phys=Physbase();	
	c_ecran.log=Logbase();
	c_ecran.les_pinceaux	= NULL;		/* pour l'instant, 	les pinceaux ne */
									/* sont pas sauvegardes				*/
	return(c_ecran);
}

/*--------------------------------------------------------
	PROCEDURE 	: recuperer_pinceaux
	AUTEUR		: M. Abramson
	DATE		: 20/5/1993
	DESCRIPTION: Cette procedure reserve la place necessaire
				a la sauvegarde des 'pinceaux' courants, puis
				recupere les composants de ces pinceaux
	PARAMETRES:	
	ENTREE/Sortie	: 
		t_carac_ecran *	pointeur sur les caracterisques de l'ecran
	--------------------------------------------------------*/
void recuperer_pinceaux(t_carac_ecran *c_ecran)
{
	int i;
	
	c_ecran->les_pinceaux	= (t_rgb *)malloc(c_ecran->nb_pinceaux_ecran
										* sizeof(t_rgb));
	for (i=0;i<c_ecran->nb_pinceaux_ecran;i++)
	{
		vq_color(	c_ecran->vdi_handle,
					i,
					1,		/* on veut les couleurs reellements presentes	*/
							/* et non les couleurs demandees				*/
					(int *)&c_ecran->les_pinceaux[i]);
	}		
	
}

/*--------------------------------------------------------
	PROCEDURE 	: reinstaller_contexte_graphique
	AUTEUR		: M. Abramson
	DATE		: 20/5/1993
	DESCRIPTION: Cette procedure reinstalle le contexte
				graphique donne en parametre, y compris
				les pinceaux, ci ceux ci existent
	PARAMETRES:	
	ENTREE: 
		par 1:	t_carac_ecran *	pointeur sur les caracterisques de l'ecran
		par 2:  t_ident_hard_soft  * pointeur sur les carac hard de la machine
	--------------------------------------------------------*/
void	reinstaller_contexte_graphique( t_carac_ecran 	*c_ecran,
										t_ident_hard_soft	*le_hard_soft)
{

	int i;
	/* premiere chose a effectuer: retourner dans le mode d'origine	*/	
	/* de l'ecran, et aux adresses d'ecran physique et logique		*/
	/* d'origine													*/

	/* sur falcon, pour faire tout cela en une seule operation, on     */
	/* utilise le nouveau setscreen VSetscreen	dans lequel le 		   */
	/* parametre rez vaut 3 et qui a alors un parametre	supplementaire */
	/* qui donne le mode												*/

	if (le_hard_soft->la_machine		== FALCON_030)
	{
		if (c_ecran->mode !=-1)	/* si le mode graphique a ete identifie		*/
		{
			VSetscreen(	c_ecran	->phys,
					c_ecran	->log,
					3,
					c_ecran	->mode);
		}
		else
		{
			/* mais attention, sur un hypothetique falcon avec carte graphique	*/
			/* et mode graphique non identifie									*/
			/* il vaut mieux ne pas modifier le mode , et pour cela utiliser    */
			/* le classique Setscreen											*/
			Setscreen(	c_ecran	->phys,
						c_ecran	->log,
						c_ecran	->mode);
		}		
	}
	else
	{
		/* sur les autres machines, il faut faire un Setscreen classique	*/
		Setscreen(	c_ecran	->phys,
					c_ecran	->log,
					c_ecran	->mode);
	}
	
	/* sur toutes les machines, si, comme on aurait du le faire,	*/
	/*	 on a sauvegarde les pinceaux, il faut remettre les pinceaux	*/
	/* d'origines	*/
	if (c_ecran->les_pinceaux)	
	{
		for (i=0;i<c_ecran->nb_pinceaux_ecran;i++)
		{
			vs_color(	c_ecran->vdi_handle,
						i,
						(int *)&c_ecran->les_pinceaux[i]);
		}
		/* puis liberer la place memoire reservee pour stocker	*/
		/* ces pinceaux											*/
		free((void *)c_ecran->les_pinceaux);
	}
}

/*--------------------------------------------------------
	PROCEDURE 	: tout_fermer
	AUTEUR		: M. Abramson
	DATE		: 20/5/1993
	DESCRIPTION: cette procedure termine proprement
			un programme en fermant la fenetre de travail
			virtuelle courante, puis en indiquant … l'AES
			que l'application est finie
	PARAMETRES:	
	ENTREE: 
		int vdi_handle;
	--------------------------------------------------------*/
void tout_fermer(int vdi_handle)
{
	v_clsvwk(vdi_handle);	/* fermer la fenetre de travail virtuelle	*/
	appl_exit();			/* indispensable sous multitos				*/
}

/*--------------------------------------------------------
	PROCEDURE 	: GetPixelCompo
	AUTEUR		: M. Abramson
	DATE		: 22/05/1993
	DESCRIPTION: Cette procedure recupere la couleur
			d'un point de l'‚cran dans ses composantes RVB sur 1000 
			quel que soit le mode
	PARAMETRES:	
	ENTREE	: 
		par 1:	T_carac_ecran	* caracteristiques de l'‚cran courant
		par 2:	int x;
		par 3:	int y;
	SORTIES:
		par 4 : t_rgb *		tableau des composantes RVB de la couleur sur 1000
	RETURN	:
		rien
	--------------------------------------------------------*/
void  GetPixelCompo(t_carac_ecran *c_ecran,
						int x,
						int y,
						t_rgb compo_rvb)
{
	int i;
	unsigned long compo_long;
	t_rgb compo_bit;			/* composante de chaque couleur	*/
	int comp1,comp2;
	
	v_get_pixel(c_ecran->vdi_handle,
				x,y,
				&comp1,
				&comp2);

	if (c_ecran->palette)		/* si il y a une palette	*/
							
	{
		/* on recupere les composantes reeles correspondant	*/
		/* a l'index de couleur								*/
		vq_color(c_ecran->vdi_handle,
				comp2,
					1,		/* on veut les couleurs reellements presentes	*/
							/* et non les couleurs demandees				*/
				(int *)compo_rvb);
							
	}
	else
	{
		/* reconstituer la couleur sur 32 bits */
		compo_long= ((long)comp1<<16)+comp2;
		
		/* les informations sont stock‚es ainsi	*/
		/*	poids fort R V B poids faible	*/  
		
		/* extraction de la composante bleue	*/
		compo_bit[2]=(int)compo_long&c_ecran->masque_coul[2];

		/* suppression du bleue dans la couleur lue	*/
		compo_long = compo_long>>c_ecran->nb_bit_coul[2];

		/* extraction de la composante verte	*/
		compo_bit[1]=(int)compo_long&c_ecran->masque_coul[1];

		/* suppression du vert dans la couleur lue	*/
		compo_long = compo_long>>c_ecran->nb_bit_coul[1];
		
		/* extraction de la composante rouge		*/
		compo_bit[0]=(int)compo_long & c_ecran->masque_coul[0];
		
		/* quantification des composantes entres 0 et 1000	*/
		for (i=0;i<3;i++)
		{
			compo_rvb[i]=
			(int)(1000UL*compo_bit[i]/c_ecran->masque_coul[i]+.5);
		}											
	}	/* fin du else sur test presence palette	*/
}

/*	Selection d'un 'pinceaux' dans la 'petite boite'	*/
/* ---------------------------------------------*/
/*	pour le texte	: vst_color(ecran.handle,numero_du_pinceau)		*/
/*	pour les marqueurs : vsm_color(ecran.handle,numero_du_pinceau)	*/
/*	pour les lines	 : vsl_color(ecran.handle,numero_du_pinceau)		*/
/* pour les remplissages : vsf_color(ecran.handle,numero_du_pinceau)	*/
