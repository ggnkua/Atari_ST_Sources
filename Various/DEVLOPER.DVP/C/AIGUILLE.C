/*******************************************************/
/*  Aiguillage de l'entr‚e au clavier vers un fichier  */
/*     Megamax Laser C      AIGUILLE.C     */
/*******************************************************/

#include <osbind.h>

#define FILENAME "AIGUILLE.DOC"
#define STDIN 0                          /* Handle d'entr‚e standard */
#define LIRE 0

int  non_std_handle;
int  handle;
char string[80];

entree (string)                /* Petite routine d'entr‚e pour chaŒne */
char string[];
{
int  i;

  i = -1;
  do
  {
    string[++i] = Cconin();   /* Lecture des caractŠres d'entr‚e standard */
    if (string[i] == 13)      /* jusqu'… appui sur Return (=13); */
      string[i] = 0;          /* Return est remplac‚ par un octet nul */
  }
  while (string[i] != 0);
}

main()
{
  handle = Fopen (FILENAME, LIRE);     /* Les entr‚es doivent venir */
   if (handle < 0)                     /* de ce fichier */
    Cconws ("Fichier introuvable!");
  else
  {
    non_std_handle = Fdup (STDIN); /* Duplication de l'identificateur clavier */
    Fforce (STDIN, handle);          /* Aiguillage de l'entr‚e standard */
                                     /* vers le fichier <handle> */

        entree (string);             /* L'entr‚e vient du fichier... */

        Cconws (string);             /* Affichage de contr“le */

        Fforce (STDIN, non_std_handle);  /* Redirige et */
    Fclose (handle);                     /* ferme le fichier */
  }
    Crawcin();                             /* Touche relƒch‚e */
}

