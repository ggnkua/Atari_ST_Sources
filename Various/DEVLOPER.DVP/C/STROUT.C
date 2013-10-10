/*********************************************************/
/*  Affichage d'un chaåne par la fonction GEMDOS Cconws  */
/*    Megamax Laser C         STROUT.C      */
/*********************************************************/

#include <osbind.h>

char  string[255];

main()
{
  strcpy (string, "\33pL'AFFICHAGE INVERSê \33q ");   /* ESC p = InversÇ */
  strcat (string, "n'est pas un probläme sous GEMDOS!");  /* ESC q = Normal */

  Cconws (string);          /* Affichage du texte prÇparÇ */
  Cconin ();                /* Attend la frappe d'une touche */
}


