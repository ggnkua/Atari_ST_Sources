/* exemple d'entr‚es/sorties format‚e
   par golio Junior, pour Falk'mag 5
*/

#include <stdio.h>

int main(void)
{ FILE *f;
  int n;
  if ((f=fopen("titi.out","w"))==NULL)
  	{ printf ("impossible d'ouvrir le fichier titi.out\n");
  	}
  	else
  	{ printf("entrer des entiers, terminer par ^Z\n");
	  while (scanf("%d", &n)!=EOF)
  		{ fprintf(f, "%d ", n);	/* attention l'espace sert de s‚parateur! */
  		}
  	  if (fclose(f))
  	  	{ printf("erreur de fermeture\n");
  	  	}
  	}
  printf("relecture et affichage des entiers :\n");
  if ((f=fopen("titi.out","r"))==NULL)
  	{ printf("impossible d'ouvrir le fichier titi.out\n");
  	}
  	else
  	{ while(fscanf(f,"%d",&n)!=EOF)
  		{ printf("%d\n",n);
  		}
  	  fclose(f);
  	}
  return 0;
}
