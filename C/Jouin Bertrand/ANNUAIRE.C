/* Annuaire simpliste mais efficace */

#include <stdio.h>
#include <string.h>

/* definition des types */
struct enregistrement
	{ char nom[20];
	  char numero[20];
	};

/* definition des variables globales */
int index;
struct enregistrement annuaire[10];

/* prototypage */
int main(void);
void entrer(void);
void lister(void);
void chercher(void);

/* procedure de lecture */
void entrer(void)
{ char entree[20];
  if (index<10) { printf(" Entrer le nom : ");
  			  	  scanf("%s",annuaire[index].nom);
  				  printf(" No de telephone ");
  				  scanf("%s",entree);
  				  strcpy(annuaire[index].numero, entree);
  				  index++;
  			    }
}

/* procedure de listage */
void lister(void)
{ int i;
  for(i=0; i<index; i++)
  	{ printf("%s -> %s \n", annuaire[i].nom, annuaire[i].numero);
  	}
}

/* procedure de recherche */
void chercher(void)
{ char entree[20];
  int i;
  printf(" Entrer le nom recherch‚ : ");
  scanf("%s",entree);
  i=0;
  while (i<index)
    { if (strcmp(entree,annuaire[i].nom)==0)
    	{ printf("%s -> %s \n", annuaire[i].nom, annuaire[i].numero);
    	  break;
    	}
      i++;
    }
}

/* procedure principal */
int main(void)
{ char a;
  index=0;
  do
    { printf("\n Annuaire \n \n");
      printf(" e : Entrer un nom\n");
      printf(" l : lister les nom de l'annuaire\n");
      printf(" c : chercher un nom\n");
      printf(" f : fin\n");
      printf(" votre choix : ");
      scanf("%c",&a);
      switch(a)
        { case 'e' : { entrer();
                       break; }
          case 'l' : { lister();
                       break; }
          case 'c' : { chercher();
                       break; }
        }
    }
  while (a!='f');
  return(0);
}
