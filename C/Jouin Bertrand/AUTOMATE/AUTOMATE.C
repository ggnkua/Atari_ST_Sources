/* -----------------------------------------------------------------
   Type de fichier : Source
   -----------------------------------------------------------------
   Description : exemple d'automate pour falk'mag 9
   Auteur      : Golio Junior (Bertrand Jouin)
   -----------------------------------------------------------------
   Nom du fichier : automate.c
   Fichier associ‚ : aucun
   Macro    :  : description
   Type     : t_matrice : d‚finition de matrice d'int
              t_automate : d‚fintion d'un automate
   Fonction : main : programme principal
   Constantes Internes : constante : description
   Variables Globales : nom : description
   Historique : - 13/12/97 : premier Jet (encore en retard!)
   ----------------------------------------------------------------- */

#include <math.h>
#include <stdio.h>

/* -----------------------------------------------------------------
   Macro
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Macro  :
   Description :
   Appels :
   Retour : 
   Date de cr‚ation : //
   Modifications :
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Constantes
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Nom : CARACTERE
   Description : ensemble de caractere de l'automate
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
typedef enum caractere {
	ZERO=0,
	UN=1,
	DEUX=2,
	TROIS=3,
	QUATRE=4,
	CINQ=5,
	SIX=6,
	SEPT=7,
	HUIT=8,
	NEUF=9,
	VIRGULE=10,
	FIN_CHAINE=11,
	BRUIT=12
	} CARACTERE;

/* -----------------------------------------------------------------
   Nom : ACTION
   Description : ensemble des actions de l'automate
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
typedef enum action {
	RIEN,
	INIT,
	INIT_VIRG,
	VIRG,
	CH,
	CH_VIRG,
	FIN_CH,
	ERREUR
	} ACTION;

/* -----------------------------------------------------------------
   types globaux
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   type : t_matrice
   Description : d‚finition de matrice d'entier
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
typedef struct t_matrice {
	int largeur;					/* largeur de la matrice */
	int hauteur;					/* hauteur de la matrice */
	int *matrice;					/* adresse de la matrice */
	} t_matrice;

/* -----------------------------------------------------------------
   type : t_automate
   Description : d‚finition d'un automate
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
typedef struct t_automate {
	int etat_initial;				/* ‚tat initial de l'automate */
	int etat_courant;				/* ‚tat courant de l'automate */
	int etat_final;					/* ‚tat final de l'automate */
	t_matrice transition;			/* matrice de transition */
	t_matrice action;				/* matrice d'action */
	} t_automate;

/* -----------------------------------------------------------------
   Prototypage de fonction
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Variables globales
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Nom :
   Type :
   Description :
   Date de cr‚ation : //
   Modifications :
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Fonctions
   ----------------------------------------------------------------- */

/* -----------------------------------------------------------------
   Fonctions   : matrice
   Description : retourne la valeur de la matrice contenu … la ligne et colonne
   ParamŠtre d'entr‚e  : la matrice
                         la ligne
                         la colonne
   ParamŠtre de sortie : le contenu
   variables globales modifi‚es : aucunes
   variables locales            : aucunes
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
int matrice(const t_matrice *matrice, int ligne, int colonne)
{ /* si l'accŠs se d‚roule en dehors de la matyrice, il y a affichage
     d'un message d'erreur et retour de la valeur 0 */
  if((matrice->hauteur>ligne)&(matrice->largeur>colonne))
  	{ return matrice->matrice[ligne*matrice->largeur+colonne];
  	}
  	else
  	{ /* erreur ! */
  	  printf("accŠs en dehors de la matrice \n");
  	  return 0;
  	}
}

