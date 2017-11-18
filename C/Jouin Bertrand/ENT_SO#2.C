/* entr‚e/sortie sur fichier
  pour Falk'mag 5, par Golio junior
*/

#include <stdio.h>

int main(void)
{ FILE *f;
  int c;
  /* ouverture du fichier en ‚criture toto.out */
  if ((f=fopen("toto.out","w"))==NULL)
  	{ printf ("impossible d'ouvrir toto.out\n");
  	}
  	else
  	{ printf("tapez votre texte jusqu'a ^Z\n");
  	  while((c=getchar())!=EOF)
  		{ fputc(c,f);
  		}
  	  if (fclose(f))
  	  	{ printf("erreur de fermeture\n");
  	  	}
  	  printf(" voici ce que vous avez tapez :\n");
  	  if ((f=fopen("toto.out","r"))==NULL)
  	  	{
  	  	}
  	  	else
  	  	{ while((c=fgetc(f))!=EOF)
  			{ putc(c,stdout);
  			}
  		  fclose(f);
  	  	}
  	}
  return 0;
}
