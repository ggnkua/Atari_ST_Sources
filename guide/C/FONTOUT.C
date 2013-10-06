/****************************************************/
/*   Affichage de la police compläte avec Bconout   */
/*   Megamax Laser C     FONTOUT.C                  */
/****************************************************/

#include <osbind.h>     /* DÇfinitions pour GEMDOS, BIOS et XBIOS */
#define  console 2
#define  ascii   5

int  i;

main()
{
  for (i=0; i<256; i++)
  {
    if (i % 16 == 0)            /* nouvelle ligne tous les 16 caractäres */
    {
      Bconout (console, 13);    /* Retour Chariot */
      Bconout (console, 10);    /* Saut de ligne */
    }
    Bconout (ascii, i);         /* Affichage proprement dit */
    Bconout (ascii, ' ');       /* Espaces entre les caractäres */
  }
    printf ("\n\n\nLa police de caractäres de l'ATARI ST\n"); 
    Bconin (console);             /* Attente de l'appui d'une touche...*/
}