/* -----------------------------------------------------------------
   Fonctions   : action
   Description : retourne le code de l'action suivant l'‚tat, et le caractŠre
   ParamŠtre d'entr‚e  : l'automate
                         le caractŠre
   ParamŠtre de sortie : l'action
   variables globales modifi‚es : aucunes
   variables locales            : aucunes
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
int action(const t_automate *automate, int caractere)
{ return matrice(&automate->action, automate->etat_courant, caractere);
}

/* -----------------------------------------------------------------
   Fonctions   : transition
   Description : effectue une transition
   ParamŠtre d'entr‚e  : l'automate
                         le caractŠre
   ParamŠtre de sortie : aucun
   variables globales modifi‚es : l'automate
   variables locales            : aucunes
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
void transition(t_automate *automate, int caractere)
{ automate->etat_courant=matrice(&automate->transition, automate->etat_courant, caractere);
}

/* -----------------------------------------------------------------
   Fonctions   : init_automate
   Description : initialisation de l'automate
   ParamŠtre d'entr‚e  : l'automate
   ParamŠtre de sortie : aucun
   variables globales modifi‚es : l'automate
   variables locales            : aucunes
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
void init_automate(t_automate *automate)
{ automate->etat_courant=automate->etat_initial;
}

/* -----------------------------------------------------------------
   Fonctions   : fin_automate
   Description : initialisation de l'automate
   ParamŠtre d'entr‚e  : l'automate
   ParamŠtre de sortie : vrai si l'automate est termin‚
   variables globales modifi‚es : aucune
   variables locales            : aucune
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
int fin_automate(const t_automate *automate)
{ return automate->etat_courant==automate->etat_final;
}

/* -----------------------------------------------------------------
   Fonctions   : automate
   Description : fait avancer d'un pas l'automate
   ParamŠtre d'entr‚e  : l'automate
                         le caractŠre
   ParamŠtre de sortie : aucun
   variables globales modifi‚es : l'automate
   variables locales            : les variables locales aux actions
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
void automate(t_automate *automate, int caractere)
{ /* variable n‚cessaire pour le fonctionnement de l'automate */
  static double nombre;		/* valeur du nombre d‚cod‚ */
  static double decalage;		/* nombnre de chiffre aprŠs la virgule */

  switch(action(automate, caractere))
  	{ case RIEN:
  		break;
	  case INIT:
	  	nombre=caractere;
	  	decalage=1;
	  	break;
	  case INIT_VIRG:
	  	nombre=0;
	  	decalage=1;
	  	break;
	  case VIRG:
	  	break;
	  case CH:
	  	nombre=nombre*10+caractere;
	  	break;
	  case CH_VIRG:
	  	nombre=nombre*10+caractere;
	  	decalage*=10;
	  	break;
	  case FIN_CH:
	  	nombre=nombre/decalage;
	  	printf("nombre rentr‚ : %f",nombre);
	  	break;
	  case ERREUR:
	  	printf("pr‚sence de caractŠre non conforme");
	  	break;
	  default:
	  	printf("erreur interne … l'automate\n");
  	}
  transition(automate, caractere);
}

/* -----------------------------------------------------------------
   Fonctions   : traduit
   Description : traduit un caractŠre ascii vers un caractŠre pour l'automate
   ParamŠtre d'entr‚e  : le caractŠre ascii
   ParamŠtre de sortie : le caractŠre automate
   variables globales modifi‚es : aucune
   variables locales            : aucune
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
int traduit(char caractere)
{ switch(caractere)
	{ case '\n':
		return FIN_CHAINE;
		break;
	  case '0':
	  	return ZERO;
	  	break;
	  case '1':
	  	return UN;
	  	break;
	  case '2':
	  	return DEUX;
	  	break;
	  case '3':
	  	return TROIS;
	  	break;
	  case '4':
	  	return QUATRE;
	  	break;
	  case '5':
	  	return CINQ;
	  	break;
	  case '6':
	  	return SIX;
	  	break;
	  case '7':
	  	return SEPT;
	  	break;
	  case '8':
	  	return HUIT;
	  	break;
	  case '9':
	  	return NEUF;
	  	break;
	  case ',':
	  	return VIRGULE;
	  	break;
	  default:
	  	return BRUIT;
	}
}

/* -----------------------------------------------------------------
   Fonctions   : main
   Description : fonction principale
   ParamŠtre d'entr‚e  : aucun
   ParamŠtre de sortie : aucun
   variables globales modifi‚es : aucunes
   variables locales            : l'automate
                                  la chaine de caractŠre
   Date de cr‚ation : 13/12/97
   Modifications :
   ----------------------------------------------------------------- */
void main()
{ char caractere;
  int caractere_auto;
  int transition[]=/*0  1  2  3  4  5  6  7  8  9  , \n erreur */
                   { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4,		/* ‚tat 0 : initial */
                     1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4,		/* ‚tat 1 : lecture de la partie entiŠre*/
                     2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 3, 4,		/* ‚tat 2 : lecture de la partie d‚cimale */
                     3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,		/* ‚tat 3 : fin de la lecture */
                     4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 4		/* ‚tat 4 : erreur */
                   };
  int action[]={ INIT, INIT, INIT, INIT, INIT, INIT, INIT, INIT, INIT, INIT, INIT_VIRG, RIEN, ERREUR,	/* ‚tat 0 */
                 CH, CH, CH, CH, CH, CH, CH, CH, CH, CH, VIRG, FIN_CH, ERREUR,	/* ‚tat 1 */
                 CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, CH_VIRG, ERREUR, FIN_CH, ERREUR,	/* ‚tat 2 */
                 RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN,	/* ‚tat 3 */
                 RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN, RIEN	/* ‚tat 4 */
               };
  t_automate lit_nbre={ 0,			/* ‚tat initial */
                        0,          /* ‚tat courant */
                        3,          /* ‚tat final */
                        { 13, 5,	/* matrice de transition */
                          transition
                        },
                        { 13, 5,
                          action
                        }
                      };

  init_automate(&lit_nbre);
  
  printf("entrer un nombre : ");

  while(!fin_automate(&lit_nbre))
  	{ caractere=getchar();
  	  caractere_auto=traduit(caractere);
  	  automate(&lit_nbre,caractere_auto);
  	}
  getchar();
}
