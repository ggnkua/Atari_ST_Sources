/*	Un squelette pour vos applications	*/
/*  graphique sous gem					*/
/*										*/
/* exemple de programme principal		*/
/*										*/
/* AUTEUR: Marc Abramson 1993			*/
/* LANGAGE: PURE C						*/
/*--------------------------------------*/#


#include <stdio.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include "list1.h"	/* pour les prototypes des fonctions du fichier	*/
					/* et les types									*/

/* avec la nouvelle version de PURE C (1.1), mode.h est inclus dans	*/
/* TOS.H et il n'est donc pas necessaire d'inclure mode.h				*/
#ifndef VGA_FALCON
	#include <mode.h>
#else
/* sauf pour Vsetscreen (extension de setscreen) qui n'est pas dispo */
/* en Pure C et qu'il faut donc definir alors						*/
	#define VSetscreen(a,b,c,d) (int)xbios(5,a,b,c,d)
#endif	

/*--------------------------------------------------------
	PROCEDURE 	: exemple_switch_reso
	AUTEUR		: M. Abramson
	DATE		: 20/5/1993
	DESCRIPTION: Cette procedure se place dans la
			plus grande r‚solution 16 couleurs
			quelque soit le mode graphique de base
			et la machine
			
	PARAMETRES:	
	ENTREES: 
		par 2: t_hard_soft	*    caracteristiques de la machine
		par 3: int 				vdi handle de la station d'origine
	ENTREE/SORTIES:
		par 1: t_carac_ecran *   caracteristiques du nouvel ‚cran

	RETURN:
		0: Le mode n'a pas chang‚, on ‚tait deja dans la bonne r‚so
		1: La r‚solution a chang‚e.
		-1 si aucun mode 16 couleurs n'est disponible
	--------------------------------------------------------*/

int exemple_switch_reso(t_carac_ecran *l_ecran,
						t_ident_hard_soft	*le_hard_soft)
{
	int reponse=1;	/* par defaut, la reponse est changement de mode	*/
	int new_mode;
	if (l_ecran->mode !=-1)	/* si on est n'est pas sur carte	*/		
	{						/* graphique						*/
		switch (le_hard_soft->la_machine)
		{
			case TT:	/* si on est sur TT	*/
				if (l_ecran->mode ==6)	/* si sur grand ecran, impossible de changer	*/
					reponse=-1;
				else
					if (l_ecran->mode !=4)		/* si le mode n'est pas la moyenne TT	*/				
					{
						Setscreen((void *)-1,
								  (void *)-1,
								  4);		/* passer en moyenne TT			*/
					}
				else
					reponse=0;
			break;
			case ST:
				if (l_ecran->mode!=1)		/* si on est en moyenne ST		*/
				{
					Setscreen((void *)-1,
							   (void *)-1,
							   0);		/* on passe en basse ST		*/
				}
				else
				if (l_ecran->mode==2)		/* si on est en monochrome	*/
				{
					reponse=-1;			/* il est difficile de passer en couleur	*/
				}
				else
					reponse=0;				
			break;
			case FALCON_030:
				/* sur falcon, on peut enfin reinitialiser le vdi	en changeant de mode	*/
				v_clsvwk(l_ecran->vdi_handle);	/* changer de mode, donc		*/
							/* refermer la station VDI		*/

				if (mon_type()==0)			/* si on est sur moniteur monochrome	*/
				{
					reponse=-1;					/* il est difficile de passer en couleur	*/
				}
				else
				{
					/* on ne conserve que les bits relatifs …u moniteur et au systeme 	*/
					new_mode=l_ecran->mode & (VGA_FALCON|PAL);
					
					if (new_mode&VGA_FALCON)		/* si on est sur moniteur VGA	*/
					{	/* plus grande reso en 16 couleurs = 640*480 16 couleurs	*/
						new_mode|=BPS4|COL80;						
					}
					else	/* sinon, sur TV	*/
					{
						/* la plus grande r‚solution en 16 couleurs		*/
						/* 640*400+OVERSCAN avec entrelacement		*/
						new_mode|=BPS4|COL80|OVERSCAN|VERTFLAG;
					}
					/* faire le changement de reso	*/
					VSetscreen( (void *)0,
								(void *)0,
								3,
								new_mode);
	
	
					/* si le mode n'a pas chang‚, on l'indique	*/								
					if (new_mode==l_ecran->mode)
						reponse=0;			
						
				}	/* fin du cas falcon	*/
			/* recuperer les caracteristiques	du nouveau mode*/										/* du nouvel ‚cran graphique		*/										
			*l_ecran=get_carac_ecran(le_hard_soft);				
			break;			
			default:		/* sur une machine non identifiee	*/
				reponse=-1;	/* on ne peut passer en couleur, nah	*/
		}		/* du test sur la machine	*/
	}
	else		/* cas de la carte graphique		*/
	{	
		reponse=-1;			/* impossible de passer en 16 couleurs	*/
	}	
	return(reponse);
}						

/* la procedure principale		*/
/*	--------------------------	*/
void main(void)
{
	t_carac_ecran		carac_ecran_initial;
	t_carac_ecran		carac_apres_chgt;
	t_ident_hard_soft	hard_soft_courant;
	t_rgb				coul_rouge={800,100,100};
	t_rgb				coul_bleue={50,120,900};
	t_rgb				coul_vert={80,750,150};
	int rep;
	
	
	/* identifier le hardware							*/
	hard_soft_courant=identifier_hard_soft();

	/* identifier le contexte graphique					*/
	carac_ecran_initial	=	get_carac_ecran(&hard_soft_courant);
	
	/* recuperer les composantes des pinceaux			*/
	recuperer_pinceaux(&carac_ecran_initial);


	/* votre application	*/
	/* ici un exemple de changement de r‚solution	*/
	carac_apres_chgt=carac_ecran_initial;
	
	/* si le changement se passe mal on l'indique	*/
	rep=exemple_switch_reso(&carac_apres_chgt,
							&hard_soft_courant);
	if (rep==-1)							
	{
		form_alert(1,"[1][Passage en |16 couleurs|impossible][Dommage !]");
	}
	else
	{
		if ((hard_soft_courant.la_machine==FALCON_030)|| 
			(rep==0)) 	/* qu'on etait deja dans la bonne r‚solution	*/
					/* on peut alors utiliser AES et VDI pour les affichages	*/
		{
			/* modification de la couleur 1 (celle du texte des boites )	*/
			/* en un rouge	profond											*/
			vs_color(	carac_apres_chgt.vdi_handle,
						1,
						(int *)coul_rouge);


			/* modification de la couleur 0 (le blanc) en un vert	*/						
			vs_color(	carac_apres_chgt.vdi_handle,
						0,
						(int *)coul_vert);
			/* modification de la couleur 3 (le fond vert en un beau bleu	*/						
			vs_color(	carac_apres_chgt.vdi_handle,
						3,
						(int *)coul_bleue);
			form_alert(1,"[2][Ok, passage |en 16 couleurs|effectu‚][Bien]");
		}
	}
	
	/* reinstaller le contexte initial, sans oublier les pinceaux	*/	
	reinstaller_contexte_graphique( &carac_ecran_initial,
									&hard_soft_courant);
	/* fermer AES et VDI	*/
	tout_fermer(carac_apres_chgt.vdi_handle);
}
